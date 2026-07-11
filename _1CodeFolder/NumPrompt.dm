// HUD entry prompts, the replacement for input() as num|text.
// HUDNumPrompt(title, default) and HUDTextPrompt(title, default) block like input() and return the value, null on cancel

#define NP_LAYER (FLY_LAYER + 5)
#define NP_W 224
#define NP_H 140
#define NP_FONT "font-family:'monogram'; font-size:12pt"
#define NP_FONT_BIG "font-family:'monogram'; font-size:24pt"
#define NP_FONT_BODY "font-family:'Pixel Operator 8'; font-size:6pt"
#define NP_MAXLEN 60
#define NP_VIEW 12   // cells visible at once, longer buffers window like a native field
#define NP_FIELD_X 16
#define NP_FIELD_Y 36
#define NP_TEXT_X 26
#define NP_TEXT_Y 33
#define NP_ADV 14

/atom/movable/shud/nppic
	layer = NP_LAYER + 0.3
	mouse_opacity = 0

/atom/movable/shud/nptext
	layer = NP_LAYER + 0.6
	mouse_opacity = 0
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/npdrag          // dialog body: swallows clicks, drags the prompt
	layer = NP_LAYER
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr)
			usr.client.NpPanelStart(params)
			usr.client.NumPromptMacros()   // clicking the dialog re-arms its key capture
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.NpPanelMove(params)
	MouseUp(location, control, params)
		if(usr) usr.client.NpPanelEnd()

/atom/movable/shud/npbtn
	layer = NP_LAYER + 0.5
	mouse_opacity = 2
	var/action
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr && usr.client) usr.client.NumPromptAction(action)

client
	var/tmp
		np_open = 0
		np_mode = "num"  // num | text
		np_val = ""
		np_result
		list/np_hud
		np_atx = 1
		np_aty = 1
		np_pan_x = 0
		np_pan_y = 0
		np_pan_mx = 0
		np_pan_my = 0
		np_pan_ox = 0
		np_pan_oy = 0
		np_pan_dragged = 0
		np_cursor = 0    // caret position within the buffer, 0..length
		np_win = 0       // first buffer index shown (display windowing)
		list/np_digits   // one maptext slot per visible glyph
		atom/movable/shud/nppic/np_caret
		np_rep_key       // held-key repeat throttle state
		np_rep_seen = 0
		np_rep_since = 0
		np_rep_last = 0

client/proc/NPloc(dx, dyTop, h = 0)
	var/py = NP_H - dyTop - h
	var/ax = dx + np_pan_x
	var/ay = py + np_pan_y
	var/axp = ((ax % 32) + 32) % 32
	var/ayp = ((ay % 32) + 32) % 32
	return "[np_atx + (ax - axp) / 32]:[axp],[np_aty + (ay - ayp) / 32]:[ayp]"

client/proc/NpAdd(atom/movable/o)
	np_hud += o
	screen += o

client/proc/NpText(dx, dyTop, w, h, txt, lay = 0.6)
	var/atom/movable/shud/nptext/T = new
	T.layer = NP_LAYER + lay
	T.maptext_width = w
	T.maptext_height = h
	T.screen_loc = NPloc(dx, dyTop, h)
	T.maptext = txt
	NpAdd(T)
	return T

// macros are disabled while any other control holds focus
client/proc/MapFocus()
	winset(src, "mapwindow.map", "focus=true")

mob/proc/HUDNumPrompt(title, default = "")
	if(!client) return null
	if(client.np_open) return null
	client.NumPromptOpen(title, default)
	while(client && client.np_open)
		sleep(2)
	return client ? client.np_result : null

mob/proc/HUDTextPrompt(title, default = "")
	if(!client) return null
	if(client.np_open) return null
	client.NumPromptOpen(title, default, "text")
	while(client && client.np_open)
		sleep(2)
	return client ? client.np_result : null

