require "/scripts/fubeesgenetics/swarm.lua"
require "/scripts/fubeesgenetics/containerutil.lua"

local M, container = fubeesSwarm, fubeesContainer
local queenSlot, firstDrone, lastDrone, podSlot, chipSlot, outputSlot = 0, 1, 3, 4, 5, 6
local inputs, specimens, state, options, previewKey, preview
local visual = {}

local function read(slot)
  return world.containerItemAt(entity.id(), slot)
end

local function setVisual(name, value)
  if visual[name] == value then return end
  animator.setAnimationState(name, value)
  visual[name] = value
end

local function specimen(slot)
  local cached = specimens[slot]
  local item = inputs[slot]
  if item and cached and container.matches(item, cached.item) then return cached.specimen end
  local bee = M.specimen(item, slot == queenSlot and "queen" or "drone")
  specimens[slot] = item and {item = item, specimen = bee} or nil
  return bee
end

local function refresh()
  for slot = queenSlot, outputSlot do inputs[slot] = read(slot) end
  local queen = specimen(queenSlot)
  local count, droneSlots = 0, {}
  if queen then
    for slot = firstDrone, lastDrone do
      local drone = specimen(slot)
      if drone and drone.species == queen.species and drone.genome == queen.genome then
        count = count + inputs[slot].count
        droneSlots[#droneSlots + 1] = slot
      end
    end
  end
  local tier = math.min(3, math.floor(count / 1000))
  local key = tier > 0 and table.concat({queen.species, queen.genome, tier}, ":") or nil
  if previewKey ~= key then
    preview = key and M.preview(queen, tier) or nil
    previewKey = key
  end
  local job = storage.swarmJob
  local status = "READY"
  if job then status = job.remaining > 0 and "WORKING" or "OUTPUT"
  elseif storage.swarmRefunds then status = "RECOVERY"
  elseif not queen then status = "QUEEN"
  elseif tier == 0 then status = "DRONES"
  elseif not inputs[podSlot] or inputs[podSlot].name ~= "capturepod" then status = "POD"
  elseif not inputs[chipSlot] or inputs[chipSlot].name ~= "aichip" then status = "CHIP"
  elseif inputs[outputSlot] then status = "OUTPUT"
  end

  local displayedTier = job and job.preview.tier or tier
  state = {status = status, count = job and displayedTier * 1000 or count,
    preview = job and job.preview or preview,
    progress = job and (M.duration - job.remaining) / M.duration or 0,
    seconds = job and math.ceil(job.remaining) or 0}
  options = droneSlots
  setVisual("queen", (inputs[queenSlot] or job) and "on" or "off")
  setVisual("gauge", "level" .. displayedTier)
  setVisual("led", job and job.remaining > 0 and "amber" or status == "READY" and "green" or "off")
  setVisual("pod", (inputs[podSlot] or job) and "on" or "off")
  setVisual("chip", (inputs[chipSlot] or job) and "on" or "off")
  setVisual("output", inputs[outputSlot] and "on" or "off")
  return state
end

local function refund()
  local pending = storage.swarmRefunds
  if not pending then return end
  while #pending > 0 do
    local entry = pending[#pending]
    local leftover = container.put(entity.id(), entry.item, entry.slot)
    if leftover then
      entry.item = leftover
      return
    end
    table.remove(pending)
  end
  storage.swarmRefunds = nil
end

local function take(slot, count, reserved)
  local expected = inputs[slot]
  local current = read(slot)
  if not current or current.count < count or not container.matches(expected, current) then return false end
  local taken = world.containerTakeNumItemsAt(entity.id(), slot, count)
  if taken then reserved[#reserved + 1] = {slot = slot, item = taken} end
  return taken and taken.count == count and container.matches(expected, taken)
end

local function encapsulate(quoted)
  local current = refresh()
  if current.status ~= "READY" or not container.same(quoted, current.preview) then return current end
  local result = M.buildPod(current.preview)
  local reserved = {}
  local remaining = current.preview.tier * 1000
  storage.swarmRefunds = reserved
  local ok = take(queenSlot, 1, reserved) and take(podSlot, 1, reserved) and take(chipSlot, 1, reserved)
  for _, slot in ipairs(options) do
    if not ok or remaining == 0 then break end
    local count = math.min(remaining, inputs[slot].count)
    ok = take(slot, count, reserved)
    remaining = remaining - count
  end
  if ok and remaining == 0 then
    storage.swarmJob = {remaining = M.duration, result = result, preview = current.preview, reserved = reserved}
    storage.swarmRefunds = nil
  else
    refund()
  end
  return refresh()
end

function init()
  inputs, specimens = {}, {}
  refresh()
  message.setHandler("fubeesgenetics.swarm.getState", function() return state end)
  message.setHandler("fubeesgenetics.swarm.encapsulate", function(_, _, quoted) return encapsulate(quoted) end)
end

function update(dt)
  refund()
  local job = storage.swarmJob
  if job then
    job.remaining = math.max(0, job.remaining - dt)
    if job.remaining == 0 and not read(outputSlot) and not container.put(entity.id(), job.result, outputSlot) then
      storage.swarmJob = nil
    end
  end
  refresh()
end

function die()
  local job = storage.swarmJob
  if job and job.remaining == 0 then
    world.spawnItem(job.result, entity.position())
    return
  end
  for _, entry in ipairs(job and job.reserved or storage.swarmRefunds or {}) do
    world.spawnItem(entry.item, entity.position())
  end
end
