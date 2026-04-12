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
		if(bonusElements&&bonusElements.len>0)
			attackElements |= bonusElements

		attackElements = Attacker.getElementalOffense()
		defenseElements = Defender.getElementalDefense();

		var/obj/Items/Enchantment/Staff/staf=Attacker.EquippedStaff()
		var/obj/Items/Sword/sord=Attacker.EquippedSword()
		var/obj/Items/Armor/armr = Defender.EquippedArmor()
		var/obj/Items/Sword/sord2 = Attacker.EquippedSecondSword()
		var/obj/Items/Sword/sord3 = Attacker.EquippedThirdSword()

		if(staf && staf.Element)
			attackElements |= staf.Element
			DebuffIntensity /= glob.ITEM_DEBUFF_APPLY_NERF
		if(sord && sord.Element)
			attackElements |= sord.Element
			DebuffIntensity /= glob.ITEM_DEBUFF_APPLY_NERF // 4
		if(sord2)
			attackElements |= sord2.Element
			DebuffIntensity /= glob.ITEM_DEBUFF_APPLY_NERF * 1.25
		if(sord3)
			attackElements |= sord3.Element
			DebuffIntensity /= glob.ITEM_DEBUFF_APPLY_NERF * 1.5

		if(onlyTheseElements)
			attackElements = onlyTheseElements
		
		if(armr && armr.Element)
			defenseElements |= armr.Element

		if(attackElements["Ultima"]||attackElements["Death"])
			ForcedDebuff+=1
		var/DamageMod=0
		for(var/element in attackElements)
			var/DebuffRate=GetDebuffRate(element, defenseElements, ForcedDebuff)
			var/CelestialDebuffRate=1
			if(Attacker.isRace(CELESTIAL, DEMON, MAKAIOSHIN))
				CelestialDebuffRate=0.2*(Attacker.AscensionsAcquired+1)
				if(CelestialDebuffRate>1)
					CelestialDebuffRate=1
			if(Attacker.SenseUnlocked>5&&Attacker.SenseUnlocked>Attacker.SenseRobbed)
				DebuffRate+=10*(Attacker.SenseUnlocked-5)
			if(Defender.HasDebuffResistance())
				DebuffRate/=1+Defender.GetDebuffResistance()
			if(glob.INTIM_REDUCES_DEBUFFS)
				if(Defender.HasIntimidation())
					var/Effective=Defender.GetIntimidation()
					var/Ratio=Attacker.GetIntimidationIgnore(Defender)
					var/Ignored=Effective*Ratio
					Effective-=Ignored
					if(Effective<0)
						Effective=0
					DebuffRate-=Effective/10
			if(DebuffRate<0)
				DebuffRate=0

			if(Attacker.passive_handler["Amplify"])
				DebuffIntensity += Attacker.passive_handler["Amplify"] * glob.AMPLIFY_MODIFIER
			if(Attacker.UsingHotnCold())
				DebuffIntensity += abs(Attacker.StyleBuff?:hotCold)/glob.HOTNCOLD_DEBUFF_DIVISOR
			switch(element)
				if("Truth")
					DamageMod+=2
					if("HellFire" in defenseElements)
						DamageMod-=1
					if("FelFire" in defenseElements)
						DamageMod-=1
				if("Ultima")
					DamageMod+=2
				if("Death")
					DamageMod+=3
				if("Love")
					DamageMod+=3
				if("Mirror")
					DamageMod+=2
				if("Chaos")
					DamageMod+=2
				if("Void")
					DamageMod+=2
				if("Felfire")
					if("Truth" in defenseElements)
						DamageMod-=1
					if("Water" in defenseElements)
						DamageMod += 1.5
					if("Wind" in defenseElements)
						DamageMod += 2
				if("HellFire")
					DamageMod+=2
					if("Truth" in defenseElements)
						DamageMod-=1
					if("Fire" in defenseElements) // simply consume lesser fire
						DamageMod+=1
					if("Wind" in defenseElements)
						DamageMod+=1
					if("Water" in defenseElements)
						DamageMod-=2//Reduced damage
				if("Fire")
					if("Water" in defenseElements)
						DamageMod-=1//Reduced damage
					if("Wind" in defenseElements)
						DamageMod+=1//Increased damage mod
				if("Water")
					if("Fire" in defenseElements)
						DamageMod+=1
					if("Earth" in defenseElements)
						DamageMod-=1
				if("Earth")
					if("Water" in defenseElements)
						DamageMod+=1
					if("Wind" in defenseElements)
						DamageMod-=1
				if("Wind")
					if("Fire" in defenseElements)
						DamageMod-=1
					if("Earth" in defenseElements)
						DamageMod+=1
			if(!damageOnly&&prob(DebuffRate))
				switch(element)
					if("HellFire")
						Defender.AddPoison(2*DebuffIntensity*glob.POISON_INTENSITY*CelestialDebuffRate, Attacker)
						Defender.AddBurn(3*DebuffIntensity*glob.BURN_INTENSITY*CelestialDebuffRate, Attacker)
						Defender.AddShearing(4*DebuffIntensity*CelestialDebuffRate, Attacker)
					if("Felfire")
						Defender.AddBurn(2*DebuffIntensity*glob.BURN_INTENSITY, Attacker)
						Defender.AddShatter(2*DebuffIntensity*glob.SHATTER_INTENSITY, Attacker)
					if("Truth")
						var/whoa = prob(50)
						if(whoa)
							Defender.AddBurn(2*DebuffIntensity*glob.BURN_INTENSITY, Attacker)
							Defender.AddPoison(2*DebuffIntensity*glob.POISON_INTENSITY, Attacker)
						else
							Defender.AddSlow(3*DebuffIntensity*glob.SLOW_INTENSITY, Attacker)
							Defender.AddShatter(3*DebuffIntensity*glob.SHATTER_INTENSITY, Attacker)
							Defender.AddShock(3*DebuffIntensity*glob.SHOCK_INTENSITY, Attacker)

					if("Chaos")
						if(prob(glob.CHAOS_CHANCE))
							Defender.AddBurn(2*DebuffIntensity*glob.BURN_INTENSITY, Attacker)
						if(prob(glob.CHAOS_CHANCE))
							Defender.AddSlow(2*DebuffIntensity*glob.SLOW_INTENSITY, Attacker)
						if(prob(glob.CHAOS_CHANCE))
							Defender.AddShatter(2*DebuffIntensity*glob.SHATTER_INTENSITY, Attacker)
						if(prob(glob.CHAOS_CHANCE))
							Defender.AddShock(2*DebuffIntensity*glob.SHOCK_INTENSITY, Attacker)
						if(prob(glob.CHAOS_CHANCE))
							Defender.AddPoison(2*DebuffIntensity*glob.POISON_INTENSITY, Attacker)
					if("Ultima")
						Defender.AddBurn(2*DebuffIntensity*glob.BURN_INTENSITY, Attacker)
						Defender.AddSlow(2*DebuffIntensity*glob.SLOW_INTENSITY, Attacker)
						Defender.AddShatter(2*DebuffIntensity*glob.SHATTER_INTENSITY, Attacker)
						Defender.AddShock(2*DebuffIntensity*glob.SHOCK_INTENSITY, Attacker)
					if("Death")
						if(prob(glob.CHAOS_CHANCE))
							Defender.AddDoom(1, Attacker)
					if("Rain")
						Defender.AddSlow(4*DebuffIntensity*glob.SLOW_INTENSITY, Attacker)
						Defender.AddShock(4*DebuffIntensity*glob.SHOCK_INTENSITY, Attacker)
					if("Poison")
						if(!Defender.HasVenomImmune() && !("Poison" in defenseElements))
							Defender.AddPoison(2*DebuffIntensity*glob.POISON_INTENSITY, Attacker)
					if("Fire")
						if(!Defender.DemonicPower())
							Defender.AddBurn(4*DebuffIntensity*glob.BURN_INTENSITY, Attacker)
					if("Water")
						Defender.AddSlow(4*DebuffIntensity*glob.SLOW_INTENSITY, Attacker)
					if("Earth")
						Defender.AddShatter(4*DebuffIntensity*glob.SHATTER_INTENSITY, Attacker)
					if("Wind")
						Defender.AddShock(4*DebuffIntensity*glob.SHOCK_INTENSITY, Attacker)
		for(var/element in defenseElements)
			switch(element)
				if("Ultima")
					DamageMod-=2
				if("Mirror")
					DamageMod-=2
				if("Chaos")
					DamageMod-=2
				if("Void")
					DamageMod-=2
		return DamageMod/10

	GetDebuffRate(var/A, list/D, var/Forced=0)
		var/Return=0
		if(Forced)
			Return=100
			return Return
		switch(A)
			if("Rain")
				Return=30

			if("HellFire")
				Return=50
				if("Mirror" in D)
					Return-=20
				if("Fire" in D)
					Return+=20
				if("Water" in D)
					Return-=35
				if("Earth" in D)
					Return-=35
				if("Wind" in D)//Super effective
					Return+=20
				if("Ultima" in D)
					Return+=10

			if("Fire")//Chance of burn
				Return=30//Chance of burn on every hit.
				if("Mirror" in D)
					Return-=20
				if("Fire" in D)
					Return+=10
				if("Water" in D)
					Return-=20
				if("Earth" in D)
					Return-=10
				if("Wind" in D)//Super effective
					Return+=20
				if("Ultima" in D)
					Return+=50
			if("Water")//Chance of freeze
				Return=30
				if("Mirror" in D)
					Return-=20
				if("Fire" in D)//Super Effective
					Return+=20
				if("Water" in D)
					Return+=10
				if("Earth" in D)
					Return-=20
				if("Wind" in D)
					Return-=10
				if("Ultima" in D)
					Return+=50
			if("Earth")//Chance of break
				Return=30
				if("Mirror" in D)
					Return-=20
				if("Fire" in D)
					Return-=10
				if("Water" in D)//Super Effective
					Return+=20
				if("Earth" in D)
					Return+=10
				if("Wind" in D)
					Return-=20
				if("Ultima" in D)
					Return+=50
			if("Wind")//Chance of off/def reduction
				Return=30
				if("Mirror" in D)
					Return-=20
				if("Fire" in D)
					Return-=20
				if("Water" in D)
					Return-=10
				if("Earth" in D)//Super Effective
					Return+=20
				if("Wind" in D)
					Return+=10
				if("Ultima" in D)
					Return+=50
		if(A=="Poison")//Chance to poison.
			Return=30
			if("Mirror" in D)
				Return-=20
			if("Ultima" in D)
				Return+=40
		if(A=="Chaos")//Chance of EVERYTHING GOES TO HELL.
			Return=30
			if("Mirror" in D)
				Return-=20
			if("Ultima" in D)
				Return+=40
		if(A=="Ultima")//Chance of EVERYTHING GOES TO HELL.
			Return=100
			if("Mirror" in D)
				Return-=20
		if(A=="Death")
			Return=100
		return Return
