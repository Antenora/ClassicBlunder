#define SHUD_SLOTS 12
#define SHUD_PITCH 32
#define SHUD_ROW_LEFT -192
#define SHUD_ROW_Y 30

#define SHUD_ORB_Y 12
#define SHUD_ORB_LEFT_X -267
#define SHUD_ORB_RIGHT_X 198
#define SHUD_BALL_D 44
#define SHUD_FILL_EMPTY_Y -54
#define SHUD_DRAIN_HIDDEN_Y 59

#define SHUD_LAYER (FLY_LAYER+2)
#define SHUD_FONT_STYLE "font-family:'monogram'; font-size:12pt"

/atom/movable/shud
	layer = SHUD_LAYER
	mouse_opacity = 0
	Click()
		return // don't let HUD clicks fall through to combat handlers
	DblClick()
		return

#define SLOT_ICON_SZ 22
#define SLOT_ICON_OFF 5
#define CD_H 22
#define CD_EMPTY_Y -22    // mask off, skill ready
#define CD_FULL_Y 0       // mask on, veil covers the icon

/proc/SkillCDRemaining(obj/Skills/S)
	if(!S || S.cooldown_remaining <= 0) return 0
	if(!S.cooldown_start) return S.cooldown_remaining
	return max(0, S.cooldown_remaining - (world.realtime - S.cooldown_start))

