local mon = peripheral.find("monitor")

mon.setBackgroundColor(colors.black)
mon.clear()
mon.setCursorPos(1,1)
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

local serverURL = "https://laughing-pancake-9xq47x5g7r3pxq9-7270.app.github.dev/"

while true do
    write("Image name: ")
    local image = read()
    if image == "" then
        image = "armada.png"
    end

    local monSize = {mon.getSize()}
    write("Monitor size: " .. monSize[1] .. "x" .. monSize[2] .. "\n")

    local imageRequest = http.get(serverURL .. "image?image=" .. image .. "&height=" .. monSize[2] .. "&width=" .. monSize[1])
    local json = textutils.unserializeJSON(imageRequest.readAll())
    imageRequest.close()

    for i=1, 15 do
        mon.setPaletteColor(pallette[i], json["palette"][i])
    end

    term.redirect(mon)

    for i=1, #json["data"] do
        local x = (i-1) % monSize[1] + 1
        local y = math.floor((i-1) / monSize[1]) + 1
        mon.setCursorPos(x, y)
        term.blit(" ", json["data"][i], json["data"][i])
    end

    term.redirect(term.native())
end
