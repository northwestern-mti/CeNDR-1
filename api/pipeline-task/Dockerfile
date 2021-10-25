# Use the official lightweight Python image.
FROM python:3.9-slim

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./

ENV PORT 8080

# Install production dependencies.
RUN apt-get update && \
    apt-get upgrade && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        virtualenv \
        python3-virtualenv && \
    apt-get autoremove && \
    apt-get clean

# make venv
RUN virtualenv --python=python3 venv
RUN venv/bin/python -m pip install --upgrade pip
RUN venv/bin/pip install --no-cache-dir -r requirements.txt

# load .env file to environment variables
RUN export $(cat .env | xargs)
RUN venv/bin/activate

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
