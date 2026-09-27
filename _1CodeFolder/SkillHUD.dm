#define SHUD_SLOTS 12
#define SHUD_PITCH 32
#define SHUD_ROW_LEFT -192
#define SHUD_ROW_Y 30

#if fexists("../Icons/Private/HotbarOrbs/orb_cut.png") || fexists("Icons/Private/HotbarOrbs/orb_cut.png")
#define SHUD_PRIVATE_ART 1
#else
#define SHUD_PRIVATE_ART 0
#endif

#if SHUD_PRIVATE_ART
#define SHUD_SLOT_ICON  'Icons/Private/HotbarOrbs/hud_slot.png'
#define SHUD_ORB_CUT    'Icons/Private/HotbarOrbs/orb_cut.png'
#define SHUD_EN_BASE    'Icons/Private/HotbarOrbs/orb_en_base.png'
#define SHUD_EN_FILL    'Icons/Private/HotbarOrbs/fill_en.png'
#define SHUD_EN_DRAIN   'Icons/Private/HotbarOrbs/drain_en.png'
#define SHUD_EN_TOP     'Icons/Private/HotbarOrbs/orb_en_top.png'
#define SHUD_HP_BASE    'Icons/Private/HotbarOrbs/orb_hp_base.png'
#define SHUD_HP_FILL    'Icons/Private/HotbarOrbs/fill_hp.png'
#define SHUD_HP_DRAIN   'Icons/Private/HotbarOrbs/drain_hp.png'
#define SHUD_HP_TOP     'Icons/Private/HotbarOrbs/orb_hp_top.png'
#define SHUD_MANA_TRACK 'Icons/Private/HotbarOrbs/mana_track.png'
#define SHUD_MANA_FILL  'Icons/Private/HotbarOrbs/mana_fill.png'
#define SHUD_MANA_CUT   'Icons/Private/HotbarOrbs/mana_cut.png'

#define SHUD_ORB_Y 14
#define SHUD_ORB_LEFT_X -258
#define SHUD_ORB_RIGHT_X 176
#define SHUD_ORB_D 76     // orb art width; the row+orbs span SHUD_ORB_LEFT_X to SHUD_ORB_RIGHT_X+this
#define SHUD_ORB_H 60
#define SHUD_BALL_D 42
#define SHUD_FILL_EMPTY_Y -46
#define SHUD_DRAIN_HIDDEN_Y 56
#define SHUD_ORB_TEXT_X -7
#define SHUD_MANA_X -254
#define SHUD_MANA_Y 24
#define SHUD_MANA_SPAN 48
#define SHUD_MANA_EMPTY_Y -49
#else
#define SHUD_SLOT_ICON  'HUD/hud_slot.png'
#define SHUD_ORB_CUT    'HUD/orb_cut.png'
#define SHUD_EN_BASE    'HUD/orb_energy_base.png'
#define SHUD_EN_FILL    'HUD/fill_energy.png'
#define SHUD_EN_DRAIN   'HUD/drain_energy.png'
#define SHUD_EN_TOP     'HUD/orb_energy_top.png'
#define SHUD_HP_BASE    'HUD/orb_health_base.png'
#define SHUD_HP_FILL    'HUD/fill_health.png'
#define SHUD_HP_DRAIN   'HUD/drain_health.png'
#define SHUD_HP_TOP     'HUD/orb_health_top.png'
#define SHUD_MANA_TRACK 'HUD/lifebar_track.png'
#define SHUD_MANA_FILL  'HUD/lifebar_fill.png'
#define SHUD_MANA_CUT   'HUD/lifebar_mask.png'

#define SHUD_ORB_Y 12
#define SHUD_ORB_LEFT_X -267
#define SHUD_ORB_RIGHT_X 198
#define SHUD_ORB_D 69
#define SHUD_ORB_H 69
#define SHUD_BALL_D 44
#define SHUD_FILL_EMPTY_Y -54
#define SHUD_DRAIN_HIDDEN_Y 59
#define SHUD_ORB_TEXT_X -13
#define SHUD_MANA_X -267
#define SHUD_MANA_Y 12
#define SHUD_MANA_SPAN 14
#define SHUD_MANA_EMPTY_Y -14
#endif

