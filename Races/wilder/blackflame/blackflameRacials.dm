/mob/proc/isBlackflame()
    if(!isRace(WILDER)) return 0;
    if(Class != "Blackflame") return 0;
    return 1;

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Undying_Rage
    TooMuchHealth = 35
    NeedsHealth = 10
    passives = list("Undying Rage" = 1)
    Cooldown = -1
    SpdMult=1.5
    DefMult=0.5
    EndMult=0.9
    ActiveMessage = "is too angry to die!"
    adjust(mob/p)
        TooMuchHealth = 35
        TimerLimit = 10 + (glob.racials.UNDYINGRAGE_DURATION * (p.AscensionsAcquired))
        var/wT = 1.5 - p.passive_handler["Wrathful Tenacity"]
        passives = list("Undying Rage" = 1, "Fury" = 1 + p.AscensionsAcquired, "Godspeed" = 3, "Relentlessness" = 1, "ShearImmunity" = 1, "Adrenaline" = 3, "LifeSteal" = 50 + (25 * p.AscensionsAcquired), \
                        "Enrage" = p.AscensionsAcquired, "Rage" = p.AscensionsAcquired, "Wrathful Tenacity" = wT) // 150% of str as end
    Trigger(mob/User, Override)
        . = ..()
        if(!User.BuffOn(src))
            adjust(User)