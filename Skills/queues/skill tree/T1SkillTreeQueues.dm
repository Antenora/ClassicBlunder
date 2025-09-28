obj
	Skills
		Queue
			//UNARMED
			Ikkotsu
				SkillCost=TIER_1_COST
				Copyable=2
				HitMessage="delivers a destructive one handed strike!!"
				DamageMult=2
				AccuracyMult = 1.1
				Dominator=2
				Crippling=5
				Duration=5
				KBAdd=10
				Launcher=1
				Cooldown=30
				UnarmedOnly=1
				EnergyCost=2
				name="Ikkotsu"
				verb/Ikkotsu()
					set category="Skills"
					set name="Ikkotsu"
					usr.SetQueue(src)
			Showstopper
				SkillCost=TIER_1_COST
				Copyable=2
				HitMessage="delivers a vicious uppercut!!"
				DamageMult=2.2
				AccuracyMult = 1.15
				Launcher=3
				Duration=6
				KBMult=0.00001
				Cooldown=30
				UnarmedOnly=1
				EnergyCost=2
				name="Showstopper"
				verb/Showstopper()
					set category="Skills"
					set name="Showstopper"
					usr.SetQueue(src)
			Dempsey_Roll
				SkillCost=TIER_1_COST
				Copyable=2
				ActiveMessage="punches with precisely articulated strikes to create whirlwind-like pull!"
				name="Dempsey Roll"
				DamageMult=0.33
				AccuracyMult = 1.15
				Determinator=1
				KBMult=0.01
				KBAdd=1
				Duration=8
				Cooldown=30
				UnarmedOnly=1
				Combo=5
				Warp=6
				Stunner=3
				IconLock='dempsey.dmi'
				LockX=-16
				LockY=-16
				PushOut=1
				PushOutIcon='BLANK.dmi'
				EnergyCost=1
				verb/Dempsey_Roll()
					set category="Skills"
					set name="Dempsey Roll"
					usr.SetQueue(src)
			Corkscrew_Blow
				SkillCost=TIER_1_COST
				Copyable=2
				ActiveMessage="strikes with cyclone power!"
				name="Corkscrew Blow"
				DamageMult=0.75
				AccuracyMult = 1.15
				KBAdd=4
				Duration=10
				Cooldown=30
				UnarmedOnly=1
				IconLock='Corkscrew.dmi'
				MultiHit=5
				Warp=4
				EnergyCost=1
				verb/Corkscrew_Blow()
					set category="Skills"
					set name="Corkscrew Blow"
					usr.SetQueue(src)

			Axe_Kick
				SkillCost=40
				Copyable=1
				name="Axe Kick"//Skill name displayed in message.
				HitMessage="brings their heel down in a mighty axe kick!!"
				DamageMult=2
				AccuracyMult = 1.1
				Duration=5
				SpeedStrike=2
				Cooldown=30
				UnarmedOnly=1
				EnergyCost=1.5
				verb/Axe_Kick()
					set category="Skills"
					set name="Axe Kick"//Verb name.
					usr.SetQueue(src)
			Kinshasa
				SkillCost=TIER_1_COST
				Copyable=2
				name="Kinshasa"//Skill name displayed in message.
				HitMessage="builds up speed and knees their target in the face!!"
				DamageMult=2.5
				AccuracyMult = 1.15
				Duration=6
				SpeedStrike=3
				Cooldown=30
				Crippling = 8
				UnarmedOnly=1
				EnergyCost=1.5
				verb/Disable_Innovate()
					set category = "Other"
					disableInnovation(usr)
				adjust(mob/p)
					if(p.isInnovative(HUMAN, "Unarmed") && !isInnovationDisable(p))
						Projectile="/obj/Skills/Projectile/KinshasaProjectile"
					else
						Projectile=null
				verb/Kinshasa()
					set category="Skills"
					set name="Kinshasa"//Verb name.
					adjust(usr)
					usr.SetQueue(src)
			Piston_Kick
				SkillCost=TIER_1_COST
				Copyable=2
				name="Piston Kick"//Skill name displayed in message.
				HitMessage="launches a shattering front kick with their heel!"
				DamageMult=1.8
				Shattering = 12
				HarderTheyFall=0.5
				AccuracyMult = 1.1
				Opener=3
				Duration=5
				Cooldown=30
				UnarmedOnly=1
				EnergyCost=2.5
				verb/Piston_Kick()
					set category="Skills"
					set name="Piston Kick"//Verb name.
					usr.SetQueue(src)
			Cripple
				SkillCost=TIER_1_COST
				Copyable=2
				DamageMult=1.5
				AccuracyMult = 1.15
				Duration=5
				Cooldown=30
				Crippling=50
				SpeedStrike=2
				SweepStrike=2
				UnarmedOnly=1
				EnergyCost=2.5
				HitMessage="delivers a crippling strike!"
				verb/Cripple()
					set category="Skills"
					usr.SetQueue(src)
			Pin
				SkillCost=TIER_1_COST
				Copyable=2
				DamageMult=2.8
				AccuracyMult = 1.15
				Instinct=2
				Grapple=1
				KBMult=0.001
				Warp=3
				SweepStrike=1
				UnarmedOnly=1
				Duration=5
				Cooldown=30
				EnergyCost=2.5
				HitMessage="performs a pinning maneuver!"
				verb/Pin()
					set category="Skills"
					usr.SetQueue(src)

			//UNIVERSAL
			Light_Rush
				NewCost=TIER_1_COST
				NewCopyable=2
				SkillCost=80
				Copyable=3
				DamageMult=0.75
				AccuracyMult = 1.175
				Duration=5
				Combo=4
				Rapid=1
				Cooldown=30
				EnergyCost=10
				IconLock=1
				HitSparkIcon='Hit Effect Divine.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitStep=/obj/Skills/Queue/Light_Rush2
				verb/Light_Rush()
					set category="Skills"
					usr.SetQueue(src)
			Light_Rush2
				DamageMult=0.15
				AccuracyMult=25
				Duration=3
				Warp=10
				Projectile="/obj/Skills/Projectile/RushBlast"
			Burst_Combination
				NewCost=TIER_1_COST
				NewCopyable=2
				name="Burst Combination"
				SkillCost=80
				Copyable=3
				DamageMult=0.15
				AccuracyMult = 1.175
				Stunner=2
				Duration=5
				Combo=10
				Projectile="/obj/Skills/Projectile/BurstBlast"
				ProjectileCount=1
				Cooldown=30
				EnergyCost=3
				IconLock=1
				HitSparkIcon='Hit Effect Satsui.dmi'
				HitSparkX=-32
				HitSparkY=-32
				verb/Burst_Combination()
					set category="Skills"
					usr.SetQueue(src)

			Sword_Clinch
				SkillCost=TIER_1_COST
				Copyable=2
				DamageMult=3
				AccuracyMult = 1.15
				Instinct=2
				Grapple=1
				KBMult=0.001
				Warp=3
				Crippling=6
				NeedsSword = 1
				Duration=5
				Cooldown=30
				EnergyCost=2.5
				HitMessage="secures their opposition with their blade!"
				verb/Sword_Clinch()
					set category="Skills"
					usr.SetQueue(src)