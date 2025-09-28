// jesus christ lets get a grip
#define GODS list("Janus", "The Calamity")
#define WSNAMES list("Masamune", "Durendal", "Kusanagi", "Caledfwlch", "Muramasa", "Soul Calibur", "Soul Edge", "Dainsleif", "Ryui Jingu Bang")
#define BRONZECLOTHS list("Pegasus","Dragon","Cygnus","Andromeda","Phoenix","Unicorn")
#define GOLDCLOTHS list("Aries",/* "Taurus" */,"Gemini","Cancer","Leo","Virgo","Libra","Scorpio", "Sagittarius","Capricorn","Aquarius","Pisces")

proc/DEBUGMSG(msg)
	if(DEBUGGING)
		world<<"DEBUG: [msg]"

var/globalTracker/glob = new()

/mob/Admin2/verb/editGlobalVariables()
	set name = "Edit Global Variables"
	set category = "Admin"
	var/atom/A = glob
	var/Edit="<html><Edit><body bgcolor=#000000 text=#339999 link=#99FFFF>"
	var/list/B=new
	Edit+="[A]<br>[A.type]"
	Edit+="<table width=10%>"
	for(var/C in A.vars)
		B+=C
		CHECK_TICK
	for(var/C in B)
		Edit+="<td><a href=byond://?src=\ref[A];action=edit;var=[C]>"
		Edit+=C
		if(istype(A.vars[C], /datum) && !istype(A.vars[C], /obj))
			if(A.vars[C].type in typesof(/datum))
				Edit+="<td><a href=byond://?src=\ref[A.vars[C]];action=edit;var=[C]>[C]</td></tr>"
		else
			Edit+="<td>[Value(A.vars[C])]</td></tr>"
		CHECK_TICK
	Edit += "</html>"
	usr<<browse(Edit,"window=[A];size=450x600")

/mob/Admin3/verb/Debuff_Apply(n as num)
	glob.BURN_INTENSITY = n
	glob.SHOCK_INTENSITY = n
	glob.SLOW_INTENSITY = n
	glob.SHATTER_INTENSITY = n
	glob.POISON_INTENSITY= n

racials
	var
		MARKEDPREYBASESTACKS = 5
		MARKEDPREYENDREDUC = 0.02
		MARKEDPREYPURERED = 0.1
		SOULDRAINMAX = 5
		SOULDRAINPER = 0.5
		SOULDRAINHEAL = 0.5
		UNDYINGRAGE_HEAL = 2.5
		UNDYINGRAGE_DURATION = 3
		COWLSHIELDVAL = 0.025
		DEVIL_ARM_STAT_MULTS = FALSE
		DEMON_NAME = "Shatterspawn"
		REVEALDEMONONTRUEFORM = FALSE
		DEMON_ERODE_DEBUFF_INTENSITY = 0.005
		DEMON_DOT_DEBUFF_INTENSITY = 6
		DEMON_RESOURCE_DEBUFF_INTENSITY = 0.2
		MADNESS_DRAIN = 5
		MADNESS_DRAIN_FORM = 2
		SSJ_BASE_CUT_OFF = 10
		SSJ_BASE_DRAIN = 0.1
		SSJ_CUT_OFF_PER_MAST = 0.25
		SSJ_MIN_MASTERY_GAIN = 0.01
		SSJ_MAX_MASTERY_GAIN = 0.02
		AUTO_SSJ_MASTERY = FALSE
		GRITSUBTRACT = 0.5
		GRITMULT = 5
		GRITDIVISOR = 1000
		YOKAI_MANA_STATS_BASE_BOON = 0.3
		MAKYO_TOTAL_TIME = 18000//30 minutes
		FEATHERDUR = 5
		SPIRITTACTMULT = 2
		CRYOKENESISMAX = 15
		CRYOKENESISDAMAGE = 2
		TOD_DMG_PER_TICK = 0.05

