var/list/LifeRecipeRegistry = list()

var/list/LIFE_METALS = list("copper", "tin", "bronze", "iron", "steel", "cobalt", "silver", "gold", "mythril", "adamantite", "starmetal", "orichalcum")
var/list/LIFE_METAL_NAME = list("copper" = "Copper", "tin" = "Tin", "bronze" = "Bronze", "iron" = "Iron", "steel" = "Steel", "cobalt" = "Cobalt", "silver" = "Silver", "gold" = "Gold", "mythril" = "Mythril", "adamantite" = "Adamantite", "starmetal" = "Starmetal", "orichalcum" = "Orichalcum")
var/list/LIFE_METAL_TIER = list("copper" = 1, "tin" = 1, "bronze" = 2, "iron" = 2, "steel" = 3, "cobalt" = 3, "silver" = 3, "gold" = 3, "mythril" = 4, "adamantite" = 4, "starmetal" = 5, "orichalcum" = 5)
var/list/LIFE_INGOT_TYPE = list("copper" = /obj/Items/Material/Ingot/copper, "tin" = /obj/Items/Material/Ingot/tin, "bronze" = /obj/Items/Material/Ingot/bronze, "iron" = /obj/Items/Material/Ingot/iron, "steel" = /obj/Items/Material/Ingot/steel, "cobalt" = /obj/Items/Material/Ingot/cobalt, "silver" = /obj/Items/Material/Ingot/silver, "gold" = /obj/Items/Material/Ingot/gold, "mythril" = /obj/Items/Material/Ingot/mythril, "adamantite" = /obj/Items/Material/Ingot/adamantite, "starmetal" = /obj/Items/Material/Ingot/starmetal, "orichalcum" = /obj/Items/Material/Ingot/orichalcum)
var/list/LIFE_GEM_CLASS = list("garnet" = "Garnet", "turquoise" = "Turquoise", "rosequartz" = "RoseQuartz", "jade" = "Jade", "amethyst" = "Amethyst", "tourmaline" = "Tourmaline", "bloodstone" = "Bloodstone", "moonstone" = "Moonstone", "sapphire" = "Sapphire", "emerald" = "Emerald", "obsidian" = "Obsidian", "voidcrystal" = "VoidCrystal")

/datum/craft_recipe/life
	var/label = ""
	var/rank_req = 1
	var/metal_min_tier = 1
	var/ingot_count = 2
	var/tier = 1
	var/money_cost = 0        // EconomyCost multiples, kept from the old tech prices
	var/list/base_stats
	var/tool_kind
	var/shape_diff = 0        // craft difficulty bump: 0 light, 1 medium, 2 heavy
	var/shape_w = 1.0         // how hard the shape swings the metal's personality
	var/fixed_metal           // recipe demands this exact metal
	var/wood_count = 0        // any-wood requirement on top of the ingots

proc/LifeAddRecipe(label, result_type, rank_req, metal_min_tier, ingot_count, tier, list/base_stats, tool_kind = null, money_cost = 0, shape_diff = 0, shape_w = 1.0, fixed_metal = null, wood_count = 0)
	var/datum/craft_recipe/life/R = new
	R.label = label
	R.result_type = result_type
	R.rank_req = rank_req
	R.metal_min_tier = metal_min_tier
	R.ingot_count = ingot_count
	R.tier = tier
	R.base_stats = base_stats
	R.tool_kind = tool_kind
	R.money_cost = money_cost
	R.shape_diff = shape_diff
	R.shape_w = shape_w
	R.fixed_metal = fixed_metal
	R.wood_count = wood_count
	LifeRecipeRegistry += R

proc/RegisterLifeSkillRecipes()
	if(LifeRecipeRegistry.len) return
	// base_stats all null now - stat adds come only from gems. rank-ordered for the forge list.
	LifeAddRecipe("Pick",              /obj/Items/LifeTool,                  1, 1, 2, 1, null, "Pick")
	LifeAddRecipe("Hammer",            /obj/Items/LifeTool,                  1, 1, 2, 1, null, "Hammer")
	LifeAddRecipe("Farmer's Hoe",      /obj/Items/FarmTool/Hoe,              1, 1, 1, 1, null, null, 0, 0, 1.0, "tin", 1)
	LifeAddRecipe("Watering Can",      /obj/Items/FarmTool/WateringCan,      1, 1, 1, 1, null, null, 0, 0, 1.0, "tin")
	LifeAddRecipe("Lockpick",          /obj/Items/Tech/Lockpick,             1, 1, 1, 1, null, null, 0.05, 0, 0.8)
	LifeAddRecipe("Armored Vest",      /obj/Items/Armor/Mobile_Armor,        2, 2, 3, 2, null, null, 0.3, 0, 0.8)
	LifeAddRecipe("Bastard Sword",     /obj/Items/Sword/Light,               2, 2, 2, 2, null, null, 0.3, 0, 0.8)
	LifeAddRecipe("Longsword",         /obj/Items/Sword/Medium,              3, 3, 3, 3, null, null, 0.4, 1, 1.0)
	LifeAddRecipe("Standard Armor",    /obj/Items/Armor/Balanced_Armor,      3, 3, 3, 3, null, null, 0.4, 1, 1.0)
	LifeAddRecipe("Conservation Kit",  /obj/Items/Tech/Conservation_Kit,     3, 1, 1, 1, null, null, 0.05)
	LifeAddRecipe("Greatsword",        /obj/Items/Sword/Heavy,               4, 3, 3, 4, null, null, 0.5, 2, 1.25)
	LifeAddRecipe("Plated Armor",      /obj/Items/Armor/Plated_Armor,        4, 3, 4, 4, null, null, 0.5, 2, 1.25)
	LifeAddRecipe("Weighted Clothing", /obj/Items/WeightedClothing/Weights,  5, 2, 3, 2, null, null, 10, 1, 1.0)
	LifeAddRecipe("Ceramic Plating",   /obj/Items/Plating/Ceramic_Plating,   6, 3, 3, 3, null, null, 2, 1, 1.0)
	LifeAddRecipe("Refractive Plating",/obj/Items/Plating/Refractive_Plating,6, 3, 3, 3, null, null, 2, 1, 1.0)
	LifeAddRecipe("Resistant Coating", /obj/Items/Tech/Resistant_Coating,    6, 3, 2, 3, null, null, 5, 1, 1.0)
	LifeAddRecipe("Fiber Bonding Agent",/obj/Items/Tech/Fiber_Bonding_Agent, 7, 4, 2, 4, null, null, 5, 1, 1.0)
	LifeAddRecipe("Quicksilver Alloy", /obj/Items/Tech/Quicksilver_Alloy,    7, 4, 2, 4, null, null, 5, 1, 1.0)
	LifeAddRecipe("Trick Weapon Kit",  /obj/Items/Tech/Trick_Weapon_Kit,     7, 4, 2, 4, null, null, 25, 1, 1.0)
	world.log << "//\[info]: Registered [LifeRecipeRegistry.len] smithing recipes."

