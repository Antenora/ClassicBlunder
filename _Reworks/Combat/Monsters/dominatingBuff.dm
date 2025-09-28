/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dominating
    Warping=4
    Steady=1
    HotHundred=1
    TimerLimit=2
    ClientTint=1
    Cooldown=20
    PhysicalHitsLimit = 0
    adjust(mob/p)
        var/asc = p.passive_handler.Get("HellRisen") * 4
        TimerLimit = 3 + (asc/2)
        Cooldown = 10 - (asc*2)
        Shattering = 5 + (asc*2.5)
        Steady = clamp(asc/2, 0.5, 2)
        PureDamage = 1 + (asc/2)
        passives = list("Shattering" = Shattering, "Steady" = Steady, "PureDamage" = PureDamage, "HotHundred" = 1, "Warping" = 4)