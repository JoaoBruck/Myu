const DOCS={
 photo:{title:"Fotografia da festa",code:"FOTO / 12.08.2017",body:"Alana aparece na extremidade da fotografia. A jaqueta amarela está amarrada à cintura.",kind:"Fotografia",note:"A cor da jaqueta pode ser comparada à amostra T-19."},
 transport:{title:"Pedido de transporte",code:"OT-0812-44",body:"Autorização de transporte para consulta/aplicação semanal. Veículo contratado porque a van institucional constava como indisponível.",kind:"Registro administrativo",note:"A van já estava fora de uso desde o sábado."},
 occurrence:{title:"Espelho da ocorrência",code:"T-01",body:"Primeira chamada registrada às 18h29. Patrulha chega às 19h08.",kind:"Ocorrência rodoviária",note:"A chamada acontece 43 minutos depois de Vicente deixar a casa-lar."},
 fiber:{title:"Triagem de fibras",code:"T-19",body:"Coleta indica fibras amarelas no cinto dianteiro. A triagem, sozinha, não determina a origem.",kind:"Triagem pericial",note:"Ravi alerta que o pretensionador poderia disparar sem passageiro."},
 missing:{title:"Anexo ausente",code:"4-B",body:"O índice cita a análise da T-19. A sequência passa de 4-A diretamente para 4-C.",kind:"Lacuna documental",note:"Há referência à remessa, à coleta e à folha. A folha não está no procedimento."},
 b12:{title:"Caderno da busca",code:"B-12",body:"17h22 — Alana não localizada. 17h41 — fundos; portão encostado; papel no trinco. 17h46 — Vicente sai com a van.",kind:"Registro manuscrito",note:"Pode ser colocado lado a lado com T-01."}
};

const key="myu-cap3-test-v1";
const defaultState={scene:0,opened:[],archived:[],timeline:[],solved:false,finished:false};
let state=Object.assign({},defaultState,JSON.parse(localStorage.getItem(key)||"{}"));
let currentDoc=null;

const qs=s=>document.querySelector(s), qsa=s=>[...document.querySelectorAll(s)];
function save(){localStorage.setItem(key,JSON.stringify(state));renderMeta()}
function sceneCount(){return 5}
function calcProgress(){const base=Math.min(state.scene,5)/5*70;const docs=Math.min(state.archived.length,5)/5*20;const solve=state.solved?10:0;return Math.round(Math.min(100,base+docs+solve))}
function showScene(n){
  state.scene=Math.max(0,Math.min(5,n));
  qsa(".scene").forEach(s=>s.classList.toggle("visible",+s.dataset.scene===state.scene));
  qsa(".rail-stop").forEach((b,i)=>{b.classList.toggle("active",i===state.scene);b.classList.toggle("done",i<state.scene)});
  const labels=["MIRANTE","ARQUIVO","RAVI","RESTAURANTE","GOUVEIA","PROGRESSO"];
  qs("#sceneLabel").textContent=labels[state.scene];
  if(state.scene===5) renderFinal();
  save(); window.scrollTo({top:0,behavior:"smooth"});
}
function renderMeta(){qs("#archiveCount").textContent=state.archived.length;qs("#progressLabel").textContent=calcProgress()+"%"}
function openDoc(id){
  const d=DOCS[id]; if(!d)return; currentDoc=id;
  if(!state.opened.includes(id))state.opened.push(id);
  qs("#drawerContent").innerHTML='<div class="doc-sheet"><div class="doc-code">'+d.code+'</div><h2>'+d.title+'</h2><dl><dt>TIPO</dt><dd>'+d.kind+'</dd><dt>STATUS</dt><dd>'+(state.archived.includes(id)?"Arquivado":"Ainda não arquivado")+'</dd></dl><p>'+d.body+'</p><div class="missing-line">'+d.note+'</div></div>';
  qs("#archiveAction").textContent=state.archived.includes(id)?"ARQUIVADO ✓":"ARQUIVAR";
  qs("#drawerBackdrop").hidden=false; qs("#drawer").classList.add("open");qs("#drawer").setAttribute("aria-hidden","false");save();
}
function closeDoc(){qs("#drawer").classList.remove("open");qs("#drawer").setAttribute("aria-hidden","true");setTimeout(()=>qs("#drawerBackdrop").hidden=true,220)}
function archiveCurrent(){if(!currentDoc)return;if(!state.archived.includes(currentDoc))state.archived.push(currentDoc);qs("#archiveAction").textContent="ARQUIVADO ✓";save()}
function renderFinal(){const p=calcProgress();qs("#finalProgress").style.width=p+"%";qs("#finalDocs").textContent=Math.min(state.archived.length,5)+" / 5";qs("#finalContradiction").textContent=state.solved?"RESOLVIDA":"NÃO RESOLVIDA";}

