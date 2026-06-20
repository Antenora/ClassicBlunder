#define MAGICLESS_RACES list(ANDROID, NOBODY)
globalTracker/var/
    list/WaterTreeNodes=list();
    list/FireTreeNodes=list();
    list/AirTreeNodes=list();
    list/EarthTreeNodes=list();
    list/LightTreeNodes=list();
    list/TimeTreeNodes=list();
    list/DarkTreeNodes=list();
    list/SpaceTreeNodes=list();

/proc/initMagicNodes()
    clearMagicNodes();
    initWaterTree();
    initFireTree();
    initAirTree();
    initEarthTree();
    initLightTree();
    initTimeTree();
    initDarkTree();
    initSpaceTree();
    getAllSpellPassives();
/proc/clearMagicNodes()
    glob.WaterTreeNodes=list();//resetti the spaghetti
    glob.FireTreeNodes=list();
    glob.AirTreeNodes=list();
    glob.EarthTreeNodes=list();
    glob.LightTreeNodes=list();
    glob.TimeTreeNodes=list();
    glob.DarkTreeNodes=list();
    glob.SpaceTreeNodes=list();
/proc/
    initWaterTree()
        var/list/nodes = list()
        for(var/t in subtypesof(/magic_node/water_tree))
            if(!ispath(t)) continue
            var/magic_node/mn = new t
            if(mn && mn.name)
                nodes[mn.name] = mn
        glob.WaterTreeNodes = nodes
    initFireTree()
        var/list/nodes = list()
        for(var/t in subtypesof(/magic_node/fire_tree))
            if(!ispath(t)) continue
            var/magic_node/mn = new t
            if(mn && mn.name)
                nodes[mn.name] = mn
        glob.FireTreeNodes = nodes
    initAirTree()
        var/list/nodes = list()
        for(var/t in subtypesof(/magic_node/air_tree))
            if(!ispath(t)) continue
            var/magic_node/mn = new t
            if(mn && mn.name)
                nodes[mn.name] = mn
        glob.AirTreeNodes = nodes
    initEarthTree()
        var/list/nodes = list()
        for(var/t in subtypesof(/magic_node/earth_tree))
            if(!ispath(t)) continue
            var/magic_node/mn = new t
            if(mn && mn.name)
                nodes[mn.name] = mn
        glob.EarthTreeNodes = nodes
    initLightTree()
        var/list/nodes = list()
        for(var/t in subtypesof(/magic_node/light_tree))
            if(!ispath(t)) continue
            var/magic_node/mn = new t
            if(mn && mn.name)
                nodes[mn.name] = mn
        glob.LightTreeNodes = nodes
    initTimeTree()
        var/list/nodes = list()
        for(var/t in subtypesof(/magic_node/time_tree))
            if(!ispath(t)) continue
            var/magic_node/mn = new t
            if(mn && mn.name)
                nodes[mn.name] = mn
        glob.TimeTreeNodes = nodes
    initDarkTree()
        var/list/nodes = list()
        for(var/t in subtypesof(/magic_node/dark_tree))
            if(!ispath(t)) continue
            var/magic_node/mn = new t
            if(mn && mn.name)
                nodes[mn.name] = mn
        glob.DarkTreeNodes = nodes
    initSpaceTree()
        var/list/nodes = list()
        for(var/t in subtypesof(/magic_node/space_tree))
            if(!ispath(t)) continue
            var/magic_node/mn = new t
            if(mn && mn.name)
                nodes[mn.name] = mn
        glob.SpaceTreeNodes = nodes

/mob/proc/initPersonalMagicTrees()
    initWaterTreeButtons();
    initFireTreeButtons();
    initAirTreeButtons();
    initEarthTreeButtons();
    initLightTreeButtons();
    initTimeTreeButtons();
    initDarkTreeButtons();
    initSpaceTreeButtons();
    hideRevealedButtons();

