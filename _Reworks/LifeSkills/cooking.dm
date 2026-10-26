#if fexists("../../Icons/Private/Cooking/CookingDishes.dmi") || fexists("Icons/Private/Cooking/CookingDishes.dmi")
#define COOKING_DISH_ICON 'Icons/Private/Cooking/CookingDishes.dmi'
#else
#define COOKING_DISH_ICON 'Icons/Objects/Senzu.dmi'
#endif

#define COOK_SATIATED_CAP 3900
#define COOK_SERVINGS_BASE 3
#define COOK_SERVING_PERF 1.2
#define COOK_SERVING_RANK 6
#define COOK_STAGE_W_CHOP 0.25
#define COOK_STAGE_W_STIR 0.35
#define COOK_STAGE_W_COOK 0.40
#define COOK_COOK_REPS 2

var/list/COOK_DUR_MIN = list(30, 40, 50, 60, 75)
var/list/COOK_FX_YIELD = list(0.10, 0.15, 0.20, 0.25, 0.30)
var/list/COOK_FX_QUALITY = list(4, 6, 8, 10, 12)
var/list/COOK_FX_RECOVER = list(0.05, 0.08, 0.10, 0.13, 0.15)
var/list/COOK_FX_STAT = list(0.01, 0.015, 0.02, 0.025, 0.03)

proc/CookStatName(stat)
	switch(stat)
		if("Str") return "Strength"
		if("End") return "Endurance"
		if("Spd") return "Speed"
		if("For") return "Force"
		if("Off") return "Offense"
		if("Def") return "Defense"
	return stat

/datum/life_matfamily/meat
	root = /obj/Items/Material/Meat
	category = "Meat"
	sell_skill = "Hunting"

/obj/Items/Material/Meat
	icon = 'Icons/LifeSkills/MonsterMats.dmi'
	desc = "A cut of meat from the hunt. A cook will want it."
	var/tier = 1
	lean     { name = "Lean Cut";     MaterialClass = "MeatLean";     icon_state = "slime_meat"; tier = 1 }
	red      { name = "Red Cut";      MaterialClass = "MeatRed";      icon_state = "slime_meat"; tier = 2 }
	marbled  { name = "Marbled Cut";  MaterialClass = "MeatMarbled";  icon_state = "slime_meat"; tier = 3 }
	prime    { name = "Prime Cut";    MaterialClass = "MeatPrime";    icon_state = "crab_meat";  tier = 4 }
	royal    { name = "Royal Cut";    MaterialClass = "MeatRoyal";    icon_state = "crab_meat";  tier = 5 }

proc/CookMeatTypeFor(tier)
	switch(clamp(round(tier), 1, 5))
		if(1) return /obj/Items/Material/Meat/lean
		if(2) return /obj/Items/Material/Meat/red
		if(3) return /obj/Items/Material/Meat/marbled
		if(4) return /obj/Items/Material/Meat/prime
		if(5) return /obj/Items/Material/Meat/royal
	return /obj/Items/Material/Meat/lean

mob/proc/CookGrantMeat(tier, perf, q)
	var/mtype = CookMeatTypeFor(tier)
	if(!mtype) return 0
	var/amt = max(1, round(LIFE_HUNT_BASE_YIELD * perf))
	amt = LifeBonusRound(amt * LifeYieldMult("Hunting"))
	if(amt <= 0) return 0
	q = QualityClamp(q)
	var/matclass = GiveMaterial(src, mtype, amt, q)
	if(!matclass) return 0
	var/mname = LifeMatName(matclass)
	src << "<font color=#78eb78>You cut away [amt]x [QualityName(q)] [mname].</font>"
	LifeLogFind("Hunting", mname)
	return amt

/datum/life_tagset/cooking
	tags = list(\
		"RedHerb" = list("herb"),\
		"GreenHerb" = list("herb"),\
		"GoldenHerb" = list("herb"),\
		"OliveHerb" = list("herb"),\
		"MintSprig" = list("herb"),\
		"FrostHerb" = list("herb"),\
		"Witchweed" = list("herb"),\
		"Nightleaf" = list("herb"),\
		"Ashwort" = list("herb"),\
		"Moonwort" = list("herb"),\
		"BrownCap" = list("mushroom"),\
		"BlueCap" = list("mushroom"),\
		"FieldMushroom" = list("mushroom"),\
		"Morel" = list("mushroom"),\
		"Toadstool" = list("mushroom"),\
		"EmperorCap" = list("mushroom"),\
		"Glowshroom" = list("mushroom"),\
		"FaeMushroom" = list("mushroom"),\
		"WildBerries" = list("sweet"),\
		"ForestNut" = list("sweet"),\
		"Honeycomb" = list("sweet"),\
		"CursedCherries" = list("sweet"),\
		"GoldenApple" = list("sweet"),\
		"StrangeFruit" = list("sweet"),\
		"Wheat" = list("grain"),\
		"Corn" = list("grain"),\
		"Potato" = list("tuber"),\
		"SweetPotato" = list("tuber"),\
		"Lettuce" = list("leafy"),\
		"Spinach" = list("leafy"),\
		"Cabbage" = list("leafy"),\
		"Celery" = list("leafy"),\
		"Broccoli" = list("leafy"),\
		"Onion" = list("allium"),\
		"Leek" = list("allium"),\
		"Garlic" = list("allium"),\
		"GreenPeas" = list("legume"),\
		"PintoBeans" = list("legume"),\
		"Strawberry" = list("berry"),\
		"Blueberry" = list("berry"),\
		"Raspberry" = list("berry"),\
		"BlueGrapes" = list("berry"))

