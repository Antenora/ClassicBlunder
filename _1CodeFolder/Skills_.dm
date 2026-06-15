

mob/var/cooldownAnnounce = 1
mob/verb
	CooldownAnnouncement()
		set category = "Other"
		set name = "Toggle Cooldown Announcement"
		if(usr.cooldownAnnounce)
			usr.cooldownAnnounce = 0
			usr << "Cooldown Announcement Disabled."
		else
			usr.cooldownAnnounce = 1
			usr << "Cooldown Announcement Enabled."



obj/Skills/var
	cooldown_remaining = 0
	cooldown_start
	tmp/halve_next_cd = 0
obj/Skills/proc/Cooldown(var/modify=1, var/Time, mob/p, var/announce_cd=1)
	var/mob/m=src.loc
	if(p)
		m = p
	if(MaxCharges > 0)
		if(p) hasMagmicInfusion(p)
		Charges--
		if(Charges <= 0)
			Using = 1
		if(!Time && m)
			if(!CooldownStatic)
				if(glob.SPEED_COOLDOWN_MODE)
					modify /= clamp(glob.SPEED_COOLDOWN_MIN, m.GetSpd()**glob.SPEED_COOLDOWN_EXPONENT, glob.SPEED_COOLDOWN_MAX)
				if(m.HasTechniqueMastery())
					var/TM = m.GetTechniqueMastery() / glob.TECHNIQUE_MASTERY_DIVISOR
					if(TM < 0)
						modify *= clamp(1+abs(TM), 1.1, glob.TECHNIQUE_MASTERY_LIMIT)
					else if(TM > 0)
						modify /= clamp((1+TM), 0.1, glob.TECHNIQUE_MASTERY_LIMIT)
			else
				if(m.Hustling())
					modify *= 0.75
			Time = src.ChargeRefresh * 10 * modify
		if(isnull(Time) || Time == 0)
			Time = src.ChargeRefresh * 10
		if(m && m.HasTestMode())
			Time = 1
		if(m)
			if(m.PureRPMode)
				return
			if(announce_cd && m.cooldownAnnounce)
				m << "[src]: [Charges]/[MaxCharges] charges remaining. Next charge in [Time / 10]s."
			Recharge(Time, m)
		return
	if(!src.Using || Time)
		if(p) hasMagmicInfusion(p);
		src.Using=1
		if(Cooldown==-1)
			src.Using=1
			return
		var/forcemessage=0
		var/list/lockedoutSkills = list()
		if(!Time && src && m)
			if(!src.CooldownStatic)
				if(glob.SPEED_COOLDOWN_MODE)
					modify /= clamp(glob.SPEED_COOLDOWN_MIN, m.GetSpd()**glob.SPEED_COOLDOWN_EXPONENT, glob.SPEED_COOLDOWN_MAX)
				if(m.HasTechniqueMastery())
					var/TM = m.GetTechniqueMastery() / glob.TECHNIQUE_MASTERY_DIVISOR
					if(TM < 0)
						modify *= clamp(1+abs(TM), 1.1, glob.TECHNIQUE_MASTERY_LIMIT)
					else if(TM > 0)
						modify/=clamp((1+(TM)),0.1,glob.TECHNIQUE_MASTERY_LIMIT)
				if(src.SpellElement)
					var/elem_cd_red = m.getSpellElementCooldownReduction(src.SpellElement)
					if(elem_cd_red)
						modify *= (1 - min(elem_cd_red, 0.80))
				if(CooldownDrag>=1)
					modify *= 1 + (CooldownDrag/100)
					CooldownDrag--
			else
				if(m.Hustling())
					modify*=0.75
			if(glob.SKILL_BRANCH_LOCK&&LockOut.len>0)
				for(var/obj/Skills/otherSkills in m.Skills)
					var/typeString = "[otherSkills.type]"
					for(var/x in LockOut)
						if(typeString == x)
							lockedoutSkills+=otherSkills
							otherSkills.Using=1
					for(var/x in PreRequisite)
						if(typeString == x)
							lockedoutSkills+=otherSkills
							otherSkills.Using=1
			if(src.SpellElement)
				if(src.SpellElement == "Time")
					if(m.hasMagePassive(/mage_passive/time/Past))
						if(!m.CheckSlotless("Outrunning the Past"))
							m.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Outrunning_the_Past);
					if(m.hasMagePassive(/mage_passive/time/Present))
						m.addTension(10, m.getMaxTensionValue())
				else if(src.SpellElement == "Space")
					if(m.hasMagePassive(/mage_passive/space/Linearity))
						if(!m.CheckSlotless("Distorted Space"))
							m.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Distorted_Space);
			Time=src.Cooldown*10*modify*(1+0.33*src.CooldownScalingCounter)
			if(src.CooldownScaling)
				src.CooldownScalingCounter++
			if(src.halve_next_cd)
				Time=max(1, round(Time/2))
				src.halve_next_cd=0
		else
			forcemessage=1
		if(isnull(Time) || Time == 0)
			Time = Cooldown
		if(m && m.HasTestMode())
			Time = 1
			if(lockedoutSkills.len)
				forcemessage = 1
		cooldown_remaining = Time
		if(m)
			if(m.PureRPMode)
				return
			cooldown_start = world.realtime
			var/start_time = world.realtime
			if(announce_cd && m.cooldownAnnounce && Time/10 > 0 && (AlwaysAnnounceCooldown || Time/10 > 5))
				m << "[src] has gone on Cooldown ([Time/10] Seconds)"
			spawn(Time)
				if(cooldown_start != start_time) return //This instance of the CD was canceled.
				src.Using=0
				cooldown_remaining = 0
				cooldown_start = 0
				if(Time>=50 || forcemessage)
					if(src in typesof(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff))
						return
					if(glob.SKILL_BRANCH_LOCK&&lockedoutSkills.len>0)
						for(var/obj/Skills/ski in lockedoutSkills)
							ski.Using=0
					if(src.CooldownNote)
						m << "<font color='white'><b>[src] is off cooldown. ([src.CooldownNote])</b></font color>"
					else
						m << "<font color='white'><b>[src] is off cooldown.</b></font color>"

