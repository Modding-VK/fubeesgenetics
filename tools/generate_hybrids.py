#!/usr/bin/env python3
"""Rebuild the hybrid catalog from pinned FU data and selected parental plants."""
import argparse
import itertools
import json
from pathlib import Path
from run_checks import ROOT, MANIFEST, asset_json


def generate(fu_root):
    data = asset_json((fu_root / 'bees/beeData.config').read_text())
    plants = asset_json((ROOT / 'tools/hybrid_plants.json').read_text())
    families = sorted(data['stats'])
    rivals = {family: set() for family in families}
    for family, entries in data['rivals'].items():
        for rival in [entries] if isinstance(entries, str) else entries:
            if family in rivals and rival in rivals:
                rivals[family].add(rival)
                rivals[rival].add(family)
    parents = {}
    for family in families:
        assert family in plants
        parents[family] = {
            'subspecies': [dict(id=i, name=s['name'], baseProduction=s['baseProduction'],
                                production=s['production']) for i, s in enumerate(data['stats'][family], 1)],
            'favoritePlant': plants[family], 'rivalFamilies': sorted(rivals[family])}
    hybrids = []
    for a, b in itertools.combinations(families, 2):
        is_rival = b in rivals[a]
        inherited = rivals[a] | rivals[b]
        if is_rival:
            inherited |= {a, b}
        hybrids.append({
            'id': f'hybrid_{a}_{b}', 'name': f'{a.capitalize()} × {b.capitalize()} Hybrid',
            'parentFamilies': [a, b],
            'subspecies': [
                {'id': 1, 'name': 'Queen-parent-dominant', 'priorityParent': 'queenParent',
                 'productionWeights': {'queenParent': .5, 'droneParent': .25}},
                {'id': 2, 'name': 'Drone-parent-dominant', 'priorityParent': 'droneParent',
                 'productionWeights': {'queenParent': .25, 'droneParent': .5}}],
            'preferredPlants': [dict(parent=f, **plants[f]) for f in [a, b]],
            'outputResources': sorted({resource for f in [a, b] for s in data['stats'][f] for resource in s['production']}),
            'rivalNativeFamilies': sorted(inherited),
            'rivalHybridRule': 'Rival when either hybrid has a parental family in the other hybrid\'s rivalNativeFamilies; identical hybrid species are compatible.',
            'parentSpeciesAreRivals': is_rival, 'hybridizationSuccessChance': .1 if is_rival else .3})
    return {
        'source': {'repository': MANIFEST['repository'], 'commit': MANIFEST['commit'], 'beeFamilies': len(families)},
        'speciesCount': len(hybrids),
        'naming': {'species': '<Parent A> × <Parent B> Hybrid',
                   'canonicalParentOrder': 'alphabetical by FU family ID',
                   'subspecies': ['Queen-parent-dominant', 'Drone-parent-dominant']},
        'visuals': {'spriteCountPerHybridSpecies': 1, 'sharedBySubspecies': True,
                    'inheritance': 'Complementary halves of native parental sprites form one bee at native scale.',
                    'subspeciesChangeAppearance': False,
                    'artStatus': 'Runtime composition for items; shared by both subspecies. The powered apiary does not spawn capturable world bees.'},
        'production': {'quantitiesAreRelativeToParentNativeRate': True,
                       'weights': {'priorityParent': .5, 'secondaryParent': .25},
                       'calculation': 'For each parent, multiply its weighted native rate by ((drone baseProduction + 1) * apiary multiplier + frame bonus) / (that parent native baseProduction + 1). Sum contributions per resource, then apply native environmental efficiency. Fixed parental references preserve genetic effects; the floor prevents zero denominators and sterile zero-gene hybrids.',
                       'parents': parents},
        'rivalry': {'nativeRelationsAreSymmetric': True, 'rivalParentsAlsoBecomeRivalsOfHybrid': True},
        'hybrids': hybrids}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--fu-root', type=Path, default=ROOT / '.cache/fu')
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    expected = generate(args.fu_root)
    for path in [ROOT / 'FUBeesGenetics/bees/hybridSpecies.config', ROOT / 'docs/HYBRID_SPECIES_CATALOG.json']:
        if args.check:
            assert asset_json(path.read_text()) == expected, f'Stale catalog: {path}'
        else:
            path.write_text(json.dumps(expected, indent=2, ensure_ascii=False) + '\n')
    print(f'Hybrid catalog: {expected["speciesCount"]} pairs; ' + ('verified' if args.check else 'generated'))


if __name__ == '__main__':
    main()
