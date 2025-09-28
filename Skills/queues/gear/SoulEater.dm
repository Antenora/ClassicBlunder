obj
	Skills
		Queue
			Heart_Slayer
				name="Heart-Slayer"
				ActiveMessage="begins to build darkness on the tip of their blade!"
				DamageMult=2.25
				AccuracyMult = 1.175
				KBMult=0.00001
				Combo=5
				Warp=5
				SpiritHand=0.5
				SpiritSword=0.5
				Duration=10
				Cooldown=40
				NeedsSword=1
				HitSparkIcon='Slash - Black.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				Instinct=2
				EnergyCost=10
				CursedWounds=1
				verb/Heart_Slayer()
					set category="Skills"
					usr.SetQueue(src)
			Riku_Soul_Render
				name="Soul Render"
				ActiveMessage="'s heart is filled with dreadful darkness, as they position themselves for an unthinkable strike .."
				HitMessage="<b><font color='red'> slices into their opponents heart, butchering their soul! </font color> </b>"
				DamageMult=2.25
				AccuracyMult = 1.175
				KBMult=0.00001
				MaimStrike=1
				HitSparkIcon='Slash - Black.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1.1
				Cooldown=150 //once per fight
				Decider=1
				NeedsSword=1
				verb/Riku_Soul_Render()
					set category="Skills"
					usr.SetQueue(src)
			Darkness_Blast
				Stunner=5
				BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Dark_Impulse"
				FollowUp="/obj/Skills/AutoHit/Soul_Blast"
				HitMessage="unleashes a point-blank blast of darkness!"
				verb/Darkness_Blast()
					set category="Skills"
					usr.SetQueue(src)
