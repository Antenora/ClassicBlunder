/mob/var/tmp/ApathyDamageBonus = 0

mob
	proc
		isInHighTension()
			if(!passive_handler || !passive_handler.Get("DeathDefied")) return FALSE
			if(!istype(race, HUMAN)) return FALSE
			if(transActive < 1) return FALSE
			return TRUE

		getMazokuSinBonusMult()
			if(!isInHighTension())
				if(ApathyDamageBonus != 0)
					ApathyDamageBonus = 0
				return 0

			var/mult = 0

			// ApathyFactor
			if(ApathyDamageBonus > 0)
				mult += ApathyDamageBonus

			// HopeFactor
			if(passive_handler && passive_handler.Get("HopeFactor") && Health < 50)
				var/hope_bonus = ((50 - Health) / 40.0) * 3 * passive_handler.Get("HopeFactor")
				mult += hope_bonus

			if(mult < 0)
				mult = 0
			if(mult>1.5)
				mult = 1.5
			// HopeFactor is now capped here.

			return mult

		applyApathyBonus(amount)
			if(amount <= 0) return
			if(!isInHighTension()) return
			if(!passive_handler || !passive_handler.Get("ApathyFactor")) return
			ApathyDamageBonus = min(1.5, ApathyDamageBonus + amount * 0.01)

		resetApathyBonus()
			ApathyDamageBonus = 0

// Mazoku transformation subtypes

/transformation/demon/devil_trigger/mazoku
	revertToTrans = 0
	form_aura_icon = 'Amazing Super Demon Aura.dmi'
	form_aura_x = -32
	autoAnger = 1
	strength = 1
	force = 1
	speed = 1
	offense = 1
	defense = 1
	endurance = 1
	transformation_message = "usrName becomes a Devil!"
	mastery_boons(mob/user)
		passives = list("GodKi" = 0.25+((user.AscensionsAcquired-3)/10), "HellRisen" = user.AscensionsAcquired/10, "DemonicDurability" = user.AscensionsAcquired/4, "Brutalize" = user.AscensionsAcquired/6, "PureDamage" = user.AscensionsAcquired, "PureReduction" = user.AscensionsAcquired, "MovementMastery" = user.AscensionsAcquired, "BuffMastery"=user.AscensionsAcquired/2)
		strength = 1 // to clear out people who already have it
		force = 1
		speed = 1
		offense = 1
		defense = 1
		endurance = 1
		enduranceadd = 0.5
		offenseadd = 0.5
		defenseadd = 0.5
		strengthadd = 0.5
		forceadd = 0.5
	transform_animation(mob/user)
		var/ShockSize = 5
		for(var/wav = 5, wav > 0, wav--)
			KenShockwave(user, icon='KenShockwaveBloodlust.dmi', Size=ShockSize, Blend=2, Time=8)
			ShockSize /= 2

/transformation/human/high_tension/mazoku
	pot_trans = 2
	passives = list(\
		"Conductor" = 10,\
		"HighTension" = 1,\
		"PureReduction" = 2,\
		"PureDamage" = 2,\
		"TensionPowered" = 0.25,\
		"TechniqueMastery" = 1,\
		"BuffMastery" = 2,\
		"Underdog" = 0.3,\
		"Tenacity" = 2\
	)
	transformation_message = "usrName reignites their humanity!"
	adjust_transformation_visuals(mob/user)
		if(!form_hair_icon&&user.Hair_Base)
			var/icon/x=new(user.Hair_Base)
			form_hair_icon = x
			form_icon_2_icon = x
		..()
	transform_animation(mob/user)
		var/ShockSize=5
		for(var/wav=5, wav>0, wav--)
			KenShockwave(user, icon='KenShockwavePurple.dmi', Size=ShockSize, Blend=2, Time=8)
			ShockSize/=2

/transformation/human/high_tension_MAX/mazoku
	pot_trans = 3
	form_aura_icon = 'AurasBig.dmi'
	form_aura_icon_state = "HT2"
	form_aura_x = -32
	passives = list(\
		"Conductor" = 10,\
		"HighTension" = -0.125,\
		"TensionPowered" = 0.375,\
		"TechniqueMastery" = 1,\
		"StyleMastery" = 2,\
		"Underdog" = 0.3,\
		"Tenacity" = 2\
	)
	transformation_message = "usrName hits their original ceiling!"
	adjust_transformation_visuals(mob/user)
		if(!form_hair_icon&&user.Hair_Base)
			var/icon/x=new(user.Hair_Base)
			if(x)
				x.Blend(rgb(150,-10,150),ICON_ADD)
			form_hair_icon = x
			form_icon_2_icon = x
		..()
	transform_animation(mob/user)
		var/ShockSize=5
		for(var/wav=5, wav>0, wav--)
			KenShockwave(user, icon='KenShockwavePurple.dmi', Size=ShockSize, Blend=2, Time=8)
			ShockSize/=2

