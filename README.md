# CeNDR

`CeNDR` is the code used to run the [_Caenorhabditis elegans_ Natural Diversity Resource](https://www.elegansvariation.org) website.

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