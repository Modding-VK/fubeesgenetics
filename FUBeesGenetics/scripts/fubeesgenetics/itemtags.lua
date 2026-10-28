-- Immutable item definitions only; never cache inspection, genome or inventory.
-- Engine callbacks are attached after this module loads.
fubeesItemTags = {}
local entries, names, nextEntry = {}, {}, 1
function fubeesItemTags.has(name, tag)
  local entry = entries[name]
  if entry and entry[tag] ~= nil then return true, entry[tag] end
  local ok, value = pcall(root.itemHasTag, name, tag)
  if not ok then return false, nil end
  if not entry then
    if names[nextEntry] then entries[names[nextEntry]] = nil end
    names[nextEntry], entry = name, {}
    entries[name] = entry
    nextEntry = nextEntry % 128 + 1
  end
  entry[tag] = not not value
  return true, entry[tag]
end
