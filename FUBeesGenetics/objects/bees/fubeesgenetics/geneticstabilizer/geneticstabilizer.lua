require "/scripts/fubeesgenetics/containerutil.lua"
require "/scripts/fubeesgenetics/fubeesgenetics_beegeneticadapter.lua"
require "/scripts/fubeesgenetics/itemtags.lua"

local copy, same = fubeesContainer.copy, fubeesContainer.same
local normalize = fubeesgenetics_beegeneticadapter.normalize
local input, output = 0, 1
local candidate, progress
local working

local function setWorking(value)
  if working ~= value then
    animator.setAnimationState("treatment", value and "working" or "idle")
    working = value
  end
end

local function specimen(item)
  item = normalize(item)
  if not item then return nil end
  local ok, bee = fubeesItemTags.has(item.name, "bee")
  local genome = item.parameters.genome
  if not ok or not bee or type(genome) ~= "string" or #genome ~= 18 or genome:find("[^0-9A-Z]") then return nil end
  item = copy(item)
  item.count = 1
  return item
end

local function recover(item)
  local leftover = fubeesContainer.putExact(entity.id(), item, input, normalize)
  if leftover then storage.recoveryEscrow = copy(leftover) end
end

function init()
  candidate, progress = nil, 0
  working = nil
  setWorking(false)
  script.setUpdateDelta(config.getParameter("scriptDelta", 30))
end

function update(dt)
  if storage.recoveryEscrow then
    setWorking(false)
    if not world.containerItemAt(entity.id(), input) then
      local left = fubeesContainer.putExact(entity.id(), storage.recoveryEscrow, input, normalize)
      if not left then storage.recoveryEscrow = nil end
    end
    candidate, progress = nil, 0
    return
  end
  if world.containerItemAt(entity.id(), output) then setWorking(false); candidate, progress = nil, 0; return end
  local current = specimen(world.containerItemAt(entity.id(), input))
  if not current then setWorking(false); candidate, progress = nil, 0; return end
  if not same(candidate, current) then candidate, progress = current, 0 end
  setWorking(true)
  progress = progress + dt
  if progress < 10 then return end
  setWorking(false)
  candidate, progress = nil, 0
  local taken = world.containerTakeNumItemsAt(entity.id(), input, 1)
  if not taken then return end
  if not same(normalize(taken), current) then recover(taken); return end
  if math.random() < 0.30 then return end
  local genome = current.parameters.genome
  local raw = genelib.statFromGenomeToDecimal(genome, "mutationChance")
  current.parameters.genome = genelib.modifyGenomeStat(genome, "mutationChance", math.floor(raw / 2 + 0.5) - raw)
  local leftover = fubeesContainer.putExact(entity.id(), current, output, normalize)
  if leftover then recover(taken) end
end

function die()
  if storage.recoveryEscrow then
    world.spawnItem(storage.recoveryEscrow, entity.position())
    storage.recoveryEscrow = nil
  end
end
