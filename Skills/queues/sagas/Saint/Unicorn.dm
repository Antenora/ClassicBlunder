obj
	Skills
		Queue
			Unicorn_Combination
				DamageMult=6
				AccuracyMult = 1.25
				Duration=5
				KBMult=0.00001
				Cooldown=180
				Instinct=2
				Opener=1
				Stunner=3
				UnarmedOnly=1
				EnergyCost=5
				Quaking=5
				HitStep=/obj/Skills/Queue/Unicorn_Combination2
				ActiveMessage="takes a starting position!"
				HitMessage="opens the opponent with a twisting frontal kick!"
				verb/Celestial_Trot()
					set category="Skills"
					usr.SetQueue(src)
			Unicorn_Combination2
				HitMessage="follows up with a storm of roundhouse kicks!"
				DamageMult=0.5
				AccuracyMult = 1.175
				Duration=5
				KBMult=0.00001
				Instinct=3
				Combo=10
				UnarmedOnly=1
				Quaking=2
				EnergyCost=5
				HitStep=/obj/Skills/Queue/Unicorn_Combination3
			Unicorn_Combination3
				HitMessage="finishes with a murderous mule kick!"
				DamageMult=6
				AccuracyMult = 1.25
				Duration=5
				KBAdd=10
				Instinct=4
				Decider=1
				Launcher=1
				UnarmedOnly=1
				Quaking=10
				EnergyCost=10