#define SHUD_LAYER (FLY_LAYER+2)
#define SHUD_FONT_STYLE "font-family:'monogram'; font-size:12pt"
#define SHUD_TEXT_LINE 16
#define SHUD_ORB_TEXT_H 56
#define SHUD_ORB_TEXT_LINE_Y(n) (SHUD_FILL_EMPTY_Y + SHUD_ORB_H + round(SHUD_BALL_D / 2) - SHUD_ORB_TEXT_H + (n) * (SHUD_TEXT_LINE / 2))

/atom/movable/shud
	plane = HUD_PLANE //off plane 0 so the farblur world capture can't eat or ghost the HUD
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

// blue glow on a slot while its skill is held / a beam charges / a timed buff is active
#define SLOT_GLOW_COLOR "#49b6ff"
#define SLOT_GLOW_SIZE 4
#define SLOT_GLOW_IN 2    
#define SLOT_GLOW_OUT 5   
#define SLOT_FLASH_CD_COLOR "#ff5a5a"   // red flash, skill pressed while unusable
#define SLOT_FLASH_OUT 4                // one-shot use/cooldown flash to fade

/proc/SkillCDRemaining(obj/Skills/S)
	if(!S || S.cooldown_remaining <= 0) return 0
	if(!S.cooldown_start || !S.cooldown_start_wt) return S.cooldown_remaining
	return max(0, S.cooldown_remaining - (world.time - S.cooldown_start_wt))

/proc/SkillNextChargeETA(obj/Skills/S)
	if(!S || !S.recharge_ends || !S.recharge_ends.len) return 0
	var/best = 0
	for(var/t in S.recharge_ends)
		if(!best || t < best)
			best = t
	return max(0, best - world.time)

