(() => {
'use strict';

const DEBUG = new URLSearchParams(location.search).get('debug') === '1';
const QUALITY = new URLSearchParams(location.search).get('quality') || 'high';
const input = { x: 0, y: 0, action: false };
window.MYU_INPUT = input;

// HTML virtual stick
const stickZone = document.getElementById('stickZone');
const stickBase = document.getElementById('stickBase');
const knob = document.getElementById('stickKnob');
const actionBtn = document.getElementById('actionBtn');
let dragging = false, center = {x:0,y:0}, radius = 1;
function refreshStick(){
  const r = stickBase.getBoundingClientRect();
  center = {x:r.left+r.width/2,y:r.top+r.height/2};
  radius = r.width * .36;
}
function setStick(x,y){
  const dx=x-center.x,dy=y-center.y,n=Math.hypot(dx,dy)||1,m=Math.min(n,radius);
  const mx=dx/n*m,my=dy/n*m;
  input.x=mx/radius; input.y=my/radius;
  knob.style.left=`calc(29% + ${mx}px)`;
  knob.style.top=`calc(29% + ${my}px)`;
}
function clearStick(){dragging=false;input.x=input.y=0;knob.style.left='29%';knob.style.top='29%'}
stickZone.addEventListener('pointerdown',e=>{refreshStick();dragging=true;stickZone.setPointerCapture?.(e.pointerId);setStick(e.clientX,e.clientY);e.preventDefault()});
stickZone.addEventListener('pointermove',e=>dragging&&setStick(e.clientX,e.clientY));
stickZone.addEventListener('pointerup',clearStick);stickZone.addEventListener('pointercancel',clearStick);
actionBtn.addEventListener('pointerdown',e=>{e.preventDefault();input.action=true;navigator.vibrate?.(8)});
addEventListener('resize',refreshStick,{passive:true});

class StreetLab extends Phaser.Scene {
  constructor(){ super('StreetLab'); }

  preload(){
    this.load.image('street', ['assets/backgrounds/exterior.webp','assets/backgrounds/exterior_normal.png']);
    this.load.spritesheet('witch', ['assets/sprites/witch_walk_atlas.webp','assets/sprites/witch_walk_normal.png'], { frameWidth:184, frameHeight:316 });
    this.load.image('shadow', 'assets/sprites/shadow_atlas.png');
    this.load.json('world', 'data/world.json');
    this.load.json('foregroundData', 'data/foreground.json');
    for (const id of ['bench','bollard1','bollard2','bollard3','bollard4','bollard5','signboard','lamp','planter','signs']) {
      this.load.image('fg_'+id, 'assets/foreground/'+id+'.png');
    }
  }

  create(){
    this.worldData = this.cache.json.get('world');
    this.keys = this.input.keyboard?.addKeys('W,A,S,D,UP,DOWN,LEFT,RIGHT,SPACE,ENTER,E') || {};

    this.street = this.add.image(0,0,'street').setOrigin(0).setDepth(0);
    if (this.street.setLighting) this.street.setLighting(true);
    this.matter.world.setBounds(-40,-40,1528,1166,64,true,true,true,true);

    this.makeBoundary(this.worldData.walkBoundary);
    this.makeObstacles(this.worldData.buildingHitboxes || [], 'BUILDING');
    this.makeObstacles(this.worldData.obstacles);

    this.environmentBodies = [...(this.worldData.buildingHitboxes || []), ...(this.worldData.obstacles || [])];

    const s = this.worldData.spawn;
    const pc = this.worldData.player || {};
    this.playerBody = this.matter.add.rectangle(s.x,s.y,pc.feetWidth || 34,pc.feetHeight || 18,{label:'PLAYER_FEET',friction:0,frictionStatic:0,frictionAir:0,restitution:0,isSensor:true});
    this.playerBody.inertia = Infinity; this.playerBody.inverseInertia = 0;
    this.playerBody.angle = 0; this.playerBody.angularVelocity = 0;

    this.player = this.add.sprite(s.x,s.y,'witch',0)
      .setOrigin(.5,.91)
      .setScale((this.worldData.player?.visualScaleFar) || .78)
      .setDepth(s.y);
    if (this.player.setLighting) this.player.setLighting(true);
    if (this.player.setSelfShadow) this.player.setSelfShadow(QUALITY==='high', .55, .28);

    this.shadow = this.add.ellipse(s.x,s.y+2,58,18,0x17121f,.36).setDepth(s.y-.5);
    this.shadow.setBlendMode(Phaser.BlendModes.MULTIPLY);

    this.playerReflection = this.add.sprite(s.x,s.y+7,'witch',0)
      .setOrigin(.5,.08)
      .setFlipY(true)
      .setAlpha(.075)
      .setTint(0x8f86ad)
      .setBlendMode(Phaser.BlendModes.SCREEN)
      .setDepth(s.y-.9);

    this.surfaceFxGfx = this.add.graphics().setDepth(55);
    this.splashes = [];
    this.stepClock = 0;
    this.moveVelocity = new Phaser.Math.Vector2(0,0);

    this.foregrounds = [];
    for (const o of this.cache.json.get('foregroundData')) {
      const fg = this.add.image(o.x,o.y,'fg_'+o.id).setOrigin(0).setDepth(o.footY);
      this.foregrounds.push({ ...o, sprite:fg });
    }

    this.lights.enable();
    this.lights.setAmbientColor(0x70778d);
    this.lightObjects = this.worldData.lights.map(l => {
      const light = this.lights.addLight(l.x,l.y,l.radius,Number(l.color),l.intensity,l.z);
      return { config:l, light };
    });

    this.reflectionGfx = this.add.graphics().setDepth(60).setBlendMode(Phaser.BlendModes.ADD);
    this.rainGfx = this.add.graphics().setDepth(2000).setBlendMode(Phaser.BlendModes.SCREEN);
    this.rain = this.makeRain(QUALITY==='high'?150:QUALITY==='medium'?90:45);

    this.cameras.main.setBounds(0,0,1448,1086);
    this.cameras.main.startFollow(this.player,false,.09,.09);
    this.cameras.main.setDeadzone(120,90);
    this.applyZoom();
    this.scale.on('resize',()=>this.applyZoom());

    if (DEBUG) {
      this.makeDebug();
      const pcDbg=this.worldData.player || {};
      this.playerDebug=this.add.rectangle(s.x,s.y,pcDbg.feetWidth||30,pcDbg.feetHeight||14,0x00ffff,.18)
        .setStrokeStyle(2,0x00ffff,.95).setDepth(10000);
    }

    this.walkClock=0;
    this.observationShown=false;
  }

  applyZoom(){
    const cam=this.cameras.main;
    const viewportW=this.scale.width, viewportH=this.scale.height;
    const fit=Math.max(viewportW/1448, viewportH/1086);
    cam.setZoom(Math.max(.72, Math.min(1.28, fit*1.02)));
  }

  makeBoundary(points){
    for(let i=0;i<points.length;i++){
      const a=points[i], b=points[(i+1)%points.length];
      const dx=b[0]-a[0],dy=b[1]-a[1];
      const len=Math.hypot(dx,dy),angle=Math.atan2(dy,dx);
      this.matter.add.rectangle((a[0]+b[0])/2,(a[1]+b[1])/2,len,18,{isStatic:true,angle,label:'WALK_EDGE'});
    }
  }

  makeObstacles(list, labelPrefix=''){
    for(const o of list){
      const label = labelPrefix ? `${labelPrefix}:${o.id}` : o.id;
      if(o.type==='rect') this.matter.add.rectangle(o.x,o.y,o.w,o.h,{isStatic:true,label,friction:0,restitution:0});
      else this.matter.add.circle(o.x,o.y,o.r,{isStatic:true,label,friction:0,restitution:0});
    }
  }

  pointInPolygon(x,y,points){
    let inside=false;
    for(let i=0,j=points.length-1;i<points.length;j=i++){
      const xi=points[i][0], yi=points[i][1], xj=points[j][0], yj=points[j][1];
      const intersects=((yi>y)!=(yj>y)) && (x < (xj-xi)*(y-yi)/((yj-yi)||0.000001)+xi);
      if(intersects) inside=!inside;
    }
    return inside;
  }

  hitsObstacle(x,y,o,padX,padY){
    if(o.type==='rect'){
      return Math.abs(x-o.x) <= (o.w/2 + padX) && Math.abs(y-o.y) <= (o.h/2 + padY);
    }
    const dx=x-o.x,dy=y-o.y;
    const r=o.r+Math.max(padX,padY);
    return dx*dx+dy*dy <= r*r;
  }

  canOccupy(x,y){
    const pc=this.worldData.player || {};
    const hw=(pc.feetWidth || 30)/2;
    const hh=(pc.feetHeight || 14)/2;
    const probes=[[0,0],[-hw,0],[hw,0],[0,-hh],[0,hh],[-hw*.75,hh*.75],[hw*.75,hh*.75]];
    for(const [ox,oy] of probes){
      if(!this.pointInPolygon(x+ox,y+oy,this.worldData.walkBoundary)) return false;
    }
    const solids=[...(this.worldData.buildingHitboxes||[]),...(this.worldData.obstacles||[])];
    for(const o of solids){
      if(this.hitsObstacle(x,y,o,hw,hh)) return false;
    }
    return true;
  }

  movePlayerDeterministic(dt){
    const Body=Phaser.Physics.Matter.Matter.Body;
    let x=this.playerBody.position.x;
    let y=this.playerBody.position.y;
    const dx=this.moveVelocity.x*dt;
    const dy=this.moveVelocity.y*dt;
    let hit=false;

    if(this.canOccupy(x+dx,y)) x+=dx;
    else { this.moveVelocity.x=0; hit=true; }

    if(this.canOccupy(x,y+dy)) y+=dy;
    else { this.moveVelocity.y=0; hit=true; }

    if(!this.canOccupy(x,y)){
      const safe=this.worldData.spawn;
      x=safe.x; y=safe.y;
      this.moveVelocity.set(0,0);
      hit=true;
    }

    Body.setPosition(this.playerBody,{x,y});
    Body.setVelocity(this.playerBody,{x:0,y:0});
    return hit;
  }

  makeRain(count){
    return Array.from({length:count},(_,i)=>({
      x:(i*97)%1448,
      y:(i*173)%1086,
      speed:330+(i%7)*24,
      len:8+(i%4)*3,
      drift:-55+(i%5)*5,
      alpha:.10+(i%6)*.018
    }));
  }

  makeDebug(){
    const g=this.add.graphics().setDepth(9999);
    g.lineStyle(3,0x44ff88,.9);
    const p=this.worldData.walkBoundary;
    g.beginPath();g.moveTo(p[0][0],p[0][1]);for(let i=1;i<p.length;i++)g.lineTo(p[i][0],p[i][1]);g.closePath();g.strokePath();
    g.lineStyle(3,0x5bbcff,.95);
    for(const o of (this.worldData.buildingHitboxes || [])){
      if(o.type==='rect') g.strokeRect(o.x-o.w/2,o.y-o.h/2,o.w,o.h);
    }
    g.lineStyle(2,0xff4d7a,.9);
    for(const o of this.worldData.obstacles){
      if(o.type==='rect') g.strokeRect(o.x-o.w/2,o.y-o.h/2,o.w,o.h);
      else g.strokeCircle(o.x,o.y,o.r);
    }
  }

  keyboardAxis(){
    let x=input.x,y=input.y;
    const K=this.keys;
    const down=k=>k?.isDown;
    if(down(K.A)||down(K.LEFT))x-=1;if(down(K.D)||down(K.RIGHT))x+=1;
    if(down(K.W)||down(K.UP))y-=1;if(down(K.S)||down(K.DOWN))y+=1;
    const n=Math.hypot(x,y);if(n>1){x/=n;y/=n}
    return{x,y};
  }

  nearestLight(px,py){
    let best=this.lightObjects[0],dist=Infinity;
    for(const o of this.lightObjects){const d=Math.hypot(px-o.config.x,py-o.config.y);if(d<dist){dist=d;best=o}}
    return { ...best, dist };
  }

  update(time,delta){
    const dt=Math.min(delta/1000,.034);
    const a=this.keyboardAxis();
    const pc=this.worldData.player || {};
    const speed=pc.walkSpeed || 42;
    const targetX=a.x*speed,targetY=a.y*speed;
    const hasInput=Math.hypot(a.x,a.y)>.05;
    const response=hasInput ? (pc.acceleration || 7.2) : (pc.deceleration || 10.5);
    const blend=1-Math.exp(-response*dt);
    this.moveVelocity.x=Phaser.Math.Linear(this.moveVelocity.x,targetX,blend);
    this.moveVelocity.y=Phaser.Math.Linear(this.moveVelocity.y,targetY,blend);
    if(!hasInput && Math.hypot(this.moveVelocity.x,this.moveVelocity.y)<1){this.moveVelocity.set(0,0)}

    const collided=this.movePlayerDeterministic(dt);
    this.playerBody.angle=0; this.playerBody.angularVelocity=0;

    const px=this.playerBody.position.x,py=this.playerBody.position.y;
    if(collided && !this.bumpLatch){
      this.bumpLatch=true;
      this.cameras.main.shake(45,.0007);
    }
    if(!collided)this.bumpLatch=false;

    const moving=Math.hypot(this.moveVelocity.x,this.moveVelocity.y)>3;
    if(moving){
      if(Math.abs(this.moveVelocity.x)>Math.abs(this.moveVelocity.y)) this.dir=this.moveVelocity.x<0?'left':'right'; else this.dir=this.moveVelocity.y<0?'back':'front';
      this.walkClock+=dt*5.0;
    } else this.walkClock=0;

    const rows={front:0,left:1,right:2,back:3};
    const seq=[0,1,2,3,2,1];
    const frame=(rows[this.dir||'front']*4)+(moving?seq[Math.floor(this.walkClock)%seq.length]:0);
    this.player.setFrame(frame);

    const scaleFar=pc.visualScaleFar || .78, scaleNear=pc.visualScaleNear || .86;
    const perspectiveScale = scaleFar + Phaser.Math.Clamp((py-470)/390, 0, 1) * (scaleNear-scaleFar);
    this.player.setScale(perspectiveScale);
    this.player.setPosition(px,py+3).setDepth(py);
    if(this.playerDebug) this.playerDebug.setPosition(px,py);

    this.playerReflection.setFrame(frame)
      .setPosition(px,py+8)
      .setScale(perspectiveScale,perspectiveScale*.19)
      .setDepth(py-.9);

    if(moving){
      this.stepClock-=dt;
      if(this.stepClock<=0){
        this.stepClock=pc.stepInterval || .14;
        this.spawnFootSplash(px,py);
      }
    } else {
      this.stepClock=Math.min(this.stepClock,.04);
    }
    this.updateSurfaceFx(dt);

    const near=this.nearestLight(px,py);
    const dx=px-near.config.x,dy=py-near.config.y,n=Math.hypot(dx,dy)||1;
    const strength=Math.max(0,1-near.dist/near.config.radius);
    this.playerReflection.setAlpha(.045 + strength*.055);
    this.shadow.setPosition(px+(dx/n)*8*strength,py+5+(dy/n)*2*strength);
    this.shadow.setScale(1+.18*strength,.78-.12*strength).setAlpha(.26+.16*strength).setDepth(py-.5);

    for(let i=0;i<this.lightObjects.length;i++){
      const o=this.lightObjects[i];
      if(o.config.id==='sky') continue;
      o.light.intensity=o.config.intensity*(.965+.035*Math.sin(time*.0027+i*1.7));
    }

    this.drawWetReflections(time);
    this.drawRain(dt);

    const actionPressed=input.action || this.keys.E?.isDown || this.keys.SPACE?.isDown || this.keys.ENTER?.isDown;
    if(actionPressed && !this.actionLatch){
      this.actionLatch=true;
      document.getElementById('status').textContent='v3 · velocidade 42 · prédio sólido · mapa fechado';
    }
    if(!actionPressed)this.actionLatch=false;
    input.action=false;
  }

  spawnFootSplash(x,y){
    const side=((this.splashes.length&1)?-1:1);
    this.splashes.push({x:x+side*7,y:y+7,age:0,life:.42,r:2.5+Math.random()*1.5});
  }

  updateSurfaceFx(dt){
    const g=this.surfaceFxGfx;
    for(const s of this.splashes)s.age+=dt;
    this.splashes=this.splashes.filter(s=>s.age<s.life);
    g.clear();
    for(const s of this.splashes){
      const t=s.age/s.life;
      g.lineStyle(1,0xc7cbe1,(1-t)*.22);
      g.strokeEllipse(s.x,s.y,s.r*(1+t*2.7)*2,s.r*(.45+t*.9));
    }
  }

  drawWetReflections(time){
    const g=this.reflectionGfx;g.clear();
    const pulse=.85+.15*Math.sin(time*.0017);
    const streaks=[
      [450,610,18,105,0xf7aa66,.10],[585,635,18,130,0xffb96e,.11],[805,650,22,145,0xf5a35c,.13],[1115,665,18,125,0xffc474,.10]
    ];
    for(const [x,y,w,h,c,a] of streaks){
      g.fillStyle(c,a*pulse);g.fillEllipse(x,y,w,h);
      g.fillStyle(c,a*.45*pulse);g.fillEllipse(x+11,y+18,w*.45,h*.6);
    }
  }

  drawRain(dt){
    const g=this.rainGfx;g.clear();g.lineStyle(1,0xcfd6ef,.16);
    for(const r of this.rain){
      r.x+=r.drift*dt;r.y+=r.speed*dt;
      if(r.y>1086||r.x<0){r.y=-20;r.x=(r.x+1448+((r.y*13)%330))%1448}
      g.lineStyle(1,0xd8ddf2,r.alpha);g.lineBetween(r.x,r.y,r.x-3,r.y+r.len);
    }
  }
}

const config={
  type:Phaser.WEBGL,
  parent:'game',
  backgroundColor:'#0e0d19',
  width:window.innerWidth,
  height:window.innerHeight,
  scene:[StreetLab],
  pixelArt:true,
  antialias:false,
  roundPixels:true,
  render:{pixelArt:true,antialias:false,roundPixels:true,selfShadow:QUALITY==='high'},
  physics:{
    default:'matter',
    matter:{gravity:{x:0,y:0},debug:DEBUG,enableSleeping:false}
  },
  scale:{mode:Phaser.Scale.RESIZE,autoCenter:Phaser.Scale.CENTER_BOTH},
  maxLights:8
};

new Phaser.Game(config);
})();