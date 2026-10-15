#!/usr/bin/env python3
"""Generate an offline native-asset Bee Exchange layout review; not an engine capture."""
import base64
import json
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1]


def main():
    from check_container_ui import load_references
    native = load_references(ROOT)
    mod = ROOT/'FUBeesGenetics'
    gui = json.loads((mod/'interface/fubeesgenetics/beeexchange/beeexchange.config').read_text())['gui']
    elements=[]
    def source(path):
        asset=mod/path.lstrip('/')
        if not asset.is_file():asset=native/path.lstrip('/')
        data=asset.read_bytes()
        return 'data:image/png;base64,'+base64.b64encode(data).decode(),struct.unpack('>II',data[16:24])
    def img(path,x,y,width=None,height=None,extra=''):
        url,(w,h)=source(path)
        elements.append(f'<img src="{url}" style="left:{x}px;bottom:{y}px;width:{width or w}px;height:{height or h}px" {extra}>')
    def label(text,x,y,extra=''):
        elements.append(f'<span style="left:{x}px;bottom:{y}px;{extra}">{text}</span>')
    b=gui['background'];img(b['fileFooter'],0,0);img(b['fileBody'],0,25);img(b['fileHeader'],0,150)
    # The engine supplies these title widgets and object preview dynamically.
    obj='/objects/bees/fubeesgenetics/beeexchange/beeexchange.png'
    icon='/objects/bees/fubeesgenetics/beeexchange/beeexchangeicon.png'
    img(icon,6,151,20,20);label('Bee Exchange',34,164)
    label('Storage',34,154,'color:#aaa')
    img(obj,20,87,40,33)
    label('20 SLOTS',120,140,'transform:translateX(-50%)')
    cells=[]
    for name in ['itemGrid','itemGrid2']:
        grid=gui[name];nx,ny=grid['dimensions'];x0,y0=grid['position']
        for i in range(nx*ny):
            x=x0+i%nx*19;y=y0+(ny-1-i//nx)*19;index=grid['slotOffset']+i
            img(grid['backingImage'],x,y,extra=f'class="cell" data-slot="{index}"')
            cells.append((index,x,y))
    img(gui['overlay']['file'],0,3,extra='class="overlay"')
    img(gui['clear']['base'],*gui['clear']['position'])
    label('Take all',83,28,'transform:translateX(-50%)')
    img(gui['close']['base'],*gui['close']['position'])
    slot_json=json.dumps(cells)
    coin_url,coin_size=source('/items/currency/money.png')
    icon_url,icon_size=source(icon)
    border_url,_=source('/interface/inventory/itembordercommon.png')
    html='''<!doctype html><meta charset="utf-8"><title>Bee Exchange 0.2.1 layout review</title>
<style>body{background:#10151a;color:#dce4e9;font:16px sans-serif;padding:24px}h1{font-size:22px}
#review{display:inline-block;background:#171f25;padding:20px}#pane{position:relative;width:166px;height:175px;zoom:3;image-rendering:pixelated}
#pane img,#pane span{position:absolute;pointer-events:none}#pane span{font:bold 8px monospace;white-space:pre;text-shadow:1px 1px #111}
#pane .cell{pointer-events:auto;cursor:pointer}.overlay{pointer-events:none}button{margin:18px 6px 10px 0;padding:8px 14px}
</style><h1>Bee Exchange — 0.2.1-dev</h1><p>Revisão offline com assets nativos. Não é captura do jogo; fonte aproximada.</p><div id="review"><div id="pane">'''+''.join(elements)+'''</div></div><p><button id="toggle">Mostrar exemplos</button><button id="clear">Esvaziar exemplos</button></p>
<p>20 slots físicos (0–19). Clique em um slot para alternar um ícone de exemplo.</p>
<script>
const slots=SLOTS,coin=COIN,icon=ICON,border=BORDER;
const coinSize=COINSIZE,iconSize=ICONSIZE;
function fill(i){if(document.querySelector('[data-example="'+i+'"]'))return;const [,x,y]=slots[i];
const el=document.createElement('div');el.dataset.example=i;el.style='position:absolute;pointer-events:none;left:'+x+'px;bottom:'+y+'px;width:19px;height:19px';
const isCoin=i===0,size=isCoin?coinSize:iconSize,src=isCoin?coin:icon;
el.innerHTML='<img src="'+border+'" style="left:0;bottom:0;width:18px;height:18px"><img class="exampleIcon" src="'+src+'" style="left:'+(9-size[0]/2)+'px;bottom:'+(9-size[1]/2)+'px;width:'+size[0]+'px;height:'+size[1]+'px"><span style="right:1px;bottom:0;font-size:8px">'+(isCoin?'7':'')+'</span>';
document.querySelector('#pane').append(el);}
function clear(){document.querySelectorAll('[data-example]').forEach(e=>e.remove());}
document.querySelector('#toggle').onclick=()=>[0,5,16,19].forEach(fill);
document.querySelector('#clear').onclick=clear;
document.querySelectorAll('.cell').forEach(e=>e.onclick=()=>{const i=+e.dataset.slot,old=document.querySelector('[data-example="'+i+'"]');if(old)old.remove();else fill(i);});
window.layoutReady=true;
</script>'''
    for key,value in {'SLOTS':slot_json,'COINSIZE':json.dumps(coin_size),'ICONSIZE':json.dumps(icon_size),
                      'COIN':json.dumps(coin_url),'ICON':json.dumps(icon_url),'BORDER':json.dumps(border_url)}.items():
        html=html.replace('='+key,'='+value)
    output=ROOT/'artwork/implemented/beeexchange-0.2.1.html'
    output.parent.mkdir(parents=True,exist_ok=True);output.write_text(html)
    print(output)


if __name__=='__main__':main()
