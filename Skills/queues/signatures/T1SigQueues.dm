obj
	Skills
		Queue

			Warping_Fist // followup on an autohit
				Warp=50
				Cooldown=150
				Dunker=3
				DamageMult=4
				Instinct=2
				Duration=12
				AccuracyMult=2
				FollowUp=TRUE
				ActiveMessage="warps behind their target!"
				HitMessage="slams their target into the ground!"
            //UNARMED
			Aura_Punch
				SignatureTechnique=1
				ActiveMessage="begins concentrating power..."
				HitMessage="unleashes a devasatating punch!"
				DamageMult=9
				AccuracyMult = 1.175
				KBMult=5
				Duration=7
				Instinct=2
				Delayer=0.1//add 1 damage mult every second that this is queued but hasnt been punched yet
				Warp=5
				Cooldown=150
				EnergyCost=5
				IconLock='CommandSparks.dmi'
				verb/Aura_Punch()
					set category="Skills"
					usr.SetQueue(src)
			The_Claw
				SignatureTechnique=1
				name="Claw Grip"
				HitMessage="grabs the opponent's face in a crushing grip!"
				DamageMult=11
				AccuracyMult = 1.175
				KBMult=0.00001
				Duration=5
				Instinct=2
				Opener=1
				Warp=2
				Cooldown=150
				Grapple=1
				EnergyCost=5
				BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Brolic_Grip"
				verb/The_Claw()
					set category="Skills"
					usr.SetQueue(src)
			Nerve_Shot
				SignatureTechnique=1
				DamageMult=2
				AccuracyMult = 1.25
				Duration=5
				Stunner=2
				Crippling=15
				Shearing=25
				Combo=5
				Rapid=1
				Cooldown=150
				Instinct=2
				UnarmedOnly=1
				EnergyCost=5
				Confusing=25
				HitMessage="confuses the opponent's senses with a volley of pressure point strikes!"
				verb/Nerve_Shot()
					set category="Skills"
					usr.SetQueue(src)
			Gale_Strike
				SignatureTechnique=1
				DamageMult=1.8//there is 0.5 damage mult 10 multihit on the gale itself
				AccuracyMult = 1.175
				KBMult=0.00001
				Duration=5
				Projectile="/obj/Skills/Projectile/GaleStrikeProjectile"
				Cooldown=150
				Instinct=2
				EnergyCost=10
				verb/Gale_Strike()
					set category="Skills"
					usr.SetQueue(src)
			Volleyball_Fist
				SignatureTechnique=1
				UnarmedOnly=1
				DamageMult=4
				AccuracyMult = 1.35
				KBMult=0.00001
				Stunner=1
				Instinct=2
				Warp=2
				HitStep=/obj/Skills/Queue/Volleyball_Fist2
				Duration=5
				Rapid=1
				Opener=1
				Cooldown=150
				EnergyCost=3
				HitMessage="staggers the opponent by sliding at their legs!"
				verb/Volleyball_Fist()
					set category="Skills"
					usr.SetQueue(src)
			Volleyball_Fist2
				UnarmedOnly=1
				DamageMult=4
				AccuracyMult = 1.175
				KBMult=0.00001
				HitStep=/obj/Skills/Queue/Volleyball_Fist3
				Duration=5
				Quaking=3
				Warp=3
				Rapid=1
				Launcher=3
				EnergyCost=3
				HitMessage="launches their opponent in the air like a volleyball!"
			Volleyball_Fist3
				UnarmedOnly=1
				DamageMult=4
				Instinct=5
				AccuracyMult = 1.175
				KBAdd=5
				Duration=5
				PushOut=3
				PushOutWaves=3
				Quaking=5
				Dunker=1
				EnergyCost=8
				HitMessage="violently spikes the opponent towards the ground!!!"


            //SWORD
			Blade_Dance
				SignatureTechnique=1
				NeedsSword=1
				DamageMult=2
				SpeedStrike=4
				AccuracyMult = 1.5
				HitStep=/obj/Skills/Queue/Blade_Dance2
				Duration=3
				Rapid=1
				Instinct=1
				Cooldown=120
				EnergyCost=2
				HitSparkIcon='Slash - Future.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1.5
				HitMessage="chases their enemy down with a rush of powerful sword strikes!"
				var/tmp/current_hits = 0
				verb/Blade_Dance()
					set category="Skills"
					if(!Using)
						current_hits = 0 
					usr.SetQueue(src)
			Blade_Dance2
				NeedsSword=1
				DamageMult=1
				SpeedStrike=2
				AccuracyMult=1.25
				HitStep=/obj/Skills/Queue/Blade_Dance2
				Duration=5
				Warp=1
				EnergyCost=1
				HitSparkIcon='Slash - Future.dmi'
				HitSparkX=-32
				HitSparkY=-32
				MissMessage = "is too exhausted to swing anymore...(Blade Dance Max Hit)"
				adjust(mob/p)
					// find blade dance
					var/obj/Skills/Queue/Blade_Dance/bd = p.FindSkill(/obj/Skills/Queue/Blade_Dance)
					bd.current_hits++
					if(bd.current_hits < 10)
						DamageMult = 1 + (0.25 * bd.current_hits)
						Warp = round(min(1, bd.current_hits/2))
						EnergyCost = 0.5 + bd.current_hits/2
						SpeedStrike = round(min(1, bd.current_hits/2))
						Duration = 4 + round(min(1, bd.current_hits/3))
						AccuracyMult = 1.5 - (0.1 * bd.current_hits)
					else
						DamageMult = 0
						EnergyCost = 0
						AccuracyMult=0.0001
						HitStep = FALSE
			Nirvana_Slash
				SignatureTechnique=1
				NeedsSword=1
				ActiveMessage="fulfils their existence in their blade."
				HitMessage="slashes at the opponent's body with their enlightened blade!"
				DamageMult=11
				AccuracyMult = 1.25
				SpiritSword=1
				KBAdd=10
				Duration=5
				Instinct=2
				Cooldown=150
				IconLock='EyeFlame.dmi'
				HitSparkIcon='LightningPlasma.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=2
				HitSparkTurns=1
				EnergyCost=5
				verb/Nirvana_Slash()
					set category="Skills"
					usr.SetQueue(src)
			Soul_Tear_Storm
				SignatureTechnique=1
				name="Soul Tear Storm"
				ActiveMessage="begins to glow with ethereal darkness!"
				DamageMult=3.5
				AccuracyMult = 1.175
				KBMult=0.00001
				Combo=5
				Warp=5
				SpiritHand=0.5
				SpiritSword=0.5
				Duration=5
				Cooldown=150
				NeedsSword=1
				HitSparkIcon='Slash - Vampire.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				Instinct=2
				EnergyCost=10
				CursedWounds=1
				verb/Soul_Tear_Storm()
					set category="Skills"
					usr.SetQueue(src)