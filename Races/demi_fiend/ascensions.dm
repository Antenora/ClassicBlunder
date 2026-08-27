ascension/sub_ascension/demi_fiend/musubi
	passives = list("Musubi" = 1)
	onAscension(mob/owner)
		..()
		if(!(locate(/obj/Skills/AutoHit/DemiFiend/Lunge) in owner))
			owner.AddSkill(new /obj/Skills/AutoHit/DemiFiend/Lunge)
			owner << "The way of Musubi is yours. Lunge has become part of your inner world."
ascension/sub_ascension/demi_fiend/shijima
	passives = list("Shijima" = 1)
ascension/sub_ascension/demi_fiend/yosuga
	passives = list("Yosuga" = 1)
ascension/sub_ascension/demi_fiend/true_demon
	passives = list("TrueDemon" = 1)
	onAscension(mob/owner)
		..()
		owner.onTrueDemonAscended()
		owner.refreshTrueDemonPowerMult()
	revertAscension(mob/owner)
		owner.revertTrueDemonImprints()
		..()
		owner.refreshTrueDemonPowerMult()

ascension
	demi_fiend
		postAscension(mob/owner)
			owner.refreshMagatama()
			owner.refreshTrueDemonPowerMult()
			if(owner.passive_handler?.Get("Musubi"))
				owner.StrAscension  += strength * 0.5
				owner.EndAscension  += endurance * 0.5
				owner.ForAscension  += force * 0.5
				owner.OffAscension  += offense * 0.5
				owner.DefAscension  += defense * 0.5
				owner.SpdAscension  += speed * 0.5
				owner.RecovAscension += recovery * 0.5
			..()

		revertAscension(mob/owner)
			if(owner.passive_handler?.Get("Musubi"))
				owner.StrAscension  -= strength * 0.5
				owner.EndAscension  -= endurance * 0.5
				owner.ForAscension  -= force * 0.5
				owner.OffAscension  -= offense * 0.5
				owner.DefAscension  -= defense * 0.5
				owner.SpdAscension  -= speed * 0.5
				owner.RecovAscension -= recovery * 0.5
			..()
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			postAscension(mob/owner)
				while(owner.SagaLevel < 2)
					owner.SagaLevel++
					owner.tierUpSaga("Devil Summoner")
				..()
			choices = list("Reason of Musubi" = /ascension/sub_ascension/demi_fiend/musubi, "Reason of Shijima" = /ascension/sub_ascension/demi_fiend/shijima, "Reason of Yosuga" = /ascension/sub_ascension/demi_fiend/yosuga)
			choiceTitle = "Choose Your Reason"
			choiceMessage = "Your conviction takes shape. Which Reason will guide your path?\n\nMusubi: Freedom from constraint—swap Magatama at will and craft without escalating cost. You gain only passives from Magatama, never their skills.\nShijima: Unity through diversity—equip multiple Magatama, gaining an extra slot each ascension (scaling halved).\nYosuga: Strength unchained—amplify Magatama passive scaling (1.25x at ascension 1, +0.25x per ascension)."
			on_ascension_message = "Your demonic power awakens further. What Reason drives you?"
			passives = list("HellPower" = 0.25, "KiControlMastery" = 2, "PureDamage" = 1, "PureReduction" = 1, "BladeFisting" = 1, "StaticWalk" = 1, "SpaceWalk" = 1, "ManaGeneration" = 5)
			strength = 0.5
			endurance = 0.5
			speed = 0.5
			force = 0.5
			offense = 0.5
			defense = 0.5
			anger = 0.15
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			postAscension(mob/owner)
				while(owner.SagaLevel < 4)
					owner.SagaLevel++
					owner.tierUpSaga("Devil Summoner")
				..()
			passives = list("HellPower" = 0.25, "KiControlMastery" = 1, "PureDamage" = 1, "PureReduction" = 1)
			strength = 1
			endurance = 1
			speed = 1
			force = 1
			offense = 1
			defense = 1
			anger = 0.15
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			postAscension(mob/owner)
				while(owner.SagaLevel < 6)
					owner.SagaLevel++
					owner.tierUpSaga("Devil Summoner")
				..()
			passives = list("HellPower" = 0.25, "KiControlMastery" = 1, "PureDamage" = 1, "PureReduction" = 1, "MovingCharge" = 1)
			strength = 2
			endurance = 2
			speed = 2
			force = 2
			offense = 2
			defense = 2
			anger = 0.1
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list("HellPower" = 0.25, "KiControlMastery" = 1, "PureDamage" = 1, "PureReduction" = 1)
			strength = 2
			endurance = 2
			speed = 2
			force = 2
			offense = 2
			defense = 2
			anger = 0.1
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list("KiControlMastery" = 1, "PureDamage" = 3, "PureReduction" = 3)
			strength = 2.5
			endurance = 2.5
			speed = 2.5
			force = 2.5
			offense = 2.5
			defense = 2.5
			anger = 0.25
			onAscension(mob/owner)
				..()
				if(owner.HasTrueDemonPath())
					owner.passive_handler?.Increase("HellPower", 1)
			revertAscension(mob/owner)
				if(owner.HasTrueDemonPath())
					owner.passive_handler?.Decrease("HellPower", 1)
				..()
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			passives = list("KiControlMastery" = 1, "PureDamage" = 3, "PureReduction" = 3)
			strength = 3
			endurance = 3
			speed = 3
			force = 3
			offense = 3
			defense = 3
			anger = 0.25
