-- Ordinary FU apiaries do not need the hybrid code until a hybrid enters a
-- queen or drone slot. Keep their startup path as small as the native script.
require "/bees/apiary.lua"

require "/scripts/fubeesgenetics/apiaryhybridloader.lua"
local nativeTryBeeSpawn = tryBeeSpawn
fubeesApiary.deferHybrids(1)

-- Native FU can spawn wild native bees. No bee_hybrid monster exists: hybrid
-- offspring remain inventory items, as they do in the powered apiary.
function tryBeeSpawn(family, genome)
  if family ~= "hybrid" then return nativeTryBeeSpawn(family, genome) end
end
