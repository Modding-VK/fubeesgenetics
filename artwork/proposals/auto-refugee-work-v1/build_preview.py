#!/usr/bin/env python3
"""Build a native 64x80 work animation proposal; does not modify live mod assets."""
from pathlib import Path
import base64
import hashlib
import json
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
STATIC = ROOT/'artwork/proposals/auto-refugee-glass-native-v1/native-adjusted.png'
BUG = OUT/'insect-source.png'
AREA = (28,53,39,60)  # front pane, entirely above mount and inside all four edges
COLORS = {'blue':(49,166,255,255),'pale':(155,212,255,255),'white':(254,255,255,255)}


def build():
    base=Image.open(STATIC).convert('RGBA')
    bug=Image.open(BUG).convert('RGBA').transpose(Image.Transpose.ROTATE_270).resize((6,6),Image.Resampling.NEAREST)
    assert base.size==(64,80) and bug.size==(6,6)
    empty=Image.new('RGBA',(64,80),(0,0,0,0))
    specimen=empty.copy();specimen.alpha_composite(bug,(30,54))
    specimens=[empty.copy()];effects=[empty.copy()]
    stages=['ready'];frames=[base.copy()]
    for i in range(1,21):
        body=specimen.copy() if i<=8 else empty.copy()
        fx=empty.copy();draw=ImageDraw.Draw(fx)
        phase=i-9
        if i<=8:
            stage='work: inseto na haste'
        else:
            stage='work: teleporte '+str(phase+1)+'/12'
            # Outline -> pale fill -> white silhouette -> compressed ellipse -> upward beam -> empty.
            if phase==0:
                for y in range(6):
                    for x in range(6):
                        if bug.getpixel((x,y))[3]:
                            for dx,dy in [(0,0),(-1,0),(1,0),(0,-1),(0,1)]:
                                xx,yy=30+x+dx,54+y+dy
                                if AREA[0]<=xx<AREA[2] and AREA[1]<=yy<AREA[3]:fx.putpixel((xx,yy),COLORS['blue'])
                fx.alpha_composite(bug,(30,54))
            elif phase in (1,2):
                color=COLORS['pale' if phase==1 else 'white']
                for y in range(6):
                    for x in range(6):
                        if bug.getpixel((x,y))[3]:fx.putpixel((30+x,54+y),color)
            elif phase in (3,4):
                draw.ellipse((29,55,36,58),fill=COLORS['blue'])
                draw.ellipse((30,56,35,57),fill=COLORS['white'])
            elif phase in (5,6):
                draw.line((29,57,36,57),fill=COLORS['white'],width=1)
                draw.point((28,57),fill=COLORS['blue']);draw.point((37,57),fill=COLORS['blue'])
                if phase==6:draw.line((32,53,32,57),fill=COLORS['pale'])
            elif phase in (7,8):
                draw.line((32,53,32,59),fill=COLORS['white'])
                if phase==7:
                    draw.line((31,53,31,58),fill=COLORS['blue'])
                    draw.line((33,53,33,58),fill=COLORS['pale'])
            elif phase in (9,10):
                for x,y in ([(31,53),(33,54),(32,55)] if phase==9 else [(32,53)]):
                    draw.point((x,y),fill=COLORS['pale'])
        # Bake the pane tint into occupied pixels, so the approved flattened glass
        # cannot obscure the specimen a second time. Highlights outside the mask stay intact.
        for layer,opacity in [(body,210),(fx,235)]:
            for y in range(AREA[1],AREA[3]):
                for x in range(AREA[0],AREA[2]):
                    pixel=layer.getpixel((x,y))
                    if pixel[3]:
                        glass=base.getpixel((x,y))
                        layer.putpixel((x,y),tuple(round(pixel[c]*0.8+glass[c]*0.2) for c in range(3))+(opacity,))
        frame=Image.alpha_composite(Image.alpha_composite(base,body),fx)
        specimens.append(body);effects.append(fx);frames.append(frame);stages.append(stage)
    names=['ready.1']+['work.'+str(i) for i in range(1,21)]
    for filename,images in [('specimen',specimens),('teleport',effects),('composite',frames)]:
        sheet=Image.new('RGBA',(64*21,80),(0,0,0,0))
        for i,im in enumerate(images):sheet.paste(im,(i*64,0))
        sheet.save(OUT/(filename+'.png'))
    base.save(OUT/'static.png')
    (OUT/'default.frames').write_text(json.dumps({'frameGrid':{'size':[64,80],'dimensions':[21,1],'names':[names]}},indent=2)+'\n')
    animation={'animatedParts':{'stateTypes':{'machine':{'default':'ready','states':{
        'ready':{'frames':1,'cycle':1,'mode':'loop'},
        'work':{'frames':20,'cycle':1.25,'mode':'transition','transition':'ready',
                'frameProperties':{'immediateSound':['']*8+['/sfx/tools/teleport_up.ogg']+['']*11}}
    }}},'parts':{}}}
    for name,filename,level,bright in [('specimen','specimen',1,False),('teleport','teleport',2,True)]:
        animation['animatedParts']['parts'][name]={'properties':{'centered':False,'zLevel':level,'fullbright':bright},
            'partStates':{'machine':{'ready':{'properties':{'image':filename+'.png:ready.1'}},
                                    'work':{'properties':{'image':filename+'.png:work.<frame>'}}}}}
    animation['animatedParts']['parts']['base']={'properties':{'centered':False,'zLevel':0,'image':'static.png'}}
    (OUT/'work.animation').write_text(json.dumps(animation,indent=2)+'\n')
    # GIF uses a background only for the review; RGBA sheets remain unflattened.
    timeline=[0]*12+list(range(1,21))+[0]*16
    review=[]
    for i in timeline:
        bg=Image.new('RGBA',(64,80),'#344451')
        d=ImageDraw.Draw(bg)
        for y in range(0,80,4):
            for x in range(0,64,4):
                if (x//4+y//4)%2==0:d.rectangle((x,y,x+3,y+3),fill='#465663')
        bg.alpha_composite(frames[i]);review.append(bg.convert('RGB').resize((384,480),Image.Resampling.NEAREST))
    review[0].save(OUT/'work-preview.gif',save_all=True,append_images=review[1:],duration=62.5,loop=0,disposal=2)
    encoded='data:image/png;base64,'+base64.b64encode((OUT/'composite.png').read_bytes()).decode()
    html='''<!doctype html><meta charset="utf-8"><title>Auto Refugee — work / teleporte</title>
<style>body{background:#15212a;color:#e5edf1;font:16px sans-serif;padding:24px}h1{font-size:24px}.row{display:flex;gap:24px;align-items:flex-end}.panel{padding:16px;background:#2c3c49}canvas{image-rendering:pixelated;background:repeating-conic-gradient(#344451 0% 25%,#465663 0% 50%) 0 0/16px 16px}button{padding:10px;margin:16px 8px 12px 0}p{max-width:940px;line-height:1.5}#phase{font-weight:bold;color:#9bd4ff}#strip{max-width:1150px;image-rendering:pixelated}</style>
<h1>Auto Refugee — proposta de work com teleporte</h1><p>64×80 por frame. Inseto na haste → silhueta azul/branca → compressão → feixe vertical → caixa vazia.</p>
<div class="row">'''
    for scale in [1,3,6]:html+=f'<div class="panel"><canvas width="64" height="80" data-scale="{scale}" style="width:{64*scale}px;height:{80*scale}px"></canvas><p>{scale}×</p></div>'
    html+='''</div><button id="start">Entrar em work</button><button id="pause">Pausar</button><button id="reset">Parada / vazia</button><label><input id="loop" type="checkbox" checked>Repetir para revisão</label>
<p id="phase">ready — caixa vazia</p><p>Amostra real do inseto Butterbee do Starbound, ampliada 2× com nearest-neighbor (6×6). Efeito adaptado do beamout nativo: 12 frames em 0,75 s. Prévia offline; o PAK não foi modificado.</p>
<script>
const image=new Image();image.src=SPRITE;
const stages=STAGES;let index=0,elapsed=0,playing=false,rest=0,last=0;
function paint(){document.querySelectorAll('canvas').forEach(c=>{const ctx=c.getContext('2d');ctx.imageSmoothingEnabled=false;ctx.clearRect(0,0,64,80);ctx.drawImage(image,index*64,0,64,80,0,0,64,80)});document.querySelector('#phase').textContent=stages[index]+' — frame '+index;window.previewFrame=index;}
function tick(t){if(!last)last=t;let dt=t-last;last=t;if(playing){elapsed+=dt;while(elapsed>=62.5){elapsed-=62.5;index++;if(index>20){index=0;playing=false;rest=0;break}}paint();}else if(document.querySelector('#loop').checked){rest+=dt;if(rest>=1000){rest=0;index=1;elapsed=0;playing=true;paint();}}requestAnimationFrame(tick)}
image.onload=()=>{paint();window.layoutReady=true;requestAnimationFrame(tick)};
document.querySelector('#start').onclick=()=>{index=1;elapsed=0;playing=true;paint()};
document.querySelector('#pause').onclick=()=>{playing=false;document.querySelector('#loop').checked=false;paint()};
document.querySelector('#reset').onclick=()=>{playing=false;document.querySelector('#loop').checked=false;index=0;paint()};
window.showFrame=(i)=>{playing=false;document.querySelector('#loop').checked=false;index=i;paint()};
</script>'''
    html=html.replace('SPRITE',json.dumps(encoded)).replace('STAGES',json.dumps(stages))
    (OUT/'preview.html').write_text(html)
    # Verify native size, containment, state endpoints and stable glass/rod outside effect area.
    assert frames[0].tobytes()==base.tobytes()==frames[-1].tobytes()
    assert not specimens[0].getbbox() and not effects[0].getbbox()
    assert specimens[1].getbbox() and frames[1].tobytes()!=base.tobytes()
    for i,frame in enumerate(frames):
        assert frame.size==(64,80)
        for y in range(80):
            for x in range(64):
                if not (AREA[0]<=x<AREA[2] and AREA[1]<=y<AREA[3]):assert frame.getpixel((x,y))==base.getpixel((x,y)),(i,x,y)
        for layer in (specimens[i],effects[i]):
            box=layer.getbbox()
            if box:assert AREA[0]<=box[0]<=box[2]<=AREA[2] and AREA[1]<=box[1]<=box[3]<=AREA[3]
    assert len(names)==21 and len(set(names))==21
    report={'frame_size':[64,80],'work_frames':20,'work_cycle_seconds':1.25,'specimen_hold_seconds':0.5,
            'teleport_frames':12,'teleport_seconds':0.75,'specimen_rotation_clockwise_degrees':90,'specimen_size':[6,6],'specimen_origin':[30,54],
            'effect_bounds':list(AREA),'idle_has_insect':False,'final_frame_matches_idle':True,
            'base_glass_rod_and_sign_unchanged_outside_effect':True,'part_order':['base','specimen','teleport'],
            'game_tested':False,'pak_changed':False,'base_sha256':hashlib.sha256(STATIC.read_bytes()).hexdigest()}
    (OUT/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report))


if __name__=='__main__':build()
