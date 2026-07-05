obj
	Skills
		Queue
			KokujinYukikaze
				NoTransplant=1
				name="Void Formation: Snow Wind"
				ActiveMessage="enters a peerless stance!"
				HitMessage="rends the opponent apart with <b>Kokujin: YUKIKAZE</b>!"
				DamageMult=15
				AccuracyMult = 1.3
				Counter=1
				Warp=10
				Duration=5
				Cooldown=90
				NeedsSword=1
				HitSparkIcon='Slash - Power.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=4
				ManaCost=25;
				verb/KokujinYukikaze()
					set category="Skills"
					set name="Void Formation: Snow Wind"
					usr.SetQueue(src)

			ChainRevolver
				NoTransplant=1
				name="Chain Revolver"
				ActiveMessage="begins to dance around their opponents in a display of graceful gun kata!"
				DamageMult=2
				AccuracyMult = 1.3
				Duration=10
				Cooldown=60
				Warp=2
				MultiHit=5
				SpiritStrike=1
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				ManaCost=10
				verb/ChainRevolver()
					set category="Skills"
					set name="Chain Revolver"
					usr.SetQueue(src)
