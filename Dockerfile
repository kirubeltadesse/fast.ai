FROM quay.io/jupyter/base-notebook

USER root

ARG DEFAULT_USER=default_value

# Set the default user
ENV DEFAULT_USER ${DEFAULT_USER}

ENV HOME /home/${DEFAULT_USER}

# Install the required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    vim \
    libssl-dev \
    libffi-dev \
    python3-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install from start bash script
COPY --chown=${NB_UID}:${NB_GID} start /usr/local/bin/start
RUN chmod +x /usr/local/bin/start

# run the start script as a bash script to install the required packages
RUN /usr/local/bin/start

RUN mamba install --quiet --yes \
    'numpy' \
    'pandas' \
    'matplotlib'

# Copy everything from /home/jovyan to /home/$USER
RUN mkdir -p /home/${DEFAULT_USER} && \
	cp -r /home/jovyan/* /home/${DEFAULT_USER}/ && \
	chown -R ${NB_UID}:${NB_GID} /home/${DEFAULT_USER}

# Install in the default python3 environment
RUN mamba install --yes 'flake8' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${DEFAULT_USER}"

# Install from the requirements.txt file
COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/
RUN pip install --no-cache-dir --requirement /tmp/requirements.txt && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${DEFAULT_USER}"

# create a symlink to the default .bashrc file
RUN ln -s /home/jovyan/.conda /home/${DEFAULT_USER}/.conda
RUN ln -s /home/jovyan/.jupyter /home/${DEFAULT_USER}/.jupyter
RUN ln -s /home/jovyan/.npm /home/${DEFAULT_USER}/.npm
RUN ln -s /home/jovyan/.profile /home/${DEFAULT_USER}/.profile

USER ${DEFAULT_USER}

# Set the working directory
WORKDIR /home/${DEFAULT_USER}/work
