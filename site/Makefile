SHELL := /bin/bash

RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
NC=\033[0m

ifeq ($(ENV),"production")
  ENV_FILE = ../env/prod/.env
	ENV_PATH = ../env/prod
	include ../env/prod/.env
else 
  ENV_FILE = ../env/stage/.env
	ENV_PATH = ../env/stage
	include ../env/stage/.env
endif

include service.env

.SILENT: configure verify-env verify-ver print-env confirm env-file
.ONESHELL: configure cloudbuild venv run build confirm


clean:
	rm -rf venv
	rm -f *.pyc
	rm -rf __pycache__/
	rm -f ./.env

venv: 
	virtualenv --python=python3 venv
	venv/bin/python -m pip install --upgrade pip
	venv/bin/pip install -r requirements.txt

debug:
	. venv/bin/activate && export $$(cat .env | xargs) && FLASK_RUN_PORT=${PORT} flask run --host=0.0.0.0

run-container:verify-env verify-ver
		docker run -p 8080:8080 \
		-it gcr.io/${GOOGLE_CLOUD_PROJECT_NAME}/${MODULE_SITE_CONTAINER_NAME}:${VERSION} /bin/bash
	
build: verify-env verify-ver clean env-file
	docker build . -t gcr.io/${GOOGLE_CLOUD_PROJECT_NAME}/${MODULE_SITE_CONTAINER_NAME}:${VERSION}

publish:
	docker push gcr.io/${GOOGLE_CLOUD_PROJECT_NAME}/${MODULE_SITE_CONTAINER_NAME}:${VERSION}

configure: clean verify-env verify-ver print-env confirm venv env-file
	echo

env-file:
	# Apply global env config to service level .env file
	echo "Writing .env file... "
	rm -rf .env
	cat $(ENV_FILE) >> .env
	cat service.env >> .env
	echo -e "DONE\n"

verify-env:
	echo -e "\n\n"
ifeq ($(ENV),)
	echo -e "$(RED)Environment argument is required!$(NC)\nPlease include 'ENV=stage' or 'ENV=prod' in your 'make' command\n"
	exit 1
else
	echo -e "ENVIRONMENT: $(RED)$(ENV)$(NC)\n\n"
endif

verify-ver:
ifeq ($(VERSION),)
	echo -e "$(RED)Container version tag is required!$(NC)\nPlease include 'VERSION=XXXX' (ie: VERSION=v1.01) in your 'make' command\n"
	exit 1
else
	echo -e "\nCONTAINER: $(GREEN)gcr.io/${GOOGLE_CLOUD_PROJECT_NAME}/${MODULE_SITE_CONTAINER_NAME}:${VERSION}$(NC)\n\n"
endif

print-env:
	echo -e "Global Environment Configuration:\n"
	cat $(ENV_FILE)
	echo -e "\nService Environment Configuration:\n"
	cat service.env

confirm:
	echo -e "\n\nPress any key to continue or ctrl + C to cancel\n" 
	read CONFIRM
