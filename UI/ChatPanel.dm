#define CHATPANEL_CTL "mapwindow.chatoverlay"

var/list/CHATCMD_ARGS = list("AObserve" = list("player"), "AddToTesterWhiteList" = list("text"), "Admin-Check-AI-Kills" = list("player"), "Admin-Heal" = list("player"), "Admin-Help" = list("text"), "Admin-Kill/KO" = list("player"), "AdminAssess" = list("player"), "AdminChat" = list("text"), "AdminPM" = list("player"), "AdminRename" = list("choice"), "AdminRevive" = list("player"), "Adminize" = list("player"), "Announce" = list("text"), "Assign-Stat-Redo" = list("player"), "Change-Faction" = list("player"), "Change-Max-Summon" = list("choice"), "Change-Nationalities" = list("player"), "ChangeWipeStartHour" = list("num"), "Clear-Kamui-Buff-Lock" = list("player"), "Coat-Test" = list("text"), "Communicator-Transmit" = list("text"), "Copy" = list("choice"), "Copy-AG" = list("choice"), "Create-AG" = list("player"), "Customize:-Forms" = list("player"), "Customize:-Hair" = list("player"), "Customize:-Icon" = list("player"), "Debuff-Apply" = list("num"), "Delete" = list("choice"), "DeleteSave" = list("player"), "Display-Mode" = list("choice:Windowed/Borderless/Full screen"), "Do-Damage" = list("player"), "Duplicate-Debug" = list("choice"), "Edit" = list("choice"), "Edit-Technology" = list("player"), "EditPassiveHandler" = list("player"), "Event-Character-Setup" = list("player"), "FPSControl" = list("num"), "Fix-SSJ-Transformations" = list("player"), "Flash" = list("text"), "Force-AI-Spawns" = list("choice"), "Give-Currency" = list("player"), "Give-Demon" = list("player"), "Give-Mapper" = list("player"), "Give-Rare-Race" = list("player"), "Give-Wound" = list("player"), "Give/Make" = list("player"), "Head-Start-Setup" = list("player"), "Lock-Send-Back" = list("choice"), "Mage-Admin" = list("player"), "Make-Summon" = list("player"), "Make-True-Demon" = list("player"), "ManuallyRemoveAdmin" = list("text"), "Mapper-Edit" = list("choice"), "Mapper-Fade-Visibility" = list("choice"), "MasteryUp" = list("choice"), "Message-Global" = list("text"), "Message-Z-Plane" = list("text"), "Modify-Companion" = list("choice"), "Narrate" = list("text"), "New-Character-Setup" = list("player"), "OOC" = list("text"), "Offer-Nation-Change" = list("player"), "Ping" = list("player"), "PlayerLog" = list("player"), "Prayer" = list("text"), "Preview-Ascensions" = list("player"), "PrivateNarrate" = list("player"), "ReMeditate" = list("player"), "Refund-All-Technology" = list("player"), "Refund-Technology" = list("player"), "Remove-Mapper" = list("player"), "Respec" = list("player"), "SagaManagement" = list("player"), "SagaRemoval" = list("player"), "Say" = list("text"), "Scan" = list("player"), "SecretManagement" = list("player"), "SecretRemoval" = list("player"), "Send-To-Spawn" = list("player"), "Spawn-Permission-Add" = list("choice"), "Spawn-Permission-Remove" = list("choice"), "Spawn-Race-Add" = list("choice"), "Spawn-Race-Remove" = list("choice"), "Spawn-Swap" = list("player"), "Summon" = list("player"), "Surface-Clear-Overrides" = list("choice"), "Surface-Inspect" = list("choice"), "Surface-Set-Cookie" = list("choice"), "Surface-Set-Light" = list("choice"), "Surface-Set-Occlusion" = list("choice"), "Surface-Set-Profile" = list("choice"), "Surface-Set-Shaft" = list("choice"), "Surface-Set-Type-Profile" = list("choice"), "Surface-Set-Wind" = list("choice"), "Tech-Unlock" = list("player"), "Teleport" = list("player"), "Test-Mode" = list("player"), "Think" = list("text"), "UnlockAscension" = list("player"), "UnlockForm" = list("player"), "Unteleport" = list("player"), "Use" = list("player"), "View-Maim-History" = list("player"), "ViewPassives" = list("player"), "Warper" = list("num", "num", "num"), "Whisper" = list("text"), "Wind-Debug" = list("choice"), "XYZTeleport" = list("player"), "Yell" = list("text"), "ahRemoveListing" = list("num"), "editInformation" = list("player"), "editRace" = list("player"), "editSecretDatum" = list("player"), "hep" = list("num", "num"), "lifeSetRank" = list("text", "num"), "makeFishingSpot" = list("text"), "makeForageNode" = list("text"), "makeOreNode" = list("text"), "makeTree" = list("text"), "moon-toggle-admin" = list("num"), "openBlobdatum" = list("player"), "refund-all-old-value" = list("player"))

client/var/chatpanel_zoom = 2
client/var/chatpanel_opacity = 0.85
client/var/chatpanel_geom = null
client/var/chatpanel_open = 0
client/var/chatpanel_lock = 0
client/var/chatpanel_fold = 0
client/var/chatpanel_booted = 0
client/var/chatpanel_x0 = 0
client/var/chatpanel_y0 = 0
client/var/chatpanel_ctx = null
client/var/chatpanel_last_text = null
client/var/chatpanel_last_time = -1
client/var/chatpanel_last_tag = null
client/var/chatpanel_debug = 0

