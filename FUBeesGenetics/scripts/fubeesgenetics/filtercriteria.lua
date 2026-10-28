require "/bees/genomeLibrary.lua"
require "/scripts/fubeesgenetics/filtercontract.lua"

-- Pure conversion at configuration time, never a scan per processed queen.
-- FU's mutation percentage is discrete and rounded; bounds are resolved with
-- the real decoder instead of assuming every displayed decimal is a gene.
fubeesCriteria = {}
local C, epsilon = fubeesCriteria, 1e-7
local function finite(n)
  return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
function C.display(raw, trait) return genelib.statToValue(genelib.numberToStat(raw), trait) end
function C.rawValid(n) return finite(n) and n >= 0 and n <= 1295 and n == math.floor(n) end
function C.normalize(trait, mode, minimum, maximum)
  if not fubeesFilter.traitSet[trait] or (mode ~= "eq" and mode ~= "range") then
    return nil, "Invalid target mode or trait."
  end
  if mode == "eq" then maximum = minimum end
  local ceiling = C.display(1295, trait)
  if not finite(minimum) or not finite(maximum) or minimum < 0 or maximum > ceiling + epsilon
    or minimum > maximum then return nil, string.format("Use ordered values between 0 and %g.", ceiling) end
  local function bound(value, upper)
    local left, right = 0, 1296
    while left < right do
      local mid = math.floor((left + right) / 2)
      local shown = C.display(mid, trait)
      local advance = upper and shown <= value + epsilon or not upper and shown < value - epsilon
      if advance then left = mid + 1 else right = mid end
    end
    return upper and left - 1 or left
  end
  local lo, hi = bound(minimum, false), bound(maximum, true)
  if lo > hi or lo > 1295 or hi < 0 then
    return nil, string.format("No FU value in this interval. Nearest: %g / %g.",
      C.display(math.max(0, math.min(1295, lo - 1)), trait), C.display(math.min(1295, lo), trait))
  end
  return {minRaw=lo, maxRaw=hi, minDisplay=minimum, maxDisplay=maximum}
end
function C.validStored(trait, target)
  if type(target) ~= "table" or not C.rawValid(target.minRaw) or not C.rawValid(target.maxRaw) then return false end
  local normalized = C.normalize(trait, "range", target.minDisplay, target.maxDisplay)
  return normalized and normalized.minRaw == target.minRaw and normalized.maxRaw == target.maxRaw or false
end
