-- Appended to the shared IC 16-slot window. Engine bindings are used only in
-- init/update, and the acknowledgement guard applies exclusively to Bee Exchange.
local providerInit, providerUpdate = init, update
local pending
local enabled = false
local function guarded(action)
  return function(...)
    if pending then return end
    pending = {request = world.sendEntityMessage(pane.containerEntityId(),
      "fubeesgenetics.storageLock"), action = action, args = {...}}
  end
end
function init()
  if providerInit then providerInit() end
  enabled = world.entityName(pane.containerEntityId()) == "fubeesgenetics_beeexchange"
    and type(ic) == "table" and ic.version == 2
  if enabled then
    ic.sortAction = guarded(ic.sortAction)
    ic.quickstackAction = guarded(ic.quickstackAction)
  end
end
function update(dt)
  if providerUpdate then providerUpdate(dt) end
  if enabled and pending and pending.request:finished() then
    local operation = pending
    pending = nil
    if operation.request:result() == true then
      operation.action(table.unpack(operation.args))
    end
  end
end