client/proc/ChatPanelSendAssets()
	src << browse_rsc('HUD/chatpanel/lc_cover.png', "lc_cover.png")
	src << browse_rsc('HUD/chatpanel/lc_cover_strip.png', "lc_cover_strip.png")
	src << browse_rsc('HUD/chatpanel/lc_forgesub.png', "lc_forgesub.png")
	src << browse_rsc('HUD/chatpanel/lc_field.png', "lc_field.png")
	src << browse_rsc('HUD/chatpanel/lc_tab.png', "lc_tab.png")
	src << browse_rsc('HUD/chatpanel/lc_tab_on.png', "lc_tab_on.png")
	src << browse_rsc('HUD/chatpanel/lc_slot.png', "lc_slot.png")
	src << browse_rsc('HUD/chatpanel/lc_lock.png', "lc_lock.png")
	src << browse_rsc('HUD/chatpanel/lc_unlock.png', "lc_unlock.png")
	src << browse_rsc('HUD/chatpanel/lc_down.png', "lc_down.png")
	src << browse_rsc('HUD/chatpanel/lc_up.png', "lc_up.png")
	src << browse_rsc('HUD/chatpanel/lc_chip.png', "lc_chip.png")
	src << browse_rsc('HUD/chatpanel/lc_track.png', "lc_track.png")
	src << browse_rsc('HUD/chatpanel/lc_rowplate.png', "lc_rowplate.png")
	src << browse_rsc('HUD/chatpanel/lc_dot.png', "lc_dot.png")
	src << browse_rsc('HUD/chatpanel/lc_caret.png', "lc_caret.png")
	src << browse_rsc('HUD/chatpanel/lc_thumb_top.png', "lc_thumb_top.png")
	src << browse_rsc('HUD/chatpanel/lc_thumb_bot.png', "lc_thumb_bot.png")
	src << browse_rsc('HUD/chatpanel/lc_thumb_mid.png', "lc_thumb_mid.png")
	src << browse_rsc('HUD/chatpanel/lc_thumb_col.png', "lc_thumb_col.png")
	src << browse_rsc('HUD/monogram.ttf', "monogram.ttf")

