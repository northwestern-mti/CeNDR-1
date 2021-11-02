SHELL := /bin/bash

RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
NC=\033[0m

ENV_PATH = ../env/$(ENV)
TF_PATH = $(ENV_PATH)/terraform

ENV_FILE = $(ENV_PATH)/global.env

include $(ENV_FILE)
include service.env

.SILENT: configure verify-env verify-ver print-env confirm env-file dev
.ONESHELL: configure cloudbuild venv run build confirm dev

clean:
	rm -rf ./venv
	rm -f *.pyc
	rm -rf ./__pycache__/
	rm -rf ./base/__pycache__/
	rm -rf ./base/*.pyc
	rm -rf ./base/static/__pycache__/
	rm -rf ./base/static/*.pyc
	rm -rf ./base/utils/__pycache__/
	rm -rf ./base/utils/*.pyc
	rm -rf ./base/views/__pycache__/
	rm -rf ./base/views/*.pyc
	rm -rf ./base/views/admin/__pycache__/
	rm -rf ./base/views/admin/*.pyc
	rm -rf ./base/views/api/__pycache__/
	rm -rf ./base/views/api/*.pyc
	rm -rf ./base/views/auth/__pycache__/
	rm -rf ./base/views/auth/*.pyc
	rm -rf ./base/views/tools/__pycache__/
	rm -rf ./base/views/tools/*.pyc
	rm -rf ./services/__pycache__/
	rm -rf ./services/*.pyc
	rm -f ./.env
	rm -rf ./caendr

dev-env: verify-env print-env confirm env-file pkg-dir
	virtualenv --python=python3 venv
	venv/bin/python -m pip install --upgrade pip
	venv/bin/pip install -r requirements.txt

dev: dev-env
	. venv/bin/activate && \
	export $$(cat .env | xargs) && \
	export GOOGLE_APPLICATION_CREDENTIALS=$(TF_PATH)/terraform-service-account.json && \
	FLASK_RUN_PORT=${PORT} flask run --host=0.0.0.0
	
build-container: verify-env verify-ver print-env confirm clean env-file pkg-dir
	docker build . -t gcr.io/${GOOGLE_CLOUD_PROJECT_NAME}/${MODULE_SITE_CONTAINER_NAME}:${VERSION}

publish-container: 
	docker push gcr.io/${GOOGLE_CLOUD_PROJECT_NAME}/${MODULE_SITE_CONTAINER_NAME}:${VERSION}

configure: verify-env clean env-file pkg-dir

build-container-tf:configure
	docker build . -t ${CONTAINER_TAG}

publish-container-tf:build-container-tf
	docker push ${CONTAINER_TAG}

pkg-dir:
	cp -rf ../shared/caendr ./caendr

env-file:
	# Apply global env config to service level .env file
	echo -e "\nWriting .env file... "
	rm -rf .env
	cat $(ENV_FILE) >> .env
	cat service.env >> .env
	echo -e "$(GREEN)DONE!$(NC)\n"

verify-env:
ifeq ($(ENV),)
	echo -e "$(RED)Environment argument is required!$(NC)\nPlease include 'ENV=stage' or 'ENV=prod' in your 'make' command\n"
	exit 1
else
	echo -e "\n*************************************************************************************************************************"
	echo -e "*		SERVICE:     $(YELLOW)Site$(NC)"
	echo -e "*		ENVIRONMENT: $(RED)$(ENV)$(NC)"
	echo -e "*************************************************************************************************************************"
endif

verify-ver:
ifeq ($(VERSION),)
	echo -e "$(RED)Container version tag is required!$(NC)\nPlease include 'VERSION=XXXX' (ie: VERSION=v1.01) in your 'make' command\n"
	exit 1
else
	echo -e "*************************************************************************************************************************"
	echo -e "*		CONTAINER:   $(GREEN)gcr.io/${GOOGLE_CLOUD_PROJECT_NAME}/${MODULE_SITE_CONTAINER_NAME}:${VERSION}$(NC)"
	echo -e "*************************************************************************************************************************\n"
endif

print-env:
	echo -e "Global Environment Configuration:\n"
	cat $(ENV_FILE)
	echo -e "\nService Environment Configuration:\n"
	cat service.env

confirm:
	echo -e "\n\nPress 'Enter' to continue or 'Ctrl + C' to cancel\n" 
	read CONFIRM
