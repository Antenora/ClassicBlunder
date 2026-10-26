#define MAIM_TIER_MAX 3
#define MAIM_CREEP_PER_HIT 0.0001
#define MAIM_CREEP_ESCALATE 0.02
#define MAIM_CREEP_EPSILON 0.000001
#define MAIM_ESCALATE_RESETS_MAGNITUDE 1
#define MAIM_HEAL_SECONDS_PER_TIER 86400
#define MAIM_SETTLE_TICKS 600
#define MAIM_MULT_FLOOR 0.05

var/list/MAIM_PARTS = list("Head", "Arms", "Legs", "Torso")
var/list/MAIM_FLAT_KINDS = list("PureReduction")
var/list/MAIM_QUALITY_HEAL_MULT = list(1.0, 1.15, 1.3, 1.5, 1.75)
var/list/MAIM_EFFECTS = list(
	"Head" = list(list("Cooldown" = 0.1), list("Off" = -0.1), list("For" = -0.2)),
	"Arms" = list(list("Str" = -0.1), list("WeaponDamage" = -0.1), list("AttackDelay" = 0.2)),
	"Legs" = list(list("Spd" = -0.1), list("Def" = -0.1), list("Move" = -0.5)),
	"Torso" = list(list("End" = -0.1), list("PureReduction" = -5), list("Energy" = -0.2)))