/mob/proc
    initWaterTreeButtons()
        loadButtons(glob.WaterTreeNodes);
    initFireTreeButtons()
        loadButtons(glob.FireTreeNodes);
    initAirTreeButtons()
        loadButtons(glob.AirTreeNodes);
    initEarthTreeButtons()
        loadButtons(glob.EarthTreeNodes);
    initLightTreeButtons()
        loadButtons(glob.LightTreeNodes);
    initTimeTreeButtons()
        loadButtons(glob.TimeTreeNodes);
    initDarkTreeButtons()
        loadButtons(glob.DarkTreeNodes);
    initSpaceTreeButtons()
        loadButtons(glob.SpaceTreeNodes);

/magic_node/var
    name = "Magic Node";
    xLoc;
    yLoc;
    lockedNodeImage;
    unlockedNodeImage;
    command;
    nodeType;//aoe, autohit, buff, debuff, line, projectile; mage, crown, spell
    list/unlocksNodes=list();
    list/grantsSkills=list();
    list/grantsSpellPassives=list();
    list/grantsMagePassives=list();
    list/grantsKnowledges=list();

/magic_node/
    New()
        ..()
        setNodeImages();

    proc/getTreeAOEImage()
    proc/getTreeAutohitImage()
    proc/getTreeBuffImage()
    proc/getTreeDebuffImage()
    proc/getTreeLineImage()
    proc/getTreeMagePassiveImage()
    proc/getTreePinnacleImage()
    proc/getTreeProjectileImage()
    proc/getTreeSpellPassiveImage()

    proc/setNodeImages()
        switch(nodeType)
            if("AOE")
                lockedNodeImage=LOCKED_AOE;
                unlockedNodeImage=getTreeAOEImage();
            if("Autohit")
                lockedNodeImage=LOCKED_AUTOHIT;
                unlockedNodeImage=getTreeAutohitImage();
            if("Buff")
                lockedNodeImage=LOCKED_BUFF;
                unlockedNodeImage=getTreeBuffImage();
            if("Debuff")
                lockedNodeImage=LOCKED_DEBUFF;
                unlockedNodeImage=getTreeDebuffImage();
            if("Line")
                lockedNodeImage=LOCKED_LINE;
                unlockedNodeImage=getTreeLineImage();
            if("Mage Passive")
                lockedNodeImage=LOCKED_MAGEP;
                unlockedNodeImage=getTreeMagePassiveImage();
            if("Pinnacle")
                lockedNodeImage=LOCKED_PINNACLE;
                unlockedNodeImage=getTreePinnacleImage();
            if("Projectile")
                lockedNodeImage=LOCKED_PROJ;
                unlockedNodeImage=getTreeProjectileImage();
            if("Spell Passive")
                lockedNodeImage=LOCKED_SPELLP;
                unlockedNodeImage=getTreeSpellPassiveImage();

/mob/var/
    list/magicKnowledge=list();
    list/accessedMagicTrees=list();
    list/acquiredMagicNodes=list();//nodes that have been acquired
    list/availableMagicNodes=list();//nodes that CAN be unlocked, but haven't been

globalTracker/var
    MagicNodeRPPCost=25;
    OldMagicNodeRPPCost=10;
    SecondElementPotential=20;
    AdvancedElementPotential=40;

/mob/var/
    tmp/nodeing=0;

/mob/verb/
    unlockMagicNode(node as text)
        set name=".unlockMagicNode"
        set hidden = 1;
        if(nodeing) return;
        if(!(node in VALID_MAGIC_NODES)) return;
        nodeing=1;
        unlockNodeChoice(node);
        nodeing=0;

