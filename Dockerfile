# Use an official Python image based on Debian/Ubuntu
FROM python:3.11-slim

# Set environment variables to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

SHELL [ "/bin/bash", "-c" ]

ENV SHELL=/bin/bash

# Install necessary system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    nodejs \
    build-essential \
    && apt-get clean

COPY requirements.txt requirements-dev.txt /tmp/

RUN --mount=type=cache,target=/root/.cache \
    python3.11 -m pip install -r /tmp/requirements-dev.txt

# Install jupyterlab_vim extension from conda-forge using mamba
RUN pip install mamba && \
    mamba install jupyterlab_vim

RUN mkdir -p /workarea

COPY . /workarea

# Set up a working directory
WORKDIR /workarea

