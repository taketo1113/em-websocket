# encoding: BINARY

require 'helper'

describe EM::WebSocket::MaskedString do
  it "should allow reading 4 byte mask and unmasking byte / bytes" do
    t = EM::WebSocket::MaskedString.new("\x00\x00\x00\x01\x00\x01\x00\x01")
    t.read_mask
    expect(t.getbyte(3)).to eq 0x00
    expect(t.getbytes(4, 4)).to eq "\x00\x01\x00\x00"
    expect(t.getbytes(5, 3)).to eq "\x01\x00\x00"
  end

  it "should return nil from getbyte if index requested is out of range" do
    t = EM::WebSocket::MaskedString.new("\x00\x00\x00\x00\x53")
    t.read_mask
    expect(t.getbyte(4)).to eq 0x53
    expect(t.getbyte(5)).to eq nil
  end
  
  it "should allow switching masking on and off" do
    t = EM::WebSocket::MaskedString.new("\x02\x00\x00\x00\x03")
    expect(t.getbyte(4)).to eq 0x03
    t.read_mask
    expect(t.getbyte(4)).to eq 0x01
    t.unset_mask
    expect(t.getbyte(4)).to eq 0x03
  end
end
