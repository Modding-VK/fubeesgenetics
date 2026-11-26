local statusLabels = {
  READY = "Ready to encapsulate", QUEEN = "Insert an adult Queen with a valid genome.",
  DRONES = "At least 1,000 matching Drones are required.",
  POD = "Insert an empty Capture Pod.", CHIP = "Insert an A.I. Chip.",
  OUTPUT = "Clear the output slot.", WORKING = "Encapsulating swarm...",
  RECOVERY = "Clear the input slots to recover the reserved items."
}
local arrow = "/interface/catalystfuelrefinery/arrowfull.png?scalenearest=4;2?setcolor=ffaf4d"
local cache, pending, current, containerId, elapsed, queued

local function setText(name, value)
  if cache[name] == value then return end
  widget.setText(name, value)
  cache[name] = value
end

local function render(state)
  current = state
  local p = state.preview
  local ready = state.status == "READY"
  if cache.ready ~= ready then widget.setButtonEnabled("encapsulate", ready); cache.ready = ready end
  setText("status", statusLabels[state.status] or "Machine unavailable.")
  setText("drones", p and string.format("Drones: %d | Batch: %d", state.count, p.tier * 1000)
    or string.format("Drones: %d / 1000", state.count))
  setText("size", p and string.format("Size: %d%% | Bonus: +%d%%", math.floor(p.scale * 100 + 0.5),
    (p.tier - 1) * 10) or "Size: —")
  setText("damage", p and string.format("Damage: %g", p.damage) or "Damage: —")
  setText("health", p and string.format("Health: %g HP", p.health) or "Health: —")
  setText("armor", p and string.format("Armor: %g", p.armor) or "Armor: —")
  setText("speed", p and string.format("Speed: %g blocks/s", p.speed) or "Speed: —")
  setText("regen", p and string.format("Regen: %g HP/s", p.regen) or "Regen: —")
  setText("element", p and p.elementName or "—")
  setText("petName", p and p.name or "")
  if cache.element ~= (p and p.element or "") then
    cache.element = p and p.element or ""
    if p then widget.setImage("elementIcon", "/interface/elements/" .. p.element .. ".png") end
    widget.setVisible("elementIcon", p ~= nil)
  end
  local pixels = math.floor(state.progress * 40)
  if cache.pixels ~= pixels then
    if pixels > 0 then widget.setImage("arrowFill", arrow .. string.format("?crop=0;0;%d;22", pixels)) end
    widget.setVisible("arrowFill", pixels > 0)
    cache.pixels = pixels
  end
  setText("time", state.seconds > 0 and (state.seconds .. " s") or "")
end

function init()
  cache, elapsed = {}, 1
  containerId = pane.containerEntityId()
  widget.setButtonEnabled("encapsulate", false)
  widget.setVisible("arrowFill", false)
  widget.setVisible("elementIcon", false)
end

function encapsulate()
  if not current or current.status ~= "READY" or not cache.ready then return end
  widget.setButtonEnabled("encapsulate", false)
  cache.ready = false
  queued = current.preview
end

function update(dt)
  if not world.entityExists(containerId) then pane.dismiss(); return end
  elapsed = elapsed + dt
  if pending and pending:finished() then
    if pending:succeeded() and pending:result() then render(pending:result()) end
    pending = nil
  end
  if not pending and queued then
    pending = world.sendEntityMessage(containerId, "fubeesgenetics.swarm.encapsulate", queued)
    queued = nil
  elseif not pending and elapsed >= 1 then
    elapsed = 0
    pending = world.sendEntityMessage(containerId, "fubeesgenetics.swarm.getState")
  end
end
