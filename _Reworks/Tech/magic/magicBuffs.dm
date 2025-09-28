/obj/Skills/Buffs/SlotlessBuffs/Skating
    BuffName = "Skating"
    TimerLimit = 0
    Godspeed = 1.5
    passives = list("Godspeed" = 2)
    Copyable = 0
    Cooldown = 0
    ActiveMessage = "starts skating on a magical skateboard, lol."
    OffMessage = "stops skating."

/obj/Skills/Buffs/SlotlessBuffs/Surfing
    BuffName = "Surfing"
    TimerLimit = 0
    Godspeed = 1
    WaterWalk = 1
    passives = list("WaterWalk" = 1, "Godspeed" = 1)
    Copyable = 0
    Cooldown = 0
    ActiveMessage = "starts surfing on a magical surfboard, lol."
    OffMessage = "stops surfing."

/obj/Skills/Buffs/var/CounterSpell

/obj/Skills/Buffs/SlotlessBuffs/Magic/Counterspell
    CounterSpell = 1
    BuffName = "Counterspell"
    ManaCost = 5
    TimerLimit = 10
    IconLock = 'SparklePurple.dmi'
    Cooldown = 60
    ActiveMessage = "starts channeling arcane energy."
    OffMessage = "stops channeling arcane energy."
    verb/Counterspell()
        set name = "Counter Spell"
        set category = "Skills"
        if(usr.CheckSlotless("Counterspell"))
            usr << "You are already using counterspell."
            return
        KenShockwave(src, icon='KenShockwaveLegend.dmi', Size=0.5, Blend=2, Time=4)
        Trigger(usr)

