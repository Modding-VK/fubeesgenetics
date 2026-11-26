require "/monsters/monster.lua"

local baseInit, baseUpdate = init, update
local untilBuzz
local stingerElement, stingerTint, stingerPower, swarmScale, untilStinger
local tints = {
  fire = "ff7845", ice = "92def8", hoarfrost = "c3f3ff", electric = "f5e76b",
  poison = "9fe85e", bioweapon = "f472a3", shadow = "9c81ef",
  cosmic = "f1a4ff", radioactive = "bcf552"
}
-- Coordinates are forward and lateral to the target, in blocks at base size.
local formations = {
  {{0.80, 0}},
  {{0.66, -0.28}, {0.66, 0.28}},
  {{0.60, -0.43}, {0.86, 0}, {0.60, 0.43}},
  {{0.53, -0.56}, {0.76, -0.19}, {0.76, 0.19}, {0.53, 0.56}}
}

local function fireStingers()
  if status.resourcePositive("stunned") then return false end
  local target = self.board:getEntity("target")
  if not target or not entity.isValidTarget(target) then return false end
  local targetPosition = world.entityPosition(target)
  if not targetPosition then return false end
  local origin = mcontroller.position()
  local delta = world.distance(targetPosition, origin)
  local distanceSquared = delta[1] * delta[1] + delta[2] * delta[2]
  if distanceSquared < 9 or distanceSquared > 324 or world.lineTileCollision(origin, targetPosition) then
    return false
  end

  local length = math.sqrt(distanceSquared)
  local dx, dy = delta[1] / length, delta[2] / length
  local formation = formations[math.random(1, #formations)]
  local parameters = {
    damageKind = stingerElement,
    power = stingerPower * status.stat("powerMultiplier") / #formation,
    processing = stingerTint
  }
  local source = entity.id()
  local fired = false
  for _, offset in ipairs(formation) do
    local forward, lateral = offset[1] * swarmScale, offset[2] * swarmScale
    local muzzle = {origin[1] + dx * forward - dy * lateral, origin[2] + dy * forward + dx * lateral}
    if not world.lineTileCollision(origin, muzzle) then
      local aim = world.distance(targetPosition, muzzle)
      if world.spawnProjectile("fubeesgenetics_swarmstinger", muzzle, source, aim, false, parameters) then
        fired = true
      end
    end
  end
  return fired
end

function init()
  baseInit()
  animator.setSoundPool("swarmBuzz", config.getParameter("swarmCybernetic")
    and {"/sfx/projectiles/bugswarm1.ogg", "/sfx/projectiles/bugswarm2.ogg",
      "/sfx/projectiles/bugswarm3.ogg", "/sfx/projectiles/bugswarm4.ogg"}
    or {"/sfx/npc/monsters/fubee.ogg"})
  untilBuzz = math.random(10, 60)
  local touch = config.getParameter("touchDamage")
  stingerElement = touch and touch.damageSourceKind
  if tints[stingerElement] then
    stingerTint = "?setcolor=" .. tints[stingerElement]
    swarmScale = config.getParameter("scale", 1)
    local levelMultiplier = root.evalFunction(
      config.getParameter("powerLevelFunction", "monsterLevelPowerMultiplier"), monster.level())
    stingerPower = touch.damage * config.getParameter("touchDamageMultiplier", 1) * levelMultiplier * 0.5
    untilStinger = math.random(4, 6)
  else
    untilStinger = nil
  end
end

function update(dt)
  baseUpdate(dt)
  if capturable.despawnTimer or capturable.justCaptured or not status.resourcePositive("health") then return end
  untilBuzz = untilBuzz - dt
  if untilBuzz <= 0 then
    animator.playSound("swarmBuzz")
    untilBuzz = math.random(10, 60)
  end
  if not untilStinger then return end
  untilStinger = untilStinger - dt
  if untilStinger <= 0 then untilStinger = fireStingers() and math.random(4, 6) or 1 end
end
