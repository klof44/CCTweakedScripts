local mon = peripheral.find("monitor")

mon.setBackgroundColor(colors.black)
mon.clear()
mon.setCursorPos(1,1)
mon.setTextScale(0.5)
term.redirect(mon)


term.blit(" ", "0", "0")
term.blit(" ", "1", "1")
term.blit(" ", "2", "2")
term.blit(" ", "3", "3")
term.blit(" ", "4", "4")
term.blit(" ", "5", "5")

sleep(3)

mon.setPaletteColor(colors.magenta, 0)