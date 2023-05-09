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
    goForwardSafe()
    turtle.turnRight()
    turtle.turnRight()
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
  print("Stepback: ", #stepStore.list)
  while #stepStore.list > 0 do
    local lastStep = stepStore.getLast()

    if stepStore.getBeforeLastExists() then
      local beforeLastStep = stepStore.getBeforeLast()
      if lastStep == "R" and beforeLastStep == "L" then
        lastStep = "SKIP"
      end
      if lastStep == "L" and beforeLastStep == "R" then
        lastStep = "SKIP"
      end
    end

    print("LastStep: ", lastStep)
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
  print("MineOre")
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

function MineTunnel:mine3x3()
  turtle.dig()
  goForwardSafe()
  forwardSteps = forwardSteps + 1
  if OreMiner:isOreDown() then
    oreMiner:mineOre()
  end
  
  turtle.digUp()
  
  
  turtle.turnRight()
  turtle.dig()

  goForwardSafe()
  turtle.digUp()
  if OreMiner:isOreFront() then
    oreMiner:mineOre()
  end

  goUpSafe()
  if OreMiner:isOreFront() then
    oreMiner:mineOre()
  end
  turtle.digUp()

  goUpSafe()
  if OreMiner:isOreFront() then
    oreMiner:mineOre()
  end
  if OreMiner:isOreAbove() then
    oreMiner:mineOre()
  end
  turtle.turnLeft()
  turtle.turnLeft()
  turtle.dig()

  goForwardSafe()
  if OreMiner:isOreAbove() then
    oreMiner:mineOre()
  end
  turtle.dig()

  goForwardSafe()
  if OreMiner:isOreFront() then
    oreMiner:mineOre()
  end
  if OreMiner:isOreAbove() then
    oreMiner:mineOre()
  end

  turtle.digDown()

  goDownSafe()
  if OreMiner:isOreFront() then
    oreMiner:mineOre()
  end
  turtle.digDown()

  goDownSafe()
  if OreMiner:isOreFront() then
    oreMiner:mineOre()
  end
  if OreMiner:isOreDown() then
    oreMiner:mineOre()
  end
  turtle.turnRight()
  turtle.turnRight()
  goForwardSafe()
  turtle.turnLeft()
end

function goBackFor(numMoves)
  turtle.turnRight()
  turtle.turnRight()

  local i = 1
  while i <= numMoves do
    goForwardSafe()
    i = i + 1
  end
  turtle.turnRight()
  turtle.turnRight()
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

local miner = MineTunnel ("1,1,Black;")

function mineTunnelFor(argDigDistance)
  local i = 1
  while i <= argDigDistance do
    miner:mine3x3()
    i = i + 1
  end
end

print("START")

mineTunnelFor(argDigDistance)
goBackFor(forwardSteps)
