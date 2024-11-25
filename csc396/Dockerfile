# Read this regarding runtime: https://stackoverflow.com/questions/59691207/docker-build-with-nvidia-runtime
# IMPORTANT: torch will NOT recognize cuda if installed in base: requires its own env.
FROM quay.io/jupyter/datascience-notebook:lab-4.1.5

USER root

ARG DEBIAN_FRONTEND=noninteractive

# Install a few dependencies for iCommands, text editing, and monitoring instances
RUN apt update && \
    apt install -y lsb-release apt-transport-https curl gnupg2 libfuse2 gettext gcc less nodejs software-properties-common apt-utils glances htop nano

# Install Go
RUN wget -q -c https://dl.google.com/go/go1.20.5.linux-amd64.tar.gz -O - | tar -xz -C /usr/local

# Install GoCommmands
RUN cd /usr/local/bin/ && \
   GOCMD_VER=$(curl -L -s https://raw.githubusercontent.com/cyverse/gocommands/main/VERSION.txt); curl -L -s https://github.com/cyverse/gocommands/releases/download/${GOCMD_VER}/gocmd-${GOCMD_VER}-linux-amd64.tar.gz | tar zxvf -

# Install Rust
RUN apt update && \
    apt install -y cargo rustc

# Install CyberDuck CLI
RUN echo "deb https://s3.amazonaws.com/repo.deb.cyberduck.io stable main" > /etc/apt/sources.list.d/cyberduck.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FE7097963FEFBE72 && \
    apt update && \
    apt install duck

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt update && \
    apt install gh

# Install and configure jupyter lab.
COPY jupyter_notebook_config.json /opt/conda/etc/jupyter/jupyter_notebook_config.json

# Add sudo to jovyan user
RUN apt update && \
    apt install -y sudo && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

ARG LOCAL_USER=jovyan
ARG PRIV_CMDS='/bin/ch*,/bin/cat,/bin/gunzip,/bin/tar,/bin/mkdir,/bin/ps,/bin/mv,/bin/cp,/usr/bin/apt*,/usr/bin/pip*,/bin/yum,/bin/snap,/bin/curl,/bin/tee,/opt'

RUN usermod -aG sudo jovyan && \
    echo "$LOCAL_USER ALL=NOPASSWD: $PRIV_CMDS" >> /etc/sudoers
RUN addgroup jovyan
RUN usermod -aG jovyan jovyan

USER jovyan

WORKDIR /home/jovyan

EXPOSE 8888

# Install pytorch in its own environment
COPY environment.yml /home/jovyan/environment.yml
RUN conda install -c conda-forge mamba -y
RUN mamba env create -f environment.yml -y && \
    mamba install -n pytorch-gpu ipykernel -y && \
    /opt/conda/envs/pytorch-gpu/bin/python -m ipykernel install --name "pytorch-gpu" --user && \
    echo "source activate pytorch-gpu" >> ~/.bashrc && \
    /bin/bash -c "source activate pytorch-gpu"

# Install Jupyter-AI https://jupyter-ai.readthedocs.io/en/latest/users/index.html#installation
# and other dependecies for the class
RUN pip install jupyter-ai conllu transformers datasets 
RUN pip install accelerate -U

# Upgrade widgets
RUN pip install --upgrade ipywidgets
RUN pip install jupyter_contrib_nbextensions widgetsnbextension pandas-profiling
# Rebuild the Jupyter Lab with new tools
RUN jupyter lab build

COPY entry.sh /bin
RUN mkdir -p /home/jovyan/.irods

ENTRYPOINT ["bash", "/bin/entry.sh"]
