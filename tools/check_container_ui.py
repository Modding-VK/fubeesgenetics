"""Verify native container references and Bee Exchange geometry against engine assets."""
import hashlib
import json
from pathlib import Path
import urllib.request


def load_references(root, fetch=False):
    manifest = json.loads((root/'tools/ui_upstream.json').read_text())
    cache = root/'.cache/ui-reference'
    for source in manifest['sources']:
        for path, expected in source['files'].items():
            target = cache/source['cache_directory']/path
            if fetch:
                url = 'https://raw.githubusercontent.com/'+source['repository']+'/'+source['commit']+'/'+path
                with urllib.request.urlopen(url, timeout=30) as response:
                    data = response.read()
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(data)
            if not target.is_file():
                raise RuntimeError(f'Missing {target}; use --fetch.')
            data = target.read_bytes()
            actual = hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
            if actual != expected:
                raise RuntimeError(f'Native UI reference blob mismatch: {path}')
    return cache/'starbound/assets/packed'


def check_container_ui(root, native_root):
    from run_checks import asset_json
    from check_assets import png_size
    mod = root/'FUBeesGenetics'
    gui = json.loads((mod/'interface/fubeesgenetics/beeexchange/beeexchange.config').read_text())['gui']
    vanilla = json.loads((native_root/'interface/chests/chest16.config').read_text())['gui']
    interface = asset_json((native_root/'interface.config').read_text())
    draggable = interface['itemDraggableArea']
    assert draggable == [-2,-2,19,19]
    assert png_size(native_root/'interface/inventory/empty.png') == (18,18)
    assert gui['background'] == vanilla['background']
    assert gui['objectImage'] == vanilla['objectImage']
    assert gui['clear']['caption'] == 'Take all' and gui['clear']['pressed'] == vanilla['clear']['hover']
    assert 'press' not in gui['clear'] and gui['close'] == vanilla['close']
    assert gui['count']['value'] == '<slots> SLOTS'
    assert gui['overlay']['mouseTransparent']
    assert "itemGrid2" not in gui
    positions,indices = [],[]
    for name,dimensions,origin,offset in [('itemGrid',[4,4],[81,42],0)]:
        grid=gui[name]
        assert grid['dimensions']==dimensions and grid['position']==origin and grid['slotOffset']==offset
        assert grid['spacing']==[19,19]
        assert grid['backingImage']=='/interface/inventory/empty.png'
        assert grid['showBackingImageWhenEmpty'] and grid['showBackingImageWhenFull']
        size=png_size(native_root/grid['backingImage'].lstrip('/'))
        # ItemSlotWidget sizes to max(itemDraggableArea.max, backingImage.size).
        child_size=[max(draggable[i+2],size[i]) for i in range(2)]
        assert child_size==[19,19]
        for i in range(dimensions[0]*dimensions[1]):
            # ItemGridWidget::locOfItemSlot: left to right, rows top to bottom.
            x=origin[0]+i%dimensions[0]*19
            y=origin[1]+(dimensions[1]-1-i//dimensions[0])*19
            assert [x+child_size[0]//2,y+child_size[1]//2]==[x+size[0]//2,y+size[1]//2]
            assert 0<=x<x+19<=166 and 42<=y<y+19<=120
            positions.append((x,y));indices.append(offset+i)
    assert len(set(positions))==16 and indices==list(range(16))
    # No drawn cells overlap another cell or the object preview on the left.
    for i,(x,y) in enumerate(positions):
        for xx,yy in positions[i+1:]:
            assert x+19<=xx or xx+19<=x or y+19<=yy or yy+19<=y
        assert x>=60 or y+19<=84
    obj=json.loads((mod/'objects/bees/fubeesgenetics/beeexchange/beeexchange.object').read_text())
    assert obj['hasWindowIcon'] and obj['slotCount']==16