progressTracker

	proc/incrementTotal()
		totalRPPToDate += RPPDaily
		totalPotentialToDate += PotentialDaily
		if(totalPotentialToDate > 100)
			totalPotentialToDate = 100
		if(totalRPPToDate > RPPLimit)
			totalRPPToDate = RPPLimit

	var
//TODO add a proc that increases total rpp/pot daily, ensuring nothing goes over the rpp limit

		Era = 1

//economy
		EconomyIncome = 1000
		EconomyCost = 1000
		EconomyMana = 100
		EconomyMult = 1
		DailyGrindCap = 1000
		maxAscension = 5
		MoneyName = "Dollars"

//potential
		PotentialDaily = 1
		totalPotentialToDate = 31


// rpp
		totalRPPToDate = 0 // a dynamic variable, that just gets added to every day tick
		RPPDaily = 15
		RPPLimit = 0
		RPPStarting = 80
		RPPStartingDays = 0
		RPPBaseMult = 1

		STAT_DIMINISHING_RETURNS = TRUE
		STAT_DIMINISHING_THRESHOLD = 1.25
		STAT_PER_POINT = 0.25
		DENOMINATOR_BASE = 1
		DENOMINATOR_MOD = 0.1
// time
		WipeStart = 0
		DaysOfWipe = 1

		SAGA_T2_POT = 15
		SAGA_T3_POT = 30

		T1_STYLES = list(10, 20)
		T2_STYLES = list(30, 45)
		T3_STYLES = list(60)
		T1_SIGS = list(5, 10, 30)
		T2_SIGS = list(25, 55)

/****************************************************
  *  *  *  *  *  * * GLOBAL TRACKER  *  *  *  *  *  *
 *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
*****************************************************/


globalTracker
	New()
		if(!progress)
			progress = new()
		if(!racials)
			racials = new()

	var

		progressTracker/progress = new()
		racials/racials = new()
// TESTER
		TESTER_MODE = FALSE
		LIVE_TESTING = FALSE
		TESTER_WHITE_LIST = list("Digi-Daisuke","RevealingFortune","Zamas2","Niezan", "Etro", "AMajin", "Redsarge", "Gogeto25",\
 "Tilthour", "Sakata Gintoki San", "Hellbante", "FoxMagnus")
		ALLOW_OTHER_NATIONALITIES = FALSE
		ALLOW_SECOND_NATIONALITIES = FALSE
// TARGETING
		LIMIT_CLICKS = TRUE
		CLICK_SAME_Z_FORCE = TRUE
		MAX_CLICK_DISTANCE = 30
		CANT_CLICK_INVS = TRUE
		ADMIN_INVIS_ONLY = FALSE
		BREAK_TARGET = TRUE
		BREAK_TARGET_ON_Z_CHANGE = TRUE
		BREAK_TARGET_ON_DIST = FALSE
		DEVILARMDEMONONLY = FALSE
		ROOTS_DURATION = 2
		AISCLASHLOCKSMOVEMENT = TRUE
		OUROMACROLOCK = 2
		AVALON_COOLDOWN = 300

//INTIM
		INTIMRATIO = 500
		NEWINTIMCALC = FALSE
		INTIM_REDUCES_DEBUFFS
		SHONENCOUNTERLIMIT = 1
//Wipe Specific
		list/GUILD_RANKINGS = list("Aegis" = 1, "Crimson Dawn" = 2, "Golden Circle" = 3, "Black Ifrit" = 5, "Revenants" = 6)

		list/VOID_LOCATION = list(144,140,15)
		list/currentlyVoidingLoc = list(150,150,1)
		VoidsAllowed = 1
		VoidChance = 78
		VoidMaim = TRUE
		VoidCut = 10
		VOID_MESSAGE = ""
		VOID_TIME = 15 MINUTES
		SHOW_VOID_ROLL = 1

		IGNORE_NOT_LOGGEDIN_LOGINS = TRUE

		list/Spawns = list()


		list/DEATH_LOCATION = list(233, 238, 2)
		list/REGEN_LOCATION = list()
		list/NO_SOUL_LOCATION = list(182, 288, 2)
		HALF_DEMON_POTENTIAL_REQ = 50

