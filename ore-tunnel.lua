local itemList = {
  ["dirt"] = true,
  ["cobblestone"] = true,
  ["gravel"] = true,
  ["sandstone"] = true
}

args = {...}
argDigDistance = tonumber(args[1])

if argDigDistance == nil then
  argDigDistance = 1
end

local forwardSteps = 0
local stepStore = {}
local oreMiner = {}
local findOres = 1

local up = 0
local side = 0

local sideBkp = 0
local upBkp = 0
local direction = 0
local invFull = false

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
  up = up + 1
end

function goDownSafe()
  while not turtle.down() do
    turtle.digDown()
  end
  up = up - 1
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

function placeBlockDownForWalkWay()
  if not turtle.detectDown() then
    turtle.select(1)
    turtle.placeDown()
  end
end

function placeBlockInFrontForSide()
  if not turtle.detect() then
    turtle.select(1)
    turtle.place()
  end
end

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
  placeBlockDownForWalkWay()
  invFull = inventoryFull()
end

function mineAndGoBottomRight()
  turtle.turnRight()
  direction = direction + 1
  turtle.dig()
  goForwardSafe()
  side = side + 1
  mineIfOreBelow()
  mineIfOreInFront()
  placeBlockInFrontForSide()
  placeBlockDownForWalkWay()
  invFull = inventoryFull()
end

function mineAndGoRightMiddle()
  turtle.digUp()
  goUpSafe()
  mineIfOreInFront()
  invFull = inventoryFull()
end

function mineAndGoRightTop()
  turtle.digUp()
  goUpSafe()
  mineIfOreInFront()
  mineIfOreAbove()
  invFull = inventoryFull()
end

function mineAndGoTopMiddle()
  turtle.turnLeft()
  direction = direction - 1
  turtle.turnLeft()
  direction = direction - 1
  turtle.dig()
  goForwardSafe()
  side = side - 1
  mineIfOreAbove()
  invFull = inventoryFull()
end

function mineAndGoTopLeft()
  turtle.dig()
  goForwardSafe()
  side = side - 1
  mineIfOreInFront()
  mineIfOreAbove()
  invFull = inventoryFull()
end

function mineAndGoLeftMiddle()
  turtle.digDown()
  goDownSafe()
  mineIfOreInFront()
  invFull = inventoryFull()
end

function mineAndGoLeftBottom()
  turtle.digDown()
  goDownSafe()
  mineIfOreInFront()
  mineIfOreBelow()
  placeBlockInFrontForSide()
  placeBlockDownForWalkWay()
  invFull = inventoryFull()
end

function goToToBottomMiddle()
  turtle.turnRight()
  direction = direction + 1
  turtle.turnRight()
  direction = direction + 1
  goForwardSafe()
  side = side + 1
  turtle.turnLeft()
  direction = direction - 1
  invFull = inventoryFull()
end


function unloadIfFull()
  print("inventoryFull",invFull)
  if invFull then
    goBackToBottomMiddle()
    goBackFor(forwardSteps)
    unLoad()
    goBackFor(forwardSteps)
  end
end

function MineTunnel:mine3x3()
  mineAndGoBottomMiddle()
  if invFull then
    return
  end
  mineAndGoBottomRight()
  if invFull then
    return
  end
  mineAndGoRightMiddle()
  if invFull then
    return
  end
  mineAndGoRightTop()
  if invFull then
    return
  end
  mineAndGoTopMiddle()
  if invFull then
    return
  end
  mineAndGoTopLeft()
  if invFull then
    return
  end
  mineAndGoLeftMiddle()
  if invFull then
    return
  end
  mineAndGoLeftBottom()
  if invFull then
    return
  end
  goToToBottomMiddle()
  if invFull then
    return
  end
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
  local success, data = turtle.inspectUp()

  if success then
    print("Block above: ", data.name)
    print("Metadata: ", data.metadata)
  else
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
  local chestInFront = isChestInFront()
  local chestAbove = isChestAbove()
  while not chestInFront and not chestAbove do
    print("Waiting for chest to unload")
    sleep(100)
    chestInFront = isChestInFront()
    chestAbove = isChestAbove()
  end

  local dropSuccess = true
  if isChestAbove() then
    for inventorySlot = 3, 16 do
      turtle.select(inventorySlot)
      dropSuccess = turtle.dropUp()
      while not dropSuccess do
        print("Chest full above, can't unload!")
        sleep(5)
        dropSuccess = turtle.dropUp()
      end
    end
  elseif isChestInFront() then
    for inventorySlot = 1, 16 do
      turtle.select(inventorySlot)
      dropSuccess = turtle.drop()
      while not dropSuccess do
        print("Chest full in front, can't unload!")
        sleep(5)
        dropSuccess = turtle.dropUp()
      end
    end
  end
  turtle.select(1)
end

function mineTunnelFor(argDigDistance)
  local i = 1
  while i <= argDigDistance do
    miner:mine3x3()
    if invFull then
      unloadIfFull()
    end
    if i % 2 == 0 then
      throwOutTrash()
    end
    i = i + 1
  end
  goBackFor(forwardSteps)
  unLoad()
  turtle.turnRight()
  direction = direction + 1
  turtle.turnRight()
  direction = direction + 1
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

function goBackToBottomMiddle()
  if direction == 0 then
  elseif direction < 0 then
    for i = -1, direction do
      turtle.turnRight()
      direction = direction + 1
    end
  elseif direction > 0 then
    for i = 1, direction do
      turtle.turnLeft()
      direction = direction - 1
    end
  end

  sideBkp = side
  upBkp = up
  for i = 1, up do
    goDownSafe()
  end

  if side == 0 then
    side = side
  elseif side < 0 then
    turtle.turnRight()
    for i = -1, side do
      side = side + 1
      goForwardSafe()
    end
    turtle.turnLeft()
  else
    turtle.turnLeft()
    for i = 1, side do
      side = side -1
      goForwardSafe()
    end
    turtle.turnRight()
  end
end

print("START")

mineTunnelFor(argDigDistance)
