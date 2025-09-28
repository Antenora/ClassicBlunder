/mob/proc/setAscension(num)
    AscensionsAcquired = num


// should hell power and hellspawn be different?
// DemonicInfluence should be hellspawn's var
/*
DemonicInfluence
    lesser hell power to a certain extent
    give hellspawn a buff that they can trigger once they get enough demonic influence
    otherwise, set it to be low health and to function as symbiote

    Demonic Influence should turn you evil for one 
        maybe while out of buff the demonic influence is like its own thing, but in buff, it converts demonic influence to hell power

Classes:
    Brawler - End/Str/Def

    Hunter - For/Str/Off 

    Duelist - Str/Spd/Off

Demon Type:
    Blademaster -
        Buff revolves around making a sword, or empowering a sword
    Unbreakable -
        Buff revolves around making armor, or empowering armor
    Fallen -
        revolves around gaining more demonic influence / hell power
    Beserker - 
        revovles around low health, high damage
    Sage -
        focuses around empowering spirtual damage, ki, magic etc
            

Per Asc
    Hellspawns gain stats based on class
    Start with high Desp (formerly humans)
    Gain DemonicInfluence and lose Desp
    we want to somehow make their gain of demonicinfluence better than what infernal gets at asc2+ (0.25 hell power)
    they gain technique mastery, intimidation and anger lesser but almos tas much as human
*/

/* Demonic Influence 

Hard Style ( more injuries ), Str/For mult = 4th total ticks, maki ticked
Sword Punching, Increase Intim the higher health you are, Increase power the higher health you are

*/




/mob/proc/setUpHellSpawn()
        passive_handler.Set("Desperation", 6)
        passive_handler.Set("DemonicInfluence", 0.1)
        passive_handler.Set("TechniqueMastery", 1)
        Intimidation = 10
        IntimidationMult = 2
        NewAnger(1.4)
        AngerPoint=50
        ascendHellSpawnClass()
        // setUpHellSpawnDemonType()


/mob/proc/ascendHellSpawnClass()
    if(!Class)
        var/inpu = input(src, "What class would you like to be? (Brawler End/Str/Def, Hunter For/Str/Off, Duelist Str/Off/Def)") in list("Brawler", "Hunter", "Duelist")
        Class = inpu
    var/bonus = AscensionsAcquired <= 3 ? 0.15 : 0.45
    StrAscension += round(bonus * 1.5,0.01)
    switch(Class)
        if("Brawler")
            EndAscension += 0.15 + bonus
            StrAscension += 0.15 + bonus
            DefAscension += 0.15 + bonus
        if("Hunter")
            ForAscension += 0.15 + bonus
            StrAscension += 0.15 + bonus
            OffAscension += 0.15 + bonus
        if("Duelist")
            StrAscension += 0.15 + bonus
            OffAscension += 0.15 + bonus
            DefAscension += 0.15 + bonus



/mob/proc/HellspawnAscension1()
    setAscension(1)
    ascendHellSpawnClass()
    NewAnger(1.5)
    Intimidation += 10 // 20 total, 40 after mult
    passive_handler.Decrease("Desperation", 1) // 5
    passive_handler.Increase("DemonicInfluence", 0.1) // 0.2
    passive_handler.Increase("TechniqueMastery", 2.5) // 3.5
    // hellspawn are hell powered humans, half demons if u will
    

/mob/proc/HellspawnAscension2()
    setAscension(2)
    ascendHellSpawnClass()
    NewAnger(1.6)
    Intimidation += 20 // 40 total, 80 after mult
    passive_handler.Decrease("Desperation", 2.5) // 2.5
    passive_handler.Increase("DemonicInfluence", 0.2) // 0.4
    passive_handler.Increase("TechniqueMastery", 2.5) // 6


/mob/proc/HellspawnAscension3()
    setAscension(3)
    ascendHellSpawnClass()
    NewAnger(1.8)
    Intimidation += 55 // 100 total, 200 after mult
    passive_handler.Decrease("Desperation", 1) // 1.5
    passive_handler.Increase("DemonicInfluence", 0.2) // 0.6
    passive_handler.Increase("TechniqueMastery", 2.5) // 8.5


/mob/proc/HellspawnAscension4()
    setAscension(4)
    ascendHellSpawnClass()
    NewAnger(2)
    Intimidation += 100 // 200 total, 400 after mult
    passive_handler.Decrease("Desperation", 1) // 0.5
    passive_handler.Increase("DemonicInfluence", 0.2) // 0.8
    passive_handler.Increase("TechniqueMastery", 2.5) // 11

/mob/proc/HellspawnAscension5()
    setAscension(5)
    ascendHellSpawnClass()
    NewAnger(2.5)
    Intimidation += 200 // 400 total, 800 after mult
    passive_handler.Decrease("Desperation", 0.5) // 
    passive_handler.Increase("DemonicInfluence", 0.2) // 1
    passive_handler.Increase("HellPower", 1)


// i think the intim is a joke at this point