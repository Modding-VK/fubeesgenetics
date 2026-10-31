local statusLabels = {
  WAITING_INPUT = "Waiting for valid parent bees",
  WAITING_OUTPUT = "Clear the result slot",
  NO_POWER = "Waiting for electrical power",
  IN_PROGRESS = "Experiment in progress",
  SUCCESS = "Hybrid queen larva created",
  FAILURE = "Hybridization failed; both bees were lost"
}
local discHints = {
  "/items/active/unsorted/researchvoxel/researchvoxelsmall.png?multiply=ffffff33",
  "/items/active/unsorted/researchvoxel/researchvoxel.png?multiply=ffffff33",
  "/items/active/unsorted/researchvoxel/researchvoxellarge.png?multiply=ffffff33"
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

local function percent(value)
  return string.format("%g", math.floor(value * 1000 + 0.5) / 10)
end

local function updateDiscHint()
  local image = not self.discPresent and discHints[self.discHintPhase] or nil
  if image == self.discHintImage then return end
  self.discHintImage = image
  if image then
    widget.setImage("discHint", image)
    widget.setVisible("discHint", true)
  else
    widget.setVisible("discHint", false)
  end
end

function init()
  self = {containerId = pane.containerEntityId(), elapsed = 0, pending = nil, closed = false,
    textValues = {warning = ""}, discPresent = true, discHintPhase = 1}
  widget.setVisible("discHint", false)
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
      local chanceText = "Success: " .. percent(result.normalChance or 0.3)
        .. "% (" .. percent(result.rivalChance or 0.1) .. "% for rival species)"
      if not result.discBonus or result.discBonus <= 0 then chanceText = chanceText .. " - Add disc for bonus" end
      setText("chance", chanceText)
      self.discPresent = result.discPresent == true
      updateDiscHint()
      local lastResult = not result.hasResult and "No result yet"
        or (result.succeeded and "Hybrid queen larva created" or "Failed; parent bees consumed")
      setText("result", string.format("Attempts: %d | %s", result.attempts, lastResult))
    else
      setText("status", "Status: machine connection unavailable")
    end
  end
  if self.elapsed >= 2 then
    self.elapsed = self.elapsed % 2
    self.discHintPhase = self.discHintPhase % 4 + 1
    updateDiscHint()
    requestState()
  end
end
