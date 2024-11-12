local LibDeflate = require("/LibDeflate")

local mon = peripheral.find("monitor")

mon.setBackgroundColor(colors.black)
mon.clear()
mon.setCursorPos(1,1)
mon.setTextScale(0.5)

local serverURL = "ws://207.161.109.8:7280/"
local ws = assert(http.websocket(serverURL .. "video"))

ws.send("1")
local chunkData = ws.receive()
local decompressed = LibDeflate:DecompressDeflate(chunkData)
print(decompressed)