// proc/isAChild(typePath, parentPath)
//     if(typePath in typesof(parentPath))
//         return TRUE
//     return FALSE
/mob/proc/throwSkill(obj/Skills/s)
    if(istype(s, /obj/Skills/AutoHit))
        Activate(s, TRUE)
    else if(istype(s, /obj/Skills/Projectile))
        UseProjectile(s)
    else if(istype(s, /obj/Skills/Queue))
        SetQueue(s)
    else if(istype(s, /obj/Skills/Grapple))
        s:Activate(src)

/mob/proc/findOrAddSkill(path) // find it, regardless
    var/obj/Skills/s = null 
    if(ispath(path) || istext(path))
        s = FindSkill(path)
        if(istext(path))
            path = text2path(path)
        if(!s)
            s = new path
    else
        s = path
    AddSkill(s)
    return s

/mob/proc/throwFollowUp(path)
    set waitfor = FALSE
    if(path == TRUE)
        return // AHAHAHAH!
    if(istext(path))
        path = text2path(path)
    var/obj/Skills/s = findOrAddSkill(path)
    s.adjust(src)
    throwSkill(s)
    
/mob/proc/cycleStackingBuffs(var/obj/Skills/S)
    if(istype(AttackQueue, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Samsara) || istype(AttackQueue?:type, /obj/Skills/Queue/Finisher/Cycle_of_Samsara))
        AttackQueue.Mastery++
        for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Samsara/s in SlotlessBuffs)
            s.Timer = 0
    if(istype(AttackQueue, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/What_Must_Be_Done))
        if(SlotlessBuffs["What Must Be Done"])
            SlotlessBuffs["What Must Be Done"].Mastery++
            SlotlessBuffs["What Must Be Done"].TimerLimit+=300


mob/proc/buffSelf(path)
    if(istext(path))
        path = text2path(path) // everything else has text useless to change it now, also makes edit easier
    var/obj/Skills/s = findOrAddSkill(path)
    if(!SlotlessBuffs[s.name])
        s.adjust(src)
    s.Password = UniqueID
    cycleStackingBuffs(s)

mob/proc/isSuperCharged(mob/p)
    if(p.passive_handler["SuperCharge"])
        if(StyleBuff.last_super_charge + glob.SUPERCHARGECD < world.time)
            return TRUE
    return FALSE

mob/proc/UsingHotnCold()
    if(StyleActive == "Hot Style")
        return TRUE
    if(StyleActive == "Cold Style")
        return TRUE
    return FALSE

/mob/proc/applySnare(limit, _icon, force = FALSE)
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Snare/s = findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Snare) // try to find it
	if(force)
		if(BuffOn(s))
			s.Trigger(src, TRUE) // this will force it off
	if(!BuffOn(s))
		s.adjust(src, limit, _icon) // regardless adjust it, no need to make it new, just add or find it
		s.Trigger(src, TRUE)
	
	// this could be better i think?


/mob/proc/TriggerPerfectCounter(mob/attacker)
    // thhis shit blows
    for(var/obj/Skills/Buffs/sb in src)
        if(sb.Counter && sb.Using)
            // trigger it as the counter will go off on deactivate XD
            sb.CounterHit = 1
            sb.Trigger(src, TRUE)


/mob/proc/getPower(mob/def)
    var/powerDif = Power / def.Power
    if(glob.CLAMP_POWER)
        if(!ignoresPowerClamp())
            powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
    return powerDif


/mob/proc/applyDebuff(mob/def, path ,passive_needed = FALSE, last_used = FALSE, cooldown = FALSE)
    if(def && path)
        if(passive_needed)
            if(!passive_handler[passive_needed]) return
        if(last_used)
            if(lasts_list[last_used] + cooldown > world.time) return
        var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/ss = def.FindSkill(path)
        if(!ss)
            ss = new path
            def.AddSkill(ss)
        ss.adjust(src, def)
        ss:add_stack(def, src)
        src << "You have applied [ss.name] to [def]!"
        def << "You feel the effects of [ss.name] being applied to you!"
        if(last_used)
            lasts_list[last_used] = world.time
