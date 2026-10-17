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
    for op in asset_json((ic_root/'interface/chests/chest16.config.patch').read_text()):
        parts=op['path'].strip('/').split('/');target=window
        for part in parts[:-1]: target=target[int(part)] if isinstance(target,list) else target[part]
        key=int(parts[-1]) if isinstance(target,list) else parts[-1]
        assert op['op'] in {'add','replace'}
        target[key]=op['value']
    assert window['gui']['itemGrid']==original['gui']['itemGrid']
    assert window['scripts']==['/scripts/v6/improvedcontainergui.lua']
    assert window['gui']['icSortButton']['callback']=='ic.sort'
    enriched=dict(fixture,icRoot=str(ic_root),nativeRoot=str(native_root),nativeUi=original,icUi=window)
    with tempfile.TemporaryDirectory(prefix='bee-ic-checks-') as temporary:
        script=Path(temporary)/'run.lua'
        script.write_text('fixture = '+lua(enriched)+'\ndofile('+lua(str(root/'tests/storage_compat_test.lua'))+')\n')
        run_lua(script)
