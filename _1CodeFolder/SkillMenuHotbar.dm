#define HOTBAR_SLOTS 12

#define STYLE_PATH /obj/Skills/Buffs/NuStyle

var/list/HOTBAR_DEFAULT_KEYS = list("1","2","3","4","5","6","7","8","9","0","-","=")

var/list/SKILLMENU_EXCLUDE = list("Heavy Strike", "Dragon Dash", "After Image Strike", "Pose", "Normal Attack", "Power Up", "Power Down", "Reverse Dash", "Zanzoken", "Grab", "Target Switch", "Toggle Style", "Toss")

#define KB_NORMAL 0
#define KB_MOVE   1
#define KB_HOTBAR 2   // +UP release only if the slotted skill is a held skill

/datum/keyaction
	var/id
	var/label
	var/command
	var/defkey
	var/category
	var/kind = KB_NORMAL
	New(_id, _label, _command, _defkey, _category, _kind = KB_NORMAL)
		id = _id; label = _label; command = _command; defkey = _defkey; category = _category; kind = _kind

var/global/list/keybind_registry
var/global/list/keybind_by_id = list()

/proc/BuildKeybindRegistry()
	if(keybind_registry) return keybind_registry
	keybind_registry = list()
	var/list/R = keybind_registry
	R += new/datum/keyaction("north", "Move Up",    "north", "W", "Movement", KB_MOVE)
	R += new/datum/keyaction("west",  "Move Left",  "west",  "A", "Movement", KB_MOVE)
	R += new/datum/keyaction("south", "Move Down",  "south", "S", "Movement", KB_MOVE)
	R += new/datum/keyaction("east",  "Move Right", "east",  "D", "Movement", KB_MOVE)
	R += new/datum/keyaction("zanzoken",    "Zanzoken",            "Zanzoken",           "Z",   "Combat")
	R += new/datum/keyaction("heavystrike", "Heavy Strike",        "Heavy-Strike",       "X",   "Combat")
	R += new/datum/keyaction("grab",        "Grab",                "Grab",               "C",   "Combat")
	R += new/datum/keyaction("toss",        "Toss",                "Toss",               "V",   "Combat")
	R += new/datum/keyaction("dragondash",  "Dragon Dash",         "Dragon-Dash",        "Q",   "Combat")
	R += new/datum/keyaction("reversedash", "Reverse Dash",        "Reverse-Dash",       "E",   "Combat")
	R += new/datum/keyaction("powerup",     "Power Up",            "Power-Up",           "R",   "Combat")
	R += new/datum/keyaction("powerdown",   "Power Down",          "Power-Down",         "F",   "Combat")
	R += new/datum/keyaction("pose",        "Pose",                "Pose",               "T",   "Combat")
	R += new/datum/keyaction("targetswitch","Target Switch",       "Target-Switch",      "Tab", "Combat")
	R += new/datum/keyaction("togglestyle", "Toggle Style",        "Toggle-Style",       "P",   "Combat")
	R += new/datum/keyaction("sense",       "Sense",               "Sense",              "O",   "Combat")
	R += new/datum/keyaction("meditate",    "Meditate",            "Meditate",           "M",   "Combat")
	R += new/datum/keyaction("autoattack",  "Auto Attack",         "Auto-Attack",        "Alt", "Combat")
	R += new/datum/keyaction("seetargets",  "See Target's Target", "See-Targets-Target", "`",   "Combat")
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

// explicit override if set (including "" for deliberately unbound), else the registry default
/mob/proc/KeybindKey(action_id)
	initShortcuts()
	if(shortcuts.keybinds && (action_id in shortcuts.keybinds))
		return shortcuts.keybinds[action_id]
	BuildKeybindRegistry()
	var/datum/keyaction/a = keybind_by_id[action_id]
	return a ? a.defkey : ""

/mob/proc/SetKeybind(action_id, key)
	initShortcuts()
	if(!shortcuts.keybinds) shortcuts.keybinds = list()
	shortcuts.keybinds[action_id] = key

/proc/HotbarMacroName(key, suffix = "")
	if(findtext(key, "=") || findtext(key, ";"))
		return "\"[key][suffix]\""
	return "[key][suffix]"

client/proc/ApplyKeybinds()
	if(!mob) return
	mob.initShortcuts()
	BuildKeybindRegistry()
	var/set_name = "macro"
	for(var/k in params2list(winget(src, null, "macro")))
		set_name = k
		break
	for(var/datum/keyaction/a in keybind_registry)
		var/key = mob.KeybindKey(a.id)
		var/eid = "kb_[a.id]"
		var/uid = "kb_[a.id]_up"
		if(!key)
			winset(src, eid, "type=macro;parent=[set_name];name=kboff_[a.id]")        // unbound, park both off the key
			winset(src, uid, "type=macro;parent=[set_name];name=kboff_[a.id]_up")
			continue
		winset(src, eid, "type=macro;parent=[set_name];name=[HotbarMacroName(key)];command=[a.command]")
		switch(a.kind)
			if(KB_MOVE)
				winset(src, uid, "type=macro;parent=[set_name];name=[HotbarMacroName(key, "+UP")];command=[a.command]-up")
			if(KB_HOTBAR)
				var/n = text2num(copytext(a.id, 7))   // "hotbarN" -> N
				var/obj/Skills/s = mob.shortcuts.vars["shortcut[n]"]
				if(s && s.HeldSkill)
					winset(src, uid, "type=macro;parent=[set_name];name=[HotbarMacroName(key, "+UP")];command=Release-Held-Skill")
				else
					winset(src, uid, "type=macro;parent=[set_name];name=kboff_[a.id]_up")
			else
				winset(src, uid, "type=macro;parent=[set_name];name=kboff_[a.id]_up")