// cached template per recipe for icons/projections
var/list/LIFE_RECIPE_TEMPLATES = list()
proc/LifeRecipeTemplate(datum/craft_recipe/life/R)
	if(!R) return null
	var/key = "[R.result_type]"
	if(!LIFE_RECIPE_TEMPLATES[key])
		LIFE_RECIPE_TEMPLATES[key] = new R.result_type
	return LIFE_RECIPE_TEMPLATES[key]

// menu page readout
proc/LifeSmithingRecipeLines(mob/M)
	RegisterLifeSkillRecipes()
	var/rank = M.LifeRank("Smithing")
	var/out = ""
	for(var/datum/craft_recipe/life/R in LifeRecipeRegistry)
		if(R.rank_req <= rank)
			out += "<font color=#78eb78>[R.label]</font> - [R.ingot_count]x tier [R.metal_min_tier]+ ingots<br>"
		else
			out += "<font color=#6b7a8d>[R.label] - rank [R.rank_req]</font><br>"
	return out

// stations

/obj/LifeSkills/Station
	density = 1
	Savable = 1
	Attackable = 0

/obj/LifeSkills/Station/Forge
	name = "Forge"
	icon = 'Icons/LifeSkills/Forge.dmi'
	icon_state = "forge"
	desc = "A working forge. Face it and press your Interact key to smelt ore."
	Click()
		if(!usr) return
		if(get_dist(usr, src) > 1)
			usr << "You need to get closer to the forge."
			return
		usr.OpenSmelting(src)
	InteractWith(mob/M)
		if(get_dist(M, src) > 1) return 0
		M.OpenSmelting(src)
		return 1

/obj/LifeSkills/Station/Anvil
	name = "Anvil"
	icon = 'Icons/LifeSkills/Stations.dmi'
	icon_state = "anvil"
	desc = "A smith's anvil. Face it and press your Interact key to forge."
	Click()
		if(!usr) return
		if(get_dist(usr, src) > 1)
			usr << "You need to get closer to the anvil."
			return
		usr.OpenForging(src)
	InteractWith(mob/M)
		if(get_dist(M, src) > 1) return 0
		M.OpenForging(src)
		return 1

mob/Admin4/verb/makeForge()
	set category = "Admin"
	new/obj/LifeSkills/Station/Forge(get_step(src, src.dir))
	src << "Forge placed."

mob/Admin4/verb/makeAnvil()
	set category = "Admin"
	new/obj/LifeSkills/Station/Anvil(get_step(src, src.dir))
	src << "Anvil placed."

/obj/Items/LifeTool
	icon = 'Icons/LifeSkills/Tools.dmi'
	Grabbable = 1
	Repairable = 1
	Destructable = 1
	Cost = 0
	ShatterMax = 300
	ShatterCounter = 300
	var/ToolKind = "Pick"
	metal_id = "copper"       // base /obj/Items var now
	var/ToolTier = 1
	var/SweetSpotBonus = 0 
	var/YieldBonus = 0
	var/QualityBonus = 0

	proc/SetupTool(kind, mid, quality)
		ToolKind = kind
		metal_id = mid
		ToolTier = LIFE_METAL_TIER[mid]
		icon_state = "[lowertext(kind)]_[mid]"
		CraftQuality = quality
		var/qm = LIFE_QUALITY_MULT[QualityClamp(quality)]
		SweetSpotBonus = 0.02 * ToolTier * qm
		YieldBonus = round(ToolTier / 2 * qm)
		QualityBonus = round(3 * ToolTier * qm)
		ShatterMax = 300
		switch(mid)
			if("iron", "adamantite") ShatterMax = 450
			if("cobalt") YieldBonus += 1
			if("silver", "gold") QualityBonus += 5
			if("tin", "mythril") SweetSpotBonus += 0.02
		ShatterMax = max(50, round(ShatterMax * qm))
		ShatterCounter = ShatterMax
		name = "[quality == QUAL_NORMAL ? "" : "[QualityName(quality)] "][LIFE_METAL_NAME[mid]] [kind]"
		desc = "A smith-made [lowertext(kind)]. Better metal, better work."

	proc/LifeToolWear(mob/M)
		if(Broken) return
		ShatterCounter -= LIFE_TOOL_WEAR
		if(ShatterCounter <= 0)
			ShatterCounter = 0
			Broken = 1
			suffix = "*Broken*"
			if(M) M << "<font color=#ff6464>Your [name] breaks!</font>"

proc/GetBestLifeTool(mob/M, kind)
	var/obj/Items/LifeTool/best
	for(var/obj/Items/LifeTool/t in M)
		if(t.ToolKind != kind || t.Broken) continue
		if(!best || t.ToolTier > best.ToolTier || (t.ToolTier == best.ToolTier && t.CraftQuality > best.CraftQuality))
			best = t
	return best

// consume best-quality first from the log; returns average quality, or 0 if short
proc/LifeConsumeBest(mob/M, cls, count)
	if(!M || count <= 0) return 0
	if(M.MatLogCount(cls) < count) return 0
	var/qsum = 0
	var/left = count
	for(var/q = QUAL_LEGENDARY to QUAL_POOR step -1)
		if(left <= 0) break
		var/take = M.MatLogTakeQ(cls, q, left)
		qsum += q * take
		left -= take
	return qsum / count

// stations open the StationHUD menu
mob/proc/OpenSmelting(obj/LifeSkills/Station/S)
	if(!client || KO || Dead) return
	client.OpenStationMenu("forge", S)

