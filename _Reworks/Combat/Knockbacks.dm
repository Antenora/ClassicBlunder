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