/obj/Items/Edibles
	Health = 1
	layer = MOB_LAYER + 0.5

/obj/Items/Edibles/Dish
	icon = COOKING_DISH_ICON
	desc = "A cooked dish. Click it to eat - a full belly leaves you Well Fed."
	Stackable = 1
	Pickable = 1
	Cost = 0
	var/dish_id = ""

	Click()
		if(!usr) return
		if(loc != usr)
			usr << "You need that in your own pack before you can eat it."
			return
		if(usr.KO)
			usr << "You cannot eat while you are knocked out."
			return
		if(usr.Dead)
			usr << "The dead do not eat."
			return
		usr.EatDish(src)

mob/proc/EatDish(obj/Items/Edibles/Dish/D)
	if(!D || D.loc != src) return 0
	if(KO)
		src << "You cannot eat while you are knocked out."
		return 0
	if(Dead)
		src << "The dead do not eat."
		return 0
	if(Airborne)
		src << "Not while you are off your feet."
		return 0
	var/datum/craft_recipe/lifecraft/cooking/R = LifeCraftRecipe(D.dish_id)
	if(!R)
		src << "You cannot make sense of this dish anymore."
		return 0
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Well_Fed/old = WellFedBuff()
	if(old) old.Trigger(src, 1)
	for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Well_Fed/stale in src)
		if(stale.SlotlessOn) stale.Trigger(src, 1)
		if(stale) DeleteSkill(stale, TRUE)
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Well_Fed/B = new
	B.Configure(R, D.CraftQuality, D.CreatorName)
	AddSkill(B)
	B.Trigger(src, 1)
	if(!BuffOn(B))
		if(B) DeleteSkill(B, TRUE)
		src << "Something stops the meal from settling. Try again in a moment."
		return 0
	Satiated = max(Satiated, min(R.DurationSecs(), COOK_SATIATED_CAP))
	OMsg(src, "[src] eats [D.name].")
	var/cook = B.cook_name
	src << "<font color=#78eb78>Well Fed: [R.FxLine(B.dish_q)] for [R.DurationMin()] min[cook ? ", prepared by [cook]" : ""].</font>"
	D.TotalStack--
	if(D.TotalStack <= 0)
		del D
	else
		D.suffix = "[D.TotalStack]"
	if(client) client.BuildInvPage()
	return 1

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Well_Fed
	name = "Well Fed"
	BuffName = "Well Fed"
	AlwaysOn = 1
	MagicNeeded = 0
	Cooldown = 0
	passives = list()
	var/dish_id = ""
	var/dish_q = QUAL_NORMAL
	var/cook_name = ""

	proc/Configure(datum/craft_recipe/lifecraft/cooking/R, q, cook)
		if(!R) return 0
		dish_id = R.id
		dish_q = QualityClamp(q)
		cook_name = cook ? "[cook]" : ""
		TimerLimit = R.DurationSecs()
		Timer = 0
		StrMult = 1
		EndMult = 1
		SpdMult = 1
		ForMult = 1
		OffMult = 1
		DefMult = 1
		RecovMult = 1
		var/m = 1 + R.FxMag(dish_q)
		switch(R.fx_kind)
			if("stat")
				switch(R.fx_arg)
					if("Str") StrMult = m
					if("End") EndMult = m
					if("Spd") SpdMult = m
					if("For") ForMult = m
					if("Off") OffMult = m
					if("Def") DefMult = m
			if("recover")
				RecovMult = m
		return 1

mob/proc/WellFedBuff()
	var/b = CheckSlotless("Well Fed")
	if(istype(b, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Well_Fed)) return b
	return null

mob/proc/WellFedRecipe()
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Well_Fed/B = WellFedBuff()
	if(!B) return null
	return LifeCraftRecipe(B.dish_id)

