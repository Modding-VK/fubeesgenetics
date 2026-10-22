-- Keep FU's ordinary apiary behavior, adding lineage-aware hybrid production.
require "/bees/apiary.lua"
require "/scripts/fubeesgenetics/containerutil.lua"
require "/scripts/fubeesgenetics/hybridbees.lua"

local nativeInit, nativeTryBeeSpawn = init, tryBeeSpawn

function init()
  fubeesContainer.install()
  nativeInit()
end

hybridbees.install(1)

-- Native FU can spawn wild native bees. No bee_hybrid monster exists: hybrid
-- offspring remain inventory items, as they do in the powered apiary.
function tryBeeSpawn(family, genome)
  if family ~= "hybrid" then return nativeTryBeeSpawn(family, genome) end
end
