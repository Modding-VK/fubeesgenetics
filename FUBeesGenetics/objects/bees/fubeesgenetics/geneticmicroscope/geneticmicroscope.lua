require "/scripts/fubeesgenetics/containerutil.lua"
require "/scripts/fubeesgenetics/fubeesgenetics_beegeneticadapter.lua"
require "/scripts/fubeesgenetics/itemtags.lua"

local INPUT, ANALYZED = 0, 1
local copy, same = fubeesContainer.copy, fubeesContainer.same
local normalize = fubeesgenetics_beegeneticadapter.normalize

local function validBee(item)
  if not item then return nil end
  local normalized = normalize(item)
  if not normalized then return nil end
  local ok, bee = fubeesItemTags.has(normalized.name, "bee")
  if not ok or not bee then return nil end
  return normalized
end

local function recover(item)
  if not item then return end
  local leftover = fubeesContainer.putExact(entity.id(), item, INPUT, normalize)
  if leftover then
    storage.recoveryEscrow = copy(leftover)
  end
end

local function process()
  if storage.recoveryEscrow then
    if not world.containerItemAt(entity.id(), INPUT) then
      local leftover = fubeesContainer.putExact(entity.id(), storage.recoveryEscrow, INPUT, normalize)
      if not leftover then storage.recoveryEscrow = nil end
    end
    return
  end

  if world.containerItemAt(entity.id(), ANALYZED) then return end
  local source = validBee(world.containerItemAt(entity.id(), INPUT))
  if not source then return end

  local unit = copy(source)
  unit.count = 1
  local taken = world.containerTakeNumItemsAt(entity.id(), INPUT, 1)
  if not taken then return end
  local takenNormalized = normalize(taken)
  if not takenNormalized or takenNormalized.count ~= 1 or not same(takenNormalized, unit) then
    recover(taken)
    return
  end

  unit.parameters = copy(unit.parameters or {})
  unit.parameters.genomeInspected = true
  local leftover = fubeesContainer.putExact(entity.id(), unit, ANALYZED, normalize)
  if leftover then
    recover(taken)
  end
end

function init()
  storage.recoveryEscrow = storage.recoveryEscrow
  script.setUpdateDelta(config.getParameter("scriptDelta", 5))
end

function update()
  process()
end

function die()
  if storage.recoveryEscrow then
    world.spawnItem(storage.recoveryEscrow, entity.position())
    storage.recoveryEscrow = nil
  end
end
