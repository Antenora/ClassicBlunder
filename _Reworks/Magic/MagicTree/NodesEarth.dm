magic_node/earth_tree
    getTreeAOEImage()
        return EARTH_UNLOCKED_AOE
    getTreeBuffImage()
        return EARTH_UNLOCKED_BUFF
    getTreeDebuffImage()
        return EARTH_UNLOCKED_DEBUFF
    getTreeMagePassiveImage()
        return EARTH_UNLOCKED_MAGEP
    getTreePinnacleImage()
        return EARTH_UNLOCKED_PINNACLE
    getTreeSpellPassiveImage()
        return EARTH_UNLOCKED_SPELLP
    
    earth_node_entry
        name=EARTH_NODE_ENTRY
        xLoc = EARTH_NODE_ENTRY_X
        yLoc = EARTH_NODE_ENTRY_Y
        nodeType = "AOE"
        grantsSkills = list(/obj/Skills/AutoHit/Magic/Earth/Seismic_Entry)
        unlocksNodes = list(EARTH_NODE_12, EARTH_NODE_13, EARTH_NODE_21);
    earth_node_12
        name=EARTH_NODE_12
        xLoc = EARTH_NODE_12_X
        yLoc = EARTH_NODE_12_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/earth/ShatterMastery);
        unlocksNodes = list(EARTH_NODE_22);
    earth_node_13
        name=EARTH_NODE_13
        xLoc = EARTH_NODE_13_X
        yLoc = EARTH_NODE_13_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/earth/toxify)
        unlocksNodes = list(EARTH_NODE_23);
    
    earth_node_21
        name=EARTH_NODE_21
        xLoc = EARTH_NODE_21_X
        yLoc = EARTH_NODE_21_Y
        nodeType = "Buff"
        grantsSkills = list(/obj/Skills/Buffs/SlotlessBuffs/Magic/Earth/Ward_of_Stone)
        unlocksNodes = list(EARTH_NODE_22, EARTH_NODE_23, EARTH_NODE_31);
    earth_node_22
        name=EARTH_NODE_22
        xLoc = EARTH_NODE_22_X
        yLoc = EARTH_NODE_22_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/earth/ShatterMastery);
        unlocksNodes = list(EARTH_NODE_21, EARTH_NODE_32, EARTH_NODE_12);
    earth_node_23
        name=EARTH_NODE_23
        xLoc = EARTH_NODE_23_X
        yLoc = EARTH_NODE_23_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/earth/rust)
        unlocksNodes = list(EARTH_NODE_33, EARTH_NODE_21, EARTH_NODE_13);
    
    earth_node_31
        name=EARTH_NODE_31
        xLoc = EARTH_NODE_31_X
        yLoc = EARTH_NODE_31_Y
        nodeType = "Debuff"
        grantsSkills = list(/obj/Skills/Buffs/SlotlessBuffs/Magic/Earth/Prickly_Ballet)
        unlocksNodes = list(EARTH_NODE_CROWN, EARTH_NODE_32, EARTH_NODE_33);
    earth_node_32
        name=EARTH_NODE_32
        xLoc = EARTH_NODE_32_X
        yLoc = EARTH_NODE_32_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/earth/FirmGuard);
        unlocksNodes = list(EARTH_NODE_42, EARTH_NODE_22, EARTH_NODE_31);
    earth_node_33
        name=EARTH_NODE_33
        xLoc = EARTH_NODE_33_X
        yLoc = EARTH_NODE_33_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/earth/muddy)
        unlocksNodes = list(EARTH_NODE_43, EARTH_NODE_23, EARTH_NODE_31);
    
    earth_node_pinnacle
        name=EARTH_NODE_CROWN
        xLoc = EARTH_NODE_CROWN_X
        yLoc = EARTH_NODE_CROWN_Y
        nodeType = "Pinnacle"
        grantsMagePassives = list(/mage_passive/earth/Aerde);
        unlocksNodes = list(EARTH_NODE_42, EARTH_NODE_43, EARTH_NODE_31);
    earth_node_42
        name=EARTH_NODE_42
        xLoc = EARTH_NODE_42_X
        yLoc = EARTH_NODE_42_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/earth/FirmGuard);
        unlocksNodes = list(EARTH_NODE_CROWN, EARTH_NODE_32);
    earth_node_43
        name=EARTH_NODE_43
        xLoc = EARTH_NODE_43_X
        yLoc = EARTH_NODE_43_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/earth/steelize)
        unlocksNodes = list(EARTH_NODE_CROWN, EARTH_NODE_33);
    