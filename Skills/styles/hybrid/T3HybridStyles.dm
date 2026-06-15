/obj/Skills/Buffs/NuStyle/UnarmedStyle
	Twin_Dragon_Fire // mystic+unarmed
		SignatureTechnique=3
		Copyable=0
		StyleStr=1.45
		StyleFor=1.3
		StyleSpd=1.25
		StyleActive="Twin Dragon Fire"
		passives = list("HybridStyle" = "MysticStyle","Fury" = 2, "Momentum" = 2,  "Harden" = 2, "SpiritHand" = 2, "Instinct" = 2, \
							"Flow" = 2, "SpiritFlow" = 2, "Combustion" = 50, "Scorching" = 6, "Shattering" = 5, "Heavy Strike" = "Inferno", "BlurringStrikes" = 2, "SweepingStrike" = 1)
		Finisher="/obj/Skills/Queue/Finisher/Bauf_Burst"
		adjust(mob/p)
			passives = list("HybridStyle" = "MysticStyle","Fury" = 2, "Momentum" = 2,  "Harden" = 2, "SpiritHand" = 2, "Instinct" = 2, \
							"Flow" = 2, "SpiritFlow" = 2, "Combustion" = 50, "Scorching" = 6, "Shattering" = 5, "Heavy Strike" = "Inferno", "BlurringStrikes" = 2, "SweepingStrike" = 1)
		verb/Twin_Dragon_Fire()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)

	School_of_the_Undefeated_of_the_East // unarmed + armed
		SignatureTechnique=3
		passives = list("HybridStyle" = "SwordStyle", "Fa Jin" = 2, "Momentum" = 2, "BlurringStrikes" = 3, "Interception" = 1.5, \
				"Extend" = 1, "Gum Gum" = 1, "BladeFisting" = 1,  "NeedsSword" = 0, "NoSword" = 1, "Flicker" = 3, "CallousedHands"=0.25)
		NeedsSword=0
		NoSword=1
		BladeFisting=1
		StyleStr = 1.5
		StyleSpd = 1.25
		StyleEnd = 1.25
		Finisher="/obj/Skills/Queue/Finisher/Winds_Of_The_King"
		StyleActive = "School of the Undefeated Of The East"
		adjust(mob/p)
			passives = list("HybridStyle" = "SwordStyle", "Fa Jin" = 2, "Momentum" = 2, "BlurringStrikes" = 3, "Interception" = 1.5, \
				"Extend" = 1, "Gum Gum" = 1, "BladeFisting" = 1,  "NeedsSword" = 0, "NoSword" = 1, "Flicker" = 3, "CallousedHands"=0.25, "Grippy" = 4)
		verb/School_of_the_Undefeated_of_the_East()
			set hidden=1
			adjust(usr)
			Trigger(usr)
