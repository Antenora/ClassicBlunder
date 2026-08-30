// jesus christ lets get a grip
#define GODS list("Zhi Xiuling","Indigo","???","Valdiel")
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
	if(!src.Alert("Are you sure you want to edit global variables?")) return
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
	if(!src.Alert("Are you sure you want to change global debuff intensity?")) return
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
		DEMON_NAME = "Shatterspawn"
		DEMON_ERODE_DEBUFF_INTENSITY = 0.005
		DEMON_DOT_DEBUFF_INTENSITY = 6
		DEMON_RESOURCE_DEBUFF_INTENSITY = 0.2
		MADNESS_DRAIN = 5
		MADNESS_DRAIN_FORM = 2
		SSJ_BASE_CUT_OFF = 10
		SSJ_BASE_DRAIN = 0.1
		SSJ_CUT_OFF_PER_MAST = 0.25
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
		FULL_MANIFESTATION_TAX=0.5
		FULL_MANIFESTATION_TAX_DIVISOR=100
		HALFIE_SSJ_BASE_DRAIN = 0.5
		UNDERDOG_MULT = 0.125

progressTracker

	proc/incrementTotal()
	//	totalRPPToDate += RPPDaily
		totalRPPToDate = RPPStarting + (RPPDaily*DaysOfWipe)
		totalPotentialToDate += PotentialDaily
		if(totalPotentialToDate > 150)
			totalPotentialToDate = 150
		if(totalRPPToDate > RPPLimit)
			totalRPPToDate = RPPLimit

	var
//TODO add a proc that increases total rpp/pot daily, ensuring nothing goes over the rpp limit

		Era = 1
		FourthFateEndwipe

//economy
		EconomyIncome = 3000
		EconomyCost = 3000
		EconomyMana = 100
		EconomyMult = 1
		DailyGrindCap = 15000
		maxAscension = 6
		MoneyName = "Dollars"


//potential
		PotentialDaily = 1
		totalPotentialToDate = 1
		MinPotential = 1


// rpp
		totalRPPToDate = 0 // a dynamic variable, that just gets added to every day tick
		RPPDaily = 10
		RPPLimit = 1000
		RPPStarting = 200
		RPPStartingDays = 0
		RPPBaseMult = 1
		MinRPP = 0

		STAT_PER_POINT = 0.25
		INVESTED_STAT_PER_POINT = 0.1
// time
		WipeStart = 0
		DaysOfWipe = 1

		SAGA_T2_POT = 15
		SAGA_T3_POT = 25
		SAGA_T4_POT = 45
		SAGA_T5_POT = 60
		SAGA_T6_POT = 75

		//unfortunately these must be set through a very dumb proc in _world.dm
		T1_STYLES = list(10, 20, 25, 35)
		T2_STYLES = list(25, 35, 45, 55)
		T3_STYLES = list(50)
		T4_STYLES = list(70)
		T1_SIGS = list(10, 20, 30)
		T2_SIGS = list(25, 45)
		T3_SIGS = list(50)

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
	proc
		outputVariableInfo(v)
			if(!(v in vars))
				admins << "Xoxo Error: parameter [v] was requested by outputVariableInfo (glob.dm). This is not a globally tracked variable.";
				return;
			return "<u>([vars[v]])</u>"
		resetSignaturePotentials()//this is the very dumb proc.
			glob.progress.T1_STYLES = list(10, 20, 25, 35)
			glob.progress.T2_STYLES = list(25, 35, 45, 55)
			glob.progress.T3_STYLES = list(50)
			glob.progress.T4_STYLES = list(70)
			glob.progress.T1_SIGS = list(10, 20, 30)
			glob.progress.T2_SIGS = list(25, 45)
			glob.progress.T3_SIGS = list(50)
			liveDebugMsg("we had to do it to em")
	var

		progressTracker/progress = new()
		racials/racials = new()
// TESTER
		TESTER_MODE = FALSE
		LIVE_TESTING = FALSE
		TESTER_WHITE_LIST = list("Digi-Daisuke","RevealingFortune","Zamas2","Niezan", "Etro", "AMajin", "Redsarge", "Gogeto25",\
 "Tilthour", "Sakata Gintoki San", "Hellbante", "FoxMagnus")
// TARGETING
		ROOTS_DURATION = 2
		AVALON_COOLDOWN = 300

//INTIM
		INTIMRATIO = 500
		SHONENCOUNTERLIMIT = 1
