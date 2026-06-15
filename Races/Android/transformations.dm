transformation
	android
		super_android
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "Agoro"
			form_aura_x = -32
			form_glow_icon = 'Ripple Radiance.dmi'
			form_icon_1_icon = 'Trucker_Hat.dmi'
			form_glow_x = -32
			form_glow_y = -32
			unlock_potential = 30
			mastery_boons(mob/user)
				var/ChipStr=user.EnhancedStrength//I mainly added these variables to make reading the code a bit easier. They aren't necessary but it makes the code look cleaner
				var/ChipEnd=user.EnhancedEndurance
				var/ChipSpd=user.EnhancedSpeed
				var/ChipFor=usr.EnhancedForce
				var/ChipOff=usr.EnhancedAggression
				var/ChipDef=usr.EnhancedReflexes
				var/asc=user.AscensionsAcquired
				var/list/chippassives = list("ManaStats" = asc,  "UnarmedDamage" = round(ChipStr/3, 1), "SwordDamage" = round(ChipStr/3, 1), "SpiritFlow" = round(ChipFor/3, 1), "Tenacity" = round(ChipEnd/3, 1),\
				"Instinct"= round(ChipOff/3, 1), "Flow" = round(ChipDef/3, 1), "Godspeed" = round(ChipSpd/3, 1))
				//Broke PureDamage scaling off 1/3rd chips of Str/Force combined to UnarmedDamage/SwordDamage and SpiritFlow Respectively. They get enough PureDamage on Ascension Anyway.
				//Changed End's PureReduction to Tenacity. They get enough PureReduction on Ascension Anyway.
				//Added ManaStats, scaling with ascension. A good android takes care of their battery.
				var/list/basepassives
				if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Ripper_Mode, user.contents))
					basepassives += list("LifeSteal" = 10 * asc)
				if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Armstrong_Augmentation, user.contents))
					basepassives += list("Harden" = asc)
				if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Ray_Gear, user.contents))
					basepassives += list("SpiritHand" = 0.25 * asc, "SpiritSword" = 0.25 * asc)
				if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Overdrive,user.contents))
					basepassives += list("MovementMastery" = 2 *asc, "ManaGeneration" = 0.5 * asc)
				if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Hilbert_Effect,user.contents))
					basepassives += list("Adaptation" = 0.25 * asc, "ZenkaiPower" = 0.1 * asc)
					//Hilbert Effect is based on Xenosaga's KOS-MOS, who has the ability to adapt to stronger opponents(T-elos) and overpower them. So I gave it these passives.
					//Feel free to change them. But Deicide didn't make sens ewhen the buff itself has it. And KOS-MOS doesn't showcase Gnosis-killing power outside of activating Hilbert-Effect until V.4
				if(user.InfinityModule)
					basepassives += list("ManaGeneration" = 2 * asc, "EnergyGeneration" = 2 * asc)
				//These passives scale with asc, much like the base buffs.
				passives=chippassives+basepassives

				//Hybrid-Chipping passives start here.
				//I may code this in a more coherent way later, for now I am listing them like this so someone checks my homework for balance.
				//This update alone should make Super Android have strong enough scaling to contend with other transformations.
				// This plays into Androids ability to customize themselves.
				//There is a 2x checker to ensure no chip for the hybrid-passives goes over 2x and still allows you to get them.
				if(ChipStr > 2)
					if(ChipEnd > 2)//Str + End = Calloused Hands
						if(ChipStr <= ChipEnd *2 && ChipEnd <= ChipStr *2)
							passives["CallousedHands"] = 0.1 * ((ChipStr + ChipEnd)/3)
					if(ChipSpd > 2) //Str + Speed = BlurringStrikes
						if(ChipStr <= ChipSpd *2 && ChipSpd <= ChipStr *2)
							passives["BlurringStrikes"] = round(1 * ((ChipStr + ChipSpd)/3), 0.1)
					if(ChipFor > 2) //Str + Force = HybridStrike
						if(ChipStr <= ChipFor *2 && ChipFor <= ChipStr *2)
							passives["HybridStrike"] = round(1 * ((ChipStr + ChipFor)/3), 0.1)
					if(ChipOff> 2) //Str + Off = HardStyle
						if(ChipStr <= ChipOff *2 && ChipOff <= ChipStr *2)
							passives["HardStyle"] = round(1 * ((ChipStr + ChipOff)/3), 0.1)
					if(ChipDef> 2) //Str + Def = CounterMaster
						if(ChipStr <= ChipDef *2 && ChipDef <= ChipStr *2)
							passives["CounterMaster"] = round(1 * ((ChipStr + ChipDef)/3), 0.1)
				if(ChipEnd > 2)
					if(ChipSpd > 2) //End + Speed = Adrenaline
						if(ChipEnd <= ChipSpd *2 && ChipSpd <= ChipEnd *2)
							passives["Adrenaline"] = round(1 * ((ChipEnd+ ChipSpd)/3), 0.1)
					if(ChipFor > 2) //End + Force = Siphon
						if(ChipEnd <= ChipFor && ChipFor <= ChipEnd *2)
							passives["Siphon"] = round(1 * ((ChipEnd + ChipFor)/3), 0.1)
					if(ChipOff > 2) //End + Off = CallousedFeet. Maybe make this End + Speed instead.
						if(ChipEnd <= ChipOff *2 && ChipOff <= ChipEnd *2)
							passives["CallousedFeet"] = round(1 * ((ChipEnd + ChipOff)/3), 0.1)
					if(ChipDef > 2) //End + Def = DeathField. On the Fense with this one.
						if(ChipEnd <= ChipDef *2 && ChipDef <= ChipEnd *2)
							passives["DeathField"] = round(1 * ((ChipEnd + ChipDef)/3), 0.1)
				if(ChipSpd > 2)
					if(ChipFor > 2) //Speed + Force = QuickCast + MovingCast (since these effect Beams Exclusively.)
						if(ChipSpd <= ChipFor *2 && ChipFor <= ChipSpd *2)
							passives["QuickCast"] = round(1 * ((ChipSpd + ChipFor)/3), 0.1)
							passives["MovingCharge"] = 1
					if(ChipOff > 2) //Speed + Off = AttackSpeed
						if(ChipSpd <= ChipOff *2 && ChipOff <= ChipSpd *2)
							passives["AttackSpeed"] = round(1 * ((ChipSpd + ChipOff)/3), 0.1)
					if(ChipDef> 2) //Speed + Def = Deflection
						if(ChipSpd <= ChipDef *2 && ChipDef <= ChipSpd *2)
							passives["Deflection"] = round(1 * ((ChipSpd + ChipDef)/3), 0.1)
				if(ChipFor > 2)
					if(ChipOff > 2) //Force + Off = SoftStyle
						if(ChipFor <= ChipOff *2 && ChipOff <= ChipFor *2)
							passives["SoftStyle"] = round(1 * ((ChipFor + ChipOff)/3), 0.1)
					if(ChipDef > 2) //Force + Def = Voidfield ON THE FENCE about this one.
						if(ChipFor <= ChipDef *2 && ChipDef <= ChipFor *2)
							passives["VoidField"] = round(1 * ((ChipFor + ChipDef)/3), 0.1)
				if(ChipOff > 2)
					if(ChipDef > 2) //Off + Def = Fluid Form + Like Water because people underestimate these stats SMILES.
						if(ChipOff <= ChipDef *2 && ChipDef <= ChipOff *2)
							passives["FluidForm"] = round(0.5 * ((ChipOff + ChipDef)/3), 0.1)
							passives["LikeWater"] = round(0.5 * ((ChipOff + ChipDef)/3), 0.1)

			transform_animation(mob/user)
				LightningStrike2(user)
				user.Quake(10)
			transform(mob/user)
				if(user.SuperAndroid)
					..()
				else return 0