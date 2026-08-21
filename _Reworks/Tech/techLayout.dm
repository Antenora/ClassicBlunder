#ifndef TT_SHAPE_ROUND
#define TT_SHAPE_ROUND   "round"     // SkillSlotRound 
#define TT_SHAPE_DIAMOND "diamond"   // SkillSlotSharp  (breakthrough milestone)
#define TT_SHAPE_LARGE   "large"     // SkillSlotSharp scaled up (start / capstone)
#define TT_FAM_FORGE     "forge"     
#define TT_FAM_CYBER     "cyber"
#define TT_FAM_MED       "medicine"
#define TT_FAM_TELE      "telecom"
#define TT_FAM_MIL       "military"
#define TT_FAM_MISC      "misc"
#endif

var/list/TT_CAPSTONES = list("Vehicular Power Armor", "Singularity", "War Crimes")

var/list/TechTreeLayout = list(
	// forge family lives in the Smithing life skill now
	"Engineering"                    = list(0, 4, TT_FAM_CYBER),
	"Force Shielding"                = list(1, 2, TT_FAM_CYBER),
	"Power Generators"               = list(1, 4, TT_FAM_CYBER),
	"Hazard Suits"                   = list(1, 6, TT_FAM_CYBER),
	"Jet Propulsion"                 = list(2, 4, TT_FAM_CYBER),
	"CyberEngineering"               = list(3, 4, TT_FAM_CYBER),
	"Cyber Augmentations"            = list(4, 3, TT_FAM_CYBER),
	"Neuron Manipulation"            = list(4, 5, TT_FAM_CYBER),
	"War Crimes"                     = list(5, 3, TT_FAM_CYBER),
	"Singularity"                    = list(5, 5, TT_FAM_CYBER),

	"Medicine"                       = list(0, 10, TT_FAM_MED),
	"Medkits"                        = list(1, 9,  TT_FAM_MED),
	"Fast Acting Medicine"           = list(1, 11, TT_FAM_MED),
	"Anesthetics"                    = list(2, 9,  TT_FAM_MED),
	"Automated Dispensers"           = list(2, 11, TT_FAM_MED),
	"Enhancers"                      = list(3, 10, TT_FAM_MED),
	"ImprovedMedicalTechnology"      = list(3, 12, TT_FAM_MED),
	"Regenerative Medicine"          = list(4, 12, TT_FAM_MED),
	"Regenerator Tanks"              = list(5, 11, TT_FAM_MED),
	"Genetic Manipulation"           = list(5, 13, TT_FAM_MED),
	"Revival Protocol"               = list(6, 12, TT_FAM_MED),
	"Prosthetic Limbs"               = list(6, 14, TT_FAM_MED),

	"Telecommunications"             = list(0, 18, TT_FAM_TELE),
	"Local Range Devices"            = list(1, 17, TT_FAM_TELE),
	"Surveilance"                    = list(1, 19, TT_FAM_TELE),
	"Wide Area Transmission"         = list(2, 17, TT_FAM_TELE),
	"Espionage Equipment"            = list(2, 20, TT_FAM_TELE),
	"Drones"                         = list(3, 18, TT_FAM_TELE),
	"AdvancedTransmissionTechnology" = list(3, 19, TT_FAM_TELE),
	"Scouters"                       = list(4, 19, TT_FAM_TELE),
	"Combat Scanning"                = list(6, 19, TT_FAM_TELE),  // cross-links up to Neuron Manipulation

	"MilitaryTechnology"             = list(0, 26, TT_FAM_MIL),
	"Assault Weaponry"               = list(1, 26, TT_FAM_MIL),
	"Missile Weaponry"               = list(2, 24, TT_FAM_MIL),
	"Melee Weaponry"                 = list(2, 26, TT_FAM_MIL),
	"Thermal Weaponry"               = list(3, 26, TT_FAM_MIL),
	"Blast Shielding"                = list(4, 24, TT_FAM_MIL),
	"MilitaryEngineering"            = list(4, 27, TT_FAM_MIL),
	"Armorpiercing Weaponry"         = list(5, 27, TT_FAM_MIL),
	"Impact Weaponry"                = list(6, 27, TT_FAM_MIL),
	"Hydraulic Weaponry"             = list(7, 27, TT_FAM_MIL),
	"Vehicular Power Armor"          = list(9, 25, TT_FAM_MIL),   // capstone: pulls Military+Telecom+Medicine

	"Culinary Basics"                = list(0, 32, TT_FAM_MISC),
	"Piloting Foundations"           = list(0, 33, TT_FAM_MISC)
)


/proc/TechNodeCol(name)
	var/list/e = TechTreeLayout[name]
	return e ? e[1] : null

/proc/TechNodeRow(name)
	var/list/e = TechTreeLayout[name]
	return e ? e[2] : null

/proc/TechNodeFamily(name)
	var/list/e = TechTreeLayout[name]
	return e ? e[3] : TT_FAM_MISC

/proc/TechNodeShape(knowledgePaths/tech/t)
	if(!t) return TT_SHAPE_ROUND
	if(t.name in TT_CAPSTONES) return TT_SHAPE_LARGE
	if(length(t.requires) == 0) return TT_SHAPE_LARGE
	if(t.breakthrough) return TT_SHAPE_DIAMOND
	return TT_SHAPE_ROUND
