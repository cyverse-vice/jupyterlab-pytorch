import subprocess, threading, time

def deepseek_pull():
        subprocess.run(['ollama', 'pull', 'deepseek-r1:1.5b'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def start_open_webui():
        subprocess.run(["uvx", "open-webui", "serve", "--port={port}"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

# Wait for ollama to start (entry.sh handles it)
time.sleep(10)
threading.Thread(target=deepseek_pull).start()
time.sleep(15)
threading.Thread(target=start_open_webui).start()
