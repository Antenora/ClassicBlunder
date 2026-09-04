/mob/proc
	getElementalOffense()
		var/list/l = list();
		if(ElementalOffense) l |= ElementalOffense;
		if(Infusion && InfusionElement) l |= InfusionElement;
		if(StyleBuff && StyleBuff.ElementalOffense) l |= StyleBuff.ElementalOffense;
		return l;
	getElementalDefense()
		var/list/l = list();
		if(ElementalDefense) l |= ElementalDefense;
		if(Infusion && InfusionElement) l |= InfusionElement;
		if(StyleBuff && StyleBuff.ElementalDefense) l |= StyleBuff.ElementalDefense;
		return l;


/mob/proc/
	hasElementalOffense(off)
		if(off in getElementalOffense()) return 1;
		return 0;
	hasElementalDefense(def)
		if(def in getElementalDefense()) return 1;
		return 0;

proc
	ElementalCheck(var/mob/Attacker, var/mob/Defender, var/ForcedDebuff=0, var/DebuffIntensity=glob.DEBUFF_INTENSITY, list/bonusElements,damageOnly = FALSE, list/onlyTheseElements)
		var/list/attackElements = list()
		var/list/defenseElements = list()
		var/list/forcedDebuffs = list("Scorching", "Freezing", "Shattering", "Paralyzing", "Soaking", "Shredding", "Toxic", "Bloodletting")
		var/list/bonus = list()
		for(var/debuff in debuffVars)
			bonus[debuff] = max(0, Attacker.passive_handler.Get("[debuff]"))
		attackElements = Attacker.getElementalOffense()
		for(var/debuff in debuffVars)
			if(Attacker.passive_handler.Get("[debuff]"))
				attackElements |= debuff2Element[debuff]
				if(debuff in forcedDebuffs)
					ForcedDebuff = 1
		if(bonusElements&&bonusElements.len>0)
			attackElements |= bonusElements
		defenseElements = Defender.getElementalDefense();

		var/obj/Items/Enchantment/Staff/staf=Attacker.EquippedStaff()
		var/obj/Items/Sword/sord=Attacker.EquippedSword()
		var/obj/Items/Armor/armr = Defender.EquippedArmor()
		var/obj/Items/Sword/sord2 = Attacker.EquippedSecondSword()
		var/obj/Items/Sword/sord3 = Attacker.EquippedThirdSword()

		if(staf && IsChartElement(staf.Element))
			attackElements |= staf.Element
			DebuffIntensity /= glob.ITEM_DEBUFF_APPLY_NERF
		if(sord && IsChartElement(sord.Element))
			attackElements |= sord.Element
			DebuffIntensity /= glob.ITEM_DEBUFF_APPLY_NERF
		if(sord2 && IsChartElement(sord2.Element))
			attackElements |= sord2.Element
			DebuffIntensity /= glob.ITEM_DEBUFF_APPLY_NERF * 1.25
		if(sord3 && IsChartElement(sord3.Element))
			attackElements |= sord3.Element
			DebuffIntensity /= glob.ITEM_DEBUFF_APPLY_NERF * 1.5

		if(onlyTheseElements)
			attackElements = onlyTheseElements

		if(armr && armr.Element)
			defenseElements |= armr.Element

		if(Attacker.passive_handler["Amplify"])
			DebuffIntensity += Attacker.passive_handler["Amplify"] * glob.AMPLIFY_MODIFIER
		if(Attacker.UsingHotnCold())
			DebuffIntensity += abs(Attacker.StyleBuff?:hotCold)/glob.HOTNCOLD_DEBUFF_DIVISOR
		var/DamageMod=0
		if(Defender.Drenched > 0 && (("Lightning" in attackElements) || ("Ice" in attackElements)))
			DamageMod += glob.DRENCHED_AMP * (Defender.Drenched / 100)
		for(var/element in attackElements)
			if(!element) continue
			DamageMod += ElementMatchupMod(element, defenseElements)
			if(damageOnly) continue
			var/DebuffRate = ForcedDebuff ? 100 : ElementProcRate(element, defenseElements)
			if(Attacker.SenseUnlocked>5&&Attacker.SenseUnlocked>Attacker.SenseRobbed)
				DebuffRate+=10*(Attacker.SenseUnlocked-5)
			if(Attacker != Defender)
				DebuffRate += Attacker.GetOff(glob.OFF_DEBUFF_PROC_RATE)
			if(!Defender.HasDebuffReversal())
				DebuffRate -= Defender.GetDef(glob.DEF_DEBUFF_PROC_RESIST_RATE)
			if(DebuffRate<0)
				DebuffRate=0
			if(!prob(DebuffRate)) continue
			switch(element)
				if("Fire")
					if(!Defender.DemonicPower())
						Defender.AddBurn((4*DebuffIntensity*glob.BURN_INTENSITY) + bonus["Burning"] + bonus["Scorching"], Attacker)
				if("Water")
					Defender.AddDrenched((4*DebuffIntensity*glob.DRENCHED_INTENSITY) + bonus["Drenching"] + bonus["Soaking"], Attacker)
				if("Ice")
					Defender.AddSlow((4*DebuffIntensity*glob.SLOW_INTENSITY) + bonus["Chilling"] + bonus["Freezing"], Attacker)
				if("Wind")
					Defender.AddExposed((4*DebuffIntensity*glob.EXPOSED_INTENSITY) + bonus["Exposing"] + bonus["Shredding"], Attacker)
				if("Lightning")
					Defender.AddShock((4*DebuffIntensity*glob.SHOCK_INTENSITY) + bonus["Shocking"] + bonus["Paralyzing"], Attacker)
				if("Earth")
					Defender.AddShatter((4*DebuffIntensity*glob.SHATTER_INTENSITY) + bonus["Crushing"] + bonus["Shattering"], Attacker)
				if("Light")
					Defender.applyJudged()
				if("Dark")
					Defender.AddDoom(DebuffIntensity*glob.DOOM_INTENSITY, Attacker)
				if("Poison")
					if(!Defender.HasVenomImmune() && !("Poison" in defenseElements))
						Defender.AddPoison((2*DebuffIntensity*glob.POISON_INTENSITY) + bonus["Poisoning"] + bonus["Toxic"], Attacker)
				if("Blade")
					if(bonus["Bloodletting"] > 0)
						Defender.AddBleed(bonus["Bloodletting"], Attacker)
		return DamageMod/glob.ELEMENTAL_DIVIDER

	GetDebuffRate(var/A, list/D, var/Forced=0)
		if(Forced)
			return 100
		return ElementProcRate(A, D)

