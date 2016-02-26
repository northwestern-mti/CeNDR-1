import os
import csv
import logging
from flask import *
from flask import Flask
from flask_debugtoolbar import DebugToolbarExtension
import sys
from peewee import *
from playhouse import *
from slugify import slugify
import hashlib
from collections import OrderedDict
from models import *
import stripe
import itertools
import markdown
from datetime import date, datetime
import dateutil
from werkzeug.contrib.atom import AtomFeed
from urlparse import urljoin
from message import *
import yaml
import webapp2
from google.appengine.api import mail
import smtplib
import pytz
from iron_mq import *
import requests
from google.appengine.api import mail
from emails import *

# Fetch credentials
from gcloud import datastore
from gcloud import storage
ds = datastore.Client(project = "andersen-lab")

def get_queue():
    iron_credentials = ds.get(ds.key("credential", "iron"))
    return IronMQ(**dict(iron_credentials)).queue("cegwas-map")

def make_external(url):
    return urljoin(request.url_root, url)

def json_serial(obj):
    """JSON serializer for objects not serializable by default json code"""

    if isinstance(obj, date):
        serial = obj.isoformat()
        return serial
    raise TypeError("Type not serializable")


stripe_keys = {
    'secret_key': "sk_test_1fmlHofOFzwqoxkPoP3E4RQ9",
    'publishable_key': "pk_test_fM3QofdBu9WCRvCkFIx8wgPl"
}

stripe.api_key = "sk_test_1fmlHofOFzwqoxkPoP3E4RQ9"


app = Flask(__name__, static_url_path='/static')
app.config['SECRET_KEY'] = os.getenv("SECRET_KEY")
app.config['DEBUG_TB_INTERCEPT_REDIRECTS'] = False
if os.getenv('SERVER_SOFTWARE') and \
        os.getenv('SERVER_SOFTWARE').startswith('Google App Engine/'):
    app.debug = False
else:
    app.debug = True
    app.config['SECRET_KEY'] = "test"
    toolbar = DebugToolbarExtension(app)


def render_markdown(filename, directory="static/content/markdown/"):
    with open(directory + filename) as f:
        return Markup(markdown.markdown(f.read()))


@app.context_processor
def utility_processor():
    def render_markdown(filename, directory="static/content/markdown/"):
        with open(directory + filename) as f:
            return Markup(markdown.markdown(f.read()))
    return dict(render_markdown=render_markdown)

@app.template_filter('format_datetime')
def format_datetime(value):
    try:
        return dateutil.parser.parse(value).strftime('%Y-%m-%d / %I:%M %p')
    except:
        pass


@app.route('/')
def main():
    page_title = "Caenorhabditis elegans Natural Diversity Resource"
    files = [x for x in os.listdir("static/content/news/") if x.startswith(".") is False]
    files.reverse()
    # latest mappings
    latest_mappings = list(report.filter(report.release == 0).join(trait).order_by(trait.submission_complete.desc()).limit(5).select(report, trait).distinct().dicts().execute())
    return render_template('home.html', **locals())


@app.route('/strain/global-strain-map/')
def map_page():
    title = "Global Strain Map"
    bcs = OrderedDict([("strain", "/strain/"), ("global-strain-map", None)])
    strain_list_dicts = []
    strain_listing = list(strain.select().filter(strain.isotype.is_null() == False).filter(
        strain.latitude.is_null() == False).execute())
    strain_listing = json.dumps([x.__dict__["_data"] for x in strain_listing], default=json_serial)
    return render_template('map.html', **locals())


@app.route('/data/')
def data_page():
    bcs = OrderedDict([("data", None)])
    title = "Data"
    current_variant_set = "20160106"
    strain_listing = strain.select().filter(strain.isotype != None).order_by(strain.isotype).execute()
    return render_template('data.html', **locals())


@app.route('/data/browser')
def genome_browser():
    bcs = OrderedDict([("data", 'Browser')])
    title = "Browser"
    return render_template('browser.html', **locals())


@app.route('/data/download/<filetype>.sh')
def download_script(filetype):
    strain_listing = strain.select().filter(strain.isotype != None).order_by(strain.isotype).execute()
    download_page = render_template('download_script.sh', **locals())
    response= make_response(download_page)
    response.headers["Content-Type"] = "text/plain" 
    return response


