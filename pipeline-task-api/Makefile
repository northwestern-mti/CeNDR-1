venv:
	virtualenv --python=python3 venv
	venv/bin/pip install -r requirements.txt
	export FLASK_ENV=development

run:
	venv/bin/python main.py

clean:
	rm -rf venv
	rm -f *.pyc
	rm -rf __pycache__/

cloudbuild-stage:
	gcloud config set project andersen-lab-302418
	gcloud builds submit --config ./envs/stage/cloudbuild.yaml . --timeout=3h 

cloudbuild-prod:
	gcloud config set project andersen-lab
	gcloud builds submit --config ./envs/prod/cloudbuild.yaml . --timeout=3h 

tf-plan-stage:
	cd ./envs/stage/terraform && terraform plan

tf-apply-stage:
	cd ./envs/stage/terraform && terraform apply