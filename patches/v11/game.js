const canvas=document.getElementById('game');
const ctx=canvas.getContext('2d',{alpha:false});
ctx.imageSmoothingEnabled=false;
const hud=document.getElementById('hud'),pill=document.getElementById('pill'),actionBtn=document.getElementById('actionBtn');

let data,current='exterior',last=0,fade=0,transition=null,hudTimer=0;
const assets={},pixelAssets={},keys={},input={x:0,y:0};
const player={x:0,y:0,vx:0,vy:0,dir:'front',moving:false,anim:0,idle:0};
const cam={x:0,y:0,zoom:1};
const WALK=[0,1,2,3,2,1];
const OFFSETS={
  front:[[0,0],[0,-1],[0,0],[0,1]],
  back:[[0,0],[0,-1],[0,0],[0,1]],
  left:[[0,0],[-1,0],[0,-1],[1,0]],
  right:[[0,0],[1,0],[0,-1],[-1,0]]
};
const dpr=()=>Math.max(1,devicePixelRatio||1);
const sc=()=>data.scenes[current];

function status(){
  return current==='exterior'
    ? 'Ande pela calçada. A perto da porta entra no café.'
    : 'Explore o café. A perto da porta volta para a rua.';
}
function showHUD(text,t=1.6){
  pill.textContent=text;
  hud.classList.remove('hidden');
  hudTimer=t;
}
async function loadImage(src){
  if(assets[src]) return assets[src];
  const im=new Image();
  await new Promise((resolve,reject)=>{im.onload=resolve;im.onerror=reject;im.src=src});
  assets[src]=im;
  return im;
}
function pixelate(im,factor){
  const low=document.createElement('canvas');
  low.width=Math.max(1,Math.round(im.width*factor));
  low.height=Math.max(1,Math.round(im.height*factor));
  const lctx=low.getContext('2d');
  lctx.imageSmoothingEnabled=false;
  lctx.drawImage(im,0,0,low.width,low.height);
  const out=document.createElement('canvas');
  out.width=im.width;
  out.height=im.height;
  const octx=out.getContext('2d');
  octx.imageSmoothingEnabled=false;
  octx.drawImage(low,0,0,low.width,low.height,0,0,out.width,out.height);
  return out;
}
async function boot(){
  data=await fetch('data/scene.json?v=11.2',{cache:'no-store'}).then(r=>r.json());
  const files=new Set([data.atlas.file]);
  for(const s of Object.values(data.scenes)) files.add(s.bg);
  await Promise.all([...files].map(loadImage));
  pixelAssets[data.atlas.file]=pixelate(assets[data.atlas.file],0.5);
  for(const s of Object.values(data.scenes)) pixelAssets[s.bg]=pixelate(assets[s.bg],0.62);
  switchScene('exterior',sc().start,true);
  resize();
  showHUD(status(),2.3);
  requestAnimationFrame(loop);
}
function switchScene(name,spawn,instant=false){
  current=name;
  player.x=spawn.x; player.y=spawn.y;
  player.vx=player.vy=0;
  player.dir=spawn.dir||'front';
  player.anim=0; player.idle=0;
  if(instant){cam.x=player.x;cam.y=player.y}
  showHUD(status(),1.3);
}
function resize(){
  canvas.width=Math.floor(innerWidth*dpr());
  canvas.height=Math.floor(innerHeight*dpr());
  canvas.style.width=innerWidth+'px';
  canvas.style.height=innerHeight+'px';
  ctx.imageSmoothingEnabled=false;
  if(data){
    const b=pixelAssets[sc().bg]||assets[sc().bg];
    cam.zoom=Math.max(canvas.width/b.width,canvas.height/b.height);
  }
  refreshStick();
}
addEventListener('resize',resize);