@app.route('/genetic-mapping/submit/')
def gwa():
    title = "Perform Mapping"
    bcs = OrderedDict([("genetic-mapping", None), ("perform-mapping", None)])

    # Generate list of allowable strains
    query = strain.select(strain.strain,
                          strain.isotype,
                          strain.previous_names).filter(strain.isotype.is_null() == False).execute()
    qresults = list(itertools.chain(*[[x.strain, x.isotype, x.previous_names] for x in query]))
    qresults = set([x for x in qresults if x != None])
    qresults = list(itertools.chain(*[x.split("|") for x in qresults]))

    strain_list = json.dumps(qresults)
    return render_template('gwa.html', **locals())


def valid_url(url, encrypt):
    url_out = slugify(url)
    if report.filter(report.report_slug == url_out).count() > 0:
        return {'error': "Report name reserved."}
    if encrypt:
        url_out = str(hashlib.sha224(url_out).hexdigest()[0:20])
    if len(url_out) > 40:
        return {'error': "Report name may not be > 40 characters."}
    else:
        return url_out

def report_namecheck(report_name):
    report_slug = slugify(report_name)
    report_hash = str(hashlib.sha224(report_slug).hexdigest()[0:20])
    if report.filter(report.report_slug == report_slug).count() > 0:
        return {'error': "Report name reserved."}
    if len(report_slug) > 40:
        return {'error': "Report name may not be > 40 characters."}
    else:
        return {"report_slug": report_slug, "report_hash": report_hash}


@app.route('/process_gwa/', methods=['POST'])
def process_gwa():
    release_dict = {"public": 0, "embargo12": 1,  "private": 2}
    title = "Run Association"
    req = request.get_json()

    queue = get_queue()

    # Add Validation
    rep_names = report_namecheck(req["report_name"])
    req["report_slug"] = rep_names["report_slug"]
    req["report_hash"] = rep_names["report_hash"]
    data = req["trait_data"]
    del req["trait_data"]
    req["release"] = release_dict[req["release"]]
    req["version"] = 1
    trait_names = data[0][1:]
    strain_set = []
    trait_keep = []
    with db.atomic():
        report_rec = report(**req)
        report_rec.save()
        trait_data = []

        for row in data[1:]:
            if row[0] is not None and row[0] != "":
                row[0] = row[0].replace("(", "\(").replace(")", "\)")
                strain_name = strain.filter((strain.strain == row[0]) |
                                            (strain.isotype == row[0]) |
                                            (strain.previous_names.regexp('^(' + row[0] + ')\|')) |
                                            (strain.previous_names.regexp('\|(' + row[0] + ')$')) |
                                            (strain.previous_names.regexp('\|(' + row[0] + ')\|')) |
                                            (strain.previous_names == row[0]))
                strain_set.append(list(strain_name)[0])

        trait_set = data[0][1:]
        for n, t in enumerate(trait_set):
            trait_vals = [row[n+1] for row in data[1:] if row[n+1] is not None]
            if t is not None and len(trait_vals) > 0:
                submit_time = datetime.now(pytz.timezone("America/Chicago"))
                trait_keep.append(t)
                trait_set[n] = trait.insert(report = report_rec, 
                trait_name = t,
                trait_slug = slugify(t),
                status = "queue",
                submission_date = submit_time).execute()
            else:
                trait_set[n] = None
        for col, t in enumerate(trait_set):
            for row, s in enumerate(strain_set):
                if t is not None and s is not None and data[1:][row][col+1]:
                    trait_data.append({"trait": t,
                               "strain": s,
                               "value": autoconvert(data[1:][row][col+1])})
        trait_value.insert_many(trait_data).execute()
    for t in trait_keep:
        req["trait_name"] = t
        req["trait_slug"] = slugify(t)
        req["submission_date"] = datetime.now(pytz.timezone("America/Chicago")).isoformat()
        # Submit job to iron worker
        resp = queue.post(str(json.dumps(req)))
        req["success"] = True
        # Send user email
    mail.send_mail(sender="CeNDR <andersen-lab@appspot.gserviceaccount.com>",
              to=req["email"],
              subject="CeNDR Mapping Report - " + req["report_slug"],
              body=mapping_submission.format(report_slug=req["report_slug"]))

    return str(json.dumps(req))

