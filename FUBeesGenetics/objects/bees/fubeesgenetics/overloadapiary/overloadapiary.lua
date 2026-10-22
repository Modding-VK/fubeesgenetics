-- Powered variant of the Frackin Universe apiary. Keep the upstream apiary's
-- storage, frame, genetics, biome and production behavior, then apply the
-- industrial multipliers and gate simulation on FU power.
require "/scripts/fupower.lua"
require "/bees/apiary.lua"

local upstreamInit = init
local upstreamUpdate = update
local upstreamUpdate2 = update2

local function powerAvailable(dt)
	power.update(dt)
	local watts = config.getParameter("isn_requiredPower", 12)
	if power.consume(watts * dt) then return true end
	setAnimationStates(true, false, false)
	return false
end

function init()
	upstreamInit()
	power.init()
end

-- The upstream first-update path switches the object's update callback to
-- update2. Both paths therefore enforce the same continuous power draw.
function update(dt)
	if powerAvailable(dt) then upstreamUpdate(dt) end
end

function update2(dt)
	if powerAvailable(dt) then upstreamUpdate2(dt) end
end

local upstreamDroneProduction = droneProduction
function droneProduction(drone)
	local oldBonus = frameBonuses.baseProduction
	local base = genelib.statFromGenomeToValue(drone.parameters.genome, "baseProduction")
	frameBonuses.baseProduction = oldBonus + base * 0.2
	upstreamDroneProduction(drone)
	frameBonuses.baseProduction = oldBonus
end

local upstreamStatFromGenomeToValue = genelib.statFromGenomeToValue
local boostDroneBreeding = false
genelib.statFromGenomeToValue = function(genome, stat, ...)
	local value = upstreamStatFromGenomeToValue(genome, stat, ...)
	if boostDroneBreeding and stat == "droneBreedRate" and queen
		and genome == queen.parameters.genome then
		return value * 1.2
	end
	return value
end

local upstreamQueenProduction = queenProduction
function queenProduction()
	boostDroneBreeding = true
	upstreamQueenProduction()
	boostDroneBreeding = false
end

local upstreamAgeQueen = ageQueen
function ageQueen(amount)
	return upstreamAgeQueen((amount or 1) / 0.7)
end

-- Hybrid lineages are handled here so native FU apiaries remain untouched.
require "/scripts/fubeesgenetics/hybridbees.lua"
hybridbees.install()
