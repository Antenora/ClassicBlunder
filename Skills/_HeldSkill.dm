// AutoHits and Projectiles apply this by setting HeldSkill = TRUE
// The skill's verb should call usr.BeginHeldSkill(src) instead of
// usr.Activate(src). Override OnHeldRelease(mob/p, benefit) to
// execute the skill.

// ChargeBenefit on release is 0-1 from progress through ChargePeriod.
// Hitting the SweetSpot window sets benefit to SweetSpotBenefit instead

#define HELD_MACRO_PREFIX "HeldKeyDown "
#define HELD_MACRO_FLAG_WINDOW 2

/obj/Skills
	var/HeldSkill        = FALSE  // Enable held-charge behavior for this skill
	var/NoFizzle         = FALSE  // If TRUE, exceeding ChargePeriod auto-releases
	var/ChargePeriod     = 3      // Max hold time in seconds
	var/SweetSpot        = 0      // Seconds from charge start when sweet spot opens (0 = disabled)
	var/SweetSpotWindow  = 0.3    // Width of the sweet spot window in seconds (default 0.3s = 3 ticks)
	var/SweetSpotBenefit = 1.5    // ChargeBenefit value when the sweet spot window is hit
	var/ChargeOverlay    = null   // Icon displayed on mob while charging
	var/ChargeWaveIcon   = 'Icons/Effects/KenShockwave.dmi'  // Icon for periodic charge shockwave
	var/ChargeWaveBlend  = 1      // Blend mode for the periodic charge shockwave
	var/ChargeBenefit    = 0      // Set on release
	var/HeldVerbName     = null   // Optional override for macro detection;
	                              // defaults to Z.name if null
	var/InfiniteHold     = FALSE  // If TRUE, hold continues indefinitely
	var/FireRate         = 0      // Smaller number = faster
	var/HeldBeam         = FALSE
	var/HeldBeamUncapped = FALSE
	var/HeldVulnerability = 0

globalTracker/var/BEAM_OVERCHARGE_DRAIN = 2
globalTracker/var/HELD_BEAM_MOVE_PENALTY = 2
globalTracker/var/HELD_BEAM_FULL_SPAN = 1.5

/obj/Skills/proc/OnHeldRelease(mob/p, var/benefit, var/sweet_spot_hit = FALSE)
	// Override in individual skills to execute the charged attack.

/obj/Skills/proc/OnHeldFizzle(mob/p)

/obj/Skills/proc/OnHeldStart(mob/p)
	// Called once when BeginHeldSkill successfully begins charging
	// Override to apply effects that last for the duration of the hold

/obj/Skills/proc/OnHeldTick(mob/p)
	// Called by ChargeLoop, tick based on FireRate, smaller = faster

// This avoids stat changes to skills persisting across use (mostly for projectiles)

/obj/Skills/Projectile/proc/ResetHeldConfig()
	if(!HeldSkill) return
	DamageMult = initial(DamageMult)
	AccMult    = initial(AccMult)
	IconLock   = initial(IconLock)
	LockX      = initial(LockX)
	LockY      = initial(LockY)
	Distance   = initial(Distance)
	Radius     = initial(Radius)
	Explode    = initial(Explode)
	Homing     = initial(Homing)
	MultiHit   = initial(MultiHit)
	Stream     = initial(Stream)
	Blasts     = initial(Blasts)

/client/var/tmp/SweetSpotHeldSkillDebug = FALSE
/client/var/tmp/list/held_skill_key_cache = null
/client/var/tmp/held_skill_cache_build_start = 0
/client/var/tmp/held_skill_macro_set = "macro"
/client/control_freak = CONTROL_FREAK_ALL

/client/New(topicdata)
	..()

// Charge state

/mob
	var/tmp/obj/Skills/held_skill         = null
	var/tmp/held_charge_start             = 0
	var/tmp/image/held_charge_overlay_ref = null
	var/tmp/image/held_charge_bar_bg_ref  = null
	var/tmp/list/held_charge_bar_sweet_refs = null
	var/tmp/list/held_charge_bar_fill_refs = null
	var/tmp/held_skill_macro_key          = null
	var/tmp/held_skill_last_release       = 0
	var/tmp/held_skill_from_macro         = 0
	var/tmp/held_skill_pending_key        = null


