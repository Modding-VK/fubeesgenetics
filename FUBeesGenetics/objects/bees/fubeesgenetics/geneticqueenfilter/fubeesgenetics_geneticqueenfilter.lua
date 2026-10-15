require "/bees/genomeLibrary.lua"
require "/scripts/fubeesgenetics/fubeesgenetics_beegeneticadapter.lua"
require "/scripts/kheAA/transferUtil.lua"

local INPUT, APPROVED, REJECTED = 0, 1, 2
local traits = {
  "baseProduction", "droneToughness", "droneBreedRate",
  "queenBreedRate", "queenLifespan", "mutationChance"
}
local traitSet = {}
for _, trait in ipairs(traits) do traitSet[trait] = true end
local modeSet = {gte = true, lte = true, ignore = true}
local reasons = {
  INVALID_DESCRIPTOR = "REJECTED_INVALID_ITEM",
  NOT_BEE = "REJECTED_INVALID_ITEM", NOT_QUEEN = "REJECTED_INVALID_ITEM",
  NOT_INSPECTED = "REJECTED_NOT_INSPECTED",
  INVALID_GENOME = "REJECTED_INVALID_GENOME", UNKNOWN_FAMILY = "REJECTED_INVALID_GENOME",
  INVALID_SUBTYPE = "REJECTED_INVALID_GENOME"
}

local function copy(value)
  if type(value) ~= "table" then return value end
  local result = {}
  for key, child in pairs(value) do result[key] = copy(child) end
  return result
end

local function same(left, right)
  if type(left) ~= type(right) then return false end
  if type(left) ~= "table" then return left == right end
  for key, value in pairs(left) do if not same(value, right[key]) then return false end end
  for key in pairs(right) do if left[key] == nil then return false end end
  return true
end

local function status(value)
  if storage.operationalStatus ~= value then
    storage.operationalStatus = value
  end
end

local function outputsEmpty()
  return world.containerItemAt(entity.id(), APPROVED) == nil
    and world.containerItemAt(entity.id(), REJECTED) == nil
end

local function refreshStatus()
  if storage.recoveryEscrow then status("RECOVERY_HOLD")
  elseif not outputsEmpty() then status("WAITING_OUTPUTS")
  elseif not world.containerItemAt(entity.id(), INPUT) then status("WAITING_INPUT")
  else status("PROCESSING") end
end

local function getState()
  refreshStatus()
  local state = {
    initialized = storage.profile ~= nil, profile = copy(storage.profile), traits = {},
    operationalStatus = storage.operationalStatus, lastResult = storage.lastResult
  }
  for _, trait in ipairs(traits) do
    local entry = {mode = storage.modes[trait]}
    if storage.references then
      entry.referenceDisplay = genelib.statToValue(genelib.numberToStat(storage.references[trait]), trait)
    end
    state.traits[trait] = entry
  end
  return state
end

-- Build a proposed result; never change stored references while evaluating.
local function decide(candidate, profile, references, modes)
  if not candidate.eligible then
    return REJECTED, reasons[candidate.reason] or "REJECTED_INVALID_ITEM"
  end
  if not profile then
    local references = {}
    for _, trait in ipairs(traits) do references[trait] = candidate.genetics[trait].raw end
    return APPROVED, "PROFILE_INITIALIZED", copy(candidate.identity), references
  end
  if candidate.identity.family ~= profile.family
    or candidate.identity.subtype ~= profile.subtype then
    return REJECTED, "REJECTED_INCOMPATIBLE_SUBSPECIES"
  end
  for _, trait in ipairs(traits) do
    local mode, value, reference = modes[trait], candidate.genetics[trait].raw, references[trait]
    if (mode == "gte" and value < reference) or (mode == "lte" and value > reference) then
      return REJECTED, "REJECTED_GENETIC_CRITERIA"
    end
  end
  local references = copy(references)
  for _, trait in ipairs(traits) do
    if modes[trait] ~= "ignore" then references[trait] = candidate.genetics[trait].raw end
  end
  return APPROVED, "APPROVED", copy(profile), references
end

local function confirmedDrop(id)
  return type(id) == "number" and id > 0 and id < math.huge and id == math.floor(id)
end

-- Nil confirms no drop; an exception does not confirm whether a side effect occurred.
local function spawnRecovery(item)
  local ok, id = pcall(world.spawnItem, item, entity.position())
  if not ok then
    self.recoveryUncertain = true
    sb.logError("[FUBeesGenetics] Spawn exception; automatic retries suspended for this load. Descriptor: %s. Error: %s",
      sb.printJson(item), tostring(id))
  end
  return ok and confirmedDrop(id)
end

-- OpenStarbound 0.1.14 returns the input descriptor even after a complete put.
-- Confirm that case against the exact synchronous slot delta before any rollback.
local function putAt(item, slot)
  local normalize = fubeesgenetics_beegeneticadapter.normalize
  local before = normalize(world.containerItemAt(entity.id(), slot))
  local leftover = world.containerPutItemsAt(entity.id(), item, slot)
  if not leftover then return nil end
  local after = normalize(world.containerItemAt(entity.id(), slot))
  local unit = normalize(item)
  local function matches(value)
    return value and value.name == unit.name and same(value.parameters, unit.parameters)
  end
  if unit and after and matches(after) and (not before or matches(before))
    and after.count == (before and before.count or 0) + unit.count then
    return nil
  end
  return leftover
end

