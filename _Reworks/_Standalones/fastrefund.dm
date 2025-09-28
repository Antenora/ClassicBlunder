// this is anything but fast
/mob/Admin3/verb/Respec(mob/P in players)
    for(var/obj/Skills/Choice in P)
        if(Choice.Copyable)
            var/Refund
            if(Choice.NewCost)
                Refund = Choice.NewCost
            switch(Choice.Copyable)
                if(1) // these r maostly gone
                    Refund = TIER_1_COST
                if(2)
                    Refund = TIER_1_COST
                if(3)
                    Refund = TIER_2_COST
                if(4)
                    Refund = TIER_3_COST
                if(5)
                    Refund = TIER_4_COST
            if(istype(Choice, /obj/Skills/Buffs/NuStyle))
                if(Choice.SignatureTechnique > 0) Refund = 0
                else P.SignatureSelected -= Choice.name
                Refund += ((2**(Choice.SignatureTechnique+1)*10)) * max(0,(Choice.Mastery-1))
            else if(Choice.Mastery>1)
                Refund+=(Refund*(Choice.Mastery-1))
            if(Choice.name in P.SkillsLocked)
                P.SkillsLocked -= Choice.name
            P.RPPSpendable+=Refund
            P.RPPSpent-=Refund
            P << "You've refunded [Choice] for [Commas(Refund)] RPP."
            Log("Admin", "[ExtractInfo(src)] refunded [Choice] for [Commas(Refund)] RPP to [ExtractInfo(P)].")
            for(var/obj/Skills/S in P)
                if(Choice&&S)
                    if(S.type==Choice.type)
                        if(S.PreRequisite.len>0 && !istype(Choice, /obj/Skills/Buffs/NuStyle))
                            for(var/path in S.PreRequisite)
                                var/p=text2path(path)
                                var/obj/Skills/oldskill=new p
                                P.AddSkill(oldskill)
                                P << "The prerequisite skill for [Choice], [oldskill] has been readded to your contents."
                        del S
            for(var/obj/Skills/Buffs/NuStyle/s in src)
                src.StyleUnlock(s)



var/list/MagicList = list("Alchemy","Healing Herbs", "Refreshment Herbs", "Magic Herbs", "Toxic Herbs", "Philter Herbs", \
"ImprovedAlchemy","ToolEnchantment","ArmamentEnchantment","TomeCreation",\
"CrestCreation","SummoningMagic","SealingMagic","SpaceMagic","TimeMagic", \
"Stimulant Herbs", "Relaxant Herbs", "Numbing Herbs", "Distillation Process", "Mutagenic Herbs",\
"Spell Focii", "Artifact Manufacturing", "Magical Communication", "Magical Vehicles", "Warding Glyphs", \
"Tome Cleansing", "Tome Security", "Tome Translation", "Tome Binding", "Tome Excerpts", "Turf Sealing", "Object Sealing", \
"Teleportation", "Retrieval", "Bilocation", \
"Transmigration", "Lifespan Extension", "Temporal Displacement", "Temporal Acceleration", "Temporal Rewinding"/*, "RitualMagic", "Introductory Ritual Magics"*/)

/var/list/MagicSubList= list("Alchemy" = list("Healing Herbs", "Refreshment Herbs", "Magic Herbs", "Toxic Herbs", "Philter Herbs") ,\
"ImprovedAlchemy" = list("Stimulant Herbs", "Relaxant Herbs", "Numbing Herbs", "Distillation Process", "Mutagenic Herbs"),\
"ToolEnchantment" = list("Spell Focii", "Artifact Manufacturing", "Magical Communication", "Magical Vehicles", "Warding Glyphs"),\
"TomeCreation" = list("Tome Cleansing", "Tome Security", "Tome Translation", "Tome Binding", "Tome Excerpts"),\
"SealingMagic" = list("Turf Sealing", "Object Sealing", "Power Sealing", "Mobility Sealing", "Command Sealing"),\
"SpaceMagic" = list("Teleportation", "Retrieval", "Bilocation"),\
"TimeMagic" = list("Transmigration", "Lifespan Extension", "Temporal Displacement", "Temporal Acceleration", "Temporal Rewinding"),
/*"RitualMagic" = list("Introductory Ritual Magics")*/)




/mob/proc/generateMagicList()
    var/playerMagicList = list()
    for(var/x in knowledgeTracker.learnedMagic)
        if(x in MagicList)
            playerMagicList += x
    return playerMagicList

/mob/proc/checkMagicList(n)
    for(var/x in MagicSubList)
        if(n in MagicSubList[x])
            return x


