/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/HalfSaiyan/Hidden_Potential
    NeedsHealth=10
    TooMuchHealth=15
    AngerMult=1.2
    TextColor=rgb(255, 0, 0)
    Cooldown=-1
    ActiveMessage="unleashes the anger they keep locked in a cage!"
    OffMessage="calms their Saiyan rage..."

    adjust(mob/p)
        var/asc = p.SaiyanNum
        var/updog = p.UnderdogNum
        NeedsHealth = clamp(25 + ((asc * 2.5)+(updog*5)), 10, 40)
        TooMuchHealth = clamp(35 + ((asc * 2.5)+(updog*5)), 15, 90)
        AngerMult = 1.2 + (asc*0.2)
        passives = list(  "UnderDog" =1  + (2 * asc),"ZenkaiPower" = 0.25)


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

