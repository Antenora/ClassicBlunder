
/*

Summon skill
    var
        cooldown : cooldown of the skill
        contractor : the name + key of the person contracted (used for summoning)
    proc
        summon : summons the person
        THIS cant be used if they have a contractor

            this will grab a random tier based on their investment in summoning
            the higher the investment, the more likely their tier will go up, they always have a chance to summon a lower tiered perso
            in the case that there are none of that tier online, it will go to the next until they eventually get somebody (subject to change)
            when this happens the summon will get summoned and their return time will be set to the summon return time
            from here it is up to roleplay for them to conduct what the contract will be if any before the timer expires (stopped by rp mode), they must then sign it and make it

        summon contractor : summons the person who you made a contract with
            this will alert the summonee that they are requested to be summoned, they will have an option to accept it and the summoner must give a reason
            by default clauses state that faulty summons will be liable to damages being paid by the summon forcibly, only through proper communication can this clause state that a fight is required
            there is no (offical) way to remove the clause in place to ensure the summoned party is not summoned for the wrong reasons


        set contractor : sets the contractor

        get contractor : gets the contractor


*/



/mob/Admin3/verb/changeMaxSummon(obj/Skills/Utility/Summon_Entity/se in world)
    set name = "Change Max Summon"
    if(istype(se, /obj/Skills/Devils_Deal))
        usr << "What would you like to change the max summon to?"
        var/input = input(usr, "Enter a number.") as num
        if(input > 0)
            se.maxSummons = input
            usr << "You have changed the max summon to [input]."
        else
            usr << "You must enter a number."




/obj/Skills/Utility/Summon_Entity
    desc = "Summon an entity from a realm far away!"
    var/timesSummoned = 0
    var/maxSummons = 1

/obj/Skills/Utility/Summon_Entity/var/actualCoolDown = 0
/obj/Skills/Utility/Summon_Entity/var/list/contractor = list()

/obj/Skills/Utility/Summon_Entity/proc/init(mob/p)
    contractor[p.key] = list(p.name, p.EnergySignature)

/obj/Skills/Utility/Summon_Entity/proc/addContractor(mob/p)
    contractor[p.key] = list(p.name, p.EnergySignature)

/obj/Skills/Utility/Summon_Entity/proc/removeContractor(mob/p)
    for(var/contract in contractor)
        if(contract == p.key)
            contractor.Remove(contract)



/obj/Skills/Utility/Summon_Entity/verb/Summon_Entity()
    set category="Utility"
    if(src.Using)
        return
    if(!usr.Move_Requirements()||usr.KO)
        return
    if(world.realtime<actualCoolDown)
        usr << "It's too soon to use this! ([round((src.actualCoolDown-world.realtime)/Hour(1), 0.1)] hours)"
        return
    src.Using=1
    usr << "You begin to summon an entity from a far away realm!"
    summon(usr)




/obj/Skills/Utility/Summon_Entity/proc/getSummonTier(mob/p)
    var/summoningInvestment = p.SummoningMagicUnlocked // max being 4
    var/summoningTier = 1 // max being 5
    var/list/chances = list(45, 30, 15, 9, 1)
// 1 = 50% chance, 2 = 20% chance, 3 = 10% chance, 4 = 9% chance, 5 = 1% chance
// increase lowest tier chance by 1% per 2 investment, and every one above increase by 2% more than 1 until 2 which then it will go down by 5% each 2 invested
    if(summoningInvestment >= 2)
        chances[5] += round(1.5 * (summoningInvestment / 2),1)
        chances[4] += round(2.5 * (summoningInvestment / 2),1)
        chances[3] += round(3 * (summoningInvestment / 2),1)
        chances[2] -= round(2 * (summoningInvestment / 2),1)
        chances[1] -= round(5 * (summoningInvestment / 2),1)
    p<<{"You currently have.... T1: [chances[1]], T2: [chances[2]], T3: [chances[3]], T4: [chances[4]], T5: [chances[5]]"}
    var/roll = rand(1, 100)
    p<<"You rolled a [roll]!"
    // 100-50 = 1, 49-30 = 2, 29-20 = 3, 19-10 = 4, 9-1 = 5
    if(roll >= chances[1])
        summoningTier = 1
    else if(roll >= chances[2])
        summoningTier = 2
    else if(roll >= chances[3])
        summoningTier = 3
    else if(roll >= chances[4])
        summoningTier = 4
    else if(roll >= chances[5])
        summoningTier = 5
    else
        summoningTier = 1
    return summoningTier

/obj/Skills/Utility/Summon_Entity/proc/summon(mob/p)
    var/orgSummonTier = getSummonTier(p)
    var/summonTier = orgSummonTier
    p << "You are preparing to summon a tier [summonTier] (or less) entity!"
    // we know what tier we want to summon, now we need to find somebody of that tier
    src.Using=0




