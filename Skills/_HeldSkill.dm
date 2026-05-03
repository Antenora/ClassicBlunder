// AutoHits and Projectiles apply this by setting HeldSkill = TRUE
// The skill's verb should call usr.BeginHeldSkill(src) instead of
// usr.Activate(src). Override OnHeldRelease(mob/p, benefit) to
// execute the skill.

// ChargeBenefit on release is 0-1 from progress through ChargePeriod.
// Hitting the SweetSpot window sets benefit to SweetSpotBenefit instead

/obj/Skills
	var/HeldSkill        = FALSE  // Enable held-charge behavior for this skill
	var/ChargePeriod     = 3      // Max hold time in seconds, hold too long = fizzle
	var/SweetSpot        = 0      // Seconds from charge start when sweet spot opens (0 = disabled)
	var/SweetSpotBenefit = 1.5    // ChargeBenefit value when the sweet spot window is hit
	var/ChargeOverlay    = null   // Icon displayed on mob while charging
	var/ChargeWaveIcon   = 'Icons/Effects/KenShockwave.dmi'  // Icon for periodic charge shockwave
	var/ChargeWaveBlend  = 1      // Blend mode for the periodic charge shockwave
	var/ChargeBenefit    = 0      // Set on release
	var/HeldVerbName     = null   // Optional override for macro detection;
	                              // defaults to Z.name if null

/obj/Skills/proc/OnHeldRelease(mob/p, var/benefit, var/sweet_spot_hit = FALSE)
	// Override in individual skills to execute the charged attack.

/client/var/tmp/SweetSpotHeldSkillDebug = FALSE
/client/var/tmp/list/held_skill_key_cache = null
/client/var/tmp/held_skill_cache_build_start = 0
/client/var/tmp/held_skill_macro_set = "macro"

/client/New(topicdata)
	..()
	// Kick off the initial macro scan shortly after connect so it's ready before
	// the player reaches gameplay. Runs every 5 minutes in the background after that.
	spawn(5) RebuildHeldSkillKeyCache()

// Charge state

/mob
	var/tmp/obj/Skills/held_skill         = null
	var/tmp/held_charge_start             = 0
	var/tmp/image/held_charge_overlay_ref = null
	var/tmp/image/held_charge_bar_bg_ref  = null
	var/tmp/image/held_charge_bar_sweet_ref = null
	var/tmp/list/held_charge_bar_fill_refs = null
	var/tmp/held_skill_macro_key          = null
	var/tmp/held_skill_last_release       = 0


/proc/_normalizeHeldName(s)
	if(!s) return ""
	s = replacetext(s, "_", " ")
	s = replacetext(s, "-", " ")
	return lowertext(s)

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

// BeginHeldSkill is called by the skill's verb instead of Activate

/mob/proc/BeginHeldSkill(var/obj/Skills/Z)
	if(held_skill) return  // Already charging something
	if(!Z || !Z.HeldSkill) return
	var/client/C = client
	if(!C) return

	// All guards run before touching any charge state.

	if(!C.held_skill_key_cache)
		var/elapsed_s = C.held_skill_cache_build_start > 0 ? round((world.time - C.held_skill_cache_build_start) / 10) : 0
		var/remaining_s = max(0, 10 - elapsed_s) + 30
		src << "<font color='red'>Macro bindings are still loading. Try again in [remaining_s] seconds.</font>"
		return

	// Key binding check also gates verb-list clicks on unbound skills (maybe?)
	var/key = findHeldSkillKey(C, Z)
	if(!key)
		src << "<font color='red'>Bind [Z.name] to a key first.</font>"
		return

	// re-entry guard
	if(held_skill_last_release && world.time - held_skill_last_release < 5)
		return

	// Cooldown / in-use check
	if(Z.Using || Z.cooldown_remaining)
		src << "<font color='red'>[Z.name] is on cooldown.</font>"
		return

	if(Z.NeedsSword)
		var/obj/Items/Sword/s = EquippedSword()
		if(!s && !HasBladeFisting() && !UsingBattleMage())
			src << "<font color='red'>You need a sword equipped to use [Z.name]!</font>"
			return

	// reinstalls the +UP macro for this exact key right now.
	winset(C, "heldskill_up_[key]", "parent=[C.held_skill_macro_set];name=[key]+UP;command=Release-Held-Skill")

	held_skill        = Z
	held_charge_start = world.time
	Z.ChargeBenefit   = 0

	if(Z.ChargeOverlay && !held_charge_overlay_ref)
		var/image/I = image(Z.ChargeOverlay)
		I.layer = MOB_LAYER + 0.1
		held_charge_overlay_ref = I
		overlays += I
	ShowHeldChargeBar(Z)
	KenShockwave(src, icon=Z.ChargeWaveIcon, Size=0.5, Blend=Z.ChargeWaveBlend, Time=8)

	held_skill_macro_key = key

	spawn() ChargeLoop(Z)


