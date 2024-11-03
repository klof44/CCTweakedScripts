local mon = peripheral.find("monitor")

mon.setBackgroundColor(colors.black)
mon.clear()
mon.setCursorPos(1,1)
mon.setTextScale(0.5)
term.redirect(mon)

local request = http.get("https://laughing-pancake-9xq47x5g7r3pxq9-7270.app.github.dev/image")
local json = textutils.unserializeJSON(request.readAll())
request.close()

for i=1, #json["result"] do
    local x = (i-1) % 121 + 1
    local y = math.floor((i-1) / 121) + 1
    paintutils.drawPixel(x, y, json["result"][i])
end