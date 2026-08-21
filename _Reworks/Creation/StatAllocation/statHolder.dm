/datum/statHolder
    var/datum/stat/Strength = new()
    var/datum/stat/Force = new()
    var/datum/stat/Endurance = new()
    var/datum/stat/Speed = new()
    var/datum/stat/Offense = new()
    var/datum/stat/Defense = new()
    var/datum/stat/Vitality = new()
    proc/reset(l)
        if(islist(l))
            var/list/stats = l
            Strength.base = stats[1]
            Endurance.base = stats[2]
            Force.base = stats[3]
            Offense.base = stats[4]
            Defense.base = stats[5]
            Speed.base = stats[6]
            Vitality.base = stats.len >= 7 ? stats[7] : 1
        else if(isdatum(l))
            var/race/r = l
            Strength.base = r.strength
            Force.base = r.force
            Endurance.base = r.endurance
            Speed.base = r.speed
            Offense.base = r.offense
            Defense.base = r.defense
            Vitality.base = r.vitality
        // having these the same case would b easier, but i didnt feel like fucking w. the skin

    proc/adjust(option, stat)
        switch(option)
            if("+")
                if(vars[stat]?:invested + 1 <= 10)
                    vars[stat]+=1
                    return TRUE
            if("-")
                if(vars[stat]?:invested - 1 >= 0)
                    vars[stat]-=1
                    return TRUE
        return FALSE

    proc/calc_stat(datum/stat/stat, custom_buff = FALSE)
        var/base = stat.base
   //     if(custom_buff)
   //         return base + (invested * 0.05 )
        return base
    proc/calc_invested(datum/stat/stat, custom_buff = FALSE)
        var/invested = stat.invested
        return invested//(invested * glob.progress.STAT_PER_POINT)

/datum/stat
    var/base = 0
    var/invested = 0
    var/totalinvested

    proc/operator+=(n)
        invested+=n
    proc/operator-=(n)
        invested-=n


//i move this here because its not going to be a part of my little baby booboobabas... 
/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Shapeshift
    var/datum/customBuff/c_buff = new()
    proc/init(mob/p)
        c_buff.init(p, src)
    adjust(mob/p)
        if(p.BuffOn(src))
            return
        if(!c_buff.check(p, src))
            return
        var/list/full2short = list("Strength" = "str", "Force" = "for", "Endurance" = "end", "Offense" = "off", "Defense" = "def", \
                                    "Speed" = "spd")
        for(var/x in full2short)
            var/raa = "[uppertext(copytext(full2short[x],1,2))][copytext(full2short[x], 2,4)]"
            vars["[raa]Mult"] = c_buff.statsadd.calc_stat(c_buff.statsmult.vars[x], TRUE)
            vars["[full2short[x]]Add"] = c_buff.statsadd.calc_stat(c_buff.statsadd.vars[x], TRUE)

        passives = c_buff.current_passives
    verb/Adjust_Shapeshifter()
        set category = "Utility"
        if(!usr.BuffOn(src) && !c_buff.selecting_aguments)
            c_buff.adjust_custom_buff(usr, src)
            if(!c_buff.check(usr, src))
                return
