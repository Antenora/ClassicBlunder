obj
	Skills
		Queue
			//SWORD
			Run_Through
				NeedsSword=1
				SkillCost=TIER_3_COST
				Copyable=3
				ActiveMessage="grips their weapon strongly!"
				HitMessage="runs the opponent through with their weapon!"
				DamageMult=4.0
				AccuracyMult = 1.15
				Duration=5
				Warp=2
				KBMult=0.001
				Grapple=1
				GrabTrigger="/obj/Skills/Grapple/Sword/Blade_Drive"
				EnergyCost=3
				Cooldown=12
				SpeedStrike = 2
				verb/Run_Through()
					set category="Skills"
					usr.SetQueue(src)
