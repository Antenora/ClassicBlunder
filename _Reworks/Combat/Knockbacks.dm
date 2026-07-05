/globalTracker/var/MAX_KB_MULT = 2
/globalTracker/var/MAX_KB_RES = 0.25
/globalTracker/var/MAX_KB_TIME = 15
/globalTracker/var/KB_SPEED = 0.75 // was 0.15
/globalTracker/var/KBMODDIVIDER = 2
//TODO convert to glob
/mob/proc/getLegendPMult()
    return HasMythical()*0.5
/mob/proc/gatherKBMods()
    . = 0
    . += HasGiantForm() * 1.25
    . += getLegendPMult()
    . += passive_handler.Get("HeavyHitter")
    . += 1 + passive_handler.Get("KBMult")
    var/zanzibarbreeze =  . 
    . = zanzibarbreeze/glob.KBMODDIVIDER
    if(. > glob.MAX_KB_MULT)
        . = glob.MAX_KB_MULT

/mob/proc/isForced()
    if(passive_handler.Get("HeavyHitter"))
        return 1
    return 0

/mob/proc/getKnockbackMultiplier(mob/defender)
    if(defender)
        // get the defenders anti kb measures
        if(!defender.passive_handler)
            return 1
        var/mod = ( ((defender.HasGiantForm() * 0.15) + (defender.HasMythical() * 0.5) + (defender.passive_handler.Get("Juggernaut") * 0.05)) )
        mod += clamp(defender.passive_handler.Get("KBRes") * 0.1, 0, 1)
        var/res = 1 - mod
        if(res < glob.MAX_KB_RES)
            res = glob.MAX_KB_RES
        return res

/mob/proc/PullToward(mob/source, var/nominal_steps, var/literal_distance = 0)
    if(!source || source == src || src.loc == null)
        return
    if(istype(src, /mob/Player/Afterimage))
        return
    if(Stasis)
        return
    nominal_steps = round(nominal_steps)
    if(nominal_steps < 1)
        return
    if(ContinuousAttacking)
        for(var/obj/Skills/Projectile/p in src.contents)
            if(p.ContinuousOn && !p.StormFall)
                src.UseProjectile(p)
            continue
    var/max_steps
    if(literal_distance)
        max_steps = nominal_steps
        if(max_steps > glob.MAX_KB_TIME)
            max_steps = glob.MAX_KB_TIME
    else
        max_steps = round(nominal_steps * source.gatherKBMods() * source.getKnockbackMultiplier(src))
        if(max_steps < 1)
            return
        if(max_steps > glob.MAX_KB_TIME)
            max_steps = glob.MAX_KB_TIME
    for(var/i = 1, i <= max_steps, i++)
        if(get_dist(src, source) <= 1)
            return
        var/d = get_dir(src, source)
        if(!d)
            return
        var/turf/T = get_step(src, d)
        if(!T || T.density)
            return
        var/blocked = 0
        for(var/atom/a in T)
            if(!a.density)
                continue
            blocked = 1
            break
        if(blocked)
            return
        if(!Move(T))
            return

/mob/proc/ApplyPullInArea(var/range_tiles, var/move_tiles)
    if(!src.loc)
        return
    range_tiles = round(range_tiles)
    move_tiles = round(move_tiles)
    if(range_tiles < 1 || move_tiles < 1)
        return
    for(var/mob/M in range(range_tiles, src))
        if(M == src)
            continue
        if(M in src.ai_followers)
            continue
        if(istype(src, /mob/Player/AI))
            var/mob/Player/AI/a = src
            if(!a.ai_team_fire && a.AllianceCheck(M))
                continue
        M.PullToward(src, move_tiles, 1)
