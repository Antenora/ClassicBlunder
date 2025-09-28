obj
	Skills
		Queue
			Shoryuken
				StyleNeeded="Ansatsuken"
				AccuracyMult = 1.25
				Launcher=3
				Duration=5
				Shattering = 2
				Cooldown=40
				proc/resetVars()
					Launcher=initial(Launcher)
					Duration=initial(Duration)
					Cooldown=initial(Cooldown)
					ManaCost=initial(ManaCost)
					ShoryukenEffect=initial(ShoryukenEffect)
				proc/activate(mob/player)
					ManaCost = 0
					Launcher=1
					var/sagaLevel = player.SagaLevel
					var/damage = clamp(1.5 + 1*(sagaLevel), 2, 12)
					var/path = player.AnsatsukenPath == "Shoryuken" ? 1 : 0
					var/cooldown = 40
					var/hitMessage = "strikes their opponent into the air with a fearsome uppercut!!"
					ShoryukenEffect=1
					Shattering = 3 * sagaLevel
					if(path)
						cooldown -= 10
						damage =  clamp(1.5 + 2*(sagaLevel), 2, 13)
					if(player.AnsatsukenAscension=="Satsui")
						Shattering *= 1.25
						GoshoryukenEffect=1
					DamageMult = damage
					HitMessage = hitMessage
					Cooldown = cooldown
				verb/Shoryuken()
					set category="Skills"
					resetVars()
					activate(usr)
					usr.SetQueue(src)
			EX_Shoryuken
				StyleNeeded="Ansatsuken"
				AccuracyMult = 2
				Launcher=3
				Duration=5
				Finisher=1
				Shattering = 25
				Cooldown=150
				ShoryukenEffect=1.5
				ManaCost = 35
				HitMessage = "unleashes the power of the Dragon with an overpowering uppercut!"
				proc/activate(mob/p)
					var/sagaLevel = p.SagaLevel
					if(p.AnsatsukenPath == "Shoryuken")
						DamageMult = clamp(6 + (1.5*sagaLevel), 6, 15)
						Cooldown = 150 - (sagaLevel * 15)
					else
						DamageMult = clamp(4 + (1*sagaLevel), 4, 15)
						Cooldown = 150 - (sagaLevel * 10)
					if(p.AnsatsukenAscension=="Satsui")
						Shattering *= 2
						GoshoryukenEffect=1

				verb/EX_Shoryuken()
					set category="Skills"
					activate(usr)
					usr.SetQueue(src)
			Shinryureppa
				StyleNeeded="Ansatsuken"
				HitMessage="shouts '<b>SHIN...</b>' as they strike their opponent with a rising blow!!!"
				DamageMult=10
				AccuracyMult = 1.25
				KBMult=0.00001
				Cooldown=180
				PushOut=3
				Finisher=1
				ManaCost=100
				Instinct=4
				Duration=10
				Rapid=1
				HitStep=/obj/Skills/Queue/Shinryureppa_chain
				verb/Shinryureppa()
					set category="Skills"
					if(usr.ManaAmount == 0) // just in case ? 
					// i assume all out attack does that and iirc ansat has that too
						return
					usr.SetQueue(src)
			Shinryureppa_chain
				StyleNeeded="Ansatsuken"
				HitMessage="shouts '<b>RYUREPPA!</b>' as they spike their opponent into the heavens with a divine uppercut!!!"
				DamageMult=5
				AccuracyMult = 1.25
				KBMult=0.00001
				Warp=5
				Instinct=4
				ShoryukenEffect=2
				PushOut=3
				Finisher=4
				Duration=5
				Launcher=4
				HitStep=/obj/Skills/Queue/Shinryureppa_dunker
			Shinryureppa_dunker
				StyleNeeded="Ansatsuken"
				HitMessage="shouts '<b>RYUREPPA!</b>' as they spike their opponent into the heavens with a divine uppercut!!!"
				DamageMult=2
				AccuracyMult = 1.25
				KBMult=0.00001
				Warp=5
				Instinct=4
				ShoryukenEffect=2
				PushOut=3
				Finisher = 8
				Duration = 5
				Dunker = 5


			Messatsu_Goshoryu
				GoshoryukenEffect=0.75
				Duration=5
				Warp=5
				Instinct=4
				DamageMult=7.5
				AccuracyMult = 1.25
				KBMult=0.00001
				KBAdd=1
				ManaCost=50
				Stunner=4
				Counter=1
				Rapid=1
				IconLock='BijuuInitial.dmi'
				IconLockUnder=1
				LockX=-32
				LockY=-32
				HitStep=/obj/Skills/Queue/Messatsu_Goshoryu2
				verb/Messatsu_Goshoryu()
					set category="Skills"
					usr.SetQueue(src)
			Messatsu_Goshoryu2
				GoshoryukenEffect=1
				Duration=5
				Warp=5
				Instinct=4
				DamageMult=3
				AccuracyMult = 1.25
				KBMult=0.00001
				KBAdd=1
				Rapid=1
				HitStep=/obj/Skills/Queue/Messatsu_Goshoryu3
			Messatsu_Goshoryu3
				DamageMult=7.5
				GoshoryukenEffect=2
				Duration=5
				Warp=5
				Instinct=4
				DamageMult=7.5
				AccuracyMult = 1.25
				KBMult=0.00001