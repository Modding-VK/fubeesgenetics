-- Execute uploaded IC 2.11 code and the real machine in isolated Lua contexts.
-- Engine, player and GUI bindings are simulated; no third-party code is copied.
local function copy(v)
 if type(v)~='table' then return v end
 local r={};for k,x in pairs(v) do r[k]=copy(x) end;return r
end
local function same(a,b)
 if type(a)~=type(b) then return false end
 if type(a)~='table' then return a==b end
 for k,v in pairs(a) do if not same(v,b[k]) then return false end end
 for k in pairs(b) do if a[k]==nil then return false end end;return true
end
local function matches(a,b) return a and b and a.name==b.name and same(a.parameters or {},b.parameters or {}) end
local function item(n,c,p) return {name=n,count=c or 1,parameters=p or {}} end
local base='/objects/bees/fubeesgenetics/beeexchange/'
local function scenario(withIC,params)
 local env=setmetatable({}, {__index=_G})
 local cfg=copy(fixture.exchangeConfig);for k,v in pairs(params or {}) do cfg[k]=copy(v) end
 local slots,drops,handlers,queue,playerItems={},{},{},{},{}
 local ctx={env=env,slots=slots,drops=drops,handlers=handlers,playerItems=playerItems,putFailure=false,facing=1,tags={}}
 env.storage={}
 local function json(path)
  if path=='/interface/chests/chest16.config' then return copy(withIC and fixture.icUi or fixture.nativeUi) end
  if path=='/items/defaultParameters.config' then return {defaultMaxStack=1000} end
  if path=='/items/defaultParameters.config:defaultMaxStack' then return 1000 end
  if path=='/items/rotting.config:rotTimeDescriptions' then return {{10,'Soon'},{100000,'Fresh'}} end
  if path=='/items/rotting.config:rottedItem' then return 'rottenfood' end
  if path==base..'trades.config' then local paths={};for k in pairs(fixture.tradeRecipes) do paths[#paths+1]=k end;table.sort(paths);return {recipes=paths} end
  assert(fixture.tradeRecipes[path],path);return copy(fixture.tradeRecipes[path])
 end
 local function itemConfig(desc)
  local n=type(desc)=='table' and desc.name or desc
  if n==cfg.objectName then return {config=copy(cfg),parameters={}} end
  return {config={shortdescription=n,category='craftingMaterial',maxStack=1000,price=1,rarity='Common'},parameters={}}
 end
 env.root={assetJson=json,itemConfig=itemConfig,itemType=function() return 'generic' end,itemTags=function() return {} end}
 env.config={getParameter=function(k,default) local v=cfg[k];if v==nil then return default end;return copy(v) end}
 env.entity={id=function() return 42 end,entityType=function() return 'object' end,position=function() return {10,20} end}
 env.object={name=function() return cfg.objectName end,direction=function() return ctx.facing end,
  setConfigParameter=function(k,v) cfg[k]=copy(v) end,
  isInputNodeConnected=function() return ctx.off or false end,getInputNodeLevel=function() return false end}
 env.script={setUpdateDelta=function(v) ctx.delta=v end}
 env.message={setHandler=function(k,fn) handlers[k]=fn end}
 env.sb={logInfo=function() end,logWarn=function() end,logError=function() end,printJson=function() return '' end}
 env.animator={setAnimationState=function() end,setGlobalTag=function(k,v) ctx.tags[k]=v end}
 local function contents() local t={};for i=0,15 do if slots[i] then t[i+1]=copy(slots[i]) end end;return t end
 env.world={containerSize=function() return 16 end,containerItems=contents,
  containerItemAt=function(_,i) return copy(slots[i]) end,
  containerTakeNumItemsAt=function(_,i,n)
   if not slots[i] or slots[i].count<n then return nil end
   local v=copy(slots[i]);v.count=n;slots[i].count=slots[i].count-n;if slots[i].count==0 then slots[i]=nil end;return v
  end,
  containerPutItemsAt=function(_,v,i)
   if ctx.putFailure or (slots[i] and not matches(slots[i],v)) then return copy(v) end
   slots[i]=slots[i] or item(v.name,0,copy(v.parameters));slots[i].count=slots[i].count+v.count
  end,
  containerTakeAll=function() local t=contents();for i=0,15 do slots[i]=nil end;return t end,
  containerItemApply=function(_,v,i) assert(i>=0 and i<16);slots[i]=copy(v) end,
  containerAddItems=function(_,v)
   for i=0,15 do if matches(slots[i],v) then slots[i].count=slots[i].count+v.count;return end end
   for i=0,15 do if not slots[i] then slots[i]=copy(v);return end end
   return copy(v)
  end,
  containerTakeAt=function(_,i) local v=slots[i];slots[i]=nil;return v end,
  spawnItem=function(v,_,count,parameters)
   drops[#drops+1]=type(v)=='table' and copy(v) or item(v,count,copy(parameters or {}));return 500+#drops
  end,entityName=function() return cfg.objectName end}
 env.world.sendEntityMessage=function(_,name,...)
  local entry={name=name,args={...},done=false};queue[#queue+1]=entry
  return {finished=function() return entry.done end,result=function() return copy(entry.value) end}
 end
 function ctx.flush()
  local old=queue;queue={}
  for _,e in ipairs(old) do if handlers[e.name] then e.value=handlers[e.name](nil,nil,table.unpack(e.args)) end;e.done=true end
 end
 local function setupRequire(e)
  local loaded={}
  e.require=function(path)
   if loaded[path] then return end;loaded[path]=true
   if path=='/scripts/util.lua' then e.util={};return end
   local f
   if path:find('^/scripts/v6/') then f=fixture.icRoot..path
   elseif path=='/scripts/kheAA/transferUtil.lua' then f=fixture.fuRoot..path
   elseif path=='/scripts/items/rotting.lua' then f=fixture.nativeRoot..path
   else f=fixture.repoRoot..'/FUBeesGenetics'..path end
   assert(loadfile(f,'t',e))()
  end
 end
 setupRequire(env)
 -- Native LuaRoot::createContext loads every script BEFORE binding root/config/
 -- object/animator callbacks. Engine APIs are unavailable during module loading.
 local bindings={}
 for _,name in ipairs({'root','config','entity','object','script','message','sb','animator','world'}) do
  bindings[name]=env[name];env[name]=nil
 end
 for _,path in ipairs(cfg.scripts) do assert(loadfile(fixture.repoRoot..'/FUBeesGenetics'..path,'t',env))() end
 for name,value in pairs(bindings) do env[name]=value end
 env.init()
 ctx.cfg=cfg
 function ctx.count(n) local c=0;for _,v in pairs(slots) do if v.name==n then c=c+v.count end end;return c end
 function ctx.gui()
  local g=setmetatable({}, {__index=_G});g.root=env.root;g.world=env.world;g.sb=env.sb
  g.pane={containerEntityId=function() return 42 end,dismiss=function() end}
  local view=cfg.uiConfig;assert(type(view)=='table')
  g.config={getParameter=function(key)
   local v=view;for part in key:gmatch('[^.]+') do v=v[part] end;return copy(v)
  end}
  local widgets={};g.widget={}
  for _,method in ipairs({'setButtonEnabled','setVisible','focus','setPosition','setImage','setText'}) do
   g.widget[method]=function(k,v) widgets[k]=v end
  end
  local texts={}
  g.widget.setText=function(k,v) texts[k]=v end
  g.widget.getText=function(k) return texts[k] or '' end
  g.player={hasCountOfItem=function(v)
   local n=0;for _,p in ipairs(playerItems) do if matches(p,v) then n=n+p.count end end;return n
  end,equippedItem=function() end,primaryHandItem=function() end,altHandItem=function() end,
  cleanupItems=function() end,consumeItem=function(v)
   for _,p in ipairs(playerItems) do if matches(p,v) and p.count>=v.count then p.count=p.count-v.count;return copy(v) end end
  end,giveItem=function(v) playerItems[#playerItems+1]=copy(v);ctx.giveBack=(ctx.giveBack or 0)+v.count end}
  setupRequire(g)
  for _,path in ipairs(view.scripts) do g.require(path) end
  g.init();ctx.flush();g.update(0)
  g.widgets=widgets;return g
 end
 return ctx
end
local groups=0
local function test(name,fn) fn();groups=groups+1;print('PASS IC '..name) end

test('no IC: native window and ordinary sale remain independent',function()
 local s=scenario(false);assert(not s.env.ic and not s.cfg.smashOnBreak)
 s.slots[0]=item('bee_honey_queen');s.env.update(1);assert(s.count('coalore')==10)
end)
test('IC init chains machine, handlers, cadence and private GUI bridge',function()
 local s=scenario(true);assert(s.env.self.trades and s.env.ic.version==2 and s.delta==10)
 assert(s.cfg.smashOnBreak and s.handlers.open and s.handlers.rename and s.handlers['fubeesgenetics.storageLock'])
 assert(#s.cfg.uiConfig.scripts==2)
 local g=s.gui();assert(g.ic.serverVersion==2 and g.widgets.icRenameButton)
 s.handlers.rename(nil,nil,'Auto Bees');assert(s.cfg.shortdescription=='Auto Bees')
end)
test('real IC sort waits for acknowledgement and preserves descriptors',function()
 local s=scenario(true);s.off=true;s.env.update(0)
 s.slots[0]=item('zzz',2,{custom='keep'});s.slots[10]=item('aaa',1,{genome='unique'})
 local g=s.gui();g.ic.sort();s.flush();g.update(0)
 assert(s.slots[0].name=='zzz') -- no server lock acknowledgement yet
 s.flush();g.update(0)
 assert(s.slots[0].name=='aaa' and s.slots[0].parameters.genome=='unique' and s.slots[1].parameters.custom=='keep')
 assert(s.env.ic.locked==2)
end)
test('real IC quick stack is verified before bee conversion resumes',function()
 local s=scenario(true);s.env.update(0);s.slots[0]=item('bee_honey_drone',4,{genome='A'})
 s.playerItems[1]=item('bee_honey_drone',1,{genome='A'})
 local g=s.gui();g.ic.quickstack();s.flush();g.update(0)
 assert(s.count('bee_honey_drone')==4 and s.playerItems[1].count==1)
 s.flush();g.update(0);assert(s.count('bee_honey_drone')==5 and s.playerItems[1].count==0)
 s.env.update(1);assert(s.count('bee_honey_drone')==5 and s.count('money')==0)
 g.update(.25);assert(not g.ic.verify and not s.giveBack)
 s.env.update(1);s.env.update(1);assert(s.count('money')==7 and s.count('bee_honey_drone')==0)
end)
test('real IC search finds the native slot and rename callback updates object',function()
 local s=scenario(true);s.slots[12]=item('stone',3);local g=s.gui()
 g.widget.setText('icSearchBox','stone');g.ic.searchBox()
 assert(g.widgets.icSearchBorder1==true)
 g.widget.setText('icRenameBox','Bee Refuge');g.ic.renameThis();s.flush();assert(s.cfg.shortdescription=='Bee Refuge')
end)
test('breaking packs content and recovers pending rewards exactly once',function()
 local s=scenario(true);s.env.update(0);s.handlers.open()
 s.slots[0]=item('bee_honey_queen');s.putFailure=true;s.env.update(1)
 assert(s.env.storage.exchangePending)
 s.slots[3]=item('stone',8,{custom='safe'});s.env.die();s.env.die()
 assert(#s.drops==2 and s.drops[1].name=='coalore' and s.drops[1].count==10)
 assert(s.drops[2].name==s.cfg.objectName and s.drops[2].parameters.content[4].parameters.custom=='safe')
 assert(next(s.slots)==nil and not s.env.storage.exchangePending)
end)
test('packed content restores once at exact slots; sale later continues',function()
 local content={[6]=item('bee_honey_drone',5,{genome='restored'}),[13]=item('stone',2)}
 local s=scenario(true,{content=content,playerInteract=true});s.env.update(0)
 assert(s.slots[5].parameters.genome=='restored' and s.slots[12].name=='stone')
 s.env.update(1);assert(s.count('money')==7 and s.count('stone')==2)
 s.env.update(1);assert(s.count('money')==7)
end)
test('IC dropOnBreak keeps ordinary engine drop path',function()
 local s=scenario(true);s.env.ic.config.dropOnBreak=true;s.env.update(0)
 assert(s.cfg.smashOnBreak==false);s.slots[0]=item('stone');s.env.die()
 assert(#s.drops==0 and s.count('stone')==1) -- engine owns the ordinary object/content drops
end)
test('installed IC aging executes on packed perishable items',function()
 local s=scenario(true);local root=s.env.root;s.env.root=nil
 s.env.require(base..'storageaging.lua');s.env.root=root
 local obj=item(s.cfg.objectName,1,{content={[1]=item('food',1,{timeToRot=20})}})
 local aged=s.env.ageItem(obj,5);assert(aged.parameters.content[1].parameters.timeToRot==15)
end)
test('removing optional IC clears only its overrides and restores packed items',function()
 local s=scenario(false,{fubeesgeneticsIC=true,smashOnBreak=true,uiConfig=fixture.icUi,
  content={[8]=item('stone',9,{custom='packed'})}})
 assert(not s.cfg.smashOnBreak and not s.cfg.fubeesgeneticsIC and s.cfg.uiConfig=='/interface/chests/chest16.config')
 assert(s.slots[7].count==9 and s.slots[7].parameters.custom=='packed')
 s.env.update(1);assert(s.count('stone')==9)
end)
test('facing remains correct through IC lock, tag resets and content restoration',function()
 local s=scenario(true,{content={[4]=item('stone',2)},playerInteract=true})
 assert(s.tags.facingSuffix=='')
 s.facing=-1;s.handlers['fubeesgenetics.storageLock']();s.env.update(.1)
 assert(s.tags.facingSuffix=='-left' and s.env.ic.locked>0)
 assert(s.slots[3].count==2)
 s.tags.facingSuffix='';s.env.update(.1);assert(s.tags.facingSuffix=='-left')
 s.facing=1;s.env.update(.1);assert(s.tags.facingSuffix=='')
end)
print('Improved Containers: '..groups..' integration groups passed (uploaded real Lua; simulated engine/UI bindings).')
