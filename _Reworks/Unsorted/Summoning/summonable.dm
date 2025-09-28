/*
Summonable skill
    vars
        currentContractors = list() : list of contractors by name+key
        summonReturnTime : time before they return back to orgin
        orgX : x coord of summoning
        orgY : y coord of summoning
        orgZ : z coord of summoning

    functions
        return : returns the person
        getContractors : gets the contractors
        getSummonReturnTime : gets the summon return time
        getOrgXYZ : gets the orgin x,y,z
        addContractors : sets the contractors
        setSummonReturnTime : sets the summon return time
        setOrgXYZ : sets the orgin x,y,z
        retrieveContract : retrieves all unsigned contracts that belong to YOU (the summonable)
        makeContract : makes a contract item for the summonable
*/


/mob/Admin3/verb/lockSendBack(obj/Skills/Devils_Deal/dd in world)
    set name = "Lock Send Back"
    if(istype(dd, /obj/Skills/Devils_Deal))
        if(dd.dontIncrement)
            dd.dontIncrement = FALSE
            usr << "You have unlocked their return time."
        else
            dd.dontIncrement = TRUE
            usr << "You have locked their return time."


/obj/Skills/Devils_Deal
    name = "Devil's Deal"

/obj/Skills/Devils_Deal/var/list/currentContractors = list()
/obj/Skills/Devils_Deal/var/summonReturnTime = 0
/obj/Skills/Devils_Deal/var/goBackHomeTime = 0
/obj/Skills/Devils_Deal/var/dontIncrement = FALSE
/obj/Skills/Devils_Deal/var/orgX = 0
/obj/Skills/Devils_Deal/var/orgY = 0
/obj/Skills/Devils_Deal/var/orgZ = 0
/obj/Skills/Devils_Deal/var/tmp/lastUse = 0


/obj/Skills/Devils_Deal/verb/Make_Contract()
    set category = "Utility"
    if(lastUse + 5 > world.realtime)
        usr << "You must wait [lastUse + 5 - world.realtime] seconds before using this again."
        return
    lastUse = world.realtime
    makeContract(usr)
    // idrc if they spam this as it will stop it but uh


/obj/Skills/Devils_Deal/verb/Retrieve_Contracts()
    set category = "Utility"
    var/list/contracts = retrieveContract(usr)
    if(contracts.len)
        usr << "You have [contracts.len] contracts."
        for(var/obj/Items/Contract/c in contracts)
            if(c in contents)
                continue
            c.Move(usr)
    else
        usr << "You have no contracts."


// procs

/obj/Skills/Devils_Deal/proc/makeContract(mob/p)
    if(p)
        var/count = 0
        for(var/obj/Items/Contract/c in p.contents)
            if(c.summon == p.key)
                count++
        if(count >= p.SummonTier*2)
            p << "You have too many contracts."
            return
        var/obj/Items/Contract/c = new()
        c.summon = p.key
        c.Move(p)

/obj/Skills/Devils_Deal/proc/retrieveContract(mob/p)
    if(p)
        var/list/contracts = list()
        for(var/obj/Items/Contract/c in world)
            if(c.summon == p.key)
                contracts += c
        return contracts



/obj/Skills/Devils_Deal/proc/setSummonReturnTime(time)
    summonReturnTime = time

/obj/Skills/Devils_Deal/proc/setOrgXYZ(x,y,z)
    orgX = x
    orgY = y
    orgZ = z

/obj/Skills/Devils_Deal/proc/returnToOrg(mob/p)
    if(p)
        p.CurrentlySummoned = FALSE
        p.loc = locate(orgX, orgY, orgZ)
        p << "You return to your orgin."

/obj/Skills/Devils_Deal/proc/getContractors()
    return currentContractors

/obj/Skills/Devils_Deal/proc/getSummonReturnTime()
    return summonReturnTime

/obj/Skills/Devils_Deal/proc/incrementSummonReturnTime(time)
    if(dontIncrement)
        return
    summonReturnTime += time

/obj/Skills/Devils_Deal/proc/setHomeTime(time)
    goBackHomeTime = time

/obj/Skills/Devils_Deal/proc/getHomeTime()
    return goBackHomeTime

/obj/Skills/Devils_Deal/proc/getOrgXYZ()
    return list(orgX, orgY, orgZ)

/obj/Skills/Devils_Deal/proc/alreadyContractor(mob/p)
    if(p)
        if(currentContractors[p.key])
            return 1
        else
            return 0

/obj/Skills/Devils_Deal/proc/addContractor(mob/p)
    if(p)
        if(!alreadyContractor(p))
            currentContractors[p.key] += "[p.name],[p.EnergySignature]"
            p << "You have established a contract with [p.name]."
        else
            p << "You already have a contract with [p.name]."

/obj/Skills/Devils_Deal/proc/removeContractor(mob/p)
    if(p)
        if(alreadyContractor(p))
            currentContractors -= p.key
            p << "You have removed your contract with [p.name]."
        else
            p << "You do not have a contract with [p.name]."



