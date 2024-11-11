local mon = peripheral.find("monitor")

mon.setBackgroundColor(colors.black)
mon.clear()
mon.setCursorPos(1, 1)
mon.setTextScale(0.5)
term.redirect(mon)

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

local serverURL = "ws://laughing-pancake-9xq47x5g7r3pxq9-7280.app.github.dev/"

local monSize = { mon.getSize() }

local ws = assert(http.websocket(serverURL .. "video?height=" .. monSize[2] .. "&width=" .. monSize[1]))
ws.send("INFO")
local framesData = ws.receive()
local chunks = textutils.unserializeJSON(framesData)["info"]['chunks']

for i = 1, chunks do
    ws.send("CHUNK " .. i)
    local chunkData = ws.receive()
    local chunk = textutils.unserializeJSON(chunkData)

    for j = 1, #chunk["frames"] do        
        sleep(1 / 10)
        mon.clear()
    
        for k = 1, 15 do
            mon.setPaletteColor(pallette[k], chunk["palette"][j][k])
        end
        
    
        for k = 1, #chunk["frames"][j] do
            local x = (k - 1) % monSize[1] + 1
            local y = math.floor((k - 1) / monSize[1]) + 1
            mon.setCursorPos(x, y)
            term.blit(" ", chunk["frames"][j][k], chunk["frames"][j][k])
        end
    end
end

ws.close()
