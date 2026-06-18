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

Inkworks // This should be passed to InkworksDarum which should be to every individual mob and edited individualy
    var
        Slots = 1 // How many Inkworks you can have on you
        Tier = 0 // Your Inkworks tier, which increases with Inkworks Research
        // Tales of The Living - Give you a status effect.
        MatchGirl = 0 // eruptingblows
        IceQueen = 0 // Freezing + IceHerald/IceAge
        Erlking = 0 // Shattering + EarthHerald
        SnowWhite = 0 // silentpoison
        // Tales of The Spirit - Adjust your moves
        Fox = 0 //SpiritFlow and Spiritsword scale better
        Wolf = 0 // + Dash Range for dash skills 
        Dragon = 0 // Buff beams somehow?
        Bear = 0 // If the person you normal attack is stunned, gain warping when damaging them.
        Snake = 0 // Hide Debuffs inflicted
        Lion = 0 // Shadow Mantle frenzy mechanics. 
        



    proc/calculateSlots() // Doing the actual math for InkworksSlots as we cannot initiate with this calculation
        var/SlotCalculation = BASE_INKWORKS_SLOTS + Tier
        Slots = SlotCalculation

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Inscribed_Ink
    MagicNeeded = 1
    ActiveMessage = "taps into the Ink inscribed into their their body."
    TextColor=rgb(182, 27, 148)
    adjust(mob/P)
    

    verb/Ink_Empowerment()
        set category = "Skills"

mob/proc/ReduceInkworksUnlocked()
    --InkworksDatum.Tier
    InkworksDatum.calculateSlots()