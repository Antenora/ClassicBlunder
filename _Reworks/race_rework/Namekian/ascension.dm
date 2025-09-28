ascension


	namekian
		one
			unlock_potential	=	ASCENSION_ONE_POTENTIAL
			onAscension(mob/owner)
				if(!applied)
					switch(owner.Class)
						if("Heretic")
							//power = 0.75
							strength = 0.5
							speed = 0.25
							anger = 0.15 // 1.4
							passives = list("Hellrisen" = 0.25, "Wrathful Tenacity" = 0.2, "AngerAdaptiveForce" = 0.25)
						if("Dragon")  /// after the merge, unmerged Dragon and Warrior will also receive some scaling power. Levi added it in for Gaja's in his push
							///power = 0.75
							passives = list("SpiritFlow" = 0.25)
							force = 0.5
							imaginationAdd = 0.5
							recovery = 0.25
							skills = list(/obj/Skills/Utility/Send_Energy)
						if("Warrior")
							//power = 1
							passives = list("Duelist" = 0.5)
							strength = 0.25
							endurance = 0.25
					if(owner.Class=="Dragon")
						for(var/obj/Skills/Utility/Send_Energy/se in owner.contents)
							se.SagaSignature=1
							se.SignatureTechnique=0
				..()
		two
			unlock_potential	=	ASCENSION_TWO_POTENTIAL
			onAscension(mob/owner)
				switch(owner.Class)
					if("Heretic")
						//power = 1
						offense = 0.25
						strength = 0.25
						endurance = 0.25
						anger = 0.1 // 1.5
						skills = list(/obj/Skills/Buffs/SpecialBuffs/Daimou_Form)
						passives = list("Hellrisen" = 0.25, "Wrathful Tenacity" = 0.1, "DemonicDurability" = 0.5)
					if("Dragon")
						//power = 1
						passives =list("SpiritHand" = 0.5, "SpiritFlow" = 0.25)
						force = 0.25
						offense = 0.25
						imaginationAdd = 0.25
						skills = list(/obj/Skills/Utility/Heal)

					if("Warrior")
						//power = 1.5
						passives = list("Duelist" = 1)
						intimidation = 10
						strength = 0.25
						endurance = 0.25
						skills = list(/obj/Skills/Buffs/SpecialBuffs/Giant_Form)
				..()
		three
			unlock_potential	=	ASCENSION_THREE_POTENTIAL
			onAscension(mob/owner)
				switch(owner.Class) // super namek era
					if("Demon")
						// power = 1.5
						speed = 0.25
						anger = 0.1 // 1.6
					if("Dragon")
						//power = 1.5
						force= 0.25
						endurance = 0.5
						passives = list("Spirit Flow" = 0.25, "HybridStrike" = 0.25)
						recovery = 0.25
					if("Warrior")
						//power = 2
						offense = 0.5
						passives = list ("Duelist" = 2, "Extend" = 1)
						strength = 0.5
						recovery = 0.5
						endurance = 0.5
				..()
		four
			unlock_potential =  ASCENSION_FOUR_POTENTIAL
			onAscension(mob/owner)
				switch(owner.Class)
					if("Demon")
						//power = 2
						intimidation = 20
						passives = list("SlayerMod" = 1.5, "MovementMastery" = 4)
					if("Warrior")
						//power = 3
						passives = list("Duelist" = 2.5, "Extend" = 2)
						strength = 0.75
						endurance = 0.25
						recovery = 0.5
						intimidation = 30
					if("Dragon")
						//power = 2.5
						force = 0.75
						recovery = 0.5
						passives = list("HybridStrike" = 0.25)
				..()
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			onAscension(mob/owner)
				switch(owner.Class) ///orange namek should be unlocked here
					if("Demon")
						//power = 3
						speed = 0.5
						anger = 0.2 // 2
						intimidation = 50
					if("Warrior")
						//power = 4
						strength = 1
						endurance = 1
						intimidation = 70
					if("Dragon")
						//power = 3.5
						force = 1
						recovery = 1
						passives = list("SoulFire" = 1, "CyberMenace" = 1, "HybridStrike" = 0.5)
				..()