shared_examples_for "a WebSocket server drafts 3 and above" do
  it "should force close connections after a timeout if close handshake is not sent by the client" do
    em {
      server_onerror_fired = false
      server_onclose_fired = false
      client_got_close_handshake = false
      
      start_server(:close_timeout => 0.1) { |ws|
        ws.onopen {
          # 1: Send close handshake to client
          EM.next_tick { ws.close(4999, "Close message") }
        }
        
        ws.onerror { |e|
          # 3: Client should receive onerror
          expect(e.class).to eq EM::WebSocket::WSProtocolError
          expect(e.message).to eq "Close handshake un-acked after 0.1s, closing tcp connection"
          server_onerror_fired = true
        }
        
        ws.onclose {
          server_onclose_fired = true
        }
      }
      start_client { |client|
        client.onmessage { |msg|
          # 2: Client does not respond to close handshake (the fake client 
          # doesn't understand them at all hence this is in onmessage)
          expect(msg).to match /Close message/ if version >= 6
          client_got_close_handshake = true
        }
        
        client.onclose {
          expect(server_onerror_fired).to eq true
          expect(server_onclose_fired).to eq true
          expect(client_got_close_handshake).to eq true
          done
        }
      }
    }
  end
end
