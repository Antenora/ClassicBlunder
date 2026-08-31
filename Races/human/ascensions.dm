mob/proc/CheckAscCombo()
	if(HeroicNum>=2&&UnderdogNum>=2)
		if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Human/High_Tension, src))
			src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Human/High_Tension)
			src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Human/High_Tension_MAX)
			src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Human/Super_High_Tension)
			src<<"You have unlocked High Tension!"
	if(SaiyanNum>=2&&UnderdogNum>=2)
		if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Racial/Human/Super_Saiyan_Rage, src))
			src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Human/Super_Saiyan_Rage)
			src<<"You have unlocked Super Saiyan Rage!"
	if(SaiyanNum==3&&HeroicNum==3)
		transUnlocked=3
		src<<"You have unlocked Beast Mode!"
/ascension/sub_ascension/human/heroic
	passives = list("PowerUpMastery" = 2)
	offense = 0.5
	strength = 0.5
	force = 0.5
	defense = 0.5
	endurance = 0.5
	speed = 0.5
	growthadd= 0.25
	onAscension(mob/owner)
		owner.HeroicNum++
		if(owner.HeroicNum==4)
			owner.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Human/Third_Eye)
		owner.CheckAscCombo()
		..()
/ascension/sub_ascension/human/underdog
	anger = 0.1
	passives = list("Tenacity" = 2, "UnderDog" = 1)
	onAscension(mob/owner)
		owner.UnderdogNum++
		owner.CheckAscCombo()
		if(owner.UnderdogNum==4)
			owner.passive_handler.Increase("EndlessAnger", 1)
		..()
/ascension/sub_ascension/human/saiyan
	passives = list("ZenkaiPower" = 0.25)
	onAscension(mob/owner)
		owner.SaiyanNum++
		if(owner.SaiyanNum==1)
			owner.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Oozaru)
			owner.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/HalfSaiyan/Hidden_Potential)
		if(owner.SaiyanNum==2)
			owner.transUnlocked=1
		if(owner.SaiyanNum==3)
			owner.transUnlocked=2
		if(owner.SaiyanNum==4)
			owner.transUnlocked=3
		if(owner.SaiyanNum==5)
			owner.transUnlocked=4
		if(owner.SaiyanNum==6)
			owner.transUnlocked=5
		owner.CheckAscCombo()
		..()



