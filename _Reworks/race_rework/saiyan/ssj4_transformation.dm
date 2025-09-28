transformation
	saiyan
		super_saiyan_4
			unlock_potential = 80
			autoAnger = 1
			speed = 1.5
			endurance = 1.5
			offense = 1.5
			defense = 1.5
			strength = 1.3
			force = 1.3
			revertToTrans = 0
			var/previousTailIcon
			var/previousTailUnderlayIcon
			var/previousTailWrappedIcon
			var/tailIcon = 'saiyantail_ssj4.dmi'
			var/tailUnderlayIcon = 'saiyantail_ssj4_under.dmi'
			var/tailWrappedIcon = 'saiyantail-wrapped_ssj4.dmi'
			form_icon_1_icon = 'GokentoMaleBase_SSJ4.dmi'
			passives = list("GiantForm" = 1, "SweepingStrike" = 1, "Brutalize" = 3, "Meaty Paws" = 2, "KiControlMastery" = 3, "PureReduction" = 5, "LifeGeneration" = 5, "Unstoppable" = 1, "AllOutAttack" = 1, "Reversal" = 0.3)
			adjust_transformation_visuals(mob/user)
				if(user.Hair_Base && !form_hair_icon)
					var/icon/x=new(user.Hair_Base)
					form_hair_icon=x
				..()

			mastery_boons(mob/user)
				passives = list("GiantForm" = 1, "Juggernaut" = 1+(mastery/25), "BuffMastery" = 5 + (mastery/10), "SweepingStrike" = 1, "Brutalize" = 3, "Meaty Paws" = 2 + (mastery/50), "KiControlMastery" = 3 + (mastery/50), "PureReduction" = 5 + (mastery/10),\
				"LifeGeneration" = 1 + (mastery/15), "Unstoppable" = 1, "AllOutAttack" = 1, "Reversal" = 0.1 + (mastery/200), "Flow" = 4, "Instinct" = 4, "Transformation Power" = clamp(user.AscensionsAcquired * 3, 1, 20))
				speed = 1.5 + (mastery/200)
				endurance = 1.5 + (mastery/200)
				offense = 1.5 + (mastery/200)
				defense = 1.5 + (mastery/200)
				strength = 1.5 + (mastery/200)
				force = 1.5 + (mastery/200)

			transform(mob/user)
				. = ..()
				previousTailIcon = user.TailIcon
				previousTailUnderlayIcon = user.TailIconUnderlay
				previousTailWrappedIcon = user.TailIconWrapped
				user.TailIcon = tailIcon
				user.TailIconUnderlay = tailUnderlayIcon
				user.TailIconWrapped = tailWrappedIcon
				user.Tail(1)

			revert(mob/user)
				. = ..()
				if(!is_active || !user.CanRevert()) return
				user.transActive = 0
				user.TailIcon = previousTailIcon
				user.TailIconUnderlay = previousTailUnderlayIcon
				user.TailIconWrapped = previousTailWrappedIcon
				previousTailIcon = null
				previousTailUnderlayIcon = null
				previousTailWrappedIcon = null
				user.Tail(1)

			transform_animation(mob/user)
				user.Quake(40)
				user.Frozen=1
				KenShockwave2(user, icon='KenShockwaveGold.dmi', Size=10)
				for(var/turf/t in Turf_Circle(user, 18))
					if(prob(50))
						spawn(rand(2,6))
							var/icon/i = icon('RisingRocks.dmi')
							t.overlays+=i
							spawn(rand(20, 60))
								t.overlays-=i
				spawn(10)
					KenShockwave2(user, icon='KenShockwaveGold.dmi', Size=10)
				user.Frozen=0
				animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=20)
				sleep(20)

				var/ShockSize = 5
				for(var/wav=5, wav>0, wav--)
					KenShockwave(user, icon='KenShockwaveGold.dmi', Size=ShockSize, Blend=2, Time=10)
					ShockSize/=2
				spawn(10)
					animate(user, color = user.MobColor, time=20)