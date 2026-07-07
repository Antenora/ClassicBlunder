// Life Skills tunables

#define LIFE_MAX_RANK 10
#define LIFE_STAMINA_MAX 100

// stamina costs
#define LIFE_COST_GATHER 5
#define LIFE_COST_SMELT 5
#define LIFE_COST_CRAFT 10
#define LIFE_COST_HUNT 5
#define LIFE_COST_FARM_TEND 2

// XP = base * tier * perf
#define LIFE_XP_GATHER_BASE 10
#define LIFE_XP_CRAFT_BASE 25

#define LIFE_PERF_MIN 0.5
#define LIFE_PERF_MAX 1.5

#define LIFE_SEC2EVT(s) ((s) * world.fps)

// mining
#define LIFE_MINING_STRIKES 3
#define LIFE_MINING_BAR_PERIOD 2.4
#define LIFE_MINING_BASE_YIELD 2
#define LIFE_GEM_CHANCE_PER_TIER 1
#define LIFE_NODE_CHARGES_MIN 3
#define LIFE_NODE_CHARGES_MAX 5
#define LIFE_NODE_RESPAWN_SECS 900
#define LIFE_NODE_DENSITY 400
#define LIFE_NODE_ZCAP 60

// bar speed: difficulty itself speeds things up, being under-ranked stacks on top
#define LIFE_SPEED_BASE 0.9
#define LIFE_SPEED_PER_DIFF 0.08
#define LIFE_SPEED_PER_UNDER 0.25
#define LIFE_SPEED_PER_OVER 0.05
#define LIFE_SPEED_MIN 0.6
#define LIFE_SPEED_MAX 3.5

// smelting rapid-tap
#define LIFE_TAP_WINDOW_BASE 3
#define LIFE_TAP_WINDOW_PER_LEVEL 0.4
#define LIFE_TAP_BASE 6
#define LIFE_TAP_PER_TIER 4
#define LIFE_TAP_MIN_GAP 2

// smithing
#define LIFE_TOOL_WEAR 5
#define LIFE_REFORGE_LS_COST 10
#define LIFE_CAPSTONE_SMITH_MULT 1.05

// legendary gathers: only rank 8+, and even then it's a roll
#define LIFE_GATHER_LEG_BASE 2

// gather gate
#define LIFE_GATHER_GATE_OK(rank, diff) ((diff) <= (rank) + 1)
#define LIFE_MINE_GATE_OK(rank, diff) LIFE_GATHER_GATE_OK(rank, diff)

// hunting: monster Potential band (tier 1..5) -> carve difficulty on the shared 1..10 scale
#define LIFE_HUNT_DIFF(tier) ((tier) * 2 - 1)
#define LIFE_CARVE_STRIKES 3
#define LIFE_HUNT_BASE_YIELD 2
#define LIFE_HUNT_DROP_COUNT 2
#define LIFE_REMAINS_DECAY_SECS 90

// gear crafting v2
#define LIFE_LEG_AUGMENT 1.15      // legendary gear: base multipliers get this on top
#define LIFE_LEG_ADD_MULT 1.25     // and the flat adds get this. gems/passives never do.
#define LIFE_GEAR_DIFF(mtier, shape) (clamp((mtier) * 2 - 1 + (shape), 1, 10))

// temper stage: hold the bar full before the pointers land. 4+ ranks out of depth is unwinnable on purpose.
#define LIFE_HOLD_NEED(D) (round((2.0 + 0.35 * (D)) * 10))
#define LIFE_HOLD_GRACE(D, rank) (clamp(1.7 - 0.2 * ((D) - (rank)), 0.75, 2.2))
#define LIFE_HOLD_DECAY 0.34

// forge stage weights - temper counts most
#define LIFE_FORGE_W1 0.35
#define LIFE_FORGE_W2 0.25
#define LIFE_FORGE_W3 0.40

#define LIFE_MAT_SLOT_RANK 5
#define LIFE_GEM_SLOT_RANK 8
#define LIFE_SALVAGE_RANK 2

