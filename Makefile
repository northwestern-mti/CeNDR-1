SHELL := /bin/bash

RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
NC=\033[0m

ifeq ($(ENV),"production")
    ENV_PATH = "./env/prod"
	include ./env/prod/.env
else 
    ENV_PATH = "./env/stage"
	include ./env/stage/.env
endif

.SILENT: configure cloud-resource-plan cloud-resource-deploy
.ONESHELL: configure cloud-resource-plan cloud-resource-deploy

clean:
	rm -rf ./env/stage/terraform/terraform.tfvars
	rm -rf ./env/stage/terraform/tf-plan

	rm -rf ./env/prod/terraform/terraform.tfvars
	rm -rf ./env/prod/terraform/tf-plan


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
		echo -e "Environment: $(RED)PRODUCTION\n"
	fi

	echo GOOGLE_CLOUD_PROJECT_NAME       = ${GOOGLE_CLOUD_PROJECT_NAME}
	echo GOOGLE_CLOUD_PROJECT_ID         = ${GOOGLE_CLOUD_PROJECT_ID}
	echo GOOGLE_CLOUD_REGION             = ${GOOGLE_CLOUD_REGION}
	echo GOOGLE_CLOUD_SERVICE_ACCOUNT    = ${GOOGLE_CLOUD_SERVICE_ACCOUNT}
	echo
	echo GOOGLE_CLOUD_REPORT_BUCKET_NAME = ${GOOGLE_CLOUD_REPORT_BUCKET_NAME}
	echo GOOGLE_CLOUD_WORK_BUCKET_NAME   = ${GOOGLE_CLOUD_WORK_BUCKET_NAME}
	echo

	echo FLASK_ENV                       = ${FLASK_ENV}

	echo -e "\nContinue (y/N)?\n" 
	read CONFIRM

	if [ "$$CONFIRM" != "y" ]; then
		exit 1
	fi


	echo -e "Writing .tfvars file...\n"

	echo gcp_project = \"${GOOGLE_CLOUD_PROJECT_NAME}\" >> $(ENV_PATH)/terraform/terraform.tfvars
	echo gcp_project_id = \"${GOOGLE_CLOUD_PROJECT_ID}\" >> $(ENV_PATH)/terraform/terraform.tfvars
	echo gcp_region = \"${GOOGLE_CLOUD_REGION}\" >> $(ENV_PATH)/terraform/terraform.tfvars
	echo gcp_auth_file = \"${GOOGLE_CLOUD_SERVICE_ACCOUNT}\" >> $(ENV_PATH)/terraform/terraform.tfvars
	echo gcp_report_bucket_name = \"${GOOGLE_CLOUD_REPORT_BUCKET_NAME}\" >> $(ENV_PATH)/terraform/terraform.tfvars
	echo gcp_work_bucket_name = \"${GOOGLE_CLOUD_WORK_BUCKET_NAME}\" >> $(ENV_PATH)/terraform/terraform.tfvars
	echo environment = \"${FLASK_ENV}\" >> $(ENV_PATH)/terraform/terraform.tfvars

	echo -e "DONE\n"



cloud-resource-plan: clean configure
	gcloud config set project ${GOOGLE_CLOUD_PROJECT_NAME}
	cd $(value ENV_PATH)/terraform && terraform init && terraform plan -out tf-plan


cloud-resource-deploy:
	gcloud config set project ${GOOGLE_CLOUD_PROJECT_NAME}
	cd $(value ENV_PATH)/terraform && terraform apply "tf-plan"


%:
	@:  