/atom/movable/shud/slottext
	mouse_opacity = 0
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/slot
	icon = SHUD_SLOT_ICON
	mouse_opacity = 2                          // full box so drag-drops land reliably
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/slot_index
	var/obj/Skills/cur
	var/on_cd = FALSE
	var/anim_key = 0                           // cooldown_start the veil animate is running for (0 = none)
	var/atom/movable/shud/orbpart/iconpart
	var/atom/movable/shud/orbpart/cdfill
	var/atom/movable/shud/slottext/keytext
	var/atom/movable/shud/slottext/cdtext
	var/atom/movable/shud/slottext/chargetext
	var/glow_on = FALSE
	var/glow_busy = FALSE     // a one-shot flash currently owns the glow filter
	var/glow_seq = 0          // flash token so rapid flashes don't look bad
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
		cdtext = new
		cdtext.layer = SHUD_LAYER + 0.6
		cdtext.maptext_width = 32
		cdtext.maptext_height = 14
		cdtext.maptext_y = 9
		chargetext = new
		chargetext.layer = SHUD_LAYER + 0.6
		chargetext.maptext_width = 8
		chargetext.maptext_height = 14
		chargetext.maptext_x = SLOT_ICON_OFF + SLOT_ICON_SZ - 6
		chargetext.maptext_y = SLOT_ICON_OFF
		vis_contents += iconpart
		vis_contents += cdfill
		vis_contents += keytext
		vis_contents += chargetext
	Del()
		for(var/atom/movable/o in vis_contents)
			vis_contents -= o
			del o
		iconpart = null
		cdfill = null
		keytext = null
		cdtext = null
		chargetext = null
		..()
	proc/SetSkill(obj/Skills/S, keylabel)
		cur = S
		on_cd = FALSE
		anim_key = 0
		if(S)
			var/icon/I = icon(SkillMenuIcon(S), SkillMenuIconState(S))
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
		cdtext.maptext = ""
		SetChargeText()
	// replacing the filter stops any running animate, used to freeze on RP-pause
	proc/SetVeilFrac(frac)
		cdfill.filters = filter(type="alpha", icon='HUD/cd_mask.png', y = CD_EMPTY_Y + round(CD_H * frac))
	proc/GlowSet(color, size, intime)            // intime 0 = snap straight to `size`
		iconpart.filters = filter(type="drop_shadow", x=0, y=0, size=(intime ? 1 : size), color=color)
		if(intime) animate(iconpart.filters[1], size=size, time=intime)
	proc/SetGlow(on)
		if(on == glow_on) return
		glow_on = on
		if(glow_busy) return                     
		if(on)
			GlowSet(istext(on) ? on : SLOT_GLOW_COLOR, SLOT_GLOW_SIZE, SLOT_GLOW_IN)
		else if(iconpart.filters && iconpart.filters.len)
			animate(iconpart.filters[1], size=0, time=SLOT_GLOW_OUT)
			var/atom/movable/ip = iconpart
			spawn(SLOT_GLOW_OUT)
				if(ip && !glow_on && !glow_busy) ip.filters = null
	proc/FlashGlow(color)
		glow_busy = TRUE
		glow_seq += 1
		var/myseq = glow_seq
		GlowSet(color, SLOT_GLOW_SIZE, 0)        // snap to full, then fade
		animate(iconpart.filters[1], size=0, time=SLOT_FLASH_OUT)
		spawn(SLOT_FLASH_OUT)
			if(glow_seq != myseq) return         // a newer flash superseded this one
			glow_busy = FALSE
			if(glow_on)
				GlowSet(istext(glow_on) ? glow_on : SLOT_GLOW_COLOR, SLOT_GLOW_SIZE, 0)   // hand back to the sustained glow
			else if(iconpart.filters)
				iconpart.filters = null
	proc/SetCDText(rem)
		if(rem <= 0)
			if(cdtext.maptext) cdtext.maptext = ""
			return
		var/r = round(rem)
		cdtext.maptext = "<center><span style=\"[SHUD_FONT_STYLE]; color:#ffffff\">[(r - (r % 10)) / 10].[r % 10]</span></center>"
	proc/SetChargeText()
		if(!chargetext) return
		if(!cur || cur.MaxCharges <= 0)
			if(chargetext.maptext) chargetext.maptext = ""
			return
		var/n = max(cur.Charges, 0)
		chargetext.maptext_width = 6 * length("[n]") + 2
		chargetext.maptext_x = SLOT_ICON_OFF + SLOT_ICON_SZ - 6 * length("[n]")
		chargetext.maptext = "<span style=\"[SHUD_FONT_STYLE]; color:[cur.Charges > 0 ? "#ffd76a" : "#ff5a5a"]\">[n]</span>"
	proc/UpdateCooldown()
		if(!cur)
			SetCDText(0)
			return FALSE
		if(cur.Cooldown == -1)
			var/locked = (cur.Using || cur.cooldown_remaining > 0)
			iconpart.alpha = locked ? 120 : 255
			cdfill.alpha = locked ? 255 : 0
			SetVeilFrac(locked ? 1 : 0)
			anim_key = 0
			on_cd = locked
			SetCDText(0)
			return FALSE
		if(cur.MaxCharges > 0)
			SetChargeText()
			var/eta = SkillNextChargeETA(cur)
			if(cur.Charges <= 0)
				on_cd = TRUE
				iconpart.alpha = 120
				cdfill.alpha = 255
				var/total = cur.ChargeRefresh * 10
				SetVeilFrac(total ? min(eta / total, 1) : 1)
				SetCDText(eta)
			else
				if(on_cd)
					iconpart.alpha = 255
					cdfill.alpha = 0
					SetVeilFrac(0)
					on_cd = FALSE
				SetCDText(0)
			anim_key = 0
			return on_cd
		var/rem = SkillCDRemaining(cur)
		if(!((cur.Using || cur.cooldown_remaining > 0) && rem > 0))
			if(on_cd)
				iconpart.alpha = 255
				cdfill.alpha = 0
				SetVeilFrac(0)
				on_cd = FALSE
				anim_key = 0
			SetCDText(0)
			return FALSE
		on_cd = TRUE
		iconpart.alpha = 120
		cdfill.alpha = 255
		var/total = cur.cooldown_full || cur.cooldown_remaining
		var/frac = total ? rem / total : 0
		SetCDText(rem) 
		animate(cdfill.filters[1], y = CD_EMPTY_Y + CD_H * frac, time = world.tick_lag, easing = LINEAR_EASING)
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
	layer = SHUD_LAYER - 0.1
	appearance_flags = KEEP_TOGETHER // so the shield glow outlines the whole orb
	var/atom/movable/shud/orbpart/fill  // liquid, rises from the bottom
	var/atom/movable/shud/orbpart/drain // injury/fatigue darkness, descends from the top
	New(loc, base_icon, fill_icon, drain_icon, top_icon)
		..()
		var/atom/movable/shud/orbpart/base = new
		base.icon = base_icon
		fill = new
		fill.icon = fill_icon
		fill.filters = filter(type="alpha", icon=SHUD_ORB_CUT, y=SHUD_FILL_EMPTY_Y)
		drain = new
		drain.icon = drain_icon
		drain.filters = filter(type="alpha", icon=SHUD_ORB_CUT, y=SHUD_DRAIN_HIDDEN_Y)
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
	maptext_height = SHUD_ORB_TEXT_H
	maptext_x = SHUD_ORB_TEXT_X
	maptext_y = 2
	proc/SetLines(list/lines)
		maptext_y = SHUD_ORB_TEXT_LINE_Y(lines.len)
		maptext = "<center>[jointext(lines, "<br>")]</center>"

