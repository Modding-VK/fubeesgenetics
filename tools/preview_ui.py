#!/usr/bin/env python3
"""Build a self-contained HTML layout review from shipped UI assets, not a game capture."""
import argparse
import base64
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UI = ROOT / 'FUBeesGenetics/interface/fubeesgenetics/geneticqueenfilter'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=ROOT / '.cache/hud-0.1.3.html')
    args = parser.parse_args()
    config = json.loads((UI / 'fubeesgenetics_geneticqueenfilter.config').read_text())
    images = {p.name: 'data:image/png;base64,' + base64.b64encode(p.read_bytes()).decode()
              for p in UI.glob('*.png')}
    html = '''<!doctype html><html lang="en"><meta charset="utf-8">
<title>Genetic Queen Filter — native assets review 0.1.3</title>
<style>
*{box-sizing:border-box}body{margin:0;padding:24px;background:#161b23;color:#dce7f1;font:14px monospace}
#review{width:1164px;height:996px;position:relative}#pane{width:388px;height:332px;
position:relative;transform:scale(3);transform-origin:top left;image-rendering:pixelated}
#pane>*{position:absolute}img{image-rendering:pixelated;pointer-events:none}
.label{white-space:pre;line-height:1;pointer-events:none}.button{border:0;padding:0;
background:transparent;color:#dce7f1;font:8px monospace;cursor:pointer;image-rendering:pixelated}
.button>img{position:absolute;inset:0;width:100%;height:100%}.caption{position:relative}
.radio{width:18px;height:18px}.reset{width:100px;height:20px}.close{width:12px;height:12px}
p{max-width:1164px;color:#aab9ca}a{color:#64d8ed}
</style><div id="review"><div id="pane"></div></div>
<p>Offline layout review using the shipped 388×332 assets, enlarged 3×. Browser text is
an approximation of the in-game font. Example profile/values; controls only change this preview.</p>
<script>
const config=__CONFIG__, images=__IMAGES__, pane=document.querySelector('#pane');
const example={family:'Family: shrouded',subspecies:'Subspecies: Vocadahl',
status:'Status: Waiting for input',lastResult:'Last result: Approved',
baseProductionReference:'30',droneToughnessReference:'48',droneBreedRateReference:'27',
queenBreedRateReference:'21',queenLifespanReference:'982',mutationChanceReference:'3.00%'};
const sizes={'header.png':[388,34],'body.png':[388,286],'footer.png':[388,12],'dna.png':[20,20]};
const image=(file)=>{let e=document.createElement('img');e.src=images[file.split('/').pop()];return e};
function place(e,x,y,w,h){e.style.left=x+'px';e.style.bottom=y+'px';if(w)e.style.width=w+'px';if(h)e.style.height=h+'px';pane.append(e)}
for(const [file,y] of [['header.png',298],['body.png',12],['footer.png',0]]){let [w,h]=sizes[file];place(image(file),0,y,w,h)}
const radios={};
for(const [name,w] of Object.entries(config.gui)){
 if(!w.position)continue;
 const [x,y]=w.position;
 if(w.type==='label'){
  const e=document.createElement('span');e.className='label';e.id=name;e.textContent=example[name]??w.value;
  e.style.fontSize=(w.fontSize??8)+'px';e.style.color=w.color??'#dce7f1';
  e.style.transform=w.hAnchor==='right'?'translate(-100%,50%)':w.hAnchor==='mid'?'translate(-50%,50%)':'translateY(50%)';
  place(e,x,y);
 }else if(w.type==='image'){
  const file=w.file.split('/').pop();const [width,height]=sizes[file];place(image(file),x,y,width,height);
 }else if(w.type==='itemgrid'){
  place(image(w.backingImage),x,y,24,24);
 }else if(w.type==='button'){
  const e=document.createElement('button');e.className='button '+(name==='close'?'close':'reset');e.id=name;
  const bg=image(w.base);e.append(bg);if(w.caption){const t=document.createElement('span');t.className='caption';t.textContent=w.caption;e.append(t)}
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
    html = html.replace('__CONFIG__', json.dumps(config)).replace('__IMAGES__', json.dumps(images))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(html)
    print(args.output)


if __name__ == '__main__':
    main()
