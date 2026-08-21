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
			NoGCD = 1
			MenuIcon="ForcePalm"
			Distance=3
			Knockback=10
			PreShockwave=1
			FocusShifter=1
			FocusShiftBoost=1.5
			PostShockwave=0
			Shockwaves=1
			Shockwave=0.5
			ShockIcon='KenShockwave.dmi'
			ShockBlend=2
			ShockTime=4
			NoPierce=0
			StrScaling=1
			EndEffectiveness=0.9
			DamageMult=3.2
			Cooldown=8
			HitSparkIcon='BLANK.dmi'
			HitSparkX=0
			HitSparkY=0
			EnergyCost=2
			Earthshaking=5
			WindUp=1
			Instinct=1
			WindupMessage="focuses their chi..."
			ActiveMessage="sends a wave of force with a single palm thrust!"
			TurfStrike=1
			TurfShift='Dirt1.dmi'
			TurfShiftDuration=3
			verb/Force_Palm()
				set category="Skills"
				usr.Activate(src)
		Force_Stomp
			SkillCost=TIER_2_COST
			Copyable=3
			UnarmedOnly=1
			Area="Wave"
			ComboMaster=1
			MenuIcon="ForceStomp"
			Distance=6
			StrScaling=1
			DamageMult=2.5
			Cooldown=8
			Stunner=0.8
			Knockback=12
			Size=4
			HitSparkIcon='BLANK.dmi'
			HitSparkX=0
			HitSparkY=0
			Shockwaves=3
			Shockwave=1
			EnergyCost=2
			SpecialAttack=1
			BuffAffected=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/AchillesHeel/Disgruntled
			Earthshaking=15
			ActiveMessage="lifts their leg before performing a tremor-inducing stomp!"
			TurfStrike=1
			TurfShift='Dirt1.dmi'
			TurfShiftDuration=3
			verb/Force_Stomp()
				set category="Skills"
				usr.Activate(src)
		Slashing_Hand_Chop
			SkillCost=TIER_2_COST
			Copyable=3
			UnarmedOnly=1
			Distance=2
			WindUp=1
			ComboMaster=1
			MenuIcon="SlashingHandChop"
			WindupMessage="relaxes their fist into a straight palm..."
			DamageMult=3.15
			StrScaling=1
			ActiveMessage="uses their hand as a blade, trying to cut down their opponent!"
			Area="Target"
			GuardBreak=1
			Silencing=1.5
			HitSparkIcon='Slash - Zan.dmi'
			HitSparkX=-16
			HitSparkY=-16
			HitSparkTurns=1
			HitSparkSize=3
			Cooldown=8
			EnergyCost=2
			Instinct=1
			verb/Slashing_Hand_Chop()
				set category="Skills"
				usr.Activate(src)
		Phantom_Strike
			SkillCost=TIER_2_COST
			Copyable=3
			UnarmedOnly=1
			Area="Wave"
			ComboMaster=1
			GuardBreak=1
			StrScaling=1
			MenuIcon="PhantomRush"
			PassThrough=1
			PreShockwave=1
			PostShockwave=0
			Shockwave=2
			FocusShifter=1
			FocusShiftBoost=1.5
			Shockwaves=2
			DamageMult=0.3
			PhantomMark=2.2
			Knockback=2
			Distance=4
			ActiveMessage="vanishes with a burst of speed to strike at their foe!"
			TurfStrike=1
			TurfShift='Dirt1.dmi'
			TurfShiftDuration=3
			Cooldown=8
			EnergyCost=2
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
			MenuIcon="DragonRush"
			StrScaling=1
			DamageMult=3.2
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
			Cooldown=8
			EnergyCost=2
			ActiveMessage="rushes forward to deliver a flurry of strikes!"
			TurfStrike=1
			TurfShift='Dirt1.dmi'
			TurfShiftDuration=3
			verb/Dragon_Rush()
				set category="Skills"
				usr.Activate(src)

		Sweeping_Kick
			SkillCost=TIER_2_COST
			Copyable=3
			UnarmedOnly=1
			Area="Circle"
			Distance=1
			StrScaling=1
			DamageMult=2.85
			Launcher=3
			MenuIcon="SweepingKick"
			NoLock=1
			NoAttackLock=1
			Cooldown=8
			Size=0.75
			Stunner=0.8
			Icon='SweepingKick.dmi'
			IconX=-32
			IconY=-32
			EnergyCost=2
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
			StrScaling=1
			DamageMult=0.55
			Cooldown=8
			MenuIcon="HelicopterKick"
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
			AlwaysAnnounceCooldown = 1
			NeedsSword=1
			Area="Circle"
			DamageMult=2.75
			Rounds=1
			StrScaling=1
			ChargeTime=0.75
			Cooldown=8
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
				set hidden = 1
				disableInnovation(usr)
			adjust(mob/p)
				if(p.isInnovative(HUMAN, "Sword") && !isInnovationDisable(p))
					GrabTrigger=null
					Rounds = 1
					HealthCost=2
					WoundCost=2
					ManaCost=0
					TurfShift=0
					TurfShiftDuration=0
				else if(p.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(p) && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic))
					GrabTrigger=null
					Rounds = 1
					HealthCost=0
					WoundCost=0
					ManaCost=3
					TurfShift='blackflameaura.dmi'
					TurfShiftDuration=2
				else
					GrabTrigger=null
					HealthCost=0
					WoundCost=0
					ManaCost=0
					Rounds = 1
					TurfShift=0
					TurfShiftDuration=0
				if(p.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(p) && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Corruption))
					CorruptionDebuff = 1
				else
					CorruptionDebuff = 0
				var/idle_secs = p.last_skill_fire_time ? (world.time - p.last_skill_fire_time) / 10 : 10
				DamageMult = 2.75 * min(1 + idle_secs * 0.06, 1.6)
			verb/Three_Thousand_Worlds()
				set category="Skills"
				var/can_fire = !(Using || cooldown_remaining)
				usr.Activate(src)
				applyDemonInnovationEffect(usr, can_fire)
		Oni_Giri
			Copyable=0
			Area="Circle"
			Distance=2
			GrabMaster=1
			DamageMult=2
			Size=2
			HitSparkIcon='Slash.dmi'
			HitSparkX=-32
			HitSparkY=-32
			HitSparkTurns=1
			HitSparkSize=1
			HitSparkDispersion=1
			TurfStrike=1
			GrabTrigger="/obj/Skills/Grapple/Sword/Shank"
		Drill_Spin
			SkillCost= TIER_2_COST
			Copyable=3
			AlwaysAnnounceCooldown = 1
			NeedsSword=1
			Area="Strike"
			ControlledRush=1
			Rush=3
			ChargeTech=1
			ChargeTime=1
			Rounds=5
			StrScaling=1
			EndEffectiveness=0.8
			DamageMult=0.7
			Cooldown=8
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
			EnergyCost=2
			Instinct=1
			ActiveMessage="spins their sword like a drill bit!"
			verb/Disable_Innovate()
				set category = "Other"
				set hidden = 1
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
					Shearing = 0
					TurfErupt=0
					TurfShift=0
					TurfShiftDuration=0
					HitSparkIcon='Slash.dmi'
					HitSparkX=-32
					HitSparkY=-32
				else if(p.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(p) && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic))
					var/pot = p.Potential
					ControlledRush=0
					Rush=0
					ChargeTech=0
					ChargeTime=0
					Size = 2 + (round(pot/25))
					WindUp=0.75
					Knockback = 0.001
					PullIn = Size + 4
					Shearing = 0
					TurfErupt=1
					TurfEruptOffset=4
					TurfShift='blackflameaura.dmi'
					TurfShiftDuration=2
					HitSparkIcon='Hit Effect Dark.dmi'
					HitSparkX=-32
					HitSparkY=-32
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
					Shearing = 0
					TurfErupt=0
					TurfShift='Dirt1.dmi'
					TurfShiftDuration=1
					HitSparkIcon='Slash.dmi'
					HitSparkX=-32
					HitSparkY=-32
				if(p.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(p) && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Corruption))
					CorruptionDebuff = 1
				else
					CorruptionDebuff = 0
			verb/Drill_Spin()
				set category="Skills"
				var/can_fire = !(Using || cooldown_remaining)
				usr.Activate(src)
				applyDemonInnovationEffect(usr, can_fire)
		Rising_Spire
			SkillCost=TIER_2_COST
			Copyable=3
			NeedsSword=1
			Distance=1
			PassThrough=1
			Area="Wave"
			StrScaling=1
			ComboMaster = 1
			DamageMult=3.35
			Cooldown=8
			Knockback=0
			Rounds=1
			Launcher=5
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
			EnergyCost=2
			ActiveMessage="spins upwards with their weapon extended!"
			verb/Rising_Spire()
				set category="Skills"
				usr.Activate(src)
		Ark_Brave
			SkillCost=TIER_2_COST
			Copyable=3
			NeedsSword=1
			Area="Circle"
			StrScaling=1
			EndEffectiveness=1
			DamageMult=3.2
			Cooldown=8
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
			EnergyCost=2
			Earthshaking=10
			GuardBreak=1
			ActiveMessage="releases a hyper destructive slash!"
			verb/Ark_Brave()
				set category="Skills"
				usr.Activate(src)
		Judgment
			SkillCost=TIER_2_COST
			Copyable=3
			NeedsSword=1
			Area="Target"
			Distance=8
			StrScaling=1
			Cooldown = 8
			DamageMult=4.5
			FocusShifter=1
			FocusShiftBoost=1.5
			ComboMaster=1
			Size=2
			EnergyCost=2
			var/tmp/verdict_pending = 0
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
			ActiveMessage="passes down Judgment!"
			verb/Judgment()
				set category="Skills"
				var/mob/caster = usr
				if(Using || cooldown_remaining)
					caster << "<font color='red'>[name] is on cooldown.</font>"
					return
				if(verdict_pending)
					return
				var/mob/T = caster.Target
				if(!T || !ismob(T) || T == caster)
					caster << "<font color='red'>You need a target to pass Judgment on.</font>"
					return
				if(get_dist(caster, T) > Distance)
					caster << "<font color='red'>They are beyond Judgment's reach.</font>"
					return
				if(caster.GCDBlocked(src))
					return
				caster.StartGCD(src)
				verdict_pending = 1
				OMsg(caster, "<b>[caster] marks [T] - the verdict comes in two seconds!</b>")
				var/obj/Effects/HE = new(null, 'Slash - Zan.dmi', -16, 16, 0, 1, 20)
				HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
				HE.Target = T
				T.vis_contents += HE
				spawn(20)
					verdict_pending = 0
					if(!caster || caster.KO || !T || T.KO || T.Health <= 0)
						return
					var/mob/oldT = caster.Target
					caster.Target = T
					var/ng = src.NoGCD
					src.NoGCD = 1
					if(!caster.Activate(src, noGCD=TRUE))
						src.Cooldown(1, null, caster)
					src.NoGCD = ng
					caster.Target = oldT