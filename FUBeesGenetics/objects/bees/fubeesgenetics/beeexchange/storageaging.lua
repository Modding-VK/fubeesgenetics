-- Let the installed IC provider age contents packed inside the machine item.
require "/scripts/items/rotting.lua"
local window = root.assetJson("/interface/chests/chest16.config")
for _, path in ipairs(window.scripts or {}) do
  if path == "/scripts/v6/improvedcontainergui.lua" then
    require "/scripts/v6/improvedcontainerrotting.lua"
    break
  end
end
