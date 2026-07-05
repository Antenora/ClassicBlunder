// global demon database
var/global/list/DEMON_DB = list()
var/global/list/DEMON_FUSION_CHART = list()
var/global/list/DEMON_SPECIAL_FUSIONS = list()

// Demons accessible only via the True Demon path
var/global/list/DEMON_TRUE_DEMON_LOCKED = list("Beelzebub", "Lucifer")


// Potential divisor for stat scaling
#define DEMON_POTENTIAL_DIVISOR 100

/datum/demon_data
	var/demon_name       = ""
	var/demon_race       = ""
	var/demon_lvl        = 0
	var/demon_str        = 0
	var/demon_for        = 0
	var/demon_end        = 0
	var/demon_spd        = 0
	var/demon_off        = 0
	var/demon_def        = 0
	var/list/demon_skills = list()        // Active skills known at base (innate + level-1 learns)
	var/list/demon_passives = list()      // Passive skills known at base (innate)
	var/list/demon_skill_learn = list()   // "Skill Name" -> learn level (active skills learned later)
	var/list/demon_passive_learn = list() // "Passive Name" -> learn level (passives learned later)
	var/demon_unique     = FALSE // TRUE = not a normal fusion result target
	var/demon_icon       = 'Icons/base/default/frisky-male_black_brown.dmi'
	var/demon_icon_state = ""
	// Pixie's portraits are guaranteed to exist and are well-formed.
	var/demon_portrait   = 'Icons/DevilSummoner/DemonPortraits128/Pixie128.dmi'
	var/demon_portrait2  = 'Icons/DevilSummoner/DemonPortraits32/Pixie32.dmi'

/datum/party_demon
	var/demon_name        = ""
	var/party_level       = 0
	var/demon_potential   = 0
	var/current_hp        = 100
	var/list/demon_skills = list()        // Currently learned active skills (max 4)
	var/list/passives     = list()        // Currently learned passives (max 4)
	var/list/skill_cooldowns = list()
	var/list/pending_skills = list()      // Active skills queued for learning
	var/list/pending_passives = list()    // Passives queued for learning
	var/highest_scaled_lvl = 0            // Highest scaled level the demon has reached (for learn checks)

/datum/compendium_demon
	var/demon_name       = ""
	var/base_level       = 0   // DS2 base level (static)
	var/recorded_level   = 0   
	var/demon_potential  = 0   
	var/list/recorded_skills = list()
	var/list/recorded_passives = list()
	var/highest_scaled_lvl = 0

/world/New()
	..()
	InitDemonDatabase()
	InitFusionData()
	InitDemonSkillVFX()
	InitDemonPassives()
