SHELL := /bin/bash

RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
NC=\033[0m

ifeq ($(ENV),"production")
    ENV_FILE = "../../env/prod/.env"
	ENV_PATH = ../../env/prod
	include ../../env/prod/.env
else 
    ENV_FILE = "../../env/stage/.env"
	ENV_PATH = ../../env/stage
	include ../../env/stage/.env
endif

include service.env


.SILENT: configure 
.ONESHELL: configure cloudbuild venv run build

clean:
	rm -rf venv
	rm -f *.pyc
	rm -rf __pycache__/

	rm -f ./.env
	rm -f ./terraform/terraform.tfvars
	rm -f ./cloudbuild.yaml


venv: 
	virtualenv --python=python3 venv
	venv/bin/pip install -r requirements.txt


configure: clean
	echo -e "\n"
	if [ -z "$(ENV)" ]; then 
		echo "Environment argument is required! Please include 'ENV=staging' or 'ENV=production' in your 'make' command"
		exit 1
	fi

	if [ "$(ENV)" = "staging" ]; then 
		echo -e "Environment: $(GREEN)STAGING$(NC)\n"
	fi
	
	if [ "$(ENV)" = "production" ]; then 
		echo -e "Environment: PRODUCTION\n"
	fi

	echo GOOGLE_CLOUD_PROJECT_NAME     = ${GOOGLE_CLOUD_PROJECT_NAME}
	echo GOOGLE_CLOUD_PROJECT_ID       = ${GOOGLE_CLOUD_PROJECT_ID}
	echo GOOGLE_CLOUD_REGION           = ${GOOGLE_CLOUD_REGION}
	echo GOOGLE_CLOUD_SERVICE_ACCOUNT  = ${ENV_PATH}/terraform/${GOOGLE_CLOUD_SERVICE_ACCOUNT}
	echo
	echo GOOGLE_CLOUD_REPORT_BUCKET_NAME = ${GOOGLE_CLOUD_REPORT_BUCKET_NAME}
	echo GOOGLE_CLOUD_WORK_BUCKET_NAME   = ${GOOGLE_CLOUD_WORK_BUCKET_NAME}
	echo

	echo -e "\nContinue (y/N)?\n" 
	read CONFIRM

	if [ "$$CONFIRM" != "y" ]; then
		exit 1
	fi

	# Write terraform config vars file
	echo "Writing .tfvars file... "

	echo nscalc_service_account_name = \"${NSCALC_SERVICE_ACCOUNT_NAME}\" >> ./terraform/terraform.tfvars
	echo nscalc_report_bucket_name = \"${GOOGLE_CLOUD_REPORT_BUCKET_NAME}\" >> ./terraform/terraform.tfvars
	echo nscalc_work_bucket_name = \"${GOOGLE_CLOUD_WORK_BUCKET_NAME}\" >> ./terraform/terraform.tfvars

	echo -e "DONE\n"


	# Apply global env config to service level .env file
	echo "Writing .env file... "

	while IFS= read -r line; do
		printf '%s\n' "$$line" >> .env
	done < $(ENV_FILE)

	# Merge service level env config
	while IFS= read -r line; do
		printf '%s\n' "$$line" >> .env
	done < service.env

	echo -e "DONE\n"


	# write cloudbuild file
	echo "Writing cloudbuild file... "

	echo -e "steps:" >> cloudbuild.yaml;
	echo -e "- name: 'gcr.io/kaniko-project/executor:latest'" >> cloudbuild.yaml;
	echo -e "  args: [--destination=gcr.io/${GOOGLE_CLOUD_PROJECT_NAME}/api-pipeline-task, --cache=true, --cache-ttl=12h]" >> cloudbuild.yaml;
	
	echo -e "DONE\n"


run: venv
	export $(cat $(ENV_FILE) | xargs)
	venv/bin/python main.py

build: configure
	docker build . -t api-pipeline-task

run-container: build
	docker run -v $(shell pwd)/${ENV_PATH}:/env:ro \
  		--env GOOGLE_APPLICATION_CREDENTIALS=/env/terraform/${GOOGLE_CLOUD_SERVICE_ACCOUNT} \
		-i -t api-pipeline-task \

cloudbuild: configure
	gcloud config set project ${GOOGLE_CLOUD_PROJECT_NAME}
	gcloud builds submit --config cloudbuild.yaml . --timeout=3h 