local function rollback(item)
  local leftover = putAt(item, INPUT)
  if not leftover then
    sb.logWarn("[FUBeesGenetics] Failed transfer rolled back to Input.")
    return
  end
  if spawnRecovery(leftover) then
    sb.logWarn("[FUBeesGenetics] Failed transfer recovered as a world drop.")
    return
  end
  if not self.recoveryUncertain then
    leftover = putAt(leftover, INPUT)
    if not leftover then
      sb.logWarn("[FUBeesGenetics] Spawn failed; final rollback to Input succeeded.")
      return
    end
  end
  -- The only permitted persistent item buffer is this exceptional one-unit escrow.
  storage.recoveryEscrow = copy(leftover)
  sb.logWarn("[FUBeesGenetics] Recovery pending; one unit preserved in emergency escrow.")
end

local function recover()
  if self.recoveryUncertain then return end
  local item = storage.recoveryEscrow
  if not world.containerItemAt(entity.id(), INPUT) then
    local leftover = putAt(item, INPUT)
    if not leftover then
      storage.recoveryEscrow = nil
      sb.logWarn("[FUBeesGenetics] Escrow restored to Input.")
      refreshStatus(); return
    end
    storage.recoveryEscrow = copy(leftover)
  end
  if spawnRecovery(storage.recoveryEscrow) then
    storage.recoveryEscrow = nil
    sb.logWarn("[FUBeesGenetics] Escrow restored as a world drop.")
  end
  refreshStatus()
end

local function sameItem(left, right)
  return left.name == right.name and same(left.parameters, right.parameters)
end

local function process()
  if storage.recoveryEscrow then recover(); return end
  -- Backpressure precedes even reading the Input, and certainly the Adapter.
  if not outputsEmpty() then status("WAITING_OUTPUTS"); return end
  local source = world.containerItemAt(entity.id(), INPUT)
  local snapshot = copy(fubeesgenetics_beegeneticadapter.normalize(source) or source)
  if not snapshot then status("WAITING_INPUT"); return end
  status("PROCESSING")
  local candidate = fubeesgenetics_beegeneticadapter.read(snapshot)
  local profile, references, modes = copy(storage.profile), copy(storage.references), copy(storage.modes)
  local destination, result, nextProfile, nextReferences = decide(candidate, profile, references, modes)

  local current = fubeesgenetics_beegeneticadapter.normalize(world.containerItemAt(entity.id(), INPUT))
  if not current or not sameItem(snapshot, current) or not outputsEmpty() then
    refreshStatus(); return
  end
  local unit = world.containerTakeNumItemsAt(entity.id(), INPUT, 1)
  if not unit then refreshStatus(); return end
  unit = fubeesgenetics_beegeneticadapter.normalize(unit) or unit
  local expected = copy(snapshot)
  expected.count = 1
  if unit.count ~= 1 or not same(unit, expected) or not outputsEmpty() then
    rollback(unit); refreshStatus(); return
  end

  local leftover = putAt(unit, destination)
  if leftover then
    rollback(leftover); refreshStatus(); return
  end
  -- Insertion confirmed by nil leftover or the exact legacy-engine slot delta.
  if destination == APPROVED then
    storage.profile, storage.references = nextProfile, nextReferences
  end
  storage.lastResult = result
  refreshStatus()
end

function init()
  self = {timer = 0}
  storage.stateRevision = nil -- Remove the obsolete development snapshot counter.
  local function rawValid(v)
    return type(v) == "number" and v == v and v >= 0 and v <= 1295 and v == math.floor(v)
  end
  local p, refs = storage.profile, storage.references
  local valid = type(p) == "table" and type(p.family) == "string" and p.family ~= ""
    and rawValid(p.subtype) and p.subtype >= 1
    and type(p.subspeciesName) == "string" and p.subspeciesName ~= "" and type(refs) == "table"
  for _, trait in ipairs(traits) do valid = valid and rawValid(refs[trait]) end
  if (p ~= nil or refs ~= nil) and not valid then
    storage.profile, storage.references = nil, nil
    sb.logWarn("[FUBeesGenetics] Incomplete genetic profile cleared; valid modes preserved.")
  end
  if type(storage.modes) ~= "table" then storage.modes = {} end
  for _, trait in ipairs(traits) do
    if not modeSet[storage.modes[trait]] then
      if storage.modes[trait] ~= nil then sb.logWarn("[FUBeesGenetics] Invalid mode reset to gte: %s", trait) end
      storage.modes[trait] = "gte"
    end
  end
  storage.lastResult = storage.lastResult or "NONE"
  refreshStatus()
  message.setHandler("fubeesgenetics.gqf.getState", function() return getState() end)
  message.setHandler("fubeesgenetics.gqf.setMode", function(_, _, trait, mode)
    if type(trait) == "string" and type(mode) == "string" and traitSet[trait] and modeSet[mode]
      and storage.modes[trait] ~= mode then
      storage.modes[trait] = mode
    end
    return getState()
  end)
  message.setHandler("fubeesgenetics.gqf.resetProfile", function()
    storage.profile, storage.references, storage.lastResult = nil, nil, "NONE"
    return getState()
  end)
  transferUtil.loadSelfContainer()
end

function update(dt)
  self.timer = self.timer + dt
  if self.timer >= 1 then
    -- One check per loaded update; do not simulate missed/unloaded cycles.
    self.timer = self.timer % 1
    transferUtil.loadSelfContainer()
    process()
  end
end

function die()
  if not storage.recoveryEscrow or self.finalRecoveryAttempted then return end
  self.finalRecoveryAttempted = true
  if self.recoveryUncertain then
    sb.logError("[FUBeesGenetics] FATAL: uncertain spawn outcome; descriptor retained for diagnosis: %s", sb.printJson(storage.recoveryEscrow))
    return
  end
  if spawnRecovery(storage.recoveryEscrow) then storage.recoveryEscrow = nil
  else sb.logError("[FUBeesGenetics] FATAL: final escrow recovery failed. Descriptor: %s", sb.printJson(storage.recoveryEscrow)) end
end
