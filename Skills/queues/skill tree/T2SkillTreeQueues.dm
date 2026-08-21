obj
	Skills
		Queue
			//SWORD
			Infinity_Trap
				SkillCost=TIER_2_COST
				Copyable=3
				ActiveMessage="enters a thoughtful stance!"
				DamageMult=1.05
				AccuracyMult = 1.15
				KBMult=0.00001
				InstantStrikes=5
				InstantStrikesDelay=0
				Warp=2
				PushOut=1
				PushOutIcon='BLANK.dmi'
				Duration=5
				Cooldown=8
				NeedsSword=1
				EnergyCost=2
				HitSparkIcon='Slash - Zero.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=0.75
				HitSparkTurns=1
				verb/Infinity_Trap()
					set category="Skills"
					var/mob/caster = usr
					if(!caster.CanUseSkill(src))
						return
					src.Cooldown(1, null, caster)
					var/drain = caster.passive_handler["Drained"] ? EnergyCost * (1 + caster.passive_handler["Drained"]/10) : EnergyCost
					caster.LoseEnergy(drain)
					caster << "You set a hidden blade snare beneath you."
					var/turf/here = get_turf(caster)
					var/obj/Skills/Projectile/Infinity_Trap_Snare/Z = new
					Z.SpawnPosition = here
					new /obj/Skills/Projectile/_Projectile(caster, Z, here)
			Zero_Reversal
				SkillCost=TIER_2_COST
				Copyable=3
				ActiveMessage="enters a low stance!"
				DamageMult=3.55
				AccuracyMult = 1.15
				KBMult=0.00001
				SpeedStrike=2
				SweepStrike=2
				PerfectGuard=1
				Warp=2
				Duration=5
				Cooldown=8
				NeedsSword=1
				EnergyCost=2
				HitSparkIcon='Slash - Black.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1.5
				verb/Zero_Reversal()
					set category="Skills"
					usr.SetQueue(src)
					if(usr.AttackQueue == src)
						usr.perfect_guard_until = world.time + Duration*10
					else
						usr.perfect_guard_until = 0
			Willow_Dance
				SkillCost=TIER_2_COST
				Copyable=3
				ActiveMessage="begins to move fluidly, countering incoming blows!"
				DamageMult=1.95
				AccuracyMult = 1.15
				Duration=8
				Cooldown=8
				Launcher=2
				NeedsSword=1
				MultiHit=3
				InstantStrikes=2
				InstantStrikesDelay=1
				Counter=1
				EnergyCost=2
				WeaveDodge=4
				RiposteOnDodge=1.5
				verb/Willow_Dance()
					set category="Skills"
					usr.SetQueue(src)
			Gravity_Blade // NEW REPLACEMENT
				SkillCost=TIER_2_COST
				Copyable=3
				HarderTheyFall=3
				Opener=1
				Cooldown=8
				Duration=5
				ActiveMessage="prepares a chain of giant-toppling attacks!"
				DamageMult=1.15
				AccuracyMult=1.1
				NeedsSword=1
				EnergyCost=2
				InstantStrikes=4
				InstantStrikesDelay=1.5
				ApplySlow=10
				SlowPinAt=30
				verb/Gravity_Blade()
					set category="Skills"
					usr.SetQueue(src)
