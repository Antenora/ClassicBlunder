obj
	Skills
		Queue
			//SWORD
			Infinity_Trap
				SkillCost=TIER_2_COST
				Copyable=3
				ActiveMessage="enters a thoughtful stance!"
				DamageMult=0.8
				AccuracyMult = 1.15
				KBMult=0.00001
				Stunner=3
				InstantStrikes=5
				InstantStrikesDelay=0
				Warp=2
				PushOut=1
				PushOutIcon='BLANK.dmi'
				Duration=5
				Cooldown=60
				NeedsSword=1
				EnergyCost=5
				HitSparkIcon='Slash - Zero.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=0.75
				HitSparkTurns=1
				verb/Infinity_Trap()
					set category="Skills"
					usr.SetQueue(src)
			Zero_Reversal
				SkillCost=TIER_2_COST
				Copyable=3
				ActiveMessage="enters a low stance!"
				DamageMult=3
				AccuracyMult = 1.15
				KBMult=0.00001
				SpeedStrike=2
				SweepStrike=2
				Counter=1
				Warp=2
				Duration=5
				Cooldown=60
				NeedsSword=1
				EnergyCost=5
				HitSparkIcon='Slash - Black.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1.5
				verb/Zero_Reversal()
					set category="Skills"
					usr.SetQueue(src)
			Willow_Dance
				SkillCost=TIER_2_COST
				Copyable=3
				ActiveMessage="begins to move fluidly, countering incoming blows!"
				DamageMult=0.9
				AccuracyMult = 1.15
				Duration=8
				Cooldown=60
				Launcher=2
				NeedsSword=1
				MultiHit=3
				InstantStrikes=2
				InstantStrikesDelay=1
				Counter=1
				EnergyCost=4
				verb/Willow_Dance()
					set category="Skills"
					usr.SetQueue(src)
			Gravity_Blade // NEW REPLACEMENT
				SkillCost=TIER_2_COST
				Copyable=3
				HarderTheyFall=3
				Opener=1
				Cooldown=60
				Duration=5
				ActiveMessage="prepares a chain of giant-toppling attacks!"
				DamageMult=1.2
				AccuracyMult=1.1
				NeedsSword=1
				EnergyCost=5
				InstantStrikes=4
				InstantStrikesDelay=1.5
				verb/Gravity_Blade()
					set category="Skills"
					usr.SetQueue(src)
			Larch_Dance // REMOVED
				ActiveMessage="prepares a murderous chain of counterattacks!"
				DamageMult=1.1
				AccuracyMult = 1.1
				Duration=5
				Cooldown=60
				NeedsSword=1
				InstantStrikes=5
				InstantStrikesDelay=1
				Counter=1
				EnergyCost=5
				verb/Larch_Dance()
					set category="Skills"
					usr.SetQueue(src)
