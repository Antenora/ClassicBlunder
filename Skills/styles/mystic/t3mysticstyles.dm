/obj/Skills/Buffs/NuStyle/MysticStyle
// TODO: Deterioration - make energy/mana cost more
//
	Oblivion_Storm
		SignatureTechnique = 3
		passives = list("DemonicInfusion" = 1, "IceHerald" = 1, "ThunderHerald" = 1, "Heavy Strike" = "HellfireInferno", \
		            "Chaos" = 15, "Scorching" = 15, "Combustion" = 80, "IceAge" = 25, "SpiritFlow" = 4, "Familiar" = 3,\
		            "CriticalChance" = 35, "CriticalDamage" = 0.25,"Harden" = 2, "WaveDancer" = 2)
		StyleFor = 1.6
		StyleSpd = 1.2
		StyleOff = 1.2
		StyleActive = "Oblivion Storm"
		Finisher="/obj/Skills/Queue/Finisher/Soul_Seller"
		verb/Oblivion_Storm()
			set hidden=1
			src.Trigger(usr)
	Annihilation
		SignatureTechnique = 3
		passives = list("Atomizer" = 1, "BetterAim" = 3, "SuperCharge" = 2, "Familiar" = 3, "SpiritFlow" = 4, \
		            "ThunderHerald" = 1, "CriticalChance" = 25, "CriticalDamage" = 0.1, "Godspeed" = 3, "AirBend" = 2, \
		            "Harden" = 2, "Scorching" = 8, "Shattering" = 8, "Shocking" = 8, "Freezing" = 8)
		StyleFor = 1.5
		StyleOff = 1.5
		StyleActive = "Annihilation"
		Finisher="/obj/Skills/Queue/Finisher/Atomic_Dismantling"
		verb/Annihilation()
			set hidden=1
			src.Trigger(usr)
	Omnimancer
		SignatureTechnique = 3
		passives = list("Deterioration" = 1, "Erosion" = 0.15, "SpiritFlow" = 4, "Amplify" = 3, "LikeWater" = 4)
		ElementalDefense = "Void"
		ElementalOffense = "Void"
		StyleFor = 1.3
		StyleOff = 1.15
		StyleDef = 1.15
		StyleActive="Singularity"
		var/obj/Skills/demonSkill = FALSE
		Trigger(mob/User, Override)
			if(!demonSkill)
				var/inp = input(User, "What demon skill do you want?") in list("/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/Hellstorm", "/obj/Skills/Projectile/Magic/HellFire/Hellpyre", "/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/OverHeat")
				BuffTechniques = list(inp)
				demonSkill = inp
			. = ..()
		proc/swap_stance(o)
			switch(o)
				if("blizzard")
					ElementalOffense = "Water"
					ElementalDefense = "Wind"
					ElementalClass = list("Wind","Water")
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Water"
					passives = list("IceHerald" = 1,"Familiar" = 2, "ThunderHerald" = 1, "CriticalChance" = 20, "CriticalDamage" = 0.2, "SpiritFlow" = 4, "Harden" = 2, \
					                "Freezing" = 5, "Shocking" = 5, "WaveDancer" = 1.5)
					Finisher="/obj/Skills/Queue/Finisher/Frostfist"
					StyleActive = "Blizzard"
					StyleOff=1.15
					StyleSpd=1.15
					StyleFor=1.3
				if("hellfire")
					passives = list("SpiritFlow" = 4, "Familiar" = 2, "Combustion" = 60, "Heavy Strike" = "Inferno",\
						"Scorching" = 1)
					ElementalOffense = "HellFire"
					ElementalDefense = "Fire"
					ElementalClass = "Fire"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Fire"
					StyleFor = 1.6
					Finisher="/obj/Skills/Queue/Finisher/Deal_with_the_Devil"
					StyleActive = "Hellfire"
				if("plasma")
					ElementalOffense = "Wind"
					ElementalDefense = "Fire"
					ElementalClass = list("Fire","Wind")
					StyleFor = 1.3
					StyleSpd = 1.3
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Earth"
					passives = list("SuperCharge" = 1,"Familiar" = 2, "SpiritFlow" = 4, "ThunderHerald" = 1, "CriticalChance" = 20, "CriticalDamage" = 0.1, \
					                "Godspeed" = 2, "AirBend" = 1.5, "Harden" = 2, "Burning" = 2, "Shattering" = 5, "Shocking" = 2, "Chilling" = 2)
					Finisher="/obj/Skills/Queue/Finisher/Mega_Arm" // Super_mega_buster
					StyleActive = "Plasma"
				if("singularity")
					passives = list("Deterioration" = 1, "Erosion" = 0.15, "SpiritFlow" = 4, "Amplify" = 3, "LikeWater" = 4, /* ??? */)
					ElementalDefense = "Void"
					ElementalOffense = "Void"
					StyleFor = 1.3
					StyleOff = 1.15
					StyleDef = 1.15
					StyleActive="Singularity"
					Finisher="/obj/Skills/Queue/Finisher/The_Void"
		verb/Blizzard_Stance()
			set category="Stances"
			if(usr.BuffOn(src))
				turnOff(usr)
			swap_stance("blizzard")
			Trigger(usr, 1)
			giveBackTension(usr)
		verb/Hellfire_Stance()
			set category="Stances"
			if(usr.BuffOn(src))
				turnOff(usr)
			swap_stance("hellfire")
			Trigger(usr, 1)
			giveBackTension(usr)
		verb/Plasma_Stance()
			set category="Stances"
			if(usr.BuffOn(src))
				turnOff(usr)
			swap_stance("plasma")
			Trigger(usr, 1)
			giveBackTension(usr)
		verb/Singularity_Stance()
			set category="Stances"
			if(usr.BuffOn(src))
				turnOff(usr)
			swap_stance("singularity")
			Trigger(usr, 1)
			giveBackTension(usr)
	Gamma_Style
		SignatureTechnique = 3
		StyleActive = "Betel"
		passives = list("SpiritFlow" = 4, "LikeWater" = 4, "Adaptation" = 4, "Steady" = 4)
		StyleStr = 1.3
		StyleSpd = 1.3
		StyleFor = 1
		StyleEnd = 1
		StyleOff = 1
		StyleDef = 1
		ElementalClass = "Fire"
		ElementalOffense = "Fire"
		ElementalDefense = "Fire"
		Finisher = "/obj/Skills/Queue/Finisher/Sorblow"
		BuffTechniques = list("/obj/Skills/Gamma_Evolution/Slide_Evolution",\
			"/obj/Skills/Gamma_Evolution/Dark_Evolution")
		var/lastSlide = 0
		var/gulusActive = 0
		var/swapping = 0
		var/slideTickerActive = 0
		verb/Gamma_Style()
			set hidden=1
			src.Trigger(usr)
		Trigger(mob/User, Override)
			if(User && !swapping && !User.BuffOn(src))
				swap_stance("betel")
				gulusActive = 0
			..()
		proc/swap_stance(o)
			switch(o)
				if("betel")
					StyleActive = "Betel"
					StyleStr = 1.3
					StyleSpd = 1.3
					StyleFor = 1.2
					StyleEnd = 1
					StyleOff = 1
					StyleDef = 1
					ElementalClass = "Fire"
					ElementalOffense = "Fire"
					ElementalDefense = "Fire"
					passives = list("Adaptation" = 5, "Scorching" = 2, "Combustion" = 60, "SpiritHand" = 4, "Heavy Strike" = "Inferno", "Fa Jin" = 2, "Instinct" = 4, "Momentum" = 4)
					Finisher = "/obj/Skills/Queue/Finisher/Sorblow"
				if("kaus")
					StyleActive = "Kaus"
					StyleStr = 1.25
					StyleSpd = 1.6
					StyleFor = 1.25
					StyleEnd = 0.8
					StyleOff = 1
					StyleDef = 1
					ElementalClass = "Wind"
					ElementalOffense = "Wind"
					ElementalDefense = "Wind"
					passives = list("Adaptation" = 5, "BlurringStrikes" = 3, "Shocking" = 3, "Flicker" = 4, "Flow" = 4, "Speed Force" = 1, "AttackSpeed" = 2, "Fury" = 4, "Skimming" = 2)
					Finisher = "/obj/Skills/Queue/Finisher/Urda_Impulse"
				if("wezen")
					StyleActive = "Wezen"
					StyleStr = 1.2
					StyleSpd = 0.8
					StyleFor = 1.5
					StyleEnd = 1.5
					StyleOff = 1
					StyleDef = 1
					ElementalClass = "Earth"
					ElementalOffense = "Earth"
					ElementalDefense = "Earth"
					passives = list("Adaptation" = 5, "Harden" = 5, "Blubber" = 4, "SweepingStrike" = 1, "Extend" = 2, "Gum Gum" = 2, "GiantForm" = 1, "Juggernaut" = 4, "Shattering" = 5)
					Finisher = "/obj/Skills/Queue/Finisher/Albion"
				if("gulus")
					StyleActive = "Gulus"
					StyleStr = 1.5
					StyleSpd = 1.5
					StyleFor = 1.5
					StyleEnd = 1.5
					StyleOff = 1.5
					StyleDef = 1.5
					ElementalClass = "Dark"
					ElementalOffense = "Dark"
					ElementalDefense = "Dark"
					passives = list("HellPower" = 0.25, "AbyssMod" = 5, "DemonicDurability" = 5, "HellRisen" = 0.5, "SpiritHand" = 4, "SpiritFlow" = 4, "AngerAdaptiveForce" = 0.25, "Scorching" = 5, "Poisoning" = 5, "LikeWater" = 4)
					Finisher = "/obj/Skills/Queue/Finisher/Desdemona"
		proc/doSlideEvolution(mob/owner)
			if(!owner) return
			if(StyleActive == "Gulus")
				owner << "Slide Evolution is sealed while in Gulus."
				return
			if(lastSlide + (30 SECONDS) > world.time)
				var/remaining = round((lastSlide + (30 SECONDS) - world.time) / 10, 0.1)
				if(remaining>30)
					remaining=0
				else
					owner << "Slide Evolution is on cooldown: [remaining]s remaining."
					return
			var/next_stance
			switch(StyleActive)
				if("Betel")
					next_stance = "kaus"
				if("Kaus")
					next_stance = "wezen"
				if("Wezen")
					next_stance = "betel"
				else
					next_stance = "betel"
			swapping = 1
			if(owner.BuffOn(src))
				turnOff(owner)
			swap_stance(next_stance)
			Trigger(owner, 1)
			swapping = 0
			giveBackTension(owner)
			lastSlide = world.time
			animate(owner, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
			animate(color = list(1,0,0, 0,1,0, 0,0,1, 0,0,0), time=10)
			OMsg(owner, "Slide Evolution! [owner] evolves into [StyleActive]!")
			startSlideCooldownTicker(owner)
		proc/startSlideCooldownTicker(mob/owner)
			if(slideTickerActive) return
			slideTickerActive = 1
			spawn(0)
				while(owner && lastSlide + (30 SECONDS) > world.time)
					sleep(1 SECONDS)
					if(!owner) break
					if(owner.PureRPMode)
						lastSlide += 1 SECONDS
				slideTickerActive = 0
		proc/doDarkEvolution(mob/owner)
			if(!owner) return
			if(StyleActive == "Gulus")
				owner << "You are already in Gulus."
				return
			if(owner.Health > 25)
				owner << "Dark Evolution can only be invoked at 25 Health or less."
				return
			var/obj/Skills/Gamma_Dark_Evolution_Lock/lock = owner.FindSkill(/obj/Skills/Gamma_Dark_Evolution_Lock)
			if(!lock)
				lock = new /obj/Skills/Gamma_Dark_Evolution_Lock
				owner.AddSkill(lock)
			if(lock.Using)
				owner << "Dark Evolution has already been invoked this fight. You must meditate to restore it."
				return
			swapping = 1
			if(owner.BuffOn(src))
				turnOff(owner)
			swap_stance("gulus")
			Trigger(owner, 1)
			swapping = 0
			giveBackTension(owner)
			lock.Using = 1
			gulusActive = 1
			animate(owner, color = list(0,0,0, 0,0,0, 0,0,0, 0,0,0))
			animate(color = list(1,0,0, 0,1,0, 0,0,1, 0,0,0), time=10)
			OMsg(owner, "[owner] gives into the power of Dark Evolution...")
			spawn(0)
				var/remaining = 60 SECONDS
				while(remaining > 0)
					sleep(1 SECONDS)
					if(!gulusActive) return
					if(!owner || owner.StyleBuff != src) return
					if(StyleActive != "Gulus") return
					if(!owner.BuffOn(src)) return
					if(owner.PureRPMode) continue
					remaining -= 1 SECONDS
				if(!gulusActive) return
				gulusActive = 0
				if(!owner || owner.StyleBuff != src) return
				if(StyleActive != "Gulus") return
				if(!owner.BuffOn(src)) return
				swapping = 1
				turnOff(owner)
				swap_stance("betel")
				Trigger(owner, 1)
				swapping = 0
				giveBackTension(owner)
				animate(owner, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
				animate(color = list(1,0,0, 0,1,0, 0,0,1, 0,0,0), time=10)
				owner << "Gulus fades; you return to Betel."

/obj/Skills/Gamma_Dark_Evolution_Lock
	name = "Dark Evolution"
	Cooldown = -1

/obj/Skills/Gamma_Evolution
	name = "Gamma Evolution"
	Slide_Evolution
		name = "Slide Evolution"
		verb/Slide_Evolution()
			set category="Skills"
			if(!istype(usr.StyleBuff, /obj/Skills/Buffs/NuStyle/MysticStyle/Gamma_Style))
				usr << "You must be in Gamma Style to use Slide Evolution."
				return
			var/obj/Skills/Buffs/NuStyle/MysticStyle/Gamma_Style/gs = usr.StyleBuff
			gs.doSlideEvolution(usr)
	Dark_Evolution
		name = "Dark Evolution"
		verb/Dark_Evolution()
			set category="Skills"
			if(!istype(usr.StyleBuff, /obj/Skills/Buffs/NuStyle/MysticStyle/Gamma_Style))
				usr << "You must be in Gamma Style to use Dark Evolution."
				return
			var/obj/Skills/Buffs/NuStyle/MysticStyle/Gamma_Style/gs = usr.StyleBuff
			gs.doDarkEvolution(usr)
