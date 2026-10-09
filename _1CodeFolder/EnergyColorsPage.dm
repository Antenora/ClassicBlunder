#define ECPAGE_CTL "mapwindow.ecoverlay"

#if fexists("../Icons/Private/EnergyFX/UI/Undo.png") || fexists("Icons/Private/EnergyFX/UI/Undo.png")
#define ENERGYFX_UI_UNDO 'Icons/Private/EnergyFX/UI/Undo.png'
#else
#define ENERGYFX_UI_UNDO 'HUD/chatpanel/lc_cross.png'
#endif

client/var/ec_made = 0
client/var/ec_loaded = 0
client/var/ec_ready = 0
client/var/ec_open = 0
client/var/ec_assets = 0
client/var/ec_seq = 0
client/var/list/ec_rows
client/var/ec_pan_x = 0
client/var/ec_pan_y = 0

/proc/EnergyColorsRowOf(obj/Skills/S)
	if(!S) return null
	if(istype(S, /obj/Skills/Queue/Burst_Combination)) return EnergyFXRowOf(/obj/Skills/Projectile/BurstBlast)
	var/datum/energyfx_row/R = EnergyFXRow(S)
	if(!R || EnergyFXRowCanon(R)) return null
	if(R.look != "blast" && R.look != "orb" && R.look != "beam") return null
	if(R.path == /obj/Skills/Projectile/BurstBlast) return null
	if(R.extra && R.extra["bit"]) return null
	return R

/proc/EnergyColorsSkills(mob/M)
	var/list/out = list()
	if(!M) return out
	for(var/obj/Skills/S in M)
		if(!EnergyColorsRowOf(S)) continue
		var/placed = 0
		for(var/i = 1 to out.len)
			var/obj/Skills/O = out[i]
			if(sorttext("[S.name]", "[O.name]") == 1)
				out.Insert(i, S)
				placed = 1
				break
		if(!placed) out += S
	return out

/proc/EnergyColorsClean(v)
	if(!istext(v) || !length(v)) return null
	var/sub = copytext(v, 1, 2) == "-"
	var/c = PromptCleanColor(sub ? copytext(v, 2) : v)
	if(!c) return null
	return sub ? "-[c]" : c

/proc/EnergyColorsApply(obj/Skills/S, k, v)
	v = EnergyColorsClean(v)
	if(!S || !v) return 0
	switch(k)
		if(1)
			S.EnergyColorMain = v
		if(2)
			S.EnergyColorCore = v
		if(3)
			S.EnergyColorGlow = v
		else
			return 0
	return 1

/proc/EnergyColorsReset(obj/Skills/S)
	if(!S) return
	S.EnergyColorMain = null
	S.EnergyColorCore = null
	S.EnergyColorGlow = null

client/proc/EnergyColorsEnsureControl()
	if(ec_made) return 1
	winset(src, "ecoverlay", "parent=mapwindow;type=browser;pos=0,0;size=765x460;anchor1=-1,-1;anchor2=-1,-1;is-visible=false")
	if(!length(winget(src, ECPAGE_CTL, "type"))) return 0
	ec_made = 1
	PromptRestackSoon()
	return 1

client/proc/EnergyColorsSendAssets()
	if(ec_assets) return
	ec_assets = 1
	ChatPanelSendAssets()
	src << browse_rsc('HUD/chatpanel/lc_tabw_on.png', "lc_tabw_on.png")
	src << browse_rsc('HUD/chatpanel/lc_btn.png', "lc_btn.png")
	src << browse_rsc('HUD/chatpanel/lc_btn_down.png', "lc_btn_down.png")
	src << browse_rsc('HUD/chatpanel/lc_chip_a.png', "lc_chip_a.png")
	src << browse_rsc('HUD/chatpanel/lc_chip_b.png', "lc_chip_b.png")
	src << browse_rsc('HUD/chatpanel/lc_band.png', "lc_band.png")
	src << browse_rsc(ENERGYFX_UI_UNDO, "ec_undo.png")

