proc
	ElementalCheck(var/mob/Attacker, var/mob/Defender, var/ForcedDebuff=0, var/DebuffIntensity=glob.DEBUFF_INTENSITY, list/bonusElements,damageOnly = FALSE, list/onlyTheseElements)
		var/list/attackElements = list()
		var/list/defenseElements = list()
		if(bonusElements&&bonusElements.len>0)
			attackElements |= bonusElements

		for(var/possible_extra_element in debuffVars)
			if(Attacker.passive_handler.Get(possible_extra_element))
				attackElements |= debuff2Element[possible_extra_element]
		var/Defense=0
		if(Attacker.ElementalOffense)
			attackElements |= Attacker.ElementalOffense

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
		if(Defender.ElementalDefense)
			defenseElements |= Defender.ElementalDefense

		if(armr && armr.Element)
			defenseElements |= armr.Element

		if(attackElements["Ultima"])
			ForcedDebuff+=1
		var/DamageMod=0
		for(var/element in attackElements)
			var/DebuffRate=GetDebuffRate(element, Defense, ForcedDebuff)
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
/*
			if(!damageOnly&&!Defender.HasDebuffResistance())
				switch(element)
					if("Fire")
						if(!Defender.Burn)
							OMsg(Attacker, messages[element])
					if("Water")
						if(!Defender.Slow)
							OMsg(Attacker, messages[element])
					if("Earth")
						if(!Defender.Shatter)
							OMsg(Attacker, messages[element])
					if("Wind")
						if(!Defender.Shock)
							OMsg(Attacker, messages[element])
					if("Poison")
						if(!Defender.Poison)
							OMsg(Attacker, messages[element])
					if("HellFire")
						if(!Defender.Poison)
							OMsg(Attacker, messages[element])
						if(!Defender.Burn)
							OMsg(Attacker, messages[element])
*/
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
						DamageMod-=1//Reduced damage
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
						Defender.AddPoison(2*DebuffIntensity*glob.POISON_INTENSITY, Attacker)
						Defender.AddBurn(3*DebuffIntensity*glob.BURN_INTENSITY, Attacker)
						Defender.AddShearing(4*DebuffIntensity, Attacker)
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
					if("Rain")
						Defender.AddSlow(4*DebuffIntensity*glob.SLOW_INTENSITY, Attacker)
						Defender.AddShock(4*DebuffIntensity*glob.SHOCK_INTENSITY, Attacker)
					if("Poison")
						if(!Defender.HasVenomImmune()&&Defense!="Poison")
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

	GetDebuffRate(var/A, var/D, var/Forced=0)
		var/Return=0
		if(Forced)
			Return=100
			return Return
		switch(A)
			if("Rain")
				Return=30

			if("HellFire")
				Return=50
				switch(D)
					if("Mirror")
						Return-=20
					if("Fire")
						Return+=20
					if("Water")
						Return-=10
					if("Earth")
						Return-=10
					if("Wind")//Super effective
						Return+=20
					if("Ultima")
						Return+=10

			if("Fire")//Chance of burn
				Return=30//Chance of burn on every hit.
				switch(D)
					if("Mirror")
						Return-=20
					if("Fire")
						Return+=10
					if("Water")
						Return-=20
					if("Earth")
						Return-=10
					if("Wind")//Super effective
						Return+=20
					if("Ultima")
						Return+=50
			if("Water")//Chance of freeze
				Return=30
				switch(D)
					if("Mirror")
						Return-=20
					if("Fire")//Super Effective
						Return+=20
					if("Water")
						Return+=10
					if("Earth")
						Return-=20
					if("Wind")
						Return-=10
					if("Ultima")
						Return+=50
			if("Earth")//Chance of break
				Return=30
				switch(D)
					if("Mirror")
						Return-=20
					if("Fire")
						Return-=10
					if("Water")//Super Effective
						Return+=20
					if("Earth")
						Return+=10
					if("Wind")
						Return-=20
					if("Ultima")
						Return+=50
			if("Wind")//Chance of off/def reduction
				Return=30
				switch(D)
					if("Mirror")
						Return-=20
					if("Fire")
						Return-=20
					if("Water")
						Return-=10
					if("Earth")//Super Effective
						Return+=20
					if("Wind")
						Return+=10
					if("Ultima")
						Return+=50
		if(A=="Poison")//Chance to poison.
			Return=30
			switch(D)
				if("Mirror")
					Return-=20
				if("Ultima")
					Return+=40
		if(A=="Chaos")//Chance of EVERYTHING GOES TO HELL.
			Return=30
			switch(D)
				if("Mirror")
					Return-=20
				if("Ultima")
					Return+=40
		if(A=="Ultima")//Chance of EVERYTHING GOES TO HELL.
			Return=100
			switch(D)
				if("Mirror")
					Return-=20
		return Return
