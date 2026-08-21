obj
	Skills
		Queue
			//UNARMED
			Meteor_Combination
				SignatureTechnique=2
				DamageMult=1.65
				AccuracyMult = 1.25
				Duration=5
				KBMult=0.00001
				Cooldown=60
				Instinct=2
				Opener=1
				Stunner=1
				UnarmedOnly=1
				EnergyCost=12
				Quaking=5
				HitStep=/obj/Skills/Queue/Meteor_Combination2
				ChainBlockStop=1
				ActiveMessage="takes a starting position!"
				HitMessage="opens the opponent with a shattering elbow strike!"
				verb/Meteor_Combination()
					set category="Skills"
					usr.SetQueue(src)
			Meteor_Combination2
				HitMessage="follows up with a storm of kicks!"
				DamageMult=1.65
				AccuracyMult = 1.175
				Duration=5
				KBMult=0.00001
				Instinct=3
				Combo=10
				UnarmedOnly=1
				Quaking=2
				EnergyCost=0
				HitStep=/obj/Skills/Queue/Meteor_Combination3
				ChainBlockStop=1
			Meteor_Combination3
				HitMessage="finishes with a murderous uppercut!"
				DamageMult=1.65
				AccuracyMult = 1.25
				Duration=5
				KBAdd=10
				Instinct=4
				Decider=1
				Launcher=1
				UnarmedOnly=1
				Quaking=10
				EnergyCost=0

			Defiance
				SignatureTechnique=2
				HitMessage="defiantly slams their head into the opponent!!"
				DamageMult=8.5
				AccuracyMult = 1.175
				Instinct=3
				MultiHit=4
				Duration=3
				KBMult=3
				Cooldown=60
				Determinator=1
				Counter=1
				UnarmedOnly=1
				EnergyCost=12
				name="Defiance"
				verb/Defiance()
					set category="Skills"
					if(usr.HealthPct() >= 35)
						usr << "<font color='red'>Defiance only answers desperation - below 35% health.</font>"
						return
					usr.SetQueue(src)

			Void_Tiger_Fist
				SignatureTechnique=2
				DamageMult=4.75
				Ashing=1
				AccuracyMult = 1.175
				Warp=2
				Shearing=10
				Instinct=4
				Duration=5
				KBAdd=2
				PushOut=3
				PushOutWaves=2
				InstantStrikes=5
				InstantStrikesDelay=1
				Cooldown=45
				UnarmedOnly=1
				EnergyCost=10
				ActiveMessage="focuses a bubble of vacuum around their fist..."
				HitMessage="unleashes a vacuum burst that tears the opponent apart!"
				verb/Void_Tiger_Fist()
					set category="Skills"
					usr.SetQueue(src)

			Final_Revenger
				SignatureTechnique=2
				DamageMult=18
				StoredPain=1
				AccuracyMult = 1.175
				Determinator=1
				Duration=5
				PushOut=5
				PushOutWaves=5
				Quaking=20
				Instinct=4
				Stunner=1
				KBMult=0.00001
				Cooldown=45
				UnarmedOnly=1
				EnergyCost=10
				IconLock=1
				verb/Final_Revenger()
					set category="Skills"
					usr.SetQueue(src)

			Red_Hot_Hundred
				SignatureTechnique=2
				DamageMult=1.17
				CrescendoRider=1
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
				Cooldown=45
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
				DamageMult=3.05
				AccuracyMult = 1.175
				Instinct=5
				HitStep=/obj/Skills/Queue/True_Kamehameha2
				Duration=5
				Cooldown=60
				Combo=2
				Warp=10
				KBAdd=10
				EnergyCost=12
				IconLock=1
				ActiveMessage="begins to charge a powerful attack while opening their target up with crushing strikes!"
				ComboHitMessages= list("yells: KA... ME...", "yells: HA... ME...")
				verb/True_Kamehameha()
					set category="Skills"
					usr.SetQueue(src)
			True_Kamehameha2
				UnarmedOnly=1
				FocusShifter=1
				FocusShiftType="FOR"
				FocusShiftBoost=2
				DamageMult=3.05
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
				DamageMult=2.9
				AccuracyMult = 1.175
				Instinct=5
				HitStep=/obj/Skills/Queue/Final_Shine2
				Duration=5
				Cooldown=60
				Combo=2
				Warp=10
				KBAdd=10
				EnergyCost=12
				IconLock=1
				ActiveMessage="begins to charge a powerful attack while dominating their target with a rapid assault!"
				verb/Final_Shine()
					set category="Skills"
					usr.SetQueue(src)
			Final_Shine2
				UnarmedOnly=1
				DamageMult=2.9
				AccuracyMult=25
				FocusShifter=1
				FocusShiftType="STR"
				FocusShiftBoost=2
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
				DamageMult=2.95
				AccuracyMult = 1.25
				KBMult=0.00001
				KBAdd=2
				Combo=11
				Warp=3
				Duration=5
				Cooldown=60
				Decider=1
				NeedsSword=1
				Instinct=4
				EnergyCost=12
				CCImmuneCast=60
				HitSparkIcon='Slash - Power.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1.1
				HitStep=/obj/Skills/Queue/Omnislash2
				adjust(mob/p)
					if(p.isInnovative(HUMAN, "Any") && !isInnovationDisable(p) && p.Class == "Heroic")
						name="Furioso"
						ActiveMessage="takes aim with a pair of pistols..."
						HitMessage="opens up their assault with a burst of fire!"
						Stunner=1
						DamageMult=0.5
						AccuracyMult=2
						Combo=2
						Instinct=2
						Cooldown=60
						HitStep=/obj/Skills/Queue/Furioso2
					else
						name="Omnislash"
						ActiveMessage="begins to glow with limitless bravery!"
						DamageMult=2.95
						AccuracyMult = 1.25
						KBMult=0.00001
						KBAdd=2
						Combo=11
						Warp=3
						Duration=5
						Cooldown=60
						Decider=1
						NeedsSword=1
						Instinct=4
						EnergyCost=12
						HitSparkIcon='Slash - Power.dmi'
						HitSparkX=-32
						HitSparkY=-32
						HitSparkTurns=1
						HitSparkSize=1.1
						HitStep=/obj/Skills/Queue/Omnislash2
				verb/Omnislash()
					set category="Skills"
					adjust(usr)
					usr.SetQueue(src)
			Omnislash2
				ActiveMessage="goes for the finishing blow!"
				DamageMult=5.9
				AccuracyMult = 1.25
				KBMult=10
				Warp=5
				Duration=5
				Decider=1
				NeedsSword=1
				Instinct=4
				EnergyCost=0
				CCImmuneCast=60
				IconLock='UltraInstinctSpark.dmi'
				HitSparkIcon='Slash - Power.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=0
				HitSparkSize=2
				verb/Omnislash()
					set category="Skills"
					usr.SetQueue(src)
			Furioso2
				ActiveMessage="charges forward to pierce with a Lance..."
				DamageMult=3.1
				Warp=5
				Launcher=4
				HitStep=/obj/Skills/Queue/Furioso3
				CCImmuneCast=60
			Furioso3
				ActiveMessage="smashes down with a Hammer..."
				Warp=1
				Dunker=3
				NoGCD=1
				DamageMult=2.6
				HitSparkIcon='FevExplosion - Steam.dmi'
				HitStep=/obj/Skills/Queue/Furioso4
				CCImmuneCast=60
			Furioso4
				ActiveMessage="makes a whirlwind of cuts with a Katana..."
				Dunker=2
				NoGCD=1
				Combo=10
				DamageMult=0.5
				Determinator=1
				HitStep=/obj/Skills/Queue/Furioso5
				CCImmuneCast=60
			Furioso5
				ActiveMessage="tears forth with a pair of Claws..."
				Combo=2
				Crippling=5
				DamageMult=1.05
				HitSparkIcon='Claw Markings.dmi'
				HitStep=/obj/Skills/Queue/Furioso6
				CCImmuneCast=60
			Furioso6
				ActiveMessage="hacks forth with an Axe..."
				Combo=3
				Shearing=5
				DamageMult=0.5
				HitStep=/obj/Skills/Queue/Furioso7
				CCImmuneCast=60
			Furioso7
				ActiveMessage="sweeps wide with a Greatsword..."
				DamageMult=1.55
				Launcher=2
				HitStep=/obj/Skills/Queue/Furioso8
				CCImmuneCast=60
			Furioso8
				ActiveMessage="sunders all defense with a blast of a Shotgun..."
				Shattering=50
				Stunner=1
				DamageMult=3.1
				HitStep=/obj/Skills/Queue/Furioso9
				CCImmuneCast=60
			Furioso9
				ActiveMessage="...Rends through space with a peerless Cut!"
				DamageMult=24.8
				AccuracyMult = 1.25
				KBMult=10
				Warp=5
				Duration=5
				Decider=1
				Finisher=1
				NeedsSword=1
				Instinct=4
				EnergyCost=0
				IconLock='UltraInstinctSpark.dmi'
				HitSparkIcon='Slash - Power.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=0
				HitSparkSize=2
				CCImmuneCast=60

