obj
	Skills/AutoHit
		Sword_Pressure
			SkillCost= TIER_1_COST
			Copyable=2
			AlwaysAnnounceCooldown = 1
			NeedsSword=1
			Area="Wave"
			Distance=6
			StrScaling=1
			Knockback=5
			HitSparkIcon='Hit Effect Pearl.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkTurns=1
			HitSparkSize=3
			TurfStrike=1
			Slow=1
			DamageMult=2.1
			Cooldown=5
			EnergyCost=1
			ActiveMessage="thrusts their blade forward, causing a powerful wave of pressure!"
			adjust(mob/p)
				if(p.isInnovative(HUMAN, "Sword") && !isInnovationDisable(p))
					Area="Around Target"
					Slow=3
					Knockback=0
					Rounds= 2
					Size= 1 + round(p.Potential/50)
					WindUp=0.5
					Distance= 12
					DistanceAround=4
					DamageMult= (1.3 + p.Potential/100*(1.3/2.8)) * 0.8
					Stunner=0
					Shearing=0
					HitSparkIcon='Hit Effect Pearl.dmi'
					HitSparkX=-32
					HitSparkY=-32
					HitSparkTurns=1
					HitSparkSize=3
					ActiveMessage="traps their foe in a bubble of Pressure with a thrust of their blade!"
				else if(p.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(p) && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic))
					Area="Around Target"
					Slow=3
					Knockback=0
					Rounds= 2
					Size= 1 + round(p.Potential/50)
					WindUp=0.5
					Distance= 12
					DistanceAround=4
					DamageMult= (1.3 + p.Potential/100*(1.3/2.8)) * 0.8
					Stunner=0.3
					Shearing=round(p.Potential/25)
					HitSparkIcon='Hit Effect Dark.dmi'
					HitSparkX=-32
					HitSparkY=-32
					HitSparkTurns=1
					HitSparkSize=3
					ActiveMessage="traps their foe in a bubble of Dark Pressure with a thrust of their blade!"
				else
					Area="Wave"
					Slow=0
					Knockback=5
					Rounds = 0
					Size = 0
					WindUp=0
					Distance = 6
					DamageMult=2.1
					Stunner=0
					Shearing=0
					HitSparkIcon='Hit Effect Pearl.dmi'
					HitSparkX=-32
					HitSparkY=-32
					HitSparkTurns=1
					HitSparkSize=3
				if(p.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(p) && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Corruption))
					CorruptionDebuff = 1
				else
					CorruptionDebuff = 0
			verb/Sword_Pressure()
				set category="Skills"
				var/can_fire = !(Using || cooldown_remaining)
				usr.Activate(src)
				applyDemonInnovationEffect(usr, can_fire)
			verb/Disable_Innovate()
				set category = "Other"
				set hidden = 1
				disableInnovation(usr)
		Stinger
			SkillCost= TIER_1_COST
			Copyable=2
			NeedsSword=1
			Area="Strike"
			PassThrough=1
			Distance=4
			StrScaling=1
			NoPierce=1
			Knockback=3
			DamageMult=2.05
			Rush=3
			Cooldown=5
			EnergyCost=1
			ActiveMessage="dashes forward with a jousting strike!"
			verb/Stinger()
				set category="Skills"
				usr.Activate(src)
		Light_Step
			SkillCost= TIER_1_COST
			Copyable=4
			NeedsSword=1
			Area="Wave"
			Distance=4
			PassThrough=1
			FocusShifter=1
			FocusShiftBoost=1.5
			StrScaling=1
			DamageMult=2.1
			EnergyCost=1
			Rounds = 1
			HitSparkIcon='Slash.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkTurns=1
			HitSparkSize= 0.65
			HitSparkDelay = 1
			HitSparkLife = 5
			HitSparkCount = 4
			HitSparkDispersion = 12
			TurfStrike = 1
			PreShockwave = 1
			Shockwave = 1
			Shockwaves = 1
			SpeedStrike = 1
			Cooldown=5
			ActiveMessage="bursts forward with a lightning-fast slash!"
			verb/Light_Step()
				set category="Skills"
				usr.Activate(src)
		Overhead_Divide
			SkillCost= TIER_1_COST
			Copyable=2
			NeedsSword=1
			Area="Wave"
			ComboMaster=1
			Distance=2
			StrScaling=1
			EndEffectiveness=1
			DamageMult=2.35
			GuardBreak=1
			WindUp=1
			HitSparkIcon='Slash.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkTurns=1
			HitSparkSize=1.5
			HitSparkDispersion=1
			TurfStrike=2
			TurfShift='Dirt1.dmi'
			TurfShiftDuration=3
			EnergyCost=1
			Cooldown=5
			ActiveMessage="brings their weapon down with a powerful overhead swing!"
			verb/Overhead_Divide()
				set category="Skills"
				usr.Activate(src)


		Vacuum_Render
			SkillCost= TIER_1_COST
			Copyable=2
			NeedsSword=1
			Area="Arc"
			StrScaling=1
			DamageMult=1.6
			Shearing=12
			FocusShifter=1
			FocusShiftBoost=1.5
			Cooldown=5
			EnergyCost=1
			Distance=3
			BlockEffectiveness=0.5
			Size=2.5
			Icon='roundhouse.dmi'
			IconX=-16
			IconY=-16
			HitSparkIcon='Slash.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkTurns=1
			HitSparkSize=1.5
			HitSparkDispersion=1
			TurfStrike=1
			TurfShift='Dirt1.dmi'
			TurfShiftDuration=1
			ActiveMessage="unleashes a vacuum powered slash!"
			verb/Vacuum_Render()
				set category="Skills"
				usr.Activate(src)
		Hack_n_Slash
			SkillCost= TIER_1_COST
			Copyable=2
			NeedsSword=1
			FinaleDouble=1
			Area="Arc"
			Distance=3
			StrScaling=1
			DamageMult=0.8
			RoundMovement=0
			FocusShifter=1
			FocusShiftBoost=1.5
			ComboMaster=1
			Rounds=3
			Cooldown=5
			EnergyCost=1
			Icon='Nest Slash.dmi'
			IconX=-16
			IconY=-16
			Size=1.5
			HitSparkIcon='Slash.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkTurns=1
			HitSparkSize=1
			HitSparkDispersion=1
			TurfStrike=1
			Instinct=1
			ActiveMessage="flourishes their blade in a series of strokes!"
			verb/Hack_n_Slash()
				set name="Hack'n'Slash"
				set category="Skills"
				usr.Activate(src)
		Hamstring
			SkillCost= TIER_1_COST
			Copyable=2
			NeedsSword=1
			Area="Arc"
			Rush = 2
			ControlledRush = 1
			StrScaling=1
			DamageMult=1.8
			Distance=1
			Crippling=5
			BonusVsSlowed=0.5
			Icon='roundhouse.dmi'
			IconX=-16
			IconY=-16
			HitSparkIcon='Slash.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkTurns=1
			HitSparkSize=1
			HitSparkDispersion=1
			TurfStrike=1
			TurfShift='Dirt1.dmi'
			TurfShiftDuration=1
			EnergyCost=1
			Cooldown=5
			ActiveMessage="slashes for their opponent's legs to cripple them!"
			verb/Hamstring()
				set category="Skills"
				usr.Activate(src)
		Cross_Slash
			SkillCost= TIER_1_COST
			Copyable=2
			AlwaysAnnounceCooldown = 1
			NeedsSword=1
			Area="Circle"
			Distance=3
			Rush=2
			StrScaling=1
			DamageMult=2.3
			Paralyzing=5
			EnergyCost=1
			HitSparkIcon='Slash - Zan.dmi'
			HitSparkX=-16
			HitSparkY=-16
			HitSparkTurns=1
			HitSparkSize=1.5
			HitSparkDispersion=1
			TurfStrike=1
			TurfShift='Dirt1.dmi'
			TurfShiftDuration=1
			Cooldown=5
			SequenceStrokes=3
			ActiveMessage="swings their weapon in a quick pattern!"
			verb/Disable_Innovate()
				set category = "Other"
				set hidden = 1
				disableInnovation(usr)
			adjust(mob/p)
				if(p.isInnovative(HUMAN, "Sword") && !isInnovationDisable(p))
					Area="Wave"
					PassThrough = 1
					var/pot = p.Potential
					Distance = 4 + (round(pot/25))
					Size = 2 + (round(pot/25))
					DamageMult = 1.4 + (round(pot/100))*(1.4/1.5)
					EnergyCost = 2
					Rush=0
					HitSparkIcon='Slash - Zan.dmi'
					HitSparkX=-16
					HitSparkY=-16
					FollowUp="/obj/Skills/AutoHit/Cross_Slash_Inno_Follow"
					SequenceStrokes=1
				else if(p.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(p) && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic))
					Area="Wave"
					PassThrough = 1
					var/pot = p.Potential
					Distance = 4 + (round(pot/25))
					Size = 2 + (round(pot/25))
					DamageMult = 1.4 + (round(pot/100))*(1.4/1.5)
					EnergyCost = 2
					Rush=0
					HitSparkIcon='Slash - Hellfire.dmi'
					HitSparkX=-16
					HitSparkY=-16
					FollowUp="/obj/Skills/AutoHit/Cross_Slash_Demon_Follow"
					SequenceStrokes=1
				else
					Area="Circle"
					Distance = 3
					PassThrough = 0
					Size = 1
					Launcher = 0
					StepsDamage = 0
					Rush = 2
					Rounds = 0
					DamageMult = 2.3
					EnergyCost = 1
					Launcher = 0
					ControlledRush = 0
					Rush = 1
					HitSparkIcon='Slash - Zan.dmi'
					HitSparkX=-16
					HitSparkY=-16
					FollowUp=null
					SequenceStrokes=3
				if(p.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(p) && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Corruption))
					CorruptionDebuff = 1
				else
					CorruptionDebuff = 0
			verb/Cross_Slash()
				set category="Skills"
				var/can_fire = !(Using || cooldown_remaining)
				usr.Activate(src)
				applyDemonInnovationEffect(usr, can_fire)

		Cross_Slash_Inno_Follow
			name = "Parting Seas"
			Copyable=0
			AlwaysAnnounceCooldown = 1
			NeedsSword=1
			Area="Circle"
			Distance=3
			StrScaling=1
			NoAttackLock=1
			DamageMult=1
			Icon='BladeCharge.dmi'
			IconX=-32
			IconY=-32
			HitSparkIcon='Slash - Zan.dmi'
			HitSparkX=-16
			HitSparkY=-16
			HitSparkTurns=1
			HitSparkSize=1.5
			HitSparkDispersion=1
			Cooldown=30
			ActiveMessage="passes forth with their blade, cleaving through misfortune!"
			adjust(mob/p)
				var/pot = p.Potential
				Size = 1 + round(pot/25)
				DamageMult = 0.45
				StepsDamage = 0.1 + round(pot/500)
				Launcher = 2 + round(pot/25)
				ComboMaster = 1
				Rounds = 2

		Cross_Slash_Demon_Follow
			name = "Infernal Divide"
			Copyable=0
			AlwaysAnnounceCooldown = 1
			NeedsSword=1
			Area="Circle"
			Distance=3
			StrScaling=1
			NoAttackLock=1
			DamageMult=1
			Icon='DarknessFlameAura.dmi'
			IconX=-32
			IconY=-32
			HitSparkIcon='Slash - Hellfire.dmi'
			HitSparkX=-16
			HitSparkY=-16
			HitSparkTurns=1
			HitSparkSize=1.5
			HitSparkDispersion=1
			TurfStrike=1
			TurfShift='blackflameaura.dmi'
			TurfShiftDuration=3
			Cooldown=30
			ActiveMessage="erupts their blade in a burst of infernal hellfire!"
			adjust(mob/p)
				var/pot = p.Potential
				Size = 1 + round(pot/25)
				DamageMult = 0.5
				Shearing = round(pot/20)
				StepsDamage = 0.1 + round(pot/500)
				Launcher = 2 + round(pot/25)
				ComboMaster = 1
				Rounds = 5
