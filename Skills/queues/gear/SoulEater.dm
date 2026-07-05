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
				SpiritHand=0.5
				SpiritSword=0.5
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
				StrOffense=1
				ForOffense=1
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
				StrOffense=1
				ForOffense=1
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
/obj/Skills/Buffs/NuStyle/SwordStyle
	Seeker_of_Darkness
		SignatureTechnique = 2
		SagaSignature = 1
		passives = list("BladeFisting" = 1, "MagicSword" = 1, "LifeSteal" = 25, "AbyssMod" = 2)
		ElementalOffense = "Heartless"
		ElementalDefense = "Dark"
		ElementalClass = "Fire"
		StyleActive = "Seeker of Darkness"
		StyleSpd = 1.3
		StyleStr = 1.3
		Finisher="/obj/Skills/Queue/Finisher/Dark_Aura"
		ManaGlow="#f000e4"
		ManaGlowSize=2
		adjust(mob/p)
			if(altered) return
			var/obj/Items/Sword/Medium/Legendary/Soul_Eater/SE=p.EquippedSword()
			if(!SE) return
			if(SE.SEType=="Sword")
				passives = list("HybridStyle" = "MysticStyle", "SweepingStrike" = 1, "BladeFisting" = 1, "MagicSword" = 1, "LifeSteal" = 25, "AbyssMod" = 2,\
				 "Iaijutsu" = 1, "BlurringStrikes"=2.5, "CriticalChance" = 15, "CriticalDamage"= 0.1,"Fury" = 3 )
				StyleSpd = 1.3
				StyleStr = 1.3
				StyleFor = 1
				StyleEnd = 1
				Finisher="/obj/Skills/Queue/Finisher/Dark_Aura"
			else if(SE.SEType=="Staff")
				passives = list("HybridStyle" = "MysticStyle", "SweepingStrike" = 1, "BladeFisting" = 1, "MagicSword" = 1, "LifeSteal" = 25, "AbyssMod" = 2,\
				 "ManaGeneration"=3, "SpiritSword" = 1.25, "MovingCharge"=1, "SpiritFlow" = 3)
				StyleFor = 1.3
				StyleStr = 1.3
				StyleSpd = 1
				StyleEnd = 1
				Finisher="/obj/Skills/Queue/Finisher/Dark_Firaga"
			else if(SE.SEType=="Shield")
				passives = list("HybridStyle" = "MysticStyle", "SweepingStrike" = 1, "BladeFisting" = 1, "MagicSword" = 1, "LifeSteal" = 25, "AbyssMod" = 2,\
				 "Harden"=2, "Momentum" = 1.5, "Pressure" = 1, "BlockChance" = 15)
				StyleEnd = 1.3
				StyleStr = 1.15
				StyleFor = 1.15
				StyleSpd=1
				Finisher="/obj/Skills/Queue/Finisher/Dark_Wave"
		verb/Seeker_of_Darkness()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
	Seeker_of_Darkness_Dual_Wield //"i did it for me"-ass update
		SignatureTechnique = 2
		SagaSignature = 1
		passives = list("BladeFisting" = 1, "MagicSword" = 1, "LifeSteal" = 25, "AbyssMod" = 2)
		ElementalOffense = "Heartless"
		ElementalDefense = "Dark"
		ElementalClass = "Fire"
		StyleActive = "Seeker of Darkness - Silent"
		StyleSpd = 1.3
		StyleStr = 1.3
		Finisher="/obj/Skills/Queue/Finisher/Dark_Aura"
		ManaGlow="#f000e4"
		ManaGlowSize=2
		NeedsSecondSword = 1
		adjust(mob/p)
			if(altered) return
			var/obj/Items/Sword/Medium/Legendary/Soul_Eater/SE=p.EquippedSword()
			if(!SE) return
			if(SE.SEType=="Sword")
				passives = list("HybridStyle" = "MysticStyle", "SweepingStrike" = 1, "BladeFisting" = 1, "MagicSword" = 1, "AbyssMod" = 2,\
				 "Iaijutsu" = 1, "BlurringStrikes"=2.5, "DoubleStrike" = 3, "NeedsSecondSword" = 1,"Fury" = 3 )
				StyleSpd = 1.3
				StyleStr = 1.3
				StyleFor = 1
				StyleEnd = 1
				Finisher="/obj/Skills/Queue/Finisher/Dark_Aura"
			else if(SE.SEType=="Staff")
				passives = list("HybridStyle" = "MysticStyle", "SweepingStrike" = 1, "BladeFisting" = 1, "MagicSword" = 1, "AbyssMod" = 2,\
				 "ManaGeneration"=2, "SpiritSword" = 0.75, "SpiritFlow" = 2, "DualCast"=1, "DoubleStrike" = 3, "NeedsSecondSword" = 1)
				StyleFor = 1.3
				StyleStr = 1.3
				StyleSpd = 1
				StyleEnd = 1
				Finisher="/obj/Skills/Queue/Finisher/Dark_Firaga"
			else if(SE.SEType=="Shield")
				passives = list("HybridStyle" = "MysticStyle", "SweepingStrike" = 1, "BladeFisting" = 1, "MagicSword" = 1, "AbyssMod" = 2,\
				 "Harden"=1, "Momentum" = 2, "BlockChance" = 15, "DoubleStrike" = 3, "NeedsSecondSword" = 1)
				StyleEnd = 1.3
				StyleStr = 1.15
				StyleFor = 1.15
				StyleSpd=1
				Finisher="/obj/Skills/Queue/Finisher/Dark_Wave"
		verb/Seeker_of_Darkness_Dual_Wield()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
