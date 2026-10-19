"""Optional tests against the user's original Improved Containers PAK sources."""
import hashlib,json,tempfile
from pathlib import Path

def run_storage_checks(root, ic_root, fixture, native_root):
    from run_checks import asset_json, lua, run_lua
    ic_root=ic_root.resolve()
    manifest=json.loads((root/'tools/ic_upstream.json').read_text())
    for path,digest in manifest['files'].items():
        assert hashlib.sha256((ic_root/path).read_bytes()).hexdigest()==digest,path
    window=json.loads((native_root/'interface/chests/chest16.config').read_text())
    original=json.loads(json.dumps(window))
    import copy
    def apply(document, operations):
        for op in operations:
            if isinstance(op,list):
                saved=copy.deepcopy(document)
                try: apply(document,op)
                except (KeyError,AssertionError):
                    document.clear();document.update(saved)
                continue
            parts=op['path'].strip('/').split('/');target=document
            for part in parts[:-1]: target=target[int(part)] if isinstance(target,list) else target[part]
            key=int(parts[-1]) if isinstance(target,list) and parts[-1]!='-' else parts[-1]
            if op['op']=='test':
                assert key in target
                if 'value' in op: assert target[key]==op['value']
            elif isinstance(target,list) and key=='-': target.append(op['value'])
            else:
                assert op['op'] in {'add','replace'}
                target[key]=op['value']
    bridge_patch=json.loads((root/'FUBeesGenetics/interface/chests/chest16.config.patch').read_text())
    # Without IC the conditional patch is a no-op, so it creates no dependency.
    standalone=copy.deepcopy(original);apply(standalone,bridge_patch)
    assert standalone==original
    apply(window,asset_json((ic_root/'interface/chests/chest16.config.patch').read_text()))
    apply(window,bridge_patch)
    assert window['gui']['itemGrid']==original['gui']['itemGrid']
    assert window['scripts']==['/scripts/v6/improvedcontainergui.lua','/objects/bees/fubeesgenetics/beeexchange/storagegui.lua']
    assert window['gui']['icSortButton']['callback']=='ic.sort'
    enriched=dict(fixture,icRoot=str(ic_root),nativeRoot=str(native_root),nativeUi=original,icUi=window)
    with tempfile.TemporaryDirectory(prefix='bee-ic-checks-') as temporary:
        script=Path(temporary)/'run.lua'
        script.write_text('fixture = '+lua(enriched)+'\ndofile('+lua(str(root/'tests/storage_compat_test.lua'))+')\n')
        run_lua(script)
