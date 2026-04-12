/magic_node/water_tree/
    getTreeAutohitImage()
        return WATER_UNLOCKED_AUTOHIT
    getTreeDebuffImage()
        return WATER_UNLOCKED_DEBUFF
    getTreeMagePassiveImage()
        return WATER_UNLOCKED_MAGEP
    getTreePinnacleImage()
        return WATER_UNLOCKED_PINNACLE
    getTreeProjectileImage()
        return WATER_UNLOCKED_PROJ
    getTreeSpellPassiveImage()
        return WATER_UNLOCKED_SPELLP

    water_entry_node
        name=WATER_NODE_ENTRY;
        xLoc = WATER_NODE_ENTRY_X;
        yLoc = WATER_NODE_ENTRY_Y;
        nodeType = "Autohit"
        unlocksNodes = list(WATER_NODE_21, WATER_NODE_22);

    water_node_21
        name=WATER_NODE_21;
        xLoc = WATER_NODE_21_X;
        yLoc = WATER_NODE_21_Y;
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/water/barotrauma);
        unlocksNodes = list(WATER_NODE_31, WATER_NODE_CENTER);

    water_node_22
        name=WATER_NODE_22;
        xLoc = WATER_NODE_22_X;
        yLoc = WATER_NODE_22_Y;
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/water/overflow);
        unlocksNodes = list(WATER_NODE_32, WATER_NODE_CENTER);

    water_node_31
        name=WATER_NODE_31;
        xLoc = WATER_NODE_31_X;
        yLoc = WATER_NODE_31_Y;
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/water/ChillMastery);
        unlocksNodes = list(WATER_NODE_41, WATER_NODE_21);

    water_node_32
        name=WATER_NODE_32;
        xLoc = WATER_NODE_32_X;
        yLoc = WATER_NODE_32_Y;
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/water/ChillMastery);
        unlocksNodes = list(WATER_NODE_42, WATER_NODE_22);

    water_node_41
        name=WATER_NODE_41;
        xLoc = WATER_NODE_41_X;
        yLoc = WATER_NODE_41_Y;
        nodeType = "Debuff"
        unlocksNodes = list(WATER_NODE_CENTER, WATER_NODE_61, WATER_NODE_31);

    water_node_42
        name=WATER_NODE_42;
        xLoc = WATER_NODE_42_X;
        yLoc = WATER_NODE_42_Y;
        nodeType = "Projectile"
        unlocksNodes = list(WATER_NODE_CENTER, WATER_NODE_62, WATER_NODE_32);

    water_node_center
        name=WATER_NODE_CENTER;
        xLoc = WATER_NODE_CENTER_X;
        yLoc = WATER_NODE_CENTER_Y;
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/water/FluidTechnique);
        unlocksNodes = list(WATER_NODE_21, WATER_NODE_22, WATER_NODE_41, WATER_NODE_42);

    water_node_61
        name=WATER_NODE_61;
        xLoc = WATER_NODE_61_X;
        yLoc = WATER_NODE_61_Y;
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/water/flashfreeze);
        unlocksNodes = list(WATER_NODE_41, WATER_NODE_TOP);

    water_node_62
        name=WATER_NODE_62;
        xLoc = WATER_NODE_62_X;
        yLoc = WATER_NODE_62_Y;
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/water/sublimate);
        unlocksNodes = list(WATER_NODE_42, WATER_NODE_TOP);

    water_node_top
        name=WATER_NODE_TOP;
        xLoc = WATER_NODE_TOP_X;
        yLoc = WATER_NODE_TOP_Y;
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/water/FluidTechnique);
        unlocksNodes = list(WATER_NODE_61, WATER_NODE_62, WATER_NODE_CROWN);

    water_node_crown
        name=WATER_NODE_CROWN;
        xLoc = WATER_NODE_CROWN_X;
        yLoc = WATER_NODE_CROWN_Y;
        nodeType = "Pinnacle"
        grantsMagePassives = list(/mage_passive/water/Awash);
        unlocksNodes = list(WATER_NODE_TOP);