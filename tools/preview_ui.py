#!/usr/bin/env python3
"""Build a self-contained HTML layout review from shipped UI assets, not a game capture."""
import argparse
import base64
import json
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1]
UI = ROOT / 'FUBeesGenetics/interface/fubeesgenetics/geneticqueenfilter'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    config = json.loads((UI / 'fubeesgenetics_geneticqueenfilter.config').read_text())
    version = json.loads((ROOT / 'FUBeesGenetics/_metadata').read_text())['version']
    if args.output is None:
        args.output = ROOT / f'.cache/hud-{version}.html'
    images = {p.name: 'data:image/png;base64,' + base64.b64encode(p.read_bytes()).decode()
              for p in UI.glob('*.png')}
    sizes = {p.name: list(struct.unpack('>II', p.read_bytes()[16:24])) for p in UI.glob('*.png')}
    width = sizes['body.png'][0]
    height = sum(sizes[name][1] for name in ['header.png', 'body.png', 'footer.png'])
    # Own inventory icon is an illustrative occupied-slot fixture, not a live item.
    sample = ROOT / 'FUBeesGenetics/objects/bees/fubeesgenetics/geneticqueenfilter/geneticqueenfiltericon.png'
    images['sample-item.png'] = 'data:image/png;base64,' + base64.b64encode(sample.read_bytes()).decode()
    html = '''<!doctype html><html lang="en"><meta charset="utf-8">
<title>Genetic Queen Filter — native assets review __VERSION__</title>
<style>
*{box-sizing:border-box}body{margin:0;padding:24px;background:#161b23;color:#dce7f1;font:14px monospace}
#review{width:__REVIEW_WIDTH__px;height:__REVIEW_HEIGHT__px;position:relative}#pane{width:__WIDTH__px;height:__HEIGHT__px;
position:relative;transform:scale(3);transform-origin:top left;image-rendering:pixelated}
#pane>*{position:absolute}img{image-rendering:pixelated;pointer-events:none}
.label{white-space:pre;line-height:1;pointer-events:none}.button{border:0;padding:0;
background:transparent;color:#dce7f1;font:8px monospace;cursor:pointer;image-rendering:pixelated}
.button>img{position:absolute;inset:0;width:100%;height:100%}.caption{position:absolute;line-height:1;white-space:pre;transform:translate(-50%,-50%)}
.radio{width:18px;height:18px}.reset{width:100px;height:20px}.close{width:12px;height:12px}
.slot-demo{position:absolute;width:21px;height:21px;border:0;padding:0;background:transparent;cursor:pointer}
.slot-demo>img{position:absolute;left:1px;bottom:1px;width:20px;height:20px}
p{max-width:1164px;color:#aab9ca}a{color:#64d8ed}
</style><div id="review"><div id="pane"></div></div>
<p>Offline layout review using the shipped __WIDTH__×__HEIGHT__ assets, enlarged 3×. Browser text is
an approximation of the in-game font. Example profile/values; controls only change this preview.</p>
<p>Click slots to toggle an example inventory icon. Frames are separate static images.
The example icon belongs to this mod; this page does not run the game.</p>
<script>
const config=__CONFIG__, images=__IMAGES__, pane=document.querySelector('#pane');
const example={family:'Family: shrouded',subspecies:'Subspecies: Vocadahl',
status:'Status: Waiting for input',lastResult:'Last result: Approved',
baseProductionReference:'30',droneToughnessReference:'48',droneBreedRateReference:'27',
queenBreedRateReference:'21',queenLifespanReference:'982',mutationChanceReference:'3.00%'};
const sizes=__SIZES__;
const image=(file)=>{let e=document.createElement('img');e.src=images[file.split('/').pop()];return e};
function place(e,x,y,w,h,z=0){e.style.left=x+'px';e.style.bottom=y+'px';e.style.zIndex=z;if(w)e.style.width=w+'px';if(h)e.style.height=h+'px';pane.append(e)}
let backgroundY=0;
for(const file of ['footer.png','body.png','header.png']){let [w,h]=sizes[file];place(image(file),0,backgroundY,w,h);backgroundY+=h}
const radios={};
for(const [name,w] of Object.entries(config.gui)){
 if(!w.position)continue;
 const [x,y]=w.position;
 if(w.type==='label'){
  const e=document.createElement('span');e.className='label';e.id=name;e.textContent=example[name]??w.value;
  e.style.fontSize=(w.fontSize??8)+'px';e.style.color=w.color??'#dce7f1';
  e.style.lineHeight=w.lineSpacing??1.3;
  const tx=w.hAnchor==='right'?'-100%':w.hAnchor==='mid'?'-50%':'0';
  const ty=w.vAnchor==='top'?'100%':w.vAnchor==='mid'?'50%':'0';
  e.style.textAlign=w.hAnchor==='mid'?'center':w.hAnchor==='right'?'right':'left';
  e.style.transform=`translate(${tx},${ty})`;
  place(e,x,y);
 }else if(w.type==='image'){
  const file=w.file.split('/').pop();const [width,height]=sizes[file];
  const e=image(file);e.id=name;place(e,x,y,width,height,w.zlevel??0);
 }else if(w.type==='itemgrid'){
  const e=document.createElement('button');e.className='slot-demo';e.id=name;e.dataset.occupied='false';
  e.setAttribute('aria-label',name+' example item');
  const item=image('sample-item.png');item.style.display='none';e.append(item);
  e.onclick=()=>{const full=e.dataset.occupied!=='true';e.dataset.occupied=String(full);item.style.display=full?'block':'none'};
  // Native draggable area [-2,-2,19,19], child center (9,9).
  place(e,x-2,y-2,21,21,w.zlevel??0);
 }else if(w.type==='button'){
  const e=document.createElement('button');e.className='button '+(name==='close'?'close':'reset');e.id=name;
  const bg=image(w.base);e.append(bg);if(w.caption){const t=document.createElement('span');t.className='caption';t.textContent=w.caption;
   const [dx,dy]=w.textOffset??[0,0];t.style.left=`calc(50% + ${dx}px)`;t.style.top=`calc(50% - ${dy}px)`;t.style.fontSize=(w.fontSize??8)+'px';e.append(t)}
  const show=f=>bg.src=images[f.split('/').pop()];e.onmouseenter=()=>show(w.hover);e.onmouseleave=()=>show(w.base);
  e.onmousedown=()=>show(w.pressed??w.base);e.onmouseup=()=>show(w.hover);
  if(name==='resetProfile')e.onclick=()=>{for(const id of Object.keys(example))document.getElementById(id).textContent=id==='family'?'Family: —':id==='subspecies'?'Subspecies: —':id==='status'?'Status: Waiting for input':id==='lastResult'?'Last result: —':'—'};
  place(e,x,y);
 }else if(w.type==='radioGroup'){
  let selected=name==='droneBreedRateModes'?1:name==='mutationChanceModes'?2:0;
  const buttons=[];const redraw=()=>buttons.forEach((b,i)=>b.firstChild.src=images[i===selected?'radiochecked.png':'radio.png']);
  for(const b of w.buttons){
   const e=document.createElement('button');e.className='button radio';e.dataset.group=name;e.dataset.option=b.id;
   e.setAttribute('aria-label',name+' '+b.id);e.append(image('radio.png'));buttons.push(e);
   e.onclick=()=>{selected=b.id;redraw()};e.onmouseenter=()=>e.firstChild.src=images[b.id===selected?'radiocheckedhover.png':'radiohover.png'];
   e.onmouseleave=redraw;place(e,x+b.position[0],y+b.position[1],18,18);
  }redraw();radios[name]=buttons;
 }
}
window.layoutReady=true;
</script></html>'''
    html = (html.replace('__CONFIG__', json.dumps(config)).replace('__IMAGES__', json.dumps(images))
            .replace('__SIZES__', json.dumps(sizes)).replace('__VERSION__', version))
    html = (html.replace('__WIDTH__', str(width)).replace('__HEIGHT__', str(height))
            .replace('__REVIEW_WIDTH__', str(width * 3)).replace('__REVIEW_HEIGHT__', str(height * 3)))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(html)
    print(args.output)


if __name__ == '__main__':
    main()
