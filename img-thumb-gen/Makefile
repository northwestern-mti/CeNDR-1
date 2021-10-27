SHELL := /bin/bash

RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
NC=\033[0m

ENV_PATH = ../env/$(ENV)
ENV_FILE = ../env/$(ENV)/.env

include $(ENV_FILE)
include service.env

.SILENT: configure verify-env verify-ver print-env confirm env-file dev
.ONESHELL: configure cloudbuild venv run build confirm dev

clean:	
	rm -f ./.env

env-file:
	# Apply global env config to service level .env file
	echo "Writing .env file... "
	rm -rf .env
	cat $(ENV_FILE) >> .env
	cat service.env >> .env
	echo -e "DONE\n"

pkg-dir:
	echo -e "DONE\n"

verify-env:
ifeq ($(ENV),)
	echo -e "$(RED)Environment argument is required!$(NC)\nPlease include 'ENV=stage' or 'ENV=prod' in your 'make' command\n"
	exit 1
else
	echo -e "\n*************************************************************************************************************************"
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