/atom/movable/shud/manabar
	icon = SHUD_MANA_TRACK
	layer = SHUD_LAYER + 0.3
	var/atom/movable/shud/orbpart/fill
	New()
		..()
		fill = new
		fill.icon = SHUD_MANA_FILL
		fill.layer = SHUD_LAYER + 0.31
		fill.filters = filter(type="alpha", icon=SHUD_MANA_CUT, y=SHUD_MANA_EMPTY_Y)
		vis_contents += fill
	Del()
		for(var/atom/movable/o in vis_contents)
			vis_contents -= o
			del o
		fill = null
		..()

client
	var/tmp
		list/shud_parts
		list/shud_slots
		atom/movable/shud/orb/orb_health
		atom/movable/shud/orb/orb_energy
		atom/movable/shud/orbtext/orbtext_health
		atom/movable/shud/orbtext/orbtext_energy
		atom/movable/shud/manabar/manabar
		health_glowing = FALSE
		obj/hotbar_ticker/hotbar_ticker   // per-tick cooldown updater on the global_loop
		// last shown values, so fill animations can pace by delta
		shud_hp_last = 0
		shud_en_last = 0
		shud_inj_last = 0
		shud_ftg_last = 0
		shud_mp_last = 0

client/proc/InitBeltHUD()
	return

client/proc/PositionBeltHUD()
	return

client/proc/ResetBeltHUD()
	return

client/proc/RefreshBeltHUD()
	return

client/proc/InitAmmoHUD()
	return

client/proc/PositionAmmoHUD()
	return

client/proc/ResetAmmoHUD()
	return

client/proc/RefreshAmmoHUD()
	return

client/proc/PositionSkillHUD()
	PositionBeltHUD()
	PositionAmmoHUD()
	if(!shud_slots || !shud_slots.len) return
	var/list/v = splittext("[view]", "x")
	if(v.len < 2) return
	var/tw = text2num(v[1])
	if(!tw) return
	var/vw = tw * world.icon_size
	var/mid = round(vw / 2)
	for(var/i = 1 to shud_slots.len)
		var/atom/movable/shud/slot/s = shud_slots[i]
		if(!s) continue
		s.screen_loc = "1:[mid + SHUD_ROW_LEFT + (i-1)*SHUD_PITCH],SOUTH:[SHUD_ROW_Y]"
		if(s.cdtext) s.cdtext.screen_loc = s.screen_loc
	var/lx = max(mid + SHUD_ORB_LEFT_X, 0)
	var/rx = min(mid + SHUD_ORB_RIGHT_X, vw - SHUD_ORB_D)
	var/ll = "1:[lx],SOUTH:[SHUD_ORB_Y]"
	var/rl = "1:[rx],SOUTH:[SHUD_ORB_Y]"
	if(orb_energy) orb_energy.screen_loc = ll
	if(orbtext_energy) orbtext_energy.screen_loc = ll
	if(orb_health) orb_health.screen_loc = rl
	if(orbtext_health) orbtext_health.screen_loc = rl
	if(manabar) manabar.screen_loc = "1:[lx + (SHUD_MANA_X - SHUD_ORB_LEFT_X)],SOUTH:[SHUD_MANA_Y]"

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
		shud_slots += s
		shud_parts += s
		shud_parts += s.cdtext
	orb_energy = new(null, SHUD_EN_BASE, SHUD_EN_FILL, SHUD_EN_DRAIN, SHUD_EN_TOP)
	shud_parts += orb_energy
	orb_health = new(null, SHUD_HP_BASE, SHUD_HP_FILL, SHUD_HP_DRAIN, SHUD_HP_TOP)
	shud_parts += orb_health
	manabar = new
	shud_parts += manabar
	orbtext_energy = new
	shud_parts += orbtext_energy
	orbtext_health = new
	shud_parts += orbtext_health
	PositionSkillHUD()
	InitMenuButton()
	InitInventoryButton()
	InitCharacterMenuButton()
	InitSkillMenuButton()
	InitTechButton()
	InitAcquireButton()
	InitLifeSkillsButton()
	InitArcaneButton()
	for(var/atom/movable/o in shud_parts)
		screen += o
	AdminPageInitButton()
	InitCharacterCard() // top-left card keeps its own object list
	mob.UpdateResourceOrbs()
	mob.TomeScrubStale()
	mob.DisableSlottableSkillVerbs()   // slotted/slottable skills become hotbar-only
	RefreshHotbar()     // paint slots from the saved /shortcut datum
	InitBeltHUD()
	InitAmmoHUD()
	hotbar_ticker = new
	hotbar_ticker.owner = src
	if(global_loop)
		global_loop.Add(hotbar_ticker)
	else
		spawn()
			var/obj/hotbar_ticker/t = hotbar_ticker
			while(t && src && t == src.hotbar_ticker && !global_loop)
				sleep(10)
			if(t && src && t == src.hotbar_ticker && global_loop)
				global_loop.Add(t)
	// RefreshHotbar above already ran ApplyKeybinds to install the key binds

