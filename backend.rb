# WebRTC signal server, negotiated over WebSocket

require 'faye/websocket'
Faye::WebSocket.load_adapter 'thin'
require 'json'

module SignalServer
  class Backend
    Peer = Struct.new :ws, :id, :peer, :passphrase

    def initialize(app)
      @app = app
      @peers = []
    end

    def call(env)
      if Faye::WebSocket.websocket? env
        ws = Faye::WebSocket.new(env, nil, { ping: 30 })

        ws.on :open do |event|
          p [:open, ws.object_id]
          @peers << Peer.new(ws, ws.object_id, nil, nil)
          ws.send JSON.generate({"type" => "connect", "id" => ws.object_id})
        end

        ws.on :message do |event|
          begin
            data = JSON.parse(event.data)
          rescue Exception => e
            p e #logging
          end
          next unless data
          p [ :message, data["sessionDescription"]["type"] ] if data["sessionDescription"]

          if data["sessionDescription"] && data["sessionDescription"]["type"] == "offer"
            peer = @peers.find {|c| c.id == data["id"] && c.ws != ws }
            if peer
              wsself = @peers.find {|c| c.ws == ws }
              wsself.peer = peer.ws
              data["id"] = wsself.id
              peer.ws.send(JSON.generate data)
            end

          elsif data["sessionDescription"] && data["sessionDescription"]["type"] == "answer"
            peer = @peers.find {|c| c.peer == ws }
            if peer
              data["id"] = @peers.find {|c| c.ws == ws }.id
              peer.ws.send JSON.generate(data)
              peer.peer = nil
            end

          elsif data["type"] == "register"
            peer = @peers.find {|c| c.ws == ws }
            peer.passphrase = data["plaintext"]

          elsif data["type"] == "passphrase"
            peer = @peers.find {|c| c.passphrase == data["plaintext"]}
            if peer
              p [:passphrase, peer.id]
              ws.send JSON.generate({"type" => "register", "id" => peer.id})
            else
              ws.send JSON.generate({"type" => "error"}) #passphrase failed
            end

          else
            p data
          end

        end

        ws.on :close do |event|
          p [:close, ws.object_id, event.code, event.reason]
          id = nil
          @peers.delete_if {|c| id = c.id if c.ws == ws }
          ws = nil
        end

        ws.rack_response
      else
        @app.call(env)
      end
    end

  end
end
