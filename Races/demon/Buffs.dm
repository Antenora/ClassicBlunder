/obj/Skills/Buffs/SlotlessBuffs/True_Form/Demon
	passives = list("HellPower" = 0.1, "AngerAdaptiveForce" = 0.25, "TechniqueMastery" = 2, "Juggernaut" = 0.5, "FakePeace" = -1)
	Cooldown = -1
	TimerLimit = 0
	BuffName = "True Form"
	name = "True Form - Demon"
	IconLock='GenesicR.dmi'
	IconLockBlend=BLEND_MULTIPLY
	LockX=-32
	LockY=-32
	HealthThreshold = 0.0001
	var/current_charges = 1
	var/last_charge_gain = 0
/*	var/list/trueFormPerAsc = list( 1 = alist("AngerAdaptiveForce" = 0.1, "TechniqueMastery" = 2, "Juggernaut" = 1, "Hellrisen" = 0.25, , "FakePeace" = -1), \
									2 = alist("AngerAdaptiveForce" = 0.2,"TechniqueMastery" = 3, "FluidForm" = 1, "GiantForm" = 1, "Juggernaut" = 1.5, "Hellrisen" = 0.5, , "FakePeace" = -1), \
									3 = alist("AngerAdaptiveForce" = 0.25,"TechniqueMastery" = 4, "FluidForm" = 1.5, "GiantForm" = 1, "Juggernaut" = 2,"Hellrisen" = 0.5, , "FakePeace" = -1), \
									4 = alist("AngerAdaptiveForce" = 0.5,"TechniqueMastery" = 6, "FluidForm" = 2, "GiantForm" = 1, "Juggernaut" = 2,"Hellrisen" = 0.5, , "FakePeace" = -1))*/
	ActiveMessage = "<i>has unleashed their true nature!</i>"
	// jsut set the niggas hellpower to 1
	adjust(mob/p)
		if(p.AscensionsAcquired==1)
			passives =list("AngerAdaptiveForce" = 0.1, "TechniqueMastery" = 2, "Juggernaut" = 1, "HellRisen" = 0.25, , "FakePeace" = -1)
		if(p.AscensionsAcquired==2)
			passives = list("AngerAdaptiveForce" = 0.2,"TechniqueMastery" = 3, "FluidForm" = 1, "Juggernaut" = 1.5, "HellRisen" = 0.5, , "FakePeace" = -1)
		if(p.AscensionsAcquired==3)
			passives = list("AngerAdaptiveForce" = 0.25,"TechniqueMastery" = 4, "FluidForm" = 1.5, "Juggernaut" = 2,"HellRisen" = 0.5, , "FakePeace" = -1)
		if(p.AscensionsAcquired==4)
			passives = list("AngerAdaptiveForce" = 0.5,"TechniqueMastery" = 6, "FluidForm" = 2, "Juggernaut" = 2,"HellRisen" = 0.5, , "FakePeace" = -1)
		var/hellpowerdif = 1 - p.passive_handler.Get("HellPower")
		if(hellpowerdif < 0)
			hellpowerdif = 0
		passives["HellPower"] = hellpowerdif
	verb/True_Form()
		set category = "Skills"
		adjust(usr)
		if(!usr.BuffOn(src))
			if(current_charges - 1 < 0)
				usr << "You have ran out of true form charges..."
				return
			adjust(usr)
			var/yesno = input(usr, "Are you sure?") in list("Yes", "No")
			if(yesno == "Yes")
				if(glob.racials.REVEALDEMONONTRUEFORM)
					OMsg(usr, "<b>[usr] has revealed their true nature as a <i>[glob.racials.DEMON_NAME]</i></b>")
				current_charges--
				usr << "You have [current_charges] charges of true form left."
				var/obj/Skills/Buffs/SlotlessBuffs/Racial/Demon/Disguise/D = locate() in usr
				if(D && usr.BuffOn(D))
					D.Trigger(usr, TRUE)
					usr << "<i>Your True Form shatters your disguise.</i>"
			else
				return 0
		src.Trigger(usr)

//Sloth AOE