client/proc/EnergyColorsPageHTML()
	return {"<!DOCTYPE html><html><head><meta charset='utf-8'><style>
 @font-face{font-family:'monogram';src:url('monogram.ttf')}
 html,body{margin:0;padding:0;background:transparent;overflow:hidden;width:100%;height:100%}
 body{font:16px/16px 'monogram';color:#eaf5ff;user-select:none;-webkit-user-select:none;background-repeat:no-repeat;background-position:0 0}
 #shell{position:absolute;left:0;top:0;image-rendering:pixelated;outline:0}
 #frame{position:absolute;left:0;top:0;right:0;bottom:0;border:16px solid transparent;border-image:url('lc_cover.png') 16 fill stretch;pointer-events:none}
 #hdr{position:relative;height:44px}
 #tab{position:absolute;top:8px;left:16px;width:84px;height:32px;background:url('lc_tabw_on.png') no-repeat;line-height:32px;text-align:center;color:#06283b}
 #ttl{position:absolute;left:108px;top:16px;height:16px;color:#bfe6ff;white-space:nowrap}
 #close{position:absolute;top:8px;right:16px;width:32px;height:32px;background:url('lc_slot.png') no-repeat;cursor:pointer}
 #close img{position:absolute;left:0;top:0;width:32px;height:32px}
 #body{position:relative;margin:0 16px;border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box;padding:8px}
 #cols{position:relative;display:flex;column-gap:12px}
 .fld{border:8px solid transparent;border-image:url('lc_field.png') 8 fill stretch;box-sizing:border-box}
 .csub{color:#7ec8f0;height:16px;white-space:nowrap}
 #lcol{position:relative;flex:0 0 auto}
 #lhead{position:relative;height:16px;margin:2px 0 6px 0}
 #lhead span{position:absolute;top:0;color:#7ec8f0;white-space:nowrap}
 #listf{position:relative}
 #list{position:absolute;left:0;top:0;right:0;bottom:0;overflow-y:scroll;overflow-x:hidden}
 #list::-webkit-scrollbar{width:14px}
 #list::-webkit-scrollbar-track{background:url('lc_track.png') no-repeat;background-size:100% 100%;margin:0}
 #list::-webkit-scrollbar-thumb{border-left:1px solid transparent;border-right:1px solid transparent;background-clip:padding-box;background-origin:padding-box;background:url('lc_thumb_top.png') left top no-repeat,url('lc_thumb_bot.png') left bottom no-repeat,url('lc_thumb_mid.png') left center no-repeat,url('lc_thumb_col.png') left top repeat-y;background-size:12px 6px,12px 6px,12px 11px,12px 1px;min-height:24px}
 #lsp{position:relative}
 .it{position:absolute;left:0;right:0;cursor:pointer}
 .it .pl{position:absolute;left:0;top:0;right:0;bottom:0;display:none;border:6px solid transparent;border-image:url('lc_rowplate.png') 6 fill stretch;box-sizing:border-box}
 .it:hover .pl{display:block;opacity:0.45}
 .it.sel .pl{display:block;opacity:1}
 .it .nm{position:absolute;white-space:nowrap;overflow:hidden;height:16px}
 .it .nm.ell{text-overflow:ellipsis}
 .it.sel .nm{color:#8be9ff}
 .sw{position:absolute;width:16px;height:16px;box-sizing:border-box;border:1px solid #06283b;cursor:pointer}
 .sw.on{box-shadow:0 0 0 1px #7ef2ff}
 .sw .mn,.chq .mn{position:absolute;left:50%;top:50%;width:6px;height:2px;margin:-1px 0 0 -3px;background:#eaf5ff;box-shadow:0 0 0 1px #06283b}
 .rp{position:absolute;height:16px;box-sizing:border-box;border:1px solid #06283b;display:flex}
 .rp i{flex:1 1 0;height:100%}
 .rs{position:absolute;width:13px;height:13px;cursor:pointer}
 #rcol{position:relative;flex:0 0 auto}
 #etop{position:relative;height:24px}
 #ename{position:absolute;left:2px;top:4px;color:#bfe6ff;white-space:nowrap}
 #ename.ell{overflow:hidden;text-overflow:ellipsis}
 #elook{position:absolute;top:4px;color:#6096c8;white-space:nowrap}
 .use{position:absolute;height:24px;line-height:24px;text-align:center;cursor:pointer;white-space:nowrap;box-sizing:border-box}
 .use .bg{position:absolute;left:0;top:0;right:0;bottom:0;border:8px solid transparent;border-image:url('lc_btn.png') 8 fill stretch;box-sizing:border-box;pointer-events:none}
 .use img{position:absolute;top:6px;width:13px;height:13px}
 .use span{position:absolute;top:0}
 .use:hover .bg{filter:brightness(1.2)}
 .use:active .bg{border-image-source:url('lc_btn_down.png');filter:none}
 .use:active span,.use:active img{margin-top:1px}
 #slots{position:relative;height:18px;margin-top:8px}
 .chip{position:absolute;top:0;height:18px;line-height:16px;color:#cfe3f5;cursor:pointer;white-space:nowrap}
 .chip .bg{position:absolute;left:0;top:0;right:0;bottom:0;border:6px solid transparent;border-image:url('lc_chip_a.png') 6 fill stretch;box-sizing:border-box;pointer-events:none}
 .chip.on{color:#06283b}
 .chip.on .bg{border-image-source:url('lc_chip_b.png')}
 .chip span{position:absolute;top:-1px}
 .chq{position:absolute;top:2px;width:10px;height:10px;box-sizing:border-box;border:1px solid #06283b}
 .chq .mn{width:4px;margin-left:-2px}
 #ctop{display:flex;column-gap:12px;margin-top:8px}
 #cleft{flex:0 0 240px}
 #cright{flex:1 1 auto;min-width:0}
 .csub.top{margin:0 2px 6px 2px}
 #cgrid{display:grid;grid-template-columns:repeat(8,24px);grid-auto-rows:18px;gap:4px;padding:1px 2px}
 .csw{width:24px;height:18px;box-sizing:border-box;border:1px solid #06283b;cursor:pointer}
 .csw.on{box-shadow:0 0 0 2px #7ef2ff}
 #cspec{position:relative;height:146px}
 #csq{position:absolute;left:0;top:0;right:26px;height:146px;box-sizing:border-box;border:1px solid #06283b;background:linear-gradient(to bottom,rgba(255,255,255,0),#fff),linear-gradient(to right,#f00,#ff0,#0f0,#0ff,#00f,#f0f,#f00)}
 #csqd{position:absolute;left:0;top:0;right:0;bottom:0;background:#000;opacity:0;pointer-events:none}
 #csqm{position:absolute;width:9px;height:9px;margin:-5px 0 0 -5px;box-sizing:border-box;border:1px solid #fff;box-shadow:0 0 0 1px #000;border-radius:50%;pointer-events:none}
 #cbar{position:absolute;right:0;top:0;width:18px;height:146px;box-sizing:border-box;border:1px solid #06283b;background:linear-gradient(to bottom,#fff,#000)}
 #cbarm{position:absolute;left:-4px;right:-4px;height:3px;margin-top:-2px;background:#fff;box-shadow:0 0 0 1px #000;pointer-events:none}
 #vhead{position:relative;height:16px;margin-top:8px}
 #vhead span{position:absolute;top:0;color:#7ec8f0;white-space:nowrap}
 #vrow{position:relative;height:30px;margin-top:6px}
 #vrow .fld{position:absolute;top:0;height:30px}
 .lb{position:absolute;left:2px;top:-1px;color:#7ec8f0}
 .tin{position:absolute;left:14px;top:-1px;right:0;height:16px;margin:0;padding:0;background:transparent;border:0;outline:0;font:16px/16px 'monogram';color:#eaf5ff;caret-color:#eaf5ff}
 .tin.hx{left:2px}
 .tin::placeholder{color:#6096c8}
 #res{position:absolute;left:-2px;top:-2px;right:-2px;bottom:-2px}
 #rhead{position:relative;height:16px;margin-top:8px}
 #rhead span{position:absolute;top:0;color:#7ec8f0;white-space:nowrap}
 #rampf{position:relative;height:34px;margin-top:6px}
 #ramp{position:absolute;left:0;top:0;right:0;bottom:0;box-sizing:border-box;border:1px solid #06283b;display:flex}
 #ramp i{flex:1 1 0;height:100%}
 .empty{color:#b8b8d9;text-align:center;white-space:nowrap;padding:8px 0}
 #foot{position:relative;margin:6px 16px 14px 16px;height:18px;white-space:nowrap;overflow:hidden}
 #foot .bg{position:absolute;left:0;top:0;right:0;bottom:0;border:6px solid transparent;border-image:url('lc_band.png') 6 fill stretch;box-sizing:border-box;pointer-events:none}
 #foot .t{position:absolute;left:8px;right:8px;top:2px;overflow:hidden;white-space:nowrap}
 #foot .k{color:#7ec8f0}
 #foot .dv{display:inline-block;width:1px;height:9px;background:#6096c8;margin:0 9px 0 8px;vertical-align:top;position:relative;top:4px}
 :root{--cur:url('lc_cur_neutral.png') 2 0, auto;--cur-text:url('lc_cur_ibeam.png') 2 5, text;--cur-drag:url('lc_cur_drag.png') 4 5, move}
 *{cursor:var(--cur) !important}
 input{cursor:var(--cur-text) !important}
 #csq,#cbar{cursor:crosshair !important}
 #hdr{cursor:var(--cur-drag) !important}
</style></head><body>
<div id='shell' tabindex='-1'>
 <div id='frame'></div>
 <div id='hdr'><div id='tab' class='L T'>COLORS</div><div id='ttl' class='L T'>Energy Colors</div><div id='close' class='L' title='close'><img src='lc_cross.png' alt=''></div></div>
 <div id='body' class='C'></div>
 <div id='foot' class='L'><div class='bg'></div><div class='t T' id='ft'></div></div>
</div>
<script>
var G0={RH:24,ROWS:12,NM_X:8,NM_W:104,SW_X:120,SW_P:18,RP_X:180,RP_W:52,RS_X:240,LCOL_W:289,RCOL_W:404,GAP:12,EMPTY_W:288};
var G={};
var NB=\[56,56,56],NM=\[158,158,158],NC=\[255,255,255],STOPS=\[0,0.25,0.5,0.75,1];
var PRESETS=\['#ff8080','#ffff80','#80ff80','#00ff80','#80ffff','#0080ff','#ff80c0','#ff80ff','#ff0000','#ffff00','#80ff00','#00ff40','#00ffff','#0080c0','#8080c0','#ff00ff','#804040','#ff8040','#00ff00','#008080','#004080','#8080ff','#800040','#ff0080','#800000','#ff8000','#008000','#008040','#0000ff','#0000a0','#800080','#8000ff','#400000','#804000','#004000','#004040','#000080','#000040','#400040','#400080','#000000','#808000','#808040','#808080','#408080','#c0c0c0','#ffffc0','#ffffff'];
var SLOTS=\['MAIN','CORE','GLOW'];
var CTL='mapwindow.ecoverlay';
var shell=document.getElementById('shell'),hdr=document.getElementById('hdr'),body=document.getElementById('body'),ft=document.getElementById('ft'),frame=document.getElementById('frame');
var Z=1,OP=0.85,B=null,P={x:0,y:0},C0={x:0,y:0},GM={x:0,y:0,w:765,h:460},SEQ=0,live=false,booted=false;
var ROWS=\[],SI=0,SL=0,HUE=0,SAT=0,VAL=1,ELL=false,ELLE=false,dirty=null,tmr=null,pick2=null,meas=null;
function el(t,c){var d=document.createElement(t);if(c)d.className=c;return d;}
function clear(n){while(n.firstChild)n.removeChild(n.firstChild);}
function hx(h){if(!h)return null;var s=h.replace('-','').replace('#','');return \[parseInt(s.substr(0,2),16),parseInt(s.substr(2,2),16),parseInt(s.substr(4,2),16)];}
function isSub(h){return !!h&&h.charAt(0)==='-';}
function hx2(n){var q=Math.max(0,Math.min(255,Math.round(n))).toString(16);return q.length<2?'0'+q:q;}
function css(c){return '#'+hx2(c\[0])+hx2(c\[1])+hx2(c\[2]);}
function lum(c){return 0.2126*c\[0]/255+0.7152*c\[1]/255+0.0722*c\[2]/255;}
function grayRule(c){var r=c\[0]/255,g=c\[1]/255,b=c\[2]/255,mx=Math.max(r,g,b),sat=mx>0?(mx-Math.min(r,g,b))/mx:0;return lum(c)<0.03||sat<0.1;}
function sstep(a,b,x){var t=Math.min(1,Math.max(0,(x-a)/(b-a)));return t*t*(3-2*t);}
function rhe(v){var f=Math.floor(v),d=v-f;if(d>0.5)return f+1;if(d<0.5)return f;return (f%2===0)?f:f+1;}
function deriveBase(m){var p=\[Math.pow(m\[0]/255,2.4),Math.pow(m\[1]/255,2.4),Math.pow(m\[2]/255,2.4)],mx=Math.max(p\[0],p\[1],p\[2],1e-6);return \[0.8*p\[0]/mx*255,0.8*p\[1]/mx*255,0.8*p\[2]/mx*255];}
function deriveCore(m){return \[255*(1-0.25*(1-m\[0]/255)),255*(1-0.25*(1-m\[1]/255)),255*(1-0.25*(1-m\[2]/255))];}
function subFrom(ref,p){return \[Math.max(0,ref\[0]-p\[0]),Math.max(0,ref\[1]-p\[1]),Math.max(0,ref\[2]-p\[2])];}
function godotRule(mh,ch,gh){
 var m=hx(mh),c=hx(ch),g=hx(gh),base=null,mid,gray=false,bright=1;
 if(m&&isSub(mh)){base=subFrom(NB,m);mid=subFrom(NM,m);}
 else if(m&&!grayRule(m)){mid=m;}
 else{if(m&&lum(m)>=0.03)bright=Math.max(m\[0],m\[1],m\[2])/255;base=\[NB\[0]*bright,NB\[1]*bright,NB\[2]*bright];mid=\[NM\[0]*bright,NM\[1]*bright,NM\[2]*bright];gray=true;}
 var ge=null;if(g)ge=isSub(gh)?subFrom(NM,g):g;
 if(ge&&lum(mid)<lum(ge)){base=mid;mid=ge;}
 else if(!base){base=deriveBase(mid);}
 var cr;
 if(c)cr=isSub(ch)?subFrom(NC,c):c;
 else if(gray&&!ge)cr=\[NC\[0]*bright,NC\[1]*bright,NC\[2]*bright];
 else cr=deriveCore(mid);
 var r=function(a){return \[rhe(a\[0]),rhe(a\[1]),rhe(a\[2])];};
 return \[r(base),r(mid),r(cr)];
}
function rampStops(p){var out=\[];for(var k=0;k<STOPS.length;k++){var I=STOPS\[k],s1=sstep(0,0.5,I),s2=sstep(0.45,1,I),st=\[];for(var ch=0;ch<3;ch++){var cb=p\[0]\[ch]/255,cm=p\[1]\[ch]/255,cc=p\[2]\[ch]/255,cv=cb+(cm-cb)*s1;st.push(rhe(Math.min(1,Math.max(0,cv+(cc-cv)*s2))*255));}out.push(st);}return out;}
function rgbHsv(r,g,b){var mx=Math.max(r,g,b),mn=Math.min(r,g,b);if(mn===mx)return \[0,0,mx];var s=(mx-mn)/mx,rc=(mx-r)/(mx-mn),gc=(mx-g)/(mx-mn),bc=(mx-b)/(mx-mn),h;if(r===mx)h=bc-gc;else if(g===mx)h=2+rc-bc;else h=4+gc-rc;h=h/6;h=h-Math.floor(h);return \[h,s,mx];}
function hsvRgb(h,s,v){if(s===0)return \[v,v,v];var i=Math.floor(h*6),f=h*6-i,p=v*(1-s),q=v*(1-s*f),t=v*(1-s*(1-f));i=((i%6)+6)%6;if(i===0)return \[v,t,p];if(i===1)return \[q,v,p];if(i===2)return \[p,v,t];if(i===3)return \[p,q,v];if(i===4)return \[t,p,v];return \[v,p,q];}
function warmEdge(c){var o=rgbHsv(c\[0],c\[1],c\[2]),hd=o\[0]*360,s=o\[1],v=o\[2];if(hd>=20&&hd<=100){hd=hd-0.55*(hd-36);s=Math.min(1,s*1.05);v=v*0.86;}else if(hd>=250&&hd<=300){hd=hd-0.4*(hd-268);}return hsvRgb(hd/360,s,v);}
function beamStops(mh,ch){
 var m=hx(mh),c=hx(ch),bright=1,src;
 if(m&&!grayRule(m))src=\[m\[0]/255,m\[1]/255,m\[2]/255];
 else{if(m&&lum(m)>=0.03)bright=Math.max(m\[0],m\[1],m\[2])/255;src=\[153/255,153/255,153/255];}
 var b=warmEdge(src),kb=Math.min(1,Math.max(0,(0.2126*b\[0]+0.7152*b\[1]+0.0722*b\[2]-0.3)/0.3));kb=kb*kb*(3-2*kb);
 var edge=\[],cr=\[];for(var i=0;i<3;i++){var e=Math.min(1,Math.max(0,b\[i]*(1-0.18*kb)));edge.push(e+(1-e)*0.12*(1-kb));cr.push(src\[i]+(1-src\[i])*0.9);}
 if(c)cr=\[c\[0]/255,c\[1]/255,c\[2]/255];
 var out=\[];for(var k=0;k<STOPS.length;k++){var t=STOPS\[k],st=\[];for(var j=0;j<3;j++)st.push(rhe(Math.min(1,Math.max(0,(edge\[j]+(cr\[j]-edge\[j])*t)*bright))*255));out.push(st);}return out;
}
function rowColors(row){
 var p=row.picks,anySub=isSub(p\[0])||isSub(p\[1])||isSub(p\[2]),res={};
 if(row.look==='beam'&&!anySub){res.rule='beam';res.stops=beamStops(p\[0],p\[1]);}
 else{res.rule='godot';res.pal=godotRule(p\[0],p\[1],p\[2]);res.stops=rampStops(res.pal);}
 var m=hx(p\[0]),c=hx(p\[1]),g=hx(p\[2]);
 var me=m?(isSub(p\[0])?subFrom(NM,m):m):NM.slice();
 var ce=c?(isSub(p\[1])?subFrom(NC,c):c):res.stops\[4];
 var gee=g?(isSub(p\[2])?subFrom(NM,g):g):me;
 res.eff=\[me,ce,gee];
 return res;
}
function okHex(v){if(typeof v!=='string')return null;var s=v.toLowerCase(),sub=false;if(s.charAt(0)==='-'){sub=true;s=s.substring(1);}if(s.length!==7||s.charAt(0)!=='#')return null;for(var i=1;i<7;i++){var c=s.charCodeAt(i);if(!((c>=48&&c<=57)||(c>=97&&c<=102)))return null;}return (sub?'-':'')+s;}
function digits(v){var o='';for(var i=0;i<v.length;i++){var c=v.charCodeAt(i);if(c>=48&&c<=57)o+=v.charAt(i);}return o;}
function hexf(v){if(!v.length)return '';var o='';v=v.toLowerCase();for(var i=0;i<v.length&&o.length<6;i++){var c=v.charCodeAt(i);if((c>=48&&c<=57)||(c>=97&&c<=102))o+=v.charAt(i);}return '#'+o;}
function hexfull(h){var s=(h.charAt(0)==='#')?h.substring(1):h;if(s.length===3)s=s.charAt(0)+s.charAt(0)+s.charAt(1)+s.charAt(1)+s.charAt(2)+s.charAt(2);return (s.length===6)?('#'+s):'';}
function dec(v){try{return decodeURIComponent(String(v).split('+').join(' '));}catch(e){return String(v);}}
function ws(p){if(window.BYOND)BYOND.winset(CTL,p);}
function topic(p){p.ecpage=p.ecpage||'';if(window.BYOND)BYOND.topic(p);}
function focusMap(){if(window.BYOND)BYOND.winset('mapwindow.map',{focus:true});}
function clampNum(v,lo,hi){if(hi<lo)hi=lo;if(v<lo)return lo;if(v>hi)return hi;return v;}
function applyCursor(){var two=(Z>=2);var r=document.documentElement.style;r.setProperty('--cur',two?"url('lc_cur_neutral2.png') 5 1, auto":"url('lc_cur_neutral.png') 2 0, auto");r.setProperty('--cur-text',two?"url('lc_cur_ibeam2.png') 5 11, text":"url('lc_cur_ibeam.png') 2 5, text");r.setProperty('--cur-drag',two?"url('lc_cur_drag2.png') 9 11, move":"url('lc_cur_drag.png') 4 5, move");}
function copyG(){G={};for(var k in G0)G\[k]=G0\[k];}
copyG();
function swatchEl(cls,c,sub){var d=el('div',cls);d.style.background=css(c);if(sub)d.appendChild(el('div','mn'));return d;}
function renderList(lcol){
 var lh=el('div');lh.id='lhead';lh.className='L';
 var hs=\[\['Skill',8+G.NM_X,null],\['Colors',8+G.SW_X,2*G.SW_P+16],\['Ramp',8+G.RP_X,G.RP_W]];
 hs.forEach(function(h){var s=el('span','T L');s.textContent=h\[0];lh.appendChild(s);s.dataset.x=h\[1];s.dataset.w=h\[2]===null?'':h\[2];});
 lcol.appendChild(lh);
 var lf=el('div','fld C L');lf.id='listf';lf.style.width=G.LCOL_W+'px';lf.style.height=(G.ROWS*G.RH+16)+'px';
 var ls=el('div','C');ls.id='list';var sp=el('div');sp.id='lsp';sp.style.height=(ROWS.length*G.RH)+'px';
 ROWS.forEach(function(r,i){
  var it=el('div','it R'+(i===SI?' sel':''));it.style.top=(i*G.RH)+'px';it.style.height=G.RH+'px';it.setAttribute('data-i',String(i));it.appendChild(el('div','pl'));
  var nm=el('div','nm T'+(ELL?' ell':''));nm.textContent=r.name;nm.style.left=G.NM_X+'px';nm.style.top='4px';nm.style.width=G.NM_W+'px';if(ELL)nm.title=r.name;it.appendChild(nm);
  for(var k=0;k<3;k++){var sw=swatchEl('sw P',r.col.eff\[k],isSub(r.picks\[k]));sw.style.left=(G.SW_X+k*G.SW_P)+'px';sw.style.top='4px';sw.setAttribute('data-k',String(k));if(i===SI&&k===SL)sw.classList.add('on');it.appendChild(sw);}
  var rp=el('div','rp P');rp.style.left=G.RP_X+'px';rp.style.top='4px';rp.style.width=G.RP_W+'px';r.col.stops.forEach(function(s){var c=el('i');c.style.background=css(s);rp.appendChild(c);});it.appendChild(rp);
  var rs=el('img','rs P');rs.src='ec_undo.png';rs.style.left=G.RS_X+'px';rs.style.top='5px';rs.title='reset';it.appendChild(rs);
  sp.appendChild(it);
 });
 ls.appendChild(sp);lf.appendChild(ls);lcol.appendChild(lf);
}
function renderEditor(rcol,row){
 var st=SL,pk=row.picks\[st],sub=isSub(pk),eff=row.col.eff\[st];
 var et=el('div','C');et.id='etop';
 var en=el('div','L T'+(ELLE?' ell':''));en.id='ename';en.textContent=row.name;if(ELLE)en.title=row.name;et.appendChild(en);
 var lk=el('div','L T');lk.id='elook';lk.textContent=row.look;et.appendChild(lk);
 var rb=el('div','use L');rb.id='reset';rb.style.right='0px';rb.style.width='92px';rb.appendChild(el('div','bg'));var ri=el('img');ri.src='ec_undo.png';ri.style.left='14px';rb.appendChild(ri);var rt=el('span','T');rt.textContent='RESET';rt.style.left='34px';rb.appendChild(rt);et.appendChild(rb);
 rcol.appendChild(et);
 var sl=el('div','C');sl.id='slots';
 var x=0;for(var k=0;k<3;k++){var cp=el('div','chip L'+(k===st?' on':''));cp.style.left=x+'px';cp.style.width='60px';cp.setAttribute('data-k',String(k));cp.appendChild(el('div','bg'));var q=swatchEl('chq',row.col.eff\[k],isSub(row.picks\[k]));q.style.left='7px';cp.appendChild(q);var t=el('span','T');t.textContent=SLOTS\[k];t.style.left='22px';cp.appendChild(t);sl.appendChild(cp);x+=64;}
 var sb=el('div','chip L'+(sub?' on':''));sb.style.right='0px';sb.style.width='72px';sb.setAttribute('data-k','sub');sb.appendChild(el('div','bg'));var sbt=el('span','T');sbt.textContent='SUBTRACT';sbt.style.left='12px';sb.appendChild(sbt);sl.appendChild(sb);
 var ad=el('div','chip L'+(sub?'':' on'));ad.style.right='76px';ad.style.width='44px';ad.setAttribute('data-k','add');ad.appendChild(el('div','bg'));var adt=el('span','T');adt.textContent='ADD';adt.style.left='13px';ad.appendChild(adt);sl.appendChild(ad);
 rcol.appendChild(sl);
 var pickC=pk?hx(pk):eff;
 var ct=el('div');ct.id='ctop';
 var cl=el('div');cl.id='cleft';var cs1=el('div','csub top T');cs1.textContent='Presets';cl.appendChild(cs1);
 var gf=el('div','fld C L');gf.style.padding='0';var gr=el('div');gr.id='cgrid';PRESETS.forEach(function(h){var d=el('div','csw');d.style.background=h;d.setAttribute('data-c',h);if(pk&&h===css(pickC))d.classList.add('on');gr.appendChild(d);});gf.appendChild(gr);cl.appendChild(gf);ct.appendChild(cl);
 var cr=el('div');cr.id='cright';var cs2=el('div','csub top T');cs2.textContent='Custom';cr.appendChild(cs2);
 var spc=el('div','L');spc.id='cspec';var sq=el('div');sq.id='csq';var sqd=el('div');sqd.id='csqd';var sqm=el('div');sqm.id='csqm';sq.appendChild(sqd);sq.appendChild(sqm);var bar=el('div');bar.id='cbar';var barm=el('div');barm.id='cbarm';bar.appendChild(barm);spc.appendChild(sq);spc.appendChild(bar);cr.appendChild(spc);ct.appendChild(cr);
 rcol.appendChild(ct);
 setHsv(pickC);
 var vh=el('div','C');vh.id='vhead';var v1=el('span','T L');v1.id='vpick';v1.textContent=sub?'Subtract from gray':'Pick';v1.style.left='2px';vh.appendChild(v1);var v2=el('span','T L');v2.textContent='Result';v2.style.left='310px';vh.appendChild(v2);rcol.appendChild(vh);
 var vr=el('div','C');vr.id='vrow';
 var lbs=\['R','G','B'],ids=\['cr','cg','cb'];for(var j=0;j<3;j++){var f=el('div','fld L');f.style.left=(j*74)+'px';f.style.width='68px';var lb=el('span','lb');lb.textContent=lbs\[j];f.appendChild(lb);var tin=el('input','tin');tin.id=ids\[j];tin.type='text';tin.maxLength=3;tin.autocomplete='off';tin.spellcheck=false;tin.value=pk?String(pickC\[j]):'';tin.placeholder=pk?'':String(Math.round(eff\[j]));f.appendChild(tin);vr.appendChild(f);}
 var hf=el('div','fld L');hf.style.left='222px';hf.style.width='80px';var hin=el('input','tin hx');hin.id='chex';hin.type='text';hin.maxLength=7;hin.autocomplete='off';hin.spellcheck=false;hin.value=pk?css(pickC):'';hin.placeholder='default';hf.appendChild(hin);vr.appendChild(hf);
 var rf=el('div','fld L');rf.style.left='308px';rf.style.width='96px';var rs=el('div');rs.id='res';rs.style.background=css(eff);rf.appendChild(rs);vr.appendChild(rf);
 rcol.appendChild(vr);
 var rh=el('div','C');rh.id='rhead';var r1=el('span','T L');r1.textContent='Ramp';r1.style.left='2px';rh.appendChild(r1);var r2=el('span','T L');r2.textContent='edge to core';r2.style.right='2px';rh.appendChild(r2);rcol.appendChild(rh);
 var rf2=el('div','fld L C');rf2.id='rampf';var rr=el('div');rr.id='ramp';row.col.stops.forEach(function(s){var c=el('i');c.style.background=css(s);rr.appendChild(c);});rf2.appendChild(rr);rcol.appendChild(rf2);
}
function key(k){var s=el('span','k');s.textContent=k;return s;}
function dv(){return el('span','dv');}
function footer(empty){
 ft.appendChild(key('ESC'));ft.appendChild(document.createTextNode(' close'));
 if(empty)return;
 ft.appendChild(dv());ft.appendChild(key('CLICK'));ft.appendChild(document.createTextNode(' a swatch to edit it'));
 ft.appendChild(dv());ft.appendChild(document.createTextNode('changes save as you go'));
}
function setHsv(c){var o=rgbHsv(c\[0]/255,c\[1]/255,c\[2]/255);if(o\[1]>0)HUE=o\[0];SAT=o\[1];VAL=o\[2];}
function markColor(){
 var sqm=document.getElementById('csqm');if(!sqm)return;
 var sqd=document.getElementById('csqd'),bar=document.getElementById('cbar'),barm=document.getElementById('cbarm');
 sqm.style.left=(HUE*100)+'%';sqm.style.top=((1-SAT)*100)+'%';sqd.style.opacity=String(1-VAL);var tp=hsvRgb(HUE,SAT,1);bar.style.background='linear-gradient(to bottom,'+css(\[tp\[0]*255,tp\[1]*255,tp\[2]*255])+',#000)';barm.style.top=((1-VAL)*100)+'%';
}
function render(){
 var ls=document.getElementById('list'),st=ls?ls.scrollTop:0;
 clear(body);clear(ft);
 var empty=ROWS.length===0;
 if(empty){
  shell.style.width=G.EMPTY_W+'px';
  var e=el('div','empty T L');e.textContent='No energy skills to color yet.';body.appendChild(e);
 }else{
  if(SI<0||SI>=ROWS.length)SI=0;
  shell.style.width=(32+12+16+G.LCOL_W+G.GAP+G.RCOL_W)+'px';
  var cols=el('div','C');cols.id='cols';
  var lcol=el('div','C');lcol.id='lcol';lcol.style.width=G.LCOL_W+'px';renderList(lcol);cols.appendChild(lcol);
  var rcol=el('div','C');rcol.id='rcol';rcol.style.width=G.RCOL_W+'px';
  renderEditor(rcol,ROWS\[SI]);cols.appendChild(rcol);
  body.appendChild(cols);
  markColor();
 }
 footer(empty);
 placeMeasured();
 var l2=document.getElementById('list');if(l2)l2.scrollTop=st;
}
function placeMeasured(){
 var en=document.getElementById('ename');if(!en)return;
 var enr=textRect(en),etr=R(document.getElementById('etop'));
 if(ELLE){var er=R(en);if(er.r<enr.r)enr=er;}
 document.getElementById('elook').style.left=Math.round((enr.r-etr.l)/kz()+8)+'px';
 document.querySelectorAll('#lhead span').forEach(function(s){var x=+s.dataset.x;if(s.dataset.w){var w=s.getBoundingClientRect().width/kz();x=x+Math.round((+s.dataset.w-w)/2);}s.style.left=x+'px';});
}
function R(e){var r=e.getBoundingClientRect();return {l:r.left,t:r.top,r:r.right,b:r.bottom};}
function textRect(e){var rg=document.createRange();rg.selectNodeContents(e);var r=rg.getBoundingClientRect();return {l:r.left,t:r.top,r:r.right,b:r.bottom};}
function kz(){var k=hdr.offsetHeight/44;var g=hdr.getBoundingClientRect().height/44;return (g>0)?g:((k>0)?k:1);}
function measure(t){if(!meas){meas=el('span');meas.style.cssText='position:absolute;left:-99999px;top:0;white-space:nowrap;visibility:hidden';document.body.appendChild(meas);}meas.textContent=t;return meas.getBoundingClientRect().width/kz();}
function maxW(){var m=1200;if(B){var av=Math.floor((B.x1-B.x0)/Z)-16;if(av<m)m=av;}return m;}
function fitAll(){
 copyG();ELL=false;ELLE=false;
 if(!ROWS.length)return;
 var wn=0,we=0;
 for(var i=0;i<ROWS.length;i++){var w=measure(ROWS\[i].name);if(w>wn)wn=w;var w2=w+8+measure(ROWS\[i].look);if(w2>we)we=w2;}
 var dl=Math.max(0,Math.ceil(wn-G0.NM_W)),de=Math.max(0,Math.ceil(2+we+8+92-G0.RCOL_W));
 var base=32+12+16+G0.LCOL_W+G0.GAP+G0.RCOL_W,room=Math.max(0,maxW()-base);
 var gl=Math.min(dl,room),gr=Math.min(de,room-gl);
 if(gl<dl)ELL=true;if(gr<de)ELLE=true;
 G.NM_W+=gl;G.SW_X+=gl;G.RP_X+=gl;G.RS_X+=gl;G.LCOL_W+=gl;G.RCOL_W+=gr;
}
function size(){var k=hdr.getBoundingClientRect().height/44;if(!(k>0))k=1;var r=shell.getBoundingClientRect();return {w:Math.round(r.width/k*Z),h:Math.round(r.height/k*Z)};}
function place(){
 document.body.style.zoom=Z;applyCursor();frame.style.opacity=OP;
 if(ELLE){var en=document.getElementById('ename');if(en)en.style.maxWidth=Math.max(0,G.RCOL_W-2-8-92-8-measure(ROWS\[SI].look))+'px';placeMeasured();}
 var s=size();
 if(B){C0.x=B.x0+Math.round(((B.x1-B.x0)-s.w)/2);C0.y=B.y0+Math.round(((B.y1-B.y0)-s.h)/2);}else{C0.x=0;C0.y=0;}
 var x=C0.x+Math.round(P.x*Z),y=C0.y+Math.round(P.y*Z);
 if(B){x=clampNum(x,B.x0,B.x1-s.w);y=clampNum(y,B.y0,B.y1-s.h);}
 GM={x:x,y:y,w:s.w,h:s.h};
 ws({pos:GM.x+','+GM.y,size:GM.w+'x'+GM.h});
}
function relayout(){fitAll();render();place();}
function rowAt(i){return ROWS\[i]||null;}
function recolor(i){var r=rowAt(i);if(r)r.col=rowColors(r);}
function commitNow(){
 if(tmr){clearTimeout(tmr);tmr=null;}
 if(!dirty)return;
 var d=dirty;dirty=null;
 var r=rowAt(d.i);if(!r)return;
 var v=r.picks\[d.k];if(!v)return;
 topic({ecpage:'set',seq:SEQ,r:d.i+1,s:d.k+1,v:v});
}
function commitSoon(){if(tmr)clearTimeout(tmr);tmr=setTimeout(commitNow,600);}
function storePick(rgb,sub){
 var r=rowAt(SI);if(!r)return;
 if(dirty&&(dirty.i!==SI||dirty.k!==SL))commitNow();
 r.picks\[SL]=(sub?'-':'')+css(rgb);
 recolor(SI);dirty={i:SI,k:SL};
}
function curSub(){var r=rowAt(SI);return r?isSub(r.picks\[SL]):false;}
function select(i,k){
 commitNow();
 if(!rowAt(i))return;
 SI=i;SL=k;render();
}
function resetRow(i){
 var r=rowAt(i);if(!r)return;
 if(dirty&&dirty.i===i){if(tmr){clearTimeout(tmr);tmr=null;}dirty=null;}
 commitNow();
 r.picks=\[null,null,null];recolor(i);
 topic({ecpage:'reset',seq:SEQ,r:i+1});
 render();
}
function flip(sub){
 var r=rowAt(SI);if(!r)return;
 var pk=r.picks\[SL];
 if(!pk&&!sub)return;
 if(pk&&isSub(pk)===sub)return;
 var c=pk?hx(pk):r.col.eff\[SL];
 storePick(c,sub);commitNow();render();
}
function pickPreset(h){var c=hx(h);if(!c)return;storePick(c,curSub());commitNow();render();}
function paintLive(skip){
 var r=rowAt(SI);if(!r)return;
 var pk=r.picks\[SL],sub=isSub(pk),eff=r.col.eff\[SL],pickC=pk?hx(pk):eff;
 var it=document.querySelector(".it\[data-i='"+SI+"']");
 if(it){
  var sws=it.querySelectorAll('.sw');
  for(var k=0;k<sws.length;k++){var s=sws.item(k);s.style.background=css(r.col.eff\[k]);var mn=s.querySelector('.mn');if(isSub(r.picks\[k])&&!mn)s.appendChild(el('div','mn'));if(!isSub(r.picks\[k])&&mn)s.removeChild(mn);}
  var cells=it.querySelectorAll('.rp i');for(var c=0;c<cells.length;c++)cells.item(c).style.background=css(r.col.stops\[c]);
 }
 var chq=document.querySelectorAll('#slots .chq');
 for(var q=0;q<chq.length;q++){var b=chq.item(q);b.style.background=css(r.col.eff\[q]);var m2=b.querySelector('.mn');if(isSub(r.picks\[q])&&!m2)b.appendChild(el('div','mn'));if(!isSub(r.picks\[q])&&m2)b.removeChild(m2);}
 var ad=document.querySelector("#slots .chip\[data-k='add']"),sb=document.querySelector("#slots .chip\[data-k='sub']");
 if(ad)ad.classList.toggle('on',!sub);if(sb)sb.classList.toggle('on',sub);
 var vp=document.getElementById('vpick');if(vp)vp.textContent=sub?'Subtract from gray':'Pick';
 markColor();
 var ids=\['cr','cg','cb'];
 if(skip!=='rgb'){for(var j=0;j<3;j++){var f=document.getElementById(ids\[j]);if(f){f.value=pk?String(pickC\[j]):'';f.placeholder=pk?'':String(Math.round(eff\[j]));}}}
 if(skip!=='hex'){var hf=document.getElementById('chex');if(hf)hf.value=pk?css(pickC):'';}
 var rs=document.getElementById('res');if(rs)rs.style.background=css(eff);
 var rc=document.querySelectorAll('#ramp i');for(var n=0;n<rc.length;n++)rc.item(n).style.background=css(r.col.stops\[n]);
 var ring=pk?css(pickC):'',cs=document.querySelectorAll('#cgrid .csw');for(var p=0;p<cs.length;p++){var d=cs.item(p);d.classList.toggle('on',ring!==''&&d.getAttribute('data-c')===ring);}
}
function pickAt(e){
 var r=pick2.el.getBoundingClientRect();
 var fx=(r.width>0)?Math.max(0,Math.min(1,(e.clientX-r.left)/r.width)):0,fy=(r.height>0)?Math.max(0,Math.min(1,(e.clientY-r.top)/r.height)):0;
 if(pick2.el.id==='csq'){HUE=Math.min(0.9999,fx);SAT=1-fy;}else{VAL=1-fy;}
 var c=hsvRgb(HUE,SAT,VAL);
 storePick(\[Math.round(c\[0]*255),Math.round(c\[1]*255),Math.round(c\[2]*255)],curSub());
 paintLive('');
}
function typedRgb(){
 var r=rowAt(SI);if(!r)return;
 var eff=r.col.eff\[SL],ids=\['cr','cg','cb'],c=\[0,0,0];
 for(var j=0;j<3;j++){var f=document.getElementById(ids\[j]);var d=digits(f.value);if(d!==f.value)f.value=d;c\[j]=d.length?Math.min(255,parseInt(d,10)):Math.round((r.picks\[SL]?hx(r.picks\[SL]):eff)\[j]);}
 setHsv(c);storePick(c,curSub());paintLive('rgb');commitSoon();
}
function typedHex(){
 var f=document.getElementById('chex');var h=hexf(f.value);if(h!==f.value)f.value=h;
 var full=hexfull(h);if(!full)return;
 var c=hx(full);setHsv(c);storePick(c,curSub());paintLive('hex');commitSoon();
}
body.addEventListener('click',function(e){
 var t=e.target;
 var rs=t.closest('.rs');if(rs){resetRow(+rs.closest('.it').getAttribute('data-i'));return;}
 var sw=t.closest('.sw');if(sw){select(+sw.closest('.it').getAttribute('data-i'),+sw.getAttribute('data-k'));return;}
 var it=t.closest('.it');if(it){select(+it.getAttribute('data-i'),SL);return;}
 var ch=t.closest('.chip');if(ch){var k=ch.getAttribute('data-k');if(k==='add')flip(false);else if(k==='sub')flip(true);else select(SI,+k);return;}
 if(t.closest('#reset')){resetRow(SI);return;}
 var cs=t.closest('.csw');if(cs){pickPreset(cs.getAttribute('data-c'));return;}
});
body.addEventListener('pointerdown',function(e){
 if(e.button!==0)return;
 var tg=e.target.closest('#csq')||e.target.closest('#cbar');if(!tg)return;
 commitNow();pick2={el:tg};try{tg.setPointerCapture(e.pointerId);}catch(err){}pickAt(e);e.preventDefault();
});
body.addEventListener('pointermove',function(e){if(pick2)pickAt(e);});
body.addEventListener('pointerup',function(e){if(!pick2)return;pickAt(e);pick2=null;commitNow();render();});
body.addEventListener('input',function(e){var id=e.target.id;if(id==='chex')typedHex();else if(id==='cr'||id==='cg'||id==='cb')typedRgb();});
body.addEventListener('focusout',function(e){if(e.target.tagName==='INPUT'){commitNow();}});
document.getElementById('close').addEventListener('click',function(){closeIt();});
document.addEventListener('keydown',function(e){
 if(e.key==='Escape'){closeIt();e.preventDefault();return;}
 if(e.key==='Enter'&&e.target.tagName==='INPUT'){commitNow();render();e.preventDefault();}
});
document.addEventListener('contextmenu',function(e){e.preventDefault();});
window.addEventListener('blur',function(){commitNow();});
function closeIt(){commitNow();topic({ecpage:'close'});focusMap();}
var drag=null,pending=false;
function flush(){pending=false;if(B){GM.x=clampNum(GM.x,B.x0,B.x1-GM.w);GM.y=clampNum(GM.y,B.y0,B.y1-GM.h);}ws({pos:GM.x+','+GM.y});}
function sched(){if(!pending){pending=true;requestAnimationFrame(flush);}}
hdr.addEventListener('pointerdown',function(e){if(e.button!==0)return;if(e.target.closest('#close'))return;drag={sx:e.screenX,sy:e.screenY,x:GM.x,y:GM.y};try{hdr.setPointerCapture(e.pointerId);}catch(err){}e.preventDefault();});
hdr.addEventListener('pointermove',function(e){if(!drag)return;GM.x=drag.x+(e.screenX-drag.sx);GM.y=drag.y+(e.screenY-drag.sy);sched();});
hdr.addEventListener('pointerup',function(e){if(!drag)return;drag=null;flush();P={x:Math.round((GM.x-C0.x)/Z),y:Math.round((GM.y-C0.y)/Z)};topic({ecpage:'pan',x:P.x,y:P.y});});
function setPage(pk){
 var o=null;try{o=JSON.parse(dec(pk));}catch(e){o=null;}if(!o)return;
 commitNow();
 var prev=rowAt(SI)?ROWS\[SI].name:null;
 SEQ=+o.seq;Z=(+o.z)||1;OP=(o.op===undefined)?0.85:+o.op;
 B=null;if((+o.x1)>(+o.x0)&&(+o.y1)>(+o.y0))B={x0:+o.x0,y0:+o.y0,x1:+o.x1,y1:+o.y1};
 P={x:(+o.px)||0,y:(+o.py)||0};
 var rows=o.rows||\[],out=\[];
 for(var i=0;i<rows.length;i++){var a=rows\[i];var r={name:String(a\[0]),look:String(a\[1]),picks:\[okHex(a\[2]),okHex(a\[3]),okHex(a\[4])]};r.col=rowColors(r);out.push(r);}
 ROWS=out;SI=0;
 if(prev!==null){for(var j=0;j<ROWS.length;j++){if(ROWS\[j].name===prev){SI=j;break;}}}
 if(SL<0||SL>2)SL=0;
 document.body.style.zoom=Z;
 relayout();
 var ls=document.getElementById('list');
 if(ls){var t=SI*G.RH,h=G.ROWS*G.RH;if(t<ls.scrollTop||t+G.RH>ls.scrollTop+h)ls.scrollTop=Math.max(0,t-h+G.RH);}
 fontsCheck();
 try{shell.focus();}catch(e){}
}
function refit(){if(!SEQ)return;relayout();}
function fontsCheck(){try{if(document.fonts&&document.fonts.check&&!document.fonts.check("16px 'monogram'"))document.fonts.load("16px 'monogram'").then(refit);}catch(e){}}
if(document.fonts&&document.fonts.ready){document.fonts.ready.then(refit);}
function boot(){live=true;booted=true;topic({ecpage:'ready'});}
if(window.BYOND){boot();}else{window.addEventListener('byond-ready',boot);}
</script>
</body></html>"}

client/proc/EnergyColorsOpen()
	if(!mob) return
	if(!EnergyColorsEnsureControl())
		mob << "The Energy Colors page could not open."
		return
	EnergyColorsSendAssets()
	ec_open = 1
	if(!ec_loaded)
		ec_loaded = 1
		winset(src, ECPAGE_CTL, "inner-background-color=transparent")
		src << browse(EnergyColorsPageHTML(), "window=[ECPAGE_CTL]")
		return
	if(ec_ready) EnergyColorsPush()

client/proc/EnergyColorsPush()
	if(!ec_open || !mob) return
	ec_seq++
	ec_rows = EnergyColorsSkills(mob)
	var/list/rows = list()
	for(var/obj/Skills/S in ec_rows)
		var/datum/energyfx_row/R = EnergyColorsRowOf(S)
		rows[++rows.len] = list("[S.name]", R.look, EnergyColorsClean(S.EnergyColorMain), EnergyColorsClean(S.EnergyColorCore), EnergyColorsClean(S.EnergyColorGlow))
	var/list/r = PanelViewRect()
	var/x0 = 0
	var/y0 = 0
	var/x1 = 0
	var/y1 = 0
	var/z = chatpanel_zoom ? chatpanel_zoom : 1
	if(r)
		x0 = r[1]
		y0 = r[2]
		x1 = r[3]
		y1 = r[4]
		z = r[5]
	var/list/pk = list("seq" = ec_seq, "z" = z, "op" = chatpanel_opacity, "x0" = x0, "y0" = y0, "x1" = x1, "y1" = y1, "px" = ec_pan_x, "py" = ec_pan_y, "rows" = rows)
	src << output(list2params(list(url_encode(json_encode(pk)))), "[ECPAGE_CTL]:setPage")
	WebOverlayShow(ECPAGE_CTL, "is-visible=true;focus=true")

client/proc/EnergyColorsClose()
	if(!ec_open) return
	ec_open = 0
	ec_rows = null
	winset(src, ECPAGE_CTL, "is-visible=false")
	MapFocus()

client/proc/EnergyColorsSkillAt(r)
	var/i = text2num("[r]")
	if(!ec_rows || isnull(i) || i != round(i) || i < 1 || i > ec_rows.len) return null
	var/obj/Skills/S = ec_rows[i]
	if(!S || !mob || !(S in mob) || !EnergyColorsRowOf(S)) return null
	return S

client/proc/EnergyColorsTopic(list/href_list)
	switch(href_list["ecpage"])
		if("ready")
			ec_ready = 1
			if(ec_open) EnergyColorsPush()
		if("pan")
			var/px = text2num(href_list["x"])
			var/py = text2num(href_list["y"])
			if(!isnull(px) && !isnull(py))
				ec_pan_x = clamp(round(px), -4000, 4000)
				ec_pan_y = clamp(round(py), -4000, 4000)
		if("set")
			if(!ec_open || text2num(href_list["seq"]) != ec_seq) return
			var/obj/Skills/S = EnergyColorsSkillAt(href_list["r"])
			if(!S)
				EnergyColorsPush()
				return
			EnergyColorsApply(S, text2num(href_list["s"]), href_list["v"])
		if("reset")
			if(!ec_open || text2num(href_list["seq"]) != ec_seq) return
			var/obj/Skills/S = EnergyColorsSkillAt(href_list["r"])
			if(!S)
				EnergyColorsPush()
				return
			EnergyColorsReset(S)
		if("close")
			EnergyColorsClose()

client/Topic(href, href_list[], hsrc)
	if(href_list && href_list["ecpage"])
		EnergyColorsTopic(href_list)
		return
	return ..()

client/WebOverlayStates()
	. = ..()
	if(ec_made) .[ECPAGE_CTL] = ec_open && ec_ready

mob/verb/Customize_Energy_Colors()
	set name = "Customize: Energy Colors"
	set category = "Other"
	set hidden = 1
	client?.EnergyColorsOpen()
