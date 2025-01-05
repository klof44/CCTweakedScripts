local serverURL = ""
local wsServerURL = ""

if (fs.exists("/LibDeflate.lua")) then
    local file = fs.open("/LibDeflate.lua", "w")
    file.write(http.get(serverURL .. "LibDeflate.lua").readAll())
    file.close()
end
local LibDeflate = require("/LibDeflate")
local dfpwm = require("cc.audio.dfpwm")

local mon = peripheral.find("monitor")

mon.setBackgroundColor(colors.black)
mon.clear()
mon.setCursorPos(1, 1)
mon.setTextScale(0.5)

local pallette = {
    [1] = colors.white,
    [2] = colors.orange,
    [3] = colors.magenta,
    [4] = colors.lightBlue,
    [5] = colors.yellow,
    [6] = colors.lime,
    [7] = colors.pink,
    [8] = colors.gray,
    [9] = colors.lightGray,
    [10] = colors.cyan,
    [11] = colors.purple,
    [12] = colors.blue,
    [13] = colors.brown,
    [14] = colors.green,
    [15] = colors.red,
    [16] = colors.black
}

local monSize = { mon.getSize() }

local ws = assert(http.websocket(wsServerURL .. "video"))

ws.send("INFO")
local infoData = ws.receive()
print(infoData)
local info = textutils.unserializeJSON(infoData)["info"]

local chunks = tonumber(info['chunks'])
local rate = tonumber(info['rate'])

ws.send("AUDIO")
local audioData = ws.receive()
local decompressedAudio = LibDeflate:DecompressDeflate(audioData)
local audioFile = fs.open("/audio.dfpwm", "w")
audioFile.write(decompressedAudio)
audioFile.close()

term.redirect(mon)

ws.send("1")
local nextChunkData = ws.receive()

local chunk
local currentChunkNum = 1
local execTime = os.clock()

local function getChunkData()
    ws.send(currentChunkNum)
    nextChunkData = ws.receive()
end

local function renderChunk()
    for k = 1, #chunk do
        sleep((1 / rate) - (os.clock() - execTime))
        execTime = os.clock();
        mon.clear()

        for j = 1, 15 do
            mon.setPaletteColor(pallette[j], chunk[k]["palette"][j])
        end

        for j = 1, #chunk[k]["data"] do
            local x = (j - 1) % monSize[1] + 1
            local y = math.floor((j - 1) / monSize[1]) + 1
            mon.setCursorPos(x, y)
            term.blit(" ", chunk[k]["data"][j], chunk[k]["data"][j])
        end

        ws.send("SYNC")
        ws.receive()
    end
end

local speaker = peripheral.find("speaker")
local decoder = dfpwm.make_decoder()
local function playAudio()
    for lines in io.lines("/audio.dfpwm", 16 * 1024) do
        local decoded = decoder(lines)
        while not speaker.playAudio(decoded, 3) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end

local function renderLoop()
    for i = 1, chunks / 2 do
        local chunkData = nextChunkData
        local decompressed = LibDeflate:DecompressDeflate(chunkData)
        chunk = textutils.unserializeJSON(decompressed)
        
        currentChunkNum = currentChunkNum + 2
        parallel.waitForAll(getChunkData, renderChunk)
    end
end

parallel.waitForAll(renderLoop, playAudio)

ws.close()
