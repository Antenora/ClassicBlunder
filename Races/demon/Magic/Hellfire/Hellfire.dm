
/obj/Skills/Projectile/Magic/HellFire/Hellpyre
    scalingValues = list("Blasts" = list(4,5,6,6,8,10), "DamageMult" = list(4,6,8,10,12,15), \
    "Delay" = list(8,4,3,2,1,1))
    ElementalClass="Fire"
    SpellElement = "Dark"
    DamageMult = 3
    AdaptRate = 1
    IconLock='Fire Blessing.dmi'
    IconSize=2
    Trail='Aura_Fire_Small.dmi'
    MultiTrail = 1
    TrailDuration=5
    TrailSize=1
    TrailX=0
    MultiHit = 5
    TrailY=0
    AccMult = 3
    Deflectable = 0
    Dodgeable = 1
    Speed = 0.75
    Cooldown = 60
    ActiveMessage = "unleashes a wave of Fire!"
    ManaCost = 5
    Delay = 8
    MagicNeeded = 0
    CorruptionGain = 1
    proc/returnToInit()
        if(!altered)
            scalingValues = /obj/Skills/Projectile/Magic/HellFire/Hellpyre::scalingValues
    adjust(mob/p)
        returnToInit()
        var/asc = p.AscensionsAcquired ? p.AscensionsAcquired + 1 : 1
        for(var/x in scalingValues)
            vars[x] = scalingValues[x][asc]
        Homing = 1
        DarknessFlame = asc + round(p.Potential/15)
        Scorching = asc * 10
        DamageMult = (DamageMult / MultiHit) / Blasts
    verb/Hellpyre()
        set category = "Skills"
        adjust(usr)
        usr.UseProjectile(src)

/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/Hellstorm
    ElementalClass="Fire"
    SpellElement = "Dark"
    scalingValues = list("Damage" = list(0.2,0.25,0.3,0.35,0.4,0.45), "Distance" = list(4,6,6,6,8,10), \
    "DarknessFlame" = list(6,12,15,20,25,25), "Slow" = list(0,0,0,0,0,0), "Burning" = list(10,15,20,25,25,30), "Duration" = list(100,150,150,175,200,300), \
    "Adapt" = list(1,1,1,1,1,1), "CorruptionGain" = list(1,1,1,1,1,1) )
    makSpace = new/spaceMaker/HellFire
    var/icon_to_use = 'Flaming Rain.dmi'
    var/states_to_use = list("","1")
    var/layer_to_use = MOB_LAYER+0.1
    Cooldown=90
    ManaCost = 8
    TimerLimit = 10
    EndYourself=1
    MagicNeeded = 0
    ActiveMessage = "rains down an onslaught of fire!"
    adjust(mob/p)
        scalingValues = /obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/Hellstorm::scalingValues
        var/asc = p.AscensionsAcquired ? p.AscensionsAcquired + 1 : 1
        makSpace.toDeath = scalingValues["Duration"][asc]
        makSpace.range = scalingValues["Distance"][asc]
        makSpace.configuration = "Fill"
        makSpace.getDmg(p, src)
    verb/HellStorm()
        set category = "Skills"
        adjust(usr)
        if(cooldown_remaining > 0)
            usr << "on cooldown"
        else
            src.Trigger(usr, 0 )
    Trigger(mob/User, Override = 0)
        . = 1
        adjust(User)
        var/aaa = ..()
        if(aaa && !User.BuffOn(src))
            makSpace.makeSpace(User, src)
            . = aaa
            Cooldown(1, 0, User)
    proc/applyEffects(mob/target, mob/owner, static_damage)
        if(!owner||!target) return
        var/asc = owner.AscensionsAcquired ? owner.AscensionsAcquired + 1 : 1
        var/DefReduction=target.GetDef()
        if(DefReduction<1)
            DefReduction=1
        if(target.IsGrabbed())
            static_damage *= glob.AUTOHIT_GRAB_NERF
        if(target.Stunned||target.Launched)
            static_damage *= glob.CCDamageModifier
        for(var/x in scalingValues)
            switch(x)
                if("Damage")
                    static_damage *= scalingValues[x][asc]
                    static_damage /= DefReduction
                    static_damage = owner.DoDamage(target, static_damage, 0, 0 , 0 , 0 , 0 , 0 , 0)
                    owner.gainCorruption((static_damage * 2) * glob.CORRUPTION_GAIN)
                if("DarknessFlame")
                    target.AddPoison(scalingValues["Burning"][asc] * 1 + (scalingValues[x][asc] * 0.33), Attacker=owner)
                if("Burning")
                    target.AddBurn(scalingValues[x][asc])
                if("Slow")
                    target.AddCrippling(scalingValues[x][asc]/DefReduction)
        if(!target:move_disabled)
            if(prob(glob.HELLSTORM_SNARERATE*asc))
                target:move_disabled = TRUE
                spawn(glob.HELLSTORM_SNAREDURATION*asc)
                    target:move_disabled = FALSE