/mob/proc/refundMagicTree(nameOfTree)
    var/actualName = checkMagicList(nameOfTree)
    var/cost = KnowledgeTree["[nameOfTree]"]["[actualName]"] // this should b the cost
    cost /= Imagination
    cost = round(cost)
    GiveRPP(cost)
    RPPSpent-=cost
    switch(nameOfTree)
        if("Turf Sealing")
            for(var/obj/Skills/Utility/Seal_Turf/st in src)
                del st
        if("Object Sealing")
            for(var/obj/Skills/Utility/Seal_Object/st in src)
                del st
        if("Alchemy")
            PotionTypes.Remove("Wild Herb")
        if("ImprovedAlchemy")
            if(src.CrestCreationUnlocked>=3&&src.ImprovedAlchemyUnlocked>=3)
                for(var/obj/Skills/Utility/Transmute/st in src)
                    del st
        if("ToolEnchantment")
            if(ToolEnchantmentUnlocked>=1)
                for(var/obj/Skills/Utility/Create_Magic_Circle/st in src)
                    del st
        if("ArmamentEnchantment")
            for(var/obj/Skills/Utility/Upgrade_Equipment/st in src)
                del st
        if("CrestCreation")
            for(var/obj/Skills/Utility/Create_Magic_Crest/st in src)
                del st
            if(CrestCreationUnlocked>=3&&ImprovedAlchemyUnlocked>=3)
                for(var/obj/Skills/Utility/Transmute/st in src)
                    del st
        if("SummoningMagic")
            for(var/obj/Skills/Utility/Summon_Entity/st in src)
                del st
        if("SealingMagic")
            for(var/obj/Skills/Utility/Seal_Break/st in src)
                del st
        if("SpaceMagic")
            if(SpaceMagicUnlocked>=3)
                for(var/obj/Skills/Blink/st in src)
                    del st
    knowledgeTracker.learnedKnowledge.Remove(nameOfTree)
    RemoveUnlockedTechnology(nameOfTree)
/mob/proc/RemoveUnlockedTechnology(var/x)
    if(x in list("Weapons", "Armor", "Weighted Clothing", "Smelting", "Locksmithing"))
        src.ForgingUnlocked--
    if(x in list("Molecular Technology", "Light Alloys", "Shock Absorbers", "Advanced Plating", "Modular Weaponry"))
        src.RepairAndConversionUnlocked--
    if(x in list("Medkits", "Fast Acting Medicine", "Enhancers", "Anesthetics", "Automated Dispensers"))
        src.MedicineUnlocked--
    if(x in list("Regenerator Tanks", "Prosthetic Limbs", "Genetic Manipulation", "Regenerative Medicine", "Revival Protocol"))
        src.ImprovedMedicalTechnologyUnlocked--
    if(x in list("Wide Area Transmissions", "Espionage Equipment", "Surveilance", "Drones", "Local Range Devices"))
        src.TelecommunicationsUnlocked--
    if(x in list("Scouters", "Obfuscation Equipment", "Satellite Surveilance", "Combat Scanning", "EM Wave Projectors"))
        src.AdvancedTransmissionTechnologyUnlocked--
    if(x in list("Hazard Suits", "Force Shielding", "Jet Propulsion", "Power Generators"))
        src.EngineeringUnlocked--
    if(x in list("Android Creation", "Conversion Modules", "Enhancement Chips", "Involuntary Implantation"))
        src.CyberEngineeringUnlocked--
    if(x in list("Assault Weaponry", "Missile Weaponry", "Melee Weaponry", "Thermal Weaponry", "Blast Shielding"))
        src.MilitaryTechnologyUnlocked--
    if(x in list("Powered Armor Specialization", "Armorpiercing Weaponry", "Impact Weaponry", "Hydraulic Weaponry"))
        src.MilitaryEngineeringUnlocked--

    if(x in list("Healing Herbs", "Refreshment Herbs", "Magic Herbs", "Toxic Herbs", "Philter Herbs"))
        src.AlchemyUnlocked--
    if(x in list("Stimulant Herbs", "Relaxant Herbs", "Numbing Herbs", "Distillation Process", "Mutagenic Herbs"))
        src.ImprovedAlchemyUnlocked--
    if(x in list("Spell Focii", "Artifact Manufacturing", "Magical Communication", "Magical Vehicles", "Warding Glyphs"))
        src.ToolEnchantmentUnlocked--
    if(x in list("Tome Cleansing", "Tome Security", "Tome Translation", "Tome Binding", "Tome Excerpts"))
        src.TomeCreationUnlocked--
    if(x in list("Turf Sealing", "Object Sealing", "Power Sealing", "Mobility Sealing", "Command Sealing"))
        src.SealingMagicUnlocked--
    if(x in list("Teleportation", "Retrieval", "Bilocation", "Dimensional Manipulation", "Dimensional Restriction"))
        src.SpaceMagicUnlocked--
    if(x in list("Transmigration", "Lifespan Extension", "Temporal Displacement", "Temporal Acceleration", "Temporal Rewinding"))
        src.TimeMagicUnlocked--

    src.knowledgeTracker.learnedKnowledge.Remove(x)