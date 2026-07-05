/obj/Skills/Buffs/SpecialBuffs/Sin

/obj/Skills/Buffs/SpecialBuffs/Sin/Gluttony
    Cooldown = -1
    var/gluttonStorage = 0
    var/maxGluttonStorage = 100
    var/hungerMult = 1 // how further the energy is multed coming in
    var/anAcquiredTaste = 0 // how many people have been eaten
    var/list/eatenPeople = list() // really lazy cause this should be given to people who are trusted most likely
    IconLock = 'Black Rock Flame.dmi'
    ElementalDefense = "Void"

    proc/resetVariables()
        gluttonStorage = 0


    proc/setVariables(mob/p)
        EndMult = 1 + (p.Potential/100)
        StrMult = 1 + (p.Potential/200)
        ForMult = 1 + (p.Potential/200)
        maxGluttonStorage = 100 + (p.Potential*2)
        hungerMult = 1 + (p.Potential/200)
        if(anAcquiredTaste)
            passives = list("Gluttony" = round(p.Potential/100,0.1), "BulletKill" = 1, "Siphon" = round(p.Potential/100, 0.1) ,\
                "Juggernaut" = 0.1 * anAcquiredTaste, "DemonicDurability" = 0.1 * anAcquiredTaste, Hellpower = 0.05 * anAcquiredTaste)
            if(anAcquiredTaste >= 10)
                passives["GodKi"] = 0.05 * (anAcquiredTaste-9)
        else
            passives = list("Gluttony" = round(p.Potential/100,0.1), "BulletKill" = 1, "Siphon" = round(p.Potential/100, 0.1))

    verb/Embrace_Sin()
        set category = "Skills"
        if(!usr.BuffOn(src))
            resetVariables()
            setVariables(usr)
        Trigger(usr)


/obj/Skills/Buffs/SlotlessBuffs/Sin/Gluttony/Digestion
    VaizardShatter = 1
    Cooldown = 120
    var/MinActivation = 25
    ActiveMessage = "condenses their stored energy into a miasma of sinful energy!"
    proc/canActivate(mob/p)
        if(p.SpecialBuff)
            var/obj/Skills/Buffs/SpecialBuffs/Sin/Gluttony/gluttonyBuff = p.SpecialBuff
            if(gluttonyBuff.gluttonStorage > 0)
                return 1
            else
                return 0
    proc/reset()
        VaizardHealth = 0

    adjust(mob/p)
        VaizardHealth = (p.SpecialBuff:gluttonStorage*0.25)/5
        passives = list("Siphon" = round(p.Potential/200, 0.1), "Juggernaut" = 0.5, "FluidForm" = 1 + round(p.Potential/150,0.25), "DemonicDurability" = p.Potential/200, "NoDodge" = 1)
        // fairly sure it don't work with uh fluid form but i'll leave it in for now
        MinActivation = 25 + (p.Potential/2)
    verb/Digestion()
        set category = "Skills"
        if(canActivate(usr))
            if(!usr.BuffOn(src))
                reset()
                adjust(usr)
            Trigger(usr)
            if(usr.BuffOn(src))
                usr.SpecialBuff:gluttonStorage -= usr.SpecialBuff:gluttonStorage*0.75
        else
            usr << "You don't have enough energy stored to digest! ([MinActivation] stored energy required)])"

