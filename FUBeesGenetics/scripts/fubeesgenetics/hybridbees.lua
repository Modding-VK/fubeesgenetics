require "/bees/genomeLibrary.lua"
require "/scripts/fubeesgenetics/containerutil.lua"
require "/scripts/fubeesgenetics/itemtags.lua"

hybridbees = {}
local M = hybridbees
local copy, same = fubeesContainer.copy, fubeesContainer.same
local plants, byPair, nativeData, rivals

-- Engine callbacks are unavailable while scripts are first being loaded.
local function loadData()
  if nativeData then return end
  plants = root.assetJson("/bees/hybridPlants.config")
  -- FU apiaries already loaded this in init; reuse that table in their Lua
  -- contexts instead of parsing the same asset a second time.
  nativeData = beeData or root.assetJson("/bees/beeData.config")
  byPair, rivals = {}, {}
  for family in pairs(nativeData.stats) do
    if family ~= "hybrid" then rivals[family] = {} end
  end
  for family, entries in pairs(nativeData.rivals) do
    if rivals[family] then
      if type(entries) == "string" then entries = {entries} end
      for _, other in ipairs(entries or {}) do
        if rivals[other] then rivals[family][other], rivals[other][family] = true, true end
      end
    end
  end
end

function M.family(item)
  local name = type(item) == "table" and item.name or item
  return type(name) == "string" and name:match("^bee_([^_]+)_[^_]+$") or nil
end

function M.isHybrid(item) return M.family(item) == "hybrid" end

