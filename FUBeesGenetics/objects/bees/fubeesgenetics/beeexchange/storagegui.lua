-- Loaded only in this machine's resolved IC window, after the IC GUI script.
-- Obtain a server acknowledgement BEFORE sorting or writing quick-stack items.
local icUpdate = update
local pending
local function guarded(action)
  return function(...)
    if pending then return end
    pending = {request = world.sendEntityMessage(pane.containerEntityId(),
      "fubeesgenetics.storageLock"), action = action, args = {...}}
  end
end
ic.sortAction = guarded(ic.sortAction)
ic.quickstackAction = guarded(ic.quickstackAction)
function update(dt)
  icUpdate(dt)
  if pending and pending.request:finished() then
    local operation = pending
    pending = nil
    if operation.request:result() == true then
      operation.action(table.unpack(operation.args))
    end
  end
end
