obj
	Skills
		Queue
			DarkImpulseGrab
				ActiveMessage="overflows with the power of darkness!"
				HitMessage="vanishes towards their opponent, smothering them with a malicious claw!"
				DamageMult=3
				AccuracyMult = 1.15
				Duration=5
				Warp=3
				Grapple=1
				KBMult=0.001
				GrabTrigger=0.5
				GoshoryukenEffect=1
				PushOut=2
				PushOutWaves=3
				PushOutIcon='DarkKiai.dmi'
				//No verb since it is set from melee.
			GhostDriveCombo
				DamageMult=0.5
				AccuracyMult = 1.175
				Instinct=4
				KBMult=0.00001
				Combo=10
				Duration=5
				//no verb because it is set from melee

obj/Skills/Queue
	Ars_Arcanum
		DamageMult=2
		AccuracyMult=1.15
		Duration=5
		KBMult=0.00001
		Cooldown=90
		Opener=1
		Stunner=1
		NeedsSword=1
		EnergyCost=1
		Quaking=5
		HitStep=/obj/Skills/Queue/Ars_Arcanum2
		PushOut=1
		PushOutWaves=1
		PushOutIcon='KenShockwaveGold.dmi'
		ActiveMessage="Keyblade covers itself in magical energy!"
		HitMessage="crushes the opponent's guard with a downward stirke!"
		verb/Ars_Arcanum()
			set category="Skills"
			usr.SetQueue(src)
	Ars_Arcanum2
		HitMessage="begins to rapidly pile on strikes with their keyblade!"
		DamageMult=0.5
		AccuracyMult=5
		Duration=5
		KBMult=0.00001
		PushOut=1
		PushOutWaves=1
		PushOutIcon='KenShockwaveGold.dmi'
		Combo=5
		NeedsSword=1
		Quaking=2
		EnergyCost=1
		HitStep=/obj/Skills/Queue/Ars_Arcanum3
	Ars_Arcanum3
		HitMessage="finishes the combo with a powerful jab!"
		DamageMult=1.5
		AccuracyMult=10
		Duration=5
		KBMult=2
		KBAdd=5
		PushOut=1
		PushOutWaves=1
		PushOutIcon='KenShockwaveGold.dmi'
		HolyMod=2
		Decider=1
		NeedsSword=1
		Quaking=10
		EnergyCost=2