/mob/proc/getHellStormDamage()
    if(src.GetStr(1) > src.GetFor(1))
        . = GetStr(1)
    else
        . = GetFor(1)
    var/dmgRoll = GetDamageMod()
    . *= dmgRoll

/obj/Skills/Buffs/SlotlessBuffs/Hellraiser
    name = "Hellraiser"
    BuffName = "Hellraiser"
    Slotless = 1
    TimerLimit = 30
    TopOverlayLock = 'Icons/Effects/Evil_Electric_Aura.dmi'

    proc/stackBuff(mob/p)
        if(SlotlessOn)
            // Buff already active: stack passives and refresh duration
            p.passive_handler.decreaseList(current_passives)
            var/new_flicker = min(6, current_passives["Flicker"] + 0.5)
            var/new_pursuer = min(6, current_passives["Pursuer"] + 0.5)
            var/new_mastery = min(6, current_passives["TechniqueMastery"] + 0.25)
            current_passives = list("Flicker" = new_flicker, "Pursuer" = new_pursuer, "TechniqueMastery" = new_mastery)
            passives = current_passives
            p.passive_handler.increaseList(current_passives)
            Timer = 0
        else
            // First application
            passives = list("Flicker" = 0.5, "Pursuer" = 0.5, "TechniqueMastery" = 0.25)
            p.AddSlotlessBuff(src)
            current_passives = passives
            p.passive_handler.increaseList(passives)




/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/OverHeat
    ElementalClass="Fire"
    scalingValues = list("CrippleAffected" = list(12,15,15,20,25,25), \
    "PoisonAffected" = list(3,6,12,12,15,15), "BurnAffected" = list(10,15,20,20,20,25), "ConfuseAffected" = list(1,2,3,4,5,6), \
    "TimerLimit" = list(5,8,12,15,20,25))
    ManaCost=5
    AffectTarget=1
    Range=15
    CrippleAffected=10
    PoisonAffected = 10
    ConfuseAffected = 1
    BurnAffected = 10
    TimerLimit = 5
    MagicNeeded = 0
    Cooldown = 60
    TargetOverlay = 'DarkShock.dmi'
    ActiveMessage = "swells fire within their target."
    proc/returnToInit()
        if(!altered)
            scalingValues = list("CrippleAffected" = list(12,15,15,20,25,25), \
    "PoisonAffected" = list(3,6,12,12,15,15), "BurnAffected" = list(3,6,12,15,15,15), "ConfuseAffected" = list(1,2,5,6,8,10), \
    "TimerLimit" = list(5,8,12,15,20,25))

    adjust(mob/p)
        returnToInit()
        var/asc = p.AscensionsAcquired ? p.AscensionsAcquired + 1 : 1
        for(var/x in scalingValues)
            vars[x] = scalingValues[x][asc]
    Trigger(mob/User, Override)
        adjust(User)
        ..()
    verb/OverHeat()
        set category = "Skills"
        src.Trigger(usr, 0 )

