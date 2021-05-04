# This directory contains the code to start the Google Cloud Run Microservice for the Heritability Tool

Build using:

gcloud config set project andersen-lab
gcloud builds submit --config cloudbuild.yaml . --timeout=3H  --machine-type=N1_HIGHCPU_8
gcloud run deploy --image gcr.io/andersen-lab/h2-1 --memory 1024Mi --platform managed h2-1
