/*
vars
    summonable : var needed to be summoned
    summon tier : tier of summon
    currentlySummoned : boolean if they are currently summoned

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
        getOrgX : gets the orgin x
        getOrgY : gets the orgin y
        getOrgZ : gets the orgin z
        setContractors : sets the contractors
        setSummonReturnTime : sets the summon return time
        setOrgX : sets the orgin x
        setOrgY : sets the orgin y
        setOrgZ : sets the orgin z
        retrieveContract : retrieves all unsigned contracts that belong to YOU (the summonable)

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

/mob/var/Summonable = FALSE
/mob/var/SummonTier = 0
/mob/var/CurrentlySummoned = FALSE



/mob/Admin4/verb/Make_Summon(mob/p in players)
    set name = "Make Summon"
    set category = "Admin"
    if(p == null)
        return
    if(!p.client)
        return

    var/whatTier = input(src, "What tier would you like the summon to be (1-5)?") as num
    if(whatTier < 1 || whatTier > 5)
        return
    if(SummonTier < 1)
        p.AddSkill(new/obj/Skills/Devils_Deal)
    p.SummonTier = whatTier
    p.Summonable = TRUE
    p<<"You have been turned into a Tier [whatTier] summon!"