// THIS IS FOR THE XIULINGITES AND IS NOT MEANT FOR DEMON USE, I JUST PUT IT HERE BECAUSE OF INHERITANCE SHENANIGANS
/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/Inkstorm
    ElementalClass="Water"
    scalingValues = list("Damage" = list(0.2,0.25,0.3,0.35,0.4,0.45), "Distance" = list(4,6,6,6,8,10), \
    "AbsoluteZero" = list(6,12,15,20,25,25), "Slow" = list(2,2,3,4,5,5), "Freezing" = list(10,15,20,25,25,30), "Duration" = list(100,150,150,175,200,300), \
    "Adapt" = list(1,1,1,1,1,1), "CorruptionGain" = list(0,0,0,0,0,0) )
    makSpace = new/spaceMaker/HellFire
    var/icon_to_use = 'Icons/New/inkwater2.dmi'
    var/states_to_use = list("","1") // Fun fact, this is USELESS
    var/layer_to_use = MOB_LAYER-0.1
    Cooldown=90
    ManaCost = 8
    TimerLimit = 10
    EndYourself=1
    MagicNeeded = 0
    ActiveMessage = "pours Ink into the world around them."
    adjust(mob/p)
        scalingValues = /obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/Inkstorm::scalingValues
        var/asc = p.AscensionsAcquired ? p.AscensionsAcquired + 1 : 1
        makSpace.toDeath = scalingValues["Duration"][asc]
        makSpace.range = scalingValues["Distance"][asc]
        makSpace.configuration = "Fill"
        makSpace.getDmg(p, src)
    verb/Inkstorm()
        set category = "Skills"
        adjust(usr)
        if(cooldown_remaining > 0)
            usr << "on cooldown"
        else
            src.Trigger(usr, 0 )
    Trigger(mob/User, Override = 0)
        . = 1
        adjust(User)
        var/aaa = ..()
        if(aaa && !User.BuffOn(src))
            makSpace.makeSpace(User, src)
            . = aaa
            Cooldown(1, 0, User)
    proc/applyEffects(mob/target, mob/owner, static_damage)
        if(!owner||!target) return
        var/asc = owner.AscensionsAcquired ? owner.AscensionsAcquired + 1 : 1
        var/DefReduction=sqrt(target.GetDef())
        for(var/x in scalingValues)
            switch(x)
                if("Damage")
                    static_damage *= scalingValues[x][asc]
                    static_damage /= DefReduction
                    static_damage = owner.DoDamage(target, static_damage, 0, 0 , 0 , 0 , 0 , 0 , 0)
                    //owner.gainCorruption((static_damage * 2) * glob.CORRUPTION_GAIN)
                if("Freezing")
                    target.AddSlow(scalingValues[x][asc]) // THIS IS SO FUCKING STUPID WHY IS FREEZING ADDED BY ADDSLOW AND SLOW ADDED BY ADDCRIPPLIGN DIE IN A HOLE
                if("AbsoluteZero")
                    target.AddShock(0.5 * scalingValues["Freezing"][asc] * 1 + (scalingValues[x][asc] * 0.33), Attacker=owner)
                    target.AddShatter(0.5 * scalingValues["Freezing"][asc] * 1 + (scalingValues[x][asc] * 0.33), Attacker=owner)
                if("Slow")
                    target.AddCrippling(scalingValues[x][asc]/DefReduction) // THIS IS SO FUCKING STUPID WHO DECIDED THIS SHIT???I HATE YOU ALL
        if(!target:move_disabled)
            if(prob(glob.HELLSTORM_SNARERATE*asc))
                target:move_disabled = TRUE
                spawn(glob.HELLSTORM_SNAREDURATION*asc)
                    target:move_disabled = FALSE
