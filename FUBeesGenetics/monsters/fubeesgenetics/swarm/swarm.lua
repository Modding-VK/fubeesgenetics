require "/monsters/monster.lua"

local baseInit, baseUpdate = init, update
local untilBuzz

function init()
  baseInit()
  animator.setSoundPool("swarmBuzz", config.getParameter("swarmCybernetic")
    and {"/sfx/projectiles/bugswarm1.ogg", "/sfx/projectiles/bugswarm2.ogg",
      "/sfx/projectiles/bugswarm3.ogg", "/sfx/projectiles/bugswarm4.ogg"}
    or {"/sfx/npc/monsters/fubee.ogg"})
  untilBuzz = math.random(10, 60)
end

function update(dt)
  baseUpdate(dt)
  if capturable.despawnTimer or capturable.justCaptured or not status.resourcePositive("health") then return end
  untilBuzz = untilBuzz - dt
  if untilBuzz > 0 then return end
  animator.playSound("swarmBuzz")
  untilBuzz = math.random(10, 60)
end