/obj/Effects/SlothShockwave
	icon = 'KenShockwaveBloodlust.dmi'
	pixel_x = -105
	pixel_y = -105
	Grabbable = 0
	mouse_opacity = 0
	layer = EFFECTS_LAYER
	var/max_size = 4.0
	var/wave_lifetime = 30
	var/mob/Players/owner
	var/DamageMult = 30
	var/StrOffense = 1
	var/ForOffense = 1
	var/EndRes = 1
	var/list/hitList = list()

	New()
		animate(src)
		transform = matrix() * 0.1
		alpha = 255
		spawn(0)
			hitDetectLoop()

	proc/hitDetectLoop()
		set waitfor = FALSE
		var/start_time = world.time
		var/prev_radius_tiles = 0.0
		var/max_radius_tiles = (max_size * 121.0) / 32.0
		var/full_dmg_threshold_tiles = max_radius_tiles * 0.75
		var/list/outsideSet = list()
		while(src)
			var/tick_begin = world.time
			if(!owner || !owner.loc) break
			if(owner.PureRPMode)
				sleep(1)
				start_time += (world.time - tick_begin)
				continue

			var/elapsed = world.time - start_time
			if(elapsed >= wave_lifetime)
				EffectFinish()
				break

			var/t = elapsed / wave_lifetime
			var/scale = 0.1 + (max_size - 0.1) * t
			var/curr_radius_tiles = (scale * 121.0) / 32.0
			src.transform = matrix() * scale
			src.alpha = round(255 * (1 - t))

			for(var/mob/Players/P in players)
				if(!P.client) continue
				if(P == owner) continue
				if(P.z != owner.z) continue
				if(owner.inParty(P.ckey)) continue

				var/dx = P.x - owner.x
				var/dy = P.y - owner.y
				var/dist = sqrt(dx * dx + dy * dy)

				if(dist > curr_radius_tiles)
					// Player is outside the ring, track them as a valid hit target
					if(!(P in outsideSet))
						outsideSet += P
				else
					// Player is inside the ring
					if(P in outsideSet)
						// They were outside last tick / crossing the outer edge
						outsideSet -= P
						// Only register a hit if they crossed the edge band itself
						// (dist > prev_radius means they didn't teleport past it)
						// and they're not in melee range and not already hit
						if(max(abs(dx), abs(dy)) > 1 && !(P in hitList))
							if(dist > prev_radius_tiles)
								hitList += P
								dealWaveDamage(P, dist, full_dmg_threshold_tiles)

			prev_radius_tiles = curr_radius_tiles
			sleep(1)

	proc/dealWaveDamage(mob/Players/target, dist_tiles, full_dmg_threshold_tiles)
		if(!owner || !target) return
		if(owner.PureRPMode) return

		var/denom = full_dmg_threshold_tiles - 1
		if(denom <= 0) denom = 0.01
		var/falloff = clamp((dist_tiles - 1) / denom, 0, 1)

		var/powerDif = owner.Power / target.Power
		if(glob.CLAMP_POWER && !owner.ignoresPowerClamp())
			powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)

		var/atk = 0
		if(StrOffense && !ForOffense)
			atk = owner.GetStr(StrOffense)
		else if(ForOffense && !StrOffense)
			atk = owner.GetFor(ForOffense)
		else if(StrOffense && ForOffense)
			atk = owner.GetStr(StrOffense) + owner.GetFor(ForOffense)
		if(atk <= 0) atk = 0.01

		var/def = target.getEndStat(1) * EndRes
		if(def <= 0) def = 0.01

		var/FinalDmg = (clamp(powerDif, 0.1, 100000) ** glob.DMG_POWER_EXPONENT) * \
		               (glob.CONSTANT_DAMAGE_EXPONENT + glob.AUTOHIT_EFFECTIVNESS) ** \
		               -(def ** glob.DMG_END_EXPONENT / atk ** glob.DMG_STR_EXPONENT)
		FinalDmg *= DamageMult
		FinalDmg *= falloff
		FinalDmg *= owner.GetDamageMod()
		FinalDmg *= glob.AUTOHIT_GLOBAL_DAMAGE

		if(FinalDmg <= 0) return
		target.LoseHealth(FinalDmg)

		var/obj/Effects/HE = new(null, 'fevExplosion - Hellfire.dmi', -32, -32, 0, 1, 8)
		HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		HE.Target = target
		target.vis_contents += HE

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sloth_Factor
	name = "Sloth Factor"
	BuffName = "Sloth Factor"
	Cooldown = -1
	var/DamageMult = 30
	var/StrOffense = 1
	var/ForOffense = 1
	var/EndRes = 1
	var/tmp/waveLoopRunning = FALSE

	Trigger(mob/User, Override = FALSE)
		var/wasOn = SlotlessOn
		. = ..()
		if(!wasOn && SlotlessOn && !waveLoopRunning)
			startWaveLoop(User)

	proc/startWaveLoop(mob/User)
		set waitfor = FALSE
		waveLoopRunning = TRUE
		while(SlotlessOn && User)
			spawnWave(User)
			sleep(100)
		waveLoopRunning = FALSE

	proc/spawnWave(mob/User)
		if(!User || !User.loc) return
		if(User.PureRPMode) return
		if(!User.demonDevilTriggerSinMastery()) return
		var/obj/Effects/SlothShockwave/S = new(User.loc)
		S.owner = User
		S.DamageMult = DamageMult
		S.StrOffense = StrOffense
		S.ForOffense = ForOffense
		S.EndRes = EndRes