// - races
		list/LockedRaces = list()
		list/CustomCommons = list("Majin","Half-Saiyan", "Android")
		RAGE_DIVISOR = 200
		MAX_RAGEPUREDAMAGE = 5
		BASE_HELL_SCALING_RATIO = 0.01
		HELL_SCALING_MULT = 1.5
		UNDERDOG_DIVISOR = 4
		CONQ_HAKI_RACES = list(HUMAN, YOKAI, DEMON, ELF, SAIYAN, NAMEKIAN, MAJIN, MAKYO, DRAGON, BEASTMAN, GAJALAKA, CHANGELING)
		EXTRA_CONQ_HAKI_POWER = 1.5
		CONQ_HAKI_CHANCE = 6
		MONEYORFRAGMENTS = 1 // 1 = fragments, 0 = cash
		REBELHEARTMOD=200
		MYTHICALPUREREDMULT = 3
		SATSUICHANCE = 10
// globals
		WorldBaseAmount = 1
		WorldDamageMult = 1.5
		WorldDefaultAcc = 50
		WorldWhiffRate = 25
		celestialObjectTicks
		NoSagaRaces = list(DEMON, DRAGON, ELF, SAIYAN)
		WILL_NOT_TARP_LIST = list("JustLat", "TheUltimateHope")
		T3_STYLES_GODKI_VALUE = 0.25
		DOUBLESTRIKECHANCE = 10
		TRIPLESTRIKECHANCE = 20
		ASURASTRIKECHANCE = 15
		CUSTOMBUFFMULTTOTAL = 3
		CUSTOMBUFFADDTOTAL = 3
		CUSTOMBUFFPASSIVETOTAL = 2
