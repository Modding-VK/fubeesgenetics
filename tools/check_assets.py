"""Static asset contracts; no Starbound runtime is simulated here."""
import copy
import json
from pathlib import Path
import struct
import zlib


def png_size(path):
    data = path.read_bytes()
    assert data[:8] == b'\x89PNG\r\n\x1a\n', path
    offset, pixels, size = 8, b'', None
    while offset < len(data):
        length = struct.unpack('>I', data[offset:offset+4])[0]
        kind = data[offset+4:offset+8]
        payload = data[offset+8:offset+8+length]
        crc = struct.unpack('>I', data[offset+8+length:offset+12+length])[0]
        assert zlib.crc32(kind + payload) & 0xffffffff == crc, path
        if kind == b'IHDR':
            w,h,depth,color,compression,filtering,interlace = struct.unpack('>IIBBBBB',payload)
            assert (depth,color,compression,filtering,interlace) == (8,6,0,0,0), path
            size = w,h
        elif kind == b'IDAT': pixels += payload
        offset += length + 12
        if kind == b'IEND': break
    assert size and len(zlib.decompress(pixels)) == size[1] * (1+size[0]*4), path
    assert offset == len(data), path
    return size


def apply_patch(document, operations):
    result = copy.deepcopy(document)
    for op in operations:
        if isinstance(op,list):
            try: result = apply_patch(result,op)
            except AssertionError: pass
        elif op['op'] == 'test':
            key = op['path'].lstrip('/')
            match = key in result and ('value' not in op or result[key] == op['value'])
            assert not match if op.get('inverse') else match
        elif op['op'] == 'add':
            key = op['path'].lstrip('/')
            if key.endswith('/-'): result[key[:-2]].append(copy.deepcopy(op['value']))
            else: result[key] = copy.deepcopy(op['value'])
        else: raise AssertionError('Unexpected patch operation')
    return result


