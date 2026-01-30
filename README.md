[![Project Supported by CyVerse](https://de.cyverse.org/Powered-By-CyVerse-blue.svg)](https://learning.cyverse.org/projects/vice/en/latest/) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) [![license](https://img.shields.io/badge/license-BSD3-red.svg?style=flat-square)](https://opensource.org/licenses/BSD-3-Clause)

# JupyterLab PyTorch

JupyterLab with PyTorch, TensorFlow, and CUDA support for GPU-accelerated deep learning in the [CyVerse Discovery Environment](https://learning.cyverse.org/vice/about/).

[![Harbor Build Status](https://github.com/cyverse-vice/jupyterlab-pytorch/actions/workflows/harbor.yml/badge.svg)](https://github.com/cyverse-vice/jupyterlab-pytorch/actions) ![GitHub commits since tagged version](https://img.shields.io/github/commits-since/cyverse-vice/jupyterlab-pytorch/latest/main?style=flat-square)

## Quick Launch

[![quicklaunch](https://img.shields.io/badge/JupyterLab-PyTorch-orange?style=plastic&logo=jupyter)](https://de.cyverse.org/apps/de/xxx/launch)

## Features

### Deep Learning Frameworks
- **PyTorch** - GPU-accelerated deep learning (pytorch-gpu conda environment)
- **TensorFlow** - Machine learning framework (tf-gpu conda environment)
- **CUDA Toolkit** - NVIDIA GPU acceleration support

### AI Development Tools
- **Claude Code** - Anthropic AI coding assistant (`claude`)
- **Gemini CLI** - Google AI CLI (`gemini`)
- **OpenAI Codex** - OpenAI coding assistant (`codex`)
- **Jupyter-AI** - AI assistant integration for notebooks
- **Ollama** - Run AI models locally

### Development Tools
- **GitHub CLI (`gh`)** - Command-line tool for GitHub operations
- **CyberDuck CLI** - Cloud storage file transfer
- **Go & Rust** - Programming language support

### CyVerse Integration
- **GoCommands (`gocmd`)** - CyVerse data transfer utilities
- **iRODS integration** - Direct access to CyVerse Data Store

## Build Requirements

Building this image requires significant resources due to GPU support:
- NVIDIA GPU with CUDA support
- Docker configured with NVIDIA runtime
- 60GB+ disk space
- See [Docker NVIDIA runtime setup](https://stackoverflow.com/questions/59691207/docker-build-with-nvidia-runtime)

## Build Locally

```bash
git clone https://github.com/cyverse-vice/jupyterlab-pytorch
cd jupyterlab-pytorch/latest
docker build -t jupyterlab-pytorch:latest .
```

## Run Locally

### With GPU support
```bash
docker run -it --rm --gpus=all -p 8888:8888 -e REDIRECT_URL=http://localhost:8888 harbor.cyverse.org/vice/jupyter/pytorch:latest
```

### CPU only
```bash
docker run -it --rm -p 8888:8888 -e REDIRECT_URL=http://localhost:8888 harbor.cyverse.org/vice/jupyter/pytorch:latest
```

Access JupyterLab at: http://localhost:8888

## Conda Environments

| Environment | Description |
|-------------|-------------|
| pytorch-gpu | PyTorch with CUDA support |
| tf-gpu | TensorFlow with CUDA support |
| base | Standard Python environment |

Activate an environment:
```bash
conda activate pytorch-gpu
```

## Build Your Own Container

```dockerfile
FROM harbor.cyverse.org/vice/jupyter/pytorch:latest

# Add your customizations
RUN mamba install -n pytorch-gpu your-package
```

## Resources

- [CyVerse VICE Documentation](https://learning.cyverse.org/vice/about/)
- [Integrate Your Own Tools](https://learning.cyverse.org/de/create_apps/)
- [PyTorch Documentation](https://pytorch.org/docs/)
- [TensorFlow Documentation](https://www.tensorflow.org/learn)
