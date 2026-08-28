#define HOTBAR_SLOTS 12

#define STYLE_PATH /obj/Skills/Buffs/NuStyle

var/list/HOTBAR_DEFAULT_KEYS = list("1","2","3","4","5","6","7","8","9","0","-","=")

var/list/SKILLMENU_EXCLUDE = list("Heavy Strike", "Dragon Dash", "After Image Strike", "Pose", "Normal Attack", "Power Up", "Power Down", "Reverse Dash", "Zanzoken", "Grab", "Target Switch", "Toggle Style", "Toss")

#define KB_NORMAL 0
#define KB_MOVE   1
#define KB_HOTBAR 2   // +UP release only if the slotted skill is a held skill
#define KB_INTERACT 3 // +UP always bound so hold-minigames see the release
#define KB_HOLD   4   // hold-type action: +UP always bound, "-up" suffix like KB_MOVE

/datum/keyaction
	var/id
	var/label
	var/command
	var/defkey
	var/defkey2
	var/category
	var/kind = KB_NORMAL
	var/rep = 0      // command repeats while the key is held (+REP macro)
	New(_id, _label, _command, _defkey, _category, _kind = KB_NORMAL, _defkey2 = "", _rep = 0)
		id = _id; label = _label; command = _command; defkey = _defkey; category = _category; kind = _kind; defkey2 = _defkey2; rep = _rep

var/global/list/keybind_registry
var/global/list/keybind_by_id = list()

/proc/BuildKeybindRegistry()
	if(keybind_registry) return keybind_registry
	keybind_registry = list()
	var/list/R = keybind_registry
	R += new/datum/keyaction("north", "Move Up",    "north", "W", "Movement", KB_MOVE, "North")
	R += new/datum/keyaction("west",  "Move Left",  "west",  "A", "Movement", KB_MOVE, "West")
	R += new/datum/keyaction("south", "Move Down",  "south", "S", "Movement", KB_MOVE, "South")
	R += new/datum/keyaction("east",  "Move Right", "east",  "D", "Movement", KB_MOVE, "East")
	R += new/datum/keyaction("normalattack","Normal Attack",      "Normal-Attack",      "Space","Combat", KB_NORMAL, "", 1)
	R += new/datum/keyaction("zanzoken",    "Zanzoken",            "Zanzoken",           "Z",   "Combat")
	R += new/datum/keyaction("afterimagestrike", "After Image Strike", "After-Image-Strike", "B", "Combat")
	R += new/datum/keyaction("heavystrike", "Heavy Strike",        "Heavy-Strike",       "X",   "Combat", KB_HOLD)
	R += new/datum/keyaction("grab",        "Grab",                "Grab",               "C",   "Combat")
	R += new/datum/keyaction("toss",        "Toss",                "Toss",               "V",   "Combat")
	R += new/datum/keyaction("dragondash",  "Dragon Dash",         "Dragon-Dash",        "Q",   "Combat")
	R += new/datum/keyaction("reversedash", "Reverse Dash",        "Reverse-Dash",       "E",   "Combat")
	R += new/datum/keyaction("guard",       "Guard",               "Guard",              "H",   "Combat", KB_HOLD)
	R += new/datum/keyaction("charge",      "Energy Charge",       "Charge",             "N",   "Combat", KB_HOLD)
	R += new/datum/keyaction("powerup",     "Power Up",            "Power-Up",           "R",   "Combat")
	R += new/datum/keyaction("powerdown",   "Power Down",          "Power-Down",         "F",   "Combat")
	R += new/datum/keyaction("pose",        "Pose",                "Pose",               "T",   "Combat")
	R += new/datum/keyaction("targetswitch","Target Switch",       "Target-Switch",      "Tab", "Combat")
	R += new/datum/keyaction("togglestyle", "Toggle Style",        "Toggle-Style",       "P",   "Combat")
	R += new/datum/keyaction("sense",       "Sense",               "Sense",              "O",   "Combat")
	R += new/datum/keyaction("meditate",    "Meditate",            "Meditation",         "M",   "Combat")
	R += new/datum/keyaction("autoattack",  "Auto Attack",         "Auto-Attack",        "CTRL+Space", "Combat")
	R += new/datum/keyaction("seetargets",  "See Target's Target", "See-Targets-Target", "`",   "Combat")
	R += new/datum/keyaction("interact",    "Interact",            "Interact",           "G",   "Combat", KB_INTERACT)
	R += new/datum/keyaction("say",         "Say",                "Say",                "", "Communication")
	R += new/datum/keyaction("ooc",         "OOC",                "OOC",                "", "Communication")
	R += new/datum/keyaction("whisper",     "Whisper",            "Whisper",            "", "Communication")
	R += new/datum/keyaction("think",       "Think",              "Think",              "", "Communication")
	R += new/datum/keyaction("emote",       "Emote",              "Emote",              "", "Communication")
	R += new/datum/keyaction("countdown",   "Countdown",          "Countdown",          "", "Communication")
	R += new/datum/keyaction("intentrp",    "Intent to Roleplay", "Intent-to-Roleplay", "", "Communication")
	R += new/datum/keyaction("intentinjure","Intent to Injure",   "Intent-to-Injure",   "", "Communication")
	R += new/datum/keyaction("intentkill",  "Intent to Kill",     "Intent-to-Kill",     "", "Communication")
	for(var/i = 1 to HOTBAR_SLOTS)
		R += new/datum/keyaction("hotbar[i]", "Hotbar Slot [i]", "Skill-Shortcut-[i]", HOTBAR_DEFAULT_KEYS[i], "Hotbar", KB_HOTBAR)
	for(var/datum/keyaction/a in R)
		keybind_by_id[a.id] = a
	return keybind_registry

// slot 1 = primary, 2 = secondary; explicit override wins ("" = unbound), stored as id / id@2
/mob/proc/KeybindKey(action_id, slot = 1)
	initShortcuts()
	var/sk = (slot == 2) ? "[action_id]@2" : action_id
	if(shortcuts.keybinds && (sk in shortcuts.keybinds))
		return shortcuts.keybinds[sk]
	BuildKeybindRegistry()
	var/datum/keyaction/a = keybind_by_id[action_id]
	if(!a) return ""
	return (slot == 2) ? a.defkey2 : a.defkey

/mob/proc/SetKeybind(action_id, slot, key)
	initShortcuts()
	if(!shortcuts.keybinds) shortcuts.keybinds = list()
	var/sk = (slot == 2) ? "[action_id]@2" : action_id
	shortcuts.keybinds[sk] = key

// pretty-print a stored key. arrow keys store as North/West but should read as Arrow Up/Left
/proc/KeyDisplay(key)
	if(!key) return "(unbound)"
	key = replacetext(key, "North", "Arrow Up")
	key = replacetext(key, "South", "Arrow Down")
	key = replacetext(key, "West", "Arrow Left")
	key = replacetext(key, "East", "Arrow Right")
	return key

/proc/HotbarMacroName(key, suffix = "")
	if(findtext(key, "=") || findtext(key, ";"))
		return "\"[key][suffix]\""
	return "[key][suffix]"

// keydown plus the +UP release for movement and held hotbar skills; empty key parks the macros
client/proc/MacroCmd(command)
	return findtext(command, " ") ? "\"[command]\"" : command

client/proc/ApplyOneBind(set_name, eid, key, command, kind, regid, rep = 0)
	var/uid = "[eid]_up"
	var/rid = "[eid]_rep"
	if(!key)
		winset(src, eid, "type=macro;parent=[set_name];name=off_[eid]")
		winset(src, uid, "type=macro;parent=[set_name];name=off_[eid]_up")
		winset(src, rid, "type=macro;parent=[set_name];name=off_[eid]_rep")
		return
	winset(src, eid, "type=macro;parent=[set_name];name=[HotbarMacroName(key)];command=[MacroCmd(command)]")
	if(rep)
		winset(src, rid, "type=macro;parent=[set_name];name=[HotbarMacroName(key, "+REP")];command=[MacroCmd(command)]")
	else
		winset(src, rid, "type=macro;parent=[set_name];name=off_[eid]_rep")
	if(kind == KB_MOVE || kind == KB_HOLD)
		winset(src, uid, "type=macro;parent=[set_name];name=[HotbarMacroName(key, "+UP")];command=[command]-up")
		return
	if(kind == KB_INTERACT)
		winset(src, uid, "type=macro;parent=[set_name];name=[HotbarMacroName(key, "+UP")];command=Interact-Release")
		return
	if(kind == KB_HOTBAR && regid)
		var/n = text2num(copytext(regid, 7))   // "hotbarN" -> N
		var/obj/Skills/s = mob.shortcuts.vars["shortcut[n]"]
		if(s && s.HeldSkill)
			winset(src, uid, "type=macro;parent=[set_name];name=[HotbarMacroName(key, "+UP")];command=Release-Held-Skill")
			return
	winset(src, uid, "type=macro;parent=[set_name];name=off_[eid]_up")

