obj
	Skills
		Queue
			Senjin_Shredder
				DamageMult=5
				AccuracyMult=1.2
				Cooldown=60
				Grapple=1
				KBMult=0.001
				PrecisionStrike=5
				Duration=25
				IconLock='PowerClawDeployed.dmi'
				GrabTrigger="/obj/Skills/Grapple/Sword/Senjin_Drive"
				ActiveMessage="'s skirt sprouts a spike!"
				HitMessage="'s skirt hooks their opponent close to them before shredding with countless blades!"
				verb/Senjin_Shredder()
					set category="Skills"
					if(!usr.CheckSpecial("Kamui Senjin")&&!usr.CheckSpecial("Kamui Senjin Shippu"))
						usr << "You need to be using Kamui Senjin or Senjin Shippu to use this!"
						return
					usr.SetQueue(src)

		Grapple
			Sword
				Senjin_Drive
					DamageMult=5
					StrRate=1
					ThrowMult=2
					TriggerMessage="stabs their numerous blades into their opponent and spins before tossing"
					Effect="Shockwave"
					EffectMult=5
