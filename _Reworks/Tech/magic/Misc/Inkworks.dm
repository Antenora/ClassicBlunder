#define BASE_INKWORKS_SLOTS 1

/* FAT FUCKING TO DO LIST FOR HADOJE:
FINISH THE FUCKING KNOWLEDGE PATH IN EnchantKnowledge.dm!!!!
ENSURE THAT THE UTILITY VERB PLAYERS USE WORKS IN _UtilityX.dm
ENSURE YOU HAVE ALL THE knowledgeUnlock STUFF SET UP!
ACTUALLY FINISH THE INKWORKS THEMSELVES
ADD THE BUFFS INKWORKS WILL GIVE!
DOUBLE CHECK MAGIC UNLOCK AND MAKE SURE INKWORKS R REFUNDED PROPERLY
CURB OUT FLASK EXPLOIYS (Ensure the guardrails flask.dm forcefully checks and resets your tier) */


// I will not contribute to mob var bloat! I REFUSE!
/mob/var/Inkworks/InkworksDatum = new()

Inkworks // This should be passed to InkworksDatum which should be to every individual mob and edited individualy
    var
        Slots = 1 // How many Inkworks you can have on you
        Tier = 0 // Your Inkworks tier, which increases with Inkworks Research
        // Tales of The Living - Give you a status effect.
        MatchGirl = 0 // Scorching + Combustion
        IceQueen = 0 // Freezing + IceHerald/IceAge
        Erlking = 0 // Shattering + EarthHerald
        // Tales of The Spirit - Adjust your moves
        Fox = 0 //SpiritFlow and Spiritsword scale better
        Bear = 0 //HotHundred / SajireRush effect
        Wolf = 0 // + Dash Range for dash skills 
        Dragon = 0 // Buff beams somehow?
        Lion = 0 // Shadow Mantle frenzy mechanics. 

    proc/calculateSlots() // Doing the actual math for InkworksSlots as we cannot initiate with this calculation
        var/SlotCalculation = BASE_INKWORKS_SLOTS + Tier
        Slots = SlotCalculation

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Inscribed_Ink
    MagicNeeded = 1
    ActiveMessage = "taps into the Ink inscribed into their their body."
    TextColor=rgb(182, 27, 148)
    adjust(mob/P)
        passives = list("Scorching" = 0, "Combustion" = 0, "Freezing" = 0, "IceAge" = 0, "Shattering" = 0, "EarthHerald" = 0)
        if(P.InkworksDatum.MatchGirl == 1)
            passives["Scorching"] += 5
            passives["Combustion"] += 100
        if(P.InkworksDatum.IceQueen == 1)
            passives["Freezing"] += 5
            passives["IceAge"] += 30
        if(P.InkworksDatum.Erlking == 1)
            passives["Shattering"] +=5
            passives["EarthHerald"] += 1 // this is as if it was combustion 100, i don't think there's an Ice Age or Combustion version of this herald passive
        if(P.InkworksDatum.Fox == 1)
            passives["Fox Spirit"] += 1
        if(P.InkworksDatum.Bear == 1)
            passives["Bear Spirit"] += 1
        if(P.InkworksDatum.Wolf == 1)  
            passives["Wolf Spirit"] += 1
        if(P.InkworksDatum.Dragon == 1)
            passives["Dragon Spirit"] += 1
        if(P.InkworksDatum.Lion)
            passives["Lion Spirit"] += 1

    verb/Ink_Empowerment()
        set category = "Skills"

mob/proc/ReduceInkworksUnlocked()
    --InkworksDatum.Tier
    InkworksDatum.calculateSlots()