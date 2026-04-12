/mob/var/list/acquiredMagePassives=list();

// Per-attacker cooldown gate for Dark Iconoclast's Power-steal on hit. Stores
// the next world.time at which an Iconoclast steal is allowed to fire on this
// mob. Tmp because cooldown state never needs to survive logout/save — combat
// state only. Read at the steal hook in _Reworks/Combat/DoDamage.dm.
/mob/var/tmp/IconoclastNextSteal=0

// Returns 1 if the mob has at least one tick of the given mage_passive subtype.
// Used by combat hooks (e.g. _Elements.dm AddBurn) to check whether the
// attacker holds a Mastery passive without having to walk acquiredMagePassives
// at the call site every time.
/mob/proc/hasMagePassive(passive_type)
    if(!passive_type) return 0
    if(!acquiredMagePassives || !acquiredMagePassives.len) return 0
    for(var/mage_passive/mp in acquiredMagePassives)
        if(istype(mp, passive_type))
            return 1
    return 0

/mob/proc/unlockMagePassive(magic_node/mn)
    if(!mn) return;
    if(!mn.grantsMagePassives || !mn.grantsMagePassives.len) return;
    var/list/elements_touched = list()
    for(var/type in mn.grantsMagePassives)
        var/mage_passive/mp = new type;
        if(!mp) continue;
        acquiredMagePassives |= mp;
        if(mp.passives && mp.passives.len)
            passive_handler.Increase(mp.passives);
        if(mp.name)
            src << "You have internalized the [mp.name] mage passive."
        if(mp.element && !(mp.element in elements_touched))
            elements_touched += mp.element
    for(var/elem in elements_touched)
        updateGestalt(elem)

/mage_passive
    var/name;
    var/desc;
    var/element;
    var/list/passives=list();
    var/list/knowledgeTypes=list();

    fire
        element="Fire"

        BurnMastery
            name="Burn Mastery"
            desc="The mage's foundational understanding of fire. Each selection increases their resistance to Burn debuffs and deepens their grip on fire spells."
            passives = list("BurnResist" = 1, "FireSpellManaCost" = 0.15)

        ScorchedForm
            name="Scorched Form"
            desc="The mage's body remembers the heat of every cast. Each selection further reinforces their physical conditioning around the practice of fire."
            passives = list("BurnResist" = 1, "FireSpellCooldown" = 0.10)

        Alight
            name="Alight"
            desc="The mage has become a vessel for fire itself. The path beyond mastery — mana flows freely, the world bends to the heat."
            passives = list("ManaGeneration" = 3, "PowerfulCasting" = 1, "FireSpellDamage" = 0.10, "FireSpellCooldown" = 0.10)

    water
        element="Water"

        ChillMastery
            name="Chill Mastery"
            desc="The mage's foundational understanding of water. Each selection increases their resistance to Chill debuffs and deepens their grip on water spells."
            passives = list("ChillResist" = 1, "WaterSpellManaCost" = 0.15)

        FluidTechnique
            name="Fluid Technique"
            desc="The mage's mind moves in time with the tide. Each selection further sharpens their mental conditioning around the practice of water."
            passives = list("ChillResist" = 1, "WaterSpellCooldown" = 0.10)

        Awash
            name="Awash"
            desc="The mage has become a vessel for water itself. The path beyond mastery — mana flows freely, the world yields to the current."
            passives = list("ManaGeneration" = 3, "ForcefulCasting" = 1, "WaterSpellDamage" = 0.10, "WaterSpellCooldown" = 0.10)

    earth
        element="Earth"

        ShatterMastery
            name="Shatter Mastery"
            desc="The mage's foundational understanding of earth. Each selection increases their resistance to Shatter debuffs and deepens their grip on earth spells."
            passives = list("ShatterResist" = 1, "EarthSpellManaCost" = 0.15)

        FirmGuard
            name="Firm Guard"
            desc="The mage's body becomes as steady as stone. Each selection further reinforces their endurance around the practice of earth."
            passives = list("ShatterResist" = 1, "EarthSpellCooldown" = 0.10)

        Aerde
            name="Aerde"
            desc="The mage has become a vessel for earth itself. The path beyond mastery — mana flows freely, the world holds beneath them."
            passives = list("ManaGeneration" = 3, "StalwartCasting" = 1, "EarthSpellDamage" = 0.10, "EarthSpellCooldown" = 0.10)

    air
        element="Air"

        ShockMastery
            name="Shock Mastery"
            desc="The mage's foundational understanding of wind. Each selection increases their resistance to Shock debuffs and deepens their grip on wind spells."
            passives = list("ShockResist" = 1, "AirSpellManaCost" = 0.15)

        FleetFooted
            name="Fleet Footed"
            desc="The mage's footwork carries the rhythm of the gale. Each selection further sharpens their reflexes around the practice of wind."
            passives = list("ShockResist" = 1, "AirSpellCooldown" = 0.10)

        Aloft
            name="Aloft"
            desc="The mage has become a vessel for wind itself. The path beyond mastery — mana flows freely, the world parts at their passing."
            passives = list("ManaGeneration" = 3, "AgileCasting" = 1, "AirSpellDamage" = 0.10, "AirSpellCooldown" = 0.10)

    light
        element="Light"

        Warden
            name="Warden"
            desc="The mage stands as a bulwark against the dark. Each selection grows their innate resistance to Evil-aligned attackers and deepens their natural healing."
            passives = list("EvilResist" = 1, "LifeGeneration" = 2)

        Seeker
            name="Seeker"
            desc="The mage's vision reaches further than their hands. Each selection extends the range at which their spells may strike, and steels them for the work."
            passives = list("SpellRange" = 1, "StalwartCasting" = 1)

        Mender
            name="Mender"
            desc="The mage has become a vessel for light itself. Mana flows in abundance, and the wounds of the world are theirs to close."
            passives = list("ManaGeneration" = 5, "LightSpellDamage" = 0.15, "LightSpellManaCost" = 0.15, "LightSpellCooldown" = 0.15)

    dark
        element="Dark"

        Shadowbringer
            name="Shadowbringer"
            desc="The mage carries the weight of the dark in their wake. Each selection grows their innate resistance to Good-aligned attackers and deepens their grip on the primordial."
            passives = list("GoodResist" = 1)

        Iconoclast
            name="Iconoclast"
            desc="The mage breaks the work of others as readily as their own. Each selection sharpens the strength behind their casting and the malice that drives it."
            passives = list("PowerfulCasting" = 1)

        Survivor
            name="Survivor"
            desc="The mage has become a vessel for darkness itself. Mana flows in abundance, and the wounds they take only feed the next casting."
            passives = list("ManaGeneration" = 5, "DarkSpellDamage" = 0.20, "DarkSpellManaCost" = 0.10, "DarkSpellCooldown" = 0.15)

    time
        element="Time"

        Past
            name="Past"
            desc="The mage's casting echoes through the moments behind them. Each selection deepens the weight of memory — speed in the wake of a cast, suffering returned to those who would strike them."
            passives = list()

        Present
            name="Present"
            desc="The mage moves with the now. Each selection sharpens the agility behind their casting and the rhythm of their counters."
            passives = list("AgileCasting" = 1)

        Future
            name="Future"
            desc="The mage has become a vessel for time itself. Mana flows in abundance, and the cost of every casting is felt only in moments yet to come."
            passives = list("ManaGeneration" = 5, "TimeSpellDamage" = 0.10, "TimeSpellManaCost" = 0.15, "TimeSpellCooldown" = 0.20)

    space
        element="Space"

        Relativity
            name="Relativity"
            desc="The mage's grasp of distance dulls the keenest of attacks. Each selection further insulates them against the forces that would tear or cripple them."
            passives = list("ShearResist" = 1, "CrippleResist" = 1)

        Linearity
            name="Linearity"
            desc="The mage moves in a single direction — forward. Each selection sharpens the agility behind their casting and softens the toll their body would otherwise pay."
            passives = list("AgileCasting" = 1)

        Kinematics
            name="Kinematics"
            desc="The mage has become a vessel for space itself. Their reservoir of mana grows vast, and the world bends to allow their workings."
            passives = list("ManaCapMult" = 0.5, "ManaGeneration" = 5, "SpaceSpellDamage" = 0.15, "SpaceSpellManaCost" = 0.20, "SpaceSpellCooldown" = 0.10)

