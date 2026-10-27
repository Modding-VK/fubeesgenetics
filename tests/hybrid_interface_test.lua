-- Production pane with deterministic promises and widget/binding counters.
local passed = 0
local function test(name, fn) fn(); passed = passed + 1; print('PASS HU' .. passed .. ' ' .. name) end
local function state()
  return {status='IN_PROGRESS',progress=24,requiredProgress=10000,watts=24,chance=.3,
    hasResult=false,attempts=0}
end
local function pane()
  local u={requests={},texts={},writes=0,exists=0}
  local e=setmetatable({}, {__index=_G});u.env=e
  e.pane={containerEntityId=function() return 42 end,dismiss=function() u.dismissed=true end}
  e.widget={setText=function(key,value) u.writes=u.writes+1;u.texts[key]=value end}
  e.world={entityExists=function(id) assert(id==42);u.exists=u.exists+1;return not u.gone end,
    sendEntityMessage=function(id,name)
      assert(id==42 and name=='fubeesgenetics.hybridizer.getState')
      local p={}
      function p:finished() return self.done end
      function p:succeeded() return self.ok end
      function p:result() return self.value end
      function p:resolve(value,ok) self.done,self.value,self.ok=true,value,ok~=false end
      u.requests[#u.requests+1]=p;return p
    end}
  assert(loadfile(fixture.repoRoot..'/FUBeesGenetics/interface/fubeesgenetics/hybridizer/hybridizerinterface.lua','t',e))()
  e.init();return u
end
test('one pending query maximum and two-second polling',function()
  local u=pane();for i=1,20 do u.env.update(.25) end;assert(#u.requests==1)
  u.requests[1]:resolve(state());u.env.update(0);assert(#u.requests==1)
  u.env.update(1);assert(#u.requests==2)
end)
test('identical snapshots do not rewrite widgets',function()
  local u=pane();u.requests[1]:resolve(state());u.env.update(0);assert(u.writes==5)
  u.env.update(2);u.requests[2]:resolve(state());u.env.update(0);assert(u.writes==5)
  u.env.update(2);local nextState=state();nextState.progress=48
  u.requests[3]:resolve(nextState);u.env.update(0);assert(u.writes==6)
end)
test('fractional rival disc bonus is shown without rounding away half percent',function()
  local u=pane();local nextState=state();nextState.chance=.125;nextState.bonus=.025
  u.requests[1]:resolve(nextState);u.env.update(0)
  assert(u.texts.chance=='Success: 12.5% (+2.5% disc)')
end)
test('failed reply recovers the status even when all other fields stay equal',function()
  local u=pane();u.requests[1]:resolve(state());u.env.update(0)
  u.env.update(2);u.requests[2]:resolve(nil,false);u.env.update(0)
  assert(u.texts.status:find('unavailable',1,true))
  u.env.update(2);u.requests[3]:resolve(state());u.env.update(0)
  assert(u.texts.status=='Status: Experiment in progress')
end)
test('polling does not repeat the same entity-existence query',function()
  local u=pane();assert(u.exists==1)
  u.requests[1]:resolve(state());u.env.update(2)
  assert(u.exists==2 and #u.requests==2)
end)
test('destroyed machine dismisses the pane and stops polling',function()
  local u=pane();u.gone=true;u.env.update(0);assert(u.dismissed)
  for i=1,20 do u.env.update(2) end;assert(#u.requests==1)
end)
print('Hybrid interface: '..passed..' test groups passed (engine bindings mocked).')
