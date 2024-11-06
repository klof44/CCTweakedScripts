

local mon = peripheral.find("monitor")

mon.setBackgroundColor(colors.black)
mon.clear()
mon.setCursorPos(1,1)
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

local paletteRequest = http.get("https://laughing-pancake-9xq47x5g7r3pxq9-7270.app.github.dev/palette")
local newPalette = textutils.unserializeJSON(paletteRequest.readAll())
paletteRequest.close()

for i=1, 15 do
    mon.setPaletteColor(pallette[i], newPalette[i])
end

local request = http.get("https://laughing-pancake-9xq47x5g7r3pxq9-7270.app.github.dev/image")
local json = textutils.unserializeJSON(request.readAll())
request.close()

for i=1, #json["result"] do
    local x = (i-1) % 79 + 1
    local y = math.floor((i-1) / 79) + 1
    mon.setCursorPos(x, y)
    term.blit(" ", json["result"][i], json["result"][i])
end