#define LIFE_FONT "font-family:'monogram'; font-size:12pt"

var/list/LIFE_RANK_XP = list(0, 400, 1000, 2000, 3600, 6000, 9500, 14500, 21000, 30000)
var/list/LIFE_RANK_RPP = list(5, 10, 15, 20, 25, 30, 40, 50, 60, 75)
var/list/LIFE_RANK_TITLES = list("Novice", "Apprentice", "Journeyman", "Adept", "Expert", "Artisan", "Veteran", "Renowned", "Virtuoso", "Master")
var/list/LIFE_SKILL_IDS = list("Fishing", "Mining", "Foraging", "Farming", "Hunting", "Smithing", "Cooking", "Thaumaturgy", "Technology")
var/list/LIFE_QUALITY_MULT = list(0.8, 1.0, 1.15, 1.3, 1.5)
// max material quality you can pull at each rank; rank 8+ just makes legendary POSSIBLE
var/list/LIFE_QCAP_BY_RANK = list(2, 2, 3, 3, 4, 4, 4, 5, 5, 5)
// what a ranked smith can no longer botch below
var/list/LIFE_QFLOOR_BY_RANK = list(1, 1, 2, 2, 2, 3, 3, 3, 3, 3)
// metal offsets scale with gear quality - quality sharpens the metal's personality
var/list/LIFE_GEARQ_SCALE = list(0.5, 1.0, 1.4, 1.8, 2.4)

// what each metal IS. wDmg/wAcc/wSpd ride weapon baselines, aAbs/aAcc/aSpd ride armor,
// dura scales ShatterMax, wpass/apass are equip passives.
var/list/LIFE_METAL_TRAITS = list(\
	"copper"     = list("wDmg" =  0.000, "wAcc" =  0.000, "wSpd" =  0.000, "aAbs" =  0.00, "aAcc" =  0.000, "aSpd" =  0.000, "dura" = 0.9, "adds" = list()),\
	"tin"        = list("wDmg" = -0.010, "wAcc" =  0.005, "wSpd" =  0.040, "aAbs" = -0.02, "aAcc" =  0.010, "aSpd" =  0.030, "dura" = 0.7, "adds" = list("Spd" = 1.3, "Str" = 0.85, "Def" = 0.85)),\
	"bronze"     = list("wDmg" =  0.010, "wAcc" =  0.005, "wSpd" =  0.010, "aAbs" =  0.02, "aAcc" =  0.005, "aSpd" =  0.010, "dura" = 1.1, "adds" = list("Str" = 1.05, "End" = 1.05, "For" = 1.05, "Spd" = 1.05, "Off" = 1.05, "Def" = 1.05)),\
	"iron"       = list("wDmg" =  0.020, "wAcc" =  0.000, "wSpd" = -0.020, "aAbs" =  0.05, "aAcc" =  0.000, "aSpd" = -0.020, "dura" = 1.3, "adds" = list("End" = 1.25, "Def" = 1.25, "Spd" = 0.85)),\
	"steel"      = list("wDmg" =  0.025, "wAcc" =  0.005, "wSpd" =  0.000, "aAbs" =  0.06, "aAcc" =  0.005, "aSpd" =  0.000, "dura" = 1.5, "adds" = list("Str" = 1.15, "Def" = 1.15)),\
	"cobalt"     = list("wDmg" =  0.035, "wAcc" = -0.015, "wSpd" =  0.010, "aAbs" =  0.03, "aAcc" = -0.010, "aSpd" =  0.020, "dura" = 1.2, "adds" = list("Str" = 1.3, "Off" = 1.3, "Def" = 0.8), "wpass" = list("CriticalChance" = 5, "CriticalDamage" = 0.05)),\
	"silver"     = list("wDmg" = -0.015, "wAcc" =  0.030, "wSpd" =  0.015, "aAbs" = -0.03, "aAcc" =  0.020, "aSpd" =  0.015, "dura" = 1.0, "adds" = list("Spd" = 1.25, "Off" = 1.1, "Str" = 0.8), "apass" = list("EvilResist" = 2)),\
	"gold"       = list("wDmg" = -0.020, "wAcc" =  0.010, "wSpd" = -0.010, "aAbs" = -0.04, "aAcc" =  0.010, "aSpd" = -0.010, "dura" = 0.5, "adds" = list("Str" = 0.7, "End" = 0.7, "For" = 0.7, "Spd" = 0.7, "Off" = 0.7, "Def" = 0.7)),\
	"mythril"    = list("wDmg" = -0.005, "wAcc" =  0.015, "wSpd" =  0.045, "aAbs" = -0.01, "aAcc" =  0.015, "aSpd" =  0.040, "dura" = 1.2, "adds" = list("Spd" = 1.3, "Off" = 1.3, "End" = 0.9), "wpass" = list("ManaGeneration" = 2), "apass" = list("ManaGeneration" = 2)),\
	"adamantite" = list("wDmg" =  0.030, "wAcc" = -0.005, "wSpd" = -0.030, "aAbs" =  0.09, "aAcc" = -0.015, "aSpd" = -0.030, "dura" = 2.0, "adds" = list("Def" = 1.35, "End" = 1.35, "Spd" = 0.75), "apass" = list("ShatterResist" = 5)),\
	"starmetal"  = list("wDmg" =  0.050, "wAcc" =  0.010, "wSpd" = -0.010, "aAbs" =  0.07, "aAcc" =  0.010, "aSpd" =  0.000, "dura" = 1.4, "adds" = list("Str" = 1.35, "Off" = 1.35, "For" = 1.35, "Def" = 0.9), "wpass" = list("PureDamage" = 1)),\
	"orichalcum" = list("wDmg" =  0.030, "wAcc" =  0.015, "wSpd" =  0.020, "aAbs" =  0.08, "aAcc" =  0.015, "aSpd" =  0.020, "dura" = 1.7, "adds" = list("Def" = 1.3, "End" = 1.3, "Spd" = 1.1, "Str" = 0.9), "apass" = list("BlockChance" = 10, "CriticalBlock" = 0.10)))

