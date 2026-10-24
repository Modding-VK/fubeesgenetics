local statusLabels = {
  WAITING_INPUT = "Waiting for valid parent bees",
  WAITING_OUTPUT = "Clear the result slot",
  NO_POWER = "Waiting for electrical power",
  IN_PROGRESS = "Experiment in progress",
  SUCCESS = "Hybrid queen larva created",
  FAILURE = "Hybridization failed; both bees were lost"
}

local function requestState()
  if not self.pending and not self.closed then
    self.pending = world.sendEntityMessage(self.containerId, "fubeesgenetics.hybridizer.getState")
  end
end

local function setText(name, value)
  if self.textValues[name] ~= value then
    self.textValues[name] = value
    widget.setText(name, value)
  end
end

function init()
  self = {containerId = pane.containerEntityId(), elapsed = 0, pending = nil, closed = false,
    textValues = {warning = ""}}
  if world.entityExists(self.containerId) then requestState() end
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
      setText("status", "Status: " .. (statusLabels[result.status] or "Unavailable"))
      setText("warning", result.reworkAlert and "WARNING: New specimen; rework cost 50% progress" or "")
      setText("energy", string.format("Experiment progress: %d / %d", math.floor(result.progress), result.requiredProgress))
      setText("power", string.format("Power draw: up to %d W", result.watts or 24))
      setText("chance", result.chance and string.format("Success for these parents: %d%%", math.floor(result.chance * 100 + 0.5))
        or "Success: 30% (10% for rival species)")
      local lastResult = not result.hasResult and "No result yet"
        or (result.succeeded and "Hybrid queen larva created" or "Failed; parent bees consumed")
      setText("result", string.format("Attempts: %d | %s", result.attempts, lastResult))
    else
      setText("status", "Status: machine connection unavailable")
    end
  end
  if self.elapsed >= 2 then
    self.elapsed = self.elapsed % 2
    requestState()
  end
end