mob
	proc
		AddBurn(var/Value, var/mob/Attacker=null)
			if(src.Stasis || src.AdminOverwatchActive)
				return
			if(Attacker && Attacker != src && Attacker.hasMagePassive(/mage_passive/fire/BurnMastery))
				Value *= 2
			if(Attacker && (Attacker == src ? !src.passive_handler.Get("BurningShot") : 1))
				if(Attacker.Attunement=="Fire")
					Value*=1.5
				else if(Attacker.Attunement=="HellFire")
					Value*=glob.HELLFIRE_VALUE_MOD
			// Devil Summoner Vile racial
			if(Attacker && Attacker.demon_racial_vile_active)
				Value *= Attacker.GetDemonVileMult()
			if(src.Attunement=="Wind")
				Value*=1.5
			if(Attunement=="Fire" && !src.passive_handler.Get("BurningShot"))
				Value/=2
			if(src.Infusion)
				if(!src.InfusionElement)
					src.InfusionElement="Fire"
				Value/=2
			if(src.HasDebuffResistance() && !src.passive_handler.Get("BurningShot"))
				Value/=1+src.GetDebuffResistance()
			Value *= getBurnResistValue()
			Value = Value // this makes 100 impossible ?
			src.Burn+=Value
			if(Value >=1 && !src.passive_handler.Get("BurningShot"))
				animate(src, color = "#ff2643")
				animate(src, color = src.MobColor, time=5)
			if(Attacker)
				var/darkFlame = Attacker.HasDarknessFlame()
				if(darkFlame&&Attacker!=src)
					src.AddPoison(Value * 1 + (darkFlame * 0.125), Attacker=Attacker)
			if(Attacker)
				if(Attacker.passive_handler["Combustion"])
					if(Attacker.passive_handler["Combustion"] <= 80)
						if(Attacker.passive_handler["Combustion"] && Burn >= Attacker.passive_handler["Combustion"])
							implodeDebuff(Attacker.passive_handler["Combustion"], "Burn")
					else
						if(Attacker.passive_handler["Combustion"] && Burn >= 80)
							implodeDebuff(Attacker.passive_handler["Combustion"], "Burn")


			if(Attacker)
				if(Attacker.passive_handler["FireHerald"] && src.Burn >= 100)
					implodeDebuff(100, "Burn")
					for(var/mob/Players/P in range(2, src))
						if(P != src && P != Attacker)
							P.AddBurn(25)

			if(src.Burn>100)
				src.Burn=100
			if(src.Burn<0)
				src.Burn=0
			for(var/obj/Items/Gear/Automated_Aid_Dispenser/AD in src)
				if(AD.suffix&&AD.Uses)
					AD.Uses--
					if(AD.Uses<0)
						AD.Uses=0
					if(!src.Cooled)
						OMsg(src, "<font color='[rgb(104, 153, 251)]'>[src]'s dispenser deploys a healing mist!!</font color>")
					src.Cooled+=100
		AddSlow(var/Value, var/mob/Attacker=null)
			if(src.Stasis || src.AdminOverwatchActive)
				return
			if(Attacker && Attacker != src && Attacker.hasMagePassive(/mage_passive/water/ChillMastery))
				Value *= 2
			if(Attacker && Attacker.Attunement == "Water")
				Value*=1.5
			if(Attunement=="Fire")
				Value*=1.5
			if(Attunement=="Water")
				Value/=2
			if(src.Infusion)
				if(!src.InfusionElement)
					src.InfusionElement="Water"
				Value/=2
			if(src.HasDebuffResistance())
				Value/=1+src.GetDebuffResistance()
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
			if(Attacker)
				if(Attacker.passive_handler["IceAge"] && Slow >= Attacker.passive_handler["IceAge"])
					implodeDebuff(Attacker.passive_handler["IceAge"], "Chill")
				if(Attacker.passive_handler["IceHerald"] && src.Slow >= 100)
					implodeDebuff(100, "Chill")
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
			if(Attacker && Attacker != src && Attacker.hasMagePassive(/mage_passive/earth/ShatterMastery))
				Value *= 2
			if(Attacker && Attacker.Attunement=="Earth")
				Value*=1.5
			if(Attunement=="Water")
				Value*=1.5
			if(Attunement=="Earth")
				Value/=2
			if(src.Infusion)
				if(!src.InfusionElement)
					src.InfusionElement="Earth"
				Value/=2
			if(src.HasDebuffResistance())
				Value/=1+src.GetDebuffResistance()
			Value *= getShatterResistValue()
			Value = Value*(1-(src.Shatter/glob.DEBUFF_STACK_RESISTANCE))
			src.Shatter+=Value

			if(Value >=1)
				src.color = "#8f7946"
				animate(src, color = src.MobColor, time=5)


			if(Attacker)
				if(Attacker.passive_handler["EarthHerald"] && src.Shatter >= 100)
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
		AddShock(var/Value, var/mob/Attacker=null)
			if(src.Stasis || src.AdminOverwatchActive)
				return
			if(Attacker && Attacker != src && Attacker.hasMagePassive(/mage_passive/air/ShockMastery))
				Value *= 2
			if(Attacker && Attacker.Attunement=="Wind")
				Value*=1.5
			if(src.Attunement=="Earth")
				Value*=1.5
			if(Attunement=="Wind")
				Value/=2
			if(src.Infusion)
				if(!src.InfusionElement)
					src.InfusionElement="Wind"
				Value/=2

			if(src.HasDebuffResistance())
				Value/=1+src.GetDebuffResistance()
			Value *= getShockResistValue()
			Value = Value*(1-(src.Shock/glob.DEBUFF_STACK_RESISTANCE))
			src.Shock+=Value

			if(Value >=1)
				animate(src, color = "#fff757")
				animate(src, color = src.MobColor, time=5)

			if(src.Shock>100)
				src.Shock=100
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
		AddPoison(var/Value, var/mob/Attacker=null)
			if(src.Stasis || src.AdminOverwatchActive)
				return
			// Devil Summoner Vile racial
			if(Attacker && Attacker.demon_racial_vile_active)
				Value *= Attacker.GetDemonVileMult()

			if(Attunement=="Poison")
				Value/=2
			Value /= 1+passive_handler.Get("VenomResistance")
			Value = Value*(1-(src.Poison/glob.DEBUFF_STACK_RESISTANCE))
			src.Poison+=Value

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
			if(src.Poison<0)
				src.Poison=0
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

			if(isRace(DRAGON) && Class == "Wind") Value /= 2
			if(src.HasMythical() > 0.75) Value = Value*(1-(src.Crippled/glob.DEBUFF_STACK_RESISTANCE))
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
			src.Attracted+=Value
			src.AttractedTo=m
			if(src.Attracted>100)
				src.Attracted=100
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
			src.Anger(Enraged=1)
		AddDoom(var/Value, var/mob/Attacker=null)
			if(src.Stasis)
				return
			if(src.DownToEarth)
				return
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
				src.Health*=0.75
				src.VaizardHealth/=2
				src.Doomed=0
				src<<"<b><font color='red'>Death passes you by, and takes a piece of you along with it.</font color></b>"
				OMsg(src, "<b><font color='purple'>The bell tolls for [src],</font color></b>")
				src.DownToEarth=100
				if(src.HasGodKi()||src.HasMaouKi())
					src<<"<b><font color='red'>Death comes for all, even those with the power of Gods. Your divinity has been temporarily forfeit.</font color></b>"