/mob/proc/unlockNodeChoice(nodeName)
    var/list/currentMagicTreeNodes = glob.vars["[magicTreeDisplayed]TreeNodes"];
    if(!isValidNode(nodeName, currentMagicTreeNodes)) return 0;
    var/magic_node/selectedNode = currentMagicTreeNodes[nodeName];
    var/msg = "The node [nodeName] grants the following effects: "
    for(var/k in selectedNode.grantsSkills)
        msg += "\n- Access to the [copytext("[k]", findLastSlash("[k]"))] magic skill.";
    for(var/sp in selectedNode.grantsSpellPassives)
        msg += "\n- Access to the [copytext("[sp]", findLastSlash("[sp]"))] bundle of spell passives.";//needs quotes on the argument to be able to be modifiable by findLastSlash proc
    for(var/mp in selectedNode.grantsMagePassives)
        msg += "\n- Access to the [mp] bundle of mage passives.";
    for(var/k in selectedNode.grantsKnowledges)
        msg += "\n- Access to the knowledge provided by [k].";
    msg += "\nIt costs [glob.MagicNodeRPPCost] RPP to unlock this node."
    if(canPurchaseNode(selectedNode))
        msg += "\nDo you want to?"
        if(alert(src, msg, "Unlock Magic Node ([nodeName])", "No", "Yes")=="Yes") unlockNode(selectedNode);
    else alert(src, msg, "Magic Node Details [nodeName]", "OK");

/mob/proc/isValidNode(nodeName, list/magicTree)
    if(!(nodeName in magicTree))
        src << "You are currently looking at the [magicTreeDisplayed] Magic Tree, and [nodeName] is not from that tree!"
        return 0;
    return 1;

/mob/proc/canPurchaseNode(magic_node/mn)
    if(!(magicTreeDisplayed in accessedMagicTrees))
        src << "You have not unlocked the [magicTreeDisplayed] Magic Tree yet, so you cannot purchase any of its nodes."
        return 0;
    if(RPPSpendable < glob.MagicNodeRPPCost)
        src << "You don't have enough RPP to buy [mn.name]! ([RPPSpendable] / [glob.MagicNodeRPPCost])";
        return 0;
    if(hasUnlockedMagicNode(mn))
        src << "You've already unlocked [mn.name]!";
        return 0;
    if(!(mn.name in availableMagicNodes))
        src << "You have not unlocked any of [mn.name]'s prerequisite nodes yet!"
        return 0;
    if(mn.nodeType == "Pinnacle" && !canUnlockPinnacle(mn))
        src << "You have not unlocked all of the [magicTreeDisplayed] Magic Tree's nodes; you can't unlock the Pinnacle yet!"
        return 0;
    return 1;

/mob/proc/hasUnlockedMagicNode(magic_node/mn)
    for(var/magic_node/macquired in acquiredMagicNodes)
        if (mn.type == macquired.type) return 1;
    return 0;

/mob/proc/canUnlockPinnacle()
    var/list/elementTree = list();
    elementTree |= glob.vars["[magicTreeDisplayed]TreeNodes"];
    for(var/nodeName in elementTree)
        var/magic_node/mn = elementTree[nodeName];
        if(mn.nodeType == "Pinnacle") continue
        if(!hasUnlockedMagicNode(mn)) return 0;
    return 1;



/mob/proc/canUnlockMagicTree(element)
    if(src.race.type in MAGICLESS_RACES)
        if(passive_handler.Get("ImbuedSoul"))
            return 1;
        else
            alert(src, "You don't have the heart or soul to utilize magic.", "ERROR", "OK");
            return 0;
    if(RPPSpendable < glob.MagicNodeRPPCost)
        alert(src, "You don't have enough RPP to unlock the [element] Magic Tree! ([RPPSpendable] / [glob.MagicNodeRPPCost])", "ERROR", "OK");
        return 0;
    if(!(element in VALID_MAGIC_ELEMENTS))
        alert(src, "Uhm? Somehow, you've tried to unlock an element that doesn't exist in the valid element list...", "ERROR", "OK");
        return; //if this isn't a real element
    if((element in ADVANCED_MAGIC_ELEMENTS) && !canObtainAdvancedElements(element))
        alert(src, "[element] is an Advanced element; you have to be over [glob.AdvancedElementPotential] Potential and have invested a T3 into Mage Status to unlock it!", "ERROR", "OK");
        return;
    if(element in accessedMagicTrees && HyperInvestmentCriteraNotMet(element))
        alert(src, "[element]-type Magic has already been unlocked for you, and you don't yet match the criteria for hyper investment...", "ERROR", "OK");
        return; //if this has already been unlocked
    return 1;

