/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/HalfSaiyan/Hidden_Potential
    NeedsHealth=10
    TooMuchHealth=15
    AngerMult=1.2
    TextColor=rgb(255, 0, 0)
    Cooldown=-1
    ActiveMessage="unleashes the anger they keep locked in a cage!"
    OffMessage="calms their yasai rage..."

    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        NeedsHealth = clamp(10 + (asc * 5), 10, 25)
        TooMuchHealth = clamp(15 + (asc * 2.5), 15, 50)
        AngerMult = 1.2 + (asc*0.2)
        passives = list(  "UnderDog" =1  + (2 * asc))


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/HalfSaiyan/Saiyan_Pride
    NeedsHealth=50
    TooMuchHealth=75
    TextColor=rgb(2, 83, 183)
    Cooldown=-1
    ActiveMessage="steels themselves, channeling the pride of their heritage."
    OffMessage="..."

    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        passives = list( "Persistence" =  0.5 + (0.5 * asc))

