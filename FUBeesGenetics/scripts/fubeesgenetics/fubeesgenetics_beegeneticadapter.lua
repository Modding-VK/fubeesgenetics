-- Read-only normalization of FU ItemDescriptors. No inventory or machine state.
require "/bees/genomeLibrary.lua"
require "/scripts/fubeesgenetics/filtercontract.lua"

local genomeLibrary = genelib
-- Engine callbacks (including root) are attached after top-level scripts load.
local beeData
-- OpenStarbound's require loads into the script context and returns no values.
-- Export a namespaced table, following FU's genelib/transferUtil convention.
fubeesgenetics_beegeneticadapter = {}
local adapter = fubeesgenetics_beegeneticadapter
local traits = fubeesFilter.traits

local function failure(reason)
  return {eligible = false, reason = reason}
end

local function finiteNumber(value)
  return type(value) == "number" and value == value
    and value > -math.huge and value < math.huge
end

-- Match FU's first/second underscore convention; caste eligibility uses tags.
local function familyFromName(name)
  local first = name:find("_", 1, true)
  if not first then return nil end
  local second = name:find("_", first + 1, true)
  if not second or second == first + 1 then return nil end
  return name:sub(first + 1, second - 1)
end

function adapter.normalize(item)
  if type(item) == "string" then item = {name = item} end
  if type(item) == "table" and item.name == nil and type(item[1]) == "string" then
    item = {name = item[1], count = item[2], parameters = item[3]}
  end
  if type(item) ~= "table" or type(item.name) ~= "string" or item.name == ""
    or (item.count ~= nil and (not finiteNumber(item.count)
      or item.count < 1 or item.count ~= math.floor(item.count)))
    or (item.parameters ~= nil and type(item.parameters) ~= "table") then
    return nil
  end
  return {name = item.name, count = item.count or 1, parameters = item.parameters or {}}
end

-- Bounded per-script cache: item tags are immutable during an asset load.
-- Errors are not cached, and no specimen/genome data is retained here.
local tagCache, tagNames, nextTag = {}, {}, 1
local function hasTag(name, tag)
  local entry = tagCache[name]
  if entry and entry[tag] ~= nil then return true, entry[tag] end
  local ok, value = pcall(root.itemHasTag, name, tag)
  if not ok then return false, nil end
  if not entry then
    if tagNames[nextTag] then tagCache[tagNames[nextTag]] = nil end
    tagNames[nextTag], entry = name, {}
    tagCache[name] = entry
    nextTag = nextTag % 128 + 1
  end
  entry[tag] = not not value
  return true, entry[tag]
end

function adapter.read(item)
  item = adapter.normalize(item)
  if not item then return failure("INVALID_DESCRIPTOR") end

  -- Unknown item names can raise through engine bindings; never crash the caller.
  local ok, isBee = hasTag(item.name, "bee")
  if not ok or not isBee then return failure("NOT_BEE") end
  local queenOk, isQueen = hasTag(item.name, "queen")
  local youngOk, isYoungQueen = hasTag(item.name, "youngQueen")
  if not queenOk or not youngOk or not (isQueen or isYoungQueen) then
    return failure("NOT_QUEEN")
  end

  local parameters = item.parameters or {}
  if not parameters.genomeInspected then return failure("NOT_INSPECTED") end

  local genome = parameters.genome
  -- Validate before any FU decoder: statToDecimal assumes valid characters.
  if type(genome) ~= "string" or #genome ~= 18 or genome:find("[^0-9A-Z]") then
    return failure("INVALID_GENOME")
  end

  beeData = beeData or root.assetJson("/bees/beeData.config")
  local family = familyFromName(item.name)
  local subtypes = family and beeData.stats[family]
  if type(subtypes) ~= "table" then return failure("UNKNOWN_FAMILY") end

  local subtype = genomeLibrary.statFromGenomeToDecimal(genome, "subtype")
  if not finiteNumber(subtype) or subtype ~= math.floor(subtype)
    or subtype < 1 or subtype > #subtypes then
    return failure("INVALID_SUBTYPE")
  end
  local subspecies = subtypes[subtype]
  if type(subspecies) ~= "table" or type(subspecies.name) ~= "string" or subspecies.name == "" then
    return failure("INVALID_GENOME")
  end

  local lineageKey
  if family == "hybrid" then
    lineageKey = fubeesFilter.hybridIdentity(parameters.hybridLineage, subtype, beeData)
    if not lineageKey then return failure("INVALID_LINEAGE") end
  end

  local genetics = {}
  for _, trait in ipairs(traits) do
    local raw = genomeLibrary.statFromGenomeToDecimal(genome, trait)
    local display = genomeLibrary.statToValue(genomeLibrary.numberToStat(raw), trait)
    if not finiteNumber(raw) or raw < 0 or raw > 1295
      or raw ~= math.floor(raw) or not finiteNumber(display) then
      return failure("INVALID_GENOME")
    end
    genetics[trait] = {raw = raw, display = display}
  end

  return {
    eligible = true,
    identity = {family = family, subtype = subtype, subspeciesName = subspecies.name, lineageKey = lineageKey},
    genetics = genetics
  }
end