/mob/proc/canObtainAdvancedElements(element)
    var/list/popoEarlyUnlocks = list("Time", "Space");//hbtc elements
    var/list/angelEarlyUnlocks = list("Light");
    var/list/demonEarlyUnlocks = list("Dark");
    if(hasEarlyMagicAdvancement()) return 1;
    if(isRace(POPO) && popoEarlyUnlocks.Find(element)) return 1;
    if((isRace(ANGEL) || isRace(MAKAIOSHIN)) && angelEarlyUnlocks.Find(element)) return 1;
    if((isRace(DEMON) || isRace(MAKAIOSHIN)) && demonEarlyUnlocks.Find(element)) return 1;
    
    if(!hasAdvancedMagicCapability()) return 0;
    return 1;

/mob/proc/hasEarlyMagicAdvancement()
    if(hasSecret("Eldritch (Reflected)")) return 1;
    return 0;

/mob/var/AdvancedMagicInvestment=0;
/mob/Admin1/verb/Give_Advanced_Magic(mob/Players/p in world|null)
    set category="Admin"
    set name = "Give Advanced Magic"
    if(!p)
        var/list/options = list("Cancel")
        for(var/mob/Players/gal in world)
            options |= gal;
        var/mob/choice = input(usr, "What player do you want to grant Advanced Magic Investment to?", "Grant Advanced Magic Investment") in options;
        if(choice=="Cancel") return;
    var/nuMagic = input(usr, "What do you want to set [p]'s Advanced Magic Investment to?", "Advanced Magic Investment (currently [p.AdvancedMagicInvestment])") as num|null;
    if(nuMagic && nuMagic > 0)
        p.AdvancedMagicInvestment = nuMagic;
        Log("Admin","[ExtractInfo(usr)] granted [ExtractInfo(p)] Advanced Magic Investment [nuMagic]!")

/mob/proc/hasAdvancedMagicCapability()
    if(Saga)
        alert("Your head is filled with too much [Saga]. You do not have space to learn Advanced Magic too.");
        return 0;
    if(CountSigs(3) >= 1+AdvancedMagicInvestment)
        alert("You must submit an app to become a proficient mage. Admins can use Give Advanced Magic to give you the capacity to advance.")
        return 0;
    if(Potential < glob.AdvancedElementPotential)
        alert("You do not have the strength to handle an advanced element yet. (Needs Potential [glob.AdvancedElementPotential])");
        return 0;
    if(CountPinnacles() < 2)
        alert("You have not mastered at least two prior Magic Trees.")
        return 0;
    return 1;

/mob/proc/CountPinnacles()
    . = 0
    for(var/magic_node/x in acquiredMagicNodes)
        if(x.nodeType=="Pinnacle") .++;

/mob/proc/getMagicalDeficiency()
    . = 0
    //if any one or any thing is supposed to be bad at magic, accumulate a negative value here
    if(. > 0) . *= (-1)//and if you forget, and make it a positive value, this will flip it around to negative
    . = clamp(., -999, 0);

/mob/proc/AnnounceNextUnlockCriteria()
    switch(accessedMagicTrees.len + getMagicalDeficiency())
        if(0)
            alert("You don't have any existing arcane knowledge to skew your perception. You can freely unlock another branch of magic!");
        if(1)
            alert("You must fully understand your first branch of arcane knowledge before diluting it with another path, and even then, it may take some time to learn new elemental principles. (Master your first Tree and then attempt to learn after potential [glob.SecondElementPotential])");
            if(Potential < glob.SecondElementPotential) return 0;
            if(CountPinnacles() < 1) return 0;
        if(2)
            alert("You must fully understand your first anmd second branches of arcane knowledges before diluting them further. In addition, to advance further, you'll be dedicating yourself as a mage (Investment of a T3).  Are you sure you want to give up other avenues of power?");
            if(Potential < glob.AdvancedElementPotential) return 0;
            if(CountPinnacles() < 2) return 0;
        if(3)
            alert("You've reached the peak of magical mastery! ... There's nothing beyond this point, you've learned all you can! ... Right?")
            return 0;
        else
            alert("You're too far beyond the natural laws of magic. It'd take an act of ᛜⳘᚾᛊᚱ ᛁᚢᚾᛊᚱꓦᛊᚢᚾᛁᛜᚢ to keep increasing your magical knowledge...");
            return 0;
    return 1;

