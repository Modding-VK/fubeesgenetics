require "/scripts/fupower.lua"
require "/scripts/fubeesgenetics/hybridbees.lua"
require "/scripts/fubeesgenetics/containerutil.lua"

local energyPerAttempt = 10000
local requiredPower
local queenSlot, droneSlot, outputSlot, bonusSlot = 1, 2, 3, 4
local discBonuses = {researchvoxel = 0.10, researchvoxellarge = 0.60, researchvoxelsmall = 0.05}
local copy, same = fubeesContainer.copy, fubeesContainer.same
local function readSlot(slot) return world.containerItemAt(entity.id(), slot - 1) end
local function setStatus(value) storage.hybridizerStatus = value end

local function validParents()
  local queen, drone = readSlot(queenSlot), readSlot(droneSlot)
  if not queen or not drone then return nil end
  if not hybridbees.validParent(queen, "queen") or not hybridbees.validParent(drone, "drone") then return nil end
  local species = hybridbees.speciesForParents(hybridbees.family(queen), hybridbees.family(drone))
  if not species then return nil end
  return queen, drone, species
end

local function specimen(item)
  return {name = item.name, parameters = copy(item.parameters or {})}
end

local function bonusFor(item, species)
  local bonus = item and discBonuses[item.name] or 0
  if species and species.parentSpeciesAreRivals then bonus = bonus * 0.5 end
  return bonus
end

local function crossingChance(species, disc)
  return math.min(1, hybridbees.successChance(species) + bonusFor(disc, species))
end

local function bindExperiment(queen, drone)
  local parents = storage.hybridExperimentParents
  if not parents then
    storage.hybridExperimentParents = {queen = specimen(queen), drone = specimen(drone)}
    return
  end
  if fubeesContainer.matches(parents.queen, queen) and fubeesContainer.matches(parents.drone, drone) then return end
  if storage.hybridProgress > 0 then
    storage.hybridProgress = storage.hybridProgress * 0.5
    storage.hybridReworkAlert = true
  end
  storage.hybridExperimentParents = {queen = specimen(queen), drone = specimen(drone)}
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

local function attemptCrossing(queen, drone, species)
  local disc = species and readSlot(bonusSlot)
  local hasBonus = disc and discBonuses[disc.name] ~= nil
  local succeeded = math.random() < crossingChance(species, disc)
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
  local sources = {{slot = queenSlot, item = queen}, {slot = droneSlot, item = drone}}
  if hasBonus then sources[#sources + 1] = {slot = bonusSlot, item = disc} end
  for _, source in ipairs(sources) do
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
  -- Only commit after both exact specimens and any selected disc were removed.
  storage.hybridProgress = 0
  storage.hybridExperimentParents = nil
  storage.hybridReworkAlert = nil
  storage.lastHybridizationSucceeded = succeeded
  storage.hybridizationAttempts = (storage.hybridizationAttempts or 0) + 1
  if result then storage.hybridPending = {{slot = outputSlot, item = result}}; deliver() end
  setStatus(succeeded and "SUCCESS" or "FAILURE")
end

local function getState()
  local _, _, species = validParents()
  local disc = species and readSlot(bonusSlot)
  local bonus = species and bonusFor(disc, species) or 0
  return {progress = storage.hybridProgress or 0, requiredProgress = energyPerAttempt,
    status = storage.hybridizerStatus or "WAITING_INPUT", succeeded = storage.lastHybridizationSucceeded,
    hasResult = storage.lastHybridizationSucceeded ~= nil, attempts = storage.hybridizationAttempts or 0,
    chance = species and crossingChance(species, disc), bonus = bonus,
    watts = requiredPower,
    reworkAlert = storage.hybridReworkAlert == true}
end

function init()
  requiredPower = config.getParameter("isn_requiredPower", 24)
  storage.hybridProgress = math.max(0, math.min(energyPerAttempt, storage.hybridProgress or 0))
  storage.hybridCharge = nil -- Retire energy banked by older versions without parents.
  storage.hybridizationAttempts = storage.hybridizationAttempts or 0
  power.init()
  animator.setAnimationState("base", "default")
  animator.setAnimationState("bees", "off")
  animator.setAnimationState("loading", "off")
  animator.setAnimationState("warning", "off")
  message.setHandler("fubeesgenetics.hybridizer.getState", function() return getState() end)
end

function update(dt)
  if not deliver() then setStatus("WAITING_OUTPUT"); return end
  local queen, drone, species = validParents()
  if not queen then setStatus("WAITING_INPUT"); return end
  bindExperiment(queen, drone)
  if readSlot(outputSlot) then setStatus("WAITING_OUTPUT"); return end
  if storage.hybridProgress >= energyPerAttempt then
    attemptCrossing(queen, drone, species)
    return
  end
  -- Experiment progress pauses without valid parents or a free result slot.
  power.update(dt)
  local draw = math.min(requiredPower * dt, energyPerAttempt - storage.hybridProgress, power.getTotalEnergy())
  if draw <= 0 or not power.consume(draw) then setStatus("NO_POWER"); return end
  storage.hybridProgress = math.min(energyPerAttempt, storage.hybridProgress + draw)
  setStatus("IN_PROGRESS")
  if storage.hybridProgress >= energyPerAttempt then attemptCrossing(queen, drone, species) end
end

function die()
  for _, entry in ipairs(storage.hybridPending or {}) do world.spawnItem(entry.item, entity.position()) end
  storage.hybridPending = nil
  world.spawnItem(object.name(), entity.position(), 1)
end
