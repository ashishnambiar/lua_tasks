local utils = {}

function utils.refreshScreen()
  io.write("\027[0;0H")
  io.write("\027[0J")
end

function utils.waitForSingleKey()
  os.execute("stty -icanon") -- put TTY in raw mode
  local answer = io.read(1)
  os.execute("stty icanon")  -- at end of program, put TTY back to normal mode
  io.write("\027[1F\r")
  io.write("\027[0J")
  return answer
end

function utils.waitForInput()
  local a = io.read()
  io.write("\027[1F\r")
  io.write("\027[0J")
  return a
end

function utils.waitForAnswer(query)
  io.write(query .. "\n")
  io.flush()
  local answer = utils.waitForSingleKey()
  io.write("\027[1F\r")
  io.write("\027[0J")
  return answer
end

function utils.quit()
  utils.refreshScreen()
  io.write("\027[?1049l")
  io.write("QUITING APPLICATION!\n")
  os.exit()
end

return utils
