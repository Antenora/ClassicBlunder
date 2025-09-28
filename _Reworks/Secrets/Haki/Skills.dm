/obj/Skills/AutoHit/var/buffAffectedType = "" // Power, Potential, Intimidation, etc -- the var to compare, if it is being compared
/obj/Skills/AutoHit/var/buffAffectedCompare = FALSE // TRUE if it is being compared, FALSE if it is not
/obj/Skills/AutoHit/var/buffAffectedBoon = ""
// then buffAffected is a list, and compare is TRUE, find the type and compare, when it is false, randomly select a buff
// otherwise just use the BuffAffected


/mob/proc/compareVariable(mob/enemy, thingToCompare, extraType)
    var/extra = secretDatum.currentTier
    if(enemy.Secret == Secret)
        if(extraType == "Haki") // they arent a king
            if(enemy.secretDatum.secretVariable["ConquerorsHaki"] == 1)
                extra -= enemy.secretDatum.currentTier
            else
                extra -= 2
    switch(thingToCompare)
        if("Potential")
            var/difference = Potential - enemy.Potential
            difference += extra
            if(difference >= 10)
                return 4
            else if(difference >= 4)
                return 3
            else if(difference >= 0)
                return 2
            else if(difference <= -1)
                return 1
            return 1
        if("Power")
            var/difference = (Power + extra*glob.EXTRA_CONQ_HAKI_POWER) / enemy.Power
            if(difference >= 2) // 2x stronger
                return 4
            else if(difference >= 1.5) // 1.5x stronger
                return 3
            else if(difference >= 1) // 1x stronger
                return 2
            else if(difference <= 0.75) // 2x weaker
                return 1






/obj/Skills/AutoHit/Haki/Conquerors_Haki
    BuffAffected=list("/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HakiDebuffs/Resisted", "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HakiDebuffs/Shaken", \
    "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HakiDebuffs/Destroyed_Will", "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HakiDebuffs/Unconscious")
    buffAffectedBoon = "Haki"
    buffAffectedCompare = TRUE
    buffAffectedType = "Potential"
    // unphased = when stronger, shaken = when equal, destroyed will = when weaker, unconscious = when much weaker
    //TODO make buffaffected of autohits detected on hit
    NoLock=1
    NoAttackLock=1
    Area="Circle"
    DamageMult = 0.001
    StrOffense = 1
    Distance = 12
    Stunner = 5
    GuardBreak = 1
    Cooldown = -1
    Instinct = 5
    ActiveMessage="'s willpower is exerted, showcasing the qualities of a King!"
    TurfStrike=1
    verb/exertWill()
        set category="Roleplay"
        set name = "Exert Will"
        // for show
        ActiveMessage = "expunges their willpower, suddenly increasing the pressure in the area!"
        if(ActiveMessage)
            OMsg(usr, "<b><font color='[ActiveColor]'>[usr] [ActiveMessage]</font color></b>")
        //TODO do some effect here

    verb/Kings_Haki()
        set category="Skills"
        set name = "Kings Haki"
        ActiveMessage="'s willpower is exerted, showcasing the qualities of a King!"
        usr.Activate(src)


/obj/Skills/Queue/Haki/Kings_Infusion
    NoWhiff = 1
    Duration = 6
    Cooldown = 30
    InstantStrikes = 2
    Shocking = 5
    DamageMult = 1
    EnergyCost = 1.5
    FollowUp = "/obj/Skills/AutoHit/Haki/Kings_Infusion_Follow"
    verb/Kings_Infusion()
        set category="Skills"
        set name = "Kings Infusion"
        usr.SetQueue(src)

/obj/Skills/AutoHit/Haki/Kings_Infusion_Follow
    NoLock=1
    NoAttackLock=1
    UnarmedOnly=1
    ComboMaster=1
    Area="Circle"
    Size = 1
    StrOffense = 1
    Distance = 1
    Rounds = 2
    Knockback = 1
    GuardBreak = 1
    Cooldown=4
    DamageMult = 0.5


/obj/Skills/Queue/Haki/Galaxy_Impact
    NoWhiff = 1
    Delayer = 0.2
    Decider = 2
    Duration = 8
    Cooldown = 160
    InstantStrikes = 3
    Launcher = 3
    DamageMult = 1
    EnergyCost = 15
    FollowUp = "/obj/Skills/AutoHit/Haki/Galaxy_Impact_Follow"
    HitSparkIcon = 'Icons/HitWind.dmi'
    HitSparkSize = 2
    ActiveMessage = "starts to channel their conquerors haki!"
    HitMessage = "hits their enemy with a heavy haki-infused punch!"

    verb/Galaxy_Impact()
        set category="Skills"
        set name = "Galaxy Impact"
        usr.SetQueue(src)


/obj/Skills/AutoHit/Haki/Galaxy_Impact_Follow
    NoLock=1
    NoAttackLock=1
    UnarmedOnly=1
    ComboMaster=1
    Area="Circle"
    Size = 5
    Icon = "Tornado.dmi"
    IconX=-8
    IconY=-8
    StrOffense = 1
    Distance = 10
    Rounds = 1
    Knockback = 1
    GuardBreak = 1
    Cooldown=4
    DamageMult = 11
    HitSparkIcon = 'Icons/GojoHitspark.dmi'
    TurfShift = 'Icons/LavaRock2.dmi'
    TurfShiftDuration = 15
    ActiveMessage = "devastates the area with a spactacular blast of pure utter willpower!"



/obj/Skills/Projectile/Divine_Departure
    EnergyCost = 5
    MultiHit = 5
    EndRate = 1
    FadeOut = 5
    Slashing = 1
    Knockback = 3
    AccMult = 2
    Dodgeable = 0
    Deflectable = 0
    DamageMult = 2
    MortalBlow = 0.5
    Radius = 3
    HyperHoming=1
    Homing=1
    HomingCharge=1
    HomingDelay=1
    Devour = 1
    StrRate = 1
    ForRate = 1
    verb/Divine_Departure()
        set category="Skills"
        set name = "Divine Departure"
        usr.UseProjectile(src)

