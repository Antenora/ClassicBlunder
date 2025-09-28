/*
/knowledgePaths
    var/name = "Not Obtainable"
    var/breakthrough = FALSE
    var/list/requires = list("Not Obtainable")
*/

/*
alchemy -> magic herbs -> healing herbs -> toxic herb
                        philter herbs/refesment herbs

ToolEnchantment    -> spell focii  -> Magical Vehicles
                    -> artifact manufacturing -> Magical Communication (spell focus + artifact manufacturing) -> warding glyphs (Magical Communication) -> ArmamentEnchantment (warding glyphs) -> tome creation (articact manufactioning + ArmamentEnchantment)

ArmamentEnchantment -> tome creation (articact manufactioning + ArmamentEnchantment)


*/

#define MAX_ALCHEMY_LEVEL 12 // there is 12 total alchemy skills
#define MAX_ENCHANTMENT_LEVEL 10
#define MAX_CREATION_LEVEL 22 // includes legend
#define MAX_SUMMONING_LEVEL 5
#define MAX_SEALING_LEVEL 3
#define MAX_SPACE_LEVEL 6
#define MAX_TIME_LEVEL 6
#define MAX_MAGIC_LEVEL 20
/mob/proc/getTotalMagicLevel()
    var/total = 0.1
    total += SpaceMagicUnlocked
    total += TimeMagicUnlocked
    total += SealingMagicUnlocked
    total += SummoningMagicUnlocked
    if(passive_handler.Get("Crimson Grimoire"))
        total = 20
    if(total >= MAX_MAGIC_LEVEL)
        total = MAX_MAGIC_LEVEL
    TotalMagicLevel = total
    return total
	





/knowledgePaths/magic

/knowledgePaths/magic/Alchemy
    name = "Alchemy"
    breakthrough = TRUE
    requires = list()

/knowledgePaths/magic/Refreshment_Herbs
    name = "Refreshment Herbs"
    requires = list("Alchemy")
/knowledgePaths/magic/Healing_Herbs
    name = "Healing Herbs"
    requires = list("Refreshment Herbs", "Magic Herbs")
/knowledgePaths/magic/Magic_Herbs
    name = "Magic Herbs"
    requires = list("Alchemy")
/knowledgePaths/magic/Toxic_Herbs
    name = "Toxic Herbs"
    requires = list("Refreshment Herbs")
/knowledgePaths/magic/Philter_Herbs
    name = "Philter Herbs"
    requires = list("Magic Herbs")
/knowledgePaths/magic/ImprovedAlchemy
    name = "ImprovedAlchemy"
    breakthrough = TRUE
    requires = list("Healing Herbs")
/knowledgePaths/magic/Stimulant_Herbs
    name = "Stimulant Herbs"
    requires = list("Mutagenic Herbs")
/knowledgePaths/magic/Relaxant_Herbs
    name = "Relaxant Herbs"
    requires = list("Numbing Herbs")
/knowledgePaths/magic/Numbing_Herbs
    name = "Numbing Herbs"
    requires = list("Toxic Herbs", "ImprovedAlchemy")
/knowledgePaths/magic/Distillation_Process
    name = "Distillation Process"
    requires = list("Stimulant Herbs", "Relaxant Herbs")
/knowledgePaths/magic/Mutagenic_Herbs
    name = "Mutagenic Herbs"
    requires = list("Numbing Herbs")

// END ALCHEMY TREE //


/knowledgePaths/magic/ToolEnchantment
    name = "ToolEnchantment"
    breakthrough = TRUE
    requires = list()

/knowledgePaths/magic/Spell_Focii
    name = "Spell Focii"
    requires = list("ToolEnchantment")
/knowledgePaths/magic/Magical_Communication // TODO: change arcane orb/mask to magical communication
    name = "Magical Communication"
    requires = list("Spell Focii")

/knowledgePaths/magic/Magical_Vehicles
    name = "Magical Vehicles"
    requires = list("Spell Focii")

/knowledgePaths/magic/Warding_Glyphs
    name = "Warding Glyphs"
    requires = list("Magical Communication")

/knowledgePaths/magic/ArmamentEnchantment
    name = "ArmamentEnchantment"
    breakthrough = TRUE
    requires = list("ToolEnchantment")
/knowledgePaths/magic/Coating_Enchantment
    name = "Coating Enchantment"
    requires = list("ArmamentEnchantment")