/proc/_normalizeHeldName(s)
	if(!s) return ""
	s = replacetext(s, "_", " ")
	s = replacetext(s, "-", " ")
	return lowertext(s)

/proc/_dequoteMacroCmd(s)
	if(s && length(s) >= 2 && copytext(s, 1, 2) == "\"" && copytext(s, length(s)) == "\"")
		return copytext(s, 2, length(s))
	return s

// Candidate keys to probe when finding which key the player has the
// skill bound to.

/proc/_heldSkillCandidateKeys()
	return list(
		"A","B","C","D","E","F","G","H","I","J","K","L","M",
		"N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
		"0","1","2","3","4","5","6","7","8","9",
		"F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
		"Numpad0","Numpad1","Numpad2","Numpad3","Numpad4",
		"Numpad5","Numpad6","Numpad7","Numpad8","Numpad9",
		"NumpadPlus","NumpadMinus","NumpadStar","NumpadSlash",
		"Space","Tab","Return","Backspace",
		"Insert","Home","Delete","End","PageUp","PageDown"
	)

/proc/_getIconWidth(icon_file, icon_state_name)
	if(!icon_file) return 32
	var/icon/I = icon(icon_file, icon_state_name)
	var/w = I.Width()
	if(!isnum(w) || w <= 0) return 32
	return w

/proc/_getIconHeight(icon_file, icon_state_name)
	if(!icon_file) return 32
	var/icon/I = icon(icon_file, icon_state_name)
	var/h = I.Height()
	if(!isnum(h) || h <= 0) return 32
	return h


/mob/proc/CanUseSkill(obj/Skills/Z)
	if(!Z) return FALSE
	if(GCDBlocked(Z)) return FALSE
	if(!CanAttack(-1)) return FALSE
	if(src.Airborne) return FALSE
	if(src.Guarding)
		src << "<font color='red'>You can't use skills while guarding!</font>"
		return FALSE
	if(src.OnMagicalVehicle())
		src << "<font color='red'>You can't use skills while on a magical vehicle!</font>"
		return FALSE
	if(src.passive_handler.Get("Silenced"))
		src << "<font color='red'>You can't use [Z], you are silenced!</font>"
		return FALSE
	if(Z.Sealed)
		src << "<font color='red'>You can't use [Z], it is sealed!</font>"
		return FALSE
	if(Z.Using || Z.cooldown_remaining)
		src << "<font color='red'>[Z] is on cooldown.</font>"
		return FALSE
	if(src.Secret == "Heavenly Restriction" && !Z.heavenlyRestrictionIgnore)
		if(src.secretDatum?:hasRestriction("All Skills")) return FALSE
		if(Z.NeedsSword && src.secretDatum?:hasRestriction("Armed Skills")) return FALSE
	if(Z.NeedsSword && !src.EquippedSword() && !src.HasBladeFisting() && !src.UsingBattleMage())
		src << "<font color='red'>You need a sword to use this technique!</font>"
		return FALSE
	// resource requirements -- availability only; the cost is deducted when the skill fires
	if(Z.HealthCost && src.HealthPct() < Z.HealthCost * glob.WorldDamageMult)
		src << "<font color='red'>You don't have enough health to use [Z].</font>"
		return FALSE
	if(Z.WoundCost && src.TotalInjury + Z.WoundCost * glob.WorldDamageMult > 99)
		src << "<font color='red'>You're too wounded to use [Z].</font>"
		return FALSE
	if(Z.EnergyCost)
		var/drain = src.passive_handler["Drained"] ? Z.EnergyCost * (1 + src.passive_handler["Drained"]/10) : Z.EnergyCost
		if(src.Energy < drain && !src.CheckSpecial("One Hundred Percent Power") && !src.CheckSpecial("Fifth Form") && !CheckActive("Eight Gates"))
			src << "<font color='red'>You don't have enough energy to use [Z].</font>"
			return FALSE
	if(Z.FatigueCost && src.TotalFatigue + Z.FatigueCost > 99)
		src << "<font color='red'>You're too fatigued to use [Z].</font>"
		return FALSE
	if(Z.ManaCost && !src.HasDrainlessMana())
		var/drain = Z.ManaCost
		drain *= src.ChakraCostMult(Z)
		if(drain <= 0) drain = 0.5
		var/need = src.TomeSpell(Z) ? drain * (1 - (0.45 * src.TomeSpell(Z))) : drain
		if(src.ManaAmount < need)
			src << "<font color='red'>You don't have enough mana to activate [Z].</font>"
			return FALSE
	if(Z.CapacityCost && src.TotalCapacity + Z.CapacityCost > 99)
		src << "<font color='red'>You don't have enough capacity to use [Z].</font>"
		return FALSE
	if(Z.CorruptionCost && src.Corruption - Z.CorruptionCost < 0)
		src << "<font color='red'>You don't have enough Corruption to activate [Z].</font>"
		return FALSE
	return TRUE

