#!/bin/bash

mkdir -p $HOME/.irods
touch $HOME/.irods/irods_environment.json
echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' >> $HOME/.irods/irods_environment.json

echo "export PATH=$PATH:/opt/conda/bin:/home/jovyan/.local/bin/env" >> ~/.bashrc

if [ -f /data-store/iplant/home/$IPLANT_USER/.gitconfig ]; then
  cp /data-store/iplant/home/$IPLANT_USER/.gitconfig ~/
fi

if [ -d /data-store/iplant/home/$IPLANT_USER/.ssh ]; then
  cp -r /data-store/iplant/home/$IPLANT_USER/.ssh ~/
fi

mkdir /home/jovyan/.open-webui

DATA_DIR=/home/jovyan/.open-webui

cat <<EOF > /home/jovyan/.jupyter/jupyter_server_config.py
c.NotebookApp.tornado_settings = {'proxy_allow_origin': '*'}
c.ServerProxy.servers = {
    "openwebui": {
        "command": [
            "uvx",
            "open-webui",
            "serve",
            "--port={port}",
        ],
        "port": 8080,
        "absolute_url": False,
        "websocket": True,
        "timeout": 120,
        #
        "launcher_entry": {
            "title": "Open-WebUI",
            "icon_path": "/home/jovyan/.jupyter/ollama.svg"
        },
    }
}
EOF

#open a terminal
#ollama serve & 

# open another terminal and pull a deepseek model
#ollama pull deepseek-r1:1.5b &

# start jupyter lab
exec jupyter lab --no-browser --LabApp.token="" --LabApp.password="" --ip="0.0.0.0" --port=8888 --allow-root 
