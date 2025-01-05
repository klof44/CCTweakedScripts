term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)

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

local serverURL = ""

while true do
    local image = read()
    if image == "" then
        image = "armada.png"
    end

    local monSize = {term.getSize()}
    write("Monitor size: " .. monSize[1] .. "x" .. monSize[2] .. "\n")

    local imageRequest = http.get(serverURL .. "image?image=" .. image .. "&height=" .. monSize[2] .. "&width=" .. monSize[1])
    local json = textutils.unserializeJSON(imageRequest.readAll())
    imageRequest.close()

    for i=1, 15 do
        term.setPaletteColor(pallette[i], json["palette"][i])
    end

    term.clear()
    for i=1, #json["data"] do
        local x = (i-1) % monSize[1] + 1
        local y = math.floor((i-1) / monSize[1]) + 1
        term.setCursorPos(x, y)
        term.blit(" ", json["data"][i], json["data"][i])
    end
end
