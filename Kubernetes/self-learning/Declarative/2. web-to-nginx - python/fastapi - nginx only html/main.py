import uvicorn
from fastapi import FastAPI
import socket
#import httpx
import requests


app = FastAPI()

@app.get("/")
def get_name():
    hostname = socket.gethostname()
    strr = f"Hello from the {hostname}"
    return strr

@app.get("/nginx") # ukazalo nginx html code
def nginx_page():
    nginx_url = 'http://nginx'
    response = requests.get(nginx_url)
    
    if response.status_code == 200:
        return response.text
    else:
        return f"Failed to retrieve content. Status code: {response.status_code}"

"""@app.get("/nginx") # ukazalo nginx html code
async def nginx():
    url = "http://nginx"  # = nginx service name in kubernetes
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        body = response.text
        return body"""

if __name__ == "__main__":
    uvicorn.run(app, port=3000, host="0.0.0.0")
