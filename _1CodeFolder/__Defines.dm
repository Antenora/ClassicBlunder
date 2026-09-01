proc/log_func(x, a, b)
	return a * (log(x) / log(10) - b )
#define HUD_PLANE 100

#define TIER_1_COST 30
#define TIER_2_COST 60
#define TIER_3_COST 90
#define TIER_4_COST 120
#define TIER_5_COST 200
#define DIRSY list(NORTH, SOUTH)
#define DIRSX list(EAST, WEST)
#define DIRS list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)

#define isAI(a) istype(a, /mob/Player/AI)
#define isNPC(a) istype(a, /mob/)
#define TICK_USAGE world.tick_usage

#define TICK_CHECK_LIMIT 75

#define TICK_CHECK ( TICK_USAGE > TICK_CHECK_LIMIT)
#define CHECK_TICK ( TICK_CHECK ? stoplag() : 0 )

#define TICK_CHECK_HIGH_PRIORITY ( TICK_USAGE > 95 )
#define CHECK_TICK_HIGH_PRIORITY ( TICK_CHECK_HIGH_PRIORITY? stoplag() : 0 )


#define BUILD_PAINT "PAINT"
#define BUILD_CURVE "CURVED LINE"
#define BUILD_SPRAY "SPRAY"
#define BUILD_RECT "RECTANGLE"
#define BUILD_RECT_HOLLOW "HOLLOW RECTANGLE"
#define BUILD_LINE "LINE"
#define BUILD_FILL "FILL"
#define BUILD_ELLIPSE "ELLIPSE"
#define BUILD_SELECT "SELECT"
#define BUILD_PICK "PICK"

#define BUILD_TURFS "Turfs"
#define BUILD_OBJS "Map Objects"

#define BUILD_MAX_DIM 50

#define TILE_HEIGHT 32
#define TILE_WIDTH 32

#define subtypesof(M) (typesof(M) - (M))
#define isdatum(d) (istype(d, /datum))

#define HUMAN /race/human
#define NAMEKIAN /race/namekian
#define SAIYAN /race/saiyan
#define HALFSAIYAN /race/half_saiyan
#define DEMON /race/demon
#define MAJIN /race/majin
#define MAJIN_ABSORB_Z 19
#define MAJIN_UNHINGED_POWER_MULT 2
#define MAKYO /race/makyo
#define DRAGON /race/dragon
#define ELDRITCH /race/eldritch
#define CHANGELING /race/changeling
#define ANDROID /race/android
#define MAKAIOSHIN /race/makaioshin
#define ANGEL /race/angel
#define POPO /race/popo
#define CELESTIAL /race/celestial
#define NOBODY /race/nobody
#define DEMIFIEND /race/demi_fiend
#define WILDER /race/wilder
#define KEYBLADE_MAGIC "KeybladeMagic"
#define DEBUG_DAMAGE 0
#define DEBUG_ITEM_DAMAGE 0
#define DEBUG_MELEE 0
#define DEBUG_AUTOHIT 0
#define DEBUG_GRAPPLE 0
#define DEBUG_PROJECTILE 0

#define T1_DMG_MULT 4
#define T2_DMG_MULT 6
#define T3_DMG_MULT 8
#define T4_DMG_MULT 10

#define NO_PENALTY 0
#define TAX_PENALTY (1 << 1)
#define HEALTH_PENALTY (1 << 2)
#define ENERGY_PENALTY (1 << 3)
#define MANA_PENALTY (1 << 4)
#define DEATH_PENALTY (1 << 5)
#define PENALTY_LIST list("No Penalty", "Tax Penalty", "Health Penalty", "Energy Penalty", "Mana Penalty", "Death Penalty")
#define PENALTY_TRANSLATION_LIST list("No Penalty" = NO_PENALTY, "Tax Penalty" = TAX_PENALTY, "Health Penalty" = HEALTH_PENALTY, "Energy Penalty" = ENERGY_PENALTY, "Mana Penalty" = MANA_PENALTY, "Death Penalty" = DEATH_PENALTY)

#define PACT_LIMIT 3

#define PACT_OWNER "Owner"
#define PACT_SUBJECT "Subject"

#define PACT_UNBROKEN 0
#define PACT_BROKEN_NO_PENALTY 1
#define PACT_BROKEN_BOTH_PENALTY 2
#define PACT_BROKEN_OWNER_PENALTY 3
#define PACT_BROKEN_SUBJECT_PENALTY 4

var/list/font_rsc=list('fonts/Gotham Book.otf')

proc
	stoplag()
		var/tickstosleep = 1
		do
			sleep(world.tick_lag*tickstosleep)
			tickstosleep *= 2
		while(world.tick_usage > 75 && (tickstosleep*world.tick_lag) < 32)

atom/proc/onBumped(atom/Obstacle)

#define SECONDS *10
#define MINUTES *(60 SECONDS)
#define HOURS *(60 MINUTES)
#define DAYS *(24 HOURS)
#define WEEKS *(7 DAYS)
#define MONTHS *(4 WEEKS)
#define YEARS *(12 MONTHS)

#define SECOND SECONDS
#define MINUTE MINUTES
#define HOUR HOURS
#define DAY DAYS
#define WEEK WEEKS

#define WHISPER_RADIUS 1
#define SAY_RADIUS 12
#define YELL_RADIUS 20
var/regex/LOOCRegex = new(@"^[\(\)\{\}]|[\(\)\{\}]$")
var/regex/yellRegex = new(@"!!!$")
var/regex/questionRegex = new(@"\?$")
var/regex/whisperSlashRegex = new(@"^/w\s")
var/regex/yellSlashRegex = new(@"^/y\s")
#define IC_OUTPUT list("icchat", "output")
#define LOOC_OUTPUT list("loocchat","oocchat","output")
#define ALL_OUTPUT list("loocchat","oocchat","output", "icchat")
#define ALL_NOT_IC_OUTPUT list("loocchat","oocchat","output")

#define YELL "yell"
#define WHISPER "whisper"
#define OBSERVE_HEADER "<b>(OBSERVE)</b>"

#define YELL_NOUNS list("shouts:", "yells:", "screams:")
#define QUESTION_NOUNS list("questions:", "queries:", "asks:")

#define QUAL_POOR      1
#define QUAL_NORMAL    2
#define QUAL_GOOD      3
#define QUAL_EPIC      4
#define QUAL_LEGENDARY 5

#define INV_CATEGORY_CAP 30
#define INV_STACK_MAX 999
