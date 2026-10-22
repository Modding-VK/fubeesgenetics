require "/scripts/fupower.lua"
require "/scripts/fubeesgenetics/hybridbees.lua"
require "/scripts/fubeesgenetics/containerutil.lua"

local energyPerAttempt = 10000
local queenSlot, droneSlot, outputSlot = 1, 2, 3
local copy, same = fubeesContainer.copy, fubeesContainer.same
local function readSlot(slot) return world.containerItemAt(entity.id(), slot - 1) end
local function setStatus(value) storage.hybridizerStatus = value end

local function validParents()
  local queen, drone = readSlot(queenSlot), readSlot(droneSlot)
  if not queen or not drone then return nil end
  if not hybridbees.validParent(queen, "queen") or not hybridbees.validParent(drone, "drone") then return nil end
  if not hybridbees.speciesForParents(hybridbees.family(queen), hybridbees.family(drone)) then return nil end
  return queen, drone
end

-- Undelivered larvae or exceptional input refunds survive reloads. Do not roll
-- another attempt while a result is still owed, and never spawn a duplicate.
local function deliver()
  local pending = storage.hybridPending
  if not pending then return true end
  while #pending > 0 do
    local entry = pending[1]
    local leftover = fubeesContainer.put(entity.id(), entry.item, entry.slot - 1)
    if leftover then entry.item = leftover; return false end
    table.remove(pending, 1)
  end
  storage.hybridPending = nil
  return true
end

local function attemptCrossing(queen, drone)
  local species = hybridbees.speciesForParents(hybridbees.family(queen), hybridbees.family(drone))
  local succeeded = math.random() < hybridbees.successChance(species)
  local result
  if succeeded then
    local genome, exceptions = hybridbees.makeGenome(queen, drone)
    local lineage = hybridbees.makeLineage(queen, drone, genome)
    if not lineage then setStatus("WAITING_INPUT"); return end
    lineage.genomeExceptions = exceptions
    result = root.createItem({name = "bee_hybrid_youngQueen", count = 1,
      parameters = {genome = genome, hybridLineage = lineage}})
    if not result or result.name ~= "bee_hybrid_youngQueen" then setStatus("WAITING_OUTPUT"); return end
  end

  local removed = {}
  for _, source in ipairs({{slot = queenSlot, item = queen}, {slot = droneSlot, item = drone}}) do
    local current = readSlot(source.slot)
    if not same(current, source.item) then
      storage.hybridPending = removed; deliver(); setStatus("WAITING_INPUT"); return
    end
    local taken = world.containerTakeNumItemsAt(entity.id(), source.slot - 1, 1)
    if taken then removed[#removed + 1] = {slot = source.slot, item = copy(taken)} end
    if not taken or taken.count ~= 1 or not fubeesContainer.matches(taken, source.item) then
      storage.hybridPending = removed; deliver(); setStatus("WAITING_INPUT"); return
    end
  end
  -- Only commit the attempt after both exact specimens were removed.
  storage.hybridCharge = 0
  storage.lastHybridizationSucceeded = succeeded
  storage.hybridizationAttempts = (storage.hybridizationAttempts or 0) + 1
  if result then storage.hybridPending = {{slot = outputSlot, item = result}}; deliver() end
  setStatus(succeeded and "SUCCESS" or "FAILURE")
end

local function getState()
  local queen, drone = validParents()
  local species = queen and hybridbees.speciesForParents(hybridbees.family(queen), hybridbees.family(drone))
  return {charge = storage.hybridCharge or 0, capacity = energyPerAttempt,
    status = storage.hybridizerStatus or "WAITING_INPUT", succeeded = storage.lastHybridizationSucceeded,
    hasResult = storage.lastHybridizationSucceeded ~= nil, attempts = storage.hybridizationAttempts or 0,
    chance = species and hybridbees.successChance(species), watts = config.getParameter("isn_requiredPower", 24)}
end

function init()
  storage.hybridCharge = math.max(0, math.min(energyPerAttempt, storage.hybridCharge or 0))
  storage.hybridizationAttempts = storage.hybridizationAttempts or 0
  power.init()
  animator.setAnimationState("base", "default")
  animator.setAnimationState("bees", "off")
  animator.setAnimationState("loading", "off")
  animator.setAnimationState("warning", "off")
  message.setHandler("fubeesgenetics.hybridizer.getState", function() return getState() end)
end

function update(dt)
  power.update(dt)
  if not deliver() then setStatus("WAITING_OUTPUT"); return end
  local queen, drone = validParents()
  if not queen then setStatus("WAITING_INPUT"); return end
  if readSlot(outputSlot) then setStatus("WAITING_OUTPUT"); return end
  if storage.hybridCharge >= energyPerAttempt then attemptCrossing(queen, drone); return end
  local watts = config.getParameter("isn_requiredPower", 24)
  local draw = math.min(watts * dt, energyPerAttempt - storage.hybridCharge, power.getTotalEnergy())
  if draw <= 0 or not power.consume(draw) then setStatus("NO_POWER"); return end
  storage.hybridCharge = math.min(energyPerAttempt, storage.hybridCharge + draw)
  setStatus("CHARGING")
  if storage.hybridCharge >= energyPerAttempt then attemptCrossing(queen, drone) end
end

function die()
  for _, entry in ipairs(storage.hybridPending or {}) do world.spawnItem(entry.item, entity.position()) end
  storage.hybridPending = nil
  world.spawnItem(object.name(), entity.position(), 1)
end
