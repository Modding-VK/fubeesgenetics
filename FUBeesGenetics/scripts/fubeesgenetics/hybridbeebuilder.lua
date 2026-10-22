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

  -- Each parent pair has a dedicated 84x28 sprite sheet with all three caste
  -- frames. The subspecies gene affects production, not the species artwork.
  local lifeBar = type(builtConfig.inventoryIcon) == "table" and builtConfig.inventoryIcon[2]
  local parents = lineage.parentFamilies
  builtConfig.inventoryIcon = {
    {image = string.format("/bees/bees/%s.png:%s", lineage.speciesId, frame), position = {0, 0}}
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
