/obj/Skills/Buffs/var/coolerAfterImages = 0


/obj/Skills/Buffs/SlotlessBuffs/CyberPunk/adjust(mob/p)

/obj/Skills/Buffs/SlotlessBuffs/CyberPunk/Sandevistan
    SBuffNeeded = "Ripper Mode"
    ClientTint = 1
    // essentially turn ur screen to grey, enable afterimages, some health drain and go hard
    // scales with pot of course
    passives = list("CoolerAfterImages" = 4)
    TimerLimit = 10
    Cooldown = 60
    HealthDrain = 0.01
    adjust(mob/p)
        if(altered) return
        var/totalPotRounded = round(glob.progress.totalPotentialToDate,10) // get the total pot
        var/totalPot = glob.progress.totalPotentialToDate
        // 50 = full strength
        // ideas: warping and such later, crit chance, crit daamge scaling, health drain while active
        if(totalPotRounded >= 50)
            // giga mode
            Godspeed = totalPotRounded/25
            CriticalChance = round(totalPotRounded/5,0.5)
            CriticalDamage = round(totalPot/100, 0.01)
            Crippling = totalPotRounded/10
            SlayerMod = totalPotRounded/12.5 // lol 1 pure damage at 100
            Warp = totalPotRounded/25
            passives = list("CoolerAfterImages" = 3, "Godspeed" = Godspeed, "CriticalChance" = CriticalChance, \
            "CriticalDamage" = CriticalDamage, "Crippling" = Crippling, "SlayerMod" = SlayerMod,\
            "Warp" = Warp, "CursedWounds" = 1, "MortalStrike" = totalPotRounded/250, "FavoredPrey" = "Races")
            Cooldown = 120 - (totalPotRounded)
            TimerLimit = 10 + (totalPotRounded/10)
            if(p.SpecialBuff?:sandevistanUsages >= 0)
                var/usages = p.SpecialBuff?:sandevistanUsages
                HealthDrain = 0.0005 + (0.005 * usages)
                HealthCost = (usages >= 3 ? 1.5 * usages : usages) / 5
                Cooldown = usages >= 3 ? Cooldown + (usages * 5) : Cooldown
        else
            Godspeed = 1
            CriticalChance = round(totalPotRounded/10,0.5)
            CriticalDamage =  round(totalPot/150, 0.01)
            Crippling = totalPotRounded/10
            passives = list("CoolerAfterImages" = 2, "Godspeed" = Godspeed, "CriticalChance" = CriticalChance, \
            "CriticalDamage" = CriticalDamage, "Crippling" = Crippling)
            Cooldown = 60 - (totalPotRounded/4)
            TimerLimit = 13 + (totalPotRounded/5)
            if(p.SpecialBuff?:sandevistanUsages >= 0)
                var/usages = p?:SpecialBuff.sandevistanUsages
                HealthDrain = 0.0005 + (0.0005 * usages)
                HealthCost = (usages >= 3 ? 0.5 * usages : usages) / 5
                Cooldown = usages >= 3 ? Cooldown + (usages * 10) : Cooldown

    verb/Sandevistan()
        set category="Skills"
        adjust(usr)
        Trigger(usr)
        if(usr?.SlotlessBuffs["Sandevistan"])
            usr.SpecialBuff:sandevistanUsages++
            usr<<"Your current Sandevistan usage is: [usr.SpecialBuff:sandevistanUsages]"
        if(usr.SlotlessBuffs["Sandevistan"])
            greyscaleScreen(usr)
    proc/greyscaleScreen(mob/p)
        animate(p.client, color = list(0.7,0.7,0.71, 0.79,0.79,0.8, 0.31,0.31,0.32, 0,0,0), time = 3)


/obj/Skills/Buffs/SlotlessBuffs/CyberPunk/GorillaArms
    SBuffNeeded = "Armstrong Augmentation"
    // essentially turn ur screen to grey, enable afterimages, some health drain and go hard
    // scales with pot of course
    TimerLimit = 30
    Cooldown = 90
    ManaCost = 5
    adjust(mob/p)
        if(altered) return
        var/totalPotRounded = round(glob.progress.totalPotentialToDate,10) // get the total pot
        var/totalPot = glob.progress.totalPotentialToDate
        if(totalPotRounded >= 50)
            KillerInstinct = round(totalPot/200,0.01)
            HeavyHitter = round(totalPotRounded/25, 0.5)
            HardStyle = round(totalPotRounded/25, 0.5)
            Steady = round(totalPotRounded/25, 0.5)
            Shattering = round(totalPotRounded/10, 0.5)
            passives = list("KillerInstinct" = KillerInstinct, "HeavyHitter" = HeavyHitter, "HardStyle" = HardStyle, \
            "Steady" = Steady, "Shattering" = Shattering)
            TimerLimit = 30 + (totalPotRounded/5)
            Cooldown = 90 - (totalPotRounded/5)
        else
            HeavyHitter = round(totalPotRounded/50, 0.5)
            HardStyle = round(totalPotRounded/50, 0.5)
            Steady = round(totalPotRounded/25, 0.5)
            Shattering = round(totalPotRounded/10, 0.5)
            passives = list("HeavyHitter" = HeavyHitter, "HardStyle" = HardStyle, \
            "Steady" = Steady, "Shattering" = Shattering)
            TimerLimit = 30 + (totalPotRounded/10)
    verb/Gorilla_Arms()
        set category="Skills"
        adjust(usr)
        Trigger(usr)
            