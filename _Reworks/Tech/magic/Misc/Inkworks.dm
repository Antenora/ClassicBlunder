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
        list/Applied = list() // How many Inkworks you have applied

    proc/calculateSlots(mob/P) // Doing the actual math for InkworksSlots as we cannot initiate with this calculation
        var/SlotCalculation = BASE_INKWORKS_SLOTS + Tier
        Slots = SlotCalculation - Applied.len
        if(Slots < 0)
            liveDebugMsg("[P] has had their slots forcefully set to 0 as a guardrail measure, their InkworksDatum may be bugged.")
            P << "Your Inkworks Slots were set to 0 as they somehow went into the negatives, please reach out to staff."
            Slots = 0

/obj/Skills/Buffs/SlotlessBuffs/Inscribed_Ink
    ActiveMessage = "taps into the Ink inscribed into their their body."
    OffMessage = "stops tapping into the power of the Ink."
    TextColor=rgb(182, 27, 148)
    adjust(mob/P)
        passives = list("Scorching" = 0, "Combustion" = 0, "Freezing" = 0, "IceAge" = 0, "Shattering" = 0, "EarthHerald" = 0)
        if(P.InkworksDatum.MatchGirl == 1) // Implodes Scorching at 80, dealing massive damage
            passives["Scorching"] += 5
            passives["Combustion"] += 100
        if(P.InkworksDatum.IceQueen == 1) // Implodes Slow at 30, dealing a bit of damage and stunning
            passives["Freezing"] += 5
            passives["IceAge"] += 30
        if(P.InkworksDatum.Erlking == 1) // Implodes Shattering at 100, making you take more damage(?)
            passives["Shattering"] +=5
            passives["EarthHerald"] += 1 // this is as if it was combustion 100, i don't think there's an Ice Age or Combustion version of this herald passive
        if(P.InkworksDatum.Fox == 1) // Increases spiritsword scaling by 40%
            passives["Fox Spirit"] += 1
        if(P.InkworksDatum.Bear == 1) // HOPEFULLY, and I do mean HOPEFULLY, counts you as having hot hundred and warping 2 when attacking a stunned/launched target
            passives["Bear Spirit"] += 1
        if(P.InkworksDatum.Wolf == 1)  // Doubles the effect of the Rush variable. If lightning kicks moves you 5 tiles, it now moves you 10.
            passives["Wolf Spirit"] += 1
        if(P.InkworksDatum.Dragon == 1) // Decreases the amount of time you need to charge to get a beam's damage WITHOUt affecting its final damage.
            passives["Dragon Spirit"] += 1
        if(P.InkworksDatum.Lion) // Frenzy
            passives["Lion Spirit"] += 1

    verb/Inscribed_Ink()
        set category = "Skills"
        set name = "Inscribed Ink"
        if(!usr.BuffOn(src)) adjust(usr)
        src.Trigger(usr)

mob/proc/ReduceInkworksUnlocked(mob/P) // I know its a mob proc but redundancy just in case
    --P.InkworksDatum.Tier
    if(P.InkworksDatum.Tier < 0)
        P.InkworksDatum.Tier = 0
    P.InkworksDatum.calculateSlots()