# jupyterlab-pytorch

:exclamation: Need to build torch using GPU :exclamation:

:exclamation: Update: requires NVIDIA GPU + changing the Docker runtime. See https://stackoverflow.com/questions/59691207/docker-build-with-nvidia-runtime :exclamation:

:exclamation: The build requires quite a lot of space. It is recommended to build on a NVIDIA capable computer with more than 60GB of space. If working on a VM, please see https://evodify.com/change-docker-storage-location/ so that you can build on a larger volume than the base :exclamation:

:pencil: Note: currently, the GitHub Action will not generate the container -- it is too big (~10.6GB) for the Action VMs. To build GPU support, requires Docker to be built with GPU

To build locally:

```
git clone https://github.com/cyverse-vice/jupyterlab-pytorch
cd latest

docker build -t jupyterlab-pytorch:22.01 .
```

test locally with GPU:

```
docker run -it --rm --gpus=all -p 8888:8888 -e REDIRECT_URL=http://localhost:8888 harbor.cyverse.org/vice/jupyter/pytorch:latest
```

test with CPU only:

```
docker run -it --rm -p 8888:8888 -e REDIRECT_URL=http://localhost:8888 harbor.cyverse.org/vice/jupyter/pytorch:latest
```

Open your browser and go to <http://localhost:8888>
