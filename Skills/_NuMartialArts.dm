obj
	Skills
		Buffs
			Read(F)
				..()
				// death becomes u
				// if(!(altered || Using))
				// 	var/path = "[type]"
				// 	var/obj/Skills/Buffs/b = new path
				// 	if(isnull(passives))
				// 		world.log << "Hey. [src] didnt get passives."
				// 		passives = list()
				// 	for(var/x in b.passives)
				// 		passives["[x]"] = b.passives[x]
			var
				CorruptionGain
				ResourceCost
				ResourceThreshold
				AngerPoint // set an anger point
				StyleStr=1
				StyleFor=1
				StyleEnd=1
				StyleSpd=1
				StyleOff=1
				StyleDef=1
				Finisher//a text path that links to a queue attack which loads an autonomous buff
				CantTrans = FALSE

//Martial
			NuStyle
				var/tensionStorage = 0
				var/last_storage = 0
				var/tmp/triggerTension 
				proc/turnOff(mob/p)
					tensionStorage = p.Tension
					last_storage = world.time
					Trigger(usr, 1)
					cooldown_remaining = 0
				proc/giveBackTension(mob/p)
					if(last_storage + 1200 > world.time) // this should never happen ?
						// we can give it back
						if(tensionStorage)
							p.Tension = tensionStorage
							tensionStorage = 0
					else
						tensionStorage = 0
				proc/initUnlock()
					// hehe
					var/obj/Skills/Buffs/NuStyle/eh = new type
					StyleComboUnlock = eh.StyleComboUnlock.Copy()
					del eh
					// i think unlocky enough i may have 2 instead make a new one, transfer it and then blah blah
				skillDescription()
					..()
					if(SignatureTechnique)
						description += "Signature Tier [SignatureTechnique]\n"
						for(var/x in StyleComboUnlock)
							var/splitup = splittext(x, "/")
							var/splitupEnd = splittext(StyleComboUnlock[x], "/")
							var/finalStringX = replacetext(splitup[length(splitup)], "_", " ")
							var/finalStringEnd = replacetext(splitupEnd[length(splitupEnd)], "_", " ")
							description += "This Style + [finalStringX] = [finalStringEnd]\n"
					if(StyleStr)
						if(StyleStr  < 1 &&  StyleStr  > 0)
							description += "Strength Reduction: [1-StyleStr]\n"
						else
							if(StyleStr > 1)
								description += "Strength Add: [StyleStr-1]\n"
					if(StyleFor)
						if(StyleFor  < 1 &&  StyleFor  > 0)
							description += "Force Reduction: [1-StyleFor]\n"
						else
							if(StyleFor > 1)
								description += "Force Add: [StyleFor-1]\n"
					if(StyleEnd)
						if(StyleEnd  < 1 &&  StyleEnd  > 0)
							description += "Endurance Reduction: [1-StyleEnd]\n"
						else
							if(StyleEnd > 1)
								description += "Endurance Add: [StyleEnd-1]\n"
					if(StyleSpd)
						if(StyleSpd  < 1 &&  StyleSpd  > 0)
							description += "Speed Reduction: [1-StyleSpd]\n"
						else
							if(StyleSpd > 1)
								description += "Speed Add: [StyleSpd-1]\n"
					if(StyleOff)
						if(StyleOff  < 1 &&  StyleOff  > 0)
							description += "Offense Reduction: [1-StyleOff]\n"
						else
							if(StyleOff > 1)
								description += "Offense Add: [StyleOff-1]\n"
					if(StyleDef)
						if(StyleDef  < 1 &&  StyleDef  > 0)
							description += "Defense Reduction: [1-StyleDef]\n"
						else
							if(StyleDef > 1)
								description += "Defense Add: [StyleDef-1]\n"

				var/StylePrimeUnlock //obtained from getting mastery 4; can be a list
				var/list/StyleComboUnlock=list()//obtained from getting mastery 3 in 2 styles; MUST be a list
				Mastery=0
				Copyable=0
				SkillCost=20
				StyleSlot=1
				var/list/UnlockedStances=list("Cancel")
				UnarmedStyle
					NoSword=1
					NoStaff=1

					//Signature Styles T1
						
					Heavenly_Demon_T3
						name = "Heavenly Demon's Chaotic Way of Shattered Realms"
						StyleActive = "Heavenly Demon's Chaotic Way of Shattered Realms"
						SignatureTechnique=3
						Copyable=0
						passives = list("Conductor" = 90, "Antsy" = 10, "CounterMaster" = 5, "SwordPunching" = 1, "NeedsSword" = 0, "NoSword" = 1)
						NeedsSword=0
						NoSword=1
						SwordPunching=1
						StyleStr=1
						StyleEnd=1
						StyleOff=1
						StyleDef=1
						StyleFor=1
						Finisher="/obj/Skills/Queue/Finisher/Cycle_of_Samsara"

					Drunken_Fist_Style
						SignatureTechnique=2
						Copyable=0
						StyleEnd=1.3
						StyleDef=1.3
						passives = list("CounterMaster" = 3, "SoftStyle" = 2, "FluidForm" = 1)
						CounterMaster=2
						SoftStyle=2
						FluidForm=1
						StyleActive="Drunken Fist"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Golden_Kirin_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/North_Star_Style")
						Finisher="/obj/Skills/Queue/Finisher/Tetsuzankou"
						verb/Drunken_Master_Style()
							set name="Drunken Fist Style"
							set hidden=1
							src.Trigger(usr)
					
					//Unarmed Saga Styles
					Ansatsuken_Style
						Copyable=0
						SagaSignature=1
						StyleStr=1.25
						StyleEnd=1.25
						StyleFor=1.25
						StyleSpd=1.25
						StyleActive="Ansatsuken"
						passives = list("Pursuer" = 1, "HardStyle" = 1)
						ManaCost=100
						Mastery=4
						AllOutAttack=1
						verb/Ansatsuken_Style()
							set hidden=1
							src.Trigger(usr)


				SwordStyle
					NeedsSword=1
					NoStaff=1