// /obj/Skills/Utility/Summon_Entity/proc/summon(mob/p)
//     var/orgSummonTier = getSummonTier(p)
//     var/summonTier = orgSummonTier
//     p << "You are preparing to summon a tier [summonTier] (or less) entity!"
//     // we know what tier we want to summon, now we need to find somebody of that tier
//     var/list/summonList = list()
//     var/list/mob/newSummonList = list()
//     // for(var/mob/m in players)
//     //     if(!m.client) continue
//     //     if(m.Summonable && !m.CurrentlySummoned)
//     //         summonList += m
//     // lets just get the list first
//     var/mob/summonee = null
//     // var/didntFind = 0
//     // var/extraTime = 30 + (120/p.SummoningMagicUnlocked)
//     // while(summonee == null)
//     //     for(var/mob/m in summonList)
//     //         if(m.SummonTier == summonTier)
//     //             newSummonList += m
//     //     if(newSummonList.len)
//     //         summonee = pick(newSummonList)
//     //         didntFind = 0
//     //         break
//     //     else
//     //         summonTier -= 1
//     //         if(summonTier < 0)
//     //             didntFind = 1
//     //             break
//     //     sleep(10)
//     // if(didntFind)
//     //     p << "You failed to summon anybody, you will have to try again later."
//     //     actualCoolDown = world.realtime + (1 MINUTES * extraTime) // 1 hour
//     //     src.Using=0
//     //     return
//     // else
//     //     var/obj/Skills/Devils_Deal/dd = summonee.findDevilsDeal()
//     //     if(dd)
//     //         actualCoolDown = world.realtime + (1 MINUTES * extraTime) // 1 hour
//     //         getOverHere(dd, summonee, p)
//     //         p.TakeManaCapacity(20)
//     src.Using=0


/obj/Skills/Utility/Summon_Entity/proc/summonContractor()
    var/list/listofSummon = list()
    for(var/x in contractor)
        listofSummon += contractor[x][1]
    var/choice = input(usr, "Who would you like to summon?", "Summon") in listofSummon + "Cancel"
    for(var/mob/m in players)
        if(m.name == choice)
            var/obj/Skills/Devils_Deal/dd = m.findDevilsDeal()
            if(dd)
                getOverHere(dd, m, usr, 1)




/obj/Skills/Utility/Summon_Entity/proc/getOverHere(obj/Skills/Devils_Deal/dd, mob/p, mob/summoner, alertThem = FALSE)
    var/extraTime = 30  + (15  * summoner.SummoningMagicUnlocked) + (15  * p.SummonTier)
    if(alertThem == TRUE)
        if(timesSummoned >= maxSummons)
            summoner << "You have already summoned [p] the maximum amount of times!"
            Using=0
            return
        var/yesno = input(p, "You have been summoned by your contractor: [summoner.name]!.Do you accept?") in list("Yes","No")
        if(yesno == "No")
            summoner << "[p] has declined your summon!"
            Using=0
            return
        else
            summoner << "[p] has accepted your summon!"
            dd.setOrgXYZ(p.x, p.y, p.z)
            extraTime = 8 * 60 + (30  * summoner.SummoningMagicUnlocked ) + (30 * p.SummonTier)
            dd.setSummonReturnTime(0)
            dd.setHomeTime(extraTime) // 10 mins of summon time before they go back
            p.loc = locate(summoner.x, summoner.y-1,summoner.z)
            p.CurrentlySummoned = TRUE
            summoner << "You have summoned [p] to you!"
            spawn()
            LightningBolt(p)
            OMsg(summoner, "[p] has been summoned by \[PLAYER\] [summoner] for aprox: [extraTime / 60] Minutes.")
            timesSummoned++
            if(timesSummoned >= maxSummons)
                timesSummoned = maxSummons
                summoner << "You have summoned [p] the maximum amount of times!"
                summoner << "Contact an ADMINISTRATOR."
            Using=0

    else
        dd.setOrgXYZ(p.x, p.y, p.z)
        dd.setSummonReturnTime(0)
        dd.setHomeTime(60 + extraTime) // 1 min
        p.loc = locate(summoner.x, summoner.y-1,summoner.z)
        p.CurrentlySummoned = TRUE
        OMsg(summoner, "[p] has been summoned by \[PLAYER\] [summoner] for aprox: [(600 + extraTime )/ 60] Minutes.")
        spawn()
            LightningBolt(p)

/mob/proc/findDevilsDeal()
    for(var/obj/Skills/Devils_Deal/dd in src)
        return dd

/mob/proc/findSummonSkill()
    for(var/obj/Skills/Utility/Summon_Entity/skill in src)
        return skill