/obj/Skills/AutoHit
	Dark_Spear
		Area="Arc"
		NoLock=1
		NoAttackLock=1
		RoundMovement=0
		Distance=8
		Instinct=4
		DamageMult=2
		Rounds=2
		StrOffense=1
		EndDefense=0.75
		TurfErupt=2
		TurfEruptOffset=3
		Earthshaking = 15
		ActiveMessage="unleashes a swing of pure strength forward!"
		HitSparkIcon='Slash - Zan.dmi'
		HitSparkX=-16
		HitSparkY=-16
		HitSparkSize=1
		HitSparkTurns=1
		HitSparkLife=10
		Icon='SweepingKick.dmi'
		IconX=-32
		IconY=-32
		IconTime=10
		Cooldown=4
/obj/Skills/Projectile
	Dark_Firagun
		Distance=50
		AdaptRate=1
		DamageMult=0.5
		HyperHoming=1
		IgnoreStun=1
		ComboMaster=1
		Stunner=5
		MultiHit=20
		AccMult=25
		Knockback = 5
		Radius=4
		Charge=0.33
		Explode=2
		IconLock='Comet.dmi'
		IconSize=0.025
		IconSizeGrowTo=0.75
		Variation=0
/obj/Skills/Queue/Finisher
	Dark_Aura
		SpeedStrike = 3
		SweepStrike = 3
		Quaking=5
		PushOut=1
		DamageMult = 1
		FollowUp="/obj/Skills/Queue/Finisher/Dark_Aura_Combo"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Dark_Aura_Style"
		BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Shredded"
		HitMessage = "breaks off into a relentless pursuit!"
	Dark_Aura_Combo
		Combo=25
		Warp=25
		SpeedStrike = 3
		DamageMult = 0.15
		HitMessage="rips through their opponent with countless slashes!"
		BuffSelf=0
		HitSparkIcon = 'Slash - Vampire.dmi'
	Dark_Firaga
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Dark_Firaga_Style"
		BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Ignited"
		FollowUp="/obj/Skills/Projectile/Dark_Firagun"//Precept_Flame_Emperor"
		DamageMult = 2
		Warp=1
		Stunner = 5
	Dark_Wave
		Warp = 20
		Stunner = 5
		InstantStrikes = 4
		HitMessage="swings a thousand strikes in an instant!"
		FollowUp="/obj/Skills/AutoHit/Dark_Spear"//Comet_Spear"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Dark_Wave_Style"
		DamageMult = 1
