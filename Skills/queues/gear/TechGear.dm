obj
	Skills
		Queue
			Gear
				Pile_Bunker
					DamageMult=9
					AccuracyMult = 1.175
					HybridStrike=0.5
					SpiritHand=1
					Steady=5
					Duration=10
					PushOut=2
					Explosive=2
					HitSparkIcon='Hit Effect Ripple.dmi'
					HitSparkX=-32
					HitSparkY=-32
					HitSparkSize=2
					KBAdd=10
					KBMult=2
					Shattering=10
					Crippling=3
					Cooldown=180
					ActiveMessage="deploys a massive metal spike..."
					HitMessage="drives their devastating Pile Bunker forward!"
					verb/Pile_Bunker()
						set category="Skills"
						if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
							return
						usr.SetQueue(src)
				Power_Fist
					NoSword=1
					DamageMult=8
					AccuracyMult = 1.175
					Duration=10
					PushOut=4
					HitSparkIcon='Hit Effect Ripple.dmi'
					HitSparkX=-32
					HitSparkY=-32
					HitSparkSize=1.25
					KBAdd=10
					KBMult=2
					Cooldown=60
					ActiveMessage="activates their Power Fist; everyone's in for some pain!"
					HitMessage="discharges the round in their Power Fist!!"
					verb/Power_Fist()
						set category="Skills"
						if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
							return
						usr.SetQueue(src)
				Power_Claw
					DamageMult=1.25
					HybridStrike=0.5
					AccuracyMult = 1.1
					Cooldown=20
					Grapple=1
					KBMult=0.001
					GrabTrigger=0.5
					Duration=25
					IconLock='PowerClawDeployed.dmi'
					ActiveMessage="boots up their mechanical claw!"
					HitMessage="crushes their opponent with their Power Claw!"
					verb/Power_Claw()
						set category="Skills"
						if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
							return
						usr.SetQueue(src)
				Hook_Grip_Claw
					DamageMult=5
					HybridStrike=0.5
					AccuracyMult=1
					Cooldown=120
					Grapple=1
					KBMult=0.001
					PrecisionStrike=5
					Duration=25
					IconLock='PowerClawDeployed.dmi'
					ActiveMessage="activates the hook shot mechanism in their claw..."
					HitMessage="stretches their mechanical appendage to grasp their foe!"
					verb/Hook_Grip_Claw()
						set category="Skills"
						if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
							return
						usr.SetQueue(src)
				Integrated
					Integrated=1
					Integrated_Pile_Bunker
						DamageMult=9
						AccuracyMult = 1.175
						HybridStrike=0.5
						SpiritHand=1
						Steady=5
						Duration=10
						PushOut=2
						Explosive=2
						HitSparkIcon='Hit Effect Ripple.dmi'
						HitSparkX=-32
						HitSparkY=-32
						HitSparkSize=2
						KBAdd=10
						KBMult=2
						Shattering=10
						Crippling=3
						Cooldown=180
						ActiveMessage="deploys a massive metal spike..."
						HitMessage="drives their devastating Pile Bunker forward!"
						verb/Pile_Bunker()
							set category="Skills"
							if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
								return
							usr.SetQueue(src)
					Integrated_Power_Fist
						NoSword=1
						SpiritHand=1
						HybridStrike=0.5
						Steady=5
						DamageMult=3.5
						AccuracyMult = 1.175
						Duration=10
						PushOut=4
						HitSparkIcon='Hit Effect Ripple.dmi'
						HitSparkX=-32
						HitSparkY=-32
						HitSparkSize=1.25
						KBAdd=10
						KBMult=2
						PureDamage=5
						Cooldown=180
						ActiveMessage="activates their Power Fist; everyone's in for some pain!"
						HitMessage="discharges the round in their Power Fist!!"
						verb/Power_Fist()
							set category="Skills"
							if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
								return
							usr.SetQueue(src)
					Integrated_Power_Claw
						DamageMult=1.25
						HybridStrike=0.5
						AccuracyMult = 1.1
						Cooldown=20
						Grapple=1
						KBMult=0.001
						GrabTrigger=0.5
						Duration=25
						IconLock='PowerClawDeployed.dmi'
						ActiveMessage="boots up their mechanical hand!"
						HitMessage="crushes their opponent with their Power Claw!"
						verb/Power_Claw()
							set category="Skills"
							if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
								return
							usr.SetQueue(src)
					Integrated_Hook_Grip_Claw
						DamageMult=5
						HybridStrike=0.5
						AccuracyMult=1
						Cooldown=20
						Grapple=1
						KBMult=0.001
						PrecisionStrike=5
						Duration=25
						IconLock='PowerClawDeployed.dmi'
						ActiveMessage="activates the hook shot mechanism in their hand..."
						HitMessage="stretches their mechanical appendage to grasp their foe!"
						verb/Hook_Grip_Claw()
							set category="Skills"
							if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
								return
							usr.SetQueue(src)