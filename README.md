# CeNDR

`CeNDR` is the code used to run the [_Caenorhabditis elegans_ Natural Diversity Resource](https://www.elegansvariation.org) website.

Initial Setup:

Create a project on Google Cloud and [create a service account](https://console.cloud.google.com/iam-admin/serviceaccounts/create) for terraform.
Verify that you are working inside of the project that you just created.
Enter 'terraform-service-account' in the 'Service account name' field, then click 'Create and Continue'
Select the 'Owner' role from 'Quick access/Basic' then click 'continue'
Click 'Done' 
From the list of [service accounts](https://console.cloud.google.com/iam-admin/serviceaccounts) click the 'Actions' column for terraform-service-account and then 'Manage Keys'
Click 'Add Key' -> 'Create New Key' and select 'JSON' for the Key type
Save the key file as 'terraform-service-account.json'


Duplicate one of the existing 'env' directories and rename it. (ie: dev, stage, prod, etc..)
Remove these files from the terraform directory:
.terraform.lock.hcl
.terraform.tfstate.lock.info
terraform.tfstate
terraform.tfstate.backup

Update the .env file to target the project that you just created.
Move 'terraform-service-account.json' to the terraform folder inside of the new env directory you just created (ie: env/dev/terraform/terraform-service-account.json)


Building Service Containers:
When deploying to a new Google Cloud Project for the first time, you must build the containers for each service and push them to the Google Container Registry for that project. This command automatically builds the containers for each service and tags them with the version numbers defined in the .env file from the corresponding env directory
make build-all-containers ENV=$(ENV)



The Dockerfile in the root directory defines a container which can be used for development. It includes tools like the google-cloud-sdk, terraform, python, and more. To build the container run:
make dev-env

To start the container and mount the current directory inside of the container on /cendr:
make dev

Authenticate with Google Cloud:
gcloud init
gcloud auth login
gcloud config set project PROJECT_ID
gcloud auth configure-docker

Remove any files that were automatically generated based on the environment configuration file (ie: env/stage/.env)
make clean

To generate the terraform infrastructure changes to be implemented for an environment:
make cloud-resource-plan ENV=stage

deploy cloud resources:
make cloud-resource-plan ENV=stage

To provision cloud resources you must include definitions for Cloud Secret Store values in env/(ENVIRONMENT)/terraform/secret.tfvars