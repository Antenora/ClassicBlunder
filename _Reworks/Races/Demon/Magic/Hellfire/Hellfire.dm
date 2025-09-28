
/obj/Skills/Projectile/Magic/HellFire/Hellpyre
    scalingValues = list("Blasts" = list(4,5,6,6,8,10), "DamageMult" = list(4,6,8,10,12,15), \
    "Delay" = list(8,4,3,2,1,1))
    ElementalClass="Fire"
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
    scalingValues = list("Damage" = list(0.3,0.5,0.7,0.8,1,1), "Distance" = list(3,6,10,15,20,20), \
    "DarknessFlame" = list(6,12,15,20,25,25), "Slow" = list(6,10,12,12,15,20), "Burning" = list(10,15,20,25,25,30), "Duration" = list(200,300,300,350,400,600), \
    "Adapt" = list(1,1,1,1,1), "CorruptionGain" = list(1,1,1,1,1) )
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
        for(var/x in scalingValues)
            switch(x)
                if("Damage")
                    static_damage *= scalingValues[x][asc]
                    static_damage = owner.DoDamage(target, static_damage, 0, 0 , 0 , 0 , 0 , 0 , 0)
                    owner.gainCorruption((static_damage * 2) * glob.CORRUPTION_GAIN)
                if("DarknessFlame")
                    target.AddPoison(scalingValues["Burning"][asc] * 1 + (scalingValues[x][asc] * 0.33), Attacker=owner)
                if("Burning")
                    target.AddBurn(scalingValues[x][asc])
                if("Slow")
                    target.AddCrippling(scalingValues[x][asc])
        if(!target:move_disabled)
            if(prob(glob.HELLSTORM_SNARERATE*asc))
                target:move_disabled = TRUE
                spawn(glob.HELLSTORM_SNAREDURATION*asc)
                    target:move_disabled = FALSE

/mob/proc/getHellStormDamage()
    if(Owner.GetStr(1) > Owner.GetFor(1))
        . = GetStr(1)
    else
        . = GetFor(1)
    var/dmgRoll = GetDamageMod()
    . *= dmgRoll




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
        
