#define MANG_BASE_VALUE 0.3 // The base value when you activate mang
#define MANG_MULT_VALUE 0.1 // The extra value from higher mang
#define MANG_MANA_COST 10 // Determines the cost of activating a Mang Ring/Level

/obj/Skills/Buffs/SlotlessBuffs/Shin_Radiance
    passives = list("GiantForm" = 1, "Harden" = 1, "PureReduction" = 1, "Godspeed" = 1, "Deflection" = 1, "ManaGeneration" = 1, "Unnerve" = 1) // SOME OF THESE GET CHANGED IN THE ADJUST
    ActiveMessage="radiates a soft, warding glow of Light."
    OffMessage="suppresses the glow of the Light, letting their emotions flow on."
    TextColor=rgb(203, 198, 47)
    //Base mults
    EndMult = 1.2 
    DefMult = 1.2
    ManaGlow = "#c7b921"
    ManaGlowSize = 2
    adjust(mob/p)
        var/secretLevel = p.secretDatum.currentTier
        var/mod = (secretLevel-5)
        // Tier Adjusted Mults
        EndMult = 1.2 + (0.05 * secretLevel) 
        DefMult = 1.2 + (0.05 * secretLevel)
        // Tier Adjusted Passives
        passives["Harden"] = clamp(secretLevel*2, 1, 5) // starts at 1, adds 2 per tier, caps at 5 (tier 3)
        passives["PureReduction"] = clamp(secretLevel >= 3 ? (secretLevel+mod) : 0, 0, 5); //Scales from tier 3 (1) to tier 5 (5)
        passives["Godspeed"] = secretLevel
        passives["Deflection"] = (0.5 * secretLevel) //Goes from 1 to 3
        passives["ManaGeneration"] = secretLevel
        passives["Unnerve"] = secretLevel // Aura Farming as a passive.
        // It also replaces your mana name to Shin but REPLACEMANA IS A STUPID FUCKING PASSIVE SO I DID IT IN THE UPDATE_STAT_LABELS PROC FUCK FUCK FUCK


    verb/Shin_Radiance()
        set category = "Skills"
        if(!usr.BuffOn(src)) adjust(usr)
        src.Trigger(usr)

    verb/Shin_Colour()
        set category = "Utility"
        var/colour = input(usr, "Select your Shin Colour", "Shin Colour Selection", rgb(203, 198, 47)) as color | null ;
        ManaGlow = colour

/obj/Skills/Buffs/SlotlessBuffs/Mang_Resonance // FAIL TO READ BELOW THIS UNDER PENALTY OF DEATH
    ActiveMessage="fills the emptiness with their most intense emotion, creating rings that hum with power."
    OffMessage="'s Mang begin to fade as the moment passes."
    TextColor=rgb(203, 198, 167)
    TimerLimit = 30
    Cooldown = 30
    IconLock = 'Icons/Buffs/SecretBuffs/Mang/MangRing1.dmi'
    var/image/currentImage;
   // IconApart = 1

     /* All of Mang's passives and stats are scattered across passive procs. This is so that they can scale based off of how many Mang you have
     The passives are as follows: Steady, Godspeed, Brutalize, BlurringStrikes, BuffMastery, PureDamage
     They scale off of how many mang you have active. They do NOT show up in the passive handler rn
     Please do not go screaming about how "Mang does nothing" I will gut you myself - Hadoje */
     
    
    /* verb/Manifest_Mang() // This is a debug verb
        set category = "Skills"
        if(!usr.BuffOn(src)) adjust(usr)
        src.Trigger(usr) */

// A bunch of procs that will be used in PowerControl.dmand for passives.

mob/proc/GetMangStats() //This proc is ued in _JinxUtility.dm specifically for adding Strength, Force, Speed, and offense based on the defines. 
    var/SecretInformation/Shin/ShinSecret = secretDatum
    return MANG_BASE_VALUE + (ShinSecret.Mang * MANG_MULT_VALUE)

mob/proc/GetMangLevel() //This proc gets how many Mang you have active is used in _BinaryChecks.dm, BlurringStrikes.dm, and Brutalize.dm
    if(Secret == "Shin")
        var/SecretInformation/Shin/ShinSecret = secretDatum
        return ShinSecret.Mang
    return 0

mob/proc/GetMangMastery() //This proc gets your max amount of mang
    if(Secret == "Shin")
        var/SecretInformation/Shin/ShinSecret = secretDatum
        return ShinSecret.MangMastery
    return 0

mob/proc/AddMangLevel() // This increases your active mang level
    var/SecretInformation/Shin/ShinSecret = secretDatum
    ShinSecret.Mang++
    updateMangVisuals();
    
/mob/proc/updateMangVisuals()
    AddMangLevelMessage();
    MangIconDraw();

mob/proc/AddMangLevelMessage() // I heard you like procs so I put a proc in your proc - Xoxo
    var/fColor;
    var/msg;
    if(GetMangLevel() >= 5)
        msg = "Ain't that a motherfu--";
        fColor = rgb(255, 0, 0);
    else
        msg = "[src] manifests [GetMangLevel()] Mang Ring\s!";
        fColor = rgb(241, 236, 129);
    OMsg(src, "<b><font color='[fColor]'>[msg]</font color></b>");

