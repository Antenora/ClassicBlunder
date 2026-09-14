#define LOGPAGE_CTL "mapwindow.logoverlay"
#define LOGPAGE_CHUNK 250

client/var/logpage_open = 0
client/var/logpage_geom = null
client/var/logpage_lock = 0
client/var/logpage_fold = 0
client/var/logpage_zoom = 1
client/var/logpage_x0 = 0
client/var/logpage_y0 = 0
client/var/logpage_booted = 0
client/var/logpage_target = null
client/var/logpage_scope = "self"
client/var/logpage_follow = 0
client/var/logpage_tz = 0
client/var/logpage_req = 0
client/var/list/logpage_pts

client/proc/LogPageSendAssets()
	ChatPanelSendAssets()
	src << browse_rsc('HUD/chatpanel/lc_tabw.png', "lc_tabw.png")
	src << browse_rsc('HUD/chatpanel/lc_tabw_on.png', "lc_tabw_on.png")
	src << browse_rsc('HUD/chatpanel/lc_chip_a.png', "lc_chip_a.png")
	src << browse_rsc('HUD/chatpanel/lc_chip_b.png', "lc_chip_b.png")
	src << browse_rsc('HUD/chatpanel/lc_band.png', "lc_band.png")
	src << browse_rsc('HUD/chatpanel/lc_star.png', "lc_star.png")
	src << browse_rsc('HUD/chatpanel/lc_star_off.png', "lc_star_off.png")
	src << browse_rsc('HUD/chatpanel/lc_search.png', "lc_search.png")
	src << browse_rsc('HUD/chatpanel/lc_btn.png', "lc_btn.png")
	src << browse_rsc('HUD/chatpanel/lc_btn_down.png', "lc_btn_down.png")
	src << browse_rsc('HUD/chatpanel/lc_arrow_l.png', "lc_arrow_l.png")
	src << browse_rsc('HUD/chatpanel/lc_arrow_r.png', "lc_arrow_r.png")
	src << browse_rsc('HUD/chatpanel/lc_arrow_d.png', "lc_arrow_d.png")
	src << browse_rsc('HUD/chatpanel/lc_arrow_u.png', "lc_arrow_u.png")
	src << browse_rsc('HUD/chatpanel/lc_car_d.png', "lc_car_d.png")
	src << browse_rsc('HUD/chatpanel/lc_car_r.png', "lc_car_r.png")
	src << browse_rsc('HUD/chatpanel/lc_car_u.png', "lc_car_u.png")

