# Use the official lightweight Python image.
FROM python:3.9-slim

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Install production dependencies.
RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        virtualenv \
        python3-virtualenv && \
    apt-get autoremove && \
    apt-get clean

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./

# make venv
RUN virtualenv --python=python3 venv
ENV VIRTUAL_ENV=$APP_HOME/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install python modules from pip
RUN python -m pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.
CMD export PYTHONPATH=${PKG_HOME} && \
    export $(cat .env | xargs) && \
    exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