//Wipe Specific
		list/VOID_LOCATION = list(144,140,15)
		list/currentlyVoidingLoc = list(150,150,1)
		VoidsAllowed = 1
		VoidChance = 78
		VoidCut = 10
		VOID_MESSAGE = ""
		VOID_TIME = 15 MINUTES


		list/Spawns = list()


		list/DEATH_LOCATION = list(233, 238, 2)
		list/REGEN_LOCATION = list()
		list/NO_SOUL_LOCATION = list(182, 288, 2)
		HALF_DEMON_POTENTIAL_REQ = 50

		DISABLE_ALL_TELEPORTS = FALSE

		MOB_POTENTIAL_MODIFIER = 99

// - races
		list/LockedRaces = list()
		list/CustomCommons = list("Majin","Half-Saiyan", "Android")
		RAGE_DIVISOR = 200
		MAX_RAGEPUREDAMAGE = 5
		UNDERDOG_DIVISOR = 4
		CONQ_HAKI_RACES = list(HUMAN, DEMON, SAIYAN, NAMEKIAN, MAJIN, MAKYO, WILDER, CHANGELING)
		EXTRA_CONQ_HAKI_POWER = 1.5
		CONQ_HAKI_CHANCE = 3
		REBELHEARTMOD=200
		MYTHICALPUREREDMULT = 3
		SATSUICHANCE = 10
// nobody stuff
		ASHEN_BURN_POWER_DIVISOR = 10
		ASHEN_TENSION_DIVISOR = 10
		LONGING_DIVISOR = 1
		LONGING_MAX_CLAMP = 3
// globals
		WorldBaseAmount = 1
		WorldDamageMult = 1.5
		WorldDefaultAcc = 50
		WorldWhiffRate = 25
		NoSagaRaces = list(ELDRITCH, NOBODY, DEMON, WILDER, SAIYAN, ANGEL, MAKAIOSHIN)
		WILL_NOT_TARP_LIST = list("JustLat", "TheUltimateHope")
		T3_STYLES_GODKI_VALUE = 0.15//Would recommend moving this to 0.25
		T3_SAGA_STLYE_GODKI = 0//TODO BETWEEN WIPES: Style. =_=
		T4_STYLES_GODKI_VALUE = 0.15//Would recommend this also be 0.25 for a cumulative 0.5
		T4_SAGA_STLYE_GODKI = 0//TODO BETWEEN WIPES: Style. =_=
		SENSE7GODKI=0.25
		SENSE8GODKI=0.25
		SENSE9GODKI=0.25
		DOUBLESTRIKECHANCE = 25
		TRIPLESTRIKECHANCE = 35
		ASURASTRIKECHANCE = 50
		CUSTOMBUFFMULTTOTAL = 3
		CUSTOMBUFFADDTOTAL = 3
		CUSTOMBUFFPASSIVETOTAL = 2
		TRIPLEHELIX_MAX_NEG_HP = -50
		GODKI_DIFF_MULT = 1 //For figuring out less swingy values for GodKi DMG/RES. 1 is what we're used to, so try 0.5 or something. Doesn't affect accuracy.