/mob/proc/findHeldSkillKey(client/C, obj/Skills/Z)
	var/raw_search = Z.HeldVerbName ? Z.HeldVerbName : Z.name
	if(!raw_search) return null
	var/search = _normalizeHeldName(raw_search)

	if(!C.held_skill_key_cache) return null

	var/list/cache = C.held_skill_key_cache
	for(var/cmd_key in cache)
		if(findtext(cmd_key, search))
			return cache[cmd_key]

	return null

// Builds (or rebuilds) the client's macro key cache and schedules a refresh
// every 5 minutes so macro changes mid-session are picked up automatically.
// On first login this fires once from client/New(), after which it reschedules
// itself. The old cache remains valid during background refreshes.
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

			var/cmd = winget(src, child_id, "command")
			if(!cmd) continue

			var/norm_cmd = _normalizeHeldName(cmd)
			for(var/held_name in held_names)
				if(findtext(norm_cmd, held_name))
					new_cache[norm_cmd] = key_name
					break
	else
		// Fallback, probe candidate keys by name (children unavailable)
		for(var/k in _heldSkillCandidateKeys())
			var/cmd = winget(src, k, "command")
			if(!cmd) continue
			var/norm_cmd = _normalizeHeldName(cmd)
			for(var/held_name in held_names)
				if(findtext(norm_cmd, held_name))
					new_cache[norm_cmd] = k
					break

	// Because new_cache is filtered to held skills only, this loop never touches
	// movement keys, hotbar slots, or any other binding.
	for(var/cmd_key in new_cache)
		var/bound_key = new_cache[cmd_key]
		winset(src, "heldskill_up_[bound_key]", "parent=[set_name];name=[bound_key]+UP;command=Release-Held-Skill")

	// both vars become visible together, after all +UP macros are set.
	held_skill_macro_set = set_name
	held_skill_key_cache = new_cache

	spawn(3000) RebuildHeldSkillKeyCache()


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
		fill.pixel_x = start_x + fill_left_inset_x + (i * fill_step)
		fill.pixel_y = start_y
		fill.alpha = 0
		held_charge_bar_fill_refs.Add(fill)
		C.images += fill

	if(Z && Z.SweetSpot > 0 && Z.ChargePeriod > 0)
		var/sweet_ratio = clamp(Z.SweetSpot / Z.ChargePeriod, 0, 1)
		var/sweet_x = start_x + fill_left_inset_x + round((segment_count - 1) * sweet_ratio)
		var/image/sweet = image(icon_file, src, "SweetSpot")
		sweet.layer = bg.layer + 0.2
		sweet.pixel_x = sweet_x
		sweet.pixel_y = start_y
		sweet.alpha = 0
		held_charge_bar_sweet_ref = sweet
		C.images += sweet

	animate(bg, alpha = 255, time = 2)
	if(held_charge_bar_sweet_ref)
		animate(held_charge_bar_sweet_ref, alpha = 255, time = 2)

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
	var/image/sweet = held_charge_bar_sweet_ref
	var/list/fills = held_charge_bar_fill_refs
	held_charge_bar_bg_ref = null
	held_charge_bar_sweet_ref = null
	held_charge_bar_fill_refs = null

	if(bg) animate(bg, alpha = 0, time = 3)
	if(sweet) animate(sweet, alpha = 0, time = 3)
	if(fills)
		for(var/image/fill in fills)
			if(fill) animate(fill, alpha = 0, time = 3)
	sleep(3)
	if(bg) C.images -= bg
	if(sweet) C.images -= sweet
	if(fills)
		for(var/image/fill in fills)
			if(fill) C.images -= fill

