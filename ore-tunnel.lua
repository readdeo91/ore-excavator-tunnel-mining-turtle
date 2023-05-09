local itemList = {
  ["dirt"] = true,
  ["cobblestone"] = true,
  ["gravel"] = true,
  ["sandstone"] = true
}

args = {...}
argDigDistance = tonumber(args[1])

local forwardSteps = 0
local stepStore = {}
local oreMiner = {}
local findOres = 1

-- --------------------------------------------------------------------------------------------------

function goForwardAndLog()
  goForwardSafe()
  stepStore:add("B")
end

function goBackAndLog()
  goBackSafe()
  stepStore:add("F")
end

function goUpAndLog()
  goUpSafe()
  stepStore:add("D")
end

function goDownAndLog()
  goDownSafe()
  stepStore:add("U")
end

function turnRightAndLog()
  turtle.turnRight()
  stepStore:add("L")
end

function turnLeftAndLog()
  turtle.turnLeft()
  stepStore:add("R")
end

-- --------------------------------------------------------------------------------------------------

function goForwardSafe()
  while not turtle.forward() do
    turtle.dig()
  end
end

function goBackSafe()
  while not turtle.back() do
    turtle.turnRight()
    turtle.turnRight()
    turtle.dig()
    turtle.turnLeft()
    turtle.turnLeft()
  end
end

function goUpSafe()
  while not turtle.up() do
    turtle.digUp()
  end
end

function goDownSafe()
  while not turtle.down() do
    turtle.digDown()
  end
end

-- --------------------------------------------------------------------------------------------------

StringList = {}
StringList.__index = StringList

function StringList.new()
  local self = setmetatable({}, StringList)
  self.list = {}
  return self
end

function StringList:add(str)
  table.insert(stepStore.list, str)
end

