-- Pinned, real FU genome library/data; only root engine bindings are mocked.
local function equal(actual, expected, label)
  assert(actual == expected, (label or "value") .. ": expected " .. tostring(expected)
    .. ", got " .. tostring(actual))
end

local function copy(value)
  if type(value) ~= "table" then return value end
  local result = {}
  for key, child in pairs(value) do result[key] = copy(child) end
  return result
end

local function same(left, right)
  if type(left) ~= type(right) then return false end
  if type(left) ~= "table" then return left == right end
  for key, value in pairs(left) do if not same(value, right[key]) then return false end end
  for key in pairs(right) do if left[key] == nil then return false end end
  return true
end

root = {
  assetJson = function(path)
    equal(path, "/bees/beeData.config", "asset path")
    return fixture.beeData
  end,
  itemHasTag = function(name, tag)
    if name == "unregistered" then error("unknown engine item") end
    return fixture.tags[name] and fixture.tags[name][tag] == true or false
  end
}

local engineRoot = root
root = nil
local originalRequire = require
require = function(path)
  if path == "/bees/genomeLibrary.lua" then
    if not genelib then dofile(fixture.fuRoot .. path) end
    return
  elseif path == "/scripts/fubeesgenetics/filtercontract.lua" or path == "/scripts/fubeesgenetics/fubeesgenetics_beegeneticadapter.lua" then
    dofile(fixture.repoRoot .. "/FUBeesGenetics" .. path)
    return
  end
  return originalRequire(path)
end
equal(require("/scripts/fubeesgenetics/fubeesgenetics_beegeneticadapter.lua"), nil,
  "engine require returns no values")
root = engineRoot
local adapter = fubeesgenetics_beegeneticadapter
assert(type(adapter) == "table" and type(adapter.read) == "function", "namespaced export")