client/proc/ChatPanelHTML()
	return {"<!DOCTYPE html><html><head><meta charset='utf-8'><style>
 @font-face{font-family:'monogram';src:url('monogram.ttf')}
 html,body{margin:0;padding:0;background:transparent;overflow:hidden;width:100%;height:100%}
 body{font:16px/16px 'monogram';color:#eaf5ff;user-select:none;-webkit-user-select:none}
 #shell{position:absolute;left:0;top:0;width:352px;height:256px;image-rendering:pixelated}
 #frame{position:absolute;left:0;top:0;right:0;bottom:0;border:16px solid transparent;border-image:url('lc_cover.png') 16 fill stretch;pointer-events:none}
 #frame.strip{border-image:url('lc_cover_strip.png') 16 fill stretch}
 #hdr{position:absolute;left:0;top:0;right:0;height:44px;cursor:move}
 .tab{position:absolute;top:8px;width:58px;height:32px;background:url('lc_tab.png') no-repeat;padding-left:8px;line-height:32px;color:#cfe3f5;box-sizing:border-box;cursor:pointer}
 .tab.on{background-image:url('lc_tab_on.png');color:#06283b}
 .tab .dot{position:absolute;left:48px;top:14px;width:4px;height:4px;background:url('lc_dot.png');display:none}
 .tab.unread .dot{display:block}
 .btn{position:absolute;top:8px;width:32px;height:32px;background:url('lc_slot.png') no-repeat;cursor:pointer}
 .btn img{position:absolute;left:8px;top:8px;width:16px;height:16px}
 #lock{right:52px}
 #fold{right:16px}
 #body{position:absolute;left:16px;right:16px;top:44px;bottom:46px;border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box}
 #log{position:absolute;left:22px;right:26px;top:50px;bottom:52px;padding:0 4px 0 4px;overflow-y:scroll;overflow-x:hidden;box-sizing:border-box;user-select:text;-webkit-user-select:text}
 #log::-webkit-scrollbar{width:14px}
 #log::-webkit-scrollbar-track{background:url('lc_track.png') no-repeat;background-size:100% 100%;margin:6px 0}
 #log::-webkit-scrollbar-thumb{border-left:1px solid transparent;border-right:1px solid transparent;background-clip:padding-box;background-origin:padding-box;background:url('lc_thumb_top.png') left top no-repeat,url('lc_thumb_bot.png') left bottom no-repeat,url('lc_thumb_mid.png') left center no-repeat,url('lc_thumb_col.png') left top repeat-y;background-size:12px 6px,12px 6px,12px 11px,12px 1px;min-height:24px}
 .line{white-space:pre-wrap;word-wrap:break-word;display:none}
 .line.show{display:block}
 .line div\[align=right]{display:block;text-align:right}
 .line div\[align=center],.line center{display:block;text-align:center}
 #inrow{position:absolute;left:16px;right:16px;bottom:12px;height:30px}
 #chip{position:absolute;left:0;top:6px;width:58px;height:18px;background:url('lc_chip.png') no-repeat;line-height:18px;text-align:center;padding-right:8px;box-sizing:border-box;cursor:pointer}
 #chip img{position:absolute;right:7px;top:7px;width:5px;height:4px}
 #rpchip{position:absolute;right:0;top:6px;width:58px;height:18px;background:url('lc_chip.png') no-repeat;line-height:18px;text-align:center;box-sizing:border-box;cursor:pointer;color:#eaf5ff}
 #rpchip:hover{color:#8be9ff}
 #field{position:absolute;left:64px;right:64px;top:0;height:30px;border:8px solid transparent;border-image:url('lc_field.png') 8 fill stretch;box-sizing:border-box}
 #in{position:absolute;left:2px;top:-1px;right:0;height:16px;margin:0;padding:0;background:transparent;border:0;outline:0;font:16px/16px 'monogram';color:#eaf5ff;caret-color:#eaf5ff}
 #grip{position:absolute;right:0;bottom:0;width:20px;height:20px;cursor:nwse-resize}
 #dd{position:absolute;left:16px;right:16px;bottom:46px;display:none;border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box;z-index:5}
 #ddl{max-height:162px;overflow:hidden}
 .dr{position:relative;height:18px;line-height:18px;padding:0 8px;white-space:nowrap;overflow:hidden;cursor:pointer;color:#eaf5ff}
 .dr .pl{position:absolute;left:0;top:0;right:0;bottom:0;border:6px solid transparent;border-image:url('lc_rowplate.png') 6 fill stretch;display:none}
 .dr.sel .pl{display:block}
 .dr span{position:relative}
 .dr .cat{position:absolute;right:8px;top:0;color:#7ec8f0}
 .dr.hint{color:#b8b8d9;cursor:default}
 </style></head><body>
 <div id='shell'>
  <div id='frame'></div>
  <div id='hdr'>
   <div class='tab on' id='t_all' style='left:16px'>ALL<span class='dot'></span></div>
   <div class='tab' id='t_combat' style='left:76px'>COMBAT<span class='dot'></span></div>
   <div class='tab' id='t_ic' style='left:136px'>IC<span class='dot'></span></div>
   <div class='tab' id='t_ooc' style='left:196px'>OOC<span class='dot'></span></div>
   <div class='btn' id='lock'><img src='lc_unlock.png' alt=''></div>
   <div class='btn' id='fold'><img src='lc_down.png' alt=''></div>
  </div>
  <div id='body'></div>
  <div id='log'></div>
  <div id='inrow'>
   <div id='chip'>SAY<img src='lc_caret.png' alt=''></div>
   <div id='field'><input id='in' type='text' autocomplete='off' spellcheck='false'></div>
   <div id='rpchip' title='open the roleplay box'>RP</div>
  </div>
  <div id='dd'><div id='ddl'></div></div>
  <div id='grip'></div>
 </div>
 <script>
 var shell=document.getElementById('shell'), hdr=document.getElementById('hdr'), log=document.getElementById('log'), inp=document.getElementById('in');
 var chip=document.getElementById('chip'), grip=document.getElementById('grip'), fold=document.getElementById('fold'), lockBtn=document.getElementById('lock');
 var lockImg=lockBtn.getElementsByTagName('img').item(0);
 var frame=document.getElementById('frame'), body=document.getElementById('body'), inrow=document.getElementById('inrow');
 var foldImg=fold.getElementsByTagName('img').item(0);
 var PREVIEW=false;
 var Z=2, OP=0.85, G={x:0,y:0,w:704,h:512}, B=null, tab='all', collapsed=false, ch='say', MAXL=300, live=false, stick=true, locked=false;
 function clampNum(v,lo,hi){ if(hi<lo) hi=lo; if(v<lo) return lo; if(v>hi) return hi; return v; }
 function clampG(){
  if(!B) return;
  var h=collapsed?48*Z:G.h;
  if(G.w>B.x1-B.x0) G.w=B.x1-B.x0;
  if(!collapsed && G.h>B.y1-B.y0){ G.h=B.y1-B.y0; h=G.h; }
  G.x=clampNum(G.x,B.x0,B.x1-G.w); G.y=clampNum(G.y,B.y0,B.y1-h);
 }
 log.addEventListener('scroll',function(){ stick=(log.scrollTop+log.clientHeight>=log.scrollHeight-4); });
 function ws(p){ if(window.BYOND) BYOND.winset('mapwindow.chatoverlay',p); }
 function topic(p){ if(window.BYOND) BYOND.topic(p); }
 function focusMap(){ if(window.BYOND) BYOND.winset('mapwindow.map',{focus:true}); }
 function layout(){
  document.body.style.zoom=Z;
  shell.style.width=Math.round(G.w/Z)+'px';
  shell.style.height=(collapsed?48:Math.round(G.h/Z))+'px';
  frame.style.opacity=OP; body.style.opacity=OP;
  frame.classList.toggle('strip',collapsed);
  if(!live){ shell.style.left=Math.round(G.x/Z)+'px'; shell.style.top=Math.round(G.y/Z)+'px'; }
  var show=collapsed?'none':'block';
  body.style.display=show; log.style.display=show; inrow.style.display=show; grip.style.display=(collapsed||locked)?'none':'block';
  foldImg.src=collapsed?'lc_up.png':'lc_down.png';
  lockImg.src=locked?'lc_lock.png':'lc_unlock.png'; hdr.style.cursor=locked?'default':'move';
  if(stick){ requestAnimationFrame(function(){ log.scrollTop=log.scrollHeight; }); }
 }
 function setGeom(x,y,w,h,z,op,bx0,by0,bx1,by1,lk,fd){ G={x:+x,y:+y,w:+w,h:+h}; Z=+z; OP=+op; if(bx1!==undefined){ B={x0:+bx0,y0:+by0,x1:+bx1,y1:+by1}; } locked=(+lk)?true:false; var wantFold=(+fd)?true:false; collapsed=false; if(wantFold){ collapsed=true; G.y+=G.h-48*Z; } clampG(); if(collapsed){ flush(); } else { layout(); } }
 function focusInput(){ inp.focus(); }
 function setZoom(z){ var nz=+z; G.w=Math.round(G.w/Z*nz); G.h=Math.round(G.h/Z*nz); Z=nz; flush(); report(); }
 var pending=false;
 function flush(){ pending=false; clampG(); ws({pos:G.x+','+G.y, size:G.w+'x'+(collapsed?48*Z:G.h)}); layout(); }
 function sched(){ if(!pending){ pending=true; requestAnimationFrame(flush); } }
 function report(){ topic({chatpanel:'geom', g:G.x+','+G.y+','+G.w+','+G.h}); }
 var drag=null;
 hdr.addEventListener('pointerdown',function(e){ if(e.button!==0||locked) return; if(e.target.closest('.tab')||e.target.closest('.btn')) return; drag={sx:e.screenX,sy:e.screenY,x:G.x,y:G.y}; try{ hdr.setPointerCapture(e.pointerId); }catch(err){} e.preventDefault(); });
 hdr.addEventListener('pointermove',function(e){ if(!drag) return; G.x=drag.x+(e.screenX-drag.sx); G.y=drag.y+(e.screenY-drag.sy); clampG(); sched(); });
 hdr.addEventListener('pointerup',function(e){ if(!drag) return; drag=null; flush(); report(); focusMap(); });
 var rs=null;
 grip.addEventListener('pointerdown',function(e){ if(e.button!==0||locked) return; rs={sx:e.screenX,sy:e.screenY,w:G.w,h:G.h}; try{ grip.setPointerCapture(e.pointerId); }catch(err){} e.preventDefault(); e.stopPropagation(); });
 grip.addEventListener('pointermove',function(e){ if(!rs) return; var mw=B?B.x1-G.x:1e9, mh=B?B.y1-G.y:1e9; G.w=clampNum(rs.w+(e.screenX-rs.sx),352*Z,mw); G.h=clampNum(rs.h+(e.screenY-rs.sy),160*Z,mh); sched(); });
 grip.addEventListener('pointerup',function(e){ if(!rs) return; rs=null; flush(); report(); focusMap(); });
 function setTab(t){
  tab=t; var tabs=document.getElementsByClassName('tab');
  for(var i=0;i<tabs.length;i++){ var el=tabs.item(i); var mine=(el.id==='t_'+t); el.classList.toggle('on',mine); if(mine) el.classList.remove('unread'); }
  refilter(); log.scrollTop=log.scrollHeight;
 }
 function refilter(){ var ls=log.getElementsByClassName('line'); for(var i=0;i<ls.length;i++){ var el=ls.item(i); el.classList.toggle('show',tab==='all'||el.classList.contains('c_'+tab)); } }
 var counts={};
 function cleanHtml(h){ var out=''; for(var i=0;i<h.length;i++){ var c=h.charCodeAt(i); if(c>=32||c===10||c===9) out+=h.charAt(i); } return out; }
 var BAD_TAGS={script:1,style:1,img:1,iframe:1,object:1,embed:1,svg:1,link:1,meta:1,form:1,input:1,button:1,video:1,audio:1,source:1};
 function scrub(el){ var all=el.querySelectorAll('*'); for(var i=all.length-1;i>=0;i--){ var n=all\[i]; var t=n.tagName.toLowerCase(); if(BAD_TAGS\[t]){ n.parentNode.removeChild(n); continue; } for(var k=n.attributes.length-1;k>=0;k--){ var a=n.attributes\[k]; var an=a.name.toLowerCase(); if(an.indexOf('on')===0||an==='style'&&a.value.indexOf('url')>=0||(an==='href'&&a.value.trim().toLowerCase().indexOf('javascript')===0)){ n.removeAttribute(a.name); } } if(t==='a'){ var h=(n.getAttribute('href')||'').trim().toLowerCase(); if(h.indexOf('http://')!==0&&h.indexOf('https://')!==0) n.removeAttribute('href'); else n.setAttribute('target','_blank'); } } }
 function addLine(tag,html){
  if(tag!=='ic'&&tag!=='ooc'&&tag!=='combat') tag='all';
  var el=document.createElement('div'); el.className='line c_'+tag; el.innerHTML=cleanHtml(html); scrub(el); el._raw=html; log.appendChild(el);
  el.classList.toggle('show',tab==='all'||tag===tab);
  counts\[tag]=(counts\[tag]||0)+1;
  if(counts\[tag]>MAXL){ var old=log.getElementsByClassName('c_'+tag); if(old.length){ log.removeChild(old.item(0)); counts\[tag]--; } }
  if(tab!=='all'&&tag!==tab&&tag!=='all'){ var tb=document.getElementById('t_'+tag); if(tb) tb.classList.add('unread'); }
  if(stick) log.scrollTop=log.scrollHeight;
 }
 function retagLast(tag,html){
  if(tag!=='ic'&&tag!=='ooc'&&tag!=='combat') return;
  var el=log.lastElementChild; if(!el) return;
  if(el._raw!==html){ var prev=el.previousElementSibling; if(prev&&prev._raw===html) el=prev; else return; }
  if(!el.classList.contains('c_all')) return;
  el.classList.remove('c_all'); el.classList.add('c_'+tag);
  counts\['all']=Math.max(0,(counts\['all']||1)-1); counts\[tag]=(counts\[tag]||0)+1;
  el.classList.toggle('show',tab==='all'||tag===tab);
  if(tab!=='all'&&tag!==tab){ var tb=document.getElementById('t_'+tag); if(tb) tb.classList.add('unread'); }
 }
 var tabEls=document.getElementsByClassName('tab');
 for(var ti=0;ti<tabEls.length;ti++){ (function(el){ el.addEventListener('click',function(){ setTab(el.id.substring(2)); focusMap(); }); })(tabEls.item(ti)); }
 fold.addEventListener('click',function(){ var d=G.h-48*Z; if(!collapsed){ collapsed=true; G.y+=d; } else { collapsed=false; G.y=G.y-d; } clampG(); flush(); report(); topic({chatpanel:'fold',f:collapsed?1:0}); focusMap(); });
 lockBtn.addEventListener('click',function(){ locked=!locked; layout(); topic({chatpanel:'lock',l:locked?1:0}); focusMap(); });
 var CHS=\['say','ooc','think','whisper'];
 function nextCh(){ ch=CHS\[(CHS.indexOf(ch)+1)%CHS.length]; chip.firstChild.nodeValue=ch.toUpperCase(); }
 chip.addEventListener('click',function(){ nextCh(); inp.focus(); });
 document.getElementById('rpchip').addEventListener('click',function(){ topic({chatpanel:'rp'}); });
 var dd=document.getElementById('dd'), ddl=document.getElementById('ddl');
 var cmds=\[], players=\[], cmdsAt=0, ddItems=\[], ddSel=0, ddMode='', ddCmd=null;
 function setCommands(s){ cmds=\[]; var parts=(s||'').split(';'); for(var i=0;i<parts.length;i++){ var f=parts\[i]; if(!f) continue; var a=f.split('|'); cmds.push({id:a\[0],cat:a\[1]||'',args:(a\[2]?a\[2].split(','):\[])}); } cmdsAt=Date.now(); refreshDD(); }
 function setPlayers(s){ players=(s||'').split('|').filter(function(x){ return x.length>0; }); refreshDD(); }
 function ddClose(){ dd.style.display='none'; ddItems=\[]; ddMode=''; ddCmd=null; }
 function splitArgs(rest){ var out=\[], cur='', q=false; for(var i=0;i<rest.length;i++){ var c=rest.charAt(i); if(c==='"'){ q=!q; continue; } if(c===' '&&!q){ if(cur.length){ out.push(cur); cur=''; } continue; } cur+=c; } if(cur.length) out.push(cur); return out; }
 function findCmd(id){ var l=id.toLowerCase(); for(var i=0;i<cmds.length;i++){ if(cmds\[i].id.toLowerCase()===l) return cmds\[i]; } return null; }
 function esc(x){ return String(x).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
 function refreshDD(){
  var v=inp.value; if(v.charAt(0)!=='/'){ ddClose(); return; }
  if(Date.now()-cmdsAt>10000){ cmdsAt=Date.now(); topic({chatpanel:'cmds'}); }
  var body=v.substring(1); var sp=body.indexOf(' ');
  ddItems=\[];
  if(sp<0){
   ddMode='cmd'; var q=body.toLowerCase();
   for(var i=0;i<cmds.length&&ddItems.length<8;i++){ if(!q||cmds\[i].id.toLowerCase().indexOf(q)>=0) ddItems.push({label:cmds\[i].id,cat:cmds\[i].cat,cmd:cmds\[i]}); }
  } else {
   var c=findCmd(body.substring(0,sp)); ddCmd=c;
   var endsSp=body.charAt(body.length-1)===' ';
   var given=splitArgs(body.substring(sp+1)); var typedTail=endsSp?'':(given.length?given\[given.length-1]:'');
   var idx=endsSp?given.length:Math.max(0,given.length-1);
   if(c&&c.args.length>idx){
    var k=c.args\[idx]; ddMode='arg';
    if(k==='player'){ if(!players.length) topic({chatpanel:'players'}); var q2=typedTail.toLowerCase(); for(var j=0;j<players.length&&ddItems.length<8;j++){ if(!q2||players\[j].toLowerCase().indexOf(q2)>=0) ddItems.push({label:players\[j],cat:'PLAYER',fill:true}); } if(!ddItems.length) ddItems.push({label:'player name',cat:'PLAYER',hint:true}); }
    else if(k.indexOf('choice:')===0){ var ch=k.substring(7).split('/'); for(var m=0;m<ch.length&&ddItems.length<8;m++){ if(!typedTail||ch\[m].toLowerCase().indexOf(typedTail.toLowerCase())>=0) ddItems.push({label:ch\[m],cat:'CHOICE',fill:true}); } }
    else { ddItems.push({label:k==='num'?'number':'text',cat:k.toUpperCase(),hint:true}); }
   } else { ddClose(); return; }
  }
  if(!ddItems.length){ ddClose(); return; }
  if(ddSel>=ddItems.length) ddSel=0;
  var h='';
  for(var r=0;r<ddItems.length;r++){ var it=ddItems\[r]; h+="<div class='dr"+(r===ddSel&&!it.hint?' sel':'')+(it.hint?' hint':'')+"' data-i='"+r+"'><div class='pl'></div><span>"+esc(it.label)+"</span><span class='cat'>"+esc(it.cat)+"</span></div>"; }
  ddl.innerHTML=h; dd.style.display='block';
 }
 function ddAccept(){
  var it=ddItems\[ddSel]; if(!it||it.hint) return false;
  var body=inp.value.substring(1); var sp=body.indexOf(' ');
  if(ddMode==='cmd'){ inp.value='/'+it.label+(it.cmd.args.length?' ':''); ddSel=0; refreshDD(); return true; }
  var head=body.substring(0,sp+1); var endsSp=body.charAt(body.length-1)===' ';
  var given=splitArgs(body.substring(sp+1)); if(!endsSp&&given.length) given.pop();
  var val=it.label.indexOf(' ')>=0?'"'+it.label+'"':it.label; given.push(val);
  inp.value='/'+head+given.join(' ')+' '; ddSel=0; refreshDD(); return true;
 }
 function cmdOf(v){ var b=v.substring(1); var sp=b.indexOf(' '); return findCmd(sp<0?b:b.substring(0,sp)); }
 function runLine(v){
  var body=v.substring(1).trim(); if(!body) return;
  var bl=body.toLowerCase();
  if(bl==='admin'||bl==='admin-panel'||bl==='mapper'||bl==='mapper-panel'){ topic({chatpanel:'admin',tab:(bl.indexOf('mapper')===0)?'map':'cmd'}); inp.value=''; ddClose(); inp.blur(); focusMap(); return; }
  if(bl==='rp'||bl==='roleplay-box'||bl==='emote'||bl==='emotenew'){ topic({chatpanel:'rp'}); inp.value=''; ddClose(); inp.blur(); return; }
  if(bl.indexOf('me ')===0){ var mt=body.substring(3).trim(); if(mt.length) topic({chatpanel:'me',text:mt}); inp.value=''; ddClose(); inp.blur(); focusMap(); return; }
  var sp=body.indexOf(' '); var c=findCmd(sp<0?body:body.substring(0,sp));
  if(c&&c.args.length){ var given=sp<0?\[]:splitArgs(body.substring(sp+1)); if(given.length<c.args.length){ if(inp.value.charAt(inp.value.length-1)!==' ') inp.value+=' '; ddSel=0; refreshDD(); return; } }
  if(window.BYOND) BYOND.command(body);
  inp.value=''; ddClose(); inp.blur(); focusMap();
 }
 ddl.addEventListener('pointerdown',function(e){ var row=e.target.closest('.dr'); if(!row||row.classList.contains('hint')) return; ddSel=+row.getAttribute('data-i'); ddAccept(); inp.focus(); e.preventDefault(); });
 inp.addEventListener('input',function(){ ddSel=0; refreshDD(); });
 inp.addEventListener('keydown',function(e){
  if(dd.style.display==='block'){
   if(e.key==='ArrowDown'){ ddSel=(ddSel+1)%ddItems.length; refreshDD(); e.preventDefault(); return; }
   if(e.key==='ArrowUp'){ ddSel=(ddSel-1+ddItems.length)%ddItems.length; refreshDD(); e.preventDefault(); return; }
   if(e.key==='Tab'){ ddAccept(); e.preventDefault(); return; }
   if(e.key==='Escape'){ ddClose(); e.preventDefault(); return; }
   if(e.key==='Enter'){
    var it=ddItems\[ddSel];
    if(ddMode==='cmd'&&it&&!it.hint&&inp.value.substring(1).toLowerCase()!==it.label.toLowerCase()){ ddAccept(); var c2=cmdOf(inp.value); if(c2&&c2.args.length){ e.preventDefault(); return; } }
    else if(ddMode==='arg'&&it&&it.fill&&inp.value.charAt(inp.value.length-1)!==' '){ ddAccept(); }
    runLine(inp.value); e.preventDefault(); return;
   }
  }
  if(e.key==='Enter'){ var v=inp.value.trim(); if(v){ if(v.charAt(0)==='/'){ runLine(v); e.preventDefault(); return; } else { topic({chatpanel:'send',ch:ch,text:v}); if(!live) addLine(ch==='ooc'?'ooc':'ic',(ch==='ooc'?"<span style='color:#5fe08a'>OOC:</span> You: ":'You say: ')+v); } } inp.value=''; ddClose(); inp.blur(); focusMap(); e.preventDefault(); }
  else if(e.key==='Escape'){ ddClose(); inp.blur(); focusMap(); e.preventDefault(); }
  else if(e.key==='Tab'){ if(inp.value.length===0){ nextCh(); } e.preventDefault(); }
 });
 log.addEventListener('pointerup',function(){ var s=window.getSelection?window.getSelection().toString():''; if(s==='') focusMap(); });
 document.addEventListener('contextmenu',function(e){ e.preventDefault(); });
 function seed(){
  addLine('ic',"<span style='color:#eaf5ff'>Valdiel says: The gate's shut again. Anyone have the key?</span>");
  addLine('ic',"<span style='color:#f2c87e'>Seraphine says: One second, checking the log.</span>");
  addLine('ooc',"<span style='color:#5fe08a'>OOC:</span><span style='color:#eaf5ff'> Kaidos: brb, client restart</span>");
  addLine('ic',"<span style='color:#f2c87e'>Seraphine whispers: don't tell him about the merchant.</span>");
  addLine('combat',"<span style='color:#e4635e'>You queue up a Heavy Strike!</span>");
  addLine('combat',"<span style='color:#7ec8f0'>Kaidos froze Seraphine solid with Snowgrave.</span>");
  addLine('ic',"<span style='color:#f2c87e'>*Seraphine shakes the frost from her sleeves*</span>");
  addLine('ic',"<span style='color:#eaf5ff'>Valdiel yells: RUN!</span>");
  addLine('ooc',"<span style='color:#5fe08a'>OOC:</span><span style='color:#eaf5ff'> Valdiel: lol</span>");
  addLine('all',"<span style='color:#b8b8d9'>Reboot in 10 minutes - wrap up your scenes.</span>");
  addLine('ic',"<span style='color:#eaf5ff'>Kaidos says: Coming through the east gate now, cover me.</span>");
  addLine('ic',"<span style='color:#f2c87e'>Seraphine says: On it.</span>");
  addLine('ooc',"<span style='color:#5fe08a'>OOC:</span><span style='color:#eaf5ff'> Kaidos: back</span>");
  addLine('ic',"<span style='color:#eaf5ff'>*Valdiel plants her feet and raises the blade*</span>");
  log.scrollTop=log.scrollHeight;
 }
 function boot(){ live=true; layout(); topic({chatpanel:'ready'}); topic({chatpanel:'cmds'}); }
 if(window.BYOND){ boot(); } else { window.addEventListener('byond-ready',boot); }
 if(PREVIEW) seed();
 if(PREVIEW){ setCommands('Admin-Teleport|Admin|player;Teleport-To|Admin|player;Summon-Player|Admin|player;Set-Spawn-Point|Admin|;Reboot-Warning|Admin|text;Who|Other|;Toggle-Weather|Admin|choice:clear/rain/storm'); setPlayers('Seraphine|Kaidos|Valdiel'); }
 if(PREVIEW){ setTimeout(function(){ if(!live){ setGeom(600,240,704,512,2,0.85,0,0,4000,3000); } },300); }
 </script></body></html>
"}

client/proc/PanelViewTiles()
	var/list/v = splittext("[view]", "x")
	if(v.len >= 2 && text2num(v[1]) && text2num(v[2]))
		return list(text2num(v[1]), text2num(v[2]))
	var/n = text2num("[view]")
	if(isnull(n)) n = 12
	return list(2 * n + 1, 2 * n + 1)

client/proc/PanelViewRect()
	var/list/parts = splittext(winget(src, "mapwindow.map", "size"), "x")
	if(parts.len < 2) return null
	var/pw = text2num(parts[1])
	var/ph = text2num(parts[2])
	if(!pw || !ph) return null
	var/list/vs = splittext(winget(src, "mapwindow.map", "view-size"), "x")
	var/vw = pw
	var/vh = ph
	if(vs.len >= 2 && text2num(vs[1]) && text2num(vs[2]))
		vw = text2num(vs[1])
		vh = text2num(vs[2])
	var/list/cp = splittext(winget(src, "mapwindow.map", "pos"), ",")
	var/cx = 0
	var/cy = 0
	if(cp.len >= 2 && !isnull(text2num(cp[1])) && !isnull(text2num(cp[2])))
		cx = text2num(cp[1])
		cy = text2num(cp[2])
	var/list/pp = splittext(winget(src, "mapwindow", "size"), "x")
	var/panew = pw
	var/paneh = ph
	if(pp.len >= 2 && text2num(pp[1]) && text2num(pp[2]))
		panew = text2num(pp[1])
		paneh = text2num(pp[2])
	var/list/t = PanelViewTiles()
	var/zf = vw / (t[1] * 32)
	var/z = (zf >= 1.5) ? 2 : 1
	var/x0 = max(cx + round((pw - vw) / 2), 0)
	var/y0 = max(cy + round((ph - vh) / 2), 0)
	var/x1 = min(cx + round((pw - vw) / 2) + vw, panew)
	var/y1 = min(cy + round((ph - vh) / 2) + vh, paneh)
	return list(x0, y0, x1, y1, z)

client/proc/ChatPanelPlace()
	var/list/r = PanelViewRect()
	if(!r)
		src << "Chat panel: could not read the map control size."
		return
	var/x0 = r[1]
	var/y0 = r[2]
	var/x1 = r[3]
	var/y1 = r[4]
	chatpanel_zoom = r[5]
	var/z = chatpanel_zoom
	var/vw = x1 - x0
	var/vh = y1 - y0
	chatpanel_x0 = x0
	chatpanel_y0 = y0
	var/x
	var/y
	var/w
	var/h
	if(chatpanel_geom)
		var/list/g = splittext(chatpanel_geom, ",")
		if(g.len == 4)
			var/gx = text2num(g[1]); var/gy = text2num(g[2]); var/gw = text2num(g[3]); var/gh = text2num(g[4])
			if(!isnull(gx) && !isnull(gy) && gw > 0 && gh > 0)
				x = x0 + round(gx * z); y = y0 + round(gy * z); w = round(gw * z); h = round(gh * z)
	if(!w || !h)
		w = 352 * z
		h = 256 * z
		x = x1 - w - 8 * z
		y = y1 - h - 84 * z
	if(w > vw) w = vw
	if(h > vh) h = vh
	if(x + w > x1) x = x1 - w
	if(y + h > y1) y = y1 - h
	if(x < x0) x = x0
	if(y < y0) y = y0
	chatpanel_geom = "[(x - x0) / z],[(y - y0) / z],[w / z],[h / z]"
	winset(src, CHATPANEL_CTL, "pos=[x],[y];size=[w]x[h]")
	src << output(list2params(list(x, y, w, h, z, chatpanel_opacity, x0, y0, x1, y1, chatpanel_lock, chatpanel_fold)), "[CHATPANEL_CTL]:setGeom")

client/proc/ChatPanelStoreGeom(gtext)
	var/list/g = splittext(gtext, ",")
	if(g.len != 4) return
	var/x = text2num(g[1]); var/y = text2num(g[2]); var/w = text2num(g[3]); var/h = text2num(g[4])
	if(isnull(x) || isnull(y) || !(w > 0) || !(h > 0)) return
	var/z = chatpanel_zoom ? chatpanel_zoom : 1
	chatpanel_geom = "[(x - chatpanel_x0) / z],[(y - chatpanel_y0) / z],[w / z],[h / z]"
	setPref("chatGeom", chatpanel_geom)

client/proc/ChatPanelShow()
	ChatPanelSendAssets()
	winset(src, CHATPANEL_CTL, "inner-background-color=transparent")
	src << browse(ChatPanelHTML(), "window=[CHATPANEL_CTL]")
	ChatPanelPlace()
	chatpanel_open = 1
	winset(src, CHATPANEL_CTL, "is-visible=true")

client/proc/ChatPanelHide()
	chatpanel_open = 0
	winset(src, CHATPANEL_CTL, "is-visible=false")
	src << "Chat panel hidden."

client/proc/ChatPanelReport()
	var/f = winget(src, null, "focus")
	var/v = winget(src, CHATPANEL_CTL, "is-visible")
	var/p = winget(src, CHATPANEL_CTL, "pos")
	var/s = winget(src, CHATPANEL_CTL, "size")
	src << "Chat panel report: focus=[f] visible=[v] pos=[p] size=[s] geom=[chatpanel_geom] lock=[chatpanel_lock] fold=[chatpanel_fold] zoom=[chatpanel_zoom] view=[view] map=[winget(src, "mapwindow.map", "size")] view-size=[winget(src, "mapwindow.map", "view-size")]"

client/proc/ChatPanelBoot()
	if(chatpanel_booted) return
	chatpanel_booted = 1
	if(prefs)
		var/g = getPref("chatGeom")
		if(istext(g) && length(g)) chatpanel_geom = g
		chatpanel_lock = getPref("chatLock") ? 1 : 0
		chatpanel_fold = getPref("chatFold") ? 1 : 0
	ChatPanelShow()
	AdminPageBoot()
	AdminPageInitButton()
	RPBoxBoot()
	spawn(10)
		RPBoxRelogHint()

var/list/CHATCMD_CATS = list("Admin", "Mapper", "Debug", "Utility", "Other", "Roleplay")

client/proc/ChatPanelBuildCmds()
	if(!mob) return
	var/list/out = list()
	var/list/seen = list()
	for(var/v in (mob.verbs + verbs))
		var/nm = "[v:name]"
		if(!length(nm)) continue
		if(v:hidden) continue
		var/cat = "[v:category]"
		if(!(cat in CHATCMD_CATS)) continue
		var/id = replacetext(nm, " ", "-")
		if(seen[id]) continue
		seen[id] = 1
		var/list/a = CHATCMD_ARGS[id]
		out += "[id]|[cat]|[islist(a) ? jointext(a, ",") : ""]"
	if(mob.Admin) out += "Admin-Panel|Admin|"
	if(mob.Mapper) out += "Mapper-Panel|Mapper|"
	src << output(list2params(list(jointext(out, ";"))), "[CHATPANEL_CTL]:setCommands")

client/proc/ChatPanelPlayers(ctl = CHATPANEL_CTL)
	var/list/names = list()
	for(var/mob/Players/P in players)
		if(!P.client) continue
		var/n = "[P.name]"
		if(length(n)) names += n
	src << output(list2params(list(jointext(names, "|"))), "[ctl]:setPlayers")

client/proc/ChatPanelFocusInput()
	if(!chatpanel_open) return
	winset(src, CHATPANEL_CTL, "focus=true")
	src << output("", "[CHATPANEL_CTL]:focusInput")

var/list/CHATPANEL_COMBAT_WORDS = list("power", "strike", " hit", "damage", "block", "parr", "dodge", "queue", "charg", "stun", "knock", "attack", "guard", "counter", "transform", "aura", "wound", "injur", "bleed", "stasis", "burn", "poison", "shock", "unconscious", "flurry", "beam", "blast", "target", "energy", "ki ")

proc/ChatPanelControlTag(window)
	if(isnull(window) || window == "") return "plain"
	var/w = "[window]"
	var/dot = findtext(w, ".", 1, 0)
	while(dot)
		w = copytext(w, dot + 1)
		dot = findtext(w, ".", 1, 0)
	switch(w)
		if("icchat") return "ic"
		if("oocchat", "loocchat") return "ooc"
		if("output") return "all"
	return null

proc/ChatPanelLooksCombat(t)
	for(var/k in CHATPANEL_COMBAT_WORDS)
		if(findtext(t, k)) return 1
	return 0

client/proc/operator<<(x, target, window)
	if(istext(x) && chatpanel_open)
		var/tag = ChatPanelControlTag(window)
		if(chatpanel_debug)
			src << output(list2params(list("all", "<span style='color:#b8b8d9'>\[bus\] window=[html_encode("[window]")] tag=[tag] len=[length(x)]</span>")), "[CHATPANEL_CTL]:addLine")
		if(tag)
			if(tag == "plain")
				tag = chatpanel_ctx ? chatpanel_ctx : (ChatPanelLooksCombat(x) ? "combat" : "all")
			if(x == chatpanel_last_text && world.time == chatpanel_last_time)
				if(tag != "all" && chatpanel_last_tag == "all")
					chatpanel_last_tag = tag
					src << output(list2params(list(tag, x)), "[CHATPANEL_CTL]:retagLast")
			else
				chatpanel_last_text = x
				chatpanel_last_time = world.time
				chatpanel_last_tag = tag
				src << output(list2params(list(tag, x)), "[CHATPANEL_CTL]:addLine")
	..()

mob/newDoDamage(mob/defender, val, unarmed, sword, secondhit, thirdhit, trueMult, spiritAtk, destructive, autohit, list/dmgTypes, strike/S = null)
	var/client/a = client
	var/client/d = defender ? defender.client : null
	var/pa = a ? a.chatpanel_ctx : null
	var/pd = d ? d.chatpanel_ctx : null
	if(a) a.chatpanel_ctx = "combat"
	if(d) d.chatpanel_ctx = "combat"
	. = ..()
	if(a) a.chatpanel_ctx = pa
	if(d) d.chatpanel_ctx = pd

mob/PowerUp()
	var/client/c = client
	var/prev = c ? c.chatpanel_ctx : null
	if(c) c.chatpanel_ctx = "combat"
	. = ..()
	if(c) c.chatpanel_ctx = prev

mob/PowerDown()
	var/client/c = client
	var/prev = c ? c.chatpanel_ctx : null
	if(c) c.chatpanel_ctx = "combat"
	. = ..()
	if(c) c.chatpanel_ctx = prev

mob/KaiokenPowerUp()
	var/client/c = client
	var/prev = c ? c.chatpanel_ctx : null
	if(c) c.chatpanel_ctx = "combat"
	. = ..()
	if(c) c.chatpanel_ctx = prev

client/Topic(href, href_list[], hsrc)
	if(href_list && href_list["adminpage"])
		AdminPageTopic(href_list)
		return
	if(href_list && href_list["rpbox"])
		RPBoxTopic(href_list)
		return
	if(href_list && href_list["chatpanel"])
		switch(href_list["chatpanel"])
			if("admin")
				AdminPageShow(href_list["tab"])
			if("rp")
				RPBoxToggle()
			if("me")
				RPBoxQuick(href_list["text"])
			if("ready")
				ChatPanelPlace()
			if("cmds")
				ChatPanelBuildCmds()
			if("players")
				ChatPanelPlayers()
			if("geom")
				ChatPanelStoreGeom(href_list["g"])
			if("lock")
				chatpanel_lock = text2num(href_list["l"]) ? 1 : 0
				setPref("chatLock", chatpanel_lock)
			if("fold")
				chatpanel_fold = text2num(href_list["f"]) ? 1 : 0
				setPref("chatFold", chatpanel_fold)
			if("send")
				var/t = href_list["text"]
				if(t && length(t))
					switch(href_list["ch"])
						if("ooc")
							OOC(t)
						if("think")
							Think(t)
						if("whisper")
							Whisper(t)
						else
							sayProc(t, null)
		return
	return ..()

mob/Players/verb/ChatPanel_Focus()
	set name = "Chat-Focus"
	set hidden = 1
	client?.ChatPanelFocusInput()

mob/Players/verb/ChatPanel_Show()
	set name = "Chat Overlay Show"
	set category = "Utility"
	set hidden = 1
	client?.ChatPanelShow()

mob/Players/verb/ChatPanel_Hide()
	set name = "Chat Overlay Hide"
	set category = "Utility"
	set hidden = 1
	client?.ChatPanelHide()

mob/Players/verb/ChatPanel_Reset()
	set name = "Chat Overlay Reset Position"
	set category = "Utility"
	if(!client) return
	client.chatpanel_geom = null
	client.chatpanel_fold = 0
	client.setPref("chatGeom", null)
	client.setPref("chatFold", 0)
	client.ChatPanelShow()

mob/Players/verb/ChatPanel_Debug()
	set name = "Chat Overlay Debug"
	set category = "Utility"
	set hidden = 1
	if(!client) return
	client.chatpanel_debug = !client.chatpanel_debug
	src << "Chat panel debug [client.chatpanel_debug ? "on" : "off"]."

mob/Players/verb/ChatPanel_Report()
	set name = "Chat Overlay Report"
	set category = "Utility"
	set hidden = 1
	client?.ChatPanelReport()