function StringList:getLast()
  return stepStore.list[#stepStore.list]
end

function StringList:getBeforeLast()
  return stepStore.list[#stepStore.list - 1]
end

function StringList:getBeforeLastExists()
  return #stepStore.list > 1
end

function StringList:removeLast()
  table.remove(stepStore.list, #stepStore.list)
end

stepStore = StringList.new()

-- --------------------------------------------------------------------------------------------------

function stepBack()
  while #stepStore.list > 0 do
    local lastStep = stepStore.getLast()

    if lastStep == "F" then
      goForwardSafe()
      stepStore.removeLast()
      oreMiner:mineOre()
    elseif lastStep == "B" then
      goBackSafe()
      stepStore.removeLast()
      oreMiner:mineOre()
    elseif lastStep == "R" then
      turtle.turnRight()
      stepStore.removeLast()
    elseif lastStep == "L" then
      turtle.turnLeft()
      stepStore.removeLast()
    elseif lastStep == "U" then
      goUpSafe()
      stepStore.removeLast()
      oreMiner:mineOre()
    elseif lastStep == "D" then
      goDownSafe()
      stepStore.removeLast()
      oreMiner:mineOre()
    elseif lastStep =="SKIP" then
      print("SKIP")
    else
      print("STEP NOT FOUND!")
    end
  end
end

-- --------------------------------------------------------------------------------------------------

OreMiner = {data={}}

function OreMiner.__init__ (baseClass, data)
  self = {data=data}
  setmetatable (self, {__index=OreMiner})
  return self
end

setmetatable (OreMiner, {__call=OreMiner.__init__})

function OreMiner:detectUp()
  turtle.detectUp()
end

function OreMiner:isOreAbove()
  local success, data = turtle.inspectUp()
  if success and string.find(data.name, "ore") ~= nil then
    return true
  else
    return false
  end
end

function OreMiner:isOreDown()
  local success, data = turtle.inspectDown()
  if success and string.find(data.name, "ore") ~= nil then
    return true
  else
    return false
  end
end

function OreMiner:isOreFront()
  local success, data = turtle.inspect()
  if success and string.find(data.name, "ore") ~= nil then
    return true
  else
    return false
  end
end

function OreMiner:mineOre()
  local oreFront = OreMiner:isOreFront()
  local oreDown = OreMiner:isOreDown()
  local oreUp = OreMiner:isOreAbove()
  local oreRight = false
  local oreLeft = false
  
  findOres = 1
  local continueLoop = true
  repeat
    oreFront = OreMiner:isOreFront()
    if oreFront then
      turtle.dig()
      goForwardAndLog()
    end

    oreDown = OreMiner:isOreDown()
    if oreDown then
      turtle.digDown()
      goDownAndLog()
    end

    oreUp = OreMiner:isOreAbove()
    if oreUp then
      turtle.digUp()
      goUpAndLog()
    end

    turnRightAndLog()
    oreRight = OreMiner:isOreFront()
    if oreRight then
      turtle.dig()
      goForwardAndLog()
    else
      turtle.turnLeft()
      stepStore.removeLast()
    end

    turnLeftAndLog()
    oreLeft = OreMiner:isOreFront()
    if oreLeft then
      turtle.dig()
      goForwardAndLog()
    else
      turtle.turnRight()
      stepStore.removeLast()
    end

    if not oreFront then
      if not oreDown then
        if not oreUp then
          if not oreRight then
            if not oreLeft then
              continueLoop = false
              print("NO ORE")
              break
            end
          end
        end
      end
    end
  until not continueLoop
stepBack()
end

oreMiner = OreMiner ()

-- --------------------------------------------------------------------------------------------------

MineTunnel = {data={}}

function MineTunnel.__init__ (baseClass, data)
  self = {data=data}
  setmetatable (self, {__index=MineTunnel})
  return self
end

setmetatable (MineTunnel, {__call=MineTunnel.__init__})

function mineIfOreInFront()
  if OreMiner:isOreFront() then
    oreMiner:mineOre()
  end
end

function mineIfOreBelow()
  if OreMiner:isOreDown() then
    oreMiner:mineOre()
  end
end

function mineIfOreAbove()
  if OreMiner:isOreAbove() then
    oreMiner:mineOre()
  end
end

function mineAndGoBottomMiddle()
  turtle.dig()
  goForwardSafe()
  forwardSteps = forwardSteps + 1
  mineIfOreBelow()
  turtle.digUp()
end

function mineAndGoBottomRight()
  turtle.turnRight()
  turtle.dig()
  goForwardSafe()
  mineIfOreBelow()
  mineIfOreInFront()
end

function mineAndGoRightMiddle()
  turtle.digUp()
  goUpSafe()
  mineIfOreInFront()
end

function mineAndGoRightTop()
  turtle.digUp()
  goUpSafe()
  mineIfOreInFront()
  mineIfOreAbove()
end

function mineAndGoTopMiddle()
  turtle.turnLeft()
  turtle.turnLeft()
  turtle.dig()
  goForwardSafe()
  mineIfOreAbove()
end

function mineAndGoTopLeft()
  turtle.dig()
  goForwardSafe()
  mineIfOreInFront()
  mineIfOreAbove()
end

function mineAndGoLeftMiddle()
  turtle.digDown()
  goDownSafe()
  mineIfOreInFront()
end

function mineAndGoLeftBottom()
  turtle.digDown()
  goDownSafe()
  mineIfOreInFront()
  mineIfOreBelow()
end

function goBackToBottomMiddle()
  turtle.turnRight()
  turtle.turnRight()
  goForwardSafe()
  turtle.turnLeft()
end

function MineTunnel:mine3x3()
  mineAndGoBottomMiddle()
  mineAndGoBottomRight()
  mineAndGoRightMiddle()
  mineAndGoRightTop()
  mineAndGoTopMiddle()
  mineAndGoTopLeft()
  mineAndGoLeftMiddle()
  mineAndGoLeftBottom()
  goBackToBottomMiddle()
end

function goBackFor(numMoves)
  turtle.turnRight()
  turtle.turnRight()

  local i = 1
  while i <= numMoves do
    goForwardSafe()
    i = i + 1
  end
end

function inspectUp()
  -- Call turtle.inspectUp() and store the result in a variable
  local success, data = turtle.inspectUp()

  -- Check if the call was successful
  if success then
    -- If successful, print the block details
    print("Block above: ", data.name)
    print("Metadata: ", data.metadata)
  else
    -- If unsuccessful, print an error message
    print("Error inspecting block above!")
  end
end

function isChestAbove()
  local success, data = turtle.inspectUp()
  if success and string.find(data.name, "chest") ~= nil then
    return true
  else
    return false
  end
end

function isChestInFront()
  local success, data = turtle.inspect()
  if success and string.find(data.name, "chest") ~= nil then
    return true
  else
    return false
  end
end

local miner = MineTunnel ("1,1,Black;")

function unLoad()
  if isChestAbove() then
    for inventorySlot = 3, 16 do
      turtle.select(inventorySlot)
      turtle.dropUp()
    end
  else  if isChestInFront() then
    for inventorySlot = 1, 16 do
      turtle.select(inventorySlot)
      turtle.drop()
    end
  end
end
  turtle.select(1)
end

function mineTunnelFor(argDigDistance)
  local i = 1
  while i <= argDigDistance do
    miner:mine3x3()
    if i % 2 == 0 then
      throwOutTrash()
    end
    i = i + 1
  end
  goBackFor(forwardSteps)
  unLoad()
  turtle.turnRight()
  turtle.turnRight()
end

function inventoryFull()
  local full = true
  for i = 1,16 do
    if turtle.getItemCount(i) == 0 then
      full = false
    end
  end
  return full
end

function throwOutTrash()
  for i = 3, 16 do
    local item = turtle.getItemDetail(i)
    if item then
      local itemName = item.name
      local itemNameMatched = false
      
      -- Check if the item name matches any of the strings in the item list
      for item_, itemNameMatch in pairs(itemList) do
        if string.find(itemName, item_) then
          itemNameMatched = true
          break
        end
      end
      
      if itemNameMatched then
        turtle.select(i)
        turtle.drop()
      end
    end
  end
end

print("START")

mineTunnelFor(argDigDistance)


