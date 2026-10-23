require "/scripts/fupower.lua"
require "/bees/apiary.lua"
require "/scripts/fubeesgenetics/containerutil.lua"

local upstreamInit, upstreamUpdate = init, update2
local upstreamDroneProduction, upstreamQueenProduction = droneProduction, queenProduction
local upstreamAgeQueen = ageQueen
local powered = false

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
  powered = power.consume(config.getParameter("isn_requiredPower", 12) * dt)
  upstreamUpdate(dt)
end
update2 = update

function uninit()
  storage.lastActive, storage.unfinishedTicks = nil, nil
end

function droneProduction(drone)
  local oldBonus = frameBonuses.baseProduction
  local base = genelib.statFromGenomeToValue(drone.parameters.genome, "baseProduction")
  frameBonuses.baseProduction = oldBonus + (powered and base * 0.2 or 0)
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

local nativeTick = beeTick
local hybridInstalled = false
function beeTick(dt)
  if not hybridInstalled then
    local queenItem = world.containerItemAt(entity.id(), queenSlot - 1)
    local found = queenItem and queenItem.name:match("^bee_hybrid_")
    if not found then
      for _, slot in ipairs(droneSlots) do
        local droneItem = world.containerItemAt(entity.id(), slot - 1)
        if droneItem and droneItem.name:match("^bee_hybrid_") then found = true; break end
      end
    end
    if found then
      require "/scripts/fubeesgenetics/hybridbees.lua"
      beeTick = nativeTick
      hybridbees.install(function() return powered and 1.2 or 1 end)
      hybridInstalled = true
      return beeTick(dt)
    end
  end
  return nativeTick(dt)
end

-- The powered apiary keeps all bees in its container; FU's random capturable
-- world-bee spawn is disabled for both native and hybrid queens.
function tryBeeSpawn() end
