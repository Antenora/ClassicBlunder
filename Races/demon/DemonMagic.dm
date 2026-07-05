
/mob/proc/checkOtherMacros(obj/Skills/Buffs/SlotlessBuffs/DemonMagic/org)
    for(var/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/dm in src)
        if(dm == org) continue
        if(dm.keyMacro != null)
            if(dm.keyMacro == org.keyMacro)
                return dm
    return TRUE

/mob/var/hasDemonCasting = FALSE
/mob/var/lastInnovationDemonMagic = null

/mob/proc/isDemonMagicCasting(checkType = null)
    if(!client?.keyQueue) return FALSE
    if(!client.keyQueue.TRIGGERED) return FALSE
    if(checkType)
        return client.keyQueue.initType == checkType
    return TRUE

/mob/proc/endDemonMagicCast()
    if(!client?.keyQueue) return
    client.keyQueue.clearInfo()

/obj/Skills/proc/applyDemonInnovationEffect(mob/p, can_fire_override = null)
    // fix for style stacking even on cd
    if(!p) return FALSE
    if(!p.isInnovative(CELESTIAL, "Any")) return FALSE
    if(isInnovationDisable(p)) return FALSE
    if(!p.isDemonMagicCasting()) return FALSE
    var/skill_can_fire = isnull(can_fire_override) ? !(Using || cooldown_remaining) : can_fire_override
    var/curMagicType = p.client?.keyQueue?.initType
    if(skill_can_fire && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/HellFire))
        var/obj/Skills/Buffs/SlotlessBuffs/Hellraiser/hr = p.SlotlessBuffs["Hellraiser"]
        if(!hr)
            hr = new/obj/Skills/Buffs/SlotlessBuffs/Hellraiser()
        hr.stackBuff(p)
    p.endDemonMagicCast()
    if(skill_can_fire)
        var/styleGain = 1
        if(curMagicType && p.lastInnovationDemonMagic && curMagicType != p.lastInnovationDemonMagic)
            styleGain = 2
        p.lastInnovationDemonMagic = curMagicType
        p.gainStyleRating(styleGain)
    return skill_can_fire

/obj/Skills/Buffs/SlotlessBuffs/DemonMagic
    // VARS
    var/keyMacro = null
    var/KEYWORD = "error"
    possible_skills = list()
    TimerLimit = 1
    Cooldown = 120
    // PROCS
/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/proc/resetToInital()

/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/proc/EditAll(mob/p)
    if(!possible_skills) return
    if(p.Admin)
        for(var/i in possible_skills)
            if(!possible_skills[i])
                p<< "possible skill lacking somewhere, setting to inital and breaking"
                possible_skills[i]?:resetToInital()
            p?:Edit(possible_skills[i])


/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Cooldown(modify, Time, mob/p, t)
    for(var/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/dm in p)
        if("[dm.type]" == "[t]") // all instances of this 
            for(var/x in dm.possible_skills)
                if(dm.possible_skills[x])
                    if(x == "Corruption")
                        continue // no longer cuck corruption skills
                    if(dm.possible_skills[x].cooldown_remaining && !(dm in src.possible_skills))
                        continue
                    dm.possible_skills[x].Using= 0 
                    dm.possible_skills[x].Cooldown(modify, Time, p)
                    p << "[dm.possible_skills[x]] has been put on cooldown."

/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/proc/setUpMacro(mob/p)
    keyMacro = null
    p << "The next button you press will be the macro for this. There will be an alert, give it a second."
    p.client.trackingMacro = src // send a trigger to track for this skill's keymacro


/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/proc/fakeTrigger(mob/p)
    if(p.client.keyQueue.TRIGGERED && p.client.keyQueue.LAST_CAST + 300 < world.time)
        p.client.keyQueue.TRIGGERED = null
        p << "Far too late."
        p.client.keyQueue.LAST_CAST = world.time
        return
    Trigger(p, 0)
