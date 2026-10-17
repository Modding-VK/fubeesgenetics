local traits = {
  "baseProduction", "droneToughness", "droneBreedRate",
  "queenBreedRate", "queenLifespan", "mutationChance"
}
local modeToId = {gte = 0, lte = 1, ignore = 2}
local idToMode = {[0] = "gte", [1] = "lte", [2] = "ignore"}
local statuses = {
  WAITING_INPUT = "Waiting for input", WAITING_OUTPUTS = "Waiting for outputs to be cleared",
  RECOVERY_HOLD = "Recovery pending — preserving item",
  PROCESSING = "Processing..."
}
local results = {
  NONE = "—", PROFILE_INITIALIZED = "Genetic profile initialized", APPROVED = "Approved",
  REJECTED_INVALID_ITEM = "Rejected — invalid item",
  REJECTED_NOT_INSPECTED = "Rejected — genome not inspected",
  REJECTED_INVALID_GENOME = "Rejected — invalid genome",
  REJECTED_INCOMPATIBLE_SUBSPECIES = "Rejected — incompatible subspecies",
  REJECTED_GENETIC_CRITERIA = "Rejected — genetic criteria"
}

local function updateHelp(dt)
  local canvas = self.helpCanvas
  canvas:clear()
  local pos, key = canvas:mousePosition(), nil
  if pos then
    for _, region in ipairs(self.helpRegions) do
      local r = region.rect
      if pos[1] >= r[1] and pos[1] < r[3] and pos[2] >= r[2] and pos[2] < r[4] then
        key = region.key; break
      end
    end
  end
  if key ~= self.helpKey then self.helpKey, self.helpElapsed = key, 0
  else self.helpElapsed = self.helpElapsed + dt end
  if not key or self.helpElapsed < 0.35 then return end
  local w, h = 260, 44
  local x = math.max(6, math.min(self.helpSize[1] - w - 6, pos[1] + 12))
  local y = math.max(6, math.min(self.helpSize[2] - h - 6, pos[2] - h - 12))
  canvas:drawRect({x,y,x+w,y+h}, "#526978")
  canvas:drawRect({x+1,y+1,x+w-1,y+h-1}, "#1b2b35")
  canvas:drawText(self.helpTexts[key], {position={x+7,y+h-7}, horizontalAnchor="left",
    verticalAnchor="top", wrapWidth=w-14}, 7, "#dbeef4")
end

local function requestState()
  if not self.pendingRead and not self.pendingCommand and not self.closed then
    self.pendingRead = world.sendEntityMessage(self.containerId, "fubeesgenetics.gqf.getState")
  end
end

local function render(state)
  if type(state) ~= "table" then return end
  self.state = state
  self.rendering = true
  local profile = state.profile or {}
  widget.setText("family", "Family: " .. (profile.family or "—"))
  widget.setText("subspecies", "Subspecies: " .. (profile.subspeciesName or "—"))
  for _, trait in ipairs(traits) do
    local entry = state.traits[trait]
    local display = "—"
    if entry.referenceDisplay ~= nil then
      display = trait == "mutationChance" and string.format("%.2f%%", entry.referenceDisplay)
        or tostring(entry.referenceDisplay)
    end
    widget.setText(trait .. "Reference", display)
    widget.setSelectedOption(trait .. "Modes", modeToId[entry.mode])
  end
  widget.setText("status", "Status: " .. (statuses[state.operationalStatus] or "—"))
  widget.setText("lastResult", "Last result: " .. (results[state.lastResult] or "—"))
  self.rendering = false
end

local function receive(promise)
  if promise:succeeded() then
    render(promise:result())
  else
    widget.setText("status", "Status: Connection unavailable; retrying...")
  end
end

local function command(name, ...)
  if self.closed or self.pendingCommand then return end
  self.discardRead = self.pendingRead ~= nil
  self.pendingCommand = world.sendEntityMessage(self.containerId, name, ...)
end

function init()
  self = {containerId = pane.containerEntityId(),
    elapsed = 0, rendering = false, traitByWidget = {}}
  self.helpCanvas = widget.bindCanvas("helpCanvas")
  self.helpSize = config.getParameter("gui").helpCanvas.size
  self.helpTexts, self.helpRegions = config.getParameter("helpTexts"), config.getParameter("helpRegions")
  self.helpElapsed = 0
  for _, trait in ipairs(traits) do self.traitByWidget[trait .. "Modes"] = trait end
  if world.entityExists(self.containerId) then requestState() end
end

local function alive()
  if self.closed then return false end
  if world.entityExists(self.containerId) then return true end
  self.closed, self.state, self.pendingRead, self.pendingCommand = true, nil, nil, nil
  self.helpCanvas:clear()
  for _, trait in ipairs(traits) do widget.setText(trait .. "Reference", "—") end
  widget.setText("family", "Family: —")
  widget.setText("subspecies", "Subspecies: —")
  widget.setText("lastResult", "Last result: —")
  widget.setText("status", "Status: Machine unavailable")
  pane.dismiss()
  return false
end

function update(dt)
  if not alive() then return end
  updateHelp(dt)
  if self.pendingRead and self.pendingRead:finished() then
    local promise = self.pendingRead
    self.pendingRead = nil
    if not self.discardRead and not self.pendingCommand then receive(promise) end
    self.discardRead = false
  end
  local completed = false
  if self.pendingCommand and self.pendingCommand:finished() then
    local promise = self.pendingCommand
    self.pendingCommand = nil
    receive(promise)
    completed = true
  end
  self.elapsed = self.elapsed + dt
  if completed or self.elapsed >= 0.5 then
    self.elapsed = self.elapsed % 0.5
    requestState()
  end
end

function modeChanged(widgetName, widgetData)
  if self.rendering or not alive() then return end
  -- Native radio callbacks identify the numeric child, not its parent group.
  local groupName = type(widgetData) == "table" and widgetData.modeGroup or widgetName
  local trait = self.traitByWidget[groupName]
  if not trait then return end
  local selected = widget.getSelectedOption(groupName)
  -- Restore the confirmed selection until the server replies with authority.
  self.rendering = true
  widget.setSelectedOption(groupName, self.state and modeToId[self.state.traits[trait].mode] or 0)
  self.rendering = false
  if self.state and idToMode[selected] then
    command("fubeesgenetics.gqf.setMode", trait, idToMode[selected])
  end
end

function resetProfile()
  if not alive() then return end
  command("fubeesgenetics.gqf.resetProfile")
end