@app.route('/validate_url/', methods=['POST'])
def validate_url():
    """
        Generates URLs from report names and validates them.
    """
    req = request.get_json()
    return json.dumps(report_namecheck(req["report_name"]))


@app.route('/Genetic-Mapping/public/')
def public_mapping():
    title = "Perform Mapping"
    bcs = OrderedDict([("genetic-mapping", None), ("public", None)])
    title = "Public Mappings"
    return render_template('public_mapping.html', **locals())


@app.route("/report/<report_slug>/")
@app.route("/report/<report_slug>/<trait_slug>")
def trait_view(report_slug, trait_slug = ""):
    report_data = list(trait.select(trait, report).join(report).where(((report.report_slug == report_slug) & (report.release == 0)) | (report.report_hash == report_slug)).dicts().execute())
    if trait_slug:
        trait_data = [x for x in report_data if x["trait_slug"] == trait_slug][0]
        title = trait_data["report_name"]
        subtitle = trait_data["trait_name"]
        if trait_data["release"] == 0:
            report_url_slug = trait_data["report_slug"]
        else:
            report_url_slug = trait_data["report_hash"]
    else:
        # Redirect to first trait always.
        first_trait = list(report_data)[0]
        return redirect(url_for("trait_view", report_slug = report_slug, trait_slug = first_trait["trait_slug"]))
    base_url = "https://storage.googleapis.com/cendr/" + report_slug + "/" + trait_slug

    # List available datasets
    report_files = list(storage.Client().get_bucket("cendr").list_blobs(prefix = report_slug + "/" + trait_slug + "/tables"))
    report_files = [os.path.split(x.name)[1] for x in report_files]

    report_url = base_url + "/report.html"
    report_html = requests.get(report_url).text.replace('src="', 'src="' + base_url + "/")
    if not report_html.startswith("<?xml"):
        report_html = "<div>" + report_html[report_html.find('<div id="phenotype'):report_html.find("</body>")].replace("</body>", "") 
    else:
        report_html = ""
    return render_template('report.html', **locals())


@app.route('/report_progress/', methods=['POST'])
def report_progress():
    """
        Generates URLs from report names and validates them.
    """
    req = request.get_json()
    current_status = list(trait.select(trait.status)
         .join(report)
         .filter(trait.trait_slug == req["trait_slug"], report.report_slug == req["report_slug"])
         .dicts()
         .execute())[0]["status"]
    return json.dumps(current_status)

@app.route('/about/')
def about():
    title = "About"
    bcs = OrderedDict([("about", "/about/")])
    return render_template('about.html', **locals())


@app.route('/about/staff/')
def staff():
    title = "Staff"
    bcs = OrderedDict([("about", "/about/"), ("staff", "")])
    staff_data = yaml.load(open("static/content/data/staff.yaml", 'r'))
    return render_template('staff.html', **locals())


@app.route('/about/panel/')
def panel():
    title = "Scientific Advisory Panel"
    bcs = OrderedDict([("about", "/about/"), ("panel", "")])
    panel_data = yaml.load(open("static/content/data/advisory-panel.yaml", 'r'))
    return render_template('panel.html', **locals())


@app.route('/genetic-mapping/status/')
def status_page():
    # queue
    bcs = OrderedDict([("genetic-mapping", None), ("status", None)])
    title = "Status"
    queue = get_queue()
    ql = [json.loads(x["body"]) for x in queue.peek(max=20)["messages"]]
    qsize = queue.size()

    from googleapiclient import discovery
    from oauth2client.client import GoogleCredentials
    credentials = GoogleCredentials.get_application_default()
    compute = discovery.build('compute', 'v1', credentials=credentials)

    # Get instance list
    instances = compute.instances().list(project = "andersen-lab", zone = "us-central1-a", filter="status eq RUNNING").execute()
    if 'items' in instances:
        instances = [x["name"] for x in instances["items"]]
    else:
        instances = []
    workers = []
    for w in instances:
        query = ds.query(kind="Worker")
        query.add_filter('full_name', '=', w + ".c.andersen-lab.internal")
        worker_list = list(query.fetch())
        if len(worker_list) > 0:
            workers.append(worker_list[0])

    recently_complete = list(report.select(report, trait).join(trait).order_by(trait.submission_complete.desc()).limit(10).dicts().execute())

    return render_template('status.html', **locals())

