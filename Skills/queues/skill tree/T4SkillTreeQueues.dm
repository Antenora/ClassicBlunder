obj
	Skills
		Queue
			GET_DUNKED
				SkillCost=TIER_5_COST
				Copyable=6
				HitMessage="takes their opponent to the hoop!"
				name="GET DUNKED"
				DamageMult=10.0
				AccuracyMult = 1.175
				Duration=15
				MenuIcon="GetDunked"
				KBMult=20
				KBAdd=20
				PushOut=3
				PushOutWaves=2
				Finisher=1
				Dunker=4
				NoGCD=1
				Warp=5
				Stunner=1
				UnarmedOnly=1
				EnergyCost=8
				Quaking=5
				Explosive=5
				Cooldown=30
				verb/GET_DUNKED()
					set category="Skills"
					set name="GET DUNKED!!"
					usr.SetQueue(src)
			Soukotsu
				SkillCost=TIER_4_COST
				Copyable=5
				name="Soukotsu"
				DamageMult=3.6
				AccuracyMult = 1.1
				Duration=5
				KBAdd=10
				PushOut=3
				PushOutWaves=2
				MenuIcon="Soukotsu"
				InstantStrikes=2
				InstantStrikesDelay=1.5
				Finisher=1
				Warp=3
				Dunker=2
				NoGCD=1
				Instinct=1
				PairBonusSkill="/obj/Skills/Queue/Ikkotsu"
				PairBonusWindow=40
				PairBonusMult=2
				UnarmedOnly=1
				EnergyCost=5
				Quaking=1
				Cooldown=18
				verb/Soukotsu()
					set category="Skills"
					set name="Soukotsu"
					usr.SetQueue(src)
			Curbstomp
				SkillCost=TIER_4_COST
				Copyable=5
				name="Curbstomp"
				DamageMult=8.5
				AccuracyMult = 1.1
				Duration=5
				MenuIcon="Curbstomp"
				KBMult=0.0001
				PushOut=5
				PushOutWaves=3
				Finisher=1
				Warp=1
				Dunker=2
				NoGCD=1
				UnarmedOnly=1
				EnergyCost=5
				Quaking=4
				Cooldown=18
				verb/Curbstomp()
					set category="Skills"
					set name="Curbstomp"
					usr.SetQueue(src)
			Six_Grand_Openings
				SkillCost=TIER_4_COST
				Copyable=5
				name="Six Grand Openings"
				HitMessage="delivers a graceful and crippling blow with their elbow!"
				DamageMult=7.25
				AccuracyMult = 1.175
				Duration=5
				MenuIcon="SixGrandOpenings"
				Counter=1
				NoWhiff=1
				Stunner=0.8
				Dunker=1
				NoGCD=1
				Decider=1
				KBMult=0.0001
				Cooldown=18
				UnarmedOnly=1
				EnergyCost=5
				GrandOpenings=6
				verb/Six_Grand_Openings()
					set category="Skills"
					usr.SetQueue(src)
			Skullcrusher
				SkillCost=TIER_4_COST
				Copyable=5
				name="Skullcrusher"
				HitMessage="brings their elbow down with crushing might!"
				DamageMult=3.85
				InstantStrikes=2
				InstantStrikesDelay=1.5
				AccuracyMult = 1.1
				Duration=5
				MenuIcon="SkullCrusher"
				NoGCD=1
				Stunner=1
				BonusVsStunned=0.25
				KBMult=0.0001
				Cooldown=18
				UnarmedOnly=1
				EnergyCost=5
				verb/Skullcrusher()
					set category="Skills"
					usr.SetQueue(src)