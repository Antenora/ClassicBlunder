
/mob/proc/checkOtherMacros(obj/Skills/Buffs/SlotlessBuffs/DemonMagic/org)
    for(var/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/dm in src)
        if(dm == org) continue
        if(dm.keyMacro != null)
            if(dm.keyMacro == org.keyMacro)
                return dm
    return TRUE

/mob/var/hasDemonCasting = FALSE

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
                Cooldown(1, null, User, type)
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