client/proc/NumPromptOpen(title, initial, mode = "num")
	if(np_open || !mob) return
	np_open = 1
	np_mode = mode
	np_result = null
	np_val = ""
	if(mode == "text")
		np_val = copytext("[initial]", 1, NP_MAXLEN + 1)
	else
		var/n = text2num("[initial]")
		if(!isnull(n) && n > 0) np_val = copytext(num2text(round(n), 10), 1, NP_MAXLEN + 1)
	np_cursor = length(np_val)
	np_win = max(0, np_cursor - NP_VIEW)

	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	if(isnull(vw)) vw = 20
	if(isnull(vh)) vh = 15
	var/mtw = round(NP_W / 32); if(mtw * 32 < NP_W) mtw++
	var/mth = round(NP_H / 32); if(mth * 32 < NP_H) mth++
	np_atx = max(1, round((vw - mtw) / 2) + 1)
	np_aty = max(1, round((vh - mth) / 2) + 1)
	np_pan_x = getPref("npPanX"); if(isnull(np_pan_x)) np_pan_x = 0
	np_pan_y = getPref("npPanY"); if(isnull(np_pan_y)) np_pan_y = 0
	var/list/b = NpPanBounds()
	np_pan_x = clamp(np_pan_x, b[1], b[2])
	np_pan_y = clamp(np_pan_y, b[3], b[4])

	np_hud = list()
	var/atom/movable/shud/npdrag/P = new
	P.icon = 'HUD/party_prompt.png'
	P.screen_loc = NPloc(0, 0, NP_H)
	NpAdd(P)
	NpText(0, 12, NP_W, 16, "<center><span style=\"[NP_FONT]; color:#8be9ff\">[title]</span></center>")
	var/atom/movable/shud/nppic/F = new
	F.icon = 'HUD/np_field.png'
	F.layer = NP_LAYER + 0.4
	F.screen_loc = NPloc(NP_FIELD_X, NP_FIELD_Y, 34)
	NpAdd(F)
	// one glyph per fixed 14px cell
	np_digits = list()
	for(var/i = 1 to NP_VIEW)
		var/atom/movable/shud/nptext/D = new
		D.layer = NP_LAYER + 0.6
		D.maptext_width = NP_ADV
		D.maptext_height = 32
		D.screen_loc = NPloc(NP_TEXT_X + (i - 1) * NP_ADV, NP_TEXT_Y, 32)
		NpAdd(D)
		np_digits += D
	// caret is a baked bar
	np_caret = new
	np_caret.icon = 'HUD/np_caret.png'
	np_caret.layer = NP_LAYER + 0.65
	NpAdd(np_caret)
	NpMkButton("ok", "CONFIRM", "#78eb78", 11, 82)
	NpMkButton("no", "CANCEL", "#ff6464", 113, 82)
	NpText(0, 116, NP_W, 12, "<center><span style=\"[NP_FONT_BODY]; color:#7a9bb5\">ENTER confirm - ESC cancel</span></center>")
	NumPromptMacros()
	NumPromptRefresh()
	spawn(1) NumPromptBlink()

client/proc/NpMkButton(action, label, tcol, dx, dyTop)
	var/atom/movable/shud/npbtn/b = new
	b.icon = 'HUD/np_btn.png'
	b.action = action
	b.screen_loc = NPloc(dx, dyTop, 24)
	NpAdd(b)
	NpText(dx, dyTop + 4, 100, 16, "<center><span style=\"[NP_FONT]; color:[tcol]\">[label]</span></center>", 0.62)

client/proc/NumPromptRefresh()
	if(!np_open) return
	// slide the window so the cursor stays visible
	var/L = length(np_val)
	np_cursor = clamp(np_cursor, 0, L)
	if(np_cursor < np_win) np_win = np_cursor
	if(np_cursor > np_win + NP_VIEW) np_win = np_cursor - NP_VIEW
	np_win = clamp(np_win, 0, max(0, L - NP_VIEW))
	if(np_digits)
		for(var/i = 1 to NP_VIEW)
			var/atom/movable/shud/nptext/D = np_digits[i]
			var/bi = np_win + i
			D.maptext = (bi <= L) ? "<center><span style=\"[NP_FONT_BIG]; color:#ffd86b\">[html_encode(copytext(np_val, bi, bi + 1))]</span></center>" : null
	if(np_caret) np_caret.screen_loc = NPloc(NP_TEXT_X + (np_cursor - np_win) * NP_ADV - 1, 43, 20)

