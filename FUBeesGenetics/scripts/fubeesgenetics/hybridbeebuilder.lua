require "/bees/beeBuilder.lua"
require "/scripts/fubeesgenetics/hybridbees.lua"

local nativeBuild = build
local function displayName(family) return family:sub(1, 1):upper() .. family:sub(2) end

function build(directory, config, parameters, level, seed)
  local builtConfig, builtParameters = nativeBuild(directory, config, parameters, level, seed)
  local lineage = hybridbees.lineage({name = config.itemName, parameters = builtParameters})
  if not lineage then return builtConfig, builtParameters end
  local frame, caste = "drone", "Drone"
  if root.itemHasTag(config.itemName, "queen") then frame, caste = "queen", "Queen"
  elseif root.itemHasTag(config.itemName, "youngQueen") then frame, caste = "youngQueen", "Queen Larva" end

  -- Complementary regions form a single 28x28 bee in its original coordinate
  -- system. No scaling, no pair of miniature bees, and no subspecies color swap.
  local lifeBar = type(builtConfig.inventoryIcon) == "table" and builtConfig.inventoryIcon[2]
  local parents = lineage.parentFamilies
  builtConfig.inventoryIcon = {
    {image = string.format("/bees/bees/%s.png:%s?crop=0;0;14;28", parents[1], frame), position = {-7, 0}},
    {image = string.format("/bees/bees/%s.png:%s?crop=14;0;28;28", parents[2], frame), position = {7, 0}}
  }
  if lifeBar then builtConfig.inventoryIcon[#builtConfig.inventoryIcon + 1] = lifeBar end
  local name = displayName(parents[1]) .. " × " .. displayName(parents[2])
  local priority = lineage.subspecies == 1 and lineage.queenFamily or lineage.droneFamily
  builtConfig.shortdescription = name .. " " .. caste
  builtConfig.tooltipFields.subTitle = "Priority: " .. displayName(priority)
  builtConfig.description = string.format("Hybrid %s. Use an Overload Apiary. Prioritizes %s resources; also produces %s resources.",
    caste:lower(), displayName(priority), displayName(priority == lineage.queenFamily and lineage.droneFamily or lineage.queenFamily))
  if lineage.genomeExceptions and #lineage.genomeExceptions > 0 then
    builtConfig.description = builtConfig.description .. " Genes already at their limit: " .. table.concat(lineage.genomeExceptions, ", ") .. "."
  end
  return builtConfig, builtParameters
end