mob/proc/OpenForging(obj/LifeSkills/Station/S)
	if(!client || KO || Dead) return
	client.OpenStationMenu("anvil", S)

proc/LifeCanSmelt(mob/M, mid)
	switch(mid)
		if("bronze")
			return (CountMaterial(M, "Copper") >= 1 && CountMaterial(M, "Tin") >= 1 && CountMaterial(M, "Coal") >= 1)
		if("steel")
			return (CountMaterial(M, "Iron") >= 1 && CountMaterial(M, "Coal") >= 2)
	return (CountMaterial(M, "[LIFE_METAL_NAME[mid]]Ore") >= 2 && CountMaterial(M, "Coal") >= 1)

proc/LifeSmeltReqText(mob/M, mid)
	switch(mid)
		if("bronze")
			return "1 Copper + 1 Tin + 1 Coal (have [CountMaterial(M, "Copper")] / [CountMaterial(M, "Tin")] / [CountMaterial(M, "Coal")])"
		if("steel")
			return "1 Iron + 2 Coal (have [CountMaterial(M, "Iron")] / [CountMaterial(M, "Coal")])"
	return "2x ore + 1 Coal (have [CountMaterial(M, "[LIFE_METAL_NAME[mid]]Ore")] / [CountMaterial(M, "Coal")])"

proc/LifeEligibleMetals(mob/M, datum/craft_recipe/life/R)
	var/list/out = list()
	if(!M || !R) return out
	if(R.fixed_metal)
		if(CountMaterial(M, LIFE_METAL_NAME[R.fixed_metal]) >= R.ingot_count)
			out += R.fixed_metal
		return out
	for(var/mid in LIFE_METALS)
		if(LIFE_METAL_TIER[mid] < R.metal_min_tier) continue
		if(CountMaterial(M, LIFE_METAL_NAME[mid]) >= R.ingot_count)
			out += mid
	return out

proc/LifeSalvageableItems(mob/M)
	var/list/out = list()
	if(!M) return out
	for(var/obj/Items/I in M)
		if(!I.metal_id || I.PermEquip) continue
		if(istype(I, /obj/Items/Material)) continue
		if(findtext(I.suffix, "Equipped")) continue
		out += I
	return out

proc/LifeRepairableItems(mob/M)
	var/list/out = list()
	if(!M) return out
	for(var/obj/Items/Sword/s in M)
		if(s.Broken && s.Class != "Wooden" && !s.Conjured) out += s
	for(var/obj/Items/Armor/a in M)
		if(a.Broken && !a.Conjured) out += a
	for(var/obj/Items/Enchantment/Staff/st in M)
		if(st.Broken && !st.Conjured) out += st
	for(var/obj/Items/LifeTool/t in M)
		if(t.Broken) out += t
	return out

// the old Reforge verb math, shared with the anvil repair rows
proc/ReforgeCostFor(mob/M, obj/Items/I)
	if(!M || !I) return 0
	var/Cost = 0.5 * Technology_Price(M, I)
	var/CostMultiplier = 1
	if(istype(I, /obj/Items/Enchantment/Staff))
		Cost /= 100
	if(istype(I, /obj/Items/Sword) || istype(I, /obj/Items/Armor) || istype(I, /obj/Items/Enchantment/Staff))
		if(I:Element)
			if(I:Element == "Silver" || I:Element == "Poison")
				CostMultiplier *= 5
			if(I:Element == "Dark" || I:Element == "Light")
				CostMultiplier *= 10
			if(I:Element == "Chaos")
				CostMultiplier *= 15
			if(I:Element == "Ultima")
				CostMultiplier *= 30
		if(I:ExtraClass)
			CostMultiplier += (CostMultiplier > 1) ? 10 : 9
		if(I:Ascended)
			CostMultiplier += (CostMultiplier > 1) ? 3 * (4 ** I:Ascended) : (3 * (4 ** I:Ascended)) - 1
		if(I:Glass && I:HighFrequency)
			Cost *= 50
	if(M.ArmamentEnchantmentUnlocked)
		Cost /= max(M.RepairAndConversionUnlocked + M.SmithingLevel(), 1)
	return round(Cost * CostMultiplier, 1)

mob/proc/DoSmelt(obj/LifeSkills/Station/S, mid)
	if(!client || KO || Dead)
		if(client) client.StForgeDone()
		return
	if(Using)
		src << "You're in the middle of something."
		client.StForgeDone()
		return
	if(client.life_minigame_sink) return
	InitLifeOreDefs()
	var/rank = LifeRank("Smithing")
	if(LIFE_METAL_TIER[mid] > LifeTierCap(rank))
		client.StForgeDone()
		return
	if(!LifeCanSmelt(src, mid))
		src << "You don't have the materials. Coal fuels every firing."
		client.StForgeDone()
		return
	if(!S || get_dist(src, S) > 1)
		src << "You need to be next to the forge."
		client.StForgeDone()
		return
	if(!UseLifeStamina(LIFE_COST_SMELT))
		client.StForgeDone()
		return
	Using = 1
	var/t = LIFE_METAL_TIER[mid]
	var/perf = RunLifeMinigame(src, "rapid_tap", t, list("level" = SmithingLevel(), "target" = S))
	Using = 0
	if(perf < 0)
		if(client) client.StForgeDone()
		return
	var/batch = max(1, SmithingLevel())
	var/made = 0
	while(made < batch)
		var/avgq = 0
		if(mid == "bronze")
			if(CountMaterial(src, "Copper") < 1 || CountMaterial(src, "Tin") < 1 || CountMaterial(src, "Coal") < 1) break
			avgq = (LifeConsumeBest(src, "Copper", 1) + LifeConsumeBest(src, "Tin", 1)) / 2
			LifeConsumeBest(src, "Coal", 1)
		else if(mid == "steel")
			if(CountMaterial(src, "Iron") < 1 || CountMaterial(src, "Coal") < 2) break
			avgq = LifeConsumeBest(src, "Iron", 1)
			LifeConsumeBest(src, "Coal", 2)
		else
			if(CountMaterial(src, "[LIFE_METAL_NAME[mid]]Ore") < 2 || CountMaterial(src, "Coal") < 1) break
			avgq = LifeConsumeBest(src, "[LIFE_METAL_NAME[mid]]Ore", 2)
			LifeConsumeBest(src, "Coal", 1)
		var/q = round(avgq, 1)
		if(perf >= 1.4) q++
		if(perf < 0.7) q--
		q = QualityClamp(min(q, LifeQualityCap(rank)))
		GiveMaterial(src, LIFE_INGOT_TYPE[mid], 1, q)
		made++
	if(!made)
		src << "The materials ran out before anything came of it."
		if(client) client.StForgeDone()
		return
	src << "<font color=#78eb78>You smelt [made]x [LIFE_METAL_NAME[mid]] Ingot.</font>"
	LifeLogFind("Smithing", "[LIFE_METAL_NAME[mid]] Ingot")
	AddLifeXP("Smithing", LifeCraftXP("Smithing", t) * 0.5, perf)
	if(client) client.StForgeDone()

proc/LifeCountExact(mob/M, cls, quality)
	return M ? M.MatLogCountQ(cls, quality) : 0

// eat one exact quality from the log; returns count consumed
proc/LifeConsumeExact(mob/M, cls, quality, count)
	if(!M || count <= 0) return 0
	return M.MatLogTakeQ(cls, quality, count)

proc/ApplyGearMetalStats(obj/Items/I, mid, shapeW)
	if(!I || !mid) return
	var/list/T = LIFE_METAL_TRAITS[mid]
	if(!T) return
	var/f = (shapeW ? shapeW : 1) * LIFE_GEARQ_SCALE[QualityClamp(I.CraftQuality)]
	if(istype(I, /obj/Items/Sword))
		I.DamageEffectiveness += T["wDmg"] * f
		I.AccuracyEffectiveness += T["wAcc"] * f
		I.SpeedEffectiveness += T["wSpd"] * f
	else if(istype(I, /obj/Items/Armor))
		I.DamageEffectiveness += T["aAbs"] * f
		I.AccuracyEffectiveness += T["aAcc"] * f
		I.SpeedEffectiveness += T["aSpd"] * f
	else
		return
	if(I.CraftQuality == QUAL_LEGENDARY)
		I.DamageEffectiveness *= LIFE_LEG_AUGMENT
		I.AccuracyEffectiveness *= LIFE_LEG_AUGMENT
		I.SpeedEffectiveness *= LIFE_LEG_AUGMENT
	if(I.craft_capstone)   // rank-10 Master Smith: everything comes out 5% stronger
		I.DamageEffectiveness *= LIFE_CAPSTONE_SMITH_MULT
		I.AccuracyEffectiveness *= LIFE_CAPSTONE_SMITH_MULT
		I.SpeedEffectiveness *= LIFE_CAPSTONE_SMITH_MULT
	if(istype(I, /obj/Items/Armor) && I.DamageEffectiveness < 0)
		I.DamageEffectiveness = 0
	if(I.SpeedEffectiveness < 0.05)
		I.SpeedEffectiveness = 0.05   // delay divisor, 0 breaks the math

proc/ApplyGemToGear(obj/Items/I, gid, gq)
	var/list/E = LIFE_GEM_EFFECT[gid]
	if(!I || !E) return
	var/mag = QualityClamp(gq)
	for(var/k in E["plus"])
		switch(k)
			if("Str") I.strAdd += mag
			if("End") I.endAdd += mag
			if("For") I.forAdd += mag
			if("Spd") I.spdAdd += mag
			if("Off") I.offAdd += mag
			if("Def") I.defAdd += mag
	for(var/k in E["minus"])
		switch(k)
			if("Str") I.strAdd -= mag
			if("End") I.endAdd -= mag
			if("For") I.forAdd -= mag
			if("Spd") I.spdAdd -= mag
			if("Off") I.offAdd -= mag
			if("Def") I.defAdd -= mag
	I.gem_id = gid
	I.gem_quality = mag

proc/GemStatLine(gid, gq)
	var/list/E = LIFE_GEM_EFFECT[gid]
	if(!E) return ""
	var/mag = QualityClamp(gq)
	var/plus = ""
	for(var/k in E["plus"])
		plus += "[plus ? " " : ""]+[mag] [uppertext(k)]"
	var/minus = ""
	for(var/k in E["minus"])
		minus += "[minus ? " " : ""]-[mag] [uppertext(k)]"
	return "<font color=#78eb78>[plus]</font> / <font color=#ff6464>[minus]</font>"

// random quality bounded by rank; mats + performance + tools push the roll
proc/LifeRollGearQuality(mob/M, avgq, perf, mid, hqb = -1)
	var/rank = M.LifeRank("Smithing")
	if(hqb < 0)
		var/obj/Items/LifeTool/hammer = GetBestLifeTool(M, "Hammer")
		hqb = hammer ? hammer.QualityBonus : 0
	var/P = 25 * (avgq - 1) + 30 * max(0, perf - 0.5) + hqb + 3 * rank
	var/roll = P + rand(-15, 15)
	var/q = QUAL_POOR
	// legendary sits above every roll but rank 10's best (max P 182 +15 = 197), so it's rank-10-only and tops ~10%
	if(roll >= 195) q = QUAL_LEGENDARY
	else if(roll >= 145) q = QUAL_EPIC
	else if(roll >= 105) q = QUAL_GOOD
	else if(roll >= 55) q = QUAL_NORMAL
	if(mid == "gold" && prob(8)) q++   // gold's the lucky metal - it can punch a tier up, legendary included
	return QualityClamp(clamp(q, LIFE_QFLOOR_BY_RANK[clamp(rank, 1, LIFE_MAX_RANK)], LifeQualityCap(rank)))

// craft-time-only stamping: identity, adds, durability, passives, gem, mat, tint
proc/LifeStampGear(obj/Items/I, datum/craft_recipe/life/R, mid, rank, list/gem, list/mmat)
	I.metal_id = mid
	I.craft_ingots = R.ingot_count
	I.craft_shape_w = R.shape_w
	I.craft_capstone = (rank >= LIFE_MAX_RANK)   // read by ApplyGearMetalStats so buffs can't wipe it
	ApplyGearMetalStats(I, mid, R.shape_w)
	var/list/T = LIFE_METAL_TRAITS[mid]
	// no recipe/metal flat adds - stat adds come only from gems
	if(I.ShatterMax)
		var/dura = T ? T["dura"] : 1
		I.ShatterMax = max(1, round(I.ShatterMax * dura * LIFE_QUALITY_MULT[QualityClamp(I.CraftQuality)]))
		I.ShatterCounter = I.ShatterMax
	// metal passives ride the normal equip hook
	var/list/mpass = null
	if(istype(I, /obj/Items/Sword)) mpass = T ? T["wpass"] : null
	else if(istype(I, /obj/Items/Armor)) mpass = T ? T["apass"] : null
	if(mpass)
		if(!I.passives) I.passives = list()
		for(var/k in mpass)
			I.passives[k] = (I.passives[k] ? I.passives[k] : 0) + mpass[k]
	// legendary weapons and armor never break, and only one leaves the anvil per day
	if(I.CraftQuality == QUAL_LEGENDARY && (istype(I, /obj/Items/Sword) || istype(I, /obj/Items/Armor)))
		I.Destructable = 0
		I.ShatterTier = 0
	// gem socket - additive, after the legendary multiply so it never scales
	if(gem && gem.len >= 2)
		ApplyGemToGear(I, gem[1], gem[2])
	// monster material - passive magnitude from the MAT's quality only
	if(mmat && mmat.len >= 2)
		ApplyMonsterMatToGear(I, mmat[1], mmat[2])
	I.color = LIFE_METAL_UI_RGB[mid]

proc/LifeStageBanner(mob/M, stage, label, list/perfs)
	if(!M || !M.client) return
	var/atom/movable/lifebar/b = new
	b.icon = null
	var/atom/movable/lifebar/part/text/t = new
	t.maptext_width = 198
	t.maptext_height = 32
	t.pixel_y = 30
	t.layer = b.layer + 0.3
	var/pips = ""
	for(var/i = 1 to 3)
		if(perfs && i <= perfs.len)
			var/p = perfs[i]
			pips += "<font color=[p >= 1.2 ? "#78eb78" : (p >= 0.8 ? "#ffd86b" : "#ff6464")]>&#9679;</font>"
		else
			pips += "<font color=#6b7a8d>&#9679;</font>"
	t.maptext = "<center><span style=\"[LIFE_FONT]; color:#ffffff\">STAGE [stage]/3 - [label]<br>[pips]</span></center>"
	b.vis_contents += t
	M.client.screen += b
	spawn(8)
		if(M && M.client) M.client.screen -= b
		del t
		del b

mob/proc/DoForge(obj/LifeSkills/Station/S, datum/craft_recipe/life/R, mid, list/gem, list/mmat, mq = 0)
	if(!client || KO || Dead || !R || !mid)
		if(client) client.StForgeDone()
		return
	if(Using)
		src << "You're in the middle of something."
		client.StForgeDone()
		return
	if(client.life_minigame_sink)
		src << "Finish what you're doing first."
		return
	var/rank = LifeRank("Smithing")
	if(R.rank_req > rank)
		src << "You don't know how to forge that yet. (Smithing rank [R.rank_req])"
		client.StForgeDone()
		return
	if(LIFE_METAL_TIER[mid] < R.metal_min_tier)
		client.StForgeDone()
		return
	var/mhave = mq ? LifeCountExact(src, LIFE_METAL_NAME[mid], mq) : CountMaterial(src, LIFE_METAL_NAME[mid])
	if(mhave < R.ingot_count)
		src << "You need [R.ingot_count]x [mq ? "[QualityName(mq)] " : ""][LIFE_METAL_NAME[mid]] ingots."
		client.StForgeDone()
		return
	if(R.wood_count && LifeCountAnyWood(src) < R.wood_count)
		src << "You need [R.wood_count]x wood of any kind for the haft."
		client.StForgeDone()
		return
	// slots only exist on weapons and armor, and only at rank
	var/gear = (ispath(R.result_type, /obj/Items/Sword) || ispath(R.result_type, /obj/Items/Armor))
	if(gem && (!gear || rank < LIFE_GEM_SLOT_RANK)) gem = null
	if(mmat && (!gear || rank < LIFE_MAT_SLOT_RANK)) mmat = null
	var/cost = R.money_cost ? round(R.money_cost * glob.progress.EconomyCost) : 0
	if(cost && !HasMoney(cost))
		src << "You need [Commas(cost)] for the fittings and supplies."
		client.StForgeDone()
		return
	if(!S || get_dist(src, S) > 1)
		src << "You need to be next to the anvil."
		client.StForgeDone()
		return
	if(!UseLifeStamina(LIFE_COST_CRAFT))
		client.StForgeDone()
		return
	Using = 1
	var/obj/Items/LifeTool/hammer = GetBestLifeTool(src, "Hammer")
	var/D = LIFE_GEAR_DIFF(LIFE_METAL_TIER[mid], R.shape_diff)
	var/speed = clamp(LIFE_SPEED_BASE + LIFE_SPEED_PER_DIFF * D + LIFE_SPEED_PER_UNDER * max(0, D - rank) - LIFE_SPEED_PER_OVER * max(0, rank - D), LIFE_SPEED_MIN, LIFE_SPEED_MAX)
	if(hammer) speed *= max(0.7, 1 - hammer.SweetSpotBonus)   // a good hammer steadies the strikes

	// stage 1: SHAPE - two strikes
	LifeStageBanner(src, 1, "SHAPE", null)
	sleep(8)
	var/p1 = 0
	var/aborted = 0
	for(var/i = 1 to 2)
		var/p = RunLifeMinigame(src, "timing_bar", D, list("speed_mult" = speed, "target" = S))
		if(p < 0)
			aborted = 1
			break
		p1 += p / 2
	// stage 2: HAMMER
	var/p2 = 0
	if(!aborted)
		LifeStageBanner(src, 2, "HAMMER", list(p1))
		sleep(8)
		p2 = RunLifeMinigame(src, "rapid_tap", -round(-D / 2), list("level" = SmithingLevel(), "target" = S))
		if(p2 < 0) aborted = 1
	// stage 3: TEMPER - hold to fill before the pointers land
	var/p3 = 0
	if(!aborted)
		LifeStageBanner(src, 3, "TEMPER", list(p1, p2))
		sleep(8)
		var/need = LIFE_HOLD_NEED(D)
		var/limit = round(need * LIFE_HOLD_GRACE(D, rank))
		p3 = RunLifeMinigame(src, "hold_fill", D, list("need" = need, "limit" = limit, "target" = S))
		if(p3 < 0) aborted = 1
	Using = 0
	if(aborted)
		src << "The work went cold before you finished."
		if(client) client.StForgeDone()
		return
	var/hqb = hammer ? hammer.QualityBonus : 0   // the hammer that did the work, even if this wear breaks it
	if(hammer) hammer.LifeToolWear(src)
	if(p3 < 1.0)
		// the temper failed - half the bars crack apart. no recipe escapes the wall
		var/lose = max(1, round(R.ingot_count / 2))
		if(mq) LifeConsumeExact(src, LIFE_METAL_NAME[mid], mq, min(lose, LifeCountExact(src, LIFE_METAL_NAME[mid], mq)))
		else LifeConsumeBest(src, LIFE_METAL_NAME[mid], min(lose, CountMaterial(src, LIFE_METAL_NAME[mid])))
		src << "<font color=#ff6464>The temper fails - the piece cracks on the anvil. [R.ingot_count - lose]x ingots survive.</font>"
		AddLifeXP("Smithing", LifeCraftXP("Smithing", R.tier) * 0.25, LIFE_PERF_MIN)
		if(client) client.StForgeDone()
		return
	var/perf = p1 * LIFE_FORGE_W1 + p2 * LIFE_FORGE_W2 + p3 * LIFE_FORGE_W3
	LifeCraftItem(R, mid, perf, cost, gem, mmat, hqb, mq)
	if(client) client.StForgeDone()

mob/proc/LifeCraftItem(datum/craft_recipe/life/R, mid, perf, cost = 0, list/gem, list/mmat, hqb = -1, mq = 0)
	if(!R || !mid) return 0
	var/chave = mq ? LifeCountExact(src, LIFE_METAL_NAME[mid], mq) : CountMaterial(src, LIFE_METAL_NAME[mid])
	if(chave < R.ingot_count)
		src << "The ingots are gone."
		return 0
	if(cost && !HasMoney(cost))
		src << "You no longer have the [Commas(cost)] for supplies."
		return 0
	var/avgq
	if(mq)
		LifeConsumeExact(src, LIFE_METAL_NAME[mid], mq, R.ingot_count)
		avgq = mq
	else
		avgq = LifeConsumeBest(src, LIFE_METAL_NAME[mid], R.ingot_count)
	if(R.wood_count) LifeConsumeAnyWood(src, R.wood_count)
	if(cost) TakeMoney(cost)
	var/rank = LifeRank("Smithing")
	var/q = LifeRollGearQuality(src, avgq, perf, mid, hqb)
	var/gear = (ispath(R.result_type, /obj/Items/Sword) || ispath(R.result_type, /obj/Items/Armor))
	if(gear && q == QUAL_LEGENDARY)
		if(LifeLegendaryForgeDay == DaysOfWipe())
			q = QUAL_EPIC
			src << "The metal answers a smith's calling only once a day. (Epic instead)"
		else
			LifeLegendaryForgeDay = DaysOfWipe()
	// slot materials consume at craft; if they vanished mid-forge the socket just stays empty
	if(gem && gem.len >= 2)
		if(!LifeConsumeExact(src, LIFE_GEM_CLASS[gem[1]], gem[2], 1))
			src << "The [gem[1]] is gone - the socket stays empty."
			gem = null
	if(mmat && mmat.len >= 2)
		if(!LifeConsumeMonsterMat(src, mmat[1], mmat[2]))
			src << "The material is gone - nothing to work in."
			mmat = null

	var/obj/Items/made = new R.result_type
	made.CraftQuality = q
	if(istype(made, /obj/Items/LifeTool))
		var/obj/Items/LifeTool/T = made
		T.SetupTool(R.tool_kind, mid, q)
	else
		LifeStampGear(made, R, mid, rank, gear ? gem : null, gear ? mmat : null)
		made.name = "[q == QUAL_NORMAL ? "" : "[QualityName(q)] "][LIFE_METAL_NAME[mid]] [made.name]"

	if(made.Stackable)
		for(var/obj/Items/o in src)
			if(o.type == made.type && o.CraftQuality == made.CraftQuality && o.metal_id == made.metal_id && o.TotalStack < INV_STACK_MAX)
				o.TotalStack++
				o.suffix = "[o.TotalStack]"
				src << "You forge another [o.name]."
				del made
				break
	if(made)
		if(made.Grabbable)
			if(CanPickupItem(made))
				made.loc = src
			else
				made.loc = loc
				src << "Your pack is full - it drops at your feet."
		else
			made.loc = loc
		made.CreatorKey = ckey
		made.CreatorSignature = EnergySignature
		made.CreatorName = "[name]"
		src << "<font color=#78eb78>You forge [made.name]!</font>"
		if(made.CraftQuality == QUAL_LEGENDARY && gear && client)
			client.ShowLegendNamePrompt(made)
	LifeLogFind("Smithing", R.label)
	AddLifeXP("Smithing", LifeCraftXP("Smithing", R.tier), clamp(perf, LIFE_PERF_MIN, LIFE_PERF_MAX))
	return 1

// ---------------- salvage ----------------

mob/proc/DoSmithSalvage(obj/LifeSkills/Station/S, obj/Items/I)
	if(!client || KO || Dead || !I) return 0
	if(Using)
		src << "You're in the middle of something."
		return 0
	var/rank = LifeRank("Smithing")
	if(rank < LIFE_SALVAGE_RANK)
		src << "You need Smithing rank [LIFE_SALVAGE_RANK] to salvage."
		return 0
	if(I.loc != src || !I.metal_id || I.PermEquip || findtext(I.suffix, "Equipped"))
		if(client) client.RefreshStationMenu()
		return 0
	if(!S || get_dist(src, S) > 1)
		src << "You need to be next to the anvil."
		return 0
	if(!UseLifeStamina(LIFE_COST_SMELT)) return 0
	var/n = max(1, round(max(1, I.craft_ingots) * min(0.75, 0.25 + 0.05 * rank)))
	if(I.Broken) n = max(1, round(n / 2))
	var/q = max(QUAL_POOR, I.CraftQuality - 1)
	var/mid = I.metal_id
	if(I.gem_id)
		src << "<font color=#ff6464>The [LIFE_GEM_CLASS[I.gem_id]] shatters with the piece.</font>"
	// one unit off a stack, the whole item otherwise
	if(I.Stackable && I.TotalStack > 1)
		I.TotalStack--
		I.suffix = "[I.TotalStack]"
	else
		del I
	GiveMaterial(src, LIFE_INGOT_TYPE[mid], n, q)
	src << "<font color=#78eb78>You melt it down for [n]x [LIFE_METAL_NAME[mid]] Ingot.</font>"
	AddLifeXP("Smithing", LIFE_XP_CRAFT_BASE * 0.25, 1)
	if(client) client.RefreshStationMenu()
	return 1

// ---------------- gear ascension ----------------

// what Upgrade Equipment called Reinforce, smith-side. hard cap 5 - asc 6 belongs to passives.
// armor caps at 4 (combat reads no further) and is smith-exclusive - the old verbs never offered it
proc/LifeAscendCeiling(mob/M, obj/Items/I)
	if(!M) return 0
	var/cap = min(5, M.SmithingLevel() + 1, glob.progress.maxAscension)
	if(I && istype(I, /obj/Items/Armor)) cap = min(cap, 4)
	return cap

proc/LifeAscendCost(obj/Items/I)
	return glob.progress.EconomyCost * 5 * (2 ** I.Ascended)

proc/LifeAscendable(mob/M, obj/Items/I)
	if(!I || I.suffix || I.LegendaryItem || I.PermEquip) return 0   // saga gear re-stamps its own ascension - don't sell into that
	if(!(istype(I, /obj/Items/Sword) || istype(I, /obj/Items/Armor) || istype(I, /obj/Items/Enchantment/Staff))) return 0
	if(I:Conjured) return 0
	return I.Ascended < LifeAscendCeiling(M, I)

proc/LifeAscendableItems(mob/M)
	var/list/out = list()
	if(!M || M.LifeRank("Smithing") < 5) return out
	for(var/obj/Items/I in M)
		if(LifeAscendable(M, I)) out += I
	return out

mob/proc/DoSmithAscend(obj/LifeSkills/Station/S, obj/Items/I)
	if(!client || KO || Dead || !I) return 0
	if(Using)
		src << "You're in the middle of something."
		return 0
	if(LifeRank("Smithing") < 5)
		src << "You need Smithing rank 5 to ascend gear."
		return 0
	if(I.loc != src || !LifeAscendable(src, I))
		if(client) client.RefreshStationMenu()
		return 0
	if(!S || get_dist(src, S) > 1)
		src << "You need to be next to the anvil."
		return 0
	if(TotalFatigue > 50)
		src << "You're too tired to work metal this fine."
		return 0
	if(TotalCapacity > 90)
		src << "You're too drained to work metal this fine."
		return 0
	var/cost = LifeAscendCost(I)
	if(!HasMoney(cost))
		src << "You need $[Commas(cost)] for the materials and supplies."
		return 0
	TakeMoney(cost)
	I.Ascended++
	I:Update_Description()
	GainFatigue(50 / max(1, ArmamentEnchantmentUnlocked, SmithingLevel()))
	src << "<font color=#78eb78>[I.name] ascends under your careful effort. ([I.Ascended]/[LifeAscendCeiling(src, I)])</font>"
	if(client) client.RefreshStationMenu()
	return 1

// the rank 3+ alternative to paying full reforge price, driven from the anvil menu
mob/proc/DoSmithRepair(obj/LifeSkills/Station/S, obj/Items/I, mid)
	if(!client || KO || Dead || !I || !mid) return 0
	if(Using)
		src << "You're in the middle of something."
		return 0
	if(LifeRank("Smithing") < 3)
		src << "You need Smithing rank 3 to smith-repair."
		return 0
	if(I.loc != src || !I.Broken)
		if(client) client.RefreshStationMenu()
		return 0
	if(!S || get_dist(src, S) > 1)
		src << "You need to be next to the anvil."
		return 0
	if(CountMaterial(src, LIFE_METAL_NAME[mid]) < 2)
		src << "You need 2 ingots of one metal to smith-repair."
		return 0
	var/cost = round(ReforgeCostFor(src, I) * 0.25, 1)
	if(cost && !HasMoney(cost))
		src << "You still need [Commas(cost)] for supplies."
		return 0
	if(!UseLifeStamina(LIFE_REFORGE_LS_COST)) return 0
	if(!LifeConsumeBest(src, LIFE_METAL_NAME[mid], 2))
		return 0
	if(cost) TakeMoney(cost)
	I.ShatterCounter = I.ShatterMax
	I.Broken = 0
	I.suffix = 0
	OMsg(src, "[src] hammers [I] back into shape!")
	AddLifeXP("Smithing", LIFE_XP_CRAFT_BASE, 1)
	if(client) client.RefreshStationMenu()
	return 1

// ---------------- projection (the bench preview runs the SAME math as the forge) ----------------

proc/LifeFmtMult(label, lo, hi)
	var/col = "#ffffff"
	if(hi > 1.001) col = "#78eb78"
	else if(hi < 0.999) col = "#ff6464"
	if(abs(hi - lo) < 0.005)
		return "<font color=[col]>[label] x[num2text(hi, 3)]</font>"
	return "<font color=[col]>[label] x[num2text(lo, 3)] - x[num2text(hi, 3)]</font>"

proc/LifeFmtAdd(stat, lo, hi)
	var/col = (hi >= 0) ? "#78eb78" : "#ff6464"
	var/s = (lo == hi) ? "[hi >= 0 ? "+" : ""][hi]" : "[lo >= 0 ? "+" : ""][lo] to [hi >= 0 ? "+" : ""][hi]"
	return "<font color=[col]>[s] [uppertext(stat)]</font>"

// one stat set at one quality - shared by the projection's floor and cap passes
proc/LifeGearStatsAt(datum/craft_recipe/life/R, mid, q, rank)
	var/obj/Items/T = LifeRecipeTemplate(R)
	var/list/MT = LIFE_METAL_TRAITS[mid]
	var/f = R.shape_w * LIFE_GEARQ_SCALE[QualityClamp(q)]
	var/isw = istype(T, /obj/Items/Sword)
	var/dmg = T.DamageEffectiveness + (MT ? MT[isw ? "wDmg" : "aAbs"] * f : 0)
	var/acc = T.AccuracyEffectiveness + (MT ? MT[isw ? "wAcc" : "aAcc"] * f : 0)
	var/spd = T.SpeedEffectiveness + (MT ? MT[isw ? "wSpd" : "aSpd"] * f : 0)
	if(q == QUAL_LEGENDARY)
		dmg *= LIFE_LEG_AUGMENT
		acc *= LIFE_LEG_AUGMENT
		spd *= LIFE_LEG_AUGMENT
	if(rank >= LIFE_MAX_RANK)   // Master Smith capstone rides the effectiveness now
		dmg *= LIFE_CAPSTONE_SMITH_MULT
		acc *= LIFE_CAPSTONE_SMITH_MULT
		spd *= LIFE_CAPSTONE_SMITH_MULT
	if(!isw && dmg < 0) dmg = 0
	if(spd < 0.05) spd = 0.05
	var/dura = round(T.ShatterMax * (MT ? MT["dura"] : 1) * LIFE_QUALITY_MULT[QualityClamp(q)])
	return list("dmg" = dmg, "acc" = acc, "spd" = spd, "dura" = dura)

// preview body for the workbench. floor..cap band at the smith's rank with these mats.
proc/LifeProjBandQ(P)
	if(P >= 195) return QUAL_LEGENDARY
	if(P >= 145) return QUAL_EPIC
	if(P >= 105) return QUAL_GOOD
	if(P >= 55) return QUAL_NORMAL
	return QUAL_POOR

proc/LifeProjectGearStats(mob/M, datum/craft_recipe/life/R, mid, list/gem, list/mmat, mq = 0)
	if(!M || !R || !mid) return ""
	var/rank = M.LifeRank("Smithing")
	var/qf = LIFE_QFLOOR_BY_RANK[clamp(rank, 1, LIFE_MAX_RANK)]
	var/qc = LifeQualityCap(rank)
	if(qc == QUAL_LEGENDARY && M.LifeLegendaryForgeDay == DaysOfWipe())
		qc = QUAL_EPIC
	if(mq)
		var/obj/Items/LifeTool/ph = GetBestLifeTool(M, "Hammer")
		var/phqb = ph ? ph.QualityBonus : 0
		var/Pbase = 25 * (mq - 1) + phqb + 3 * rank
		qf = clamp(LifeProjBandQ(Pbase - 15), qf, qc)
		qc = clamp(LifeProjBandQ(Pbase + 30 + 15), max(qf, LIFE_QFLOOR_BY_RANK[clamp(rank, 1, LIFE_MAX_RANK)]), qc)
	var/list/lo = LifeGearStatsAt(R, mid, qf, rank)
	var/list/hi = LifeGearStatsAt(R, mid, qc, rank)
	var/obj/Items/T = LifeRecipeTemplate(R)
	var/isw = istype(T, /obj/Items/Sword)
	var/out = "<font color=[QualityColor(qf)]>[QualityName(qf)]</font>[qf == qc ? "" : " - <font color=[QualityColor(qc)]>[QualityName(qc)]</font>"]<br>"
	if(M.LifeRank("Smithing") >= 8 && M.LifeLegendaryForgeDay == DaysOfWipe())
		out += "<font color=#6b7a8d>Legendary: forged today</font><br>"
	out += "[LifeFmtMult(isw ? "DMG" : "ABSORB", lo["dmg"], hi["dmg"])]<br>"
	out += "[LifeFmtMult("ACC", lo["acc"], hi["acc"])]<br>"
	out += "[LifeFmtMult("SPD", lo["spd"], hi["spd"])]<br>"
	out += "DURABILITY [lo["dura"]][lo["dura"] == hi["dura"] ? "" : " - [hi["dura"]]"][qc == QUAL_LEGENDARY ? " <font color=#ffd86b>(Legendary: unbreakable)</font>" : ""]<br>"
	var/list/MT = LIFE_METAL_TRAITS[mid]
	var/list/mpass = MT ? (isw ? MT["wpass"] : MT["apass"]) : null
	if(mpass)
		for(var/k in mpass)
			out += "<font color=#8be9ff>[k] +[mpass[k]]</font> "
		out += "<br>"
	if(gem && gem.len >= 2)
		out += "SOCKET: <font color=[QualityColor(gem[2])]>[LIFE_GEM_CLASS[gem[1]]]</font> [GemStatLine(gem[1], gem[2])]<br>"
	if(mmat && mmat.len >= 2)
		out += "ESSENCE: [LifeMonsterMatLine(mmat[1], mmat[2])]<br>"
	// what you're holding now, for the only question that matters
	var/obj/Items/eq = isw ? M:EquippedSword() : M:EquippedArmor()
	if(eq)
		var/cmp = ""
		if(hi["dmg"] > eq.DamageEffectiveness + 0.001) cmp += "<font color=#78eb78>+[isw ? "DMG" : "ABSORB"]</font> "
		else if(hi["dmg"] < eq.DamageEffectiveness - 0.001) cmp += "<font color=#ff6464>-[isw ? "DMG" : "ABSORB"]</font> "
		if(hi["acc"] > eq.AccuracyEffectiveness + 0.001) cmp += "<font color=#78eb78>+ACC</font> "
		else if(hi["acc"] < eq.AccuracyEffectiveness - 0.001) cmp += "<font color=#ff6464>-ACC</font> "
		if(hi["spd"] > eq.SpeedEffectiveness + 0.001) cmp += "<font color=#78eb78>+SPD</font> "
		else if(hi["spd"] < eq.SpeedEffectiveness - 0.001) cmp += "<font color=#ff6464>-SPD</font> "
		if(cmp) out += "vs equipped: [cmp]"
	return out
