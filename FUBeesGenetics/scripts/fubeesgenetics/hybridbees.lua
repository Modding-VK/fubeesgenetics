require "/bees/genomeLibrary.lua"

hybridbees = hybridbees or {}

local hybridCatalog = root.assetJson("/bees/hybridSpecies.config")
local speciesById = {}
local speciesByPair = {}
local nativeParents = hybridCatalog.production.parents
local getFlowerLikenessNative

for _, species in ipairs(hybridCatalog.hybrids) do
  speciesById[species.id] = species
  speciesByPair[species.parentFamilies[1] .. ":" .. species.parentFamilies[2]] = species
end

local function familyFromItem(item)
  if not item or type(item.name) ~= "string" then return nil end
  return item.name:match("^bee_([^_]+)_[^_]+$")
end

local function pairKey(familyA, familyB)
  if familyA < familyB then return familyA .. ":" .. familyB end
  return familyB .. ":" .. familyA
end

local function midpoint(a, b)
  if a == b then return a end
  local average = (a + b) / 2
  if average < 2 then return math.ceil(average) end
  return math.floor(average)
end

local function ensureGenome(item)
  if item.parameters and item.parameters.genome then return item.parameters.genome end
  return genelib.generateDefaultGenome(item.name)
end

local function parentStats(item)
  local genome = ensureGenome(item)
  return genelib.returnFullGenomeStats(genome), genome
end

local function geneForGenome(statsA, genomeA, statsB, genomeB, stat, exceptions)
  local rawA = genelib.statFromGenomeToDecimal(genomeA, stat)
  local rawB = genelib.statFromGenomeToDecimal(genomeB, stat)
  local raw

  if stat == "subtype" then
    raw = math.random(1, 2)
  elseif stat == "workTime" then
    local a = statsA.workTime
    local b = statsB.workTime
    if a == b and a ~= "both" then
      raw = a == "night" and 1 or 0
    elseif a == "both" and b ~= "both" then
      raw = b == "night" and 1 or 0
    elseif b == "both" and a ~= "both" then
      raw = a == "night" and 1 or 0
    else
      raw = math.random(0, 1)
    end
  elseif stat == "mutationChance" then
    raw = math.max(rawA, rawB) + 1
    if raw > (genelib.libraryLength ^ 2 - 1) then
      raw = genelib.libraryLength ^ 2 - 1
      table.insert(exceptions, stat)
    end
  else
    raw = math.min(rawA, rawB) - 1
    if raw < 0 then
      raw = 0
      table.insert(exceptions, stat)
    end
  end

  return genelib.numberToStat(raw)
end

function hybridbees.makeGenome(queenItem, droneItem)
  local statsA, genomeA = parentStats(queenItem)
  local statsB, genomeB = parentStats(droneItem)
  local exceptions = {}
  local genome = ""
  for _, stat in ipairs(genelib.statOrder) do
    genome = genome .. geneForGenome(statsA, genomeA, statsB, genomeB, stat, exceptions)
  end
  return genome, exceptions
end

function hybridbees.makeLineage(queenItem, droneItem, genome)
  local familyA = familyFromItem(queenItem)
  local familyB = familyFromItem(droneItem)
  if not familyA or not familyB or familyA == familyB or familyA == "hybrid" or familyB == "hybrid" then
    return nil, "invalidParents"
  end

  local species = speciesByPair[pairKey(familyA, familyB)]
  if not species then return nil, "unknownSpecies" end

  local queenGenome = ensureGenome(queenItem)
  local droneGenome = ensureGenome(droneItem)
  local queenSubtype = genelib.statFromGenomeToValue(queenGenome, "subtype")
  local droneSubtype = genelib.statFromGenomeToValue(droneGenome, "subtype")
  local parentSubtypes = {}
  parentSubtypes[familyFromItem(queenItem)] = queenSubtype
  parentSubtypes[familyFromItem(droneItem)] = droneSubtype

  local beeData = root.assetJson("/bees/beeData.config")
  local subtypeNames = {}
  for family, subtype in pairs(parentSubtypes) do
    subtypeNames[family] = beeData.stats[family][subtype].name
  end
  local biomeValues = {}
  local parentBiomesA = beeData.biomeLikeness[familyA] or {}
  local parentBiomesB = beeData.biomeLikeness[familyB] or {}
  for biome, value in pairs(parentBiomesA) do
    biomeValues[biome] = midpoint(value, parentBiomesB[biome] or 2)
  end
  for biome, value in pairs(parentBiomesB) do
    if biomeValues[biome] == nil then biomeValues[biome] = midpoint(parentBiomesA[biome] or 2, value) end
  end

  local preferredPlants = {}
  for _, plant in ipairs(species.preferredPlants) do
    preferredPlants[plant.parent] = plant.id
  end

  local parents = {familyA, familyB}
  table.sort(parents)
  local subtypeId = genelib.statFromGenomeToValue(genome, "subtype")
  local lineage = {
    speciesId = species.id,
    parentFamilies = parents,
    queenFamily = familyFromItem(queenItem),
    droneFamily = familyFromItem(droneItem),
    parentSubtypes = parentSubtypes,
    parentFlowerSubtypes = subtypeNames,
    preferredPlants = preferredPlants,
    biomeLikeness = biomeValues,
    subspecies = subtypeId
  }
  return lineage
end