// combat
		HIT_SCAN_DELAY = 5
		OVERHWELMING_BASE_END_NERF = 0.05
		OVERHWELMING_SHATTER_APPLY = 150
		OVERHWELMING_BASE_PR_NERF = 0.05
		OVERHWELMING_BASE_FLOW = 0.15
		BEAST_OVERHWELMING_STATIC = 20
		RUPTURE_BASE_DAMAGE = 2
		SUNYATA_BASE_CHANCE = 15
		INTERCEPTION_BASE_CHANCE = 10
		INTERCEPTION_NEGATES_DAMAGE = 1

		MOMENTUM_PROCS_OFF_DAMAGE = 1

		HALF_SWORD_ARMOR_REDUCTION = 1
		HALF_SWORD_UNARMOURED_DIVISOR = 10
		IAI_CHANCE = 100 
		IAI_BASE_DAMAGE = 0.15
		PARRY_CHANCE = 100 //TODO: come back here
		PARRY_REDUCTION_MULT = 2
		PARRY_BASE_DMG = 0.3
		MAX_CHAIN_PARRY = 5
		PERSISTENCE_CHANCE_SELF = 6
		PERSISTENCE_CHANCE = 3
		PERSISTENCE_DIVIDES_DAMAGE = TRUE
		PRESISTENCE_DIVISOR_MIN = 1
		PRESISTENCE_DIVISOR_MAX = 8
		PERSISTENCE_NEGATES_DAMAGE = TRUE

		MAX_PERSISTENCE_CALCULATED = 8

		TENACITY_GETUP_CHANCE = 2.5
		TENACITY_VAI_MULT = 2.5
		TENACITY_VAI_MIN = 2
		TENACITY_VAI_MAX = 14


		UNDERDOG_DMG_MULTIPLER = 1
		UNDERDOG_RED_MULTIPLER = 1

		KOB_GETS_STATS_LOW_LIFE = 0
		
		MAX_CRIPPLE_MULT = 2
		CRIPPLE_DIVISOR = 100
		RUPTURED_MOVE_DMG = 0.05

		MECH_LEVEL_MULT = 0.15
		PILOT_MULT = 0.09
		POSE_TIME_NEEDED = 2

		MAX_HARDEN = 20
		DEMONIC_DURA_BASE = 0.04
		MAX_HARDENING = 5
		STYLE_MASTERY_DIVISOR = 10
		HARDENING_BASE = 0.0006
		BASE_STACK_REDUCTION = 0.25
		REGEN_ASC_ONE_HEAL = 3
		HEALTH_POTION_NERF = 4
		BUFF_MASTER_HIGHTHRESHOLD = 1.2
		BUFF_MASTERY_LOWTHRESHOLD = 0.95
		BUFF_MASTERY_LOWMULT = 0.1
		BUFF_MASTERY_HIGHMULT = 0.05
		RUSTING_RATE = 0.25
		TECHNIQUE_MASTERY_DIVISOR = 10
		TECHNIQUE_MASTERY_LIMIT = 2.5 // 1+(techmastery/10) is formula. 2.5 = 15 techmastery before no more does nothing at effectiveness = 1
		FAMILIAR_SKILL_CD = 500
		FAMILIAR_CD_REDUCTION = 30
		AURASPELLONATTACK = 1
		SKILL_BRANCH_LOCK = 1
		FATIGUEDIVIDE = 10

		Q_DIVISOR = 10
		FINISHERDMG = 0.005
		OPENERDMG = 0.005
		DECIDERDMG = 0.2
		SPEEDSTRIKEDIVISOR = 5
		SWEEPSTRIKEDIVISOR = 5
		LIGHT_ATTACK_SPEED_DMG_ENABLED = 1
		LIGHT_ATTACK_SPEED_DMG_EXPONENT = 0.4
		LIGHT_ATTACK_SPEED_DMG_LOWER = 0.5
		LIGHT_ATTACK_SPEED_DMG_UPPER = 3

		ZANZO_SPEED_EXPONENT = 0.25
		ZANZO_SPEED_HIGHEST_CLAMP = 2
		ZANZO_SPEED_LOWEST_CLAMP = 0.25


		USE_SPEED_IN_ZANZO_RECHARGE = 1


		ZANZO_FLICKER_DIVISOR = 5
		ZANZO_FLICKER_LOWEST_CLAMP = 1
		ZANZO_FLICKER_HIGHEST_CLAMP = 2
		ZANZO_FLICKER_BASE_GAIN = 0.15
		BLINK_COST = 0.5
		DEBUFF_INTENSITY = 1.5
		AMPLIFY_MODIFIER = 0.25
		HOTNCOLD_MODIFIER = 5
		HOTNCOLD_DEBUFF_DIVISOR = 25
		HOTNCOLD_STAT_DIVISOR = 150
		ITEM_DEBUFF_APPLY_NERF = 2.5
		BURN_INTENSITY = 1
		SLOW_INTENSITY = 1
		SHATTER_INTENSITY = 1
		SHOCK_INTENSITY = 1
		POISON_INTENSITY = 1
		VENOMBLINDMULT = 10
		CHAOS_CHANCE = 25
		BASE_DEBUFF_REDUCTION_DIVISOR = 100
		BASE_DEBUFF_REDUCTION_DIVISOR_LOWER = 0.05
		BASE_DEBUFF_REDUCTION_DIVISOR_UPPER = 1
		IMPLODE_DIVISOR = 1000
		IMPLODE_CD = 150
		ZORNHAU_MULT = 0.15
//EXTRAS?? //
		MORTAL_BLOW_CHANCE = 8
		MULTIHIT_NERF = FALSE
		GetUpVar = 1 // how fast u get up ?
		MAGIC_BASE_COST = 50
		TECH_BASE_COST = 30
		MAGIC_INTELL_MATTERS = TRUE
		WorldPUDrain = 1
		DMG_CALC_2 = TRUE