client/proc/NumPromptBlink()
	if(!np_open || !np_caret) return
	animate(np_caret, alpha = 0, time = 4, loop = -1)
	animate(alpha = 255, time = 4)

client/proc/NumPromptAction(action)
	switch(action)
		if("ok") NumPromptClose(1)
		if("no") NumPromptClose(0)

client/proc/NumPromptClose(confirmed)
	if(!np_open) return
	if(np_mode == "text")
		np_result = confirmed ? np_val : null   // "" is a real answer, it clears the field
	else
		np_result = (confirmed && np_val != "") ? text2num(np_val) : null
	np_open = 0
	NumPromptUnmacros()
	if(np_hud)
		for(var/atom/movable/o in np_hud)
			screen -= o
			del o
	np_hud = null
	np_digits = null
	np_caret = null

// dragging

client/proc/NpPanBounds()
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	var/bx = (np_atx - 1) * 32
	var/by = (np_aty - 1) * 32
	var/minx = -bx; if(minx > 0) minx = 0
	var/maxx = vw * 32 - NP_W - bx; if(maxx < 0) maxx = 0
	var/miny = -by; if(miny > 0) miny = 0
	var/maxy = vh * 32 - NP_H - by; if(maxy < 0) maxy = 0
	return list(minx, maxx, miny, maxy)

client/proc/NpShiftLive(dpx, dpy)
	if(!dpx && !dpy) return
	if(np_hud)
		for(var/atom/movable/o in np_hud)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)

client/proc/NpPanelStart(params)
	np_pan_dragged = 0
	var/list/m = MouseAbs(params)
	if(!m) return
	np_pan_mx = m[1]; np_pan_my = m[2]
	np_pan_ox = np_pan_x; np_pan_oy = np_pan_y

client/proc/NpPanelMove(params)
	if(!np_open) return
	var/list/m = MouseAbs(params)
	if(!m) return
	var/list/b = NpPanBounds()
	var/wantx = clamp(np_pan_ox + (m[1] - np_pan_mx), b[1], b[2])
	var/wanty = clamp(np_pan_oy + (m[2] - np_pan_my), b[3], b[4])
	var/dx = wantx - np_pan_x
	var/dy = wanty - np_pan_y
	if(!dx && !dy) return
	np_pan_x = wantx; np_pan_y = wanty
	np_pan_dragged = 1
	NpShiftLive(dx, dy)

client/proc/NpPanelEnd()
	if(!np_pan_dragged) return
	np_pan_dragged = 0
	setPref("npPanX", np_pan_x)
	setPref("npPanY", np_pan_y)

// key capture

/proc/NpKeys(text_mode = 0)
	var/list/L = list("RETURN", "ESCAPE", "BACK", "EAST", "WEST")
	for(var/i = 0 to 9)
		L += "[i]"
		L += "NUMPAD[i]"
	if(text_mode)
		L += "SPACE"
		L += "NORTH"   // no walking off mid-word
		L += "SOUTH"
		for(var/c = 97 to 122)
			L += uppertext(ascii2text(c))
			L += "SHIFT+[uppertext(ascii2text(c))]"
		var/list/P = NpPunct()
		for(var/tok in P)
			L += P[tok]
		var/list/SP = NpShiftPunct()
		for(var/tok in SP)
			L += "SHIFT+[SP[tok][1]]"
	return L

/proc/NpPunct()
	return list("dash" = "-", "eq" = "=", "comma" = ",", "dot" = ".", "apos" = "'", "semi" = ";", "slash" = "/")