/atom/movable/shud/slottext
	mouse_opacity = 0
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/slot
	icon = 'HUD/hud_slot.png'
	mouse_opacity = 2                          // full box so drag-drops land reliably
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/slot_index
	var/obj/Skills/cur
	var/on_cd = FALSE
	var/anim_key = 0                           // cooldown_start the veil animate is running for (0 = none)
	var/atom/movable/shud/orbpart/iconpart
	var/atom/movable/shud/orbpart/cdfill
	var/atom/movable/shud/slottext/keytext
	New()
		..()
		iconpart = new
		iconpart.layer = SHUD_LAYER + 0.1
		iconpart.pixel_x = SLOT_ICON_OFF
		iconpart.pixel_y = SLOT_ICON_OFF
		cdfill = new
		cdfill.icon = 'HUD/cd_fill.png'
		cdfill.layer = SHUD_LAYER + 0.2
		cdfill.pixel_x = SLOT_ICON_OFF
		cdfill.pixel_y = SLOT_ICON_OFF
		cdfill.filters = filter(type="alpha", icon='HUD/cd_mask.png', y = CD_EMPTY_Y)
		cdfill.alpha = 0
		keytext = new
		keytext.layer = SHUD_LAYER + 0.5
		keytext.maptext_width = 32
		keytext.maptext_height = 12
		keytext.maptext_y = 0
		vis_contents += iconpart
		vis_contents += cdfill
		vis_contents += keytext
	Del()
		for(var/atom/movable/o in vis_contents)
			vis_contents -= o
			del o
		iconpart = null
		cdfill = null
		keytext = null
		..()
	proc/SetSkill(obj/Skills/S, keylabel)
		cur = S
		on_cd = FALSE
		anim_key = 0
		if(S)
			var/icon/I = icon(SkillMenuIcon(S))
			I.Scale(SLOT_ICON_SZ, SLOT_ICON_SZ)
			iconpart.icon = I
		else
			iconpart.icon = null
		iconpart.alpha = 255
		cdfill.alpha = 0
		if(keylabel)
			keytext.maptext = "<center><span style=\"[SHUD_FONT_STYLE]; color:#cfe9ff\">[keylabel]</span></center>"
		else
			keytext.maptext = ""
	// replacing the filter stops any running animate, used to freeze on RP-pause
	proc/SetVeilFrac(frac)
		cdfill.filters = filter(type="alpha", icon='HUD/cd_mask.png', y = CD_EMPTY_Y + round(CD_H * frac))
	// tried to do live countdown but couldn't figure it out, may come back to it
	proc/UpdateCooldown()
		if(!cur)
			return FALSE
		if(cur.Cooldown == -1)
			var/locked = (cur.Using || cur.cooldown_remaining > 0)
			iconpart.alpha = locked ? 120 : 255
			cdfill.alpha = locked ? 255 : 0
			SetVeilFrac(locked ? 1 : 0)
			anim_key = 0
			on_cd = locked
			return FALSE
		var/rem = SkillCDRemaining(cur)
		if(!((cur.Using || cur.cooldown_remaining > 0) && rem > 0))
			if(on_cd)
				iconpart.alpha = 255
				cdfill.alpha = 0
				SetVeilFrac(0)
				on_cd = FALSE
				anim_key = 0
			return FALSE
		on_cd = TRUE
		iconpart.alpha = 120
		cdfill.alpha = 255
		var/total = cur.cooldown_remaining
		var/frac = total ? rem / total : 0
		if(!cur.cooldown_start)
			SetVeilFrac(frac)              
			anim_key = 0
		else if(anim_key != cur.cooldown_start)
			SetVeilFrac(frac)              // fresh cast, plant start then one smooth crawl
			animate(cdfill.filters[1], y = CD_EMPTY_Y, time = rem, easing = LINEAR_EASING)
			anim_key = cur.cooldown_start
		return TRUE
	Click(location, control, params)
		if(!usr || !usr.client) return
		usr.initShortcuts()
		var/obj/Skills/S = usr.shortcuts.vars["shortcut[slot_index]"]
		if(!S) return
		if(params && findtext(params, "right=1"))   // right-click toggles the info panel
			if(usr.client.skinfo_skill == S)
				usr.client.CloseSkillInfo()
			else
				usr.client.ShowSkillInfo(S)
			return
		if(S.HeldSkill)
			usr << "<font color='#ff6b6b'>[S.name] is a held skill, press and hold its bound key to charge it.</font>"
			return
		spawn() usr.attemptShortcut(slot_index)
	MouseDrop(atom/over_object, atom/src_location, atom/over_location, src_control, over_control, params)
		if(!usr) return
		usr.initShortcuts()
		var/obj/Skills/S = usr.shortcuts.vars["shortcut[slot_index]"]
		if(!S) return
		if(S.Using || S.cooldown_remaining)            // cooldown lock
			usr << "<font color='#ff6b6b'>[S.name] is on cooldown.</font>"
			return
		if(istype(over_object, /atom/movable/shud/slot))   // dropped on another slot, swap them
			var/atom/movable/shud/slot/tgt = over_object
			if(tgt == src) return
			var/obj/Skills/B = usr.shortcuts.vars["shortcut[tgt.slot_index]"]
			if(B && (B.Using || B.cooldown_remaining))
				usr << "<font color='#ff6b6b'>[B.name] is on cooldown.</font>"
				return
			usr.shortcuts.vars["shortcut[tgt.slot_index]"] = S
			usr.shortcuts.vars["shortcut[slot_index]"] = B   // B may be null, then the skill just moves
			usr.client?.RefreshHotbar()
			return
		if(istype(over_object, /atom/movable/shud)) return   // dropped on other HUD, ignore
		usr.shortcuts.vars["shortcut[slot_index]"] = null     // dropped on the world, clear the slot
		usr.client?.RefreshHotbar()

/atom/movable/shud/orbpart
	mouse_opacity = 0

/atom/movable/shud/orb
	appearance_flags = KEEP_TOGETHER // so the shield glow outlines the whole orb
	var/atom/movable/shud/orbpart/fill  // liquid, rises from the bottom
	var/atom/movable/shud/orbpart/drain // injury/fatigue darkness, descends from the top
	New(loc, base_icon, fill_icon, drain_icon, top_icon)
		..()
		var/atom/movable/shud/orbpart/base = new
		base.icon = base_icon
		fill = new
		fill.icon = fill_icon
		fill.filters = filter(type="alpha", icon='HUD/orb_cut.png', y=SHUD_FILL_EMPTY_Y)
		drain = new
		drain.icon = drain_icon
		drain.filters = filter(type="alpha", icon='HUD/orb_cut.png', y=SHUD_DRAIN_HIDDEN_Y)
		var/atom/movable/shud/orbpart/glass = new
		glass.icon = top_icon
		vis_contents += base
		vis_contents += fill
		vis_contents += drain
		vis_contents += glass
	Del()
		for(var/atom/movable/o in vis_contents)
			vis_contents -= o
			del o
		fill = null
		drain = null
		..()