// combat
		HIT_SCAN_DELAY = 5
		OVERHWELMING_BASE_END_NERF = 0.05
		OVERHWELMING_SHATTER_APPLY = 150
		OVERHWELMING_BASE_PR_NERF = 0.05
		OVERHWELMING_BASE_FLOW = 0.15
		BEAST_OVERHWELMING_STATIC = 20
		RUPTURE_BASE_DAMAGE = 2
		SUNYATA_BASE_CHANCE = 5
		INTERCEPTION_BASE_CHANCE = 10


		HALF_SWORD_ARMOR_REDUCTION = 1
		HALF_SWORD_UNARMOURED_DIVISOR = 10
		IAI_CHANCE_CAP = 80
		IAI_CHANCE_CURVE = 2
		IAI_DR_MULT = 0.5
		PARRY_CHANCE_CAP = 80
		PARRY_CHANCE_CURVE = 2
		PARRY_BASE_DMG = 0.3
		MAX_CHAIN_PARRY = 5
		PERSISTENCE_CHANCE_SELF = 6
		PERSISTENCE_CHANCE = 3
		PRESISTENCE_DIVISOR_MIN = 1
		PRESISTENCE_DIVISOR_MAX = 8

		MAX_PERSISTENCE_CALCULATED = 8

		TENACITY_GETUP_CHANCE = 2.5
		TENACITY_VAI_MULT = 2.5
		TENACITY_VAI_MIN = 2
		TENACITY_VAI_MAX = 14

		ANGER_RUSH_CAP = 50
		ANGER_RUSH_ALLY_DOWN = 15
		ANGER_RUSH_DEFIANCE = 3
		ANGER_RUSH_MANA = 0.5
		ANGER_RUSH_FINISHER = 10
		ANGER_RUSH_CC = 6
		ANGER_RUSH_GRAB_BREAK = 4
		ANGER_CC_WINDOW = 150
		ANGER_ENDLESS_RATE = 0.02

		ELEMENTAL_DIVIDER = 1

		DESPERATION_ATK_RATE = 1.5 //trueMult per (UnderDog+Det) point at full Injury, x the flavor ratio
		DESPERATION_DEF_RATE = 0.75
		DESPERATION_CAP = 5 //the whole system tops out at +-50% damage swing

		GOD_KI_CAP = 1.5


		MAX_CRIPPLE_MULT = 2
		CRIPPLE_DIVISOR = 100
		RUPTURED_MOVE_DMG = 0.05

		MECH_LEVEL_MULT = 0.15
		PILOT_MULT = 0.09
		POSE_TIME_NEEDED = 2

		DEMONIC_DURA_BASE = 0.10
		STYLE_MASTERY_DIVISOR = 10
		BASE_STACK_REDUCTION = 0.25
		REGEN_ASC_ONE_HEAL = 3
		HEALTH_POTION_NERF = 4 // HAHA YOU FOOLS, THIS WON'T DO ANYTHING TO MY FLASKS!
		BUFF_MASTER_HIGHTHRESHOLD = 1.2
		BUFF_MASTERY_LOWTHRESHOLD = 0.95
		BUFF_MASTERY_LOWMULT = 0.1
		BUFF_MASTERY_HIGHMULT = 0.05
		RUSTING_RATE = 0.25
		celestialObjectTicks = 43200
		FAMILIAR_SKILL_CD = 500
		FAMILIAR_CD_REDUCTION = 30
		FATIGUEDIVIDE = 10

		Q_DIVISOR = 10
		FINISHERDMG = 0.005
		OPENERDMG = 0.005
		DECIDERDMG = 0.2
		SPEEDSTRIKEDIVISOR = 20
		SWEEPSTRIKEDIVISOR = 20
		LIGHT_ATTACK_SPEED_DMG_EXPONENT = 0.4
		LIGHT_ATTACK_SPEED_STAT_BASE = 10
		LIGHT_ATTACK_SPEED_REF = 20
		LIGHT_ATTACK_SPEED_DMG_LOWER = 0.75
		LIGHT_ATTACK_SPEED_DMG_UPPER = 1.5

		ZANZO_SPEED_EXPONENT = 0.25
		ZANZO_SPEED_HIGHEST_CLAMP = 2
		ZANZO_SPEED_LOWEST_CLAMP = 0.25




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
		OFF_DEBUFF_RATE = 0.015 //precision pays: attacker Off scales applied debuff stacks
		OFF_DEBUFF_PROC_RATE = 0.3 //and nudges elemental proc rolls
		DEF_DEBUFF_RESIST_RATE = 0.01 //Def is the baseline status res - lags Off on purpose, typed resists stack on top
		DEF_DEBUFF_PROC_RESIST_RATE = 0.2
		STR_PHYS_RESIST_RATE = 0.009 //muscle shrugs off Cripple/Shear/Bleed/Shatter
		FOR_MENTAL_RESIST_RATE = 0.009 //will shrugs off Confuse/Charm/Doom/Frenzy
		STR_KB_RATE = 0.0073 //muscle sends harder
		VIT_KB_RATE = 0.0067 //mass stays planted
		VIT_INJURY_SOFTEN = 0.02 //a sturdy body shrugs off what injuries do to it afterwards
		FOR_BLAST_DENSITY = 0.37 //dense blasts resist deflection (shooter For -> deflect contest)
		VENOMBLINDMULT = 10
		CHAOS_CHANCE = 25
		BASE_DEBUFF_REDUCTION_DIVISOR = 100
		BASE_DEBUFF_REDUCTION_DIVISOR_LOWER = 0.05
		BASE_DEBUFF_REDUCTION_DIVISOR_UPPER = 1
		IMPLODE_DIVISOR = 1000
		IMPLODE_CD = 150

		STASIS_LENGTH_MODIFIER = 0.25

		KAIOKEN_BASE_TAX = 0.5
		KAIOKEN_TAX_DIVISOR = 1000
		KAIOKEN_EXPONENT = 2

		RUSH_DELAY_MIN = 0.5 // The minimum rush delay, half of a decisecond.
		RUSH_DELAY_DIVISOR = 2 // The Default Divisor for rushes.
