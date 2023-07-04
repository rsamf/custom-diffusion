FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

RUN apt-get update
RUN apt-get install -y wget

# Install python
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    /bin/bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

ENV PATH "/opt/conda/bin:$PATH"

# Installs google cloud sdk, this is mostly for using gsutil to export model.
RUN wget -nv \
    https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz && \
    mkdir /root/tools && \
    tar xvzf google-cloud-sdk.tar.gz -C /root/tools && \
    rm google-cloud-sdk.tar.gz && \
    /root/tools/google-cloud-sdk/install.sh --usage-reporting=false \
        --path-update=false --bash-completion=false \
        --disable-installation-options && \
    rm -rf /root/.config/* && \
    ln -s /root/.config /config && \
    # Remove the backup directory that gcloud creates
    rm -rf /root/tools/google-cloud-sdk/.install/.backup


WORKDIR /opt/train

# Install deps
RUN apt-get install -y git
RUN python -m pip install --upgrade pip
COPY environment.yaml .
RUN git clone https://github.com/CompVis/stable-diffusion && \
    cd stable-diffusion && \
    git reset --hard 21f890f && \
    cd ..
RUN conda env create -f environment.yaml

# Setup env vars
ENV PATH="/opt/conda/envs/ldm/bin:/opt/ml/code:${PATH}"
ENV CONDA_DEFAULT_ENV="ldm"
ENV TRAINING_SCRIPT="train.py"
ENV PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:512"

# Code
COPY scripts scripts
COPY src /opt/ml/code/src
COPY train.py .

ENTRYPOINT scripts/train.sh
