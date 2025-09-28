/obj/Skills/Buffs/proc/GainLoop(mob/source)
	if(AffectTarget)
		if(source.Target && get_dist(source,source.Target) > Range)
			HandleBuffDeactivation(source)
			return
		if(!source.Target)
			HandleBuffDeactivation(source)
			return

	var/turnOff = 0
	turnOff += CheckThresholdAndTrigger(source, HealthDrain, "Health", HealthThreshold)
	if(turnOff && !AllOutAttack)
		return
	turnOff += CheckThresholdAndTrigger(source, WoundDrain, "Wound", WoundThreshold)
	if(turnOff && !AllOutAttack)
		return
	turnOff += CheckThresholdAndTrigger(source, EnergyDrain, "Energy", EnergyThreshold)
	if(turnOff && !AllOutAttack)
		return
	turnOff += CheckThresholdAndTrigger(source, FatigueDrain, "Fatigue", FatigueThreshold)
	if(turnOff && !AllOutAttack)
		return
	turnOff += CheckThresholdAndTrigger(source, CapacityDrain, "Capacity", CapacityThreshold)
	if(turnOff && !AllOutAttack)
		return
	turnOff += CheckThresholdAndTrigger(source, ManaDrain, "Mana", ManaThreshold)
	if(turnOff && !AllOutAttack)
		return

	if (VaizardShatter && source.VaizardHealth <= 0)
		HandleBuffDeactivation(source)
		return

	if (TimerLimit)
		Timer = max(Timer + world.tick_lag / 10, 0)
		if (Timer >= TimerLimit)
			HandleBuffDeactivation(source)
			return

	if (TooMuchHealth && source.Health >= TooMuchHealth)
		HandleBuffDeactivation(source)
		return

	if (WaveringAngerLimit)
		WaveringAnger = min(WaveringAnger + 0.1, WaveringAngerLimit)
		if (WaveringAnger >= WaveringAngerLimit)
			source.SetNoAnger(src, prob(33) ? 1 : 0)
			WaveringAnger = 0

	HandleHealing(source)

	ApplyBuffEffects(source)

	ApplyStatDrains(source)

	if(InstantAffect && !InstantAffected)
		InstantAffected = 1

/obj/Skills/Buffs/proc/CheckThresholdAndTrigger(mob/source, drain, drainType, threshold)
	var/currentValue
	var/mob/target = source
	var/flipsign = FALSE
	if(AffectTarget)
		target = source.Target
	if (drain)
		switch(drainType)
			if("Health")
				target.DoDamage(target, TrueDamage(HealthDrain))
			if ("Wound")
				target.DoDamage(target, TrueDamage(drain))
			if ("Energy")
				target.LoseEnergy(drain)
			if ("Fatigue")
				target.GainFatigue(drain)
			if ("Capacity")
				target.LoseCapacity(drain)
			if ("Mana")
				target.LoseMana(drain)
	switch(drainType)
		if("Health")
			currentValue = target.Health + target.TotalInjury
		if ("Wound")
			currentValue = target.TotalInjury
			flipsign = TRUE
		if ("Energy")
			currentValue = target.Energy * (1 - target.EnergyCut)
		if ("Fatigue")
			currentValue = target.TotalFatigue
			flipsign = TRUE
		if ("Capacity")
			currentValue = target.TotalCapacity
			flipsign = TRUE
		if ("Mana")
			currentValue = target.ManaAmount
	if(!flipsign)
		if (!AllOutAttack && threshold && currentValue < threshold)
			HandleBuffDeactivation(source)
			return 1
	else
		if (!AllOutAttack && threshold && currentValue >= threshold)
			HandleBuffDeactivation(source)
			return 1
	return 0

/obj/Skills/Buffs/proc/HandleBuffDeactivation(mob/source)
	Trigger(source, Override=1)