//EXTRAS?? //
		MORTAL_BLOW_CHANCE = 8
		MULTIHIT_NERF = FALSE
		GetUpVar = 1 // how fast u get up ?
		MAGIC_BASE_COST = 100
		TECH_BASE_COST = 30
		WorldPUDrain = 1
// global mults
		WHILEWARPINGNERF = 10
		GATES_PUSPIKE_BASE = 6
		GATES_STAT_MULT_DIVISOR = 25
		SECRET_KNIFE_CHANCE = 100

		ATTACK_DELAY_STAT_BASE = 10
		ATTACK_DELAY_EXPONENT = 0.7
		ATTACK_DELAY_DIVISOR = 40.7
		ATTACK_DELAY_MAX = 20
		ATTACK_DELAY_MIN = 1.5
		SPEED_FORCE_TRUEMULT = 2
		SPEED_FORCE_DELAYMULT = 4
		CYBERIZESAGAS = list("King of Braves")
		ENERGY_GEN_DIVISOR = 10
		LIFE_GEN_DIVISOR = 10
		MANA_GEN_DIVISOR = 10
		DevilSummonerDemonDamageMod = 1
		DevilSummonerDemonSkillMod = 1
		DevilSummonerDemonDamageTakenMod = 1
		DEMON_SUMMONER_GRANT_FACTOR = 0.5
		WOUND_RECOVERY_REDUCTION = 0.5

		OXYGEN_DRAIN = 3
		OXYGEN_DRAIN_DIVISOR = 2

		CAN_BE_SLOWED_GODSPEED = 6
		FA_JIN_BASE_DMG_ADD = 1.75
		FA_JIN_BASE_KB_ADD = 3
		FA_JIN_BASE_COOLDOWN = 250
		FA_JIN_COOLDOWN_REDUCTION = 25
		BASE_WUJUDAMAGE = 0.015
		GLOBAL_BEAM_DAMAGE_DIVISOR = 1
		BEAM_TIME_MULT = 3
		GLOBAL_QUEUE_DAMAGE = 0.8
		CHAOS_DAMAGE_DIVISOR = 10
		GIANT_FORM_DMG_MULT = 0.7778	//what the old GiantForm roll clamp worked out to
		GLOBAL_MELEE_MULT = 0.54	//0.9 with the old 0.6 roll baked in
		GLOBAL_POWER_MULT = 1
		GLOBAL_ITEM_DAMAGE_MULT = 1
		PROJ_DAMAGE_MULT = 0.8
		MMO_PROJ_DAMAGE_MULT = 1 // Specifically for attacks that use a telegraphed marker.
		AUTOHIT_GLOBAL_DAMAGE = 0.48	//0.8 with the old 0.6 roll baked in
		SOFT_STYLE_RATIO = 0.2
		SOFT_STYLE_DMG_BOON_DIVISOR = 2
		HARD_STYLE_DMG_BOON_DIVISOR = 3
		SOUL_FIRE_MANA_RATIO = 0.4
		SOUL_FIRE_FATIGUE_RATIO = 0.1
		CHEAP_SHOT_DIVISOR = 40
		HARD_STYLE_RATIO = 0.1
		CURSED_WOUNDS_RATE = 0.25
		GLOBAL_EXPONENT_MULT = 1/3
		GRAPPLE_MELEE_BOON = 1.25
		GRIPPY_MOD = 0.25
		CLAMP_POWER = TRUE
		MIN_POWER_DIFF = 0.1
		MAX_POWER_DIFF = 5
		AUTOHIT_GRAB_NERF = 0.5
		PARTY_DAMAGE_NERF = 0.8
		MANA_STATS_BASE_BOON = 0.15
		MANA_STATS_EFF_MULT = 2
		MANA_STATS_MAX_BOON = 2
		NIMBUSRANGE = 10
		NIMBUSCD = 150
		SUPERCHARGECD = 500
		SERRATEDCD = 300
		SERRATEDCHANCE = 2.5
		SERRATED_DAMAGE = 0.25
		POTIONHEAL=2
		POTIONCOST=5000
		SUPERCHARGERATE = 0.1
		ATOMIZERRATE = 0.1
		GLADIATOR_DISARM_MAX = 30
		DISARM_TIMER = 5
		NEO_DODGERATE = 10
		BOUNCE_REDUCTION = 0.25
		LOWEST_ACC = 25
		MACROCHECKTIME = 3
		GCD_TIME = 20
		STYLE_EFFECT_CD = 400
		BLINDINGVENOM_CD = 400
		LINGERCHANCE = 5
		GRAPPLE_WHIFF_DAMAGE = 3