mob/proc/ReduceMangLevel() // This decreases your active mang level
    var/SecretInformation/Shin/ShinSecret = secretDatum
    ShinSecret.Mang--
    if (!GetMangLevel()) MangIconErase()
    else updateMangVisuals();
        

mob/proc/ShinActive() // This checks if Shin is on
    if(Secret == "Shin" && CheckSlotless("Shin Radiance"))
        return 1
    return 0

mob/proc/MangActive() // THis checks if Mang is on
    if(Secret == "Shin" && CheckSlotless("Mang Resonance"))
        return 1
    return 0

mob/proc/MangToShin() // This transitions Mang to Shin (Congratulations on your transition)
    MangIconErase();
    endMangBuff();
    startShinBuff();
/mob/proc/ShinToMang()
    endShinBuff();
    startMangBuff();
    if(GetMangLevel()<1) AddMangLevel();//if you're currently at 0 mang rings, get at least 1
    else updateMangVisuals();//otherwise, just announce what mang rings you're using

mob/proc/MangManaPay(fullcost = 0) // It's a surprise tool that helps us later
    if(fullcost)
        return clamp(GetMangLevel(), 1, 5)//clamp prevents 0 mang rings from being free
    return 1    

mob/proc/MangManaCost() // Checks if you have the mana before spending it.
    var/MangLevelCost = MANG_MANA_COST * MangManaPay(!MangActive()) // This is later (tl;dr determines if you pay per increment or for all mang)
    if(GetMangMastery() == GetMangLevel() && MangActive()) return//extra clause added in case you timed out of Mang while at your max level
    if(ManaAmount >= MangLevelCost)
        LoseMana(MangLevelCost)
        return 1
    if(ManaAmount < MangLevelCost)
        return 0

mob/proc/MangOnCD() // Checks if your mang is on CD
    for(var/obj/Skills/Buffs/SlotlessBuffs/Mang_Resonance/mr in contents)
        if(mr.Using)
            return 1
    return 0

mob/proc/ShinSecretLevel() // This is currently not in use (I think)
    var/secretLevel = src.secretDatum.currentTier
    return secretLevel

mob/proc/MangIconDraw() // used to draw our mang icon, necessary so we can draw the correct state
    var/obj/Skills/Buffs/SlotlessBuffs/Mang_Resonance/Mang = MangCall()
    if(!Mang) return;
    if(Mang.currentImage) MangIconErase();
    var/image/i = image(icon=Mang.IconLock, icon_state="Mang[GetMangLevel()]", pixel_x = Mang.LockX, pixel_y = Mang.LockY);
    i.appearance_flags = KEEP_APART;
    Mang.currentImage = i;
    overlays += Mang.currentImage;

mob/proc/MangIconErase() // used to erase our mang icon, necessary so we can not have overlapping states
    var/obj/Skills/Buffs/SlotlessBuffs/Mang_Resonance/Mang = MangCall()
    if(Mang && Mang.currentImage)
        overlays -= Mang.currentImage;
        Mang.currentImage = 0;

mob/proc/MangCall() // This allows us to pass 'Mang_Resonance' to other procs :D
    for(var/obj/Skills/Buffs/SlotlessBuffs/Mang_Resonance/mr in contents)
        if (!BuffOn(mr)) return 0
        return mr
//Can you tell I'm losing it yet?


//Thank you for these Xoxo <3
mob/proc/usingShinBuff() // Checks if we're using shin
    return CheckSlotless("Shin Radiance") ? 1 : 0;

mob/proc/startShinBuff() // Turns Shin on (owo)
    for(var/obj/Skills/Buffs/SlotlessBuffs/Shin_Radiance/sr in contents)
        if(!BuffOn(sr)) sr.Trigger(src, Override=1);

mob/proc/endShinBuff() // Turns Shin off (aww)
    for(var/obj/Skills/Buffs/SlotlessBuffs/Shin_Radiance/sr in contents)
        if(BuffOn(sr)) sr.Trigger(src, Override=1);

mob/proc/usingMangBuff() // Checks if we're using Mang
    return CheckSlotless("Mang Resonance") ? 1 : 0;

mob/proc/startMangBuff() // Turns Mang on (uwu)
    for(var/obj/Skills/Buffs/SlotlessBuffs/Mang_Resonance/mr in contents)
        if(!BuffOn(mr)) mr.Trigger(src, Override=1);

mob/proc/endMangBuff() // Turns Mang off (Oops)
    for(var/obj/Skills/Buffs/SlotlessBuffs/Mang_Resonance/mr in contents)
        if(BuffOn(mr)) mr.Trigger(src, Override=1);

/mob/proc/canMangPU()
    if(!ActiveBuff) return 0;
    return ((GetMangMastery() >= GetMangLevel()) && ((usingShinBuff() && !MangOnCD()) || usingMangBuff()));

//tbh i think we could probably make a proc that handles both CD expiration and turning mang rings off but... i'm just gonna leave well enough alone
mob/proc/MangCDSwap(obj/Skills/Buffs/b) // This is no longer commented out and I just put it where I should have advised to put it in the first place ~ Xoxo
    if(istype(b, /obj/Skills/Buffs/SlotlessBuffs/Mang_Resonance))
        MangIconErase();
        startShinBuff();
