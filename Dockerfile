FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade && \
    apt-get -y install  --no-install-recommends \
        python3 python3-venv python3-dev virtualenv python3-virtualenv build-essential \
        gunicorn ca-certificates curl git libncursesw5-dev libncurses5-dev zlib1g-dev \
        libbz2-dev liblzma-dev fuse tabix graphviz libgraphviz-dev pkg-config libxml2 \
        xmlsec1 libxml2-dev libxmlsec1-dev libxmlsec1-openssl wget unzip gnupg docker.io && \
    apt-get autoremove && \
    apt-get clean

# Install Google Cloud SDK
RUN curl -sSL https://sdk.cloud.google.com > /tmp/gcl && bash /tmp/gcl --install-dir=/usr/local/bin --disable-prompts
ENV PATH=$PATH:/usr/local/bin/google-cloud-sdk/bin

# Install Terraform
RUN wget --quiet https://releases.hashicorp.com/terraform/1.0.9/terraform_1.0.9_linux_amd64.zip \
  && unzip terraform_1.0.9_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_1.0.9_linux_amd64.zip

WORKDIR /caendr