// effectiveness (dmg calc  shit)
		GRAPPLE_DAMAGE_MULT = 0.48	//0.8 with the old 0.6 roll baked in
		MUSCLE_POWER_DIVISOR = 4
		MAX_PURSUER_BOON = 10
		DMG_POWER_EXPONENT = 0.3
		DMG_ACC_EXPONENT = 0.4
		TENSION_MULTIPLIER = 1
		UNDERDOG_HUMAN_TENSION_MULT = 1.2
		DEFENDER_TENSION_REDUCER = 0.65
		MIN_TENSION = 10
		CORRUPTION_GAIN = 1.25
		HELLSTORM_SNARERATE = 3
		HELLSTORM_SNAREDURATION = 3
		FIELD_MODIFIERS = 0.01
		GLUTTONY_MODIFIER = 0.14
		UNARMED_DAMAGE_DIVISOR = 10
		SKIMMING_DAMAGE_MULT=0.15
		ROYAL_GUARD_CHARGE_MULT=1.0
		ROYAL_GUARD_DMG_MULT=1.0

		CASTING_PASSIVE_DIVISOR = 4

		TILE_DURATION_DIVISOR=2

		HARDER_THEY_FALL_BIO_DIVISOR = 100 // if u use this when changie first start it will do big damage
		HARDER_THEY_FALL_VAI_DIVISOR = 25 // more often no1 has this much vai, in hindsight deus ex machima will give kob more tha nthis, but they will suffer 2x damage ig


		PRIMORDIAL_EFFECTIVENESS = 1

		SANCTIFY_EFFECTIVENESS = 1
// dmg rolls

//SPEED COOLDOWN SHIT


// CC related
		CCDamageModifier = 0.1
		STUN_IMMUNE_TIMER = 250
		MAX_STUN_ADDITION = 100
		MAX_STUN_TIME = 600
		LAUNCH_LOCKOUT = 200
		MAX_LAUNCH_TIME = 25
// acc
		SWORD_GLOBAL_ACCURACY_NERF = 0.1
		STAFF_GLOBAL_ACCURACY_NERF = 0.1
		ARMOR_GLOBAL_ACCURACY_NERF = 0.2
		MAX_SWORD_ASCENSION = 6

		AUTOHIT_WHIFF_DAMAGE = 2
		AUTOHIT_MISS_DAMAGE = 5
		// Fraction of fully scaled AutoHit FinalDmg dealt to the attacker on auto-reversal
		AUTOHIT_REVERSAL_DAMAGE_FRAC = 0.28


		AUTOHIT_WAVE_OFFSHOOT_DAMAGE_DIVISOR = 1

		//Whiff dmg is now rand between these.
		MIN_WHIFF_DMG = 1.25
		MAX_WHIFF_DMG = 1.5



// TIMING_WINDOW is the one true timing number - touch it and everything moves together
		TIMING_WINDOW = 5
// fixed damage roll
// cc proration - replaces the 0.1x rule when on
		PRORATION_FLOOR = 0.3
		PRORATION_DECAY = 0.15
		PRORATION_CM_FLOOR_BONUS = 0.1
		PRORATION_CM_DECAY_CUT = 0.03
		PRORATION_LIGHT_FLOOR_BONUS = 0.2
		PRORATION_DUNK_FLOOR = 0.6
// counter-hit
		COUNTER_HIT_TENSION = 5
		COUNTER_HIT_STOP_BONUS = 2
		COUNTER_HIT_STOP_CAP = 5
// life skills
		//temporarily off
		LIFE_NODE_SPAWNS = 0
// wall splat
		SPLAT_STAGGER_DS = 10
		SPLAT_MIN_REMAINING = 3
		SPLAT_DMG_PER_TILE = 0.5
// perfect break
		PERFECT_BREAK_REFUND = 1
// launch visuals
		LAUNCH_LIFT_PX = 28
