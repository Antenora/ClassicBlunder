#define RPBOX_CTL "mapwindow.rpoverlay"

client/var/rpbox_open = 0
client/var/rpbox_geom = null
client/var/rpbox_lock = 0
client/var/rpbox_fold = 0
client/var/rpbox_zoom = 1
client/var/rpbox_x0 = 0
client/var/rpbox_y0 = 0
client/var/rpbox_booted = 0
client/var/rpbox_mode = "wysiwyg"
client/var/rpbox_keep = 0
client/var/rpbox_third = 0
client/var/rpbox_slot = 0
client/var/rpbox_colors = ""
client/var/list/rpbox_drafts
client/var/list/rpbox_history
client/var/list/rpbox_snippets
client/var/rpbox_last_send = 0

var/list/RP_ALLOWED_TAGS = list("b", "i", "u", "s", "strike", "em", "strong", "br", "center", "font", "a", "div")
var/list/RP_FONT_IDS = list("crimson", "cinzel", "caveat", "elite", "fraktur", "gotham", "pixel")
mob/var/RPFont = ""

mob/proc/RPFontWrap(body)
	if(!istext(body) || !length(body)) return body
	if(!istext(RPFont) || !length(RPFont) || !(RPFont in RP_FONT_IDS)) return body
	var/pre = ""
	if(findtext(body, "//") == 1 || findtext(body, "||") == 1)
		pre = copytext(body, 1, 3)
		body = copytext(body, 3)
	return "[pre]<font face=[RPFont]>[body]</font>"

proc/RPTagName(t, start)
	var/n = ""
	var/i = start
	while(i <= length(t))
		var/c = copytext(t, i, i + 1)
		if((c >= "a" && c <= "z") || (c >= "A" && c <= "Z"))
			n += c
			i++
		else
			break
	return lowertext(n)

proc/RPValidColor(c)
	if(!istext(c) || !length(c) || length(c) > 20) return 0
	if(copytext(c, 1, 2) == "#")
		var/hex = copytext(c, 2)
		if(length(hex) != 3 && length(hex) != 6) return 0
		for(var/i = 1, i <= length(hex), i++)
			if(!findtext("0123456789abcdef", lowertext(copytext(hex, i, i + 1)))) return 0
		return 1
	for(var/i = 1, i <= length(c), i++)
		var/ch = lowertext(copytext(c, i, i + 1))
		if(ch < "a" || ch > "z") return 0
	return 1

proc/RPAttr(tagtext, name)
	var/p = findtext(lowertext(tagtext), name)
	if(!p) return null
	var/i = p + length(name)
	while(i <= length(tagtext) && copytext(tagtext, i, i + 1) == " ") i++
	if(copytext(tagtext, i, i + 1) != "=") return null
	i++
	while(i <= length(tagtext) && copytext(tagtext, i, i + 1) == " ") i++
	var/q = copytext(tagtext, i, i + 1)
	var/val = ""
	if(q == "\"" || q == "'")
		i++
		while(i <= length(tagtext) && copytext(tagtext, i, i + 1) != q)
			val += copytext(tagtext, i, i + 1)
			i++
	else
		while(i <= length(tagtext))
			var/c = copytext(tagtext, i, i + 1)
			if(c == " " || c == ">" || c == "/") break
			val += c
			i++
	return val

proc/RPSanitize(t)
	if(!istext(t)) return ""
	var/out = ""
	var/pos = 1
	var/L = length(t)
	while(pos <= L)
		var/lt = findtext(t, "<", pos, 0)
		if(!lt)
			out += copytext(t, pos)
			break
		out += copytext(t, pos, lt)
		var/gt = findtext(t, ">", lt, 0)
		if(!gt)
			out += "&lt;" + copytext(t, lt + 1)
			break
		var/raw = copytext(t, lt, gt + 1)
		var/closing = (copytext(raw, 2, 3) == "/")
		var/nm = RPTagName(raw, closing ? 3 : 2)
		if(!(nm in RP_ALLOWED_TAGS))
			out += "&lt;" + copytext(raw, 2)
			pos = gt + 1
			continue
		if(closing)
			out += "</[nm]>"
		else if(nm == "font")
			var/col = RPAttr(raw, "color")
			var/sz = RPAttr(raw, "size")
			var/attrs = ""
			if(RPValidColor(col)) attrs += " color=[col]"
			if(istext(sz) && length(sz) == 1 && findtext("1234567", sz)) attrs += " size=[sz]"
			var/fc = lowertext("[RPAttr(raw, "face")]")
			if(fc in RP_FONT_IDS) attrs += " face=[fc]"
			out += "<font[attrs]>"
		else if(nm == "a")
			var/href = RPAttr(raw, "href")
			if(istext(href) && (findtext(href, "http://") == 1 || findtext(href, "https://") == 1))
				out += "<a href='[replacetext(href, "'", "")]'>"
			else
				out += "<a>"
		else if(nm == "div")
			var/al = lowertext("[RPAttr(raw, "align")]")
			if(al == "center" || al == "right" || al == "left") out += "<div align=[al]>"
			else out += "<div>"
		else if(nm == "br")
			out += "<br>"
		else
			out += "<[nm]>"
		pos = gt + 1
	return out

client/proc/RPBoxSendAssets()
	ChatPanelSendAssets()
	src << browse_rsc('HUD/chatpanel/lc_tabw.png', "lc_tabw.png")
	src << browse_rsc('HUD/chatpanel/lc_tabw_on.png', "lc_tabw_on.png")
	src << browse_rsc('HUD/chatpanel/lc_chip_a.png', "lc_chip_a.png")
	src << browse_rsc('HUD/chatpanel/lc_chip_b.png', "lc_chip_b.png")
	src << browse_rsc('HUD/chatpanel/lc_btn.png', "lc_btn.png")
	src << browse_rsc('HUD/chatpanel/lc_btn_down.png', "lc_btn_down.png")
	src << browse_rsc('HUD/chatpanel/lc_band.png', "lc_band.png")

