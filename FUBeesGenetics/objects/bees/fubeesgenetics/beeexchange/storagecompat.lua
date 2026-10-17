-- Object script modules load before engine callbacks exist. Resolve optional
-- providers only in init(), after root/config/object/animator have been bound.
local exchangeInit, exchangeUpdate, exchangeDie = init, update, die
local providerInit, providerUpdate, providerDie
local compatInit

local function hasProvider()
  local window = root.assetJson("/interface/chests/chest16.config")
  for _, path in ipairs(window.scripts or {}) do
    if path == "/scripts/v6/improvedcontainergui.lua" then return true end
  end
  return false
end

local function fallbackInit()
  if config.getParameter("fubeesgeneticsIC") then
    object.setConfigParameter("uiConfig", "/interface/chests/chest16.config")
    object.setConfigParameter("smashOnBreak", false)
    object.setConfigParameter("fubeesgeneticsIC", false)
  end
  exchangeInit()
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

local function compatDie()
  if self.storageCompatDestroyed then return end
  self.storageCompatDestroyed = true
  exchangeDie()
  providerDie()
end

compatInit = function()
  -- ContainerObject requires a string asset path. Repair persisted table values
  -- from older builds before the player can open an existing machine.
  object.setConfigParameter("uiConfig", "/interface/chests/chest16.config")
  if not hasProvider() then
    update, die = exchangeUpdate, exchangeDie
    fallbackInit()
    return
  end
  if not providerInit then
    -- IC captures existing init/update while loading. Give it the real machine
    -- functions, not this wrapper, so init cannot recurse into itself.
    init, update, die = exchangeInit, exchangeUpdate, exchangeDie
    require "/scripts/v6/improvedcontainer.lua"
    providerInit, providerUpdate, providerDie = init, update, die
  end
  init, update, die = compatInit, providerUpdate, compatDie
  object.setConfigParameter("fubeesgeneticsIC", true)
  object.setConfigParameter("smashOnBreak", true)
  providerInit()
  script.setUpdateDelta(config.getParameter("scriptDelta", 10))
  message.setHandler("fubeesgenetics.storageLock", function()
    ic.locked = 2
    return true
  end)
  message.setHandler("lock", function() ic.locked = 2 end)

end
init = compatInit
