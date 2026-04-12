magic_node/air_tree
    getTreeAutohitImage()
        return AIR_UNLOCKED_AUTOHIT
    getTreeBuffImage()
        return AIR_UNLOCKED_BUFF
    getTreeLineImage()
        return AIR_UNLOCKED_LINE
    getTreeMagePassiveImage()
        return AIR_UNLOCKED_MAGEP
    getTreePinnacleImage()
        return AIR_UNLOCKED_PINNACLE
    getTreeSpellPassiveImage()
        return AIR_UNLOCKED_SPELLP

    air_node_south
        name=AIR_NODE_ENTRY
        xLoc = AIR_NODE_ENTRY_X;
        yLoc = AIR_NODE_ENTRY_Y;
        nodeType = "Autohit"
        unlocksNodes = list(AIR_NODE_EAST, AIR_NODE_WEST, AIR_NODE_SOUTH2);
    air_node_south2
        name=AIR_NODE_SOUTH2
        xLoc = AIR_NODE_SOUTH2_X
        yLoc = AIR_NODE_SOUTH2_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/air/paralyzer);
        unlocksNodes = list(AIR_NODE_EAST2, AIR_NODE_WEST2, AIR_NODE_SOUTH3);
    air_node_south3
        name=AIR_NODE_SOUTH3
        xLoc = AIR_NODE_SOUTH3_X
        yLoc = AIR_NODE_SOUTH3_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/air/ShockMastery);
        unlocksNodes = list(AIR_NODE_EAST3, AIR_NODE_WEST3, AIR_NODE_SOUTH2);
    air_node_east
        name=AIR_NODE_EAST
        xLoc = AIR_NODE_EAST_X
        yLoc = AIR_NODE_EAST_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/air/ShockMastery);
        unlocksNodes = list(AIR_NODE_CROWN, AIR_NODE_EAST2);
    air_node_east2
        name=AIR_NODE_EAST2
        xLoc = AIR_NODE_EAST2_X
        yLoc = AIR_NODE_EAST2_Y
        nodeType = "Buff"
        unlocksNodes = list(AIR_NODE_EAST, AIR_NODE_EAST3, AIR_NODE_NORTH2, AIR_NODE_SOUTH2);
    air_node_east3
        name=AIR_NODE_EAST3
        xLoc = AIR_NODE_EAST3_X
        yLoc = AIR_NODE_EAST3_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/air/synapse);
        unlocksNodes = list(AIR_NODE_EAST2, AIR_NODE_NORTH3, AIR_NODE_SOUTH3);
    air_node_west
        name=AIR_NODE_WEST
        xLoc = AIR_NODE_WEST_X
        yLoc = AIR_NODE_WEST_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/air/pinpoint);
        unlocksNodes = list(AIR_NODE_CROWN, AIR_NODE_WEST2);
    air_node_west2
        name=AIR_NODE_WEST2
        xLoc = AIR_NODE_WEST2_X
        yLoc = AIR_NODE_WEST2_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/air/FleetFooted);
        unlocksNodes = list(AIR_NODE_WEST, AIR_NODE_WEST3, AIR_NODE_NORTH2, AIR_NODE_SOUTH2);
    air_node_west3
        name=AIR_NODE_WEST3
        xLoc = AIR_NODE_WEST3_X
        yLoc = AIR_NODE_WEST3_Y
        nodeType = "Line"
        unlocksNodes = list(AIR_NODE_NORTH3, AIR_NODE_SOUTH3, AIR_NODE_WEST2);
    air_node_north
        name=AIR_NODE_CROWN
        xLoc = AIR_NODE_CROWN_X
        yLoc = AIR_NODE_CROWN_Y
        nodeType = "Pinnacle"
        grantsMagePassives = list(/mage_passive/air/Aloft);
        unlocksNodes = list(AIR_NODE_NORTH2, AIR_NODE_WEST3, AIR_NODE_EAST3);
    air_node_north2
        name=AIR_NODE_NORTH2
        xLoc = AIR_NODE_NORTH2_X
        yLoc = AIR_NODE_NORTH2_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/air/whirlwind);
        unlocksNodes = list(AIR_NODE_CROWN, AIR_NODE_NORTH3, AIR_NODE_EAST2, AIR_NODE_WEST2);
    air_node_north3
        name=AIR_NODE_NORTH3
        xLoc = AIR_NODE_NORTH3_X
        yLoc = AIR_NODE_NORTH3_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/air/FleetFooted);
        unlocksNodes = list(AIR_NODE_EAST3, AIR_NODE_WEST3, AIR_NODE_NORTH2);
