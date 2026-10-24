local statusLabels = {
  WAITING_INPUT = "Waiting for valid parent bees",
  WAITING_OUTPUT = "Clear the result slot",
  NO_POWER = "Waiting for electrical power",
  CHARGING = "Charging hybridization coil",
  SUCCESS = "Hybrid queen larva created",
  FAILURE = "Hybridization failed; both bees were lost"
}

local function requestState()
  if not self.pending and not self.closed and world.entityExists(self.containerId) then
    self.pending = world.sendEntityMessage(self.containerId, "fubeesgenetics.hybridizer.getState")
  end
end

function init()
  self = {containerId = pane.containerEntityId(), elapsed = 0, pending = nil, closed = false}
  requestState()
end

function update(dt)
  if self.closed then return end
  if not world.entityExists(self.containerId) then
    self.closed = true
    pane.dismiss()
    return
  end

  self.elapsed = self.elapsed + dt
  if self.pending and self.pending:finished() then
    local result = self.pending:succeeded() and self.pending:result() or nil
    self.pending = nil
    if result then
      widget.setText("status", "Status: " .. (statusLabels[result.status] or "Unavailable"))
      widget.setText("energy", string.format("Energy: %d / %d", math.floor(result.charge), result.capacity))
      widget.setText("power", string.format("Power draw: up to %d W", result.watts or 24))
      widget.setText("chance", result.chance and string.format("Success for these parents: %d%%", math.floor(result.chance * 100 + 0.5))
        or "Success: 30% (10% for rival species)")
      local lastResult = not result.hasResult and "No result yet"
        or (result.succeeded and "Hybrid queen larva created" or "Failed; parent bees consumed")
      widget.setText("result", string.format("Attempts: %d | %s", result.attempts, lastResult))
    else
      widget.setText("status", "Status: machine connection unavailable")
    end
  end
  if self.elapsed >= 2 then
    self.elapsed = self.elapsed % 2
    requestState()
  end
end
