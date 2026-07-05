obj
	Skills
		Queue
			Cyberize
				Taser_Strike
					name="Taser Strike"
					DamageMult=4
					AccuracyMult = 1.175
					Duration=6
					Stunner=4
					KBMult=0.1
					Cooldown=60
					ManaCost=2
					ActiveMessage="builds up a stunning charge..."
					HitMessage="delivers an electrified strike!!"
					verb/Taser_Strike()
						set category="Skills"
						if(usr.Secret=="Heavenly Restriction" && (usr.secretDatum?:hasRestriction("Science") || usr.secretDatum?:hasRestriction("Cybernetics")))
							return
						usr.SetQueue(src)