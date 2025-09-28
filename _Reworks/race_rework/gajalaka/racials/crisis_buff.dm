/racials/var/GOLD_DRAGON_FORMULA = 1000000
/racials/var/GAJALAKA_ACOLYTE = 0.8
/racials/var/GAJALAKA_SCHOLAR = 1
/racials/var/GAJALAKA_HEART = 1.5
/racials/var/GAJACASHDROPDIVISOR = 300
/racials/var/CASHLEAKREMOVES = FALSE
/racials/var/GAJALEAKTHRESHOLD = 2

/obj/Skills/Buffs/SlotlessBuffs/Autonomous
    proc/gaja_calcs(mob/p, racial_boon, perAscBoon)
        var/asc = p.AscensionsAcquired
        var/money
        for(var/obj/Money/m in p.contents)
            money = m.Level
        var/baseMultMod = 1 + max(0,money/(glob.racials.GOLD_DRAGON_FORMULA * racial_boon))
        var/cashLeak = 0
        if(baseMultMod >= glob.racials.GAJALEAKTHRESHOLD)
            cashLeak = 1
        passives = list("PureDamage" = asc * perAscBoon + (baseMultMod), "PureReduction" =  asc * perAscBoon + (baseMultMod), "LeakCash" = cashLeak)
        PowerMult = baseMultMod
        SpdMult = baseMultMod
        StrMult = baseMultMod
        OffMult = baseMultMod
        DefMult = baseMultMod
        EndMult = baseMultMod
        ForMult = baseMultMod

    Heart_of_The_Acolyte // worships money and the mountain
        TextColor=rgb(95,60,95)
        NeedsHealth = 50
        TooMuchHealth = 75
        HealthThreshold = 0.001
        ActiveMessage = "gains the faint glitter of gold in their aura!"
        OffMessage = "loses some of that goblin greed..."
        Cooldown = -1
        passives = list("PureDamage" = 1, "PureReduction" = 1)
        adjust(mob/p)
            if(altered) return
            gaja_calcs(p, glob.racials.GAJALAKA_ACOLYTE, 0.2)
    Heart_of_The_Rebel
        TextColor=rgb(133, 69, 0)
        NeedsHealth = 50
        TooMuchHealth = 75
        HealthThreshold = 0.001
        ActiveMessage = "becomes the fang..."
        OffMessage = "loses their edge..."
        Cooldown = -1
        passives = list("Rebel Heart" = 1) // scaling mults and pure dmg/red based on health lost
        AllOutAttack = 1
        IconLock='Double Slaughter.dmi'
        LockX = -2
        LockY = -2
        FatigueDrain = 0.0008
        adjust(mob/p)
            passives["Rebel Heart"] = 1+p.AscensionsAcquired
            passives["ShonenPower"] = (1+p.AscensionsAcquired)/4
            passives["SwordPunching"] = 1
            FatigueDrain = 0.0008 * (1+p.AscensionsAcquired)
    

    Heart_of_The_Noble
        TextColor=rgb(75, 195, 255)
        NeedsHealth = 50
        TooMuchHealth = 75
        HealthThreshold = 0.001
        ActiveMessage = "summons a massive burst of mana!"
        OffMessage = "loses their excessive mana..."
        Cooldown = -1
        passives = list()
        adjust(mob/p)
            if(altered) return
            gaja_calcs(p, glob.racials.GAJALAKA_SCHOLAR, 0.35)
            var/asc = p.AscensionsAcquired
            passives = list("MasterfulCasting" = 1, "QuickCast" = max(1+asc,3), "MovingCharge" = 1, \
                "TechniqueMastery" = 1+asc, "DualCast" = clamp(4-asc,0,1), "ManaGeneration" = 1+asc)

    Heart_of_Liberation
        TextColor=rgb(207, 172, 0)
        NeedsHealth = 50
        TooMuchHealth = 75
        HealthThreshold = 0.001
        ActiveMessage = "'s heart beats like a drum!'"
        OffMessage = "'s heart calms down...'"
        Cooldown = -1
        passives = list()
        IconLock='Skull Kid Hat.dmi'
        adjust(mob/p)
            if(altered) return
            gaja_calcs(p, glob.racials.GAJALAKA_HEART, 0.5)
            var/asc = p.AscensionsAcquired
            passives = list("KillerInstinct" = 0.05 * asc, "CursedWounds" = 1, "HellPower" = 0.1 * asc )


    
