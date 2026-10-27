require "/scripts/fupower.lua"
require "/bees/apiary.lua"
require "/scripts/fubeesgenetics/containerutil.lua"
require "/scripts/fubeesgenetics/apiaryhybridloader.lua"

local upstreamInit, upstreamUpdate = init, update2
local upstreamDroneProduction, upstreamQueenProduction = droneProduction, queenProduction
local upstreamAgeQueen = ageQueen
local powered = false
local displayedPowered = false
local requiredPower

function init()
  powered, displayedPowered = false, false
  requiredPower = config.getParameter("isn_requiredPower", 12)
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
  powered = power.consume(requiredPower * dt) == true
  upstreamUpdate(dt)
  -- The powered image currently matches default. Change the animator only
  -- when power availability changes, using the same decision as production.
  if powered ~= displayedPowered then
    animator.setAnimationState("base", powered and "powered" or "default", true)
    displayedPowered = powered
  end
end
update2 = update

function uninit()
  storage.lastActive, storage.unfinishedTicks = nil, nil
end

function droneProduction(drone)
  if not powered then return upstreamDroneProduction(drone) end
  local oldBonus = frameBonuses.baseProduction
  local base = genelib.statFromGenomeToValue(drone.parameters.genome, "baseProduction")
  frameBonuses.baseProduction = oldBonus + (base * 0.2)
  upstreamDroneProduction(drone)
  frameBonuses.baseProduction = oldBonus
end

local nativeStat = genelib.statFromGenomeToValue
local boostDroneBreeding = false
genelib.statFromGenomeToValue = function(genome, stat, ...)
  local value = nativeStat(genome, stat, ...)
  if powered and boostDroneBreeding and stat == "droneBreedRate" and queen and genome == queen.parameters.genome then return value * 1.2 end
  return value
end

function queenProduction()
  boostDroneBreeding = true
  upstreamQueenProduction()
  boostDroneBreeding = false
end

function ageQueen(amount) return upstreamAgeQueen((amount or 1) / 0.7) end

fubeesApiary.deferHybrids(function() return powered and 1.2 or 1 end)

-- The powered apiary keeps all bees in its container; FU's random capturable
-- world-bee spawn is disabled for both native and hybrid queens.
function tryBeeSpawn() end
