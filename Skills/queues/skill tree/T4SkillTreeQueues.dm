obj
	Skills
		Queue
			GET_DUNKED
				SkillCost=160
				Copyable=4
				name="GET DUNKED"
				DamageMult=6
				AccuracyMult = 1.175
				Duration=5
				KBMult=0.00001
				PushOut=3
				PushOutWaves=2
				Finisher=1
				Dunker=4
				Warp=2
				Stunner=3
				UnarmedOnly=1
				EnergyCost=4
				Quaking=1
				Cooldown=120
				verb/GET_DUNKED()
					set category="Skills"
					set name="Get Dunked"
					usr.SetQueue(src)
			Soukotsu
				SkillCost=TIER_4_COST
				Copyable=5
				name="Soukotsu"
				DamageMult=4
				AccuracyMult = 1.1
				Duration=5
				KBAdd=10
				PushOut=3
				PushOutWaves=2
				InstantStrikes=2
				InstantStrikesDelay=1.5
				Finisher=1
				Warp=3
				Dunker=2
				Stunner=2
				Instinct=1
				UnarmedOnly=1
				EnergyCost=8
				Quaking=1
				Cooldown=120
				verb/Soukotsu()
					set category="Skills"
					set name="Soukotsu"
					usr.SetQueue(src)
			Curbstomp
				SkillCost=TIER_4_COST
				Copyable=5
				name="Curbstomp"
				DamageMult=10
				AccuracyMult = 1.1
				Duration=5
				KBMult=0.0001
				PushOut=5
				PushOutWaves=3
				Finisher=1
				Warp=1
				Dunker=2
				Stunner=2
				UnarmedOnly=1
				EnergyCost=4
				Quaking=4
				Cooldown=120
				verb/Curbstomp()
					set category="Skills"
					set name="Curbstomp"
					usr.SetQueue(src)
			Six_Grand_Openings
				SkillCost=TIER_4_COST
				Copyable=5
				name="Six Grand Openings"
				HitMessage="delivers a graceful and crippling blow with their elbow!"
				DamageMult=8
				AccuracyMult = 1.175
				Duration=5
				Counter=1
				NoWhiff=1
				Crippling=5
				Stunner=2
				Dunker=1
				Decider=1
				KBMult=0.0001
				Cooldown=120
				UnarmedOnly=1
				EnergyCost=5
				verb/Six_Grand_Openings()
					set category="Skills"
					usr.SetQueue(src)
			Skullcrusher
				SkillCost=TIER_4_COST
				Copyable=5
				name="Skullcrusher"
				HitMessage="brings their elbow down with crushing might!"
				DamageMult=5
				InstantStrikes=2
				InstantStrikesDelay=1.5
				AccuracyMult = 1.1
				Duration=5
				Stunner=4
				KBMult=0.0001
				Cooldown=120
				UnarmedOnly=1
				EnergyCost=4
				verb/Skullcrusher()
					set category="Skills"
					usr.SetQueue(src)