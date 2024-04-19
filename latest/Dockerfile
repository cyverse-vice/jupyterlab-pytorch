# Read this regarding runtime: https://stackoverflow.com/questions/59691207/docker-build-with-nvidia-runtime
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
ARG PRIV_CMDS='/bin/ch*,/bin/cat,/bin/gunzip,/bin/tar,/bin/mkdir,/bin/ps,/bin/mv,/bin/cp,/usr/bin/apt*,/usr/bin/pip*,/bin/yum'

RUN usermod -aG sudo jovyan && \
    echo "$LOCAL_USER ALL=NOPASSWD: $PRIV_CMDS" >> /etc/sudoers

# Uncommet these to install cuda (commented as cuda is installed below)
# RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
# RUN sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
# RUN wget https://developer.download.nvidia.com/compute/cuda/12.4.1/local_installers/cuda-repo-ubuntu2204-12-4-local_12.4.1-550.54.15-1_amd64.deb
# RUN sudo dpkg -i cuda-repo-ubuntu2204-12-4-local_12.4.1-550.54.15-1_amd64.deb
# RUN sudo cp /var/cuda-repo-ubuntu2204-12-4-local/cuda-*-keyring.gpg /usr/share/keyrings/
# RUN sudo apt-get update && sudo apt-get -y install cuda-toolkit-12-4
# RUN rm cuda-repo-ubuntu2204-12-4-local_12.4.1-550.54.15-1_amd64.deb

USER jovyan

WORKDIR /home/jovyan

EXPOSE 8888

# Install pytorch to the base conda environment
# RUN conda install pytorch torchvision torchaudio cudatoolkit=11.3 -c pytorch -y

# Install a few more ML packages for pytorch and jupyter
# RUN conda install -c conda-forge mamba -y
# RUN mamba create -n pytorch && conda init && conda activate pytorch

# RUN mamba install -c pytorch -c nvidia pytorch torchvision torchaudio pytorch-cuda=12.1 pytorch-lightning cudatoolkit cuda -y
# RUN mamba install -c conda-forge ipykernel opencv jupyterlab-nvdashboard mlflow -y

# Extra copy of the conda environment in case we need it
COPY environment.yml /home/jovyan/environment.yml
RUN conda install -c conda-forge mamba -y
RUN mamba env create -f environment.yml -y && \
    echo "source activate pytorch-gpu" >> ~/.bashrc && \
    /bin/bash -c "source activate pytorch-gpu"

# Install Jupyter-AI https://jupyter-ai.readthedocs.io/en/latest/users/index.html#installation
RUN pip install jupyter-ai 

# Rebuild the Jupyter Lab with new tools
RUN jupyter lab build

# Activate the conda base in the image
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/jovyan/.bashrc 
#  echo "conda activate pytorch-gpu" >> /home/jovyan/.bashrc

# Resolves error for libcudart.so
# RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-11.3/targets/x86_64-linux/lib && source /etc/profile" >> /home/jovyan/.bashrc

COPY entry.sh /bin
RUN mkdir -p /home/jovyan/.irods

ENTRYPOINT ["bash", "/bin/entry.sh"]
