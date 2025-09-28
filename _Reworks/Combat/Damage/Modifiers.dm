globalTracker/var/SYMBIOTE_DMG_TEST = 2

/mob/proc/styleModifiers(mob/defender)
    if(HasSoftStyle())
        . += (defender.TotalFatigue/20) * (GetSoftStyle() / glob.SOFT_STYLE_DMG_BOON_DIVISOR)
    if(HasHardStyle())
        . += (defender.TotalInjury/20) * (GetHardStyle() / glob.HARD_STYLE_DMG_BOON_DIVISOR)
    if(passive_handler.Get("CheapShot"))
        . += (defender.TotalInjury/glob.CHEAP_SHOT_DIVISOR) * (passive_handler.Get("CheapShot"))
    if(HasCyberStigma())
        if(defender.CyberCancel || defender.Mechanized || defender.Saga == "King of Braves")
            var/mana = defender.ManaAmount
            var/manaCap = defender.GetManaCapMult()
            var/ratio = mana / manaCap
            ratio = abs(ratio - 100) / 33
            . += ratio * (max(defender.Mechanized,defender.CyberCancel) * (GetCyberStigma() ))

/mob/proc/DeicideDamage(mob/defender, forced = 0 )
    if(defender.HasGodKi())
        if(!forced)
            var/defenderGKi = defender.GetGodKi()
            var/deicideTicks = passive_handler.Get("Deicide")
            var/percent = deicideTicks * defenderGKi
            var/nerf = HasGodKi() ? 1 - GetGodKi() : 0
            if(nerf)
                if(nerf<=0)
                    nerf = defenderGKi - GetGodKi()
                    percent = deicideTicks * nerf
                . += percent * nerf
            else
                . += percent
        else
            . += forced



/mob/proc/attackModifiers(mob/defender)
    var/nerf = (defender.HasGodKi()) ? 1 - (0.3 * defender.GetGodKi()) : 0
    if(nerf && nerf <= 0)
        nerf = 0.1
    if(passive_handler.Get("Enraged") && Anger)
        if(!defender.Anger || Anger > defender.Anger)
            . += passive_handler.Get("Enraged") / glob.ENRAGED_DAMAGE_DIVISOR
    if(HasHolyMod())
        . += HolyDamage(defender) / glob.HOLY_DAMAGE_DIVISOR
    if(HasAbyssMod())
        . += AbyssDamage(defender) / glob.ABYSS_DAMAGE_DIVISOR
    if(HasSlayerMod())
        . += SlayerDamage(defender) / glob.SLAYER_DAMAGE_DIVISOR
    if(passive_handler.Get("Deicide"))
        . += DeicideDamage(defender) / glob.DEICIDE_DAMAGE_DIVISOR
    else
        if(nerf > 0)
            . *= nerf
