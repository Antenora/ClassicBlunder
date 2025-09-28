
/mob/var/tmp/list/lasts_list = list("overwhelm" = -999, "rupture" = -999, "serrated" = -999)
/proc/getDeciderDamage(playerHealth, sourceHealth)
	var/healthDifference = abs(playerHealth - sourceHealth)
	var/damageMultiplier = 2 * (2.7** (-healthDifference/10))
	return round(damageMultiplier, 0.01)

/mob/proc/lightRush(mob/enemy, option)
	if("Launch")
		if(enemy.Launched)
			if(passive_handler["Sajire Rush"])
				return TRUE
			if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Launchers"))
				return TRUE
	else if("Stun")
		if(enemy.Stunned)
			if(passive_handler["Sajire Rush"])
				return TRUE
			if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Stunners"))
				return TRUE
	return FALSE


/mob/proc/Melee1(dmgmulti=1, spdmulti=1, iconoverlay, forcewarp, forcedTarget=null, ExtendoAttack=null, SecondStrike, ThirdStrike, accmulti=1, SureKB=0, NoKB=0, IgnoreCounter=0, BreakAttackRate=0, hitback = 0)
	if(glob.AURASPELLONATTACK && !AttackQueue)
		for(var/a in SlotlessBuffs)
			var/obj/Skills/Buffs/b = SlotlessBuffs[a]
			if(istype(b, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura))
				var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/aura = b
				if(aura.TossSkill)
					if((last_aura_toss - ((passive_handler["Familiar"]-1) * glob.FAMILIAR_CD_REDUCTION)) + glob.FAMILIAR_SKILL_CD < world.time && (Target && Target != src))
						last_aura_toss = world.time
						throwFollowUp(aura.skillToToss)
		if(passive_handler["EntanglingRoots"] && can_use_style_effect("EntaglingRoots") && Target != src)
			var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Snare/s = Target.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Snare)
			if(!s)
				s = new(glob.ROOTS_DURATION, 'root.dmi')
				Target.AddSkill(s)
			else
				s.TimerLimit = glob.ROOTS_DURATION
				s.IconLock = 'root.dmi'
			s.Trigger(Target, TRUE)
			last_style_effect = world.time
	if(Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Normal Attack"))
		return
	// CHECKS
	if(Stasis)
		return
	if(SecondStrike || ThirdStrike)
		BreakAttackRate=1
	if(!CanAttack() && !BreakAttackRate)
		return
	if(Flying)
		var/obj/Items/check = EquippedFlyingDevice()
		if(istype(check))
			check.ObjectUse(src)
			src << "You are knocked off your flying device!"
	if(dmgmulti<=0)
		dmgmulti=0.05
	// 				VARIABLES 				//
	var/unarmedAtk = 1
	var/swordAtk = 0
	var/lightAtk = 0
	var/obj/Items/Sword/s = EquippedSword()
	var/obj/Items/Sword/s2 = EquippedSecondSword()
	if(!s2 && UsingDualWield()) s2 = s
	var/obj/Items/Sword/s3 = EquippedThirdSword()
	if(!s3 && UsingTrinityStyle()) s3 = s
	var/obj/Items/Enchantment/Staff/st = EquippedStaff()
	var/acc = 1
	var/damage = 0 // potential will form the basis of the damage, potential is constant, only some things boost it
	var/dmgRoll = GetDamageMod() // damage mod is a random roll
	var/delay = SpeedDelay()
	// 				VARIABLES END			//

	// 				MAIN START				//

	// 				MELEE START			//
	#if DEBUG_MELEE
	log2text("Delay", delay, "damageDebugs.txt", "[ckey]/[name]")
	#endif
	if(AttackQueue)
		var/pCombo = progressCombo(delay)
		if(!pCombo)
			return
		else
			delay = pCombo
		if(!AttackQueue)
			#if DEBUG_MELEE
			log2text("Damageroll", "Starting DamageRoll", "damageDebugs.txt", "[ckey]/ [name]")
			#endif
		else
			if(AttackQueue.Rapid || AttackQueue.Launcher)
				delay /= 10 //Rapid and Launcher attacks are 10x faster
	#if DEBUG_MELEE
	log2text("Damageroll", "Starting DamageRoll", "damageDebugs.txt", "[ckey]/[name]")
	log2text("Damageroll", dmgRoll, "damageDebugs.txt", "[ckey]/[name]")
	#endif
	// 				EXTRA EFFECTS 			//


	if(!ThirdStrike)
		MultiStrike(SecondStrike, ThirdStrike) // trigger double/triple strike if applicable
	var/warpingStrike = getWarpingStrike() // get warping strike if applicable
	var/reqCounter = 99//counterWarp(s,s2,s3)
	if(passive_handler["Flying Thunder God"])
		reqCounter = 15 - passive_handler["Flying Thunder God"]
	if(IaidoCounter>=reqCounter)
		warpingStrike = 100
	if(Warping || passive_handler.Get("Warping"))
		var/warp = Warping
		if(passive_handler.Get("Warping") > Warping)
			warp = passive_handler.Get("Warping")
		warpingStrike=warp
		if(warpingStrike<2)
			warpingStrike=2

	// 				EXTRA EFFECTS END		//

	// 				WEAPON DAMAGE 			//

	if(s)
		unarmedAtk=0
		swordAtk=1
	var/specialAtk = FALSE
	if(st)
		specialAtk = TRUE

	if(src.AttackQueue)
		if(src.AttackQueue.NeedsSword)
			unarmedAtk=0
			swordAtk=1
		else
			unarmedAtk=1
			swordAtk=0

	var/list/itemMod = getItemDamage(list(s,s2,s3,st), delay, acc, SecondStrike, ThirdStrike, swordAtk, specialAtk)
	delay = itemMod[1]
	acc = itemMod[2]
	#if DEBUG_MELEE
	log2text("DamageMod", "After Item Damage", "damageDebugs.txt", "[ckey]/[name]")
	log2text("DamageMod", itemMod[3], "damageDebugs.txt", "[ckey]/[name]")
	#endif
	// 				WEAPON DAMAGE END		//

	// 				BLADE MODE 				//
	if(passive_handler.Get("HellRisen") && hasTarget())
		if(isDominating(Target))
			if(!CheckSlotless("Dominating"))
				if(Target.Stunned || Target.Launched)
					// Dominator Blade Mode Lite here
					if(!FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dominating, src))
						AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dominating)
					var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dominating/dm = FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dominating, src)
					dm.adjust(src)
					if(!dm.Using)
						animate(client, color =rgb(224, 49, 49), time = 3)
						dm.Trigger(src)





	if(BladeMode && !passive_handler.Get("HellRisen"))
		if(Target)
			if(!CheckSlotless("Blade Mode"))
				if(Target.Launched || Target.Stunned)
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Blade_Mode, src)) // TODO maybe change this so its better
						AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Blade_Mode)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Blade_Mode/bm in src)

						if(!bm.Using)
							bm.passives = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Blade_Mode::passives
							animate(client, color = list(0.5,0.5,0.55, 0.6,0.6,0.66, 0.31,0.31,0.37, 0,0,0), time = 3)
							bm.Trigger(src)

	// 				BLADE MODE END			//

	// 				WARPING 				//

	if(devaCounter >= 15 || passive_handler["AirBend"] && can_use_style_effect("AirBend"))
		if(Target && Target != src && Target in view(10, src))
			var/mob/tgt = Target
			tgt.Knockbacked=1
			flick("KB", tgt)
			animate(tgt, pixel_z = 6,  easing = ELASTIC_EASING, time = 3)
			step_towards(tgt, src)
			tgt.Knockbacked=0
			animate(pixel_z = 0, easing = ELASTIC_EASING, time = 1.5)
			devaCounter=0
			if(passive_handler["AirBend"])
				last_style_effect = world.time
	if(passive_handler["Nimbus"] && last_nimbus + glob.NIMBUSCD - (passive_handler["Nimbus"]*10) < world.time)
		if(HasTarget() && TargetInRange(glob.NIMBUSRANGE + passive_handler["Nimbus"]))
			if(CanDash())
				is_dashing++
				AfterImageGhost(src)
				DashTo(Target, glob.NIMBUSRANGE + passive_handler["Nimbus"], 1 - (passive_handler["Nimbus"]/4), 0)
				var/msg = replacetext(nimbus_message, "player_name", "[src]")
				msg = replacetext(msg, "target_name", "[src.Target]")
				src.OMessage(10,"[msg]","<font color=red>[src]([src.key]) used Nimbus.")
				last_nimbus = world.time
				// TODO: make hud later if we feel like it chat
	if(warpingStrike)
		if(Target && Target.loc && Target != src && Target && get_dist(Target, src) < warpingStrike)
			forcewarp = Target
	if((forcewarp && Target.z == z))
		if(passive_handler["Flying Thunder God"] && IaidoCounter>=reqCounter)
			new/obj/tracker/FTG_seeker(locate(x,y,z), Target, src) //TODO: make this a normal projectile maybe? does no damage, but throws this, idk that way it can be used as a follow up
			if(IaidoCounter)
				IaidoCounter = 0
		else
			Comboz(forcewarp)


		//	WARPING END	//

		//	DELAY	//

	delay = adjustDelay(delay)

	if(!BreakAttackRate)
		NextAttack = world.time
	else
		if(AttackQueue)
			if(AttackQueue.Combo && (!Target || Target == src))
				NextAttack = world.time
			if(AttackQueue.Counter)
				NextAttack = world.time += delay



	// 				DELAY END				//

	var/windChance = passive_handler.Get("WindRelease")
	if(!forcewarp&&prob(windChance*5))
		for(var/mob/m in orange(windChance*3))
			if(inParty(m.ckey)) continue
			src.Knockback(windChance, m, Direction=get_dir(m, src))

	// 				RAYCASTING 				//

	var/list/mob/enemies = getEnemies(forcedTarget)

	// 				RAYCASTING END			//

	// 				ATTACK 					//

	if(length(enemies)>0)
		var/shockwaveChance = passive_handler.Get("ShockwaveBlows")
		if(!AttackQueue&&prob(shockwaveChance*10))
			GetAndUseSkill(/obj/Skills/AutoHit/Shockwave_Blows, AutoHits, TRUE)

		if(passive_handler.Get("RefreshingBlows"))
			for(var/mob/m in oview(passive_handler.Get("RefreshingBlows")*2, src))
				m.Slow -= passive_handler.Get("RefreshingBlows")
				if(m.Slow < 0)
					m.Slow = 0
				m.Crippled -= passive_handler.Get("RefreshingBlows")
				if(m.Crippled < 0)
					m.Crippled = 0
				m.Burn -= passive_handler.Get("RefreshingBlows")
				if(m.Burn < 0)
					m.Burn = 0
				m.Poison -= passive_handler.Get("RefreshingBlows")
				if(m.Poison < 0)
					m.Poison = 0
				m.Shatter -= passive_handler.Get("RefreshingBlows")
				if(m.Shatter < 0)
					m.Shatter = 0
				m.Shock -= passive_handler.Get("RefreshingBlows")
				if(m.Shock < 0)
					m.Shock = 0
				m.Sheared -= passive_handler.Get("RefreshingBlows")
				if(m.Sheared < 0)
					m.Sheared = 0

		NextAttack += delay
		var/Disarm = 0
		if(UsingGladiator())
			if(GladiatorCounter >= glob.GLADIATOR_DISARM_MAX * 6-UsingGladiator())
				Disarm = 1
				GladiatorCounter = 0
		for(var/mob/enemy in enemies)
			if(istype(enemy, /mob/irlNPC))
				continue
			if(istype(enemy, /mob/MonkeySoldier))
				continue
			if(enemy.Stasis)
				continue
			if(enemy != src)

		// 				STYLE EFFECTS 			//
				activateStyleEffects(forcewarp, FALSE, Disarm, enemy) // this proc is redundant for forewarp
		// 				STYLE EFFECTS END		//

		// 				STATS 					//
				#if DEBUG_MELEE
				log2text("DamageMod", "old DmgMod", "damageDebugs.txt", "[ckey]/[name]")
				log2text("DamageMod", itemMod[3], "damageDebugs.txt", "[ckey]/[name]")
				#endif
				var/powerDif = Power / enemy.Power
				if(glob.CLAMP_POWER)
					if(!ignoresPowerClamp())
						powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)

				#if DEBUG_MELEE
				log2text("powerDif", powerDif, "damageDebugs.txt", "[ckey]/[name]")
				#endif
				var/atk = getStatDmg2()
				var/def = enemy.getEndStat(1)
				var/brutalize = GetBrutalize()
				if(brutalize)
					def -= (def * clamp(brutalize, 0.01, 0.9)) // MOVE THIS TO A GET PROC SO IT CAN BE TRACKED
				var/damageMultiplier = dmgmulti
				if(AttackQueue && AttackQueue.HarderTheyFall)
					var/enemyEnd = enemy.GetEnd()
					atk += enemyEnd * (AttackQueue.HarderTheyFall/10)
				#if DEBUG_MELEE
				log2text("DamageMod", "newDmgMod", "damageDebugs.txt", "[ckey]/[name]")
				log2text("DamageMod", damage, "damageDebugs.txt", "[ckey]/[name]")
				#endif

				if(HasPridefulRage()) // this used to set endurance to 1, not it reduces the enemy endurance by 50%, 2 ticks will reduce it to 1
					if(passive_handler.Get("PridefulRage") >= 2)
						def = 1
					else
						def = clamp(enemy.GetEnd()/2, 1, enemy.GetEnd())

				#if DEBUG_MELEE
				log2text("atk/def stats", "[atk]/[def]", "damageDebugs.txt", "[ckey]/[name]")

				// powerDif += src.getIntimDMGReduction(enemy)

				log2text("powerDif (After Intim)", powerDif, "damageDebugs.txt", "[ckey]/[name]")
				#endif

				damage = (powerDif**glob.DMG_POWER_EXPONENT) * (glob.CONSTANT_DAMAGE_EXPONENT+glob.MELEE_EFFECTIVENESS) ** -(def**glob.DMG_END_EXPONENT / atk**glob.DMG_STR_EXPONENT)


				#if DEBUG_MELEE
				log2text("Damage", "Staring Damage", "damageDebugs.txt", "[ckey]/[name]")
				log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
				#endif

				if(party && passive_handler.Get("TeamHater"))
					if(enemy in party)
						damage *= 1+passive_handler.Get("TeamHater")

				damage *= damageMultiplier
		// 				GIANT FORM 				//
				if(enemy.HasGiantForm())
					var/modifier = glob.upper_damage_roll / 6
					dmgRoll = GetDamageMod(0, -modifier)
					#if DEBUG_MELEE
					log2text("Damageroll", "After GiantForm", "damageDebugs.txt", "[ckey]/[name]")
					log2text("Damageroll", dmgRoll, "damageDebugs.txt", "[ckey]/[name]")
					#endif
		// 				GIANT FORM END			//

				damage *= dmgRoll

				#if DEBUG_MELEE
				log2text("Damage", "After DamageRoll", "damageDebugs.txt", "[ckey]/[name]")
				log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
				#endif

				if(itemMod[3])
					damage *= itemMod[3]
					#if DEBUG_MELEE
					log2text("Damage", "After Item Damage", "damageDebugs.txt", "[ckey]/[name]")
					log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
					#endif
				if(unarmedAtk && HasUnarmedDamage())
					damage *= 1 + (GetUnarmedDamage()/glob.UNARMED_DAMAGE_DIVISOR)
					#if DEBUG_MELEE
					log2text("Damage", "After unarmed Damage", "damageDebugs.txt", "[ckey]/[name]")
					log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
					#endif
				damageMultiplier = 1 // NEW multiplier variable
		// 				STATS END				//

		// 				ARMOR					//

				var/obj/Items/Armor/atkArmor = EquippedArmor()
				var/obj/Items/Armor/defArmor = enemy.EquippedArmor()

				if(atkArmor)
					acc *= GetArmorAccuracy(atkArmor)
					delay /= GetArmorDelay(atkArmor)
					#if DEBUG_MELEE
					log2text("Delay", "After Armor", "damageDebugs.txt", "[ckey]/[name]")
					log2text("Delay", delay, "damageDebugs.txt", "[ckey]/[name]")
					#endif

				if(spdmulti)
					if(unarmedAtk)
						spdmulti += 0.75
					delay/=spdmulti
					#if DEBUG_MELEE
					log2text("Delay", "After Speed", "damageDebugs.txt", "[ckey]/[name]")
					log2text("Delay", delay, "damageDebugs.txt", "[ckey]/[name]")
					#endif
		// 				ARMOR END				//

		// 				QUEUE	 				//
				var/knockDistance = 0
				var/speedStrike = passive_handler.Get("BlurringStrikes")
				if(UsingFencing() || speedStrike)
					speedStrike += UsingFencing()
					damage *= clamp(sqrt( 1  + ( (GetSpd()) * (speedStrike/15) ) ),1,3)
				if(AttackQueue)
					damage *= QueuedDamage(enemy)
					if(Secret=="Heavenly Restriction" && secretDatum?:hasImprovement("Queues"))
						damage *= clamp(secretDatum?:getBoon(src, "Queues"), 1, 10)
					#if DEBUG_MELEE
					log2text("Damage", "After Queue", "damageDebugs.txt", "[ckey]/[name]")
					log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
					#endif
					if(QueuedKBMult()<1 && !QueuedKBAdd())
						NoKB=1
					else
						knockDistance *= QueuedKBMult()
					knockDistance = QueuedKBAdd()

					if(AttackQueue.Ooze)
