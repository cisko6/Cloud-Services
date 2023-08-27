from flask import Flask
import socket
import requests

app = Flask(__name__)

@app.route('/')
def get_name():
    hostname = socket.gethostname()
    strr = f"Hello from the {hostname}"
    return strr

@app.route('/nginx')
def nginx_proxy():
    nginx_url = 'http://nginx'
    response = requests.get(nginx_url)
    return response.text

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=3000)