/obj/Skills/Buffs/proc/HandleHealing(mob/source)
	var/mob/target = source 
	if(AffectTarget && source.Target)
		target = source.Target
	if (WoundHeal)
		target.HealWounds(target.GetRecov(WoundHeal) / 10)
	if (FatigueHeal)
		target.HealFatigue((StableHeal ? FatigueHeal : target.GetRecov(FatigueHeal)) / 10, 1)
	if (CapacityHeal)
		target.HealCapacity(CapacityHeal / 10)
	if (HealthHeal)
		var/healTarget = (target.Health + target.TotalInjury >= 100 || (target.TotalInjury && target.icon_state == "Meditate"))
		if (healTarget)
			target.HealWounds(target.GetRecov(HealthHeal) / 10)
		else
			target.HealHealth(target.GetRecov(HealthHeal) / 10)
	if (EnergyHeal)
		var/energyTarget = (target.Energy + target.TotalFatigue >= 100 || (target.TotalFatigue && target.icon_state == "Meditate"))
		if (energyTarget)
			target.HealFatigue(target.GetRecov(EnergyHeal) / 10, 1)
		else
			target.HealEnergy(target.GetRecov(EnergyHeal) / 10, 1)
	if (ManaHeal)
		target.HealMana(ManaHeal / 10)

/obj/Skills/Buffs/proc/ApplyBuffEffects(mob/source)
	if((InstantAffect && InstantAffected))
		return
	var/mob/target = source
	if(AffectTarget && source.Target)
		target = source.Target
	if (BurnAffected)
		target.AddBurn(BurnAffected, source)
	if (SlowAffected)
		target.AddSlow(SlowAffected, source)
	if (ShockAffected)
		target.AddShock(ShockAffected, source)
	if (ShatterAffected)
		target.AddShatter(ShatterAffected, source)
	if (PoisonAffected)
		target.AddPoison(PoisonAffected, source)
	if (ShearAffected)
		target.AddShearing(ShearAffected, source)
	if(CrippleAffected)
		target.AddCrippling(CrippleAffected, source)
	if(StunAffected)
		Stun(target, StunAffected)

/obj/Skills/Buffs/proc/ApplyStatDrains(mob/source)
	if((InstantAffect && InstantAffected))
		return
	var/mob/target = source
	if(AffectTarget && source.Target)
		target = source.Target
	if (StrTaxDrain)
		target.AddStrTax(StrTaxDrain)
	if (StrCutDrain)
		target.AddStrCut(StrCutDrain)
	if (EndTaxDrain)
		target.AddEndTax(EndTaxDrain)
	if (EndCutDrain)
		target.AddEndCut(EndCutDrain)
	if (SpdTaxDrain)
		target.AddSpdTax(SpdTaxDrain)
	if (SpdCutDrain)
		target.AddSpdCut(SpdCutDrain)
	if (ForTaxDrain)
		target.AddForTax(ForTaxDrain)
	if (ForCutDrain)
		target.AddForCut(ForCutDrain)
	if (OffTaxDrain)
		target.AddOffTax(OffTaxDrain)
	if (OffCutDrain)
		target.AddOffCut(OffCutDrain)
	if (DefTaxDrain)
		target.AddDefTax(DefTaxDrain)
	if (DefCutDrain)
		target.AddDefCut(DefCutDrain)
	if (RecovTaxDrain)
		target.AddRecovTax(RecovTaxDrain)
	if (RecovCutDrain)
		target.AddRecovCut(RecovCutDrain)

turf/proc/GainLoop(mob/source)
	if(effectApplied)
		switch(effectApplied)
			if("Stellar")
				if(!source.passive_handler.Get("Constellation"))
				// start draining or somethin
					if(source.Energy > 1)
						source.Energy -= 0.015
					if(source.TotalFatigue < 99)
						source.TotalFatigue += 0.015
				else
					if(source.Energy < 99)
						source.Energy += 0.015
					if(source.TotalFatigue > 0)
						source.TotalFatigue -= 0.015
		if(isdatum(effectApplied))
			if((istype(effectApplied, /datum/DemonRacials)))
				if(source != ownerOfEffect)
					effectApplied?:applyDebuffs(source, ownerOfEffect)
			if((istype(effectApplied, /obj/Skills/Buffs)))
				if(source != ownerOfEffect)
					var/mob/p = ownerOfEffect
					var/dmg = p.getHellStormDamage()
					effectApplied?:applyEffects(source, ownerOfEffect, dmg)
	if(Deluged)
		source.Swim()
	else
		if(source.Swim)
			source.RemoveWaterOverlay()
			source.Swim = 0
			if (isplayer(source))
				source:move_speed = source.MovementSpeed()

		var/oxygen_cap = source.OxygenMax / max(source.SenseRobbed, 1)
		source.Oxygen = min(source.Oxygen + rand(1, 3), oxygen_cap)

		if (source.icon_state == "Train" && source.Secret == "Ripple")
			source.Oxygen = min(source.Oxygen + (oxygen_cap * 0.2), oxygen_cap * 2)

