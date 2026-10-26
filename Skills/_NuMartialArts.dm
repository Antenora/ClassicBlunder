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
				CantTrans = FALSE

//Martial
			NuStyle
				var/tensionStorage = 0
				var/last_storage = 0
				var/tmp/triggerTension
				var/list/stage_passives
				var/list/stage_flags
				var/SagaStyle = 0
				var/tmp/applied_stage = 0
				proc/StyleStage(mob/p)
					return 1
				proc/StageNextPotential(mob/p)
					return null
				proc/turnOff(mob/p)
					tensionStorage = p.Tension
					last_storage = world.time
					Trigger(p, 1)
					cooldown_remaining = 0
				proc/giveBackTension(mob/p)
					if(last_storage + 1200 > world.time) // this should never happen ?
						// we can give it back
						if(tensionStorage)
							p.Tension = tensionStorage
							tensionStorage = 0
					else
						tensionStorage = 0
				Mastery=0
				Copyable=0
				SkillCost=20
				StyleSlot=1
				var/list/UnlockedStances=list("Cancel")
				UnarmedStyle
					NoSword=1
					NoStaff=1

					//Unarmed Saga Styles
					Ansatsuken_Style
						SagaStyle = 1
						Copyable=0
						SagaSignature=1
						StyleActive="Ansatsuken"
						passives = list("Pursuer" = 1, "HardStyle" = 1)
						ManaCost=100
						Mastery=4
						AllOutAttack=1
						adjust(mob/p)
							passives["BladeFisting"] = (p.SagaLevel >= 6) ? 1 : 0
						verb/Ansatsuken_Style()
							set hidden=1
							if(!usr.BuffOn(src)) adjust(usr)
							src.Trigger(usr)
					//numbers past t1 aren't finalized, i'm just tossing them in here so i won't forget to change them later
					Strong_Fist //t1
						SagaStyle = 1
						Copyable=0
						SagaSignature=1
						StyleActive="Strong Fist"
						passives = list("Pursuer" = 1, "TechniqueMastery" = 1, "Flicker"=1)
						AllOutAttack=1
						verb/Strong_Fist_Style()
							set hidden=1
							src.Trigger(usr)
					Stronger_Fist //t3?
						SagaStyle = 1
						Copyable=0
						SagaSignature=1
						StyleActive="Stronger Fist"
						passives = list("Pursuer" = 2, "TechniqueMastery" = 2, "Flicker"=2,"UnarmedDamage"=1)
						AllOutAttack=1
						adjust(mob/p)
							passives = list("Pursuer" = 2, "TechniqueMastery" = 2, "Flicker"=2,"UnarmedDamage"=1)
						verb/Stronger_Fist()
							set hidden=1
							adjust(usr)
							src.Trigger(usr)
					Strongest_Fist //t5????
						SagaStyle = 1
						Copyable=0
						SagaSignature=1
						StyleActive="Strongest Fist"
						passives = list("Pursuer" = 4, "TechniqueMastery" = 2.5, "Flicker"=4,"UnarmedDamage"=2)
						AllOutAttack=1
						adjust(mob/p)
							passives = list("Pursuer" = 4, "TechniqueMastery" = 2.5, "Flicker"=4,"UnarmedDamage"=2)
						verb/Strongest_Fist()
							set hidden=1
							adjust(usr)
							src.Trigger(usr)


				SwordStyle
					NeedsSword=1
					NoStaff=1

//Saga Sword Styles

	//Keyblade


				EnergyStyle

				GunStyle

mob/proc/StyleStageRefresh()
	return