/transformation/human/super_high_tension/mazoku
	pot_trans = 3
	form_aura_icon = 'SpiralAura.dmi'
	form_aura_x = -32
	passives = list(\
		"Conductor" = 10,\
		"HighTension" = -0.125,\
		"PureReduction" = 3,\
		"PureDamage" = 3,\
		"TensionPowered" = 0.25,\
		"TechniqueMastery" = 3,\
		"StyleMastery" = 2,\
		"BuffMastery" = 2,\
		"Underdog" = 0.4,\
		"Tenacity" = 3,\
		"SuperHighTension" = 1\
	)
	transformation_message = "usrName pushes forward into the future!"
	adjust_transformation_visuals(mob/user)
		if(!form_hair_icon&&user.Hair_Base)
			var/icon/x=new(user.Hair_Base)
			if(x)
				x.Blend(rgb(-10,150,50),ICON_ADD)
			form_hair_icon = x
			form_icon_2_icon = x
		..()
	transform_animation(mob/user)
		var/ShockSize=5
		for(var/wav=5, wav>0, wav--)
			KenShockwave(user, icon='KenShockwaveLegend.dmi', Size=ShockSize, Blend=2, Time=8)
			ShockSize/=2

/transformation/human/super_high_tension_MAX/mazoku
	pot_trans = 5
	passives = list(\
		"Conductor" = 10,\
		"DoubleHelix" = 1,\
		"TensionPowered" = 0.375,\
		"TechniqueMastery" = 5,\
		"StyleMastery" = 2,\
		"BuffMastery" = 2,\
		"Underdog" = 1,\
		"Tenacity" = 10,\
		"SuperHighTension" = 1\
	)
	transformation_message = "usrName maximizes the very limits of their potential, evolving beyond the person they were a minute before!"
	adjust_transformation_visuals(mob/user)
		if(!form_hair_icon&&user.Hair_Base)
			var/icon/x=new(user.Hair_Base)
			if(x)
				x.Blend(rgb(-10,150,50),ICON_ADD)
			form_hair_icon = x
			form_icon_2_icon = x
		..()
	transform_animation(mob/user)
		var/ShockSize = 5
		LightningStrike2(user, Offset=0)
		spawn(10)
		for(var/wav=5, wav>0, wav--)
			KenShockwave(user, icon='KenShockwaveLegend.dmi', Size=ShockSize, Blend=2, Time=8)
			ShockSize/=2

/transformation/human/unlimited_high_tension/mazoku
	pot_trans = 15
	passives = list(\
		"Conductor" = 10,\
		"UnlimitedHighTension" = 1,\
		"CreateTheHeavens" = 1\
	)
	transformation_message = "usrName shatters through heaven and earth, becoming equal to the Gods!!"
	adjust_transformation_visuals(mob/user)
		if(!form_hair_icon&&user.Hair_Base)
			var/icon/x=new(user.Hair_Base)
			form_hair_icon = x
			form_icon_2_icon = x
		..()
	transform_animation(mob/user)
		var/ShockSize = 5
		LightningStrike2(user, Offset=0)
		spawn(10)
		for(var/wav=5, wav>0, wav--)
			KenShockwave(user, icon='KenShockwaveDivine.dmi', Size=ShockSize, Blend=2, Time=8)
			ShockSize/=2

/transformation/human/sacred_energy_aura
	revertToTrans = 0
	form_aura_icon = 'AurasBig.dmi'
	form_aura_icon_state = "SSJ"
	form_aura_x = -32
	form_glow_icon = 'Ripple Radiance.dmi'
	form_glow_x = -32
	form_glow_y = -32
	autoAnger = 1
	pot_trans = 15
	enduranceadd = 2
	offenseadd = 2
	defenseadd = 2
	strengthadd = 2
	forceadd = 2
	passives = list(\
		"Conductor" = 50,\
		"HighTension" = 0.75,\
		"TensionPowered" = 1.25,\
		"TechniqueMastery" = 16,\
		"BuffMastery" = 14,\
		"PureReduction" = 11,\
		"PureDamage" = 11,\
		"UnderDog" = 2,\
		"Tenacity" = 17,\
		"StyleMastery" = 6,\
		"SuperHighTension" = 1,\
		"DoubleHelix" = 1,\
		"UnlimitedHighTension" = 1,\
		"CreateTheHeavens" = 1,\
		"GodKi" = 1,\
		"HellRisen" = 1,\
		"DemonicDurability" = 6,\
		"Brutalize" = 6,\
		"MovementMastery" = 6,\
	)
	transformation_message = "usrName awakens their Sacred Energy Aura!"
	transform_animation(mob/user)
		var/ShockSize = 5
		LightningStrike2(user, Offset=0)
		spawn(10)
		for(var/wav = 5, wav > 0, wav--)
			KenShockwave(user, icon='KenShockwaveDivine.dmi', Size=ShockSize, Blend=2, Time=8)
			ShockSize /= 2
		if(user.client)
			ScreenShatter(user)

