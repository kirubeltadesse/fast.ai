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

# Set NB_USER to the current user's username
# RUN conda install --quiet --yes \
#     'numpy' \
#     'pandas' \
#     'scipy' \
#     'scikit-learn' \
#     'matplotlib' \
#     'seaborn' \
#     'jupyter' \
#     'jupyterlab' \
#     'ipywidgets' \
#     'nodejs' \
#     'plotly' \

# Install in the default python3 environment
RUN pip install --no-cache-dir 'flake8' && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install from the requirements.txt file
COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/
RUN pip install --no-cache-dir --requirement /tmp/requirements.txt && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
