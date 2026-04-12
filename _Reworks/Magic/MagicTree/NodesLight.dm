magic_node/light_tree
    getTreeBuffImage()
        return LIGHT_UNLOCKED_BUFF
    getTreeLineImage()
        return LIGHT_UNLOCKED_LINE
    getTreeMagePassiveImage()
        return LIGHT_UNLOCKED_MAGEP
    getTreePinnacleImage()
        return LIGHT_UNLOCKED_PINNACLE
    getTreeProjectileImage()
        return LIGHT_UNLOCKED_PROJ
    getTreeSpellPassiveImage()
        return LIGHT_UNLOCKED_SPELLP
    
    light_node_entry
        name=LIGHT_NODE_ENTRY
        xLoc = LIGHT_NODE_ENTRY_X
        yLoc = LIGHT_NODE_ENTRY_Y
        nodeType = "Line"
        unlocksNodes = list(LIGHT_NODE_12);
    
    light_node_12
        name=LIGHT_NODE_12
        xLoc = LIGHT_NODE_12_X;
        yLoc = LIGHT_NODE_12_Y;
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/light/sanctify)
        unlocksNodes = list(LIGHT_NODE_13);
    
    light_node_13
        name=LIGHT_NODE_13
        xLoc = LIGHT_NODE_13_X;
        yLoc = LIGHT_NODE_13_Y;
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/light/Warden);
        unlocksNodes = list(LIGHT_NODE_23, LIGHT_NODE_33, LIGHT_NODE_43);
    
    light_node_21
        name=LIGHT_NODE_21
        xLoc = LIGHT_NODE_21_X;
        yLoc = LIGHT_NODE_21_Y;
        nodeType = "Buff"
        unlocksNodes = list(LIGHT_NODE_22);
    
    light_node_22
        name=LIGHT_NODE_22
        xLoc = LIGHT_NODE_22_X;
        yLoc = LIGHT_NODE_22_Y;
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/light/enshrine)
        unlocksNodes = list(LIGHT_NODE_23, LIGHT_NODE_21);
    
    light_node_23
        name=LIGHT_NODE_23
        xLoc = LIGHT_NODE_23_X
        yLoc = LIGHT_NODE_23_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/light/Warden);
        unlocksNodes = list(LIGHT_NODE_43, LIGHT_NODE_13, LIGHT_NODE_22);
    
    light_node_31
        name=LIGHT_NODE_31
        xLoc = LIGHT_NODE_31_X
        yLoc = LIGHT_NODE_31_Y
        nodeType = "Projectile"
        unlocksNodes = list(LIGHT_NODE_32);
    
    light_node_32
        name=LIGHT_NODE_32
        xLoc = LIGHT_NODE_32_X
        yLoc = LIGHT_NODE_32_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/light/mirrored)
        unlocksNodes = list(LIGHT_NODE_33, LIGHT_NODE_31);
    
    light_node_33
        name=LIGHT_NODE_33
        xLoc = LIGHT_NODE_33_X
        yLoc = LIGHT_NODE_33_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/light/Seeker);
        unlocksNodes = list(LIGHT_NODE_43, LIGHT_NODE_13, LIGHT_NODE_32);

    light_node_crown
        name=LIGHT_NODE_CROWN
        xLoc = LIGHT_NODE_CROWN_X
        yLoc = LIGHT_NODE_CROWN_Y
        nodeType = "Pinnacle"
        grantsMagePassives = list(/mage_passive/light/Mender);
        unlocksNodes = list(LIGHT_NODE_42);
    
    light_node_42
        name=LIGHT_NODE_42
        xLoc = LIGHT_NODE_42_X
        yLoc = LIGHT_NODE_42_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/light/cleansing)
        unlocksNodes = list(LIGHT_NODE_CROWN, LIGHT_NODE_43);
    
    light_node_43
        name=LIGHT_NODE_43
        xLoc = LIGHT_NODE_43_X
        yLoc = LIGHT_NODE_43_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/light/Seeker);
        unlocksNodes = list(LIGHT_NODE_23, LIGHT_NODE_33, LIGHT_NODE_42, LIGHT_NODE_13);
