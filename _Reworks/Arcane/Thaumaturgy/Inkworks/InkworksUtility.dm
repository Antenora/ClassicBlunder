
verb/Bestow_Inkwork(mob/P)
    set category = "Utility"
    set hidden = 1
    if (P.Using == 1) // Guard Rails to prevent people spamming this verb (looks @ jumpy)
        return
    else (P.Using = 1)
    var/list/Options = list("Cancel") // List of Players we can use this on
    for(var/mob/Players/M in view(1, usr))
        Options.Add(M)
    var/mob/Choice = input(usr, "Choose a Player", "Bestow Inkwork") in Options // The Menu that chooses the player
    if(Choice == "Cancel")
        P.Using = 0 // If you're not doing anything, set this back to 0
        return
    else
        if(Choice.isRace(ANDROID)) // I'm sorry android players...
            usr << "This Vessel cannot support Inkworks"
            P.Using = 0
            return
        if(Choice.hasSecret("Heavenly Restriction") && Choice.secretDatum?:hasRestriction("Magic"))
            usr << "This Vessel's Heavenly Restriction rejects your feeble Magic."
            P.Using = 0
            return
        if(!Choice.CyberCancel == 0)
            usr << "This Vessel's Mechanical Augments are incompatible with magic."
            P.Using = 0
            return
        var/inkchoice = input(usr, "Choose an Inkwork to Bestow on [Choice]", "Bestow Inkwork") in usr.InkworksTypes
        InkworksIfWall(inkchoice, Choice)
        P.Using = 0

proc/InkworksIfWall(inkchoice, mob/Choice) // I hate this I hate this I hate this I hate this
// In a mob's inkworksdatum there is a list called Applied, if the inkchoice (which takes from a list tied to knowledgeunlock.dm)
// already exists in the mob's specific Applied list, it will return. Otherwise it will add to this list.
    if (Choice.InkworksDatum.Slots == 0)
        usr.Using = 0
        usr << "This Vessel cannot support any more Inkworks."
        return
    if (inkchoice in Choice.InkworksDatum.Applied)
        usr << "This vessel already had this Inkwork applied to them."
        usr.Using = 0
        return
    if (inkchoice == "Match Girl")
        Choice.InkworksDatum.Applied = "Match Girl"
        Choice.InkworksDatum.MatchGirl = 1
        usr << "The Story of the Match Girl has been successfully inked onto this vessel."
    if (inkchoice == "Ice Queen")
        Choice.InkworksDatum.Applied = "Ice Queen"
        Choice.InkworksDatum.IceQueen = 1
        usr << "The Story of the Ice Queen has been successfully inked onto this vessel."
    if(inkchoice == "Erlking")
        Choice.InkworksDatum.Applied = "Erlking"
        Choice.InkworksDatum.Erlking = 1
        usr << "The Story of the Erlking has been successfully inked onto this vessel."
    if(inkchoice == "Fox Spirit")
        Choice.InkworksDatum.Applied = "Fox Spirit"
        Choice.InkworksDatum.Fox = 1
        usr << "The Fox Spirit has been successfully inked onto this vessel."
    if(inkchoice == "Bear Spirit")
        Choice.InkworksDatum.Applied = "Bear Spirit"
        Choice.InkworksDatum.Bear = 1
        usr << "The Bear Spirit has been succesfully inked onto this vessel."
    if(inkchoice == "Wolf Spirit")
        Choice.InkworksDatum.Applied = "Wolf Spirit"
        Choice.InkworksDatum.Wolf = 1
        usr << "The Wolf Spirit has been succesfully inked onto this vessel."
    if(inkchoice == "Dragon Spirit")
        Choice.InkworksDatum.Applied = "Dragon Spirit"
        Choice.InkworksDatum.Dragon = 1
        usr << "The Dragon Spirit has been successfully inked onto this vessel."
    if(inkchoice == "Lion Spirit")
        Choice.InkworksDatum.Applied = "Lion Spirit"
        Choice.InkworksDatum.Lion = 1
        usr << "The Lion Spirit has been succesfully inked onto this vessel"
        // The Lion does concern himself with inkworks
    Choice.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Inscribed_Ink)
    Choice.InkworksDatum.calculateSlots()
    return