// global mults
		WHILEWARPINGNERF = 10
		GATES_PUSPIKE_BASE = 6
		GATES_STAT_MULT_DIVISOR = 25
		SECRET_KNIFE_CHANCE = 100

		ATTACK_DELAY_EXPONENT=0.6
		ATTACK_DELAY_DIVISOR=12
		ATTACK_DELAY_MAX = 20
		ATTACK_DELAY_MIN = 2
		CYBERIZESAGAS = list("King of Braves")
		ENERGY_GEN_DIVISOR = 10
		ENERGY_GEN_MULT = 0.2
		LIFE_GEN_DIVISOR = 10
		LIFE_GEN_MULT = 0.2

		OXYGEN_DRAIN = 3
		OXYGEN_DRAIN_DIVISOR = 2

		CAN_BE_SLOWED_GODSPEED = 6
		SAGAINNOVATION = TRUE
		FA_JIN_BASE_DMG_ADD = 1.75
		FA_JIN_BASE_KB_ADD = 3
		FA_JIN_BASE_COOLDOWN = 250
		FA_JIN_COOLDOWN_REDUCTION = 25
		BASE_WUJUDAMAGE = 0.015
		GLOBAL_BEAM_DAMAGE_DIVISOR = 35
		GLOBAL_QUEUE_DAMAGE = 0.85
		GLOBAL_MELEE_MULT = 0.9
		GLOBAL_POWER_MULT = 1
		GLOBAL_ITEM_DAMAGE_MULT = 0.75
		EXPONENTIAL_PROJ_DAMAGE = FALSE
		PROJ_DAMAGE_MULT = 1
		AUTOHIT_GLOBAL_DAMAGE = 0.8
		SOFT_STYLE_RATIO = 0.3
		SOFT_STYLE_DMG_BOON_DIVISOR = 2
		HARD_STYLE_DMG_BOON_DIVISOR = 3
		SOUL_FIRE_MANA_RATIO = 0.25
		SOUL_FIRE_FATIGUE_RATIO = 0.05
		CHEAP_SHOT_DIVISOR = 40
		HARD_STYLE_RATIO = 0.1
		CURSED_WOUNDS_RATE = 0.25
		GLOBAL_EXPONENT_MULT = 1/3
		GRAPPLE_MELEE_BOON = 1.25
		GRIPPY_MOD = 0.25
		CLAMP_POWER = TRUE
		MIN_POWER_DIFF = 0.5
		MAX_POWER_DIFF = 1.5
		AUTOHIT_GRAB_NERF = 0.5
		PARTY_DAMAGE_NERF = 0.8
		MOD_AFTER_ACC = TRUE
		MANA_STATS_BASE_BOON = 0.15
		NIMBUSRANGE = 10
		NIMBUSCD = 150
		SUPERCHARGECD = 500
		SERRATEDCD = 300
		SERRATEDCHANCE = 2.5
		SERRATED_DAMAGE = 0.25
		POTIONHEAL=2
		SUPERCHARGERATE = 0.1
		ATOMIZERRATE = 0.1
		GLADIATOR_DISARM_MAX = 750
		DISARM_TIMER = 150
		BASE_FLOW_PROB = 5
		BASE_FLUIDFORM_PROB = 5
		BASE_BACKTRACK_PROB = 8
		NEO_DODGERATE = 10
		BOUNCE_REDUCTION = 0.25
		LOWEST_ACC = 25
		MACROCHECKTIME = 3
		CUCK_MACROSTRINGS = TRUE
		CONSTANT_DAMAGE_EXPONENT = 4
		STYLE_EFFECT_CD = 400
		BLINDINGVENOM_CD = 400
		SPIRIT_FLOW_DIVISOR = 4 
		AUTOHIT_HYBRID_AS_MULT = FALSE
		LINGERCHANCE = 5
		GRAPPLE_WHIFF_DAMAGE = 3
		EXTRASTATSONAUTOHIT = FALSE