local function isHybrid(item)
  return item and item.parameters and item.parameters.hybridLineage ~= nil
end

local function speciesForLineage(lineage)
  return lineage and speciesById[lineage.speciesId]
end

local function hybridBiomeFavor(lineage)
  local likeness = lineage.biomeLikeness[biome] or 2
  if likeness == 0 then return -1 end
  if likeness == 1 then return beeData.biomeDisliked end
  if likeness == 3 then return beeData.biomeFavorite end
  return beeData.biomeLiked
end

local function hybridFlowerFavor(lineage)
  local names = lineage.parentFlowerSubtypes or {}
  local total, count = 0, 0
  for _, family in ipairs(lineage.parentFamilies) do
    local name = names[family]
    if name then
      local favor = getFlowerLikenessNative(name)
      if favor >= 0 then
        total = total + favor
        count = count + 1
      end
    end
  end
  if count == 0 then return -1 end
  return total / count
end

local function productionRequirements(lineage)
  local species = speciesForLineage(lineage)
  if not species then return nil end
  if not species.subspecies[lineage.subspecies] then return nil end

  local requirements = {}
  local priorityFamily = lineage.subspecies == 1 and lineage.queenFamily or lineage.droneFamily
  for _, family in ipairs(lineage.parentFamilies) do
    local weight = family == priorityFamily and 0.5 or 0.25
    local parent = nativeParents[family]
    local subtype = parent and parent.subspecies[lineage.parentSubtypes[family]]
    if subtype then
      for product, requirement in pairs(subtype.production) do
        local rate = weight * subtype.baseProduction / requirement
        requirements[product] = (requirements[product] or 0) + rate
      end
    end
  end

  local baseProduction = genelib.statFromGenomeToValue(queen.parameters.genome, "baseProduction")
  for product, rate in pairs(requirements) do
    if rate > 0 then requirements[product] = baseProduction / rate end
  end
  return requirements
end

local function hybridDroneProduction(drone)
  local lineage = drone.parameters.hybridLineage or (queen and queen.parameters.hybridLineage)
  if not queen or not isHybrid(queen)
    or queen.parameters.hybridLineage.speciesId ~= (lineage and lineage.speciesId) then
    return
  end
  local requirements = productionRequirements(lineage)
  if not requirements then return end

  local biomeFavor = hybridBiomeFavor(lineage)
  if biomeFavor == -1 then return end
  local flowerFavor = hybridFlowerFavor(lineage)
  if flowerFavor == -1 then return end
  if ticksToSimulate and ticksToSimulate % 2 == 1
    and genelib.statFromGenomeToValue(drone.parameters.genome, "workTime") ~= "both" then
    return
  end

  local production = (genelib.statFromGenomeToValue(drone.parameters.genome, "baseProduction")
    + frameBonuses.baseProduction) * 1.2
    * (((drone.count / 1000) + math.min(1 / ((1 + hivesAroundHive) * 0.75), 1)
      + flowerFavor + biomeFavor) / 4) * 0.5

  for product, requirement in pairs(requirements) do
    droneProductionProgress[product] = (droneProductionProgress[product] or 0) + production
    if droneProductionProgress[product] >= requirement then
      local count = math.floor(droneProductionProgress[product] / requirement)
      droneProductionProgress[product] = droneProductionProgress[product] - requirement * count
      local item = {name = product, count = count}
      for i = firstInventorySlot, slotCount do
        item = world.containerPutItemsAt(entity.id(), item, i - 1)
        contents[i] = world.containerItemAt(entity.id(), i - 1)
        if not item then break end
      end
      if item and not ticksToSimulate then
        world.spawnItem(item, entity.position(), nil, nil, nil, 0.5)
      end
    end
  end
end

function hybridbees.install()
  getFlowerLikenessNative = getFlowerLikeness
  local nativeBiomeFavor = getBiomeFavor
  local nativeDroneProduction = droneProduction
  local nativeGenerateYoungQueen = generateYoungQueen
  local nativeTryBeeSpawn = tryBeeSpawn

  getBiomeFavor = function(name)
    if name and name:match("^bee_hybrid_") and queen and isHybrid(queen) then
      return hybridBiomeFavor(queen.parameters.hybridLineage)
    end
    return nativeBiomeFavor(name)
  end

  getFlowerLikeness = function(subtypeName)
    if queen and isHybrid(queen) then
      return hybridFlowerFavor(queen.parameters.hybridLineage)
    end
    return getFlowerLikenessNative(subtypeName)
  end

  droneProduction = function(drone)
    if isHybrid(drone) or (queen and isHybrid(queen)) then
      return hybridDroneProduction(drone)
    end
    return nativeDroneProduction(drone)
  end

  generateYoungQueen = function()
    local item = nativeGenerateYoungQueen()
    if queen and isHybrid(queen) then
      item.parameters.hybridLineage = copy(queen.parameters.hybridLineage)
    end
    return item
  end

  tryBeeSpawn = function(family, genome)
    if family == "hybrid" then return end
    return nativeTryBeeSpawn(family, genome)
  end
end

function hybridbees.isRivalHybridization(species)
  return species and species.parentSpeciesAreRivals == true
end

function hybridbees.successChance(species)
  if hybridbees.isRivalHybridization(species) then return 0.1 end
  return 0.3
end

function hybridbees.speciesForParents(familyA, familyB)
  return speciesByPair[pairKey(familyA, familyB)]
end
