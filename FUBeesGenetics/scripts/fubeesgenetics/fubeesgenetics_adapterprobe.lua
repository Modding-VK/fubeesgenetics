-- Optional developer probe. Requiring this file does not create items or run tests.
require "/scripts/fubeesgenetics/fubeesgenetics_beegeneticadapter.lua"

fubeesgenetics_adapterprobe = {}

function fubeesgenetics_adapterprobe.run()
  local results = {}
  for _, name in ipairs({"bee_honey_queen", "bee_honey_youngQueen"}) do
    -- Create a real descriptor via the installed FU builder. The probe alone
    -- supplies a known inspected genome; the Adapter never creates/modifies items.
    local item = root.createItem({name = name, count = 1,
      parameters = {genome = "010001ZZ0A0BHZE000", genomeInspected = true}})
    assert(item and item.name == name, "FU item asset unavailable: " .. name)
    local result = fubeesgenetics_beegeneticadapter.read(item)
    assert(result.eligible, name .. ": " .. tostring(result.reason))
    assert(result.identity.family == "honey" and result.identity.subtype == 1,
      "Unexpected lineage: " .. name)
    assert(result.genetics.baseProduction.raw == 0, "Production decode failed")
    assert(result.genetics.droneBreedRate.raw == 1295, "Breed rate decode failed")
    assert(result.genetics.queenLifespan.raw == 11, "Genetic lifespan decode failed")
    assert(result.genetics.mutationChance.raw == 647, "Mutation raw decode failed")
    assert(result.genetics.mutationChance.display == 49.92, "Mutation display decode failed")
    results[name] = result
  end
  return results
end
