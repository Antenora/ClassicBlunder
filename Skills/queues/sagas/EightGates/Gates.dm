obj
	Skills
		Queue
			Front_Lotus
				GateNeeded=1
				UnarmedOnly=1
				DamageMult=4
				AccuracyMult = 1.25
				Stunner=3
				Instinct=4
				Duration=5
				Cooldown=150
				Warp=10
				KBMult=0.001
				Grapple=1
				GrabTrigger="/obj/Skills/Grapple/Lotus_Drop"
				HitMessage="kicks the opponent in the air before initiating a suicidal drop!"
				verb/Front_Lotus()
					set category="Skills"
					usr.SetQueue(src)
			Reverse_Lotus
				GateNeeded=3
				UnarmedOnly=1
				DamageMult=7
				AccuracyMult = 1.25
				Stunner=3
				Instinct=4
				HitStep=/obj/Skills/Queue/Reverse_Lotus2
				Duration=5
				Cooldown=180
				Warp=10
				HitMessage="stuns the opponent with a precise blow; an opening!"
				verb/Reverse_Lotus()
					set category="Skills"
					usr.SetQueue(src)
			Reverse_Lotus2
				GateNeeded=4
				UnarmedOnly=1
				DamageMult=3
				AccuracyMult=1
				Combo=3
				KBAdd=3
				HitStep=/obj/Skills/Queue/Reverse_Lotus3
				MissStep=/obj/Skills/Queue/Reverse_Lotus3
				Step=/obj/Skills/Queue/Reverse_Lotus3
				Duration=5
				Quaking=2
				Warp=10
				HitMessage="tosses the opponent around with a flurry of crushing strikes!"
			Reverse_Lotus3
				GateNeeded=5
				UnarmedOnly=1
				DamageMult=3
				Instinct=4
				AccuracyMult = 1.175
				Duration=5
				PushOut=5
				Quaking=5
				Warp=10
				SpecialEffect="Smash"
				HitMessage="finishes the opponent with a shattering punch!!!"
			Morning_Peacock
				UnarmedOnly=1
				ActiveMessage="radiates burning vigor!"
				HitMessage="expresses their youth with a firestorm of strikes!!!!"
				DamageMult=0.6
				AccuracyMult = 1.25
				KBMult=0.00001
				Launcher=3
				Duration=5
				Instinct=2
				Combo=20
				Finisher=1
				HitStep=/obj/Skills/Queue/GET_DUNKED
				Projectile="/obj/Skills/Projectile/AsaKujaku"
				ProjectileCount=1
				Warp=3
				GateNeeded=6
				Cooldown=-1
				IconLock='Flaming_fists.dmi'
				HitSparkIcon='fevExplosion.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=0.3
				verb/Morning_Peacock()
					set category="Skills"
					usr.SetQueue(src)
