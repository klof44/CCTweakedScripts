local dfpwm = require("cc.audio.dfpwm")

local speakers = {
    "left",
    "right",
    "back",
    "top",
    "bottom",
}
local decoders = {
    dfpwm.make_decoder(),
    dfpwm.make_decoder(),
    dfpwm.make_decoder(),
    dfpwm.make_decoder(),
    dfpwm.make_decoder(),
}

while true do
    for input in io.lines("/song.dfpwm", 16 * 1024) do
        for i=1, #decoders do
            local decoded = decoders[i](input)
            local peripheral = peripheral.wrap(speakers[i])
            while not peripheral.playAudio(decoded, 3, math.random(0.9, 1.1)) do
                os.pullEvent("speaker_audio_empty")
            end
            sleep(math.random(0.01, 0.5))
        end
    end
end
