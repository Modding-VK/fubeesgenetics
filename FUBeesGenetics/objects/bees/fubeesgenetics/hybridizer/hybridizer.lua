require "/scripts/fupower.lua"
require "/scripts/fubeesgenetics/hybridbees.lua"

local energyPerAttempt = 10000
local queenSlot = 1
local droneSlot = 2
local outputSlot = 3

local function readSlot(slot)
  return world.containerItemAt(entity.id(), slot - 1)
end

local function setStatus(value)
  storage.hybridizerStatus = value
end

local function validParents()
  local queen = readSlot(queenSlot)
  local drone = readSlot(droneSlot)
  if not queen or not drone then return nil end
  if not root.itemHasTag(queen.name, "queen") or not root.itemHasTag(drone.name, "drone") then return nil end
  if root.itemHasTag(queen.name, "hybrid") or root.itemHasTag(drone.name, "hybrid") then return nil end
  local familyA = queen.name:match("^bee_([^_]+)_")
  local familyB = drone.name:match("^bee_([^_]+)_")
  if not hybridbees.speciesForParents(familyA, familyB) then return nil end
  return queen, drone
end

local function outputAvailable()
  return readSlot(outputSlot) == nil
end

local function same(left, right)
  if type(left) ~= type(right) then return false end
  if type(left) ~= "table" then return left == right end
  for key, value in pairs(left) do if not same(value, right[key]) then return false end end
  for key in pairs(right) do if left[key] == nil then return false end end
  return true
end

local function putResult(item)
  world.containerPutItemsAt(entity.id(), item, outputSlot - 1)
  local stored = readSlot(outputSlot)
  return stored and stored.name == item.name and stored.count == item.count
    and same(stored.parameters, item.parameters)
end

local function attemptCrossing(queen, drone)
  local familyA = queen.name:match("^bee_([^_]+)_")
  local familyB = drone.name:match("^bee_([^_]+)_")
  local species = hybridbees.speciesForParents(familyA, familyB)
  local succeeded = math.random() <= hybridbees.successChance(species)
  local result

  if succeeded then
    local genome, exceptions = hybridbees.makeGenome(queen, drone)
    local lineage, errorCode = hybridbees.makeLineage(queen, drone, genome)
    if lineage then
      lineage.genomeExceptions = exceptions
      result = {name = "bee_hybrid_queen", count = 1, parameters = {genome = genome, hybridLineage = lineage}}
    else
      succeeded = false
      sb.logWarn("[Bee Abusive Industry] Hybridization failed to create lineage: %s", errorCode)
    end
  end

  -- Both specimens are spent on either result, matching the failed experiment cost.
  world.containerTakeNumItemsAt(entity.id(), queenSlot - 1, 1)
  world.containerTakeNumItemsAt(entity.id(), droneSlot - 1, 1)

  if succeeded and result and not putResult(result) then
    world.spawnItem(result, entity.position())
  end
  storage.hybridCharge = 0
  storage.lastHybridizationSucceeded = succeeded == true
  storage.hybridizationAttempts = (storage.hybridizationAttempts or 0) + 1
  setStatus(succeeded and "SUCCESS" or "FAILURE")
end

local function getState()
  return {
    charge = storage.hybridCharge or 0,
    capacity = energyPerAttempt,
    status = storage.hybridizerStatus or "WAITING_INPUT",
    succeeded = storage.lastHybridizationSucceeded,
    hasResult = storage.lastHybridizationSucceeded ~= nil,
    attempts = storage.hybridizationAttempts or 0
  }
end

function init()
  storage.hybridCharge = math.max(0, math.min(energyPerAttempt, storage.hybridCharge or 0))
  storage.hybridizationAttempts = storage.hybridizationAttempts or 0
  power.init()
  message.setHandler("fubeesgenetics.hybridizer.getState", function() return getState() end)
end

function update(dt)
  power.update(dt)
  local queen, drone = validParents()
  if not queen then
    setStatus("WAITING_INPUT")
    return
  end
  if not outputAvailable() then
    setStatus("WAITING_OUTPUT")
    return
  end
  if storage.hybridCharge >= energyPerAttempt then
    attemptCrossing(queen, drone)
    return
  end

  local watts = config.getParameter("isn_requiredPower", 24)
  local remaining = energyPerAttempt - storage.hybridCharge
  local draw = math.min(watts * dt, remaining)
  if draw <= 0 or not power.consume(draw) then
    setStatus("NO_POWER")
    return
  end

  storage.hybridCharge = storage.hybridCharge + draw
  setStatus("CHARGING")
  if storage.hybridCharge >= energyPerAttempt then
    attemptCrossing(queen, drone)
  end
end