// generic for now
/proc/SKILL_TYPE_ICON(obj/Skills/S)
	if(istype(S, /obj/Skills/Projectile)) return 'HUD/skill_projectile.png'
	if(istype(S, /obj/Skills/Queue))      return 'HUD/skill_queue.png'
	if(istype(S, /obj/Skills/Grapple))    return 'HUD/skill_grapple.png'
	if(istype(S, /obj/Skills/Buffs))      return 'HUD/skill_buff.png'
	if(istype(S, /obj/Skills/AutoHit))    return 'HUD/skill_autohit.png'
	return 'HUD/skill_autohit.png'

/proc/SkillMenuIcon(obj/Skills/S)
	if(!S) return null
	return SKILL_TYPE_ICON(S)

/proc/SkillHasSkillVerb(obj/Skills/S)
	if(!S) return 0
	for(var/v in S.verbs)
		if(!v) continue
		if(v:hidden) continue
		if(v:category == "Skills") return 1
	return 0

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
			else
				usr.client.ShowSkillInfo(skill)   // closes any open one first, so it swaps
			return
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

// type tab. lit while it's the active filter. label rides on the frame as a separate
// transparent-bg menutext child so the outline filter traces the text, not the frame
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
	CloseMenu()           // never two big panels at once
	CloseInventory()
	CloseCharacterMenu()
	skmenu_open = TRUE
	skmenu_tab = "All"
	skmenu_page = 1
	btn_skills.icon = 'HUD/ui_slot_unavailable.png'
	btn_skills.SetGlyphDimmed(TRUE)
	btn_skills_label.alpha = 0
	skmenu_objs = list()
	skmenu_icon_objs = list()
	skmenu_tab_objs = list()

	var/atom/movable/shud/menupanel/P = new
	P.screen_loc = "CENTER:[-MHUD_PANEL_W/2],CENTER:[-MHUD_PANEL_H/2]"
	skmenu_objs += P

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
		var/col = (k - 1) % SKMENU_COLS
		var/row = round((k - 1) / SKMENU_COLS)
		E.screen_loc = "CENTER:[SKMENU_GRID_X0 + col * SKMENU_GRID_PITCH],CENTER:[SKMENU_GRID_Y0 - row * SKMENU_GRID_PITCH]"
		skmenu_icon_objs += E
		screen += E
	if(fade)
		KineticEntrance(skmenu_icon_objs)

// panel-local (dx from left, dy from top) > tile:pixel screen_loc. anchored low to dodge the
// CENTER HUD-shift bug on tall panels
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
	P.layer = MHUD_LAYER + 1.0
	P.screen_loc = SILoc(0, SKINFO_H)
	skinfo_objs += P

	var/atom/movable/shud/orbpart/ic = new      // mouse-transparent so the panel keeps the clicks
	ic.icon = SkillMenuIcon(S)
	ic.layer = MHUD_LAYER + 1.1
	ic.screen_loc = SILoc((SKINFO_W - 32) / 2, 56)
	skinfo_objs += ic

	var/atom/movable/shud/menutext/nm = new
	nm.layer = MHUD_LAYER + 1.1
	nm.maptext_width = SKINFO_W
	nm.maptext_height = 20
	nm.maptext = "<center><span style=\"[MHUD_FONT]; color:#ffd86b\">[S.name]</span></center>"
	nm.screen_loc = SILoc(0, 84)
	skinfo_objs += nm

	var/body = ""
	for(var/ln in S.InfoPanelLines())
		body += "[ln]<br>"
	var/atom/movable/shud/menutext/tx = new
	tx.layer = MHUD_LAYER + 1.1
	tx.maptext_width = SKINFO_W - 48
	tx.maptext_height = SKINFO_H - 96
	tx.maptext = "<center><span style=\"[MHUD_FONT]; color:#ffffff\">[body]</span></center>"
	tx.screen_loc = SILoc(24, SKINFO_H - 4)
	skinfo_objs += tx

	for(var/atom/movable/o in skinfo_objs)
		screen += o
	KineticEntrance(skinfo_objs)

client/proc/CloseSkillInfo()
	skinfo_skill = null
	if(!skinfo_objs) return
	while(skinfo_objs.len)
		var/atom/movable/o = skinfo_objs[skinfo_objs.len]
		skinfo_objs.len--
		screen -= o
		del o
	skinfo_objs = null
