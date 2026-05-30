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
        // Tales of The Living
        MatchGirl = 0 // Scorching
        SnowQueen = 0 // Freezing
        IssunBoshi = 0 // Underdog 
        YouthFountain = 0 // Lifegen
        // Tales of The Spirit
        Kumiho = 0 // Lifesteal
        Gorgon = 0 // Cripple
        Harpy = 0 // Skimming



    proc/calculateSlots() // Doing the actual math for InkworksSlots as we cannot initiate with this calculation
        var/SlotCalculation = BASE_INKWORKS_SLOTS + Tier
        Slots = SlotCalculation

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Inscribed_Ink
    MagicNeeded = 1
    ActiveMessage = "taps into the Ink adorning their body."
    TextColor=rgb(182, 27, 148)
    adjust(mob/P)
    

    verb/Ink_Empowerment()
        set category = "Skills"

mob/proc/ReduceInkworksUnlocked()
    --InkworksDatum.Tier