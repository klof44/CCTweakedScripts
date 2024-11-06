local mon = peripheral.find("monitor")

mon.setBackgroundColor(colors.black)
mon.clear()
mon.setCursorPos(1,1)
mon.setTextScale(0.5)
term.redirect(mon)


term.write(mon.getSize())