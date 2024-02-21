FROM quay.io/jupyter/base-notebook

USER root

# Install the required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libssl-dev \
    libffi-dev \
    python3-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN conda install --quiet --yes \
    'numpy' \
    'pandas' \
    'matplotlib'


# Set the default user
ARG DEFAULT_USER=kirubel

# print the current user
RUN echo "Current user: ${DEFAULT_USER}"

# Copy everything from /home/jovyan to /home/$USER
RUN mkdir -p /home/${DEFAULT_USER} && \
	cp -r /home/jovyan/* /home/${DEFAULT_USER}/ && \
	chown -R ${NB_UID}:${NB_GID} /home/${DEFAULT_USER}

# Install in the default python3 environment
RUN pip install --no-cache-dir 'flake8' && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${DEFAULT_USER}"

# Install from the requirements.txt file
COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/
RUN pip install --no-cache-dir --requirement /tmp/requirements.txt


# create a symlink to the default .bashrc file
RUN ln -s /home/jovyan/.bashrc /home/${DEFAULT_USER}/.bashrc
RUN ln -s /home/jovyan/.bash_logout /home/${DEFAULT_USER}/.bash_logout
RUN ln -s /home/jovyan/.cache /home/${DEFAULT_USER}/.cache

RUN ln -s /home/jovyan/.conda /home/${DEFAULT_USER}/.conda
RUN ln -s /home/jovyan/.jupyter /home/${DEFAULT_USER}/.jupyter
RUN ln -s /home/jovyan/.npm /home/${DEFAULT_USER}/.npm
RUN ln -s /home/jovyan/.profile /home/${DEFAULT_USER}/.profile

USER ${DEFAULT_USER}

# Set the working directory
WORKDIR /home/${DEFAULT_USER}/work

