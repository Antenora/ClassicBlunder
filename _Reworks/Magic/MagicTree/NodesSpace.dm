magic_node/space_tree
    getTreeAOEImage()
        return SPACE_UNLOCKED_AOE
    getTreeAutohitImage()
        return SPACE_UNLOCKED_AUTOHIT
    getTreeDebuffImage()
        return SPACE_UNLOCKED_DEBUFF
    getTreeMagePassiveImage()
        return SPACE_UNLOCKED_MAGEP
    getTreePinnacleImage()
        return SPACE_UNLOCKED_PINNACLE
    getTreeSpellPassiveImage()
        return SPACE_UNLOCKED_SPELLP

    space_node_entry
        name=SPACE_NODE_ENTRY
        xLoc = SPACE_NODE_ENTRY_X
        yLoc = SPACE_NODE_ENTRY_Y
        nodeType = "AOE"
        unlocksNodes = list(SPACE_NODE_21, SPACE_NODE_22);
    
    space_node_21
        name=SPACE_NODE_21
        xLoc = SPACE_NODE_21_X;
        yLoc = SPACE_NODE_21_Y;
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/space/Relativity)
        unlocksNodes = list(SPACE_NODE_31, SPACE_NODE_32);
    
    space_node_22
        name=SPACE_NODE_22
        xLoc = SPACE_NODE_22_X;
        yLoc = SPACE_NODE_22_Y;
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/space/constellation)
        unlocksNodes = list(SPACE_NODE_32, SPACE_NODE_33);
    
    space_node_31
        name=SPACE_NODE_31
        xLoc = SPACE_NODE_31_X;
        yLoc = SPACE_NODE_31_Y;
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/space/nebula)
        unlocksNodes = list(SPACE_NODE_41, SPACE_NODE_42, SPACE_NODE_21);
    
    space_node_32
        name=SPACE_NODE_32
        xLoc = SPACE_NODE_32_X;
        yLoc = SPACE_NODE_32_Y;
        nodeType = "Autohit"
        unlocksNodes = list(SPACE_NODE_42, SPACE_NODE_43, SPACE_NODE_5, SPACE_NODE_21, SPACE_NODE_22);
    
    space_node_33
        name=SPACE_NODE_33
        xLoc = SPACE_NODE_33_X
        yLoc = SPACE_NODE_33_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/space/Relativity)
        unlocksNodes = list(SPACE_NODE_43, SPACE_NODE_44, SPACE_NODE_22);
    
    space_node_41
        name=SPACE_NODE_41
        xLoc = SPACE_NODE_41_X
        yLoc = SPACE_NODE_41_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/space/quasar)
        unlocksNodes = list(SPACE_NODE_42, SPACE_NODE_31);
    
    space_node_42
        name=SPACE_NODE_42
        xLoc = SPACE_NODE_42_X
        yLoc = SPACE_NODE_42_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/space/supernova)
        unlocksNodes = list(SPACE_NODE_41, SPACE_NODE_5, SPACE_NODE_31, SPACE_NODE_32);
    
    space_node_43
        name=SPACE_NODE_43
        xLoc = SPACE_NODE_43_X
        yLoc = SPACE_NODE_43_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/space/Linearity)
        unlocksNodes = list(SPACE_NODE_5, SPACE_NODE_32, SPACE_NODE_44);
    
    space_node_44
        name=SPACE_NODE_44
        xLoc = SPACE_NODE_44_X
        yLoc = SPACE_NODE_44_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/space/Linearity)
        unlocksNodes = list(SPACE_NODE_43, SPACE_NODE_33);
    
    space_node_5
        name=SPACE_NODE_5
        xLoc = SPACE_NODE_5_X
        yLoc = SPACE_NODE_5_Y
        nodeType = "Debuff"
        unlocksNodes = list(SPACE_NODE_42, SPACE_NODE_43, SPACE_NODE_32, SPACE_NODE_CROWN);
    
    space_node_crown
        name=SPACE_NODE_CROWN
        xLoc = SPACE_NODE_CROWN_X
        yLoc = SPACE_NODE_CROWN_Y
        nodeType = "Pinnacle"
        grantsMagePassives = list(/mage_passive/space/Kinematics)
        unlocksNodes = list(SPACE_NODE_5);