/mob/proc/ForceClearHeldChargeState()
	held_skill = null
	held_charge_start = 0
	held_skill_macro_key = null

	if(held_charge_overlay_ref)
		overlays -= held_charge_overlay_ref
		held_charge_overlay_ref = null

	var/client/C = client
	if(C)
		if(held_charge_bar_bg_ref)
			C.images -= held_charge_bar_bg_ref
		if(held_charge_bar_sweet_ref)
			C.images -= held_charge_bar_sweet_ref
		if(held_charge_bar_fill_refs)
			for(var/image/fill in held_charge_bar_fill_refs)
				if(fill) C.images -= fill

	held_charge_bar_bg_ref = null
	held_charge_bar_sweet_ref = null
	held_charge_bar_fill_refs = null

// ChargeLoop runs for the duration of the hold

/mob/proc/ChargeLoop(var/obj/Skills/Z)
	while(held_skill == Z)
		// Interrupt conditions
		var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Charmed/charm_skill = locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Charmed) in src
		if(Stunned || Launched || Stasis > 0 || (charm_skill && BuffOn(charm_skill)))
			FizzleHeldSkill(Z)
			return

		// Overheld fizzle
		if(world.time - held_charge_start > Z.ChargePeriod * 10)
			FizzleHeldSkill(Z)
			return

		// closing the visual gap after BeginHeldSkill's initial pulse.
		KenShockwave(src, icon=Z.ChargeWaveIcon, Size=0.5, Blend=Z.ChargeWaveBlend, Time=8)
		var/hold_ticks = world.time - held_charge_start
		var/progress = clamp(hold_ticks / (Z.ChargePeriod * 10), 0, 1)
		UpdateHeldChargeBar(progress)

		sleep(2)

// ReleaseHeldSkill is called by the Release_Held_Skill verb (KEY+UP macro)

/mob/proc/ReleaseHeldSkill()
	var/obj/Skills/Z = held_skill
	if(!Z) return

	var/hold_ticks = world.time - held_charge_start
	UpdateHeldChargeBar(clamp(hold_ticks / (Z.ChargePeriod * 10), 0, 1))

	// Overheld
	if(hold_ticks > Z.ChargePeriod * 10)
		FizzleHeldSkill(Z)
		return

	var/benefit = clamp(hold_ticks / (Z.ChargePeriod * 10), 0.0, 1.0)
	var/sweet_spot_hit = FALSE

	// Sweet spot window is SweetSpot to SweetSpot + 0.3s
	if(Z.SweetSpot && hold_ticks >= Z.SweetSpot * 10 && hold_ticks <= Z.SweetSpot * 10 + 3)
		benefit = Z.SweetSpotBenefit
		sweet_spot_hit = TRUE

	Z.ChargeBenefit = benefit
	ClearHeldChargeState()
	held_skill_last_release = world.time
	if(sweet_spot_hit)
		for(var/mob/m in admins)
			if(m && m.client && m.Admin && m.client.SweetSpotHeldSkillDebug)
				m << "<font color='#66ff99'>(SweetSpot Debug) [src] hit [Z.name]'s sweet spot at [round(hold_ticks / 10, 0.1)]s.</font>"
	Z.OnHeldRelease(src, benefit, sweet_spot_hit)

// FizzleHeldSkill for skill being overheld, interrupted, or cancelled

/mob/proc/FizzleHeldSkill(var/obj/Skills/Z)
	if(held_skill != Z) return
	ClearHeldChargeState()
	held_skill_last_release = world.time
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
	StrOffense = 1
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

		p.Activate(src)

	verb/Charged_Lightning_Kicks()
		set category = "Skills"
		usr.BeginHeldSkill(src)
