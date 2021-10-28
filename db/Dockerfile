FROM google/cloud-sdk:slim

ENV PYTHONUNBUFFERED True

# Create mountpoint for UNIX socket connection to cloudsql
VOLUME /cloudsql

# Install production dependencies.
RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        python3-virtualenv \
        virtualenv \
        wget && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create src directory
ENV APP_HOME /db
WORKDIR $APP_HOME

# make venv
RUN virtualenv --python=python3 venv
ENV VIRTUAL_ENV=$APP_HOME/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Setup CloudSQL proxy
RUN wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy && \
    chmod +x cloud_sql_proxy

# Copy local code to the container image.
COPY . ./
RUN chmod +x run.sh

# Install python modules from pip
RUN python -m pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt


