SHELL:=/bin/bash

RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
NC=\033[0m

ENV_PATH = ./env/$(ENV)
TF_PATH = $(ENV_PATH)/terraform

ENV_FILE = $(ENV_PATH)/global.env
SECRET_ENV_FILE = $(ENV_PATH)/secrets.env


include $(ENV_FILE)

.SILENT:  cloud-resource-deploy cloud-resource-destroy verify-env print-env confirm build-all-containers configure-all cloud-resource-plan
.ONESHELL: cloud-resource-plan cloud-resource-deploy cloud-resource-destroy verify-env print-env confirm build-all-containers

clean:
	rm -rf ./env/stage/terraform/tf-plan
	rm -rf ./env/prod/terraform/tf-plan
	rm -rf venv
	rm -f *.pyc
	rm -rf __pycache__/
	rm -f ./.env

clean-all:
	cd api/pipeline-task && make clean && cd ../../
	cd site && make clean && cd ../
	cd img-thumb-gen && make clean && cd ../

dev-env:
	docker build . -t caendr-builder

dev:
	docker run -p 8080:8080 \
		-v $(PWD):/caendr:rw \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-it caendr-builder /bin/bash 

build-all-containers:
	cd api/pipeline-task && make build-container ENV=$(ENV) VERSION=$(MODULE_API_PIPELINE_TASK_CONTAINER_VERSION)
	cd site && make build-container ENV=$(ENV) VERSION=$(MODULE_SITE_CONTAINER_VERSION)

publish-all-containers:
	cd api/pipeline-task && make publish-container ENV=$(ENV) VERSION=$(MODULE_API_PIPELINE_TASK_CONTAINER_VERSION)
	cd site && make publish-container ENV=$(ENV) VERSION=$(MODULE_SITE_CONTAINER_VERSION)

configure-all: verify-env print-env confirm
	cd api/pipeline-task && make configure ENV=$(ENV) && cd ../../
	cd site && make configure ENV=$(ENV) && cd ../
	cd img-thumb-gen && make configure ENV=$(ENV) && cd ../
	
	echo -e "\n**********************************************************************************"
	echo -e "*              $(GREEN)Global Environment Configuration Complete!$(NC)                        *"
	echo -e "**********************************************************************************\n"

cloud-resource-plan: configure-all
	gcloud config set project ${GOOGLE_CLOUD_PROJECT_NAME}
	export $$(cat $(ENV_FILE) | xargs) && \
	while IFS= read -r line; do export TF_VAR_$$line; done < $(ENV_FILE) && \
	while IFS= read -r line; do export TF_VAR_$$line; done < $(SECRET_ENV_FILE) && \
	cd $(TF_PATH) && terraform init && terraform plan -out tf-plan && \
	echo -e "\n\nType 'make cloud-resource-deploy ENV=$(ENV)' to apply the terraform plan\n" 

cloud-resource-deploy: cloud-resource-plan
	echo -e "\nContinue (y/N)?\n" 
	read CONFIRM
	if [ "$$CONFIRM" != "y" ]; then
		exit 1
	fi
	cd $(TF_PATH) && terraform apply "tf-plan"

cloud-resource-destroy: verify-env print-env confirm
	gcloud config set project ${GOOGLE_CLOUD_PROJECT_NAME}
	export $$(cat $(ENV_FILE) | xargs) && \
	while IFS= read -r line; do export TF_VAR_$$line; done < $(ENV_FILE) && \
	while IFS= read -r line; do export TF_VAR_$$line; done < $(SECRET_ENV_FILE) && \
	cd $(TF_PATH) && terraform init && terraform destroy

verify-env:
ifeq ($(ENV),)
	echo -e "$(RED)Environment argument is required!$(NC)\nPlease include 'ENV=stage' or 'ENV=prod' in your 'make' command\n"
	exit 1
else
	echo -e "\n*************************************************************************************************************************"
	echo -e "*		SERVICE:     $(YELLOW)Global$(NC)"
	echo -e "*		ENVIRONMENT: $(RED)$(ENV)$(NC)"
	echo -e "*************************************************************************************************************************\n"
endif

print-env:
	echo -e "Global Environment Configuration:\n"
	cat $(ENV_FILE)

confirm:
	echo -e "\n\nPress 'Enter' to continue or 'Ctrl + C' to cancel\n" 
	read CONFIRM


%:
	@:
