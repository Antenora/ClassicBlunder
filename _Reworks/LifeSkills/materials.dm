var/list/LifeOreDefs = list()

/obj/Items/var/CreatorName   // display name for the maker's mark; CreatorKey is just the ckey
// smithed-gear identity - all saved, all inert on legacy items
/obj/Items/var/metal_id
/obj/Items/var/craft_ingots = 0
/obj/Items/var/craft_shape_w = 1
/obj/Items/var/craft_capstone = 0   // forged by a rank-10 Master Smith - +5% effectiveness, re-applied by setStatLine
/obj/Items/var/gem_id
/obj/Items/var/gem_quality = 0
/obj/Items/var/mmat_id
/obj/Items/var/mmat_quality = 0

/datum/ore_def
	var/id
	var/name
	var/kind = "metal"      // metal | gem | utility
	var/tier = 1
	var/difficulty = 1
	var/yield_type

proc/LifeOreDef(id)
	InitLifeOreDefs()
	return LifeOreDefs[id]

proc/LifeOreAdd(id, name, kind, tier, difficulty, ytype)
	var/datum/ore_def/d = new
	d.id = id
	d.name = name
	d.kind = kind
	d.tier = tier
	d.difficulty = difficulty
	d.yield_type = ytype
	LifeOreDefs[id] = d

proc/InitLifeOreDefs()
	if(LifeOreDefs.len) return
	// metals
	LifeOreAdd("copper",     "Copper",       "metal",   1, 1,  /obj/Items/Material/Ore/copper)
	LifeOreAdd("tin",        "Tin",          "metal",   1, 2,  /obj/Items/Material/Ore/tin)
	LifeOreAdd("iron",       "Iron",         "metal",   2, 3,  /obj/Items/Material/Ore/iron)
	LifeOreAdd("cobalt",     "Cobalt",       "metal",   3, 5,  /obj/Items/Material/Ore/cobalt)
	LifeOreAdd("silver",     "Silver",       "metal",   3, 5,  /obj/Items/Material/Ore/silver)
	LifeOreAdd("gold",       "Gold",         "metal",   3, 6,  /obj/Items/Material/Ore/gold)
	LifeOreAdd("mythril",    "Mythril",      "metal",   4, 7,  /obj/Items/Material/Ore/mythril)
	LifeOreAdd("adamantite", "Adamantite",   "metal",   4, 8,  /obj/Items/Material/Ore/adamantite)
	LifeOreAdd("starmetal",  "Starmetal",    "metal",   5, 9,  /obj/Items/Material/Ore/starmetal)
	LifeOreAdd("orichalcum", "Orichalcum",   "metal",   5, 10, /obj/Items/Material/Ore/orichalcum)
	// utility
	LifeOreAdd("clay",       "Clay",         "utility", 1, 1,  /obj/Items/Material/clay)
	LifeOreAdd("coal",       "Coal",         "utility", 1, 2,  /obj/Items/Material/coal)
	LifeOreAdd("stone",      "Stone",        "utility", 1, 1,  /obj/Items/Material/stone)
	// gems
	LifeOreAdd("garnet",     "Garnet",       "gem",     2, 3,  /obj/Items/Material/Gem/garnet)
	LifeOreAdd("turquoise",  "Turquoise",    "gem",     2, 3,  /obj/Items/Material/Gem/turquoise)
	LifeOreAdd("rosequartz", "Rose Quartz",  "gem",     2, 3,  /obj/Items/Material/Gem/rosequartz)
	LifeOreAdd("jade",       "Jade",         "gem",     3, 4,  /obj/Items/Material/Gem/jade)
	LifeOreAdd("amethyst",   "Amethyst",     "gem",     3, 4,  /obj/Items/Material/Gem/amethyst)
	LifeOreAdd("tourmaline", "Tourmaline",   "gem",     3, 5,  /obj/Items/Material/Gem/tourmaline)
	LifeOreAdd("bloodstone", "Bloodstone",   "gem",     4, 6,  /obj/Items/Material/Gem/bloodstone)
	LifeOreAdd("moonstone",  "Moonstone",    "gem",     4, 7,  /obj/Items/Material/Gem/moonstone)
	LifeOreAdd("sapphire",   "Sapphire",     "gem",     4, 7,  /obj/Items/Material/Gem/sapphire)
	LifeOreAdd("emerald",    "Emerald",      "gem",     4, 7,  /obj/Items/Material/Gem/emerald)
	LifeOreAdd("obsidian",   "Obsidian",     "gem",     5, 8,  /obj/Items/Material/Gem/obsidian)
	LifeOreAdd("voidcrystal","Void Crystal", "gem",     5, 9,  /obj/Items/Material/Gem/voidcrystal)

// commonness when seeding the world, by difficulty 1..10 (this mayyyy get scrapped or redone)
var/list/LIFE_SEED_WEIGHTS = list(40, 34, 28, 22, 16, 12, 8, 5, 3, 2)

proc/LifeOreSeedWeight(D)
	return LIFE_SEED_WEIGHTS[clamp(D, 1, 10)]

/obj/Items/Material
	icon = 'Icons/LifeSkills/Materials.dmi'
	Grabbable = 1
	Cost = 0

/obj/Items/Material/Ore
	desc = "Raw ore. Smelt it down at a forge."
	var/ore_id = ""
	var/tier = 1
	copper     { name = "Copper Ore";     MaterialClass = "CopperOre";     icon_state = "ore_copper";     ore_id = "copper";     tier = 1 }
	tin        { name = "Tin Ore";        MaterialClass = "TinOre";        icon_state = "ore_tin";        ore_id = "tin";        tier = 1 }
	iron       { name = "Iron Ore";       MaterialClass = "IronOre";       icon_state = "ore_iron";       ore_id = "iron";       tier = 2 }
	cobalt     { name = "Cobalt Ore";     MaterialClass = "CobaltOre";     icon_state = "ore_cobalt";     ore_id = "cobalt";     tier = 3 }
	silver     { name = "Silver Ore";     MaterialClass = "SilverOre";     icon_state = "ore_silver";     ore_id = "silver";     tier = 3 }
	gold       { name = "Gold Ore";       MaterialClass = "GoldOre";       icon_state = "ore_gold";       ore_id = "gold";       tier = 3 }
	mythril    { name = "Mythril Ore";    MaterialClass = "MythrilOre";    icon_state = "ore_mythril";    ore_id = "mythril";    tier = 4 }
	adamantite { name = "Adamantite Ore"; MaterialClass = "AdamantiteOre"; icon_state = "ore_adamantite"; ore_id = "adamantite"; tier = 4 }
	starmetal  { name = "Starmetal Ore";  MaterialClass = "StarmetalOre";  icon_state = "ore_starmetal";  ore_id = "starmetal";  tier = 5 }
	orichalcum { name = "Orichalcum Ore"; MaterialClass = "OrichalcumOre"; icon_state = "ore_orichalcum"; ore_id = "orichalcum"; tier = 5 }

/obj/Items/Material/Ingot
	desc = "A worked bar of metal, ready for the anvil."
	var/ore_id = ""
	var/tier = 1
	copper     { name = "Copper Ingot";     MaterialClass = "Copper";     icon_state = "ingot_copper";     ore_id = "copper";     tier = 1 }
	tin        { name = "Tin Ingot";        MaterialClass = "Tin";        icon_state = "ingot_tin";        ore_id = "tin";        tier = 1 }
	bronze     { name = "Bronze Ingot";     MaterialClass = "Bronze";     icon_state = "ingot_bronze";     ore_id = "bronze";     tier = 2 }
	iron       { name = "Iron Ingot";       MaterialClass = "Iron";       icon_state = "ingot_iron";       ore_id = "iron";       tier = 2 }
	steel      { name = "Steel Ingot";      MaterialClass = "Steel";      icon_state = "ingot_steel";      ore_id = "steel";      tier = 3 }
	cobalt     { name = "Cobalt Ingot";     MaterialClass = "Cobalt";     icon_state = "ingot_cobalt";     ore_id = "cobalt";     tier = 3 }
	silver     { name = "Silver Ingot";     MaterialClass = "Silver";     icon_state = "ingot_silver";     ore_id = "silver";     tier = 3 }
	gold       { name = "Gold Ingot";       MaterialClass = "Gold";       icon_state = "ingot_gold";       ore_id = "gold";       tier = 3 }
	mythril    { name = "Mythril Ingot";    MaterialClass = "Mythril";    icon_state = "ingot_mythril";    ore_id = "mythril";    tier = 4 }
	adamantite { name = "Adamantite Ingot"; MaterialClass = "Adamantite"; icon_state = "ingot_adamantite"; ore_id = "adamantite"; tier = 4 }
	starmetal  { name = "Starmetal Ingot";  MaterialClass = "Starmetal";  icon_state = "ingot_starmetal";  ore_id = "starmetal";  tier = 5 }
	orichalcum { name = "Orichalcum Ingot"; MaterialClass = "Orichalcum"; icon_state = "ingot_orichalcum"; ore_id = "orichalcum"; tier = 5 }

