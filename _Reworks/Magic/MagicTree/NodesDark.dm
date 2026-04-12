magic_node/dark_tree
    getTreeAutohitImage()
        return DARK_UNLOCKED_AUTOHIT
    getTreeLineImage()
        return DARK_UNLOCKED_LINE
    getTreeMagePassiveImage()
        return DARK_UNLOCKED_MAGEP
    getTreePinnacleImage()
        return DARK_UNLOCKED_PINNACLE
    getTreeProjectileImage()
        return DARK_UNLOCKED_PROJ
    getTreeSpellPassiveImage()
        return DARK_UNLOCKED_SPELLP

    dark_node_entry
        name=DARK_NODE_ENTRY
        xLoc = DARK_NODE_ENTRY_X;
        yLoc = DARK_NODE_ENTRY_Y;
        nodeType = "Autohit"
        unlocksNodes = list(DARK_NODE_11, DARK_NODE_12);
    dark_node_11
        name=DARK_NODE_11
        xLoc = DARK_NODE_11_X
        yLoc = DARK_NODE_11_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/dark/Shadowbringer)
        unlocksNodes = list(DARK_NODE_21);
    dark_node_12
        name=DARK_NODE_12
        xLoc = DARK_NODE_12_X
        yLoc = DARK_NODE_12_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/dark/disaster)
        unlocksNodes = list(DARK_NODE_24);
    dark_node_21
        name=DARK_NODE_21
        xLoc = DARK_NODE_21_X
        yLoc = DARK_NODE_21_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/dark/hemomantic)
        unlocksNodes = list(DARK_NODE_41, DARK_NODE_11);
    dark_node_22
        name=DARK_NODE_22
        xLoc = DARK_NODE_22_X
        yLoc = DARK_NODE_22_Y
        nodeType = "Projectile"
        unlocksNodes = list(DARK_NODE_23, DARK_NODE_3);
    dark_node_23
        name=DARK_NODE_23
        xLoc = DARK_NODE_23_X
        yLoc = DARK_NODE_23_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/dark/Shadowbringer)
        unlocksNodes = list(DARK_NODE_22, DARK_NODE_24);
    dark_node_24
        name=DARK_NODE_24
        xLoc = DARK_NODE_24_X
        yLoc = DARK_NODE_24_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/dark/ravenous)
        unlocksNodes = list(DARK_NODE_23, DARK_NODE_12);
    dark_node_3
        name=DARK_NODE_3
        xLoc = DARK_NODE_3_X
        yLoc = DARK_NODE_3_Y
        nodeType = "Line"
        unlocksNodes = list(DARK_NODE_42, DARK_NODE_22);
    dark_node_41
        name=DARK_NODE_41
        xLoc = DARK_NODE_41_X
        yLoc = DARK_NODE_41_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/dark/Iconoclast)
        unlocksNodes = list(DARK_NODE_51, DARK_NODE_21);
    dark_node_42
        name=DARK_NODE_42
        xLoc = DARK_NODE_42_X
        yLoc = DARK_NODE_42_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/dark/vampyric)
        unlocksNodes = list(DARK_NODE_52, DARK_NODE_3);
    dark_node_51
        name=DARK_NODE_51
        xLoc = DARK_NODE_51_X
        yLoc = DARK_NODE_51_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/dark/Iconoclast)
        unlocksNodes = list(DARK_NODE_CROWN, DARK_NODE_41);
    dark_node_52
        name=DARK_NODE_52
        xLoc = DARK_NODE_52_X
        yLoc = DARK_NODE_52_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/dark/anima)
        unlocksNodes = list(DARK_NODE_CROWN, DARK_NODE_42);
    dark_node_crown
        name=DARK_NODE_CROWN
        xLoc = DARK_NODE_CROWN_X
        yLoc = DARK_NODE_CROWN_Y
        nodeType = "Pinnacle"
        grantsMagePassives = list(/mage_passive/dark/Survivor)
        unlocksNodes = list(DARK_NODE_51, DARK_NODE_52);
