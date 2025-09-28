obj
	Skills
		Queue
			Eldritch_Ruinate
				DamageMult=0.5
				AccuracyMult = 1.1
				Warp=5
				KBAdd=1
				KBMult=0.00001
				Instinct=0
				Combo=10
				HitSparkIcon='Slash - Vampire.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				Duration=5
				ActiveMessage="lets their presence try to overtake their opponents!"
				adjust(mob/p)
					var/ascLevel = 1 + p.AscensionsUnlocked
					var/boon = 3 * ascLevel
					src.Scorching=8 + boon
					src.Freezing=8 + boon
					src.Paralyzing=8 + boon
					src.Shattering=8 + boon
					DamageMult = 0.5 + (ascLevel*0.25)
