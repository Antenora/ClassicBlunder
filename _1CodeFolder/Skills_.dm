

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
obj/Skills/proc/Cooldown(var/modify=1, var/Time, mob/p)
	var/mob/m=src.loc
	if(p)
		m = p
	if(!src.Using || Time)
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
			Time=src.Cooldown*10*modify*(1+0.33*src.CooldownScalingCounter)
			if(src.CooldownScaling)
				src.CooldownScalingCounter++
		else
			forcemessage=1
		if(isnull(Time) || Time == 0)
			Time = Cooldown
		cooldown_remaining = Time
		if(m)
			if(m.PureRPMode)
				return
			cooldown_start = world.realtime
			var/start_time = world.realtime
			if(m.cooldownAnnounce && Time/10 > 5)
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
	if(src.KO||src.Stunned||src.AutoHitting||src.Frozen>=2)
		return  FALSE
	if(src.Stasis)
		return  FALSE
	if(Z.Using && Wut!="Zanzoken")
		return FALSE
	if(Z.MagicNeeded&&!src.HasLimitlessMagic())
		if(src.HasMechanized()&&src.HasLimitlessMagic()!=1)
			src << "You lack the ability to use magic!"
			return
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
					src.gatherNames() // should b on load/login
					reward_auto()
					src.CheckAscensions()
					if(isRace(DEMON))
						race?:checkReward(src)
					if(isRace(BEASTMAN) && race?:Racial == "Monkey King")
						var/obj/Skills/Buffs/s = findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastman/Never_Fall/)
						if(!s.Using)
							s.Trigger(src, TRUE)
					if(isRace(HALFSAIYAN))
						switch(Class) // leave this in until they all get it
							if("Compassion")
								findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/HalfSaiyan/Hidden_Potential)
								src << "You have gained Hidden Potential"
							if("Anger")
								findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/HalfSaiyan/Saiyan_Pride)
								src << "You have gained Saiyan Pride"
					removeBlobBuffs()
					if(!src.SignatureSelecting)
						src.SignatureSelecting=1
						src.PotentialSkillCheck()
						src.SignatureSelecting=0

					if(src.Saga)
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
				else
					if(Z.Using==1)
						return
					src.icon_state=""
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
					GetAndUseSkill(/obj/Skills/Buffs/SlotlessBuffs/Heavenly_Reversal, Buffs, TRUE)
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
				if(src.HasRipple())
					src.OMessage(10,"[src] increases their distance from [src.Target] to regain the rhythm of their breathing!","<font color=red>[src]([src.key]) used  Back Dash.")
					src.Oxygen+=(src.OxygenMax)*0.25
					if(src.Oxygen>=(src.OxygenMax)*2)
						src.Oxygen=(src.OxygenMax)*2
				else if(src.StanceActive=="Crane")
					src.OMessage(10,"[src] backflips away from [src.Target]!","<font color=red>[src]([src.key]) used  Back Dash.")
				else
					src.OMessage(10,"[src] dashes away from [src.Target]!","<font color=red>[src]([src.key]) used  Back Dash.")
				while(Distance>0)
					if(src.StanceActive=="Crane")
						src.icon_state="KB"
					else if(src.HasRipple())
						src.icon_state="Pose"
					else
						src.icon_state="Flight"
					step_away(src,src.Target,68)
					for(var/atom/a in get_step(src,dir))
						if(a==src)
							continue
						if(a.density)
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

				var/Distance=20
				var/Delay=0.5
				if(src.Beaming||src.BusterTech)
					if(!src.HasMovingCharge())
						Distance=5
					else
						Distance=10

				if(!src.AttackQueue)
					if(Secret)
						if(src.HasRipple())
							if(src.Oxygen>src.OxygenMax*1.25&&src.Oxygen>150&&src.PoseEnhancement&&src.HealthAnnounce25==1)
								src.HealthAnnounce25=2
								src.SetQueue(new/obj/Skills/Queue/Sunlight_Yellow_Overdrive)
							else
								src.SetQueue(new/obj/Skills/Queue/Zoom_Punch)
						if(src.Secret=="Vampire")
							if(!src.PoseEnhancement)
								var/obj/Skills/Queue/Vampire_Lunge/VL=new/obj/Skills/Queue/Vampire_Lunge
								VL.adjust(src)
								src.SetQueue(VL)
							else
								var/obj/Skills/Queue/Vampire_Rage/VR=new/obj/Skills/Queue/Vampire_Rage
								VR.adjust(src)
								src.SetQueue(VR)
						if(src.Secret=="Eldritch" && CheckSlotless("True Form"))
							var/obj/Skills/Queue/Eldritch_Ruinate/ER=new/obj/Skills/Queue/Eldritch_Ruinate
							ER.adjust(src)
							src.SetQueue(ER)

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
					if(src.HasRipple()&&src.Oxygen>=30)
						if(!src.AttackQueue)
							src.SetQueue(new/obj/Skills/Queue/Rebuff_Overdrive)
						Z.Cooldown(1.5)
					else if(src.Secret=="Werewolf")
						Z.Cooldown(0.5)
					else if(src.Secret=="Eldritch" && CheckSlotless("True Form"))
						src.Activate(new/obj/Skills/AutoHit/Attractive_Force)
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
				if(src.HasRipple()&&src.Oxygen>=30)
					if(!src.AttackQueue)
						src.SetQueue(new/obj/Skills/Queue/Rebuff_Overdrive)
					Z.Cooldown(1.5)
				else if(src.Secret=="Werewolf")
					src.Activate(new/obj/Skills/AutoHit/Rabid_Retaliation)
					Z.Cooldown(2)
				else if(src.Secret=="Eldritch" && CheckSlotless("True Form"))
					src.Activate(new/obj/Skills/AutoHit/Attractive_Force)
					Z.Cooldown()
				else
					if(!src.HasDashMaster())
						Z.Cooldown()
					if(src.Target in oview(src, 1))
						src.dir=get_dir(src, src.Target)
						src.Melee1(1, 5, accmulti=1.125+(src.GetSuperDash()/4))


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

			if("PowerUp")
				if(src.KO)return
				if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Power Control")) return
				if(src.PoweringDown)return
				if(CheckSlotless("Great Ape"))
					CanTransform()
					return
				if(passive_handler.Get("Piloting"))return
				if(src.Kaioken)
					var/Mastery
					for(var/obj/Skills/Buffs/SpecialBuffs/Kaioken/KK in src)
						Mastery=KK.Mastery
					if(src.Kaioken<2+Mastery)
						switch(src.Kaioken)
							if(1)
								src.Kaioken=2
								src <<"<b>Kaioken Times Three!</b>"
							if(2)
								src.Kaioken=3
								src <<"<b>Kaioken Times Four!</b>"
							if(3)
								src.Kaioken=4
								src <<"<b>Kaioken Times Ten!</b>"
							if(4)
								src.Kaioken=5
								src <<"<b>Kaioken Times Twenty!</b>"
							if(5)
								src << "You're at your maximum level of Kaioken."
					else
						src << "You don't have enough mastery of Kaioken to push it further."
					return
				if(src.CheckActive("Ki Control")||(src.CheckSpecial("One Hundred Percent Power")&&src.transUnlocked<4)||(src.CheckSpecial("Fifth Form")&&src.transUnlocked<4))
					return
				if(src.HasPULock())
					return
				if(src.PoweringUp==1)
					if(src.transActive()<src.transUnlocked)
						src.PoweringUp=0
						src.Transform()
						return
				if(!src.PoweringUp)
					src.PoweringUp=1
					if(src.PowerControl>=100)
						if(src.Saga=="Cosmo")
							OMsg(src, "[src] ignites their Cosmo!!")
						else if(src.custom_powerup)
							if(customPUnameInclude)
								OMsg(src, "[src] [src.custom_powerup]")
							else
								OMsg(src, "[src.custom_powerup]")
						else
							OMsg(src, "[src] begins gathering power!!")
						src.Auraz("Add")
					else
						src.PowerControl=100
						src << "You return to normal power."
						src.PoweringUp=0
			if("PowerDown")
				if(src.KO)
					return
				if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Power Control")) return
				if(CheckSlotless("Great Ape"))
					return
				if(passive_handler.Get("Piloting"))
					return
				if(src.Kaioken)
					src << "You douse your Kaioken..."
					src.SpecialBuff.Trigger(src)
					sleep()
					if(src.CheckActive("Ki Control"))
						for(var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC in src)
							src.UseBuff(KC)
					return
				if(src.HasPULock())
					return
				if(src.PoweringUp)
					src.PoweringUp=0
					src << "You stop powering up."
					src.Auraz("Remove")
					return
				else
					if(src.CheckActive("Ki Control"))
						for(var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC in src)
							src.UseBuff(KC)
							return
					if(src.CheckSpecial("One Hundred Percent Power"))
						for(var/obj/Skills/Buffs/SpecialBuffs/OneHundredPercentPower/FF in src)
							src.UseBuff(FF)
							return
					if(src.CheckSpecial("Fifth Form"))
						for(var/obj/Skills/Buffs/SpecialBuffs/FifthForm/FF in src)
							src.UseBuff(FF)
							return
					if(src.HasKiControl() && src.PowerControl > 100)
						src.PowerControl=100
						src.Auraz("Remove")
						src << "You return to normal power."
						return
					if(transActive&&!src.HasNoRevert())
						for(var/obj/Skills/Buffs/B in src)
							if(src.BuffOn(B)&&B.Transform&&!B.AlwaysOn)
								B.Trigger(src)
								return
						src.Revert()
						src << "You revert from your transformed state."
						return
					else
						if(src.PowerControl!=1)
							src.PowerControl=1
							src << "You restrain your power..."
							src.Auraz("Remove")
							return

			if("FalseMoon")
				if(Z.Using)
					return
				if(src.KO)
					return
				Z.Cooldown()
				src.OMessage(10,"[src] conjures up a ball of energy into their palm and chucks it into the sky!.","[src]([src.key]) made a false moon!")
				new/obj/ProjectionMoon(src.loc)

			if("CallStar")
				if(Z.Using)
					return
				if(src.KO)
					return
				Z.Cooldown()
				src.OMessage(10,"[src] invokes the appearance of the crimson Star!","[src]([src.key]) called upon the cursed star!")
				CallStar(src.z)

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