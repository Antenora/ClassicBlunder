/*
Contract item
    needs to be able to be written on and "signed" by both parties
    the owner of the contract is always the summon, the summonable skill allows them to make a contract
    these contracts are bound to them, but can be destroyed or given away and destroyed (aka broken)
    the contract will take the key and name of the person as well as ask for a description
    furthermore it will ask for the actual goal of the contract aside from the description for ease

    vars
        summon : name+key of the person who made the contract
        summoner : name+key of the summoner
        description : description of the contract
        goal : goal of the contract
        signatures : list of names+keys of people who have signed the contract
        signed : boolean if the contract is signed or not
        sigKeys : list of keys of people who have signed the contract

    functions
        sign : signs the contract
        break : breaks the contract
        give : gives the contract to someone else
        write : writes on the contract
        read : reads the contract
        getSummon : gets the summoner
        getSummoner : gets the summoner
        getDesc : gets the description
        getGoal : gets the goal
        getSignatures : gets the signatures
        getSigned : gets if the contract is signed
        getSigKeys : gets the keys of the signatures
        completeContract : completes the contract
            this will delete the item, but also clear the variables in summonable skill, as well as the summoner's summon skill
*/


/obj/Items/Contract
    name = "Soul Binding Contract"
    desc = "A contract made between two parties, it is bound to the summon and can not be broken or given away"
    Destructable = FALSE
    Health = 1#INF
    icon='SummoningContract.dmi'

// VARIABLES







/obj/Items/Contract/var/goal = "There has yet to be a goal set out by the two parties"
/obj/Items/Contract/var/summon = null
/obj/Items/Contract/var/summoner = null
/obj/Items/Contract/var/description = "There has yet to be a description set out by the two parties"
/obj/Items/Contract/var/signatures = ""
/obj/Items/Contract/var/signed = FALSE
/obj/Items/Contract/var/list/sigKeys = list()
/obj/Items/Contract/var/usable = TRUE

// VERBS //
/obj/Items/Contract/verb/Read_contract()
    usr << "The contract is between [summon] and [summoner]"
    usr << "The description of the contract is: [description]"
    usr << "The goal of the contract is: [goal]"
    usr << "The signatures on the contract are: [signatures]"


/obj/Items/Contract/verb/Write_Contract()
    setDescription(usr)
    setGoal(usr)

/obj/Items/Contract/verb/Sign_Contract()
    if(alreadySigned(usr.key))
        usr << "You have already signed the contract"
        return
    signContract(usr.name, usr.key, usr)

/obj/Items/Contract/verb/Break_Contract()
    if(usr.key != summon)
        usr << "Only the creator of this contract can break it"
        return
    if(!signed)
        usr << "The contract is not signed"
        return
    switch((input(usr, "Are you sure you want to break the contract? If there are reprecussions they will happen") in list("Yes","No")))
        if("Yes")
            usr << "You feel a sharp pain in your chest as the contract breaks!"
            for(var/mob/admin in admins)
                admin<<"[usr]([usr.ckey]) broken a contract with [summoner]! Please address the situation!"
            for(var/mob/summonerr in world)
                if(summonerr.key == summoner)
                    summonerr << "You feel a sharp pain in your chest as the contract breaks!"
                    summonerr.findSummonSkill().removeContractor(usr)
            name = "Broken Contract"
            usable = FALSE


 // FUNCTIONS //

/obj/Items/Contract/proc/setDescription(mob/p)
    if(!usable) return
    if(p.key != summon)
        p << "Only the creator of this contract can write it"
        return
    if(signed)
        p << "The contract is already signed"
        return
    p << "Please write the description of the contract"
    description = input(p, "Description: ", "What do you want to make the description?") as message

/obj/Items/Contract/proc/setGoal(mob/p)
    if(!usable) return
    if(p.key != summon)
        p << "Only the creator of this contract can write it"
        return
    if(signed)
        p << "The contract is already signed"
        return
    p << "Give an ooc summary of the goal of the contract (Say your summoner wants you to beat somebody up or something like that)"
    goal = input(p, "Goal: ", "What do you want to make the goal?") as message



/obj/Items/Contract/proc/alreadySigned(key)
    if(sigKeys.Find(key))
        return TRUE
    return FALSE


/obj/Items/Contract/proc/getSummon()
    return summon

/obj/Items/Contract/proc/getSummoner()
    return summoner

/obj/Items/Contract/proc/getDesc()
    return description

/obj/Items/Contract/proc/getGoal()
    return goal

/obj/Items/Contract/proc/getSignatures()
    return signatures

/obj/Items/Contract/proc/getSigned()
    return signed

/obj/Items/Contract/proc/getSigKeys()
    return sigKeys

/obj/Items/Contract/proc/signContract(name, key, mob/p)
    if(!usable)
        p << "The contract is broken and can not be signed"
        return
    if(description == "There has yet to be a description set out by the two parties")
        p << "You must write a description before signing the contract"
        return
    if(goal == "There has yet to be a goal set out by the two parties")
        p << "You must write a goal before signing the contract"
        return
    if(!signed)
        if(p.key != summon)
            // look for summon skill and set it up
            var/obj/Skills/Utility/Summon_Entity/skill = p.findSummonSkill() // this is the summon skill.
            var/mob/theSummon = findSummon(summon) // this is the summoner
            skill.addContractor(theSummon)
            summoner = p.key
        signatures += name + ","
        sigKeys[key] += p.EnergySignature
        if(sigKeys >= 2)
            signed = TRUE
        viewers(p) << "[p] signs a contract with their blood!"
    else
        p << "The contract is already signed"

/proc/findSummon(k)
    for(var/mob/summon in world)
        if(summon.key == k)
            return summon
    return null