# A simple WebRTC signalling server

### The docker image
Super simple to set up. This is what I use in bash:

    sudo docker build -t ajhamwood/signal .
    sudo docker run --name signal --net=host
      -d -p 127.0.0.1:3000:3000 ajhamwood/signal
    sudo docker logs -f signal

### remote.js

Uses a WebSocket connection to carry RTC negotiation.  
`var remote = new Remote("ws://example.com")`

You can test if the server is up by pinging root.  
`fetch("http://example.com", {mode: "no-cors"}).then(launch).catch(handle)`

Establish a connection using a matchword.  
`remote.makeCall("sup").then(doStuff)`  
`remote.answerCall("sup").then(doStuff)`

Use the messaging channel like so:  
`remote.onmessage = console.log`  
`remote.postMessage("hey bro")`

Coming soon: media channels (video/audio).
