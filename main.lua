local u = require "utils"
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
  if curPos > #tasks then
    curPos = #tasks
  elseif curPos < 1 then
    curPos = 1
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
    u.refreshScreen()
    io.write("Changing mode to " .. mode .. "\n")
    currentMode = mode
  end
end

local keyPressed = {}
keyPressed[113] = u.quit          -- "q"
keyPressed[81] = u.quit           -- "Q"

keyPressed[114] = u.refreshScreen -- "r"
keyPressed[82] = u.refreshScreen  -- "R"
keyPressed[12] = u.refreshScreen  -- ctrl+"l"

keyPressed[105] = changeMode("i") -- "i"
keyPressed[27] = changeMode("n")  -- "esc"
keyPressed[10] = changeMode("n")  -- "enter"

keyPressed[106] = curPosDown      -- "j"
keyPressed[107] = curPosUp        -- "k"

keyPressed[107] = curPosUp        -- "k"
keyPressed[103] = curStart        -- "g"
keyPressed[71] = curEnd           -- "G"

keyPressed[120] = toggleTask      -- "x"
keyPressed[68] = deleteTask       -- "D"

addTask("New Task", false)
addTask("Another Task", true)
addTask("Some Task 1", false)
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
local inputCurPos = 0

local function cursorLeft()
  if #input > 0 and inputCurPos > 0 then
    inputCurPos = inputCurPos - 1
  else
    inputCurPos = 0
  end
end

local function cursorRight()
  if #input > 0 and inputCurPos < #input then
    inputCurPos = inputCurPos + 1
  elseif inputCurPos > #input then
    inputCurPos = #input
  end
end

local function cursorStart()
  if #input > 0 then
    inputCurPos = 0
  end
end

local function cursorEnd()
  if #input > 0 then
    inputCurPos = #input
  end
end

local function backSpace()
  if #input > 0 and inputCurPos > 0 then
    input = string.sub(input, 1, inputCurPos - 1) .. string.sub(input, inputCurPos + 1, #input)
    cursorLeft()
  end
end

local function textInput(text)
  local i = #input
  input = string.sub(input, 1, inputCurPos) .. text .. string.sub(input, inputCurPos + 1, #input)
  i = #input - i
  inputCurPos = inputCurPos + i
  if inputCurPos > #input then
    inputCurPos = #input
  elseif inputCurPos < 1 then
    inputCurPos = 0
  end
end

local function setCursor()
  io.write("\027[2;" .. inputCurPos + 1 .. "H")
end

local iModeOps = {}
iModeOps[127] = backSpace  -- backSpace
iModeOps[8] = cursorLeft   -- ctrl+"h"
iModeOps[12] = cursorRight -- ctrl+"l"
iModeOps[1] = cursorStart  -- ctrl+"a"
iModeOps[5] = cursorEnd    -- ctrl+"e"

local function render()
  u.refreshScreen()
  local s = string.byte(key, 1, 1)

  -- io.write(key, " -> ", s, "\n")
  -- goto continue

  if currentMode == "i"
  then
    io.write("IN INSERT MODE\n")
    if s == 27 or s == 10 then
      keyPressed[s]()
      addTask(input, false)
      u.refreshScreen()
      io.write("Added New task\n\n")
      renderList()
      input = ""
    elseif iModeOps[s] == nil
    then
      textInput(key)
    else
      iModeOps[s]()
    end
    io.write(input)
    io.write("\n\n|" .. string.sub(input, 1, inputCurPos) .. "<->" .. string.sub(input, inputCurPos + 1, #input) .. "|\n")
    io.write("pos: " .. inputCurPos)
    setCursor()
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
  renderList()
  while true
  do
    key = u.waitForSingleKey()
    render()
  end

  u.waitForSingleKey()
end


io.write("\027[?1049h")

u.refreshScreen()

main()

io.write("\027[?1049l")
