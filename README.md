# CeNDR

`CeNDR` is the code used to run the [_Caenorhabditis elegans_ Natural Diversity Resource](https://www.elegansvariation.org) website.


Remove any files that were automatically generated based on the environment configuration file (ie: env/stage/.env)

make clean


Generate terraform configuration details and per-service static .env files for the specified environment (ie: staging, production):

make configure ENV="staging"


deploy cloud resources:

make cloud-resource-plan ENV=staging

requirements:

google cloud sdk:

sudo apt-get update
sudo apt-get install google-cloud-sdk
sudo apt-get install google-cloud-sdk-cloud-build-local

cloud-build-local --config=[BUILD_CONFIG] --dryrun=false --push [SOURCE_CODE]



google-cloud-sdk-app-engine-python
google-cloud-sdk-pubsub-emulator
google-cloud-sdk-cloud-build-local


gcloud init
gcloud config set project PROJECT_ID
gcloud auth configure-docker


gcloud auth activate-service-account ACCOUNT --key-file=KEY-FILE