turf/Waters/Deluged = 1

turf/Special/Ichor_Water/Deluged = 1

turf/Special/Midgar_Ichor/Deluged = 1

mob/proc/loseOxygen(mult = 1)
	var/BreathingMaskOn = FALSE
	for(var/obj/Items/Tech/SpaceMask/SM in src)
		if(SM.suffix)
			BreathingMaskOn=1
	if(!BreathingMaskOn)
		if(!passive_handler.Get("SpaceWalk")&&(!src.race in list(MAJIN,DRAGON)))
			src.Oxygen-=rand(2,4)
			if(src.Oxygen<0)
				src.Oxygen=0
		if(src.Oxygen<10)
			src.LoseEnergy(2.0)
			if(src.TotalFatigue>=95)
				src.DamageSelf(TrueDamage(0.1))
				if(src.Health<-300)
					if(prob(20)&&!src.StabilizeModule)
						src.Death(null,"oxygen deprivation!")
	else if(BreathingMaskOn)
		if(src.Oxygen<(src.OxygenMax/max(src.SenseRobbed,1)))
			src.Oxygen+=rand(1,3)
		if(src.icon_state=="Train"&&src.Secret=="Ripple")
			src.Oxygen+=(src.OxygenMax/max(src.SenseRobbed,1))*0.2
			if(src.Oxygen>=(src.OxygenMax/max(src.SenseRobbed,1))*2)
				src.Oxygen=(src.OxygenMax/max(src.SenseRobbed,1))*2
		if(src.Oxygen<10)
			src.LoseEnergy(2)
			if(src.TotalFatigue>=95)
				src.DamageSelf(TrueDamage(0.1))
				if(src.Health<-300)
					if(prob(20)&&!src.StabilizeModule)
						src.Death(null,"oxygen deprivation!")

