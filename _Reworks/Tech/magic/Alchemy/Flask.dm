// Check Items.dm and sift through the spaghetti to find how this item is equipped and unequipped via the Equip proc and the ObjectUse proc
// (I fucking hate this shit dude)
// Flask making and adjusting verb is in _UtilitX.dm at line 1483 (Concoct_Flask)
#define BASE_MAX_CHARGES 2 // How many charges we start out with
#define FLASK_CD 300
#define BASE_MAX_SLOTS 2 // How many herb slots we start with

/obj/Items/Flask
    Unwieldy = 1 // Should prevent people from using this outside of meditate
    icon = 'Icons/enchantment/Magic Potion.dmi'
    // 0 means they will not trigger if statements
    // 1 means they will
    // Basic Healing effects
    var/Heal=0
    var/Energy=0
    var/Mana=0
    // Damaging effects
    //var/Toxic=0
    // Passive Effects
    var/Hallucinogen=0 // Anger Buffs
    var/Searing=0 // Damage Buffs
    var/Flowy=0 // Flow Buffs
    var/Hard=0 // Tank Buffs
    var/Quicksilver=0 // Speed Buffs
    // Misc stuff
    EquipIcon = 0
    var/Tier = 0 // This will be used to upgrade your flask
    var/Slots= 2 // How many Herbs/Buffs a charge holds. It's actually defined in GetMaxFlaskCharges(), this just initilizes it.
    var/Charges = 2 // How many uses you have in your flask before you need to meditate again. It's actually defined in GetMaxFlaskCharges(), this just initilizes it.
    // Charge refilling is handled in Gains.dm, line 237
    // Below is The Buff We Pass This Shit To and spends charges
    Techniques = list("/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Flask_Charge")

    verb/Imbibe_Flask() // We cosnume a charge from the flask!
        set category = "Skills"
        if(usr.hasSecret("Heavenly Restriction") && usr.secretDatum?:hasRestriction("Magic"))
            usr << "Your body cannot possibly accept this."
            return
        if(usr.equippedFlask.Charges == 0)
            usr << "You have no Flask Charges left!"
            return
        if(!usr.CheckSlotless("Flask Charge")) // If no buff, 
            for(var/typesFromTechniques in src.Techniques) // We want to go fishing
                var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Flask_Charge/usedFlask = usr.findOrAddSkill(typesFromTechniques); // then we assign our fish to a var
                if(usedFlask.Using)
                    usr << "You cannot imbibe more right now!"
                    return // FUCK YOU FUCK YOU FUCK YOU 
                if(!usr.reduceCharge()) return // mob proc that reduces charges
                usedFlask.adjust(usr); // We can now pass adjust and trigger procs as if we were in the buff (kind of)
                usedFlask.Trigger(usr);

/* for(var/typesFromTechniques in src.Techniques)
    var/obj/Skills/Buffs/Slotlessbuffs/Autonomous/Flask_Charge/usedFlask = usr.findOrAddSkill(typesFromTechniques);
    usedFlask.adjust(usr);
    usedFlask.Trigger(usr);*/

// This is the thing the players actually interact with, it also can be accessed in all the important ways
/mob/var/obj/Items/Flask/equippedFlask


