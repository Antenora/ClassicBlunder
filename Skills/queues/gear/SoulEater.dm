obj
	Skills
		Queue
			Heart_Slayer
				name="Heart-Slayer"
				ActiveMessage="begins to build darkness on the tip of their blade!"
				DamageMult=2.25
				AccuracyMult = 1.175
				KBMult=0.00001
				Combo=5
				Warp=5
				Duration=10
				Cooldown=40
				NeedsSword=1
				HitSparkIcon='Slash - Black.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				Instinct=2
				EnergyCost=10
				CursedWounds=1
				verb/Heart_Slayer()
					set category="Skills"
					usr.SetQueue(src)
obj
	Skills
		AutoHit
			Dark_Break
				Copyable=5
				NeedsSword=1
				Area="Target"
				GuardBreak=1
				StrScaling=1
				ForScaling=1
				DamageMult=5
				SpeedStrike=5
				Distance=10
				PassThrough=1
				PreShockwave=1
				PostShockwave=1
				HitSparkIcon='Slash - Vampire.dmi'
				HitSparkX=-32
				HitSparkY=-32
				Shockwave=2
				Shockwaves=2
				ActiveMessage="appears above their opponent for an instantaneous overhead slash!"
				Cooldown=45
				EnergyCost=10
				verb/Dark_Break()
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
			Shadowbreaker
				Copyable=5
				NeedsSword=1
				Area="Wide Wave"
				StrScaling=1
				ForScaling=1
				Distance=10
				PassThrough=1
				PreShockwave=1
				PostShockwave=0
				Shockwave=2
				Shockwaves=2
				SpeedStrike=4
				DamageMult=10
				ActiveMessage="spins forward at high speed, surrounded by the power of darkness!"
				HitSparkIcon='Slash - Vampire.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1
				HitSparkDispersion=1
				TurfStrike=1
				TurfShift='StarPixel.dmi'
				TurfShiftDuration=3
				Cooldown=60
				Instinct=1
				verb/Shadowbreaker()
					set category="Skills"
					usr.Activate(src)
/obj/Skills/Buffs/SlotlessBuffs/Seeker_of_Darkness
	BuffName = "Seeker of Darkness"
	Copyable = 0
	NeedsSword = 1
	NoStaff = 1
	passives = list("LifeSteal" = 25, "AbyssMod" = 2)
	ElementalOffense = "Heartless"
	ElementalDefense = "Dark"
	ElementalClass = "Fire"
	ManaGlow="#f000e4"
	ManaGlowSize=2
	adjust(mob/p)
		passives = list("LifeSteal" = 25, "AbyssMod" = 2)
		var/obj/Items/Sword/Medium/Legendary/Soul_Eater/SE = p.EquippedSword()
		if(!istype(SE)) return
		if(SE.SEType=="Sword")
			passives["CriticalDamage"] = 0.1
			passives["Fury"] = 3
		else if(SE.SEType=="Staff")
			passives["ManaGeneration"] = 3
		else if(SE.SEType=="Shield")
			passives["Harden"] = 2
			passives["Momentum"] = 1.5
	verb/Seeker_of_Darkness()
		set category = "Skills"
		set hidden = 1
		src.Trigger(usr)
