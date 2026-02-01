# Read this regarding runtime: https://stackoverflow.com/questions/59691207/docker-build-with-nvidia-runtime
# IMPORTANT: torch will NOT recognize cuda if installed in base: requires its own env.
FROM quay.io/jupyter/pytorch-notebook:cuda12-python-3.11

USER root

ARG DEBIAN_FRONTEND=noninteractive
ARG LOCAL_USER=jovyan
ARG PRIV_CMDS='/bin/ch*,/bin/cat,/bin/gunzip,/bin/tar,/bin/mkdir,/bin/ps,/bin/mv,/bin/cp,/usr/bin/apt*,/usr/bin/pip*,/bin/yum,/bin/snap,/bin/curl,/bin/tee,/opt'

# ============================================================================
# LAYER 1: System dependencies + Node.js 20.x + GitHub CLI (combined for efficiency)
# ============================================================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        lsb-release apt-transport-https curl gnupg2 libfuse2 gettext \
        gcc less software-properties-common apt-utils \
        glances htop nano sudo pciutils && \
    # Install Node.js 20.x (required for AI tools)
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    # Install GitHub CLI
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install -y gh && \
    # Cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ============================================================================
# LAYER 2: GoCommands + Ollama (root-level tools)
# ============================================================================
RUN cd /usr/local/bin/ && \
    GOCMD_VER=$(curl -L -s https://raw.githubusercontent.com/cyverse/gocommands/main/VERSION.txt) && \
    curl -L -s https://github.com/cyverse/gocommands/releases/download/${GOCMD_VER}/gocmd-${GOCMD_VER}-linux-amd64.tar.gz | tar zxvf - && \
    # Install Ollama
    curl -fsSL https://ollama.ai/install.sh | sh

# ============================================================================
# LAYER 3: Jupyter-AI (pip install as root for system-wide availability)
# ============================================================================
RUN pip install --no-cache-dir jupyter-ai

# ============================================================================
# LAYER 4: Sudo configuration + Jupyter config
# ============================================================================
COPY jupyter_notebook_config.json /opt/conda/etc/jupyter/jupyter_notebook_config.json

RUN usermod -aG sudo jovyan && \
    echo "$LOCAL_USER ALL=NOPASSWD: $PRIV_CMDS" >> /etc/sudoers && \
    addgroup jovyan 2>/dev/null || true && \
    usermod -aG jovyan jovyan

# ============================================================================
# Switch to jovyan user for remaining installations
# ============================================================================
USER jovyan
WORKDIR /home/jovyan

# ============================================================================
# LAYER 5: Conda environments (PyTorch + TensorFlow)
# ============================================================================
COPY --chown=jovyan:jovyan tf_environment.yml torch_environment.yml /home/jovyan/

RUN mamba env create -f tf_environment.yml -y && \
    mamba env create -f torch_environment.yml -y && \
    # Register kernels
    /opt/conda/envs/tf-gpu/bin/python -m ipykernel install --name "tf-gpu" --display-name "TensorFlow GPU" --user && \
    /opt/conda/envs/pytorch-gpu/bin/python -m ipykernel install --name "pytorch-gpu" --display-name "PyTorch GPU" --user && \
    # Configure bashrc
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate pytorch-gpu" >> ~/.bashrc && \
    # Cleanup conda caches
    mamba clean -afy && \
    rm -rf ~/.cache/pip/* ~/.cache/conda/*

# ============================================================================
# LAYER 6: AI tools (Claude Code, Gemini CLI, OpenAI Codex)
# ============================================================================
RUN npm config set prefix ~/.npm-global && \
    mkdir -p ~/.npm-global/bin && \
    export PATH=~/.npm-global/bin:$PATH && \
    npm install -g @anthropic-ai/claude-code @google/gemini-cli @openai/codex && \
    npm cache clean --force

ENV PATH="/home/jovyan/.npm-global/bin:${PATH}"

# ============================================================================
# LAYER 7: Entry point configuration
# ============================================================================
COPY --chown=jovyan:jovyan entry.sh /bin/entry.sh
RUN mkdir -p ~/.irods

EXPOSE 8888

ENTRYPOINT ["bash", "/bin/entry.sh"]
