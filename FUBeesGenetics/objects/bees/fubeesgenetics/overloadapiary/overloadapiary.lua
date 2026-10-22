require "/scripts/fupower.lua"
require "/bees/apiary.lua"
require "/scripts/fubeesgenetics/containerutil.lua"
require "/scripts/fubeesgenetics/hybridbees.lua"

local upstreamInit, upstreamUpdate = init, update2
local upstreamDroneProduction, upstreamQueenProduction = droneProduction, queenProduction
local upstreamAgeQueen = ageQueen

function init()
  fubeesContainer.install()
  upstreamInit()
  power.init()
  -- An unloaded power network cannot pay for production. Discard FU's offline
  -- simulation timestamps, including timestamps from an older saved version.
  storage.lastActive, storage.unfinishedTicks, ticksToSimulate = nil, nil, nil
end

function update(dt)
  if biome == "unknown" then return end
  power.update(dt)
  if power.consume(config.getParameter("isn_requiredPower", 12) * dt) then
    upstreamUpdate(dt)
  else
    setAnimationStates(true, false, false)
  end
end
update2 = update

function uninit()
  storage.lastActive, storage.unfinishedTicks = nil, nil
end

function droneProduction(drone)
  local oldBonus = frameBonuses.baseProduction
  local base = genelib.statFromGenomeToValue(drone.parameters.genome, "baseProduction")
  frameBonuses.baseProduction = oldBonus + base * 0.2
  upstreamDroneProduction(drone)
  frameBonuses.baseProduction = oldBonus
end

local nativeStat = genelib.statFromGenomeToValue
local boostDroneBreeding = false
genelib.statFromGenomeToValue = function(genome, stat, ...)
  local value = nativeStat(genome, stat, ...)
  if boostDroneBreeding and stat == "droneBreedRate" and queen and genome == queen.parameters.genome then return value * 1.2 end
  return value
end

function queenProduction()
  boostDroneBreeding = true
  upstreamQueenProduction()
  boostDroneBreeding = false
end

function ageQueen(amount) return upstreamAgeQueen((amount or 1) / 0.7) end
hybridbees.install(1.2)

-- The powered apiary keeps all bees in its container; FU's random capturable
-- world-bee spawn is disabled for both native and hybrid queens.
function tryBeeSpawn() end