function M.speciesForParents(a, b)
  if type(a) ~= "string" or type(b) ~= "string" or a == b then return nil end
  loadData()
  if not rivals[a] or not rivals[b] or not plants[a] or not plants[b] then return nil end
  if a > b then a, b = b, a end
  local key = a .. ":" .. b
  if byPair[key] then return byPair[key] end
  local inherited = {}
  for family in pairs(rivals[a]) do inherited[family] = true end
  for family in pairs(rivals[b]) do inherited[family] = true end
  local isRival = rivals[a][b] or false
  if isRival then inherited[a], inherited[b] = true, true end
  local rivalFamilies = {}
  for family in pairs(inherited) do rivalFamilies[#rivalFamilies + 1] = family end
  table.sort(rivalFamilies)
  local species = {id = "hybrid_" .. a .. "_" .. b, parentFamilies = {a, b},
    parentSpeciesAreRivals = isRival, rivalNativeFamilies = rivalFamilies,
    preferredPlants = {{parent = a, id = plants[a].id, likeness = plants[a].likeness},
      {parent = b, id = plants[b].id, likeness = plants[b].likeness}}}
  byPair[key] = species
  return species
end

local function validGenome(genome, family)
  loadData()
  if type(genome) ~= "string" or #genome ~= 18 or genome:find("[^0-9A-Z]") then return false end
  local subtype = genelib.statFromGenomeToValue(genome, "subtype")
  return nativeData.stats[family] and nativeData.stats[family][subtype] ~= nil, subtype
end

local function parentGenome(item)
  local genome = item.parameters and item.parameters.genome
  -- Pinned FU's Shuttershard default uses mutationChance=0.05. Its encoder
  -- rounds that gene to a single "0" instead of "00". Repair only that exact
  -- known default for inheritance; never rewrite the inventory specimen.
  if M.family(item) == "crystalwing" and genome == "02040F0101GO0OO00" then
    return "02040F0101GO00OO00"
  end
  return genome
end

local function ensureGenome(item)
  item.parameters = item.parameters or {}
  if not item.parameters.genome then item.parameters.genome = genelib.generateDefaultGenome(item.name) end
  return parentGenome(item)
end

function M.validParent(item, caste)
  loadData()
  local family = M.family(item)
  if not family or family == "hybrid" or not nativeData.stats[family] then return false end
  local ok, tagged = fubeesItemTags.has(item.name, caste)
  if not ok or not tagged then return false end
  local valid = validGenome(parentGenome(item), family)
  return valid
end

function M.makeGenome(queenItem, droneItem)
  local a, b = ensureGenome(queenItem), ensureGenome(droneItem)
  local genome, exceptions = "", {}
  local function round(value) return math.floor(value + 0.5) end
  for _, stat in ipairs(genelib.statOrder) do
    local av, bv = genelib.statFromGenomeToDecimal(a, stat), genelib.statFromGenomeToDecimal(b, stat)
    local value
    if stat == "subtype" then value = math.random(1, 2)
    elseif stat == "workTime" then
      if av == bv and av < 2 then value = av
      elseif av >= 2 and bv < 2 then value = bv
      elseif bv >= 2 and av < 2 then value = av
      else value = math.random(0, 1) end
    elseif stat == "mutationChance" then
      value = math.min(1295, math.max(av, bv) + 1)
      if value <= math.max(av, bv) then exceptions[#exceptions + 1] = stat end
    elseif stat == "miteResistance" then
      -- This gene is encoded around a neutral midpoint; scale its resistance,
      -- not the raw code, so neutral parents do not gain a large intolerance.
      local weaker = math.min(av, bv)
      local neutral = genelib.libraryLength ^ 2 / 2
      local resistance = weaker - neutral
      value = math.max(0, math.min(1295, neutral + round(resistance * (resistance >= 0 and 2 / 3 or 4 / 3))))
      if value >= weaker then exceptions[#exceptions + 1] = stat end
    else
      local weaker = math.min(av, bv)
      -- Reduce the weaker parent's positive trait by one third, rounding to
      -- the nearest gene unit. A positive trait cannot fall below one.
      value = weaker == 0 and 0 or math.max(1, round(weaker * 2 / 3))
      if value >= weaker then exceptions[#exceptions + 1] = stat end
    end
    genome = genome .. genelib.numberToStat(value)
  end
  return genome, exceptions
end

local function midpoint(a, b)
  local value = (a + b) / 2
  return value < 2 and math.ceil(value) or math.floor(value)
end

-- Keep all intolerances. Pick one favourite per parent, deterministically.
-- Only explicitly declared conflicts are averaged (absence is not a conflict).
function M.inheritBiomes(a, b)
  local result, names = {}, {}
  for name in pairs(a) do names[name] = true end
  for name in pairs(b) do names[name] = true end
  for name in pairs(names) do
    local av, bv = a[name], b[name]
    local value = av ~= nil and bv ~= nil and midpoint(av, bv) or (av or bv)
    result[name] = value
  end
  local selected = {}
  for _, parent in ipairs({a, b}) do
    local favorites = {}
    for name, value in pairs(parent) do
      if value == 3 and result[name] == 3 then favorites[#favorites + 1] = name end
    end
    table.sort(favorites)
    if favorites[1] then selected[favorites[1]] = true end
  end
  for name, value in pairs(result) do if value == 3 and not selected[name] then result[name] = 2 end end
  return result
end

local function refreshEnvironment(lineage, species)
  lineage.biomeLikeness = M.inheritBiomes(nativeData.biomeLikeness[lineage.queenFamily] or {},
    nativeData.biomeLikeness[lineage.droneFamily] or {})
  lineage.preferredPlants = {}
  for _, plant in ipairs(species.preferredPlants) do lineage.preferredPlants[plant.parent] = plant.id end
  lineage.version = 2
end

function M.makeLineage(queenItem, droneItem, genome)
  local a, b = M.family(queenItem), M.family(droneItem)
  local species = M.speciesForParents(a, b)
  if not species or not M.validParent(queenItem, "queen") or not M.validParent(droneItem, "drone")
    or not validGenome(genome, "hybrid") then return nil, "invalidParents" end
  local lineage = {speciesId = species.id, parentFamilies = copy(species.parentFamilies),
    queenFamily = a, droneFamily = b, parentSubtypes = {},
    subspecies = genelib.statFromGenomeToValue(genome, "subtype")}
  lineage.parentSubtypes[a] = genelib.statFromGenomeToValue(ensureGenome(queenItem), "subtype")
  lineage.parentSubtypes[b] = genelib.statFromGenomeToValue(ensureGenome(droneItem), "subtype")
  refreshEnvironment(lineage, species)
  return lineage
end

function M.lineage(item)
  if not M.isHybrid(item) or not item.parameters then return nil end
  local lineage = item.parameters.hybridLineage
  if type(lineage) ~= "table" then return nil end
  local species = M.speciesForParents(lineage.queenFamily, lineage.droneFamily)
  if not species or species.id ~= lineage.speciesId
    or type(lineage.parentSubtypes) ~= "table" then return nil end
  local valid, subtype = validGenome(item.parameters.genome, "hybrid")
  if not valid then return nil end
  for _, family in ipairs(species.parentFamilies) do
    if not nativeData.stats[family][lineage.parentSubtypes[family]] then return nil end
  end
  if not same(lineage.parentFamilies, species.parentFamilies) then
    lineage.parentFamilies = copy(species.parentFamilies)
  end
  lineage.subspecies = subtype
  if lineage.version ~= 2 then refreshEnvironment(lineage, species) end
  return lineage
end

function M.compatible(a, b)
  local la, lb = M.lineage(a), M.lineage(b)
  return la and lb and la.speciesId == lb.speciesId or false
end

local function contains(list, value)
  if type(list) == "string" then return list == value end
  for _, entry in ipairs(list or {}) do if entry == value then return true end end
  return false
end

function M.areRivals(a, b)
  loadData()
  local fa, fb, la, lb = M.family(a), M.family(b), M.lineage(a), M.lineage(b)
  if la and lb and la.speciesId == lb.speciesId then return false end
  if la then
    local rivals = M.speciesForParents(la.queenFamily, la.droneFamily).rivalNativeFamilies
    if lb then
      for _, parent in ipairs(lb.parentFamilies) do if contains(rivals, parent) then return true end end
    elseif contains(rivals, fb) then return true end
  end
  if lb then
    local rivals = M.speciesForParents(lb.queenFamily, lb.droneFamily).rivalNativeFamilies
    if la then
      for _, parent in ipairs(la.parentFamilies) do if contains(rivals, parent) then return true end end
    elseif contains(rivals, fa) then return true end
  end
  if la or lb or not fa or not fb or fa == fb then return false end
  return contains(nativeData.rivals[fa], fb) or contains(nativeData.rivals[fb], fa)
end

function M.successChance(species) return species and species.parentSpeciesAreRivals and 0.1 or 0.3 end

-- Each denominator is fixed by its native parental subtype, never by the
-- current queen's genes. The +1 floor gives zero-gene hybrids a small finite
-- output while preserving the effect of genetic improvement and frame bonuses.
function M.productionRates(lineage, genome, frameBonus, multiplier)
  loadData()
  local rates = {}
  local genetic = genelib.statFromGenomeToValue(genome, "baseProduction")
  local priority = lineage.subspecies == 1 and lineage.queenFamily or lineage.droneFamily
  for _, family in ipairs(lineage.parentFamilies) do
    local parent = nativeData.stats[family][lineage.parentSubtypes[family]]
    local weight = family == priority and 0.5 or 0.25
    local factor = ((genetic + 1) * (multiplier or 1) + (frameBonus or 0)) / (math.max(0, parent.baseProduction) + 1)
    for product, requirement in pairs(parent.production) do
      if requirement > 0 then rates[product] = (rates[product] or 0) + math.max(0, weight * parent.baseProduction / requirement * factor) end
    end
  end
  return rates
end

local tickFlowers, inBeeTick
function M.flowerFavor(lineage)
  if inBeeTick and not tickFlowers then tickFlowers = {} end
  if tickFlowers and tickFlowers[lineage.speciesId] ~= nil then return tickFlowers[lineage.speciesId] end
  loadData()
  local preferences = {}
  for _, plant in ipairs(M.speciesForParents(lineage.queenFamily, lineage.droneFamily).preferredPlants) do
    preferences[plant.id] = math.max(preferences[plant.id] or 0, plant.likeness or 1)
  end
  local objects = world.objectQuery(entity.position(), nativeData.flowerSearchRadius,
    {withoutEntityId = entity.id(), order = "nearest"})
  local count, favor = 0, 0
  for _, id in ipairs(objects) do
    local stage = world.farmableStage(id)
    if stage then
      local stages = world.getObjectParameter(id, "stages", {})
      local name = world.entityName(id)
      local addition = preferences[name] or nativeData.flowerDefaultLikeness
      addition = addition * (stage > #stages - 2 and nativeData.flowerLastTwoStagesModifier or nativeData.flowerLowerStagesModifier)
      count = count + 1
      favor = favor + addition * (count > nativeData.flowerMinimum and nativeData.flowerExtrasFavorModifier or 1)
      if count >= nativeData.flowerMaximum then break end
    end
  end
  if count == 0 then favor = -1
  elseif count <= nativeData.flowerMinimum then favor = favor / (nativeData.flowerMinimum / count) end
  if tickFlowers then tickFlowers[lineage.speciesId] = favor end
  return favor
end

local function putOutput(item)
  for slot = firstInventorySlot, slotCount do
    item = world.containerPutItemsAt(entity.id(), item, slot - 1)
    contents[slot] = world.containerItemAt(entity.id(), slot - 1)
    if not item then return end
  end
  if item then world.spawnItem(item, entity.position()) end
end

function M.install(multiplier)
  multiplier = multiplier or 1
  local function currentMultiplier()
    return type(multiplier) == "function" and multiplier() or multiplier
  end
  local nativeBiome, nativeFlower, nativeDrone = getBiomeFavor, getFlowerLikeness, droneProduction
  local nativeYoung, nativeQueen, nativeTick = generateYoungQueen, queenProduction, beeTick
  local nativeSame, nativeActive, nativeRivalries = isSameQueen, isDroneActive, checkRivalries

  local function biomeFavor(lineage)
    -- Delegate to FU so resistance frames retain their original behavior.
    local previous = beeData.biomeLikeness.hybrid
    beeData.biomeLikeness.hybrid = lineage.biomeLikeness
    local result = nativeBiome("bee_hybrid_queen")
    beeData.biomeLikeness.hybrid = previous
    return result
  end
  getBiomeFavor = function(name)
    if M.family(name) == "hybrid" or name == "hybrid" then
      local lineage = M.lineage(queen)
      return lineage and biomeFavor(lineage) or -1
    end
    return nativeBiome(name)
  end
  getFlowerLikeness = function(subtype)
    local lineage = M.lineage(queen)
    if lineage then return M.flowerFavor(lineage) end
    return nativeFlower(subtype)
  end
  isSameQueen = function(a, b)
    if M.isHybrid(a) or M.isHybrid(b) then
      if not M.compatible(a, b) or not same(M.lineage(a), M.lineage(b)) then return false end
    end
    return nativeSame(a, b)
  end
  isDroneActive = function(drone)
    if M.isHybrid(drone) or M.isHybrid(queen) then
      if not M.compatible(drone, queen) then return false end
    end
    return nativeActive(drone)
  end
  checkRivalries = function()
    local halt = nativeRivalries()
    local q = contents[queenSlot]
    local hybridPresent = M.isHybrid(q)
    if not hybridPresent then
      for _, slot in ipairs(droneSlots) do
        if M.isHybrid(contents[slot]) then hybridPresent = true; break end
      end
    end
    if not hybridPresent then return halt end
    for i, slot in ipairs(droneSlots) do
      local a = contents[slot]
      if a and root.itemHasTag(a.name, "drone") then
        if q and (M.isHybrid(a) or M.isHybrid(q)) and M.areRivals(q, a) then
          halt = true
          world.containerTakeNumItemsAt(entity.id(), slot - 1, math.max(1, math.floor(a.count * beeData.droneDecayPercentile)))
          contents[slot] = world.containerItemAt(entity.id(), slot - 1)
        end
        for j = i + 1, #droneSlots do
          local b = contents[droneSlots[j]]
          if b and root.itemHasTag(b.name, "drone") and (M.isHybrid(a) or M.isHybrid(b)) and M.areRivals(a, b) then
            halt = true
            -- Genes may be zero after hybridization; avoid FU's toughness / 0.
            local ta = math.max(1, genelib.statFromGenomeToValue(a.parameters.genome, "droneToughness"))
            local tb = math.max(1, genelib.statFromGenomeToValue(b.parameters.genome, "droneToughness"))
            world.containerTakeNumItemsAt(entity.id(), slot - 1, math.min(a.count, math.max(1, math.ceil(b.count * tb / (3 * ta)))))
            world.containerTakeNumItemsAt(entity.id(), droneSlots[j] - 1, math.min(b.count, math.max(1, math.ceil(a.count * ta / (3 * tb)))))
            contents[slot] = world.containerItemAt(entity.id(), slot - 1)
            contents[droneSlots[j]] = world.containerItemAt(entity.id(), droneSlots[j] - 1)
          end
        end
      end
    end
    return halt
  end
  generateYoungQueen = function()
    local lineage = M.lineage(queen)
    if not lineage then return nativeYoung() end
    local genomes = {}
    for _, slot in ipairs(droneSlots) do
      local drone = contents[slot]
      if M.compatible(queen, drone) then genomes[#genomes + 1] = drone.parameters.genome end
    end
    local genome = genelib.evolveGenome(genelib.getAvarageGenome(queen.parameters.genome, genomes), frameBonuses.mutationChance)
    local child = {name = "bee_hybrid_youngQueen", count = 1,
      parameters = {genome = genome, hybridLineage = copy(lineage)}}
    M.lineage(child)
    return child
  end
  queenProduction = function()
    local lineage = M.lineage(queen)
    if not lineage then
      if M.isHybrid(queen) then return end
      return nativeQueen()
    end
    local bv, fv = biomeFavor(lineage), M.flowerFavor(lineage)
    if bv < 0 or fv < 0 then return end
    local hasMate = false
    for _, slot in ipairs(droneSlots) do if M.compatible(queen, contents[slot]) then hasMate = true end end
    local randomness = math.random(beeData.productionRandomModifierRange[1], beeData.productionRandomModifierRange[2]) * 0.01
    -- Unfertilized queens can establish their own drones; young queens need a
    -- compatible mate. A small floor keeps a zero breeding gene viable.
    local breed = (genelib.statFromGenomeToValue(queen.parameters.genome, "droneBreedRate") + 0.1) * currentMultiplier()
    droneProgress = droneProgress + (breed + frameBonuses.droneBreedRate * ((fv + bv) / 2)) * randomness * 0.25
    if hasMate then
      youngQueenProgress = youngQueenProgress + (0.01 + genelib.statFromGenomeToValue(queen.parameters.genome, "queenBreedRate")
        + frameBonuses.queenBreedRate * ((fv + bv) / 2)) * randomness * 0.5
      while youngQueenProgress >= beeData.youngQueenProductionRequirement do
        youngQueenProgress = youngQueenProgress - beeData.youngQueenProductionRequirement
        putOutput(generateYoungQueen())
      end
    end
    if droneProgress >= beeData.droneProductionRequirement then
      local count = math.floor(droneProgress / beeData.droneProductionRequirement)
      droneProgress = droneProgress % beeData.droneProductionRequirement
      local params = copy(queen.parameters); params.lifespan = nil; params.wild = nil
      local item = {name = "bee_hybrid_drone", count = count, parameters = params}
      for _, slot in ipairs(droneSlots) do
        item = world.containerPutItemsAt(entity.id(), item, slot - 1)
        contents[slot] = world.containerItemAt(entity.id(), slot - 1)
        if not item then break end
      end
      if item then putOutput(item) end
    end
    ageQueen()
  end
  beeTick = function(dt)
    -- Native FU otherwise requires existing drones before allowing any births.
    if M.lineage(queen) then hasDrones = true end
    inBeeTick = true
    -- Clear even on an engine exception; never reuse world data on another
    -- tick, a direct helper call, or an offline simulation iteration.
    local ok, result = pcall(nativeTick, dt)
    tickFlowers, inBeeTick = nil, false
    if not ok then error(result, 0) end
    return result
  end
  droneProduction = function(drone)
    if not M.isHybrid(drone) and not M.isHybrid(queen) then return nativeDrone(drone) end
    if not M.compatible(drone, queen) then return end
    local lineage = M.lineage(drone)
    local bv, fv = biomeFavor(lineage), M.flowerFavor(lineage)
    if bv < 0 or fv < 0 then return end
    local efficiency = ((drone.count / 1000) + math.min(1 / ((1 + hivesAroundHive) * 0.75), 1) + fv + bv) / 4 * 0.5
    for product, rate in pairs(M.productionRates(lineage, drone.parameters.genome, frameBonuses.baseProduction, currentMultiplier())) do
      local progress = (droneProductionProgress[product] or 0) + rate * efficiency
      local count = math.floor(progress)
      droneProductionProgress[product] = progress - count
      if count > 0 then putOutput({name = product, count = count}) end
    end
  end
end