mob
	proc
		AddBurn(var/Value, var/mob/Attacker=null, var/raw=0)
			if(src.Stasis || src.AdminOverwatchActive)
				return
			if(Attacker && Attacker != src)
				Value *= 1 + Attacker.GetOff(glob.OFF_DEBUFF_RATE)
			var/burningShot = src.passive_handler.Get("BurningShot")
			if(!(Attacker == src && burningShot))
				Value *= AttunementAtkMult("Fire", Attacker)
			if(!burningShot && raw < 2)
				Value *= AttunementDefMult("Fire")
			if(Attacker && Attacker.demon_racial_vile_active)
				Value *= Attacker.GetDemonVileMult()
			Value *= InfuseElement("Fire")
			if(!burningShot)
				Value/=1+src.GetStatusResist()
			Value *= getBurnResistValue()
			if(src.Drenched > 0 && !(Attacker == src && burningShot) && world.time >= src.burn_dry_until)
				Value *= 1 - (src.Drenched / 200)
				src.Drenched -= Value * glob.DRENCHED_DOUSE / 2
				if(src.Drenched < 0)
					src.Drenched = 0
			Value = Value // this makes 100 impossible ?
			src.Burn+=Value

			// Track stacks from Erupting Blows sources separately
			if(Attacker && Attacker.passive_handler.Get("EruptingBlows"))
				src.SilentBurnAmount += Value

			if(Value >=1 && !raw && !src.passive_handler.Get("BurningShot"))
				animate(src, color = "#ff2643")
				animate(src, color = src.MobColor, time=5)
			if(Attacker)
				var/darkFlame = Attacker.HasDarknessFlame()
				if(darkFlame&&Attacker!=src)
					src.AddPoison(Value * 1 + (darkFlame * 0.125), Attacker=Attacker)
			if(Attacker)
				if(Attacker.passive_handler["Combustion"])
					var/combThresh = Attacker.passive_handler["Combustion"]
					var/combMult = Attacker.passive_handler.Get("EruptingBlows") ? 1.5 : 1
					if(combThresh <= 80)
						if(Burn >= combThresh)
							implodeDebuff(combThresh * combMult, "Burn")
					else
						if(Burn >= 80)
							implodeDebuff(combThresh * combMult, "Burn")


			if(src.Burn>100)
				src.Burn=100
			if(src.SilentBurnAmount > src.Burn)
				src.SilentBurnAmount = src.Burn
			if(src.Burn<0)
				src.Burn=0
				src.SilentBurnAmount=0
			for(var/obj/Items/Gear/Automated_Aid_Dispenser/AD in src)
				if(AD.suffix&&AD.Uses)
					AD.Uses--
					if(AD.Uses<0)
						AD.Uses=0
					if(!src.Cooled)
						OMsg(src, "<font color='[rgb(104, 153, 251)]'>[src]'s dispenser deploys a healing mist!!</font color>")
					src.Cooled+=100
		AddBleed(var/Value, var/mob/Attacker=null)
			if(src.Stasis || src.AdminOverwatchActive)
				return
			if(Attacker && Attacker != src)
				Value *= 1 + Attacker.GetOff(glob.OFF_DEBUFF_RATE)
			Value /= 1 + src.GetStatusResist()
			Value /= 1 + src.GetPhysResist()
			Value = Value * (1 - (src.Bleed / glob.DEBUFF_STACK_RESISTANCE))
			src.Bleed += Value
			if(Value >= 1)
				animate(src, color = "#cc0000")
				animate(src, color = src.MobColor, time=5)
			if(src.Bleed > 100)
				src.Bleed = 100
			if(src.Bleed < 0)
				src.Bleed = 0

		AddSlow(var/Value, var/mob/Attacker=null)
			if(src.HasChillImmune())
				return
			if(src.Stasis || src.AdminOverwatchActive)
				return
			if(Attacker && Attacker != src)
				Value *= 1 + Attacker.GetOff(glob.OFF_DEBUFF_RATE)
			Value *= AttunementMult("Ice", Attacker)
			Value *= InfuseElement("Ice")
			Value/=1+src.GetStatusResist()
			Value = Value*(1-(src.Slow/glob.DEBUFF_STACK_RESISTANCE))
			Value *= getChillResistValue()
			src.Slow+=Value

			if(Value >=1)
				animate(src, color = "#578cff")
				animate(src, color = src.MobColor, time=5)
				if(Attacker&&Attacker.HasAbsoluteZero())
					src.Shatter+=Value/2
					if(src.Shatter>100)
						src.Shatter=100
					src.Shock+=Value/2
					if(src.Shock>100)
						src.Shock=100
					ShockThreshold(Attacker)
			if(Attacker)
				if(Attacker.passive_handler["IceAge"] && Slow >= Attacker.passive_handler["IceAge"])
					implodeDebuff(Attacker.passive_handler["IceAge"], "Chill")
			if(src.Slow>100)
				src.Slow=100
			if(src.Slow<0)
				src.Slow=0
			for(var/obj/Items/Gear/Automated_Aid_Dispenser/AD in src)
				if(AD.suffix&&AD.Uses)
					AD.Uses--
					if(AD.Uses<0)
						AD.Uses=0
					if(!src.Cooled)
						OMsg(src, "<font color='[rgb(104, 153, 251)]'>[src]'s dispenser deploys a healing mist!!</font color>")
					src.Cooled+=100
		AddShatter(var/Value, var/mob/Attacker=null)
			if(src.Stasis || src.AdminOverwatchActive)
				return
			if(Attacker && Attacker != src)
				Value *= 1 + Attacker.GetOff(glob.OFF_DEBUFF_RATE)
			Value *= AttunementMult("Earth", Attacker)
			Value *= InfuseElement("Earth")
			Value/=1+src.GetStatusResist()
			Value /= 1 + src.GetPhysResist()
			Value *= getShatterResistValue()
			Value = Value*(1-(src.Shatter/glob.DEBUFF_STACK_RESISTANCE))
			src.Shatter+=Value

			if(Value >=1)
				src.color = "#8f7946"
				animate(src, color = src.MobColor, time=5)


			if(Attacker)
				var/eh = Attacker.getEarthHerald()
				if(eh && Shatter >= (100 / eh))
					implodeDebuff(100, "Shatter")

			if(src.Shatter>100)
				src.Shatter=100
			if(src.Shatter<0)
				src.Shatter=0
			for(var/obj/Items/Gear/Automated_Aid_Dispenser/AD in src)
				if(AD.suffix&&AD.Uses)
					AD.Uses--
					if(AD.Uses<0)
						AD.Uses=0
					if(!src.Sprayed)
						OMsg(src, "<font color='[rgb(104, 153, 251)]'>[src]'s dispenser deploys a healing mist!!</font color>")
					src.Sprayed+=100
		ShockThreshold(mob/Attacker)
			if(src.Shock < glob.SHOCK_PARALYSIS_AT) return
			if(!Attacker || Attacker == src) return
			src.Shock = glob.SHOCK_PARALYSIS_RESET
			Stun(src, glob.SHOCK_PARALYSIS, FALSE)
		AddShock(var/Value, var/mob/Attacker=null)
			if(src.Stasis || src.AdminOverwatchActive)
				return
			if(Attacker && Attacker != src)
				Value *= 1 + Attacker.GetOff(glob.OFF_DEBUFF_RATE)
			Value *= AttunementMult("Lightning", Attacker)
			Value *= InfuseElement("Lightning")
			Value/=1+src.GetStatusResist()
			Value *= getShockResistValue()
			Value = Value*(1-(src.Shock/glob.DEBUFF_STACK_RESISTANCE))
			src.Shock+=Value

			if(Value >=1)
				animate(src, color = "#fff757")
				animate(src, color = src.MobColor, time=5)

			ShockThreshold(Attacker)
			if(src.Shock<0)
				src.Shock=0
			for(var/obj/Items/Gear/Automated_Aid_Dispenser/AD in src)
				if(AD.suffix&&AD.Uses)
					AD.Uses--
					if(AD.Uses<0)
						AD.Uses=0
					if(!src.Stabilized)
						OMsg(src, "<font color='[rgb(104, 153, 251)]'>[src]'s dispenser deploys a healing mist!!</font color>")
					src.Stabilized+=100
		AddDrenched(var/Value, var/mob/Attacker=null)
			if(src.Stasis || src.AdminOverwatchActive)
				return
			if(Attacker && Attacker != src)
				Value *= 1 + Attacker.GetOff(glob.OFF_DEBUFF_RATE)
			Value *= AttunementMult("Water", Attacker)
			Value *= InfuseElement("Water")
			Value/=1+src.GetStatusResist()
			Value = Value*(1-(src.Drenched/glob.DEBUFF_STACK_RESISTANCE))
			src.Drenched+=Value

			if(Value >=1)
				animate(src, color = "#7ec8ff")
				animate(src, color = src.MobColor, time=5)

			if(src.Burn > 0 && world.time >= src.burn_dry_until)
				src.Burn -= Value * glob.DRENCHED_DOUSE
				if(src.Burn < 0)
					src.Burn = 0
				if(src.SilentBurnAmount > src.Burn)
					src.SilentBurnAmount = src.Burn

			if(src.Drenched>100)
				src.Drenched=100
			if(src.Drenched<0)
				src.Drenched=0
		AddExposed(var/Value, var/mob/Attacker=null)
			if(src.Stasis || src.AdminOverwatchActive)
				return
			if(Attacker && Attacker != src)
				Value *= 1 + Attacker.GetOff(glob.OFF_DEBUFF_RATE)
			Value *= AttunementMult("Wind", Attacker)
			Value *= InfuseElement("Wind")
			Value/=1+src.GetStatusResist()
			Value = Value*(1-(src.Exposed/glob.DEBUFF_STACK_RESISTANCE))
			src.Exposed+=Value

			if(Value >=1)
				animate(src, color = "#d8ffe8")
				animate(src, color = src.MobColor, time=5)

			if(src.Exposed>100)
				src.Exposed=100
			if(src.Exposed<0)
				src.Exposed=0
		AddPoison(var/Value, var/mob/Attacker=null)
			if(src.Stasis || src.AdminOverwatchActive)
				return
			if(Attacker && Attacker != src)
				Value *= 1 + Attacker.GetOff(glob.OFF_DEBUFF_RATE)
			Value /= 1 + src.GetStatusResist()
			// Devil Summoner Vile racial
			if(Attacker && Attacker.demon_racial_vile_active)
				Value *= Attacker.GetDemonVileMult()

			if(Attunement=="Poison")
				Value/=2
			Value = Value*(1-(src.Poison/glob.DEBUFF_STACK_RESISTANCE))
			src.Poison+=Value

			// Track stacks from Silent Poison sources separately
			if(Attacker && Attacker.passive_handler.Get("SilentPoison"))
				src.SilentPoisonAmount += Value

			if(Value >=1)
				animate(src, color = "#ff1cff")
				animate(src, color = src.MobColor, time=5)
			if(Attacker && client)
				if(Attacker.passive_handler["BlindingVenom"])
					if(!BlindingVenom)
						BlindingVenom=Attacker.passive_handler["BlindingVenom"]

			if(Attacker&&Attacker.CursedWounds())
				AddShearing(Value/2)
				AddCrippling(Value/3)
			if(src.Poison>100)
				src.Poison=100
			if(src.SilentPoisonAmount > src.Poison)
				src.SilentPoisonAmount = src.Poison
			if(src.Poison<0)
				src.Poison=0
				src.SilentPoisonAmount=0
			for(var/obj/Items/Gear/Automated_Aid_Dispenser/AD in src)
				if(AD.suffix&&AD.Uses)
					AD.Uses--
					if(AD.Uses<0)
						AD.Uses=0
					if(!src.Antivenomed)
						OMsg(src, "<font color='[rgb(104, 153, 251)]'>[src]'s dispenser deploys a healing mist!!</font color>")
					src.Antivenomed+=100
		AddConfusing(var/Value, var/mob/Attacker=null)
			if(src.Stasis)
				return
			if(Attacker && Attacker != src)
				Value *= 1 + Attacker.GetOff(glob.OFF_DEBUFF_RATE)
			Value /= 1 + src.GetStatusResist()
			Value /= 1 + src.GetMentalResist()
			src.Confused+=Value
			if(src.Confused>100)
				src.Confused=100
			for(var/obj/Items/Gear/Automated_Aid_Dispenser/AD in src)
				if(AD.suffix&&AD.Uses)
					AD.Uses--
					if(AD.Uses<0)
						AD.Uses=0
					if(!src.Stabilized)
						OMsg(src, "<font color='[rgb(104, 153, 251)]'>[src]'s dispenser deploys a healing mist!!</font color>")
					src.Stabilized+=100
		AddShearing(var/Value, var/mob/Attacker=null)
			if(src.HasShearImmunity())
				return
			if(src.Stasis)
				return
			if(Attacker && Attacker != src)
				Value *= 1 + Attacker.GetOff(glob.OFF_DEBUFF_RATE)
			Value /= 1 + src.GetStatusResist()
			Value /= 1 + src.GetPhysResist()
			Value *= getShearResistValue()
			Value = Value*(1-(src.GetEffectiveShearForStackingEffects()/glob.DEBUFF_STACK_RESISTANCE))
			src.Sheared+=Value
			if(src.Sheared>100)
				src.Sheared=100
			for(var/obj/Items/Gear/Automated_Aid_Dispenser/AD in src)
				if(AD.suffix&&AD.Uses)
					AD.Uses--
					if(AD.Uses<0)
						AD.Uses=0
					if(!src.Sprayed)
						OMsg(src, "<font color='[rgb(104, 153, 251)]'>[src]'s dispenser deploys a healing mist!!</font color>")
					src.Sprayed+=100
		AddCrippling(var/Value, var/mob/Attacker=null)
			if(src.Stasis)
				return
			if(Attacker && Attacker != src)
				Value *= 1 + Attacker.GetOff(glob.OFF_DEBUFF_RATE)
			Value /= 1 + src.GetStatusResist()
			Value /= 1 + src.GetPhysResist()

			if(isRace(WILDER) && Class == "Wind") Value /= 2
			Value *= getCrippleResistValue()

			src.Crippled+=Value

			if(src.Crippled>100) src.Crippled=100
			for(var/obj/Items/Gear/Automated_Aid_Dispenser/AD in src)
				if(AD.suffix&&AD.Uses)
					AD.Uses--
					if(AD.Uses<0)
						AD.Uses=0
					if(!src.Sprayed)
						OMsg(src, "<font color='[rgb(104, 153, 251)]'>[src]'s dispenser deploys a healing mist!!</font color>")
					src.Sprayed+=100
		AddAttracting(var/Value, var/mob/m)
			if(src.Stasis)
				return
			if(world.time < src.AttractingCooldown)
				return
			if(m && m != src)
				Value *= 1 + m.GetOff(glob.OFF_DEBUFF_RATE)
			Value /= 1 + src.GetStatusResist()
			Value /= 1 + src.GetMentalResist()
			src.Attracted+=Value
			src.AttractedTo=m
			if(src.Attracted>=100)
				src.Attracted=0
				src.AttractingCooldown = world.time + glob.ATTRACTING_CHARM_CD
				src.applyCharmed(m, 5)
		AddTerrifying(var/Value, var/mob/m)
			if(src.Stasis)
				return
			src.Terrified+=Value
			src.TerrifiedOf=m
			if(src.Terrified>100)
				src.Terrified=100
		AddPacifying(var/Value, var/mob/Attacker=null)
			if(src.Stasis)
				return
			if(!src.DemonicPower())
				src.Calm(Pacified=1)
		AddEnraging(var/Value, var/mob/Attacker=null)
			if(src.Stasis)
				return
			src.ForceAngered(Enraged=1)
		AddDoom(var/Value, var/mob/Attacker=null, var/DI)
			if(src.Stasis)
				return
			if(src.DownToEarth)
				return
			if(Attacker && Attacker != src)
				Value *= 1 + Attacker.GetOff(glob.OFF_DEBUFF_RATE)
			Value /= 1 + src.GetStatusResist()
			Value /= 1 + src.GetMentalResist()
			src.Doomed+=Value
			if(src.Doomed>=100)
				if(src.passive_handler.Get("The Inkstone"))
					src.Doomed=0
					src.DownToEarth=100
					OMsg(src, "<b><font color='purple'>The bell tolls for [src]...</font color></b>")
					sleep(30)
					OMsg(src, "<b><font color='purple'>...but they refuse.</font color></b>")
					sleep(10)
					OMsg(src, "<b><font color='purple'>And yet, one more crack in their armor shows.</font color></b>")
					if(src.BioArmor)
						src.BioArmor*=0.95
					return
				src.VaizardHealth/=2
				src.ManaAmount/=4
				src.Doomed=0
				src<<"<b><font color='red'>Death passes you by, and takes a piece of you along with it.</font color></b>"
				OMsg(src, "<b><font color='purple'>The bell tolls for [src],</font color></b>")
				src.DownToEarth=100
				if(DI)
					src.Health*=0.60
				if(src.HasGodKi()||src.HasMaouKi())
					src<<"<b><font color='red'>Death comes for all, even those with the power of Gods. Your divinity has been temporarily forfeit.</font color></b>"