obj/Skills/proc/Recharge(Time, mob/m)
	spawn(Time)
		Charges = min(Charges + 1, MaxCharges)
		if(Charges > 0)
			Using = 0
		if(m && m.cooldownAnnounce)
			m << "<font color='white'><b>[src] charge restored. ([Charges]/[MaxCharges])</b></font color>"
#define get_turf(A) (get_step(A, 0))

/mob/var/tmp/lastZanzoUsage = 0
/mob/var/tmp/lastHit = 0
mob/Players/verb
	Auto_Attack()
		set category = "Skills"
		client.setPref("autoAttacking", !client.getPref("autoAttacking"))
		lastHit = world.time
		src << "You are [client.getPref("autoAttacking") ? "now Auto Attacking." : "no longer Auto Attacking."]"
	Attack()
		set category="Skills"
		set name="Normal Attack"
		if(src.icon_state=="Meditate")
			src.SkillX("Meditate",src)
		// get step in front, get all stuff on that turf, only use melee if it has more than a turf
		src.Melee1()

mob/proc/SkillX(var/Wut,var/obj/Skills/Z,var/bypass=0)
	if(Z)
		if(!locate(Z) in src)
			return  FALSE
	if(src.KO||src.Stunned||src.AutoHitting||src.Frozen>=2||src.Suspended)
		return  FALSE
	if(src.judgement_cut_chain_active && !istype(Z, /obj/Skills/AutoHit/Judgement_Cut))
		return FALSE
	if(src.Stasis)
		return  FALSE
	if(Z.Using && Wut!="Zanzoken")
		return FALSE
	if(Z.MagicNeeded&&!src.HasLimitlessMagic())
		if(src.HasMechanized()&&src.HasLimitlessMagic()!=1)
			src << "You lack the ability to use magic!"
			return
		if(src.HasMagicTaken())
			src << "Your mana circuits are too damaged to use magic! (until [time2text(src.MagicTaken, "DDD MMM DD hh:mm:ss")])"
			return;
		if(Z.Copyable>=3||!Z.Copyable)
			if(!src.HasSpellFocus(Z))
				src << "You need a spell focus to use [Z]."
				return
	if(!src.Frozen||bypass)
		switch(Wut)

			if("Meditate")
				if(src.KO||src.icon_state=="KB"||src.icon_state=="Train"||src.icon_state=="Flight"||src.Beaming||src.BusterTech||(NextAttack > world.time))
					return
				if(src.icon_state!="Meditate")
					for(var/mob/Player/AI/a in view(25, src))
						if(a.Target==src && (a.WoundIntent || a.Lethal))
							src << "You're in too much danger to begin resting."
							return
			//		src.gatherNames() // should b on load/login
					reward_auto()
					src.CheckAscensions()
					if(isRace(DEMON)||isRace(MAKAIOSHIN))
						race?:checkReward(src)
					if(isRace(BEASTKIN) && race?:Racial == "Monkey King")
						var/obj/Skills/Buffs/s = findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastkin/Never_Fall/)
						if(!s.Using)
							s.Trigger(src, TRUE)
					removeBlobBuffs()
					if(!src.SignatureSelecting)
						src.SignatureSelecting=1
						src.PotentialSkillCheck()
						src.SignatureSelecting=0

					if(src.Saga||src.CyberneticMainframe)
						src.YeetSignatures()
						if(src.SagaAdminPermission)
							src.saga_up_self()


					if(src.CheckActive("Ki Control"))
						for(var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC in src)
							src.UseBuff(KC)
					if(src.CheckSlotless("What Must Be Done"))
						for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/wmbd in src.Buffs)
							if(wmbd.Password)
								src.UseBuff(wmbd)
								del wmbd

					src.OMessage(1,null,"[src]([src.key]) meditated!")
					src.dir=SOUTH
					src.AfterImageStrike=0
					src.Grounded=0
					if(src.InfusionElement)
						src.InfusionElement=null
					src.icon_state="Meditate"
					Z.Using=1
					spawn(20)
						Z.Using=0
					src.Meditation()
					src.MultReset()
				else
					if(Z.Using==1)
						return
					src.icon_state=""
					if(src.passive_handler.Get("AlphainForce") > 0)
						(src.passive_handler.Set("AlphainForce", 0))
					if(MeditateTime >= 15)
						src.Tension=0
						Momentum = 0
						for(var/obj/Skills/s in src)
							if(length(s.possible_skills) > 0)
								for(var/t in s.possible_skills)
									if(s.possible_skills["[t]"].Cooldown<0 && s.possible_skills["[t]"].Using)
										s.possible_skills["[t]"].Using = 0
										usr << "[t] has been reset, allowing you to use it again."
							if(s.Cooldown<0 && s.Using)
								s.Using = 0
								usr << "[s] has been reset, allowing you to use it again."
							if(s.CooldownScaling && s.CooldownScalingCounter)
								s.CooldownScalingCounter=0
								usr << "[s] has had its scaling cooldown reset."
					MeditateTime = 0

			if("Grab")
				src.Grab()
				if(ismob(src.Grab))
					Z.Cooldown()


			if("ReverseDash")
				var/Modifier=1
				if(hasEldritchPower()) summonEldritchMinion();
				if(src.Secret=="Haki")
					if(src.secretDatum.secretVariable["HakiSpecialization"]=="Observation")
						Modifier+=1
				if(src.Saga=="Eight Gates")
					Modifier+=2
				if(!src.HasDashMaster())
					Z.Cooldown(1/Modifier)
				if(src.CheckSlotless("New Moon Form"))
					if(src.CheckSlotless("Half Moon Form"))
						for(var/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Half_Moon_Form/H in src)
							H.Trigger(src)
				if(src.Secret=="Haki")
					if(src.CheckSlotless("Haki Armament"))
						for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armament/H in src)
							H.Trigger(src)
					if(!src.CheckSlotless("Haki Observation"))
						for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Observation/H in src)
							H.Trigger(src)
					src.AddHaki("Observation")
					if(!src.CheckSlotless("Haki Future Flash")&&!src.CheckSlotless("Haki Future Flash Lite"))
						if(src.secretDatum.secretVariable["HakiSpecialization"]=="Observation")
							for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Future_Flash/H in src)
								H.Trigger(src)
						else
							for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Future_Flash_Lite/H in src)
								H.Trigger(src)
				if(!src.Target||(src.Target&&!istype(src.Target,/mob)))
					return
				if(src.Target==src)
					return
				if(src.Beaming==2)
					return
				if(src.TimeFrozen)
					return
				if(src.Knockbacked)
					return
				if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Reverse Dash"))
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Heavenly_Reversal, src))
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Heavenly_Reversal)
					else
						for(var/obj/Skills/Buffs/SlotlessBuffs/Heavenly_Reversal/W in src)
							W.Trigger(src)
				var/Distance=5
				var/Delay=1
				src.Frozen=1
				if(src.Beaming||src.BusterTech)
					Distance=3
				if(src.GetSuperDash()>=2)
					AfterImageGhost(src)
					Delay=0
				else if(locate(/obj/Skills/Zanzoken, src)||src.HasSuperDash()&&src.GetSuperDash()<2)
					AfterImage(src)
					Delay=0
				if(is_arcane_beast)
					for(var/mob/Player/AI/Nympharum/n in ai_followers)
						n.PlayAction("NymphReverseDashSupport")
				if(src.RippleActive())
					src.OMessage(10,"[src] increases their distance from [src.Target] to regain the rhythm of their breathing!","<font color=red>[src]([src.key]) used  Back Dash.")
					src.Oxygen+=(src.OxygenMax)*0.25
					if(src.Oxygen>=(src.OxygenMax)*2)
						src.Oxygen=(src.OxygenMax)*2
				else if(src.StyleActive == "Crane Style")
					src.OMessage(10,"[src] backflips away from [src.Target]!","<font color=red>[src]([src.key]) used  Back Dash.")
				else if(src.Secret=="Spiral")
					src.OMessage(10,"[src] dashes towards [src.Target], as a true Spiral Warrior never runs from battle!!!!","<font color=red>[src]([src.key]) used  Back Dash.")
				else
					src.OMessage(10,"[src] dashes away from [src.Target]!","<font color=red>[src]([src.key]) used  Back Dash.")
				while(Distance>0)
					if(src.StyleActive == "Crane Style")
						src.icon_state="KB"
					else if(src.RippleActive())
						src.icon_state="Train"
					else
						src.icon_state="Flight"
					if(src.Secret=="Spiral")
						src.DashTo(src.Target, 20, 0.5, Clashable=1)
					else
						step_away(src,src.Target,68)
					for(var/atom/a in get_step(src,dir))
						if(a==src)
							continue
						if(a.density)
							Distance=0
					if(src.Secret=="Spiral")
						Distance=0
					Distance-=1
					sleep(Delay*world.tick_lag)
				src.dir=get_dir(src,src.Target)
				src.Frozen=0
				if(src.Launched)
					src.Launched=0
					LaunchEnd(src)
				src.NextAttack=0
				src.icon_state=""
				walk(src,0)
				if(src.Beaming==1)
					for(var/obj/Skills/Projectile/Beams/B in src)
						if(B.Charging)
							src.UseProjectile(B)
				if(src.HasDashCount())
					src.IncDashCount()

			if("DragonDash")
				if(!CanDash())
					return

				var/Modifier = (src.HasPursuer()/10)
				if(!src.HasDashMaster())
					Z.Cooldown(clamp(1-Modifier,0.1, 1))

				if(src.CheckSlotless("New Moon Form"))
					if(!src.CheckSlotless("Half Moon Form"))
						for(var/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Half_Moon_Form/H in src)
							H.Trigger(src)
				if(src.hasSecret("Eldritch (Reflected)"))
					src.HealMana(5)
				if(src.Secret=="Haki")
					src.AddHaki("Armament")
					if(!src.CheckSlotless("Haki Armament"))
						for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armament/H in src)
							H.Trigger(src)
					if(src.CheckSlotless("Haki Observation"))
						for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Observation/H in src)
							H.Trigger(src)
					if(!src.CheckSlotless("Haki Armor")&&!src.CheckSlotless("Haki Armor Lite"))
						if(src.secretDatum.secretVariable["HakiSpecialization"]=="Armament")
							for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armor/H in src)
								H.Trigger(src)
						else
							for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armor_Lite/H in src)
								H.Trigger(src)

				if(src.Secret == "Eldritch")
					if(src.isLunaticMode())
						src.Lunatic_Dash_Effect();
						src.InflictLunacy(3, src.Target);

				var/Distance=20
				var/Delay=0.5
				if(src.Beaming||src.BusterTech)
					if(!src.HasMovingCharge())
						Distance=5
					else
						Distance=10

				if(!src.AttackQueue)
					if(Secret)
						if(src.RippleActive())
							if(src.Oxygen>src.OxygenMax*1.25&&src.Oxygen>150&&src.PoseEnhancement&&src.HealthAnnounce25==1)
								src.HealthAnnounce25=2
								var/obj/Skills/Queue/Sunlight_Yellow_Overdrive/SYO=new/obj/Skills/Queue/Sunlight_Yellow_Overdrive
								SYO.adjust(src)
								src.SetQueue(SYO)
							else
								var/obj/Skills/Queue/Zoom_Punch/ZP=new/obj/Skills/Queue/Zoom_Punch
								ZP.adjust(src)
								src.SetQueue(ZP)
						if(src.Secret=="Vampire")
							if(!src.PoseEnhancement)
								var/obj/Skills/Queue/Vampire_Lunge/VL=new/obj/Skills/Queue/Vampire_Lunge
								VL.adjust(src)
								src.SetQueue(VL)
							else
								var/obj/Skills/Queue/Vampire_Rage/VR=new/obj/Skills/Queue/Vampire_Rage
								VR.adjust(src)
								src.SetQueue(VR)
						if(canSetEldritchRuinate()) setEldritchRuinate();

				if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Dragon Dash"))
					Delay = 0.75 / secretDatum?:getBoon(src, "Dragon Dash")
				if(src.HasSuperDash())
					Distance+=15*src.GetSuperDash()
					Delay=0.5/src.GetSuperDash()
					var/Wave=src.GetSuperDash()
					for(var/wav=Wave, wav>0, wav--)
						KenShockwave(src, icon='KenShockwave.dmi', Size=Wave)
						Wave/=2

				src.OMessage(10,"[src] dashed towards [src.Target]!","<font color=red>[src]([src.key]) used  Dragon Dash.")
				src.is_dashing++
				if(src.GetSuperDash()>=2)
					AfterImageGhost(src)
				if(is_arcane_beast)
					for(var/mob/Player/AI/Nympharum/n in ai_followers)
						n.PlayAction("NymphDragonDashSupport")
				src.DashTo(src.Target, Distance, Delay, Clashable=1)
				if(src.Beaming==1)
					for(var/obj/Skills/Projectile/Beams/B in src)
						if(B.Charging)
							src.UseProjectile(B)
				else
					src.NextAttack=0
					if(src.CheckSlotless("East Strength"))
						if(!src.AttackQueue)
							src.SetQueue(new/obj/Skills/Queue/East_Rush)
					src.Melee1(1, 5, accmulti=1.125+(src.GetSuperDash()/4), BreakAttackRate=1)

				if(src.HasDashCount())
					src.IncDashCount()

			if("Aerial Recovery")
				if(src.KO)
					return
				if(src.Beaming||src.BusterTech)
					return
				if(src.TimeFrozen)
					return
				if(!src.Knockback)
					return
				if(src.Energy>EnergyMax/8)
					src.OMessage(10,"[src] regained their footing!!","<font color=red>[src]([src.key]) used Aerial Recovery.")
					RecoverImage(src)
					src.AerialRecovery=1
					src.StopKB()
					if(src.RippleActive()&&src.Oxygen>=30)
						if(!src.AttackQueue)
							src.SetQueue(new/obj/Skills/Queue/Rebuff_Overdrive)
						Z.Cooldown(1.5)
					else if(src.Secret=="Werewolf")
						Z.Cooldown(0.5)
					else if(hasEldritchPower())
						var/obj/Skills/AutoHit/a = findOrAddSkill(/obj/Skills/AutoHit/Attractive_Force);
						src.Activate(a);
						Z.Cooldown()
					else
						if(!src.HasDashMaster())
							Z.Cooldown()
			if("Aerial Payback")
				if(src.KO)
					return
				if(!src.Target)
					return
				if(src.Beaming||src.BusterTech)
					return
				if(src.TimeFrozen)
					return
				if(!src.Knockback)
					return
				if(src.is_dashing)
					return
				var/Distance=10
				var/Delay=0.75
				if(src.HasSuperDash())
					Distance+=20*src.GetSuperDash()
					Delay=0.5/src.GetSuperDash()
					var/Wave=2
					for(var/wav=Wave, wav>0, wav--)
						KenShockwave(src, icon='KenShockwave.dmi', Size=Wave)
						Wave/=2
				src.OMessage(10,"[src] regained their footing and dashed towards [src.Target]!","<font color=red>[src]([src.key]) used Aerial Payback.")
				RecoverImage(src)
				src.is_dashing++
				src.AerialRecovery=2
				src.StopKB()
				src.DashTo(src.Target, Distance, Delay)
				src.AerialRecovery=0
				if(src.RippleActive()&&src.Oxygen>=30)
					if(!src.AttackQueue)
						src.SetQueue(new/obj/Skills/Queue/Rebuff_Overdrive)
					Z.Cooldown(1.5)
				else if(src.Secret=="Werewolf")
					src.Activate(new/obj/Skills/AutoHit/Rabid_Retaliation)
					Z.Cooldown(2)
				else if(hasEldritchPower())
					var/obj/Skills/AutoHit/a = findOrAddSkill(/obj/Skills/AutoHit/Attractive_Force);
					src.Activate(a);
					Z.Cooldown()
				else
					if(!src.HasDashMaster())
						Z.Cooldown()
					if(src.Target in oview(src, 1))
						src.dir=get_dir(src, src.Target)
						src.Melee1(1, 5, accmulti=1.125+(src.GetSuperDash()/4))


			if("Release Absorb")
				src.releaseAbsorbedPrompt()
				return

			if("Absorb")
				// if(Z.Using)
				// 	return
				if(!Target)
					src<< "You must have a target to absorb!"
					return
				var/mob/Players/P = src.Target
				if(get_dist(P,src)>2)
					src << "You can't absorb them from so far away!"
					return
				if(src.majinAbsorb)
					absorbSomebody(P)
				if(istype(SpecialBuff, /obj/Skills/Buffs/SpecialBuffs/Sin/Gluttony))
					// they r gluttony
					if(SpecialBuff:anAcquiredTaste + 1 > 20)
						src << "You can't absorb any more people!"
						return
					else
						SpecialBuff:anAcquiredTaste++
						SpecialBuff:eatenPeople += "[P.name] | [P.ckey]"
						src << "You forcibly remove the power from [P] and corrupt it with your Gluttony Sin."
				return

			if("Time Skip")
				Z.Cooldown()
				src.appearance_flags+=NO_CLIENT_COLOR
				animate(src.client, color = list(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1), time = 3)
				for(var/mob/Players/M in oview(20,src))
					M.client.fps=0.0001
				spawn(30)
					for(var/mob/Players/B in players)
						if(B.client.fps!=world.fps)
							B.client.fps=world.fps
						animate(B.client, color = null, time = 3)
						src.appearance_flags-=NO_CLIENT_COLOR
			if("Time Stop")
				if(src.TimeStop)
					src.TimeStop=0
					Z:TimeStopped=0
					for(var/mob/E in hearers(12,src))
						E<<"<font color=[src.Text_Color]>[src] says: Let the flow of time return to normal."
					for(var/mob/B in world)
						if(B.TimeFrozen)
							B.TimeFrozen=0
							B.Frozen=0
						if(B.client)
							spawn()animate(B.client, color = null, time = 3)
					Z.Cooldown()
				else
					if(src.Health<20/Z.Mastery)
						src << "You haven't the vitality to stop time..."
						return
					for(var/mob/E in hearers(12,src))
						E<<"<font color=[src.Text_Color]>[src] says: Time..."
					sleep(15)
					for(var/mob/M in view(20,src))
						if(M.client)
							spawn()animate(M.client, color = list(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1), time = 7)
					for(var/mob/E in hearers(12,src))
						E<<"<font color=[src.Text_Color]>[src] yells: <b>...STOP!</b>"
					for(var/mob/M in view(20,src))
						if(M!=src&&M.WorldImmune==0&&!M.passive_handler.Get("StaticWalk"))
							M.Frozen=1
							M.TimeFrozen=1
					sleep(10)
					for(var/mob/M in view(20,src))
						if(M.client)
							spawn()animate(M.client, color = null, time = 3)
							spawn()animate(M.client, color = list(0.6,0,0.1, 0,0.6,0.1, 0,0,0.7, 0,0,0), time = 3)
					for(var/mob/E in hearers(12,src))
						E<<"<font color=[src.Text_Color]>[src] says: Time is now frozen."
					src.TimeStop=1
					Z:TimeStopped=0

			if("Chaos Control")
				if(Z.Using)
					return
				if(src.Health<20/max(Z.Mastery,1))
					src << "You haven't the vitality to invoke chaos control..."
					return
				Z.Using = 1
				for(var/mob/E in hearers(12,src))
					E<<"<font color=[src.Text_Color]>[src] says: Chaos..."
				sleep(15)
				for(var/mob/M in view(20,src))
					if(M.client)
						spawn()animate(M.client, color = list(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1), time = 7)
				for(var/mob/E in hearers(12,src))
					E<<"<font color=[src.Text_Color]>[src] yells: <b>...Control!</b>"
				if(!Z:frozen_mobs)
					Z:frozen_mobs = list()
				else
					Z:frozen_mobs.Cut()
				for(var/mob/M in view(20,src))
					if(M != src)
						M.Frozen = 1
						M.TimeFrozen = 1
						Z:frozen_mobs += M
				sleep(10)
				for(var/mob/M in view(20,src))
					if(M.client)
						spawn()animate(M.client, color = null, time = 3)
						spawn()animate(M.client, color = list(0.6,0,0.1, 0,0.6,0.1, 0,0,0.7, 0,0,0), time = 3)
				for(var/mob/E in hearers(12,src))
					E<<"<font color=[src.Text_Color]>[src] says: Time is now frozen."
				var/duration = 50 + max(Z.Mastery,1) * 20
				var/mob/caster = src
				spawn(duration)
					if(Z && Z:frozen_mobs)
						for(var/mob/B in Z:frozen_mobs)
							if(B)
								B.TimeFrozen = 0
								B.Frozen = 0
							if(B.client)
								spawn()animate(B.client, color = null, time = 3)
						if(caster)
							if(caster.client)
								spawn()animate(caster.client, color = null, time = 3)
							for(var/mob/E in hearers(12,caster))
								E<<"<font color=[caster.Text_Color]>[caster] says: Let the flow of time return to normal."
						Z:frozen_mobs.Cut()
						Z.Cooldown()
					if(Z)
						Z.Using = 0

			if("Heal")
				if(src.Energy<50)
					return
				if(src.KO)
					return
				for(var/mob/Players/P in get_step(src,src.dir))
					if(P)
						Z.Cooldown()
						view(src)<<"[src] heals [P]"
						if(src.Imagination<=1)
							src.LoseEnergy(50)
						src.LoseHealth(25)
						if(P.KO)
							P.Conscious()
						P.Sheared=0
						P.HealWounds(25*src.Imagination)
						P.HealHealth(25*src.Imagination)
						P.TotalFatigue=0
						P.Energy=P.EnergyMax
						if(P.BPPoison<1)
							if(src.Imagination>1)
								P.BPPoison=1
							P.BPPoisonTimer=1
						if(P.MortallyWounded)
							P.MortallyWounded=0
							P.TsukiyomiTime=1
							view(src)<<"[src] stabilizes [P]."
						if(P.SenseRobbed)
							if(P.SenseRobbed>=5)
								animate(P.client, color=null, time=1)
							P.SenseRobbed=0
							view(src)<<"[src] restores [P]'s robbed senses!"
						break
			if("Refresh")
				if(src.Energy<80)
					return
				if(src.KO)
					return
				for(var/mob/Players/P in oview(7,usr))
					if(P)
						Z.Cooldown()
						view(src)<<"[src] heals [P]"
						src.LoseEnergy(100)
						src.GainFatigue(100)
						if(P.KO)
							P.Conscious()
						P.Sheared=0
						P.HealWounds(25*src.Imagination)
						P.HealHealth(25*src.Imagination)
						P.TotalFatigue=0
						P.Energy=P.EnergyMax
						if(P.BPPoison<1)
							P.BPPoisonTimer=1
						if(P.MortallyWounded)
							P.MortallyWounded=0
							P.TsukiyomiTime=1
							view(src)<<"[src] stabilizes [P]."
						if(P.SenseRobbed)
							if(P.SenseRobbed>=5)
								animate(P.client, color=null, time=1)
							P.SenseRobbed=0
							view(src)<<"[src] restores [P]'s robbed senses!"
						break
			if("UltimateHeal")
				if(src.ManaAmount<100)
					return
				if(src.KO)
					return
				for(var/mob/Players/P in oview(7,usr))
					if(P)
						Z.Cooldown()
						src.ManaAmount=0
						view(src)<<"[src] does their best trying to heal [P]! Please be nice to them."
						if(P.KO)
							P.Conscious()
						P.Sheared=0
						P.HealWounds(0.5*src.Imagination)
						P.HealHealth(0.5*src.Imagination)
						P.TotalFatigue=0
						if(P.BPPoison<1)
							P.BPPoisonTimer=1
						break
			if("BetterHeal")
				if(src.ManaAmount<75)
					return
				if(src.KO)
					return
				for(var/mob/Players/P in oview(7,usr))
					if(P)
						Z.Cooldown()
						src.ManaAmount=0
						view(src)<<"[src] does a much better job healing [P]."
						if(P.KO)
							P.Conscious()
						P.Sheared=0
						P.HealWounds(2*src.Imagination)
						P.HealHealth(2*src.Imagination)
						P.TotalFatigue=0
						if(P.BPPoison<1)
							P.BPPoisonTimer=1
						if(P.MortallyWounded)
							P.MortallyWounded=0
							P.TsukiyomiTime=1
							view(src)<<"[src] stabilizes [P]."
						if(P.SenseRobbed)
							if(P.SenseRobbed>=5)
								animate(P.client, color=null, time=1)
							P.SenseRobbed=0
							view(src)<<"[src] restores [P]'s robbed senses!"
						break
			if("Regrowth")
				if(Z.Using)
					return
				if(!src.HasManaCapacity(50))
					src << "You do not have enough magic capacity to perform regrowth!"
					Using=0
					return
				src << "You begin channeling arcane life force. . ."
				sleep(100)
				src.TakeManaCapacity(50)
				Z.Cooldown()
				if(src.MortallyWounded)
					src.MortallyWounded=0
					src.TsukiyomiTime=1
					view(src) <<"[src] stabilizes themselves through regrowth!"
				if(BPPoison>1)
					BPPoison=1
					BPPoisonTimer=0
					view(src) <<"[src] recovers from their wounds through regrowth!"
				if(Maimed)
					Maimed=max(Maimed-1, 0)
					view(src) <<"[src] recovers a lost limb through regrowth!"
				if(SenseRobbed)
					if(SenseRobbed>=5)
						animate(client, color=null, time=1)
					SenseRobbed=0
					view(src) <<"[src] restores their robbed senses through regrowth!"
				if(StrCut)
					AddStrTax(StrCut)
					StrCut=0
				if(EndCut)
					AddEndTax(EndCut)
					EndCut=0
				if(SpdCut)
					AddSpdTax(SpdCut)
					SpdCut=0
				if(ForCut)
					AddForTax(ForCut)
					ForCut=0
				if(OffCut)
					AddOffTax(OffCut)
					OffCut=0
				if(DefCut)
					AddDefTax(DefCut)
					DefCut=0
				if(src.KO)
					src.Conscious()
				src.HealWounds(50)

			if("Fly")
				if(src.KO||src.icon_state=="Meditate"||src.icon_state=="Train"||src.icon_state=="KB") return
				if(src.Flying)
					if(Z.Using==1)//See: Meditate
						return
					Flight(src, Land=1)
				else if(src.Energy>(src.EnergyMax/10))
					src.Flying=1
					usr.OMessage(1,null,"[usr]([usr.key]) flew!")
					Flight(src, Start=1)
					if(isplayer(usr))
						usr:move_speed = usr.MovementSpeed()
					Z.Using=1
					spawn(20)
						Z.Using=0
				else
					src<<"You do not have enough energy to fly."

			if("Clairvoyance")
				if(Z.BuffUsing)
					Z.BuffUsing=0
					src.sight &= ~(SEE_SELF|SEE_TURFS|SEE_MOBS|SEE_OBJS)
					src.OMessage(10,"[src]'s eyes revert to normal.","<font color=red>[src]([src.key]) deactivated Clairvoyance.")
				else
					Z.BuffUsing=1
					src.sight |= (SEE_SELF|SEE_TURFS|SEE_MOBS|SEE_OBJS)
					src.OMessage(10,"[src]'s pupils begin to pulsate with a strange, golden energy.","<font color=red>[src]([src.key]) activated Clairvoyance.")
			if("LimitOverForce")
				if(Z.Using)
					return
				var/Select=input("Do you really want to end the wipe...?") in list ("Yes", "No")
				switch(Select)
					if("Yes")
						src.OMessage(10,"<font color=red><b>[src] raises their hand up...</font color></b>","<font color=red>[src]([src.key]) activated complete obliteration.")
						for(var/mob/Players/M)
							M.CutsceneMode=1
						sleep(10)
					/*	world << "<font size=+4><font color=#FF00FF><b>Rank-Up-Magic...</b></font size>"
						sleep(10)
						world << "<font size=+4><b><font color=#FF00FF>LIMIT OVER FORCE!</b></font size>"
						sleep(40)
						world << "<font size=+2><b><font color=#FFFF00>The entire universe shifts.</b></font size>"
						sleep(20)
						world << "<font size=+2><b><font color=#FFFF00>The world itself, changes.</b></font size>"
						sleep(20)
						world << "<font size=+2><b><font color=#FFFF00>And as the story is shifted to a higher realm...</b></font size>"
						sleep(20)
						world << "<font size=+2><b><font color=#FFFF00>...the strings tying you to your vessel are torn.</b></font size>"
						sleep(20)
						world << "<font size=+2><b><font color=#FFFF00>And your vessel, which you took so much time to craft, and colored in with care...</b></font size>"
						sleep(20)
						world << "<center><font size=+2><b><font color=#FF0000>...has been discarded.</b></font size></center>"
						sleep(30)
						world<<"<font size=+4><b><font color=#FF0000>(CONNECTION: TERMINATED)</b></font size>"*/
						glob.progress.FourthFateEndwipe=1
						for(var/mob/Players/M in world)
							if(M!=src)
								M.passive_handler.Increase("Utterly Powerless")
								M.passive_handler.Increase("Completely Obliterated")
								M.passive_handler.Increase("Disconnected")
								M.ObliteratedX=M.x
								M.ObliteratedY=M.y
								M.ObliteratedZ=M.z
								M.loc=locate(0,0,0)
								M.client.SaveChar()
								del M
					//		M.Health-=src.ForVsRes(M, 30)
				//		Z.Cooldown()
					if("No")
						return
			if("GiveFourthFate")
				if(Z.Using)
					return
				var/Select=input("Do you really want to end the wipe...?") in list ("Yes", "No")
				switch(Select)
					if("Yes")
						for(var/mob/Players/M)
							if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/The_Fourth_Fate, M))
								M.AddSkill(new/obj/Skills/Buffs/NuStyle/UnarmedStyle/The_Fourth_Fate)
								M<<"<b><font color=#0099FF>You have unlocked The Fourth Fate!"
					if("No")
						return
			if("EndWipe")
				if(Z.Using)
					return
				var/Select=input("Do you really want to end the wipe...?") in list ("Yes", "No")
				switch(Select)
					if("Yes")
						for(var/mob/Players/M)
							if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/The_Fourth_Fate, M))
								M.AddSkill(new/obj/Skills/Buffs/NuStyle/UnarmedStyle/The_Fourth_Fate)
								M<<"<b><font color=#0099FF>You have unlocked The Fourth Fate!"
					if("No")
						return
			if("Telepath")
				var/list/who=list("Cancel")
				for(var/mob/Players/A in players)
					who.Add(A)
				for(var/mob/Players/W in who)
					if(!(locate(W.EnergySignature) in usr.EnergySignaturesKnown)&&!usr.passive_handler.Get("SpiritPower"))
						if(!(W in hearers(50,usr)))
							who.Remove(W)
					if(!W.EnergySignature&&!usr.passive_handler.Get("SpiritPower"))
						who.Remove(W)
				var/mob/Players/selector=input("Select a player to telepath.") in who||null
				if(selector=="Cancel")
					return
				var/message=input(src,"What do you want to telepath?") as text|null
				if(message==null)
					return
				message=copytext(message,1,500)
				if(selector)
					selector <<"<font face=Old English Text MT><font color=red>[src] says in telepathy, '[html_encode(message)]'"
					for(var/mob/Players/m in hearers(50, src))
						if(m==selector)
							continue
						if(m==src)
							continue
						if(m.HasTelepathy())
							if(m.HearThoughts)
								m<<"<font face=Old English Text MT><font color=red>[src] says to [selector] in telepathy, '[html_encode(message)]'"
					for(var/mob/Players/m in hearers(50, selector))
						if(m==selector)
							continue
						if(m==src)
							continue
						if(m.HasTelepathy())
							if(m.HearThoughts)
								m<<"<font face=Old English Text MT><font color=red>[src] says to [selector] in telepathy, '[html_encode(message)]'"
					selector.OMessage(0,null,"<font color=purple>[selector]([selector.key]) received the telepath '[html_encode(message)]' from [src]([src.key])")
				if(src)
					src<<"<font face=Old English Text MT><font color=red>You telepathed [selector], '[html_encode(message)]'"
					src.OMessage(0,null,"<font color=purple>[src]([src.key]) telepathed '[html_encode(message)]' to [selector]([selector.key])")
			if("FalseMoon")
				if(Z.Using)
					return
				if(src.KO)
					return
				Z.Cooldown()
				src.OMessage(10,"[src] conjures up a ball of energy into their palm and chucks it into the sky!.","[src]([src.key]) made a false moon!")
				new/obj/ProjectionMoon(src.loc)

			if("TrueSun")
				if(Z.Using)
					return
				if(src.KO)
					return
				Z.Cooldown()
				src.OMessage(10,"[src] manifests an orb of light into their palm and releases it into the sky!.","[src]([src.key]) released the true sun!")
				new/obj/ProjectionSun(src.loc)

			if("Zanzoken")
				if(!src.Move_Requirements())
					return
				if(src.PoweringUp)
					return
				if(src.Beaming||src.BusterTech)
					return
				if(Target && !Target.loc)
					return

				//UNTARGETED ZANZO
				if(!src.Target)
					src.ActiveZanzo=3
					src.MovementCharges--

				//TARGETED ZANZO
				else
					if(20 >= get_dist(src.Target,src))
						if(lastZanzoUsage+2>world.time)
							return
						if(MovementCharges<1)
							return
						if(last_combo >= world.time)
							return
						lastZanzoUsage = world.time
						src.StopKB()
						if(src.Target.Beaming==2)
							if(!(src.Target in view(10, src)))
								return
							src.Move(get_step(src.Target,src.Target.dir))
							src.dir=src.Target.dir
						else
							if(src.UsingGhostDrive())
								AfterImageGhost(src)
								src.Comboz(src.Target)
								src.dir=get_dir(src,src.Target)
								src.Melee1(1, 5, accmulti=1.2, SureKB=1, BreakAttackRate=1)
							else
								var/denko = getDenkoSekka()
								if(denko)
									src.MovementCharges--
									if(MovementCharges<0)
										MovementCharges=0
									lastZanzoUsage = world.time + 8
									var/denkoSavedColor = src.color
									var/denkoSavedPixelZ = src.pixel_z
									src.DenkoSekkaZanzoFade(denkoSavedPixelZ)
									sleep(5)
									src.Comboz(src.Target, FALSE, FALSE, passive_handler["Backstabber"])
									src.dir=get_dir(src,src.Target)
									src.DenkoSekkaZanzoLand(denkoSavedColor, denkoSavedPixelZ)
									src.DenkoSekkaCharged = denko
									src.Melee1(1, 5, accmulti=1.1, SureKB=1, BreakAttackRate=1)
									return
								else
									if(HasGiantForm())
										var/Wave=2
										for(var/wav=Wave, wav>0, wav--)
											KenShockwave(src, icon='fevKiai.dmi', Size=Wave)
											Wave/=2
									else
										VanishImage(src)
									src.Comboz(src.Target, FALSE, FALSE, passive_handler["Backstabber"])
									src.dir=get_dir(src,src.Target)
									src.Melee1(1, 5, accmulti=1.1, SureKB=1, BreakAttackRate=1)
						src.MovementCharges--
						if(MovementCharges<0)
							MovementCharges=0

			if("Walking")
				if(src.KO||src.Stunned||src.AutoHitting||src.Frozen>=2||src.PoweringUp)
					return
				if(src.Stasis)
					return
				if(Z.Using)
					return
				Z.Cooldown()
				src.ActiveZanzo=0
				sleep()
				src.ActiveZanzo=4

			if("Blink")
				if(src.KO||src.Stunned||src.AutoHitting||src.Frozen>=2||src.PoweringUp)
					return
				if(src.Stasis)
					return
				if(!Z.BuffUsing)
					Z.BuffUsing=1
					src << "You begin to rapidly skip through space!"
					return
				else
					Z.BuffUsing=0
					src << "You stabilize your position in space."
					return

			if("KeepBody")
				for(var/mob/Players/P in get_step(src,dir))
					if(P.KeepBody)
						if(!P.KO)
							return
						P.KeepBody=0
						src.OMessage(10,"[src] takes [P]'s body","[src]([src.key]) took [P]([P.key]) 's body")

					else
						P.KeepBody=1
						src.OMessage(10,"[src] gives [P]'s their body.","[src]([src.key]) gave [P]([P.key]) their body.")
					break

			if("GivePower")
				if(Z.Using)
					return
				if(!src.KO)
					for(var/mob/P in get_step(src,dir))
						P.HealHealth(src.Health/2*src.Imagination)
						P.HealEnergy(src.Energy/2*src.Imagination)
						P.BPPoison+=((src.Power/src.GetPowerUpRatio())/(P.Power/P.GetPowerUpRatio()))
						P.BPPoisonTimer=RawMinutes(5*src.Imagination)
						if(P.SenseRobbed)
							if(P.SenseRobbed>=5)
								animate(P.client, color=null, time=1)
							P.SenseRobbed=0
						src.Unconscious(null,"giving power to [P]!")
						src.OMessage(10,null,"[src]([src.key]) gave power to [P]([P.key])")
						return
					Z.Cooldown()