function pointInPolygon(x,y,poly){
  let inside=false;
  for(let i=0,j=poly.length-1;i<poly.length;j=i++){
    const xi=poly[i][0],yi=poly[i][1],xj=poly[j][0],yj=poly[j][1];
    const hit=((yi>y)!==(yj>y))&&(x<(xj-xi)*(y-yi)/(yj-yi)+xi);
    if(hit) inside=!inside;
  }
  return inside;
}
function inWalkArea(x,y){
  const polys=sc().walkPolygons||[];
  return polys.some(p=>pointInPolygon(x,y,p));
}
function hitsBlocker(x,y,b,r=5){
  if(b.type==='rect'){
    return x+r>b.x&&x-r<b.x+b.w&&y+r>b.y&&y-r<b.y+b.h;
  }
  if(b.type==='circle'){
    const dx=x-b.x,dy=y-b.y,rr=b.r+r;
    return dx*dx+dy*dy<=rr*rr;
  }
  return false;
}
function walkable(x,y){
  const probes=[[0,0],[5,0],[-5,0],[0,4],[0,-4],[4,3],[-4,3]];
  for(const[ox,oy]of probes){
    const px=x+ox,py=y+oy;
    if(!inWalkArea(px,py)) return false;
    for(const b of (sc().blockers||[])) if(hitsBlocker(px,py,b)) return false;
  }
  return true;
}

addEventListener('keydown',e=>{
  const k=e.key.toLowerCase();
  keys[k]=true;
  if(['e',' ','enter'].includes(k)){e.preventDefault();interact()}
});
addEventListener('keyup',e=>keys[e.key.toLowerCase()]=false);

function axis(){
  let x=input.x,y=input.y;
  const kx=(keys.d||keys.arrowright?1:0)-(keys.a||keys.arrowleft?1:0);
  const ky=(keys.s||keys.arrowdown?1:0)-(keys.w||keys.arrowup?1:0);
  if(kx||ky){x=kx;y=ky}
  let n=Math.hypot(x,y);
  if(n>1){x/=n;y/=n;n=1}
  if(!(kx||ky)){
    const dz=.18;
    if(n<dz) return{x:0,y:0};
    const t=(n-dz)/(1-dz),c=t*t*(3-2*t);
    x=x/n*c;y=y/n*c;
  }
  return{x,y};
}

const stickZone=document.getElementById('stickZone'),stickBase=document.getElementById('stickBase'),knob=document.getElementById('stickKnob');
let dragging=false,center={x:0,y:0},radius=1;
function refreshStick(){
  const r=stickBase.getBoundingClientRect();
  center={x:r.left+r.width/2,y:r.top+r.height/2};
  radius=r.width*.36;
}
function setStick(x,y){
  const dx=x-center.x,dy=y-center.y,n=Math.hypot(dx,dy)||1,m=Math.min(n,radius);
  const mx=dx/n*m,my=dy/n*m;
  input.x=mx/radius;input.y=my/radius;
  knob.style.left=`calc(29% + ${mx}px)`;
  knob.style.top=`calc(29% + ${my}px)`;
}
function clearStick(){
  dragging=false;input.x=input.y=0;
  knob.style.left='29%';knob.style.top='29%';
}
stickZone.addEventListener('pointerdown',e=>{refreshStick();dragging=true;setStick(e.clientX,e.clientY);e.preventDefault()});
addEventListener('pointermove',e=>dragging&&setStick(e.clientX,e.clientY));
addEventListener('pointerup',()=>dragging&&clearStick());
addEventListener('pointercancel',()=>dragging&&clearStick());
actionBtn.addEventListener('pointerdown',()=>{navigator.vibrate?.(8);interact()});

function nearDoor(){
  const d=sc().door;
  return Math.hypot(player.x-d.x,player.y-d.y)<d.radius;
}
function interact(){
  if(transition)return;
  if(nearDoor()){
    const d=sc().door;
    transition={to:d.to,spawn:d.spawn,phase:'out'};
    return;
  }
  showHUD('Chegue mais perto da porta.',.85);
}