globalTracker/var/DEBUFF_STACK_MAX = 100;

/mob/proc/CleanseDebuff(amt)
	var/list/debuff = list("Poison", "Burn", "Shatter", "Slow", "Shock", "Drenched", "Exposed", "Crippled", "Confused", "Stunned", "Sheared", "Attracted","Doomed");
	for(var/db in debuff)
		src.vars["[db]"] -= amt;
/mob/proc/shouldCleanse(mob/trg)
	if(trg == src) return 1;
	if(src.party && trg in src.party.members) return 1;
	return 0;
/mob/proc/RefreshBlow(refreshingBlow)
	if(!src.party) return 0;
	for(var/mob/m in oview(refreshingBlow * 2, src))
		if(m in src.party.members)
			m.CleanseDebuff(refreshingBlow);

mob
	proc
		Debuffs()
			if(src.Stasis)
				return
			if(src.Poison)
				doDebuffDamage("Poison")
			if(src.Burn)
				doDebuffDamage("Burn")

			if(src.Bleed)
				doDebuffDamage("Bleed")

			if(src.Frenzy)
				doDebuffDamage("Frenzy")

			if(src.Shatter)
				if(src.Shatter > glob.DEBUFF_STACK_MAX)
					src.Shatter = glob.DEBUFF_STACK_MAX;

				var/shatterReduction = max(0.1, (src.GetEnd(0.25)+src.GetDef(0.1))*(1+src.GetStatusResist()))
				if(src.Sprayed) shatterReduction *= 2;
				src.Shatter-= shatterReduction;

				if(src.Shatter<0)
					src.Shatter=0

			if(src.Slow)
				if(src.Slow > glob.DEBUFF_STACK_MAX)
					src.Slow = glob.DEBUFF_STACK_MAX;

				var/slowReduction = max(0.1, (src.GetEnd(0.25)+src.GetSpd(0.1))*(1+src.GetStatusResist()))
				if(src.Cooled) slowReduction *= 2;
				if(passive_handler["Shirayuki"]) //Rukia Zanpakuto Shenanigans.
					if(!src.CheckActive("Ki Control")) // Shirayuki Passive + Ki Control Active = Slow does not decay.
						src.Slow -= slowReduction * 2.5; //This should make it to where if you have the passive but aren't Powered-Up, it decays quicker.
				else
					src.Slow -= slowReduction;

				if(src.Slow<0)
					src.Slow=0

			if(src.Shock)
				if(src.Shock > glob.DEBUFF_STACK_MAX)
					src.Shock = glob.DEBUFF_STACK_MAX;

				var/shockReduction = max(0.1, (src.GetEnd(0.25)+src.GetSpd(0.1))*(1+src.GetStatusResist()));
				if(src.Stabilized) shockReduction *= 2;
				src.Shock-= shockReduction;

				if(src.Shock<0)
					src.Shock=0

			if(src.Drenched)
				if(src.Drenched > glob.DEBUFF_STACK_MAX)
					src.Drenched = glob.DEBUFF_STACK_MAX;

				var/drenchReduction = max(0.1, (src.GetEnd(0.25)+src.GetSpd(0.1))*(1+src.GetStatusResist()));
				src.Drenched-= drenchReduction;

				if(src.Drenched<0)
					src.Drenched=0

			if(src.Exposed)
				if(src.Exposed > glob.DEBUFF_STACK_MAX)
					src.Exposed = glob.DEBUFF_STACK_MAX;

				var/exposedReduction = max(0.1, (src.GetEnd(0.25)+src.GetDef(0.1))*(1+src.GetStatusResist()));
				src.Exposed-= exposedReduction;

				if(src.Exposed<0)
					src.Exposed=0

			if(src.Crippled)
				if(src.Crippled > glob.DEBUFF_STACK_MAX)
					src.Crippled = glob.DEBUFF_STACK_MAX;

				var/cripReduction = max(0.1, (src.GetSpd(0.25)+src.GetDef(0.1))*(1+src.GetStatusResist()));
				if(src.Sprayed) cripReduction *= 2;
				src.Crippled-= cripReduction;

				if(src.Crippled<0)
					src.Crippled=0

			if(src.Confused&&!src.Stunned&&!src.Suspended)
				if(src.Confused > glob.DEBUFF_STACK_MAX)
					src.Confused = glob.DEBUFF_STACK_MAX;

				var/confuseReduce = max(1, (1+src.GetSpd(0.25)));//This max statement should never fire, unless stats are going negative, but they might!
				if(src.Stabilized) confuseReduce = 5;
				src.Confused-=confuseReduce;

				if(src.Confused<0)
					src.Confused=0

			if(src.Sheared)
				if(src.Sheared > glob.DEBUFF_STACK_MAX)
					src.Sheared = glob.DEBUFF_STACK_MAX;

				var/shearReduce = 0.25;
				if(src.icon_state=="Meditate") shearReduce *= 8;
				if(src.Sprayed) shearReduce *= 2;
				src.Sheared -= shearReduce;

				if(src.Sheared<0)
					src.Sheared=0
			if(src.Doomed)
				var/DoomReduce=0.01
				if(src.icon_state=="Meditate") DoomReduce*= 100;
				src.Doomed -= DoomReduce
				if(src.Doomed<0)
					src.Doomed=0
			if(src.DownToEarth)
				var/DownToEarthReduce=0.25
				if(src.icon_state=="Meditate") DownToEarthReduce*= 8;
				if(src.DownToEarth>=50) DownToEarthReduce*=4;
				src.DownToEarth-=DownToEarthReduce
				if(src.DownToEarth<0)
					src.DownToEarth=0

			if(src.Attracted&&!src.Confused&&!src.Stunned&&!src.Suspended)
				src.Attracted--
			if(src.Attracted<=0)
				src.Attracted=0
				src.AttractedTo=0

			if(!src.AttractedTo)
				src.Attracted=0


