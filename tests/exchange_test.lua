-- Exercise the actual controller with pinned FU recipes and fault-injectable inventory.
local function copy(x)
 if type(x)~='table' then return x end
 local r={};for k,v in pairs(x) do r[k]=copy(v) end;return r
end
local function same(a,b)
 if type(a)~=type(b) then return false end
 if type(a)~='table' then return a==b end
 for k,v in pairs(a) do if not same(v,b[k]) then return false end end
 for k in pairs(b) do if a[k]==nil then return false end end;return true
end
local base='/objects/bees/fubeesgenetics/beeexchange/'
local slots,faults,puts,takes,drops,logs
local paths={};for path in pairs(fixture.tradeRecipes) do paths[#paths+1]=path end;table.sort(paths)
root={assetJson=function(path)
 if path==base..'trades.config' then return {recipes=paths} end
 if path=='/items/defaultParameters.config' then return {defaultMaxStack=1000} end
 assert(fixture.tradeRecipes[path],path);return copy(fixture.tradeRecipes[path])
end,itemConfig=function(item)
 if faults.onItemConfig then faults.onItemConfig(item) end
 if faults.missingOutput and item.name==faults.missingOutput then return nil end
 return {config={maxStack=faults.maxStack or 1000},parameters={}}
end}
entity={id=function() return 42 end,position=function() return {10,20} end,entityType=function() return 'object' end}
config={getParameter=function(name) if name=='slotCount' then return 20 end end}
sb={logInfo=function() end,logError=function(...) logs[#logs+1]={...} end,printJson=function() return 'descriptor' end}
world={containerItemAt=function(id,s)
 assert(id==42 and s>=0 and s<20);return copy(slots[s])
end,containerTakeNumItemsAt=function(id,s,n)
 takes=takes+1
 if faults.takeFailure==takes or not slots[s] or slots[s].count<n then return nil end
 local item=copy(slots[s]);item.count=n
 slots[s].count=slots[s].count-n;if slots[s].count==0 then slots[s]=nil end
 if faults.afterTake then faults.afterTake(s,item) end
 return item
end,containerPutItemsAt=function(id,item,s)
 puts=puts+1
 if faults.putFailure or (slots[s] and (slots[s].name~=item.name or not same(slots[s].parameters,item.parameters))) then return copy(item) end
 local limit=faults.maxStack or 1000
 local inserted=math.min(item.count,limit-(slots[s] and slots[s].count or 0))
 if faults.partialPut then inserted=math.min(inserted,faults.partialPut) end
 if inserted>0 then
  slots[s]=slots[s] or {name=item.name,count=0,parameters=copy(item.parameters)}
  slots[s].count=slots[s].count+inserted
 end
 if faults.legacyPutReturn then return copy(item) end
 if inserted<item.count then local left=copy(item);left.count=item.count-inserted;return left end
end,spawnItem=function(item)
 if faults.spawnFailure then return nil end
 drops[#drops+1]=copy(item);return 500
end}
require=function(path)
 if path=='/scripts/util.lua' then util={};return end
 assert(path=='/scripts/kheAA/transferUtil.lua');dofile(fixture.fuRoot..path)
end
dofile(fixture.repoRoot..'/FUBeesGenetics'..base..'beeexchange.lua')
local function fresh(saved,inventory)
 slots=copy(inventory or {});storage=copy(saved or {});faults={};puts=0;takes=0;drops={};logs={}
 transferUtil.vars=nil;init()
end
local function item(name,count,parameters) return {name=name,count=count or 1,parameters=parameters or {}} end
local function total(name)
 local n=0;for _,v in pairs(slots) do if v.name==name then n=n+v.count end end
 for _,v in ipairs(storage.exchangePending or {}) do if v.name==name then n=n+v.count end end
 for _,v in ipairs(drops) do if v.name==name then n=n+v.count end end
 return n
end
local function fill()
 for s=0,19 do slots[s]=item('stone',1000,{slot=s}) end
end
local groups=0
local function test(label,fn) fresh();fn();groups=groups+1;print('PASS '..label) end

test('E1 every one of the 105 real FU trades returns the exact recipe reward',function()
 for _,path in ipairs(paths) do
  fresh();local recipe=fixture.tradeRecipes[path]
  slots[0]=item(recipe.input[1].item,recipe.input[1].count,{genome='unique',inspected=false})
  update(1)
  assert(total(recipe.input[1].item)==0,path)
  assert(total(recipe.output.item)==recipe.output.count,path)
  assert(not storage.exchangePending,path)
 end
end)
test('E2 non-bees and unsupported bee names untouched; later slots still sell',function()
 slots[0]=item('stone',99,{custom=true});slots[1]=item('bee_fake_queen');slots[19]=item('bee_honey_queen')
 local a,b=copy(slots[0]),copy(slots[1]);update(1)
 assert(same(slots[0],a) and same(slots[1],b) and total('coalore')==10 and takes==1)
end)
test('E3 four drones wait, fifth arriving triggers exactly one batch',function()
 slots[0]=item('bee_honey_drone',4);update(1);assert(takes==0 and total('money')==0)
 slots[1]=item('bee_honey_drone');update(1);assert(total('money')==7 and total('bee_honey_drone')==0)
end)
test('E4 drone batches aggregate different parameters, preserve the remainder',function()
 slots[0]=item('bee_honey_drone',3,{genome='A'});slots[1]=item('bee_honey_drone',4,{genome='B'})
 update(1);assert(total('money')==7 and total('bee_honey_drone')==2)
 assert(slots[1].parameters.genome=='B')
end)
test('E5 different drone species never combine to meet a batch',function()
 slots[0]=item('bee_honey_drone',3);slots[1]=item('bee_artisan_drone',2);update(1)
 assert(takes==0 and total('money')==0)
end)
test('E6 full inventory holds a stacked queen without consuming it',function()
 fill();slots[0]=item('bee_honey_queen',2);local before=copy(slots);update(1)
 assert(same(slots,before) and takes==0)
 slots[10]=nil;update(1);assert(total('coalore')==10 and total('bee_honey_queen')==1)
end)
test('E7 consumption can free the output slot in a full container',function()
 fill();slots[0]=item('bee_honey_queen');update(1)
 assert(total('coalore')==10 and total('bee_honey_queen')==0)
end)
test('E8 output capacity respects stack limits, splits rewards safely',function()
 faults.maxStack=8;slots[0]=item('bee_honey_queen');update(1)
 assert(total('coalore')==10 and not storage.exchangePending)
 for _,v in pairs(slots) do assert(v.count<=8) end
end)
test('E9 insufficient total output capacity leaves bees untouched',function()
 fill();slots[0]=item('bee_honey_queen');faults.maxStack=8
 update(1);assert(total('bee_honey_queen')==1 and total('coalore')==0 and takes==0)
end)
test('E10 compatible rewards stack and pre-existing resources are never sold',function()
 slots[0]=item('coalore',989);slots[1]=item('bee_honey_queen');slots[2]=item('money',20)
 update(1);assert(total('coalore')==999 and total('money')==20)
 update(10);assert(total('coalore')==999 and total('money')==20)
end)
test('E11 same-name output with custom parameters does not get merged',function()
 slots[0]=item('coalore',1,{custom=true});slots[1]=item('bee_honey_queen');update(1)
 assert(slots[0].count==1 and slots[0].parameters.custom and total('coalore')==11)
end)
test('E12 legacy complete-put return does not duplicate refunds or rewards',function()
 slots[0]=item('bee_honey_queen');faults.legacyPutReturn=true
 update(1);update(1);assert(total('coalore')==10 and puts==1 and takes==1 and not storage.exchangePending)
end)
test('E13 failed take issues no reward and preserves the bee',function()
 slots[0]=item('bee_honey_queen');faults.takeFailure=1;update(1)
 assert(total('bee_honey_queen')==1 and total('coalore')==0)
end)
test('E14 interrupted multi-stack take refunds exact removed descriptors',function()
 slots[0]=item('bee_honey_drone',3,{genome='A'});slots[1]=item('bee_honey_drone',2,{genome='B'})
 faults.putFailure=true;faults.takeFailure=2;update(1)
 assert(total('bee_honey_drone')==5 and total('money')==0 and storage.exchangePending[1].parameters.genome=='A')
end)
test('E15 failed output keeps one owed reward, blocks new consumption, survives reload',function()
 slots[0]=item('bee_honey_queen',2);faults.putFailure=true;update(1)
 assert(total('bee_honey_queen')==1 and total('coalore')==10 and takes==1)
 update(1);assert(takes==1 and total('coalore')==10)
 local saved,inventory=copy(storage),copy(slots)
 fresh(saved,inventory);update(1)
 assert(total('bee_honey_queen')==0 and total('coalore')==20 and not storage.exchangePending)
end)
test('E16 partial insertion records only undelivered remainder',function()
 slots[0]=item('bee_honey_queen');faults.partialPut=4;update(1)
 assert(total('coalore')==10 and storage.exchangePending[1].count==6)
 faults.partialPut=nil;update(1);assert(total('coalore')==10 and not storage.exchangePending)
end)
test('E17 pending output waits when full and resumes when room returns',function()
 slots[0]=item('bee_honey_queen');faults.putFailure=true;update(1)
 fill();faults.putFailure=nil;update(1);assert(storage.exchangePending and total('coalore')==10)
 slots[7]=nil;update(1);assert(not storage.exchangePending and slots[7].name=='coalore' and slots[7].count==10)
end)
test('E18 unresolvable output item cannot consume a bee',function()
 slots[0]=item('bee_honey_queen');faults.missingOutput='coalore';update(1)
 assert(takes==0 and total('bee_honey_queen')==1)
end)
test('E19 loaded cadence, closed-pane operation and no offline catch-up',function()
 slots[0]=item('bee_honey_queen',100);update(.5);assert(takes==0)
 update(.5);assert(takes==1 and total('coalore')==10)
 update(100);assert(takes==2 and total('coalore')==20)
end)
test('E20 breaking drops only exceptional pending items, once',function()
 slots[0]=item('bee_honey_queen');faults.putFailure=true;update(1)
 die();die();assert(#drops==1 and drops[1].name=='coalore' and drops[1].count==10 and not storage.exchangePending)
end)
test('E21 failed destruction recovery reports failure without retry duplication',function()
 slots[0]=item('bee_honey_queen');faults.putFailure=true;update(1);faults.spawnFailure=true
 die();die();assert(#drops==0 and #logs==1 and storage.exchangePending[1].count==10)
end)
test('E22 real FU automation registration exposes the same 20-slot container',function()
 assert(transferUtil.vars.inContainers[42] and transferUtil.vars.outContainers[42])
 assert(transferUtil.vars.containerId==42 and self.size==20)
end)
test('E23 a changed input snapshot aborts before any withdrawal',function()
 slots[0]=item('bee_honey_queen',1,{genome='before'})
 faults.onItemConfig=function()
  faults.onItemConfig=nil;slots[0].parameters.genome='after'
 end
 update(1);assert(takes==0 and total('coalore')==0 and slots[0].parameters.genome=='after')
end)
test('E24 a later drone stack changed during withdrawal refunds the first stack',function()
 slots[0]=item('bee_honey_drone',3,{genome='A'});slots[1]=item('bee_honey_drone',2,{genome='B'})
 faults.afterTake=function()
  faults.afterTake=nil;slots[1].name='stone';faults.putFailure=true
 end
 update(1)
 assert(takes==1 and total('bee_honey_drone')==3 and total('stone')==2 and total('money')==0)
 assert(storage.exchangePending[1].parameters.genome=='A')
end)
test('E25 runtime rewards follow loaded FU recipes, not a duplicated price table',function()
 local path='/recipes/bees/beerefuge/queens/honeyqueen.recipe'
 local original=copy(fixture.tradeRecipes[path])
 fixture.tradeRecipes[path].output.count=13
 fresh();slots[0]=item('bee_honey_queen');update(1)
 assert(total('coalore')==13)
 fixture.tradeRecipes[path]=original
end)
test('E26 full-container trades can use remaining capacity in an existing output stack',function()
 fill();slots[0]=item('bee_honey_queen',2);slots[19]=item('coalore',990)
 update(1);assert(total('bee_honey_queen')==1 and slots[19].count==1000)
end)
print('Bee Exchange: '..groups..' test groups passed (engine bindings mocked).')