mob/proc/isMazokuHuman()
	if(!isRace(HUMAN)) return FALSE
	if(!passive_handler) return FALSE
	if(!passive_handler.Get("DormantDemon")) return FALSE
	if(!passive_handler.Get("DeathDefied")) return FALSE
	return TRUE

mob/proc/isMazokuPathHuman()
	if(!isRace(HUMAN)) return FALSE
	if(!passive_handler) return FALSE
	if(!passive_handler.Get("DormantDemon")) return FALSE
	return TRUE

mob/proc/isInMazokuDT()
	if(!isMazokuHuman()) return FALSE
	if(!race || !race.transformations || transActive < 1) return FALSE
	if(transActive > race.transformations.len) return FALSE
	return istype(race.transformations[transActive], /transformation/demon/devil_trigger/mazoku)

mob/proc/isMazokuAscension6()
	if(!isMazokuHuman()) return FALSE
	return AscensionsAcquired >= 6

mob/proc/isInMazokuSEA()
	if(!isMazokuHuman()) return FALSE
	if(!race || !race.transformations || transActive < 1) return FALSE
	if(transActive > race.transformations.len) return FALSE
	return istype(race.transformations[transActive], /transformation/human/sacred_energy_aura)

// Reverts all active HT forms sequentially (slots 1–5) until transActive reaches 0.
mob/proc/mazokuRevertAllHT()
	var/safety = 10
	while(transActive > 0 && !isInMazokuDT() && !isInMazokuSEA() && safety-- > 0)
		var/old_ta = transActive
		race.transformations[transActive].revert(src)
		if(transActive == old_ta)
			transActive = 0
			break

// Sequentially activates HT forms from slot 1 up to the highest available (max slot 5).
mob/proc/mazokuActivateHighestHT()
	if(!race || !race.transformations) return
	var/target_slot = min(transUnlocked, 5)
	if(target_slot < 1) return
	for(var/i = 1; i <= target_slot; i++)
		race.transformations[i].transform(src, TRUE)

/mob/proc/MazokuEffects()
/*	transform_animation(mob/user)
		spawn(30)
			KenShockwave(src, icon='GojoShockwave.dmi', PixelY=24, Size=1, Blend=2)
		spawn(30)
			KenShockwave(src, icon='GojoShockwave.dmi', PixelY=24, Size=3, Blend=2)
		spawn(30)
			KenShockwave(src, icon='GojoShockwave.dmi', PixelY=24, Size=5, Blend=2)
		spawn(30)
			KenShockwave(src, icon='GojoShockwave.dmi', PixelY=24, Size=10, Blend=2)*/

/transformation/human/revert(mob/user)
	..()
	if(!user || user.transActive >= 1) return
	user.resetApathyBonus()

// Mazoku (HopeFactor) exclusive Queue technique
obj/Skills/Queue/Kibou_ou_Hope
	name = "Kibou ou Hope"
	DamageMult = 20
	Cooldown = 60
	EnergyCost = 5
	Duration = 10
	WaveHit = 1
	UnarmedOnly = 1
	Determinator = 1
	Delayer = 0.25
	ActiveMessage = "embraces a dream that exists beyond hope..."
	HitMessage = "goes beyond their limits and seizes the future in their hands!"
	verb/Kibou_ou_Hope()
		set category = "Skills"
		if(!usr.isInHighTension())
			usr << "You are not a Mazoku Human."
			return
		if(!usr.passive_handler || !usr.passive_handler.Get("HopeFactor"))
			usr << "You aren't hopeful enough to use this power."
			return
		if(usr.isInMazokuDT())
			usr << "You cannot use this in Mazoku DT."
			return
		if(usr.Health >= 40)
			usr << "You cannot use this until your health is low."
			return
		var/healthDiff = 0
		if(usr.Target && istype(usr.Target, /mob/Players) && usr.Target != usr)
			healthDiff = max(0, usr.Target:Health - usr.Health)
		src.DamageMult = 20 + (healthDiff * 2)
		usr.SetQueue(src)