mob/proc/Swim()
	var/IgnoresWater=0
	var/BreathingMaskOn = 0
	if(passive_handler.Get("Fishman")||passive_handler.Get("SpaceWalk")||src.race in list(MAJIN,DRAGON))
		BreathingMaskOn=1
	for(var/obj/Items/Tech/SpaceMask/SM in src)
		if(SM.suffix)
			BreathingMaskOn=1
	for(var/mob/P in range(1,src))
		if(P.Grab==src)
			IgnoresWater=1
	if((passive_handler.Get("Skimming")+is_dashing) || src.Flying || src.HasWaterWalk() || src.HasGodspeed()>=2)
		IgnoresWater=1
		if(src.Swim)
			src.Swim=0
			src.RemoveWaterOverlay()
			if(isplayer(src))
				src:move_speed = MovementSpeed()
			//do easiest conditions first
			if((src.PoseEnhancement&&src.Secret=="Ripple"&&!(src.Flying&&!passive_handler.Get("Skimming"))+is_dashing))
				src.underlays+=image('The Ripple.dmi', pixel_x=-32, pixel_y=-32)
		else if(src.Secret=="Ripple")
			src.RemoveWaterOverlay()
			if((src.PoseEnhancement&&!src.Flying&&!(passive_handler.Get("Skimming"))+is_dashing))
				src.underlays+=image('The Ripple.dmi', pixel_x=-32, pixel_y=-32)
	if(!IgnoresWater)
		if(istype(loc,/turf/Waters/Water7))
			if(!src.HasWalkThroughHell())
				if(!isRace(DEMON)&&!src.HasHellPower())
					src.AddBurn(10)
		else
			if(src.Burn)
				src.Burn-=(src.Burn/2)
				if(src.Burn<0)
					src.Burn=0
		if(istype(loc,/turf/Special/Ichor_Water) && !src.HasVenomImmune())
			src.AddPoison(2)
		if(istype(loc,/turf/Waters/WaterD) && !src.HasVenomImmune())
			src.AddPoison(2)
		if(istype(loc,/turf/Special/Midgar_Ichor) && !src.HasVenomImmune())
			src.AddPoison(1)
		if(istype(loc,/turf/Special/Midgar_IchorWall) && !src.HasVenomImmune())
			src.AddPoison(1)
		if(istype(loc,/turf/Special/MidgarIchorW) && !src.HasVenomImmune())
			src.AddPoison(1)
		if(istype(loc,/turf/Special/MidgarIchorE) && !src.HasVenomImmune())
			src.AddPoison(1)
		if(istype(loc,/turf/Special/MidgarIchorN) && !src.HasVenomImmune())
			src.AddPoison(1)
		if(istype(loc,/turf/Special/MidgarIchorS) && !src.HasVenomImmune())
			src.AddPoison(1)
		if(Swim==0)
			src.RemoveWaterOverlay()
			spawn()
				if(loc:Deluged)
					src.overlays+=image('WaterOverlay.dmi',"Deluged")
					var/mob/p = loc:ownerOfEffect
					if(p!= src)

						src.AddSlow(1 + (0.5 * p.AscensionsAcquired))
						src.AddShock(1 + (0.5 * p.AscensionsAcquired))
				else if(src.PoseEnhancement&&src.Secret=="Ripple")
					src.underlays+=image('The Ripple.dmi', pixel_x=-32, pixel_y=-32)
				else if(loc.type==/turf/Waters/Water7/LavaTile)
					src.overlays+=image('LavaTileOverlay.dmi')
				else
					src.overlays+=image('WaterOverlay.dmi',"[loc.icon_state]")
		if(!Swim)
			Swim=1
			if(isplayer(src))
				src:move_speed = MovementSpeed()
		if(!src.KO)
			var/amounttaken=glob.OXYGEN_DRAIN/glob.OXYGEN_DRAIN_DIVISOR
			if(loc:Shallow==1)
				amounttaken=0
			if(src.PoseEnhancement&&src.Secret=="Ripple")
				amounttaken=0
			if(BreathingMaskOn)
				amounttaken=0
			if(loc:Deluged==1)
				amounttaken=4
			if(isRace(DRAGON))
				amounttaken=0
			if(passive_handler.Get("Fishman")||passive_handler.Get("SpaceWalk"))
				amounttaken=0
			if(src.FusionPowered)
				amounttaken=0
			if(!PureRPMode)
				src.Oxygen-=amounttaken
				if(src.Oxygen<0)
					src.Oxygen=0
				if(src.Oxygen<10)
					src.LoseEnergy(0.4)
					if(src.TotalFatigue>=95)
						src.Unconscious(null,"fatigue due to swimming! They will drown if not rescued!")
		else
			if(!isRace(DRAGON))
				if(BreathingMaskOn==0)
					src.Oxygen=0
					src.DamageSelf(TrueDamage(0.1))
					if(src.Health<-300)
						if(prob(20)&&!src.StabilizeModule)
							src.Death(null,"oxygen deprivation!")
				else
					if(src.Oxygen<(src.OxygenMax/max(src.SenseRobbed,1)))
						src.Oxygen=min(src.Oxygen+(rand(1,3)),(src.OxygenMax/max(src.SenseRobbed,1)))
					if(src.Oxygen<10)
						src.LoseEnergy(2)
						if(src.TotalFatigue>=95)
							src.DamageSelf(TrueDamage(1))
							if(src.Health<-300)
								if(prob(20)&&!src.StabilizeModule)
									src.Death(null,"oxygen deprivation!")