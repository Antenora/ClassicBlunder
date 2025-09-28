proc/log_func(x, a, b)
	return a * (log(x) / log(10) - b )
#define TIER_1_COST 30
#define TIER_2_COST 60
#define TIER_3_COST 90
#define TIER_4_COST 120
#define TIER_5_COST 200
#define DIRSY list(NORTH, SOUTH)
#define DIRSX list(EAST, WEST)
#define DIRS list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)


#define isai(a) istype(a, /mob/Player/AI)
#define isNPC(a) istype(a, /mob/)
#define TICK_USAGE world.tick_usage

#define TICK_CHECK_LIMIT 75

/// Returns true if tick_usage is above the limit
#define TICK_CHECK ( TICK_USAGE > TICK_CHECK_LIMIT)
/// runs stoplag if tick_usage is above the limit
#define CHECK_TICK ( TICK_CHECK ? stoplag() : 0 )

/// Returns true if tick usage is above 95, for high priority usage
#define TICK_CHECK_HIGH_PRIORITY ( TICK_USAGE > 95 )
/// runs stoplag if tick_usage is above 95, for high priority usage
#define CHECK_TICK_HIGH_PRIORITY ( TICK_CHECK_HIGH_PRIORITY? stoplag() : 0 )

//Key thing that stops lag. Cornerstone of performance in ss13, Just sitting here, in unsorted.dm. Now with dedicated file!

#define BUILD_PAINT "PAINT"
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
#define MAKYO /race/makyo
#define DRAGON /race/dragon
#define ELF /race/high_faoroan
#define YOKAI /race/yokai
#define ELDRITCH /race/eldritch
#define BEASTMAN /race/beastman
#define GAJALAKA /race/gajalaka
#define CHANGELING /race/changeling
#define ANDROID /race/android
#define SHINJIN /race/shinjin

#define DEBUG_DAMAGE 0
#define DEBUG_ITEM_DAMAGE 0
#define DEBUG_MELEE 0
#define DEBUG_AUTOHIT 0
#define DEBUG_GRAPPLE 0
#define DEBUG_PROJECTILE 0


//pacts in pacts.dm
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

var/list/font_rsc=list('fonts/Gotham Book.otf') // forces it into the rsc.

proc
	stoplag()
		var/tickstosleep = 1
		do
			sleep(world.tick_lag*tickstosleep)
			tickstosleep *= 2 //increase the amount we sleep each time since sleeps are expensive (5-15 proc calls)
		while(world.tick_usage > 75 && (tickstosleep*world.tick_lag) < 32) //stop if we get to the point where we sleep for seconds at a time

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