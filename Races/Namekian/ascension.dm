ascension
	namekian
		one
			unlock_potential	=	ASCENSION_ONE_POTENTIAL
			onAscension(mob/owner)
				if(!applied)
					switch(owner.Class)
						if("Demon")
							strength = 0.55
							force = 0.55
							endurance = 0.45
							speed = 0.25
							anger = 0.25
							passives = list(   "TechniqueMastery" = 0.5)
						if("Dragon")
							passives = list( "QuickCast"=0.5)
							force = 0.5
							imaginationAdd = 0.5
							recovery = 0.25
							skills = list(/obj/Skills/Utility/Send_Energy)
						if("Warrior")
							//power = 1
							passives = list("TechniqueMastery" = 0.25, "Tenacity" = 0.5)
							strength = 0.35
							endurance = 0.35
					if(owner.Class=="Dragon")
						for(var/obj/Skills/Utility/Send_Energy/se in owner.contents)
							se.SagaSignature=1
							se.SignatureTechnique=0
				..()
		two
			unlock_potential	=	ASCENSION_TWO_POTENTIAL
			onAscension(mob/owner)
				switch(owner.Class)
					if("Demon")
						strength = 0.7
						force = 0.7
						endurance = 0.6
						speed = 0.25
						offense = 0.6
						anger = 0.25
						skills = list(/obj/Skills/Buffs/SpecialBuffs/Daimou_Form)
					if("Dragon")
						//power = 1
						passives =list(  "QuickCast"=0.5, "ManaPU" = 1)
						force = 0.25
						offense = 0.25
						imaginationAdd = 0.25
						skills = list(/obj/Skills/Utility/Heal)

					if("Warrior")
						//power = 1.5
						passives = list("TechniqueMastery" = 0.5, "Tenacity" = 0.5)
						strength = 0.35
						endurance = 0.35
						skills = list(/obj/Skills/Buffs/SpecialBuffs/Giant_Form)
				if(owner.Class=="Dragon")
					for(var/obj/Skills/Utility/Heal/se in owner.contents)
						se.SagaSignature=1
						se.SignatureTechnique=0
				..()
		three
			unlock_potential	=	ASCENSION_THREE_POTENTIAL
			onAscension(mob/owner)
				switch(owner.Class) // super namek era
					if("Demon")
						strength = 1.75
						force = 1.75
						endurance = 1.5
						offense = 0.75
						anger = 0.5
					if("Dragon")
						//power = 1.5
						force= 0.25
						endurance = 0.5
						passives = list(  "QuickCast"=1)
						recovery = 0.25
					if("Warrior")
						//power = 2
						offense = 0.65
						passives = list ("Extend" = 1, "Gum Gum" = 1, "TechniqueMastery" = 1, "Tenacity" = 0.5)
						strength = 0.65
						recovery = 0.65
						endurance = 0.65
				..()
		four
			unlock_potential =  ASCENSION_FOUR_POTENTIAL
			onAscension(mob/owner)
				switch(owner.Class)
					if("Demon")
						//power = 2
						strength = 2.75
						force = 2.75
						endurance = 2.5
						anger = 0.5
						passives = list(  "Extend" = 1, "Gum Gum" = 1)
					if("Warrior")
						//power = 3
						passives = list("Extend" = 1, "Gum Gum" = 1, "TechniqueMastery" = 1, "Tenacity" = 0.5)
						strength = 1
						endurance = 0.35
						recovery = 0.5
					if("Dragon")
						//power = 2.5
						force = 0.75
						recovery = 0.5
						passives = list( "QuickCast"=1)
				..()
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			onAscension(mob/owner)
				if(owner.transUnlocked != 2&&owner.Class!="Demon")
					owner.transUnlocked = 2
				switch(owner.Class) ///orange namek should be unlocked here
					if("Demon")
						strength = 2.75
						force = 2.75
						anger = 0.3
					if("Warrior")
						//power = 4
						strength = 1
						endurance = 1
					if("Dragon")
						//power = 3.5
						force = 1
						recovery = 1
						passives = list("SoulFire" = 1, "CyberStigma" = 1)
				..()
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			onAscension(mob/owner)
				switch(owner.Class)
					if("Demon")
						strength = 2.75
						force = 2.75
						anger = 0.3
					if("Warrior")
						//power = 4
						strength = 1
						endurance = 1
					if("Dragon")
						//power = 3.5
						force = 1
						recovery = 1
						passives = list("SoulFire" = 1, "CyberStigma" = 1)
				..()