/atom/movable/shud/orbtext
	layer = SHUD_LAYER + 0.5
	maptext_width = 96  // wider than the orb so "100% (100%)" fits on one line
	maptext_height = 40
	maptext_x = -13     // recenters the wide text over the orb
	maptext_y = 4

client
	var/tmp
		list/shud_parts
		list/shud_slots
		atom/movable/shud/orb/orb_health
		atom/movable/shud/orb/orb_energy
		atom/movable/shud/orbtext/orbtext_health
		atom/movable/shud/orbtext/orbtext_energy
		health_glowing = FALSE
		obj/hotbar_ticker/hotbar_ticker   // per-tick cooldown updater on the global_loop
		// last shown values, so fill animations can pace by delta
		shud_hp_last = 0
		shud_en_last = 0
		shud_inj_last = 0
		shud_ftg_last = 0

client/proc/InitSkillHUD()
	ClearSkillHUD()
	if(!mob) return
	shud_parts = list()
	shud_slots = list()
	shud_hp_last = 0
	shud_en_last = 0
	shud_inj_last = 0
	shud_ftg_last = 0
	for(var/i = 1 to SHUD_SLOTS)
		var/atom/movable/shud/slot/s = new
		s.slot_index = i
		s.screen_loc = "CENTER:[SHUD_ROW_LEFT + (i-1)*SHUD_PITCH],SOUTH:[SHUD_ROW_Y]"
		shud_slots += s
		shud_parts += s
	orb_energy = new(null, 'HUD/orb_energy_base.png', 'HUD/fill_energy.png', 'HUD/drain_energy.png', 'HUD/orb_energy_top.png')
	orb_energy.screen_loc = "CENTER:[SHUD_ORB_LEFT_X],SOUTH:[SHUD_ORB_Y]"
	shud_parts += orb_energy
	orb_health = new(null, 'HUD/orb_health_base.png', 'HUD/fill_health.png', 'HUD/drain_health.png', 'HUD/orb_health_top.png')
	orb_health.screen_loc = "CENTER:[SHUD_ORB_RIGHT_X],SOUTH:[SHUD_ORB_Y]"
	shud_parts += orb_health
	orbtext_energy = new
	orbtext_energy.screen_loc = "CENTER:[SHUD_ORB_LEFT_X],SOUTH:[SHUD_ORB_Y]"
	shud_parts += orbtext_energy
	orbtext_health = new
	orbtext_health.screen_loc = "CENTER:[SHUD_ORB_RIGHT_X],SOUTH:[SHUD_ORB_Y]"
	shud_parts += orbtext_health
	InitMenuButton()
	InitInventoryButton()
	InitCharacterMenuButton()
	InitSkillMenuButton()
	for(var/atom/movable/o in shud_parts)
		screen += o
	InitCharacterCard() // top-left card keeps its own object list
	mob.UpdateResourceOrbs()
	RefreshHotbar()     // paint slots from the saved /shortcut datum
	hotbar_ticker = new
	hotbar_ticker.owner = src
	if(global_loop) global_loop.Add(hotbar_ticker)
	// RefreshHotbar above already ran ApplyKeybinds to install the key binds

client/proc/ClearSkillHUD()
	if(hotbar_ticker)
		if(global_loop) global_loop.Remove(hotbar_ticker)
		del hotbar_ticker
		hotbar_ticker = null
	ResetMenuHUD()
	ResetInventoryHUD()
	ResetCharacterCard()
	CloseCharacterMenu()
	ResetSkillMenuHUD()
	health_glowing = FALSE
	orb_health = null
	orb_energy = null
	orbtext_health = null
	orbtext_energy = null
	shud_slots = null   // slot objects are freed via shud_parts below
	if(shud_parts)
		while(shud_parts.len)
			var/atom/movable/o = shud_parts[shud_parts.len]
			shud_parts.len--
			screen -= o
			del o
		shud_parts = null

mob/proc/UpdateResourceOrbs()
	if(!client) return
	var/enp = EnergyMax ? round((Energy / EnergyMax) * 100, 0.01) : 0
	client.UpdateOrbDisplay(round(Health, 0.01), round(VaizardHealth + BioArmor, 0.01), round(TotalInjury, 0.01), enp, round(TotalFatigue, 0.01))