//Signature Style T1
					Arcane_Bladework_Style
						SignatureTechnique=2
						Copyable=0
						StyleStr=1.25
						StyleFor=1.25
						StyleSpd=1.5
						passives = list("DoubleStrike" = 1, "ArcaneBladework" = 1, "TechniqueMastery" = 3, "SpiritSword" = 0.75, "WeaponBreaker" = 2)
						DoubleStrike=1
						NoStaff=0
						ArcaneBladework=1
						TechniqueMastery=5
						SpiritSword=0.75
						WeaponBreaker=2
						StyleActive="Arcane Bladework"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Battle_Mage_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/South_Star_Style")
						Finisher="/obj/Skills/Queue/Finisher/Sacred_Edge"
						verb/Arcane_Bladework_Style()
							set hidden=1
							src.Trigger(usr)
					Blade_Singing_Style
						SignatureTechnique=2
						Copyable=0
						NeedsSword=0
						passives = list("SwordPunching" = 1, "WeaponBreaker" = 3, "Pursuer" = 2, "Flicker" = 2)
						SwordPunching=1
						StyleSpd=2
						StyleOff=1.25
						StyleStr=1.25
						WeaponBreaker=3
						Pursuer=2
						Flicker=2
						StyleActive="Blade Singing"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/FreeStyle/Shunko_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Rhythm_of_War_Style")
						Finisher="/obj/Skills/Queue/Finisher/Centifoila"
						verb/Blade_Singing_Style()
							set hidden=1
							src.Trigger(usr)
					Battle_Mage_Style
						SignatureTechnique=2
						Copyable=0
						NoSword=1
						NeedsSword=0
						NoStaff=0
						NeedsStaff=1
						passives = list("Flicker" = 2, "Pursuer" = 2, "TechniqueMastery" = 3, "MartialMagic" = 1)
						Flicker=2
						Pursuer=2
						StyleStr=1.25
						StyleFor=1.25
						StyleSpd=1.5
						MartialMagic=1
						//Staff-as-sword
						//Refinement
						StyleActive="Battle Mage"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Arcane_Bladework_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/South_Star_Style")
						Finisher="/obj/Skills/Queue/Finisher/Absolute_Truth"
						verb/Battle_Mage_Style()
							set hidden=1
							src.Trigger(usr)