// --- Gestalt Unlock System ---
// Gestalt Style and Buff are granted automatically when a player acquires
// mage passives for an element. Tier scales with depth of investment:
//   1 mage passive in element = Tier 1
//   2 mage passives = Tier 2
//   3 mage passives (full element) = Tier 3

/mob/proc/countMagePassivesForElement(element)
    . = 0
    if(!acquiredMagePassives || !acquiredMagePassives.len) return
    for(var/mage_passive/mp in acquiredMagePassives)
        if(mp.element == element)
            .++
    // Each element tree has 5 mage passive nodes (4 non-pinnacle + crown),
    // but Gestalt only supports tiers 1-3. Cap so tier never overshoots.
    if(. > 3) . = 3

/mob/proc/getGestaltStylePath(element)
    switch(element)
        if("Fire") return /obj/Skills/Buffs/NuStyle/Magus_Style/Fire_Gestalt
        if("Water") return /obj/Skills/Buffs/NuStyle/Magus_Style/Water_Gestalt
        if("Earth") return /obj/Skills/Buffs/NuStyle/Magus_Style/Earth_Gestalt
        if("Air") return /obj/Skills/Buffs/NuStyle/Magus_Style/Wind_Gestalt
        if("Light") return /obj/Skills/Buffs/NuStyle/Magus_Style/Light_Gestalt
        if("Dark") return /obj/Skills/Buffs/NuStyle/Magus_Style/Dark_Gestalt
        if("Time") return /obj/Skills/Buffs/NuStyle/Magus_Style/Time_Gestalt
        if("Space") return /obj/Skills/Buffs/NuStyle/Magus_Style/Space_Gestalt
    return null