mob/proc/WellFedMinutesLeft()
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Well_Fed/B = WellFedBuff()
	if(!B || !B.TimerLimit) return 0
	return max(0, -round(-(B.TimerLimit - B.Timer) / 60))

mob/proc/WellFedLine()
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Well_Fed/B = WellFedBuff()
	if(!B) return ""
	var/datum/craft_recipe/lifecraft/cooking/R = LifeCraftRecipe(B.dish_id)
	if(!R) return ""
	return R.FxLine(B.dish_q)

mob/LifeYieldMult(skill)
	. = ..()
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Well_Fed/B = WellFedBuff()
	if(!B) return
	var/datum/craft_recipe/lifecraft/cooking/R = LifeCraftRecipe(B.dish_id)
	if(!R || R.fx_kind != "yield" || R.fx_arg != skill) return
	. *= (1 + R.FxMag(B.dish_q))

mob/LifeQualityPoints(skill)
	. = ..()
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Well_Fed/B = WellFedBuff()
	if(!B) return
	var/datum/craft_recipe/lifecraft/cooking/R = LifeCraftRecipe(B.dish_id)
	if(!R || R.fx_kind != "quality") return
	. += round(R.FxMag(B.dish_q), 1)

mob/LifeCraftSubExtra()
	. = ..()
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Well_Fed/B = WellFedBuff()
	if(!B) return
	var/datum/craft_recipe/lifecraft/cooking/R = LifeCraftRecipe(B.dish_id)
	if(!R) return
	. = "[.][. ? " | " : ""]Well Fed: [R.label], [WellFedMinutesLeft()] min left"

/datum/craft_recipe/lifecraft/cooking
	skill = "Cooking"
	station = "stove"
	result_count = COOK_SERVINGS_BASE
	var/fx_kind = "yield"
	var/fx_arg = "Mining"
	stages = list(\
		list("id" = "rapid_tap", "label" = "CHOP", "w" = COOK_STAGE_W_CHOP, "reps" = 1, "gate" = 0),\
		list("id" = "stir_spiral", "label" = "STIR", "w" = COOK_STAGE_W_STIR, "reps" = 1, "gate" = 1),\
		list("id" = "timing_bar", "label" = "COOK", "w" = COOK_STAGE_W_COOK, "reps" = COOK_COOK_REPS, "gate" = 0))

	proc/FxMag(q)
		q = QualityClamp(q)
		var/t = clamp(tier, 1, 5)
		switch(fx_kind)
			if("yield") return COOK_FX_YIELD[t] * LIFE_QUALITY_MULT[q]
			if("quality") return COOK_FX_QUALITY[t] * LIFE_QUALITY_MULT[q]
			if("recover") return COOK_FX_RECOVER[t] * LIFE_QUALITY_MULT[q]
			if("stat") return COOK_FX_STAT[t] * LIFE_QUALITY_MULT[q]
		return 0

	proc/FxLabel()
		switch(fx_kind)
			if("yield")
				if(fx_arg == "Fishing") return "Fishing bonus catch"
				return "[fx_arg] yield"
			if("quality") return "Craft quality"
			if("recover") return "Recovery"
			if("stat") return CookStatName(fx_arg)
		return "Nothing"

	proc/FxValue(q)
		if(fx_kind == "quality") return "+[round(FxMag(q), 1)]"
		return "+[round(FxMag(q) * 100, 1)]%"

	proc/FxLine(q)
		return "[FxLabel()] [FxValue(q)]"

	proc/DurationMin()
		return COOK_DUR_MIN[clamp(tier, 1, 5)]

	proc/DurationSecs()
		return DurationMin() * 60

	proc/Servings(mob/M, perf)
		. = COOK_SERVINGS_BASE
		if(perf >= COOK_SERVING_PERF) .++
		if(M && M.LifeRank("Cooking") >= COOK_SERVING_RANK) .++

	Summary(mob/M)
		return FxLine(QUAL_NORMAL)

	Project(mob/M, list/picks)
		. = ..()
		if(!M) return
		var/rank = M.LifeRank(skill)
		var/lo = LIFE_QFLOOR_BY_RANK[clamp(rank, 1, LIFE_MAX_RANK)]
		var/hi = max(lo, LifeQualityCap(rank))
		. += "Effect: [FxLabel()] [FxValue(lo)][lo == hi ? "" : " to [FxValue(hi)]"]"
		. += "Well Fed for: [DurationMin()] min"
		var/base = Servings(M, 1)
		var/best = Servings(M, LIFE_PERF_MAX)
		. += "Servings: [base][best > base ? " (up to [best] at performance [COOK_SERVING_PERF])" : ""]"

	MakeResult(mob/M, q, perf)
		if(!M || !result_type) return null
		var/qq = QualityClamp(q)
		var/n = Servings(M, perf)
		var/obj/Items/Edibles/Dish/made = new result_type
		made.CraftQuality = qq
		made.CreatorKey = M.ckey
		made.CreatorSignature = M.EnergySignature
		made.CreatorName = "[M.name]"
		made.TotalStack = n
		made.suffix = "[n]"
		if(qq != QUAL_NORMAL) made.name = "[QualityName(qq)] [made.name]"
		if(n > COOK_SERVINGS_BASE)
			M << "<font color=#78eb78>[n - COOK_SERVINGS_BASE] extra serving[n - COOK_SERVINGS_BASE == 1 ? "" : "s"] comes off the pan - [n] in all.</font>"
		M.GiveOrDrop(made)
		if(made) return made
		for(var/obj/Items/Edibles/Dish/e in M)
			if(e.type == result_type && e.CraftQuality == qq) return e
		return null