// every gem gives AND takes. T4-5 give twice. magnitude = gem quality (1..5) on every listed stat.
var/list/LIFE_GEM_EFFECT = list(\
	"garnet"      = list("plus" = list("Str"),        "minus" = list("Spd")),\
	"turquoise"   = list("plus" = list("Spd"),        "minus" = list("Def")),\
	"rosequartz"  = list("plus" = list("For"),        "minus" = list("Str")),\
	"jade"        = list("plus" = list("Def"),        "minus" = list("Off")),\
	"amethyst"    = list("plus" = list("Off"),        "minus" = list("End")),\
	"tourmaline"  = list("plus" = list("End"),        "minus" = list("For")),\
	"bloodstone"  = list("plus" = list("Str", "Off"), "minus" = list("Def")),\
	"moonstone"   = list("plus" = list("For", "Spd"), "minus" = list("Str")),\
	"sapphire"    = list("plus" = list("Off", "Def"), "minus" = list("Spd")),\
	"emerald"     = list("plus" = list("End", "Def"), "minus" = list("Off")),\
	"obsidian"    = list("plus" = list("Str", "End"), "minus" = list("Spd")),\
	"voidcrystal" = list("plus" = list("Off", "Spd"), "minus" = list("For")))

// desaturated metal casts for gear tinting + desc lines
var/list/LIFE_METAL_UI_RGB = list(\
	"copper" = "#d99c72", "tin" = "#dfe4e8", "bronze" = "#d8b06a", "iron" = "#c9ccd4",\
	"steel" = "#b7c4d4", "cobalt" = "#7f9fe8", "silver" = "#f0f4fa", "gold" = "#ffdf8a",\
	"mythril" = "#a8e2f5", "adamantite" = "#a49ac9", "starmetal" = "#d98a80", "orichalcum" = "#f5b078")