ascension
	human
		var/dormantDemonPassivesAdded = 0

		proc/applyDormantDemonPassives(mob/owner)
			if(applied || dormantDemonPassivesAdded || !owner.passive_handler)
				return
			if(!owner.passive_handler.Get("DormantDemon"))
				return
			passives["HellPower"] = (isnum(passives["HellPower"]) ? passives["HellPower"] : 0) + 0.25
			passives["HellRisen"] = (isnum(passives["HellRisen"]) ? passives["HellRisen"] : 0) + 0.25
			passives["AbyssMod"] = (isnum(passives["AbyssMod"]) ? passives["AbyssMod"] : 0) + 1
			dormantDemonPassivesAdded = 1

		revertAscension(mob/owner)
			..()
			if(!dormantDemonPassivesAdded)
				return
			if(isnum(passives["HellPower"]))
				passives["HellPower"] -= 0.25
				if(passives["HellPower"] <= 0)
					passives -= "HellPower"
			if(isnum(passives["HellRisen"]))
				passives["HellRisen"] -= 0.25
				if(passives["HellRisen"] <= 0)
					passives -= "HellRisen"
			if(isnum(passives["AbyssMod"]))
				passives["AbyssMod"] -= 1
				if(passives["AbyssMod"] <= 0)
					passives -= "AbyssMod"
			dormantDemonPassivesAdded = 0

		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			choices = list("Heroic" = /ascension/sub_ascension/human/heroic, "Underdog" = /ascension/sub_ascension/human/underdog, "Saiyan" = /ascension/sub_ascension/human/saiyan)
			passives = list("Tenacity" = 1, "Shonen" = 1, "ShonenPower" = 0.15, "UnderDog" = 1,"Persistence" = 1)
			new_anger_message = "grows desperate!"
			on_ascension_message = "You learn the meaning of desperation..."
			simulateChoiceMutation(mob/owner)
				if(!applied)
					offense = 0.5
					strength = 0.5
					force = 0.5
					defense = 0.5
					endurance = 0.5
					speed = 0.5
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				applyDormantDemonPassives(owner)
				..()
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			passives = list("Tenacity" = 1, "Shonen" = 1, "ShonenPower" = 0.15, "UnderDog"=1, "Adrenaline"=1, "Persistence" = 1)
			choices = list("Heroic" = /ascension/sub_ascension/human/heroic, "Underdog" = /ascension/sub_ascension/human/underdog, "Saiyan" = /ascension/sub_ascension/human/saiyan)
			new_anger_message = "grows determined!"
			on_ascension_message = "You learn the meaning of responsibility..."
			simulateChoiceMutation(mob/owner)
				if(!applied)
					offense = 0.5
					strength = 0.5
					force = 0.5
					defense = 0.5
					endurance = 0.5
					speed = 0.5
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				applyDormantDemonPassives(owner)
				if(owner.Class=="Underdog" && owner.transUnlocked<2)
					owner.transUnlocked=2
				..()
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			var/mazokuSinChosen = ""
			passives = list("Tenacity" = 1,  "UnderDog"=1, "Persistence" = 1)
			choices = list("Heroic" = /ascension/sub_ascension/human/heroic, "Underdog" = /ascension/sub_ascension/human/underdog, "Saiyan" = /ascension/sub_ascension/human/saiyan)
			new_anger_message="grows confident!"
			on_ascension_message = "You learn the meaning of confidence..."
			simulateChoiceMutation(mob/owner)
				if(!applied)
					offense = 0.5
					strength = 0.5
					force = 0.5
					defense = 0.5
					endurance = 0.5
					speed = 0.5
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				if(owner.Class=="Underdog" && owner.transUnlocked<3)
					owner.transUnlocked=3
				applyDormantDemonPassives(owner)
				..()
			postAscension(mob/owner)
				..()
				if(!owner.passive_handler || !owner.passive_handler.Get("DormantDemon")) return
				if(mazokuSinChosen != "") return
				var/sinChoice = input(owner, "A dormant power stirs within you. Which path do you walk?", "Dormant Demon Awakening") in list("Apathy", "Hope")
				mazokuSinChosen = sinChoice
				switch(sinChoice)
					if("Apathy")
						owner.passive_handler.Increase("ApathyFactor", 1)
					if("Hope")
						owner.passive_handler.Increase("HopeFactor", 1)
						if(!locate(/obj/Skills/Queue/Kibou_ou_Hope, owner))
							owner.AddSkill(new /obj/Skills/Queue/Kibou_ou_Hope)
			revertAscension(mob/owner)
				if(mazokuSinChosen != "" && owner.passive_handler)
					owner.passive_handler.Decrease(mazokuSinChosen + "Factor", 1)
					if(mazokuSinChosen == "Hope")
						var/obj/Skills/Queue/Kibou_ou_Hope/k = locate(/obj/Skills/Queue/Kibou_ou_Hope, owner)
						if(k) owner.DeleteSkill(k)
					mazokuSinChosen = ""
				..()

		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list("Tenacity" = 1,  "UnderDog"=1, "Persistence" = 1)
			choices = list("Heroic" = /ascension/sub_ascension/human/heroic, "Underdog" = /ascension/sub_ascension/human/underdog, "Saiyan" = /ascension/sub_ascension/human/saiyan)
			new_anger_message = "gains absolute clarity!"
			on_ascension_message = "You learn the meaning of competence..."
			simulateChoiceMutation(mob/owner)
				if(!applied)
					offense = 0.5
					strength = 0.5
					force = 0.5
					defense = 0.5
					endurance = 0.5
					speed = 0.5
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				applyDormantDemonPassives(owner)
				..()

		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list( "Tenacity" = 1,  "UnderDog"=1, "Persistence" = 1)
			choices = list("Heroic" = /ascension/sub_ascension/human/heroic, "Underdog" = /ascension/sub_ascension/human/underdog, "Saiyan" = /ascension/sub_ascension/human/saiyan)
			new_anger_message = "becomes angry!"
			on_ascension_message = "You learn the meaning of humanity..."
			simulateChoiceMutation(mob/owner)
				if(!applied)
					offense = 0.5
					strength = 0.5
					force = 0.5
					defense = 0.5
					endurance = 0.5
					speed = 0.5
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				if(owner.Class=="Underdog" && owner.transUnlocked<4)
					owner.transUnlocked=4
				applyDormantDemonPassives(owner)
				..()
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			passives = list( "Tenacity" = 1,  "UnderDog"=1, "Persistence" = 1)
			choices = list("Heroic" = /ascension/sub_ascension/human/heroic, "Underdog" = /ascension/sub_ascension/human/underdog, "Saiyan" = /ascension/sub_ascension/human/saiyan)
			new_anger_message = "becomes angry!"
			on_ascension_message = "You learn the meaning of humanity..."
			simulateChoiceMutation(mob/owner)
				if(!applied)
					offense = 0.5
					strength = 0.5
					force = 0.5
					defense = 0.5
					endurance = 0.5
					speed = 0.5
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				if(owner.Class=="Underdog" && owner.transUnlocked<5)
					owner.transUnlocked=5
				applyDormantDemonPassives(owner)
				..()
		/*		if(owner.isMazokuHuman())
					var/already_has_sea = FALSE
					for(var/transformation/T in owner.race.transformations)
						if(istype(T, /transformation/human/sacred_energy_aura))
							already_has_sea = TRUE
							break
					if(!already_has_sea)
						owner.race.transformations += new /transformation/human/sacred_energy_aura()*/
/*			revertAscension(mob/owner)
				if(owner.passive_handler && owner.race && owner.race.transformations)
					for(var/transformation/T in owner.race.transformations.Copy())
						if(istype(T, /transformation/human/sacred_energy_aura))
							owner.race.transformations -= T
							del T
							break
				..()*/
