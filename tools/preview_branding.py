#!/usr/bin/env python3
"""Review the native metadata icon using pinned FU pixels and image directives."""
import argparse
import base64
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--fu-root', type=Path, default=ROOT / '.cache/fu')
    parser.add_argument('--output', type=Path, default=ROOT / 'artwork/branding/identity.html')
    args = parser.parse_args()
    metadata = json.loads((ROOT / 'FUBeesGenetics/_metadata').read_text())
    frames = json.loads((args.fu_root / 'bees/bees/default.frames').read_text())
    sheet = base64.b64encode((args.fu_root / 'bees/bees/cybernetic.png').read_bytes()).decode()
    html = '''<!doctype html><html lang="en"><meta charset="utf-8">
<title>Bee Abusive Industry — identity review</title>
<style>
body{background:#191919;color:#ddd;font:18px monospace;padding:24px;margin:0}
#modPreview{width:760px;background:#303030;border:3px solid #77818a;padding:20px;box-sizing:border-box}
.row{background:#212121;border:2px solid #555;display:flex;gap:16px;align-items:center;padding:8px}
.row canvas{width:42px;height:42px;flex:none}canvas{image-rendering:pixelated}
.fields{padding:16px 0;line-height:1.8}.label{color:#aaa}.zoom{width:112px;height:112px}
.cover{width:512px;height:512px;background:#ff9b3d;display:grid;place-items:center}
.cover canvas{width:480px;height:480px}p{max-width:760px;font-size:14px}a{color:#ffc780}
</style>
<div id="modPreview"><div class="row"><canvas class="icon"></canvas><b id="name"></b></div>
<div class="fields"><div><span class="label">AUTHOR </span><span id="author"></span></div>
<div><span class="label">VERSION </span><span id="version"></span></div>
<div id="description"></div></div><canvas class="icon zoom"></canvas></div>
<p>Native 14×14 icon, enlarged for inspection. The card approximates the Mods menu;
browser typography is not the in-game font. The cover below is a separate export.</p>
<div class="cover" id="workshopPreview"><canvas class="icon"></canvas></div>
<p>Cybernetic Queen texture: Frackin Universe team / sayterdarkwynd and contributors.
<a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a>.
<a href="https://github.com/sayterdarkwynd/FrackinUniverse/blob/17868d86c9bb7bc00f92038fb78b48cebd1b41b8/bees/bees/cybernetic.png">Source</a>.
Modified presentation: queen-frame crop, nearest-neighbor scaling and orange background.
No endorsement is implied.</p>
<script>
const metadata=__METADATA__,frames=__FRAMES__;
document.querySelector('#name').textContent=metadata.friendlyName;
document.querySelector('#author').textContent=metadata.author;
document.querySelector('#version').textContent=metadata.version;
document.querySelector('#description').textContent=metadata.description;
const image=new Image();image.src='data:image/png;base64,__SHEET__';
image.onload=()=>{
 const [w,h]=frames.frameGrid.size, frameName=metadata.icon.split('?')[0].split(':')[1];
 let fx=-1,fy=-1;
 frames.frameGrid.names.forEach((row,y)=>row.forEach((name,x)=>{if(name===frameName){fx=x;fy=y}}));
 if(fx<0)throw Error('Unknown frame');
 const source=document.createElement('canvas');source.width=image.width;source.height=image.height;
 const ctx=source.getContext('2d');ctx.drawImage(image,0,0);
 const src=ctx.getImageData(fx*w,fy*h,w,h).data;
 let plane={w,h,data:new Uint8ClampedArray(w*h*4)};
 for(let y=0;y<h;y++)for(let x=0;x<w;x++)plane.data.set(src.slice(((h-1-y)*w+x)*4,((h-1-y)*w+x)*4+4),(y*w+x)*4);
 for(const directive of metadata.icon.split('?').slice(1)){
  const [op,arg]=directive.split('='),parts=arg.split(';');
  if(op==='crop'){
   const [x0,y0,x1,y1]=parts.map(Number),nw=x1-x0,nh=y1-y0;
   if(x0<0||y0<0||x1>plane.w||y1>plane.h)throw Error('Invalid native crop');
   const next=new Uint8ClampedArray(nw*nh*4);
   for(let y=0;y<nh;y++)for(let x=0;x<nw;x++){const i=((y+y0)*plane.w+x+x0)*4;next.set(plane.data.slice(i,i+4),(y*nw+x)*4)}
   plane={w:nw,h:nh,data:next};
  }else if(op==='scalenearest'){
   const scale=Number(arg),nw=Math.max(1,Math.round(plane.w*scale)),nh=Math.max(1,Math.round(plane.h*scale));
   const next=new Uint8ClampedArray(nw*nh*4);
   for(let y=0;y<nh;y++)for(let x=0;x<nw;x++){
    const sx=Math.min(plane.w-1,Math.round(x/scale)),sy=Math.min(plane.h-1,Math.round(y/scale)),i=(sy*plane.w+sx)*4;
    next.set(plane.data.slice(i,i+4),(y*nw+x)*4);
   }plane={w:nw,h:nh,data:next};
  }else if(op==='border'){
   const radius=Number(parts[0]);if(parts[1]!==parts[2])throw Error('Preview only supports constant border color');
   const color=[0,2,4].map(i=>parseInt(parts[1].slice(i,i+2),16));color.push(255);
   const nw=plane.w+radius*2,nh=plane.h+radius*2,next=new Uint8ClampedArray(nw*nh*4);
   for(let y=0;y<nh;y++)for(let x=0;x<nw;x++){
    const sx=x-radius,sy=y-radius,i=(sy*plane.w+sx)*4;
    if(sx>=0&&sy>=0&&sx<plane.w&&sy<plane.h&&plane.data[i+3]){next.set(plane.data.slice(i,i+4),(y*nw+x)*4);continue}
    let found=false;
    for(let yy=Math.max(0,sy-radius);yy<=Math.min(plane.h-1,sy+radius)&&!found;yy++)
     for(let xx=Math.max(0,sx-radius);xx<=Math.min(plane.w-1,sx+radius);xx++)if(plane.data[(yy*plane.w+xx)*4+3]){found=true;break}
    if(found)next.set(color,(y*nw+x)*4);
   }plane={w:nw,h:nh,data:next};
  }else throw Error('Unsupported icon directive '+op);
 }
 if(plane.w!==14||plane.h!==14)throw Error('Icon exceeds native row size');
 const top=new Uint8ClampedArray(plane.data.length);
 for(let y=0;y<plane.h;y++)for(let x=0;x<plane.w;x++){const i=(y*plane.w+x)*4;top.set(plane.data.slice(i,i+4),((plane.h-1-y)*plane.w+x)*4)}
 if(!Array.from({length:196},(_,i)=>top[i*4+3]).every(a=>a===255))throw Error('Background is not fully opaque');
 for(const canvas of document.querySelectorAll('.icon')){canvas.width=14;canvas.height=14;canvas.getContext('2d').putImageData(new ImageData(top,14,14),0,0)}
 // The Workshop export has room for the original 16x16 Queen without downscaling.
 const cover=document.querySelector('#workshopPreview canvas');cover.width=24;cover.height=24;
 const coverContext=cover.getContext('2d');coverContext.imageSmoothingEnabled=false;
 coverContext.fillStyle='#ff9b3d';coverContext.fillRect(0,0,24,24);
 coverContext.drawImage(source,fx*w+4,fy*h+6,16,16,4,4,16,16);
 window.logoReady=true;
};
</script></html>'''
    html = html.replace('__METADATA__', json.dumps(metadata)).replace('__FRAMES__', json.dumps(frames)).replace('__SHEET__', sheet)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(html)
    print(args.output)


if __name__ == '__main__':
    main()
