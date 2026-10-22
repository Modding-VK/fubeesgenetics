require "/bees/beeBuilder.lua"

local nativeBuild = build
local function displayName(family)
  return family:gsub("(%l)(%w*)", function(first, rest)
    return string.upper(first) .. rest
  end)
end

function build(directory, config, parameters, level, seed)
  local builtConfig, builtParameters = nativeBuild(directory, config, parameters, level, seed)
  local lineage = builtParameters.hybridLineage
  if not lineage then return builtConfig, builtParameters end

  local parents = lineage.parentFamilies or {}
  local frame = "drone"
  if root.itemHasTag(config.itemName, "queen") then
    frame = "queen"
  elseif root.itemHasTag(config.itemName, "youngQueen") then
    frame = "youngQueen"
  end

  if #parents == 2 then
    builtConfig.inventoryIcon = {
      {image = string.format("/bees/bees/%s.png:%s?scalenearest=0.65", parents[1], frame), position = {-3, 0}},
      {image = string.format("/bees/bees/%s.png:%s?scalenearest=0.65", parents[2], frame), position = {3, 0}}
    }
    local name = displayName(parents[1]) .. " × " .. displayName(parents[2]) .. " Hybrid"
    local priority = lineage.subspecies == 1 and lineage.queenFamily or lineage.droneFamily
    local role = lineage.subspecies == 1 and "Queen" or "Drone"
    builtConfig.shortdescription = name
    builtConfig.tooltipFields.subTitle = name .. " — " .. role .. "-parent dominant (" .. displayName(priority) .. ")"
    builtConfig.tooltipFields.hybridParentsLabel = "Parents: " .. displayName(parents[1]) .. " × " .. displayName(parents[2])
    if lineage.genomeExceptions and #lineage.genomeExceptions > 0 then
      builtConfig.tooltipFields.genomeExceptionLabel = "Some genes were already at the limit and could not be weakened further."
    end
  end

  return builtConfig, builtParameters
end
