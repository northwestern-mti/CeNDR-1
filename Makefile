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

.SILENT: confirm-env configure cloud-resource-plan cloud-resource-deploy cloud-resource-destroy verify-env print-env confirm
.ONESHELL: configure cloud-resource-plan cloud-resource-deploy cloud-resource-destroy verify-env print-env confirm

clean:
	rm -rf ./env/stage/terraform/tf-plan
	rm -rf ./env/prod/terraform/tf-plan
	rm -rf venv
	rm -f *.pyc
	rm -rf __pycache__/
	rm -f ./.env

dev-env:
	docker build . -t cendr-builder

dev:
	docker run -p 8080:8080 \
		-v $(PWD):/caendr:rw \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-it cendr-builder /bin/bash 

cloud-resource-plan: verify-env print-env confirm
	gcloud config set project ${GOOGLE_CLOUD_PROJECT_NAME}
	export $$(cat $(ENV_FILE) | xargs)
	while IFS= read -r line; do
		export TF_VAR_$$line
	done < $(ENV_FILE)
	cd $(ENV_PATH)/terraform && terraform init && terraform plan -var-file $(PWD)/$(TF_SECRETS) -out tf-plan

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
	echo -e "\n\n"
ifeq ($(ENV),)
	echo -e "$(RED)Environment argument is required!$(NC)\nPlease include 'ENV=stage' or 'ENV=prod' in your 'make' command\n"
	exit 1
else
	echo -e "ENVIRONMENT: $(RED)$(ENV)$(NC)\n\n"
endif

print-env:
	echo -e "Global Environment Configuration:\n"
	cat $(ENV_FILE)

confirm:
	echo -e "\n\nPress any key to continue or ctrl + C to cancel\n" 
	read CONFIRM



%:
	@:
