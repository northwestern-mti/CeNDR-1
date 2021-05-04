# This directory contains the code to start the Google Cloud Run Microservice for the Indel Primer Tool

Build using:

gcloud config set project andersen-lab
gcloud builds submit --config cloudbuild.yaml . --timeout=3h --machine-type=N1_HIGHCPU_8
gcloud run deploy --image gcr.io/andersen-lab/indel_primer_2 --platform managed indel-primer-2
