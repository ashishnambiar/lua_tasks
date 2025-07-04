local function refreshScreen()
  io.write("\027[0;0H")
  io.write("\027[0J")
end

local function waitForSingleKey()
  os.execute("stty -icanon") -- put TTY in raw mode
  local answer = io.read(1)
  os.execute("stty icanon")  -- at end of program, put TTY back to normal mode
  io.write("\027[1F\r")
  io.write("\027[0J")
  return answer
end

local function waitForInput()
  local a = io.read()
  io.write("\027[1F\r")
  io.write("\027[0J")
  return a
end


local function waitForAnswer(query)
  io.write(query .. "\n")
  io.flush()
  local answer = waitForSingleKey()
  io.write("\027[1F\r")
  io.write("\027[0J")
  return answer
end

local function quit()
  refreshScreen()
  io.write("\027[?1049l")
  io.write("QUITING APPLICATION!\n")
  os.exit()
end

--[[
 ____ _____  _    ____ _____   _   _ _____ ____  _____
/ ___|_   _|/ \  |  _ \_   _| | | | | ____|  _ \| ____|
\___ \ | | / _ \ | |_) || |   | |_| |  _| | |_) |  _|
 ___) || |/ ___ \|  _ < | |   |  _  | |___|  _ <| |___
|____/ |_/_/   \_\_| \_\|_|   |_| |_|_____|_| \_\_____|
--]]
--

local modes = {
  n = "normal",
  i = "insert",
}

local currentMode = "n"
local curPos = 1
local tasks = {
}

local function curPosNew(i)
  curPos = i
  if curPos < 1 then
    curPos = 1
  elseif curPos > #tasks then
    curPos = #tasks
  end
end

local function curStart()
  curPosNew(1)
end
local function curEnd()
  curPosNew(#tasks)
end
local function curPosUp()
  curPosNew(curPos - 1)
end
local function curPosDown()
  curPosNew(curPos + 1)
end


local function addTask(
    task --[[string]],
    done --[[boolean]]
)
  tasks[#tasks + 1] = {
    data = task,
    done = done,
  }
end
local function toggleTask()
  local i = curPos
  tasks[i].done = not tasks[i].done
end

local function deleteTask()
  local i = curPos
  table.remove(tasks, i)
  curPosNew(curPos)
end


local function changeMode(mode)
  return function()
    refreshScreen()
    io.write("Changing mode to " .. mode .. "\n")
    currentMode = mode
  end
end

local keyPressed = {}
keyPressed[113] = quit            -- "q"
keyPressed[81] = quit             -- "Q"

keyPressed[114] = refreshScreen   -- "r"
keyPressed[82] = refreshScreen    -- "R"
keyPressed[12] = refreshScreen    -- ctrl+"l"

keyPressed[105] = changeMode("i") -- "i"
keyPressed[27] = changeMode("n")  -- "esc"
keyPressed[10] = changeMode("n")  -- "enter"

keyPressed[106] = curPosDown      -- "j"
keyPressed[107] = curPosUp        -- "k"

keyPressed[107] = curPosUp        -- "k"
keyPressed[103] = curStart        -- "g"
keyPressed[71] = curEnd           -- "G"

keyPressed[120] = toggleTask      -- "x"
keyPressed[100] = deleteTask      -- "d"

addTask("New Task", false)
addTask("Another Task", true)
addTask("Some Task", false)
addTask("Some Task 2", false)

local function renderList()
  for i = 1, #tasks
  do
    local item = "[" .. (tasks[i].done and "x" or " ") .. "] " .. tasks[i].data .. "\n"
    io.write((curPos == i and "> " or "  ") .. item)
  end
end

local key = ""
local input = ""

local function render()
  refreshScreen()
  local s = string.byte(key, 1, 1)

  -- io.write(key, " -> ", s, "\n")
  -- goto continue

  if currentMode == "i"
  then
    io.write("IN INSERT MODE\n")
    if s == 27 or s == 10 then
      keyPressed[s]()
      io.write("ESCAPING\n")
      addTask(input, false)
      input = ""
    elseif s == 14 then
      io.write("other things")
    else
      input = input .. key
    end
    io.write(input)
  else
    if keyPressed[s] ~= nil
    then
      keyPressed[s]()
    else
      io.write("UNKOWN COMMAND\n")
    end
    io.write("\n")
    renderList()
    io.write("\027[0;0H")
  end
  ::continue::
end

local function main()
  while true
  do
    key = waitForSingleKey()
    render()
  end

  waitForSingleKey()
end


io.write("\027[?1049h")

refreshScreen()

main()

io.write("\027[?1049l")