/mob/proc/getGestaltBuffPath(element)
    switch(element)
        if("Fire") return /obj/Skills/Buffs/SpecialBuffs/Fire_Gestalt_Buff
        if("Water") return /obj/Skills/Buffs/SpecialBuffs/Water_Gestalt_Buff
        if("Earth") return /obj/Skills/Buffs/SpecialBuffs/Earth_Gestalt_Buff
        if("Air") return /obj/Skills/Buffs/SpecialBuffs/Wind_Gestalt_Buff
        if("Light") return /obj/Skills/Buffs/SpecialBuffs/Light_Gestalt_Buff
        if("Dark") return /obj/Skills/Buffs/SpecialBuffs/Dark_Gestalt_Buff
        if("Time") return /obj/Skills/Buffs/SpecialBuffs/Time_Gestalt_Buff
        if("Space") return /obj/Skills/Buffs/SpecialBuffs/Space_Gestalt_Buff
    return null

/mob/proc/updateGestalt(element)
    var/new_tier = countMagePassivesForElement(element)
    if(new_tier <= 0) return
    var/style_path = getGestaltStylePath(element)
    var/buff_path = getGestaltBuffPath(element)
    if(!style_path || !buff_path) return
    // Grant or update Gestalt Style
    var/obj/Skills/gs = FindSkill(style_path)
    var/gestalt_existed = gs ? 1 : 0
    if(!gs)
        gs = findOrAddSkill(style_path)
        src << "Your mastery of [element] magic has crystallized into a Gestalt Style."
    if(gs)
        gs.vars["tier"] = new_tier
        // If style is currently active, force-toggle it off then on so new tier's stats take effect immediately
        if(src.StyleBuff && src.StyleBuff.type == style_path)
            var/obj/Skills/Buffs/gs_buff = gs
            gs_buff.Trigger(src, 1)
            gs_buff.Trigger(src, 1)
    // Grant or update Gestalt Buff
    var/obj/Skills/gb = FindSkill(buff_path)
    if(!gb)
        gb = findOrAddSkill(buff_path)
        src << "Your mastery of [element] magic has crystallized into a Gestalt Buff."
    if(gb)
        gb.vars["tier"] = new_tier
        // If buff is currently active, force-toggle it off then on so new tier's stats take effect immediately
        if(src.SpecialBuff && src.SpecialBuff.type == buff_path)
            var/obj/Skills/Buffs/gb_buff = gb
            gb_buff.Trigger(src, 1)
            gb_buff.Trigger(src, 1)
    if(gestalt_existed && new_tier > 1)
        src << "Your [element] Gestalt has deepened to tier [new_tier]."

/mob/proc/removeGestaltForElement(element)
    var/style_path = getGestaltStylePath(element)
    var/buff_path = getGestaltBuffPath(element)
    if(style_path)
        var/obj/Skills/gs = FindSkill(style_path)
        if(gs) del gs
    if(buff_path)
        var/obj/Skills/gb = FindSkill(buff_path)
        if(gb) del gb

/mob/proc/removeAllGestalts()
    for(var/elem in list("Fire", "Water", "Earth", "Air", "Light", "Dark", "Time", "Space"))
        removeGestaltForElement(elem)

// Full refund of the new magic tree system. Reverses everything obtainNode() does:
// mage passives + their passive_handler values, spell passives, spell slot skills,
// magic knowledge, Gestalt Style/Buff objects, and all tree progress tracking.
// Refunds RPP for every acquired node.
/mob/proc/refundNewMagicTree()
    // 1. Remove mage passive contributions from passive_handler, then clear the list
    for(var/mage_passive/mp in acquiredMagePassives)
        if(mp.passives && mp.passives.len)
            passive_handler.Decrease(mp.passives)
    acquiredMagePassives.Cut()
    // 2. Remove all Gestalt Style and Buff objects
    removeAllGestalts()
    // 3. Remove spell passives (disenchant any that are slotted, then clear)
    for(var/spell_passive/sp in acquiredSpellPassives)
        if(sp.enchantedIn)
            disenchantSpellWithPassive(sp.enchantedIn, sp)
    acquiredSpellPassives.Cut()
    // 4. Remove spell slot skills granted by magic nodes
    for(var/obj/Skills/S in src)
        if(S.SpellSlot)
            del S
    // 5. Remove the Enchant_Spell utility if it exists
    var/obj/Skills/enc = FindSkill(/obj/Skills/Utility/Enchant_Spell)
    if(enc) del enc
    // 6. Refund RPP for each acquired node
    var/node_count = acquiredMagicNodes.len
    if(node_count > 0)
        var/refund = node_count * glob.MagicNodeRPPCost
        RPPSpendable += refund
        RPPSpent -= refund
        if(RPPSpendable > RPPCurrent)
            RPPSpendable = RPPCurrent
    // 7. Clear magic knowledge from nodes
    magicKnowledge.Cut()
    // 8. Clear tree progress
    acquiredMagicNodes.Cut()
    availableMagicNodes.Cut()
    accessedMagicTrees.Cut()
    src << "Your magic tree has been fully refunded."
