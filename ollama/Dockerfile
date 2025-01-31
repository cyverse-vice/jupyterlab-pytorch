FROM harbor.cyverse.org/vice/jupyter/datascience:4.3.4 

USER root

# Install cuda toolkit and nvidia drivers

RUN apt update && \
    apt install -y wget gnupg && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt update && \
    apt install -y cuda-toolkit-12-5 nvidia-driver-535 -y
  
# Add CUDA to PATH
ENV PATH=/usr/local/cuda/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Install Ollama and dependecies
RUN apt install pciutils -y && \
    curl https://ollama.ai/install.sh | sh

#RUN ollama serve & sleep 5 && ollama run mxbai-embed-large

# install uvx
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /home/jovyan/.local/bin/uvx /usr/local/bin/uvx && \
    mv /home/jovyan/.local/bin/uv /usr/local/bin/uv && \
    chmod +x /usr/local/bin/uvx && \
    chmod +x /usr/local/bin/uv

# Ensure the workspace directory exists and has the right permissions
RUN mkdir -p /home/jovyan/.jupyter/lab/workspaces && \
    chown -R jovyan:jovyan /home/jovyan/.jupyter && \
    chmod -R 700 /home/jovyan/.jupyter && \
    chown -R jovyan:jovyan /home/jovyan/.local

USER jovyan

WORKDIR /home/jovyan

EXPOSE 8888 8080

# Install TF in its own environment
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

# Install Jupyter-AI https://jupyter-ai.readthedocs.io/en/latest/users/index.html#installation
RUN pip install jupyter-ai 

# Activate the conda base in the image & create access to kernel
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/jovyan/.bashrc

# Resolves error for libcudart.so
# RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-11.3/targets/x86_64-linux/lib && source /etc/profile" >> /home/jovyan/.bashrc

# Install and configure jupyter lab.
COPY jupyter_notebook_config.json /opt/conda/etc/jupyter/jupyter_notebook_config.json

# Configure Open-WebUI Launcher
RUN pip install open-webui
COPY ollama.svg /home/jovyan/.jupyter/ollama.svg
COPY start_ollama.py /home/jovyan/.jupyter/start_ollama.py

RUN mkdir /home/jovyan/.open-webui

COPY entry.sh /bin
RUN mkdir -p /home/jovyan/.irods

ENTRYPOINT ["bash", "/bin/entry.sh"]