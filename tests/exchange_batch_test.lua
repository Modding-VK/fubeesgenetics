-- Independent exhaustive oracle for the slot-threshold planner.
require = function(path) dofile(fixture.repoRoot .. '/FUBeesGenetics' .. path) end
require '/scripts/fubeesgenetics/exchangebatch.lua'
local copy=fubeesContainer.copy
local passed=0
local function test(name,fn) fn();passed=passed+1;print('PASS B'..passed..' '..name) end
local reward={name='money',count=7,parameters={}}
local function oracle(slots,start,size,cost,output,limit,budget)
  local best=0
  for batches=1,budget do
    local after,needed=copy(slots),batches*cost
    for offset=0,size-1 do
      local i=(start+offset)%size;local item=after[i]
      if item and item.name=='drone' then
        local take=math.min(item.count,needed);item.count=item.count-take;needed=needed-take
        if item.count==0 then after[i]=nil end
      end
    end
    if needed==0 then
      local capacity=0
      for i=0,size-1 do
        local item=after[i]
        if not item then capacity=capacity+limit
        elseif item.name=='money' and next(item.parameters)==nil then capacity=capacity+math.max(0,limit-item.count) end
      end
      if batches*output<=capacity then best=batches end
    end
  end
  return best
end
test('a larger batch can fit when a smaller batch cannot free a slot',function()
  local slots={[0]={name='drone',count=10,parameters={gene='A'}}}
  assert(fubeesBatch.select(slots,0,1,'drone',5,reward,1000,200)==2)
end)
test('random slot arrangements match exhaustive feasible-quantity search',function()
  math.randomseed(364064)
  for scenario=1,300 do
    local slots={}
    for i=0,3 do
      local kind=math.random(1,5)
      if kind<3 then slots[i]={name='drone',count=math.random(1,20),parameters={gene=tostring(i)}}
      elseif kind==3 then slots[i]={name='money',count=math.random(1,10),parameters={}}
      elseif kind==4 then slots[i]={name='money',count=1,parameters={custom=true}} end
    end
    local before=copy(slots);local start=math.random(0,3);local cost=scenario%2==0 and 5 or 3
    local output=scenario%2==0 and 7 or 4
    local r={name='money',count=output,parameters={}}
    local expected=oracle(slots,start,4,cost,output,10,8)
    assert(fubeesBatch.select(slots,start,4,'drone',cost,r,10,8)==expected,'scenario '..scenario)
    assert(fubeesContainer.same(slots,before),'planner changed its input')
  end
end)
print('Batch planner: '..passed..' test groups passed (pure Lua).')
