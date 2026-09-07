#define FACEPAGE_CTL "mapwindow.faceoverlay"

client/var/facepage_open = 0
client/var/facepage_geom = null
client/var/facepage_zoom = 1
client/var/facepage_x0 = 0
client/var/facepage_y0 = 0
client/var/facepage_booted = 0

client/proc/FacePageSendAssets()
	ChatPanelSendAssets()
	src << browse_rsc('HUD/chatpanel/lc_tabw.png', "lc_tabw.png")
	src << browse_rsc('HUD/chatpanel/lc_tabw_on.png', "lc_tabw_on.png")
	src << browse_rsc('HUD/chatpanel/lc_chip_a.png', "lc_chip_a.png")
	src << browse_rsc('HUD/chatpanel/lc_chip_b.png', "lc_chip_b.png")
	src << browse_rsc('HUD/chatpanel/lc_band.png', "lc_band.png")
	src << browse_rsc('HUD/chatpanel/lc_star.png', "lc_star.png")

client/proc/FacePageHTML()
	return {"<!DOCTYPE html><html><head><meta charset='utf-8'><style>
 @font-face{font-family:'monogram';src:url('monogram.ttf')}
 html,body{margin:0;padding:0;background:transparent;overflow:hidden;width:100%;height:100%}
 body{font:16px/16px 'monogram';color:#eaf5ff;user-select:none;-webkit-user-select:none}
 #shell{position:absolute;left:0;top:0;width:352px;height:350px;image-rendering:pixelated}
 #frame{position:absolute;left:0;top:0;right:0;bottom:0;border:16px solid transparent;border-image:url('lc_cover.png') 16 fill stretch;pointer-events:none}
 #hdr{position:absolute;left:0;top:0;right:0;height:44px}
 .tabw{position:absolute;top:8px;width:84px;height:32px;background:url('lc_tabw.png') no-repeat;line-height:32px;text-align:center;color:#cfe3f5;cursor:pointer}
 .tabw.on{background-image:url('lc_tabw_on.png');color:#06283b}
 .btn{position:absolute;top:8px;right:16px;width:32px;height:32px;background:url('lc_slot.png') no-repeat;cursor:pointer}
 .btn img{position:absolute;left:0;top:0;width:32px;height:32px}
 #body{position:absolute;left:16px;right:16px;top:44px;height:232px;border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box}
 #grid{position:absolute;left:22px;right:26px;top:50px;height:220px;overflow-y:scroll;overflow-x:hidden;box-sizing:border-box;padding:2px 0 6px 0;font-size:0;line-height:0}
 #grid::-webkit-scrollbar{width:14px}
 #grid::-webkit-scrollbar-track{background:url('lc_track.png') no-repeat;background-size:100% 100%;margin:6px 0}
 #grid::-webkit-scrollbar-thumb{border-left:1px solid transparent;border-right:1px solid transparent;background-clip:padding-box;background-origin:padding-box;background:url('lc_thumb_top.png') left top no-repeat,url('lc_thumb_bot.png') left bottom no-repeat,url('lc_thumb_mid.png') left center no-repeat,url('lc_thumb_col.png') left top repeat-y;background-size:12px 6px,12px 6px,12px 11px,12px 1px;min-height:24px}
 .cell{position:relative;display:inline-block;vertical-align:top;width:90px;height:92px;margin:0 3px 4px 3px;cursor:pointer;border-radius:4px;font-size:16px;line-height:16px}
 .cell .pl{position:absolute;left:0;top:0;right:0;bottom:0;border:6px solid transparent;border-image:url('lc_rowplate.png') 6 fill stretch;display:none}
 .cell.live .pl{display:block}
 .cell:hover{box-shadow:inset 0 0 0 1px #3490c0}
 .cell.live:hover{box-shadow:none}
 .cell img.pt{position:absolute;left:24px;top:4px;width:42px;height:43px}
 .cell img.st{position:absolute;right:6px;top:6px;display:none}
 .cell.def img.st{display:block}
 .cell .nm{position:absolute;left:2px;right:2px;top:50px;text-align:center;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
 .cell .tr{position:absolute;left:2px;right:2px;top:70px;text-align:center;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;color:#7ec8f0}
 .cell.man .tr{color:#b8b8d9}
 .empty{padding:8px 6px;color:#b8b8d9;white-space:normal;font-size:16px;line-height:16px}
 #acts{position:absolute;left:16px;right:16px;bottom:38px;height:30px}
 .bg{position:absolute;left:0;top:0;right:0;bottom:0;pointer-events:none}
 .sub{border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box}
 .chip{position:absolute;top:6px;height:18px;line-height:16px;text-align:center;color:#cfe3f5;cursor:pointer}
 .chip .bg{border:6px solid transparent;border-image:url('lc_chip_a.png') 6 fill stretch;box-sizing:border-box}
 .chip.on{color:#06283b}
 .chip.on .bg{border-image-source:url('lc_chip_b.png')}
 .chip span{position:relative}
 #hint{position:absolute;right:8px;top:7px;color:#b8b8d9}
 #foot{position:absolute;left:16px;right:16px;bottom:14px;height:18px;white-space:nowrap;overflow:hidden}
 #foot .bg{border:6px solid transparent;border-image:url('lc_band.png') 6 fill stretch;box-sizing:border-box}
 #foot .t{position:absolute;left:8px;top:2px}
 #foot .k{color:#7ec8f0}
 #foot .d{color:#b8b8d9}
 #foot .dv{display:inline-block;width:1px;height:8px;background:#6096c8;margin:0 9px 0 8px;vertical-align:top;position:relative;top:4px}
 :root{--cur:url('lc_cur_neutral.png') 2 0, auto;--cur-text:url('lc_cur_ibeam.png') 2 5, text;--cur-drag:url('lc_cur_drag.png') 4 5, move}
 *{cursor:var(--cur) !important}
 #hdr.dragok{cursor:var(--cur-drag) !important}
 </style></head><body>
 <div id='shell'>
  <div id='frame'></div>
  <div id='hdr'>
   <div class='tabw on' id='t_all' style='left:16px'>ALL</div>
   <div class='tabw' id='t_auto' style='left:102px'>AUTO</div>
   <div class='tabw' id='t_manual' style='left:188px'>MANUAL</div>
   <div class='btn' id='close' title='close'><img src='lc_cross.png' alt=''></div>
  </div>
  <div id='body'></div>
  <div id='grid'></div>
  <div id='acts'><div class='bg sub'></div>
   <div class='chip' id='hold' style='left:6px;width:44px' title='keep your default expression even when a trigger applies'><div class='bg'></div><span>HOLD</span></div>
   <div class='chip' id='reset' style='left:56px;width:52px' title='clear your chosen expression and hold'><div class='bg'></div><span>RESET</span></div>
   <span id='hint'>picture: character menu</span>
  </div>
  <div id='foot'><div class='bg'></div><div class='t' id='foott'></div></div>
 </div>
 <script>
 var shell=document.getElementById('shell'), hdr=document.getElementById('hdr'), grid=document.getElementById('grid'), frame=document.getElementById('frame'), foott=document.getElementById('foott');
 var PREVIEW=false;
 var CTL='mapwindow.faceoverlay', PW=352, PH=350;
 function applyCursor(){ var two=(Z>=2); var r=document.documentElement.style; r.setProperty('--cur',two?"url('lc_cur_neutral2.png') 5 1, auto":"url('lc_cur_neutral.png') 2 0, auto"); r.setProperty('--cur-text',two?"url('lc_cur_ibeam2.png') 5 11, text":"url('lc_cur_ibeam.png') 2 5, text"); r.setProperty('--cur-drag',two?"url('lc_cur_drag2.png') 9 11, move":"url('lc_cur_drag.png') 4 5, move"); }
 var Z=2, OP=0.85, G={x:0,y:0,w:704,h:700}, B=null, live=false, tab='all';
 var states=\[], defIdx=0, liveIdx=0, hold=false;
 function clampNum(v,lo,hi){ if(hi<lo) hi=lo; if(v<lo) return lo; if(v>hi) return hi; return v; }
 function esc(x){ return String(x).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/'/g,'&#39;'); }
 function dec(v){ try{ return decodeURIComponent(String(v).split('+').join(' ')); }catch(e){ return String(v); } }
 function ws(p){ if(window.BYOND) BYOND.winset(CTL,p); }
 function topic(p){ p.facepage=p.facepage||''; if(window.BYOND) BYOND.topic(p); }
 function focusMap(){ if(window.BYOND) BYOND.winset('mapwindow.map',{focus:true}); }
 function clampG(){ if(!B) return; G.x=clampNum(G.x,B.x0,B.x1-G.w); G.y=clampNum(G.y,B.y0,B.y1-G.h); }
 function layout(){
  document.body.style.zoom=Z; applyCursor();
  shell.style.width=PW+'px'; shell.style.height=PH+'px';
  frame.style.opacity=OP;
  if(!live){ shell.style.left=Math.round(G.x/Z)+'px'; shell.style.top=Math.round(G.y/Z)+'px'; }
  hdr.classList.add('dragok');
 }
 function setGeom(x,y,w,h,z,op,bx0,by0,bx1,by1){ G={x:+x,y:+y,w:+w,h:+h}; Z=+z; OP=+op; if(bx1!==undefined){ B={x0:+bx0,y0:+by0,x1:+bx1,y1:+by1}; } clampG(); layout(); }
 var pending=false;
 function flush(){ pending=false; clampG(); ws({pos:G.x+','+G.y, size:G.w+'x'+G.h}); layout(); }
 function sched(){ if(!pending){ pending=true; requestAnimationFrame(flush); } }
 function report(){ topic({facepage:'geom', g:G.x+','+G.y}); }
 var drag=null;
 hdr.addEventListener('pointerdown',function(e){ if(e.button!==0) return; if(e.target.closest('.tabw')||e.target.closest('.btn')) return; drag={sx:e.screenX,sy:e.screenY,x:G.x,y:G.y}; try{ hdr.setPointerCapture(e.pointerId); }catch(err){} e.preventDefault(); });
 hdr.addEventListener('pointermove',function(e){ if(!drag) return; G.x=drag.x+(e.screenX-drag.sx); G.y=drag.y+(e.screenY-drag.sy); clampG(); sched(); });
 hdr.addEventListener('pointerup',function(e){ if(!drag) return; drag=null; flush(); report(); focusMap(); });
 var TABS=\['all','auto','manual'];
 function setTab(t){ tab=t; for(var i=0;i<TABS.length;i++){ document.getElementById('t_'+TABS\[i]).classList.toggle('on',TABS\[i]===t); } render(); }
 for(var ti=0;ti<TABS.length;ti++){ (function(t){ document.getElementById('t_'+t).addEventListener('click',function(){ setTab(t); focusMap(); }); })(TABS\[ti]); }
 function setStates(s){ states=\[]; var parts=(s||'').split(';'); for(var i=0;i<parts.length;i++){ var f=parts\[i].split('|'); if(f.length<2) continue; states.push({i:+f\[0],name:dec(f\[1]),trig:dec(f\[2]||''),img:f\[3]||''}); } render(); footer(); }
 function setState(d,l,h){ defIdx=+d; liveIdx=+l; hold=(+h)?true:false; document.getElementById('hold').classList.toggle('on',hold); render(); footer(); }
 function byIdx(i){ for(var k=0;k<states.length;k++){ if(states\[k].i===i) return states\[k]; } return null; }
 function okImg(v){ return v.indexOf('pt_')===0&&v.slice(-4)==='.png'&&v.indexOf('/')<0&&v.indexOf(':')<0&&v.length<80; }
 function render(){
  var h='', n=0;
  for(var k=0;k<states.length;k++){
   var s=states\[k]; var auto=s.trig.length>0;
   if(tab==='auto'&&!auto) continue;
   if(tab==='manual'&&auto) continue;
   n++;
   h+="<div class='cell"+(s.i===liveIdx?' live':'')+(s.i===defIdx?' def':'')+(auto?'':' man')+"' data-i='"+s.i+"' title='"+esc(s.name)+(auto?' - '+esc(s.trig):' - no trigger')+"'><div class='pl'></div>"+(okImg(s.img)?"<img class='pt' src='"+esc(s.img)+"' alt=''>":'')+"<img class='st' src='lc_star.png' alt=''><span class='nm'>"+esc(s.name)+"</span><span class='tr'>"+(auto?esc(s.trig):'no trigger')+"</span></div>";
  }
  if(!n){ h="<div class='empty'>"+(states.length<=1?'Upload a .dmi portrait with icon states from the Character Menu to get expressions. States named anger1, form1, form1anger1, ko or hurt switch on their own. Any other name is manual.':'nothing in this tab')+"</div>"; }
  grid.innerHTML=h;
  var imgs=grid.querySelectorAll('img.pt'); for(var q=0;q<imgs.length;q++) imgs\[q].addEventListener('error',retryImg);
 }
 function retryImg(e){ var im=e.target; var n=+(im.getAttribute('data-n')||0); if(n>=10) return; setTimeout(function(){ if(!im.parentNode) return; var c=im.cloneNode(false); c.setAttribute('data-n',n+1); c.addEventListener('error',retryImg); im.parentNode.replaceChild(c,im); },300*(n+1)); }
 function footer(){
  var d=byIdx(defIdx), l=byIdx(liveIdx);
  foott.innerHTML="<span class='k'>DEFAULT </span>"+esc(d?d.name:'blank')+"<span class='dv'></span><span class='k'>LIVE </span>"+esc(l?l.name:'blank')+"<span class='dv'></span><span class='d'>"+states.length+" expression"+(states.length===1?'':'s')+"</span>";
 }
 grid.addEventListener('click',function(e){ var c=e.target.closest('.cell'); if(!c) return; var i=+c.getAttribute('data-i'); defIdx=i; render(); footer(); topic({facepage:'pick',i:i}); });
 document.getElementById('hold').addEventListener('click',function(){ hold=!hold; document.getElementById('hold').classList.toggle('on',hold); topic({facepage:'hold',on:hold?1:0}); });
 document.getElementById('reset').addEventListener('click',function(){ topic({facepage:'reset'}); });
 document.getElementById('close').addEventListener('click',function(){ topic({facepage:'close'}); focusMap(); });
 document.addEventListener('contextmenu',function(e){ e.preventDefault(); });
 function boot(){ live=true; layout(); topic({facepage:'ready'}); }
 if(window.BYOND){ boot(); } else { window.addEventListener('byond-ready',boot); }
 if(PREVIEW){
  setStates('1|blank|;2|happy|;3|smirk|;4|anger1|75%25%20HP;5|anger2|50%25%20HP;6|form1|Super%20Saiyan;7|form1anger1|Super%20Saiyan%20at%2075%25%20HP;8|form2|Super%20Saiyan%202;9|ko|knocked%20out;10|hurt|below%2025%25%20HP');
  setState(2,4,0);
  setTimeout(function(){ if(!live){ setGeom(556,12,704,700,2,0.85,0,0,4000,3000); } },300);
 }
 </script></body></html>
"}

client/proc/FacePageBoot()
	if(facepage_booted) return
	facepage_booted = 1
	if(prefs)
		var/g = getPref("faceGeom")
		if(istext(g) && length(g)) facepage_geom = g

client/proc/FacePagePlace()
	var/list/r = PanelViewRect()
	if(!r) return
	var/x0 = r[1]
	var/y0 = r[2]
	var/x1 = r[3]
	var/y1 = r[4]
	var/z = r[5]
	facepage_zoom = z
	facepage_x0 = x0
	facepage_y0 = y0
	var/w = 352 * z
	var/h = 350 * z
	var/x
	var/y
	if(facepage_geom)
		var/list/g = splittext(facepage_geom, ",")
		if(g.len >= 2)
			var/gx = text2num(g[1]); var/gy = text2num(g[2])
			if(!isnull(gx) && !isnull(gy))
				x = x0 + round(gx * z); y = y0 + round(gy * z)
	if(isnull(x) || isnull(y))
		x = x0 + 278 * z
		y = y0 + 6 * z
	if(x + w > x1) x = x1 - w
	if(y + h > y1) y = y1 - h
	if(x < x0) x = x0
	if(y < y0) y = y0
	facepage_geom = "[(x - x0) / z],[(y - y0) / z]"
	winset(src, FACEPAGE_CTL, "pos=[x],[y];size=[w]x[h]")
	src << output(list2params(list(x, y, w, h, z, chatpanel_opacity, x0, y0, x1, y1)), "[FACEPAGE_CTL]:setGeom")

client/proc/FacePageStoreGeom(gtext)
	var/list/g = splittext(gtext, ",")
	if(g.len < 2) return
	var/x = text2num(g[1]); var/y = text2num(g[2])
	if(isnull(x) || isnull(y)) return
	var/z = facepage_zoom ? facepage_zoom : 1
	facepage_geom = "[(x - facepage_x0) / z],[(y - facepage_y0) / z]"
	setPref("faceGeom", facepage_geom)

client/proc/FacePageShow()
	if(!mob) return
	FacePageBoot()
	FacePageSendAssets()
	for(var/s in mob.PortraitStates()) EnsurePortrait(mob, s)
	winset(src, FACEPAGE_CTL, "inner-background-color=transparent")
	src << browse(FacePageHTML(), "window=[FACEPAGE_CTL]")
	facepage_open = 1
	FacePagePlace()
	winset(src, FACEPAGE_CTL, "is-visible=true")

client/proc/FacePageHide()
	facepage_open = 0
	winset(src, FACEPAGE_CTL, "is-visible=false")

client/proc/FacePageToggle()
	if(facepage_open) FacePageHide()
	else FacePageShow()

client/proc/FacePagePush()
	if(!facepage_open || !mob) return
	var/list/st = mob.PortraitStates()
	var/list/out = list()
	for(var/i = 1, i <= st.len, i++)
		var/s = st[i]
		EnsurePortrait(mob, s)
		out += "[i]|[url_encode(length(s) ? s : "blank")]|[url_encode(mob.PortraitTrigger(s))]|pt_[mob.ckey]_[mob.chat_portrait_ver]_[i].png"
	src << output(list2params(list(jointext(out, ";"))), "[FACEPAGE_CTL]:setStates")
	FacePageState()

client/proc/FacePageState()
	if(!facepage_open || !mob) return
	var/list/st = mob.PortraitStates()
	var/d = mob.PortraitCanon(mob.PortraitDefault)
	if(!istext(d)) d = ""
	src << output(list2params(list(st.Find(d), st.Find(mob.PortraitState()), mob.PortraitHold ? 1 : 0)), "[FACEPAGE_CTL]:setState")

client/proc/FacePageTopic(list/href_list)
	switch(href_list["facepage"])
		if("ready")
			FacePagePlace()
			FacePagePush()
		if("geom")
			FacePageStoreGeom(href_list["g"])
		if("pick")
			if(mob) mob.PortraitPickIndex(text2num(href_list["i"]))
			FacePageState()
		if("hold")
			if(mob)
				mob.PortraitHold = text2num(href_list["on"]) ? 1 : 0
				mob.PortraitDefaultChanged()
			FacePageState()
		if("reset")
			if(mob)
				mob.PortraitDefault = ""
				mob.PortraitHold = 0
				mob.PortraitDefaultChanged()
			FacePageState()
		if("close")
			FacePageHide()

mob/Players/verb/FacePage_Open()
	set name = "Expressions"
	set category = "Roleplay"
	set hidden = 1
	client?.FacePageToggle()