// effectiveness (dmg calc  shit)
		MELEE_EFFECTIVENESS = 1
		PROJECTILE_EFFECTIVNESS = 1
		GRAPPLE_EFFECTIVNESS = 2
		AUTOHIT_EFFECTIVNESS = 2
		GRAPPLE_DAMAGE_MULT = 1
		MUSCLE_POWER_DIVISOR = 4
		MAX_PURSUER_BOON = 10
		DMG_END_EXPONENT = 0.4
		DMG_STR_EXPONENT = 0.4
		DMG_POWER_EXPONENT = 0.3
		PURE_MODIFIER = 0.5
		PURE_MOD_POST_CALC = TRUE
		TENSION_MULTIPLIER = 1
		MIN_TENSION = 10
		CORRUPTION_GAIN = 1.25
		HELLSTORM_SNARERATE = 3
		HELLSTORM_SNAREDURATION = 3
		FIELD_MODIFIERS = 0.01
		GLUTTONY_MODIFIER = 0.14
		STEADY_MODIFIER = 0.05
		UNARMED_DAMAGE_DIVISOR = 10


		HARDER_THEY_FALL_BIO_DIVISOR = 100 // if u use this when changie first start it will do big damage
		HARDER_THEY_FALL_VAI_DIVISOR = 25 // more often no1 has this much vai, in hindsight deus ex machima will give kob more tha nthis, but they will suffer 2x damage ig

// dmg rolls
		min_damage_roll = 0.2
		upper_damage_roll = 0.8

//SPEED COOLDOWN SHIT
		SPEED_COOLDOWN_MODE = 0
		SPEED_COOLDOWN_EXPONENT = 0.25
		SPEED_COOLDOWN_MIN = 0.75
		SPEED_COOLDOWN_MAX = 1.5


// CC related
		CCDamageModifier = 0.1
		STUN_IMMUNE_TIMER = 250
		MAX_STUN_ADDITION = 100
		MAX_STUN_TIME = 600
		LAUNCH_LOCKOUT = 200
		MAX_LAUNCH_TIME = 25
		TIMESTOP_MULTIPLIER = 70
// acc
		SWORD_GLOBAL_ACCURACY_NERF = 0.1
		STAFF_GLOBAL_ACCURACY_NERF = 0.1
		ARMOR_GLOBAL_ACCURACY_NERF = 0.2
		MAX_SWORD_ASCENSION = 5

		AUTOHIT_WHIFF_DAMAGE = 2
		AUTOHIT_MISS_DAMAGE = 5


		AUTOHIT_WAVE_OFFSHOOT_DAMAGE_DIVISOR = 1

		//Whiff dmg is now rand between these.
		MIN_WHIFF_DMG = 1.25
		MAX_WHIFF_DMG = 1.5


		GRABS_AUTOHIT = 1

		FLUID_FORM_RATE = 0.1
		DESPERATION_HIT_CHANCE = 0.005
		DESPERATION_MAX_HIT_CHANCE = 0.05

		JORDAN_ACCURACY = FALSE

		MIN_JORDAN_ACC_MOD = 0.05
		MAX_JORDAN_ACC_MOD = 3


		OLD_ACCURACY = 0

		MOD_AFTER_ROLL = 0

		//Min & max of AccMult in accuracy formula
		ACC_ACCMULT_MIN = 0.25
		ACC_ACCMULT_MAX = 2
		DEBUG_MESSAGES_ACCURACY = FALSE
		//how large the modifier for accuracy can be (off/def*accmult) clamped between these.

		//How much off, def, and spd contribute.
		ACC_OFF = 0.8
		ACC_DEF = 0.8
		ACC_OFF_SPD = 0.3
		ACC_DEF_SPD = 0.3
		EXTRA_DEF_MOD = 1.1
		//Attaches an exponent to the accmult before clamping.

		//straight multiplier to how much it breaks.
		WEAPON_BREAKER_EFFECTIVENESS = 1
		WEAPON_BREAKER_DIVISOR = 1.5
		WEAPON_ASC_DURA_BOON = 0.3
		//straight multiplier at the end; for ubw saga only (self-inflicted break)
		UBW_BREAK_MULTIPLIER = 10
		//firm multiplies break by a further x5
		UBW_FIRM_BREAK_MULTIPLIER = 5

		//how much copy_blade costs.
		UBW_COPY_COST = 6

		MAX_BREAK_MULT = 6
		MAX_BREAK_VAL = 200


		DEICIDE_DAMAGE_DIVISOR = 2
		HOLY_DAMAGE_DIVISOR = 2
		ABYSS_DAMAGE_DIVISOR = 2
		SLAYER_DAMAGE_DIVISOR = 2
		ENRAGED_DAMAGE_DIVISOR = 2
		SLAYER_DAMAGE_CLAMP = 10
		SPIRIT_FORM_BASE_RATE = 0.15
		SPIRIT_FORM_LEAK_VAL = 3
