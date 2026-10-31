-- FU calls checkRivalries immediately after refreshing contents in beeTick.
-- Inspect that authoritative tick snapshot instead of crossing world bindings
-- again just to decide whether the optional hybrid implementation is needed.
fubeesApiary = {}
function fubeesApiary.deferHybrids(multiplier)
  local nativeRivalries = checkRivalries
  local function isHybrid(item)
    return item and item.name:match("^bee_hybrid_") ~= nil
  end
  checkRivalries = function(...)
    local found = isHybrid(contents[queenSlot])
    if not found then
      for _, slot in ipairs(droneSlots) do
        if isHybrid(contents[slot]) then found = true; break end
      end
    end
    if not found then return nativeRivalries(...) end
    require "/scripts/fubeesgenetics/containerutil.lua"
    require "/scripts/fubeesgenetics/hybridbees.lua"
    fubeesContainer.install()
    checkRivalries = nativeRivalries
    hybridbees.install(multiplier)
    return checkRivalries(...)
  end
end
