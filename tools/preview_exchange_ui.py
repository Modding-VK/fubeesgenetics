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
    from PIL import Image
    from io import BytesIO
    sprite = Image.open(ROOT/'.cache/fu/objects/generic/cropshipper/cropshipperkhe.png').convert('RGBA').crop((128,0,192,80))
    sprite.alpha_composite(Image.open(mod/'objects/bees/fubeesgenetics/beeexchange/autorefugee-plaque.png').convert('RGBA'))
    sprite_data=BytesIO();sprite.save(sprite_data,format='PNG')
    # Offline GIF follows the same FU frames, fullbright layer and sign order.
    sheet=Image.open(ROOT/'.cache/fu/objects/generic/cropshipper/cropshipperkhe.png').convert('RGBA')
    bright=Image.open(native/'objects/generic/cropshipper/cropshipperfullbright.png').convert('RGBA')
    sign=Image.open(mod/'objects/bees/fubeesgenetics/beeexchange/autorefugee-plaque.png').convert('RGBA')
    grid=json.loads((native/'objects/generic/cropshipper/default.frames').read_text())['frameGrid']
    indices={name:i for i,name in enumerate(grid['names'][0])}
    sequence=[('ready.1',100),('ready.2',100)]
    sequence += [('ship.'+str(i),87) for i in range(1,24)]
    sequence += [('closed.'+str(i%2+1),100) for i in range(15)]
    sequence += [('open.'+str(i),100) for i in range(1,5)]
    sequence += [('ready.1',100),('ready.2',100)]
    frames=[]
    for name,duration in sequence:
        x=indices[name]*64
        frame=sheet.crop((x,0,x+64,80))
        frame.alpha_composite(bright.crop((x,0,x+64,80)))
        frame.alpha_composite(sign)
        bg=Image.new('RGBA',(64,80),'#263039');bg.alpha_composite(frame)
        frames.append(bg.convert('RGB').resize((192,240),Image.Resampling.NEAREST))
    gif=ROOT/'artwork/implemented/beeexchange-0.2.3-shipment.gif'
    gif.parent.mkdir(parents=True,exist_ok=True)
    frames[0].save(gif,save_all=True,append_images=frames[1:],duration=[ms for _,ms in sequence],loop=0,disposal=2)

    elements=[]
    def source(path):
        if path=='/__preview/beeexchange.png':
            return 'data:image/png;base64,'+base64.b64encode(sprite_data.getvalue()).decode(),(64,80)
        asset=mod/path.lstrip('/')
        if not asset.is_file():asset=native/path.lstrip('/')
        data=asset.read_bytes()
        return 'data:image/png;base64,'+base64.b64encode(data).decode(),struct.unpack('>II',data[16:24])
    def img(path,x,y,width=None,height=None,extra=''):
        url,(w,h)=source(path)
        elements.append(f'<img src="{url}" style="left:{x}px;bottom:{y}px;width:{width or w}px;height:{height or h}px" {extra}>')
    def label(text,x,y,extra=''):
        elements.append(f'<span style="left:{x}px;bottom:{y}px;{extra}">{text}</span>')
    b=gui['background']
    footer=source(b['fileFooter'])[1][1];body=source(b['fileBody'])[1][1];header=source(b['fileHeader'])[1][1]
    pane_height=footer+body+header
    img(b['fileFooter'],0,0);img(b['fileBody'],0,footer);img(b['fileHeader'],0,footer+body)
    # The engine supplies these title widgets and object preview dynamically.
    obj='/__preview/beeexchange.png'
    icon='/objects/generic/cropshipper/cropshippericon.png'
    img(icon,6,pane_height-24,20,20);label('Bee Exchange',34,pane_height-11)
    label('Storage',34,pane_height-21,'color:#aaa')
    img(obj,gui['objectImage']['position'][0]-16,gui['objectImage']['position'][1]-20,32,40)
    label('16 SLOTS',*gui['count']['position'],'transform:translateX(-50%)')
    cells=[]
    for name in ['itemGrid']:
        grid=gui[name];nx,ny=grid['dimensions'];x0,y0=grid['position']
        for i in range(nx*ny):
            x=x0+i%nx*19;y=y0+(ny-1-i//nx)*19;index=grid['slotOffset']+i
            img(grid['backingImage'],x,y,extra=f'class="cell" data-slot="{index}"')
            cells.append((index,x,y))
    img(gui['overlay']['file'],*gui['overlay']['position'],extra='class="overlay"')
    img(gui['clear']['base'],*gui['clear']['position'])
    label('Take all',gui['clear']['position'][0]+31,gui['clear']['position'][1]+2,'transform:translateX(-50%)')
    img(gui['close']['base'],*gui['close']['position'])
    slot_json=json.dumps(cells)
    coin_url,coin_size=source('/items/currency/money.png')
    icon_url,icon_size=source(icon)
    border_url,_=source('/interface/inventory/itembordercommon.png')
    sprite_url,_ = source(obj)
    html='''<!doctype html><meta charset="utf-8"><title>Bee Exchange 0.2.3 layout review</title>
<style>body{background:#10151a;color:#dce4e9;font:16px sans-serif;padding:24px}h1{font-size:22px}
#review{display:inline-block;background:#171f25;padding:20px}#pane{position:relative;width:166px;height:175px;zoom:3;image-rendering:pixelated}
#pane img,#pane span{position:absolute;pointer-events:none}#pane span{font:bold 8px monospace;white-space:pre;text-shadow:1px 1px #111}
#pane .cell{pointer-events:auto;cursor:pointer}.overlay{pointer-events:none}button{margin:18px 6px 10px 0;padding:8px 14px}
</style><h1>Bee Exchange — 0.2.3-dev</h1><p>Revisão offline com assets nativos. Não é captura do jogo; fonte aproximada.</p><div id="review"><div id="pane">'''+''.join(elements)+'''</div></div><aside style="display:inline-block;vertical-align:top;margin-left:24px;padding:16px;background:#263039"><h2>Auto Refugee</h2><img style="image-rendering:pixelated;width:192px;height:240px" src="'''+sprite_url+'''"><p>Sprite nativo 64×80, escala 3×.</p></aside><p><button id="toggle">Mostrar exemplos</button><button id="clear">Esvaziar exemplos</button></p>
<p>16 slots físicos (0–15). Clique em um slot para alternar um ícone de exemplo.</p>
<script>
const slots=SLOTS,coin=COIN,icon=ICON,border=BORDER;
const coinSize=COINSIZE,iconSize=ICONSIZE;
function fill(i){if(document.querySelector('[data-example="'+i+'"]'))return;const [,x,y]=slots[i];
const el=document.createElement('div');el.dataset.example=i;el.style='position:absolute;pointer-events:none;left:'+x+'px;bottom:'+y+'px;width:19px;height:19px';
const isCoin=i===0,size=isCoin?coinSize:iconSize,src=isCoin?coin:icon;
el.innerHTML='<img src="'+border+'" style="left:0;bottom:0;width:18px;height:18px"><img class="exampleIcon" src="'+src+'" style="left:'+(9-size[0]/2)+'px;bottom:'+(9-size[1]/2)+'px;width:'+size[0]+'px;height:'+size[1]+'px"><span style="right:1px;bottom:0;font-size:8px">'+(isCoin?'7':'')+'</span>';
document.querySelector('#pane').append(el);}
function clear(){document.querySelectorAll('[data-example]').forEach(e=>e.remove());}
document.querySelector('#toggle').onclick=()=>[0,5,12,15].forEach(fill);
document.querySelector('#clear').onclick=clear;
document.querySelectorAll('.cell').forEach(e=>e.onclick=()=>{const i=+e.dataset.slot,old=document.querySelector('[data-example="'+i+'"]');if(old)old.remove();else fill(i);});
window.layoutReady=true;
</script>'''
    for key,value in {'SLOTS':slot_json,'COINSIZE':json.dumps(coin_size),'ICONSIZE':json.dumps(icon_size),
                      'COIN':json.dumps(coin_url),'ICON':json.dumps(icon_url),'BORDER':json.dumps(border_url)}.items():
        html=html.replace('='+key,'='+value)
    html=html.replace('height:175px','height:'+str(pane_height)+'px')
    output=ROOT/'artwork/implemented/beeexchange-0.2.3.html'
    output.parent.mkdir(parents=True,exist_ok=True);output.write_text(html)
    print(output)


if __name__=='__main__':main()
