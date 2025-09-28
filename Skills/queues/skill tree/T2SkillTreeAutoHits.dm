obj
	Skills/AutoHit
		Force_Palm
			SkillCost=TIER_2_COST
			Copyable=3
			UnarmedOnly=1
			FlickAttack=1
			Area="Cone"
			ComboMaster=1
			Destroyer = 2
			Distance=3
			Knockback=10
			PreShockwave=1
			PostShockwave=0
			Shockwaves=1
			Shockwave=0.5
			ShockIcon='KenShockwave.dmi'
			ShockBlend=2
			ShockTime=4
			NoPierce=0
			StrOffense=1
			EndDefense=0.9
			DamageMult=4.5
			Cooldown=60
			HitSparkIcon='BLANK.dmi'
			HitSparkX=0
			HitSparkY=0
			EnergyCost=3
			Earthshaking=5
			WindUp=1
			Instinct=1
			WindupMessage="focuses their chi..."
			ActiveMessage="sends a wave of force with a single palm thrust!"
			verb/Force_Palm()
				set category="Skills"
				usr.Activate(src)
		Force_Stomp
			SkillCost=TIER_2_COST
			Copyable=3
			UnarmedOnly=1
			Area="Circle"
			ComboMaster=1
			Distance=4
			StrOffense=1
			DamageMult=1
			Cooldown=60
			Stunner=2
			Knockback=12
			Size=4
			HitSparkIcon='BLANK.dmi'
			HitSparkX=0
			HitSparkY=0
			Shockwaves=3
			Shockwave=1
			EnergyCost=3
			SpecialAttack=1
			BuffAffected=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/AchillesHeel/Disgruntled
			Earthshaking=15
			ActiveMessage="lifts their leg before performing a tremor-inducing stomp!"
			verb/Force_Stomp()
				set category="Skills"
				usr.Activate(src)
		Phantom_Strike
			SkillCost=TIER_2_COST
			Copyable=3
			UnarmedOnly=1
			Area="Wave"
			ComboMaster=1
			GuardBreak=1
			StrOffense=1
			PassThrough=1
			PreShockwave=1
			PostShockwave=0
			Shockwave=2
			Shockwaves=2
			DamageMult=5
			Knockback=2
			Distance=4
			ActiveMessage="vanishes with a burst of speed to strike at their foe!"
			Cooldown=60
			EnergyCost=6
			Instinct=1
			verb/Phantom_Strike()
				set category="Skills"
				usr.Activate(src)
		Dragon_Rush
			SkillCost=TIER_2_COST
			Copyable=3
			UnarmedOnly=1
			FlickAttack=1
			Area="Circle"
			NoLock=1
			NoAttackLock=1
			StrOffense=1
			DamageMult=3.5
			DelayTime=0
			PreShockwave=1
			PreShockwaveDelay=1
			PostShockwave=0
			Shockwaves=2
			Shockwave=0.5
			ShockIcon='KenShockwaveLegend.dmi'
			ShockBlend=2
			ShockDiminish=1.15
			ShockTime=4
			Rush=6
			ControlledRush=1
			HitSparkIcon='Hit Effect.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkCount=10
			HitSparkDispersion=12
			Launcher=3
			DelayedLauncher=1
			Cooldown=60
			EnergyCost=5
			ActiveMessage="rushes forward to deliver a flurry of strikes!"
			verb/Dragon_Rush()
				set category="Skills"
				usr.Activate(src)

		Roundhouse_Kick
			SkillCost=TIER_2_COST
			Copyable=2
			UnarmedOnly=1
			Area="Arc"
			ComboMaster=1
			Distance=4
			StrOffense=1
			DamageMult=4.8
			Knockback=3
			Cooldown=60
			Icon='roundhouse.dmi'
			IconX=-16
			IconY=-16
			EnergyCost=2
			ActiveMessage="delivers a roundhouse kick!"
			verb/Roundhouse_Kick()
				set category="Skills"
				usr.Activate(src)
		Sweeping_Kick
			SkillCost=TIER_2_COST
			Copyable=3
			UnarmedOnly=1
			Area="Circle"
			Distance=1
			StrOffense=1
			DamageMult=1.8
			Launcher=3
			NoLock=1
			NoAttackLock=1
			Cooldown=60
			Size=0.75
			Rounds=3
			Icon='SweepingKick.dmi'
			IconX=-32
			IconY=-32
			EnergyCost=3
			CanBeDodged=1
			ActiveMessage="sweeps the legs from under their opponent!"
			verb/Leg_Sweep()
				set category="Skills"
				usr.Activate(src)
		Helicopter_Kick
			SkillCost=TIER_2_COST
			Copyable=3
			UnarmedOnly=1
			Area="Circle"
			StrOffense=1
			DamageMult=1.25
			Cooldown=60
			Rounds=5
			Shattering=1
			RoundMovement=1
			Size=2
			Icon='SweepingKick.dmi'
			IconX=-32
			IconY=-32
			FlickSpin=1
			EnergyCost=2
			ActiveMessage="throws their body into a handstand while delivering numerous spin kick!"
			verb/Helicopter_Kick()
				set category="Skills"
				usr.Activate(src)
		
		Three_Thousand_Worlds
			SkillCost= TIER_2_COST
			Copyable=3
			NeedsSword=1
			Area="Circle"
			DamageMult=2
			Rounds=2
			ChargeTech=1
			StrOffense=1
			ChargeFlight=1
			ChargeTime=0.75
			Grapple=1
			GrabTrigger="/obj/Skills/AutoHit/Oni_Giri"
			GrabMaster=1
			Cooldown=60
			Size=1
			FlickSpin=1
			EnergyCost=2
			NoLock=1
			NoAttackLock=1
			Icon='CircleWind.dmi'
			IconX=-32
			IconY=-32
			HitSparkIcon='Slash.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkTurns=1
			HitSparkSize=1
			HitSparkDispersion=1
			TurfStrike=1
			ActiveMessage="shreds a path forward!"
			verb/Disable_Innovate()
				set category = "Other"
				disableInnovation(usr)
			adjust(mob/p)
				if(p.isInnovative(HUMAN, "Sword") && !isInnovationDisable(p))
					GrabTrigger="/obj/Skills/Grapple/Sword/No_Worries"
					Rounds = 2 + round(p.Potential/25)
					HealthCost=2
					WoundCost=2
				else
					GrabTrigger="/obj/Skills/AutoHit/Oni_Giri"
					HealthCost=0
					WoundCost=0
					Rounds = 2
			verb/Three_Thousand_Worlds()
				set category="Skills"
				adjust(usr)
				usr.Activate(src)
		Oni_Giri
			Copyable=0
			Area="Circle"
			Distance=2
			GrabMaster=1
			DamageMult=2
			AdaptRate=1
			Size=2
			HitSparkIcon='Slash.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkTurns=1
			HitSparkSize=1
			HitSparkDispersion=1
			TurfStrike=1
			GrabTrigger="/obj/Skills/Grapple/Sword/Shank"
		Hero_Spin
			SkillCost=80
			Copyable=2
			NeedsSword=1
			Area="Circle"
			StrOffense=1
			DamageMult=4.8
			Cooldown=60
			Knockback=3
			Size=1
			Icon='CircleWind.dmi'
			IconX=-32
			IconY=-32
			EnergyCost=2
			ActiveMessage="spins with a powerful slash!"
			verb/Hero_Spin()
				set category="Skills"
				usr.Activate(src)
		Drill_Spin
			SkillCost= TIER_2_COST
			Copyable=3
			NeedsSword=1
			Area="Circle"
			Shearing=1
			ControlledRush=1
			Rush=3
			ChargeTech=1
			ChargeTime=1
			Rounds=5
			StrOffense=1
			DamageMult=1
			Cooldown=60
			Knockback=1
			Size=1
			Icon='CircleWind.dmi'
			IconX=-32
			IconY=-32
			HitSparkIcon='Slash.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkTurns=1
			HitSparkSize=1
			HitSparkDispersion=1
			TurfStrike=1
			TurfShift='Dirt1.dmi'
			TurfShiftDuration=1
			EnergyCost=5
			Instinct=1
			ActiveMessage="spins their sword like a drill bit!"
			verb/Disable_Innovate()
				set category = "Other"
				disableInnovation(usr)
			adjust(mob/p)
				if(p.isInnovative(HUMAN, "Sword") && !isInnovationDisable(p))
					var/pot = p.Potential
					ControlledRush=0
					Rush=0
					ChargeTech=0
					ChargeTime=0
					Size = 2 + (round(pot/25))
					WindUp=0.75
					Knockback = 0.001
					PullIn = Size + 4
					Shearing = 5 + (pot/5)

				else
					ControlledRush=1
					Rush=3
					ChargeTech=1
					ChargeTime=1
					Size = 1
					Distance = 1
					Launcher = 0
					WindUp=0
					Knockback = 1
					PullIn = 0
					Shearing = 1
			verb/Drill_Spin()
				set category="Skills"
				adjust(usr)
				usr.Activate(src)
		Rising_Spire
			SkillCost=TIER_2_COST
			Copyable=3
			NeedsSword=1
			Distance=1
			PassThrough=1
			Slow=0.75
			Area="Wave"
			StrOffense=1
			ComboMaster = 1
			DamageMult=1
			Cooldown=60
			Knockback=0
			Rounds=4
			Launcher=2
			NoLock=1
			NoAttackLock=1
			Size=2
			Icon='CircleWind.dmi'
			IconX=-32
			IconY=-32
			HitSparkIcon='Slash.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkTurns=1
			HitSparkSize=1
			HitSparkDispersion=1
			TurfStrike=1
			EnergyCost=4
			ActiveMessage="spins upwards with their weapon extended!"
			verb/Rising_Spire()
				set category="Skills"
				usr.Activate(src)
		Ark_Brave
			SkillCost=TIER_2_COST
			Copyable=3
			NeedsSword=1
			Area="Circle"
			StrOffense=1
			EndDefense=1
			DamageMult=5
			Cooldown=60
			Knockback=5
			Size=2
			Distance=2
			Rush=2
			ControlledRush=1
			RoundMovement=0
			WindUp=1
			WindupMessage="charges their blade with imperial willpower!"
			Icon='SweepingKick.dmi'
			IconX=-32
			IconY=-32
			HitSparkIcon='Slash.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkTurns=1
			HitSparkSize=1
			HitSparkDispersion=1
			TurfStrike=1
			TurfShift='Dirt1.dmi'
			TurfShiftDuration=3
			EnergyCost=10
			Earthshaking=10
			ActiveMessage="releases a hyper destructive slash!"
			verb/Ark_Brave()
				set category="Skills"
				usr.Activate(src)
		Judgment
			SkillCost=TIER_2_COST
			Copyable=3
			NeedsSword=1
			Area="Circle"
			StrOffense=1
			Cooldown = 60
			DamageMult=0.35
			Rounds=20
			ComboMaster=1
			Size=2
			EnergyCost=5
			Icon='CircleWind.dmi'
			IconX=-32
			IconY=-32
			HitSparkIcon='Slash - Zan.dmi'
			HitSparkX=-16
			HitSparkY=-16
			HitSparkTurns=1
			HitSparkSize=1
			HitSparkDispersion=1
			TurfStrike=1
			ActiveMessage="spins for glory!"
			verb/Judgment()
				set category="Skills"
				usr.Activate(src)