client/proc/OrbAnimTime(oldval, newval)
	var/delta = abs(newval - oldval)
	if(!delta) return 0
	return min(16, 8 + delta / 12)

client/proc/UpdateOrbDisplay(hp, shield, inj, enp, ftg)
	if(!orb_health || !orb_energy) return
	var/hpc = min(max(hp, 0), 100)
	var/enc = min(max(enp, 0), 100)
	var/injc = min(max(inj, 0), 100)
	var/ftgc = min(max(ftg, 0), 100)
	var/t = OrbAnimTime(shud_hp_last, hpc)
	if(t) animate(orb_health.fill.filters[1], y = round(SHUD_BALL_D * hpc / 100) + SHUD_FILL_EMPTY_Y, time = t, easing = SINE_EASING)
	t = OrbAnimTime(shud_en_last, enc)
	if(t) animate(orb_energy.fill.filters[1], y = round(SHUD_BALL_D * enc / 100) + SHUD_FILL_EMPTY_Y, time = t, easing = SINE_EASING)
	t = OrbAnimTime(shud_inj_last, injc)
	if(t) animate(orb_health.drain.filters[1], y = SHUD_DRAIN_HIDDEN_Y - round(SHUD_BALL_D * injc / 100), time = t, easing = SINE_EASING)
	t = OrbAnimTime(shud_ftg_last, ftgc)
	if(t) animate(orb_energy.drain.filters[1], y = SHUD_DRAIN_HIDDEN_Y - round(SHUD_BALL_D * ftgc / 100), time = t, easing = SINE_EASING)
	shud_hp_last = hpc
	shud_en_last = enc
	shud_inj_last = injc
	shud_ftg_last = ftgc

	if(shield > 0 && !health_glowing)
		health_glowing = TRUE
		orb_health.filters = filter(type="outline", size=1, color="#4fa8ff")
	else if(shield <= 0 && health_glowing)
		health_glowing = FALSE
		orb_health.filters = null

	var/htext = "<center><span style=\"[SHUD_FONT_STYLE]; color:#ffffff\">[hp]%"
	if(shield > 0)
		htext += " <span style=\"color:#7fc4ff\">([shield]%)</span>"
	htext += "</span>"
	if(inj > 0)
		htext += "<br><span style=\"[SHUD_FONT_STYLE]; color:#ff8a5c\">[inj]%</span>"
	htext += "</center>"
	orbtext_health.maptext = htext
	orbtext_health.filters = filter(type="outline", size=1, color="#000000")

	var/etext = "<center><span style=\"[SHUD_FONT_STYLE]; color:#ffffff\">[enp]%</span>"
	if(ftg > 0)
		etext += "<br><span style=\"[SHUD_FONT_STYLE]; color:#e8d44d\">[ftg]%</span>"
	etext += "</center>"
	orbtext_energy.maptext = etext
	orbtext_energy.filters = filter(type="outline", size=1, color="#000000")

client/proc/HotbarKeyLabel(n)
	if(mob && n >= 1 && n <= length(HOTBAR_DEFAULT_KEYS)) return mob.KeybindKey("hotbar[n]")
	return ""

// call after any assign/swap/clear and once at HUD init
client/proc/RefreshHotbar()
	if(!mob || !shud_slots) return
	mob.initShortcuts()
	for(var/atom/movable/shud/slot/s in shud_slots)
		var/obj/Skills/S = mob.shortcuts.vars["shortcut[s.slot_index]"]
		s.SetSkill(S, HotbarKeyLabel(s.slot_index))
	RefreshHotbarCooldowns()
	ApplyKeybinds()   // re-sync key binds and held-skill +UP releases on every slot change

client/proc/RefreshHotbarCooldowns()
	var/any = FALSE
	if(shud_slots)
		for(var/atom/movable/shud/slot/s in shud_slots)
			if(s.UpdateCooldown()) any = TRUE
	return any

// rides the per-tick global_loop so the veil descends smoothly
/obj/hotbar_ticker
	var/client/owner
	Update()
		if(!owner || !owner.mob)
			global_loop.Remove(src)
			del src
			return
		owner.RefreshHotbarCooldowns()
