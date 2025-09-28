/*
The intention of absorb is to absorb the person when they are KO'd
 and apply a minor tax
As well as a wound / maiming to the person who absorbed the person
When absorbing people will be able to take passives from the target
and there's a limit to how many they can have
Super can absorb more and have more passives (stacking mayhaps?)
Only issue i see with this is we either tie it to a slotless buff
making it a style will cause issues.
*/


majinAbsorb
    var/list/absorbed = list() // list of absorbed people
    var/list/passives = list() // passives that are attacked to buffs
    var/list/racialPassives = list() // passives attached to racials
    var/absorbLimit = 2
    var/absorbCount = 0
    var/absorbTax = 5 // 3% tax
    var/absorbPassiveTickLimit = 0.5
    var/tickPerAbsorb = 0.25
    // Some passives work differently and will get a boost, also some races provide more
majinAbsorb/proc/updateVariables(mob/p, clear = FALSE)
    var/Super = p.Class == "Super" ? TRUE : FALSE
    var/asc = p.AscensionsAcquired
    absorbLimit = MAJIN_ABSORB_LIMIT + (Super ? asc : floor(asc/2))
    absorbPassiveTickLimit = MAJIN_PASSIVE_LIMIT + ( (asc-1) * MAJIN_PASSIVE_LIMIT ) + (Super ? MAJIN_PASSIVE_LIMIT : 0)
    absorbTax = 3 + (MAJIN_ABSORB_TAX * asc)
    tickPerAbsorb = 0.25 + ((asc-1) * 0.1) + (Super ? 0.25 : 0)
    absorbCount = absorbed.len

#define BOOSTPASSIVES list("Piloting Prowess", "Intimidation")
#define NERFPASSIVES list("StealsStats", "HellPower","GodKi","SpiritPower", "BuffMastery", "Desperation", "DemonicDurability")
#define MAKEFULL list("EnhancedSmell", "EnhancedHearing")
#define NORMALBOOST 2.5
#define SHINJINBOOST 5


majinAbsorb/proc/addAbsorbee(mob/p)
    absorbed["[p.ckey]"] = p.ckey
    p<< "You feel a part of your powers get absorbed away!"

majinAbsorb/proc/nerfAbsorbee(mob/p)
    var/nerf = absorbTax / 100
    p.StrTax += nerf
    p.EndTax += nerf
    p.ForTax += nerf

majinAbsorb/proc/addRacialPassive(passiveName)
    if(passiveName in racialPassives)
        return
    racialPassives += passiveName

majinAbsorb/proc/adjustPassive(passiveName, race/race)
    if(race.name == "Shinjin")
        return SHINJINBOOST
    if(passiveName in BOOSTPASSIVES)
        return NORMALBOOST
    if(passiveName in NERFPASSIVES)
        return 0.75
    return 1

/mob/proc/getMajinRacials()
    . = list()
    switch(Class)
        if("Innocent")
            . += "DemonicDurability"
            . += "Blubber"
        if("Super")
            . += "Steady"
            . += "FluidForm"
        if("Unhinged")
            . += "UnhingedForm"
            . += "Adrenaline"
            . += "Hustle"
    var/newPickslist = list()
    if(length(majinPicks) > 0)
        for(var/pick in majinPicks)
            newPickslist = majinPicks["[pick]"]
    // make newpickslist into a list but split the string by a comma
    // so basically "Harness Evil,Brutality" becomes "Harness Evil" and "Brutality
    // then we can use the switch statement to add the passives
    newPickslist = splittext(newPickslist, ",")
    if(length(newPickslist)> 0)
        switch(newPickslist[1])
            if("Harness Evil")
                switch(newPickslist[2])
                    if("Brutality")
                        . += "Pursuer"
                        . += "UnhingedForm"
                    if("Both")
                        . += "Pursuer"
                        . += "UnhingedForm"
            if("Remain Consistent")
                switch(newPickslist[2])
                    if("Adaptability")
                        . += "Adaptation"
                        . += "Flicker"
                        . += "Huslte"
                        if(AscensionsAcquired > 2)
                            . += "StealsStats"
                    if("Consistency")
                        . += "Steady"
                        . += "DebuffResistance"
                        . += "StableBP"
                    if("Both")
                        . += "Steady"
                        . += "DebuffResistance"
                        . += "StableBP"
                        . += "Adaptation"
                        . += "Flicker"
                        . += "Huslte"
                        if(AscensionsAcquired > 2)
                            . += "StealsStats"
            if("Become Docile")
                switch(newPickslist[2])
                    if("Stability")
                        . += "VenomResistance"
                        . += "DebuffResistance"
                        . += "Juggernaut"
                    if("Peace")
                        . += "Flow"
                        . += "VoidField"
                    if("Both")
                        . += "VenomResistance"
                        . += "DebuffResistance"
                        . += "Juggernaut"
                        . += "Flow"
                        . += "VoidField"

proc/removeDuplicates(list/list1)
    var/list/newList = list()
    for(var/element in list1)
        if(element in newList)
            continue
        newList += element
    return newList



/mob/proc/getAllRacials()
    . = list()
    for(var/x in list("Majin", "Half Saiyan", "Saiyan", "Human", "Makyo", "Namekian", "Monster", "Shinjin", "Demon"))
        . += getRacialPassives(x)
    return .

/mob/proc/findAlteredVariables()
    for(var/x in getAllRacials())
        if(vars[x] > 0)
            src<<"You have an extra variable: [x], if you got this from absorb, you will need to get it removed and added back via an admin"
            // we could do it auto with a bit more digging, as a majin will have some of these passives, and they could have potentially absorbed more to have more than they already have
            if(passive_handler.Get(x))
                src << "You have an extra passive: [x], if you got this from absorb, you will need to get it removed and added back via an admin"

            for(var/mob/admin in world)
                if(admin.Admin)
                    admin << "[src] has an extra variable: [x], if they got this from absorb, you will need to get it removed and add it back"