/obj/Items/Material/Gem
	desc = "A rough gem. Thaumaturges and tinkerers will want these."
	var/ore_id = ""
	var/tier = 1
	garnet      { name = "Garnet";       MaterialClass = "Garnet";      icon_state = "gem_garnet";      ore_id = "garnet";      tier = 2 }
	turquoise   { name = "Turquoise";    MaterialClass = "Turquoise";   icon_state = "gem_turquoise";   ore_id = "turquoise";   tier = 2 }
	rosequartz  { name = "Rose Quartz";  MaterialClass = "RoseQuartz";  icon_state = "gem_rosequartz";  ore_id = "rosequartz";  tier = 2 }
	jade        { name = "Jade";         MaterialClass = "Jade";        icon_state = "gem_jade";        ore_id = "jade";        tier = 3 }
	amethyst    { name = "Amethyst";     MaterialClass = "Amethyst";    icon_state = "gem_amethyst";    ore_id = "amethyst";    tier = 3 }
	tourmaline  { name = "Tourmaline";   MaterialClass = "Tourmaline";  icon_state = "gem_tourmaline";  ore_id = "tourmaline";  tier = 3 }
	bloodstone  { name = "Bloodstone";   MaterialClass = "Bloodstone";  icon_state = "gem_bloodstone";  ore_id = "bloodstone";  tier = 4 }
	moonstone   { name = "Moonstone";    MaterialClass = "Moonstone";   icon_state = "gem_moonstone";   ore_id = "moonstone";   tier = 4 }
	sapphire    { name = "Sapphire";     MaterialClass = "Sapphire";    icon_state = "gem_sapphire";    ore_id = "sapphire";    tier = 4 }
	emerald     { name = "Emerald";      MaterialClass = "Emerald";     icon_state = "gem_emerald";     ore_id = "emerald";     tier = 4 }
	obsidian    { name = "Obsidian";     MaterialClass = "Obsidian";    icon_state = "gem_obsidian";    ore_id = "obsidian";    tier = 5 }
	voidcrystal { name = "Void Crystal"; MaterialClass = "VoidCrystal"; icon_state = "gem_voidcrystal"; ore_id = "voidcrystal"; tier = 5 }

/obj/Items/Material/clay
	name = "Clay"
	MaterialClass = "Clay"
	icon_state = "clay"
	desc = "Casting clay for molds."

/obj/Items/Material/coal
	name = "Coal"
	MaterialClass = "Coal"
	icon_state = "coal"
	desc = "Smelter fuel. Also folds into steel."

/obj/Items/Material/stone
	name = "Stone"
	MaterialClass = "Stone"
	icon_state = "stone"
	desc = "Plain cut stone."

// deposit a material straight into the Collection Log (returns the matclass, or null)
proc/GiveMaterial(mob/M, mat_type, amount, quality = QUAL_NORMAL)
	if(!M || amount <= 0 || !mat_type) return null
	quality = QualityClamp(quality)
	var/matclass = LifeMatClassOf(mat_type)
	if(!matclass) return null
	var/banked = M.MatLogAdd(matclass, quality, amount)
	if(banked < amount)
		M << "<font color=#ff6464>Your [LifeMatName(matclass)] store is full at [INV_STACK_MAX] - [amount - banked] couldn't be banked.</font>"
	return matclass
