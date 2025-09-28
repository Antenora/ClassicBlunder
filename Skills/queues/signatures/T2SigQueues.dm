obj
	Skills
		Queue
			//UNARMED
			Meteor_Combination
				SignatureTechnique=2
				DamageMult=10
				AccuracyMult = 1.25
				Duration=5
				KBMult=0.00001
				Cooldown=180
				Instinct=2
				Opener=1
				Stunner=3
				UnarmedOnly=1
				EnergyCost=5
				Quaking=5
				HitStep=/obj/Skills/Queue/Meteor_Combination2
				ActiveMessage="takes a starting position!"
				HitMessage="opens the opponent with a shattering elbow strike!"
				verb/Meteor_Combination()
					set category="Skills"
					usr.SetQueue(src)
			Meteor_Combination2
				HitMessage="follows up with a storm of kicks!"
				DamageMult=0.5
				AccuracyMult = 1.175
				Duration=5
				KBMult=0.00001
				Instinct=3
				Combo=10
				UnarmedOnly=1
				Quaking=2
				EnergyCost=5
				HitStep=/obj/Skills/Queue/Meteor_Combination3
			Meteor_Combination3
				HitMessage="finishes with a murderous uppercut!"
				DamageMult=6
				AccuracyMult = 1.25
				Duration=5
				KBAdd=10
				Instinct=4
				Decider=1
				Launcher=1
				UnarmedOnly=1
				Quaking=10
				EnergyCost=10

			Defiance
				SignatureTechnique=2
				HitMessage="defiantly slams their head into the opponent!!"
				DamageMult=15
				AccuracyMult = 1.175
				Instinct=3
				Duration=5
				KBMult=3
				Cooldown=180
				Determinator=1
				Counter=1
				UnarmedOnly=1
				EnergyCost=10
				name="Defiance"
				verb/Defiance()
					set category="Skills"
					usr.SetQueue(src)

			Void_Tiger_Fist
				SignatureTechnique=2
				DamageMult=3.6
				AccuracyMult = 1.175
				Warp=2
				Shearing=5
				Instinct=4
				Duration=5
				KBAdd=2
				PushOut=3
				PushOutWaves=2
				InstantStrikes=5
				InstantStrikesDelay=1
				Cooldown=180
				UnarmedOnly=1
				EnergyCost=10
				ActiveMessage="focuses a bubble of vacuum around their fist..."
				HitMessage="unleashes a vacuum burst that tears the opponent apart!"
				verb/Void_Tiger_Fist()
					set category="Skills"
					usr.SetQueue(src)

			Final_Revenger
				SignatureTechnique=2
				DamageMult=15
				AccuracyMult = 1.175
				Determinator=1
				Duration=5
				PushOut=5
				PushOutWaves=5
				Quaking=20
				Instinct=4
				Stunner=3
				KBMult=0.00001
				Cooldown=180
				UnarmedOnly=1
				EnergyCost=10
				IconLock=1
				verb/Final_Revenger()
					set category="Skills"
					usr.SetQueue(src)

			Red_Hot_Hundred
				SignatureTechnique=2
				DamageMult=0.75
				AccuracyMult = 1.175
				Warp=5
				KBAdd=1
				KBMult=0.00001
				Combo=25
				Rapid=1
				Instinct=2
				IconLock='Flaming_fists.dmi'
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				Duration=5
				Cooldown=180
				UnarmedOnly=1
				EnergyCost=10
				ActiveMessage="blurs forward with a storm of countless attacks!"
				verb/Red_Hot_Hundred()
					set category="Skills"
					usr.SetQueue(src)

			//UNIVERSAL
			True_Kamehameha
				PreRequisite=list("/obj/Skills/Projectile/Beams/Big/Super_Kamehameha")
				SignatureTechnique=2
				UnarmedOnly=1
				DamageMult=4
				AccuracyMult = 1.175
				Instinct=5
				HitStep=/obj/Skills/Queue/True_Kamehameha2
				Duration=5
				Cooldown=180
				Combo=2
				Warp=10
				KBAdd=10
				EnergyCost=10
				IconLock=1
				ActiveMessage="begins to charge a powerful attack while opening their target up with crushing strikes!"
				ComboHitMessages=list(1="yells: KA... ME...", 2="yells: HA... ME...")
				verb/True_Kamehameha()
					set category="Skills"
					usr.SetQueue(src)
			True_Kamehameha2
				UnarmedOnly=1
				DamageMult=5
				AccuracyMult=25
				Instinct=5
				Duration=8
				Warp=10
				HitMessage="yells: HAAAAAAAAAA!"
				Projectile="/obj/Skills/Projectile/Beams/Big/True_Kamehameha"
				ProjectileBeam=1

			Final_Shine
				PreRequisite=list("/obj/Skills/Projectile/Beams/Big/Final_Flash")
				SignatureTechnique=2
				UnarmedOnly=1
				DamageMult=12
				AccuracyMult = 1.175
				Instinct=5
				HitStep=/obj/Skills/Queue/Final_Shine2
				Duration=5
				Cooldown=180
				Combo=2
				Warp=10
				KBAdd=10
				EnergyCost=10
				IconLock=1
				ActiveMessage="begins to charge a powerful attack while dominating their target with a rapid assault!"
				verb/Final_Shine()
					set category="Skills"
					usr.SetQueue(src)
			Final_Shine2
				UnarmedOnly=1
				DamageMult=5
				AccuracyMult=25
				Instinct=5
				Duration=3
				Warp=10
				Projectile="/obj/Skills/Projectile/Beams/Big/Final_Shine"
				ProjectileBeam=1

			//ARMED
			Omnislash
				SignatureTechnique=2
				name="Omnislash"
				ActiveMessage="begins to glow with limitless bravery!"
				DamageMult=0.5
				AccuracyMult = 1.25
				KBMult=0.00001
				KBAdd=2
				Combo=12
				Warp=3
				Duration=5
				Cooldown=-1 //once per fight
				Decider=1
				NeedsSword=1
				Instinct=4
				EnergyCost=5
				HitSparkIcon='Slash - Power.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1.1
				HitStep=/obj/Skills/Queue/Omnislash2
				verb/Omnislash()
					set category="Skills"
					usr.SetQueue(src)
			Omnislash2
				ActiveMessage="goes for the finishing blow!"
				DamageMult=12
				AccuracyMult = 1.25
				KBMult=10
				Warp=5
				Duration=5
				Decider=1
				NeedsSword=1
				Instinct=4
				EnergyCost=10
				IconLock='UltraInstinctSpark.dmi'
				HitSparkIcon='Slash - Power.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=0
				HitSparkSize=2
				verb/Omnislash()
					set category="Skills"
					usr.SetQueue(src)

