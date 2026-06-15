// Tier 4+ Racial Passive Bonuses
// Applied when a demon is summoned, removed when unsummoned/despawned/logout

/mob/var/demon_racial_passive_race = ""
/mob/var/demon_racial_fallen_active = FALSE
/mob/var/demon_racial_femme_active = FALSE
/mob/var/demon_racial_snake_active = FALSE
/mob/var/demon_racial_touki_speed = 0
/mob/var/demon_racial_tyrant_active = FALSE
/mob/var/image/demon_tyrant_underlay = null
/mob/var/demon_racial_vile_active = FALSE
/mob/var/demon_racial_jaki_def_penalty = 0
/mob/var/demon_fallen_loop_gen = 0
/mob/var/demon_tyrant_loop_gen = 0

/mob/proc/ApplyDemonRacialPassive(race)
	if(demon_racial_passive_race != "")
		RemoveDemonRacialPassive()
	demon_racial_passive_race = race

	switch(race)
		if("Avatar")
			passive_handler.Increase("DebuffResistance", 1)
		if("Avian")
			SpdMultTotal *= 1.15
		if("Beast")
			StrMultTotal *= 1.15
		if("Deity")
			PowerBoost *= 1.15
		if("Divine")
			passive_handler.Increase("LifeGeneration", 2)
		if("Dragon")
			EndMultTotal *= 1.10
			DefMultTotal *= 1.10
		if("Element")
			passive_handler.Increase("DebuffDurationReduction", 0.30)
		if("Fairy")
			passive_handler.Increase("EnergyGeneration", 2)
		if("Fallen")
			demon_racial_fallen_active = TRUE
			spawn() DemonFallenPassiveLoop()
		if("Femme")
			demon_racial_femme_active = TRUE
		if("Fiend")
			passive_handler.Increase("LifeSteal", 20)
		if("True Fiend") // Placeholder, idk what to do for this yet
			passive_handler.Increase("LifeSteal", 20)
		if("Genma")
			passive_handler.Increase("ManaCapMult", 0.25)
			passive_handler.Increase("ManaStats", 4)
		if("Ghost")
			passive_handler.Increase("FluidForm", 1)
			passive_handler.Increase("Flow", 3)
		if("Hero")
			StrMultTotal *= 1.08
			EndMultTotal *= 1.08
			ForMultTotal *= 1.08
			SpdMultTotal *= 1.08
			OffMultTotal *= 1.08
			DefMultTotal *= 1.08
		if("Jaki")
			StrMultTotal *= 1.20
			DefMultTotal *= 0.95
		if("Kishin")
			passive_handler.Increase("TechniqueMastery", 1)
		if("Megami")
			passive_handler.Increase("ManaGeneration", 5)
		if("Mitama")
			Anger += 0.2
		if("Omega")
			passive_handler.Increase("PureReduction", 2)
		if("Snake")
			demon_racial_snake_active = TRUE
		if("Touki")
			var/speed_bonus = 2
			passive_handler.Increase("AttackSpeed", speed_bonus)
			demon_racial_touki_speed = speed_bonus
		if("Tyrant")
			demon_racial_tyrant_active = TRUE
			var/image/I = image('Icons/DevilSummoner/portrait_placeholder.dmi', src, "")
			I.pixel_x = -16
			I.pixel_y = -16
			I.layer = EFFECTS_LAYER - 1
			demon_tyrant_underlay = I
			underlays += I
			spawn() DemonTyrantAuraLoop()
		if("Vile")
			demon_racial_vile_active = TRUE
		if("Wilder")
			passive_handler.Increase("Brutalize", 3)

/mob/proc/RemoveDemonRacialPassive()
	var/race = demon_racial_passive_race
	if(race == "") return
	demon_racial_passive_race = ""

	switch(race)
		if("Avatar")
			passive_handler.Decrease("DebuffResistance", 1)
		if("Avian")
			SpdMultTotal /= 1.15
		if("Beast")
			StrMultTotal /= 1.15
		if("Deity")
			PowerBoost /= 1.15
		if("Divine")
			passive_handler.Decrease("LifeGeneration", 2)
		if("Dragon")
			EndMultTotal /= 1.10
			DefMultTotal /= 1.10
		if("Element")
			passive_handler.Decrease("DebuffDurationReduction", 0.30)
		if("Fairy")
			passive_handler.Decrease("EnergyGeneration", 2)
		if("Fallen")
			demon_racial_fallen_active = FALSE
		if("Femme")
			demon_racial_femme_active = FALSE
		if("Fiend")
			passive_handler.Decrease("LifeSteal", 20)
		if("True Fiend") // Placeholder, see above
			passive_handler.Decrease("LifeSteal", 20)
		if("Genma")
			passive_handler.Decrease("ManaCapMult", 0.25)
			passive_handler.Decrease("ManaStats", 4)
		if("Ghost")
			passive_handler.Decrease("FluidForm", 1)
			passive_handler.Decrease("Flow", 3)
		if("Hero")
			StrMultTotal /= 1.08
			EndMultTotal /= 1.08
			ForMultTotal /= 1.08
			SpdMultTotal /= 1.08
			OffMultTotal /= 1.08
			DefMultTotal /= 1.08
		if("Jaki")
			StrMultTotal /= 1.20
			DefMultTotal /= 0.95
		if("Kishin")
			passive_handler.Decrease("TechniqueMastery", 1)
		if("Megami")
			passive_handler.Decrease("ManaGeneration", 5)
		if("Mitama")
			Anger -= 0.2
		if("Omega")
			passive_handler.Decrease("PureReduction", 2)
		if("Snake")
			demon_racial_snake_active = FALSE
		if("Touki")
			passive_handler.Decrease("AttackSpeed", demon_racial_touki_speed)
			demon_racial_touki_speed = 0
		if("Tyrant")
			demon_racial_tyrant_active = FALSE
			if(demon_tyrant_underlay)
				underlays -= demon_tyrant_underlay
				demon_tyrant_underlay = null
		if("Vile")
			demon_racial_vile_active = FALSE
		if("Wilder")
			passive_handler.Decrease("Brutalize", 3)


