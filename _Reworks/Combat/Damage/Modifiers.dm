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
        if(defender.HasNull())
            . = 0;


globalTracker/var/
    MORTAL_VS_GOD_SPEC_DMG_REDUCTION = 0.3;

#define NO_GOD_KI_REDUCTION 1
#define VALID_SPEC_DMG_TYPE list("Holy", "Abyss", "Slayer", "Deicide")//only slayer is implemented atm
/mob/proc/attackModifiers(mob/defender, list/forcedDmgList=list())
    var/godKiNerf = NO_GOD_KI_REDUCTION;
    if(defender.HasGodKi() && !HasGodKi() && !HasNull()) godKiNerf += max(0, (glob.MORTAL_VS_GOD_SPEC_DMG_REDUCTION * defender.GetGodKi()));
    if(passive_handler.Get("Enraged") && Anger)
        if(!defender.Anger || Anger > defender.Anger)
            . += passive_handler.Get("Enraged") / glob.ENRAGED_DAMAGE_DIVISOR
    var/forcedHoly = getForcedDamageType("Holy", forcedDmgList)
    if(HasHolyMod() || forcedHoly)
        var/holyMag = max(HasHolyMod() ? GetHolyMod() : 0, forcedHoly)
        . += HolyDamage(defender, holyMag) / glob.HOLY_DAMAGE_DIVISOR
    var/forcedAbyss = getForcedDamageType("Abyss", forcedDmgList)
    if(HasAbyssMod() || forcedAbyss)
        var/abyssMag = max(HasAbyssMod() ? GetAbyssMod() : 0, forcedAbyss)
        . += AbyssDamage(defender, abyssMag) / glob.ABYSS_DAMAGE_DIVISOR
    . += GetSlayerMod(defender, getForcedDamageType("Slayer", forcedDmgList)) / glob.SLAYER_DAMAGE_DIVISOR; //validates within the GetSlayerMod proc, which does still need to be moved out of _binaryChecks
    if(passive_handler.Get("Deicide")) . += DeicideDamage(defender) / glob.DEICIDE_DAMAGE_DIVISOR
    else . /= max(NO_GOD_KI_REDUCTION, godKiNerf);

/mob/proc/getForcedDamageType(typeToFind, list/forcedDmgList=list())
    if(!typeToFind) return 0;
    if(!forcedDmgList || forcedDmgList.len < 1) return 0;
    if(!(typeToFind in VALID_SPEC_DMG_TYPE)) return 0;
    var/val = forcedDmgList[typeToFind];
    . = 0;
    . += isnum(val) ? val : 0;

/// For Holy/Abyss autohits
/mob/proc/autohitSpecDmgTypeList(obj/Skills/Z)
    if(!Z) return list()
    . = list()
    if(Z.HolyMod) .["Holy"] = Z.HolyMod
    if(Z.AbyssMod) .["Abyss"] = Z.AbyssMod
    if(Z.SlayerMod) .["Slayer"] = Z.SlayerMod

/mob/proc/autohitPurityDamageBlocked(mob/defender, obj/Skills/Z)
    if(!defender || !Z) return FALSE
    if(!HasPurity() && !Z.Purity) return FALSE
    var/found = 0
    if(HasBeyondPurity() || Z.BeyondPurity)
        if(HasHolyMod() || Z.HolyMod)
            if(defender.IsGood())
                found = 1
        if(found)
            return TRUE
    else
        if(HasHolyMod() || Z.HolyMod)
            if(defender.IsEvil())
                found = 1
        if(!found)
            return TRUE
    return FALSE