client/proc/ClearSkillHUD()
	ResetBeltHUD()
	ResetAmmoHUD()
	if(hotbar_ticker)
		if(global_loop) global_loop.Remove(hotbar_ticker)
		del hotbar_ticker
		hotbar_ticker = null
	ResetMenuHUD()
	ResetInventoryHUD()
	ResetCharacterCard()
	CloseCharacterMenu()
	ResetSkillMenuHUD()
	ResetTechHUD()
	ResetAcquireHUD()
	ResetLifeSkillsHUD()
	ResetArcaneHUD()
	ResetStationHUD()
	ResetLogHUD()
	ResetAhHUD()
	CloseOppMenu()
	health_glowing = FALSE
	orb_health = null
	orb_energy = null
	orbtext_health = null
	orbtext_energy = null
	manabar = null
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
	var/cap = ManaCap()
	var/mp = cap > 0 ? round(min(ManaAmount / cap, 1) * 100, 0.01) : 0
	client.UpdateOrbDisplay(round(HealthPct(), 0.01), round(VaizardHealth + BioArmor, 0.01), round(TotalInjury, 0.01), enp, round(TotalFatigue, 0.01), mp)

client/proc/OrbAnimTime(oldval, newval)
	var/delta = abs(newval - oldval)
	if(!delta) return 0
	return min(16, 8 + delta / 12)

client/proc/UpdateOrbDisplay(hp, shield, inj, enp, ftg, mp = 0)
	if(!orb_health || !orb_energy) return
	var/hpc = min(max(hp, 0), 100)
	var/enc = min(max(enp, 0), 100)
	var/injc = min(max(inj, 0), 100)
	var/ftgc = min(max(ftg, 0), 100)
	var/mpc = min(max(mp, 0), 100)
	var/t = OrbAnimTime(shud_hp_last, hpc)
	if(t) animate(orb_health.fill.filters[1], y = round(SHUD_BALL_D * hpc / 100) + SHUD_FILL_EMPTY_Y, time = t, easing = SINE_EASING)
	t = OrbAnimTime(shud_en_last, enc)
	if(t) animate(orb_energy.fill.filters[1], y = round(SHUD_BALL_D * enc / 100) + SHUD_FILL_EMPTY_Y, time = t, easing = SINE_EASING)
	t = OrbAnimTime(shud_inj_last, injc)
	if(t) animate(orb_health.drain.filters[1], y = SHUD_DRAIN_HIDDEN_Y - round(SHUD_BALL_D * injc / 100), time = t, easing = SINE_EASING)
	t = OrbAnimTime(shud_ftg_last, ftgc)
	if(t) animate(orb_energy.drain.filters[1], y = SHUD_DRAIN_HIDDEN_Y - round(SHUD_BALL_D * ftgc / 100), time = t, easing = SINE_EASING)
	if(manabar)
		t = OrbAnimTime(shud_mp_last, mpc)
		if(t) animate(manabar.fill.filters[1], y = round(SHUD_MANA_SPAN * mpc / 100) + SHUD_MANA_EMPTY_Y, time = t, easing = SINE_EASING)
	shud_hp_last = hpc
	shud_en_last = enc
	shud_inj_last = injc
	shud_ftg_last = ftgc
	shud_mp_last = mpc

	if(shield > 0 && !health_glowing)
		health_glowing = TRUE
		orb_health.filters = filter(type="outline", size=1, color="#4fa8ff")
	else if(shield <= 0 && health_glowing)
		health_glowing = FALSE
		orb_health.filters = null

	var/list/hl = list("<span style=\"[SHUD_FONT_STYLE]; color:#ffffff\">[hp]%</span>")
	if(shield > 0)
		hl += "<span style=\"[SHUD_FONT_STYLE]; color:#7fc4ff\">([shield]%)</span>"
	if(inj > 0)
		hl += "<span style=\"[SHUD_FONT_STYLE]; color:#ff8a5c\">[inj]%</span>"
	orbtext_health.SetLines(hl)
	orbtext_health.filters = filter(type="outline", size=1, color="#000000")

	var/list/el = list("<span style=\"[SHUD_FONT_STYLE]; color:#ffffff\">[enp]%</span>")
	if(ftg > 0)
		el += "<span style=\"[SHUD_FONT_STYLE]; color:#e8d44d\">[ftg]%</span>"
	orbtext_energy.SetLines(el)
	orbtext_energy.filters = filter(type="outline", size=1, color="#000000")