/proc/KbKeyElemId(key)
	var/id = "kmac"
	for(var/i = 1 to length(key))
		id += "_[text2ascii(key, i)]"
	return id

// bind one physical key to a command (+ its +UP / +REP siblings, per kind/rep)
client/proc/KbWriteKey(set_name, key, command, kind, regid, rep)
	var/eid = KbKeyElemId(key)
	winset(src, eid, "type=macro;parent=[set_name];name=[HotbarMacroName(key)];command=[MacroCmd(command)]")
	if(rep)
		winset(src, "[eid]_rep", "type=macro;parent=[set_name];name=[HotbarMacroName(key, "+REP")];command=[MacroCmd(command)]")
	else
		winset(src, "[eid]_rep", "type=macro;parent=[set_name];name=[HotbarMacroName(key, "+REP")];command=")
	var/up_cmd = null
	switch(kind)
		if(KB_MOVE)     up_cmd = "[command]-up"
		if(KB_HOLD)     up_cmd = "[command]-up"
		if(KB_INTERACT) up_cmd = "Interact-Release"
		if(KB_HOTBAR)
			if(regid)
				var/n = text2num(copytext(regid, 7))   // "hotbarN" -> N
				var/obj/Skills/s = mob.shortcuts.vars["shortcut[n]"]
				if(s && s.HeldSkill) up_cmd = "Release-Held-Skill"
	if(up_cmd)
		winset(src, "[eid]_up", "type=macro;parent=[set_name];name=[HotbarMacroName(key, "+UP")];command=[MacroCmd(up_cmd)]")
	else
		winset(src, "[eid]_up", "type=macro;parent=[set_name];name=[HotbarMacroName(key, "+UP")];command=")

// park a key: the element stays, its command goes empty
client/proc/KbClearKey(set_name, key)
	var/eid = KbKeyElemId(key)
	winset(src, eid, "type=macro;parent=[set_name];name=[HotbarMacroName(key)];command=")
	winset(src, "[eid]_up", "type=macro;parent=[set_name];name=[HotbarMacroName(key, "+UP")];command=")
	winset(src, "[eid]_rep", "type=macro;parent=[set_name];name=[HotbarMacroName(key, "+REP")];command=")

// physical keys bound on the last ApplyKeybinds, so newly-freed keys get cleared
/client/var/tmp/list/kb_live_keys

client/proc/ApplyKeybinds()
	if(!mob) return
	mob.initShortcuts()
	BuildKeybindRegistry()
	if(mob.shortcuts.keybinds && mob.shortcuts.keybinds.len)
		var/list/ownedkeys = list()
		for(var/sk in mob.shortcuts.keybinds)
			var/kv = mob.shortcuts.keybinds[sk]
			if(kv) ownedkeys[kv] = sk
		for(var/datum/keyaction/a in keybind_registry)
			for(var/s = 1 to 2)
				var/sk = (s == 2) ? "[a.id]@2" : a.id
				if(sk in mob.shortcuts.keybinds) continue
				var/key = (s == 2) ? a.defkey2 : a.defkey
				if(key && ownedkeys[key])
					mob.SetKeybind(a.id, s, "")
					mob << "Your custom [KeyDisplay(key)] bind keeps its key, [a.label] is unbound. Give it a key in Keybinds."
	var/set_name = "macro"
	for(var/k in params2list(winget(src, null, "macro")))
		set_name = k
		break
	// collect the desired bind for each physical key (key -> list(command, kind, regid, rep))
	var/list/desired = list()
	// diagonals first so a (practically impossible) player collision would still win below
	for(var/dd in list("Northeast", "Northwest", "Southeast", "Southwest"))
		desired[dd] = list(lowertext(dd), KB_MOVE, null, 0)
	for(var/datum/keyaction/a in keybind_registry)
		for(var/s = 1 to 2)
			var/key = mob.KeybindKey(a.id, s)
			if(!key) continue
			desired[key] = list(a.command, a.kind, a.id, a.rep)
	// misc binds: any non-skill verb the player chose, stored as "misc:<command>" with optional @2 for slot 2
	if(mob.shortcuts.keybinds)
		for(var/sk in mob.shortcuts.keybinds)
			if(copytext(sk, 1, 6) != "misc:") continue
			var/mkey = mob.shortcuts.keybinds[sk]
			if(!mkey) continue
			var/body = copytext(sk, 6)
			if(length(body) > 2 && copytext(body, length(body) - 1) == "@2")
				body = copytext(body, 1, length(body) - 1)
			desired[mkey] = list("RunVerb [body]", KB_NORMAL, null, 0)
	var/list/newlive = list()
	for(var/key in desired)
		var/list/e = desired[key]
		KbWriteKey(set_name, key, e[1], e[2], e[3], e[4])
		newlive[key] = 1
	// any key bound last time but not this time gets its command cleared so it stops firing
	if(kb_live_keys)
		for(var/key in kb_live_keys)
			if(newlive[key]) continue
			KbClearKey(set_name, key)
	kb_live_keys = newlive
	// an open number prompt re-asserts its key overlay on top of whatever was just written
	if(np_open) NumPromptMacros()

var/global/datum/keybind_menu/keybind_menu = new()

/datum/keybind_menu/Topic(href, list/href_list)
	if(!usr || !usr.client) return
	var/act = href_list["action"]
	if(act == "reset")
		usr.initShortcuts()
		usr.shortcuts.keybinds = list()
		usr.client.ApplyKeybinds()
		usr.client.RefreshHotbar()
		usr.client.OpenKeybindMenu()   // redraw so every key shows its default
		return
	if(act == "resetone")            // revert one action to its defaults by dropping its overrides
		var/rid = href_list["id"]
		if(rid)
			usr.initShortcuts()
			if(usr.shortcuts.keybinds)
				usr.shortcuts.keybinds -= rid
				usr.shortcuts.keybinds -= "[rid]@2"
			usr.client.ApplyKeybinds()
			usr.client.RefreshHotbar()
			usr.client.OpenKeybindMenu()
		return
	var/id = href_list["id"]
	var/slot = text2num(href_list["slot"]) || 1
	if(act == "rebind")
		var/key = href_list["key"]
		if(id && key)
			usr.ClearKeybindKey(key, id, slot)   // a key only ever drives one action+slot
			usr.SetKeybind(id, slot, key)
	else if(act == "unbind")
		if(id) usr.SetKeybind(id, slot, "")
	usr.client.ApplyKeybinds()
	usr.client.RefreshHotbar()

// clear a key off every other action+slot (registry and misc) so it never double-fires
/mob/proc/ClearKeybindKey(key, keepid, keepslot)
	if(!key) return
	initShortcuts()
	BuildKeybindRegistry()
	for(var/datum/keyaction/a in keybind_registry)
		for(var/s in 1 to 2)
			if(a.id == keepid && s == keepslot) continue
			if(KeybindKey(a.id, s) == key) SetKeybind(a.id, s, "")
	if(shortcuts.keybinds)
		var/keepsk = (keepslot == 2) ? "[keepid]@2" : keepid
		for(var/sk in shortcuts.keybinds)
			if(copytext(sk, 1, 6) != "misc:") continue
			if(sk == keepsk) continue
			if(shortcuts.keybinds[sk] == key) shortcuts.keybinds[sk] = ""

/mob/verb/Keybinds()
	set category = "Utility"
	set hidden = 1
	set name = "Keybinds"
	if(client) client.OpenKeybindMenu()

client/proc/OpenKeybindMenu()
	if(!mob) return
	mob << browse(KeybindMenuHTML(), "window=keybinds;size=620x640")