def check_assets(root, fu_root, native_root):
    from run_checks import asset_json
    mod = root/'FUBeesGenetics'
    count = 0
    def passed(label):
        nonlocal count
        count += 1
        print('PASS '+label)
    docs = {p:json.loads(p.read_text()) for p in mod.rglob('*') if p.suffix in {'.object','.config','.recipe','.patch','.animation'}}
    objects = [(p,d) for p,d in docs.items() if p.suffix == '.object']
    assert {d["objectName"] for _,d in objects} == {"fubeesgenetics_geneticqueenfilter", "fubeesgenetics_beeexchange"}
    path,obj = next((p,d) for p,d in objects if d["objectName"] == "fubeesgenetics_geneticqueenfilter")
    ident = 'fubeesgenetics_geneticqueenfilter'
    assert obj['objectName'] == ident and obj['objectType'] == 'container' and obj['slotCount'] == 3
    passed('S1 JSON and true three-slot container')
    orientation, = obj['orientations']
    assert obj['printable'] is False and orientation['anchors'] == ['bottom']
    assert orientation['frames'] == 1 and 'image' not in orientation and 'flipImages' not in orientation
    assert set(map(tuple,orientation['spaces'])) == {(x,y) for x in range(5) for y in range(4)}
    assert png_size(path.parent/orientation['dualImage']) == (40,32)
    assert png_size(path.parent/obj['inventoryIcon']) == (20,20)
    assert not {'animation','lightColor','consumeFuel','kheAA_slotLimits'} & obj.keys()
    passed('S2 static footprint, icon, non-printable and native dualImage facing')
    for p in mod.rglob('*.png'): png_size(p)
    ui_dir = mod/'interface/fubeesgenetics/geneticqueenfilter'
    native_sizes = {'header.png':(388,34), 'body.png':(388,286), 'footer.png':(388,12),
                    'dna.png':(20,20), 'close.png':(12,12), 'closehover.png':(12,12),
                    'arrowup.png':(7,7), 'arrowdown.png':(7,7)}
    native_sizes.update({name+'.png':(24,24) for name in ['approvedslot','inputslot','rejectedslot']})
    native_sizes.update({name+'.png':(18,18) for name in ['radio','radiohover','radiochecked','radiocheckedhover']})
    native_sizes.update({name+'.png':(100,20) for name in ['reset','resethover','resetpress']})
    for name,size in native_sizes.items(): assert png_size(ui_dir/name) == size
    passed('S3 PNG CRC and decompressed image sizes')
    def refs(value):
        if isinstance(value,dict):
            for child in value.values(): refs(child)
        elif isinstance(value,list):
            for child in value: refs(child)
        elif isinstance(value,str) and value.startswith('/') and not value.startswith('//'):
            target = value.split(':')[0].split('?')[0]
            assert (mod/target.lstrip('/')).is_file() or (native_root/target.lstrip('/')).is_file() or (fu_root/target.lstrip('/')).is_file(), target
    refs(obj)
    ui = json.loads((mod/obj['uiConfig'].lstrip('/')).read_text())
    refs(ui)
    passed('S4 shipped object and interface paths resolve')
    gui = ui['gui']
    for name,off,x,frame in [('itemGrid',1,60,'approvedFrame'),('itemGrid2',0,180,'inputFrame'),('outputItemGrid',2,300,'rejectedFrame')]:
        assert gui[name]['type']=='itemgrid' and gui[name]['slotOffset']==off and gui[name]['position']==[x+3,38]
        assert gui[name]['dimensions']==[1,1] and gui[name]['spacing']==[19,19]
        assert gui[name]['backingImage']==''
        assert not gui[name]['showBackingImageWhenFull'] and not gui[name]['showBackingImageWhenEmpty']
        f=gui[frame]
        assert f['type']=='image' and f['position']==[x,35] and f['mouseTransparent']
        assert f['centered'] is False and f['trim'] is False
        assert f['zlevel'] < gui[name]['zlevel'] and png_size(mod/f['file'].lstrip('/'))==(24,24)
        # Native ItemSlot uses integer half-size 19//2; it must match the frame center.
        assert [v+19//2 for v in gui[name]['position']]==[v+24//2 for v in f['position']]
    passed('S5 static frames, native item centering and inventory offsets')
    for t in ['baseProduction','droneToughness','droneBreedRate','queenBreedRate','queenLifespan','mutationChance']:
        group = gui[t+'Modes']
        assert group['type']=='radioGroup' and group['callback']=='modeChanged'
        assert [b['id'] for b in group['buttons']] == [0,1,2]
        assert all(b.get('data') == {'modeGroup':t+'Modes'} for b in group['buttons'])
        assert sum(bool(b.get('selected')) for b in group['buttons']) == 1
    for w in gui.values():
        if isinstance(w,dict) and w.get('type')=='button': assert 'press' not in w and 'pressed' in w
    assert set(ui['scriptWidgetCallbacks'])=={'modeChanged','resetProfile'}
    passed('S6 exclusive selectors, callbacks and pressed artwork')
    recipe = next(d for p,d in docs.items() if p.suffix=='.recipe' and d['output']['item']==ident)
    assert {v['item']:v['count'] for v in recipe['input']} == {'aichip':2,'laserdiode':5,'skathreinforcedglass':5,'titaniumbar':10,
        'liquidhealing':10,'liquidsulphuricacid':5,'unknowngene':2}
    assert recipe['output']=={'item':ident,'count':1}
    assert set(recipe['groups'])=={'mod','beestation','tools','all','functional'}
    for name in ['aichip','skathreinforcedglass','liquidsulphuricacid','unknowngene']:
        items = [asset_json(p.read_text()) for p in (fu_root/'items').rglob('*') if p.suffix in {'.item','.liqitem'}]
        assert any(i['itemName']==name for i in items)
    passed('S7 recipe IDs quantities and station groups')
    patch = next(d for p,d in docs.items() if p.suffix=='.patch')
    for before in [{}, {'learnBlueprintsOnPickup':['existing']},asset_json((fu_root/'objects/bees/beestation/beestation.object').read_text())]:
        after = apply_patch(before,patch)
        assert after['learnBlueprintsOnPickup'] == before.get('learnBlueprintsOnPickup',[])+[ident,'fubeesgenetics_beeexchange']
        assert {k:v for k,v in after.items() if k!='learnBlueprintsOnPickup'} == {k:v for k,v in before.items() if k!='learnBlueprintsOnPickup'}
    passed('S8 conditional blueprint patch preserves existing entries')
    c=gui['helpCanvas']
    assert c['mouseTransparent'] and not c['captureMouseEvents'] and not c['captureKeyboardEvents']
    assert ui['helpTexts']=={
        'gte':'Accept if candidate value is equal to or greater than the reference.',
        'lte':'Accept if candidate value is equal to or lower than the reference.',
        'ignore':'Ignore this trait. Its stored reference will not change.',
        'reference':'Genetic value currently used for comparison.'}
    assert len(ui['helpRegions'])==28
    for region in ui['helpRegions']:
        assert region['key'] in ui['helpTexts']
        x1,y1,x2,y2=region['rect'];assert 0<=x1<x2<=388 and 0<=y1<y2<=332
        for name in ['itemGrid','itemGrid2','outputItemGrid']:
            x,y=gui[name]['position'];assert x2<=x or x1>=x+24 or y2<=y or y1>=y+24
    passed('S9 exact help text and mouse-transparent non-capturing canvas')
    exchange_path,exchange = next((p,d) for p,d in objects if d['objectName']=='fubeesgenetics_beeexchange')
    shipper=asset_json((fu_root/'objects/generic/cropshipper/cropshipper_kheAA2.object').read_text())
    assert shipper['shortdescription']=='Terramart Shipments 3.5'
    assert exchange['objectType']=='container' and exchange['slotCount']==16 and shipper['slotCount']==40
    assert png_size(exchange_path.parent/'autorefugee-plaque.png')==(64,80)
    assert exchange['inventoryIcon']=='/objects/generic/cropshipper/cropshippericon.png'
    assert png_size(native_root/exchange['inventoryIcon'].lstrip('/'))==(16,16)
    orientation=exchange['orientations'][0]
    assert orientation['imagePosition']==[-8,0]
    assert set(map(tuple,orientation['spaces']))=={(x,y) for x in range(6) for y in range(5)}
    assert orientation['imageLayers']==[{'image':'static.png'}]
    animation=docs[mod/exchange['animation'].lstrip('/')]
    refs(animation)
    states=animation['animatedParts']['stateTypes']['machine']['states']
    assert states['work']['frames']==20 and states['work']['cycle']==1.25
    assert states['work']['transition']=='ready'
    assert states['work']['frameProperties']['immediateSound'][8]=='/sfx/tools/teleport_up.ogg'
    assert exchange['animationPosition']==[-8,0]
    for name in ['specimen','teleport']:
        assert png_size(exchange_path.parent/(name+'.png'))==(1344,80)
    assert png_size(exchange_path.parent/'static.png')==(64,80)
    assert animation['animatedParts']['parts']['teleport']['properties']['fullbright']
    assert states['ready']['frames']==2 and states['ready']['cycle']==0.2
    display=animation['animatedParts']['parts']['display']
    assert display['properties']['fullbright'] and display['properties']['zLevel']==3
    assert png_size(exchange_path.parent/'display.png')==(1408,80)
    display_names=json.loads((exchange_path.parent/'display.frames').read_text())['frameGrid']['names'][0]
    assert display_names==['ready.1','ready.2']+['work.'+str(i) for i in range(1,21)]
    for race in ['human','apex','avian','floran','glitch','hylotl','novakid','generic']:
        assert exchange[race+'Description'].strip()

    refs(exchange)
    exchange_ui=json.loads((mod/exchange['uiConfig'].lstrip('/')).read_text())
    refs(exchange_ui)
    grid=exchange_ui['gui']['itemGrid']
    assert grid['dimensions']==[4,4] and grid['spacing']==[19,19] and grid['slotOffset']==0
    assert not exchange['printable']
    passed('S10 Bee Exchange 16-slot container and native grid assets')
    exchange_recipe=next(d for p,d in docs.items() if p.suffix=='.recipe' and d['output']['item']=='fubeesgenetics_beeexchange')
    assert exchange_recipe['input']==[{'item':'beerefuge','count':1},{'item':'cropshipper_kheAA2','count':1},{'item':'aichip','count':2}]
    assert exchange_recipe['groups']==recipe['groups']
    assert exchange_recipe['output']['count']==1
    refuge=asset_json((fu_root/'objects/bees/beerefuge/beerefuge.object').read_text())
    assert refuge['objectName']=='beerefuge' and shipper['objectName']=='cropshipper_kheAA2'
    passed('S11 exact Bee Refuge/Terramart/AI Chips recipe and shared unlock')
    trade_manifest=docs[exchange_path.parent/'trades.config']
    expected={str('/'+str(p.relative_to(fu_root))) for p in (fu_root/'recipes/bees/beerefuge').rglob('*.recipe')
              if len((r:=asset_json(p.read_text()))['input'])==1 and r['input'][0]['item'].startswith('bee_')}
    assert set(trade_manifest['recipes'])==expected and len(expected)==105
    assert len(trade_manifest['recipes'])==len(set(trade_manifest['recipes']))
    passed('S12 all 105 pinned Bee Refuge trades included, no codex trades')
    from check_container_ui import check_container_ui
    check_container_ui(root, native_root)
    passed('S13 native chest layout, visible slots, exact centering and offsets 0-15')
    print(f'Assets: {count} test groups passed (static checks).')