client/proc/LogPageHTML()
	return {"<!DOCTYPE html><html><head><meta charset='utf-8'><style>
 @font-face{font-family:'monogram';src:url('monogram.ttf')}
 @font-face{font-family:'lfcrimson';src:url('lf_crimson.ttf')}
 @font-face{font-family:'lfcinzel';src:url('lf_cinzel.ttf')}
 @font-face{font-family:'lfcaveat';src:url('lf_caveat.ttf')}
 @font-face{font-family:'lfelite';src:url('lf_elite.ttf')}
 @font-face{font-family:'lffraktur';src:url('lf_fraktur.ttf')}
 @font-face{font-family:'lfgotham';src:url('gotham.otf')}
 font\[face=crimson],#ed.f-crimson{font-family:lfcrimson,serif;font-size:17px;line-height:1.15}
 font\[face=cinzel],#ed.f-cinzel{font-family:lfcinzel,serif;font-size:13px;line-height:1.3}
 font\[face=caveat],#ed.f-caveat{font-family:lfcaveat,cursive;font-size:19px;line-height:1.05}
 font\[face=elite],#ed.f-elite{font-family:lfelite,monospace;font-size:14px;line-height:1.25}
 font\[face=fraktur],#ed.f-fraktur{font-family:lffraktur,serif;font-size:17px;line-height:1.15}
 font\[face=gotham],#ed.f-gotham{font-family:lfgotham,sans-serif;font-size:14px;line-height:1.25}
 font\[face=pixel],#ed.f-pixel{font-family:monogram,monospace;font-size:16px;line-height:1}
 html,body{margin:0;padding:0;background:transparent;overflow:hidden;width:100%;height:100%}
 body{font:16px/16px 'monogram';color:#eaf5ff;user-select:none;-webkit-user-select:none}
 #shell{position:absolute;left:0;top:0;width:496px;height:420px;image-rendering:pixelated}
 #frame{position:absolute;left:0;top:0;right:0;bottom:0;border:16px solid transparent;border-image:url('lc_cover.png') 16 fill stretch;pointer-events:none}
 #frame.strip{border-image:url('lc_cover_strip.png') 16 fill stretch}
 #hdr{position:absolute;left:0;top:0;right:0;height:44px}
 .tabw{position:absolute;top:8px;width:84px;height:32px;background:url('lc_tabw.png') no-repeat;line-height:32px;text-align:center;color:#cfe3f5;cursor:pointer}
 .tabw.on{background-image:url('lc_tabw_on.png');color:#06283b}
 .btn{position:absolute;top:8px;width:32px;height:32px;background:url('lc_slot.png') no-repeat;cursor:pointer}
 .btn img.ic{position:absolute;left:8px;top:8px;width:16px;height:16px}
 .btn img.ar{position:absolute;left:9px;top:8px;width:13px;height:15px}
 #lock{right:52px}
 #fold{right:16px}
 .row3{position:absolute;left:16px;right:16px;height:30px}
 .lab{position:absolute;top:8px;color:#7ec8f0}
 .fld{position:absolute;height:30px;border:8px solid transparent;border-image:url('lc_field.png') 8 fill stretch;box-sizing:border-box}
 .dd{position:absolute;top:4px;height:22px;border:8px solid transparent;border-image:url('lc_field.png') 8 fill stretch;box-sizing:border-box;cursor:pointer}
 .dd span{position:absolute;left:0;top:-5px;right:14px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
 .dd img{position:absolute;right:0;top:1px;width:5px;height:4px}
 .fld .txt{position:absolute;left:2px;top:-1px;white-space:nowrap}
 .fld img.car{position:absolute;right:1px;top:5px;width:5px;height:4px}
 .slot{position:absolute;top:-1px;width:32px;height:32px;background:url('lc_slot.png') no-repeat;cursor:pointer}
 .slot img{position:absolute;left:9px;top:8px;width:13px;height:15px}
 #prev{left:0}
 #date{left:36px;width:132px;cursor:pointer}
 #next{left:172px}
 #srch{left:212px;right:0}
 #srch img.mg{position:absolute;left:1px;top:-1px;width:16px;height:16px}
 #q{position:absolute;left:22px;top:-1px;right:60px;height:16px;margin:0;padding:0;background:transparent;border:0;outline:0;font:16px/16px 'monogram';color:#eaf5ff;caret-color:#eaf5ff}
 #cnt{position:absolute;right:30px;top:-1px;color:#8aa2c8;white-space:nowrap}
 .stp{position:absolute;top:1px;width:10px;height:10px;cursor:pointer}
 #sup{right:14px}
 #sdn{right:0}
 .lit{position:absolute;height:24px;border:8px solid transparent;border-image:url('lc_btn.png') 8 fill stretch;box-sizing:border-box;cursor:pointer;color:#eaf5ff;text-align:center}
 .lit span{position:absolute;left:0;right:0;top:-3px}
 .lit.on{border-image-source:url('lc_btn_down.png');color:#06283b}
 .lit:hover{color:#8be9ff}
 .lit.on:hover{color:#06283b}
 #chips{position:absolute;left:16px;right:16px;height:18px}
 .chip{position:absolute;top:0;height:18px;line-height:16px;text-align:center;color:#cfe3f5;cursor:pointer}
 .chip .bg{position:absolute;left:0;top:0;right:0;bottom:0;border:6px solid transparent;border-image:url('lc_chip_a.png') 6 fill stretch;box-sizing:border-box;pointer-events:none}
 .chip.on{color:#06283b}
 .chip.on .bg{border-image-source:url('lc_chip_b.png')}
 .chip span{position:relative}
 .chip:hover{color:#8be9ff}
 .chip.on:hover{color:#06283b}
 #body{position:absolute;left:16px;right:16px;bottom:78px;border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box}
 #log{position:absolute;left:22px;right:26px;bottom:84px;padding:2px 4px 4px 4px;overflow-y:scroll;overflow-x:hidden;box-sizing:border-box;user-select:text;-webkit-user-select:text}
 #log::-webkit-scrollbar{width:14px}
 #log::-webkit-scrollbar-track{background:url('lc_track.png') no-repeat;background-size:100% 100%;margin:6px 0}
 #log::-webkit-scrollbar-thumb{border-left:1px solid transparent;border-right:1px solid transparent;background-clip:padding-box;background-origin:padding-box;background:url('lc_thumb_top.png') left top no-repeat,url('lc_thumb_bot.png') left bottom no-repeat,url('lc_thumb_mid.png') left center no-repeat,url('lc_thumb_col.png') left top repeat-y;background-size:12px 6px,12px 6px,12px 11px,12px 1px;min-height:24px}
 #log.nofonts font\[face]{font-family:'monogram' !important;font-size:16px !important;line-height:16px !important}
 .sh{position:relative;margin:2px 0 4px 0;padding:0 0 2px 48px;border-bottom:1px solid #344975;color:#bfe6ff;white-space:nowrap;overflow:hidden;cursor:pointer}
 .sh img{position:absolute;left:34px;top:3px;width:10px;height:10px}
 .sh .sp{color:#8aa2c8}
 .sh .rs{float:right;color:#8be9ff}
 .sh .rs i{font-style:normal;cursor:pointer}
 .sh .rs i:hover{text-decoration:underline}
 .row{position:relative;padding:0 0 0 48px;margin:1px 0 1px 0;min-height:16px;white-space:pre-wrap;word-wrap:break-word;cursor:pointer}
 .row.pt{min-height:48px;display:flex;align-items:flex-end}
 .row.pt .tx{flex:1 1 auto;min-width:0;padding-top:3px}
 .row img.pt{position:absolute;left:0;bottom:2px;width:42px;height:43px}
 .row .tm{float:right;color:#8aa2c8;margin-left:10px;white-space:nowrap}
 .row .st{float:right;width:12px;height:12px;margin:2px 0 0 6px;background:url('lc_star.png') no-repeat center;background-size:contain;display:none}
 .row.pin .st{display:block}
 .row .pl{position:absolute;left:-6px;top:-2px;right:-6px;bottom:-2px;border:6px solid transparent;border-image:url('lc_rowplate.png') 6 fill stretch;display:none;pointer-events:none}
 .row.sel .pl{display:block}
 .row.sel{z-index:1}
 .row .tx,.row .tm,.row .st{position:relative}
 .row .k{color:#8aa2c8}
 .row .oc{color:#5fe08a}
 .row .sys{color:#b8b8d9}
 .row .hit{color:#5c7e9a}
 .row .mu{color:#7b8fb0}
 .row .tag{color:#7ec8f0}
 .row .v{color:inherit}
 .hl{background:#644e1b}
 .hl.cur{outline:1px solid #8be9ff}
 .more{position:relative;display:inline-block;height:18px;line-height:16px;padding:0 8px;margin:4px 0 2px 0;color:#cfe3f5;cursor:pointer}
 .more .bg{position:absolute;left:0;top:0;right:0;bottom:0;border:6px solid transparent;border-image:url('lc_chip_a.png') 6 fill stretch;box-sizing:border-box}
 .more span{position:relative}
 .row div\[align=right]{display:block;text-align:right}
 .row div\[align=center],.row center{display:block;text-align:center}
 .th{position:relative;height:16px;margin:0 0 4px 0;padding-bottom:2px;border-bottom:1px solid #344975;color:#7ec8f0;white-space:nowrap}
 .tr{position:relative;height:18px;line-height:16px;white-space:nowrap;cursor:pointer}
 .tr .pl{position:absolute;left:-6px;top:-1px;right:-6px;bottom:-1px;border:6px solid transparent;border-image:url('lc_rowplate.png') 6 fill stretch;display:none;pointer-events:none}
 .tr.sel .pl{display:block}
 .tr:hover .pl{display:block}
 .c{position:absolute;top:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
 .tr .c.t{color:#8aa2c8}
 .tr .c.a{color:#bfe6ff}
 .tr .c.d{color:#a9c4e6}
 .tr .c.sev{color:#e4635e}
 .card{position:relative;margin:0 0 6px 0;padding:6px 8px 6px 8px;border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box}
 .card .ti{color:#bfe6ff}
 .card .sp{color:#8aa2c8}
 .card .rs{color:#8be9ff;white-space:normal;margin:4px 0}
 .card .cn{color:#7ec8f0;margin:2px 0 6px 0}
 .card .acts{position:relative;height:18px}
 .card .chip{position:absolute}
 .story{padding:2px 6px 8px 6px;white-space:pre-wrap;word-wrap:break-word;user-select:text;-webkit-user-select:text}
 .story p{margin:0 0 10px 0}
 .story .who{color:#7ec8f0}
 .kv{position:relative;height:16px;white-space:nowrap}
 .kv .k{color:#7ec8f0}
 .kv .v{position:absolute;right:0;top:0;color:#eaf5ff}
 .sub{position:relative;margin:0 0 6px 0;padding:6px 8px;border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box}
 .sub .hd{color:#bfe6ff;margin-bottom:4px}
 .note{margin:0 0 6px 0;white-space:pre-wrap;word-wrap:break-word}
 .note .by{color:#8aa2c8}
 .empty{padding:8px 6px;color:#b8b8d9;white-space:normal}
 #band{position:absolute;left:16px;right:16px;bottom:38px;height:34px;border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box}
 #ctx{position:absolute;left:2px;top:3px;color:#8aa2c8;white-space:nowrap}
 #bchips{position:absolute;left:0;top:2px;right:70px;height:18px}
 #bchips .chip{position:relative;display:inline-block;margin-right:6px;padding:0 8px}
 #export{position:absolute;right:0;top:-1px;width:60px}
 #foot{position:absolute;left:16px;right:16px;bottom:14px;height:18px;white-space:nowrap;overflow:hidden}
 #foot .bg{position:absolute;left:0;top:0;right:0;bottom:0;border:6px solid transparent;border-image:url('lc_band.png') 6 fill stretch;box-sizing:border-box}
 #foot .t{position:absolute;left:8px;top:2px}
 #foot .k{color:#7ec8f0}
 #foot .d{color:#b8b8d9}
 #foot .dv{display:inline-block;width:1px;height:8px;background:#6096c8;margin:0 9px 0 8px;vertical-align:top;position:relative;top:4px}
 #grip{position:absolute;right:0;bottom:0;width:20px;height:20px}
 .pop{position:absolute;display:none;border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box;z-index:9;background:transparent}
 .pop .in{position:relative}
 .dr{position:relative;height:18px;line-height:18px;padding:0 8px;white-space:nowrap;overflow:hidden;cursor:pointer;color:#eaf5ff}
 .dr .pl{position:absolute;left:0;top:0;right:0;bottom:0;border:6px solid transparent;border-image:url('lc_rowplate.png') 6 fill stretch;display:none}
 .dr.sel .pl,.dr:hover .pl{display:block}
 .dr span{position:relative}
 .dr .cat{position:absolute;right:8px;top:0;color:#7ec8f0}
 .dr.hint{color:#b8b8d9;cursor:default}
 #cal{width:232px}
 #calh{position:relative;height:18px;margin:2px 0 4px 0;text-align:center;color:#bfe6ff}
 #calh img{position:absolute;top:2px;width:10px;height:10px;cursor:pointer}
 #calp{left:6px}
 #caln{right:6px}
 .cw{position:relative;height:16px;color:#7ec8f0}
 .cw span,.cd span{display:inline-block;width:30px;text-align:center}
 .cd{position:relative;height:18px}
 .cd span{cursor:pointer;height:18px;line-height:18px;position:relative}
 .cd span.has{color:#eaf5ff}
 .cd span.no{color:#5c7e9a}
 .cd span.has:after{content:'';position:absolute;left:13px;bottom:1px;width:4px;height:4px;background:url('lc_dot.png')}
 .cd span.today{color:#8be9ff}
 .cd span.selday{color:#06283b;background:#3490c0}
 .pin{position:relative}
 #tpop .fld{position:relative;left:0;right:0;height:30px;margin:0 0 4px 0;display:block}
 #tpop input{position:absolute;left:2px;top:-1px;right:2px;height:16px;margin:0;padding:0;background:transparent;border:0;outline:0;font:16px/16px 'monogram';color:#eaf5ff;caret-color:#eaf5ff}
 #tlist{max-height:180px;overflow:hidden}
 #npop{width:300px}
 #npop textarea{display:block;width:100%;height:64px;box-sizing:border-box;margin:0 0 4px 0;padding:2px;background:#0c1828;border:1px solid #344975;outline:0;resize:none;font:16px/16px 'monogram';color:#eaf5ff;caret-color:#eaf5ff}
 #apop{width:260px}
 #apop .fld{position:relative;left:0;right:0;height:30px;margin:4px 0;display:block}
 #apop input{position:absolute;left:2px;top:-1px;right:2px;height:16px;margin:0;padding:0;background:transparent;border:0;outline:0;font:16px/16px 'monogram';color:#eaf5ff;caret-color:#eaf5ff}
 .pop .acts{position:relative;height:18px;margin-top:2px}
 .pop .acts .chip{position:relative;display:inline-block;margin-right:6px;padding:0 8px}
 :root{--cur:url('lc_cur_neutral.png') 2 0, auto;--cur-text:url('lc_cur_ibeam.png') 2 5, text;--cur-drag:url('lc_cur_drag.png') 4 5, move}
 *{cursor:var(--cur) !important}
 input,textarea,#log,.story{cursor:var(--cur-text) !important}
 #hdr.dragok,#grip{cursor:var(--cur-drag) !important}
 </style></head><body>
 <div id='shell'>
  <div id='frame'></div>
  <div id='hdr'>
   <div id='tabs'></div>
   <div class='btn' id='lock'><img class='ic' src='lc_unlock.png' alt=''></div>
   <div class='btn' id='fold'><img class='ar' src='lc_arrow_d.png' alt=''></div>
  </div>
  <div class='row3' id='trow' style='display:none'>
   <span class='lab' style='left:0'>TARGET</span>
   <div class='dd' id='tsel' style='left:42px;right:158px'><span id='tname'>-</span><img src='lc_caret.png' alt=''></div>
   <div class='lit' id='keys' style='right:110px;top:3px;width:40px'><span>KEYS</span></div>
   <div class='lit' id='follow' style='right:58px;top:3px;width:52px'><span>FOLLOW</span></div>
   <div class='lit' id='record' style='right:0;top:3px;width:52px'><span>RECORD</span></div>
  </div>
  <div class='row3' id='nav'>
   <div class='slot' id='prev'><img src='lc_arrow_l.png' alt=''></div>
   <div class='fld' id='date'><span class='txt' id='datet'>-</span><img class='car' src='lc_caret.png' alt=''></div>
   <div class='slot' id='next'><img src='lc_arrow_r.png' alt=''></div>
   <div class='fld' id='srch'><img class='mg' src='lc_search.png' alt=''><input id='q' type='text' autocomplete='off' spellcheck='false'><span id='cnt'></span><img class='stp' id='sup' src='lc_car_u.png' alt=''><img class='stp' id='sdn' src='lc_car_d.png' alt=''></div>
  </div>
  <div id='chips'></div>
  <div id='body'></div>
  <div id='log'></div>
  <div id='band'><span id='ctx'></span><div id='bchips'></div><div class='lit' id='export'><span>EXPORT</span></div></div>
  <div id='foot'><div class='bg'></div><div class='t' id='foott'></div></div>
  <div class='pop' id='cal'><div class='in'><div id='calh'><img id='calp' src='lc_car_r.png' alt='' style='transform:scaleX(-1)'><span id='calt'></span><img id='caln' src='lc_car_r.png' alt=''></div><div class='cw'><span>SU</span><span>MO</span><span>TU</span><span>WE</span><span>TH</span><span>FR</span><span>SA</span></div><div id='calg'></div></div></div>
  <div class='pop' id='tpop'><div class='in'><div class='fld'><input id='tq' type='text' autocomplete='off' spellcheck='false' placeholder='filter names'></div><div id='tlist'></div></div></div>
  <div class='pop' id='xpop'><div class='in' id='xlist'></div></div>
  <div class='pop' id='npop'><div class='in'><div class='hd' style='color:#bfe6ff;margin-bottom:4px' id='nhd'>NOTE</div><textarea id='ntext' spellcheck='false'></textarea><div class='acts'><div class='chip' id='nsave'><div class='bg'></div><span>SAVE</span></div><div class='chip' id='ncancel'><div class='bg'></div><span>CANCEL</span></div></div></div></div>
  <div class='pop' id='apop'><div class='in'><div style='color:#bfe6ff'>KEYWORD ALERTS</div><div id='alist'></div><div class='fld'><input id='aq' type='text' autocomplete='off' spellcheck='false' placeholder='new word'></div><div class='acts'><div class='chip' id='aadd'><div class='bg'></div><span>ADD</span></div><div class='chip' id='aclose'><div class='bg'></div><span>CLOSE</span></div></div></div></div>
  <div id='grip'></div>
 </div>
 <script>
 var shell=document.getElementById('shell'), hdr=document.getElementById('hdr'), log=document.getElementById('log'), frame=document.getElementById('frame'), bodyEl=document.getElementById('body');
 var tabsEl=document.getElementById('tabs'), chipsEl=document.getElementById('chips'), bandEl=document.getElementById('band'), foott=document.getElementById('foott'), ctxEl=document.getElementById('ctx'), bchips=document.getElementById('bchips');
 var trow=document.getElementById('trow'), nav=document.getElementById('nav'), grip=document.getElementById('grip'), fold=document.getElementById('fold'), lockBtn=document.getElementById('lock');
 var lockImg=lockBtn.getElementsByTagName('img').item(0), foldImg=fold.getElementsByTagName('img').item(0);
 var qIn=document.getElementById('q'), cntEl=document.getElementById('cnt'), dateT=document.getElementById('datet');
 var PREVIEW=false;
 var CTL='mapwindow.logoverlay', MINW=496, MINH=360;
 var Z=2, OP=0.85, G={x:0,y:0,w:992,h:840}, B=null, live=false, locked=false, collapsed=false;
 var role={lvl:0,me:'',name:'',target:'',scope:'self',ts:0};
 var rows=\[], reqId=0, buf=null, day='', dayCounts={}, calMonth='', pins={}, sceneNames={}, sel=null, view='list', tab='log';
 var types={}, who='', q='', hits=\[], hitIdx=-1, keysOn=false, following=false, storyIdx=-1, targets=\[], record=null, alerts=\[], expanded={}, ctxAnchor=0, truncated=false, lastDays='';
 var TZ=-new Date().getTimezoneOffset();
 var CHAT={say:1,yell:1,ask:1,looc:1,whisper:1,think:1,ooc:1,emote:1,roll:1,legacy:1,narrate:1,announce:1};
 var IC={say:1,yell:1,ask:1,whisper:1,think:1,emote:1,roll:1};
 var GROUPS={SAY:{say:1,yell:1,ask:1,looc:1},EMOTE:{emote:1},WHISPER:{whisper:1,think:1},OOC:{ooc:1},ROLLS:{roll:1},COMBAT:{combat:1,hit:1,kill:1,death:1,maim:1}};
 var ACAT={BANS:'bans',EDITS:'edits',TELEPORT:'teleport',WORLD:'world',AHELP:'ahelp',CHAT:'chat'};
 function clampNum(v,lo,hi){ if(hi<lo) hi=lo; if(v<lo) return lo; if(v>hi) return hi; return v; }
 function esc(x){ return String(x==null?'':x).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/'/g,'&#39;'); }
 function dec(v){ try{ return decodeURIComponent(String(v).split('+').join(' ')); }catch(e){ return String(v); } }
 function ws(p){ if(window.BYOND) BYOND.winset(CTL,p); }
 function topic(p){ p.logpage=p.logpage||''; if(window.BYOND) BYOND.topic(p); }
 function focusMap(){ if(window.BYOND) BYOND.winset('mapwindow.map',{focus:true}); }
 function applyCursor(){ var two=(Z>=2); var r=document.documentElement.style; r.setProperty('--cur',two?"url('lc_cur_neutral2.png') 5 1, auto":"url('lc_cur_neutral.png') 2 0, auto"); r.setProperty('--cur-text',two?"url('lc_cur_ibeam2.png') 5 11, text":"url('lc_cur_ibeam.png') 2 5, text"); r.setProperty('--cur-drag',two?"url('lc_cur_drag2.png') 9 11, move":"url('lc_cur_drag.png') 4 5, move"); }
 function isAdmin(){ return role.lvl>=3 && role.scope!=='self'; }
 function adminMode(){ return role.lvl>=3; }
 function pad2(n){ return (n<10?'0':'')+n; }
 function todayLocal(){ var d=new Date(); return d.getFullYear()+'-'+pad2(d.getMonth()+1)+'-'+pad2(d.getDate()); }
 function dayLabel(s){ var p=s.split('-'); if(p.length<3) return s; var M=\['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']; return (+p\[2])+' '+M\[(+p\[1])-1]+' '+p\[0]; }
 function shiftDay(s,n){ var p=s.split('-'); var d=new Date(+p\[0],+p\[1]-1,+p\[2]); d.setDate(d.getDate()+n); return d.getFullYear()+'-'+pad2(d.getMonth()+1)+'-'+pad2(d.getDate()); }
 function hm(lt){ return (lt&&lt.length>=16)?lt.substring(11,16):''; }
 function clampG(){
  if(!B) return;
  var h=collapsed?48*Z:G.h;
  if(G.w>B.x1-B.x0) G.w=B.x1-B.x0;
  if(!collapsed && G.h>B.y1-B.y0){ G.h=B.y1-B.y0; h=G.h; }
  G.x=clampNum(G.x,B.x0,B.x1-G.w); G.y=clampNum(G.y,B.y0,B.y1-h);
 }
 function hasTrow(){ return adminMode() && (tab==='players'); }
 function layout(){
  document.body.style.zoom=Z; applyCursor();
  var W=Math.round(G.w/Z), H=collapsed?48:Math.round(G.h/Z);
  shell.style.width=W+'px'; shell.style.height=H+'px';
  frame.style.opacity=OP; bodyEl.style.opacity=OP; bandEl.style.opacity=OP;
  frame.classList.toggle('strip',collapsed);
  if(!live){ shell.style.left=Math.round(G.x/Z)+'px'; shell.style.top=Math.round(G.y/Z)+'px'; }
  var show=collapsed?'none':'block';
  var top=44;
  var tr=hasTrow();
  trow.style.display=(collapsed||!tr)?'none':'block';
  if(tr){ trow.style.top=top+'px'; top+=36; }
  nav.style.top=top+'px'; nav.style.display=show;
  chipsEl.style.top=(top+36)+'px'; chipsEl.style.display=show;
  bodyEl.style.top=(top+60)+'px'; bodyEl.style.display=show;
  log.style.top=(top+66)+'px'; log.style.display=show;
  bandEl.style.display=show; document.getElementById('foot').style.display=show; grip.style.display=(collapsed||locked)?'none':'block';
  foldImg.src=collapsed?'lc_arrow_u.png':'lc_arrow_d.png';
  lockImg.src=locked?'lc_lock.png':'lc_unlock.png'; hdr.classList.toggle('dragok',!locked);
 }
 function setGeom(x,y,w,h,z,op,bx0,by0,bx1,by1,lk,fd){ G={x:+x,y:+y,w:+w,h:+h}; Z=+z; OP=+op; if(bx1!==undefined){ B={x0:+bx0,y0:+by0,x1:+bx1,y1:+by1}; } locked=(+lk)?true:false; var wantFold=(+fd)?true:false; collapsed=false; if(wantFold){ collapsed=true; G.y+=G.h-48*Z; } clampG(); if(collapsed){ flush(); } else { layout(); } }
 var pending=false;
 function flush(){ pending=false; clampG(); ws({pos:G.x+','+G.y, size:G.w+'x'+(collapsed?48*Z:G.h)}); layout(); }
 function sched(){ if(!pending){ pending=true; requestAnimationFrame(flush); } }
 function report(){ topic({logpage:'geom', g:G.x+','+G.y+','+G.w+','+G.h}); }
 var drag=null;
 hdr.addEventListener('pointerdown',function(e){ if(e.button!==0||locked) return; if(e.target.closest('.tabw')||e.target.closest('.btn')) return; drag={sx:e.screenX,sy:e.screenY,x:G.x,y:G.y}; try{ hdr.setPointerCapture(e.pointerId); }catch(err){} e.preventDefault(); });
 hdr.addEventListener('pointermove',function(e){ if(!drag) return; G.x=drag.x+(e.screenX-drag.sx); G.y=drag.y+(e.screenY-drag.sy); clampG(); sched(); });
 hdr.addEventListener('pointerup',function(e){ if(!drag) return; drag=null; flush(); report(); focusMap(); });
 var rs=null;
 grip.addEventListener('pointerdown',function(e){ if(e.button!==0||locked) return; rs={sx:e.screenX,sy:e.screenY,w:G.w,h:G.h}; try{ grip.setPointerCapture(e.pointerId); }catch(err){} e.preventDefault(); e.stopPropagation(); });
 grip.addEventListener('pointermove',function(e){ if(!rs) return; var mw=B?B.x1-G.x:1e9, mh=B?B.y1-G.y:1e9; G.w=clampNum(rs.w+(e.screenX-rs.sx),MINW*Z,mw); G.h=clampNum(rs.h+(e.screenY-rs.sy),MINH*Z,mh); sched(); });
 grip.addEventListener('pointerup',function(e){ if(!rs) return; rs=null; flush(); report(); render(); focusMap(); });
 fold.addEventListener('click',function(){ var d=G.h-48*Z; if(!collapsed){ collapsed=true; G.y+=d; } else { collapsed=false; G.y=G.y-d; } clampG(); flush(); report(); topic({logpage:'fold',f:collapsed?1:0}); focusMap(); });
 lockBtn.addEventListener('click',function(){ locked=!locked; layout(); topic({logpage:'lock',l:locked?1:0}); focusMap(); });
 function tabList(){ if(adminMode()) return \['players','world','admin','logins']; return \['log','scenes','pinned']; }
 function tabLabel(t){ return t.toUpperCase(); }
 function buildTabs(){ var ts=tabList(), h=''; for(var i=0;i<ts.length;i++){ h+="<div class='tabw"+(ts\[i]===tab?' on':'')+"' data-t='"+ts\[i]+"' style='left:"+(16+i*86)+"px'>"+tabLabel(ts\[i])+"</div>"; } tabsEl.innerHTML=h; }
 tabsEl.addEventListener('click',function(e){ var t=e.target.closest('.tabw'); if(!t) return; setTab(t.getAttribute('data-t')); focusMap(); });
 function scopeFor(t){ if(!adminMode()) return 'self'; if(t==='players') return 'players'; return t; }
 function setTab(t){
  tab=t; sel=null; storyIdx=-1; record=null; closePops(); q=''; qIn.value=''; hits=\[]; hitIdx=-1; cntEl.textContent='';
  if(adminMode()){ view=(t==='admin'||t==='logins')?'table':'list'; role.scope=scopeFor(t); if(t!=='players') role.target=''; }
  else { view=(t==='scenes')?'scenes':(t==='pinned'?'pinned':'list'); }
  types={}; who=''; buildTabs(); buildChips(); layout();
  if(adminMode()&&(t==='players'||t==='world'||t==='admin'||t==='logins')) load(); else render();
 }
 function chipList(){ if(adminMode()&&tab==='admin') return \['ALL','BANS','EDITS','TELEPORT','WORLD','AHELP','CHAT']; if(adminMode()&&tab==='logins') return \['ALL','IN','OUT','ALTS']; return \['ALL','SAY','EMOTE','WHISPER','OOC','ROLLS','COMBAT']; }
 function anyType(){ for(var k in types) if(types\[k]) return true; return false; }
 function buildChips(){ var cs=chipList(), h=''; var none=!anyType(); for(var i=0;i<cs.length;i++){ var on=(cs\[i]==='ALL')?none:!!types\[cs\[i]]; h+="<div class='chip"+(on?' on':'')+"' data-c='"+cs\[i]+"' style='left:"+(i*67)+"px;width:62px'><div class='bg'></div><span>"+cs\[i]+"</span></div>"; } chipsEl.innerHTML=h; }
 chipsEl.addEventListener('click',function(e){ var c=e.target.closest('.chip'); if(!c) return; var k=c.getAttribute('data-c'); if(k==='ALL'){ types={}; } else { types\[k]=!types\[k]; } buildChips(); render(); focusMap(); });
 function typeOk(r){
  if(!anyType()) return true;
  if(adminMode()&&tab==='admin'){ for(var k in types){ if(types\[k]&&ACAT\[k]===r.cat) return true; } return false; }
  if(adminMode()&&tab==='logins'){ if(types.IN&&r.ev==='in') return true; if(types.OUT&&r.ev==='out') return true; if(types.ALTS&&r.r&&r.r.length) return true; return false; }
  for(var g in types){ if(types\[g]&&GROUPS\[g]&&GROUPS\[g]\[r.ty]) return true; }
  return false;
 }
 function setRole(lvl,me,name,target,scope,ts){
  role={lvl:+lvl,me:dec(me),name:dec(name),target:dec(target),scope:dec(scope),ts:+ts};
  if(adminMode()){ tab=(role.scope==='admin')?'admin':(role.scope==='logins'?'logins':(role.scope==='world'?'world':'players')); if(role.scope==='self') role.scope='players'; view=(tab==='admin'||tab==='logins')?'table':'list'; }
  else { tab='log'; role.scope='self'; role.target=role.me; view='list'; }
  if(!role.target) role.target=role.me;
  document.getElementById('tname').textContent=role.target===role.me?role.name:role.target;
  if(!day) day=todayLocal();
  buildTabs(); buildChips(); layout(); load(); requestDays();
 }
 function setTargets(s){ targets=\[]; var parts=(s||'').split(';'); for(var i=0;i<parts.length;i++){ var f=parts\[i].split('|'); if(f.length<2||!f\[0]) continue; targets.push({k:f\[0],n:dec(f\[1]),on:f\[2]==='1'}); } var t=findTarget(role.target); if(t) document.getElementById('tname').textContent=t.n; renderTargets(); }
 function findTarget(k){ for(var i=0;i<targets.length;i++) if(targets\[i].k===k) return targets\[i]; return null; }
 function targetName(){ if(role.target===role.me) return role.name; var t=findTarget(role.target); return t?t.n:role.target; }
 function load(){ if(!day) day=todayLocal(); closePops(); sel=null; topic({logpage:'load',day:day,tz:TZ,scope:role.scope,target:role.target}); dateT.textContent=dayLabel(day); if(!live&&!PREVIEW){ render(); } }
 function requestDays(){ var m=day.substring(0,7); calMonth=m; topic({logpage:'days',month:m,tz:TZ,scope:role.scope,target:role.target}); }
 function rowsBegin(req,n){ buf={req:+req,n:+n,rows:\[]}; }
 function rowsAdd(req,json){ if(!buf||buf.req!==+req) return; var arr=\[]; try{ arr=JSON.parse(json); }catch(e){ arr=\[]; } for(var i=0;i<arr.length;i++) buf.rows.push(arr\[i]); }
 function rowsEnd(req,d,scope,target,trunc,anchor){
  if(!buf||buf.req!==+req) return;
  rows=buf.rows; buf=null; truncated=(+trunc)?true:false; ctxAnchor=anchor?+anchor:0;
  if(d==='context'){ role.scope='world'; role.target=''; tab='world'; view='list'; buildTabs(); buildChips(); layout(); }
  else { if(d) day=dec(d); dateT.textContent=dayLabel(day); }
  expanded={}; hits=\[]; hitIdx=-1;
  render();
  if(ctxAnchor){ var el=log.querySelector("\[data-i='"+ctxAnchor+"']"); if(el){ el.classList.add('sel'); sel=ctxAnchor; el.scrollIntoView({block:'center'}); } }
  if(day===todayLocal()&&!ctxAnchor){ log.scrollTop=log.scrollHeight; }
  if(lastDays!==day.substring(0,7)+role.scope+role.target){ lastDays=day.substring(0,7)+role.scope+role.target; requestDays(); }
 }
 function rowsLive(json){ var arr=\[]; try{ arr=JSON.parse(json); }catch(e){ arr=\[]; } if(!arr.length) return; if(day!==todayLocal()) return; for(var i=0;i<arr.length;i++) rows.push(arr\[i]); var stick=(log.scrollTop+log.clientHeight>=log.scrollHeight-8); render(); if(stick) log.scrollTop=log.scrollHeight; }
 function setPins(csv){ pins={}; var p=(csv||'').split(','); for(var i=0;i<p.length;i++){ if(p\[i]) pins\[p\[i]]=true; } render(); }
 function setScenes(json){ try{ sceneNames=JSON.parse(json)||{}; }catch(e){ sceneNames={}; } render(); }
 function setDays(month,s){ if(dec(month)!==calMonth) return; dayCounts={}; var parts=(s||'').split(';'); for(var i=0;i<parts.length;i++){ var f=parts\[i].split(':'); if(f.length===2) dayCounts\[f\[0]]=+f\[1]; } if(document.getElementById('cal').style.display==='block') renderCal(); }
 function setFollow(on){ following=(+on)?true:false; document.getElementById('follow').classList.toggle('on',following); }
 function setAlerts(s){ alerts=(s||'').split('|').filter(function(x){ return x.length>0; }); renderAlerts(); }
 function setRecord(json){ try{ record=JSON.parse(json); }catch(e){ record=null; } view='record'; render(); }
 function setNotes(target,json){ if(!record) return; try{ record.notes=JSON.parse(json)||\[]; }catch(e){} if(view==='record') render(); }
 function exported(n,ext){ ctxEl.textContent='EXPORTED '+n+' LINES AS '+String(ext).toUpperCase(); }
 function meta(r){ if(r._me!==undefined) return r._me; var m=null; if(r.me){ try{ m=JSON.parse(r.me); }catch(e){ m=null; } } r._me=m; return m; }
 function plainOf(r){ var d=document.createElement('div'); d.innerHTML=cleanHtml(String(r.m||'')); return (d.textContent||'').replace(/ /g,' '); }
 function cleanHtml(h){ var out=''; for(var i=0;i<h.length;i++){ var c=h.charCodeAt(i); if(c>=32||c===10||c===9) out+=h.charAt(i); } return out; }
 var BAD_TAGS={script:1,style:1,iframe:1,object:1,embed:1,svg:1,link:1,meta:1,form:1,input:1,button:1,video:1,audio:1,source:1};
 function okPortrait(n){ var sv=n.getAttribute('src')||''; return n.className==='pt'&&sv.indexOf('pt_')===0&&sv.slice(-4)==='.png'&&sv.indexOf('/')<0&&sv.indexOf(':')<0&&sv.length<80; }
 function scrub(el){ var all=el.querySelectorAll('*'); for(var i=all.length-1;i>=0;i--){ var n=all\[i]; var t=n.tagName.toLowerCase(); if(BAD_TAGS\[t]||(t==='img'&&!okPortrait(n))){ n.parentNode.removeChild(n); continue; } for(var k=n.attributes.length-1;k>=0;k--){ var a=n.attributes\[k]; var an=a.name.toLowerCase(); if(an.indexOf('on')===0||an==='style'&&a.value.indexOf('url')>=0||(an==='href'&&a.value.trim().toLowerCase().indexOf('javascript')===0)){ n.removeAttribute(a.name); } } if(t==='a'){ var h=(n.getAttribute('href')||'').trim().toLowerCase(); if(h.indexOf('http://')!==0&&h.indexOf('https://')!==0) n.removeAttribute('href'); else n.setAttribute('target','_blank'); } } }
 function nameSpan(r){ var c=(r.c&&r.c.length>3)?r.c:'#eaf5ff'; var k=(isAdmin()&&keysOn&&r.k)?" <span class='k'>("+esc(r.k)+")</span>":''; return "<span style='color:"+esc(c)+"'>"+esc(r.n)+"</span>"+k; }
 function lineHtml(r){
  var m=meta(r), c=(r.c&&r.c.length>3)?r.c:'#eaf5ff', body=cleanHtml(String(r.m||''));
  var font=(r.f&&r.f.length)?" face='"+esc(r.f)+"'":'';
  switch(r.ty){
   case 'say': case 'yell': case 'ask': case 'looc': var noun=(m&&m.noun)?m.noun:'says:'; var b=(r.ty==='yell')?"<b>"+body+"</b>":body; return "<span style='color:"+esc(c)+"'>"+esc(r.n)+keyTag(r)+" "+esc(noun)+" <font"+font+">"+b+"</font></span>";
   case 'whisper': if(r.mu) return "<span class='mu'><span style='color:"+esc(c)+"'>"+esc(r.n)+"</span>"+keyTag(r)+" whispers something.</span>"; return "<span style='color:"+esc(c)+"'>"+esc(r.n)+keyTag(r)+" whispers: <i>"+body+"</i></span>";
   case 'think': return "<span style='color:"+esc(c)+"'><i>"+esc(r.n)+"</i>"+keyTag(r)+" thinks: "+body+"</span>";
   case 'ooc': return "<span class='oc'>OOC:</span> <span style='color:"+esc(c)+"'>"+esc((m&&m.key)?m.key:r.n)+"</span>"+keyTag(r)+": "+body;
   case 'emote': return "<font"+font+">"+body+"</font>";
   case 'roll': return body;
   case 'combat': return "<span class='tag'>"+body+"</span>";
   case 'hit': return "<span class='hit'>"+body+"</span>";
   case 'kill': case 'death': case 'maim': return "<span class='sys'><span class='tag'>"+r.ty.toUpperCase()+"</span> "+body+"</span>";
   case 'announce': return "<span class='sys'><span class='tag'>ANNOUNCE</span> "+body+"</span>";
   case 'narrate': return "<i><span class='mu'>"+esc(r.n)+":</span> "+body+"</i>";
   default: return "<span class='sys'>"+body+"</span>";
  }
 }
 function keyTag(r){ return (isAdmin()&&keysOn&&r.k)?" <span class='k'>("+esc(r.k)+")</span>":''; }
 function charsPerLine(){ var w=log.clientWidth-8-48-70; return Math.max(20,Math.floor(w/6)); }
 function estRows(r){ var p=plainOf(r); var brs=(String(r.m||'').match(/<br/gi)||\[]).length; return Math.ceil(p.length/charsPerLine())+brs; }
 function visibleRows(){ var out=\[]; for(var i=0;i<rows.length;i++){ var r=rows\[i]; if(!typeOk(r)) continue; if(who&&r.n!==who) continue; if(view==='pinned'&&!pins\[String(r.i)]) continue; out.push(r); } return out; }
 function tmin(lt){ if(!lt||lt.length<16) return 0; return (+lt.substring(11,13))*60+(+lt.substring(14,16)); }
 function scenesOf(list){
  var sc=\[], cur=null;
  for(var i=0;i<list.length;i++){
   var r=list\[i]; var t=tmin(r.lt); var a=r.a||'';
   var brk=false;
   if(!cur) brk=true; else { if(t-cur.last>20) brk=true; else if(a&&cur.area&&a!==cur.area) brk=true; }
   if(brk){ cur={key:String(r.i),area:a,from:r.lt,to:r.lt,first:t,last:t,names:{},order:\[],rows:\[]}; sc.push(cur); }
   if(!cur.area&&a) cur.area=a;
   cur.rows.push(r); cur.last=t; cur.to=r.lt;
   if(r.n&&CHAT\[r.ty]&&!cur.names\[r.n]){ cur.names\[r.n]=1; cur.order.push(r.n); }
  }
  return sc;
 }
 function sceneTitle(s){ var nm=sceneNames\[s.key]; if(nm) return nm; return (s.area||'UNKNOWN PLACE').toUpperCase(); }
 function rosterHtml(s,max){ var h='', n=s.order.length, shown=Math.min(max,n); for(var i=0;i<shown;i++){ h+=(i?', ':'')+"<i data-n='"+esc(s.order\[i])+"'>"+esc(s.order\[i])+"</i>"; } if(n>shown) h+="  <i data-more='"+esc(s.key)+"'>+"+(n-shown)+"</i>"; return h; }
 function rowHtml(r){
  var p=(r.p&&IC\[r.ty]&&okName(r.p)); var pinned=pins\[String(r.i)]; var long=estRows(r)>6&&!expanded\[String(r.i)];
  var inner=lineHtml(r);
  var h="<div class='row"+(p?' pt':'')+(pinned?' pin':'')+(sel===r.i?' sel':'')+"' data-i='"+r.i+"'"+(long?" data-long='1'":'')+"><div class='pl'></div>";
  if(p) h+="<img class='pt' src='"+esc(r.p)+"' alt=''>";
  h+="<div class='tx'><span class='tm'>"+esc(hm(r.lt))+"</span><span class='st'></span>"+inner+"</div></div>";
  return h;
 }
 function okName(v){ return v.indexOf('pt_')===0&&v.slice(-4)==='.png'&&v.indexOf('/')<0&&v.indexOf(':')<0&&v.length<80; }
 function clipLong(el){
  var rowsEl=el.querySelectorAll('.row\[data-long]');
  for(var i=0;i<rowsEl.length;i++){
   var rw=rowsEl\[i]; var tx=rw.querySelector('.tx'); if(!tx) continue;
   var maxH=6*16+4; if(tx.offsetHeight<=maxH+8) continue;
   tx.style.maxHeight=maxH+'px'; tx.style.overflow='hidden';
   var r=rowById(+rw.getAttribute('data-i')); var words=plainOf(r).split(' ').filter(function(x){ return x.length>0; }).length;
   var more=document.createElement('div'); more.className='more'; more.setAttribute('data-x',rw.getAttribute('data-i')); more.innerHTML="<div class='bg'></div><span>SHOW ALL  "+words.toLocaleString()+" WORDS</span>";
   rw.appendChild(more);
  }
 }
 function rowById(i){ for(var k=0;k<rows.length;k++) if(rows\[k].i===i) return rows\[k]; return null; }
 function render(){
  var h='';
  if(view==='record'){ log.innerHTML=recordHtml(); footer(); band(); return; }
  if(view==='table'){ log.innerHTML=tableHtml(); footer(); band(); return; }
  var list=visibleRows();
  if(view==='story'){ log.innerHTML=storyHtml(list); footer(); band(); return; }
  var sc=scenesOf(list);
  if(view==='scenes'){ log.innerHTML=cardsHtml(sc); footer(); band(); return; }
  if(!list.length){ log.innerHTML="<div class='empty'>"+(rows.length?'nothing matches the current filters':'no lines on this day')+"</div>"; footer(); band(); return; }
  for(var s=0;s<sc.length;s++){
   var S=sc\[s];
   if(view==='list') h+="<div class='sh' data-k='"+esc(S.key)+"'><img src='lc_car_d.png' alt=''><span class='rs'>"+rosterHtml(S,3)+"</span>"+esc(sceneTitle(S))+"   <span class='sp'>"+esc(hm(S.from))+" - "+esc(hm(S.to))+"</span></div>";
   for(var i=0;i<S.rows.length;i++) h+=rowHtml(S.rows\[i]);
  }
  log.innerHTML=h;
  var els=log.querySelectorAll('.row .tx'); for(var e=0;e<els.length;e++) scrub(els\[e]);
  clipLong(log);
  applySearch();
  footer(); band();
 }
 function cardsHtml(sc){
  if(!sc.length) return "<div class='empty'>no scenes on this day</div>";
  var h='';
  for(var i=0;i<sc.length;i++){ var S=sc\[i]; var ic=0; for(var k=0;k<S.rows.length;k++) if(IC\[S.rows\[k].ty]) ic++;
   h+="<div class='card' data-k='"+esc(S.key)+"'><div class='ti'>"+esc(sceneTitle(S))+" <span class='sp'>"+esc(hm(S.from))+" - "+esc(hm(S.to))+"</span></div><div class='rs'>"+rosterHtml(S,12)+"</div><div class='cn'>"+S.rows.length+" lines, "+ic+" in character</div><div class='acts'><div class='chip' data-a='open' style='left:0;width:58px'><div class='bg'></div><span>OPEN</span></div><div class='chip' data-a='story' style='left:64px;width:58px'><div class='bg'></div><span>STORY</span></div><div class='chip' data-a='name' style='left:128px;width:58px'><div class='bg'></div><span>NAME</span></div></div></div>";
  }
  return h;
 }
 function storyHtml(list){
  var sc=scenesOf(list); var S=null; for(var i=0;i<sc.length;i++) if(sc\[i].key===String(storyIdx)) S=sc\[i];
  if(!S) return "<div class='empty'>that scene is no longer on this day</div>";
  var h="<div class='story'><p><span class='who'>"+esc(sceneTitle(S))+"</span> <span class='sp' style='color:#8aa2c8'>"+esc(hm(S.from))+" - "+esc(hm(S.to))+"</span></p>";
  for(var k=0;k<S.rows.length;k++){ var r=S.rows\[k]; if(!IC\[r.ty]||r.mu) continue; h+="<p>"+lineHtml(r)+"</p>"; }
  h+="</div>";
  var d=document.createElement('div'); d.innerHTML=h; scrub(d); return d.innerHTML;
 }
 function tableHtml(){
  var list=\[]; for(var i=0;i<rows.length;i++){ var r=rows\[i]; if(!typeOk(r)) continue; if(q&&!tableMatch(r)) continue; list.push(r); }
  if(!list.length) return "<div class='empty'>"+(rows.length?'nothing matches the current filters':'no entries on this day')+"</div>";
  var h='', W=log.clientWidth-8;
  if(tab==='admin'){
   h+="<div class='th'><span class='c' style='left:0'>TIME</span><span class='c' style='left:42px'>ADMIN</span><span class='c' style='left:114px'>ACTION</span><span class='c' style='left:"+Math.max(312,W-160)+"px'>DETAIL</span></div>";
   for(var a=0;a<list.length;a++){ var r=list\[a]; var sev=(r.cat==='bans'); var det=r.tg&&r.tg.length?r.tg+(r.d&&r.d.length?' '+r.d:''):(r.d||''); var dl=Math.max(312,W-160);
    h+="<div class='tr"+(sel===r.i?' sel':'')+"' data-i='"+r.i+"'><div class='pl'></div><span class='c t' style='left:0;width:36px'>"+esc(hm(r.lt))+"</span><span class='c a' style='left:42px;width:66px'>"+esc(r.n||r.k)+"</span><span class='c"+(sev?' sev':'')+"' style='left:114px;width:"+(dl-120)+"px'>"+esc(stripTags(r.ac))+"</span><span class='c d' style='left:"+dl+"px;right:0'>"+esc(stripTags(det))+"</span></div>";
   }
  } else {
   h+="<div class='th'><span class='c' style='left:0'>TIME</span><span class='c' style='left:42px'>KEY</span><span class='c' style='left:190px'>EVENT</span><span class='c' style='left:232px'>IP</span><span class='c' style='left:340px'>CID</span></div>";
   for(var b=0;b<list.length;b++){ var r2=list\[b];
    h+="<div class='tr"+(sel===r2.i?' sel':'')+"' data-i='"+r2.i+"' title='"+esc(r2.r||'')+"'><div class='pl'></div><span class='c t' style='left:0;width:36px'>"+esc(hm(r2.lt))+"</span><span class='c a' style='left:42px;width:142px'>"+esc(r2.k)+"</span><span class='c' style='left:190px;width:36px'>"+esc(r2.ev)+"</span><span class='c d' style='left:232px;width:102px'>"+esc(r2.ip)+"</span><span class='c d' style='left:340px;right:0'>"+esc(r2.cid)+(r2.r&&r2.r.length?" <span class='sev'>ALT?</span>":'')+"</span></div>";
   }
  }
  return h;
 }
 function stripTags(s){ var d=document.createElement('div'); d.innerHTML=cleanHtml(String(s||'')); return d.textContent||''; }
 function tableMatch(r){ var s=(r.n+' '+r.k+' '+(r.ac||'')+' '+(r.tg||'')+' '+(r.d||'')+' '+(r.ip||'')+' '+(r.cid||'')+' '+(r.ev||'')+' '+(r.r||'')).toLowerCase(); return s.indexOf(q.toLowerCase())>=0; }
 function recordHtml(){
  if(!record) return "<div class='empty'>no record loaded</div>";
  var h="<div class='sub'><div class='hd'>"+esc(record.n||record.k)+" <span style='color:#8aa2c8'>("+esc(record.k)+")</span></div>";
  h+="<div class='kv'><span class='k'>Lines on record</span><span class='v'>"+(+record.total||0).toLocaleString()+"</span></div>";
  h+="<div class='kv'><span class='k'>First seen</span><span class='v'>"+esc(record.first||'-')+"</span></div>";
  h+="<div class='kv'><span class='k'>Last seen</span><span class='v'>"+esc(record.last||'-')+"</span></div></div>";
  h+="<div class='sub'><div class='hd'>ACTIVITY, LAST 14 DAYS</div>";
  var days=record.days||\[]; if(!days.length) h+="<div class='kv'><span class='k'>none</span></div>"; for(var i=0;i<days.length;i++) h+="<div class='kv'><span class='k'>"+esc(dayLabel(days\[i].d))+"</span><span class='v'>"+days\[i].c+"</span></div>";
  h+="</div><div class='sub'><div class='hd'>MOST OFTEN WITH, LAST 30 DAYS</div>";
  var ps=record.partners||\[]; if(!ps.length) h+="<div class='kv'><span class='k'>none</span></div>"; for(var p=0;p<ps.length;p++) h+="<div class='kv'><span class='k'>"+esc(ps\[p].k)+"</span><span class='v'>"+ps\[p].c+"</span></div>";
  h+="</div>";
  var hrs=record.hours||\[]; if(hrs.length){ h+="<div class='sub'><div class='hd'>ACTIVE HOURS, LAST 30 DAYS</div>"; var mx=1; for(var x=0;x<hrs.length;x++) mx=Math.max(mx,+hrs\[x].c); for(var y=0;y<hrs.length;y++){ var bar=''; var n=Math.round(10*hrs\[y].c/mx); for(var z=0;z<n;z++) bar+='#'; h+="<div class='kv'><span class='k'>"+esc(hrs\[y].h)+":00</span><span class='v' style='color:#7ec8f0'>"+bar+"</span></div>"; } h+="</div>"; }
  var pun=record.pun||\[]; h+="<div class='sub'><div class='hd'>PUNISHMENTS</div>"; if(!pun.length) h+="<div class='kv'><span class='k'>none on file</span></div>"; for(var u=0;u<pun.length;u++) h+="<div class='note'><span class='sev' style='color:#e4635e'>"+esc(pun\[u].p)+"</span> by "+esc(pun\[u].by)+" "+esc(pun\[u].d)+" <span class='by'>"+esc(pun\[u].t)+"</span><br>"+esc(pun\[u].r)+"</div>"; h+="</div>";
  if(record.logins){ var lg=record.logins; h+="<div class='sub'><div class='hd'>LOGINS"+(record.alts&&record.alts.length?" <span style='color:#e4635e'>shares IP or CID with "+esc(record.alts.join(', '))+"</span>":'')+"</div>"; if(!lg.length) h+="<div class='kv'><span class='k'>none</span></div>"; for(var l=0;l<lg.length;l++) h+="<div class='kv'><span class='k'>"+esc(lg\[l].lt)+" "+esc(lg\[l].ev)+"</span><span class='v' style='color:#a9c4e6'>"+esc(lg\[l].ip)+" / "+esc(lg\[l].cid)+"</span></div>"; h+="</div>"; }
  var ns=record.notes||\[]; h+="<div class='sub'><div class='hd'>NOTES</div>"; if(!ns.length) h+="<div class='kv'><span class='k'>no notes yet</span></div>"; for(var m=0;m<ns.length;m++) h+="<div class='note'><span class='by'>"+esc(ns\[m].lt)+" "+esc(ns\[m].by)+(ns\[m].e?" on line "+esc(ns\[m].e):'')+"</span><br>"+esc(ns\[m].b)+"</div>"; h+="</div>";
  return h;
 }
 function footer(){
  var n=0, scn=0; if(view==='table'){ n=rows.length; } else { var list=visibleRows(); n=list.length; scn=scenesOf(list).length; }
  var tzs='UTC'+(TZ>=0?'+':'')+(TZ/60);
  var h="<span>"+esc(dayLabel(day))+"</span>";
  if(adminMode()&&tab==='players') h="<span>"+esc(targetName()).toUpperCase()+"</span><span class='dv'></span>"+h;
  h+="<span class='dv'></span>"+n.toLocaleString()+"<span class='k'> "+(view==='table'?(tab==='admin'?'ACTIONS':'LOGINS'):'LINES')+"</span>";
  if(view!=='table') h+="<span class='dv'></span>"+scn+"<span class='k'> SCENES</span>";
  if(anyType()){ var c=0; for(var k in types) if(types\[k]) c++; h+="<span class='dv'></span>"+c+" / "+(chipList().length-1)+"<span class='k'> TYPES</span>"; }
  if(hits.length) h+="<span class='dv'></span>"+(hitIdx+1)+" / "+hits.length+"<span class='k'> HITS</span>";
  if(truncated) h+="<span class='dv'></span><span style='color:#e4635e'>TRUNCATED</span>";
  h+="<span class='dv'></span>"+tzs;
  foott.innerHTML=h;
 }
 function band(){
  var chips=\[], label='';
  var r=sel?rowById(sel):null;
  if(view==='story'){ label='STORY'; chips=\['BACK']; }
  else if(view==='record'){ label='RECORD'; chips=\['BACK','ADD NOTE']; }
  else if(view==='scenes'){ label='SCENES'; chips=\[]; }
  else if(view==='table'){ label=r?'ROW '+hm(r.lt):'NO ROW'; chips=r?\['COPY']:\[]; }
  else { label=r?'LINE '+hm(r.lt):'NO LINE'; if(r){ if(isAdmin()){ chips=\['CONTEXT','NOTE',pins\[String(r.i)]?'UNPIN':'PIN','COPY']; } else { chips=\[pins\[String(r.i)]?'UNPIN':'PIN','QUOTE','COPY']; } } }
  if(adminMode()&&(tab==='world'||tab==='players')&&view==='list') chips.push('ALERTS');
  ctxEl.textContent=label;
  var h=''; for(var i=0;i<chips.length;i++) h+="<div class='chip' data-b='"+chips\[i]+"'><div class='bg'></div><span>"+chips\[i]+"</span></div>";
  bchips.innerHTML=h; bchips.style.left=(ctxEl.offsetWidth+12)+'px';
  document.getElementById('export').style.display=(view==='table'||view==='record')?'none':'block';
 }
 log.addEventListener('click',function(e){
  var more=e.target.closest('.more'); if(more){ expanded\[more.getAttribute('data-x')]=true; render(); return; }
  var nm=e.target.closest('.rs i'); if(nm){ var mk=nm.getAttribute('data-more'); if(mk){ var S=null, sc=scenesOf(visibleRows()); for(var i=0;i<sc.length;i++) if(sc\[i].key===mk) S=sc\[i]; if(S){ nm.parentNode.innerHTML=rosterHtml(S,999); } return; } var n=nm.getAttribute('data-n'); who=(who===n)?'':n; render(); return; }
  var act=e.target.closest('.card .chip'); if(act){ var card=act.closest('.card'); var key=card.getAttribute('data-k'); var a=act.getAttribute('data-a'); if(a==='open'){ view='list'; tab=adminMode()?tab:'log'; buildTabs(); render(); var sh=log.querySelector(".sh\[data-k='"+key+"']"); if(sh) sh.scrollIntoView(); } else if(a==='story'){ storyIdx=+key; view='story'; render(); } else if(a==='name'){ openNote('SCENE NAME',sceneNames\[key]||'',function(v){ topic({logpage:'scene',k:key,title:v}); }); } return; }
  var sh=e.target.closest('.sh'); if(sh){ var k2=sh.getAttribute('data-k'); var hide=sh.classList.toggle('closed'); var n2=sh.nextElementSibling; while(n2&&!n2.classList.contains('sh')){ n2.style.display=hide?'none':''; n2=n2.nextElementSibling; } sh.querySelector('img').src=hide?'lc_car_r.png':'lc_car_d.png'; return; }
  var row=e.target.closest('.row,.tr'); if(row){ var id=+row.getAttribute('data-i'); sel=(sel===id)?null:id; var all=log.querySelectorAll('.row.sel,.tr.sel'); for(var z=0;z<all.length;z++) all\[z].classList.remove('sel'); if(sel!==null) row.classList.add('sel'); band(); }
 });
 bchips.addEventListener('click',function(e){
  var c=e.target.closest('.chip'); if(!c) return; var b=c.getAttribute('data-b'); var r=sel?rowById(sel):null;
  if(b==='BACK'){ view=(adminMode()?((tab==='admin'||tab==='logins')?'table':'list'):(tab==='scenes'?'scenes':(tab==='pinned'?'pinned':'list'))); record=null; storyIdx=-1; render(); return; }
  if(b==='PIN'||b==='UNPIN'){ if(!r) return; var on=(b==='PIN'); if(on) pins\[String(r.i)]=true; else delete pins\[String(r.i)]; topic({logpage:'pin',i:r.i,on:on?1:0}); render(); return; }
  if(b==='COPY'){ if(!r) return; copyText(view==='table'?tableLine(r):plainLine(r)); ctxEl.textContent='COPIED'; return; }
  if(b==='QUOTE'){ if(!r) return; copyText('> '+plainLine(r)); ctxEl.textContent='QUOTED TO CLIPBOARD'; return; }
  if(b==='CONTEXT'){ if(!r) return; topic({logpage:'context',i:r.i}); return; }
  if(b==='NOTE'){ if(!r) return; openNote('NOTE ON '+(r.n||r.k),'',function(v){ topic({logpage:'note',target:isAdmin()?(role.scope==='world'?(r.k||''):role.target):role.me,e:r.i,s:'note',body:v}); }); return; }
  if(b==='ADD NOTE'){ openNote('NOTE ON '+(record?record.k:''),'',function(v){ topic({logpage:'note',target:record?record.k:role.target,e:0,s:'note',body:v}); }); return; }
  if(b==='ALERTS'){ openPop('apop',bandEl.offsetLeft+2,bandEl.offsetTop-150); topic({logpage:'alerts',op:'list'}); return; }
 });
 function plainLine(r){ var m=meta(r); var b=plainOf(r); switch(r.ty){ case 'say': case 'yell': case 'ask': case 'looc': return r.n+' '+((m&&m.noun)?m.noun:'says:')+' '+b; case 'whisper': return r.mu?(r.n+' whispers something.'):(r.n+' whispers: '+b); case 'think': return r.n+' thinks: '+b; case 'ooc': return 'OOC '+r.n+': '+b; default: return b; } }
 function tableLine(r){ if(tab==='admin') return hm(r.lt)+' '+(r.n||r.k)+' '+stripTags(r.ac)+' '+stripTags(r.tg||'')+' '+stripTags(r.d||''); return hm(r.lt)+' '+r.k+' '+r.ev+' '+r.ip+' '+r.cid+' '+(r.r||''); }
 function copyText(t){ try{ if(navigator.clipboard&&navigator.clipboard.writeText){ navigator.clipboard.writeText(t); return; } }catch(e){} var ta=document.createElement('textarea'); ta.value=t; ta.style.position='absolute'; ta.style.left='-1000px'; document.body.appendChild(ta); ta.select(); try{ document.execCommand('copy'); }catch(e){} document.body.removeChild(ta); }
 var noteCb=null;
 function openNote(title,initial,cb){ noteCb=cb; document.getElementById('nhd').textContent=title; document.getElementById('ntext').value=initial||''; openPop('npop',60,120); setTimeout(function(){ document.getElementById('ntext').focus(); },30); }
 document.getElementById('nsave').addEventListener('click',function(){ var v=document.getElementById('ntext').value.trim(); closePops(); if(noteCb) noteCb(v); noteCb=null; focusMap(); });
 document.getElementById('ncancel').addEventListener('click',function(){ closePops(); noteCb=null; focusMap(); });
 function openPop(id,x,y){ closePops(); var p=document.getElementById(id); p.style.left=x+'px'; p.style.top=y+'px'; p.style.display='block'; }
 function closePops(){ var ps=document.getElementsByClassName('pop'); for(var i=0;i<ps.length;i++) ps\[i].style.display='none'; }
 document.addEventListener('pointerdown',function(e){ if(e.target.closest('.pop')||e.target.closest('#date')||e.target.closest('#tsel')||e.target.closest('#export')||e.target.closest('#bchips')) return; closePops(); });
 document.getElementById('date').addEventListener('click',function(){ var c=document.getElementById('cal'); if(c.style.display==='block'){ closePops(); return; } calMonth=day.substring(0,7); openPop('cal',nav.offsetLeft+36,nav.offsetTop+32); renderCal(); topic({logpage:'days',month:calMonth,tz:TZ,scope:role.scope,target:role.target}); });
 function renderCal(){
  var p=calMonth.split('-'); var y=+p\[0], m=+p\[1]; var M=\['JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER'];
  document.getElementById('calt').textContent=M\[m-1]+' '+y;
  var first=new Date(y,m-1,1).getDay(), dim=new Date(y,m,0).getDate(), today=todayLocal(), h='', cell=0;
  h+="<div class='cd'>"; for(var b=0;b<first;b++){ h+="<span></span>"; cell++; }
  for(var d=1;d<=dim;d++){ var ds=y+'-'+pad2(m)+'-'+pad2(d); var has=dayCounts\[ds]>0; var cls=(has?'has':'no')+(ds===today?' today':'')+(ds===day?' selday':''); h+="<span class='"+cls+"' data-d='"+ds+"' title='"+(has?dayCounts\[ds]+' lines':'')+"'>"+d+"</span>"; cell++; if(cell%7===0) h+="</div><div class='cd'>"; }
  h+="</div>";
  document.getElementById('calg').innerHTML=h;
 }
 document.getElementById('calg').addEventListener('click',function(e){ var s=e.target.closest('span\[data-d]'); if(!s) return; day=s.getAttribute('data-d'); closePops(); load(); focusMap(); });
 document.getElementById('calp').addEventListener('click',function(){ var p=calMonth.split('-'); var y=+p\[0], m=+p\[1]-1; if(m<1){ m=12; y--; } calMonth=y+'-'+pad2(m); dayCounts={}; renderCal(); topic({logpage:'days',month:calMonth,tz:TZ,scope:role.scope,target:role.target}); });
 document.getElementById('caln').addEventListener('click',function(){ var p=calMonth.split('-'); var y=+p\[0], m=+p\[1]+1; if(m>12){ m=1; y++; } calMonth=y+'-'+pad2(m); dayCounts={}; renderCal(); topic({logpage:'days',month:calMonth,tz:TZ,scope:role.scope,target:role.target}); });
 document.getElementById('prev').addEventListener('click',function(){ day=shiftDay(day,-1); load(); focusMap(); });
 document.getElementById('next').addEventListener('click',function(){ if(day>=todayLocal()) return; day=shiftDay(day,1); load(); focusMap(); });
 document.getElementById('tsel').addEventListener('click',function(){ if(!adminMode()) return; var t=document.getElementById('tpop'); if(t.style.display==='block'){ closePops(); return; } openPop('tpop',trow.offsetLeft+42,trow.offsetTop+28); document.getElementById('tpop').style.width=(document.getElementById('tsel').offsetWidth)+'px'; renderTargets(); topic({logpage:'targets'}); setTimeout(function(){ document.getElementById('tq').focus(); },30); });
 function renderTargets(){ var f=document.getElementById('tq').value.toLowerCase(); var h='', n=0; for(var i=0;i<targets.length&&n<9;i++){ var t=targets\[i]; if(f&&t.n.toLowerCase().indexOf(f)<0&&t.k.indexOf(f)<0) continue; n++; h+="<div class='dr"+(t.k===role.target?' sel':'')+"' data-k='"+esc(t.k)+"'><div class='pl'></div><span>"+esc(t.n)+"</span><span class='cat'>"+(t.on?'ONLINE':esc(t.k))+"</span></div>"; } if(!n) h="<div class='dr hint'>no names match</div>"; document.getElementById('tlist').innerHTML=h; }
 document.getElementById('tq').addEventListener('input',renderTargets);
 document.getElementById('tlist').addEventListener('pointerdown',function(e){ var r=e.target.closest('.dr'); if(!r||r.classList.contains('hint')) return; role.target=r.getAttribute('data-k'); role.scope='players'; document.getElementById('tname').textContent=targetName(); closePops(); load(); e.preventDefault(); });
 document.getElementById('keys').addEventListener('click',function(){ keysOn=!keysOn; document.getElementById('keys').classList.toggle('on',keysOn); render(); focusMap(); });
 document.getElementById('follow').addEventListener('click',function(){ topic({logpage:'follow',on:following?0:1}); focusMap(); });
 document.getElementById('record').addEventListener('click',function(){ if(view==='record'){ view='list'; record=null; render(); return; } topic({logpage:'record',target:role.target}); });
 document.getElementById('export').addEventListener('click',function(){ var x=document.getElementById('xpop'); if(x.style.display==='block'){ closePops(); return; } var fm=\[\['txt','TEXT FILE'],\['html','HTML PAGE'],\['md','MARKDOWN']]; var h=''; for(var i=0;i<fm.length;i++) h+="<div class='dr' data-f='"+fm\[i]\[0]+"'><div class='pl'></div><span>"+fm\[i]\[1]+"</span><span class='cat'>."+fm\[i]\[0]+"</span></div>"; document.getElementById('xlist').innerHTML=h; openPop('xpop',bandEl.offsetLeft+bandEl.offsetWidth-160,bandEl.offsetTop-72); document.getElementById('xpop').style.width='160px'; });
 document.getElementById('xlist').addEventListener('pointerdown',function(e){ var r=e.target.closest('.dr'); if(!r) return; var f=r.getAttribute('data-f'); closePops(); var tl=\[]; for(var k in types) if(types\[k]&&GROUPS\[k]) for(var t in GROUPS\[k]) tl.push(t); topic({logpage:'export',fmt:f,day:day,tz:TZ,scope:role.scope,target:role.target,types:tl.length?tl.join(','):'all',who:who,q:q}); ctxEl.textContent='EXPORTING...'; e.preventDefault(); });
 function renderAlerts(){ var h=''; for(var i=0;i<alerts.length;i++) h+="<div class='dr' data-w='"+esc(alerts\[i])+"'><div class='pl'></div><span>"+esc(alerts\[i])+"</span><span class='cat'>REMOVE</span></div>"; if(!h) h="<div class='dr hint'>no alert words yet</div>"; document.getElementById('alist').innerHTML=h; }
 document.getElementById('alist').addEventListener('pointerdown',function(e){ var r=e.target.closest('.dr'); if(!r||r.classList.contains('hint')) return; topic({logpage:'alerts',op:'remove',word:r.getAttribute('data-w')}); e.preventDefault(); });
 document.getElementById('aadd').addEventListener('click',function(){ var v=document.getElementById('aq').value.trim(); if(!v) return; document.getElementById('aq').value=''; topic({logpage:'alerts',op:'add',word:v}); });
 document.getElementById('aclose').addEventListener('click',function(){ closePops(); focusMap(); });
 function applySearch(){
  hits=\[]; var old=log.querySelectorAll('.hl'); for(var i=0;i<old.length;i++){ var o=old\[i]; var p=o.parentNode; while(o.firstChild) p.insertBefore(o.firstChild,o); p.removeChild(o); p.normalize(); }
  if(!q){ cntEl.textContent=''; return; }
  var ql=q.toLowerCase(); var walker=document.createTreeWalker(log,NodeFilter.SHOW_TEXT,null,false); var nodes=\[]; var n;
  while((n=walker.nextNode())){ if(n.parentNode.closest('.tm,.sh,.more')) continue; if(n.nodeValue.toLowerCase().indexOf(ql)>=0) nodes.push(n); }
  for(var k=0;k<nodes.length;k++){ var tn=nodes\[k]; var txt=tn.nodeValue; var low=txt.toLowerCase(); var pos=0, idx; var frag=document.createDocumentFragment();
   while((idx=low.indexOf(ql,pos))>=0){ if(idx>pos) frag.appendChild(document.createTextNode(txt.substring(pos,idx))); var sp=document.createElement('span'); sp.className='hl'; sp.textContent=txt.substr(idx,q.length); frag.appendChild(sp); hits.push(sp); pos=idx+q.length; }
   if(pos<txt.length) frag.appendChild(document.createTextNode(txt.substring(pos)));
   tn.parentNode.replaceChild(frag,tn);
  }
  if(hitIdx>=hits.length) hitIdx=hits.length?0:-1;
  if(hits.length&&hitIdx<0) hitIdx=0;
  markHit();
 }
 function markHit(){ for(var i=0;i<hits.length;i++) hits\[i].classList.toggle('cur',i===hitIdx); cntEl.textContent=hits.length?((hitIdx+1)+' / '+hits.length):(q?'0 / 0':''); if(hitIdx>=0&&hits\[hitIdx]){ var row=hits\[hitIdx].closest('.row'); if(row&&row.getAttribute('data-long')){ expanded\[row.getAttribute('data-i')]=true; } hits\[hitIdx].scrollIntoView({block:'center'}); } footer(); }
 function stepHit(d){ if(!hits.length) return; hitIdx=(hitIdx+d+hits.length)%hits.length; markHit(); }
 var qTimer=null;
 qIn.addEventListener('input',function(){ q=qIn.value; if(qTimer) clearTimeout(qTimer); qTimer=setTimeout(function(){ hitIdx=-1; if(view==='table') render(); else applySearch(); footer(); },120); });
 qIn.addEventListener('keydown',function(e){ if(e.key==='Enter'){ stepHit(e.shiftKey?-1:1); e.preventDefault(); } else if(e.key==='Escape'){ qIn.value=''; q=''; applySearch(); qIn.blur(); focusMap(); e.preventDefault(); } });
 document.getElementById('sup').addEventListener('click',function(){ stepHit(-1); });
 document.getElementById('sdn').addEventListener('click',function(){ stepHit(1); });
 document.addEventListener('keydown',function(e){ if(e.ctrlKey&&(e.key==='f'||e.key==='F')){ qIn.focus(); qIn.select(); e.preventDefault(); } else if(e.key==='Escape'&&document.activeElement===document.body){ closePops(); } });
 log.addEventListener('pointerup',function(){ var s=window.getSelection?window.getSelection().toString():''; if(s==='') focusMap(); });
 document.addEventListener('contextmenu',function(e){ e.preventDefault(); });
 function boot(){ live=true; layout(); topic({logpage:'ready'}); }
 if(window.BYOND){ boot(); } else { window.addEventListener('byond-ready',boot); }
 if(PREVIEW){
  day=todayLocal();
  setRole(0,'valdiel','Valdiel','valdiel','self',0);
  var T=day+' ';
  rows=\[
   {i:1,t:'',lt:T+'20:14:10',ty:'say',n:'Valdiel',c:'#eaf5ff',f:'',p:'',a:'Kame House',m:"The gate's shut again. Anyone have the key?",me:'',mu:0},
   {i:2,t:'',lt:T+'20:15:02',ty:'whisper',n:'Seraphine',c:'#f2c87e',f:'',p:'',a:'Kame House',m:"don't tell him about the merchant.",me:'',mu:0},
   {i:3,t:'',lt:T+'20:16:40',ty:'ooc',n:'Kaidos',c:'#eaf5ff',f:'',p:'',a:'Kame House',m:'brb, client restart',me:'',mu:0},
   {i:4,t:'',lt:T+'20:18:05',ty:'combat',n:'Kaidos',c:'#eaf5ff',f:'',p:'',a:'Kame House',m:"<font color='#7ec8f0'>Kaidos froze Seraphine solid with Snowgrave.</font>",me:'',mu:0},
   {i:5,t:'',lt:T+'20:19:30',ty:'emote',n:'Seraphine',c:'#f0fa33',f:'',p:'',a:'Kame House',m:"<font color='#f2c87e'>*Seraphine<font color='#f6dfae'> draws the frost from her sleeves with two slow passes of her hand, the crystals scattering across the flagstones like spilled salt. She does not look at the gate. She looks at the sky above it, where the last of the light is thinning into a bruise of violet and iron, and for a long moment she says nothing at all.<br><br>When she finally moves it is to kneel, one knee to the cold stone, and press her palm flat against the ground. The tremor is faint, a rumour of a tremor, but she has learned to trust rumours. Somewhere under the arena the old channels are waking, and the merchant's cart was not the only thing that left at dusk.<br><br>She rises. The frost has already begun to creep back along her wrists, patient as ever, and she lets it. We are not late, she says, though her voice carries none of the certainty of the words. We are exactly where they wanted us to be.</font>*</font>",me:'',mu:0},
   {i:6,t:'',lt:T+'20:21:12',ty:'say',n:'Kaidos',c:'#eaf5ff',f:'',p:'',a:'Kame House',m:"The merchant left at dusk. We're late, and the guards saw us.",me:'',mu:0},
   {i:7,t:'',lt:T+'20:22:00',ty:'roll',n:'Kaidos',c:'#eaf5ff',f:'',p:'',a:'Kame House',m:"<b><font color=red>DICE:</b></font> Kaidos rolled 17 (1d20).",me:'',mu:0},
   {i:8,t:'',lt:T+'22:05:00',ty:'say',n:'Valdiel',c:'#eaf5ff',f:'',p:'',a:'Training Grounds',m:'Again. From the top.',me:'',mu:0},
   {i:9,t:'',lt:T+'22:06:30',ty:'whisper',n:'Kaidos',c:'#eaf5ff',f:'',p:'',a:'Training Grounds',m:'',me:'',mu:1}
  ];
  pins={'2':true};
  setTimeout(function(){ if(!live){ setGeom(12,262,992,840,2,0.85,0,0,4000,3000,0,0); render(); } },300);
 }
 </script></body></html>
"}

client/proc/LogPageBoot()
	if(logpage_booted) return
	logpage_booted = 1
	if(prefs)
		var/g = getPref("logGeom")
		if(istext(g) && length(g)) logpage_geom = g
		logpage_lock = getPref("logLock") ? 1 : 0
		logpage_fold = getPref("logFold") ? 1 : 0

client/proc/LogPageLevel()
	if(!mob) return 0
	return mob.Admin ? mob.Admin : 0

client/proc/LogPageMayView(scope, target)
	if(!mob) return 0
	var/lvl = LogPageLevel()
	switch(scope)
		if("self") return 1
		if("players") return (target == mob.ckey) || lvl >= 3
		if("world") return lvl >= 3
		if("admin") return lvl >= 3
		if("logins") return lvl >= 4
	return 0

client/proc/LogPagePlace()
	var/list/r = PanelViewRect()
	if(!r) return
	var/x0 = r[1]
	var/y0 = r[2]
	var/x1 = r[3]
	var/y1 = r[4]
	var/z = r[5]
	logpage_zoom = z
	logpage_x0 = x0
	logpage_y0 = y0
	var/vw = x1 - x0
	var/vh = y1 - y0
	var/x
	var/y
	var/w
	var/h
	if(logpage_geom)
		var/list/g = splittext(logpage_geom, ",")
		if(g.len == 4)
			var/gx = text2num(g[1]); var/gy = text2num(g[2]); var/gw = text2num(g[3]); var/gh = text2num(g[4])
			if(!isnull(gx) && !isnull(gy) && gw > 0 && gh > 0)
				x = x0 + round(gx * z); y = y0 + round(gy * z); w = round(gw * z); h = round(gh * z)
	if(!w || !h)
		w = 496 * z
		h = 420 * z
		x = x0 + 6 * z
		y = y1 - h - 84 * z
	if(w > vw) w = vw
	if(h > vh) h = vh
	if(x + w > x1) x = x1 - w
	if(y + h > y1) y = y1 - h
	if(x < x0) x = x0
	if(y < y0) y = y0
	logpage_geom = "[(x - x0) / z],[(y - y0) / z],[w / z],[h / z]"
	winset(src, LOGPAGE_CTL, "pos=[x],[y];size=[w]x[h]")
	src << output(list2params(list(x, y, w, h, z, chatpanel_opacity, x0, y0, x1, y1, logpage_lock, logpage_fold)), "[LOGPAGE_CTL]:setGeom")

client/proc/LogPageStoreGeom(gtext)
	var/list/g = splittext(gtext, ",")
	if(g.len != 4) return
	var/x = text2num(g[1]); var/y = text2num(g[2]); var/w = text2num(g[3]); var/h = text2num(g[4])
	if(isnull(x) || isnull(y) || !(w > 0) || !(h > 0)) return
	var/z = logpage_zoom ? logpage_zoom : 1
	logpage_geom = "[(x - logpage_x0) / z],[(y - logpage_y0) / z],[w / z],[h / z]"
	setPref("logGeom", logpage_geom)

client/proc/LogPageShow(target, scope)
	if(!mob) return
	LogPageBoot()
	LogPageSendAssets()
	var/lvl = LogPageLevel()
	if(target) target = ckey(target)
	if(!scope) scope = (target && target != mob.ckey) ? "players" : "self"
	if(scope == "players" && lvl < 3 && target && target != mob.ckey) target = null
	if(!target && (scope == "self" || scope == "players")) target = mob.ckey
	if(!LogPageMayView(scope, target))
		scope = "self"
		target = mob.ckey
	logpage_scope = scope
	logpage_target = target
	winset(src, LOGPAGE_CTL, "inner-background-color=transparent")
	src << browse(LogPageHTML(), "window=[LOGPAGE_CTL]")
	logpage_open = 1
	LogPagePlace()
	winset(src, LOGPAGE_CTL, "is-visible=true")

client/proc/LogPageHide()
	logpage_open = 0
	logpage_follow = 0
	logdb_followers -= src
	winset(src, LOGPAGE_CTL, "is-visible=false")

client/proc/LogPageToggle()
	if(logpage_open) LogPageHide()
	else LogPageShow()

client/proc/LogPageRole()
	if(!mob) return
	src << output(list2params(list(LogPageLevel(), mob.ckey, mob.name, logpage_target ? logpage_target : mob.ckey, logpage_scope, mob.Timestamp ? 1 : 0)), "[LOGPAGE_CTL]:setRole")

client/proc/LogPageTargets()
	if(!mob || LogPageLevel() < 3) return
	var/list/seen = list()
	var/list/out = list()
	for(var/mob/Players/P in players)
		if(!P.client || !P.ckey) continue
		seen[P.ckey] = 1
		out += "[P.ckey]|[url_encode("[P.name]")]|1"
	if(LogDbOpen())
		var/database/query/q = new
		if(LogDbExec(q, "SELECT actor, name, max(id) AS m FROM events WHERE actor != '' AND t >= date('now','-60 days') GROUP BY actor ORDER BY m DESC LIMIT 200"))
			while(q.NextRow())
				var/list/row = q.GetRowData()
				var/ck = "[row["actor"]]"
				if(seen[ck]) continue
				seen[ck] = 1
				out += "[ck]|[url_encode("[row["name"]]")]|0"
	src << output(list2params(list(jointext(out, ";"))), "[LOGPAGE_CTL]:setTargets")

proc/LogDbTzMod(tz)
	var/m = isnull(tz) ? 0 : round(tz)
	return "[m >= 0 ? "+" : ""][m] minutes"

client/proc/LogPageSendPortrait(pt)
	if(!pt || pt == "") return
	if(!logpage_pts) logpage_pts = list()
	if(logpage_pts[pt]) return
	var/path = "[LOGDB_PORTRAITS][pt]"
	if(!fexists(path)) return
	logpage_pts[pt] = 1
	src << browse_rsc(file(path), pt)

client/proc/LogPageRowJson(list/row, admin)
	var/list/j = list()
	j["i"] = row["id"]
	j["t"] = row["t"]
	j["lt"] = row["lt"]
	j["ty"] = row["ty"]
	j["n"] = row["name"]
	j["c"] = row["color"]
	j["f"] = row["font"]
	j["p"] = row["pt"]
	j["a"] = row["area"]
	var/body = row["body"]
	if(!admin && row["ty"] == "legacy" && length(row["sbody"])) body = row["sbody"]
	j["m"] = body
	j["me"] = row["meta"]
	j["mu"] = row["mu"] ? 1 : 0
	if(admin)
		j["k"] = row["actor"]
		j["x"] = row["x"]
		j["y"] = row["y"]
		j["z"] = row["z"]
	return j

client/proc/LogPageQueryEvents(scope, target, from, upto, tz, cap)
	var/list/rows = list()
	var/database/query/q = new
	var/mod = LogDbTzMod(tz)
	var/ok
	if(scope == "world")
		ok = LogDbExec(q, "SELECT e.id, e.t, datetime(e.t, ?) AS lt, e.ty, e.actor, e.name, e.color, e.font, e.pt, e.z, e.x, e.y, e.area, e.body, e.sbody, e.meta, 0 AS mu FROM events e WHERE e.t >= ? AND e.t < ? ORDER BY e.id LIMIT ?", mod, from, upto, cap)
	else
		ok = LogDbExec(q, "SELECT e.id, e.t, datetime(e.t, ?) AS lt, e.ty, e.actor, e.name, e.color, e.font, e.pt, e.z, e.x, e.y, e.area, e.body, e.sbody, e.meta, w.muffled AS mu FROM events e LEFT JOIN witness w ON w.event_id = e.id AND w.ckey = ? WHERE e.t >= ? AND e.t < ? AND (e.actor = ? OR w.ckey IS NOT NULL) ORDER BY e.id LIMIT ?", mod, target, from, upto, target, cap)
	if(ok)
		while(q.NextRow())
			rows += list(q.GetRowData())
	return rows

client/proc/LogPageLoad(day, tz, scope, target)
	if(!mob) return
	tz = text2num(tz)
	if(isnull(tz)) tz = 0
	logpage_tz = tz
	if(!scope || scope == "") scope = "self"
	if(scope == "self" || scope == "players")
		if(!target || target == "") target = mob.ckey
		target = ckey(target)
	else
		target = null
	if(!LogPageMayView(scope, target))
		scope = "self"
		target = mob.ckey
	logpage_scope = scope
	logpage_target = target
	if(!LogDbOpen()) return
	var/list/rng = LogDbLocalDayRange(day, tz)
	if(!rng) return
	var/from = rng[1]
	var/upto = rng[2]
	logpage_req++
	var/req = logpage_req
	var/admin = (LogPageLevel() >= 3) && scope != "self"
	var/mod = LogDbTzMod(tz)
	var/list/out = list()
	var/database/query/q = new
	var/truncated = 0
	switch(scope)
		if("self", "players", "world")
			var/list/rows = LogPageQueryEvents(scope, target, from, upto, tz, LOGDB_ROW_CAP + 1)
			if(rows.len > LOGDB_ROW_CAP)
				truncated = 1
				rows.Cut(LOGDB_ROW_CAP + 1)
			for(var/list/row in rows)
				if(row["pt"] && row["pt"] != "") LogPageSendPortrait(row["pt"])
				out += list(LogPageRowJson(row, admin))
		if("admin")
			var/lvl = LogPageLevel()
			var/ok
			if(lvl >= 4) ok = LogDbExec(q, "SELECT id, t, datetime(t, ?) AS lt, actor, name, level, category, action, target, detail FROM admin_actions WHERE t >= ? AND t < ? ORDER BY id LIMIT ?", mod, from, upto, LOGDB_ROW_CAP)
			else ok = LogDbExec(q, "SELECT id, t, datetime(t, ?) AS lt, actor, name, level, category, action, target, detail FROM admin_actions WHERE t >= ? AND t < ? AND level < 4 ORDER BY id LIMIT ?", mod, from, upto, LOGDB_ROW_CAP)
			if(ok)
				while(q.NextRow())
					var/list/row = q.GetRowData()
					out += list(list("i" = row["id"], "t" = row["t"], "lt" = row["lt"], "k" = row["actor"], "n" = row["name"], "lv" = row["level"], "cat" = row["category"], "ac" = row["action"], "tg" = row["target"], "d" = row["detail"]))
		if("logins")
			if(LogDbExec(q, "SELECT id, t, datetime(t, ?) AS lt, ckey, name, ip, cid, ev, reason FROM logins WHERE t >= ? AND t < ? ORDER BY id LIMIT ?", mod, from, upto, LOGDB_ROW_CAP))
				while(q.NextRow())
					var/list/row = q.GetRowData()
					out += list(list("i" = row["id"], "t" = row["t"], "lt" = row["lt"], "k" = row["ckey"], "n" = row["name"], "ip" = row["ip"], "cid" = row["cid"], "ev" = row["ev"], "r" = row["reason"]))
	src << output(list2params(list(req, out.len)), "[LOGPAGE_CTL]:rowsBegin")
	var/i = 1
	while(i <= out.len)
		var/j = min(i + LOGPAGE_CHUNK - 1, out.len)
		var/list/chunk = out.Copy(i, j + 1)
		src << output(list2params(list(req, json_encode(chunk))), "[LOGPAGE_CTL]:rowsAdd")
		i = j + 1
	LogPagePins()
	LogPageScenes()
	src << output(list2params(list(req, day, scope, target ? target : "", truncated)), "[LOGPAGE_CTL]:rowsEnd")

client/proc/LogPagePins()
	if(!mob || !LogDbOpen()) return
	var/database/query/q = new
	var/list/ids = list()
	if(LogDbExec(q, "SELECT event_id FROM pins WHERE ckey=? ORDER BY event_id", mob.ckey))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			ids += "[row["event_id"]]"
	src << output(list2params(list(jointext(ids, ","))), "[LOGPAGE_CTL]:setPins")

client/proc/LogPageScenes()
	if(!mob || !LogDbOpen()) return
	var/database/query/q = new
	var/list/out = list()
	if(LogDbExec(q, "SELECT skey, title FROM scenes WHERE ckey=?", mob.ckey))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			out[row["skey"]] = row["title"]
	src << output(list2params(list(json_encode(out))), "[LOGPAGE_CTL]:setScenes")

client/proc/LogPagePin(id, on)
	if(!mob || !LogDbOpen()) return
	id = text2num(id)
	if(!id) return
	var/database/query/q = new
	if(text2num(on)) LogDbExec(q, "INSERT OR REPLACE INTO pins (ckey, event_id, t) VALUES (?,?,datetime('now'))", mob.ckey, id)
	else LogDbExec(q, "DELETE FROM pins WHERE ckey=? AND event_id=?", mob.ckey, id)
	LogPagePins()

client/proc/LogPageScene(skey, title)
	if(!mob || !LogDbOpen()) return
	if(!skey || skey == "") return
	title = html_encode(copytext("[title]", 1, 80))
	var/database/query/q = new
	if(length(title)) LogDbExec(q, "INSERT OR REPLACE INTO scenes (ckey, skey, title) VALUES (?,?,?)", mob.ckey, skey, title)
	else LogDbExec(q, "DELETE FROM scenes WHERE ckey=? AND skey=?", mob.ckey, skey)
	LogPageScenes()

client/proc/LogPageDays(month, tz, scope, target)
	if(!mob || !LogDbOpen()) return
	tz = text2num(tz)
	if(isnull(tz)) tz = 0
	var/list/p = splittext("[month]", "-")
	if(p.len < 2) return
	var/y = text2num(p[1]); var/m = text2num(p[2])
	if(isnull(y) || isnull(m)) return
	var/ny = y; var/nm = m + 1
	if(nm > 12)
		nm = 1
		ny++
	var/list/r1 = LogDbLocalDayRange("[y]-[m < 10 ? "0" : ""][m]-01", tz)
	var/list/r2 = LogDbLocalDayRange("[ny]-[nm < 10 ? "0" : ""][nm]-01", tz)
	if(!r1 || !r2) return
	var/from = r1[1]
	var/upto = r2[1]
	if(scope == "self" || scope == "players")
		if(!target || target == "") target = mob.ckey
		target = ckey(target)
	if(!LogPageMayView(scope, target)) return
	var/mod = LogDbTzMod(tz)
	var/database/query/q = new
	var/ok
	switch(scope)
		if("self", "players")
			ok = LogDbExec(q, "SELECT substr(datetime(e.t, ?),1,10) AS d, count(*) AS c FROM events e LEFT JOIN witness w ON w.event_id = e.id AND w.ckey = ? WHERE e.t >= ? AND e.t < ? AND (e.actor = ? OR w.ckey IS NOT NULL) GROUP BY d", mod, target, from, upto, target)
		if("world")
			ok = LogDbExec(q, "SELECT substr(datetime(t, ?),1,10) AS d, count(*) AS c FROM events WHERE t >= ? AND t < ? GROUP BY d", mod, from, upto)
		if("admin")
			ok = LogDbExec(q, "SELECT substr(datetime(t, ?),1,10) AS d, count(*) AS c FROM admin_actions WHERE t >= ? AND t < ? GROUP BY d", mod, from, upto)
		if("logins")
			ok = LogDbExec(q, "SELECT substr(datetime(t, ?),1,10) AS d, count(*) AS c FROM logins WHERE t >= ? AND t < ? GROUP BY d", mod, from, upto)
	var/list/out = list()
	if(ok)
		while(q.NextRow())
			var/list/row = q.GetRowData()
			out += "[row["d"]]:[row["c"]]"
	src << output(list2params(list(month, jointext(out, ";"))), "[LOGPAGE_CTL]:setDays")

client/proc/LogPageNotes(target)
	if(!mob || LogPageLevel() < 3 || !LogDbOpen()) return
	target = ckey(target)
	var/database/query/q = new
	var/list/out = list()
	if(LogDbExec(q, "SELECT id, t, datetime(t, ?) AS lt, admin, event_id, severity, body FROM notes WHERE ckey=? ORDER BY id DESC LIMIT 100", LogDbTzMod(logpage_tz), target))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			out += list(list("i" = row["id"], "lt" = row["lt"], "by" = row["admin"], "e" = row["event_id"], "s" = row["severity"], "b" = row["body"]))
	src << output(list2params(list(target, json_encode(out))), "[LOGPAGE_CTL]:setNotes")

client/proc/LogPageNoteAdd(target, event_id, severity, body)
	if(!mob || LogPageLevel() < 3 || !LogDbOpen()) return
	target = ckey(target)
	body = html_encode(copytext("[body]", 1, 2000))
	if(!length(body)) return
	var/database/query/q = new
	LogDbExec(q, "INSERT INTO notes (t, admin, ckey, event_id, severity, body) VALUES (datetime('now'),?,?,?,?,?)", mob.ckey, target, text2num(event_id) ? text2num(event_id) : 0, severity ? severity : "note", body)
	LogAdminAction(mob, "other", "added a note on [target]", target, copytext(body, 1, 120))
	LogPageNotes(target)

client/proc/LogPageRecord(target)
	if(!mob || LogPageLevel() < 3 || !LogDbOpen()) return
	target = ckey(target)
	var/mod = LogDbTzMod(logpage_tz)
	var/database/query/q = new
	var/list/rec = list()
	rec["k"] = target
	rec["n"] = target
	var/list/days = list()
	if(LogDbExec(q, "SELECT substr(datetime(t, ?),1,10) AS d, count(*) AS c FROM events WHERE actor=? AND t >= date('now','-14 days') GROUP BY d ORDER BY d", mod, target))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			days += list(list("d" = row["d"], "c" = row["c"]))
	rec["days"] = days
	var/list/partners = list()
	if(LogDbExec(q, "SELECT w.ckey AS k, count(*) AS c FROM events e JOIN witness w ON w.event_id = e.id WHERE e.actor=? AND w.ckey != ? AND e.t >= date('now','-30 days') GROUP BY w.ckey ORDER BY c DESC LIMIT 6", target, target))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			partners += list(list("k" = row["k"], "c" = row["c"]))
	rec["partners"] = partners
	var/list/hours = list()
	if(LogDbExec(q, "SELECT substr(datetime(t, ?),12,2) AS h, count(*) AS c FROM events WHERE actor=? AND t >= date('now','-30 days') GROUP BY h ORDER BY h", mod, target))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			hours += list(list("h" = row["h"], "c" = row["c"]))
	rec["hours"] = hours
	if(LogDbExec(q, "SELECT count(*) AS c, min(t) AS f, max(t) AS l FROM events WHERE actor=?", target) && q.NextRow())
		var/list/row = q.GetRowData()
		rec["total"] = row["c"]
		rec["first"] = row["f"]
		rec["last"] = row["l"]
	if(LogDbExec(q, "SELECT name FROM events WHERE actor=? ORDER BY id DESC LIMIT 1", target) && q.NextRow())
		var/list/row = q.GetRowData()
		rec["n"] = row["name"]
	var/list/logins = list()
	if(LogPageLevel() >= 4)
		if(LogDbExec(q, "SELECT datetime(t, ?) AS lt, ip, cid, ev, reason FROM logins WHERE ckey=? ORDER BY id DESC LIMIT 20", mod, target))
			while(q.NextRow())
				var/list/row = q.GetRowData()
				logins += list(list("lt" = row["lt"], "ip" = row["ip"], "cid" = row["cid"], "ev" = row["ev"], "r" = row["reason"]))
		var/list/alts = list()
		if(LogDbExec(q, "SELECT DISTINCT l2.ckey AS k FROM logins l1 JOIN logins l2 ON (l1.ip = l2.ip OR l1.cid = l2.cid) WHERE l1.ckey=? AND l2.ckey != ? LIMIT 20", target, target))
			while(q.NextRow())
				var/list/row = q.GetRowData()
				alts += "[row["k"]]"
		rec["alts"] = alts
	rec["logins"] = logins
	var/list/pun = list()
	if(Punishments)
		for(var/list/z in Punishments)
			if(!islist(z)) continue
			if(ckey("[z["Key"]]") != target) continue
			pun += list(list("p" = "[z["Punishment"]]", "by" = "[z["User"]]", "r" = "[z["Reason"]]", "d" = "[z["Duration"]]", "t" = "[z["Time"]]"))
	rec["pun"] = pun
	var/list/notes = list()
	if(LogDbExec(q, "SELECT id, datetime(t, ?) AS lt, admin, event_id, severity, body FROM notes WHERE ckey=? ORDER BY id DESC LIMIT 100", mod, target))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			notes += list(list("i" = row["id"], "lt" = row["lt"], "by" = row["admin"], "e" = row["event_id"], "s" = row["severity"], "b" = row["body"]))
	rec["notes"] = notes
	src << output(list2params(list(json_encode(rec))), "[LOGPAGE_CTL]:setRecord")

client/proc/LogPageContext(id)
	if(!mob || LogPageLevel() < 3 || !LogDbOpen()) return
	id = text2num(id)
	if(!id) return
	var/database/query/q = new
	var/t = null
	if(LogDbExec(q, "SELECT t FROM events WHERE id=?", id) && q.NextRow())
		var/list/row = q.GetRowData()
		t = row["t"]
	if(!t) return
	var/from = null
	var/upto = null
	if(LogDbExec(q, "SELECT datetime(?, '-5 minutes') AS f, datetime(?, '+5 minutes') AS t", t, t) && q.NextRow())
		var/list/row = q.GetRowData()
		from = row["f"]
		upto = row["t"]
	if(!from || !upto) return
	logpage_scope = "world"
	logpage_target = null
	logpage_req++
	var/req = logpage_req
	var/list/rows = LogPageQueryEvents("world", null, from, upto, logpage_tz, LOGDB_ROW_CAP)
	var/list/out = list()
	for(var/list/row in rows)
		if(row["pt"] && row["pt"] != "") LogPageSendPortrait(row["pt"])
		out += list(LogPageRowJson(row, 1))
	src << output(list2params(list(req, out.len)), "[LOGPAGE_CTL]:rowsBegin")
	var/i = 1
	while(i <= out.len)
		var/j = min(i + LOGPAGE_CHUNK - 1, out.len)
		src << output(list2params(list(req, json_encode(out.Copy(i, j + 1)))), "[LOGPAGE_CTL]:rowsAdd")
		i = j + 1
	src << output(list2params(list(req, "context", "world", "", 0, id)), "[LOGPAGE_CTL]:rowsEnd")

client/proc/LogPageFollow(on)
	if(!mob) return
	on = text2num(on) ? 1 : 0
	if(on && LogPageLevel() < 3 && logpage_scope != "self") on = 0
	logpage_follow = on
	if(on)
		if(!(src in logdb_followers)) logdb_followers += src
	else
		logdb_followers -= src
	src << output(list2params(list(on)), "[LOGPAGE_CTL]:setFollow")

client/proc/LogPageLivePush(list/batch)
	if(!mob || !logpage_open || !logpage_follow) return
	var/scope = logpage_scope
	if(!(scope == "self" || scope == "players" || scope == "world")) return
	var/target = logpage_target
	var/admin = (LogPageLevel() >= 3) && scope != "self"
	var/list/out = list()
	var/database/query/q = new
	var/mod = LogDbTzMod(logpage_tz)
	for(var/list/r in batch)
		if(r["table"] != "events" || !r["id"]) continue
		if(scope != "world")
			var/list/wit = r["wit"]
			if(r["actor"] != target && !(islist(wit) && !isnull(wit[target]))) continue
		var/list/row = null
		if(LogDbExec(q, "SELECT e.id, e.t, datetime(e.t, ?) AS lt, e.ty, e.actor, e.name, e.color, e.font, e.pt, e.z, e.x, e.y, e.area, e.body, e.sbody, e.meta FROM events e WHERE e.id=?", mod, r["id"]) && q.NextRow())
			row = q.GetRowData()
		if(!row) continue
		var/list/wit2 = r["wit"]
		row["mu"] = (scope != "world" && islist(wit2) && wit2[target]) ? 1 : 0
		if(row["pt"] && row["pt"] != "") LogPageSendPortrait(row["pt"])
		out += list(LogPageRowJson(row, admin))
	if(out.len)
		src << output(list2params(list(json_encode(out))), "[LOGPAGE_CTL]:rowsLive")

client/proc/LogPageAlerts(op, word)
	if(!mob || LogPageLevel() < 3) return
	if(op == "add") LogDbAlertAdd(word, mob)
	else if(op == "remove") LogDbAlertRemove(word)
	else LogDbOpen()
	src << output(list2params(list(jointext(logdb_alert_words, "|"))), "[LOGPAGE_CTL]:setAlerts")

client/proc/LogPageLineText(list/r, fmt)
	var/ty = "[r["ty"]]"
	var/name = "[r["n"]]"
	var/body = "[r["m"]]"
	var/list/me = null
	if(r["me"] && r["me"] != "")
		me = json_decode(r["me"])
	var/plain = LogDbStripTags(body)
	var/noun = (islist(me) && me["noun"]) ? "[me["noun"]]" : "says:"
	var/color = (r["c"] && r["c"] != "") ? "[r["c"]]" : "#eaf5ff"
	switch(fmt)
		if("html")
			switch(ty)
				if("say", "yell", "ask", "looc") return "<span style='color:[color]'>[name]</span> <span class=v>[noun]</span> [body]"
				if("whisper") return r["mu"] ? "<span class=d><span style='color:[color]'>[name]</span> whispers something.</span>" : "<span style='color:[color]'>[name]</span> <span class=v>whispers:</span> <i>[body]</i>"
				if("think") return "<i><span style='color:[color]'>[name]</span> thinks:</i> [body]"
				if("ooc") return "<span class=o>OOC:</span> <span style='color:[color]'>[name]</span>: [body]"
				if("emote") return body
				if("hit") return "<span class=h>[body]</span>"
				if("announce") return "<span class=s>ANNOUNCE</span> [body]"
				if("narrate") return "<i><span class=d>[name]:</span> [body]</i>"
				else return "<span class=s>[body]</span>"
		if("md")
			switch(ty)
				if("say", "yell", "ask", "looc") return "**[name]** [noun] [plain]"
				if("whisper") return r["mu"] ? "*[name] whispers something.*" : "**[name]** whispers: *[plain]*"
				if("think") return "*[name] thinks:* [plain]"
				if("ooc") return "OOC **[name]**: [plain]"
				if("emote") return "> *[plain]*"
				if("announce") return "**ANNOUNCE** [plain]"
				else return plain
		else
			switch(ty)
				if("say", "yell", "ask", "looc") return "[name] [noun] [plain]"
				if("whisper") return r["mu"] ? "[name] whispers something." : "[name] whispers: [plain]"
				if("think") return "[name] thinks: [plain]"
				if("ooc") return "OOC [name]: [plain]"
				if("announce") return "ANNOUNCE: [plain]"
				else return plain

client/proc/LogPageExport(fmt, day, tz, scope, target, types, who, q)
	if(!mob) return
	tz = text2num(tz)
	if(isnull(tz)) tz = 0
	if(!scope || scope == "") scope = "self"
	if(scope == "self" || scope == "players")
		if(!target || target == "") target = mob.ckey
		target = ckey(target)
	else
		target = null
	if(scope == "admin" || scope == "logins") return
	if(!LogPageMayView(scope, target))
		scope = "self"
		target = mob.ckey
	if(!LogDbOpen()) return
	var/list/rng = LogDbLocalDayRange(day, tz)
	if(!rng) return
	var/admin = (LogPageLevel() >= 3) && scope != "self"
	var/list/rows = LogPageQueryEvents(scope, target, rng[1], rng[2], tz, LOGDB_ROW_CAP)
	var/list/tyset = null
	if(types && types != "" && types != "all")
		tyset = splittext(types, ",")
	var/whol = (who && who != "") ? lowertext(who) : null
	var/ql = (q && q != "") ? lowertext(q) : null
	if(fmt != "html" && fmt != "md") fmt = "txt"
	var/list/lines = list()
	var/label = (scope == "world") ? "World" : ((target == mob.ckey) ? "[mob.name]" : target)
	if(fmt == "html")
		lines += "<!DOCTYPE html><html><head><meta charset='utf-8'><title>[label] [day]</title><style>body{background:#0c1828;color:#eaf5ff;font:15px/1.45 'Segoe UI',sans-serif;padding:18px 24px;max-width:960px;margin:0 auto}h1{font-size:18px;color:#bfe6ff;margin:0 0 4px 0}.sub{color:#8aa2c8;margin-bottom:14px}.l{padding:3px 0;border-bottom:1px solid #16243a}.t{color:#8aa2c8;display:inline-block;width:56px;font-variant-numeric:tabular-nums}.v{color:#7ec8f0}.o{color:#5fe08a}.h{color:#5c7e9a}.s{color:#b8b8d9}.d{color:#8aa2c8}.a{color:#8aa2c8;font-size:12px;margin-left:8px}font{font-family:inherit}</style></head><body><h1>[html_encode(label)] - [day]</h1><div class='sub'>Exported from ClassicBlunder2 logs. Times are local (UTC[tz >= 0 ? "+" : ""][round(tz / 60)]).</div>"
	else if(fmt == "md")
		lines += "# [label] - [day]"
		lines += ""
	else
		lines += "[label] - [day]"
		lines += ""
	var/n = 0
	for(var/list/row in rows)
		var/list/j = LogPageRowJson(row, admin)
		if(tyset && !("[j["ty"]]" in tyset)) continue
		if(whol && lowertext("[j["n"]]") != whol) continue
		var/text = LogPageLineText(j, fmt)
		if(ql && !findtext(lowertext(LogDbStripTags("[j["n"]] [j["m"]]")), ql)) continue
		var/lt = "[j["lt"]]"
		var/hm = length(lt) >= 16 ? copytext(lt, 12, 17) : lt
		n++
		if(fmt == "html")
			lines += "<div class='l'><span class='t'>[hm]</span>[text][(j["a"] && j["a"] != "") ? "<span class='a'>[html_encode("[j["a"]]")]</span>" : ""]</div>"
		else if(fmt == "md")
			lines += "**[hm]** [text]"
		else
			lines += "\[[hm]\] [text]"
	if(fmt == "html") lines += "</body></html>"
	var/ext = (fmt == "html") ? "html" : ((fmt == "md") ? "md" : "txt")
	var/stamp = "[world.time]"
	var/path = "[LOGDB_EXPORTS][mob.ckey]_[stamp].[ext]"
	fdel(path)
	text2file(jointext(lines, "\n"), path)
	var/safe = ckey(label)
	if(!length(safe)) safe = "log"
	src << ftp(file(path), "[safe]_[day].[ext]")
	src << output(list2params(list(n, ext)), "[LOGPAGE_CTL]:exported")
	spawn(6000) fdel(path)

client/proc/LogPageTopic(list/href_list)
	switch(href_list["logpage"])
		if("ready")
			LogPagePlace()
			LogPageRole()
			if(LogPageLevel() >= 3) LogPageTargets()
		if("geom")
			LogPageStoreGeom(href_list["g"])
		if("lock")
			logpage_lock = text2num(href_list["l"]) ? 1 : 0
			setPref("logLock", logpage_lock)
		if("fold")
			logpage_fold = text2num(href_list["f"]) ? 1 : 0
			setPref("logFold", logpage_fold)
		if("load")
			LogPageLoad(href_list["day"], href_list["tz"], href_list["scope"], href_list["target"])
		if("days")
			LogPageDays(href_list["month"], href_list["tz"], href_list["scope"], href_list["target"])
		if("pin")
			LogPagePin(href_list["i"], href_list["on"])
		if("scene")
			LogPageScene(href_list["k"], href_list["title"])
		if("notes")
			LogPageNotes(href_list["target"])
		if("note")
			LogPageNoteAdd(href_list["target"], href_list["e"], href_list["s"], href_list["body"])
		if("record")
			LogPageRecord(href_list["target"])
		if("context")
			LogPageContext(href_list["i"])
		if("follow")
			LogPageFollow(href_list["on"])
		if("targets")
			LogPageTargets()
		if("alerts")
			LogPageAlerts(href_list["op"], href_list["word"])
		if("export")
			LogPageExport(href_list["fmt"], href_list["day"], href_list["tz"], href_list["scope"], href_list["target"], href_list["types"], href_list["who"], href_list["q"])
		if("close")
			LogPageHide()

mob/Players/verb/LogPage_Open()
	set name = "Logs"
	set category = "Roleplay"
	set hidden = 1
	client?.LogPageToggle()

mob/Players/verb/LogPage_Reset()
	set name = "Logs Reset Position"
	set category = "Utility"
	if(!client) return
	client.logpage_geom = null
	client.logpage_fold = 0
	client.setPref("logGeom", null)
	client.setPref("logFold", 0)
	if(client.logpage_open) client.LogPageShow(client.logpage_target, client.logpage_scope)