// What actually handles the Potion Buff and Hopefully works?
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Flask_Charge
    MagicNeeded=1
    ActiveMessage="imbibes a concoction from their Flask!"
    TextColor=rgb(149, 255, 0)
    CooldownStatic = 1 // No, you will not use technique mastery.
    Cooldown = 0 // THIS IS HANDLED IN ADJUST FUCK MY CHUD LIFE
    TimerLimit = 60
    passives = list() // THese r handled in the adjust proc too
    adjust(mob/P)
        Cooldown = P.GetFlaskCD()
        InstantAffect = 1
        // This is used so that passives can be added and subtracted so I don't use = like a fucking moron.
        // Any potions that introduce passives must have the new passives added to this list at 0
        // Never use = Operator for passives outside of this list, instead use += and make downsides negative or 0 - Hadoje
        passives = list("PureReduction" = 0, "Godspeed" = 0, "AngerAdaptiveForce" = 0, "PureDamage" = 0, "Steady" = 0, "Flow" = 0, "LikeWater "= 0, "Unnerve" = 0, "Skimming" = 0)
        // I am so fucking sorry for what is about to happen
        /* SOMEONE BROKE THE HEALS SO THEY ONLY WORK PER TIC WHICH MAKES IT IMPOSSIBLE TO HAVE A BALANCED HEALTH POTION I FUCKING HATE THESE ANIMALS
        if(P.equippedFlask.Heal == 1) // if you chose a  herb, your value for said herb should be 1 and ONLY 1
            StableHeal=1
            //Check glob.dm for POTIONHEAL
            src.HealthHeal = glob.POTIONHEAL/2*(P.equippedFlask.Tier+1)  // 2.5, 5, 7.5 if POTIONHEAL = 5
            src.ManaHeal = (-1)*glob.POTIONHEAL*(5-P.equippedFlask.Tier) // T0 = -25, T1 = -20, T3 = -15 if POTIONHEAL=  5
            src.EnergyHeal = (-1)*glob.POTIONHEAL*(2-P.equippedFlask.Tier)// T0 = -10, T1 = -5, T3 = 0 if POTIONHEAL=  5
        */

        if(P.equippedFlask.Mana == 1) //  ONLY THE VALUE OF 1 SHOULD BE HERE
            StableHeal=1
            src.ManaHeal = (glob.POTIONHEAL*(P.equippedFlask.Tier+1)) // I give up on quantifying this. Adjust POTIONHEAL in glob.dm if it gets out of hand

        if(P.equippedFlask.Energy == 1) // Same as above
            StableHeal=1
            src.EnergyHeal = (glob.POTIONHEAL*(P.equippedFlask.Tier+1)) // I also give up on quantifying this.

        if(P.equippedFlask.Hallucinogen == 1) // This gives you immediate anger and anger buffs at expense of defense
            AutoAnger=1 // Makes you angry instantly
            // Please note: the comments will tell you what the math does
            EndMult = 0.6 + (P.equippedFlask.Tier+1)/10 // T0 = 0.7, T1 = 0.8, T3 = 0.9 endurance mult (DOWNSIDE)
            DefMult = 0.6 + (P.equippedFlask.Tier+1)/10 // T0 = 0.7, T1 = 0.8, T3 = 0.9 Defense mult (DOWNSIDE)
            passives["PureReduction"] += -7 + (P.equippedFlask.Tier+1) // T0 = -6, T1 = -5 T2 = -4, PS: -1 PureReduction = 5% extra damage taken,
            passives["AngerAdaptiveForce"] += ((P.equippedFlask.Tier+1)/10) // T0 0.1 AAF, T1 0.2, T2 0.3 PS: 0.1 AAF = 10% increase of strongest dmg stat
            passives["AngerThreshold"] += 2 + ((P.equippedFlask.Tier/2)) // t0 = 200 Anger, T1 = 250 Anger, T2 = 300 Anger
        if(P.equippedFlask.Searing == 1) // Damage
            StrMult = 1 + (P.equippedFlask.Tier+1)/10 // T0 = 1.1, T1 = 1.2, T2 = 1.3
            ForMult = 1 + (P.equippedFlask.Tier+1)/10 // Same as above
            passives["PureDamage"] += (P.equippedFlask.Tier+1) // T0 = 1, T1 = 2, T2 = 3 // 5% to 15% dmg boost
            passives["Steady"] += (P.equippedFlask.Tier+1) // T0 = 1, T1 = 2, T2 = 3
            passives["PureReduction"] += -5 + (P.equippedFlask.Tier+1) // T0 = -4, T1= -3 T2 = -2 // 20% to 10% extra damage taken (DOWNSIDE)
        if(P.equippedFlask.Flowy == 1) // Dodging
            DefMult = 1 + (P.equippedFlask.Tier+1)/4 // T0 = 1.25, T1 = 1.5, T2 = 1.75 // This makes you dodge more
            StrMult = 0.85 + (P.equippedFlask.Tier+1)/20  // T0 = 0.9, T1 = 0.95, T3 = 1 (DOWNSIDE)
            ForMult = 0.85 + (P.equippedFlask.Tier+1)/20 // T0 = 0.9, T1 = 0.95, T3 = 1 (DOWNSIDE)
            passives["Flow"] += (P.equippedFlask.Tier+1) // T0 = 1, T1 = 2, T2 = 3
            passives["LikeWater"] += (P.equippedFlask.Tier+1) // Same as Above
        if(P.equippedFlask.Hard == 1) // Defense
            EndMult = 1 + (P.equippedFlask.Tier+1)/10 //T0 = 1.1, T1 = 1.2, T3 = 1.3 endurance mult
            SpdMult = 0.85 + (P.equippedFlask.Tier+1)/20 // T0 = 0.9, T1 = 0.95, T3 = 1 (DOWNSIDE)
            passives["PureReduction"] += (P.equippedFlask.Tier+1) // T0 = 1, T1 = 2, T2 = 3
            passives["Unnerve"] += (P.equippedFlask.Tier+1) // T0 = 1, T1 = 2, T2 = 3
            passives["Godspeed"] += -4 + (P.equippedFlask.Tier+1) // T0 = -3, T1 = -2, T2 = -1 (DOWNSIDE)
        if(P.equippedFlask.Quicksilver == 1) // Speed, you must be feeling pretty stupid restricting magic now huh Jess?
            SpdMult = 1 + (P.equippedFlask.Tier+1)/10 //T0 = 1.1, T1 = 1.2, T3 = 1.3 speed mult
            StrMult = 0.85 + (P.equippedFlask.Tier+1)/20  // T0 = 0.9, T1 = 0.95, T3 = 1 (DOWNSIDE)
            ForMult = 0.85 + (P.equippedFlask.Tier+1)/20 // T0 = 0.9, T1 = 0.95, T3 = 1 (DOWNSIDE)
            passives["Godspeed"] += (P.equippedFlask.Tier+1) // T0 = 1, T1 = 2, T2 = 3
            passives["Skimming"] += (P.equippedFlask.Tier+1) // T0 = 1, T1 = 2, T2 = 3

