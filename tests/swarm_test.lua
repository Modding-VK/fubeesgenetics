local id = "fubeesgenetics_swarm"
local controller = "/objects/bees/fubeesgenetics/swarmassembler/swarmassembler.lua"

local function setup()
  local env = setmetatable({}, {__index = _G})
  local slots, handlers, animations, drops = {}, {}, {}, {}
  local function read(slot)
    local item = slots[slot]
    return env.fubeesContainer.copy(item)
  end
  env.require = function(path)
    local prefix = path:find("fubeesgenetics", 1, true) and fixture.repoRoot .. "/FUBeesGenetics" or fixture.fuRoot
    assert(loadfile(prefix .. path, "t", env))()
  end
  env.storage = {}
  env.entity = {id = function() return 42 end, position = function() return {0, 0} end}
  env.root = {
    assetJson = function() return fixture.beeData end,
    itemHasTag = function(name, tag)
      return name:match("^bee_") ~= nil and (tag == "bee" or name:match("_" .. tag .. "$") ~= nil)
    end,
    createItem = function(item) return env.fubeesContainer.copy(item) end,
    monsterPortrait = function(monsterType, parameters)
      assert(monsterType == id and parameters.colorSwap["7a7a7a"])
      return {{image = "portrait"}}
    end
  }
  env.sb = {makeUuid = function() return "unique-pod" end}
  env.animator = {setAnimationState = function(name, value) animations[name] = value end}
  env.message = {setHandler = function(name, callback) handlers[name] = callback end}
  env.world = {
    containerItemAt = function(_, slot) return read(slot) end,
    containerTakeNumItemsAt = function(_, slot, count)
      if env.failSlot == slot then return nil end
      local item = assert(read(slot))
      local taken = math.min(count, item.count)
      slots[slot].count = item.count - taken
      if slots[slot].count == 0 then slots[slot] = nil end
      item.count = taken
      return item
    end,
    containerPutItemsAt = function(_, item, slot)
      if slots[slot] then
        assert(env.fubeesContainer.matches(slots[slot], item) and item.count + slots[slot].count <= 1000)
        slots[slot].count = slots[slot].count + item.count
      else
        slots[slot] = env.fubeesContainer.copy(item)
      end
      return item -- oSB can return the input after a successful insertion
    end,
    spawnItem = function(item) drops[#drops + 1] = item; return #drops end
  }
  env.require(controller)
  env.init()
  return env, slots, handlers, animations, drops
end

local function item(name, count, genome)
  return {name = name, count = count, parameters = genome and {genome = genome} or {}}
end

local function loadBatch(env, slots)
  local genome = "01" .. env.genelib.generateDefaultGenome("bee_scoria_queen"):sub(3)
  slots[0] = item("bee_scoria_queen", 1, genome)
  slots[1] = item("bee_scoria_drone", 1000, genome)
  slots[2] = item("bee_scoria_drone", 1000, genome)
  slots[4] = item("capturepod", 1)
  slots[5] = item("aichip", 1)
  return genome
end

local e, slots, handlers, visual = setup()
local get, start = handlers["fubeesgenetics.swarm.getState"], handlers["fubeesgenetics.swarm.encapsulate"]
local genome = loadBatch(e, slots)
slots[2].count = 999
slots[3] = item("bee_scoria_drone", 1000, e.genelib.modifyGenomeStat(genome, "droneToughness", 1))
e.update(0)
local state = get()
assert(state.count == 1999 and state.preview.tier == 1 and visual.gauge == "level1")
assert(state.preview.name == "Small Scoria Swarm" and state.preview.element == "fire")
local stale = state.preview
slots[2].count = 1000
slots[3] = item("bee_honey_drone", 1000, genome)
e.update(0)
state = get()
assert(state.count == 2000 and state.status == "READY" and visual.led == "green")
assert(state.preview.name == "Medium Scoria Swarm")
assert(math.abs(state.preview.health - stale.health * 1.1) <= 0.02)
assert(start(nil, nil, stale).status == "READY" and slots[0])
slots[3] = item("bee_scoria_drone", 1000, genome)
e.update(0)
local large = get().preview
assert(large.name == "Large Scoria Swarm" and visual.gauge == "level3")
assert(start(nil, nil, large).status == "WORKING")
assert(visual.led == "amber" and not slots[0] and slots[6] == nil)
assert(start(nil, nil, state.preview).status == "WORKING")
e.update(59)
assert(not slots[6] and get().seconds == 1)
e.init()
slots[6] = item("blocked", 1)
e.update(1)
assert(get().status == "OUTPUT" and slots[6].name == "blocked")
slots[6] = nil
e.update(0)
local pod = slots[6]
assert(pod.name == "filledcapturepod" and not e.storage.swarmJob)
local pet = pod.parameters.pets[1]
assert(pet.name == "Large Scoria Swarm" and pet.config.type == id)
assert(pet.config.parameters.scale == 1.3 and pet.config.parameters.touchDamage.damageSourceKind == "fire")
assert(pet.config.parameters.genome == nil and pet.genome == nil)
assert(pet.config.parameters.statusSettings.stats.healthRegen.baseValue == large.regen)
e.update(1)
assert(slots[6] == pod)

local fail, failedSlots, callbacks, _, drops = setup()
loadBatch(fail, failedSlots)
fail.update(0)
fail.failSlot = 2
local failedState = callbacks["fubeesgenetics.swarm.getState"]()
callbacks["fubeesgenetics.swarm.encapsulate"](nil, nil, failedState.preview)
assert(not fail.storage.swarmJob and not fail.storage.swarmRefunds)
assert(failedSlots[0] and failedSlots[1].count == 1000 and failedSlots[2].count == 1000)
assert(failedSlots[4] and failedSlots[5])
fail.failSlot = nil
assert(callbacks["fubeesgenetics.swarm.encapsulate"](nil, nil, failedState.preview).status == "WORKING")
fail.die()
assert(#drops == 5 and not failedSlots[6])
print("Swarm Assembler integration checks passed")
