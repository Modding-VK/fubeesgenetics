-- Real mod code, pinned FU genome/builder/apiary, and mocked engine bindings.
local function copy(v)
  if type(v) ~= "table" then return v end
  local r = {}; for k, x in pairs(v) do r[k] = copy(x) end; return r
end
local function same(a, b)
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return a == b end
  for k, v in pairs(a) do if not same(v, b[k]) then return false end end
  for k in pairs(b) do if a[k] == nil then return false end end
  return true
end
local function equal(a, b, label)
  assert(a == b, (label or "value") .. ": expected " .. tostring(b) .. ", got " .. tostring(a))
end
local function finite(x) return type(x) == "number" and x == x and x < math.huge and x > -math.huge end
local function setup(bootstrap, skipHybridBuilder)
  local e = setmetatable({}, {__index = _G}); e._G = e; e.self = {}; e.copy = copy; e.compare = same
  e.math = copy(math); e.roll = .05; e.subtype = 1
  e.math.random = function(a, b)
    if a == 1 and b == 2 then return e.subtype end
    if b then return math.floor((a + b) / 2) end
    if a then return a end
    return e.roll
  end
  e.storage = {}; e.inventory = {}; e.spawned = {}; e.monsters = {}; e.consumed = 0
  e.supply = 1e9; e.settings = copy(fixture.hybridizerConfig); e.data = copy(fixture.hybridBeeData)
  e.frameStats = {}; e.flowers = {}; e.labels = {}; e.messages = {}; e.now = 1000; e.assetLoads = {}
  for i = 1, 5 do e.flowers[i] = {name = "beeflower", stage = 2, stages = {{}, {}, {}}} end
  local loaded = {}
  e.loadedScripts = loaded
  local engineRoot, engineWorld
  e.require = function(path)
    if loaded[path] then return end; loaded[path] = true
    if path == "/scripts/fupower.lua" then
      e.power = {init = function() end, update = function() end, getTotalEnergy = function() return e.supply end,
        consume = function(n) assert(finite(n) and n >= 0); if n > e.supply then return false end; e.consumed = e.consumed + n; return true end}
      return
    end
    if path == "/scripts/util.lua" or path == "/zb/zb_util.lua" then return end
    if path == "/scripts/kheAA/transferUtil.lua" then e.transferUtil = {loadSelfContainer = function() end}; return end
    local prefix = path:find("fubeesgenetics", 1, true) and fixture.repoRoot .. "/FUBeesGenetics" or fixture.fuRoot
    assert(loadfile(prefix .. path, "t", e))()
  end
  -- No root/world/config callbacks during bootstrap, matching the engine.
  e.require("/bees/genomeLibrary.lua")
  e.require("/bees/beeBuilder.lua"); e.nativeBuild = e.build
  if not skipHybridBuilder then
    e.require("/scripts/fubeesgenetics/hybridbeebuilder.lua")
    e.require("/scripts/fubeesgenetics/hybridbees.lua")
  end
  if bootstrap then e.require(bootstrap) end
  e.entity = {id = function() return 42 end, position = function() return {0, 0} end}
  e.config = {getParameter = function(k, d) if e.settings[k] == nil then return d end return e.settings[k] end}
  e.message = {setHandler = function(k, callback) e.messages[k] = callback end}
  e.sb = {logWarn = function() end}; e.script = {setUpdateDelta = function() end}
  e.animator = {setAnimationState = function() end, setGlobalTag = function(k, v) e.labels[k] = v end}
  e.object = {setInteractive = function(v) e.interactive = v end, name = function() return e.settings.objectName end,
    toAbsolutePosition = function(p) return p end}
  e.root = {assetJson = function(path)
    e.assetLoads[path] = (e.assetLoads[path] or 0) + 1
    if path == "/bees/beeData.config" then return copy(e.data) end
    if path == "/bees/hybridPlants.config" then return copy(fixture.hybridPlants) end
    if path == "/items/defaultParameters.config" then return {defaultMaxStack = 1000} end
    error("Unmocked asset " .. path)
  end, itemHasTag = function(name, tag)
    if name == "basicframe" then return tag == "apiaryFrame" end
    local tags = fixture.tags[name]
    if tags then return tags[tag] or false end
    local config = fixture.hybridItems[name]
    if config then for _, t in ipairs(config.itemTags) do if t == tag then return true end end; return false end
    if tag == "drone" and name:match("^bee_[^_]+_drone$") then return true end
    return tag == "bee" and name:match("^bee_") ~= nil
  end, itemConfig = function(item)
    local name = type(item) == "string" and item or item.name
    return {config = name == "basicframe" and copy(e.frameStats) or copy(fixture.hybridItems[name] or {maxStack = 1000})}
  end}
  e.root.createItem = function(descriptor)
    local item = type(descriptor) == "string" and {name = descriptor, count = 1} or copy(descriptor)
    item.count = item.count or 1; item.parameters = item.parameters or {}
    if item.name:match("^bee_") then
      local cfg = copy(fixture.hybridItems[item.name] or {itemName = item.name, inventoryIcon = "/bees/bees/honey.png:queen"})
      local builder = fixture.hybridItems[item.name] and e.build or e.nativeBuild
      local _, params = builder("/bees/bees/", cfg, copy(item.parameters), 1, 1)
      item.parameters = params
    end
    return item
  end
  e.world = {
    containerItemAt = function(_, i) return copy(e.inventory[i]) end,
    containerItems = function() local items = {}; for i, v in pairs(e.inventory) do items[i + 1] = copy(v) end; return items end,
    containerSize = function() return e.settings.slotCount end,
    containerPutItemsAt = function(_, item, slot)
      assert(finite(item.count) and item.count >= 1 and math.floor(item.count) == item.count, "Invalid item count")
      if e.blockInsert == slot then return copy(item) end
      local built = e.root.createItem(item); local before = e.inventory[slot]
      if before and (before.name ~= built.name or not same(before.parameters, built.parameters)) then return copy(item) end
      local limit = e.root.itemHasTag(item.name, "queen") and 1 or 1000
      local delta = math.min(built.count, limit - (before and before.count or 0))
      if delta > 0 then local stored = copy(built); stored.count = (before and before.count or 0) + delta; e.inventory[slot] = stored end
      if e.reportFull then return copy(item) end
      if delta == built.count then return nil end
      built.count = built.count - delta; return built
    end,
    containerTakeNumItemsAt = function(_, slot, n)
      if e.failTake == slot then return nil end
      local item = e.inventory[slot]; if not item then return nil end
      local taken = copy(item); taken.count = math.min(n, item.count)
      item.count = item.count - taken.count; if item.count == 0 then e.inventory[slot] = nil end
      return taken
    end,
    containerTakeAt = function(_, slot) local item = e.inventory[slot]; e.inventory[slot] = nil; return copy(item) end,
    spawnItem = function(item, _, n)
      local built = e.root.createItem(type(item) == "string" and {name = item, count = n or 1} or item)
      assert(finite(built.count) and built.count >= 1); table.insert(e.spawned, built); return 99
    end,
    spawnMonster = function(name, pos, params) table.insert(e.monsters, {name = name, parameters = copy(params)}); return 100 end,
    objectQuery = function(_, _, options)
      if options and options.callScript then return {} end
      local ids = {}; for i in ipairs(e.flowers) do ids[#ids + 1] = i end; return ids
    end,
    farmableStage = function(id) return e.flowers[id].stage end,
    getObjectParameter = function(id, key, default) return copy(e.flowers[id][key] or default) end,
    entityName = function(id) return e.flowers[id].name end,
    type = function() return "forest" end, time = function() return e.now end, timeOfDay = function() return .25 end,
    entityExists = function() return true end, monsterQuery = function() return {} end, entityQuery = function() return {} end}
  e.world.containerAddItems = function(_, item)
    for i = e.settings.firstInventorySlot - 1, e.settings.slotCount - 1 do
      item = e.world.containerPutItemsAt(42, item, i); if not item then return nil end
    end
    return item
  end
  e.world.containerStackItems = e.world.containerAddItems
  e.parent = function(family, caste) return e.root.createItem("bee_" .. family .. "_" .. caste) end
  e.hybrid = function(a, b)
    local q, d = e.parent(a, "queen"), e.parent(b, "drone")
    local genome, exceptions = e.hybridbees.makeGenome(q, d)
    local lineage, err = e.hybridbees.makeLineage(q, d, genome)
    assert(lineage, tostring(a) .. '/' .. tostring(b) .. ': ' .. tostring(err) .. ' ' .. q.parameters.genome .. ' ' .. d.parameters.genome .. ' -> ' .. genome)
    lineage.genomeExceptions = exceptions
    return e.root.createItem({name = "bee_hybrid_queen", count = 1, parameters = {genome = genome, hybridLineage = lineage}})
  end
  e.startMachine = function(a, b)
    e.inventory[0] = e.parent(a or "honey", "queen"); e.inventory[1] = e.parent(b or "carpenter", "drone")
    e.require("/objects/bees/fubeesgenetics/hybridizer/hybridizer.lua"); e.init()
  end
  e.startApiary = function()
    e.settings = copy(fixture.overloadConfig)
    e.require("/objects/bees/fubeesgenetics/overloadapiary/overloadapiary.lua"); e.init()
    e.inventory[2] = {name = "basicframe", count = 1, parameters = {}}
  end
  e.startNativeApiary = function(large)
    e.settings = {objectName = large and "normalalveary" or "normalapiary",
      slotCount = large and 20 or 12, queenSlot = 1,
      droneSlots = large and {2, 3} or {2}, frameSlots = large and {4, 5} or {3},
      firstInventorySlot = large and 6 or 4, scriptDelta = 5}
    e.require("/scripts/fubeesgenetics/nativeapiary.lua"); e.init()
  end
  e.finish = function() for _ = 1, 417 do e.update(1) end end
  return e
end

local passed = 0
local function test(label, callback) callback(); passed = passed + 1; print("PASS H" .. passed .. " " .. label) end
local function activateHybrid(e, queen)
  e.inventory[0] = queen
  e.beeTick(1)
  e.queen = queen
  e.contents = e.world.containerItems(42)
end

test("Machine and apiary bootstrap before engine callbacks", function()
  setup("/objects/bees/fubeesgenetics/hybridizer/hybridizer.lua")
  setup("/objects/bees/fubeesgenetics/overloadapiary/overloadapiary.lua")
end)
test("No power preserves parents and charge", function()
  local e = setup(); e.startMachine(); e.supply = 0; e.update(1)
  equal(e.storage.hybridCharge, 0); equal(e.inventory[0].count, 1); equal(e.inventory[1].count, 1)
end)
test("Occupied output delays crossing but permits charging", function()
  local e = setup(); e.startMachine(); e.inventory[2] = {name = "dirtmaterial", count = 1, parameters = {}}; e.update(1)
  equal(e.consumed, 24); equal(e.storage.hybridizerStatus, "CHARGING")
end)
test("Slow supply charges gradually and survives init", function()
  local e = setup(); e.startMachine(); e.supply = 2; for _ = 1, 10 do e.update(1) end
  equal(e.storage.hybridCharge, 20); equal(e.consumed, 20); e.init(); equal(e.storage.hybridCharge, 20)
end)
test("Failure consumes exactly 10000 energy and both specimens", function()
  local e = setup(); e.startMachine(); e.roll = .99; e.finish()
  equal(e.consumed, 10000); equal(e.inventory[0], nil); equal(e.inventory[1], nil)
  equal(e.inventory[2], nil); equal(#e.spawned, 0); equal(e.storage.hybridizationAttempts, 1)
end)
for subtype = 1, 2 do
  test("Single larva, native promotion, genome and lineage for subtype " .. subtype, function()
    local e = setup(); e.startMachine(); e.subtype = subtype; e.finish()
    local larva = e.inventory[2]; equal(larva.name, "bee_hybrid_youngQueen"); equal(larva.count, 1)
    equal(larva.parameters.lifespan, nil); equal(#e.spawned, 0); equal(e.consumed, 10000)
    equal(larva.parameters.hybridLineage.subspecies, subtype)
    e.require("/bees/apiary.lua"); local adult = e.youngQueenToQueen(larva)
    equal(adult.name, "bee_hybrid_queen"); assert(same(adult.parameters, larva.parameters))
    local built = e.root.createItem(adult)
    equal(built.parameters.genome, larva.parameters.genome); assert(same(built.parameters.hybridLineage, larva.parameters.hybridLineage))
    assert(built.parameters.lifespan > 0)
  end)
end
test("Old engine insertion return cannot duplicate a larva", function()
  local e = setup(); e.startMachine(); e.reportFull = true; e.finish()
  equal(e.inventory[2].count, 1); equal(#e.spawned, 0); equal(e.storage.hybridPending, nil)
end)
test("Rejected output is persisted and delivered once after reload", function()
  local e = setup(); e.startMachine(); e.blockInsert = 2; e.finish()
  assert(e.storage.hybridPending); equal(e.inventory[2], nil); equal(#e.spawned, 0)
  e.init(); e.blockInsert = nil; e.update(1)
  equal(e.inventory[2].count, 1); equal(e.storage.hybridPending, nil); equal(e.storage.hybridizationAttempts, 1)
end)
test("Partial parent removal refunds and does not spend a second attempt", function()
  local e = setup(); e.startMachine(); local q = copy(e.inventory[0]); e.failTake = 1; e.finish()
  assert(same(e.inventory[0], q)); equal(e.inventory[1].count, 1); equal(e.storage.hybridizationAttempts, 0)
  equal(e.storage.hybridCharge, 10000); equal(#e.spawned, 0)
end)
test("Invalid names, genomes and same-family crosses are rejected", function()
  local e = setup(); e.startMachine("honey", "honey"); e.update(1); equal(e.consumed, 24)
  e.inventory[0] = {name = "brokenname", count = 1, parameters = {}}; e.update(1); equal(e.consumed, 48)
  e.inventory[0] = e.parent("carpenter", "queen"); e.inventory[0].parameters.genome = "bad"; e.update(1); equal(e.consumed, 72)
  equal(e.storage.hybridizationAttempts, 0)
  equal(e.hybridbees.speciesForParents(nil, "honey"), nil)
end)
test("All 595 pairs have valid rivals and symmetric native chances", function()
  local e = setup(); local rivals = fixture.beeData.rivals
  local function has(list, value)
    if type(list) == "string" then return list == value end
    for _, v in ipairs(list or {}) do if v == value then return true end end; return false
  end
  for _, species in ipairs(fixture.hybridCatalog.hybrids) do
    local a, b = table.unpack(species.parentFamilies)
    for _, rival in ipairs(species.rivalNativeFamilies) do assert(fixture.beeData.stats[rival], rival) end
    local expected = (has(rivals[a], b) or has(rivals[b], a)) and .1 or .3
    local computed = e.hybridbees.speciesForParents(a, b)
    equal(computed.id, species.id)
    assert(same(computed.parentFamilies, species.parentFamilies))
    assert(same(computed.rivalNativeFamilies, species.rivalNativeFamilies))
    for index, plant in ipairs(computed.preferredPlants) do
      equal(plant.parent, species.preferredPlants[index].parent)
      equal(plant.id, species.preferredPlants[index].id)
      equal(plant.likeness, species.preferredPlants[index].likeness)
    end
    equal(e.hybridbees.successChance(computed), expected)
    equal(e.hybridbees.successChance(e.hybridbees.speciesForParents(b, a)), expected)
  end
  equal(e.assetLoads["/bees/hybridPlants.config"], 1)
  equal(e.assetLoads["/bees/hybridSpecies.config"], nil)
end)
test("Ordinary FU apiaries do not load hybrid plant data", function()
  local e = setup(nil, true); e.startNativeApiary(false)
  e.inventory[0] = e.parent("honey", "queen")
  e.inventory[1] = e.parent("honey", "drone")
  e.inventory[2] = {name = "basicframe", count = 1, parameters = {}}
  for _ = 1, 30 do e.beeTick(1) end
  equal(e.assetLoads["/bees/hybridPlants.config"], nil)
  assert(not e.loadedScripts["/scripts/fubeesgenetics/hybridbees.lua"])
  assert(not e.loadedScripts["/scripts/fubeesgenetics/containerutil.lua"])
end)
test("Ordinary Overload Apiaries do not load hybrid code", function()
  local e = setup(nil, true); e.startApiary()
  e.inventory[0] = e.parent("honey", "queen")
  e.inventory[1] = e.parent("honey", "drone")
  for _ = 1, 30 do e.beeTick(1) end
  equal(e.assetLoads["/bees/hybridPlants.config"], nil)
  assert(not e.loadedScripts["/scripts/fubeesgenetics/hybridbees.lua"])
end)
test("Hybrid item builder uses the sprite without loading hybrid production code", function()
  local source = setup(); local specimen = source.hybrid("honey", "carpenter")
  local e = setup(nil, true)
  e.require("/scripts/fubeesgenetics/hybridbeebuilder.lua")
  local built = e.build("/bees/bees/", copy(fixture.hybridItems[specimen.name]), copy(specimen.parameters), 1, 1)
  equal(built.inventoryIcon[1].image, "/bees/bees/hybrid_carpenter_honey.png:queen")
  assert(not e.loadedScripts["/scripts/fubeesgenetics/hybridbees.lua"])
  equal(e.assetLoads["/bees/hybridPlants.config"], nil)
end)
test("Hybrid rivals include native rivals, their hybrids and rival parents", function()
  local e = setup(); local h = e.hybrid("carpenter", "mason")
  assert(e.hybridbees.areRivals(h, e.parent("carpenter", "drone")))
  assert(e.hybridbees.areRivals(e.parent("mason", "drone"), h))
  local other = e.hybrid("artisan", "honey")
  assert(e.hybridbees.areRivals(h, other)); assert(e.hybridbees.areRivals(other, h))
  assert(not e.hybridbees.areRivals(h, copy(h)))
end)
test("Unshared intolerances, explicit conflicts and two preferred biomes", function()
  local e = setup(); local inherit = e.hybridbees.inheritBiomes
  equal(inherit({desert = 0}, {}).desert, 0)
  local v = inherit({a = 3, b = 3, c = 0}, {a = 0, b = 1, c = 2})
  equal(v.a, 2); equal(v.b, 2); equal(v.c, 1)
  v = inherit({a = 3, b = 3, x = 0}, {c = 3, d = 3, y = 1})
  equal(v.a, 3); equal(v.b, 2); equal(v.c, 3); equal(v.d, 2); equal(v.x, 0); equal(v.y, 1)
end)
test("Legacy lineages migrate environmental data and preserve genes", function()
  local e = setup(); local h = e.hybrid("honey", "mason"); local genome = h.parameters.genome
  h.parameters.hybridLineage.version = nil; h.parameters.hybridLineage.biomeLikeness.desert = 1
  local lineage = e.hybridbees.lineage(h); equal(lineage.version, 2); equal(lineage.biomeLikeness.desert, 0)
  equal(h.parameters.genome, genome)
end)
test("Only one chosen plant per parent receives preferred affinity", function()
  local e = setup(); local h = e.hybrid("honey", "carpenter"); local l = h.parameters.hybridLineage
  for _, plant in ipairs(e.flowers) do plant.name = "beeflower" end
  equal(e.hybridbees.flowerFavor(l), 5)
  for _, plant in ipairs(e.flowers) do plant.name = "algaeseed" end
  equal(e.hybridbees.flowerFavor(l), 5)
  for _, plant in ipairs(e.flowers) do plant.name = "unselectedseed"; plant.beeLikeness = {honey = 99, carpenter = 99} end
  assert(e.hybridbees.flowerFavor(l) < 1)
  e.flowers = {}; equal(e.hybridbees.flowerFavor(l), -1)
end)
test("All pair/subtype outputs are finite, positive and use the union of resources", function()
  local e = setup()
  for _, species in ipairs(fixture.hybridCatalog.hybrids) do
    for subtype = 1, 2 do
      e.subtype = subtype
      local h = e.hybrid(table.unpack(species.parentFamilies)); local l = h.parameters.hybridLineage
      local rates = e.hybridbees.productionRates(l, h.parameters.genome, 0, 1)
      local expected = {}
      for _, family in ipairs(l.parentFamilies) do
        for resource in pairs(e.data.stats[family][l.parentSubtypes[family]].production) do expected[resource] = true end
      end
      for resource in pairs(expected) do assert(finite(rates[resource]) and rates[resource] > 0, species.id .. ':' .. resource) end
      for resource in pairs(rates) do assert(expected[resource]) end
    end
  end
end)
test("Genetic production changes rates instead of cancelling out", function()
  local e = setup(); local h = e.hybrid("aquarum", "honey"); local l = h.parameters.hybridLineage
  equal(e.genelib.statFromGenomeToValue(h.parameters.genome, "baseProduction"), 0)
  local rates = e.hybridbees.productionRates(l, h.parameters.genome, 0, 1)
  local improved = e.hybridbees.productionRates(l, e.genelib.modifyGenomeStat(h.parameters.genome, "baseProduction", 1), 0, 1)
  for resource, rate in pairs(rates) do equal(improved[resource], 2 * rate) end
end)
test("Native overload multipliers and aging remain 1.2 / 1.2 / 0.7", function()
  local e = setup(); e.startApiary(); e.queen = e.parent("honey", "queen")
  e.queen.parameters.wild = nil; e.inventory[0] = copy(e.queen); e.hasFrame = true
  local before = e.queen.parameters.lifespan; e.ageQueen(); equal(e.queen.parameters.lifespan, before - 1 / .7)
  e.frameBonuses.baseProduction = 3; e.frameBonuses.droneBreedRate = 0
  e.droneProgress, e.youngQueenProgress = 0, 0
  local breed = e.genelib.statFromGenomeToValue(e.queen.parameters.genome, "droneBreedRate")
  e.queenProduction(); equal(e.droneProgress, breed * 1.2 * .25)
  local d = e.parent("honey", "drone"); d.count = 1
  local base = e.genelib.statFromGenomeToValue(d.parameters.genome, "baseProduction")
  local bv, fv = e.getBiomeFavor(d.name), e.getFlowerLikeness("honey")
  e.droneProduction(d)
  local expected = (base * 1.2 + 3) * ((.001 + 1 + bv + fv) / 4) * .5
  for _, value in pairs(e.droneProductionProgress) do assert(math.abs(value - expected) < 1e-9) end
  equal(e.frameBonuses.baseProduction, 3)
end)
test("Powered apiary skips offline catchup and pauses without power", function()
  local e = setup(); e.storage.lastActive = 0; e.storage.unfinishedTicks = 700; e.startApiary()
  equal(e.storage.lastActive, nil); equal(e.ticksToSimulate, nil)
  local ticks = 0; e.beeTick = function() ticks = ticks + 1 end
  e.update(1/12); e.update(1/12); equal(ticks, 0); equal(e.consumed, 2)
  e.supply = 0; for _ = 1, 20 do e.update(1) end; equal(ticks, 0); equal(e.consumed, 2)
  e.supply = 100; for _ = 1, 20 do e.update(.1) end; assert(ticks >= 1)
  e.uninit(); equal(e.storage.lastActive, nil); equal(e.storage.unfinishedTicks, nil)
end)
test("Larva matures and establishes drones without a native starter", function()
  local e = setup(); e.startApiary()
  local h = e.hybrid("honey", "carpenter"); h.name = "bee_hybrid_youngQueen"; h.parameters.lifespan = nil
  e.inventory[0] = e.root.createItem(h)
  for _ = 1, 300 do e.update(1) end
  assert(e.inventory[1] and e.inventory[1].name == "bee_hybrid_drone")
  assert(e.hybridbees.compatible(e.inventory[0], e.inventory[1])); assert(e.consumed > 0)
end)
test("Zero-gene production works with no NaN and old return semantics", function()
  local e = setup(); e.startApiary(); e.reportFull = true
  local h = e.hybrid("aquarum", "honey"); e.inventory[0] = h
  local d = copy(h); d.name = "bee_hybrid_drone"; d.count = 100; d.parameters.lifespan = nil
  e.inventory[1] = e.root.createItem(d)
  for _ = 1, 100 do e.update(1) end
  local total = 0
  for slot = 3, 11 do local item = e.inventory[slot]; if item then assert(finite(item.count)); total = total + item.count end end
  assert(total > 0); equal(#e.spawned, 0)
end)
test("Cross-species native drones cannot produce hybrid resources", function()
  local e = setup(); e.startApiary(); activateHybrid(e, e.hybrid("honey", "carpenter"))
  e.droneProduction(e.parent("honey", "drone")); equal(next(e.droneProductionProgress), nil)
  assert(not e.isDroneActive(e.parent("honey", "drone")))
end)
test("Queen/drone rivalry works with the single drone slot", function()
  local e = setup(); e.startApiary(); activateHybrid(e, e.hybrid("carpenter", "mason"))
  e.inventory[1] = e.parent("carpenter", "drone"); e.inventory[1].count = 50
  e.contents = e.world.containerItems(42); assert(e.checkRivalries()); assert(e.inventory[1].count < 50)
end)
test("Queen identity and descendant lineage cannot cross unrelated pairs", function()
  local e = setup(); e.startApiary(); local a, b = e.hybrid("honey", "carpenter"), e.hybrid("honey", "artisan")
  activateHybrid(e, a)
  b.parameters.genome = a.parameters.genome
  assert(not e.isSameQueen(a, b)); assert(not e.hybridbees.compatible(a, b))
  e.queen = a; local mate = copy(a); mate.name = "bee_hybrid_drone"; mate.parameters.lifespan = nil
  e.contents[2] = mate; local child = e.generateYoungQueen()
  equal(child.name, "bee_hybrid_youngQueen"); equal(child.parameters.hybridLineage.speciesId, a.parameters.hybridLineage.speciesId)
end)
test("Resistance frames still resolve hybrid biome intolerance", function()
  local e = setup(); e.startApiary(); activateHybrid(e, e.hybrid("honey", "mason")); e.biome = "desert"
  equal(e.getBiomeFavor(e.queen.name), -1); e.frameBonuses.heatResistance = true
  equal(e.getBiomeFavor(e.queen.name), e.data.biomeLiked)
end)
test("Both subspecies use their species sprite and preserve life bars", function()
  local e = setup(); local a = e.hybrid("honey", "carpenter")
  local b = copy(a); b.parameters.genome = e.genelib.modifyGenomeStat(b.parameters.genome, "subtype", 1)
  local ca = e.build("/bees/bees/", copy(fixture.hybridItems[a.name]), copy(a.parameters), 1, 1)
  local cb = e.build("/bees/bees/", copy(fixture.hybridItems[b.name]), copy(b.parameters), 1, 1)
  assert(same(ca.inventoryIcon, cb.inventoryIcon)); equal(#ca.inventoryIcon, 1)
  equal(ca.inventoryIcon[1].image, '/bees/bees/hybrid_carpenter_honey.png:queen')
  equal(ca.inventoryIcon[1].position[1], 0)
  local larva = copy(a); larva.name = 'bee_hybrid_youngQueen'; larva.parameters.lifespan = nil
  local larvaConfig = e.build('/bees/bees/', copy(fixture.hybridItems[larva.name]), copy(larva.parameters), 1, 1)
  equal(larvaConfig.inventoryIcon[1].image, '/bees/bees/hybrid_carpenter_honey.png:youngQueen')
  local drone = copy(a); drone.name = 'bee_hybrid_drone'; drone.parameters.lifespan = nil
  local droneConfig = e.build('/bees/bees/', copy(fixture.hybridItems[drone.name]), copy(drone.parameters), 1, 1)
  equal(droneConfig.inventoryIcon[1].image, '/bees/bees/hybrid_carpenter_honey.png:drone')
  a.parameters.genomeInspected = true
  ca = e.build("/bees/bees/", copy(fixture.hybridItems[a.name]), copy(a.parameters), 1, 1)
  equal(#ca.inventoryIcon, 2); assert(ca.inventoryIcon[2].image:find('beelifebar', 1, true))
end)
test("Powered apiary never spawns native or hybrid capturable bees", function()
  local e = setup(); e.startApiary()
  local native = e.parent("honey", "queen")
  e.tryBeeSpawn("honey", native.parameters.genome)
  local h = e.hybrid("honey", "carpenter")
  e.tryBeeSpawn("hybrid", h.parameters.genome)
  equal(#e.monsters, 0)
  e.inventory[0] = native
  for _ = 1, 100 do e.update(1) end
  equal(#e.monsters, 0)
  e.inventory[0] = h
  for _ = 1, 100 do e.update(1) end
  equal(#e.monsters, 0)
end)
test("Native small and large apiaries produce hybrid resources and preserve lineage", function()
  for _, large in ipairs({false, true}) do
    local e = setup(); local h = e.hybrid("honey", "carpenter"); e.startNativeApiary(large)
    local larva = copy(h); larva.name = "bee_hybrid_youngQueen"; larva.parameters.lifespan = nil
    e.inventory[0] = e.root.createItem(larva)
    e.inventory[e.settings.frameSlots[1] - 1] = {name = "basicframe", count = 1, parameters = {}}
    for _ = 1, 100 do e.beeTick(1) end
    local drone = e.inventory[1]
    assert(drone and e.hybridbees.compatible(e.inventory[0], drone))
    assert(e.inventory[0].parameters.hybridLineage.speciesId == h.parameters.hybridLineage.speciesId)
    drone.count = 1000; e.inventory[1] = drone
    for _ = 1, 150 do e.beeTick(1) end
    local total = 0
    for slot = e.settings.firstInventorySlot - 1, e.settings.slotCount - 1 do
      local item = e.inventory[slot]
      if item and item.name ~= "bee_hybrid_drone" and item.name ~= "bee_hybrid_youngQueen" then total = total + item.count end
    end
    assert(total > 0); equal(#e.monsters, 0)
    e.queen = e.inventory[0]; e.contents = e.world.containerItems(42)
    local child = e.generateYoungQueen()
    equal(child.name, "bee_hybrid_youngQueen")
    equal(child.parameters.hybridLineage.speciesId, h.parameters.hybridLineage.speciesId)
    local native = e.parent("honey", "queen")
    e.data.beeSpawnChance = 1; e.roll = 0
    e.tryBeeSpawn("honey", native.parameters.genome)
    equal(#e.monsters, 1)
    e.tryBeeSpawn("hybrid", h.parameters.genome)
    equal(#e.monsters, 1)
  end
end)
print("Hybrids: " .. passed .. " test groups passed (engine bindings mocked).")
