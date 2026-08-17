
/mob/var/tmp/list/lasts_list = list("overwhelm" = -999, "rupture" = -999, "serrated" = -999)
/mob/var/tmp/petal_attacking = FALSE
/proc/getDeciderDamage(playerHealth, sourceHealth)
	var/healthDifference = abs(playerHealth - sourceHealth)
	var/damageMultiplier = 2 * (2.7** (-healthDifference/10))
	return round(damageMultiplier, 0.01)

/mob/proc/lightRush(mob/enemy, option)
	if(option == "Launch")
		if(enemy.Launched)
			if(passive_handler["Sajire Rush"])
				return TRUE
			if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Launchers"))
				return TRUE
			if(passive_handler.Get("Bear Spirit"))
				return TRUE
	else if(option == "Stun")
		if(enemy.Stunned)
			if(passive_handler["Sajire Rush"])
				return TRUE
			if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Stunners"))
				return TRUE
			if(passive_handler.Get("Bear Spirit"))
				return TRUE
	return FALSE


/mob/proc/Melee1(dmgmulti=1, spdmulti=1, iconoverlay, forcewarp, forcedTarget=null, ExtendoAttack=null, SecondStrike, ThirdStrike, AsuraStrike, accmulti=1, SureKB=0, NoKB=0, IgnoreCounter=0, BreakAttackRate=0, hitback = 0)
	if(HeldSkillBlocksAction(null)) return
	if(!AttackQueue)
		for(var/a in SlotlessBuffs)
			var/obj/Skills/Buffs/b = SlotlessBuffs[a]
			if(istype(b, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura))
				var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/aura = b
				if(aura.TossSkill)
					if((last_aura_toss - ((passive_handler["Familiar"]-1) * glob.FAMILIAR_CD_REDUCTION)) + glob.FAMILIAR_SKILL_CD < world.time && (Target && Target != src))
						last_aura_toss = world.time
						throwFollowUp(aura.skillToToss)
		if(passive_handler["EntanglingRoots"] && can_use_style_effect("EntanglingRoots") && Target != src)
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
	if(Suspended)
		return
	if(Airborne)
		return
	if(judgement_cut_chain_active)
		return
	if(SecondStrike || ThirdStrike || AsuraStrike)
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
	#endif
	// 				EXTRA EFFECTS 			//

	if(!AsuraStrike)
		MultiStrike(SecondStrike, ThirdStrike, AsuraStrike)
	if(!ThirdStrike)
		MultiStrike(SecondStrike, ThirdStrike) // trigger double/triple strike if applicable
	var/warpingStrike = getWarpingStrike() // get warping strike if applicable
	var/iaidoGaugeMax = 100;
	if(IaidoCounter>=iaidoGaugeMax)
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

	var/list/itemMod = getItemDamage(list(s,s2,s3,st), delay, acc, SecondStrike, ThirdStrike, AsuraStrike, swordAtk, specialAtk)
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
		if(HasTarget() && TargetInRange(glob.NIMBUSRANGE + passive_handler["Nimbus"]) && !CheckSlotless("Nimbus Rider"))
			if(CanDash())
				is_dashing++
				AfterImageGhost(src)
				DashTo(Target, glob.NIMBUSRANGE + passive_handler["Nimbus"], 1 - (passive_handler["Nimbus"]/4), 0)
				var/msg = replacetext(nimbus_message, "player_name", "[src]")
				msg = replacetext(msg, "target_name", "[src.Target]")
				src.OMessage(10,"[msg]","<font color=red>[src]([src.key]) rides the Nimbus.")
				last_nimbus = world.time
				if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastkin/Nimbus_Rider, src)) // TODO maybe change this so its better
					AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastkin/Nimbus_Rider)
				for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastkin/Nimbus_Rider/nr in src)
					if(!nr.Using)
						nr.passives = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastkin/Nimbus_Rider::passives
						nr.Trigger(src)
				// TODO: make hud later if we feel like it chat
	if(warpingStrike && !petal_attacking)
		if(Target && Target.loc && Target != src)
			var/inWarp
			if(PmActive())//step-inclusive so a mid-tile target doesn't round out of warp range
				inWarp = max(abs((Target.x-x)*32 + (Target.step_x-step_x)), abs((Target.y-y)*32 + (Target.step_y-step_y))) < warpingStrike*32
			else
				inWarp = get_dist(Target, src) < warpingStrike
			if(inWarp)
				forcewarp = Target
	if((forcewarp && Target.z == z && !petal_attacking))
		if(passive_handler["Flying Thunder God"] && IaidoCounter>=iaidoGaugeMax)
			new/obj/tracker/FTG_seeker(locate(x,y,z), Target, src) //TODO: make this a normal projectile maybe? does no damage, but throws this, idk that way it can be used as a follow up
			if(IaidoCounter)
				IaidoCounter = 0
		else
			Comboz(forcewarp)


		//	WARPING END	//

		//	DELAY	//

	delay = adjustDelay(delay)

	var/obj/Items/Armor/atkArmor = EquippedArmor()
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

	if(delay<=0.5)
		delay = 0.5

	if(!BreakAttackRate)
		NextAttack = world.time
	else
		if(AttackQueue)
			if(AttackQueue.Combo && (!Target || Target == src))
				NextAttack = world.time
			if(AttackQueue.Counter)
				NextAttack = world.time + delay



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

		var/refresh = passive_handler.Get("RefreshingBlows");
		if(refresh) src.RefreshBlow(refresh);

		if(!petal_attacking) NextAttack += delay
		var/Disarm = 0
		if(src.UsingGladiator())
			if(src.GladiatorCounter >= glob.GLADIATOR_DISARM_MAX / src.UsingGladiator())
				Disarm = 1
				src.GladiatorCounter = 0
		for(var/mob/enemy in enemies)
			if(istype(enemy, /mob/irlNPC))
				continue
			if(istype(enemy, /mob/MonkeySoldier))
				continue
			if(enemy.Stasis)
				continue
			if(enemy != src)
				if(Disarm)
					src.DisarmTarget(enemy);
		// 				STATS 					//
				#if DEBUG_MELEE
				log2text("DamageMod", "old DmgMod", "damageDebugs.txt", "[ckey]/[name]")
				log2text("DamageMod", itemMod[3], "damageDebugs.txt", "[ckey]/[name]")
				#endif
				var/powerDif = Power / enemy.Power
				if(glob.CLAMP_POWER)
					if(!ignoresPowerClamp(enemy))
						powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)

				#if DEBUG_MELEE
				log2text("powerDif", powerDif, "damageDebugs.txt", "[ckey]/[name]")
				#endif
				var/atk = getStatDmg2()
				var/def = enemy.getEndStat(1)
				var/damageMultiplier = dmgmulti
				if(AttackQueue)
					var/qIdnt = AttackQueue.FocusStatIdentity()
					var/qStr = FocusShiftScaling(qIdnt, "STR", AttackQueue.StrScaling)
					var/qFor = FocusShiftScaling(qIdnt, "FOR", AttackQueue.ForScaling)
					var/queueAtk = (qStr ? GetStr(qStr) : 0) + (qFor ? GetFor(qFor) : 0) + (AttackQueue.SpdScaling ? GetSpd(AttackQueue.SpdScaling) : 0) + (AttackQueue.OffScaling ? GetOff(AttackQueue.OffScaling) : 0) + (AttackQueue.DefScaling ? GetDef(AttackQueue.DefScaling) : 0) + (AttackQueue.EndScaling ? GetEnd(AttackQueue.EndScaling) : 0)
					var/qBase = AttackQueue.BaseStatOverride(src)
					if(qBase)
						atk = qBase
					atk += queueAtk
					def *= AttackQueue.EndEffectiveness
				if(AttackQueue && AttackQueue.HarderTheyFall)
					var/enemyEnd = enemy.GetEnd()
					atk += enemyEnd * (AttackQueue.HarderTheyFall/10)
				#if DEBUG_MELEE
				log2text("DamageMod", "newDmgMod", "damageDebugs.txt", "[ckey]/[name]")
				log2text("DamageMod", damage, "damageDebugs.txt", "[ckey]/[name]")
				#endif


				#if DEBUG_MELEE
				log2text("atk/def stats", "[atk]/[def]", "damageDebugs.txt", "[ckey]/[name]")

				// powerDif += src.getIntimDMGReduction(enemy)

				log2text("powerDif (After Intim)", powerDif, "damageDebugs.txt", "[ckey]/[name]")
				#endif

				damage = strikeCoreDamage(powerDif, atk, def)


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
					damage *= glob.GIANT_FORM_DMG_MULT
		// 				GIANT FORM END			//

				damage *= strikeJudgmentMult()

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

				var/obj/Items/Armor/defArmor = enemy.EquippedArmor()
		// 				ARMOR END				//

		// 				QUEUE	 				//
				var/knockDistance = 0
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
					knockDistance += QueuedKBAdd()

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
				if(!src.petal_attacking) flick("Attack",src)
				if(passive_handler["Hit Scan"]) // this is troublesome
					new/obj/tracker(locate(x,y,z),enemy, src, HitScanIcon, HitScanHitSpark,HitScanHitSparkX, HitScanHitSparkY)
				//TODO: come back to this
				var/countered=0

				if(AttackQueue && AttackQueue.Dunker && enemy.Launched)
					if(AttackQueue.Dunker)
						DunkSlam(src, enemy)	//rise to them, hit lands mid-air, both slam down
						sleep(3)
				else
					damage *= enemy.ccProrationMult(src)	//queued hits scale too, that's the point
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
					if(passive_handler.Get("Bear Spirit"))
						damage *= 1
						adjust = 3
					if(enemy.Launched && Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Launchers"))
						damage *= 1+secretDatum?:getBoon(src,"Launchers")
					if(enemy.Stunned && Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Stunners"))
						damage *= 1+secretDatum?:getBoon(src,"Stunners")
					if(passive_handler["Speed Force"])
						damage *= 0 + (0.25 * passive_handler["Speed Force"])
					else
						damage /= max(2,4-adjust)
					damage *= clamp(GetSpd()**glob.LIGHT_ATTACK_SPEED_DMG_EXPONENT,glob.LIGHT_ATTACK_SPEED_DMG_LOWER,glob.LIGHT_ATTACK_SPEED_DMG_UPPER) // args were swapped - the 3x cap never applied
					if(!adjust)
						NoKB=1
					if(SecondStrike || ThirdStrike || AsuraStrike)
						damage *= 0.3

					NextAttack = world.time + 1.25
					#if DEBUG_MELEE
					log2text("Damage", "After HotHundred", "damageDebugs.txt", "[ckey]/[name]")
					log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
					#endif
		// 				HOT HUNDRED END			//

		// 				MELEE COUNTER 			//
				countered = counterShit(enemy, IgnoreCounter)
				//queue-counter: fresh queue reads the incoming queued swing and punishes it
				if(!countered && !IgnoreCounter && AttackQueue && enemy.AttackQueue && world.time <= enemy.queue_counter_until && !enemy.Stunned && !enemy.Launched)
					var/atkFin = istype(AttackQueue, /obj/Skills/Queue/Finisher)
					var/defFin = istype(enemy.AttackQueue, /obj/Skills/Queue/Finisher)
					if(!(atkFin && !defFin))	//a finisher punches through normal windows
						enemy.queue_counter_until = 0
						countered = 1
						if(atkFin && defFin)	//finisher clash: both spent, big cinematic
							ClearQueue()
							enemy.ClearQueue()
							enemy.AfterImageStrike++	//forces the clash branch, decremented inside it
							AfterImageStrike(src, enemy, 0)
						else
							enemy.dir = get_dir(enemy, src)
							enemy.NextAttack = 0
							var/mob/counterer = enemy
							spawn() counterer.Melee1(1, 1, IgnoreCounter = 1)
		// 				MELEE COUNTER END		//

		// 				HIT RESOLUTION 			//

				if(enemy.Stunned)
					hitResolution = HIT

				//snapshot before the hit can cancel their beam/charge out
				var/counterHit = enemy.isCommitted()

				if(!countered)
					var/dodged = 0
					var/disperseX = rand(-12,12)
					var/disperseY = rand(-12,12)
					// If it was not countered
					if(hitResolution != MISS)
						// and they hit in any way
					// 				AIS			 			//
						if(enemy.aisArmed()&&!dodged)
							enemy.aisConsume()

							if(AttackQueue && AttackQueue.HitSparkIcon)
								disperseX=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
								disperseY=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
								var/hitsparkSword = swordAtk
							//	if(swordAtk && HasBladeFisting())
							//		hitsparkSword = 0
								HitEffect(enemy, unarmedAtk, hitsparkSword, SecondStrike, ThirdStrike, AsuraStrike, disperseX, disperseY)
							StunClear(enemy)
							AfterImageStrike(enemy,src,1)
							dodged = 1

					// 				AIS END					//

						else

					// 	 			NO DODGE				//

							if(enemy.aisArmed()&&!enemy.IsGuarding()&&!passive_handler.Get("NoDodge")&&!dodged&&!IgnoreCounter)
								enemy.aisConsume()

								if(AttackQueue && AttackQueue.HitSparkIcon)
									disperseX=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
									disperseY=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
									var/hitsparkSword = swordAtk
							//		if(swordAtk && HasBladeFisting())
							//			hitsparkSword = 0
									HitEffect(enemy, unarmedAtk, hitsparkSword, SecondStrike, ThirdStrike, AsuraStrike, disperseX, disperseY)
								enemy.dir = get_dir(enemy,src)
								StunClear(enemy)
								enemy.NextAttack=0
								enemy.Melee1(1,1,SureKB=1)
								dodged = 1
					// 				NO DODGE END		//
						if(AttackQueue && enemy.passive_handler.Get("Sunyata"))
							if( prob(enemy.passive_handler.Get("Sunyata") * glob.SUNYATA_BASE_CHANCE))
								OMsg(enemy, "<b><font color=#ff0000>[enemy] has negated [src]'s attack!</font></b>")
								dodged = 1
						if((AttackQueue && enemy.passive_handler["Interception"]) && !AttackQueue.Finisher)
							if(prob(enemy.passive_handler["Interception"] * glob.INTERCEPTION_BASE_CHANCE))
								OMsg(enemy, "<b><font color=#ff0000>[enemy] reverses [src]'s attack!</font></b>")
								dodged = 1
								ClearQueue()
								var/obj/Effects/Interception/p = new()
								p.Target = enemy
								enemy.vis_contents += p
								flick( "interception", p )
								enemy.InterceptionStrike(src, enemy.passive_handler["Interception"])
						if(!dodged)
					// 				HIT					//

							enemy.ccCountHit()
							var/damageSnapshot = damage
							STRIKE
							if(AttackQueue?.InstantStrikesPerformed)
								damage = damageSnapshot
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
							if(hitResolution == WHIFF)
								var/whiffed = TRUE
								if(AttackQueue)
									if(AttackQueue.NoWhiff)
										hitResolution = HIT
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

							if(AttackQueue)
							// 				ONHITS				//
								if(AttackQueue.Burning||AttackQueue.Scorching||AttackQueue.Chilling||AttackQueue.Freezing||AttackQueue.Crushing||AttackQueue.Shattering||AttackQueue.Shocking||AttackQueue.Paralyzing||AttackQueue.Poisoning||AttackQueue.Toxic)
									var/list/addElements = list()
									if(AttackQueue.Burning||AttackQueue.Scorching)
										addElements |= "Fire"
									else if(AttackQueue.Chilling||AttackQueue.Freezing)
										addElements |= "Water"
									else if(AttackQueue.Crushing||AttackQueue.Shattering)
										addElements |= "Earth"
									else if(AttackQueue.Shocking||AttackQueue.Paralyzing)
										addElements |= "Wind"
									else if(AttackQueue.Poisoning||AttackQueue.Toxic)
										addElements |= "Poison"
									ElementalCheck(src, enemy, 0, glob.DEBUFF_INTENSITY, addElements)

								if(AttackQueue.Shearing)
									enemy.AddShearing(AttackQueue.Shearing,src)
								if(AttackQueue.Crippling)
									enemy.AddCrippling(AttackQueue.Crippling, src)
								if(AttackQueue.Doom)
									enemy.AddDoom(AttackQueue.Doom, src)
								if(AttackQueue.Ashing)
									applyAshChoked(enemy, src)

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
								var/parryVal = enemy.passive_handler["Parry"]
								if(prob(glob.PARRY_CHANCE_CAP * parryVal / (parryVal + glob.PARRY_CHANCE_CURVE)) && hitback <= glob.MAX_CHAIN_PARRY && enemy.CanMeleeReach(src))
									var/obj/Effects/Parry/p = new()
									p.Target = enemy
									enemy.vis_contents += p
									flick("parry", p)
									enemy.Melee1(dmgmulti = (glob.PARRY_BASE_DMG * (parryVal+enemy.BonusParry())), forcedTarget=src, hitback=hitback+1)
							if(enemy.passive_handler["Iaijutsu"] && (s || s2 || s3 || swordAtk))
								var/iaiVal = enemy.passive_handler["Iaijutsu"]
								if(prob(glob.IAI_CHANCE_CAP * iaiVal / (iaiVal + glob.IAI_CHANCE_CURVE)))
									var/obj/Effects/Iai/p = new()
									p.Target = enemy
									enemy.vis_contents += p
									flick("iai", p)
									damage *= glob.IAI_DR_MULT
							if(enemy.passive_handler["Perfect Counter"])
								// if only we could ping the thing that is giving this
								enemy.TriggerPerfectCounter(src) // i cant actually test this
							if(defArmor)
								var/dmgEffective = enemy.GetArmorDamage(defArmor)
								var/peel = passive_handler.Get("ArmorPeeling")
								if(peel)
									dmgEffective *= 1 - (glob.ARMOR_PEEL_CAP * peel / (peel + 2))
								if(UsingHalfSword())
									dmgEffective -= UsingHalfSword() * glob.HALF_SWORD_ARMOR_REDUCTION
								if(dmgEffective>0)
									damage -=  damage * dmgEffective/10
								else
									damage += damage * abs(dmgEffective/10)
								#if DEBUG_MELEE
								log2text("damage", "After Armor", "damageDebugs.txt", "[ckey]/[name]")
								log2text("damage", damage, "damageDebugs.txt", "[ckey]/[name]")
								#endif
							if(UsingHalfSword() && !defArmor)
								damage += damage * (UsingHalfSword()/glob.HALF_SWORD_UNARMOURED_DIVISOR)
							damage *= glob.GLOBAL_MELEE_MULT
							#if DEBUG_MELEE
							log2text("Damage", "After Global Multiplier", "damageDebugs.txt", "[ckey]/[name]")
							log2text("Damage", damage, "damageDebugs.txt", "[ckey]/[name]")
							#endif
							//Reflexively stunning an opponent is bad. fight me over it ~ xoxo
							/*if(enemy.hasMagmicShield())
								Stun(src, 3, FALSE)
								enemy.MagmicShieldOff();*/
							damage *= enemy.getMeleeResistValue();//this is 1 if there is no melee resistance passive on the enemy
							var/sniper = passive_handler.Get("Sniper")
							if(sniper > 0 && enemy.loc)
								var/dist = get_dist(src, enemy)
								if(dist > 0)
									damage *= 1 + (sniper * dist * 0.01)
							// For Tetrakarn reflect
							var/strike/S = new(src, enemy, damage)
							S.unarmed = unarmedAtk
							S.sword = swordAtk
							S.second = SecondStrike
							S.third = ThirdStrike
							S.melee = 1
							S.element = (AttackQueue ? AttackQueue.SpellElement : null)
							if(AttackQueue)
								S.dmgTypes = buildSpecDmgTypes(AttackQueue.HolyMod, AttackQueue.Sanctify, AttackQueue.AbyssMod, AttackQueue.SlayerMod)
								S.critEff = AttackQueue.CritEffectiveness
								S.blockEff = AttackQueue.BlockEffectiveness
								S.critBonus = AttackQueue.CritChanceBonus
							var/dmgValue = S.resolve()
							. = dmgValue
							lastHit = world.time
							if(istype(AttackQueue, /obj/Skills/Queue/Finisher))
								enemy.AngerEvent(glob.ANGER_RUSH_FINISHER)
							//raw damage on purpose - otherDmg doesn't exist yet at spark time
							var/hitWeight = clamp((damage - glob.HIT_STOP_MIN) / max(1, 14 - glob.HIT_STOP_MIN), 0, 1)
							enemy?.HitBend(hitWeight, get_dir(src, enemy))
					// 										MELEE END																	 //
							var/shocked=0
							if((SureKB || AttackQueue && QueuedKBAdd()) && !NoKB)
								if(AttackQueue)
									knockDistance *= QueuedKBMult()
								knockDistance = round(knockDistance)
								if(SureKB && knockDistance < max(SureKB, 5))
									knockDistance = max(SureKB, 5)
								if(!AttackQueue || AttackQueue && !AttackQueue.Grapple)
									if(enemy)
										if(enemy.passive_handler&&enemy.passive_handler.Get("Blubber")||enemy.passive_handler&&enemy.passive_handler.Get("The Immovable Object"))
											var/blubber = enemy.passive_handler.Get("Blubber")
											if(enemy.passive_handler.Get("The Immovable Object"))
												blubber+=5
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
								//	if(swordAtk && HasBladeFisting())
								//		hitsparkSword = 0
									//HitEffect args are positional - new ones go on the end, passed named
									HitEffect(enemy, unarmedAtk, hitsparkSword, SecondStrike, ThirdStrike, AsuraStrike, disperseX, disperseY, Weight=hitWeight)
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
						//	if(swordAtk && HasBladeFisting())
						//		hitsparkSword = 0
							//double HitEffect with the queue dispatch above is intentional
							if(!src.petal_attacking) HitEffect(enemy, unarmedAtk, hitsparkSword, SecondStrike, ThirdStrike, AsuraStrike, disperseX, disperseY, Weight=hitWeight)


							if(passive_handler.Get("MonkeyKing"))
								if(prob(passive_handler.Get("MonkeyKing")* 25 ))
									summonMonkeySoldier(damage, passive_handler.Get("MonkeyKing"))

							if(UsingAnsatsuken())
								HealMana(clamp((damage*1.25) * SagaLevel, 0.5, 20), 1)
							if(SagaLevel>1&&Saga=="Path of a Hero: Rebirth")
								if(passive_handler["Determination"])
									if(passive_handler["Determination(White)"])
										HealMana(clamp((damage*0.4) * SagaLevel, 0.5, 20), 1)
									else
										HealMana(clamp((damage*0.4) * SagaLevel, 0.5, 20), 1)
								else
									HealMana(clamp((damage*1) * SagaLevel, 0.5, 20), 1)
							if(GetAttracting())
								enemy.AddAttracting(GetAttracting(), src)
								// 		OTHER DMG START 		//
							var/otherDmg = damage

							if(UsingKendo()&&HasSword()&&CountStyles(2))
								if(s.Class == "Wooden")
									otherDmg *= 1.15

							if(UsingCriticalImpact())
								otherDmg *= 1.25

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
									HitStop(src, enemy, quakeIntens, counterHit ? glob.COUNTER_HIT_STOP_BONUS : 0)
									if(counterHit)
										src.gainTension(glob.COUNTER_HIT_TENSION)
									//shake lurches the way the hit lands
									enemy?.Earthquake(quakeIntens, -4,4,-4,4, 0, get_dir(src, enemy))
							else if(counterHit)
								CounterHitReward(src, enemy, otherDmg)
					else
							//		MISS START  //
						if(enemy.CheckSpecial("Ultra Instinct"))
							if(AttackQueue)
								if(AttackQueue.HitSparkIcon)
									disperseX=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
									disperseY=rand((-1)*AttackQueue.HitSparkDispersion, AttackQueue.HitSparkDispersion)
									HitEffect(enemy, unarmedAtk, swordAtk, SecondStrike, ThirdStrike, AsuraStrike, disperseX, disperseY)
							UltraPrediction2(enemy, src)
						else if(AttackQueue&&AttackQueue.NoWhiff)
							enemy.dir=get_dir(enemy,src)
							flick("Attack", enemy)
							if(!lightAtk)
								KenShockwave(enemy,icon='KenShockwave.dmi',Size=0.4,PixelX=((enemy.x-src.x)*(-16)+pick(-12,-8,8,12)),PixelY=((enemy.y-src.y)*(-16)+pick(-12,-8,8,12)), Time=6)
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
				if(passive_handler["Tossing"] && passive_handler["Extra Secret Knives"])
					var/sk = passive_handler["Extra Secret Knives"]
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

	else
		var/TurfDamage=(potential_power_mult*PowerBoost*Power_Multiplier*AngerMax)*(GetStr(3)+GetFor(2)+(10*GetWeaponBreaker()))
		for(var/turf/T in get_step(src,src.dir))
			flick("Attack",src)
			T.Health-=TurfDamage
			if(T.Health<=0) Destroy(T)
			return
		for(var/obj/P in get_step(src,src.dir))
			if(!P.Attackable)
				continue
			flick("Attack",src)
			if(istype(P, /obj/DomainExpansionBarrier))
				var/obj/DomainExpansionBarrier/barrier = P
				var/turf/bTurf = isturf(barrier.loc) ? barrier.loc : null
				var/mob/domainOwner = bTurf ? bTurf.domain_expansion_owner : null
				if(!domainOwner || !domainOwner.domainExpansionActive)
					return
				var/turf/aTurf = isturf(src.loc) ? src.loc : null
				if(aTurf && aTurf.domain_expansion_owner == domainOwner)
					src << "<b>The Domain boundary cannot be broken from the inside.</b>"
					return
				barrier.domain_hp -= TurfDamage
				if(barrier.domain_hp <= 0)
					domainOwner.domainExpansionBarriers -= barrier
					del(barrier)
					domainOwner.BreachDomain()
				return
			for(var/obj/Seal/S in P)
				if(src.ckey!=S.Creator)
					TurfDamage=0
			if(P.Destructable)
				if(P.Health<=TurfDamage)
					Destroy(P)
			return
		if(src.HasSpecialStrike()||EquippedStaff()||src.passive_handler["Determination(Yellow)"]||src.passive_handler["Determination(White)"]||hasSecret("Eldritch (Reflected)")||src.passive_handler["Chaos Buster"]&&src.ManaAmount > 10)
			flick("Attack",src)
			NextAttack=world.time
			if(src.passive_handler.Get("Gun Kata"))
				GetAndUseSkill(/obj/Skills/Projectile/GunKataShot, Projectiles, TRUE)
			if(src.passive_handler["Determination(Yellow)"]||src.passive_handler["Determination(White)"])
				if(SagaLevel<4)
					GetAndUseSkill(/obj/Skills/Projectile/SmallLemonThing, Projectiles, TRUE)
				if(SagaLevel>=4)
					if(prob(30))
						GetAndUseSkill(/obj/Skills/Projectile/BIG_SHOT, Projectiles, TRUE)
					else
						GetAndUseSkill(/obj/Skills/Projectile/SmallLemonThing, Projectiles, TRUE)
			if(hasSecret("Eldritch (Reflected)"))
				if(src.AttackQueue)
					if(src.AttackQueue.Warp)
						GetAndUseSkill(/obj/Skills/Projectile/Convergence, Projectiles, TRUE)
					else
						GetAndUseSkill(/obj/Skills/AutoHit/The_Other_Side, AutoHits, TRUE)
				else
					GetAndUseSkill(/obj/Skills/Projectile/Realitys_Fickle_Shards, Projectiles, TRUE)
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
			else if(src.CheckSlotless("OverSoul")&&BoundLegend=="Durendal")
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
						for(var/obj/Skills/Buffs/SlotlessBuffs/Heavenly_Ring_Dance/TH in src.AutoHits)
							src.UseBuff(TH)

					NextAttack+=30
					sleep(10)
					src.Target.Frozen=0
				else
					src.Activate(new/obj/Skills/AutoHit/Heavenly_Ring_Dance_Burst)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Heavenly_Ring_Dance/TH in src.AutoHits)
						src.UseBuff(TH)
			else if(src.CheckSlotless("Libra Armory")&&src.AttackQueue)
				GetAndUseSkill(/obj/Skills/Projectile/Libra_Slash, Projectiles, TRUE)
				src.ClearQueue()
			else if(src.CheckSlotless("Spirit Bow"))
				GetAndUseSkill(/obj/Skills/Projectile/Aether_Arrow, Projectiles, TRUE)
			else if(src.passive_handler.Get("Chaos Buster"))
				var/level = src.passive_handler.Get("Chaos Buster")
				if(level == 1)
					GetAndUseSkill(/obj/Skills/Projectile/ChaosBusterShot, Projectiles, TRUE)
				if(level == 2)
					GetAndUseSkill(/obj/Skills/Projectile/SuperChaosBusterShot, Projectiles, TRUE)
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

/mob/proc/handlePostDamage(mob/enemy, damage)
	if(passive_handler.Get("Mortal Will"))
		passive_handler.Increase("MortalStacks")
		if(passive_handler.Get("MortalStacks") >= 6)
			passive_handler.Set("MortalStacks", 1)
			if(!locate(/obj/Skills/Projectile/Comet_Spear, src))
				src.AddSkill(new/obj/Skills/Projectile/Comet_Spear)
			for(var/obj/Skills/Projectile/Comet_Spear/cp in src)
				cp.adjust(src)
				src.UseProjectile(cp)
	if(passive_handler["Momentum"])
		MomentumAccumulate()
	if(passive_handler["Fury"])
		FuryAccumulate();
