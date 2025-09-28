obj
	Skills/AutoHit
		Sword_Pressure
			SkillCost= TIER_1_COST
			Copyable=2
			NeedsSword=1
			Area="Wave"
			Distance=6
			StrOffense=1
			Knockback=5
			HitSparkIcon='Hit Effect Pearl.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkTurns=1
			HitSparkSize=3
			TurfStrike=1
			Slow=1
			DamageMult=2.8
			Cooldown=30
			EnergyCost=3
			ActiveMessage="thrusts their blade forward, causing a powerful wave of pressure!"
			verb/Disable_Innovate()
				set category = "Other"
				disableInnovation(usr)
			adjust(mob/p)
				if(p.isInnovative(HUMAN, "Sword") && !isInnovationDisable(p))
					Area = "Around Target"
					Slow=3
					Knockback=0
					Rounds= 2 + round(p.Potential/25)
					Size = 1 + round(p.Potential/50)
					WindUp=0.5
					Distance = 12
					DistanceAround=4
					DamageMult = 2 + p.Potential/100

				else
					Area = "Wave"
					Slow=0
					Knockback=5
					Rounds = 0
					Size = 0
					WindUp=0
					Distance = 6
					DamageMult=2.8

			verb/Sword_Pressure()
				set category="Skills"
				usr.Activate(src)
		Stinger
			SkillCost= TIER_1_COST
			Copyable=2
			NeedsSword=1
			Area="Strike"
			PassThrough=1
			Distance=4
			StrOffense=1
			NoPierce=1
			Knockback=3
			DamageMult=2.2
			Rush=3
			Cooldown=30
			EnergyCost=2
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
			StrOffense=1
			DamageMult=1.5
			EnergyCost=3
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
			Cooldown=30
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
			StrOffense=1
			EndDefense=1
			DamageMult=3.25
			HitSparkIcon='Slash.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkTurns=1
			HitSparkSize=1.5
			HitSparkDispersion=1
			TurfStrike=2
			TurfShift='Dirt1.dmi'
			TurfShiftDuration=3
			EnergyCost=3
			Cooldown=30
			ActiveMessage="brings their weapon down with a powerful overhead swing!"
			verb/Overhead_Divide()
				set category="Skills"
				usr.Activate(src)


		Arc_Slash
			SkillCost=40
			Copyable=1
			NeedsSword=1
			Area="Arc"
			StrOffense=1
			DamageMult=2.2
			Cooldown=30
			EnergyCost=1
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
			ActiveMessage="swings their blade in a wide arc!"
			verb/Arc_Slash()
				set category="Skills"
				usr.Activate(src)
		Vacuum_Render
			SkillCost= TIER_1_COST
			Copyable=2
			NeedsSword=1
			Area="Arc"
			StrOffense=1
			DamageMult=2
			Shearing=12
			Cooldown=30
			EnergyCost=3
			Distance=3
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
			EnergyCost=1
			ActiveMessage="unleashes a vacuum powered slash!"
			verb/Vacuum_Render()
				set category="Skills"
				usr.Activate(src)
		Hack_n_Slash
			SkillCost= TIER_1_COST
			Copyable=2
			NeedsSword=1
			Area="Arc"
			Distance=3
			StrOffense=1
			DamageMult=0.35
			RoundMovement=0
			ComboMaster=1
			Rounds=10
			Cooldown=30
			EnergyCost=2
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
			EnergyCost=1
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
			Launcher=2
			StrOffense=1
			DamageMult=2.8
			Distance=1
			Crippling=5
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
			EnergyCost=3
			Cooldown=30
			ActiveMessage="slashes for their opponent's legs to cripple them!"
			verb/Hamstring()
				set category="Skills"
				usr.Activate(src)
		Cross_Slash
			SkillCost= TIER_1_COST
			Copyable=2
			NeedsSword=1
			Area="Circle"
			Distance=3
			Rush=2
			StrOffense=1
			DamageMult=1.5
			EnergyCost=3
			HitSparkIcon='Slash - Zan.dmi'
			HitSparkX=-16
			HitSparkY=-16
			HitSparkTurns=1
			HitSparkSize=1.5
			HitSparkDispersion=1
			TurfStrike=1
			TurfShift='Dirt1.dmi'
			TurfShiftDuration=1
			Cooldown=30
			ActiveMessage="swings their weapon in a quick pattern!"
			verb/Disable_Innovate()
				set category = "Other"
				disableInnovation(usr)
			adjust(mob/p)
				if(p.isInnovative(HUMAN, "Sword") && !isInnovationDisable(p))
					Area="Wave"
					PassThrough = 1
					var/pot = p.Potential
					Distance = 4 + (round(pot/25))
					Size = 2 + (round(pot/25))
					DamageMult = 1 + (round(pot/100))
					EnergyCost = 6 + (round(pot/25))
					Rush=0
					FollowUp="/obj/Skills/AutoHit/Cross_Slash_Inno_Follow"
				else
					Distance = 3
					PassThrough = 0
					Size = 1
					Launcher = 0
					StepsDamage = 0
					Rush = 2
					Rounds = 0
					DamageMult = 1.5
					EnergyCost = 3
					Launcher = 0 
					ControlledRush = 0
					Rush = 1 
					FollowUp=null
			verb/Cross_Slash()
				set category="Skills"
				adjust(usr)
				usr.Activate(src)
		
		Cross_Slash_Inno_Follow
			name = "Parting Seas"
			Copyable=0
			NeedsSword=1
			Area="Circle"
			Distance=3
			StrOffense=1
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
			ActiveMessage="swings their weapon in a quick pattern!"
			adjust(mob/p)
				var/pot = p.Potential
				Size = 1 + round(pot/25)
				DamageMult = 0.5
				StepsDamage = 0.1 + round(pot/500)
				Launcher = 2 + round(pot/25)
				ComboMaster = 1
				Rounds = 5