@app.route('/about/statistics/')
def statistics():
    title = "Site Statistics"
    bcs = OrderedDict([("about", "/about/"), ("statistics", None)])

    # Collection dates
    collection_dates = list(strain.select().filter(
        strain.isotype != None, strain.isolation_date != None).order_by(strain.isolation_date).execute())

    return render_template('statistics.html', **locals())


@app.route('/strain/')
def strain_listing_page():
    bcs = OrderedDict([("strain", None)])
    title = "Strain Catalog"
    strain_listing = strain.select().filter(strain.isotype != None).order_by(strain.isotype).execute()
    return render_template('strain_catalog.html', **locals())


@app.route('/strain/submit/')
def strain_submission_page():
    bcs = OrderedDict([("strain", "submission")])
    title = "Strain Submission"
    return render_template('strain_submission.html', **locals())


@app.route('/order/', methods=['POST'])
def order_page():
    bcs = OrderedDict([("strain", "/strain/"), ("order", "")])
    title = "Order"
    key = stripe_keys["publishable_key"]
    if 'stripeToken' in request.form:
        total = 500

        customer = stripe.Customer.create(
            email=request.form['stripeEmail'],
            card=request.form['stripeToken']
        )

        charge = stripe.Charge.create(
            customer=customer.id,
            amount=total,
            currency='usd',
            description='Flask Charge'
        )
        order_formatted = {k: autoconvert(v) for k, v in request.form.items()}
        order_formatted["price"] = total
        order_id = order.create(**order_formatted).save()
        return redirect(url_for("order_confirmation", order_id=request.form["stripeToken"][20:]), code=302)
    else:
        ordered = request.form.getlist('strain')
        # Calculate total
        ind_strains = len(ordered) * 1500
        total = ind_strains
        strain_listing = strain.select().where(strain.isotype << ordered).order_by(strain.isotype).execute()
        return render_template('order.html', **locals())


@app.route("/order/<order_id>/")
def order_confirmation(order_id):
    title = "Order: " + order_id
    query = "%" + order_id
    record = order.get(order.stripeToken ** query)
    return render_template('order_confirm.html', **locals())


@app.route('/strain/<isotype_name>/')
def isotype_page(isotype_name):
    page_type = "isotype"
    obj = isotype_name
    rec = list(strain.filter(strain.isotype == isotype_name).order_by(strain.latitude).dicts().execute())
    ref_strain = [x for x in rec if x["strain"] == isotype_name][0]
    strain_json_output = json.dumps([x for x in rec if x["latitude"] != None],  default=json_serial)
    return render_template('strain.html', **locals())


@app.route("/strain/protocols/")
def protocols():
    title = "Protocols"
    bcs = OrderedDict([("strain", "/strain/"), ("protocols", "")])
    protocols = yaml.load(open("static/content/data/protocols.yaml", 'r'))
    return render_template('protocols.html', **locals())


@app.route("/news/")
def news():
    title = "Andersen Lab News"
    files = os.listdir("static/content/news/")
    files.reverse()
    bcs = OrderedDict([("News", "")])
    return render_template('news.html', **locals())


@app.route("/news/<filename>/")
def news_item(filename):
    title = filename[11:].strip(".md").replace("-", " ")
    return render_template('news_item.html', **locals())


@app.route('/feed.atom')
def feed():
    feed = AtomFeed('CNDR News',
                    feed_url=request.url, url=request.url_root)
    files = os.listdir("static/content/news/")
    files.reverse()
    for filename in files:
        filename[11:]
        title = filename[11:].strip(".md").replace("-", " ")
        content = render_markdown(filename, "static/content/news/")
        date_published = datetime.strptime(filename[:10], "%Y-%m-%d")
        feed.add(title, unicode(content),
                 content_type='html',
                 author="CNDR News",
                 url=make_external(url_for("news_item", filename=filename.strip(".md"))),
                 updated=date_published,
                 published=date_published)
    return feed.get_response()


@app.route('/outreach/')
def outreach():
    title = "Outreach"
    bcs = OrderedDict([("outreach", "")])
    return render_template('outreach.html', **locals())

@app.route('/contact-us/')
def contact():
    title = "Contact Us"
    bcs = OrderedDict([("Contact Us", "/contact-us/")])
    return render_template('contact.html', **locals())

@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404
