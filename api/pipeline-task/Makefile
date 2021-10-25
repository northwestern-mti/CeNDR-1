SHELL := /bin/bash

RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
NC=\033[0m

ENV_PATH = ./env/$(ENV)
ENV_FILE = ./env/$(ENV)/.env

include $(ENV_FILE)
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

run: 
	. venv/bin/activate
	export $(cat .env | xargs)
	python main.py

build: configure
	docker build . -t api-pipeline-task

#run-container: build
#docker run -v $(shell pwd)/${ENV_PATH}:/env:ro \
#--env GOOGLE_APPLICATION_CREDENTIALS=/env/terraform/${GOOGLE_CLOUD_SERVICE_ACCOUNT_FILE} \
#-i -t api-pipeline-task \

cloudbuild: configure
	gcloud config set project ${GOOGLE_CLOUD_PROJECT_NAME}
	gcloud builds submit --config cloudbuild.yaml . --timeout=3h 

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
	echo GOOGLE_CLOUD_SERVICE_ACCOUNT_FILE  = ${ENV_PATH}/terraform/${GOOGLE_CLOUD_SERVICE_ACCOUNT_FILE}
	echo
	echo MODULE_API_PIPELINE_TASK_REPORT_BUCKET_NAME = ${MODULE_API_PIPELINE_TASK_REPORT_BUCKET_NAME}
	echo MODULE_API_PIPELINE_TASK_WORK_BUCKET_NAME   = ${MODULE_API_PIPELINE_TASK_WORK_BUCKET_NAME}
	echo

	echo -e "\nContinue (y/N)?\n" 
	read CONFIRM

	if [ "$$CONFIRM" != "y" ]; then
		exit 1
	fi

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