/proc/NpShiftPunct()
	return list(\
		"bang" = list("1", "!"), "at" = list("2", "@"), "hash" = list("3", "#"), \
		"dollar" = list("4", "$"), "pct" = list("5", "%"), "caret" = list("6", "^"), \
		"amp" = list("7", "&"), "star" = list("8", "*"), "lparen" = list("9", "("), \
		"rparen" = list("0", ")"), "under" = list("-", "_"), "plus" = list("=", "+"), \
		"lt" = list(",", "<"), "gt" = list(".", ">"), "quote" = list("'", "\""), \
		"colon" = list(";", ":"), "quest" = list("/", "?"))

client/proc/NpMacroSet()
	for(var/k in params2list(winget(src, null, "macro")))
		return k
	return "macro"

client/proc/NumPromptMacros()
	var/set_name = NpMacroSet()
	// park any player bind sitting on a prompt key
	var/list/npkeys = NpKeys(np_mode == "text")
	if(mob)
		mob.initShortcuts()
		BuildKeybindRegistry()
		for(var/datum/keyaction/a in keybind_registry)
			for(var/s = 1 to 2)
				var/key = mob.KeybindKey(a.id, s)
				if(key && (uppertext(key) in npkeys))
					ApplyOneBind(set_name, "kb_[a.id]_[s]", "", a.command, a.kind, a.id)
		if(mob.shortcuts && mob.shortcuts.keybinds)
			for(var/sk in mob.shortcuts.keybinds)
				if(copytext(sk, 1, 6) != "misc:") continue
				var/key = mob.shortcuts.keybinds[sk]
				if(!key || !(uppertext(key) in npkeys)) continue
				var/body = copytext(sk, 6)
				var/slot = 1
				if(length(body) > 2 && copytext(body, length(body) - 1) == "@2")
					slot = 2
					body = copytext(body, 1, length(body) - 1)
				ApplyOneBind(set_name, "kbm_[NormalizeSkillName(body)]_[slot]", "", null, 0, null)
	for(var/i = 0 to 9)
		ApplyOneBind(set_name, "np_d[i]", "[i]", "NumPromptKey [i]", 0, null, 1)
		ApplyOneBind(set_name, "np_n[i]", "NUMPAD[i]", "NumPromptKey [i]", 0, null, 1)
	ApplyOneBind(set_name, "np_bak", "BACK", "NumPromptBack", 0, null, 1)
	ApplyOneBind(set_name, "np_lft", "WEST", "NumPromptLeft", 0, null, 1)
	ApplyOneBind(set_name, "np_rgt", "EAST", "NumPromptRight", 0, null, 1)
	if(np_mode == "text")
		for(var/c = 97 to 122)
			var/ch = ascii2text(c)
			ApplyOneBind(set_name, "np_c_[ch]", uppertext(ch), "NumPromptChar [ch]", 0, null, 1)
			ApplyOneBind(set_name, "np_cs_[ch]", "SHIFT+[uppertext(ch)]", "NumPromptChar [uppertext(ch)]", 0, null, 1)
		var/list/punct = NpPunct()
		for(var/tok in punct)
			ApplyOneBind(set_name, "np_p_[tok]", punct[tok], "NumPromptChar [tok]", 0, null, 1)
		var/list/shifted = NpShiftPunct()
		for(var/tok in shifted)
			ApplyOneBind(set_name, "np_s_[tok]", "SHIFT+[shifted[tok][1]]", "NumPromptChar [tok]", 0, null, 1)
		ApplyOneBind(set_name, "np_spc", "SPACE", "NumPromptChar space", 0, null, 1)
	ApplyOneBind(set_name, "np_ret", "RETURN", "NumPromptOk", 0, null)
	ApplyOneBind(set_name, "np_esc", "ESCAPE", "NumPromptNo", 0, null)
	MapFocus()   // macros are mute without map focus