/mob/proc/BeginHeldSkill(var/obj/Skills/Z)
	var/from_macro = held_skill_from_macro && (world.time - held_skill_from_macro) <= HELD_MACRO_FLAG_WINDOW
	held_skill_from_macro = 0
	var/hotbar_key = held_skill_pending_key
	held_skill_pending_key = null

	if(held_skill) return  // Already charging something
	if(!Z || !Z.HeldSkill) return
	if(Z.HeldBeam && Beaming == 2)
		UseProjectile(Z)
		return
	if(Z.HeldBeam && Beaming == 1 && !BeamChannelLive())
		Beaming = 0
		BeamCharging = 0
	if(Z.HeldBeam && Beaming)
		return
	var/client/C = client
	if(!C) return
	if(!CanUseSkill(Z)) return

	// All guards run before touching any charge state.

	var/list/keys
	if(hotbar_key)
		keys = list(hotbar_key)
		from_macro = TRUE
	else
		src << "<font color='red'>Put [Z.name] in a hotbar slot and hold its key from there.</font>"
		return

	// Clicked from the verb panel / command line instead of pressed on a key
	if(!from_macro)
		if(keys && keys.len)
			src << "<font color='red'>Use [Z.name] from the key you bound it to, not by clicking it. (If you just changed the bind, relog.)</font>"
		else
			src << "<font color='red'>Bind [Z.name] to a key and use it from that key, not by clicking it. (If you just bound it, relog.)</font>"
		return

	// No key bound
	if(!keys || !keys.len)
		src << "<font color='red'>Bind [Z.name] to a key first. (Relogging should fix this.)</font>"
		return

	// re-entry guard
	if(held_skill_last_release && world.time - held_skill_last_release < 5)
		return

	if(!hotbar_key)
		for(var/k in keys)
			winset(C, "heldskill_up_[k]", "type=macro;parent=[C.held_skill_macro_set];name=[k]+UP;command=Release-Held-Skill")

	held_skill        = Z
	held_charge_start = world.time
	Z.ChargeBenefit   = 0
	Z.sustain_pour_bank = 0

	if(Z.ChargeOverlay && !held_charge_overlay_ref)
		var/image/I = image(Z.ChargeOverlay)
		I.layer = MOB_LAYER + 0.1
		held_charge_overlay_ref = I
		overlays += I
	ShowHeldChargeBar(Z)
	if(Z.InfiniteHold)
		UpdateHeldChargeBar(1)
	KenShockwave(src, icon=Z.ChargeWaveIcon, Size=0.5, Blend=Z.ChargeWaveBlend, Time=8)

	held_skill_macro_key = keys

	Z.OnHeldStart(src)
	spawn() ChargeLoop(Z)


/mob/verb/HeldKeyDown(cmd as text)
	set name = "HeldKeyDown"
	set hidden = 1
	set instant = 1
	if(!cmd) return
	var/obj/Skills/Z = _resolveHeldSkill(cmd)
	if(!Z) return
	held_skill_from_macro = world.time
	var/ident = replacetext(replacetext(cmd, " ", "_"), "-", "_")
	if(hascall(Z, ident))
		call(Z, ident)()
	else
		BeginHeldSkill(Z)