/knowledgePaths/magic/Door_To_Darkness
    name = "Door to Darkness"
    requires = list("Coating Enchantment")

/knowledgePaths/magic/Magical_Forging
    name = "Magical Forging"
    requires = list("Door to Darkness")

/knowledgePaths/magic/Soul_Infusion
    name = "Soul Infusion"
    requires = list("Magical Forging")
/*
/knowledgePaths/magic/RitualMagic
    name = "RitualMagic"
    breakthrough = TRUE
    requires = list("ToolEnchantment")
/knowledgePaths/magic/Introductory_Ritual_Magics
    name = "Introductory Ritual Magics"
    requires = list("RitualMagic")
*/
/knowledgePaths/magic/TomeCreation
    name = "TomeCreation"
    breakthrough = TRUE
    requires = list("ArmamentEnchantment","Magical Communication")

/knowledgePaths/magic/Tome_Cleansing
    name = "Tome Cleansing"
    requires = list("Tome Expansion")
/knowledgePaths/magic/Tome_Security
    name = "Tome Security"
    requires = list("Tome Cleansing")

/knowledgePaths/magic/Tome_Translation
    name = "Tome Translation"
    requires = list("Tome Security", "Tome Excerpts")
/knowledgePaths/magic/Tome_Expansion
    name = "Tome Expansion"
    requires = list("TomeCreation")

/knowledgePaths/magic/Tome_Binding // last one, only for legendary tiered tomes
    name = "Tome Binding"
    requires = list("Tome Translation")
/knowledgePaths/magic/Tome_Excerpts
    name = "Tome Excerpts"
    requires = list("Tome Expansion")
/knowledgePaths/magic/CrestCreation
    name = "CrestCreation"
    breakthrough = TRUE
    requires = list("Tome Translation")
/knowledgePaths/magic/Crest_Expert
    name = "Crest Expert"
    requires = list("CrestCreation")
/knowledgePaths/magic/Crest_Master
    name = "Crest Master"
    requires = list("Crest Expert")
/knowledgePaths/magic/Crest_Grandmaster
    name = "Crest Grandmaster"
    requires = list("Crest Master")
/knowledgePaths/magic/Crest_Legend
    name = "Crest Legend"
    requires = list("Crest Grandmaster")
    // make this go up to 10 or something

/knowledgePaths/magic/SummonMagic
    name = "Summon Magic"
    requires = list()
    // make this go up to 5

/knowledgePaths/magic/SealingMagic
    name = "SealingMagic"
    breakthrough = TRUE
    requires = list()

/knowledgePaths/magic/Spell_Sealing // this has been removed
    // allow this to seal a spell in a tome, making it unable to cast it
    name = "Spell Sealing"
    requires = list("SealingMagic")
/knowledgePaths/magic/Object_Sealing
    name = "Object Sealing"
    requires = list("Spell Sealing")
/knowledgePaths/magic/SpaceMagic // add counterspell, bascially ais but for magic
    name = "SpaceMagic"
    breakthrough = TRUE
    requires = list("SealingMagic")
/knowledgePaths/magic/Counterspell
    name = "Counterspell"
    requires = list("SpaceMagic", "SealingMagic")

/knowledgePaths/magic/Holding_Magic
    name = "Holding Magic"
    requires = list("Counterspell")

/knowledgePaths/magic/Teleportation
    name = "Teleportation"
    requires = list("Holding Magic")

/knowledgePaths/magic/Retrieval
    name = "Retrieval"
    requires = list("Teleportation")
/knowledgePaths/magic/Bilocation
    name = "Bilocation"
    requires = list("Retrieval")

/knowledgePaths/magic/TimeMagic // time + teleport gives you haste
    name = "TimeMagic"
    breakthrough = TRUE
    requires = list("Teleportation")


/knowledgePaths/magic/Transmigration
    name = "Transmigration"
    requires = list("TimeMagic")
/knowledgePaths/magic/Life_Warranty
    // impart a +1 void roll
    name = "Life Warranty"
    requires = list("Transmigration")
/knowledgePaths/magic/Temporal_Displacement
    // increased chance to void
    name = "Temporal Displacement"
    requires = list("Life Warranty")

/knowledgePaths/magic/Temporal_Acceleration // haste
    name = "Temporal Acceleration"
    requires = list("TimeMagic", "Teleportation")

/knowledgePaths/magic/Temporal_Rewinding // A HEAL
    name = "Temporal Rewinding"
    requires = list("Temporal Acceleration")