globalTracker/var/pot_between_refunds = 2

mob/var/last_refund_pot = 0
mob/var/refund_banned = FALSE
mob/var/tmp/refunding = FALSE

mob/proc/pick_refund_skill(mob/target = src)
	var/list/Refundable=list("Cancel")
	for(var/obj/Skills/S in target.Skills)
		if(S.Copyable>0&&S.SkillCost>1&&!S.Copied)
			Refundable.Add(S)
		else if(istype(S, /obj/Skills/Buffs/NuStyle) && !S.Copied  && !S.SignatureTechnique && !S.SignatureTechnique && S.SkillCost > 1)
			Refundable.Add(S)
	var/obj/Skills/Choice=input(src, "What skill are you refunding?", "RPP Refund") in Refundable
	if(Choice=="Cancel")
		return

	return Choice

mob/proc/refund_skill(obj/Skills/refunded_skill)
	var/Refund=refunded_skill.SkillCost
	if(refunded_skill.NewCost)
		Refund = refunded_skill.NewCost
	if(refunded_skill.Mastery>1)
		Refund+=(Refund*(refunded_skill.Mastery-1))
	if(refunded_skill.name in src.SkillsLocked)
		src.SkillsLocked -= refunded_skill.name

	RPPSpendable+=Refund
	RPPSpent-=Refund
	src << "You've have been refunded [refunded_skill] for [Commas(Refund)] RPP."
	if(usr && src != usr)
		usr << "You've refunded [refunded_skill] for [Commas(Refund)] RPP."
	for(var/obj/Skills/S in Skills)
		if(refunded_skill&&S)
			if(S.type==refunded_skill.type)
				if(istype(S, /obj/Skills/Buffs))
					var/obj/Skills/Buffs/s = S
					if(src.BuffOn(s))
						s.Trigger(src, Override=1)
				/*if(istype(S, /obj/Skills/Buffs/NuStyle))
					if(S:StyleComboUnlock)
						if(IsList(S:StyleComboUnlock))
							for(var/x in S:StyleComboUnlock)
								if(!x) return
								var/advanced_path=text2path(S:StyleComboUnlock[x])
								if(!advanced_path) return
								var/obj/Skills/Buffs/NuStyle/StyleToRefund = locate(advanced_path) in src
								if(StyleToRefund)
									refund_skill(StyleToRefund)*/
				del S
				break
	for(var/obj/Skills/Buffs/NuStyle/s in src)
		src.StyleUnlock(s)

	if(Potential > 1)
		Potential -= 1

mob/verb/Refund()
	set category="Other"
	if(refund_banned) return
	if(refunding)
		usr << "You're already trying to refund something!"
		return
	if(last_refund_pot!=0 && usr.Potential < last_refund_pot+glob.pot_between_refunds)
		usr << "You've already refunded something within the last [glob.pot_between_refunds] potential!"
		return
	refunding = TRUE

	var/refunding_skill = pick_refund_skill()

	if(!refunding_skill)
		refunding = FALSE
		return

	usr.refund_skill(refunding_skill)

	last_refund_pot = usr.Potential
	refunding = FALSE



/mob/proc/refund_all_copyables_old()
	for(var/obj/Skills/S in Skills)
		if((S.Copyable>0&&S.SkillCost))
			refund_skil_old(S)

/mob/proc/refund_all_copyables()
	for(var/obj/Skills/S in Skills)
		if((S.Copyable>0&&S.SkillCost))
			refund_skill(S)

// im going to sin below
/mob/Admin3/verb/refund_all_old_value(mob/p in world)
	p.refund_all_copyables()

mob/proc/refund_skil_old(obj/Skills/refunded_skill)
	var/Refund=refunded_skill.SkillCost

	if(istype(refunded_skill, /obj/Skills/Buffs/NuStyle))
		if(refunded_skill.SignatureTechnique > 0) Refund = 0
		else src.SignatureSelected -= refunded_skill.name
		Refund += ((2**(refunded_skill.SignatureTechnique+1)*10)) * max(0,(refunded_skill.Mastery-1))
	else if(refunded_skill.Mastery>1)
		Refund+=(refunded_skill.SkillCost*(refunded_skill.Mastery-1))
	if(refunded_skill.name in src.SkillsLocked)
		src.SkillsLocked -= refunded_skill.name

	RPPSpendable+=Refund
	RPPSpent-=Refund
	src << "You've have been refunded [refunded_skill] for [Commas(Refund)] RPP."
	if(usr && src != usr)
		usr << "You've refunded [refunded_skill] for [Commas(Refund)] RPP."
	for(var/obj/Skills/S in Skills)
		if(refunded_skill&&S)
			if(S.type==refunded_skill.type)
				if(istype(S, /obj/Skills/Buffs))
					var/obj/Skills/Buffs/s = S
					if(src.BuffOn(s))
						s.Trigger(src, Override=1)
				del S
				break
	for(var/obj/Skills/Buffs/NuStyle/s in src)
		src.StyleUnlock(s)
