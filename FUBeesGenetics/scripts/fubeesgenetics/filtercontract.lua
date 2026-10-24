-- Small, engine-independent contract shared by the controller, adapter and pane.
fubeesFilter = {
  traits = {"baseProduction", "droneToughness", "droneBreedRate",
    "queenBreedRate", "queenLifespan", "mutationChance"},
  modeToId = {gte = 0, lte = 1, ignore = 2},
  idToMode = {[0] = "gte", [1] = "lte", [2] = "ignore"},
  processInterval = 1,
  pollInterval = 1
}
fubeesFilter.traitSet = {}
for _, trait in ipairs(fubeesFilter.traits) do fubeesFilter.traitSet[trait] = true end

-- H1/H2 are relative to parental roles. A normalized key also records the
-- actual native subtypes and dominant family, independent of role ordering.
function fubeesFilter.hybridIdentity(lineage, subtype, data)
  if type(lineage) ~= "table" or (subtype ~= 1 and subtype ~= 2)
    or type(lineage.parentSubtypes) ~= "table" then return nil end
  local a, b = lineage.queenFamily, lineage.droneFamily
  if type(a) ~= "string" or type(b) ~= "string" or a == b or a == "hybrid" or b == "hybrid"
    or not a:match("^[a-z]+$") or not b:match("^[a-z]+$") then return nil end
  local dominant = subtype == 1 and a or b
  if a > b then a, b = b, a end
  local sa, sb = lineage.parentSubtypes[a], lineage.parentSubtypes[b]
  local function valid(family, index)
    return type(index) == "number" and index == math.floor(index)
      and data.stats[family] and data.stats[family][index] ~= nil
  end
  local species = "hybrid_" .. a .. "_" .. b
  if lineage.speciesId ~= species or not valid(a, sa) or not valid(b, sb) then return nil end
  return species .. ":" .. sa .. ":" .. sb .. ":" .. dominant
end

function fubeesFilter.sameIdentity(a, b)
  if a.family ~= b.family then return false end
  if a.family == "hybrid" then
    return type(a.lineageKey) == "string" and a.lineageKey == b.lineageKey
  end
  return a.subtype == b.subtype
end
