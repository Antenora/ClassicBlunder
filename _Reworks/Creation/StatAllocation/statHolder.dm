/datum/statHolder
    var/datum/stat/Strength = new()
    var/datum/stat/Force = new()
    var/datum/stat/Endurance = new()
    var/datum/stat/Speed = new()
    var/datum/stat/Offense = new()
    var/datum/stat/Defense = new()
    proc/reset(l)
        if(islist(l))
            var/list/stats = l
            Strength.base = stats[1]
            Endurance.base = stats[2]
            Force.base = stats[3]
            Offense.base = stats[4]
            Defense.base = stats[5]
            Speed.base = stats[6]
        else if(isdatum(l))
            var/race/r = l
            Strength.base = r.strength
            Force.base = r.force
            Endurance.base = r.endurance
            Speed.base = r.speed
            Offense.base = r.offense
            Defense.base = r.defense
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

    proc/exponential_scaling(datum/stat/s)
        var/per_point = glob.progress.STAT_PER_POINT
        var/denom_base = glob.progress.DENOMINATOR_BASE
        var/denom_mod = glob.progress.DENOMINATOR_MOD
        if(s.base <= 0.25)
            denom_mod *= (s.base / glob.progress.STAT_DIMINISHING_THRESHOLD)
        return round(s.base + (per_point * (s.invested/(denom_base+denom_mod * s.invested))), 0.01)

    proc/calc_stat(datum/stat/stat, custom_buff = FALSE)
        var/base = stat.base
        var/invested = stat.invested
        if(custom_buff)
            return base + (invested * 0.05 )
        else
            if(glob.progress.STAT_DIMINISHING_RETURNS && base + (invested *glob.progress.STAT_PER_POINT) > glob.progress.STAT_DIMINISHING_THRESHOLD)
                return exponential_scaling(stat)
        return base + (invested * glob.progress.STAT_PER_POINT)

/datum/stat
    var/base = 0
    var/invested = 0

    proc/operator+=(n)
        invested+=n
    proc/operator-=(n)
        invested-=n