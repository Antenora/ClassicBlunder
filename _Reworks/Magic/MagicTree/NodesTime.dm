magic_node/time_tree
    getTreeAOEImage()
        return TIME_UNLOCKED_AOE
    getTreeBuffImage()
        return TIME_UNLOCKED_BUFF
    getTreeDebuffImage()
        return TIME_UNLOCKED_DEBUFF
    getTreeMagePassiveImage()
        return TIME_UNLOCKED_MAGEP
    getTreePinnacleImage()
        return TIME_UNLOCKED_PINNACLE
    getTreeSpellPassiveImage()
        return TIME_UNLOCKED_SPELLP

    time_node_entry
        name=TIME_NODE_ENTRY
        xLoc = TIME_NODE_ENTRY_X
        yLoc = TIME_NODE_ENTRY_Y
        nodeType = "AOE"
        grantsSkills = list(/obj/Skills/AutoHit/Magic/Time/Tempus_Cessat)
        unlocksNodes = list(TIME_NODE_12, TIME_NODE_13);
    
    time_node_11
        name=TIME_NODE_11
        xLoc = TIME_NODE_11_X;
        yLoc = TIME_NODE_11_Y;
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/time/chargeflux)
        unlocksNodes = list(TIME_NODE_21, TIME_NODE_12);
    
    time_node_12
        name=TIME_NODE_12
        xLoc = TIME_NODE_12_X;
        yLoc = TIME_NODE_12_Y;
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/time/Past)
        unlocksNodes = list(TIME_NODE_11, TIME_NODE_33);
    
    time_node_13
        name=TIME_NODE_13
        xLoc = TIME_NODE_13_X;
        yLoc = TIME_NODE_13_Y;
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/time/stasis)
        unlocksNodes = list(TIME_NODE_32, TIME_NODE_14);
    
    time_node_14
        name=TIME_NODE_14
        xLoc = TIME_NODE_14_X;
        yLoc = TIME_NODE_14_Y;
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/time/Past)
        unlocksNodes = list(TIME_NODE_13, TIME_NODE_22);
    
    time_node_21
        name=TIME_NODE_21
        xLoc = TIME_NODE_21_X
        yLoc = TIME_NODE_21_Y
        nodeType = "Buff"
        grantsSkills = list(/obj/Skills/Buffs/SlotlessBuffs/Magic/Time/Haste)
        unlocksNodes = list(TIME_NODE_31, TIME_NODE_11);
    
    time_node_22
        name=TIME_NODE_22
        xLoc = TIME_NODE_22_X
        yLoc = TIME_NODE_22_Y
        nodeType = "Debuff"
        grantsSkills = list(/obj/Skills/Buffs/SlotlessBuffs/Magic/Time/Wither)
        unlocksNodes = list(TIME_NODE_34, TIME_NODE_14);
    
    time_node_31
        name=TIME_NODE_31
        xLoc = TIME_NODE_31_X
        yLoc = TIME_NODE_31_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/time/Present)
        unlocksNodes = list(TIME_NODE_21, TIME_NODE_32);
    
    time_node_32
        name=TIME_NODE_32
        xLoc = TIME_NODE_32_X
        yLoc = TIME_NODE_32_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/time/passage)
        unlocksNodes = list(TIME_NODE_31, TIME_NODE_13, TIME_NODE_CROWN);
    
    time_node_33
        name=TIME_NODE_33
        xLoc = TIME_NODE_33_X
        yLoc = TIME_NODE_33_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/time/Present)
        unlocksNodes = list(TIME_NODE_12, TIME_NODE_CROWN, TIME_NODE_34);
    
    time_node_34
        name=TIME_NODE_34
        xLoc = TIME_NODE_34_X
        yLoc = TIME_NODE_34_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/time/paradox)
        unlocksNodes = list(TIME_NODE_33, TIME_NODE_22);
    
    time_node_crown
        name=TIME_NODE_CROWN
        xLoc = TIME_NODE_CROWN_X
        yLoc = TIME_NODE_CROWN_Y
        nodeType = "Pinnacle"
        grantsMagePassives = list(/mage_passive/time/Future)
        unlocksNodes = list(TIME_NODE_32, TIME_NODE_33);