client/proc/RPBoxHTML()
	return {"<!DOCTYPE html><html><head><meta charset='utf-8'><style>
 @font-face{font-family:'monogram';src:url('monogram.ttf')}
 @font-face{font-family:'gothamrp';src:url('gotham.otf')}
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
 #shell{position:absolute;left:0;top:0;width:660px;height:440px;image-rendering:pixelated}
 #frame{position:absolute;left:0;top:0;right:0;bottom:0;border:16px solid transparent;border-image:url('lc_cover.png') 16 fill stretch;pointer-events:none}
 #frame.strip{border-image:url('lc_cover_strip.png') 16 fill stretch}
 #hdr{position:absolute;left:0;top:0;right:0;height:44px;cursor:move}
 .tabw{position:absolute;top:8px;width:84px;height:32px;background:url('lc_tabw.png') no-repeat;line-height:32px;text-align:center;color:#cfe3f5;cursor:pointer}
 .tabw.on{background-image:url('lc_tabw_on.png');color:#06283b}
 .btn{position:absolute;top:8px;width:32px;height:32px;background:url('lc_slot.png') no-repeat;cursor:pointer}
 .btn img{position:absolute;left:8px;top:8px;width:16px;height:16px}
 #close{right:16px}
 #close img{left:0;top:0;width:32px;height:32px}
 .sq img{position:absolute;left:4px;top:4px;width:16px;height:16px}
 #view{position:absolute;left:0;right:0;top:44px;bottom:0}
 .bg{position:absolute;left:0;top:0;right:0;bottom:0;pointer-events:none}
 .sub{border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box}
 .fld{border:8px solid transparent;border-image:url('lc_field.png') 8 fill stretch;box-sizing:border-box}
 .plate{border:6px solid transparent;border-image:url('lc_rowplate.png') 6 fill stretch;box-sizing:border-box}
 #tools{position:absolute;left:16px;right:16px;top:0;height:30px}
 .sq{position:absolute;top:3px;width:24px;height:24px;line-height:24px;text-align:center;color:#eaf5ff;cursor:pointer}
 .sq .bg{border:8px solid transparent;border-image:url('lc_btn.png') 8 fill stretch;box-sizing:border-box}
 .sq span{position:relative;top:1px}
 .sq:hover{color:#8be9ff}
 .sq:hover .bg{filter:brightness(1.2)}
 .sq:active{color:#06283b}
 .sq:active .bg{border-image-source:url('lc_btn_down.png');filter:none}
 .sq .c{position:absolute;left:6px;top:17px;width:12px;height:3px}
 .sq .ca{position:relative;top:-1px}
 .chip{position:absolute;top:6px;height:18px;line-height:16px;text-align:center;color:#cfe3f5;cursor:pointer;white-space:nowrap}
 .chip .bg{border:6px solid transparent;border-image:url('lc_chip_a.png') 6 fill stretch;box-sizing:border-box}
 .chip.on{color:#06283b}
 .chip.on .bg{border-image-source:url('lc_chip_b.png')}
 .chip span{position:relative}
 #edbody{position:absolute;left:16px;right:16px;top:36px;bottom:158px}
 #edbody.pmin{bottom:108px}
 #ed,#srcwrap,#hist{position:absolute;left:22px;right:26px;top:42px;bottom:164px;box-sizing:border-box}
 .bn #ed,.bn #srcwrap,.bn #hist{top:62px}
 .pmin #ed,.pmin #srcwrap,.pmin #hist{bottom:114px}
 #ed{padding:4px max(6px,calc(50% - 310px));overflow-y:scroll;overflow-x:hidden;font:14px/18px 'gothamrp',Arial,sans-serif;color:#eaf5ff;outline:0;user-select:text;-webkit-user-select:text;white-space:pre-wrap;word-wrap:break-word}
 #ed.ph:before{content:attr(data-ph);color:#6f86a8;pointer-events:none}
 #ed center{text-align:center;display:block}
 #ed div\[align=right],#prevc div\[align=right]{display:block;text-align:right}
 #ed div\[align=center],#prevc div\[align=center]{display:block;text-align:center}
 #ed a{color:#8be9ff}
 #srcwrap{display:none}
 #hl,#src{position:absolute;left:0;top:0;right:0;bottom:0;margin:0;padding:4px max(6px,calc(50% - 310px));font:16px/18px 'monogram';white-space:pre-wrap;word-wrap:break-word;box-sizing:border-box;overflow-y:scroll;overflow-x:hidden}
 #hl{color:#eaf5ff;pointer-events:none}
 #hl .tg{color:#5f7da8}
 #hl .bad{color:#e4635e}
 #src{background:transparent;color:transparent;caret-color:#eaf5ff;border:0;outline:0;resize:none;user-select:text;-webkit-user-select:text}
 #src::selection{background:rgba(139,233,255,0.35)}
 #ed::-webkit-scrollbar,#src::-webkit-scrollbar,#prevc::-webkit-scrollbar,#hist::-webkit-scrollbar{width:14px}
 #ed::-webkit-scrollbar-track,#src::-webkit-scrollbar-track,#prevc::-webkit-scrollbar-track,#hist::-webkit-scrollbar-track{background:url('lc_track.png') no-repeat;background-size:100% 100%;margin:6px 0}
 #ed::-webkit-scrollbar-thumb,#src::-webkit-scrollbar-thumb,#prevc::-webkit-scrollbar-thumb,#hist::-webkit-scrollbar-thumb{border-left:1px solid transparent;border-right:1px solid transparent;background-clip:padding-box;background-origin:padding-box;background:url('lc_thumb_top.png') left top no-repeat,url('lc_thumb_bot.png') left bottom no-repeat,url('lc_thumb_mid.png') left center no-repeat,url('lc_thumb_col.png') left top repeat-y;background-size:12px 6px,12px 6px,12px 11px,12px 1px;min-height:24px}
 #hl::-webkit-scrollbar{width:14px;background:transparent}
 #hl::-webkit-scrollbar-thumb{background:transparent}
 #banner{position:absolute;left:22px;right:26px;top:42px;height:18px;line-height:16px;display:none;z-index:3}
 #banner .bg{left:0;right:0}
 #banner .t{position:absolute;left:8px;top:0;color:#bfe6ff}
 #banner .a{position:absolute;right:8px;top:0;color:#8be9ff;cursor:pointer}
 #hist{display:none;overflow-y:scroll;overflow-x:hidden;padding-top:2px}
 .hr{position:relative;height:40px;white-space:nowrap;border-bottom:1px solid #243c60}
 .hr .pl{position:absolute;left:0;top:-1px;right:0;height:40px;display:none}
 .hr:hover .pl{display:block}
 .hr .when{position:absolute;left:8px;top:4px;color:#7ec8f0}
 .hr .ex{position:absolute;left:8px;right:112px;top:20px;overflow:hidden;text-overflow:ellipsis;font:13px/16px 'gothamrp',Arial,sans-serif;color:#eaf5ff}
 .hr .ld{right:8px}
 .hr .cp{right:58px}
 .empty{position:absolute;left:8px;top:2px;color:#b8b8d9}
 #prev{position:absolute;left:16px;right:16px;bottom:74px;height:80px}
 #prev.min{height:30px}
 #prevhd{position:absolute;left:14px;top:6px;color:#bfe6ff;cursor:pointer}
 #prevhd .ar{display:inline-block;width:5px;height:4px;background:url('lc_caret.png');margin-left:6px;vertical-align:middle;position:relative;top:-1px}
 #prev.min #prevhd .ar{transform:rotate(180deg)}
 #prev .tint{position:absolute;left:6px;right:6px;top:22px;bottom:6px;background:rgba(3,10,22,0.5);pointer-events:none}
 #prev.min .tint{display:none}
 #prevc{position:absolute;left:14px;right:14px;top:24px;bottom:6px;overflow-y:auto;overflow-x:hidden;font:12px/15px 'gothamrp',Arial,sans-serif;color:#eaf5ff;padding:0 max(0px,calc(50% - 310px));user-select:text;-webkit-user-select:text;word-wrap:break-word}
 #prev.min #prevc{display:none}
 #prevc center{display:block;text-align:center}
 #prevc a{color:#8be9ff}
 #acts{position:absolute;left:16px;right:16px;bottom:38px;height:30px}
 #acts .chip{top:6px}
 #send{position:absolute;right:6px;top:3px;width:64px;height:24px;line-height:24px;text-align:center;color:#06283b;cursor:pointer}
 #send .bg{border:8px solid transparent;border-image:url('lc_btn_down.png') 8 fill stretch;box-sizing:border-box}
 #send span{position:relative;top:1px}
 #send:hover .bg{filter:brightness(1.15)}
 #send:active{color:#eaf5ff}
 #send:active .bg{border-image-source:url('lc_btn.png');filter:none}
 #send:active span{top:2px}
 #foot{position:absolute;left:16px;right:16px;bottom:14px;height:18px;white-space:nowrap;overflow:hidden}
 #foot .bg{border:6px solid transparent;border-image:url('lc_band.png') 6 fill stretch;box-sizing:border-box}
 #foot .t{position:absolute;left:8px;top:2px}
 #foot .r{position:absolute;right:10px;top:2px;color:#7ec8f0}
 #foot .k{color:#7ec8f0}
 #foot .dv{display:inline-block;width:1px;height:8px;background:#344975;margin:0 9px 0 10px;vertical-align:top;position:relative;top:4px}
 #pop{position:absolute;display:none;z-index:6;filter:drop-shadow(3px 3px 0 rgba(0,0,0,0.6))}
 .swgrid{position:relative;padding:2px 6px 4px 6px;white-space:normal}
 .sw2{display:inline-block;position:relative;width:24px;height:24px;margin:2px;cursor:pointer;vertical-align:top}
 .sw2 .bg{border:8px solid transparent;border-image:url('lc_btn.png') 8 fill stretch;box-sizing:border-box}
 .sw2:hover .bg{filter:brightness(1.2)}
 .sw2 .c{position:absolute;left:4px;top:4px;width:16px;height:16px;box-shadow:inset 0 0 0 1px #06283b}
 .pf .pick{position:absolute;right:8px;top:6px;width:44px;height:18px;line-height:16px;text-align:center;color:#cfe3f5;cursor:pointer}
 .pf .pick .bg{border:6px solid transparent;border-image:url('lc_chip_a.png') 6 fill stretch;box-sizing:border-box}
 .pf .pick span{position:relative}
 .pf .pick:hover{color:#8be9ff}
 .hb{position:absolute;top:8px;width:44px;height:24px;line-height:24px;text-align:center;color:#eaf5ff;cursor:pointer}
 .hb .bg{border:8px solid transparent;border-image:url('lc_btn.png') 8 fill stretch;box-sizing:border-box}
 .hb span{position:relative;top:1px}
 .hb:hover{color:#8be9ff}
 .hb:hover .bg{filter:brightness(1.2)}
 .tabw.empty{color:#7f97b8}
 .tabw.on.empty{color:#06283b}
 #pop .bg{border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box}
 #popl{position:relative;padding:6px 0}
 .dr{position:relative;height:18px;line-height:18px;padding:0 8px;white-space:nowrap;overflow:hidden;cursor:pointer;color:#eaf5ff}
 .dr .pl{position:absolute;left:0;top:0;right:0;bottom:0;display:none}
 .dr:hover .pl,.dr.sel .pl{display:block}
 .dr span{position:relative}
 .dr .sw{display:inline-block;width:10px;height:10px;vertical-align:middle;margin-right:6px;position:relative;top:-1px}
 .dr.hint{color:#b8b8d9;cursor:default}
 .dr .x{position:absolute;right:8px;top:0;color:#e4635e}
 .pf{position:relative;height:30px;margin:0 8px}
 .pf .bg{border:8px solid transparent;border-image:url('lc_field.png') 8 fill stretch;box-sizing:border-box}
 .pf input{position:absolute;left:8px;top:8px;right:8px;height:16px;margin:0;padding:0;background:transparent;border:0;outline:0;font:16px/16px 'monogram';color:#eaf5ff;caret-color:#eaf5ff}
 .pf input\[type=color]{position:absolute;left:0;top:0;width:1px;height:1px;opacity:0;padding:0;border:0}
 .pf input.hex{right:60px;text-transform:uppercase}
 #grip{position:absolute;right:0;bottom:0;width:20px;height:20px;cursor:nwse-resize}
 :root{--cur:url('lc_cur_neutral.png') 2 0, auto;--cur-text:url('lc_cur_ibeam.png') 2 5, text;--cur-drag:url('lc_cur_drag.png') 4 5, move}
 *{cursor:var(--cur) !important}
 input,textarea,\[contenteditable='true'],#log{cursor:var(--cur-text) !important}
 #hdr.dragok,#grip{cursor:var(--cur-drag) !important}
 </style></head><body>
 <div id='shell'>
  <div id='frame'></div>
  <div id='hdr'>
   <div class='tabw on' id='s_0' style='left:16px'>DRAFT A<span class='dot'></span></div>
   <div class='tabw' id='s_1' style='left:102px'>DRAFT B<span class='dot'></span></div>
   <div class='tabw' id='s_2' style='left:188px'>DRAFT C<span class='dot'></span></div>
   <div class='btn' id='close' title='close the box (your drafts are kept)'><img src='lc_cross.png' alt=''></div>
  </div>
  <div id='view'>
   <div id='tools'>
    <div class='sq' data-a='bold' style='left:0' title='bold (Ctrl+B)'><div class='bg'></div><span>B</span></div>
    <div class='sq' data-a='italic' style='left:28px' title='italics (Ctrl+I)'><div class='bg'></div><span>I</span></div>
    <div class='sq' data-a='underline' style='left:56px' title='underline (Ctrl+U)'><div class='bg'></div><span style='text-decoration:underline'>U</span></div>
    <div class='sq' data-a='strike' style='left:84px' title='strikethrough (Ctrl+S)'><div class='bg'></div><span style='text-decoration:line-through'>S</span></div>
    <div class='chip' data-a='size' style='left:116px;width:52px'><div class='bg'></div><span>SIZE</span></div>
    <div class='sq' data-a='color' id='swatch' style='left:174px' title='text color'><div class='bg'></div><span class='ca' id='swa'>A</span><div class='c' id='swc'></div></div>
    <div class='chip' data-a='align' id='c_align' style='left:204px;width:60px' title='alignment of the current line: click to cycle left, center, right'><div class='bg'></div><span id='alignlbl'>LEFT</span></div>
    <div class='chip' data-a='link' style='left:270px;width:44px'><div class='bg'></div><span>LINK</span></div>
    <div class='chip' data-a='quote' style='left:320px;width:52px' title='wrap in speech quotes'><div class='bg'></div><span>QUOTE</span></div>
    <div class='chip' data-a='third' id='c_third' style='left:378px;width:72px' title='your name goes after the post instead of before it'><div class='bg'></div><span>3RD PERSON</span></div>
    <div class='chip' data-a='dice' style='left:456px;width:44px' title='roll dice and insert the result'><div class='bg'></div><span>DICE</span></div>
    <div class='chip' data-a='snip' style='left:506px;width:60px' title='saved snippets'><div class='bg'></div><span>SNIPPETS</span></div>
    <div class='sq' id='lock' style='right:28px' title='lock position and size'><div class='bg'></div><img src='lc_unlock.png' alt=''></div>
    <div class='sq' id='fold' style='right:0' title='collapse to the tab strip'><div class='bg'></div><img src='lc_down.png' alt=''></div>
   </div>
   <div id='edbody'><div class='bg sub'></div></div>
   <div id='banner'><div class='bg plate'></div><span class='t' id='bantext'></span><span class='a' id='banact'></span></div>
   <div id='ed' contenteditable='true' spellcheck='true' data-ph='Write your roleplay here. Ctrl+Enter sends.'></div>
   <div id='srcwrap'><pre id='hl'></pre><textarea id='src' spellcheck='false'></textarea></div>
   <div id='hist'></div>
   <div id='prev'><div class='bg sub'></div><div class='tint'></div><div id='prevhd'>PREVIEW<span class='ar'></span></div><div id='prevc'></div></div>
   <div id='acts'><div class='bg sub'></div>
    <div class='chip' data-a='discard' style='left:6px;width:58px'><div class='bg'></div><span>CLEAR</span></div>
    <div class='chip' data-a='history' id='c_hist' style='left:70px;width:58px'><div class='bg'></div><span>HISTORY</span></div>
    <div class='chip' data-a='export' style='left:134px;width:58px' title='copy your sent posts to the clipboard'><div class='bg'></div><span>EXPORT</span></div>
    <div class='chip' data-a='expr' id='c_expr' style='left:198px;width:72px' title='your expression: shown on your portrait in chat until you change it'><div class='bg'></div><span>EXPRESSION</span></div>
    <div class='chip' data-a='font' id='c_font' style='left:276px;width:44px' title='the font your posts are shown in until you change it'><div class='bg'></div><span>FONT</span></div>
    <div class='chip' data-a='html' id='c_html' style='right:140px;width:58px' title='edit the tags directly'><div class='bg'></div><span>SOURCE</span></div>
    <div class='chip' data-a='keep' id='c_keep' style='right:84px;width:44px' title='keep the box open after sending'><div class='bg'></div><span>KEEP</span></div>
    <div id='send' title='send (Ctrl+Enter)'><div class='bg'></div><span>SEND</span></div>
   </div>
   <div id='foot'><div class='bg'></div><div class='t' id='foott'></div><div class='r' id='footr'></div></div>
  </div>
  <div id='pop'><div class='bg'></div><div id='popl'></div></div>
  <div id='grip'></div>
 </div>
 <script>
 var PREVIEW=false;
 var NL=String.fromCharCode(10), TAB=String.fromCharCode(9), Q=String.fromCharCode(34);
 var shell=document.getElementById('shell'), hdr=document.getElementById('hdr'), grip=document.getElementById('grip'), fold=document.getElementById('fold'), lockBtn=document.getElementById('lock');
 var lockImg=lockBtn.getElementsByTagName('img').item(0), foldImg=fold.getElementsByTagName('img').item(0);
 var frame=document.getElementById('frame'), view=document.getElementById('view');
 var ed=document.getElementById('ed'), srcwrap=document.getElementById('srcwrap'), src=document.getElementById('src'), hl=document.getElementById('hl'), hist=document.getElementById('hist');
 var prev=document.getElementById('prev'), prevc=document.getElementById('prevc'), edbody=document.getElementById('edbody'), banner=document.getElementById('banner');
 var pop=document.getElementById('pop'), popl=document.getElementById('popl'), foott=document.getElementById('foott'), footr=document.getElementById('footr');
 var CTL='mapwindow.rpoverlay', MINW=660, MINH=360;
 var Z=2, OP=0.85, G={x:0,y:0,w:1320,h:880}, B=null, collapsed=false, live=false, locked=false;
 function applyCursor(){ var two=(Z>=2); var r=document.documentElement.style; r.setProperty('--cur',two?"url('lc_cur_neutral2.png') 5 1, auto":"url('lc_cur_neutral.png') 2 0, auto"); r.setProperty('--cur-text',two?"url('lc_cur_ibeam2.png') 5 11, text":"url('lc_cur_ibeam.png') 2 5, text"); r.setProperty('--cur-drag',two?"url('lc_cur_drag2.png') 9 11, move":"url('lc_cur_drag.png') 4 5, move"); }

 var slots=\[{t:'',at:0},{t:'',at:0},{t:'',at:0}], slot=0, mode='wysiwyg', third=false, keep=false, sentLog=\[], snippets=\[], colors=\[], curColor='#ff5555', faces=\[], faceIdx=1;
 function dec(v){ try{ return decodeURIComponent(String(v).split('+').join(' ')); }catch(e){ return String(v); } }
 function setFaces(s){ faces=\[]; var parts=(s||'').split(';'); for(var i=0;i<parts.length;i++){ var f=parts\[i].split('|'); if(f.length<2) continue; faces.push({i:+f\[0],name:dec(f\[1]),trig:dec(f\[2]||'')}); } exprChip(); }
 function setFace(i){ faceIdx=+i; exprChip(); }
 var FONTS=\[{id:'crimson',label:'Crimson Pro',css:'lfcrimson,serif',size:'17px'},{id:'cinzel',label:'Cinzel',css:'lfcinzel,serif',size:'13px'},{id:'caveat',label:'Caveat',css:'lfcaveat,cursive',size:'19px'},{id:'elite',label:'Special Elite',css:'lfelite,monospace',size:'14px'},{id:'fraktur',label:'UnifrakturCook',css:'lffraktur,serif',size:'17px'},{id:'gotham',label:'Gotham',css:'lfgotham,sans-serif',size:'14px'},{id:'pixel',label:'Pixel',css:'monogram,monospace',size:'16px'}], font='';
 function fontById(id){ for(var i=0;i<FONTS.length;i++){ if(FONTS\[i].id===id) return FONTS\[i]; } return null; }
 function setFont(f){ font=fontById(String(f||''))?String(f):''; applyFont(); }
 function applyFont(){ var cl=ed.classList, rm=\[]; for(var i=0;i<cl.length;i++){ if(cl\[i].indexOf('f-')===0) rm.push(cl\[i]); } for(var j=0;j<rm.length;j++) cl.remove(rm\[j]); if(font) cl.add('f-'+font); var c=document.getElementById('c_font'); var cur=fontById(font); c.classList.toggle('on',!!font); c.title=cur?('your posts are shown in '+cur.label+' until you change it'):'the font your posts are shown in until you change it'; refreshPreview(); }
 function fontMenu(el){
  var selOn=(mode==='source')?(src.selectionEnd>src.selectionStart):(selText().length>0);
  var h="<div class='dr hint'><span>"+(selOn?'font for the selected text':'no text selected: the font for all your posts')+"</span></div>";
  h+="<div class='dr"+((!selOn&&!font)?' sel':'')+"' data-f=''><div class='pl plate'></div><span>"+(selOn?'Pixel (plain)':'Default (pixel)')+"</span></div>";
  for(var i=0;i<FONTS.length;i++){ var f=FONTS\[i]; if(f.id==='pixel') continue; h+="<div class='dr"+((!selOn&&font===f.id)?' sel':'')+"' data-f='"+f.id+"'><div class='pl plate'></div><span style='font-family:"+f.css+";font-size:"+f.size+"'>"+esc(f.label)+"</span></div>"; }
  popl.innerHTML=h; popShow(el,220);
  popl.onclick=function(e){ var r=e.target.closest('.dr'); if(!r||r.classList.contains('hint')) return; popClose(); var id=r.getAttribute('data-f')||''; if(selOn){ applySelFont(id||'pixel'); } else { setFont(id); topic({rpbox:'font',f:id}); } };
 }
 function applySelFont(id){ if(mode==='source'){ srcWrap('<font face='+id+'>','</font>'); return; } cmd('fontName',id); }
 function exprChip(){ var cur=null; for(var i=0;i<faces.length;i++){ if(faces\[i].i===faceIdx) cur=faces\[i]; } var el=document.getElementById('c_expr'); el.classList.toggle('on',!!(cur&&cur.name!=='blank')); el.title=cur?('your expression: '+cur.name+(cur.trig.length?' ('+cur.trig+')':'')+'. Shown on your portrait in chat until you change it.'):'your expression: shown on your portrait in chat until you change it'; }
 function exprMenu(el){ var items=\[]; for(var i=0;i<faces.length;i++){ items.push({label:faces\[i].name+(faces\[i].i===faceIdx?'  *':''),v:faces\[i].i}); } if(!items.length) items.push({label:'blank',v:1}); popMenu(el,items,function(it){ setFace(it.v); topic({rpbox:'face',i:it.v}); }); }
 var me={name:'You',tc:'#45fa3f',ec:'#f0fa33'};
 var saveTimer=null, prevTimer=null, srvTimer=null, idleTimer=null, typing=false, lastSave=0, dirty=false, histOpen=false, undoText=null;
 var ALLOWED={b:1,i:1,u:1,s:1,strike:1,em:1,strong:1,br:1,center:1,font:1,a:1,div:1};
 function clampNum(v,lo,hi){ if(hi<lo) hi=lo; if(v<lo) return lo; if(v>hi) return hi; return v; }
 function esc(x){ return String(x).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
 function escAttr(x){ return esc(x).replace(/'/g,'&#39;'); }
 function ws(p){ if(window.BYOND) BYOND.winset(CTL,p); }
 function topic(p){ p.rpbox=p.rpbox||''; if(window.BYOND) BYOND.topic(p); }
 function focusMap(){ if(window.BYOND) BYOND.winset('mapwindow.map',{focus:true}); }
 function clampG(){
  if(!B) return;
  var h=collapsed?48*Z:G.h;
  if(G.w>B.x1-B.x0) G.w=B.x1-B.x0;
  if(!collapsed && G.h>B.y1-B.y0){ G.h=B.y1-B.y0; h=G.h; }
  G.x=clampNum(G.x,B.x0,B.x1-G.w); G.y=clampNum(G.y,B.y0,B.y1-h);
 }
 function layout(){
  document.body.style.zoom=Z; applyCursor();
  shell.style.width=Math.round(G.w/Z)+'px';
  shell.style.height=(collapsed?48:Math.round(G.h/Z))+'px';
  frame.style.opacity=OP;
  frame.classList.toggle('strip',collapsed);
  if(!live){ shell.style.left=Math.round(G.x/Z)+'px'; shell.style.top=Math.round(G.y/Z)+'px'; }
  view.style.display=collapsed?'none':'block'; grip.style.display=(collapsed||locked)?'none':'block';
  foldImg.src=collapsed?'lc_up.png':'lc_down.png';
  lockImg.src=locked?'lc_lock.png':'lc_unlock.png'; hdr.classList.toggle('dragok',!locked);
  if(collapsed) popClose();
 }
 function setGeom(x,y,w,h,z,op,bx0,by0,bx1,by1,lk,fd){ G={x:+x,y:+y,w:+w,h:+h}; Z=+z; OP=+op; if(bx1!==undefined){ B={x0:+bx0,y0:+by0,x1:+bx1,y1:+by1}; } locked=(+lk)?true:false; var wantFold=(+fd)?true:false; collapsed=false; if(wantFold){ collapsed=true; G.y+=G.h-48*Z; } clampG(); if(collapsed){ flush(); } else { layout(); } }
 var pending=false;
 function flush(){ pending=false; clampG(); ws({pos:G.x+','+G.y, size:G.w+'x'+(collapsed?48*Z:G.h)}); layout(); }
 function sched(){ if(!pending){ pending=true; requestAnimationFrame(flush); } }
 function report(){ topic({rpbox:'geom', g:G.x+','+G.y+','+G.w+','+G.h}); }
 var drag=null;
 hdr.addEventListener('pointerdown',function(e){ if(e.button!==0||locked) return; if(e.target.closest('.tabw')||e.target.closest('.btn')) return; drag={sx:e.screenX,sy:e.screenY,x:G.x,y:G.y}; try{ hdr.setPointerCapture(e.pointerId); }catch(err){} e.preventDefault(); });
 hdr.addEventListener('pointermove',function(e){ if(!drag) return; G.x=drag.x+(e.screenX-drag.sx); G.y=drag.y+(e.screenY-drag.sy); clampG(); sched(); });
 hdr.addEventListener('pointerup',function(e){ if(!drag) return; drag=null; flush(); report(); focusMap(); });
 var rs=null;
 grip.addEventListener('pointerdown',function(e){ if(e.button!==0||locked) return; rs={sx:e.screenX,sy:e.screenY,w:G.w,h:G.h}; try{ grip.setPointerCapture(e.pointerId); }catch(err){} e.preventDefault(); e.stopPropagation(); });
 grip.addEventListener('pointermove',function(e){ if(!rs) return; var mw=B?B.x1-G.x:1e9, mh=B?B.y1-G.y:1e9; G.w=clampNum(rs.w+(e.screenX-rs.sx),MINW*Z,mw); G.h=clampNum(rs.h+(e.screenY-rs.sy),MINH*Z,mh); sched(); });
 grip.addEventListener('pointerup',function(e){ if(!rs) return; rs=null; flush(); report(); popClose(); focusMap(); });
 fold.addEventListener('click',function(){ var d=G.h-48*Z; if(!collapsed){ collapsed=true; G.y+=d; } else { collapsed=false; G.y=G.y-d; } clampG(); flush(); report(); topic({rpbox:'fold',f:collapsed?1:0}); focusMap(); });
 lockBtn.addEventListener('click',function(){ locked=!locked; layout(); topic({rpbox:'lock',l:locked?1:0}); focusMap(); });
 document.getElementById('close').addEventListener('click',function(){ if(dirty) saveDraft(); popClose(); topic({rpbox:'close'}); focusMap(); });
 function stripTags(h){ return String(h).replace(/<\[^>]*>/g,''); }
 function words(h){ var t=stripTags(h).split(NL).join(' ').split(TAB).join(' '); var n=0, parts=t.split(' '); for(var i=0;i<parts.length;i++){ if(parts\[i].length) n++; } return n; }
 function okColor(c){ c=String(c||''); if(c.charAt(0)==='#'){ var hex=c.substring(1); if(hex.length!==3&&hex.length!==6) return false; for(var i=0;i<hex.length;i++){ if('0123456789abcdefABCDEF'.indexOf(hex.charAt(i))<0) return false; } return true; } for(var j=0;j<c.length;j++){ if('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.indexOf(c.charAt(j))<0) return false; } return c.length>0&&c.length<20; }
 function okSize(s){ return String(s).length===1&&'1234567'.indexOf(String(s))>=0; }
 function okHref(h){ h=String(h||''); return h.indexOf('http://')===0||h.indexOf('https://')===0; }
 function serNode(node){
  var out='';
  var kids=node.childNodes;
  for(var i=0;i<kids.length;i++){
   var n=kids\[i];
   if(n.nodeType===3){ out+=esc(n.nodeValue); continue; }
   if(n.nodeType!==1) continue;
   var t=n.tagName.toLowerCase();
   if(t==='br'){ out+=NL; continue; }
   var inner=serNode(n);
   if(t==='b'||t==='strong'){ out+='<b>'+inner+'</b>'; continue; }
   if(t==='i'||t==='em'){ out+='<i>'+inner+'</i>'; continue; }
   if(t==='u'){ out+='<u>'+inner+'</u>'; continue; }
   if(t==='s'||t==='strike'||t==='del'){ out+='<s>'+inner+'</s>'; continue; }
   if(t==='font'){ var c=n.getAttribute('color'), sz=n.getAttribute('size'), fc=String(n.getAttribute('face')||'').toLowerCase(); var a=''; if(c&&okColor(c)) a+=' color='+c; if(sz&&okSize(sz)) a+=' size='+sz; if(fc&&fontById(fc)) a+=' face='+fc; out+=a?('<font'+a+'>'+inner+'</font>'):inner; continue; }
   if(t==='a'){ var h=n.getAttribute('href')||''; out+=okHref(h)?("<a href='"+h.replace(/'/g,'')+"'>"+inner+'</a>'):inner; continue; }
   if(t==='center'){ out+='<center>'+inner+'</center>'; continue; }
   if(t==='span'){ var st=n.style||{}; var w=inner; if(st.fontWeight==='bold'||(+st.fontWeight)>=600) w='<b>'+w+'</b>'; if(st.fontStyle==='italic') w='<i>'+w+'</i>'; if(String(st.textDecoration).indexOf('underline')>=0) w='<u>'+w+'</u>'; if(String(st.textDecoration).indexOf('line-through')>=0) w='<s>'+w+'</s>'; var col=rgbToHex(st.color); if(col) w='<font color='+col+'>'+w+'</font>'; out+=w; continue; }
   if(t==='div'||t==='p'||t==='li'||t==='h1'||t==='h2'||t==='h3'||t==='blockquote'){
    var alg=String((n.style&&n.style.textAlign)||n.getAttribute('align')||'').toLowerCase();
    var body=alg==='center'?'<center>'+inner+'</center>':(alg==='right'?'<div align=right>'+inner+'</div>':inner);
    if(out.length&&out.charAt(out.length-1)!==NL) out+=NL;
    out+=body;
    if(body.length&&body.charAt(body.length-1)!==NL) out+=NL;
    continue;
   }
   out+=inner;
  }
  return out;
 }
 function rgbToHex(c){ c=String(c||''); if(c.charAt(0)==='#') return okColor(c)?c:''; if(c.indexOf('rgb')!==0) return ''; var a=c.indexOf('('), b=c.indexOf(')'); if(a<0||b<0) return ''; var parts=c.substring(a+1,b).split(','); if(parts.length<3) return ''; var h='#'; for(var i=0;i<3;i++){ var v=Math.max(0,Math.min(255,parseInt(parts\[i],10)||0)).toString(16); if(v.length<2) v='0'+v; h+=v; } return h; }
 function trimNL(s){ while(s.length&&s.charAt(s.length-1)===NL) s=s.substring(0,s.length-1); return s; }
 function serialize(){ var s=trimNL(serNode(ed)); return s; }
 function cleanTree(srcNode,dst){
  var kids=srcNode.childNodes;
  for(var i=0;i<kids.length;i++){
   var n=kids\[i];
   if(n.nodeType===3){ dst.appendChild(document.createTextNode(n.nodeValue)); continue; }
   if(n.nodeType!==1) continue;
   var t=n.tagName.toLowerCase();
   if(t==='br'){ dst.appendChild(document.createElement('br')); continue; }
   if(t==='script'||t==='style'||t==='img'||t==='iframe'||t==='object'||t==='embed'||t==='svg'||t==='link'||t==='meta') continue;
   var el=null;
   if(t==='b'||t==='strong') el=document.createElement('b');
   else if(t==='i'||t==='em') el=document.createElement('i');
   else if(t==='u') el=document.createElement('u');
   else if(t==='s'||t==='strike'||t==='del') el=document.createElement('s');
   else if(t==='center') el=document.createElement('center');
   else if(t==='font'){ el=document.createElement('font'); var c=n.getAttribute('color'), sz=n.getAttribute('size'), fc=String(n.getAttribute('face')||'').toLowerCase(); if(c&&okColor(c)) el.setAttribute('color',c); if(sz&&okSize(sz)) el.setAttribute('size',sz); if(fc&&fontById(fc)) el.setAttribute('face',fc); }
   else if(t==='a'){ var h=n.getAttribute('href')||''; if(okHref(h)){ el=document.createElement('a'); el.setAttribute('href',h); el.setAttribute('target','_blank'); } }
   else if(t==='div'||t==='p'){ var dal=String(n.getAttribute('align')||(n.style&&n.style.textAlign)||'').toLowerCase(); if(dal==='center'){ el=document.createElement('center'); } else if(dal==='right'){ el=document.createElement('div'); el.setAttribute('align','right'); } else { if(dst.childNodes.length&&!(dst.lastChild.nodeType===1&&dst.lastChild.tagName==='BR')) dst.appendChild(document.createElement('br')); cleanTree(n,dst); dst.appendChild(document.createElement('br')); continue; } }
   if(el){ cleanTree(n,el); dst.appendChild(el); } else cleanTree(n,dst);
  }
 }
 function cleanHtml(h){ var doc=new DOMParser().parseFromString('<body>'+String(h)+'</body>','text/html'); var frag=document.createDocumentFragment(); cleanTree(doc.body,frag); var d=document.createElement('div'); d.appendChild(frag); return d.innerHTML; }
 function gameToEditor(g){ return cleanHtml(String(g).split(NL).join('<br>')); }
 function getGame(){ return mode==='source'?src.value:serialize(); }
 function setGame(g){ if(mode==='source'){ src.value=g; paintHl(); } else { ed.innerHTML=gameToEditor(g); } placeholder(); }
 function placeholder(){ var e=mode==='source'?(src.value.length===0):(serialize().length===0); ed.classList.toggle('ph',e&&mode!=='source'); }
 function tagsOf(s){ var out=\[], re=/<\[^>]*>/g, m; while((m=re.exec(s))){ var raw=m\[0]; var close=raw.charAt(1)==='/'; var j=close?2:1, name=''; while(j<raw.length){ var ch=raw.charAt(j).toLowerCase(); if(ch>='a'&&ch<='z') name+=ch; else break; j++; } out.push({i:m.index,l:raw.length,name:name,close:close,raw:raw}); } return out; }
 function checkTags(s){ var st=\[], bad=\[]; var tg=tagsOf(s); for(var i=0;i<tg.length;i++){ var t=tg\[i]; if(!ALLOWED\[t.name]){ bad.push(i); continue; } if(t.name==='br') continue; if(!t.close) st.push({n:t.name,idx:i}); else { var k=st.length-1; while(k>=0&&st\[k].n!==t.name) k--; if(k<0) bad.push(i); else st.splice(k,1); } } for(var q=0;q<st.length;q++) bad.push(st\[q].idx); return {tags:tg,bad:bad,open:st}; }
 function paintHl(){ var s=src.value; var r=checkTags(s); var badSet={}; for(var i=0;i<r.bad.length;i++) badSet\[r.bad\[i]]=1; var out='', pos=0; for(var k=0;k<r.tags.length;k++){ var t=r.tags\[k]; out+=esc(s.substring(pos,t.i)); out+="<span class='"+(badSet\[k]?'bad':'tg')+"'>"+esc(t.raw)+'</span>'; pos=t.i+t.l; } out+=esc(s.substring(pos)); if(out.length&&out.charAt(out.length-1)===NL) out+=' '; hl.innerHTML=out; hl.scrollTop=src.scrollTop; }
 src.addEventListener('scroll',function(){ hl.scrollTop=src.scrollTop; });
 function autoClose(s){ var r=checkTags(s); var o=r.open; for(var i=o.length-1;i>=0;i--) s+='</'+o\[i].n+'>'; return {text:s,closed:o.length}; }
 function setMode(m,quiet){
  if(m===mode) return;
  var g=getGame();
  mode=m; document.getElementById('c_html').classList.toggle('on',mode==='source');
  ed.style.display=mode==='source'?'none':'block'; srcwrap.style.display=mode==='source'?'block':'none';
  setGame(g); if(!quiet) settingsChanged(); counts();
  (mode==='source'?src:ed).focus();
 }
 function renderLocal(g){
  var msg=g;
  var tp=third;
  if(msg.indexOf('//')===0||msg.indexOf('||')===0){ msg=msg.substring(2); tp=true; }
  msg=msg.split(NL).join('<br>');
  msg=msg.split('</center><br>').join('</center>');
  msg=msg.split('</div><br>').join('</div>');
  msg=msg.replace(/"\[^"]*"/g,function(x){ return '<font color='+me.tc+'>'+x+'</font>'; });
  if(font) msg='<font face='+font+'>'+msg+'</font>';
  if(!tp) return '<font color='+me.tc+'>*'+esc(me.name)+'<font color='+me.ec+'> '+msg+'</font>*</font>';
  return '<font color='+me.tc+'>*<font color='+me.ec+'>'+msg+'</font><br><br>('+esc(me.name)+')*</font>';
 }
 function showPreview(html){ prevc.innerHTML=cleanHtml(html); }
 function setPreview(html){ showPreview(html); }
 function refreshPreview(){ var g=getGame(); if(!g.length){ prevc.innerHTML="<span style='color:#6f86a8'>your post appears here as others will see it</span>"; return; } showPreview(renderLocal(g)); if(srvTimer) clearTimeout(srvTimer); srvTimer=setTimeout(function(){ if(live) topic({rpbox:'preview',text:getGame(),third:third?1:0}); },700); }
 function counts(){ var g=getGame(); var w=words(g), c=stripTags(g).length; var sv=lastSave?Math.max(0,Math.round((Date.now()-lastSave)/1000)):-1; var sav=dirty?'saving':(sv<0?'':(sv<5?'saved just now':(sv<60?'saved '+sv+'s ago':'saved '+Math.floor(sv/60)+'m ago'))); foott.innerHTML="<span class='k'>WORDS </span>"+w+"<span class='k'>  CHARS </span>"+c+(sav?"<span class='dv'></span>"+esc(sav):''); footr.textContent=(mode==='source'?'SOURCE':'RICH')+(third?' 3RD':'')+(keep?' KEEP':''); }
 function markTyping(){ if(!typing){ typing=true; topic({rpbox:'typing',on:1}); } if(idleTimer) clearTimeout(idleTimer); idleTimer=setTimeout(function(){ typing=false; topic({rpbox:'typing',on:0}); },120000); }
 function changed(){
  dirty=true; placeholder(); counts();
  if(mode==='source') paintHl();
  if(prevTimer) clearTimeout(prevTimer); prevTimer=setTimeout(refreshPreview,150);
  if(saveTimer) clearTimeout(saveTimer); saveTimer=setTimeout(saveDraft,1200);
  markTyping();
  document.getElementById('s_'+slot).classList.toggle('empty',getGame().length===0);
 }
 function saveDraft(){ var g=getGame(); slots\[slot].t=g; slots\[slot].at=Date.now(); dirty=false; lastSave=Date.now(); try{ localStorage.setItem('rpdraft'+slot,g); localStorage.setItem('rpdraftat'+slot,String(Date.now())); }catch(e){} topic({rpbox:'draft',slot:slot,text:g}); counts(); }
 ed.addEventListener('input',changed);
 src.addEventListener('input',changed);
 function selText(){ var s=window.getSelection(); return s?String(s):''; }
 function srcWrap(before,after){ var a=src.selectionStart, b=src.selectionEnd; var v=src.value; src.value=v.substring(0,a)+before+v.substring(a,b)+after+v.substring(b); src.focus(); src.selectionStart=a+before.length; src.selectionEnd=b+before.length; changed(); }
 function srcInsert(t){ var a=src.selectionStart, b=src.selectionEnd; var v=src.value; src.value=v.substring(0,a)+t+v.substring(b); src.focus(); src.selectionStart=src.selectionEnd=a+t.length; changed(); }
 function cmd(c,v){ ed.focus(); try{ document.execCommand('styleWithCSS',false,false); }catch(e){} document.execCommand(c,false,v); changed(); }
 function insertGame(g){ if(mode==='source') srcInsert(g); else { ed.focus(); document.execCommand('insertHTML',false,gameToEditor(g)); changed(); } }
 var ALIGNS=\['left','center','right'];
 function curAlign(){ if(mode==='source'){ var v=src.value, a=src.selectionStart; var before=v.substring(Math.max(0,a-40),a).toLowerCase(); if(before.lastIndexOf('<center>')>before.lastIndexOf('</center>')) return 'center'; if(before.lastIndexOf('<div align=right>')>before.lastIndexOf('</div>')) return 'right'; return 'left'; } try{ if(document.queryCommandState('justifyCenter')) return 'center'; if(document.queryCommandState('justifyRight')) return 'right'; }catch(e){} return 'left'; }
 function showAlign(){ document.getElementById('alignlbl').textContent=curAlign().toUpperCase(); }
 function srcUnwrap(open,close){ var v=src.value, a=src.selectionStart, b=src.selectionEnd; if(v.substring(a-open.length,a)===open&&v.substring(b,b+close.length)===close){ src.value=v.substring(0,a-open.length)+v.substring(a,b)+v.substring(b+close.length); src.selectionStart=a-open.length; src.selectionEnd=b-open.length; return true; } return false; }
 function cycleAlign(){ var cur=curAlign(); var next=ALIGNS\[(ALIGNS.indexOf(cur)+1)%ALIGNS.length]; if(mode==='source'){ srcUnwrap('<center>','</center>'); srcUnwrap('<div align=right>','</div>'); if(next==='center') srcWrap('<center>','</center>'); else if(next==='right') srcWrap('<div align=right>','</div>'); else { src.focus(); changed(); } } else { cmd(next==='center'?'justifyCenter':(next==='right'?'justifyRight':'justifyLeft')); } showAlign(); }
 document.addEventListener('selectionchange',function(){ if(document.activeElement===ed||document.activeElement===src) showAlign(); });
 function act(a,el){
  if(a==='bold'){ mode==='source'?srcWrap('<b>','</b>'):cmd('bold'); return; }
  if(a==='italic'){ mode==='source'?srcWrap('<i>','</i>'):cmd('italic'); return; }
  if(a==='underline'){ mode==='source'?srcWrap('<u>','</u>'):cmd('underline'); return; }
  if(a==='strike'){ mode==='source'?srcWrap('<s>','</s>'):cmd('strikeThrough'); return; }
  if(a==='align'){ cycleAlign(); return; }
  if(a==='quote'){ if(mode==='source'){ srcWrap(Q,Q); } else { var t=selText(); ed.focus(); document.execCommand('insertText',false,Q+t+Q); changed(); } return; }
  if(a==='size'){ popMenu(el,\[{label:'small',v:'1'},{label:'normal',v:'3'},{label:'large',v:'5'},{label:'huge',v:'7'}],function(it){ if(mode==='source') srcWrap('<font size='+it.v+'>','</font>'); else cmd('fontSize',it.v); }); return; }
  if(a==='color'){ colorMenu(el); return; }
  if(a==='link'){ linkMenu(el); return; }
  if(a==='third'){ third=!third; document.getElementById('c_third').classList.toggle('on',third); settingsChanged(); refreshPreview(); counts(); return; }
  if(a==='dice'){ popMenu(el,\[{label:'d4',v:'4'},{label:'d6',v:'6'},{label:'d8',v:'8'},{label:'d10',v:'10'},{label:'d12',v:'12'},{label:'d20',v:'20'},{label:'d100',v:'100'},{label:'2d6',v:'6',n:2}],function(it){ if(live) topic({rpbox:'roll',n:it.n||1,sides:it.v}); else setRoll('\['+(it.n||1)+'d'+it.v+': 7]'); }); return; }
  if(a==='snip'){ snipMenu(el); return; }
  if(a==='expr'){ exprMenu(el); return; }
  if(a==='font'){ fontMenu(el); return; }
  if(a==='html'){ setMode(mode==='source'?'wysiwyg':'source'); return; }
  if(a==='discard'){ var g=getGame(); if(!g.length) return; undoText=g; setGame(''); changed(); saveDraft(); showBanner('draft cleared','undo',function(){ setGame(undoText); changed(); saveDraft(); hideBanner(); }); return; }
  if(a==='history'){ toggleHistory(); return; }
  if(a==='export'){ exportHistory(); return; }
  if(a==='keep'){ keep=!keep; document.getElementById('c_keep').classList.toggle('on',keep); settingsChanged(); counts(); return; }
 }
 function setRoll(text){ insertGame(text+' '); }
 function settingsChanged(){ topic({rpbox:'settings',mode:mode,keep:keep?1:0,third:third?1:0,slot:slot,colors:colors.join(',')}); }
 document.getElementById('tools').addEventListener('click',function(e){ var b=e.target.closest('\[data-a]'); if(!b) return; act(b.getAttribute('data-a'),b); e.preventDefault(); });
 document.getElementById('tools').addEventListener('pointerdown',function(e){ if(e.target.closest('\[data-a]')) e.preventDefault(); });
 document.getElementById('acts').addEventListener('click',function(e){ var b=e.target.closest('\[data-a]'); if(b){ act(b.getAttribute('data-a'),b); e.preventDefault(); } });
 document.getElementById('acts').addEventListener('pointerdown',function(e){ if(e.target.closest('\[data-a]')||e.target.closest('#send')) e.preventDefault(); });
 document.getElementById('send').addEventListener('click',function(){ send(); });
 function popShow(el,w){ var r=el.getBoundingClientRect(); var ox=0, oy=0, n=el; while(n&&n!==shell){ ox+=n.offsetLeft; oy+=n.offsetTop; n=n.offsetParent; } pop.style.left=Math.max(16,Math.min(ox,(shell.offsetWidth||600)-16-w))+'px'; pop.style.top=(oy+el.offsetHeight+2)+'px'; pop.style.width=w+'px'; pop.style.display='block'; var ph=pop.offsetHeight, sh=shell.offsetHeight||440; if(oy+el.offsetHeight+2+ph>sh-16){ pop.style.top=Math.max(16,oy-ph-2)+'px'; } }
 function popClose(){ pop.style.display='none'; popl.innerHTML=''; }
 function popMenu(el,items,onpick){ var h=''; for(var i=0;i<items.length;i++){ var it=items\[i]; h+="<div class='dr' data-i='"+i+"'><div class='pl plate'></div>"+(it.color?"<span class='sw' style='background:"+it.color+"'></span>":'')+"<span>"+esc(it.label)+"</span>"+(it.del?"<span class='x' data-del='"+i+"'>x</span>":'')+"</div>"; } popl.innerHTML=h; popShow(el,150); popl.onclick=function(e){ var d=e.target.closest('\[data-del]'); if(d){ if(items\[+d.getAttribute('data-del')].ondel) items\[+d.getAttribute('data-del')].ondel(); popClose(); e.stopPropagation(); return; } var r=e.target.closest('.dr'); if(!r||r.classList.contains('hint')) return; popClose(); onpick(items\[+r.getAttribute('data-i')]); }; }
 function applyColor(c){ if(!okColor(c)) return; curColor=c; document.getElementById('swc').style.background=c; document.getElementById('swa').style.color=c; colors=\[c].concat(colors.filter(function(x){ return x!==c; })).slice(0,6); if(mode==='source') srcWrap('<font color='+c+'>','</font>'); else cmd('foreColor',c); settingsChanged(); }
 function colorMenu(el){
  var base=\[{label:'your speech color',v:me.tc},{label:'your emote color',v:me.ec},{label:'white',v:'#eaf5ff'},{label:'crimson',v:'#e4635e'},{label:'ember',v:'#f2a33a'},{label:'gold',v:'#f2c87e'},{label:'leaf',v:'#5fe08a'},{label:'sky',v:'#7ec8f0'},{label:'violet',v:'#b58cff'},{label:'rose',v:'#f08cc8'},{label:'teal',v:'#4ec9b0'},{label:'slate',v:'#b8b8d9'}];
  for(var i=0;i<colors.length;i++) base.push({label:'recent '+colors\[i],v:colors\[i]});
  var items=\[], seen={};
  for(var q=0;q<base.length;q++){ var key=String(base\[q].v).toLowerCase(); if(seen\[key]) continue; seen\[key]=1; items.push(base\[q]); }
  while(items.length%5!==0&&items.length>10) items.pop();
  if(items.length>10&&items.length<15) items.length=10;
  var h="<div class='dr hint'><span>COLOR</span></div><div class='swgrid'>";
  for(var k=0;k<items.length;k++) h+="<div class='sw2' data-i='"+k+"' title='"+escAttr(items\[k].label)+"'><div class='bg'></div><div class='c' style='background:"+items\[k].v+"'></div></div>";
  h+="</div><div class='pf'><div class='bg'></div><input type='text' class='hex' id='cust' placeholder='#HEX' maxlength='7'><input type='color' id='custp' value='"+curColor+"'><div class='pick' id='pickbtn' title='open the color picker'><div class='bg'></div><span>PICK</span></div></div>";
  popl.innerHTML=h; popShow(el,170);
  popl.onclick=function(e){ if(e.target.closest('#pickbtn')){ document.getElementById('custp').click(); return; } if(e.target.closest('.pf')) return; var r=e.target.closest('.sw2'); if(!r) return; popClose(); applyColor(items\[+r.getAttribute('data-i')].v); };
  var cust=document.getElementById('cust'), custp=document.getElementById('custp');
  cust.addEventListener('keydown',function(e){ if(e.key==='Enter'){ var v=cust.value.trim(); if(v.charAt(0)!=='#') v='#'+v; popClose(); applyColor(v); e.preventDefault(); } if(e.key==='Escape'){ popClose(); e.preventDefault(); } });
  custp.addEventListener('input',function(){ cust.value=custp.value; });
  custp.addEventListener('change',function(){ popClose(); applyColor(custp.value); });
 }
 function linkMenu(el){
  var sel=selText();
  popl.innerHTML="<div class='dr hint'><span>link address</span></div><div class='pf'><div class='bg'></div><input type='text' id='lurl' placeholder='https://'></div>";
  popShow(el,260); var inp=document.getElementById('lurl'); inp.focus();
  inp.addEventListener('keydown',function(e){ if(e.key==='Enter'){ var u=inp.value.trim(); if(u.length&&u.indexOf('http://')!==0&&u.indexOf('https://')!==0) u='https://'+u; popClose(); if(okHref(u)){ if(mode==='source') srcWrap("<a href='"+u.replace(/'/g,'')+"'>",'</a>'); else { if(sel.length) cmd('createLink',u); else insertGame("<a href='"+u.replace(/'/g,'')+"'>"+esc(u)+'</a>'); } } e.preventDefault(); } if(e.key==='Escape'){ popClose(); e.preventDefault(); } });
 }
 function snipMenu(el){
  var items=\[]; var sel=mode==='source'?src.value.substring(src.selectionStart,src.selectionEnd):selText();
  for(var i=0;i<snippets.length;i++){ (function(idx){ items.push({label:snippets\[idx].n,v:snippets\[idx].t,del:true,ondel:function(){ snippets.splice(idx,1); pushSnippets(); }}); })(i); }
  var h='';
  for(var k=0;k<items.length;k++) h+="<div class='dr' data-i='"+k+"'><div class='pl plate'></div><span>"+esc(items\[k].label)+"</span><span class='x' data-del='"+k+"'>x</span></div>";
  if(!items.length) h+="<div class='dr hint'><span>no snippets yet</span></div>";
  h+="<div class='dr hint'><span>"+(sel.length?'save the selection as:':'select text to save a snippet')+"</span></div>";
  if(sel.length) h+="<div class='pf'><div class='bg'></div><input type='text' id='snipname' placeholder='name' maxlength='24'></div>";
  popl.innerHTML=h; popShow(el,220);
  popl.onclick=function(e){ var d=e.target.closest('\[data-del]'); if(d){ items\[+d.getAttribute('data-del')].ondel(); popClose(); e.stopPropagation(); return; } if(e.target.closest('.pf')) return; var r=e.target.closest('.dr'); if(!r||r.classList.contains('hint')) return; popClose(); insertGame(items\[+r.getAttribute('data-i')].v); };
  var sn=document.getElementById('snipname'); if(sn){ sn.focus(); sn.addEventListener('keydown',function(e){ if(e.key==='Enter'){ var nm=sn.value.trim(); if(nm.length){ var g=mode==='source'?sel:trimNL(serNode(selFragment())); if(!g.length) g=esc(sel); snippets.push({n:nm,t:g}); pushSnippets(); } popClose(); e.preventDefault(); } if(e.key==='Escape'){ popClose(); e.preventDefault(); } }); }
 }
 function selFragment(){ var s=window.getSelection(); var d=document.createElement('div'); if(s&&s.rangeCount){ d.appendChild(s.getRangeAt(0).cloneContents()); } return d; }
 function pushSnippets(){ topic({rpbox:'snippets',json:JSON.stringify(snippets)}); }
 document.addEventListener('pointerdown',function(e){ if(pop.style.display==='block'&&!e.target.closest('#pop')&&!e.target.closest('\[data-a]')) popClose(); });
 function showBanner(text,actLabel,fn){ document.getElementById('bantext').textContent=text; var a=document.getElementById('banact'); a.textContent=actLabel||''; a.onclick=fn||null; banner.style.display='block'; view.classList.add('bn'); if(banner._t) clearTimeout(banner._t); banner._t=setTimeout(hideBanner,10000); }
 function hideBanner(){ banner.style.display='none'; view.classList.remove('bn'); }
 function ago(ms){ var m=Math.floor(ms/60000); if(m<1) return 'moments ago'; if(m<60) return m+'m ago'; var h=Math.floor(m/60); if(h<24) return h+'h ago'; return Math.floor(h/24)+'d ago'; }
 function selectSlot(i,quiet){
  if(dirty) saveDraft();
  slot=i; for(var k=0;k<3;k++) document.getElementById('s_'+k).classList.toggle('on',k===i);
  histOpen=false; hist.style.display='none'; ed.style.display=mode==='source'?'none':'block'; srcwrap.style.display=mode==='source'?'block':'none'; document.getElementById('c_hist').classList.remove('on');
  setGame(slots\[i].t||''); dirty=false; lastSave=slots\[i].at||0; counts(); refreshPreview(); hideBanner();
  if(!quiet) settingsChanged();
 }
 for(var si=0;si<3;si++){ (function(i){ document.getElementById('s_'+i).addEventListener('click',function(){ if(collapsed){ fold.click(); } selectSlot(i); (mode==='source'?src:ed).focus(); }); })(si); }
 function send(){
  var g=getGame();
  if(mode==='source'){ var ac=autoClose(g); if(ac.closed){ g=ac.text; src.value=g; paintHl(); showBanner('closed '+ac.closed+' open tag'+(ac.closed>1?'s':''),'',null); } }
  g=trimNL(g);
  if(!stripTags(g).split(' ').join('').split(NL).join('').length){ showBanner('nothing to send','',null); return; }
  if(!live){ sentLog.unshift({t:g,at:Date.now()}); renderHistory(); afterSend(); return; }
  topic({rpbox:'send',slot:slot,text:g,third:third?1:0,keep:keep?1:0});
 }
 function sent(s){ afterSend(); }
 function afterSend(){ if(typing){ typing=false; if(idleTimer) clearTimeout(idleTimer); } slots\[slot].t=''; slots\[slot].at=0; setGame(''); dirty=false; lastSave=0; try{ localStorage.removeItem('rpdraft'+slot); }catch(e){} document.getElementById('s_'+slot).classList.add('empty'); counts(); refreshPreview(); if(!keep){ topic({rpbox:'close'}); focusMap(); } else { (mode==='source'?src:ed).focus(); } }
 function toggleHistory(){ histOpen=!histOpen; document.getElementById('c_hist').classList.toggle('on',histOpen); if(histOpen){ renderHistory(); ed.style.display='none'; srcwrap.style.display='none'; hist.style.display='block'; } else { hist.style.display='none'; ed.style.display=mode==='source'?'none':'block'; srcwrap.style.display=mode==='source'?'block':'none'; } }
 function renderHistory(){ var h=''; for(var i=0;i<sentLog.length;i++){ var e=sentLog\[i]; h+="<div class='hr' data-i='"+i+"'><div class='pl plate'></div><span class='when'>"+esc(ago(Date.now()-e.at))+"</span><span class='ex'>"+esc(stripTags(e.t).split(NL).join(' '))+"</span><div class='hb cp' data-cp='"+i+"'><div class='bg'></div><span>COPY</span></div><div class='hb ld' data-ld='"+i+"'><div class='bg'></div><span>LOAD</span></div></div>"; } if(!sentLog.length) h="<div class='empty'>nothing sent yet</div>"; hist.innerHTML=h; }
 hist.addEventListener('click',function(e){ var ld=e.target.closest('\[data-ld]'), cp=e.target.closest('\[data-cp]'); var i=ld?+ld.getAttribute('data-ld'):(cp?+cp.getAttribute('data-cp'):-1); if(i<0) return; var en=sentLog\[i]; if(!en) return; if(cp){ copyText(stripTags(en.t)); showBanner('copied','',null); return; } var target=slot; if(getGame().length){ var free=-1; for(var k=0;k<3;k++){ if(!(slots\[k].t||'').length){ free=k; break; } } if(free>=0) target=free; else { undoText=getGame(); } } toggleHistory(); if(target!==slot) selectSlot(target); setGame(en.t); changed(); saveDraft(); if(undoText) showBanner('loaded over your draft','undo',function(){ setGame(undoText); undoText=null; changed(); saveDraft(); hideBanner(); }); });
 function copyText(t){ try{ if(navigator.clipboard&&navigator.clipboard.writeText){ navigator.clipboard.writeText(t); return; } }catch(e){} var ta=document.createElement('textarea'); ta.value=t; document.body.appendChild(ta); ta.select(); try{ document.execCommand('copy'); }catch(e){} document.body.removeChild(ta); }
 function exportHistory(){ if(!sentLog.length){ showBanner('nothing to export','',null); return; } var out=\[]; for(var i=sentLog.length-1;i>=0;i--){ var e=sentLog\[i]; out.push('\['+new Date(e.at).toLocaleString()+'] '+stripTags(e.t)); } copyText(out.join(NL+NL)); showBanner('copied '+sentLog.length+' post'+(sentLog.length>1?'s':'')+' to the clipboard','',null); }
 function onKey(e){
  if(e.ctrlKey&&e.key==='Enter'){ send(); e.preventDefault(); return; }
  if(e.ctrlKey&&!e.shiftKey){ var k=e.key.toLowerCase(); if(k==='b'){ act('bold'); e.preventDefault(); return; } if(k==='i'){ act('italic'); e.preventDefault(); return; } if(k==='u'){ act('underline'); e.preventDefault(); return; } if(k==='s'){ act('strike'); e.preventDefault(); return; } if(k==='l'){ act('link',document.querySelector("\[data-a='link']")); e.preventDefault(); return; } }
  if(e.key==='Escape'){ popClose(); (mode==='source'?src:ed).blur(); focusMap(); e.preventDefault(); return; }
  if(e.key==='Tab'){ e.preventDefault(); if(mode==='source') srcInsert('    '); else document.execCommand('insertText',false,'    '); }
 }
 ed.addEventListener('keydown',onKey); src.addEventListener('keydown',onKey);
 ed.addEventListener('paste',function(e){ var cd=e.clipboardData; if(!cd) return; e.preventDefault(); var h=cd.getData('text/html'); var t=cd.getData('text/plain'); var g=h?trimNL(serNode(new DOMParser().parseFromString('<body>'+h+'</body>','text/html').body)):esc(t); insertGame(g); });
 src.addEventListener('paste',function(e){ var cd=e.clipboardData; if(!cd) return; e.preventDefault(); srcInsert(cd.getData('text/plain')); });
 document.getElementById('prevhd').addEventListener('click',function(){ prev.classList.toggle('min'); edbody.classList.toggle('pmin',prev.classList.contains('min')); });
 document.addEventListener('contextmenu',function(e){ if(!e.target.closest('#ed')&&!e.target.closest('#src')) e.preventDefault(); });
 function setIdentity(name,tc,ec){ me={name:String(name),tc:okColor(tc)?tc:me.tc,ec:okColor(ec)?ec:me.ec}; refreshPreview(); }
 function setDrafts(json){ try{ var a=JSON.parse(json); for(var i=0;i<3&&i<a.length;i++){ var t=String(a\[i].t||''); var m=+a\[i].m||0; if(!t.length){ try{ var l=localStorage.getItem('rpdraft'+i); if(l&&l.length){ t=l; m=Math.round((Date.now()-(+localStorage.getItem('rpdraftat'+i)||Date.now()))/60000); } }catch(e){} } slots\[i]={t:t,at:t.length?Date.now()-m*60000:0}; document.getElementById('s_'+i).classList.toggle('empty',t.length===0); } }catch(e){} selectSlot(slot,true); var cur=slots\[slot]; if(cur.t.length) showBanner('draft from '+ago(Date.now()-cur.at)+' restored','discard',function(){ act('discard'); hideBanner(); }); }
 function setHistory(json){ try{ var a=JSON.parse(json); sentLog=\[]; for(var i=0;i<a.length;i++) sentLog.push({t:String(a\[i].t||''),at:Date.now()-(+a\[i].m||0)*60000}); }catch(e){} if(histOpen) renderHistory(); }
 function setSnippets(json){ try{ snippets=JSON.parse(json)||\[]; }catch(e){ snippets=\[]; } }
 function setSettings(m,k,t,s,c){ keep=(+k)?true:false; third=(+t)?true:false; document.getElementById('c_keep').classList.toggle('on',keep); document.getElementById('c_third').classList.toggle('on',third); colors=String(c||'').split(',').filter(function(x){ return okColor(x); }); if(colors.length){ curColor=colors\[0]; document.getElementById('swc').style.background=curColor; document.getElementById('swa').style.color=curColor; } var sl=+s; if(sl>=0&&sl<3) slot=sl; setMode(m==='source'?'source':'wysiwyg',true); counts(); }
 function focusInput(){ (mode==='source'?src:ed).focus(); }
 setInterval(counts,5000);
 document.getElementById('swc').style.background=curColor; document.getElementById('swa').style.color=curColor;
 function boot(){ live=true; layout(); topic({rpbox:'ready'}); }
 if(window.BYOND){ boot(); } else { window.addEventListener('byond-ready',boot); }
 if(PREVIEW){
  setIdentity('Seraphine','#f2c87e','#f0fa33');
  setSettings('wysiwyg',0,0,0,'#e4635e');
  setDrafts(JSON.stringify(\[{t:'The gate creaks as she leans on it, eyes on the tree line. <b>Nothing moves.</b>'+NL+NL+'"Kaidos," she says, low, "tell me that was the wind."',m:12},{t:'',m:0},{t:'',m:0}]));
  setHistory(JSON.stringify(\[{t:'She shakes the frost from her sleeves and <i>grins</i>.',m:9},{t:'"One second, checking the log."',m:31}]));
  setSnippets(JSON.stringify(\[{n:'scene header',t:'<center><b>- - -</b></center>'},{n:'sigh',t:'<i>*a long, tired sigh*</i>'}]));
  setFaces('1|blank|;2|happy|;3|smirk|;4|anger1|75%25%20HP'); setFace(2);
  setFont('crimson');
  setTimeout(function(){ if(!live){ setGeom(16,120,1320,880,2,0.85,0,0,4000,3000,0,0); } },300);
 }
 counts(); refreshPreview(); placeholder();
 </script></body></html>
"}

client/proc/RPBoxBoot()
	if(rpbox_booted) return
	rpbox_booted = 1
	rpbox_drafts = list(list("t" = "", "at" = 0), list("t" = "", "at" = 0), list("t" = "", "at" = 0))
	rpbox_history = list()
	rpbox_snippets = list()
	if(!prefs) return
	var/g = getPref("rpGeom")
	if(istext(g) && length(g)) rpbox_geom = g
	rpbox_lock = getPref("rpLock") ? 1 : 0
	rpbox_fold = getPref("rpFold") ? 1 : 0
	rpbox_keep = getPref("rpKeep") ? 1 : 0
	rpbox_third = getPref("rpThird") ? 1 : 0
	var/m = getPref("rpMode")
	if(m == "source") rpbox_mode = "source"
	var/s = text2num("[getPref("rpSlot")]")
	if(!isnull(s) && s >= 0 && s <= 2) rpbox_slot = s
	var/c = getPref("rpColors")
	if(istext(c)) rpbox_colors = c
	var/dj = getPref("rpDrafts")
	if(istext(dj) && length(dj))
		var/list/d = json_decode(dj)
		if(islist(d))
			for(var/i = 1, i <= 3 && i <= d.len, i++)
				var/list/e = d[i]
				if(islist(e) && istext(e["t"]))
					rpbox_drafts[i] = list("t" = e["t"], "at" = isnum(e["at"]) ? e["at"] : 0)
	var/hj = getPref("rpHistory")
	if(istext(hj) && length(hj))
		var/list/h = json_decode(hj)
		if(islist(h))
			for(var/e in h)
				if(islist(e) && istext(e["t"]))
					rpbox_history += list(list("t" = e["t"], "at" = isnum(e["at"]) ? e["at"] : 0))
	var/sj = getPref("rpSnippets")
	if(istext(sj) && length(sj))
		var/list/sn = json_decode(sj)
		if(islist(sn))
			for(var/e in sn)
				if(islist(e) && istext(e["n"]) && istext(e["t"]))
					rpbox_snippets += list(list("n" = e["n"], "t" = e["t"]))

client/proc/RPBoxDraftWords()
	var/n = 0
	for(var/list/e in rpbox_drafts)
		var/t = e["t"]
		if(!istext(t) || !length(t)) continue
		var/plain = t
		var/lt = findtext(plain, "<", 1, 0)
		while(lt)
			var/gt = findtext(plain, ">", lt, 0)
			if(!gt) break
			plain = copytext(plain, 1, lt) + " " + copytext(plain, gt + 1)
			lt = findtext(plain, "<", 1, 0)
		var/list/parts = splittext(replacetext(plain, "\n", " "), " ")
		for(var/p in parts)
			if(length(p)) n++
	return n

client/proc/RPBoxRelogHint()
	if(!rpbox_booted) RPBoxBoot()
	var/n = RPBoxDraftWords()
	if(n) src << "<span style='color:#b8b8d9'>You have an unsent roleplay draft ([n] words). Type /rp or press the RP button to open it.</span>"

client/proc/RPBoxPlace()
	var/list/r = PanelViewRect()
	if(!r) return
	var/x0 = r[1]
	var/y0 = r[2]
	var/x1 = r[3]
	var/y1 = r[4]
	var/z = r[5]
	rpbox_zoom = z
	rpbox_x0 = x0
	rpbox_y0 = y0
	var/vw = x1 - x0
	var/vh = y1 - y0
	var/x
	var/y
	var/w
	var/h
	if(rpbox_geom)
		var/list/g = splittext(rpbox_geom, ",")
		if(g.len == 4)
			var/gx = text2num(g[1]); var/gy = text2num(g[2]); var/gw = text2num(g[3]); var/gh = text2num(g[4])
			if(!isnull(gx) && !isnull(gy) && gw > 0 && gh > 0)
				x = x0 + round(gx * z); y = y0 + round(gy * z); w = round(gw * z); h = round(gh * z)
	if(!w || !h)
		w = 660 * z
		h = 440 * z
		x = x0 + 8 * z
		y = y1 - h - 84 * z
	if(w > vw) w = vw
	if(h > vh) h = vh
	if(x + w > x1) x = x1 - w
	if(y + h > y1) y = y1 - h
	if(x < x0) x = x0
	if(y < y0) y = y0
	rpbox_geom = "[(x - x0) / z],[(y - y0) / z],[w / z],[h / z]"
	winset(src, RPBOX_CTL, "pos=[x],[y];size=[w]x[h]")
	src << output(list2params(list(x, y, w, h, z, chatpanel_opacity, x0, y0, x1, y1, rpbox_lock, rpbox_fold)), "[RPBOX_CTL]:setGeom")

client/proc/RPBoxStoreGeom(gtext)
	var/list/g = splittext(gtext, ",")
	if(g.len != 4) return
	var/x = text2num(g[1]); var/y = text2num(g[2]); var/w = text2num(g[3]); var/h = text2num(g[4])
	if(isnull(x) || isnull(y) || !(w > 0) || !(h > 0)) return
	var/z = rpbox_zoom ? rpbox_zoom : 1
	rpbox_geom = "[(x - rpbox_x0) / z],[(y - rpbox_y0) / z],[w / z],[h / z]"
	setPref("rpGeom", rpbox_geom)

client/proc/RPBoxShow()
	if(!mob) return
	RPBoxBoot()
	RPBoxSendAssets()
	winset(src, RPBOX_CTL, "inner-background-color=transparent")
	src << browse(RPBoxHTML(), "window=[RPBOX_CTL]")
	rpbox_open = 1
	RPBoxPlace()
	winset(src, RPBOX_CTL, "is-visible=true")
	winset(src, RPBOX_CTL, "focus=true")

client/proc/RPBoxHide()
	rpbox_open = 0
	winset(src, RPBOX_CTL, "is-visible=false")
	RPBoxTyping(0)

client/proc/RPBoxToggle()
	if(rpbox_open) RPBoxHide()
	else RPBoxShow()

client/proc/RPBoxMinutesAgo(at)
	if(!isnum(at) || at <= 0) return 0
	var/m = round((world.realtime - at) / 600)
	return m < 0 ? 0 : m

client/proc/RPBoxDraftsJson()
	var/list/out = list()
	for(var/list/e in rpbox_drafts)
		out += list(list("t" = e["t"], "m" = RPBoxMinutesAgo(e["at"])))
	return json_encode(out)

client/proc/RPBoxHistoryJson()
	var/list/out = list()
	for(var/list/e in rpbox_history)
		out += list(list("t" = e["t"], "m" = RPBoxMinutesAgo(e["at"])))
	return json_encode(out)

client/proc/RPBoxPushAll()
	if(!mob) return
	src << output(list2params(list("[mob.name]", "[mob.Text_Color]", "[mob.Emote_Color]")), "[RPBOX_CTL]:setIdentity")
	src << output(list2params(list(mob.RPFont)), "[RPBOX_CTL]:setFont")
	src << output(list2params(list(rpbox_mode, rpbox_keep, rpbox_third, rpbox_slot, rpbox_colors)), "[RPBOX_CTL]:setSettings")
	src << output(list2params(list(json_encode(rpbox_snippets))), "[RPBOX_CTL]:setSnippets")
	src << output(list2params(list(RPBoxHistoryJson())), "[RPBOX_CTL]:setHistory")
	src << output(list2params(list(RPBoxDraftsJson())), "[RPBOX_CTL]:setDrafts")
	RPBoxFaces()
	RPBoxFaceState()
	src << output("", "[RPBOX_CTL]:focusInput")

client/proc/RPBoxFaces()
	if(!mob || !rpbox_open) return
	src << output(list2params(list(mob.PortraitFaceList())), "[RPBOX_CTL]:setFaces")

client/proc/RPBoxFaceState()
	if(!mob || !rpbox_open) return
	var/list/st = mob.PortraitStates()
	var/d = mob.PortraitCanon(mob.PortraitDefault)
	if(!istext(d)) d = ""
	src << output(list2params(list(st.Find(d))), "[RPBOX_CTL]:setFace")

client/proc/RPBoxSaveDrafts()
	var/list/out = list()
	for(var/list/e in rpbox_drafts)
		out += list(list("t" = e["t"], "at" = e["at"]))
	setPref("rpDrafts", json_encode(out))

client/proc/RPBoxDraft(slot, text)
	var/s = text2num("[slot]")
	if(isnull(s) || s < 0 || s > 2) return
	if(!istext(text)) text = ""
	rpbox_drafts[s + 1] = list("t" = text, "at" = length(text) ? world.realtime : 0)
	RPBoxSaveDrafts()

client/proc/RPBoxTyping(on)
	if(!mob) return
	if(on)
		if(mob.rping) return
		mob.rping = TRUE
		mob.checkInvisibilityBreaking()
		var/image/em = new('Emoting.dmi')
		em.appearance_flags = 66
		em.layer = EFFECTS_LAYER
		mob.emoteBubble = em
		mob.overlays += mob.emoteBubble
	else
		if(!mob.rping) return
		mob.rping = FALSE
		if(mob.emoteBubble) mob.overlays -= mob.emoteBubble

client/proc/RPBoxSend(slot, text, third, keep)
	if(!mob || !istext(text) || !length(text)) return
	if(rpbox_last_send >= world.time) return
	rpbox_last_send = world.time + 10
	var/body = mob.RPFontWrap(RPSanitize(text))
	if(third && findtext(body, "//") != 1 && findtext(body, "||") != 1) body = "//" + body
	mob.SubmitRoleplay(body, 0)
	rpbox_history.Insert(1, list(list("t" = text, "at" = world.realtime)))
	while(rpbox_history.len > 10) rpbox_history.len--
	var/list/hout = list()
	for(var/list/e in rpbox_history)
		hout += list(list("t" = e["t"], "at" = e["at"]))
	setPref("rpHistory", json_encode(hout))
	var/s = text2num("[slot]")
	if(!isnull(s) && s >= 0 && s <= 2)
		rpbox_drafts[s + 1] = list("t" = "", "at" = 0)
		RPBoxSaveDrafts()
	RPBoxTyping(0)
	src << output(list2params(list(RPBoxHistoryJson())), "[RPBOX_CTL]:setHistory")
	src << output(list2params(list(isnull(s) ? 0 : s)), "[RPBOX_CTL]:sent")

client/proc/RPBoxQuick(text)
	if(!mob || !istext(text) || !length(text)) return
	if(rpbox_last_send >= world.time) return
	rpbox_last_send = world.time + 10
	mob.checkInvisibilityBreaking()
	mob.SubmitRoleplay(mob.RPFontWrap(RPSanitize(text)), 0)

client/proc/RPBoxPreview(text, third)
	if(!mob) return
	var/body = mob.RPFontWrap(RPSanitize(istext(text) ? text : ""))
	if(third && findtext(body, "//") != 1 && findtext(body, "||") != 1) body = "//" + body
	src << output(list2params(list(mob.applyRoleplayParsing(body, 0))), "[RPBOX_CTL]:setPreview")

client/proc/RPBoxSetFont(f)
	if(!mob) return
	f = lowertext("[f]")
	mob.RPFont = (f in RP_FONT_IDS) ? f : ""
	src << output(list2params(list(mob.RPFont)), "[RPBOX_CTL]:setFont")

client/proc/RPBoxRoll(n, sides)
	if(!mob) return
	n = text2num("[n]")
	sides = text2num("[sides]")
	if(isnull(n) || isnull(sides)) return
	n = clamp(round(n), 1, 10)
	sides = clamp(round(sides), 2, 100)
	var/total = 0
	var/list/rolls = list()
	for(var/i = 1, i <= n, i++)
		var/r = rand(1, sides)
		rolls += r
		total += r
	var/detail = jointext(rolls, ", ")
	mob.OMessage(10, "<b><font color=red>DICE:</b></font> [mob] rolled [total] ([n]d[sides][n > 1 ? ": [detail]" : ""]).")
	src << output(list2params(list("\[[n]d[sides]: [total][n > 1 ? " ([detail])" : ""]\]")), "[RPBOX_CTL]:setRoll")

client/proc/RPBoxSnippets(json)
	var/list/out = list()
	if(istext(json) && length(json))
		var/list/sn = json_decode(json)
		if(islist(sn))
			for(var/e in sn)
				if(islist(e) && istext(e["n"]) && istext(e["t"]) && length(e["n"]))
					out += list(list("n" = copytext(e["n"], 1, 25), "t" = RPSanitize(e["t"])))
				if(out.len >= 30) break
	rpbox_snippets = out
	setPref("rpSnippets", json_encode(out))

client/proc/RPBoxSettings(mode, keep, third, slot, colors)
	rpbox_mode = (mode == "source") ? "source" : "wysiwyg"
	rpbox_keep = text2num("[keep]") ? 1 : 0
	rpbox_third = text2num("[third]") ? 1 : 0
	var/s = text2num("[slot]")
	if(!isnull(s) && s >= 0 && s <= 2) rpbox_slot = s
	var/list/cs = list()
	for(var/c in splittext("[colors]", ","))
		if(RPValidColor(c)) cs += c
		if(cs.len >= 6) break
	rpbox_colors = jointext(cs, ",")
	setPref("rpMode", rpbox_mode)
	setPref("rpKeep", rpbox_keep)
	setPref("rpThird", rpbox_third)
	setPref("rpSlot", rpbox_slot)
	setPref("rpColors", rpbox_colors)

client/proc/RPBoxTopic(list/href_list)
	switch(href_list["rpbox"])
		if("ready")
			RPBoxPlace()
			RPBoxPushAll()
		if("geom")
			RPBoxStoreGeom(href_list["g"])
		if("lock")
			rpbox_lock = text2num(href_list["l"]) ? 1 : 0
			setPref("rpLock", rpbox_lock)
		if("fold")
			rpbox_fold = text2num(href_list["f"]) ? 1 : 0
			setPref("rpFold", rpbox_fold)
		if("draft")
			RPBoxDraft(href_list["slot"], href_list["text"])
		if("send")
			RPBoxSend(href_list["slot"], href_list["text"], text2num(href_list["third"]), text2num(href_list["keep"]))
		if("preview")
			RPBoxPreview(href_list["text"], text2num(href_list["third"]))
		if("roll")
			RPBoxRoll(href_list["n"], href_list["sides"])
		if("snippets")
			RPBoxSnippets(href_list["json"])
		if("settings")
			RPBoxSettings(href_list["mode"], href_list["keep"], href_list["third"], href_list["slot"], href_list["colors"])
		if("typing")
			RPBoxTyping(text2num(href_list["on"]))
		if("face")
			if(mob) mob.PortraitPickIndex(text2num(href_list["i"]))
		if("font")
			RPBoxSetFont(href_list["f"])
		if("close")
			RPBoxHide()

mob/Players/verb/RPBox_Open()
	set name = "Roleplay Box"
	set category = "Roleplay"
	set hidden = 1
	client?.RPBoxToggle()