/mob/proc/_resolveHeldSkill(cmd)
	var/norm = _normalizeHeldName(cmd)
	if(!norm) return null
	for(var/obj/Skills/Z in src.contents)
		if(!Z.HeldSkill) continue
		var/raw = Z.HeldVerbName ? Z.HeldVerbName : Z.name
		if(raw && _normalizeHeldName(raw) == norm) return Z
	for(var/obj/Skills/Z in src.contents)
		if(!Z.HeldSkill) continue
		var/raw = Z.HeldVerbName ? Z.HeldVerbName : Z.name
		if(!raw) continue
		var/rn = _normalizeHeldName(raw)
		if(findtext(norm, rn) || findtext(rn, norm)) return Z
	return null


/mob/proc/findHeldSkillKeys(client/C, obj/Skills/Z)
	var/raw_search = Z.HeldVerbName ? Z.HeldVerbName : Z.name
	if(!raw_search) return null
	var/search = _normalizeHeldName(raw_search)

	if(!C.held_skill_key_cache) return null

	var/list/cache = C.held_skill_key_cache
	for(var/cmd_key in cache)
		if(findtext(cmd_key, search))
			return cache[cmd_key]   // list of every key this skill is bound to

	return null

// Builds the client's held-skill macro key cache only on login now, should help with lag/dcs, players will just need to relog if they change key for their hold skill
/client/proc/RebuildHeldSkillKeyCache()
	if(!src) return
	held_skill_cache_build_start = world.time

	// Only macros whose command matches one of these names will enter the cache,
	// which means movement keys, hotbar slots, and all other macros are ignored
	var/list/held_names = list()
	for(var/T in subtypesof(/obj/Skills))
		if(!initial(T:HeldSkill)) continue
		var/raw = initial(T:HeldVerbName) ? initial(T:HeldVerbName) : initial(T:name)
		if(raw) held_names += _normalizeHeldName(raw)

	var/list/new_cache = list()
	var/list/shortcut_key_map = list()

	var/macro_set_str = winget(src, null, "macro")
	var/macro_params = params2list(macro_set_str)
	var/set_name = "macro"
	for(var/k in macro_params)
		set_name = k
		break

	var/children_str = winget(src, set_name, "children")
	if(children_str)
		for(var/child_id in splittext(children_str, "\n"))
			if(!child_id) continue

			if(copytext(child_id, 1, 14) == "heldskill_up_")
				winset(src, child_id, "parent=[set_name];name=[child_id]_off")
				continue

			var/key_name = winget(src, child_id, "name")
			if(!key_name || findtext(key_name, "+UP")) continue

			var/cmd = _dequoteMacroCmd(winget(src, child_id, "command"))
			if(!cmd) continue

			var/original_cmd = cmd
			if(copytext(cmd, 1, length(HELD_MACRO_PREFIX) + 1) == HELD_MACRO_PREFIX)
				original_cmd = copytext(cmd, length(HELD_MACRO_PREFIX) + 1)

			var/norm_cmd = _normalizeHeldName(original_cmd)

			var/matched_shortcut = FALSE
			for(var/sc_n = 1, sc_n <= 12, sc_n++)
				if(norm_cmd == "skill shortcut [sc_n]")
					if(!shortcut_key_map["[sc_n]"]) shortcut_key_map["[sc_n]"] = list()
					shortcut_key_map["[sc_n]"] |= key_name
					matched_shortcut = TRUE
					break
			if(matched_shortcut) continue

			for(var/held_name in held_names)
				if(findtext(norm_cmd, held_name))
					if(!new_cache[norm_cmd]) new_cache[norm_cmd] = list()
					new_cache[norm_cmd] |= key_name
					winset(src, child_id, "command=\"[HELD_MACRO_PREFIX][original_cmd]\"")
					break
	else
		for(var/k in _heldSkillCandidateKeys())
			var/cmd = _dequoteMacroCmd(winget(src, k, "command"))
			if(!cmd) continue
			var/original_cmd = cmd
			if(copytext(cmd, 1, length(HELD_MACRO_PREFIX) + 1) == HELD_MACRO_PREFIX)
				original_cmd = copytext(cmd, length(HELD_MACRO_PREFIX) + 1)
			var/norm_cmd = _normalizeHeldName(original_cmd)
			var/matched_shortcut = FALSE
			for(var/sc_n = 1, sc_n <= 12, sc_n++)
				if(norm_cmd == "skill shortcut [sc_n]")
					if(!shortcut_key_map["[sc_n]"]) shortcut_key_map["[sc_n]"] = list()
					shortcut_key_map["[sc_n]"] |= k
					matched_shortcut = TRUE
					break
			if(matched_shortcut) continue
			for(var/held_name in held_names)
				if(findtext(norm_cmd, held_name))
					if(!new_cache[norm_cmd]) new_cache[norm_cmd] = list()
					new_cache[norm_cmd] |= k
					winset(src, k, "command=\"[HELD_MACRO_PREFIX][original_cmd]\"")
					break

	var/mob/sc_mob = src.mob
	if(sc_mob && sc_mob.shortcuts)
		for(var/sc_n = 1, sc_n <= 12, sc_n++)
			var/list/sc_keys = shortcut_key_map["[sc_n]"]
			if(!sc_keys || !sc_keys.len) continue
			var/obj/Skills/sc_skill = sc_mob.shortcuts.vars["shortcut[sc_n]"]
			if(!sc_skill || !sc_skill.HeldSkill) continue
			var/sc_raw = sc_skill.HeldVerbName ? sc_skill.HeldVerbName : sc_skill.name
			if(!sc_raw) continue
			var/sc_norm = _normalizeHeldName(sc_raw)
			if(!new_cache[sc_norm]) new_cache[sc_norm] = list()
			for(var/sk in sc_keys)
				new_cache[sc_norm] |= sk

	// Because new_cache is filtered to held skills only, this loop never touches
	// movement keys, hotbar slots, or any other binding.
	for(var/cmd_key in new_cache)
		var/list/bound_keys = new_cache[cmd_key]
		for(var/bound_key in bound_keys)
			winset(src, "heldskill_up_[bound_key]", "type=macro;parent=[set_name];name=[bound_key]+UP;command=Release-Held-Skill")

	// both vars become visible together, after all +UP macros are set.
	held_skill_macro_set = set_name
	held_skill_key_cache = new_cache