mob
	proc
		AddBurn(var/Value, var/mob/Attacker=null)
			if(src.Stasis)
				return
			if(src.ElementalDefense=="Wind")
				Value*=1.5//Super Effective
			if(Attacker && (Attacker == src ? !src.passive_handler.Get("BurningShot") : 1))
				if(Attacker.Attunement=="Fire")
					Value*=1.5
				else if(Attacker.Attunement=="HellFire")
					Value*=glob.HELLFIRE_VALUE_MOD
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
				if(Attacker.passive_handler["Combustion"] && Burn >= Attacker.passive_handler["Combustion"])
					implodeDebuff(Attacker.passive_handler["Combustion"], "Burn")


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
			if(src.Stasis)
				return
			if(src.ElementalDefense=="Fire")
				Value*=1.5//Super effective
			if(Attacker)
				if(Attacker.Attunement=="Water")
					Value*=1.5
			if(src.Attunement=="Fire")
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
			if(src.Stasis)
				return
			if(src.ElementalDefense=="Water")
				Value*=1.5
			if(Attacker)
				if(Attacker.Attunement=="Earth")
					Value*=1.5
			if(src.Attunement=="Water")
				Value*=1.5
			if(src.Infusion)
				if(!src.InfusionElement)
					src.InfusionElement="Earth"
				Value/=2

			if(Attunement=="Earth")
				Value/=2

			if(src.HasDebuffResistance())
				Value/=1+src.GetDebuffResistance()
			Value = Value*(1-(src.Shatter/glob.DEBUFF_STACK_RESISTANCE))
			src.Shatter+=Value

			if(Value >=1)
				src.color = "#8f7946"
				animate(src, color = src.MobColor, time=5)


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
			if(src.Stasis)
				return
			if(src.ElementalDefense=="Earth")
				Value*=1.5
			if(Attacker)
				if(Attacker.Attunement=="Wind")
					Value*=1.5
			if(src.Attunement=="Earth")
				Value*=1.5
			if(src.Infusion)
				if(!src.InfusionElement)
					src.InfusionElement="Wind"
				Value/=2
			if(Attunement=="Wind")
				Value/=2

			if(src.HasDebuffResistance())
				Value/=1+src.GetDebuffResistance()
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
			if(src.Stasis)
				return

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
			if(src.Stasis)
				return
			Value = Value*(1-(src.Sheared/glob.DEBUFF_STACK_RESISTANCE))
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
			// if(src.isRace(MAJIN))
			// 	if(!src.AscensionsAcquired||src.AscensionsAcquired>=3)
			// 		Value=0
			if(isRace(DRAGON) && Class == "Wind")
				Value /= 2
			if(src.HasMythical() > 0.75)
				Value = Value*(1-(src.Crippled/glob.DEBUFF_STACK_RESISTANCE))
				src.Crippled+=Value
			if(src.Crippled>100)
				src.Crippled=100
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

mob
	proc
		Debuffs()
			if(src.Stasis)
				return
			if(src.Poison)
				doDebuffDamage("Poison")
			if(src.Burn)
				doDebuffDamage("Burn")

			if(src.Shatter)
				if(src.Sprayed)
					src.Shatter-=(src.GetEnd(0.25)+src.GetDef(0.1))*2*(1+src.GetDebuffResistance())
				else
					src.Shatter-=(src.GetEnd(0.25)+src.GetDef(0.1))*(1+src.GetDebuffResistance())
				if(src.Shatter<=0)
					src.Shatter=0

			if(src.Slow)
				if(src.Cooled)
					src.Slow-=(src.GetEnd(0.25)+src.GetSpd(0.1))*2*(1+src.GetDebuffResistance())
				else
					src.Slow-=(src.GetEnd(0.25)+src.GetSpd(0.1))*(1+src.GetDebuffResistance())
				if(src.Slow<=0)
					src.Slow=0

			if(src.Shock)
				if(src.Stabilized)
					src.Shock-=(src.GetEnd(0.25)+src.GetSpd(0.1))*2*(1+src.GetDebuffResistance())
				else
					src.Shock-=(src.GetEnd(0.25)+src.GetSpd(0.1))*(1+src.GetDebuffResistance())
				if(src.Shock<=0)
					src.Shock=0

			if(src.Crippled)
				if(src.Sprayed)
					src.Crippled-=(src.GetSpd(0.25)+src.GetDef(0.1))*2*(1+src.GetDebuffResistance())
				else
					src.Crippled-=(src.GetSpd(0.25)+src.GetDef(0.1))*(1+src.GetDebuffResistance())
				if(src.Crippled<=0)
					src.Crippled=0

			if(src.Confused&&!src.Stunned)
				if(src.Stabilized)
					src.Confused-=5
				else
					src.Confused-=clamp(1 + (src.GetSpd(0.25)), 1, 3)
				if(src.Confused<=0)
					src.Confused=0

			if(src.Sheared)
				if(src.Sprayed)
					if(src.icon_state=="Meditate")
						src.Sheared-=4
					else
						src.Sheared-=0.5
				else
					if(src.icon_state=="Meditate")
						src.Sheared-=2
					else
						src.Sheared-=0.25
			if(src.Sheared<=0)
				src.Sheared=0

			if(src.Attracted&&!src.Confused&&!src.Stunned)
				src.Attracted--
				if(src.Attracted<=0)
					src.Attracted=0
					src.AttractedTo=0

			if(!src.AttractedTo)
				if(src.Attracted>0)
					src.Attracted=0