/*						world << "[enemy.x] [enemy.y] [enemy.z]"
						world << "[AttackQueue.Ooze]"*/
						var/minx = enemy.x - (AttackQueue.Ooze*2)
						var/miny = enemy.y - (AttackQueue.Ooze*2)
						var/maxx = enemy.x + (AttackQueue.Ooze*2)
						var/maxy = enemy.y + (AttackQueue.Ooze*2)
				//		world << "MIN/MAX: [minx], [miny], [maxx], [maxy]"
						for(var/turf/T in block(minx, miny, enemy.z, maxx, maxy))
							if(!T.density)
								CHECK_TICK
							//	world << "LOCATION: [T.x], [T.y], [T.z]"
								new/obj/leftOver/Ooze(T.x, T.y, T.z, src)
					#if DEBUG_MELEE
					log2text("Knockback", "After Queue", "damageDebugs.txt", "[ckey]/[name]")
					log2text("Knockback", knockDistance, "damageDebugs.txt", "[ckey]/[name]")
					#endif
		// 				QUEUE END				//

		// 				MULTIATTACK				//
				else
					if(Secret=="Heavenly Restriction" && secretDatum?:hasImprovement("Normal Attack"))
						damage *= clamp(secretDatum?:getBoon(src, "Basic Attack"), 1, 10)
				var/multiAtkNerf = 1
				if(AttackQueue && AttackQueue?.ComboPerformed>0)
					// multiAtkNerf = 1 - clamp(AttackQueue.ComboPerformed * 0.1, 0.1, 0.99)
					damage *= multiAtkNerf
					#if DEBUG_MELEE
					log2text("Damage", "After MultiAtkNerf", "damageDebugs.txt", "[ckey]/[name]")
					log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
					#endif
		// 				MULTIATTACK END			//

		// 				KNOCKBACK 				//
				knockDistance += getMeleeKnockback(enemy)

		// 				KNOCKBACK END			//

		// 				ACCURACY 				//

				var/hitResolution = Accuracy_Formula(src, enemy, acc*accmulti)
				if(enemy.icon_state == "Meditate" || enemy.KO)
					hitResolution = HIT

		// 				ACCURACY END			//

		// 				STATUS 					//
				flick("Attack",src)
				if(passive_handler["Hit Scan"]) // this is troublesome
					new/obj/tracker(locate(x,y,z),enemy, src, HitScanIcon, HitScanHitSpark,HitScanHitSparkX, HitScanHitSparkY)
				//TODO: come back to this
				var/countered=0

				if(AttackQueue && AttackQueue.Dunker && enemy.Launched)
					if(AttackQueue.Dunker)
						spawn()
							Jump(src)
						sleep(3)
						spawn()
							LaunchEnd(enemy)
				else if(!AttackQueue && (enemy.Launched || enemy.Stunned))
					damage *= glob.CCDamageModifier
					#if DEBUG_MELEE
					log2text("Damage", "After Stun", "damageDebugs.txt", "[ckey]/[name]")
					log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
					#endif
		// 				STATUS END				//

		// 				HOT HUNDRED 			//
				var/hh = (passive_handler.Get("HotHundred") || passive_handler["Speed Force"] >= 2) ? TRUE : FALSE
				if(!AttackQueue && (hh || lightRush(enemy, "Launch") || lightRush(enemy, "Stun")))
					lightAtk = 1
					var/adjust = 0
					Comboz(enemy, LightAttack = 1)
					if(passive_handler.Get("HotHundred"))
						lightAtk=0
						adjust = hh-1
					if(enemy.Launched && Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Launchers"))
						damage *= 1+secretDatum?:getBoon(src,"Launchers")
					if(enemy.Stunned && Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Stunners"))
						damage *= 1+secretDatum?:getBoon(src,"Stunners")
					if(passive_handler["Speed Force"])
						damage *= 0 + (0.25 * passive_handler["Speed Force"])
					else
						damage /= max(2,4-adjust)
					if(glob.LIGHT_ATTACK_SPEED_DMG_ENABLED)
						damage *= clamp(glob.LIGHT_ATTACK_SPEED_DMG_LOWER,GetSpd()**glob.LIGHT_ATTACK_SPEED_DMG_EXPONENT,glob.LIGHT_ATTACK_SPEED_DMG_UPPER)
					if(!adjust)
						NoKB=1
					if(SecondStrike || ThirdStrike)
						damage *= 0.3

					NextAttack = world.time + 1.25
					#if DEBUG_MELEE
					log2text("Damage", "After HotHundred", "damageDebugs.txt", "[ckey]/[name]")
					log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
					#endif
		// 				HOT HUNDRED END			//

		// 				MELEE COUNTER 			//
				countered = counterShit(enemy, IgnoreCounter)
		// 				MELEE COUNTER END		//

		// 				HIT RESOLUTION 			//

				if(enemy.Stunned)
					hitResolution = HIT

				if(!countered)
					var/dodged = 0
					var/disperseX = rand(-12,12)
					var/disperseY = rand(-12,12)
					// If it was not countered
					if(hitResolution != MISS)
						// and they hit in any way
						if(!enemy.passive_handler.Get("NoDodge"))


					// 				FLOW					//

							if(enemy.HasFlow()&&!IgnoreCounter)

								var/BASE_FLOW_PROB = glob.BASE_FLOW_PROB
								var/flow = enemy.GetFlow()
								var/instinct = HasInstinct()
								var/result = 0

								if(instinct)
									result = flow - instinct
								else
									result = flow
								var/backtrack = enemy.passive_handler.Get("BackTrack")
								if(prob((BASE_FLOW_PROB*result) + glob.BASE_BACKTRACK_PROB * backtrack))
									if(AttackQueue && AttackQueue.HitSparkIcon)
										var/hitsparkSword = swordAtk
										disperseX=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
										disperseY=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
										if(swordAtk && HasSwordPunching())
											hitsparkSword = 0
										HitEffect(enemy, unarmedAtk, hitsparkSword, SecondStrike, ThirdStrike, disperseX, disperseY)
									if(enemy.CheckSpecial("Ultra Instinct"))
										//TODO play the ultra instinct sound
										StunClear(enemy)
										UltraPrediction(enemy)
									else
										StunClear(enemy)
										WildSense(enemy, src, 0)
									dodged = 1
									if(enemy.CombatCPU)
										enemy.LoseMana(1)
					// 				FLOW END				//
					// 				AIS			 			//
						if(enemy.AfterImageStrike>0&&!dodged)
							enemy.AfterImageStrike-=1
							if(enemy.AfterImageStrike<0)
								enemy.AfterImageStrike=0

							var/instinct = HasInstinct()
							if(prob(100-(instinct*20)))
								if(AttackQueue && AttackQueue.HitSparkIcon)
									disperseX=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
									disperseY=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
									var/hitsparkSword = swordAtk
									if(swordAtk && HasSwordPunching())
										hitsparkSword = 0
									HitEffect(enemy, unarmedAtk, hitsparkSword, SecondStrike, ThirdStrike, disperseX, disperseY)
								StunClear(enemy)
								AfterImageStrike(enemy,src,1)
								dodged = 1
							else

								StunClear(enemy)
								AfterImageStrike(enemy,src,0)
								AfterImageStrike(src,enemy,0)

					// 				AIS END					//

						else

					// 	 			NO DODGE				//

							if(enemy.AfterImageStrike>0&&!passive_handler.Get("NoDodge")&&!dodged&&!IgnoreCounter)
								enemy.AfterImageStrike-=1
								if(enemy.AfterImageStrike<0)
									enemy.AfterImageStrike=0

								var/instinct = HasInstinct()

								if(prob(100-(instinct*20)))
									if(AttackQueue && AttackQueue.HitSparkIcon)
										disperseX=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
										disperseY=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
										var/hitsparkSword = swordAtk
										if(swordAtk && HasSwordPunching())
											hitsparkSword = 0
										HitEffect(enemy, unarmedAtk, hitsparkSword, SecondStrike, ThirdStrike, disperseX, disperseY)
									enemy.dir = get_dir(enemy,src)
									StunClear(enemy)
									enemy.NextAttack=0
									enemy.Melee1(1,1,SureKB=1)
									dodged = 1
								else
									StunClear(enemy)
									AfterImageStrike(src,enemy,0)
					// 				NO DODGE END		//
						if(AttackQueue && enemy.passive_handler.Get("Sunyata"))
							if( prob(enemy.passive_handler.Get("Sunyata") * glob.SUNYATA_BASE_CHANCE))
								OMsg(enemy, "<b><font color=#ff0000>[enemy] has negated [src]'s attack!</font></b>")
								dodged = 1
						if((AttackQueue && enemy.passive_handler["Interception"]) && !AttackQueue.Finisher)
							if(prob(enemy.passive_handler["Interception"] * glob.INTERCEPTION_BASE_CHANCE))
								OMsg(enemy, "<b><font color=#ff0000>[enemy] reverses [src]'s attack!</font></b>")
								if(glob.INTERCEPTION_NEGATES_DAMAGE)
									dodged = 1
								ClearQueue()
								var/obj/Effects/Interception/p = new()
								p.Target = enemy
								enemy.vis_contents += p
								flick( "interception", p )
								enemy.InterceptionStrike(src, enemy.passive_handler["Interception"])
						if(!dodged)
					// 				HIT					//

							STRIKE
							if(UsingSpellWeaver())
								if(prob(50))
									var/obj/Skills/Projectile/DancingBlast/db = locate(/obj/Skills/Projectile/DancingBlast, src)
									if(!db)
										db = new()
										AddSkill(db)
									//TODO TEST THIS TO MAKE SURE IT IS WORKING
									UseProjectile(db)
							if(passive_handler["LingeringPoison"])
								if(prob(glob.LINGERCHANCE * passive_handler["LingeringPoison"]))
									var/linger =  passive_handler["LingeringPoison"]
									new/obj/leftOver/poisonCloud(locate(x+rand(-8+linger, (8-linger)), y+rand(-8+linger, (8-linger)), z), src,  passive_handler["LingeringPoison"])

							// 				WHIFFING		 			//
							#if DEBUG_MELEE
							log2text("Damage", "Start of Hit", "damageDebugs.txt", "[ckey]/[name]")
							log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
							#endif
							if(hitResolution == WHIFF || prob(glob.BASE_FLUIDFORM_PROB * enemy.HasFluidForm()))
								var/whiffed = TRUE
								if(AttackQueue)
									if(AttackQueue.NoWhiff)
										if(!enemy.passive_handler.Get("NoForcedWhiff"))
											hitResolution = HIT
										else
											hitResolution = MISS // this doesn't do anything
											damage = 0
								else
									if(NoWhiff()) // cant whiff
										whiffed = FALSE

								if(whiffed)
									damage /= rand(glob.MIN_WHIFF_DMG, glob.MAX_WHIFF_DMG)
									enemy.Whiff()
									#if DEBUG_MELEE
									log2text("Damage", "After Whiff", "damageDebugs.txt", "[ckey]/[name]")
									log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
									#endif
					// 				WHIFFING END				//

							if(enemy.passive_handler.Get("Siphon"))
								var/usingEnergy = HasSpiritHand() || HasSpiritSword() || HasHybridStrike() || UsingSpiritStrike() ? 1 : 0
								if(usingEnergy && prob(10 * enemy.passive_handler.Get("Siphon")))
									var/heal = damage * (enemy.passive_handler.Get("Siphon") / 10)

									if(HasSpiritSword())
										heal *= GetSpiritSword()
									else if(HasHybridStrike())
										heal *= GetHybridStrike()
									//TODO TEST ENERGY SIPHON IT MIGHT BE WONKY
									damage -= heal
									enemy.HealEnergy(heal)
									#if DEBUG_MELEE
									log2text("Damage", "After Energy Siphon", "damageDebugs.txt", "[ckey]/[name]")
									log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
									#endif
							if(AttackQueue)
							// 				ONHITS				//
								if(AttackQueue.Scorching||AttackQueue.Chilling||AttackQueue.Freezing||AttackQueue.Crushing||AttackQueue.Shattering||AttackQueue.Shocking||AttackQueue.Paralyzing||AttackQueue.Poisoning||AttackQueue.Toxic)
									var/list/addElements = list()
									if(AttackQueue.Scorching)
										addElements |= "Fire"
									else if(AttackQueue.Chilling||AttackQueue.Freezing)
										addElements |= "Water"
									else if(AttackQueue.Crushing||AttackQueue.Shattering)
										addElements |= "Earth"
									else if(AttackQueue.Shocking||AttackQueue.Paralyzing)
										addElements |= "Wind"
									else if(AttackQueue.Poisoning||AttackQueue.Toxic)
										addElements |= "Poison"
									ElementalCheck(src, enemy, 0,, addElements)

								if(AttackQueue.Shearing)
									enemy.AddShearing(AttackQueue.Shearing,src)
								if(AttackQueue.Crippling)
									enemy.AddShearing(AttackQueue.Crippling, src)

								if(AttackQueue.Dunker)
									if(enemy.Launched)
										enemy.Dunked = AttackQueue.Dunker
										lightAtk = 0
										NoKB = 0
										SureKB = 0
										knockDistance += 5 * AttackQueue.Dunker
										damage *= 1 + (AttackQueue.Dunker / 10)
								if(AttackQueue.MortalBlow)
									if(prob(glob.MORTAL_BLOW_CHANCE * AttackQueue.MortalBlow) && !enemy.MortallyWounded)
										var/mortalDmg = enemy.Health * 0.05 // 5% of current
										enemy.LoseHealth(mortalDmg)
										enemy.WoundSelf(mortalDmg/2)
										enemy.MortallyWounded += 1
										OMsg(enemy, "<b><font color=#ff0000>[src] has dealt a mortal blow to [enemy]!</font></b>")

								if(glob.MULTIHIT_NERF)
									if(AttackQueue.InstantStrikes && AttackQueue.InstantStrikesPerformed>=1)
										var/mod = 1 - (0.1 * AttackQueue.InstantStrikesPerformed)
										if(mod <= 0.1)
											mod = 0.05
										damage *= mod
										#if DEBUG_MELEE
										log2text("Damage", "After Instant Strikes", "damageDebugs.txt", "[ckey]/[name]")
										log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
										#endif
							// 				ONHITS END			//

							// reduce damage by 1% for every 0.1 damage effectiveness, 1 damage effectiveness = 10% damage reduction
							//TODO ARMOR AT THE END
							if(enemy.passive_handler["Parry"] && (s || s2 || s3 || swordAtk))

								if(prob(enemy.passive_handler["Parry"] * glob.PARRY_CHANCE) && hitback <= glob.MAX_CHAIN_PARRY)
									var/obj/Effects/Parry/p = new()
									p.Target = enemy
									enemy.vis_contents += p
									flick("parry", p)
									damage /= enemy.passive_handler["Parry"] * glob.PARRY_REDUCTION_MULT
									enemy.Melee1(dmgmulti = (glob.PARRY_BASE_DMG * enemy.passive_handler["Parry"]), forcedTarget=src, hitback=hitback+1) // this does mean that they will hit from no matter the range if hit by melee
							if(enemy.passive_handler["Iaijutsu"])
								if(prob(enemy.passive_handler["Iaijutsu"] * glob.IAI_CHANCE) && hitback <= glob.MAX_CHAIN_PARRY)
									var/obj/Effects/Iai/p = new()
									p.Target = enemy
									enemy.vis_contents += p
									flick("iai", p)
									enemy.Melee1(dmgmulti =(glob.IAI_BASE_DAMAGE * enemy.passive_handler["Iaijutsu"]), forcedTarget = src, hitback=hitback+1)
							if(enemy.passive_handler["Perfect Counter"])
								// if only we could ping the thing that is giving this
								enemy.TriggerPerfectCounter(src) // i cant actually test this
							if(defArmor&&!passive_handler.Get("ArmorPeeling"))
								var/dmgEffective = enemy.GetArmorDamage(defArmor)
								if(passive_handler["Half-Sword"])
									dmgEffective -= passive_handler["Half-Sword"] * glob.HALF_SWORD_ARMOR_REDUCTION
								if(dmgEffective>0)
									damage -=  damage * dmgEffective/10
								else
									damage += damage * abs(dmgEffective/10)
								#if DEBUG_MELEE
								log2text("damage", "After Armor", "damageDebugs.txt", "[ckey]/[name]")
								log2text("damage", damage, "damageDebugs.txt", "[ckey]/[name]")
								#endif
							if(passive_handler["Half-Sword"] && !defArmor)
								damage += damage * (passive_handler["Half-Sword"]/glob.HALF_SWORD_UNARMOURED_DIVISOR)
							damage *= glob.GLOBAL_MELEE_MULT
							#if DEBUG_MELEE
							log2text("Damage", "After Global Multiplier", "damageDebugs.txt", "[ckey]/[name]")
							log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
							#endif
							if(enemy.passive_handler["Magmic"] && enemy.SlotlessBuffs["Magmic Shield"])
								Stun(src, 3, TRUE)
								enemy.SlotlessBuffs["Magmic Shield"].Trigger(enemy, TRUE)
							var/dmgValue = DoDamage(enemy, damage, unarmedAtk, swordAtk, SecondStrike, ThirdStrike)
							. = dmgValue
							if(!glob.MOMENTUM_PROCS_OFF_DAMAGE)
								handlePostDamage(enemy) // it already proc'd
							lastHit = world.time
					// 										MELEE END																	 //
							var/shocked=0
							if((SureKB || AttackQueue && QueuedKBAdd()) && !NoKB)
								knockDistance = round(knockDistance)
								if(SureKB && knockDistance < max(SureKB, 5))
									knockDistance = max(SureKB, 5)
								if(!AttackQueue || AttackQueue && !AttackQueue.Grapple)
									if(enemy)
										if(enemy.passive_handler&&enemy.passive_handler.Get("Blubber"))
											var/blubber = enemy.passive_handler.Get("Blubber")
											if(prob(blubber * 25))
												enemy.Knockback(knockDistance / clamp(5-blubber, 1,4),src)
												knockDistance  *= 1 - (0.10 * blubber)
									Knockback(knockDistance, enemy)
									if(passive_handler["Heavy Attack"])
										if(passive_handler["Heavy Attack"] == "Beast")
											DashTo(enemy, 25, 0.75, 0)
							if(AttackQueue)
								if(AttackQueue.HitSparkDispersion)
									disperseX=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
									disperseY=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
									var/hitsparkSword = swordAtk
									if(swordAtk && HasSwordPunching())
										hitsparkSword = 0
									HitEffect(enemy, unarmedAtk, hitsparkSword, SecondStrike, ThirdStrike, disperseX, disperseY)
								if(AttackQueue?.PushOut)
									var/shockwave = AttackQueue.PushOutWaves
									var/shockSize = AttackQueue.PushOut
									var/shockIcon = AttackQueue.PushOutIcon
									for(var/wav=shockwave, wav>0, wav--)
										KenShockwave(enemy, icon = shockIcon, Size = shockSize)
										shockSize /= 2
									shocked=1
								if(AttackQueue?.WarpAway)
									WarpEffect(enemy, AttackQueue.WarpAway)
								if(AttackQueue?.Launcher)
									var/time = AttackQueue.Launcher
									if(!enemy.Launched)
										spawn()
											LaunchEffect(src, enemy, time)
									else
										enemy.Launched += 5

								if(AttackQueue?.InstantStrikes)
									if(AttackQueue.InstantStrikesDelay)
										sleep(AttackQueue.InstantStrikesDelay*world.tick_lag)
									if(AttackQueue)
										if(AttackQueue.InstantStrikesPerformed<AttackQueue.InstantStrikes-1)
											AttackQueue.InstantStrikesPerformed++
											goto STRIKE
								if(AttackQueue)
									QueuedHitMessage(enemy)
									src.doQueueEffects(enemy)
							var/hitsparkSword = swordAtk
							if(swordAtk && HasSwordPunching())
								hitsparkSword = 0
							HitEffect(enemy, unarmedAtk, hitsparkSword, SecondStrike, ThirdStrike, disperseX, disperseY)


							if(passive_handler.Get("MonkeyKing"))
								if(prob(passive_handler.Get("MonkeyKing")* 25 ))
									summonMonkeySoldier(damage, passive_handler.Get("MonkeyKing"))

							if(UsingAnsatsuken())
								HealMana(clamp((damage*1.25) * SagaLevel, 0.5, 20), 1)
							if(SagaLevel>1&&Saga=="Path of a Hero: Rebirth")
								if(passive_handler["Determination"])
									HealMana(clamp((damage*0.25) * SagaLevel, 0.5, 20), 1)
								else
									HealMana(clamp((damage*1) * SagaLevel, 0.5, 20), 1)
							if(passive_handler["RenameMana"])
								HealMana(clamp(damage * (Potential/10), 0.005, 25), 1)
							if(GetAttracting())
								enemy.AddAttracting(GetAttracting(), src)
								// 		OTHER DMG START 		//
							var/otherDmg = (damage+(GetIntimidation()/100)*(1+(2*GetGodKi())))

							// if(UsingZornhau()&&HasSword())
							// 	otherDmg *= 1 + (UsingZornhau()*glob.ZORNHAU_MULT)

							if(UsingKendo()&&HasSword()&&CountStyles(2))
								if(s.Class == "Wooden")
									otherDmg *= 1.15

							if(UsingCriticalImpact())
								otherDmg *= 1.25

							if(passive_handler.Get("Quaker"))
								otherDmg += passive_handler.Get("Quaker")
							if(passive_handler.Get("QuakerMod"))
								otherDmg *= passive_handler.Get("QuakerMod")
							if(passive_handler["Rupture"])
								applyDebuff(enemy, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Rupture, "Rupture","rupture", 200)
							if(passive_handler["Overwhelming"])
								applyDebuff(enemy, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Cornered, "Overwhelming","overwhelm", 200)
							if(passive_handler["Serrated"] && (s || s2 || s3))
								if(prob(passive_handler["Serrated"] * glob.SERRATEDCHANCE))
									applyDebuff(enemy, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Festered_Wound, "Serrated", "serrated", glob.SERRATEDCD)



						// HIT EFFECTS //

							if(UsingVortex()&& otherDmg>=3) // wtf is this
								for(var/mob/m in oview(round(otherDmg/3,1 ), src))
									// get everyone around em
									m.AddSlow(otherDmg/3, src)

							if(otherDmg >= 3 || AttackQueue&&QueuedKBAdd()||SureKB)
								if(!shocked)
									KenShockwave(enemy, Size=clamp(otherDmg * randValue(0.001,0.2), 0.0001, 1.5), PixelX = disperseX, PixelY = disperseY, Time=4)
									var/quakeIntens = otherDmg
									if(quakeIntens>14)
										quakeIntens=14
									enemy?.Earthquake(quakeIntens, -4,4,-4,4)
					else
							//		MISS START  //
						if(enemy.CheckSpecial("Ultra Instinct"))
							if(AttackQueue)
								if(AttackQueue.HitSparkIcon)
									disperseX=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
									disperseY=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
									HitEffect(enemy, unarmedAtk, swordAtk, SecondStrike, ThirdStrike, disperseX, disperseY)
							UltraPrediction2(enemy, src)
						else if(AttackQueue&&AttackQueue.NoWhiff)
							enemy.dir=get_dir(enemy,src)
							flick("Attack", enemy)
							if(!lightAtk)
								KenShockwave(enemy,icon='KenShockwave.dmi',Size=(src.GetIntimidation()+enemy.GetIntimidation())*0.4,PixelX=((enemy.x-src.x)*(-16)+pick(-12,-8,8,12)),PixelY=((enemy.y-src.y)*(-16)+pick(-12,-8,8,12)), Time=6)
							if(AttackQueue&&AttackQueue.DrawIn)
								enemy.AddAttracting((AttackQueue.DrawIn*QueuedDamage(enemy)), src)
						else
							spawn()
								Dodge(enemy)
						if(AttackQueue)
							spawn()
								QueuedMissMessage()
				if(passive_handler["Tossing"] && passive_handler["Secret Knives"])
					var/sk = passive_handler["Secret Knives"]
					if(prob(passive_handler["Tossing"] * glob.SECRET_KNIFE_CHANCE))
						var/path = "/obj/Skills/Projectile/[sk]"
						var/obj/Skills/Projectile/p = FindSkill(path)
						if(!ispath(text2path(path)))
							path = /obj/Skills/Projectile/Secret_Knives
							world.log << "[sk] PATH FOR SECRET KNIVES DOESN'T EXIST!"
						if(!p)
							p = new path
							AddSkill(p)
						p.adjust(src)
						src.UseProjectile(p)

				if(delay<=0.5)
					delay = 0.5

	else
		var/TurfDamage=(src.potential_power_mult*src.PowerBoost*src.Power_Multiplier*src.AngerMax)*(src.GetStr(3)+src.GetFor(2)+src.GetIntimidation()+(10*src.GetWeaponBreaker()))
		for(var/turf/T in get_step(src,src.dir))
			flick("Attack",src)
			T.Health-=TurfDamage
			if(T.Health<=0) Destroy(T)
			return
		for(var/obj/P in get_step(src,src.dir))
			if(!P.Attackable)
				continue
			flick("Attack",src)
			for(var/obj/Seal/S in P)
				if(src.ckey!=S.Creator)
					TurfDamage=0
			if(P.Destructable)
				if(P.Health<=TurfDamage)
					Destroy(P)
			return
		if(src.HasSpecialStrike()||EquippedStaff())
			flick("Attack",src)
			NextAttack=world.time
			if(src.CheckSpecial("Ray Gear"))
				if(src.AttackQueue)
					if(src.AttackQueue.Warp)
						GetAndUseSkill(/obj/Skills/Projectile/Homing_Ray_Missiles, Projectiles, TRUE)
					else
						GetAndUseSkill(/obj/Skills/Projectile/Plasma_Cannon, Projectiles, TRUE)
					src.ClearQueue()
					NextAttack+=15
				else
					GetAndUseSkill(/obj/Skills/Projectile/Machine_Gun_Burst, Projectiles, TRUE)
					NextAttack+=15
			else if(src.CheckSpecial("Wisdom Form"))
				GetAndUseSkill(/obj/Skills/Projectile/Wisdom_Form_Blast, Projectiles, TRUE)
			else if(src.CheckSlotless("OverSoul"))
				GetAndUseSkill(/obj/Skills/AutoHit/DurendalPressure, AutoHits, TRUE)
			else if(src.CheckSlotless("Heavenly Ring Dance"))
				if(src.Target&&src.Target!=src)
					src.Target.Frozen=1
					src.Target.AddCrippling(20)
					if(src.Target.SenseRobbed<(src.SenseUnlocked-1)&&!src.AttackQueue&&src.TotalFatigue<50&&!BreakAttackRate)
						RecoverImage(src.Target)
						src.Target.SenseRobbed++
						src.GainFatigue(10)
						if(src.Target.SenseRobbed==1)
							src.Target << "You've been stripped of your sense of touch! You find it harder to move!"
						else if(src.Target.SenseRobbed==2)
							src.Target << "You've been stripped of your sense of smell! You find it harder to breathe!"
						else if(src.Target.SenseRobbed==3)
							src.Target << "You've been stripped of your sense of taste! You find it harder to speak!"
						else if(src.Target.SenseRobbed==4)
							src.Target << "You've been stripped of your sense of hearing! You find it harder to hear!"
						else if(src.Target.SenseRobbed==5)
							src.Target << "You've been stripped of your sense of sight! You find it harder to see!"
							animate(src.Target.client, color = list(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1), time = 5)
						else if(src.Target.SenseRobbed==6)
							src.Target << "You've been stripped of your sixth sense! Your mind is clouded and your abilities are crippled!"
					else
						src.ClearQueue()
						src.Activate(new/obj/Skills/AutoHit/Heavenly_Ring_Dance)
						for(var/obj/Skills/Buffs/SlotlessBuffs/Heavenly_Ring_Dance/TH in usr.AutoHits)
							usr.UseBuff(TH)

					NextAttack+=30
					sleep(10)
					src.Target.Frozen=0
				else
					src.Activate(new/obj/Skills/AutoHit/Heavenly_Ring_Dance_Burst)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Heavenly_Ring_Dance/TH in usr.AutoHits)
						usr.UseBuff(TH)
			else if(src.CheckSlotless("Libra Armory")&&src.AttackQueue)
				GetAndUseSkill(/obj/Skills/Projectile/Libra_Slash, Projectiles, TRUE)
				src.ClearQueue()
			else if(src.CheckSlotless("Spirit Bow"))
				GetAndUseSkill(/obj/Skills/Projectile/Aether_Arrow, Projectiles, TRUE)
			else if(src.CheckSlotless("Sagittarius Bow")&&!AttackQueue&&!passive_handler.Get("HotHundred"))
				GetAndUseSkill(/obj/Skills/Projectile/Sagittarius_Arrow, Projectiles, TRUE)
			else if(st&&st.modifiedAttack)
				if(!locate(/obj/Skills/Projectile/Staff_Projectile, Projectiles))
					src.AddSkill(new/obj/Skills/Projectile/Staff_Projectile)
				for(var/obj/Skills/Projectile/Staff_Projectile/pc in Projectiles)
					switch(st.Class) // ascensions should do something here
						if("Wand")
							pc.Blasts = 3
							pc.DamageMult = 0.25
							pc.Speed = 0.75
						if("Rod")
							pc.Blasts = 2
							pc.DamageMult = 0.75
							pc.Speed = 1
						if("Staff")
							pc.Blasts = 1
							pc.DamageMult = 1.5
							pc.Speed = 1.25
					src.UseProjectile(pc)
			return

/mob/var/Momentum = 0
/mob/var/Fury = 0
/mob/proc/handlePostDamage(mob/enemy, damage)
	if(passive_handler["LeakCash"])
		for(var/obj/Money/money in src.contents)
			if(money.Level>0)
				var/newX = 0
				var/newY = 0
				if(!glob.racials.CASHLEAKREMOVES)
					newX = src.x + rand(-3, 3)
					newY = src.y + rand(-3, 3)
					for(var/i = 0, i < 10; i++)
						var/turf/t = locate(newX,newY,src.z)
						if(t.density)
							if(i == 9) break
							newX = src.x + rand(-3, 3)
							newY = src.y + rand(-3, 3)
							continue
						else
							break
				var/obj/gold/gold = new()
				gold.createPile(src, enemy, newX, newY, src.z, glob.racials.CASHLEAKREMOVES)
				src << "You feel a need to go collect your coins before they're stolen!"
	if(passive_handler.Get("Mortal Will"))
		passive_handler.Increase("MortalStacks")
		if(passive_handler.Get("MortalStacks") >= 6)
			passive_handler.Set("MortalStacks", 1)
			if(!locate(/obj/Skills/Projectile/Comet_Spear, src))
				src.AddSkill(new/obj/Skills/Projectile/Comet_Spear)
			for(var/obj/Skills/Projectile/Comet_Spear/cp in src)
				cp.adjust(src)
				src.UseProjectile(cp)
	if(glob.MOMENTUM_PROCS_OFF_DAMAGE)
		var/momentum = passive_handler.Get("Momentum")
		var/acu = enemy.passive_handler["Acupuncture"]
		if(momentum)
			if(acu)
				if(prob(acu * glob.ACUPUNCTURE_BASE_CHANCE))
					Momentum = clamp( Momentum - acu/glob.ACUPUNCTURE_DIVISOR, 0 , passive_handler["Relentlessness"] ? 100 : glob.MAX_MOMENTUM_STACKS)
			else
				if(prob(glob.BASE_MOMENTUM_CHANCE * momentum))
					Momentum = clamp( round(Momentum + (1 + momentum/glob.MOMENTUM_DIVISOR)), 0 , passive_handler["Relentlessness"] ? 100 : glob.MAX_MOMENTUM_STACKS)
		if(passive_handler["Fury"])
			if(acu && prob(acu * glob.ACUPUNCTURE_BASE_CHANCE))
				Fury = clamp( Fury - acu/glob.ACUPUNCTURE_DIVISOR, 0 , passive_handler["Relentlessness"] ? 100 : glob.MAX_FURY_STACKS)
			else
				if(prob(glob.BASE_FURY_CHANCE * passive_handler["Fury"]))
					Fury = clamp(Fury + 1 + passive_handler["Fury"]/glob.FURY_DIVISOR, 0, passive_handler["Relentlessness"] ? 100 : glob.MAX_FURY_STACKS)