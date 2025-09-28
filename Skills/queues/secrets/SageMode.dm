obj
	Skills
		Queue
			Rasengan
				ActiveMessage="forms a ball of chakra in their hand!"
				HitMessage="slams their opponent with a ball of chakra!"
				AccuracyMult = 1.175
				Paralyzing=1
				KBAdd = 2
				Dunker = 1
				InstantStrikes = 5
				EnergyCost = 6
				Cooldown = 60
				DamageMult = 1
				Duration = 5
				KBMult = 1.15
				Shearing=1
				IconLock = 'Rasengan_DBR.dmi'
				HitSparkIcon = 'Hit Effect Oath.dmi'
				HitSparkX = -32
				HitSparkY = -32
				HitSparkSize = 1.5
				verb/Rasengan()
					set category="Skills"
					usr.SetQueue(src)
			Oodama_Rasengan
				ActiveMessage="forms a massive ball of chakra in their hand!"
				HitMessage="slams their opponent with a massive ball of chakra!"
				AccuracyMult = 1.175
				Paralyzing=1
				KBAdd = 4
				Dunker = 1
				InstantStrikes = 5
				EnergyCost = 6
				ManaCost = 15
				Cooldown = 120
				DamageMult = 1.5
				Delayer=0.25
				Duration = 6
				KBMult = 1.5
				Shearing=3
				IconLock = 'Rasengan_DBR.dmi'
				HitSparkIcon = 'Hit Effect Oath.dmi'
				HitSparkX = -32
				HitSparkY = -32
				HitSparkSize = 1.5
				verb/Oodama_Rasengan()
					set category="Skills"
					usr.SetQueue(src)