/mob/proc/getRacialPassives(hardRace = FALSE)
    . = list()
    if(!hardRace)
        hardRace = race.type
    switch(hardRace)
        if(MAJIN)
            . = getMajinRacials()
        if("Half Saiyan")
        if(ELF)
            . += "Deicide"
            . += "TechniqueMastery"
            . += "Flow"
            . += "Unstoppable"
            . += "SwordPunching"
        if(SAIYAN)
            . += "Intimidation"
            . += "MovementMastery"
        if(HUMAN)
            . += "PilotingProwess"
            . += "Adrenaline"
            . += "DemonicDurability"
        if(MAKYO)
            . += "MovementMastery"
            . += "Intimidation"
        if(NAMEKIAN)
            . += "EnhancedHearing"
            . += "Intimidation"
            // Not sure what else
        if(BEASTMAN)
            . += "EnhancedSmell"
            . += "EnhancedHearing"
            . += "DemonicDurability"
        if(YOKAI)
            . += "EnhancedHearing"
            . += "TechniqueMastery"
            . += "MovementMastery"
        if(ELDRITCH)
            . += "SpaceWalk"
            . += "DebuffResistance"
            . += "VenomResistance"
            . += "SoulFire"
            . += "DeathField"
            . += "VoidField"
        if(DEMON)
            . += "CursedWounds"
            . += "DemonDurability"
            . += "HellPower"
        if(ELF)
            . += "Xenobiology"
            . += "Deicide"
            . += "TechniqueMastery"
        if(GAJALAKA)
            . += "CashCow"
            . += "Blubber"
        if(DRAGON)
            . += "Erosion"
            . += "SpiritHand"
            . += "Godspeed"
    . = removeDuplicates(.)


majinAbsorb/proc/doAbsorb(mob/absorber, mob/absorbee)
    updateVariables(absorber)
    if(length(absorbed) > 0)
        if(absorbed[absorbee.ckey] == absorbee.ckey)
            absorber << "You've already absorbed this person, absorb another person."
            return
    if(absorbCount >= absorbLimit)
        absorber << "You can't absorb any more passives, you've reached your limit"
        return
    var/list/racialPassives = absorbee.getRacialPassives()
    var/passiveInQuestion = input(absorber, "Which passive would you like to absorb?", "Absorb") in racialPassives
    var/maxGain
    var/maxPasssiveCanHave = absorbPassiveTickLimit * adjustPassive(passiveInQuestion, absorbee.race)

    var/absorbeePassiveTicks = absorbee.passive_handler.Get(passiveInQuestion)
    if(absorbeePassiveTicks > 0)
        maxGain = absorbeePassiveTicks
    else
        return // if they don't have the passive, we can't absorb it
    var/passiveticks = tickPerAbsorb
    passiveticks *= adjustPassive(passiveInQuestion, absorbee.race)
    var/existingPassive = absorber.passive_handler.Get(passiveInQuestion) ? absorber.passive_handler.Get(passiveInQuestion) : 0
    // now lets check how much the person absorbing can have
    if((existingPassive + passiveticks) >= maxPasssiveCanHave)
        passiveticks = maxPasssiveCanHave - existingPassive
    else
        if(existingPassive >= maxPasssiveCanHave)
            absorber << "You can not absorb any more of [passiveInQuestion]"
            return
        // make it the limit
    if(passiveticks > maxGain)
        passiveticks = maxGain
    if(existingPassive == maxGain)
        absorber << "You can not absorb any more of [passiveInQuestion]"
        return
    if((existingPassive + passiveticks) > maxGain)
        absorber << "You would exceed the passive limit, you can only absorb [maxGain] ticks of [passiveInQuestion]. Adjusting to [maxGain]"
        passiveticks = maxGain
        absorber.passive_handler.Set(passiveInQuestion, passiveticks)
    else
        absorber.passive_handler.Increase("[passiveInQuestion]", passiveticks)
    absorber << "You have absorbed [passiveInQuestion] from [absorbee] making your total [absorber.passive_handler.Get(passiveInQuestion)]]!"
    absorbCount++
    passives[passiveInQuestion] = passiveticks
    absorber.HealHealth(15)
    absorber.HealEnergy(15)
    addAbsorbee(absorbee)
    nerfAbsorbee(absorbee)
/mob/proc/absorbSomebody(mob/target)
    var/errorCodes = list("ERROR: CODE ERROR", "TRIED TO USE CURRENT TARGET BUT THERE IS NONE", \
    "TARGET IS SELF", "TARGET IS NOT KNOCKED OUT", "THAT TARGET IS METAL")
    if(!target)
        // let's check if its a code error and they're targeting them
        . = errorCodes[1]
        target = src.Target
        if(!target)
            . = errorCodes[2]
            src << .
        src << . // let's tell them what happened
    if(target == src)
        . = errorCodes[3]
        src << .
    if(!target.KO)
        . = errorCodes[4]
        src<< .
        return
    if(target.isRace(ANDROID))
        . = errorCodes[5]
        src << .
        return
    if(target.client.address == src.client.address || target.client.computer_id == src.client.computer_id )
        if(!soIgnore && target.client.computer_id != src.client.computer_id)
            . = "ERROR: TARGET IS YOU"
            src << .
            return
    if(majinAbsorb)
        majinAbsorb.doAbsorb(src, target)