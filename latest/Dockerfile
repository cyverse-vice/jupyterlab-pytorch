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

########################################################################
# Uncommet these to install cuda (commented as cuda is installed below)#
########################################################################

# Install cuda toolkit
#RUN apt-get update && \
#    apt-get install -y wget gnupg && \
#    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb && \
#    dpkg -i cuda-keyring_1.0-1_all.deb && \
#    apt-get update
#RUN sudo apt-get install -y cuda-toolkit-12-1
  
# Add CUDA to PATH
#ENV PATH=/usr/local/cuda/bin:$PATH
#ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Install NVIDIA driver
#RUN sudo apt install nvidia-driver-555 -y

########################################################################
########################################################################

USER jovyan

WORKDIR /home/jovyan

EXPOSE 8888

# Install TF in its own environment
# Note: TF needs further testing
COPY tf_environment.yml /home/jovyan/tf_environment.yml
RUN mamba env create -f tf_environment.yml -y && \
    mamba install -n tf-gpu ipykernel -y && \
    /opt/conda/envs/tf-gpu/bin/python -m ipykernel install --name "tf-gpu" --user && \
    echo "source activate tf-gpu" >> ~/.bashrc

# Install pytorch in its own environment
COPY torch_environment.yml /home/jovyan/torch_environment.yml
RUN conda install -c conda-forge mamba -y
RUN mamba env create -f torch_environment.yml -y && \
    mamba install -n pytorch-gpu ipykernel -y && \
    /opt/conda/envs/pytorch-gpu/bin/python -m ipykernel install --name "pytorch-gpu" --user && \
    echo "source activate pytorch-gpu" >> ~/.bashrc && \
    /bin/bash -c "source activate pytorch-gpu"

# Install Ollama and dependecies
USER root
RUN sudo apt-get install pciutils -y && \
    curl https://ollama.ai/install.sh | sh
#RUN ollama serve & sleep 5 && ollama run mxbai-embed-large

# Install Jupyter-AI https://jupyter-ai.readthedocs.io/en/latest/users/index.html#installation
RUN pip install jupyter-ai 

USER jovyan

# Rebuild the Jupyter Lab with new tools
RUN jupyter lab build

# Activate the conda base in the image & create access to kernel
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/jovyan/.bashrc
#    echo "conda activate pytorch-gpu" >> /home/jovyan/.bashrc
#RUN ipython kernel install --name "pytorch-gpu" --user 

# Resolves error for libcudart.so
# RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-11.3/targets/x86_64-linux/lib && source /etc/profile" >> /home/jovyan/.bashrc

COPY entry.sh /bin
RUN mkdir -p /home/jovyan/.irods

ENTRYPOINT ["bash", "/bin/entry.sh"]