/obj/Skills/Buffs/SlotlessBuffs/Sin/Gluttony/Consumption
    Cooldown = 120
    var/MinActivation = 50
    StableHeal = 1
    proc/canActivate(mob/p)
        if(p.SpecialBuff)
            var/obj/Skills/Buffs/SpecialBuffs/Sin/Gluttony/gluttonyBuff = p.SpecialBuff
            if(gluttonyBuff.gluttonStorage > 0)
                return 1
            else
                return 0
    adjust(mob/p)
        passives = list("Gluttony" = round(p.Potential/100,0.5), "ManaSteal" = p.Potential/4, "EnergySteal" = p.Potential/4, "PureReduction" = p.Potential/25, "LifeSteal" = p.Potential/8)
        var/baseHeal = p.Potential/20
        var/missingHealth = abs(p.Health - 100)
        var/boons = 1 + ((p.SpecialBuff:anAcquiredTaste / 20) + (p.SpecialBuff:gluttonStorage/p.SpecialBuff:maxGluttonStorage) )
        var/perMissing = 0.008
        TimerLimit = 20 + (p.Potential/4)
        HealthHeal = (baseHeal + (missingHealth * perMissing * boons)) / (20 + (p.Potential/4))
        MinActivation = 50 + p.Potential
        Cooldown = 360 - (p.Potential*2)

    verb/Consumption()
        set category = "Skills"
        if(canActivate(usr) && usr.SpecialBuff:gluttonStorage >= MinActivation)
            if(!usr.BuffOn(src))
                adjust(usr)
            else
                usr.SpecialBuff:gluttonStorage -= usr.SpecialBuff:gluttonStorage*0.75
            Trigger(usr)
            if(usr.BuffOn(src))
                var/found = 0
                var/obj/Skills/AutoHit/Sin/Gluttony/Consumption_Aura/consumptionAura
                for(var/obj/Skills/AutoHit/Sin/Gluttony/Consumption_Aura/ca in usr)
                    if(ca)
                        consumptionAura = ca
                        consumptionAura.Rounds = TimerLimit
                        consumptionAura.DamageMult = ((usr.SpecialBuff:gluttonStorage*0.5)/5) / TimerLimit
                        found = 1
                if(!found)
                    consumptionAura = new(TimerLimit, usr.SpecialBuff:gluttonStorage*0.5)
                    usr.AddSkill(consumptionAura)
                usr.Activate(consumptionAura)
        else
            usr << "You don't have enough energy stored to consume! ([MinActivation] stored energy required)])"



/obj/Skills/AutoHit/Sin/Gluttony/Consumption_Aura
    New(timer, value)
        if(timer && value)
            Rounds = timer
            DamageMult = (value/15)/Rounds
        ..()
    Area="Circle"
    StrOffense = 1
    ForOffense = 1
    Cooldown = 4
    Size=2
    IconX=-8
    IconY=-8
    Instinct=1
    ActiveMessage="starts to consume the very reality around themselves!"


/obj/Skills/AutoHit/Sin/Gluttony/Regurgitate
    Area="Arc"
    Distance = 3
    TurfErupt = 1
    WindupMessage = "starts to heave..."
    ActiveMessage = "releases a torrent of stored energy!"
    Cooldown = 15
    StrOffense = 1
    ForOffense = 1
    DamageMult = 5
    adjust(mob/p)
        var/bigValue = p.SpecialBuff:gluttonStorage*0.03
        SoulFire = bigValue
        Scorching = bigValue * 4
        Shearing = bigValue * 4
        Crippling = bigValue * 4
        DamageMult = (p.Potential/10) + (p.SpecialBuff:gluttonStorage*0.025)
    proc/canActivate(mob/p)
        if(p.SpecialBuff)
            var/obj/Skills/Buffs/SpecialBuffs/Sin/Gluttony/gluttonyBuff = p.SpecialBuff
            if(gluttonyBuff.gluttonStorage > 0)
                return 1
            else
                return 0
    verb/Regurgitate()
        set category = "Skills"
        if(cooldown_remaining)
            usr << "You can't regurgitate yet!"
            return
        if(canActivate(usr))
            adjust(usr)
            usr.SpecialBuff:gluttonStorage -= usr.SpecialBuff:gluttonStorage*0.1
            usr.Activate(src)
        else
            usr << "You don't have enough energy stored to regurgitate! "







/obj/Skills/Buffs/SpecialBuffs/Sin/Gluttony/proc/eatEnergies(val)
    if(gluttonStorage + val > maxGluttonStorage)
        gluttonStorage = maxGluttonStorage
    else
        gluttonStorage += val
    //TODO add a hud effect for this