/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Trigger(mob/User, Override = 0)
    var/datum/queueTracker/keyQ = User.client.keyQueue
    if(isnull(keyQ.TRIGGERED))
        if(keyQ.LAST_CAST + 15 < world.time)
            keyQ.trigger(type)
            User << "You have started to cast [src]." // replace with animation of text above head.
            User.castAnimation()
            Cooldown = 0
            keyQ.LAST_CAST = world.time
    else
        var/initType = keyQ.initType
        // this has already been activated, therefore this must be the 2nd input
        var/result = keyQ.detectInput(10)
        var/perfect = FALSE
        if(result == 2)
            perfect = TRUE
            result = 1
        switch(result)
            if(1)
                // Cross-combo: AngelMagic was pressed first, DemonMagic pressed second
                if(findtext("[initType]", "/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/"))
                    if(User.passive_handler.Get("ChaosRuler"))
                        var/list/initParts = splittext("[initType]", "/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/")
                        var/list/curParts = splittext("[type]", "/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/")
                        var/initName = initParts.len >= 2 ? initParts[2] : ""
                        var/curName = curParts.len >= 2 ? curParts[2] : ""
                        if(initName == "Divinity" && curName == "Corruption")
                            var/obj/Skills/Buffs/SlotlessBuffs/Chaos_Soldier/cs = locate(/obj/Skills/Buffs/SlotlessBuffs/Chaos_Soldier) in User
                            if(cs)
                                cs.Trigger(User)
                                if(User.isRace(MAKAIOSHIN) && User.passive_handler && User.passive_handler.Get("Limited Rank-Up"))
                                    User.cooldownChaosSkillSingle(cs)
                                else
                                    User.cooldownAllChaosSkills()
                            else
                                User << "You lack the knowledge to complete this technique."
                        else if(initName == "Order" && curName == "HellFire")
                            var/obj/Skills/Buffs/SlotlessBuffs/Chaos_Control/cc = locate(/obj/Skills/Buffs/SlotlessBuffs/Chaos_Control) in User
                            if(cc)
                                User.SkillX("Chaos Control", cc)
                                if(User.isRace(MAKAIOSHIN) && User.passive_handler && User.passive_handler.Get("Limited Rank-Up"))
                                    User.cooldownChaosSkillSingle(cc)
                                else
                                    User.cooldownAllChaosSkills()
                            else
                                User << "You lack the knowledge to complete this technique."
                    if(perfect)
                        User.Quake(5, 0)
                    keyQ.TRIGGERED = null
                    return
                // execute the skill here
                User << "You have used your [KEYWORD] spell."
                var/trueType = splittext("[initType]", "/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/")
                var/obj/Skills/theSkill = possible_skills[trueType[2]]
                if(possible_skills[trueType[2]].cooldown_remaining > 0)
                    User << "This is on cooldown"
                    return
                
                var/triggered = theSkill?:Trigger(User, 0)
                if(triggered)
                    Cooldown(1, null, User, type)
                if(perfect)
                    User.Quake(5, 0)
                keyQ.TRIGGERED = null
            if(0)
                User << "Too Soon..."
            if(-1)
                User << "You took too long."
                keyQ.TRIGGERED = null


/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic
    name = "Dark Magic"
    
    KEYWORD = "damage"
    verb/Dark_Magic()
        set category = "Skills"
        fakeTrigger(usr)
    


    possible_skills = list("DarkMagic" = new/obj/Skills/Projectile/Magic/DarkMagic/Shadow_Ball, "HellFire" = new/obj/Skills/Projectile/Magic/HellFire/Hellpyre ,"Corruption" = new/obj/Skills/AutoHit/Magic/Corruption/Corrupt_Reality )


    resetToInital()
        possible_skills = list("DarkMagic" = new/obj/Skills/Projectile/Magic/DarkMagic/Shadow_Ball, "HellFire" = new/obj/Skills/Projectile/Magic/HellFire/Hellpyre ,"Corruption" = new/obj/Skills/AutoHit/Magic/Corruption/Corrupt_Reality )

/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/HellFire
    name = "Hell Fire"
    KEYWORD = "utility"
    verb/Hell_Fire()
        set category = "Skills"
        fakeTrigger(usr)
        if(!possible_skills["Corruption"])
            possible_skills["Corruption"] = new/obj/Skills/Buffs/SlotlessBuffs/Magic/Corruption/Corrupt_Space

    possible_skills = list("DarkMagic" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Soul_Leech, "HellFire" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/Hellstorm ,"Corruption" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/Corruption/Corrupt_Space)

    resetToInital()
        possible_skills = list("DarkMagic" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Soul_Leech, "HellFire" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/Hellstorm ,"Corruption" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/Corruption/Corrupt_Space)

/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Corruption
    name = "Corruption"
    KEYWORD = "crowd control"
    verb/Corruption()
        set category = "Skills"
        fakeTrigger(usr)
    possible_skills = list("DarkMagic" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Dominate_Mind, "HellFire" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/OverHeat,"Corruption" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/Corruption/Corrupt_Time )

    resetToInital()
        possible_skills = list("DarkMagic" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Dominate_Mind, "HellFire" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/OverHeat,"Corruption" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/Corruption/Corrupt_Time )