//Signature Style T3
					Five_Rings_Style
						SignatureTechnique=3
						NeedsSecondSword=1
						NeedsThirdSword=1
						Copyable=0
						StyleStr=1.5
						StyleSpd=1.5
						passives = list("Shearing" = 5, "Crippling" = 5, "DoubleStrike" = 2, "TripleStrike" = 2, "SweepingStrike" = 1, "SlayerMod" = 2.5, "NeedsSecondSword" = 1, "NeedsThirdSword" = 1)
						Shearing=5
						Crippling=5
						NoForcedWhiff=1
						DoubleStrike=2
						TripleStrike=2
						SweepingStrike=1
						SlayerMod=2.5
						StyleActive="Five Rings"
						Finisher="/obj/Skills/Queue/Finisher/Ashura_Kai"
						verb/Toggle_Sword_Count()
							set category="Other"
							if(src.NeedsSecondSword&&src.NeedsThirdSword)
								src.NeedsSecondSword=1
								src.NeedsThirdSword=0
								usr << "You decide to wield <font color='yellow'>two</font color> swords."
							else if(src.NeedsSecondSword&&!src.NeedsThirdSword)
								src.NeedsSecondSword=0
								usr << "You decide to wield a <font color='red'>single</font color> sword."
							else
								src.NeedsSecondSword=1
								src.NeedsThirdSword=1
								usr << "You decide to wield <font color='green'>three</font color> swords."
						verb/Five_Rings_Style()
							set hidden=1
							src.Trigger(usr)
					South_Star_Style
						SignatureTechnique=3
						Copyable=0
						NeedsSword=0
						NoSword=1
						StyleStr=1.4
						StyleFor=1.4
						StyleSpd=1.2
						passives = list("Flicker" = 3, "Pursuer" = 3, "MovementMastery" = 8, "TechniqueMastery" = 4, "MartialMagic" = 1, "HybridStrike" = 1, "KiBlade" = 1)
						Flicker=3
						Pursuer=3
						MovementMastery=8
						TechniqueMastery=10
						MartialMagic=1
						DoubleStrike=1
						TripleStrike=1
						HybridStrike=1
						NoSword=1
						NoStaff=1
						KiBlade=1
						ElementalClass="Fire"
						StyleActive="South Star"
						Finisher="/obj/Skills/Queue/Finisher/Skyward_Strike"
						verb/South_Star_Style()
							set hidden=1
							src.Trigger(usr)
