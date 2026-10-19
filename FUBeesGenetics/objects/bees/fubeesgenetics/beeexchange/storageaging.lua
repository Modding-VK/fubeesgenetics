-- Item aging modules also load before root is bound. Resolve the optional IC
-- provider lazily on the first ageItem call, not while loading this module.
require "/scripts/items/rotting.lua"
local vanillaAge = ageItem
local selectedAge
local bridgeAge
bridgeAge = function(item, elapsed)
  if not selectedAge then
    selectedAge = vanillaAge
    local window = root.assetJson("/interface/chests/chest16.config")
    for _, path in ipairs(window.scripts or {}) do
      if path == "/scripts/v6/improvedcontainergui.lua" then
        ageItem = vanillaAge
        require "/scripts/v6/improvedcontainerrotting.lua"
        selectedAge = ageItem
        ageItem = bridgeAge
        break
      end
    end
  end
  return selectedAge(item, elapsed)
end
ageItem = bridgeAge
