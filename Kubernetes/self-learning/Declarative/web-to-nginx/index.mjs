import express from 'express'
import os from 'os'
import fetch from 'node-fetch'

const app = express()
const PORT = 3000

app.get("/", (req, res) => {
    const helloMessage = `Hello from the ${os.hostname()}`
    console.log(helloMessage)
    res.send(helloMessage)
})

app.get("/nginx", async (req, res) => { // /nginx je názov service v k8s
    const url = 'http://nginx'
    const response = await fetch(url);
    const body = await response.text();
    res.send(body)
})

app.listen(PORT, () => {
    console.log(`Web server is listening at port ${PORT}`)
})