// -- items -- //

		JSON_PASSIVES = list()
// - swords
		SwordAscDamage= 0.05
		SwordAscAcc= 0.05
		SwordAscDelay= 0.05
// - staffs
		StaffAscDamage = 0.05
		StaffAscAcc = 0.05
		StaffAscDelay = 0.05
// - armor
		ArmorAscDamage = 0.05
		ArmorAscDelay = 0.05
		ArmorAscAcc = 0.05
// not sure why he made them all variable, but its more flexibility= FALSE

		/// Dainsleif Drain
		DainsleifDrainAmount = 0.005
		DainsleifDrain = FALSE

		
		infWeaponSoul = TRUE
		WeaponSoulNames = WSNAMES
		prayerTargetNames = GODS
		list/WeaponSoul = list("Muramasa" = FALSE, "Soul Calibur" = FALSE,"Soul Edge" = FALSE,\
 "Dainsleif" = FALSE)
 // false = open, true = taken

		list/var/Heroes = list("Finn")

		infConstellations = TRUE
		BronzeConstellationNames = BRONZECLOTHS
		GoldConstellationNames = GOLDCLOTHS
		list/BronzeConstellation = list("Pegasus" = FALSE, "Dragon" = FALSE, "Cygnus" = FALSE, "Andromeda" = FALSE, "Phoenix" = FALSE, "Unicorn" = FALSE)
		list/GoldConstellation = list("Aries" = FALSE,"Gemini" = FALSE,"Cancer" = FALSE,"Leo" = FALSE,"Virgo" = FALSE,"Libra" = FALSE,\
"Scorpio" = FALSE,"Capricorn" = FALSE,"Aquarius" = FALSE,"Pisces" = FALSE, "Sagittarius" = FALSE)

		CHIKARA_WHITELIST = FALSE

		STAT_DMG_EXPONENT = 0.75
		SOULTUGMULT = 5

		ALLOW_CLICK_CORPSE = 0
		STACK_ANIMATE_TIME = 4
		list/trueNames = list()

		discordICAnnounceWebhookURL
		discordOOCAnnounceWebhookURL
		discordAdminHelpWebhookURL
// FUNCTIONS

globalTracker/proc/takeLimited(option, n)
	if(vars[option][n] == TRUE)
		usr << "This is already taken, please report this error"
		return
	vars[option][n] = TRUE



globalTracker/proc/ResetSwords()
	WeaponSoul = list("Muramasa" = FALSE, "Soul Calibur" = FALSE,"Soul Edge" = FALSE,\
	"Dainsleif" = FALSE)
	Log("Admin", "All legendary swords have been selected, so the list was reset.")


globalTracker/proc/getOpen(option)
	var/list/returnList = vars["[option]Names"]
	for(var/item in vars[option])
		if(vars[option][item] == TRUE)
			returnList.Remove(item)
	return returnList
