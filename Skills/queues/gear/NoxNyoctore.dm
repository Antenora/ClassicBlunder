obj
	Skills
		Queue
			KokujinYukikaze
				NoTransplant=1
				name="Void Formation: Snow Wind"
				ActiveMessage="enters a peerless stance!"
				HitMessage="rends the opponent apart with <b>Kokujin: YUKIKAZE</b>!"
				DamageMult=4.5
				AccuracyMult = 1.175
				Counter=1
				Warp=2
				Duration=5
				Cooldown=60
				NeedsSword=1
				HitSparkIcon='Slash - Power.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=4
				verb/KokujinYukikaze()
					set category="Skills"
					set name="Void Formation: Snow Wind"
					usr.SetQueue(src)

			ChainRevolver
				NoTransplant=1
				name="Chain Revolver"
				ActiveMessage="begins to dance around their opponents in a display of graceful gun kata!"
				DamageMult=2.5
				AccuracyMult = 1.1
				Duration=10
				Cooldown=60
				Warp=2
				MultiHit=3
				SpiritStrike=1
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				verb/ChainRevolver()
					set category="Skills"
					set name="Chain Revolver"
					usr.SetQueue(src)
