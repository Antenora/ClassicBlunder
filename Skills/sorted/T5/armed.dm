/obj/Skills/AutoHit
	Jest_of_the_Dead
		SkillCost=TIER_5_COST
		Copyable=6
		NeedsSword=1
		Area="Arc"
		StrOffense=1
		DamageMult=2.5
		ControlledRush=1
		Rush=10
		LifeSteal=50
		WindUp=1
		WindupIcon='StormArmor.dmi'
		Rounds=10
		ChargeTech=1
		ChargeTime=1
		Knockback=1
		Cooldown=150
		Size=1
		Icon='reckless.dmi'
		IconX=-16
		IconY=-16
		WindupMessage="infuses their blade with the Ghosts of the Past..."
		ActiveMessage="carves through all in their path!"
		verb/Jest_of_the_Dead()
			set category="Skills"
			usr.Activate(src)
	Judgment_Cut_End
		AdaptRate=1
		NeedsSword=1
		DamageMult=16
		Area="Around Target"
		Distance=12
		DistanceAround=12
		TurfStrike=1
		CanBeDodged=0
		CanBeBlocked=0
		GuardBreak=1
		Divide=1
		Slow=1
		WindUp=1
		IgnoreWindUpReduction=1
		WindupMessage="<b>sheathes their blade...</b>"
		ActiveMessage="unleashes a myriad of slashes in the blink of an eye!"
		Shockwaves=3
		Shockwave=4
		HitSparkIcon='Slash - Future.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitSparkTurns=1
		HitSparkSize=1
		HitSparkDispersion=1
		ComboMaster=1
obj/Skills/Queue
	Judgment_Cut_End
		SkillCost=TIER_5_COST
		Copyable=6
		HitMessage="warps through time and space!"
		name="Judgment Cut End"
		NeedsSword=1
		DamageMult=1
		AccuracyMult = 1.175
		Duration=15
		KBMult=0.01
		Finisher=1
		Dunker=4
		Warp=15
		Bolt=1
		Stunner=5
		NeedsSword=1
		EnergyCost=4
		FollowUp="/obj/Skills/AutoHit/Judgment_Cut_End"
		Cooldown=75
		verb/Judgment_Cut_End()
			set category="Skills"
			set name="Judgment Cut End"
			var/mob/p = usr
			var/in_window = (p.judgement_cut_bonus_end_time > world.time)
			var/bonus = p.judgement_cut_bonus_value
			var/cc = p.judgement_cut_bonus_chain_count
			p.judgement_cut_bonus_end_time = 0
			p.judgement_cut_bonus_value = 1
			p.judgement_cut_bonus_chain_count = 0
			if(in_window && bonus > 1)
				var/obj/Skills/AutoHit/Judgment_Cut_End/followup = locate() in p
				var/saved_q_dmg = src.DamageMult
				var/saved_f_dmg = followup ? followup.DamageMult : 0
				var/saved_f_msg = followup ? followup.ActiveMessage : null
				src.DamageMult = saved_q_dmg * bonus
				if(followup)
					followup.DamageMult = saved_f_dmg * bonus
					if(cc >= 3)
						followup.ActiveMessage = "yells: <font size = +1><b>JACKPOT!</b></font size>"
				var/obj/Skills/Queue/Judgment_Cut_End/q = src
				spawn(100)
					q.DamageMult = saved_q_dmg
					if(followup)
						followup.DamageMult = saved_f_dmg
						followup.ActiveMessage = saved_f_msg
			p.SetQueue(src)
