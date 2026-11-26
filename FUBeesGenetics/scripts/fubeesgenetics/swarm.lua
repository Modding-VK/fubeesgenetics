require "/bees/genomeLibrary.lua"
require "/scripts/fubeesgenetics/itemtags.lua"
require "/scripts/fubeesgenetics/filtercontract.lua"

fubeesSwarm = {type = "fubeesgenetics_swarm", duration = 60}
local M = fubeesSwarm
local beeData
local profiles = {
  aquarum = {"ice", "6fc9ef"}, artisan = {"physical", "d7a576"},
  assassin = {"poison", "823b68"}, bumblebee = {"physical", "ffe05c"},
  carpenter = {"physical", "ac734c"}, crystalwing = {"cosmic", "baacff"},
  cuckoo = {"physical", "ccb47f"}, cybernetic = {"electric", "7affea"},
  devoratrix = {"bioweapon", "b263a3"}, digger = {"physical", "d0a55b"},
  exspiravit = {"shadow", "b4a1e4"}, gelidburrower = {"hoarfrost", "adf5ff"},
  goldensaint = {"physical", "ffcf55"}, harlequin = {"physical", "ef91ba"},
  honey = {"physical", "ffae45"}, inventor = {"electric", "89a8fa"},
  isovapitdae = {"poison", "7bd759"}, leafcutter = {"physical", "97bf66"},
  loamzipper = {"physical", "b49356"}, mason = {"physical", "b9a588"},
  orchid = {"physical", "e381dc"}, oremason = {"physical", "b6c2c7"},
  plasterer = {"physical", "edce9f"}, reaper = {"shadow", "a95bc8"},
  redbanded = {"physical", "ed6c57"}, rimewing = {"ice", "88e5fa"},
  sandprowler = {"physical", "f0c46a"}, scoria = {"fire", "ff7440"},
  shrouded = {"shadow", "7b83d1"}, squash = {"physical", "f69f65"},
  stalwart = {"physical", "a6b4a2"}, stellar = {"cosmic", "9e82f6"},
  sweat = {"physical", "e6cb73"}, tunguskudae = {"radioactive", "cce371"},
  xenodaemonae = {"bioweapon", "db6c92"}
}
local damageNames = {
  physical = "Physical", fire = "Fire", ice = "Ice", hoarfrost = "Hoarfrost",
  electric = "Electric", poison = "Poison", bioweapon = "Bioweapon",
  shadow = "Shadow", cosmic = "Cosmic", radioactive = "Radioactive"
}
local sizes = {"Small", "Medium", "Large"}
local scales = {1, 1.15, 1.30}

local function speciesName(name)
  return (name:gsub("(%l)(%u)", "%1 %2"):gsub("^%l", string.upper))
end

function M.specimen(item, caste)
  if not item then return end
  local _, isBee = fubeesItemTags.has(item.name, "bee")
  local _, isCaste = fubeesItemTags.has(item.name, caste)
  if not isBee or not isCaste then return end
  local family = item.name:match("^bee_([^_]+)_")
  local parameters = item.parameters or {}
  local genome = parameters.genome
  if not family or type(genome) ~= "string" or #genome ~= 18 or genome:find("[^0-9A-Z]") then return end
  beeData = beeData or root.assetJson("/bees/beeData.config")
  local subtype = genelib.statFromGenomeToDecimal(genome, "subtype")
  local definition = beeData.stats[family] and beeData.stats[family][subtype]
  if not definition then return end
  if family == "hybrid" then
    local lineage = parameters.hybridLineage
    local species = fubeesFilter.hybridIdentity(lineage, subtype, beeData)
    if not species then return end
    local dominant = subtype == 1 and lineage.queenFamily or lineage.droneFamily
    local a, b = lineage.queenFamily, lineage.droneFamily
    if a > b then a, b = b, a end
    local first = beeData.stats[a][lineage.parentSubtypes[a]].name
    local second = beeData.stats[b][lineage.parentSubtypes[b]].name
    return {species = species, genome = genome, appearance = dominant,
      name = speciesName(first) .. " × " .. speciesName(second)}
  end
  return {species = family, genome = genome, appearance = family, name = speciesName(definition.name)}
end

function M.preview(queen, tier)
  local genome = queen.genome
  local multiplier = 1 + (tier - 1) / 10
  local profile = profiles[queen.appearance] or {"physical", "ffae45"}
  local function scale(stat, low, high)
    local value = genelib.statFromGenomeToDecimal(genome, stat) / 1295
    return math.floor((low + (high - low) * math.sqrt(value)) * multiplier * 100 + 0.5) / 100
  end
  return {
    tier = tier, scale = scales[tier],
    name = sizes[tier] .. " " .. queen.name .. " Swarm",
    element = profile[1], elementName = damageNames[profile[1]],
    color = profile[2], cybernetic = queen.appearance == "cybernetic",
    damage = scale("baseProduction", 9, 65),
    health = scale("queenLifespan", 45, 190),
    armor = scale("droneToughness", 0, 45),
    speed = scale("mutationChance", 8, 20),
    regen = scale("queenBreedRate", 0, 3)
  }
end

function M.buildPod(result)
  local name = result.name
  local hit = {{0.625, 1}, {1, 0.625}, {1, -0.625}, {0.625, -1},
    {-0.625, -1}, {-1, -0.625}, {-1, 0.625}, {-0.625, 1}}
  for _, vertex in ipairs(hit) do
    vertex[1], vertex[2] = vertex[1] * result.scale, vertex[2] * result.scale
  end
  local parameters = {
    seed = result.tier, aggressive = true, shortdescription = name, scale = result.scale,
    colorSwap = {["7a7a7a"] = result.color},
    movementSettings = {flySpeed = result.speed},
    behaviorConfig = {
      hostileActions = {{name = "action-swoop", cooldown = 1,
        parameters = {skillName = "flyingSwoopApproach", minimumRange = 0, maximumRange = 30,
          onGround = false, windupTime = 0.25, windupState = "charge", windupStopForce = 50,
          swoopState = "charge", swoopVelocity = result.speed * 1.5, gravityMultiplier = -0.3,
          collisionCheck = true, highArc = false, swoopTime = 1.1,
          winddownTime = 0.1, winddownState = "fly", winddownStopForce = 20}}}
    },
    touchDamage = {poly = hit, damage = result.damage, damageSourceKind = result.element, knockback = 20},
    statusSettings = {stats = {
      maxHealth = {baseValue = result.health}, protection = {baseValue = result.armor},
      healthRegen = {baseValue = result.regen}
    }},
    swarmCybernetic = result.cybernetic
  }
  local portrait = root.monsterPortrait(M.type, parameters)
  local description = string.format("%s damage: %g | Health: %g | Armor: %g", result.elementName,
    result.damage, result.health, result.armor)
  return {name = "filledcapturepod", count = 1, parameters = {
    podUuid = sb.makeUuid(), description = description,
    tooltipFields = {subtitle = name, objectImage = portrait},
    pets = {{name = name, description = description, portrait = portrait, collisionPoly = hit,
      config = {type = M.type, parameters = parameters}}}
  }}
end
