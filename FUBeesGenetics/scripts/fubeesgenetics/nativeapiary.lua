-- Ordinary FU apiaries do not need the hybrid code until a hybrid enters a
-- queen or drone slot. Keep their startup path as small as the native script.
require "/bees/apiary.lua"

local nativeTick, nativeTryBeeSpawn = beeTick, tryBeeSpawn
local installed = false

local function hybridInHive()
  local queenItem = world.containerItemAt(entity.id(), queenSlot - 1)
  if queenItem and queenItem.name:match("^bee_hybrid_") then return true end
  for _, slot in ipairs(droneSlots) do
    local droneItem = world.containerItemAt(entity.id(), slot - 1)
    if droneItem and droneItem.name:match("^bee_hybrid_") then return true end
  end
  return false
end

function beeTick(dt)
  if not installed and hybridInHive() then
    require "/scripts/fubeesgenetics/containerutil.lua"
    require "/scripts/fubeesgenetics/hybridbees.lua"
  fubeesContainer.install()
    beeTick = nativeTick
    hybridbees.install(1)
    installed = true
    return beeTick(dt)
  end
  return nativeTick(dt)
end

-- Native FU can spawn wild native bees. No bee_hybrid monster exists: hybrid
-- offspring remain inventory items, as they do in the powered apiary.
function tryBeeSpawn(family, genome)
  if family ~= "hybrid" then return nativeTryBeeSpawn(family, genome) end
end
