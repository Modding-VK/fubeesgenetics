require "/scripts/fubeesgenetics/containerutil.lua"

-- Pure, slot-bounded planner. Capacity is not monotonic per batch: consuming
-- a complete input stack opens another reward slot. Examine those thresholds,
-- rather than binary-searching feasibility or simulating each batch of five.
fubeesBatch = {}
local function integer(n)
  return type(n) == "number" and n > 0 and n < math.huge and n == math.floor(n)
end
function fubeesBatch.select(slots, start, size, name, cost, reward, limit, budget)
  if not integer(cost) or not integer(reward.count) or not integer(limit) or not integer(budget) then return 0 end
  local prefixes, total, capacity = {}, 0, 0
  for offset = 0, size - 1 do
    local item = slots[(start + offset) % size]
    if item and item.name == name and integer(item.count) then
      total = total + item.count; prefixes[#prefixes + 1] = total
    end
    if not item then capacity = capacity + limit
    elseif fubeesContainer.matches(item, reward) then capacity = capacity + math.max(0, limit - item.count) end
  end
  local ceiling, best = math.min(budget, math.floor(total / cost)), 0
  for freed = 0, #prefixes do
    local batches = math.min(ceiling, math.floor((capacity + freed * limit) / reward.count))
    if batches > best then
      local actual = capacity
      for _, prefix in ipairs(prefixes) do if prefix <= batches * cost then actual = actual + limit end end
      if batches * reward.count <= actual then best = batches end
    end
  end
  return best
end