//Saga Sword Styles

	//Hiten Mitsurugi
					Hiten_Mitsurugi_Ryuu
						Copyable=0
						SagaSignature=1
						StyleStr=1 // ???
						StyleSpd=1
						StyleActive="Hiten Mitsurugi"
						passives = list("Godspeed" = 1, "BlurringStrikes" = 0.25, "Flicker" = 1)
						Flicker=1
						Mastery=4
						ClassNeeded = list("Light", "Wooden")
						Finisher="/obj/Skills/Queue/Finisher/Flash_Strike"
						adjust(mob/p)
							StyleStr = 1.1 + (p.SagaLevel * 0.05)
							StyleSpd = 1.1 + (p.SagaLevel * 0.1)
							StyleOff = 1.1 + (p.SagaLevel * 0.05)
						verb/Hiten_Mitsurugi_Ryuu()
							set hidden=1
							src.Trigger(usr)

	//Keyblade
					Command
						Copyable=0
						FlashChange=1
						Mastery=4
						Speed_Rave_Style
							StyleStr = 1.5
							StyleSpd = 1.5
							StyleOff = 1.1
							StyleDef = 1.1
							StyleActive="Speed Rave"
							passives = list("BlurringStrikes" = 1, "AfterImages" = 1, "Steady" = 1)
							Finisher="/obj/Skills/Queue/Finisher/Fever_Pitch"
							adjust(mob/p)
								StyleStr = 1.2 + (0.05 * p.SagaLevel)
								StyleSpd = 1.2 + (0.05 * p.SagaLevel)
								StyleOff = 1 + (0.05 * p.SagaLevel)
								StyleDef = 1 + (0.05 * p.SagaLevel)
							verb/Speed_Rave_Style()
								set hidden=1
								src.Trigger(usr)
						Critical_Impact_Style
							StyleStr = 1
							StyleEnd = 1
							StyleOff = 1
							StyleActive="Critical Impact"
							passives = list("CriticalChance" = 15, "CriticalDamage" = 0.1, "HeavyHitter" = 1, "CallousedHands" = 0.15)
							Finisher="/obj/Skills/Queue/Finisher/Fatal_Mode"
							adjust(mob/p)
								StyleStr = 1.2 + (0.1 * p.SagaLevel)
								StyleEnd = 1.2 + (0.1 * p.SagaLevel)
								StyleOff = 1 + (0.05 * p.SagaLevel)
							verb/Critical_Impact_Style()
								set hidden=1
								src.Trigger(usr)
						Spell_Weaver_Style
							StyleFor = 1.5
							StyleSpd = 1.5
							StyleDef = 1.1
							StyleActive="Spell Weaver"
							passives = list("SpiritFlow" = 0.15, "QuickCast" = 1, "MovingCharge" = 1, "Siphon" = 2)
							Finisher="/obj/Skills/Queue/Finisher/Magic_Wish"
							adjust(mob/p)
								StyleFor = 1.1 + (0.1 * p.SagaLevel)
								StyleSpd = 1.2 + (0.05 * p.SagaLevel)
								StyleDef = 1 + (0.05 * p.SagaLevel)
							verb/Spell_Weaver_Style()
								set hidden=1
								src.Trigger(usr)
						Firestorm_Style
							StyleStr=1
							StyleFor=1
							ElementalClass="Fire"
							StyleActive="Firestorm"
							ElementalOffense="Fire"
							ElementalDefense="Fire"
							passives = list("Burning" = 1)
							Burning=1
							Finisher="/obj/Skills/Queue/Finisher/Fire_Storm"
							adjust(mob/p)
								StyleFor = 1 + (0.1 * p.SagaLevel)
								StyleStr = 1 + (0.1 * p.SagaLevel)
							verb/Firestorm_Style()
								set hidden=1
								src.Trigger(usr)
						Diamond_Dust_Style
							StyleEnd=1
							StyleFor=1
							ElementalClass="Water"
							StyleActive="Diamond Dust"
							ElementalOffense="Water"
							ElementalDefense="Water"
							passives = list("Chilling" = 1)
							Chilling=1
							Finisher="/obj/Skills/Queue/Finisher/Diamond_Dust"
							adjust(mob/p)
								StyleFor = 1 + (0.1 * p.SagaLevel)
								StyleEnd = 1 + (0.1 * p.SagaLevel)
							verb/Diamond_Dust_Style()
								set hidden=1
								src.Trigger(usr)
						Thunderbolt_Style
							StyleEnd=1.5
							StyleSpd=1.5
							ElementalClass="Wind"
							StyleActive="Thunderbolt"
							ElementalOffense="Wind"
							ElementalDefense="Wind"
							passives = list("Shocking" = 1)
							Shocking=1
							Finisher="/obj/Skills/Queue/Finisher/Thunderbolt"
							adjust(mob/p)
								StyleSpd = 1 + (0.1 * p.SagaLevel)
								StyleEnd = 1 + (0.1 * p.SagaLevel)
							verb/Thunderbolt_Style()
								set hidden=1
								src.Trigger(usr)
						Wing_Blade_Style
							StyleStr=1.25
							StyleFor=1.25
							StyleSpd=1.5
							StyleActive="Wing Blade"
							passives = list("SweepingStrike" = 1, "DoubleStrike" = 1, "BlurringStrikes" = 1)
							SweepingStrike=1
							SwordIcon='BLANK.dmi'
							SwordIconSecond='BLANK.dmi'
							IconLock='WingBlade.dmi'
							LockX=-16
							LockY=-16
							IconLockBlend=2
							IconApart=1
							Finisher="/obj/Skills/Queue/Finisher/Wing_Blade"
							adjust(mob/p)
								StyleSpd = 1 + (0.05 * p.SagaLevel)
								StyleEnd = 1 + (0.05 * p.SagaLevel)
								StyleSpd = 1 + (0.1 * p.SagaLevel)
							verb/Wing_Blade_Style()
								set hidden=1
								src.Trigger(usr)
						Cyclone_Style
							StyleStr=1.25
							StyleFor=1.25
							StyleSpd=1.5
							ElementalClass="Wind"
							StyleActive="Cyclone"
							ElementalOffense="Wind"
							ElementalDefense="Wind"
							passives = list( "TechniqueMastery" = 1.5, "BlurringStrikes" = 1, "Paralyzing" = 1, "SpiritFlow" = 0.25)
							Shocking=1
							Paralyzing=0.2
							Finisher="/obj/Skills/Queue/Finisher/Cyclone"
							adjust(mob/p)
								StyleStr = 1 + (0.05 * p.SagaLevel)
								StyleFor = 1 + (0.05 * p.SagaLevel)
								StyleSpd = 1 + (0.1 * p.SagaLevel)
							verb/Cyclone_Style()
								set hidden=1
								src.Trigger(usr)
						Rock_Breaker_Style
							StyleDef=1.25
							StyleStr=1.25
							StyleEnd=1.5
							ElementalClass="Earth"
							StyleActive="Rock Breaker"
							ElementalOffense="Earth"
							ElementalDefense="Earth"
							passives = list("Hardening" = 1, "Crushing" = 1, "ArmorPeeling" = 1, "CallousedHands" = 0.15)
							Crushing=1
							Finisher="/obj/Skills/Queue/Finisher/Rock_Breaker"
							adjust(mob/p)
								StyleDef = 1 + (0.05 * p.SagaLevel)
								StyleStr = 1 + (0.05 * p.SagaLevel)
								StyleEnd = 1 + (0.1 * p.SagaLevel)
							verb/Rock_Breaker_Style()
								set hidden=1
								src.Trigger(usr)
						Dark_Impulse_Style
							StyleStr=1.5
							StyleEnd=1.5
							IconLock='DarknessGlow.dmi'
							IconUnder=1
							passives = list("Momentum" = 1, "CallousedHands " = 0.3)
							LockX=-32
							LockY=-32
							StyleActive="Dark Impulse"
							ElementalOffense = "Dark"
							ElementalDefense = "Dark"
							Finisher="/obj/Skills/Queue/Finisher/Dark_Impulse"
							adjust(mob/p)
								StyleStr = 1 + (0.1 * p.SagaLevel)
								StyleEnd = 1 + (0.1 * p.SagaLevel)
							verb/Dark_Impulse_Style()
								set hidden=1
								src.Trigger(usr)
						Ghost_Drive_Style
							StyleOff=1.25
							StyleDef=1.25
							StyleFor=1.5
							StyleActive="Ghost Drive"
							passives = list("Likewater" = 1, "Godspeed" = 1, "MovingCharge" = 1, "QuickCast" = 1, "SpiritFlow" = 0.5)
							Afterimages=1
							Finisher="/obj/Skills/Queue/Finisher/Ghost_Drive"
							adjust(mob/p)
								StyleOff = 1 + (0.05 * p.SagaLevel)
								StyleDef = 1 + (0.05 * p.SagaLevel)
								StyleFor = 1 + (0.1 * p.SagaLevel)
							verb/Ghost_Drive_Style()
								set hidden=1
								src.Trigger(usr)
						Blade_Charge_Style
							StyleStr = 1.25
							StyleOff = 1.25
							StyleFor = 1.5
							StyleActive="Blade Charge"
							passives = list("Extend" = 1, "SpiritSword" = 0.75, "SpiritHand" = 1)
							Extend=1
							Finisher="/obj/Skills/Queue/Finisher/Blade_Charge"
							adjust(mob/p)
								StyleStr = 1 + (0.05 * p.SagaLevel)
								StyleOff = 1 + (0.05 * p.SagaLevel)
								StyleFor = 1 + (0.1 * p.SagaLevel)
							verb/Blade_Charge_Style()
								set hidden=1
								src.Trigger(usr)

				FreeStyle
					NeedsSword=0
					NoSword=0
					NoStaff=0
				// WitchCraft
					Witch_Style
						StyleFor = 1.5
						StyleSpd = 1.1
						ElementalClass= "Water"
						StyleActive = "Witch"
						ElementalOffense = "Felfire"
						Finisher = "/obj/Skills/Queue/Finisher/Sundered_Sky"
						passives = list("QuickCast" = 1, "Flow" = 0.5, "MartialMagic" = 1)
						verb/Witch_Style()
							set hidden=1
							src.Trigger(usr)