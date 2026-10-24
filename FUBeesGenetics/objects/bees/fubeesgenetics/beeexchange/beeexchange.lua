require "/scripts/kheAA/transferUtil.lua"
require "/scripts/fubeesgenetics/containerutil.lua"

local BASE = "/objects/bees/fubeesgenetics/beeexchange/"
local copy, same, matches = fubeesContainer.copy, fubeesContainer.same, fubeesContainer.matches
local function integer(n)
  return type(n) == "number" and n > 0 and n < math.huge and n == math.floor(n)
end
local function contents()
  local result, snapshot = {}, world.containerItems(entity.id())
  for slot = 0, self.size - 1 do result[slot] = snapshot[slot + 1] end
  return result
end
local function maxStack(item)
  local data = root.itemConfig(item)
  if not data or not data.config then return nil end
  return (data.parameters or {}).maxStack or data.config.maxStack or self.defaultMaxStack
end

-- Plan against the inventory *after* consumption. Never remove bees until the
-- complete reward fits. Shared slots behave like Terramart, without selling junk.
local function destinations(slots, item)
  local limit = maxStack(item)
  if not integer(limit) then return nil end
  local remaining, plan = item.count, {}
  for _, occupied in ipairs({true, false}) do
    for slot = 0, self.size - 1 do
      local current = slots[slot]
      if (occupied and matches(current, item)) or (not occupied and not current) then
        local count = math.min(remaining, math.max(0, limit - (current and current.count or 0)))
        if count > 0 then
          plan[#plan + 1] = {slot = slot, count = count}
          remaining = remaining - count
          if remaining == 0 then return plan end
        end
      end
    end
  end
end

-- Read actual slot deltas: older OpenStarbound versions can return the full
-- input descriptor even after a successful containerPutItemsAt.
local function put(item, slot)
  local before = world.containerItemAt(entity.id(), slot)
  if before and not matches(before, item) then return 0 end
  world.containerPutItemsAt(entity.id(), item, slot)
  local after = world.containerItemAt(entity.id(), slot)
  if not matches(after, item) then return 0 end
  local delta = after.count - (before and before.count or 0)
  if delta >= 0 and delta <= item.count then return delta end
  error("Bee Exchange: unexpected inventory delta; refusing another transaction")
end

-- Exceptional refunds/rewards persist across reloads. There is never a second
-- sale while any previous transaction still has undelivered items.
local function deliver()
  local pending = storage.exchangePending
  if not pending then return true end
  while #pending > 0 do
    local item = pending[1]
    local plan = destinations(contents(), item)
    if not plan then return false end
    for _, entry in ipairs(plan) do
      local portion = copy(item)
      portion.count = entry.count
      local delivered = put(portion, entry.slot)
      item.count = item.count - delivered
      if delivered ~= entry.count then return false end
    end
    table.remove(pending, 1)
  end
  storage.exchangePending = nil
  return true
end

local function exchange(slot)
  -- A hint only: a real trade still takes a fresh complete snapshot and
  -- revalidates every physical source before withdrawal. Empty/reward/junk
  -- slots do not need to serialize the other fifteen slots.
  local hint = world.containerItemAt(entity.id(), slot)
  if not hint or not self.trades[hint.name] then return false end
  local slots = contents()
  local candidate = slots[slot]
  local trade = candidate and self.trades[candidate.name]
  if not trade then return false end
  local sources, needed = {}, trade.input.count
  -- A drone batch can span stacks with different genetic parameters.
  for offset = 0, self.size - 1 do
    local index = (slot + offset) % self.size
    local item = slots[index]
    if item and item.name == candidate.name and integer(item.count) then
      local count = math.min(needed, item.count)
      sources[#sources + 1] = {slot = index, item = copy(item), count = count}
      item.count = item.count - count
      if item.count == 0 then slots[index] = nil end
      needed = needed - count
      if needed == 0 then break end
    end
  end
  if needed > 0 or not destinations(slots, trade.output) then return false end

  local removed = {}
  for _, source in ipairs(sources) do
    local current = world.containerItemAt(entity.id(), source.slot)
    if not same(current, source.item) then
      storage.exchangePending = removed
      deliver()
      return false
    end
    local taken = world.containerTakeNumItemsAt(entity.id(), source.slot, source.count)
    if taken then removed[#removed + 1] = copy(taken) end
    if not taken or not matches(taken, source.item) or taken.count ~= source.count then
      storage.exchangePending = removed
      deliver()
      return false
    end
  end
  -- All exact inputs were taken synchronously. The reward is now owed, even if
  -- an output binding unexpectedly fails. Persist it before trying insertion.
  storage.exchangePending = {copy(trade.output)}
  deliver()
  return true
end

-- Share one work cycle across simultaneous sales; never restart mid-teleport.
local function animateSale()
  if self.shippingTimer then return end
  self.shippingTimer = 0
  animator.setAnimationState("machine", "work", true)
end

local function syncFacing()
  -- Placement and restored objects can resolve direction after init. Reassert
  -- the atlas tag before any early return, including IC locks and on/off gates.
  animator.setGlobalTag("facingSuffix", object.direction() == -1 and "-left" or "")
end

function init()
  self = {timer = 0, cursor = 0, trades = {}, size = config.getParameter("slotCount")}
  syncFacing()
  self.defaultMaxStack = root.assetJson("/items/defaultParameters.config").defaultMaxStack
  for _, path in ipairs(root.assetJson(BASE .. "trades.config").recipes) do
    local recipe = root.assetJson(path)
    assert(#recipe.input == 1, "Bee Exchange requires a single bee input")
    local input, output = recipe.input[1], recipe.output
    assert(input.item:match("^bee_.+_queen$") or input.item:match("^bee_.+_youngQueen$")
      or input.item:match("^bee_.+_drone$"), "Non-bee trade refused")
    assert(integer(input.count) and integer(output.count), "Invalid Bee Refuge quantities")
    assert(not self.trades[input.item], "Duplicate Bee Refuge trade")
    self.trades[input.item] = {input = copy(input), output = {
      name = output.item, count = output.count, parameters = copy(output.parameters or {})}}
  end
  -- Young Queens pay the same resource and amount as their adult species.
  -- Resolve after loading every recipe: manifest order must not affect rewards.
  for name, trade in pairs(self.trades) do
    if name:match("_youngQueen$") then
      local adult = assert(self.trades[(name:gsub("_youngQueen$", "_queen"))],
        "Young Queen has no adult Bee Refuge trade: " .. name)
      trade.output = copy(adult.output)
    end
  end
  for _, trade in pairs(self.trades) do
    assert(not self.trades[trade.output.name], "Recursive Bee Refuge trade refused")
  end
  transferUtil.loadSelfContainer()
  animator.setAnimationState("machine", "ready")
end

function update(dt)
  syncFacing()
  if self.shippingTimer then
    self.shippingTimer = self.shippingTimer + dt
    if self.shippingTimer >= 1.25 then self.shippingTimer = nil end
  end
  self.timer = self.timer + dt
  if self.timer < 1 then return end
  self.timer = self.timer % 1
  transferUtil.loadSelfContainer()
  if ic and ic.version == 2 and (ic.locked or 0) > 0 then return end
  if not deliver() then return end
  -- Same switch rule as FU Terramart 3.5: unwired runs automatically;
  -- connected low pauses new sales, connected high enables them. Finish any
  -- already owed delivery regardless of switch state.
  local logicNode = transferUtil.vars.logicNode
  if object.isInputNodeConnected(logicNode) and not object.getInputNodeLevel(logicNode) then return end
  -- One recipe per slot per second, no offline catch-up. Rotate priority so a
  -- continually refilled early slot cannot monopolize limited output capacity.
  local start = self.cursor
  self.cursor = (start + 1) % self.size
  for offset = 0, self.size - 1 do
    if exchange((start + offset) % self.size) then animateSale() end
    if storage.exchangePending then return end
  end
end

function die()
  if self.finalRecoveryAttempted then return end
  self.finalRecoveryAttempted = true
  local pending = storage.exchangePending
  if not pending then return end
  -- Physical inventory is dropped by the engine. Only owed items need help.
  while #pending > 0 do
    local ok, id = pcall(world.spawnItem, pending[1], entity.position())
    if not ok or not integer(id) then
      sb.logError("[FUBeesGenetics] Bee Exchange pending drop failed: %s", sb.printJson(pending))
      return
    end
    table.remove(pending, 1)
  end
  storage.exchangePending = nil
end
