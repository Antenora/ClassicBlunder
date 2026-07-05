obj
	Skills
		Queue
			Vampire_Lunge
				DamageMult=2
				AccuracyMult = 1.1
				Warp=5
				KBAdd=0
				KBMult=0.00001
				LifeSteal=100
				Instinct=4
				HitSparkIcon='Hit Effect Vampire.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1.5
				Duration=5
				ActiveMessage="lets loose a dreaded battlecry as they leap forth!  WRYYYY!!"
				adjust(mob/p)
					var/secretLevel = p.getSecretLevel()
					LifeSteal = min(25 * secretLevel,100)
					Crippling = secretLevel


				//set manually so no verb
			Vampire_Rage
				DamageMult=2
				AccuracyMult = 1.1
				Warp=5
				KBAdd=1
				KBMult=0.00001
				LifeSteal=100
				Instinct=4
				Combo=10
				HitSparkIcon='Slash - Vampire.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				Duration=5
				ActiveMessage="transforms their body into a storm of shadow blades!"
				// this is literally ora ora
				adjust(mob/p)
					var/secretLevel = p.getSecretLevel()
					LifeSteal = min(50 * secretLevel,100)
					Crippling = secretLevel * 1.5