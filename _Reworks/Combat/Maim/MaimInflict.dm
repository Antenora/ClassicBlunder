obj/Skills/Maim
	name = "Maim"
	Desc = "Maim an opponent you have beaten. Target someone knocked out within one tile after a serious fight, then pick the body part. A part already at tier 3 cannot be picked, and each knockout allows one maim."
	verb/Maim()
		set category = "Skills"
		usr.MaimAction(src)

mob/var/tmp/maim_ko_used = 0

mob/proc/MaimRefusal(mob/T)
	if(KO)
		return "You cannot do that while knocked out."
	if(!ismob(T) || T == src)
		return "You need a target to maim."
	if(get_dist(src, T) > 1)
		return "[T] must be within one tile."
	if(!T.KO)
		return "[T] must be knocked out."
	if(party && party.members && (T in party.members))
		return "You cannot maim a member of your party."
	if(!FightingSeriously(src, T))
		return "Maiming needs a serious fight: injury or lethal intent."
	if(T.maim_ko_used)
		return "[T] has already been maimed this knockout."
	return null

mob/proc/MaimAction(obj/Skills/S)
	if(S && S.Using)
		return
	var/mob/T = Target
	var/why = MaimRefusal(T)
	if(why)
		src << why
		return
	var/list/choices = list()
	for(var/p in MAIM_PARTS)
		if(T.MaimTierOf(p) < MAIM_TIER_MAX)
			choices += p
	if(!choices.len)
		src << "[T] cannot be maimed any further."
		return
	if(S)
		S.Using = 1
	var/part = Ask(src, "Which part of [T] do you maim?", "Maim", null, "pick", choices, 1)
	if(S)
		S.Using = 0
	if(!(part in choices))
		return
	why = MaimRefusal(T)
	if(why)
		src << why
		return
	T.maim_ko_used = 1
	var/t = T.MaimApply(part, 1)
	T.recordMaim(src, "Maim", "[part] tier [t]")
	OMsg(src, "<font color='red'>[src] maims [T]'s [lowertext(part)]!</font color>")
	T << "<font color='red'>Your [lowertext(part)] has been maimed. It is now tier [t].</font color>"

mob/Conscious()
	maim_ko_used = 0
	return ..()

mob/Players/addMissingSkills()
	..()
	if(!(locate(/obj/Skills/Maim) in src))
		AddSkill(new /obj/Skills/Maim)
