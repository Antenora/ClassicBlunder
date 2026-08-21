obj
	Skills
		Queue

			Warping_Fist // followup on an autohit
				Warp=50
				Cooldown=150
				Dunker=3
				NoGCD=1
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
				DamageMult=6.25
				AccuracyMult = 1.175
				KBMult=5
				Duration=7
				Instinct=2
				Warp=5
				Cooldown=12
				EnergyCost=3
				IconLock='CommandSparks.dmi'
				HeldSkill=TRUE
				NoFizzle=TRUE
				ChargePeriod=3
				OnHeldRelease(mob/p, benefit, sweet_spot_hit)
					if(!p)
						return
					DamageMult = 6.25 * (0.5 + 0.5 * min(max(benefit, 0), 1))
					p.SetQueue(src)
				verb/Aura_Punch()
					set category="Skills"
					usr.BeginHeldSkill(src)
			The_Claw
				SignatureTechnique=1
				name="Claw Grip"
				HitMessage="grabs the opponent's face in a crushing grip!"
				DamageMult=5.5
				AccuracyMult = 1.175
				KBMult=0.00001
				Duration=5
				Instinct=2
				Opener=1
				Warp=2
				Cooldown=12
				Grapple=1
				EnergyCost=3
				EnergyBurn=4
				DrainToSelf=1
				BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Brolic_Grip"
				adjust(mob/p)
					var/asc= p.AscensionsAcquired
					if(p.isInnovative(HUMAN, "Any") && !isInnovationDisable(p) && p.Class == "Heroic")
						DamageMult= 3.5 +(asc*0.5)
						AccuracyMult=1.5
						Opener=1
						Duration=5
						Instinct=1
						Warp=2
						WarpAway=null
						Grapple=1
						Cooldown=12+asc
						CooldownStatic=1
						BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Serum_W"
						HitMessage= "grasps the opponent's face in a crushing grip, dragging them through a series of portals!"
					else
						DamageMult=5.5
						Duration=5
						Opener=1
						Warp=2
						Instinct=2
						WarpAway=null
						Cooldown=12
						Grapple=1
						BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Brolic_Grip"
				verb/The_Claw()
					set category="Skills"
					adjust(usr)
					usr.SetQueue(src)
			Nerve_Shot
				SignatureTechnique=1
				DamageMult=0.8
				AccuracyMult = 1.25
				Duration=5
				Stunner=0.8
				Crippling=5
				WeakenRider=0.1
				Combo=5
				Rapid=1
				Cooldown=12
				Instinct=2
				UnarmedOnly=1
				EnergyCost=3
				HitMessage="confuses the opponent's senses with a volley of pressure point strikes!"
				verb/Nerve_Shot()
					set category="Skills"
					usr.SetQueue(src)
			Gale_Strike
				SignatureTechnique=1
				DamageMult=0.5//there is 0.5 damage mult 10 multihit on the gale itself
				AccuracyMult = 1.175
				KBMult=0.00001
				Duration=5
				Projectile="/obj/Skills/Projectile/GaleStrikeProjectile"
				Cooldown=12
				Instinct=2
				EnergyCost=3
				verb/Gale_Strike()
					set category="Skills"
					usr.SetQueue(src)
			Volleyball_Fist
				SignatureTechnique=1
				UnarmedOnly=1
				DamageMult=2.5
				AccuracyMult = 1.35
				KBMult=0.00001
				Stunner=0.8
				Instinct=2
				Warp=2
				HitStep=/obj/Skills/Queue/Volleyball_Fist2
				Duration=5
				Rapid=1
				Opener=1
				Cooldown=15
				EnergyCost=4
				HitMessage="staggers the opponent by sliding at their legs!"
				verb/Volleyball_Fist()
					set category="Skills"
					usr.SetQueue(src)
			Volleyball_Fist2
				UnarmedOnly=1
				DamageMult=2.5
				JuggleBonus=1.15
				AccuracyMult = 1.175
				KBMult=0.00001
				HitStep=/obj/Skills/Queue/Volleyball_Fist3
				Duration=5
				Quaking=3
				Warp=3
				Rapid=1
				Launcher=3
				EnergyCost=0
				HitMessage="launches their opponent in the air like a volleyball!"
			Volleyball_Fist3
				UnarmedOnly=1
				DamageMult=2.5
				JuggleBonus=1.15
				Instinct=5
				AccuracyMult = 1.175
				KBAdd=5
				Duration=5
				PushOut=3
				PushOutWaves=3
				Quaking=5
				Dunker=1
				NoGCD=1
				EnergyCost=0
				HitMessage="violently spikes the opponent towards the ground!!!"

			Crescent_Cartwheel
				SignatureTechnique=1
				DamageMult=0.8
				SpeedStrike=4
				AccuracyMult = 2
				HitStep=/obj/Skills/Queue/Crescent_Cartwheel2
				Duration=3
				Rapid=1
				Instinct=1
				Cooldown=12
				EnergyCost=3
				Warp=3
				HitSparkIcon='Slash - Future.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1.5
				HitMessage="releases a flurry of kicks in a single cartwheel!"
				var/tmp/current_hits = 0
				verb/Crescent_Cartwheel()
					set category="Skills"
					if(!Using)
						current_hits = 0
					usr.SetQueue(src)
			Crescent_Cartwheel2
				DamageMult=1
				SpeedStrike=1
				AccuracyMult=2.5
				HitStep=/obj/Skills/Queue/Crescent_Cartwheel2
				Duration=5
				Warp=1
				EnergyCost=1
				HitSparkIcon='Slash - Future.dmi'
				HitSparkX=-32
				HitSparkY=-32
				MissMessage = "is too exhausted to flip anymore...(Crescent_Cartwheel Max Hit)"
				adjust(mob/p)
					var/obj/Skills/Queue/Crescent_Cartwheel/bd = p.FindSkill(/obj/Skills/Queue/Crescent_Cartwheel)
					bd.current_hits++
					if(bd.current_hits < 10)
						DamageMult = 0.6 + (0.05 * bd.current_hits)
						Warp = round(max(1, bd.current_hits/2))
						EnergyCost = 0
						SpeedStrike = round(max(1, bd.current_hits/2))
						Duration = 4 + round(max(1, bd.current_hits/3))
						AccuracyMult = 2.5 - (0.1 * bd.current_hits)
					else
						DamageMult = 0
						EnergyCost = 0
						AccuracyMult=0.0001
						HitStep = FALSE
            //SWORD
			Blade_Dance
				SignatureTechnique=1
				NeedsSword=1
				DamageMult=0.8
				SpeedStrike=4
				AccuracyMult = 1.5
				HitStep=/obj/Skills/Queue/Blade_Dance2
				Duration=3
				Rapid=1
				Instinct=1
				Cooldown=12
				EnergyCost=3
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
					var/obj/Skills/Queue/Blade_Dance/bd = p.FindSkill(/obj/Skills/Queue/Blade_Dance)
					bd.current_hits++
					if(bd.current_hits < 10)
						DamageMult = 0.6 + (0.05 * bd.current_hits)
						Warp = round(max(1, bd.current_hits/2))
						EnergyCost = 0
						SpeedStrike = round(max(1, bd.current_hits/2))
						Duration = 4 + round(max(1, bd.current_hits/3))
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
				DamageMult=6
				AccuracyMult = 1.25
				KBAdd=10
				Duration=5
				Instinct=2
				Cooldown=12
				IconLock='EyeFlame.dmi'
				HitSparkIcon='LightningPlasma.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=2
				HitSparkTurns=1
				EnergyCost=3
				adjust(mob/p)
					DamageMult = (world.time - p.last_damaged_time >= 40) ? 6 : 3.6
				verb/Nirvana_Slash()
					set category="Skills"
					adjust(usr)
					usr.SetQueue(src)
			Soul_Tear_Storm
				SignatureTechnique=1
				name="Soul Tear Storm"
				ActiveMessage="begins to glow with ethereal darkness!"
				DamageMult=1.2
				AccuracyMult = 1.175
				KBMult=0.00001
				Combo=5
				Warp=5
				Duration=5
				Cooldown=12
				NeedsSword=1
				HitSparkIcon='Slash - Vampire.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				Instinct=2
				EnergyCost=3
				CursedWounds=3
				verb/Soul_Tear_Storm()
					set category="Skills"
					usr.SetQueue(src)