// grab tech / toss aim / ais
// guard
		GUARD_DR = 0.65
		GUARD_METER_MAX = 100
		GUARD_METER_FLAT = 6
		GUARD_METER_SCALE = 2
		GUARD_METER_DECAY = 4
		GUARD_BREAK_DS = 50
		GUARD_BREAK_DMG_AMP = 1.3
		GUARD_PUSHBACK_PX = 7
		ALPHA_COUNTER_TENSION = 30
		ALPHA_COUNTER_RANGE = 2
		ALPHA_COUNTER_KB = 5
		ALPHA_COUNTER_CD_DS = 50
// queue layer
		QUEUE_COUNTER_CM_BONUS = 1
		QUEUE_COUNTER_MAX = 10
		FLOURISH_WINDOW_DS = 20
		FLOURISH_TENSION = 10
// active energy charge kills idle regen when on
		CHARGE_BASE = 0.5
		CHARGE_RAMP_MAX = 2
		CHARGE_RAMP_DS = 35
		CHARGE_BREAK_HITS = 3

		PERCEPTION_CORRECTION_RATE = 0.1
		DESPERATION_HIT_CHANCE = 0.005
		DESPERATION_MAX_HIT_CHANCE = 0.05

		DEBUG_MESSAGES_ACCURACY = FALSE

		//to-hit contest. base 50, every rating point of (atk - def) moves it by ACC_POINT
		ACC_OFF = 0.8
		ACC_DEF = 0.8
		ACC_OFF_SPD = 0.3
		ACC_DEF_SPD = 0.3
		TRUEMULT_POINT_VALUE = 0.1 //one trueMult point = this much damage swing
		ACC_POINT = 2
		WHIFF_BAND = 25 //glancing zone above the hit roll
		POWER_ACC_POINT = 5 //acc per point of clamped power-advantage gap
		PERCEPTION_CORRECTION_LEVELS = 2 //Clarity/Intuition each count as this many perception levels
		SHONEN_RAMP_START = 30 //SP Power wakes up below this Health
		SHONEN_RAMP_FLOOR = 5 //and peaks here
		SHONEN_POWER_SCALE = 1.25 //trueMult points per ShonenPower at the peak
		WOUND_RATE = 0.25 //share of a hit that lands as wounds, before the End curve
		SWORD_WOUND_SCALE = 0.5 //sword damage feeds the wound share
		STAGGER_HIT_CAP = 5 //per-hit stagger contribution ceiling
		EROSION_RATE_DIVISOR = 45
		STAT_STEAL_RATE = 0.025
		LEAK_ATTACKER_RATE = 0.21
		LEAK_DEFENDER_RATE = 0.05
		RECOIL_RATE = 0.125 //BleedHit/BurnHit self-recoil
		WorldDeflectBase = 75 //deflection contest base - deliberately above WorldDefaultAcc
		DEF_DEFLECT_RATE = 0.004 //Def digs into the deflection pre-empt
		FOR_BLAST_DENSITY_MIT = 0.0037 //shooter For shaves it back

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


		HOLY_DAMAGE_DIVISOR = 10
		ABYSS_DAMAGE_DIVISOR = 10
		SLAYER_DAMAGE_DIVISOR = 2
		ENRAGED_DAMAGE_DIVISOR = 2
		SLAYER_DAMAGE_CLAMP = 10
		SPIRIT_FORM_BASE_RATE = 0.15
		SPIRIT_FORM_LEAK_VAL = 3

		DEFLECTION_DAMAGE_MULT = 0.075
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


		WeaponSoulNames = WSNAMES
		prayerTargetNames = GODS

		BronzeConstellationNames = BRONZECLOTHS
		GoldConstellationNames = GOLDCLOTHS
		list/Keychains=list("Kingdom Key", "Kingdom Key D", "Flame Liberator", "Wayward Wind", "Rainfell", "Oathkeeper", "Way To Dawn", "Bond of Flame", "Sweetstack", "Two Become One",\
		"Oblivion", "Fenrir", "No Name", "Lionheart", "Spellbinder", "Star Seeker", "Lost Memory",\
		"Earthshaker", "Chaos Ripper", "One Winged Angel", "Moogle O Glory", "Fairytale Endings")
		list/FinalKeychains=list("Ultima Weapon", "X-Blade", "Ebony Slumber", "Prismatic Dreams")

		STAT_DMG_EXPONENT = 0.75
		SOULTUGMULT = 5

		STACK_ANIMATE_TIME = 4
		list/trueNames = list()

		discordICAnnounceWebhookURL
		discordOOCAnnounceWebhookURL
		discordAdminHelpWebhookURL
// FUNCTIONS