/mob/proc/ShowHeldChargeBar(var/obj/Skills/Z)
	var/client/C = client
	if(!C) return
	if(held_charge_bar_bg_ref || held_charge_bar_fill_refs) return

	var/icon_file = 'Icons/UI/ChargeBar.dmi'
	var/mob_w = _getIconWidth(icon, icon_state)
	var/bar_w = _getIconWidth(icon_file, "Bar")
	var/bar_h = _getIconHeight(icon_file, "Bar")
	var/fill_step = 1
	var/fill_left_inset_x = 0
	var/fill_right_inset_x = 3
	var/fill_marker_w = 3

	var/start_x = round((mob_w - bar_w) / 2)
	var/start_y = -(bar_h + 5)

	var/image/bg = image(icon_file, src, "Bar")
	bg.layer = MOB_LAYER + 10
	bg.plane = HUD_PLANE
	bg.appearance_flags = KEEP_APART | NO_CLIENT_COLOR | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	bg.pixel_x = start_x
	bg.pixel_y = start_y
	bg.alpha = 0

	C.images += bg
	held_charge_bar_bg_ref = bg
	held_charge_bar_fill_refs = list()

	var/fill_region_w = max(1, bar_w - fill_left_inset_x - fill_right_inset_x)
	var/segment_count = max(1, fill_region_w - fill_marker_w)
	for(var/i = 0, i < segment_count, i++)
		var/image/fill = image(icon_file, src, "Progress")
		fill.layer = bg.layer + 0.3
		fill.plane = bg.plane
		fill.appearance_flags = bg.appearance_flags
		fill.pixel_x = start_x + fill_left_inset_x + (i * fill_step)
		fill.pixel_y = start_y
		fill.alpha = 0
		held_charge_bar_fill_refs.Add(fill)
		C.images += fill

	if(Z && Z.SweetSpot > 0 && Z.ChargePeriod > 0)
		// VariableSweetSpot is laid out like Progress (1-pixel slanted
		// diagonal in orange). Tiling it at the same pixel_x positions a
		// Progress marker would occupy means the orange lands on exactly
		// the same screen columns the red fill tip will pass through, so
		// the indicator spans precisely the hit window for any combination
		// of SweetSpot, SweetSpotWindow, and ChargePeriod.
		// window_ticks here mirrors the same rounding ReleaseHeldSkill
		// applies so the visible orange covers exactly the integer ticks
		// that actually count as a sweet-spot hit, no more, no less.
		var/window_ticks = max(1, round(Z.SweetSpotWindow * 10))
		var/start_ratio = clamp(Z.SweetSpot / Z.ChargePeriod, 0, 1)
		var/end_ratio = clamp((Z.SweetSpot * 10 + window_ticks) / (Z.ChargePeriod * 10), 0, 1)
		var/first_offset = max(0, floor(segment_count * start_ratio) - 1)
		var/last_offset = max(first_offset, floor(segment_count * end_ratio) - 1)
		var/first_px = start_x + fill_left_inset_x + first_offset
		var/last_px = start_x + fill_left_inset_x + last_offset
		held_charge_bar_sweet_refs = list()
		for(var/px = first_px, px <= last_px, px++)
			var/image/sweet = image(icon_file, src, "VariableSweetSpot")
			sweet.layer = bg.layer + 0.2
			sweet.plane = bg.plane
			sweet.appearance_flags = bg.appearance_flags
			sweet.pixel_x = px
			sweet.pixel_y = start_y
			sweet.alpha = 0
			held_charge_bar_sweet_refs += sweet
			C.images += sweet

	animate(bg, alpha = 255, time = 2)
	if(held_charge_bar_sweet_refs)
		for(var/image/sweet in held_charge_bar_sweet_refs)
			animate(sweet, alpha = 255, time = 2)

