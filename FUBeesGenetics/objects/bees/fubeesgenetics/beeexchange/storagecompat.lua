-- Optional integration with the installed Improved Containers 2.x. No IC code
-- is bundled. The canonical UI identifies the matching provider/handlers.
local window = root.assetJson("/interface/chests/chest16.config")
local installed = false
for _, path in ipairs(window.scripts or {}) do
  if path == "/scripts/v6/improvedcontainergui.lua" then installed = true end
end
if not installed then
  local exchangeInit = init
  function init()
    -- Remove only our persisted IC overrides when the optional mod is removed.
    if config.getParameter("fubeesgeneticsIC") then
      object.setConfigParameter("uiConfig", "/interface/chests/chest16.config")
      object.setConfigParameter("smashOnBreak", false)
      object.setConfigParameter("fubeesgeneticsIC", false)
    end
    exchangeInit()
    -- Packed machines remain recoverable even after IC is uninstalled.
    local content = config.getParameter("content")
    if not storage.init and type(content) == "table" then
      for slot, item in pairs(content) do
        local leftover = world.containerItemApply(entity.id(), item, slot - 1)
        if leftover then world.spawnItem(leftover, entity.position()) end
      end
      object.setConfigParameter("content", {})
      storage.init = true
    end
  end
  return
end

local exchangeDie = die
require "/scripts/v6/improvedcontainer.lua"
local icInit, icDie = init, die

function init()
  object.setConfigParameter("fubeesgeneticsIC", true)
  object.setConfigParameter("smashOnBreak", true)
  icInit()
  -- IC's default 60 ticks would throttle the machine's 1.25-second animation.
  script.setUpdateDelta(config.getParameter("scriptDelta", 10))
  message.setHandler("fubeesgenetics.storageLock", function()
    ic.locked = 2
    return true
  end)
  -- IC verifies quick-stack writes for up to 1.4 seconds after insertion.
  message.setHandler("lock", function() ic.locked = 2 end)
  local ui = root.assetJson("/interface/chests/chest16.config")
  ui.scripts = ui.scripts or {}
  local bridge = "/objects/bees/fubeesgenetics/beeexchange/storagegui.lua"
  for _, path in ipairs(ui.scripts) do if path == bridge then return end end
  table.insert(ui.scripts, bridge)
  object.setConfigParameter("uiConfig", ui)
end

function die()
  if self.storageCompatDestroyed then return end
  self.storageCompatDestroyed = true
  -- IC does not chain die(): recover owed rewards before it packs the inventory.
  exchangeDie()
  icDie()
end