// verbs for the Misc section
client/proc/MiscVerbs()
	BuildKeybindRegistry()
	if(mob) mob.CollectMenuVerbs()   // refresh so newly-granted Other/Utility verbs are bindable too
	var/list/reg = list()
	for(var/datum/keyaction/a in keybind_registry)
		reg[a.command] = 1
	var/list/out = list()
	var/list/srcs = list()
	for(var/v in mob.verbs) srcs += v
	if(mob.hud_menu_verbs) for(var/v in mob.hud_menu_verbs) srcs += v
	for(var/v in srcs)
		if(!v) continue
		if(v:category != "Other" && v:category != "Utility") continue
		var/nm = "[v:name]"
		if(reg[replacetext(replacetext(nm, " ", "-"), "_", "-")]) continue
		out[nm] = nm
	for(var/obj/Skills/Buffs/b in mob.contents)
		if(b.TimerLimit && !b.MiscBindable) continue   // timed buffs go in the hotbar
		if(!b.fire_ident) continue   // non-timed buffs are now stripped, their verb name lives in fire_ident
		var/nm = replacetext(b.fire_ident, "_", " ")
		if(reg[replacetext(replacetext(nm, " ", "-"), "_", "-")]) continue
		out[nm] = nm
	return out

/mob/verb/RunVerb(cmd as text)
	set hidden = 1
	set instant = 1
	if(!cmd) return
	for(var/v in verbs)
		if(v && "[v:name]" == cmd)
			call(src, v)()
			return
	for(var/v in hud_menu_verbs)
		if(v && "[v:name]" == cmd)
			call(src, v)()
			return
	for(var/v in hud_customize_verbs)
		if(v && "[v:name]" == cmd)
			call(src, v)()
			return
	for(var/obj/Skills/sk in contents)
		for(var/v in sk.verbs)
			if(v && "[v:name]" == cmd)
				call(sk, v)()
				return
	// fire them by their saved fire_ident
	var/nc = NormalizeSkillName(cmd)
	for(var/obj/Skills/sk in contents)
		if(sk.fire_ident && NormalizeSkillName(sk.fire_ident) == nc && hascall(sk, sk.fire_ident))
			call(sk, sk.fire_ident)()
			return

// one table row: label, primary key box, secondary key box. aid is the action id (or misc:<command>).
client/proc/KeybindRow(aid, label)
	var/k1 = mob.KeybindKey(aid, 1)
	var/k2 = mob.KeybindKey(aid, 2)
	var/d1 = k1 ? KeyDisplay(k1) : "(unbound)"
	var/d2 = k2 ? KeyDisplay(k2) : "(unbound)"
	var/sid = NormalizeSkillName(aid)
	var/e1 = "kb_[sid]_1"
	var/e2 = "kb_[sid]_2"
	return {"<tr><td class='lbl'>[label]</td><td class='kc'><span class='kb' id='[e1]' data-k="[k1]" onclick='rb("[e1]","[aid]",1)'>[d1]</span><span class='ub' onclick='ub("[e1]","[aid]",1)'>x</span></td><td class='kc'><span class='kb' id='[e2]' data-k="[k2]" onclick='rb("[e2]","[aid]",2)'>[d2]</span><span class='ub' onclick='ub("[e2]","[aid]",2)'>x</span></td><td class='rc'><span class='rl' onclick='ro("[aid]")'>reset</span></td></tr>"}

