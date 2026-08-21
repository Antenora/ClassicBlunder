/mob/proc/isBlackflame()
    if(!isRace(WILDER)) return 0;
    if(Class != "Blackflame") return 0;
    return 1;

/obj/Skills/AutoHit/Wilder
    Blackflame_Breath
        Area = "Wave";
        DamageMult = 1.5;
        Rounds = 3;
        Slow = 0.1;
        TurfErupt = 1;
        TurfShift = 'BlackflameTrail.dmi';
        TurfShiftDuration = 5;
        Scorching = 5;
        Toxic = 5;
        FrenzyDebuff = 5;
        Stunner = 1;
        ComboMaster = 1;
        //Notably does not have grab master
        //Do not give it grab master
        //🔫
        adjust(mob/p)
            //Wilders only have 3 ascensions
            var/asc = p.AscensionsAcquired;
            DamageMult = 1.5 + (0.5 * asc);
            Rounds = 3 + asc;
        verb/Blackflame_Breath()
            set category = "Skills"
            if(!Using) adjust(usr);
            usr.Activate(src);
            
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wilder/
    Burning_Cloak
        NeedsHealth = 25
        FatigueThreshold = 80;
        Cooldown = -1
        SpdMult = 1.5;
        OffMult = 1.5;
        DefMult = 0.5;
        ActiveMessage = "blends fire and destruction for overwhelming offensive prowess!"
        adjust(mob/p)
            var/asc = p.AscensionsAcquired;
            
            NeedsHealth = min(50, 25 + (9 * asc));
            TooMuchHealth = (NeedsHealth + 25);
            FatigueThreshold = 80 - (10 * asc);

            WoundDrain = 0.25 - (0.25 / 3 * asc);
            FatigueDrain = 0.5 - (0.5 / 3 * asc);
            if(FatigueDrain <= 0) FatigueThreshold = 0;
            else FatigueThreshold = 80;

            strAdd = 0.5 + (1/3*asc);
            forAdd = 0.5 + (1/3*asc);

            passives = list("Relentlessness" = 1, "Shadowbringer" = 1, "FrenzyCarrier" = 1);
            passives["Wrathful Tenacity"] = 0.2 + (0.1 * asc);
            passives["DemonicDurability"] = 2 + asc;
            //passives were kill: angeradaptiveforce
            passives["HellPower"] = 0.2 + (0.1 * asc);
            passives["Adrenaline"] = asc * 2;
        Trigger(mob/User, Override)
            . = ..()
            if(!User.BuffOn(src))
                adjust(User)
