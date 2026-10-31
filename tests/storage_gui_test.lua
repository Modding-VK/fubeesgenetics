-- Test the addon acknowledgement bridge; this does not replace original IC tests.
local passed=0
local function test(name,fn) fn();passed=passed+1;print('PASS SG'..passed..' '..name) end
local function setup(machine,withIC)
  local u={providerUpdates=0,actions=0,requests={}}
  local e=setmetatable({}, {__index=_G});u.env=e
  local originalAction=function(...) u.actions=u.actions+1;u.args={...} end
  e.ic=withIC and {version=2,sortAction=originalAction,quickstackAction=originalAction} or nil
  e.init=function() u.providerInitialized=true end
  local providerUpdate=function() u.providerUpdates=u.providerUpdates+1 end
  e.update=providerUpdate;u.providerUpdate=providerUpdate;u.originalAction=originalAction
  assert(loadfile(fixture.repoRoot..'/FUBeesGenetics/objects/bees/fubeesgenetics/beeexchange/storagegui.lua','t',e))()
  e.pane={containerEntityId=function() return 42 end}
  e.world={entityName=function() return machine and 'fubeesgenetics_beeexchange' or 'other_container' end,
    sendEntityMessage=function(id,name)
      assert(id==42 and name=='fubeesgenetics.storageLock')
      local p={};function p:finished() return self.done end;function p:result() return self.value end
      u.requests[#u.requests+1]=p;return p
    end}
  e.init();assert(u.providerInitialized);return u
end
test('unrelated containers retain the original provider update and actions',function()
  local u=setup(false,true);assert(u.env.update==u.providerUpdate)
  assert(u.env.ic.sortAction==u.originalAction)
  for i=1,10 do u.env.update(.1) end
  assert(u.providerUpdates==10 and #u.requests==0)
end)
test('Bee Exchange waits for lock acknowledgement and preserves action arguments',function()
  local u=setup(true,true);u.env.ic.sortAction('alpha',7);u.env.ic.quickstackAction('ignored')
  assert(#u.requests==1 and u.actions==0)
  u.env.update(.1);assert(u.actions==0 and u.providerUpdates==1)
  u.requests[1].done,u.requests[1].value=true,true;u.env.update(.1)
  assert(u.actions==1 and u.args[1]=='alpha' and u.args[2]==7)
  u.env.ic.quickstackAction('next');assert(#u.requests==2)
end)
test('negative acknowledgement releases the guard without invoking the action',function()
  local u=setup(true,true);u.env.ic.sortAction()
  u.requests[1].done,u.requests[1].value=true,false;u.env.update(.1);assert(u.actions==0)
  u.env.ic.sortAction();assert(#u.requests==2)
  local foreign=setup(false,false);assert(foreign.env.update==foreign.providerUpdate)
end)
print('Storage GUI: '..passed..' test groups passed (engine bindings mocked).')
