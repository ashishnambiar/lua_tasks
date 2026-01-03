---@param t table
---@param item any
---@return any
local function indexOf(t, item)
  for k, v in ipairs(t)
  do
    if item == v then
      return k
    end
  end
end

---@param t table
---@return string
local function encode(t)
  local result = ""
  local columns = {}
  local isFirstLine = true
  for k, v in pairs(t) do
    if isFirstLine then
      isFirstLine = false
    else
      result = result .. "\r\n"
    end
    if next(columns) == nil then
      for k1, v1 in pairs(v) do
        table.insert(columns, k1)
      end
    end
    local isFirstItem = true
    for _, l in pairs(columns) do
      if isFirstItem then
        isFirstItem = false
      else
        result = result .. ","
      end
      local val = v[l]
      if type(v[l]) == "boolean" then
        val = v[l] and "true" or "false"
      else
        if type(v[l]) == "string" then
          val = '"' .. v[l] .. '"'
        end
      end
      result = result .. val
    end
  end
  local header = ""
  local isFirstItem = true
  for _, v in pairs(columns) do
    if isFirstItem then
      isFirstItem = false
    else
      header = header .. ","
    end
    header = header .. v
  end
  return header .. "\r\n" .. result
end

---@param s string
---@return table
local function decode(s)
  local result = {}

  return result
end

---@class TaskItem
---@field task string
---@field done boolean
TaskItem = {}

---@param task string
---@return TaskItem
function TaskItem:new(task)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.task = task
  o.done = false
  return o
end

function TaskItem.toggleDone(self)
  self.done = not self.done
end

---@param t table
local function loopTable(t, i)
  if i ~= nil then
    i = i + 1
  else
    i = 1
  end
  for k, v in pairs(t) do
    if type(v) == "table" then
      loopTable(v, i)
    else
      print(string.rep("  ", i) .. k .. " : ", v)
    end
  end
end

local i1 = TaskItem:new("task 1")
local i2 = TaskItem:new("task 2")
local i3 = TaskItem:new("task 3")

local items = {
  i1,
  i2,
  i3,
}

-- local csvString = encode(items)
-- print(csvString)
-- local file = io.open("test.txt", "w")
-- if file ~= nil then
--   file:write(csvString)
--   file:close()
-- end

local file2 = io.open("test.txt", "r")
if file2 ~= nil then
  local result = {}

  local isFirstLine = true
  local token = ""
  local tokens = {}
  local keys = {}
  local insideQuote = false
  local l = file2:read('a')

  for i = 1, #l do
    local char = l:sub(i, i)
    -- if inside quote then ignore all "," & newline until the next quote
    if insideQuote then
      if char == '"' then
        insideQuote = false
      else
        token = token .. char
      end
    else
      if char == '"' then
        insideQuote = true
      elseif char == "," then
        if isFirstLine then
          print("end key")
          table.insert(keys, token)
          token = ""
        else
          print("end token")
          if token == "false" then
            table.insert(tokens, false)
          elseif token == "true" then
            table.insert(tokens, true)
          else
            table.insert(tokens, token)
          end
          token = ""
        end
        goto continue
      else
        token = token .. char
      end

      if token:sub(#token - 1, #token) == "\r\n" then
        if isFirstLine then
          isFirstLine = false
        end
        token = ""
      end
    end

    print(token)

    ::continue::
  end
  file2:close()

  print(string.rep("-", 10))
  for k, v in pairs(tokens) do
    print(k, v)
  end

  print(table.concat(result, " , "))
end
