SHELL:=/bin/bash

RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
NC=\033[0m

ENV_PATH = ./env/$(ENV)
ENV_FILE = ./env/$(ENV)/.env
TF_VARS = $(ENV_PATH)/terraform/terraform.tfvars
TF_SECRETS = $(ENV_PATH)/terraform/secret.tfvars

include $(ENV_FILE)

.SILENT: cloud-resource-plan cloud-resource-deploy cloud-resource-destroy verify-env print-env confirm build-all-containers
.ONESHELL: cloud-resource-plan cloud-resource-deploy cloud-resource-destroy verify-env print-env confirm build-all-containers

clean:
	rm -rf ./env/stage/terraform/tf-plan
	rm -rf ./env/prod/terraform/tf-plan
	rm -rf venv
	rm -f *.pyc
	rm -rf __pycache__/
	rm -f ./.env

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
	cd api/pipeline-task && make clean env-file pkg-dir ENV=$(ENV) && cd ../../
	cd site && make clean env-file pkg-dir ENV=$(ENV) && cd ../
	cd img-thumb-gen && make clean env-file pkg-dir ENV=$(ENV)  && cd ../

cloud-resource-plan: configure-all
	gcloud config set project ${GOOGLE_CLOUD_PROJECT_NAME}
	export $$(cat $(ENV_FILE) | xargs)
	while IFS= read -r line; do
		export TF_VAR_$$line
	done < $(ENV_FILE)
	cd $(ENV_PATH)/terraform && terraform init && terraform plan -var-file $(PWD)/$(TF_SECRETS) -out tf-plan
	echo -e "\n\nType 'make cloud-resource-deploy ENV=$(ENV)' to apply the terraform plan\n" 

cloud-resource-deploy: cloud-resource-plan
	echo -e "\nContinue (y/N)?\n" 
	read CONFIRM
	if [ "$$CONFIRM" != "y" ]; then
		exit 1
	fi
	cd $(ENV_PATH)/terraform && terraform apply "tf-plan"

cloud-resource-destroy: verify-env print-env confirm
	gcloud config set project ${GOOGLE_CLOUD_PROJECT_NAME}
	export $$(cat $(ENV_FILE) | xargs)
	while IFS= read -r line; do
		export TF_VAR_$$line
	done < $(ENV_FILE)
	cd $(ENV_PATH)/terraform && terraform init && terraform destroy -var-file $(PWD)/$(TF_SECRETS)

verify-env:
ifeq ($(ENV),)
	echo -e "$(RED)Environment argument is required!$(NC)\nPlease include 'ENV=stage' or 'ENV=prod' in your 'make' command\n"
	exit 1
else
	echo -e "\n*************************************************************************************************************************"
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
