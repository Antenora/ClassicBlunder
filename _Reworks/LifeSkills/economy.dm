#define LIFE_SELL_CAP_FRAC 0.5      // fraction of the daily grind cap sellable per day
#define LIFE_SELL_RANK_MIN 0.3      // price mult at rank 1...
#define LIFE_SELL_RANK_MAX 2.0      // ...up to rank 10

// tier curve flattens on purpose, tier 5 pays barely 3x tier 1
var/list/LIFE_SELL_TIERVAL = list(1.0, 1.7, 2.2, 2.6, 2.9)
var/list/LIFE_SELL_QMULT = list(0.5, 1, 1.6, 2.5, 4)

// which gatherer's rank prices a category
var/list/LIFE_SELL_SKILL = list("Ores" = "Mining", "Ingots" = "Smithing", "Gems" = "Mining", "Fuel" = "Mining", "Monster Parts" = "Hunting", "Flora" = "Foraging", "Wood" = "Foraging", "Fruit" = "Foraging", "Fish" = "Fishing", "Crops" = "Farming")

proc/LifeSellPrice(mob/M, matclass, quality)
	var/datum/matdef/d = LifeMatDef(matclass)
	if(!d) return 0
	var/tier = 1
	var/obj/Items/Material/t = new d.mtype
	if("tier" in t.vars) tier = t.vars["tier"]
	del t
	tier = clamp(tier, 1, 5)
	var/skill = LIFE_SELL_SKILL[d.category]
	var/rank = skill ? M.LifeRank(skill) : 1
	var/rankmult = LIFE_SELL_RANK_MIN + (clamp(rank, 1, LIFE_MAX_RANK) - 1) * ((LIFE_SELL_RANK_MAX - LIFE_SELL_RANK_MIN) / (LIFE_MAX_RANK - 1))
	var/base = LIFE_SELL_TIERVAL[tier] * 0.004 * glob.progress.EconomyCost
	return max(1, round(base * LIFE_SELL_QMULT[QualityClamp(quality)] * rankmult))

// daily sell budget, grind-cap shaped and ascension-scaled
mob/var/matsell_day = -1
mob/var/matsell_earned = 0

mob/proc/MatSellSettleDay()
	if(matsell_day == DaysOfWipe()) return
	matsell_day = DaysOfWipe()
	matsell_earned = 0

mob/proc/MatSellCap()
	return max(1000, round(glob.progress.DailyGrindCap * EconomyMult * LIFE_SELL_CAP_FRAC * (AscensionsAcquired + 1)))

mob/proc/MatSellRemaining()
	MatSellSettleDay()
	return max(0, MatSellCap() - matsell_earned)

// pulls from the log, pays out, partial-fills against the daily budget
mob/proc/DoLogSell(matclass, quality, amount)
	if(!matclass || amount <= 0) return
	MatSellSettleDay()
	var/unit = LifeSellPrice(src, matclass, quality)
	if(unit <= 0) return
	var/remaining = MatSellRemaining()
	if(remaining <= 0)
		src << "<font color=#ff6464>The buyer's coffers are empty for today. Come back tomorrow.</font>"
		return
	var/can_afford = round(remaining / unit)
	if(can_afford < 1)
		src << "<font color=#ff6464>The buyer can't cover even one of those today.</font>"
		return
	amount = min(amount, MatLogCountQ(matclass, quality), can_afford)
	if(amount <= 0) return
	var/taken = MatLogTakeQ(matclass, quality, amount)
	if(taken <= 0) return
	var/total = unit * taken
	matsell_earned += total
	GiveMoney(total)
	src << "<font color=#78eb78>Sold [taken]x [QualityName(quality)] [LifeMatName(matclass)] for $[Commas(total)]. ([Commas(MatSellRemaining())] buyer budget left today)</font>"

// the buyer stall

/obj/LifeSkills/MaterialBuyer
	name = "material buyer"
	desc = "Buys raw materials for cash. Interact to open your log and sell."
	icon = 'Icons/LifeSkills/FarmTools.dmi'
	icon_state = "stall"
	color = "#ffd86b"
	density = 1
	Savable = 1
	InteractWith(mob/M)
		M.client?.OpenLogMenu(src)
		return 1
	Click()
		if(!usr || get_dist(usr, src) > 3) return
		usr.client?.OpenLogMenu(src)

mob/Admin4/verb/makeMaterialBuyer()
	set category = "Admin"
	new/obj/LifeSkills/MaterialBuyer(get_step(src, src.dir))
	src << "Material buyer placed."