client/proc/HotbarKeyLabel(n)
	if(!mob || n < 1 || n > length(HOTBAR_DEFAULT_KEYS)) return ""
	var/k = mob.KeybindKey("hotbar[n]") || mob.KeybindKey("hotbar[n]", 2)
	return k ? KeyDisplay(k) : ""

// call after any assign/swap/clear and once at HUD init
client/proc/RefreshHotbar()
	if(!mob || !shud_slots) return
	mob.initShortcuts()
	for(var/atom/movable/shud/slot/s in shud_slots)
		var/obj/Skills/S = mob.shortcuts.vars["shortcut[s.slot_index]"]
		s.SetSkill(S, HotbarKeyLabel(s.slot_index))
	RefreshHotbarCooldowns()
	ApplyKeybinds()   // re-sync key binds and held-skill +UP releases on every slot change
	RefreshBeltHUD()

// a slot glows blue while its skill is in an active state
mob/proc/SkillGlowActive(obj/Skills/S)
	if(!S) return FALSE
	if(S.IsSpell && SpellPrimed(S)) return "#ffd86b"
	if(S == held_skill) return TRUE                                // held skill currently charging
	if(("Charging" in S.vars) && S.vars["Charging"]) return TRUE   // beam mid-charge
	if(istype(S, /obj/Skills/Buffs))
		var/obj/Skills/Buffs/b = S
		if(b.TimerLimit && BuffOn(b)) return TRUE                  // timed buff active
	return FALSE

// matches the slot's cooldown veil: is this skill currently on cooldown / mid-use?
mob/proc/SkillOnCooldown(obj/Skills/S)
	if(!S) return FALSE
	if(S.Cooldown == -1) return (S.Using || S.cooldown_remaining > 0)
	return (S.Using || S.cooldown_remaining > 0) && SkillCDRemaining(S) > 0

// flash the slot after a hotbar press: blue if the skill went off, red if it failed for any reason
client/proc/FlashSkillUse(obj/Skills/S, num, was_on_cd, used)
	if(!mob || !S) return
	var/failed
	if(was_on_cd)
		failed = TRUE
	else if(S.HeldSkill)
		failed = (mob.held_skill != S)                                          // the hold never started
	else
		failed = !(used || S.cooldown_remaining > 0 || S.Using || mob.SkillGlowActive(S))
	FlashSlot(num, failed ? SLOT_FLASH_CD_COLOR : SLOT_GLOW_COLOR)

client/proc/FlashSlot(num, color)
	if(!shud_slots) return
	for(var/atom/movable/shud/slot/s in shud_slots)
		if(s.slot_index == num)
			s.FlashGlow(color)
			return

client/proc/RefreshHotbarCharges()
	if(!shud_slots) return
	for(var/atom/movable/shud/slot/s in shud_slots)
		s.SetChargeText()

client/proc/RefreshHotbarCooldowns()
	var/any = FALSE
	if(shud_slots)
		for(var/atom/movable/shud/slot/s in shud_slots)
			if(s.UpdateCooldown()) any = TRUE
			s.SetGlow(mob.SkillGlowActive(s.cur))
	return any

// rides the per-tick global_loop so the veil descends smoothly
/obj/hotbar_ticker
	var/client/owner
	var/tmp/active = 1
	Update()
		if(!owner || !owner.mob)
			global_loop.Remove(src)
			del src
			return
		if(!active && (round(world.time * 2) % 2))
			return
		owner.RefreshAmmoHUD()
		active = owner.RefreshHotbarCooldowns()
