-- Read actual slot deltas: some OpenStarbound versions return the entire input
-- descriptor even after successful insertion. Normalize builder parameters first.
fubeesContainer = {}
local rawPut

function fubeesContainer.copy(value)
  if type(value) ~= "table" then return value end
  local result = {}
  for key, child in pairs(value) do result[key] = fubeesContainer.copy(child) end
  return result
end

function fubeesContainer.same(a, b)
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return a == b end
  for key, value in pairs(a) do if not fubeesContainer.same(value, b[key]) then return false end end
  for key in pairs(b) do if a[key] == nil then return false end end
  return true
end

function fubeesContainer.matches(a, b)
  return a and b and a.name == b.name
    and fubeesContainer.same(a.parameters or {}, b.parameters or {})
end

-- Filter transfers must never rebuild an inspected specimen. Preserve the
-- original descriptor and legacy nil/leftover behavior, confirming successful
-- legacy returns only through an exact synchronous slot delta.
function fubeesContainer.putExact(id, descriptor, slot, normalize)
  local before = normalize(world.containerItemAt(id, slot))
  local leftover = world.containerPutItemsAt(id, descriptor, slot)
  if not leftover then return nil end
  local after = normalize(world.containerItemAt(id, slot))
  local unit = normalize(descriptor)
  if unit and after and fubeesContainer.matches(after, unit)
    and (not before or fubeesContainer.matches(before, unit))
    and after.count == (before and before.count or 0) + unit.count then return nil end
  return leftover
end

function fubeesContainer.put(id, descriptor, slot)
  local item = root.createItem(descriptor)
  if not item or item.count < 1 then return descriptor end
  local before = world.containerItemAt(id, slot)
  if before and not fubeesContainer.matches(before, item) then return item end
  (rawPut or world.containerPutItemsAt)(id, item, slot)
  local after = world.containerItemAt(id, slot)
  local delta = fubeesContainer.matches(after, item) and (after.count - (before and before.count or 0)) or 0
  assert(delta >= 0 and delta <= item.count, "Bee inventory: unexpected insertion delta")
  if delta == item.count then return nil end
  item.count = item.count - delta
  return item
end

-- Only affects the current object's Lua context, including its native FU calls.
-- Install in init, after the engine attaches world/root callbacks.
function fubeesContainer.install()
  if rawPut then return end
  rawPut = world.containerPutItemsAt
  world.containerPutItemsAt = fubeesContainer.put
end