equal(genelib.stringLibrary, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", "genetic alphabet")
equal(table.concat(genelib.statOrder, ","),
  "subtype,baseProduction,droneToughness,droneBreedRate,queenBreedRate,queenLifespan,mutationChance,miteResistance,workTime",
  "gene order")
equal(fixture.beeData.beeUpdateInterval, 1, "FU tick")

-- Any accidental call to a mutation/generation API makes the tests fail.
for _, name in ipairs({"generateDefaultGenome", "modifyGenomeStat", "evolveGenome",
  "getAvarageGenome", "modifyStatString"}) do
  genelib[name] = function() error("Adapter must not mutate/generate genome: " .. name) end
end

local genome = "010001ZZ0A0BHZE000"
equal(#genome, 18)
local queen = {name = "bee_honey_queen", count = 1,
  parameters = {genome = genome, genomeInspected = true, wild = false, lifespan = 1}}
local count = 0
local function test(label, callback)
  callback()
  count = count + 1
  print("PASS " .. label)
end

local function read(item)
  local before = copy(item)
  local beforeData = copy(fixture.beeData)
  local result = adapter.read(item)
  assert(same(item, before), "descriptor mutated")
  assert(same(fixture.beeData, beforeData), "bee data mutated")
  return result
end

local function changed(name, values)
  local item = copy(queen)
  if name then item.name = name end
  for key, value in pairs(values or {}) do item.parameters[key] = value end
  return item
end

local function reject(item, reason)
  local result = read(item)
  equal(result.eligible, false)
  equal(result.reason, reason)
  equal(result.genetics, nil)
  equal(result.identity, nil)
end

local expected = {
  baseProduction = 0, droneToughness = 1, droneBreedRate = 1295,
  queenBreedRate = 10, queenLifespan = 11, mutationChance = 647
}
local function validate(item)
  local result = read(item)
  equal(result.eligible, true)
  equal(result.identity.family, "honey")
  equal(result.identity.subtype, 1)
  equal(result.identity.subspeciesName, fixture.beeData.stats.honey[1].name)
  local traitCount = 0
  for trait, value in pairs(result.genetics) do
    traitCount = traitCount + 1
    equal(value.raw, expected[trait], trait .. " raw")
    equal(value.display, genelib.statFromGenomeToValue(genome, trait), trait .. " display")
  end
  equal(traitCount, 6)
  equal(result.genetics.workTime, nil)
  equal(result.genetics.miteResistance, nil)
  equal(result.genetics.queenLifespan.raw, 11, "ignore remaining lifespan")
  equal(result.genetics.mutationChance.display, 49.92, "FU mutation conversion")
  equal(result.genome, nil)
end

test("A1 inspected Queen, six raw/display traits", function() validate(queen) end)
test("A2 inspected Young Queen", function() validate(changed("bee_honey_youngQueen")) end)
test("A3 Drone rejected", function() reject(changed("bee_honey_drone"), "NOT_QUEEN") end)
test("A4 non-bee rejected", function() reject(changed("stone"), "NOT_BEE") end)
test("A5 not inspected", function() reject(changed(nil, {genomeInspected = false}), "NOT_INSPECTED") end)
test("A6 wild and inspected eligible", function() validate(changed(nil, {wild = true})) end)
test("A7 non-wild and missing inspection rejected", function()
  local item = copy(queen); item.parameters.genomeInspected = nil
  reject(item, "NOT_INSPECTED")
end)
test("A8 missing genome without generation", function()
  local item = copy(queen); item.parameters.genome = nil
  reject(item, "INVALID_GENOME")
end)
test("A9 genome size and type", function()
  for _, value in ipairs({"", genome:sub(1, 17), genome .. "0", 123, false, {}}) do
    reject(changed(nil, {genome = value}), "INVALID_GENOME")
  end
end)
test("A10 invalid alphabet never reaches decoder", function()
  local decimal, display = genelib.statFromGenomeToDecimal, genelib.statFromGenomeToValue
  genelib.statFromGenomeToDecimal = function() error("decoder called for invalid input") end
  genelib.statFromGenomeToValue = genelib.statFromGenomeToDecimal
  for _, char in ipairs({"a", "!", " ", "\0"}) do
    reject(changed(nil, {genome = char .. genome:sub(2)}), "INVALID_GENOME")
  end
  genelib.statFromGenomeToDecimal, genelib.statFromGenomeToValue = decimal, display
end)
test("A11 subtype zero", function()
  reject(changed(nil, {genome = "00" .. genome:sub(3)}), "INVALID_SUBTYPE")
end)
test("A12 subtype out of family range", function()
  reject(changed(nil, {genome = "ZZ" .. genome:sub(3)}), "INVALID_SUBTYPE")
end)
test("unknown and malformed family", function()
  reject(changed("bee_unknown_queen"), "UNKNOWN_FAMILY")
  reject(changed("brokenname"), "UNKNOWN_FAMILY")
end)
test("tags determine caste, not name", function()
  validate(changed("bee_honey_unusual"))
  reject(changed("bee_honey_fakequeen"), "NOT_QUEEN")
end)
test("invalid descriptors and engine lookup failure", function()
  for _, item in ipairs({false, {}, {name = 42}, {name = ""},
    {name = queen.name, count = 0}, {name = queen.name, count = -1},
    {name = queen.name, count = 1.5}, {name = queen.name, count = math.huge},
    {name = queen.name, parameters = "bad"}}) do
    reject(item, "INVALID_DESCRIPTOR")
  end
  reject(nil, "INVALID_DESCRIPTOR")
  local item = copy(queen); item.count = 0/0
  -- NaN is unequal to itself, so inspect input fields separately from deep equality.
  equal(adapter.read(item).reason, "INVALID_DESCRIPTOR")
  equal(item.name, queen.name); assert(item.count ~= item.count)
  reject(changed("unregistered"), "NOT_BEE")
end)
test("absent parameters and non-boolean inspection", function()
  local item = copy(queen); item.parameters = nil
  reject(item, "NOT_INSPECTED")
  for _,flag in ipairs({"true",0,""}) do validate(changed(nil, {genomeInspected = flag})) end
end)
test("stack count does not affect genetics", function()
  local item = changed("bee_honey_youngQueen"); item.count = 1000
  validate(item)
  item.count = nil; validate(item)
end)
test("all configured FU family/subtype identities", function()
  for family, subtypes in pairs(fixture.beeData.stats) do
    local name = "bee_" .. family .. "_queen"
    -- Synthetic tags cover all configured identities; real honey tags tested above.
    fixture.tags[name] = {bee = true, queen = true}
    for subtype, data in ipairs(subtypes) do
      local item = changed(name, {genome = genelib.numberToStat(subtype) .. genome:sub(3)})
      local result = read(item)
      equal(result.eligible, true, family .. " subtype " .. subtype)
      equal(result.identity.family, family)
      equal(result.identity.subtype, subtype)
      equal(result.identity.subspeciesName, data.name)
    end
  end
end)
test("results never alias input or previous results", function()
  local first = read(queen)
  first.genetics.baseProduction.raw = 100
  first.identity.family = "changed"
  validate(queen)
end)
test("A13 excluded gene characters still validate", function()
  for i=15,18 do reject(changed(nil,{genome=genome:sub(1,i-1).."!"..genome:sub(i+1)}),"INVALID_GENOME") end
end)
test("A14-A18 defaults, shorthand and structural precedence", function()
  reject("bee_honey_queen","NOT_INSPECTED")
  validate({queen.name,1,copy(queen.parameters)})
  reject({name="notbee",parameters=42},"INVALID_DESCRIPTOR")
  reject({name="notbee",count=0},"INVALID_DESCRIPTOR")
  reject({name="notbee",count="1"},"INVALID_DESCRIPTOR")
  local q=copy(queen);q.count=nil;validate(q)
end)
test("unusable subtype name is INVALID_GENOME", function()
  local entry=fixture.beeData.stats.honey[1];local name=entry.name
  entry.name="";reject(queen,"INVALID_GENOME");entry.name=nil;reject(queen,"INVALID_GENOME");entry.name=name
end)

test("A23 hybrid pairs, native subtypes and dominance have distinct identities", function()
  fixture.beeData.stats.hybrid = {{name="hybridA"}, {name="hybridB"}}
  fixture.tags.bee_hybrid_queen = {bee=true,queen=true}
  local function hybrid(a,b,subtype,as,bs)
    local item=changed("bee_hybrid_queen", {genome=genelib.numberToStat(subtype)..genome:sub(3)})
    local x,y=a,b;if x>y then x,y=y,x end
    item.parameters.hybridLineage={speciesId="hybrid_"..x.."_"..y,queenFamily=a,droneFamily=b,
      parentSubtypes={[a]=as or 1,[b]=bs or 1}}
    return item
  end
  local a=read(hybrid('honey','carpenter',1));assert(a.eligible)
  local samePair=read(hybrid('carpenter','honey',2));assert(samePair.eligible)
  assert(fubeesFilter.sameIdentity(a.identity,samePair.identity))
  for _,q in ipairs({hybrid('honey','mason',1),hybrid('honey','carpenter',2),hybrid('honey','carpenter',1,2,1)}) do
    local b=read(q);assert(b.eligible and not fubeesFilter.sameIdentity(a.identity,b.identity))
  end
  local malformed=hybrid('honey','carpenter',1);malformed.parameters.hybridLineage.speciesId='wrong'
  reject(malformed,'INVALID_LINEAGE')
  malformed.parameters.hybridLineage=nil;reject(malformed,'INVALID_LINEAGE')
  malformed=hybrid('honey','carpenter',1);malformed.parameters.hybridLineage.parentSubtypes.honey='bad'
  reject(malformed,'INVALID_LINEAGE')
  fixture.beeData.stats.hybrid=nil
end)
test("A24 tag cache is bounded and never caches specimen inspection", function()
  local old=root.itemHasTag;local calls=0
  root.itemHasTag=function(...) calls=calls+1;return old(...) end
  for i=1,140 do
    local name='cache_probe_'..i
    reject(changed(name),'NOT_BEE')
  end
  local before=calls;validate(queen);local first=calls-before
  assert(first==3,'Evicted tags must be reloaded')
  for i=1,10 do validate(queen) end
  assert(calls==before+3,'Repeated names must reuse cached tags')
  reject(changed(nil,{genomeInspected=false}),'NOT_INSPECTED')
  root.itemHasTag=old
end)
print("Adapter: " .. count .. " test groups passed; engine smoke test still required.")