atom/proc/Quake(var/duration=30, var/globe=0)
	set waitfor=0
	if(duration == null || duration == 0)
		return
	while(duration)
		duration-=world.tick_lag
		if(!globe)
			for(var/mob/M in view(src))
				if(M.client)
					M.client.pixel_x=rand(-8,8)
					M.client.pixel_y=rand(-8,8)
				if(!duration)
					if(M.client)
						M.client.pixel_x=0
						M.client.pixel_y=0
		else
			for(var/mob/M in players)
				if(M.z!=globe&&globe!=999)
					continue
				if(M.client)
					M.client.pixel_x=rand(-8,8)
					M.client.pixel_y=rand(-8,8)
				if(!duration)
					if(M.client)
						M.client.pixel_x=0
						M.client.pixel_y=0
		if(duration<0)
			duration=0
		sleep(world.tick_lag)

atom/proc/Earthquake(var/duration=30,var/xpixelmin=0,var/xpixelmax=5,var/ypixelmin=0,var/ypixelmax=5, var/globe=0)
	while(duration)
		duration-=1
		if(!globe)
			for(var/mob/M in view(src))
				if(M.client)
					M.client.pixel_x=rand(xpixelmin,xpixelmax)
					M.client.pixel_y=rand(ypixelmin,ypixelmax)
				if(!duration) if(M.client)
					M.client.pixel_x=0
					M.client.pixel_y=0
		else
			for(var/mob/M in players)
				if(M.z!=globe&&globe!=999)
					continue
				if(M.client)
					M.client.pixel_x=rand(xpixelmin,xpixelmax)
					M.client.pixel_y=rand(ypixelmin,ypixelmax)
				if(!duration)
					if(M.client)
						M.client.pixel_x=0
						M.client.pixel_y=0
		if(duration<0)
			duration=0
		sleep(1)