/mob/proc/unlockTreeChoice(element)
    if(!AnnounceNextUnlockCriteria()) return 0;
    return (alert(src, "Do you want to unlock [element]-type magic? This is your [accessedMagicTrees.len+1]\th magic tree unlock. The initial unlock costs [glob.MagicNodeRPPCost] RPP, and it grants you the first node.", "Unlock [element] Tree", "No", "Yes") == "Yes");

/mob/proc/HyperInvestmentCriteraNotMet(element)
    //implement criteria for lapping elements later
    return 0;
/mob/proc/magicTreeHyperInvestment(element)
    src << "Calm down."

/mob/proc/unlockEntryNode(element)//happens for free when you buy the tree
    var/nodeName = glob.vars["[element]TreeNodes"][1];
    unlockNode(glob.vars["[element]TreeNodes"][nodeName]);

/mob/proc/unlockNode(magic_node/mn)
    SpendRPP(glob.MagicNodeRPPCost);
    acquiredMagicNodes |= mn;
    availableMagicNodes |= mn.unlocksNodes;
    obtainNode(mn);
    src << "Unlocked node [mn.name]!";
    updateSelectionNodes();

/mob/proc/obtainNode(magic_node/mn)
    switch(mn.nodeType)
        if("Spell Passive") unlockSpellPassive(mn);
        if("Mage Passive") unlockMagePassive(mn);
    //a Pinnacle node may also carry a mage passive payload (e.g. Fire crown grants Alight),
    //so always grant if grantsMagePassives is populated, even outside the switch.
    if(mn.nodeType != "Mage Passive" && mn.grantsMagePassives.len)
        unlockMagePassive(mn);
    if(mn.isSpellSlot()) unlockSpellSlot(mn);
    unlockMagicKnowledge(mn);

/magic_node/proc/isSpellSlot()
    if(nodeType in list("AOE", "Autohit", "Projectile", "Line", "Buff", "Debuff")) return 1;
    return 0;

/mob/proc/unlockMagicTree(element)
    if(element in accessedMagicTrees)
        magicTreeHyperInvestment(element);
        return;
    accessedMagicTrees |= element;

    src << "You've unlocked the ability to choose [element] magic tree nodes!";
    src << "Each node costs [glob.MagicNodeRPPCost] RPP to unlock.";
    unlockEntryNode(element);

/mob/verb/
    Unlock_Access_Node(element as text)
        set name = ".unlockAccessNode"
        set hidden = 1;
        if(nodeing) return;
        if(!canUnlockMagicTree(element)) return;
        nodeing=1;
        if(unlockTreeChoice(element))
            unlockMagicTree(element);
        nodeing=0;
/*
/mob/verb/
    debug_fire_magic()
        set name="DEBUG: fire magic"
        set category="Debug"
        var/magic_node/fire_tree/fire_node_entry/fne = new;
        usr << "name: [fne.name]"
        for(var/p in fne.grantsSkills)
            usr << "type in grantsSkills: [p]"
            var/obj/Skills/s = findOrAddSkill(p);
            usr << "skill obj made: [s.name]"
    debug_reinit_magictrees()
        set name = "DEBUG: re initialize magic trees"
        set category = "Debug"
        clearMagicNodes()
        initMagicNodes()
    debug_check_all_spell_passives()
        set name = "DEBUG: check all spell passives"
        set category = "Debug"
        for(var/x in allSpellPassives)
            src << "[x] is in spell passives."*/