globalTracker/var/DEBUFF_STACK_MAX = 100;

/mob/proc/CleanseDebuff(amt)
	var/list/debuff = list("Poison", "Burn", "Shatter", "Slow", "Shock", "Crippled", "Confused", "Stunned", "Sheared", "Attracted","Doomed");
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

			if(src.Frenzy)
				doDebuffDamage("Frenzy")

			if(src.Shatter)
				if(src.Shatter > glob.DEBUFF_STACK_MAX)
					src.Shatter = glob.DEBUFF_STACK_MAX;

				var/shatterReduction = max(0.1, (src.GetEnd(0.25)+src.GetDef(0.1))*(1+src.GetDebuffResistance()))
				if(src.Sprayed) shatterReduction *= 2;
				src.Shatter-= shatterReduction;

				if(src.Shatter<0)
					src.Shatter=0

			if(src.Slow)
				if(src.Slow > glob.DEBUFF_STACK_MAX)
					src.Slow = glob.DEBUFF_STACK_MAX;

				var/slowReduction = max(0.1, (src.GetEnd(0.25)+src.GetSpd(0.1))*(1+src.GetDebuffResistance()))
				if(src.Cooled) slowReduction *= 2;
				src.Slow -= slowReduction;

				if(src.Slow<0)
					src.Slow=0

			if(src.Shock)
				if(src.Shock > glob.DEBUFF_STACK_MAX)
					src.Shock = glob.DEBUFF_STACK_MAX;

				var/shockReduction = max(0.1, (src.GetEnd(0.25)+src.GetSpd(0.1))*(1+src.GetDebuffResistance()));
				if(src.Stabilized) shockReduction *= 2;
				src.Shock-= shockReduction;

				if(src.Shock<0)
					src.Shock=0

			if(src.Crippled)
				if(src.Crippled > glob.DEBUFF_STACK_MAX)
					src.Crippled = glob.DEBUFF_STACK_MAX;

				var/cripReduction = max(0.1, (src.GetSpd(0.25)+src.GetDef(0.1))*(1+src.GetDebuffResistance()));
				if(src.Sprayed) cripReduction *= 2;
				src.Crippled-= cripReduction;

				if(src.Crippled<0)
					src.Crippled=0

			if(src.Confused&&!src.Stunned)
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

			if(src.Attracted&&!src.Confused&&!src.Stunned)
				src.Attracted--
			if(src.Attracted<=0)
				src.Attracted=0
				src.AttractedTo=0

			if(!src.AttractedTo)
				src.Attracted=0