client/proc/NumPromptUnmacros()
	var/set_name = NpMacroSet()
	for(var/i = 0 to 9)
		ApplyOneBind(set_name, "np_d[i]", "", null, 0, null)
		ApplyOneBind(set_name, "np_n[i]", "", null, 0, null)
	for(var/c = 97 to 122)
		ApplyOneBind(set_name, "np_c_[ascii2text(c)]", "", null, 0, null)
		ApplyOneBind(set_name, "np_cs_[ascii2text(c)]", "", null, 0, null)
	for(var/tok in NpPunct())
		ApplyOneBind(set_name, "np_p_[tok]", "", null, 0, null)
	for(var/tok in NpShiftPunct())
		ApplyOneBind(set_name, "np_s_[tok]", "", null, 0, null)
	ApplyOneBind(set_name, "np_spc", "", null, 0, null)
	ApplyOneBind(set_name, "np_ret", "", null, 0, null)
	ApplyOneBind(set_name, "np_esc", "", null, 0, null)
	ApplyOneBind(set_name, "np_bak", "", null, 0, null)
	ApplyOneBind(set_name, "np_lft", "", null, 0, null)
	ApplyOneBind(set_name, "np_rgt", "", null, 0, null)
	ApplyKeybinds()

client/proc/NpRepOk(k)
	var/now = world.time
	var/streak = (np_rep_key == k && now - np_rep_seen <= 3)
	np_rep_seen = now
	if(!streak)
		np_rep_key = k
		np_rep_since = now
		np_rep_last = now
		return 1
	if(now - np_rep_since < 5) return 0    // initial hold delay
	if(now - np_rep_last < 1) return 0     // repeat rate
	np_rep_last = now
	return 1

// macro-fired verbs
mob/verb/NumPromptKey(k as text)
	set hidden = 1
	if(!client || !client.np_open) return
	if(length(k) != 1 || k < "0" || k > "9") return
	if(!client.NpRepOk("d[k]")) return
	if(length(client.np_val) >= NP_MAXLEN) return
	// edit as plain text
	client.np_val = copytext(client.np_val, 1, client.np_cursor + 1) + k + copytext(client.np_val, client.np_cursor + 1)
	client.np_cursor++
	client.NumPromptRefresh()

mob/verb/NumPromptChar(c as text)
	set hidden = 1
	if(!client || !client.np_open || client.np_mode != "text") return
	var/ch = ""
	if(c == "space") ch = " "
	else if(length(c) == 1 && ((c >= "a" && c <= "z") || (c >= "A" && c <= "Z"))) ch = c
	else
		var/list/punct = NpPunct()
		if(c in punct) ch = punct[c]
		else
			var/list/shifted = NpShiftPunct()
			if(c in shifted) ch = shifted[c][2]
	if(!ch) return
	if(!client.NpRepOk("c[ch]")) return
	if(length(client.np_val) >= NP_MAXLEN) return
	client.np_val = copytext(client.np_val, 1, client.np_cursor + 1) + ch + copytext(client.np_val, client.np_cursor + 1)
	client.np_cursor++
	client.NumPromptRefresh()

mob/verb/NumPromptBack()
	set hidden = 1
	if(!client || !client.np_open) return
	if(!client.NpRepOk("bak")) return
	if(client.np_cursor <= 0) return
	client.np_val = copytext(client.np_val, 1, client.np_cursor) + copytext(client.np_val, client.np_cursor + 1)
	client.np_cursor--
	client.NumPromptRefresh()

mob/verb/NumPromptLeft()
	set hidden = 1
	if(!client || !client.np_open) return
	if(!client.NpRepOk("lft")) return
	client.np_cursor = max(0, client.np_cursor - 1)
	client.NumPromptRefresh()

mob/verb/NumPromptRight()
	set hidden = 1
	if(!client || !client.np_open) return
	if(!client.NpRepOk("rgt")) return
	client.np_cursor = min(length(client.np_val), client.np_cursor + 1)
	client.NumPromptRefresh()

mob/verb/NumPromptOk()
	set hidden = 1
	if(!client || !client.np_open) return
	client.NumPromptClose(1)

mob/verb/NumPromptNo()
	set hidden = 1
	if(!client || !client.np_open) return
	client.NumPromptClose(0)