// Procs that handle all this stupid chud shit
mob/proc/reduceCharge() // Reduces charges, fuck this gave me a headache
    if(equippedFlask.Charges == 0) // Empty
        src << "You have no Flask Charges left!"
        return
    else if(equippedFlask.Charges > GetMaxFlaskCharges() || equippedFlask.Charges < 0) // Why do you have more than 4? Max tier flasks should have 4.
        src << "ERROR: Your number of Flask Charges is [equippedFlask.Charges], this shouldn't be possible. Contact staff."
        liveDebugMsg("[src] has [equippedFlask.Charges] Flask Charges. This shouldn't be possible.") // I'll thank myself later when someone inevitably exploits flasks.
        if(equippedFlask.Charges > GetMaxFlaskCharges())
            equippedFlask.Charges = GetMaxFlaskCharges()
        return
    --equippedFlask.Charges // The whole reason we're here
    return 1;


mob/proc/GetMaxFlaskCharges() // adds tier to the define, used in Gains.dm line 237
    return BASE_MAX_CHARGES + equippedFlask.Tier

mob/proc/GetFlaskCD() // Determines our cooldown
    return FLASK_CD - (equippedFlask.Tier*60) // T0 = FLASK_CD, T1 = FLASK_CD-1 MIN., T2 = FLASK_CD-2MIN. This will probably be rebalanced at some point

mob/proc/GetMaxFlaskSlots() // adds tier to the define, used in _UtilityX.dm line 1550
    return BASE_MAX_SLOTS + equippedFlask.Tier
