# jupyterlab-pytorch

:exclamation: need to build torch using GPU :exclamation:

notes: currently, the GitHub Action will not generate the container -- it is too big (~10.6GB) for the Action VMs

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