/mob/proc/UpdateHeldChargeBar(var/ratio)
	if(!held_charge_bar_bg_ref || !held_charge_bar_fill_refs) return
	ratio = clamp(ratio, 0, 1)

	var/segment_count = held_charge_bar_fill_refs.len
	var/filled_segments = floor(segment_count * ratio)
	if(ratio >= 1) filled_segments = segment_count
	var/i = 0
	for(var/image/fill in held_charge_bar_fill_refs)
		i++
		if(!fill) continue
		fill.alpha = i <= filled_segments ? 255 : 0

/mob/proc/HideHeldChargeBar()
	var/client/C = client
	if(!C) return

	var/image/bg = held_charge_bar_bg_ref
	var/list/sweets = held_charge_bar_sweet_refs
	var/list/fills = held_charge_bar_fill_refs
	held_charge_bar_bg_ref = null
	held_charge_bar_sweet_refs = null
	held_charge_bar_fill_refs = null

	if(bg) animate(bg, alpha = 0, time = 3)
	if(sweets)
		for(var/image/sweet in sweets)
			if(sweet) animate(sweet, alpha = 0, time = 3)
	if(fills)
		for(var/image/fill in fills)
			if(fill) animate(fill, alpha = 0, time = 3)
	sleep(3)
	if(bg) C.images -= bg
	if(sweets)
		for(var/image/sweet in sweets)
			if(sweet) C.images -= sweet
	if(fills)
		for(var/image/fill in fills)
			if(fill) C.images -= fill

/mob/proc/ForceClearHeldChargeState()
	held_skill = null
	held_charge_start = 0
	held_skill_macro_key = null
	dir_locked = 0

	if(held_charge_overlay_ref)
		overlays -= held_charge_overlay_ref
		held_charge_overlay_ref = null

	var/client/C = client
	if(C)
		if(held_charge_bar_bg_ref)
			C.images -= held_charge_bar_bg_ref
		if(held_charge_bar_sweet_refs)
			for(var/image/sweet in held_charge_bar_sweet_refs)
				if(sweet) C.images -= sweet
		if(held_charge_bar_fill_refs)
			for(var/image/fill in held_charge_bar_fill_refs)
				if(fill) C.images -= fill

	held_charge_bar_bg_ref = null
	held_charge_bar_sweet_refs = null
	held_charge_bar_fill_refs = null

// ChargeLoop runs for the duration of the hold

