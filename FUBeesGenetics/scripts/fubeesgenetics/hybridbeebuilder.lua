require "/bees/beeBuilder.lua"

local nativeBuild = build
local function displayName(family) return family:sub(1, 1):upper() .. family:sub(2) end
local function visualLineage(parameters)
  local lineage = parameters and parameters.hybridLineage
  local genome = parameters and parameters.genome
  if type(lineage) ~= "table" or type(genome) ~= "string" or #genome ~= 18
    or genome:find("[^0-9A-Z]") or type(lineage.parentSubtypes) ~= "table" then return nil end
  local a, b = lineage.queenFamily, lineage.droneFamily
  if type(a) ~= "string" or type(b) ~= "string" or a == b
    or not a:match("^[a-z]+$") or not b:match("^[a-z]+$")
    or not lineage.parentSubtypes[a] or not lineage.parentSubtypes[b] then return nil end
  local speciesId = a < b and "hybrid_" .. a .. "_" .. b or "hybrid_" .. b .. "_" .. a
  if lineage.speciesId ~= speciesId then return nil end
  local subtype = genome:sub(1, 2)
  if subtype ~= "01" and subtype ~= "02" then return nil end
  return {speciesId = speciesId, parentFamilies = a < b and {a, b} or {b, a},
    queenFamily = a, droneFamily = b, subspecies = subtype == "01" and 1 or 2,
    genomeExceptions = lineage.genomeExceptions}
end

function build(directory, config, parameters, level, seed)
  local builtConfig, builtParameters = nativeBuild(directory, config, parameters, level, seed)
  local lineage = visualLineage(builtParameters)
  if not lineage then return builtConfig, builtParameters end
  local frame, caste = "drone", "Drone"
  if config.itemName == "bee_hybrid_queen" then frame, caste = "queen", "Queen"
  elseif config.itemName == "bee_hybrid_youngQueen" then frame, caste = "youngQueen", "Queen Larva"
  elseif config.itemName ~= "bee_hybrid_drone" then return builtConfig, builtParameters end

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
  builtConfig.description = string.format("Hybrid %s. Works in FU Apiaries and the Overload Apiary. Prioritizes %s resources; also produces %s resources.",
    caste:lower(), displayName(priority), displayName(priority == lineage.queenFamily and lineage.droneFamily or lineage.queenFamily))
  if lineage.genomeExceptions and #lineage.genomeExceptions > 0 then
    builtConfig.description = builtConfig.description .. " Gene penalty limited for: " .. table.concat(lineage.genomeExceptions, ", ") .. "."
  end
  return builtConfig, builtParameters
end
