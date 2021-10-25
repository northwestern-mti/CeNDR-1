FROM gcr.io/google-appengine/python

# Install production dependencies.
RUN apt-get update && \
    apt-get upgrade && \
    apt-get install -y --no-install-recommends \
        gunicorn \
        python3 \
        python3-venv \
        python3-dev \
        virtualenv \
        python3-virtualenv \
        build-essential \
        ca-certificates \
        curl \
        git \
        libncursesw5-dev \
        libncurses5-dev \
        make \
        zlib1g-dev \
        libbz2-dev \
        liblzma-dev \
        fuse \
        tabix \
        graphviz \
        libgraphviz-dev \
        pkg-config \
        libxml2 \
        xmlsec1 \
        libxml2-dev \
        libxmlsec1-dev \
        libxmlsec1-openssl && \
    apt-get autoremove && \
    apt-get clean

# Copy local code to container image
ENV APP_HOME /site
WORKDIR $APP_HOME
COPY . ./

# make venv
RUN virtualenv --python=python3 venv
ENV VIRTUAL_ENV=$APP_HOME/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install python modules from pip
RUN python -m pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

RUN FLASK_APP=main:app GAE_VERSION=blank-blank flask

CMD export $(cat .env | xargs) && gunicorn -b :$PORT main:app