qsa(".next").forEach(b=>b.addEventListener("click",()=>showScene(state.scene+1)));
qsa(".prev").forEach(b=>b.addEventListener("click",()=>showScene(state.scene-1)));
qsa(".rail-stop").forEach(b=>b.addEventListener("click",()=>showScene(+b.dataset.scene)));
qsa("[data-open-doc]").forEach(b=>b.addEventListener("click",()=>openDoc(b.dataset.openDoc)));
qs("#drawerClose").addEventListener("click",closeDoc);qs("#drawerBackdrop").addEventListener("click",closeDoc);qs("#archiveAction").addEventListener("click",archiveCurrent);
qs("#archiveBtn").addEventListener("click",()=>{const id=[...state.archived,...state.opened][0]||"photo";openDoc(id)});
qs("#homeBtn").addEventListener("click",()=>showScene(0));

qsa("[data-compare]").forEach(b=>b.addEventListener("click",()=>{
 const id=b.dataset.compare;if(!state.timeline.includes(id))state.timeline.push(id);else state.timeline=state.timeline.filter(x=>x!==id);
 b.classList.toggle("selected",state.timeline.includes(id));
 const ok=state.timeline.includes("b12")&&state.timeline.includes("t01");
 qs("#gapCard").classList.toggle("unlocked",ok);qs("#timelineNext").disabled=!ok;
 if(ok){["b12","occurrence"].forEach(d=>{if(!state.opened.includes(d))state.opened.push(d)})} save();
}));
qsa(".mark").forEach(b=>b.addEventListener("click",()=>b.classList.toggle("selected")));

qsa("[data-use]").forEach(b=>b.addEventListener("click",()=>{
 qsa("[data-use]").forEach(x=>x.classList.remove("selected"));b.classList.add("selected");
 const id=b.dataset.use;const status=qs("#useStatus");
 if(id==="bait"){
   state.solved=true;
   qs("#revealBox").classList.add("solved");
   qs("#revealBox").innerHTML="<small>CONTRADIÇÃO ENCONTRADA</small><p>— Não era algodão.<br>— O que era?<br><strong>— Poliéster.</strong><br><br>Gouveia corrigiu um detalhe de uma página que acabara de dizer que nunca recebeu.</p>";
   status.textContent="A isca funcionou. A contradição foi registrada.";
   qs("#finishBtn").disabled=false;
 }else{
   status.textContent=id==="fiber"?"Ele pode dizer que uma triagem não estabelece origem.":id==="missing"?"Ele já negou ter recebido o anexo.":id==="photo"?"A fotografia liga a cor, mas não prova que ele viu o laudo.":"";
 }
 save();
}));
qs("#finishBtn").addEventListener("click",()=>{state.finished=true;showScene(5)});
qs("#timelineNext").addEventListener("click",()=>showScene(4));
qs("#resetBtn").addEventListener("click",()=>{localStorage.removeItem(key);state={...defaultState};location.reload()});
qs("#resumeBtn").addEventListener("click",()=>showScene(state.finished?4:Math.min(state.scene,4)));

state.timeline.forEach(id=>{const b=qs('[data-compare="'+id+'"]');if(b)b.classList.add("selected")});
const timelineReady=state.timeline.includes("b12")&&state.timeline.includes("t01");qs("#gapCard").classList.toggle("unlocked",timelineReady);qs("#timelineNext").disabled=!timelineReady;
if(state.solved){qs("#revealBox").classList.add("solved");qs("#revealBox").innerHTML="<small>CONTRADIÇÃO ENCONTRADA</small><p>— Não era algodão.<br>— O que era?<br><strong>— Poliéster.</strong><br><br>Gouveia corrigiu um detalhe de uma página que acabara de dizer que nunca recebeu.</p>";qs("#finishBtn").disabled=false}
showScene(Math.min(state.scene,5));renderMeta();