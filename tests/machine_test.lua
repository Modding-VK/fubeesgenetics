-- Production controller and pinned FU libraries, with fault-injectable engine bindings.
local function copy(x)
  if type(x) ~= 'table' then return x end
  local r={};for k,v in pairs(x) do r[k]=copy(v) end;return r
end
local function same(a,b)
  if type(a)~=type(b) then return false end
  if type(a)~='table' then return a==b end
  for k,v in pairs(a) do if not same(v,b[k]) then return false end end
  for k in pairs(b) do if a[k]==nil then return false end end;return true
end
local traits={'baseProduction','droneToughness','droneBreedRate','queenBreedRate','queenLifespan','mutationChance'}
local slots,handlers,reads,drops,faults,logs,adapterReads,spawnCalls,serialized
root={assetJson=function(p)
  if p=='/bees/beeData.config' then return fixture.beeData end
  assert(p=='/items/defaultParameters.config');return {defaultMaxStack=1000}
end,itemHasTag=function(n,t) return fixture.tags[n] and fixture.tags[n][t] or false end}
entity={id=function() return 42 end,position=function() return {10,20} end,entityType=function() return 'object' end}
config={getParameter=function() return nil end}
sb={logInfo=function() end,logWarn=function(s,...) logs[#logs+1]={level='warn',text=string.format(s,...)} end,
 logError=function(s,...) logs[#logs+1]={level='error',text=string.format(s,...)} end,
 printJson=function(x) serialized[#serialized+1]=copy(x);return 'FULL_DESCRIPTOR' end}
message={setHandler=function(n,f) handlers[n]=f end}
world={
 containerItemAt=function(id,s)
  assert(id==42);reads[s]=(reads[s] or 0)+1
  if faults.onRead then faults.onRead(s,reads[s]) end
  return copy(slots[s])
 end,
 containerTakeNumItemsAt=function(id,s,n)
  assert(id==42 and s==0 and n==1)
  if faults.noTake or not slots[s] then return nil end
  local item=copy(slots[s]);item.count=1
  slots[s].count=slots[s].count-1;if slots[s].count==0 then slots[s]=nil end
  if faults.afterTake then faults.afterTake(item) end;return item
 end,
 containerPutItemsAt=function(id,item,s)
  assert(id==42)
  if (s~=0 and faults.failOutput) or (s==0 and faults.failInput) then return copy(item) end
  if slots[s] then
   local a,b=copy(item),copy(slots[s]);a.count=nil;b.count=nil
   if not same(a,b) then return copy(item) end
   slots[s].count=slots[s].count+item.count
  else slots[s]=copy(item) end
  return faults.legacyPutReturn and copy(item) or nil
 end,
 spawnItem=function(item)
  spawnCalls=spawnCalls+1
  if faults.spawnError then error('injected spawn failure') end
  if faults.spawnNil then
   if faults.afterSpawnFailure then faults.afterSpawnFailure() end;return nil
  end
  if faults.spawnInvalid then return false end
  drops[#drops+1]=copy(item);return 123
 end}
require=function(p)
 if p=='/scripts/util.lua' then util={};return end
 if p=='/bees/genomeLibrary.lua' then if not genelib then dofile(fixture.fuRoot..p) end;return end
 if p=='/scripts/kheAA/transferUtil.lua' then dofile(fixture.fuRoot..p);return end
 assert(p:match('^/scripts/fubeesgenetics/'))
 dofile(fixture.repoRoot..'/FUBeesGenetics'..p)
end
local engineRoot = root
root = nil
dofile(fixture.repoRoot..'/FUBeesGenetics/objects/bees/fubeesgenetics/geneticqueenfilter/fubeesgenetics_geneticqueenfilter.lua')
root = engineRoot
local originalRead=fubeesgenetics_beegeneticadapter.read
fubeesgenetics_beegeneticadapter.read=function(x) adapterReads=adapterReads+1;return originalRead(x) end
local function fresh(saved)
 storage=copy(saved or {});slots={};handlers={};reads={};drops={};faults={};logs={};serialized={};adapterReads=0;spawnCalls=0
 transferUtil.vars=nil;init()
end
local function call(n,...) return handlers['fubeesgenetics.gqf.'..n](nil,nil,...) end
local function bee(values,caste,subtype,family)
 local g=genelib.numberToStat(subtype or 1)
 for _,t in ipairs(traits) do g=g..genelib.numberToStat(values and values[t] or 100) end
 return {name='bee_'..(family or 'honey')..'_'..(caste or 'youngQueen'),count=1,
  parameters={genome=g..'0000',genomeInspected=true,wild=true,lifespan=17,custom={unchanged=true}}}
end
local function tick(q) slots[1],slots[2]=nil,nil;slots[0]=copy(q);update(1) end
local function baseline() fresh();tick(bee());slots[1]=nil end
local count=0
local function test(n,f) f();count=count+1;print('PASS '..n) end

test('M1 defaults and real FU transferUtil registration',function()
 fresh();assert(storage.lastResult=='NONE' and storage.operationalStatus=='WAITING_INPUT')
 for _,t in ipairs(traits) do assert(storage.modes[t]=='gte') end
 assert(transferUtil.vars.didInit and transferUtil.vars.inContainers[42] and transferUtil.vars.outContainers[42])
end)
test('M2 first valid baseline stores ignored raw traits and preserves configured modes',function()
 fresh();call('setMode','mutationChance','ignore');tick(bee())
 assert(storage.lastResult=='PROFILE_INITIALIZED' and slots[1] and storage.modes.mutationChance=='ignore')
 for _,t in ipairs(traits) do assert(storage.references[t]==100) end
end)
test('M3 eligibility failures never initialize genetic state',function()
 for _,c in ipairs({'drone','fakequeen'}) do fresh();tick(bee(nil,c));assert(slots[2] and not storage.profile) end
 fresh();local q=bee();q.parameters.genomeInspected=false;tick(q);assert(storage.lastResult=='REJECTED_NOT_INSPECTED')
 fresh();q=bee();q.parameters.genome='bad';tick(q);assert(storage.lastResult=='REJECTED_INVALID_GENOME')
end)
test('M4 either occupied output blocks before reading Input or Adapter',function()
 for _,s in ipairs({1,2}) do
  fresh();slots[0]=bee();slots[s]=bee();reads={};update(1)
  assert(not reads[0] and adapterReads==0 and slots[0] and storage.operationalStatus=='WAITING_OUTPUTS')
 end
end)
test('M5 cadence, one unit from stack and no offline catch-up',function()
 fresh();local q=bee();q.count=5;slots[0]=q
 update(.9);assert(not slots[1]);update(.1);assert(slots[1].count==1 and slots[0].count==4)
 slots[1]=nil;update(9);assert(slots[0].count==3 and same(slots[1].parameters,q.parameters))
end)
test('M6 equality accepted for every gte/lte trait',function()
 for _,mode in ipairs({'gte','lte'}) do baseline();for _,t in ipairs(traits) do call('setMode',t,mode) end
 tick(bee());assert(storage.lastResult=='APPROVED') end
end)
test('M7 each active trait enforces AND without partial improvements',function()
 for _,mode in ipairs({'gte','lte'}) do for _,trait in ipairs(traits) do
  baseline();for _,t in ipairs(traits) do call('setMode',t,mode) end
  local refs=copy(storage.references);tick(bee({[trait]=mode=='gte' and 99 or 101}))
  assert(slots[2] and same(refs,storage.references))
 end end
end)
test('M8 ignore freezes and reactivation uses the old reference',function()
 baseline();call('setMode','baseProduction','ignore');tick(bee({baseProduction=10,droneToughness=101}))
 assert(storage.references.baseProduction==100 and storage.references.droneToughness==101)
 call('setMode','baseProduction','gte');tick(bee({baseProduction=99,droneToughness=101}));assert(slots[2])
end)
test('M9 all ignored still enforce lineage and allow caste changes',function()
 baseline();for _,t in ipairs(traits) do call('setMode',t,'ignore') end
 tick(bee(nil,'queen'));assert(slots[1]);tick(bee(nil,nil,2));assert(slots[2] and storage.lastResult=='REJECTED_INCOMPATIBLE_SUBSPECIES')
 tick(bee(nil,nil,1,'carpenter'));assert(slots[2] and storage.lastResult=='REJECTED_INCOMPATIBLE_SUBSPECIES')
end)
test('M10 invalid commands ignored and snapshots cannot mutate authority',function()
 baseline();call('setMode','fake','ignore');call('setMode','baseProduction','fake');call('setMode',{}, {})
 local s=call('getState');assert(s.traits.baseProduction.mode=='gte' and s.revision==nil)
 s.profile.family='wrong';s.traits.baseProduction.mode='ignore';assert(storage.profile.family=='honey' and storage.modes.baseProduction=='gte')
end)
test('M11 Reset preserves modes and all physical slots',function()
 baseline();call('setMode','baseProduction','lte');slots[0]=bee();slots[1]=bee();slots[2]=bee()
 local before=copy(slots);call('resetProfile');assert(same(before,slots) and storage.modes.baseProduction=='lte')
 assert(not storage.profile and not storage.references and storage.lastResult=='NONE' and storage.operationalStatus=='WAITING_OUTPUTS')
end)
test('M12 placed profile references modes and lastResult survive simulated reload',function()
 baseline();call('setMode','mutationChance','lte');local saved=copy(storage);saved.operationalStatus='WAITING_OUTPUTS';fresh(saved)
 assert(storage.profile.family=='honey' and storage.references.mutationChance==100 and storage.modes.mutationChance=='lte')
 assert(storage.lastResult=='PROFILE_INITIALIZED' and storage.operationalStatus=='WAITING_INPUT')
end)
test('M13 parameter change before withdrawal aborts without commit',function()
 fresh();slots[0]=bee();reads={};faults.onRead=function(s,n) if s==0 and n==2 then slots[0].parameters.lifespan=2 end end
 update(1);assert(slots[0].parameters.lifespan==2 and not slots[1] and not storage.profile and storage.lastResult=='NONE')
end)
test('M14 output filled during revalidation aborts before withdrawal',function()
 fresh();slots[0]=bee();reads={};faults.onRead=function(s,n) if s==1 and n==2 then slots[1]=bee() end end
 update(1);assert(slots[0] and not storage.profile)
end)
test('M15 failed take never changes genetic state',function()
 fresh();slots[0]=bee();faults.noTake=true;update(1);assert(slots[0] and not storage.profile and storage.lastResult=='NONE')
end)
test('M16 output failure restores the exact stack and parameters',function()
 fresh();slots[0]=bee();slots[0].count=3;local q=copy(slots[0]);faults.failOutput=true;update(1)
 assert(same(q,slots[0]) and not storage.profile and not storage.recoveryEscrow and #drops==0)
end)
test('M17 failed approved improvement preserves previous result and references',function()
 baseline();local refs=copy(storage.references);slots[0]=bee({baseProduction=101});faults.failOutput=true;update(1)
 assert(same(refs,storage.references) and storage.lastResult=='PROFILE_INITIALIZED')
end)
test('M18 occupied Input rollback creates one exact drop',function()
 fresh();local q=bee();slots[0]=copy(q);faults.failOutput=true
 faults.afterTake=function() slots[0]={name='stone',count=1,parameters={}} end
 update(1);assert(#drops==1 and same(drops[1],q) and not storage.profile and not storage.recoveryEscrow)
end)
test('M19 output occupancy after take restores Input',function()
 fresh();slots[0]=bee();faults.afterTake=function() slots[2]=bee() end
 update(1);assert(slots[0] and slots[2] and not slots[1] and not storage.profile)
end)
test('M20 unexpected descriptor returned by take is rolled back',function()
 fresh();slots[0]=bee();faults.afterTake=function(q) q.parameters.lifespan=99 end
 update(1);assert(slots[0].parameters.lifespan==99 and not storage.profile)
end)
test('M21 zero raw and extreme mutation display use FU conversion',function()
 fresh();tick(bee({queenLifespan=0,mutationChance=1295}));assert(storage.references.queenLifespan==0)
 assert(call('getState').traits.mutationChance.referenceDisplay==99.92)
end)
test('M22 last applied client command wins without revision or locks',function()
 baseline();call('setMode','baseProduction','lte');local b=call('setMode','baseProduction','ignore')
 assert(b.revision==nil and b.traits.baseProduction.mode=='ignore');call('resetProfile');assert(not call('getState').initialized)
end)
test('M23 adult baseline and all-lte improvements',function()
 fresh();tick(bee(nil,'queen'));for _,t in ipairs(traits) do call('setMode',t,'lte') end
 local v={};for _,t in ipairs(traits) do v[t]=99 end;tick(bee(v));assert(storage.lastResult=='APPROVED')
 for _,t in ipairs(traits) do assert(storage.references[t]==99) end
end)
test('M24 repeated cycles conserve stack counts with occupied-output backpressure',function()
 fresh();slots[0]=bee();slots[0].count=20;local removed=0
 for i=1,20 do update(1);assert(slots[1].count==1);local remaining=slots[0] and slots[0].count or 0
  update(1);assert((slots[0] and slots[0].count or 0)==remaining)
  removed=removed+1;slots[1]=nil;assert(removed+remaining==20 and #drops==0)
 end
end)
test('M25 directive 500/99 rejection never contributes earlier improvements',function()
 baseline();local refs=copy(storage.references);tick(bee({baseProduction=500,droneToughness=99}))
 assert(slots[2] and same(refs,storage.references))
end)
test('M26 mutation uses ordinary numerical gte/lte/ignore without inversion',function()
 for _,mode in ipairs({'gte','lte','ignore'}) do
  baseline();call('setMode','mutationChance',mode);tick(bee({mutationChance=99}))
  assert((slots[1]~=nil)==(mode~='gte'))
  assert(storage.references.mutationChance==(mode=='lte' and 99 or 100))
 end
end)
test('M27 nil drop creates exactly one escrow and no genetic commit',function()
 fresh();local q=bee();slots[0]=copy(q);faults.failOutput=true;faults.spawnNil=true
 faults.afterTake=function() slots[0]={name='stone',count=1,parameters={}} end
 update(1);assert(spawnCalls==1 and #drops==0 and same(storage.recoveryEscrow,q))
 assert(storage.operationalStatus=='RECOVERY_HOLD' and not storage.profile and storage.lastResult=='NONE')
end)
test('M28 spawn exception preserves descriptor and suspends ambiguous retries',function()
 fresh();local q=bee();slots[0]=copy(q);faults.failOutput=true;faults.failInput=true;faults.spawnError=true
 update(1);update(1);die();assert(spawnCalls==1 and same(storage.recoveryEscrow,q) and not storage.profile)
 assert(same(serialized[1],q) and self.recoveryUncertain)
end)
test('M29 nil drop permits final Input recovery if it becomes available',function()
 fresh();local q=bee();slots[0]=copy(q);faults.failOutput=true;faults.spawnNil=true
 faults.afterTake=function() slots[0]={name='stone',count=1,parameters={}} end
 faults.afterSpawnFailure=function() slots[0]=nil end
 update(1);assert(same(slots[0],q) and not storage.recoveryEscrow and not storage.profile and #drops==0)
end)
test('M30 escrow blocks genetics, survives Reset and restores Input before next cycle',function()
 fresh({recoveryEscrow=bee()});slots[0]={name='stone',count=1,parameters={}};faults.spawnNil=true
 update(1);call('resetProfile');assert(storage.recoveryEscrow and adapterReads==0)
 slots[0]=nil;update(1);assert(not storage.recoveryEscrow and slots[0] and not storage.profile and adapterReads==0)
 update(1);assert(storage.profile and slots[1])
end)
test('M31 occupied Input recovers escrow through a single drop',function()
 fresh({recoveryEscrow=bee(),lastResult='APPROVED'});slots[0]={name='stone',count=1,parameters={}};update(1)
 assert(#drops==1 and not storage.recoveryEscrow and storage.lastResult=='APPROVED' and adapterReads==0)
end)
test('M32 destruction touches only escrow and attempts final drop once',function()
 fresh({recoveryEscrow=bee()});slots[0]=bee();slots[1]=bee();slots[2]=bee();die();die()
 assert(#drops==1 and not storage.recoveryEscrow and slots[0] and slots[1] and slots[2])
 fresh({recoveryEscrow=bee()});faults.spawnNil=true;die();die();assert(spawnCalls==1 and storage.recoveryEscrow and logs[1].level=='error')
end)
test('M33 incomplete profiles clear safely while valid modes survive',function()
 for _,refs in ipairs({{}, {baseProduction=1}, {baseProduction=-1}}) do
  fresh({profile={family='honey',subtype=1,subspeciesName='Honey'},references=refs,stateRevision=42,
   modes={baseProduction='ignore',queenLifespan='bad'}})
  assert(not storage.profile and not storage.references and storage.stateRevision==nil)
  assert(storage.modes.baseProduction=='ignore' and storage.modes.queenLifespan=='gte' and #logs>=2)
  tick(bee());assert(storage.lastResult=='PROFILE_INITIALIZED')
 end
end)
test('M34 count-only changes do not invalidate identity',function()
 fresh();slots[0]=bee();slots[0].count=3;reads={}
 faults.onRead=function(s,n) if s==0 and n==2 then slots[0].count=2 end end
 update(1);assert(storage.profile and slots[1].count==1 and slots[0].count==1)
end)
test('M35 mode changes freeze raw and display derives from composite reference',function()
 baseline();local refs=copy(storage.references)
 for _,m in ipairs({'lte','ignore','gte'}) do call('setMode','mutationChance',m);assert(same(refs,storage.references)) end
 call('setMode','mutationChance','ignore');tick(bee({mutationChance=1200}))
 assert(storage.references.mutationChance==100)
 assert(call('getState').traits.mutationChance.referenceDisplay==genelib.statToValue(genelib.numberToStat(100),'mutationChance'))
end)
test('M36 repeated failed recovery and reload retain exact descriptor',function()
 local q=bee();fresh({recoveryEscrow=copy(q),lastResult='REJECTED_GENETIC_CRITERIA'})
 slots[0]={name='stone',count=1,parameters={}};faults.spawnNil=true
 for i=1,4 do update(1);assert(same(storage.recoveryEscrow,q) and adapterReads==0 and #drops==0) end
 fresh(copy(storage));assert(storage.operationalStatus=='RECOVERY_HOLD');update(1)
 assert(not storage.recoveryEscrow and same(slots[0],q) and storage.lastResult=='REJECTED_GENETIC_CRITERIA')
end)
test('M37 invalid drop return is not accepted as successful recovery',function()
 fresh({recoveryEscrow=bee()});slots[0]={name='stone',count=1,parameters={}};faults.spawnInvalid=true;update(1)
 assert(storage.recoveryEscrow and storage.operationalStatus=='RECOVERY_HOLD' and #drops==0)
end)
test('M38 OpenStarbound 0.1.14 full put return does not duplicate or roll back',function()
 fresh();faults.legacyPutReturn=true;slots[0]=bee();slots[0].count=3;update(1)
 assert(storage.profile and storage.lastResult=='PROFILE_INITIALIZED')
 assert(slots[0].count==2 and slots[1].count==1 and not storage.recoveryEscrow and #drops==0)
 fresh();faults.legacyPutReturn=true;tick({name='stone',count=1,parameters={}})
 assert(slots[2] and not slots[0] and storage.lastResult=='REJECTED_INVALID_ITEM' and #drops==0)
end)
test('M39 legacy full put return confirms rollback into an existing input stack',function()
 fresh();faults.legacyPutReturn=true;faults.failOutput=true;slots[0]=bee();slots[0].count=3
 update(1);assert(slots[0].count==3 and not slots[1] and not storage.profile and #drops==0 and not storage.recoveryEscrow)
end)
test('M40 legacy full put return clears recovered escrow exactly once',function()
 fresh({recoveryEscrow=bee()});faults.legacyPutReturn=true;update(1)
 assert(slots[0].count==1 and not storage.recoveryEscrow and #drops==0 and not storage.profile)
 update(1);assert(not slots[0] and slots[1].count==1 and storage.profile and #drops==0)
end)

test('M41 reference display is decoded only after reference changes',function()
 baseline();local old=genelib.statToValue;local conversions=0
 genelib.statToValue=function(...) conversions=conversions+1;return old(...) end
 call('getState');assert(conversions==6)
 for i=1,20 do call('getState') end
 assert(conversions==6)
 call('setMode','baseProduction','ignore');assert(conversions==6)
 call('resetProfile');assert(not call('getState').traits.baseProduction.referenceDisplay)
 genelib.statToValue=old
 tick(bee());assert(call('getState').traits.baseProduction.referenceDisplay~=nil)
end)
test('M42 old ambiguous hybrid baseline clears without touching modes, escrow or slots',function()
 fresh({profile={family='hybrid',subtype=1,subspeciesName='hybridA'},references={baseProduction=1,
  droneToughness=1,droneBreedRate=1,queenBreedRate=1,queenLifespan=1,mutationChance=1},
  modes={baseProduction='ignore'},recoveryEscrow=bee()})
 assert(not storage.profile and not storage.references and storage.modes.baseProduction=='ignore')
 assert(storage.recoveryEscrow and storage.operationalStatus=='RECOVERY_HOLD')
end)
test('M43 exact transfers never invoke item builders',function()
 local old=root.createItem;root.createItem=function() error('Filter must not rebuild specimens') end
 fresh();faults.legacyPutReturn=true;local q=bee();q.parameters.extra={deep={x=7}}
 tick(q);assert(same(slots[1].parameters,q.parameters) and storage.profile)
 root.createItem=old
end)
test('M44 hybrid filter rejects unrelated pairs even with all traits ignored',function()
 fixture.beeData.stats.hybrid={{name='hybridA'},{name='hybridB'}}
 fixture.tags.bee_hybrid_queen={bee=true,queen=true}
 local function hybrid(a,b,subtype)
  local q=bee(nil,'queen',subtype,'hybrid');local x,y=a,b;if x>y then x,y=y,x end
  q.parameters.hybridLineage={queenFamily=a,droneFamily=b,speciesId='hybrid_'..x..'_'..y,
   parentSubtypes={[a]=1,[b]=1}}
  return q
 end
 fresh();tick(hybrid('honey','carpenter',1));assert(storage.profile.lineageKey)
 for _,trait in ipairs(traits) do call('setMode',trait,'ignore') end
 tick(hybrid('honey','mason',1));assert(storage.lastResult=='REJECTED_INCOMPATIBLE_SUBSPECIES')
 tick(hybrid('honey','carpenter',2));assert(storage.lastResult=='REJECTED_INCOMPATIBLE_SUBSPECIES')
 tick(hybrid('carpenter','honey',2));assert(storage.lastResult=='APPROVED')
 local saved=copy(storage);fresh(saved);assert(same(saved.profile,storage.profile))
 fixture.beeData.stats.hybrid=nil
end)
print('Machine: '..count..' test groups passed (engine bindings mocked).')