function update(dt){
  if(hudTimer>0){
    hudTimer-=dt;
    if(hudTimer<=0)hud.classList.add('hidden');
  }
  actionBtn.classList.toggle('near',nearDoor());

  if(transition){
    const s=7.5;
    if(transition.phase==='out'){
      fade=Math.min(1,fade+dt*s);
      player.vx*=.72;player.vy*=.72;
      if(fade>=1){
        switchScene(transition.to,transition.spawn);
        transition.phase='in';
      }
    }else{
      fade=Math.max(0,fade-dt*s);
      if(fade<=0)transition=null;
    }
  }

  const a=axis();
  const max=current==='exterior'?145:132;
  const targetX=transition?0:a.x*max,targetY=transition?0:a.y*max;
  const active=Math.abs(a.x)+Math.abs(a.y)>.01;
  player.vx+=(targetX-player.vx)*Math.min(1,dt*(active?12:8));
  player.vy+=(targetY-player.vy)*Math.min(1,dt*(active?12:8));

  const sp=Math.hypot(player.vx,player.vy);
  player.moving=sp>3.5;
  if(player.moving){
    player.dir=Math.abs(player.vx)>Math.abs(player.vy)
      ?(player.vx>0?'right':'left')
      :(player.vy>0?'front':'back');
    player.anim=(player.anim+dt*(2.3+sp/max*3.2))%WALK.length;
    player.idle=0;
  }else{
    player.anim=0;
    player.idle+=dt;
  }

  const nx=player.x+player.vx*dt,ny=player.y+player.vy*dt;
  if(walkable(nx,player.y))player.x=nx;else player.vx=0;
  if(walkable(player.x,ny))player.y=ny;else player.vy=0;

  const b=pixelAssets[sc().bg]||assets[sc().bg];
  const vw=canvas.width/cam.zoom,vh=canvas.height/cam.zoom;
  const dx=player.x-cam.x,dy=player.y-cam.y,dzx=vw*.105,dzy=vh*.085;
  let tx=cam.x,ty=cam.y;
  if(dx>dzx)tx=player.x-dzx;else if(dx<-dzx)tx=player.x+dzx;
  if(dy>dzy)ty=player.y-dzy;else if(dy<-dzy)ty=player.y+dzy;
  tx=Math.max(vw/2,Math.min(b.width-vw/2,tx));
  ty=Math.max(vh/2,Math.min(b.height-vh/2,ty));
  cam.x+=(tx-cam.x)*Math.min(1,dt*6);
  cam.y+=(ty-cam.y)*Math.min(1,dt*6);
}

function drawPixelShadow(x,y,frame,depth,dir){
  const step=(frame===1||frame===3)?-2:0;
  const shift=dir==='right'?2:dir==='left'?-2:0;
  const widths=[18,28,36,42,36,28,18];
  ctx.save();
  ctx.globalAlpha=.20;
  ctx.fillStyle='#1a1325';
  for(let i=0;i<widths.length;i++){
    const w=(widths[i]+step)*depth;
    const yy=y+(i-3)*depth;
    ctx.fillRect(Math.round(x-w/2+shift),Math.round(yy),Math.round(w),Math.max(1,Math.round(depth)));
  }
  ctx.restore();
}

function draw(){
  const s=sc(),b=pixelAssets[s.bg]||assets[s.bg];
  ctx.fillStyle='#120f1f';
  ctx.fillRect(0,0,canvas.width,canvas.height);

  const vw=canvas.width/cam.zoom,vh=canvas.height/cam.zoom;
  const cx=Math.max(vw/2,Math.min(b.width-vw/2,cam.x));
  const cy=Math.max(vh/2,Math.min(b.height-vh/2,cam.y));
  const sx=cx-vw/2,sy=cy-vh/2;

  ctx.save();
  ctx.scale(cam.zoom,cam.zoom);
  ctx.translate(-sx,-sy);
  ctx.imageSmoothingEnabled=false;
  ctx.drawImage(b,0,0);

  const a=pixelAssets[data.atlas.file]||assets[data.atlas.file];
  const row=data.atlas.rows[player.dir],fw=data.atlas.frameW,fh=data.atlas.frameH;
  const frame=player.moving?WALK[Math.floor(player.anim)%WALK.length]:0;
  const depth=current==='exterior'?1+(player.y/b.height)*.06:.98+(player.y/b.height)*.04;
  const scale=data.atlas.scale*depth;
  const dw=fw*scale,dh=fh*scale;
  const off=OFFSETS[player.dir][frame]||[0,0];
  const px=Math.round(player.x-dw/2+off[0]);
  const py=Math.round(player.y-dh+8+off[1]);

  drawPixelShadow(player.x,player.y-5,frame,depth,player.dir);
  ctx.drawImage(a,frame*fw,row*fh,fw,fh,px,py,Math.round(dw),Math.round(dh));
  ctx.restore();

  if(fade>0){
    ctx.fillStyle=`rgba(9,7,16,${fade})`;
    ctx.fillRect(0,0,canvas.width,canvas.height);
  }
}

function loop(t){
  if(!last)last=t;
  const dt=Math.min(.033,(t-last)/1000);
  last=t;
  update(dt);
  draw();
  requestAnimationFrame(loop);
}
boot();