/obj/Skills/Buffs/NuStyle/SwordStyle

	God_of_Hyperdeath //mystic+armed
		SignatureTechnique=3
		StyleActive="God of Hyperdeath!!!!"
		StyleStr = 1.35
		StyleFor = 1.35
		StyleEnd = 1.3
		passives = list("HybridStyle" = "MysticStyle", "Heavy Strike" = "ChaosBlaster", "CriticalChance" = 25, "CriticalDamage"= 0.15, "SpiritSword" = 1.5, "SpiritFlow"=2.5, \
					"Secret Knives" = "GodSlayer", "MovingCharge"=1, "Tossing"=2)
		Finisher="/obj/Skills/Queue/Finisher/Hyper_Goner"
		adjust(mob/p)
			passives = list("HybridStyle" = "MysticStyle", "CriticalChance" = 25, "CriticalDamage"= 0.15, "SpiritSword" = 1.5, "SpiritFlow"=2.5, \
						"Secret Knives" = "GodSlayer", "MovingCharge"=1, "Tossing"=2)

		verb/God_of_Hyperdeath()
			set hidden=1
			adjust(usr)
			Trigger(usr)
	Tsui_no_Hiken_Kaguzuchi // mystic+armed, but on fire
		SignatureTechnique=3
		passives = list("HybridStyle" = "MysticStyle",  "CriticalChance" = 10, "CriticalDamage"= 0.05, "SpiritSword" = 0.5, "DemonicInfusion" = 1, "Combustion" = 60, "Scorching" = 8,\
						"Heavy Strike" = "Inferno", "Instinct" = 1, "Persistence" = 1, "BurnHit" = 0.5, "SpiritFlow"=2)
		// crits deal an extra amount based on the enemy's max health
		StyleStr = 1.65
		StyleFor = 1.65
		StyleOff = 1.15
		StyleEnd = 0.75
		StyleDef = 0.85
		ElementalOffense = "HellFire"
		ElementalDefense = "Fire"
		ElementalClass = "Fire"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Fire"
		StyleActive="Tsui no Hiken: Kaguzuchi"
		Finisher="/obj/Skills/Queue/Finisher/Deal_with_the_Devil"
		var/obj/Skills/demonSkill = FALSE
		adjust(mob/p)
			passives = list("HybridStyle" = "MysticStyle",  "CriticalChance" = 15, "CriticalDamage"= 0.15, "SpiritSword" = 0.5, "DemonicInfusion" = 1, "Combustion" = 60, "Scorching" = 8,\
						"Heavy Strike" = "Inferno", "Instinct" = 1, "Persistence" = 1, "BurnHit" = 0.5, "SpiritFlow"=2)
		Trigger(mob/User, Override)
			if(!demonSkill)
				var/inp = input(User, "What demon skill do you want?") in list("/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/Hellstorm", "/obj/Skills/Projectile/Magic/HellFire/Hellpyre", "/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/OverHeat")
				BuffTechniques = list(inp)
				demonSkill = inp
			sleep(2)
			..()

		verb/Tsui_no_Hiken_Kaguzuchi()
			set hidden=1
			Trigger(usr)
	Plasma_Blade
		SignatureTechnique=3
		passives = list("Iaido" = 4, "HybridStyle" = "MysticStyle", "Wuju" = 1, "CriticalChance" = 40, "CriticalDamage"= 0.05, "Shocking" = 4, "ThunderHerald" = 1, \
			"Instinct" = 1, "Flicker" = 1, "Fury" = 2.5, "Iaijutsu" = 2, "BlurringStrikes" = 1.5, "Rain" = 3,\
			"SpiritSword" = 1, "SpiritFlow"=4)
		StyleSpd = 1.5
		StyleFor = 1.35
		StyleOff = 1.15
		ElementalOffense = "Wind"
		StyleActive="Plasma Blade"
		Finisher="/obj/Skills/Queue/Finisher/Plasma_Formation"
		adjust(mob/p)
			passives = list( "HybridStyle" = "MysticStyle", "Wuju" = 1, "CriticalChance" = 40, "CriticalDamage"= 0.05, "Shocking" = 4, "ThunderHerald" = 1, \
			"Instinct" = 1, "Flicker" = 1, "Fury" = 2.5, "Iaijutsu" = 3, "BlurringStrikes" = 1.5, "Rain" = 3, "SpiritSword" = 1, "SpiritFlow"=4);
		verb/Plasma_Blade()
			set hidden=1
			if(!usr.BuffOn(src)) adjust(usr);
			Trigger(usr)
	Bloodwhetter
		SignatureTechnique=3
		passives = list("HybridStyle" = "MysticStyle", "Serrated" = 1, "Familiar" = 2, \
			"SpiritFlow" = 2, "BlindingVenom" = 2, "BloodEruption" = 2, "LingeringPoison" = 1,\
			"SpiritSword" = 0.25, "Crippling" = 3, "Poisoning" = 5, "Pursuer" = 1, )
		// crits deal an extra amount based on the enemy's max health
		StyleStr = 1.35
		StyleFor = 1.35
		StyleOff = 1.3
		StyleActive="Bloodwhetter"
		Finisher="/obj/Skills/Queue/Finisher/Blood_Sacrifice"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Poison"
		adjust(mob/p)
			passives = list("HybridStyle" = "MysticStyle", "Serrated" = 1, "Familiar" = 2, \
			"SpiritFlow" = 2, "BlindingVenom" = 2, "BloodEruption" = 2, "LingeringPoison" = 1,\
			"SpiritSword" = 0.5, "Crippling" = 5, "Poisoning" = 5, "Pursuer" = 1)
		verb/Bloodwhetter()
			set hidden=1
			Trigger(usr)
