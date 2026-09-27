#ifndef TT_SHAPE_ROUND
#define TT_SHAPE_ROUND   "round"     // SkillSlotRound 
#define TT_SHAPE_DIAMOND "diamond"   // SkillSlotSharp  (breakthrough milestone)
#define TT_SHAPE_LARGE   "large"     // SkillSlotSharp scaled up (start / capstone)
#define TT_FAM_ENGINEER  "engineer"
#define TT_FAM_OPERATIVE "operative"
#define TT_FAM_GUNSMITH  "gunsmith"
#define TT_FAM_MECHANIST "mechanist"
#define TT_FAM_CYBER     "cyber"
#define TT_FAM_MEDIC     "medic"
#endif

#define TECH_PRICE_HUB 2
#define TECH_PRICE_T1  3
#define TECH_PRICE_T2  5
#define TECH_PRICE_T3  6
#define TECH_PRICE_T4  8
#define TECH_PRICE_T5  10

var/list/TT_CAPSTONES = list("Teleportation", "Technique Analysis", "Energy Weaponry", "Heavy Ordnance", 	"Vehicular Power Armor", "Singularity", "Core Transplant", "Genetic Manipulation", "Revival Protocol")

var/list/TechBenchFamily = list(
	"Engineer"      = TT_FAM_ENGINEER,
	"Operative"     = TT_FAM_OPERATIVE,
	"Gunsmith"      = TT_FAM_GUNSMITH,
	"Mechanist"     = TT_FAM_MECHANIST,
	"Cyberneticist" = TT_FAM_CYBER,
	"Medic"         = TT_FAM_MEDIC)

var/list/TechTreeLayout = list(
	"Engineering"                 = list(0, 1,  TT_FAM_ENGINEER),
	"Fabrication"                 = list(1, 1,  TT_FAM_ENGINEER),
	"Power Generators"            = list(2, 1,  TT_FAM_ENGINEER),
	"Hazard Suits"                = list(3, 0,  TT_FAM_ENGINEER),
	"Field Gadgets"               = list(3, 2,  TT_FAM_ENGINEER),
	"Force Shielding"             = list(4, 0,  TT_FAM_ENGINEER),
	"Automated Defenses"          = list(4, 1,  TT_FAM_ENGINEER),
	"EM Wave Projectors"          = list(4, 2,  TT_FAM_ENGINEER),
	"Drones"                      = list(4, 3,  TT_FAM_ENGINEER),
	"Teleportation"               = list(5, 1,  TT_FAM_ENGINEER),

	"Telecommunications"          = list(0, 6,  TT_FAM_OPERATIVE),
	"Scouters"                    = list(2, 5,  TT_FAM_OPERATIVE),
	"Espionage Equipment"         = list(2, 7,  TT_FAM_OPERATIVE),
	"Wide Area Transmission"      = list(3, 5,  TT_FAM_OPERATIVE),
	"Intrusion Tools"             = list(3, 7,  TT_FAM_OPERATIVE),
	"Obfuscation Equipment"       = list(4, 5,  TT_FAM_OPERATIVE),
	"Combat Scanning"             = list(4, 7,  TT_FAM_OPERATIVE),
	"Technique Analysis"          = list(5, 6,  TT_FAM_OPERATIVE),

	"Military Technology"         = list(0, 10, TT_FAM_GUNSMITH),
	"Assault Weaponry"            = list(2, 9,  TT_FAM_GUNSMITH),
	"Demolitions"                 = list(2, 11, TT_FAM_GUNSMITH),
	"Munitions"                   = list(3, 9,  TT_FAM_GUNSMITH),
	"Weapon Modding"              = list(3, 11, TT_FAM_GUNSMITH),
	"Heavy Weaponry"              = list(4, 9,  TT_FAM_GUNSMITH),
	"Electronic Warfare"          = list(4, 11, TT_FAM_GUNSMITH),
	"Energy Weaponry"             = list(5, 9,  TT_FAM_GUNSMITH),
	"Heavy Ordnance"              = list(5, 11, TT_FAM_GUNSMITH),

	"Military Engineering"        = list(0, 14, TT_FAM_MECHANIST),
	"Piloting Foundations"        = list(1, 14, TT_FAM_MECHANIST),
	"Jet Propulsion"              = list(2, 14, TT_FAM_MECHANIST),
	"Melee Weaponry"              = list(3, 13, TT_FAM_MECHANIST),
	"Powered Exoskeletons"        = list(3, 14, TT_FAM_MECHANIST),
	"Weapon Modules"              = list(3, 15, TT_FAM_MECHANIST),
	"Powered Armor Specialization"= list(4, 13, TT_FAM_MECHANIST),
	"Mech Fabrication"            = list(4, 15, TT_FAM_MECHANIST),
	"Vehicular Power Armor"       = list(5, 14, TT_FAM_MECHANIST),

	"Cyber Engineering"           = list(0, 18, TT_FAM_CYBER),
	"Cyber Augmentations"         = list(1, 18, TT_FAM_CYBER),
	"Combat Routines"             = list(2, 18, TT_FAM_CYBER),
	"Neuron Manipulation"         = list(3, 18, TT_FAM_CYBER),
	"Cybernetic Mainframe"        = list(4, 17, TT_FAM_CYBER),
	"War Crimes"                  = list(4, 19, TT_FAM_CYBER),
	"Singularity"                 = list(5, 17, TT_FAM_CYBER),
	"Core Transplant"             = list(5, 19, TT_FAM_CYBER),

	"Medicine"                    = list(0, 22, TT_FAM_MEDIC),
	"Fast Acting Medicine"        = list(2, 21, TT_FAM_MEDIC),
	"Trauma Care"                 = list(2, 22, TT_FAM_MEDIC),
	"Medkits"                     = list(2, 23, TT_FAM_MEDIC),
	"Enhancers"                   = list(3, 21, TT_FAM_MEDIC),
	"Improved Medical Technology" = list(3, 23, TT_FAM_MEDIC),
	"Regenerative Medicine"       = list(4, 21, TT_FAM_MEDIC),
	"Regenerator Tanks"           = list(4, 23, TT_FAM_MEDIC),
	"Genetic Manipulation"        = list(5, 21, TT_FAM_MEDIC),
	"Revival Protocol"            = list(5, 23, TT_FAM_MEDIC)
)


/proc/TechNodeCol(name)
	var/list/e = TechTreeLayout[name]
	return e ? e[1] : null

/proc/TechNodeRow(name)
	var/list/e = TechTreeLayout[name]
	return e ? e[2] : null

/proc/TechNodeFamily(name)
	var/list/e = TechTreeLayout[name]
	return e ? e[3] : TT_FAM_ENGINEER

/proc/TechTierPrice(tier)
	switch(tier)
		if(0) return TECH_PRICE_HUB
		if(1) return TECH_PRICE_T1
		if(2) return TECH_PRICE_T2
		if(3) return TECH_PRICE_T3
		if(4) return TECH_PRICE_T4
		if(5) return TECH_PRICE_T5
	return TECH_PRICE_T5

/proc/TechTierRank(tier)
	return max(1, 2 * tier - 1)

/proc/TechNodeShape(knowledgePaths/tech/t)
	if(!t) return TT_SHAPE_ROUND
	if(t.name in TT_CAPSTONES) return TT_SHAPE_LARGE
	if(t.tier <= 0) return TT_SHAPE_LARGE
	return TT_SHAPE_ROUND