/mob/proc/ChargeLoop(var/obj/Skills/Z)
	FxChargeShimmer(src, Z) //heat wavers over the caster while they hold
	FlashChargeTick(src, 2)
	var/last_tick_fire = 0
	while(held_skill == Z)
		var/hold_smm = SlowMoDelayMult(src)
		if(hold_smm > 1)
			held_charge_start += 2 * (1 - 1 / hold_smm)
		// Interrupt conditions
		var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Charmed/charm_skill = locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Charmed) in src
		if(Stunned || Suspended || Launched || Stasis > 0 || KO || Dead || (charm_skill && BuffOn(charm_skill)))
			FizzleHeldSkill(Z)
			return

		if(Z.HeldBeam)
			var/raw = HeldBeamBenefit(Z)
			UpdateHeldChargeBar(min(raw, 1))
			if(raw >= 1)
				var/drain = glob.BEAM_OVERCHARGE_DRAIN * 0.2
				if(src.Energy <= drain)
					ReleaseHeldSkill()
					return
				src.LoseEnergy(drain)
				if(Z.SustainPour && src.Energy > 20)
					Z.sustain_pour_bank = min(Z.sustain_pour_bank + 0.2, Z.SustainPour)
		else if(Z.InfiniteHold)
			if(Z.FireRate > 0 && world.time - last_tick_fire >= Z.FireRate)
				Z.OnHeldTick(src)
				last_tick_fire = world.time
		else
			// Overheld, fizzle normally, or auto-release if the skill opts out
			if(world.time - held_charge_start > Z.ChargePeriod * 10)
				if(Z.NoFizzle)
					ReleaseHeldSkill()
				else
					FizzleHeldSkill(Z)
				return

			var/hold_ticks = world.time - held_charge_start
			var/progress = clamp(hold_ticks / (Z.ChargePeriod * 10), 0, 1)
			UpdateHeldChargeBar(progress)

		// closing the visual gap after BeginHeldSkill's initial pulse.
		var/ringp = 0.5
		if(Z.HeldBeam)
			ringp = min(HeldBeamBenefit(Z), 1)
		else if(!Z.InfiniteHold)
			ringp = clamp((world.time - held_charge_start) / max(Z.ChargePeriod * 10, 1), 0, 1)
		KenShockwave(src, icon=Z.ChargeWaveIcon, Size=0.3 + 0.35 * ringp, Blend=Z.ChargeWaveBlend, Time=8)

		sleep(2)

// ReleaseHeldSkill is called by the Release_Held_Skill verb (KEY+UP macro)

/mob/proc/HeldBeamBenefit(obj/Skills/Z)
	if(!Z || !held_charge_start) return 0
	return (world.time - held_charge_start) / max(Z.ChargePeriod * 10, 1) * max(GetBeamChargeSpeedMult(), 0.1)

/mob/proc/ReleaseHeldSkill()
	var/obj/Skills/Z = held_skill
	if(!Z) return

	if(Z.HeldBeam)
		var/raw = HeldBeamBenefit(Z)
		if(!Z.HeldBeamUncapped)
			raw = min(raw, 1)
		Z.ChargeBenefit = raw
		ClearHeldChargeState()
		held_skill_last_release = world.time
		Z.OnHeldRelease(src, raw, FALSE)
		return

	if(Z.InfiniteHold)
		Z.ChargeBenefit = 1
		ClearHeldChargeState()
		held_skill_last_release = world.time
		Z.OnHeldRelease(src, 1, FALSE)
		return

	var/hold_ticks = world.time - held_charge_start
	UpdateHeldChargeBar(clamp(hold_ticks / (Z.ChargePeriod * 10), 0, 1))

	// Overheld
	if(hold_ticks > Z.ChargePeriod * 10)
		if(Z.NoFizzle)
			hold_ticks = Z.ChargePeriod * 10
		else
			FizzleHeldSkill(Z)
			return

	var/benefit = clamp(hold_ticks / (Z.ChargePeriod * 10), 0.0, 1.0)
	var/sweet_spot_hit = FALSE

	// Sweet spot window is SweetSpot to SweetSpot + SweetSpotWindow seconds.
	// Window width clamps to at least 1 tick so a near-zero SweetSpotWindow
	// still has a hittable frame.
	if(Z.SweetSpot)
		var/window_ticks = max(1, round(Z.SweetSpotWindow * 10))
		if(hold_ticks >= Z.SweetSpot * 10 && hold_ticks <= Z.SweetSpot * 10 + window_ticks)
			benefit = Z.SweetSpotBenefit
			sweet_spot_hit = TRUE

	Z.ChargeBenefit = benefit
	ClearHeldChargeState()
	held_skill_last_release = world.time
	if(sweet_spot_hit)
		FlashSweetSpot(src)
		for(var/mob/m in admins)
			if(m && m.client && m.Admin && m.client.SweetSpotHeldSkillDebug)
				m << "<font color='#66ff99'>(SweetSpot Debug) [src] hit [Z.name]'s sweet spot at [round(hold_ticks / 10, 0.1)]s.</font>"

	Z.OnHeldRelease(src, benefit, sweet_spot_hit)