/mob/var/demon_fallen_last_boost = 0

/mob/proc/DemonFallenPassiveLoop()
	set waitfor = FALSE
	var/my_gen = ++demon_fallen_loop_gen
	demon_fallen_last_boost = 0
	while(src && client && demon_racial_fallen_active && my_gen == demon_fallen_loop_gen)
		var/hp_ratio = clamp(Health / max(1, 100 - (100 * HealthCut) - TotalInjury), 0, 1)
		var/bonus = (1 - hp_ratio) * 0.5
		if(abs(bonus - demon_fallen_last_boost) > 0.01)
			PowerBoost /= max(0.01, 1 + demon_fallen_last_boost)
			PowerBoost *= (1 + bonus)
			demon_fallen_last_boost = bonus
		sleep(10)
	// Only cleanup if we are still the active loop
	if(my_gen == demon_fallen_loop_gen && demon_fallen_last_boost > 0)
		PowerBoost /= max(0.01, 1 + demon_fallen_last_boost)
		demon_fallen_last_boost = 0

/mob/proc/DemonFemmeCharmCheck(mob/defender)
	if(!demon_racial_femme_active) return
	if(!defender || !defender.client) return
	if(prob(8))
		defender.applyCharmed(src, 5)


/mob/proc/DemonSnakePoisonCheck(mob/defender)
	if(!demon_racial_snake_active) return
	if(!defender) return
	defender.AddPoison(3, src)

/mob/proc/GetDemonVileMult()
	if(demon_racial_vile_active)
		return 1.25
	return 1

/mob/var/list/demon_tyrant_debuffed = null

/mob/proc/DemonTyrantAuraLoop()
	set waitfor = FALSE
	var/my_gen = ++demon_tyrant_loop_gen
	if(!demon_tyrant_debuffed) demon_tyrant_debuffed = list()
	while(src && client && demon_racial_tyrant_active && my_gen == demon_tyrant_loop_gen)
		var/list/in_range = list()

		for(var/mob/M in oview(3, src))
			if(!M.client) continue
			if(party && party.members && (M in party.members)) continue
			if(istype(M, /mob/Player/AI/Demon))
				var/mob/Player/AI/Demon/d = M
				if(d.demon_owner_key == ckey) continue
			in_range += M

		for(var/mob/M in in_range)
			if(!(M in demon_tyrant_debuffed))
				M.StrMultTotal *= 0.9
				M.EndMultTotal *= 0.9
				M.ForMultTotal *= 0.9
				M.SpdMultTotal *= 0.9
				M.OffMultTotal *= 0.9
				M.DefMultTotal *= 0.9
				demon_tyrant_debuffed += M

		var/list/to_remove = list()
		for(var/mob/M in demon_tyrant_debuffed)
			if(!(M in in_range))
				to_remove += M
		for(var/mob/M in to_remove)
			M.StrMultTotal /= 0.9
			M.EndMultTotal /= 0.9
			M.ForMultTotal /= 0.9
			M.SpdMultTotal /= 0.9
			M.OffMultTotal /= 0.9
			M.DefMultTotal /= 0.9
			demon_tyrant_debuffed -= M

		sleep(5)

	// Only cleanup if we are still the active loop
	if(my_gen == demon_tyrant_loop_gen && demon_tyrant_debuffed)
		for(var/mob/M in demon_tyrant_debuffed)
			M.StrMultTotal /= 0.9
			M.EndMultTotal /= 0.9
			M.ForMultTotal /= 0.9
			M.SpdMultTotal /= 0.9
			M.OffMultTotal /= 0.9
			M.DefMultTotal /= 0.9
		demon_tyrant_debuffed.Cut()
