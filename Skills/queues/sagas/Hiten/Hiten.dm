obj
	Skills
		Queue
			JawStrike//t1
				name="Ryushosen"
				StyleNeeded="Hiten Mitsurugi"
				DamageMult=2
				AccuracyMult = 4
				SpeedStrike=2
				KBMult=0.0001
				Launcher=3
				Rapid=1
				Duration=5
				Cooldown=30
				EnergyCost=2
				HitMessage="strikes their opponent in the jaw with the flat of their sword!"
				verb/Ryushosen()
					set category="Skills"
					usr.SetQueue(src)
			FallingBlade//t1
				name="Ryutsuisen"
				StyleNeeded="Hiten Mitsurugi"
				DamageMult=2.5
				AccuracyMult = 4
				SpeedStrike=2
				Dunker=2
				Rapid=1
				Duration=5
				Cooldown=30
				EnergyCost=2
				HitMessage="jumps up and brings their blade down to add momentum to their strike!"
				verb/Ryutsuisen()
					set category="Skills"
					usr.SetQueue(src)
			Twin_Dragon_Slash
				name="Souryusen"
				StyleNeeded="Hiten Mitsurugi"
				DamageMult=5
				AccuracyMult = 1.2
				KBMult=0.0001
				SpeedStrike=2
				Duration=5
				Instinct=3
				Cooldown=120
				Rapid=1
				EnergyCost=5
				HitMessage="strikes with their blade faster than the eye can see!"
				HitStep=/obj/Skills/Queue/Sheath_Strike
				MissStep=/obj/Skills/Queue/Sheath_Strike
				verb/Souryusen()
					set category="Skills"
					usr.SetQueue(src)
			Sheath_Strike
				HitMessage="whips their sheath to follow up with their blade!"
				DamageMult=1
				AccuracyMult = 1.2
				KBMult=2
				SpeedStrike=4
				Warp=3
				Shattering=5
				Stunner=2
				Duration=5
				NeedsSword=1
				Instinct=4
				Rapid=1
				HitSparkIcon='Hit Effect.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1.5
			Nine_Dragons_Strike
				name="Kuzuryusen"
				StyleNeeded="Hiten Mitsurugi"
				DamageMult=0.75
				AccuracyMult = 1.25
				KBMult=0.00001
				SpeedStrike=6
				InstantStrikes=9
				InstantStrikesDelay=1
				//do the combo message thing
				Warp=10
				Duration=20
				Finisher=1
				Cooldown=180
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=4
				HitSparkDispersion=1
				PushOut=1
				Rapid=1
				PushOutIcon='BLANK.dmi'
				Instinct=4
				EnergyCost=5
				verb/Kuzuryusen()
					set category="Skills"
					usr.SetQueue(src)
			Heavenly_Dragon_Flash
				name="Amakakeru Ryuu no Hirameki"
				StyleNeeded="Hiten Mitsurugi"
				Duration=8
				DamageMult=8
				SpeedStrike=10
				AccuracyMult=1
				KBMult=0.00001
				Warp=10
				Instinct=4
				DrawIn=4
				Determinator=1
				Finisher=1
				Rapid=1
				Counter=1
				NoWhiff=1
				Cooldown=-1
				HitSparkIcon='Slash - Power.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=2
				PushOut=5
				AllOutAttack=1
				PushOutIcon='BLANK.dmi'
				HitStep=/obj/Skills/Queue/Heavenly_Dragon_Claw
				MissStep=/obj/Skills/Queue/Heavenly_Dragon_Claw
				ActiveMessage="grips the handle of their blade tightly!"
				HitMessage="utilizes a stutter-step to surpass godspeed with a single blow!"
				MissMessage="generates a powerful vacuum as their slash is blocked, drawing the opponent in!!!"
				verb/Amakakeru_Ryuu_no_Hirameki()
					set category="Skills"
					usr.SetQueue(src)
			Heavenly_Dragon_Claw
				StyleNeeded="Hiten Mitsurugi"
				Duration=10
				DamageMult=8 // but gimp damage since u will be doing 3x
				SpeedStrike=10 // p much get all ur speed
				AccuracyMult=20
				KBAdd=10
				Warp=10
				Instinct=10
				Quaking=10
				Rapid=1
				Counter=1
				NoWhiff=1
				Determinator=1
				Decider=1
				Finisher=1
				HitSparkIcon='Slash - Power.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=3
				HitMessage="throws all of their momentum into a centrifugal force-powered finishing blow!!!"