client/proc/KeybindMenuHTML()
	BuildKeybindRegistry()
	var/r = "\ref[keybind_menu]"
	var/rows = ""
	var/lastcat = ""
	for(var/datum/keyaction/a in keybind_registry)
		if(a.category != lastcat)
			rows += {"<tr><td colspan='4' class='cat'>[a.category]</td></tr>"}
			lastcat = a.category
		rows += KeybindRow(a.id, a.label)
	var/list/misc = MiscVerbs()
	if(misc.len)
		rows += {"<tr><td colspan='4' class='cat'>Misc</td></tr>"}
		for(var/cmd in misc)
			rows += KeybindRow("misc:[cmd]", misc[cmd])
	return {"<html><head><style>
body{background:#0a1420;color:#cfe9ff;font-family:Verdana,Arial,sans-serif;font-size:12px;margin:0;padding:8px;}
h1{color:#8be9ff;font-size:15px;margin:2px 0 4px;text-align:center;letter-spacing:2px;}
.hint{color:#7a9bb5;font-size:10px;text-align:center;margin-bottom:6px;}
table{width:100%;border-collapse:collapse;}
.hd{color:#8be9ff;font-size:11px;text-align:center;padding:2px;border-bottom:1px solid #2a4a5a;}
.lbl{padding:3px 6px;}
.kc{text-align:center;padding:3px 4px;white-space:nowrap;}
.kb{display:inline-block;background:#16263a;color:#cfe9ff;border:1px solid #3a5a70;padding:2px 6px;min-width:96px;text-align:center;cursor:pointer;}
.ub{display:inline-block;color:#ff6b6b;cursor:pointer;padding:0 6px;font-weight:bold;}
.cat{color:#8be9ff;font-weight:bold;border-bottom:1px solid #2a4a5a;padding:9px 6px 2px;}
.rs{display:block;width:170px;margin:14px auto 6px;background:#3a1a1a;color:#ffb0b0;border:1px solid #6a2a2a;padding:6px;text-align:center;cursor:pointer;}
.rc{text-align:center;padding:3px 4px;}
.rl{color:#7a9bb5;cursor:pointer;font-size:10px;text-decoration:underline;}
</style></head><body>
<h1>KEYBINDS</h1>
<div class='hint'>click a key box then press the new key, or a combo like CTRL+W. esc cancels, x clears.</div>
<table><tr><th class='hd'>Action</th><th class='hd'>Primary</th><th class='hd'>Secondary</th><th class='hd'></th></tr>[rows]</table>
<div class='rs' onclick='rst()'>Reset to Defaults</div>
<script>
var ref='[r]';var w=null;
function go(a){location.href='byond://?src='+ref+a;}
function dk(k){if(!k)return '(unbound)';k=k.replace('North','Arrow Up');k=k.replace('South','Arrow Down');k=k.replace('West','Arrow Left');k=k.replace('East','Arrow Right');return k;}
function setbtn(el,raw){el.setAttribute('data-k',raw);el.innerHTML=dk(raw);el.style.background='#16263a';el.style.color='#cfe9ff';}
function rb(eid,aid,slot){
 if(w){var p=document.getElementById(w.eid);if(p)setbtn(p,p.getAttribute('data-k'));}
 w={eid:eid,aid:aid,slot:slot};
 var el=document.getElementById(eid);el.innerHTML='press a key';el.style.background='#8be9ff';el.style.color='#0a1420';
}
function ub(eid,aid,slot){var el=document.getElementById(eid);if(el)setbtn(el,'');go(';action=unbind;id='+encodeURIComponent(aid)+';slot='+slot);}
function rst(){go(';action=reset');}
function ro(aid){go(';action=resetone;id='+encodeURIComponent(aid));}
function clr(k,exeid){var s=document.getElementsByTagName('span');for(var i=0;i<s.length;i++){var x=s\[i\];if(x.className=='kb'&&x.id!=exeid&&x.getAttribute('data-k')==k)setbtn(x,'');}}
function mk(e){
 var c=e.keyCode;
 if(c==16||c==17||c==18||c==91||c==92||c==93||c==20||c==144)return '';
 if(c==27)return 'CANCEL';
 var b='';
 if(c>=65&&c<=90)b=String.fromCharCode(c);
 else if(c>=48&&c<=57)b=String.fromCharCode(c);
 else if(c>=96&&c<=105)b='Numpad'+(c-96);
 else if(c>=112&&c<=123)b='F'+(c-111);
 else{var m={32:'Space',9:'Tab',13:'Return',8:'Backspace',37:'West',38:'North',39:'East',40:'South',45:'Insert',46:'Delete',36:'Home',35:'End',33:'PageUp',34:'PageDown',106:'NumpadStar',107:'NumpadPlus',109:'NumpadMinus',111:'NumpadSlash',110:'NumpadPeriod',186:';',187:'=',188:',',189:'-',190:'.',191:'/',192:'`'};b=m\[c\]||'';}
 if(b=='')return '';
 var p='';if(e.ctrlKey)p+='CTRL+';if(e.shiftKey)p+='SHIFT+';if(e.altKey)p+='ALT+';
 return p+b;
}
document.onkeydown=function(e){
 if(!w)return true;
 e=e||window.event;var k=mk(e);
 if(k=='')return false;
 var ctx=w;w=null;var el=document.getElementById(ctx.eid);
 if(k=='CANCEL'){if(el)setbtn(el,el.getAttribute('data-k'));return false;}
 clr(k,ctx.eid);if(el)setbtn(el,k);
 go(';action=rebind;id='+encodeURIComponent(ctx.aid)+';slot='+ctx.slot+';key='+encodeURIComponent(k));
 return false;
};
</script>
</body></html>"}

#define SKILL_ICON_FILE 'HUD/SkillIcons.dmi'

// per-type fallback for skills with no MenuIcon
/proc/SKILL_TYPE_ICON(obj/Skills/S)
	if(istype(S, /obj/Skills/Projectile)) return 'HUD/skill_projectile.png'
	if(istype(S, /obj/Skills/Queue))      return 'HUD/skill_queue.png'
	if(istype(S, /obj/Skills/Grapple))    return 'HUD/skill_grapple.png'
	if(istype(S, /obj/Skills/Buffs))      return 'HUD/skill_buff.png'
	if(istype(S, /obj/Skills/AutoHit))    return 'HUD/skill_autohit.png'
	return 'HUD/skill_autohit.png'

/proc/SkillMenuIcon(obj/Skills/S)
	if(!S) return null
	if(S.MenuIcon) return SKILL_ICON_FILE
	return SKILL_TYPE_ICON(S)

/proc/SkillMenuIconState(obj/Skills/S)
	if(!S) return null
	return S.MenuIcon

/proc/SkillHasSkillVerb(obj/Skills/S)
	if(!S) return 0
	if(S.fire_ident) return 1   // verb stripped for hotbar-only use, fire_ident is the marker
	for(var/v in S.verbs)
		if(!v) continue
		if(v:category == "Skills") return 1
	return 0

/obj/Skills/proc/DisableSkillVerb()
	if(!SkillMenuVisible(src)) return
	for(var/v in verbs)
		if(!v || v:category != "Skills") continue
		fire_ident = replacetext(replacetext("[v:name]", " ", "_"), "-", "_")
		verbs -= v
		break

/mob/proc/DisableSlottableSkillVerbs()
	for(var/obj/Skills/s in contents)
		s.DisableSkillVerb()

/obj/Skills/New()
	..()
	DisableSkillVerb()

/proc/NormalizeSkillName(name)
	if(!name) return ""
	name = lowertext("[name]")
	name = replacetext(name, " ", "")
	name = replacetext(name, "-", "")
	name = replacetext(name, "_", "")
	return name

/proc/IsCoreSkill(obj/Skills/S)
	if(!S) return 0
	var/n = NormalizeSkillName(S.name)
	for(var/e in SKILLMENU_EXCLUDE)
		if(NormalizeSkillName(e) == n) return 1
	return 0

/proc/SkillMenuType(obj/Skills/S)
	if(istype(S, /obj/Skills/Projectile)) return "Projectile"
	if(istype(S, /obj/Skills/Queue))      return "Queue"
	if(istype(S, /obj/Skills/Grapple))    return "Grapple"
	if(istype(S, /obj/Skills/Buffs))      return "Buff"
	if(istype(S, /obj/Skills/AutoHit))    return "AutoHit"
	return null

/proc/SkillMenuVisible(obj/Skills/S)
	if(!S) return 0
	if(istype(S, STYLE_PATH)) return 0
	if(istype(S, /obj/Skills/Buffs/Styles)) return 0                    // legacy styles
	if(istype(S, /obj/Skills/Buffs/SlotlessBuffs/Autonomous)) return 0  // debuffs + autonomous/finisher buffs
	if(istype(S, /obj/Skills/Buffs/ActiveBuffs/Ki_Control)) return 0    // passive Ki Control
	if(istype(S, /obj/Skills/Queue/Finisher)) return 0                  // style finishers
	if(IsCoreSkill(S)) return 0
	if(!SkillMenuType(S)) return 0
	return SkillHasSkillVerb(S)

/proc/SkillSlotFree(obj/Skills/S)
	return istype(S, /obj/Skills/Buffs)

/mob/proc/GetMenuSkills(type_filter)
	var/list/out = list()
	for(var/obj/Skills/S in contents)
		if(!SkillMenuVisible(S)) continue
		if(type_filter && type_filter != "All" && SkillMenuType(S) != type_filter)
			continue
		out += S
	return out

/obj/Skills/proc/InfoPanelLines()
	var/list/L = list()
	if(StrScaling)
		L += "Strength Scaling: [round(StrScaling * 100)]%"
	if(ForScaling)
		L += "Force Scaling: [round(ForScaling * 100)]%"
	if(MaxCharges > 0)
		L += "Charges: [Charges]/[MaxCharges] (refreshes every [ChargeRefresh]s)"
	else if(Cooldown != -1)
		L += "Cooldown: [Cooldown]s"
	else
		L += "Cooldown: On Meditate"
	if(("Damage" in vars) && vars["Damage"])
		L += "Damage: [vars["Damage"]]"
	if("Piercing" in vars)
		L += "Piercing: [vars["Piercing"] > 0 ? "Yes" : "No"]"
	if("Deflectable" in vars)
		L += "Deflectable: [vars["Deflectable"] > 0 ? "Yes" : "No"]"
	if(("Knockback" in vars) && vars["Knockback"] > 0)
		L += "Knockback: [vars["Knockback"]]"
	if(Launcher) L += "Launcher: [Launcher]"
	if(Stunner) L += "Stunner: [Stunner]"
	if(FollowUp) L += "Follow Up Move: [FollowUp]"
	if(Grapple) L += "Grapples"
	var/list/els = list()
	if(Burning) els += "Burning"
	if(Scorching) els += "Scorching"
	if(Chilling) els += "Chilling"
	if(Freezing) els += "Freezing"
	if(Crushing) els += "Crushing"
	if(Shattering) els += "Shattering"
	if(Shocking) els += "Shocking"
	if(Paralyzing) els += "Paralyzing"
	if(Poisoning) els += "Poisoning"
	if(Toxic) els += "Toxic"
	if(Shearing) els += "Shearing"
	if(Crippling) els += "Crippling"
	if(els.len) L += "Elements: [jointext(els, ", ")]"
	if(NeedsSword) L += "Requires Sword"
	if(HeavyOnly) L += "Heavy Sword Only"
	if(NoSword) L += "Unarmed Only"
	if(BuffSelf) L += "Self Buff: [BuffSelf]"
	if(BuffAffected) L += "Target Buff: [BuffAffected]"
	if(HealthCost) L += "Health Cost: [HealthCost]"
	if(WoundCost) L += "Wound Cost: [WoundCost]"
	if(EnergyCost) L += "Energy Cost: [EnergyCost]"
	if(FatigueCost) L += "Fatigue Cost: [FatigueCost]"
	if(ManaCost) L += "Mana Cost: [ManaCost]"
	if(CapacityCost) L += "Capacity Cost: [CapacityCost]"
	if(Instinct) L += "Instinct: [Instinct]"
	if(("FocusShifter" in vars) && vars["FocusShifter"] && FocusStatIdentity())
		var/selected_type = ("FocusShiftType" in vars) ? vars["FocusShiftType"] : "None"
		var/boost = ("FocusShiftBoost" in vars) ? vars["FocusShiftBoost"] : 1.5
		var/timer = ("FocusShiftTimer" in vars) ? vars["FocusShiftTimer"] : 0
		var/burstpassive = loc:passive_handler.Get("FocusShiftBurst")
		var/timerpassive = loc:passive_handler.Get("FocusShiftMastery")

		if(!selected_type || selected_type == "None")
			selected_type = FocusStatIdentity() == "STR" ? "FOR" : "STR"

		var/ftext = "Focus Shift: [selected_type] Type, [selected_type]-based skills get "
		var/stextNormal = "x[boost] "
		var/stextBoosted = "x<span style=\"color:#ffd86b\">[boost + burstpassive]</span> "

		var/pickedText = burstpassive ? stextBoosted : stextNormal
		var/ttext = "[selected_type] scaling (min 150%) "

		var/ftextNormal = "for [timer/2] secs."
		var/ftextBoosted = "for <span style=\"color:#ffd86b\">[(timer / 2) + (timerpassive / 2)]</span> secs."
		var/pickedText2 = timerpassive ? ftextBoosted : ftextNormal


		L += ftext+pickedText+ttext+pickedText2

	//	L += "Focus Shift: [selected_type] Type, [selected_type]-based skills get x[boost] [selected_type] scaling (min 150%) for [timer/2] secs."
	return L

// buff classification + info-panel lines
/proc/IsDebuffBuff(obj/Skills/Buffs/b)
	return istype(b, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff)
/proc/IsMenuBuff(obj/Skills/Buffs/b)
	return istype(b) && !b.TimerLimit && !IsDebuffBuff(b)    // non-timed, non-debuff: usable + shown in the character menu
/proc/IsStripBuff(obj/Skills/Buffs/b)
	return istype(b) && b.TimerLimit > 0 && !IsDebuffBuff(b) // timed, non-debuff: shown in the top-left strip

/proc/BuffPct(mult)
	var/pct = round((mult - 1) * 100, 1)
	return "[pct >= 0 ? "+" : ""][pct]%"
/proc/BuffStatLine(list/L, label, add, mult)
	var/txt = ""
	if(mult && mult != 1) txt += BuffPct(mult)
	if(add) txt += "[txt ? ", " : ""][add > 0 ? "+" : ""][add]"
	if(txt) L += "[label]: [txt]"

// buff stat boosts (duration + stat changes),
/obj/Skills/Buffs/proc/BuffBoostLines()
	var/list/L = list()
	if(TimerLimit > 0) L += "Duration: [round(TimerLimit)]s"
	BuffStatLine(L, "Strength", strAdd, StrMult)
	BuffStatLine(L, "Endurance", endAdd, EndMult)
	BuffStatLine(L, "Force", forAdd, ForMult)
	BuffStatLine(L, "Speed", spdAdd, SpdMult)
	BuffStatLine(L, "Offense", offAdd, OffMult)
	BuffStatLine(L, "Defense", defAdd, DefMult)
	if(PowerMult != 1) L += "Power: [BuffPct(PowerMult)]"
	if(RegenMult != 1) L += "Regen: [BuffPct(RegenMult)]"
	if(RecovMult != 1) L += "Recovery: [BuffPct(RecovMult)]"
	if(EnergyMult != 1) L += "Energy: [BuffPct(EnergyMult)]"
	if(!L.len) L += "No stat changes."
	return L

/proc/StyleAddLine(list/L, label, mult)
	if(!mult || mult == 1) return
	var/v = round(mult - 1, 0.01)
	L += "[label]: [v > 0 ? "+" : ""][v]"

/obj/Skills/Buffs/NuStyle/BuffBoostLines()
	var/list/L = ..()
	var/list/S = list()
	StyleAddLine(S, "Strength", StyleStr)
	StyleAddLine(S, "Endurance", StyleEnd)
	StyleAddLine(S, "Force", StyleFor)
	StyleAddLine(S, "Speed", StyleSpd)
	StyleAddLine(S, "Offense", StyleOff)
	StyleAddLine(S, "Defense", StyleDef)
	if(S.len)
		L -= "No stat changes."
		L += S
	return L

// fallback
/obj/Skills/Buffs/InfoPanelLines()
	var/list/L = BuffBoostLines()
	if(passives && passives.len)
		L += "<span style=\"color:#8be9ff\">Passives</span>"
		for(var/p in passives)
			var/v = passives[p]
			L += (v == 1) ? "[p]" : "[p] ([v])"
	return L

#define SKMENU_COLS 5
#define SKMENU_ROWS 2
#define SKMENU_PAGE_SIZE (SKMENU_COLS * SKMENU_ROWS)
#define SKMENU_GRID_X0 -134      // col 0 icon left edge, aligned with leftmost tab
#define SKMENU_GRID_Y0 -18       // row 0 icon bottom edge, relative CENTER
#define SKMENU_GRID_PITCH 48     // 32px icon + 16px gap
#define SKMENU_TAB_COLS 3
#define SKMENU_TAB_W 84
#define SKMENU_TAB_PITCH 92      // 84 tab + 8px gap
#define SKMENU_TAB_X0 -134       // col 0 tab left edge
#define SKMENU_TAB_Y0 64         // row 0 tab bottom edge
#define SKMENU_TAB_ROW_PITCH 34
#define SKINFO_W 336
#define SKINFO_H 320
#define BUFF_VISIBLE 6
#define BUFF_RH 15
#define BUFF_ROWS 7        // 6 visible + 1 buffer row for smooth scrolling
#define BUFF_BAND_H 90     // BUFF_VISIBLE * BUFF_RH
#define BUFF_Y0 201        // SILoc dy of row 1's bottom edge at sub=0
#define BUFF_CLIP_T 186
#define BUFF_CLIP_B 276
#define BUFF_TRACK_X 298   // right of the row band, inside the panel border
#define BUFF_TRACK_Y 186   // dy of the track top = band top
#define BUFF_TRACK_H 90    // = BUFF_BAND_H
#define BUFF_THUMB_H 36

// tab label -> GetMenuSkills filter key
var/global/list/SKMENU_TAB_DEFS = list("All"="All", "Queues"="Queue", "Buffs"="Buff", "Grapples"="Grapple", "Projectiles"="Projectile", "Autohits"="AutoHit")

/atom/movable/shud/skmenu_icon
	mouse_opacity = 1
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	layer = MHUD_LAYER + 0.3
	var/obj/Skills/skill
	New()
		..()
		filters = filter(type="outline", size=1, color="#29b8d4")
	MouseEntered(location, control, params)
		filters = filter(type="outline", size=1, color="#8be9ff")
		usr?.client?.SkillMenuHoverIcon(skill, TRUE)
	MouseExited(location, control, params)
		filters = filter(type="outline", size=1, color="#29b8d4")
		usr?.client?.SkillMenuHoverIcon(skill, FALSE)
	Click(location, control, params)
		if(!usr || !usr.client || !skill) return
		if(params && findtext(params, "right=1"))
			if(usr.client.skinfo_skill == skill)
				usr.client.CloseSkillInfo()
			else if(istype(skill, /obj/Skills/Buffs))
				usr.client.ShowBuffInfo(skill)    // buffs get the dedicated panel with right-clickable passive rows
			else
				usr.client.ShowSkillInfo(skill)
			return
		// non-timed, non-debuff buffs are the only skills usable straight from the menu
		if(IsMenuBuff(skill))
			usr.fireShortcut(skill)
	MouseDrop(atom/over_object, atom/src_location, atom/over_location, src_control, over_control, params)
		if(!usr || !skill) return
		if(!istype(over_object, /atom/movable/shud/slot)) return
		usr.initShortcuts()
		var/atom/movable/shud/slot/tgt = over_object
		// no same skill in two slots
		for(var/i = 1 to HOTBAR_SLOTS)
			if(usr.shortcuts.vars["shortcut[i]"] == skill)
				usr.shortcuts.vars["shortcut[i]"] = null
		// can't displace a skill that's on cooldown
		var/obj/Skills/B = usr.shortcuts.vars["shortcut[tgt.slot_index]"]
		if(B && (B.Using || B.cooldown_remaining))
			usr << "<font color='#ff6b6b'>[B.name] is on cooldown.</font>"
			return
		usr.shortcuts.vars["shortcut[tgt.slot_index]"] = skill
		usr.client?.RefreshHotbar()

// type tab. label is a separate transparent child so the outline traces the text, not the frame
/atom/movable/shud/skmenu_tab
	icon = 'HUD/ui_tab_idle.png'
	layer = MHUD_LAYER + 0.3
	mouse_opacity = 1
	var/tabkey
	var/tablabel
	var/active = FALSE
	var/atom/movable/shud/menutext/lbl
	New()
		..()
		lbl = new
		lbl.layer = MHUD_LAYER + 0.35
		lbl.maptext_width = SKMENU_TAB_W
		lbl.maptext_height = 16
		lbl.maptext_y = 11   // raised ~3px north so descenders clear the bottom of the 32px frame
		vis_contents += lbl
	Del()
		if(lbl)
			vis_contents -= lbl
			del lbl
		..()
	proc/SetState(hovered = FALSE)
		icon = active ? 'HUD/ui_tab_active.png' : 'HUD/ui_tab_idle.png'
		var/c = active ? "#10233f" : (hovered ? "#8be9ff" : "#ffffff")   // dark text on the lit face
		lbl.maptext = "<center><span style=\"[MHUD_FONT]; color:[c]\">[tablabel]</span></center>"
	MouseEntered(location, control, params)
		SetState(TRUE)
	MouseExited(location, control, params)
		SetState(FALSE)
	Click()
		usr?.client?.SkillMenuSelectTab(tabkey)

// right-click anywhere to dismiss
/atom/movable/shud/skinfopanel
	parent_type = /atom/movable/shud/menupanel
	Click(location, control, params)
		if(params && findtext(params, "right=1"))
			usr?.client?.CloseSkillInfo()

/atom/movable/shud/skmenu_widget
	parent_type = /atom/movable/shud/pressbtn
	layer = MHUD_LAYER + 0.4
	DoAction()
		switch(action)
			if("close")      usr?.client?.CloseSkillMenu()
			if("prev")       usr?.client?.SkillMenuFlipPage(-1)
			if("next")       usr?.client?.SkillMenuFlipPage(1)

client
	var/tmp
		skmenu_open = FALSE
		skmenu_tab = "All"
		skmenu_page = 1
		skmenu_pages = 1
		list/skmenu_objs
		list/skmenu_icon_objs
		list/skmenu_tab_objs
		list/skinfo_objs
		list/buffdesc_objs
		buff_info_open = FALSE
		list/buff_pass_list
		list/buff_pass_rows
		buff_pass_px = 0
		buff_pass_target = 0
		buff_pass_anim = FALSE
		atom/movable/shud/buffthumb/buff_thumb
		obj/Skills/skinfo_skill
		si_atx = 1              // info panel tile anchor, computed from view
		si_aty = 1
		atom/movable/shud/menubtn/btn_skills
		atom/movable/shud/menulabel/btn_skills_label
		atom/movable/shud/menutext/skmenu_pagetext

client/proc/InitSkillMenuButton()
	btn_skills = new('HUD/ui_icon_skills.png')
	btn_skills.btn_id = "skills"
	btn_skills.screen_loc = "EAST:-4,NORTH:-212"   // right-edge strip, below Character
	shud_parts += btn_skills
	btn_skills_label = new
	btn_skills_label.maptext_width = 48
	btn_skills_label.SetText("Skills")
	btn_skills_label.pixel_x = -54
	btn_skills_label.pixel_y = 8
	btn_skills.label = btn_skills_label
	btn_skills.vis_contents += btn_skills_label

client/proc/ResetSkillMenuHUD()
	CloseSkillMenu()
	btn_skills = null
	btn_skills_label = null

client/proc/ToggleSkillMenu()
	if(skmenu_open)
		CloseSkillMenu()
	else
		OpenSkillMenu()

client/proc/CloseSkillMenu()
	CloseSkillInfo()
	skmenu_open = FALSE
	if(skmenu_icon_objs)
		while(skmenu_icon_objs.len)
			var/atom/movable/o = skmenu_icon_objs[skmenu_icon_objs.len]
			skmenu_icon_objs.len--
			screen -= o
			del o
		skmenu_icon_objs = null
	if(skmenu_objs)
		while(skmenu_objs.len)
			var/atom/movable/o = skmenu_objs[skmenu_objs.len]
			skmenu_objs.len--
			screen -= o
			del o
		skmenu_objs = null
	skmenu_tab_objs = null
	skmenu_pagetext = null
	if(btn_skills)
		btn_skills.icon = 'HUD/ui_slot_available.png'
		btn_skills.SetGlyphDimmed(FALSE)

client/proc/OpenSkillMenu()
	if(skmenu_open || !mob) return
	mob.DisableSlottableSkillVerbs()   // catch skills learned since login so they're hotbar-only too
	CloseMenu()           // never two big panels at once
	CloseInventory()
	CloseCharacterMenu()
	CloseTechMenu()
	CloseAcquireMenu()
	CloseLifeSkillsMenu()
	CloseStationMenu()
	skmenu_open = TRUE
	skmenu_tab = "All"
	skmenu_page = 1
	btn_skills.icon = 'HUD/ui_slot_unavailable.png'
	btn_skills.SetGlyphDimmed(TRUE)
	btn_skills_label.alpha = 0
	skmenu_objs = list()
	skmenu_icon_objs = list()
	skmenu_tab_objs = list()

	var/atom/movable/shud/menupanel/draggable/P = new
	P.screen_loc = "CENTER:[-MHUD_PANEL_W/2],CENTER:[-MHUD_PANEL_H/2]"
	skmenu_objs += P
	// restore saved drag position, clamped to the current view
	sk_pan_x = getPref("skPanX"); if(isnull(sk_pan_x)) sk_pan_x = 0
	sk_pan_y = getPref("skPanY"); if(isnull(sk_pan_y)) sk_pan_y = 0
	var/list/sb = PanBounds("skills", null)
	sk_pan_x = clamp(sk_pan_x, sb[1], sb[2])
	sk_pan_y = clamp(sk_pan_y, sb[3], sb[4])

	var/atom/movable/shud/menutext/title = new
	title.maptext_width = MHUD_PANEL_W
	title.maptext_height = 20
	title.maptext = "<center><span style=\"[MHUD_FONT]; color:#ffffff\">SKILLS</span></center>"
	title.screen_loc = "CENTER:[-MHUD_PANEL_W/2],CENTER:100"
	skmenu_objs += title

	var/atom/movable/shud/skmenu_widget/X = new
	X.icon = 'HUD/ui_cross.png'
	X.action = "close"
	X.widget_kind = "cross"
	X.screen_loc = "CENTER:132,CENTER:96"
	skmenu_objs += X

	var/atom/movable/shud/skmenu_widget/AL = new
	AL.icon = 'HUD/ui_arrow_left.png'
	AL.action = "prev"
	AL.widget_kind = "arrow_left"
	AL.screen_loc = "CENTER:-130,CENTER:-104"
	skmenu_objs += AL

	var/atom/movable/shud/skmenu_widget/AR = new
	AR.icon = 'HUD/ui_arrow_right.png'
	AR.action = "next"
	AR.widget_kind = "arrow_right"
	AR.screen_loc = "CENTER:98,CENTER:-104"
	skmenu_objs += AR

	// footer shows page count or the hovered skill's name (generic icons can't tell two queues apart)
	skmenu_pagetext = new
	skmenu_pagetext.maptext_width = 200
	skmenu_pagetext.maptext_height = 18
	skmenu_pagetext.screen_loc = "CENTER:-100,CENTER:-98"
	skmenu_objs += skmenu_pagetext

	var/ti = 0
	for(var/lbl in SKMENU_TAB_DEFS)
		var/atom/movable/shud/skmenu_tab/T = new
		T.tabkey = SKMENU_TAB_DEFS[lbl]
		T.tablabel = lbl
		T.active = (T.tabkey == skmenu_tab)
		var/col = ti % SKMENU_TAB_COLS
		var/trow = round(ti / SKMENU_TAB_COLS)
		T.screen_loc = "CENTER:[SKMENU_TAB_X0 + col * SKMENU_TAB_PITCH],CENTER:[SKMENU_TAB_Y0 - trow * SKMENU_TAB_ROW_PITCH]"
		T.SetState(FALSE)
		skmenu_tab_objs += T
		skmenu_objs += T
		ti++

	for(var/atom/movable/o in skmenu_objs)
		screen += o
	PanShift(skmenu_objs, sk_pan_x, sk_pan_y)
	KineticEntrance(skmenu_objs)
	BuildSkillMenuGrid(TRUE)

client/proc/RenderSkillTabs()
	if(!skmenu_tab_objs) return
	for(var/atom/movable/shud/skmenu_tab/T in skmenu_tab_objs)
		T.active = (T.tabkey == skmenu_tab)
		T.SetState(FALSE)

client/proc/UpdateSkillPageText()
	if(!skmenu_pagetext) return
	skmenu_pagetext.maptext = "<center><span style=\"[MHUD_FONT]; color:#ffffff\">[skmenu_page]/[skmenu_pages]</span></center>"

client/proc/SkillMenuSelectTab(tabkey)
	if(!skmenu_open || skmenu_tab == tabkey) return
	skmenu_tab = tabkey
	skmenu_page = 1
	RenderSkillTabs()
	BuildSkillMenuGrid()

client/proc/SkillMenuFlipPage(dir)
	if(!skmenu_open) return
	skmenu_page += dir
	BuildSkillMenuGrid()

client/proc/SkillMenuHoverIcon(obj/Skills/S, over)
	if(!skmenu_open || !skmenu_pagetext) return
	if(over && S)
		skmenu_pagetext.maptext = "<center><span style=\"[MHUD_FONT]; color:#8be9ff\">[S.name]</span></center>"
	else
		UpdateSkillPageText()

client/proc/BuildSkillMenuGrid(fade = FALSE)
	if(!mob || !skmenu_open) return
	while(skmenu_icon_objs.len)
		var/atom/movable/o = skmenu_icon_objs[skmenu_icon_objs.len]
		skmenu_icon_objs.len--
		screen -= o
		del o
	var/list/L = mob.GetMenuSkills(skmenu_tab)
	skmenu_pages = max(1, -round(-L.len / SKMENU_PAGE_SIZE)) // ceil
	skmenu_page = min(max(skmenu_page, 1), skmenu_pages)
	UpdateSkillPageText()
	var/start = (skmenu_page - 1) * SKMENU_PAGE_SIZE
	for(var/k = 1 to SKMENU_PAGE_SIZE)
		var/idx = start + k
		if(idx > L.len) break
		var/obj/Skills/S = L[idx]
		var/atom/movable/shud/skmenu_icon/E = new
		E.skill = S
		E.icon = SkillMenuIcon(S)
		E.icon_state = SkillMenuIconState(S)
		var/col = (k - 1) % SKMENU_COLS
		var/row = round((k - 1) / SKMENU_COLS)
		E.screen_loc = "CENTER:[SKMENU_GRID_X0 + col * SKMENU_GRID_PITCH],CENTER:[SKMENU_GRID_Y0 - row * SKMENU_GRID_PITCH]"
		skmenu_icon_objs += E
		screen += E
	PanShift(skmenu_icon_objs, sk_pan_x, sk_pan_y)
	if(fade)
		KineticEntrance(skmenu_icon_objs)

// panel-local dx/dy > tile:pixel screen_loc, anchored low to dodge the CENTER HUD-shift bug
client/proc/SILoc(dx, dy)
	var/py = SKINFO_H - dy
	return "[si_atx + round((dx - dx % 32) / 32)]:[dx % 32],[si_aty + round((py - py % 32) / 32)]:[py % 32]"

client/proc/ShowSkillInfo(obj/Skills/S)
	if(!S || !mob) return
	CloseSkillInfo()
	skinfo_objs = list()
	skinfo_skill = S

	// tile-anchor so the footprint never overhangs the view top (the HUD shift bug)
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	var/mtw = round(SKINFO_W / 32); if(mtw * 32 < SKINFO_W) mtw++
	var/mth = round(SKINFO_H / 32); if(mth * 32 < SKINFO_H) mth++
	si_atx = max(1, round((vw - mtw) / 2) + 1)
	si_aty = max(1, round((vh - mth) / 2) + 1)

	var/atom/movable/shud/skinfopanel/P = new
	P.icon = 'HUD/skill_info_panel.png'
	P.layer = MHUD_LAYER + 2.0                   // above the character menu (FLY+4.x) when a buff is right-clicked there
	P.screen_loc = SILoc(0, SKINFO_H)
	skinfo_objs += P

	var/atom/movable/shud/orbpart/ic = new      // mouse-transparent so the panel keeps the clicks
	ic.icon = SkillMenuIcon(S)
	ic.icon_state = SkillMenuIconState(S)
	ic.layer = MHUD_LAYER + 2.1
	ic.screen_loc = SILoc((SKINFO_W - 32) / 2, 56)
	skinfo_objs += ic

	var/atom/movable/shud/menutext/nm = new
	nm.layer = MHUD_LAYER + 2.1
	nm.maptext_width = SKINFO_W
	nm.maptext_height = 20
	nm.maptext = "<center><span style=\"[MHUD_FONT]; color:#ffd86b\">[S.name]</span></center>"
	nm.screen_loc = SILoc(0, 84)
	skinfo_objs += nm

	var/body = ""
	for(var/ln in S.InfoPanelLines())
		body += "[ln]<br>"
	var/atom/movable/shud/menutext/tx = new
	tx.layer = MHUD_LAYER + 2.1
	tx.maptext_width = SKINFO_W - 48
	tx.maptext_height = SKINFO_H - 96
	tx.maptext = "<center><span style=\"[MHUD_FONT]; color:#ffffff\">[body]</span></center>"
	tx.screen_loc = SILoc(24, SKINFO_H - 4)
	skinfo_objs += tx

	for(var/atom/movable/o in skinfo_objs)
		screen += o
	KineticEntrance(skinfo_objs)

client/proc/CloseSkillInfo()
	CloseBuffPassDesc()
	buff_info_open = FALSE
	buff_pass_list = null
	buff_pass_rows = null
	buff_thumb = null
	skinfo_skill = null
	if(!skinfo_objs) return
	while(skinfo_objs.len)
		var/atom/movable/o = skinfo_objs[skinfo_objs.len]
		skinfo_objs.len--
		screen -= o
		del o
	skinfo_objs = null

/atom/movable/shud/buffpassrow
	layer = MHUD_LAYER + 2.2
	mouse_opacity = 0
	maptext_height = 15
	var/pass_name
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")
	MouseEntered(location, control, params)
		filters = filter(type="outline", size=1, color="#8be9ff")
	MouseExited(location, control, params)
		filters = filter(type="outline", size=1, color="#000000")
	Click(location, control, params)
		if(!usr || !usr.client || !pass_name) return
		if(params && findtext(params, "right=1"))
			usr.client.ShowBuffPassDesc(pass_name)

// passive-band scrollbar; click or drag jumps the list to the cursor
/atom/movable/shud/bufftrack
	layer = MHUD_LAYER + 2.25
	mouse_opacity = 2
	Click(location, control, params)
		if(usr) usr.client.BuffScrollTrackTo(params)
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.BuffScrollTrackTo(params)

/atom/movable/shud/buffthumb
	layer = MHUD_LAYER + 2.26
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.BuffScrollTrackTo(params)

/atom/movable/shud/buffdescpanel
	parent_type = /atom/movable/shud/menupanel
	Click(location, control, params)
		if(usr && usr.client && params && findtext(params, "right=1"))
			usr.client.CloseBuffPassDesc()

client/proc/ShowBuffInfo(obj/Skills/Buffs/b)
	if(!b || !mob) return
	CloseSkillInfo()
	skinfo_objs = list()
	skinfo_skill = b
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	var/mtw = round(SKINFO_W / 32); if(mtw * 32 < SKINFO_W) mtw++
	var/mth = round(SKINFO_H / 32); if(mth * 32 < SKINFO_H) mth++
	si_atx = max(1, round((vw - mtw) / 2) + 1)
	si_aty = max(1, round((vh - mth) / 2) + 1)

	var/atom/movable/shud/skinfopanel/P = new
	P.icon = 'HUD/skill_info_panel.png'
	P.layer = MHUD_LAYER + 2.0
	P.screen_loc = SILoc(0, SKINFO_H)
	skinfo_objs += P

	var/atom/movable/shud/orbpart/ic = new
	ic.icon = SkillMenuIcon(b)
	ic.icon_state = SkillMenuIconState(b)
	ic.layer = MHUD_LAYER + 2.1
	ic.screen_loc = SILoc((SKINFO_W - 32) / 2, 56)
	skinfo_objs += ic

	var/atom/movable/shud/menutext/nm = new
	nm.layer = MHUD_LAYER + 2.1
	nm.maptext_width = SKINFO_W
	nm.maptext_height = 20
	nm.maptext = "<center><span style=\"[MHUD_FONT]; color:#ffd86b\">[b.name]</span></center>"
	nm.screen_loc = SILoc(0, 84)
	skinfo_objs += nm

	var/body = ""
	for(var/ln in b.BuffBoostLines())
		body += "[ln]<br>"
	var/atom/movable/shud/menutext/bx = new
	bx.layer = MHUD_LAYER + 2.1
	bx.maptext_width = SKINFO_W - 48
	bx.maptext_height = 64
	bx.maptext = "<center><span style=\"[MHUD_FONT]; color:#ffffff\">[body]</span></center>"
	bx.screen_loc = SILoc(24, 158)
	skinfo_objs += bx

	buff_info_open = TRUE
	buff_pass_px = 0
	buff_pass_target = 0
	buff_pass_list = list()
	buff_pass_rows = list()
	if(b.passives)
		for(var/p in b.passives)
			buff_pass_list += p
	if(buff_pass_list.len)
		var/atom/movable/shud/menutext/ph = new
		ph.layer = MHUD_LAYER + 2.4
		ph.maptext_width = SKINFO_W
		ph.maptext_height = 16
		ph.maptext = "<center><span style=\"[MHUD_FONT]; color:#8be9ff\">Passives</span></center>"
		ph.screen_loc = SILoc(0, 180)
		skinfo_objs += ph
		for(var/k = 1 to BUFF_ROWS)             // 6 visible + 1 buffer for smooth scroll
			var/atom/movable/shud/buffpassrow/r = new
			r.maptext_width = SKINFO_W - 64
			buff_pass_rows += r
			skinfo_objs += r
		// cover strips in the panel-interior color (#29375F) clip rows scrolling past the band edges
		var/atom/movable/shud/orbpart/tcov = new
		tcov.icon = BuffCoverIcon(20)
		tcov.mouse_opacity = 0
		tcov.layer = MHUD_LAYER + 2.3
		tcov.screen_loc = SILoc(20, 186)
		skinfo_objs += tcov
		var/atom/movable/shud/orbpart/bcov = new
		bcov.icon = BuffCoverIcon(18)
		bcov.mouse_opacity = 0
		bcov.layer = MHUD_LAYER + 2.3
		bcov.screen_loc = SILoc(20, 294)
		skinfo_objs += bcov
		var/atom/movable/shud/bufftrack/tr = new
		tr.icon = 'HUD/scroll_track_90.png'
		tr.screen_loc = SILoc(BUFF_TRACK_X, BUFF_TRACK_Y + BUFF_TRACK_H)
		skinfo_objs += tr
		buff_thumb = new
		buff_thumb.icon = 'HUD/scroll_thumb.png'
		skinfo_objs += buff_thumb
		RefreshBuffPassRows()

	for(var/atom/movable/o in skinfo_objs)
		screen += o
	KineticEntrance(skinfo_objs)

/proc/BuffCoverIcon(h)
	var/icon/I = icon('BLANK.dmi')
	I.Scale(296, h)
	I.DrawBox("#29375F", 1, 1, 296, h)
	return I

client/proc/RefreshBuffPassRows()
	if(!buff_pass_list || !buff_pass_rows) return
	var/obj/Skills/Buffs/bb = skinfo_skill
	var/total = buff_pass_list.len
	var/maxpx = max(0, total * BUFF_RH - BUFF_BAND_H)
	buff_pass_px = clamp(buff_pass_px, 0, maxpx)
	var/sub = buff_pass_px % BUFF_RH
	var/first = (buff_pass_px - sub) / BUFF_RH
	for(var/k = 1 to buff_pass_rows.len)
		var/atom/movable/shud/buffpassrow/r = buff_pass_rows[k]
		var/rowdy = BUFF_Y0 + (k - 1) * BUFF_RH - sub
		r.screen_loc = SILoc(32, rowdy)
		var/idx = first + k
		if(idx <= total)
			var/p = buff_pass_list[idx]
			var/v = (bb && bb.passives) ? bb.passives[p] : null
			var/vtxt = (isnull(v) || v == 1) ? "" : " ([v])"
			var/mid = rowdy - 7
			r.pass_name = p
			r.maptext = "<center><span style=\"[MHUD_FONT]; color:#ffffff\">[p][vtxt]</span></center>"
			r.alpha = 255
			var/px = length("[p][vtxt]") * 6
			var/off = max(0, round((SKINFO_W - 64 - RowHitW(px)) / 2))
			r.icon = RowHitIcon(px)
			r.pixel_x = off
			r.maptext_x = -off
			var/live = (mid >= BUFF_CLIP_T && mid <= BUFF_CLIP_B)
			r.mouse_opacity = live ? 2 : 0
			if(!live) r.filters = filter(type="outline", size=1, color="#000000")
		else
			r.pass_name = null
			r.maptext = ""
			r.alpha = 0
			r.icon = null
			r.pixel_x = 0
			r.maptext_x = 0
			r.mouse_opacity = 0
			r.filters = filter(type="outline", size=1, color="#000000")
	if(buff_thumb)
		if(maxpx <= 0)
			buff_thumb.alpha = 80
			buff_thumb.screen_loc = SILoc(BUFF_TRACK_X + 1, BUFF_TRACK_Y + BUFF_THUMB_H)
		else
			buff_thumb.alpha = 255
			var/off = round((buff_pass_px / maxpx) * (BUFF_TRACK_H - BUFF_THUMB_H))
			buff_thumb.screen_loc = SILoc(BUFF_TRACK_X + 1, BUFF_TRACK_Y + off + BUFF_THUMB_H)

// returns 1 if the buff panel is open (and consumed the wheel), so MouseWheel knows to stop
client/proc/BuffWheelScroll(delta_y)
	if(!buff_info_open || !buff_pass_list || !buff_pass_list.len) return 0
	var/bmax = max(0, buff_pass_list.len * BUFF_RH - BUFF_BAND_H)
	if(bmax > 0)
		var/bdir = (delta_y > 0) ? -1 : 1
		buff_pass_target = clamp(buff_pass_target + bdir * BUFF_RH, 0, bmax)
		if(!buff_pass_anim) AnimateBuffPassScroll()
	return 1

client/proc/AnimateBuffPassScroll()
	set waitfor = 0
	buff_pass_anim = TRUE
	while(buff_info_open && buff_pass_list && buff_pass_px != buff_pass_target)
		var/diff = buff_pass_target - buff_pass_px
		var/stepp = round(diff * 0.5)
		if(!stepp) stepp = (diff > 0) ? 1 : -1
		buff_pass_px += stepp
		RefreshBuffPassRows()
		sleep(world.tick_lag)
	buff_pass_anim = FALSE

client/proc/BuffScrollTrackTo(params)
	if(!buff_info_open || !buff_pass_list) return
	var/maxpx = max(0, buff_pass_list.len * BUFF_RH - BUFF_BAND_H)
	if(maxpx <= 0) return
	var/list/pl = params2list(params)
	var/sl = pl["screen-loc"]
	if(!sl) return
	var/list/cm = splittext(sl, ",")
	if(cm.len < 2) return
	var/list/yp = splittext(cm[2], ":")
	if(yp.len < 2) return
	var/row = text2num(yp[1])
	var/py = text2num(yp[2])
	if(isnull(row) || isnull(py)) return
	var/local_h = (row - 1) * 32 + py - (si_aty - 1) * 32
	var/frac = ((SKINFO_H - BUFF_TRACK_Y) - local_h) / BUFF_TRACK_H
	frac = clamp(frac, 0, 1)
	buff_pass_px = round(frac * maxpx)
	buff_pass_target = buff_pass_px          // cancel any running wheel glide
	RefreshBuffPassRows()

client/proc/ShowBuffPassDesc(name)
	CloseBuffPassDesc()
	if(!name) return
	buffdesc_objs = list()
	var/atom/movable/shud/buffdescpanel/P = new
	P.icon = 'HUD/skill_info_panel.png'
	P.layer = MHUD_LAYER + 3.0
	P.screen_loc = SILoc(0, SKINFO_H)
	buffdesc_objs += P
	var/atom/movable/shud/menutext/T = new
	T.layer = MHUD_LAYER + 3.1
	T.maptext_width = SKINFO_W
	T.maptext_height = 20
	T.maptext = "<center><span style=\"[MHUD_FONT]; color:#ffd86b\">[name]</span></center>"
	T.screen_loc = SILoc(0, 44)
	buffdesc_objs += T
	var/d = (global.PassiveInfo && (name in global.PassiveInfo)) ? StripBalanceNote(global.PassiveInfo[name]) : "No description available."
	var/list/lines = WrapDescLines(d, 47)   // 288px body at 6px/char (monogram 12pt)
	var/n = min(lines.len, 14)              // 14 rows fit between title and hint
	for(var/i = 1 to n)
		var/txt = lines[i]
		if(i == 14 && lines.len > 14) txt += " ..."
		var/atom/movable/shud/menutext/L = new
		L.layer = MHUD_LAYER + 3.1
		L.maptext_width = SKINFO_W - 48
		L.maptext_height = 16
		L.maptext = "<span style=\"[MHUD_FONT]; color:#ffffff\">[txt]</span>"
		L.screen_loc = SILoc(24, 68 + (i - 1) * 16)
		buffdesc_objs += L
	var/atom/movable/shud/menutext/H = new
	H.layer = MHUD_LAYER + 3.1
	H.maptext_width = SKINFO_W
	H.maptext_height = 16
	H.maptext = "<center><span style=\"[MHUD_FONT]; color:#7a9bb5\">right-click to close</span></center>"
	H.screen_loc = SILoc(0, 306)
	buffdesc_objs += H
	for(var/atom/movable/o in buffdesc_objs)
		screen += o
	KineticEntrance(buffdesc_objs)

client/proc/CloseBuffPassDesc()
	if(!buffdesc_objs) return
	while(buffdesc_objs.len)
		var/atom/movable/o = buffdesc_objs[buffdesc_objs.len]
		buffdesc_objs.len--
		screen -= o
		del o
	buffdesc_objs = null
