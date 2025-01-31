import subprocess
import threading
import os
import time

def serve_ollama():
    subprocess.run(['ollama', 'serve'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def deepseek_pull():
    subprocess.run(['ollama', 'pull', 'deepseek-r1:1.5b'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def start_open_webui():
    subprocess.run(["uvx", "open-webui", "serve", "--port={port}"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

# Start servers in separate threads
threading.Thread(target=serve_ollama).start()
time.sleep(5)
threading.Thread(target=deepseek_pull).start()
time.sleep(15)
threading.Thread(target=start_open_webui).start()