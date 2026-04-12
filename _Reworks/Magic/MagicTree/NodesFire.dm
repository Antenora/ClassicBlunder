magic_node/fire_tree
    getTreeAOEImage()
        return FIRE_UNLOCKED_AOE
    getTreeLineImage()
        return FIRE_UNLOCKED_LINE
    getTreeMagePassiveImage()
        return FIRE_UNLOCKED_MAGEP
    getTreePinnacleImage()
        return FIRE_UNLOCKED_PINNACLE
    getTreeProjectileImage()
        return FIRE_UNLOCKED_PROJ
    getTreeSpellPassiveImage()
        return FIRE_UNLOCKED_SPELLP
    
    fire_node_entry
        name=FIRE_NODE_ENTRY
        xLoc = FIRE_NODE_ENTRY_X
        yLoc = FIRE_NODE_ENTRY_Y
        nodeType = "AOE"
        grantsSkills = list(/obj/Skills/AutoHit/Magic/Fire/Blazing_Whip)
        unlocksNodes = list(FIRE_NODE_21, FIRE_NODE_22);
    
    fire_node_21
        name=FIRE_NODE_21
        xLoc = FIRE_NODE_21_X;
        yLoc = FIRE_NODE_21_Y;
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/fire/BurnMastery);
        unlocksNodes = list(FIRE_NODE_31);

    fire_node_22
        name=FIRE_NODE_22
        xLoc = FIRE_NODE_22_X;
        yLoc = FIRE_NODE_22_Y;
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/fire/BurnMastery);
        unlocksNodes = list(FIRE_NODE_32);
    
    fire_node_31
        name=FIRE_NODE_31
        xLoc = FIRE_NODE_31_X;
        yLoc = FIRE_NODE_31_Y;
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/fire/blaze);
        unlocksNodes = list(FIRE_NODE_21, FIRE_NODE_41);
    
    fire_node_32
        name=FIRE_NODE_32
        xLoc = FIRE_NODE_32_X;
        yLoc = FIRE_NODE_32_Y;
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/fire/magma);
        unlocksNodes = list(FIRE_NODE_22, FIRE_NODE_42);
    
    fire_node_41
        name=FIRE_NODE_41
        xLoc = FIRE_NODE_41_X
        yLoc = FIRE_NODE_41_Y
        nodeType = "Line"
        grantsSkills = list(/obj/Skills/Projectile/Fire/Dragon_Arc);
        unlocksNodes = list(FIRE_NODE_51, FIRE_NODE_31);
    
    fire_node_42
        name=FIRE_NODE_42
        xLoc = FIRE_NODE_42_X
        yLoc = FIRE_NODE_42_Y
        nodeType = "Projectile"
        grantsSkills = list(/obj/Skills/Projectile/Fire/Fireball);
        unlocksNodes = list(FIRE_NODE_52, FIRE_NODE_32);
    
    fire_node_51
        name=FIRE_NODE_51
        xLoc = FIRE_NODE_51_X
        yLoc = FIRE_NODE_51_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/fire/ScorchedForm);
        unlocksNodes = list(FIRE_NODE_61, FIRE_NODE_41);

    fire_node_52
        name=FIRE_NODE_52
        xLoc = FIRE_NODE_52_X
        yLoc = FIRE_NODE_52_Y
        nodeType = "Mage Passive"
        grantsMagePassives = list(/mage_passive/fire/ScorchedForm);
        unlocksNodes = list(FIRE_NODE_62, FIRE_NODE_42);
    
    fire_node_61
        name=FIRE_NODE_61
        xLoc = FIRE_NODE_61_X
        yLoc = FIRE_NODE_61_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/fire/ashfield);
        unlocksNodes = list(FIRE_NODE_CROWN, FIRE_NODE_51);
    
    fire_node_62
        name=FIRE_NODE_62
        xLoc = FIRE_NODE_62_X
        yLoc = FIRE_NODE_62_Y
        nodeType = "Spell Passive"
        grantsSpellPassives = list(/spell_passive/fire/nuclear);
        unlocksNodes = list(FIRE_NODE_CROWN, FIRE_NODE_52);
    
    fire_node_crown
        name=FIRE_NODE_CROWN
        xLoc = FIRE_NODE_CROWN_X
        yLoc = FIRE_NODE_CROWN_Y
        nodeType = "Pinnacle"
        grantsMagePassives = list(/mage_passive/fire/Alight);
        unlocksNodes = list(FIRE_NODE_51, FIRE_NODE_52);
