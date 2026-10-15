-- Production ContainerPane Lua with controlled promises and programmatic callbacks.
local traits={'baseProduction','droneToughness','droneBreedRate','queenBreedRate','queenLifespan','mutationChance'}
local count=0
local function test(n,f) f();count=count+1;print('PASS '..n) end
local function state(mode,initialized)
 local s={initialized=initialized~=false,traits={},operationalStatus='WAITING_INPUT',lastResult='NONE'}
 if s.initialized then s.profile={family='honey',subtype=1,subspeciesName='Honey Bee'} end
 for _,t in ipairs(traits) do s.traits[t]={mode=mode or 'gte',referenceDisplay=s.initialized and 0 or nil} end
 if s.initialized then s.traits.mutationChance.referenceDisplay=49.92 end
 return s
end
local function ui(destroyed)
 local u={texts={},selected={},requests={},env={},mouse={-100,-100},helpDraws={},destroyed=destroyed}
 local e=u.env;setmetatable(e,{__index=_G})
 -- WidgetParser names children by numeric ID; ButtonGroup passes that child.
 function u:click(group,id)
  local w=assert(fixture.uiConfig.gui[group])
  for _,b in ipairs(w.buttons) do if b.id==id then
   if self.selected[group]~=id then
    self.selected[group]=id;e.modeChanged(tostring(id),b.data)
   end
   return
  end end
  error('No radio option '..tostring(id))
 end
 e.config={getParameter=function(k) return fixture.uiConfig[k] end}
 local c={}
 function c:clear() u.helpDraws={} end
 function c:mousePosition() return u.mouse end
 function c:drawRect(rect,color) u.helpDraws[#u.helpDraws+1]={rect=rect,color=color} end
 function c:drawText(text,positioning,size,color) u.helpDraws[#u.helpDraws+1]={text=text,positioning=positioning,size=size,color=color} end
 e.pane={containerEntityId=function() return 42 end,dismiss=function() u.dismissed=true end}
 e.widget={setText=function(n,t) u.texts[n]=t end,getSelectedOption=function(n) return u.selected[n] end,
  setSelectedOption=function(n,id) u:click(n,id) end,
  bindCanvas=function(n) assert(n=='helpCanvas');return c end}
 e.world={entityExists=function() return not u.destroyed end,sendEntityMessage=function(id,name,...)
  assert(id==42 and not u.destroyed);local p={name=name,args={...},done=false,ok=true}
  function p:finished() return self.done end
  function p:succeeded() return self.ok end
  function p:result() return self.value end
  function p:resolve(v,ok) self.value=v;self.done=true;self.ok=ok~=false end
  u.requests[#u.requests+1]=p;return p
 end}
 assert(loadfile(fixture.repoRoot..'/FUBeesGenetics/interface/fubeesgenetics/geneticqueenfilter/fubeesgenetics_geneticqueenfilterinterface.lua','t',e))()
 e.init();return u
end
local function boot() local u=ui();u.requests[1]:resolve(state());u.env.update(0);return u end

test('U1 one passive query maximum, immediate initial request',function()
 local u=ui();assert(#u.requests==1);for i=1,10 do u.env.update(.5) end;assert(#u.requests==1)
 u.requests[1]:resolve(state());u.env.update(.5);assert(#u.requests==2)
end)
test('U2 authoritative display accepts zero and formats mutation percent',function()
 local u=boot();assert(u.texts.baseProductionReference=='0' and u.texts.mutationChanceReference=='49.92%')
 assert(u.texts.family=='Family: honey' and u.texts.subspecies=='Subspecies: Honey Bee' and #u.requests==1)
end)
test('U3 mode command restores confirmed radio until reply',function()
 local u=boot();u.selected.baseProductionModes=1;u.env.modeChanged('baseProductionModes')
 assert(u.selected.baseProductionModes==0 and #u.requests==2)
 local p=u.requests[2];assert(p.args[1]=='baseProduction' and p.args[2]=='lte')
 p:resolve(state('lte'));u.env.update(0);assert(u.selected.baseProductionModes==1 and #u.requests==3)
end)
test('U4 old passive reply after command completion is permanently discarded',function()
 local u=boot();u.env.update(.5);local old=u.requests[2]
 u.selected.baseProductionModes=2;u.env.modeChanged('baseProductionModes');u.requests[3]:resolve(state('ignore'));u.env.update(0)
 old:resolve(state('gte'));u.env.update(0);assert(u.selected.baseProductionModes==2)
 u.env.update(.5);u.requests[4]:resolve(state('lte'));u.env.update(0);assert(u.selected.baseProductionModes==1)
end)
test('U5 one mutable command per pane and no revision dependency',function()
 local u=boot();u.selected.baseProductionModes=1;u.env.modeChanged('baseProductionModes')
 u.selected.baseProductionModes=2;u.env.modeChanged('baseProductionModes');u.env.resetProfile();u.env.update(2)
 assert(#u.requests==2);u.requests[2]:resolve(state('lte'));u.env.update(0)
 assert(u.selected.baseProductionModes==1 and not u.env.self.latestRevision and not u.env.self.state.revision)
end)
test('U6 Reset waits for authoritative empty state and preserves local physical handling',function()
 local u=boot();u.env.resetProfile();assert(#u.requests==2 and #u.requests[2].args==0)
 assert(u.texts.family=='Family: honey');u.requests[2]:resolve(state('gte',false));u.env.update(0)
 assert(u.texts.family=='Family: —' and u.texts.baseProductionReference=='—')
end)
test('U7 transient failed promise retries instead of assuming entity destroyed',function()
 local u=ui();u.requests[1]:resolve(nil,false);u.env.update(.5)
 assert(u.texts.status:find('Connection unavailable',1,true) and #u.requests==2 and not u.dismissed)
 u.requests[2]:resolve(state());u.env.update(0);assert(u.texts.status=='Status: Waiting for input')
end)
test('U8 unknown controls, no snapshot and invalid selection do not issue mutations',function()
 local u=ui();u.selected.baseProductionModes=1;u.env.modeChanged('baseProductionModes');u.env.modeChanged('fake');assert(#u.requests==1)
 u.requests[1]:resolve(state());u.env.update(0);u.selected.baseProductionModes=99;u.env.modeChanged('baseProductionModes');assert(#u.requests==1)
end)
test('U9 all selectors map exclusive radio options to allowed modes',function()
 for _,t in ipairs(traits) do local u=boot();u.selected[t..'Modes']=2;u.env.modeChanged(t..'Modes')
  assert(u.requests[2].args[1]==t and u.requests[2].args[2]=='ignore') end
end)
test('U10 independent panes converge after authoritative refresh',function()
 local a,b=boot(),boot();a.env.update(.5);b.env.update(.5)
 a.requests[2]:resolve(state('lte'));b.requests[2]:resolve(state('lte'));a.env.update(0);b.env.update(0)
 assert(a.selected.queenLifespanModes==1 and b.selected.queenLifespanModes==1)
end)
test('U11 operational status and last result are independent',function()
 local u=ui();local s=state();s.operationalStatus='WAITING_OUTPUTS';s.lastResult='APPROVED'
 u.requests[1]:resolve(s);u.env.update(0);assert(u.texts.lastResult=='Last result: Approved')
 assert(u.texts.status=='Status: Waiting for outputs to be cleared')
end)
test('U12 all MD hover help regions show correct text after delay without messages',function()
 for _,r in ipairs(fixture.uiConfig.helpRegions) do local u=boot();u.mouse={r.rect[1]+1,r.rect[2]+1}
  u.env.update(0);assert(#u.helpDraws==0);u.env.update(.36)
  assert(u.helpDraws[3].text==fixture.uiConfig.helpTexts[r.key] and #u.requests==1) end
end)
test('U13 tooltip clears over native slots and outside pane',function()
 for _,p in ipairs({{72,47},{192,47},{312,47},{400,400},{-1,-1}}) do
  local u=boot();u.mouse={260,218};u.env.update(0);u.env.update(.36);assert(#u.helpDraws==3)
  u.mouse=p;u.env.update(0);assert(#u.helpDraws==0)
 end
 local u=boot();u.mouse=nil;u.env.update(.36);assert(#u.helpDraws==0)
end)
test('U14 tooltip stays in pane and comparator change restarts delay',function()
 local u=boot();u.mouse={340,108};u.env.update(0);u.env.update(.36);local r=u.helpDraws[1].rect
 assert(r[1]>=0 and r[2]>=0 and r[3]<=388 and r[4]<=332)
 u.mouse={302,108};u.env.update(0);assert(#u.helpDraws==0);u.env.update(.36);assert(u.helpDraws[3].text==fixture.uiConfig.helpTexts.lte)
end)
test('U15 destroyed entity clears view, closes and stops commands and reads',function()
 local u=boot();u.destroyed=true;u.env.update(0);assert(u.dismissed and not u.env.self.state and u.texts.family=='Family: —')
 u.env.resetProfile();u.selected.baseProductionModes=1;u.env.modeChanged('baseProductionModes');u.env.update(1);assert(#u.requests==1)
 local gone=ui(true);gone.env.update(0);assert(gone.dismissed and #gone.requests==0)
end)
test('U16 recovery status is visible and preserves lastResult display',function()
 local u=ui();local s=state();s.operationalStatus='RECOVERY_HOLD';s.lastResult='APPROVED'
 u.requests[1]:resolve(s);u.env.update(0)
 assert(u.texts.status=='Status: Recovery pending — preserving item' and u.texts.lastResult=='Last result: Approved')
end)
test('U17 modes work before baseline; failed command resumes passive polling',function()
 local u=ui();u.requests[1]:resolve(state('gte',false));u.env.update(0)
 u.selected.baseProductionModes=2;u.env.modeChanged('baseProductionModes');assert(#u.requests==2)
 u.requests[2]:resolve(nil,false);u.env.update(0);assert(#u.requests==3 and not u.env.self.pendingCommand)
end)
test('U18 numeric child callback identifies each row for every comparator',function()
 for _,trait in ipairs(traits) do for id,mode in pairs({[0]='gte',[1]='lte',[2]='ignore'}) do
  local u=ui();u.requests[1]:resolve(state(id==0 and 'lte' or 'gte'));u.env.update(0)
  u:click(trait..'Modes',id)
  assert(#u.requests==2,'Numeric child callback did not send a command for '..trait)
  local p=u.requests[2]
  assert(p.name=='fubeesgenetics.gqf.setMode' and p.args[1]==trait and p.args[2]==mode)
  local reply=state(id==0 and 'lte' or 'gte');reply.traits[trait].mode=mode
  p:resolve(reply);u.env.update(0);assert(u.selected[trait..'Modes']==id)
  for _,other in ipairs(traits) do if other~=trait then
   assert(u.selected[other..'Modes']==(id==0 and 1 or 0))
  end end
  u.requests[3]:resolve(reply);u.env.update(.5)
  assert(u.selected[trait..'Modes']==id and #u.requests==4)
 end end
end)
test('U19 malformed child metadata cannot issue a mode command',function()
 local u=boot()
 for _,data in ipairs({false,'bad',{}, {modeGroup='fake'},{modeGroup=1}}) do u.env.modeChanged('1',data) end
 u.env.modeChanged('2');assert(#u.requests==1)
end)
test('U20 numeric child command survives stale reads and stays selected after reopen',function()
 local u=boot();u.env.update(.5);local stale=u.requests[2]
 u:click('mutationChanceModes',2);assert(#u.requests==3)
 local confirmed=state();confirmed.traits.mutationChance.mode='ignore'
 u.requests[3]:resolve(confirmed);u.env.update(0)
 stale:resolve(state());u.env.update(0);assert(u.selected.mutationChanceModes==2)
 u.env.update(.5);u.requests[4]:resolve(confirmed);u.env.update(0)
 assert(u.selected.mutationChanceModes==2)
 local reopened=ui();reopened.requests[1]:resolve(confirmed);reopened.env.update(0)
 assert(reopened.selected.mutationChanceModes==2 and #reopened.requests==1)
end)
print('Interface: '..count..' test groups passed (engine bindings mocked).')