// FizzleHeldSkill for skill being overheld, interrupted, or cancelled

/mob/proc/FizzleHeldSkill(var/obj/Skills/Z)
	if(held_skill != Z) return
	ClearHeldChargeState()
	held_skill_last_release = world.time
	Z.OnHeldFizzle(src)
	Z.Cooldown(1, null, src)
	src << "<font color='red'>Your technique fizzled!</font>"

// Cleanup

/mob/proc/ClearHeldChargeState()
	held_skill        = null
	held_charge_start = 0
	held_skill_macro_key = null
	if(held_charge_overlay_ref)
		overlays -= held_charge_overlay_ref
		held_charge_overlay_ref = null
	spawn() HideHeldChargeBar()

// HeldSkillBlocksAction returns TRUE if a held skill is currently
// charging and the requested skill would conflict.

/mob/proc/HeldSkillBlocksAction(obj/Skills/Z)
	if(held_skill && held_skill != Z)
		src << "<font color='red'>You can't do that while charging [held_skill.name].</font>"
		return TRUE
	if(judgement_cut_chain_active && !(istype(Z, /obj/Skills/AutoHit/Judgement_Cut) || istype(Z, /obj/Skills/AutoHit/Jarona)))
		return TRUE
	return FALSE

/mob/verb/Release_Held_Skill()
	set name = "Release Held Skill"
	set hidden = 1
	set instant = 1
	if(usr.held_skill)
		usr.ReleaseHeldSkill()

/mob/Admin2/verb/Toggle_SweetSpot_Held_Skill_Debug()
	set category = "Admin"
	set name = "Toggle SweetSpot Held Skill Debug"
	if(!client) return
	client.SweetSpotHeldSkillDebug = !client.SweetSpotHeldSkillDebug
	src << "<font color='#888888'>SweetSpot held skill debug: [client.SweetSpotHeldSkillDebug ? "ON" : "OFF"]</font>"

// Exampleskill

/obj/Skills/AutoHit/Charged_Lightning_Kicks
	Area = "Arc"
	StrScaling = 1
	DamageMult = 2.75
	Rush = 5
	ControlledRush = 1
	Rounds = 3
	ComboMaster = 1
	RoundMovement = 0
	NoAttackLock = 1
	NoLock = 1
	Cooldown = 60
	Distance = 2
	EnergyCost = 5
	Launcher = 2
	Instinct = 1
	Icon = 'Nest Slash.dmi'
	IconX = -16
	IconY = -16
	Size = 2
	TurfStrike = 1
	TurfShift = 'Dirt1.dmi'
	TurfShiftDuration = 3
	ActiveMessage = "channels lightning through their legs and delivers a torrent of kicks!"

	// Held skill config
	HeldSkill = TRUE
	ChargePeriod = 3
	SweetSpot = 1.5
	SweetSpotBenefit = 3.0
	ChargeOverlay = 'DarkShock.dmi'
	ChargeWaveIcon = 'Icons/Effects/KenShockwave.dmi'
	ChargeWaveBlend = 2

	adjust(mob/p)

	OnHeldRelease(mob/p, var/benefit)
		DamageMult = 2.75 + (2.0 * benefit)  // placeholder scaling

		// Add a fourth round at 70%+ charge
		if(benefit >= 0.7)  // placeholder threshold
			Rounds = 4
		else
			Rounds = 3

		p.Activate(src, noGCD = TRUE)

	verb/Charged_Lightning_Kicks()
		set category = "Skills"
		usr.BeginHeldSkill(src)