/obj/LifeSkills/Station/Stove
	name = "Stove"
	icon = 'Icons/Turfs/KatiePack/Furniture/Steampunk Stove.png'
	desc = "A cook's stove. Face it and press your Interact key to open the kitchen."
	station_kind = "stove"
	craft_skill = "Cooking"
	craft_title = "KITCHEN"
	craft_verb = "COOK"

mob/Admin4/verb/makeStove()
	set category = "Admin"
	new/obj/LifeSkills/Station/Stove(get_step(src, src.dir))
	src << "Stove placed."

proc/LifeCookingPageBody(mob/M)
	if(!M) return ""
	var/datum/lifeskill/S = M.GetLifeSkill("Cooking")
	var/body = "Face a stove and press [M.InteractKeyName()], or click it, to open the kitchen. Pick a dish, fill its ingredient slots, then pay the Life Stamina and cook.<br>Chop, stir and cook in that order - the stir is the one that matters, and a stir you never finish ruins the dish.<br><br>"
	var/line = M.WellFedLine()
	if(line)
		var/mins = M.WellFedMinutesLeft()
		body += "Well Fed: [line], [mins] minute[mins == 1 ? "" : "s"] left.<br>"
	else
		body += "Well Fed: nothing in your belly right now.<br>"
	var/found = S.collection_log ? S.collection_log.len : 0
	body += "Collection log: [found] dish[found == 1 ? "" : "es"] discovered."
	return body

mob/Admin4/verb/cookGiveIngredients()
	set category = "Admin"
	RegisterLifeMaterials()
	var/list/wanted = list("Meat", "Fish", "Crops", "Fruit", "Flora", "Monster Parts")
	var/n = 0
	for(var/mc in LifeMatRegistry)
		var/datum/matdef/d = LifeMatRegistry[mc]
		if(!d || !(d.category in wanted)) continue
		if(LifeMatTier(mc) > 4) continue
		MatLogAdd(mc, QUAL_NORMAL, 20)
		MatLogAdd(mc, QUAL_GOOD, 10)
		MatLogAdd(mc, QUAL_EPIC, 5)
		n++
	src << "Stocked [n] cooking ingredients, tiers 1 to 4: 20 Normal, 10 Good, 5 Epic of each."

mob/Admin4/verb/cookWellFedInfo()
	set category = "Admin"
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Well_Fed/B = WellFedBuff()
	if(!B)
		src << "<b>Well Fed: not active.</b>"
	else
		var/datum/craft_recipe/lifecraft/cooking/R = LifeCraftRecipe(B.dish_id)
		src << "<b>Well Fed: [R ? R.label : "unknown dish"] ([B.dish_id]), [QualityName(B.dish_q)], by [B.cook_name ? B.cook_name : "nobody"].</b>"
		src << "Effect: [WellFedLine()]. Timer [round(B.Timer, 0.1)]/[B.TimerLimit] ([WellFedMinutesLeft()] min left)."
		src << "SlotlessOn [B.SlotlessOn], Using [B.Using], AlwaysOn [B.AlwaysOn], Cooldown [B.Cooldown]."
		src << "Buff mults: Str [B.StrMult] End [B.EndMult] Spd [B.SpdMult] For [B.ForMult] Off [B.OffMult] Def [B.DefMult] Recov [B.RecovMult]."
		src << "Mob totals: Str [StrMultTotal] End [EndMultTotal] Spd [SpdMultTotal] For [ForMultTotal] Off [OffMultTotal] Def [DefMultTotal] Recov [RecovMultTotal]."
	src << "Satiated: [Satiated]"
	src << "LifeCraftSubExtra: \"[LifeCraftSubExtra()]\""
	for(var/s in LIFE_SKILL_IDS)
		src << " [s]: LifeYieldMult x[round(LifeYieldMult(s), 0.001)], LifeQualityPoints +[LifeQualityPoints(s)]"
