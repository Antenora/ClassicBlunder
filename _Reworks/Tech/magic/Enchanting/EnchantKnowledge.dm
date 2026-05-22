/knowledgePaths/magic/enchanting


/knowledgePaths/magic/enchanting/ToolEnchantment
    name = "ToolEnchantment"
    breakthrough = TRUE
    requires = list()

/knowledgePaths/magic/enchanting/Spell_Focii
    name = "Spell Focii"
    requires = list("ToolEnchantment")
/knowledgePaths/magic/enchanting/Magical_Communication // TODO: change arcane orb/mask to magical communication
    name = "Magical Communication"
    requires = list("Spell Focii")

/knowledgePaths/magic/enchanting/Magical_Vehicles
    name = "Magical Vehicles"
    requires = list("Spell Focii")

/knowledgePaths/magic/enchanting/Warding_Glyphs
    name = "Warding Glyphs"
    requires = list("Magical Communication")

/knowledgePaths/magic/enchanting/ArmamentEnchantment
    name = "ArmamentEnchantment"
    breakthrough = TRUE
    requires = list("ToolEnchantment")
/knowledgePaths/magic/enchanting/Coating_Enchantment
    name = "Coating Enchantment"
    requires = list("ArmamentEnchantment")
/knowledgePaths/magic/enchanting/Door_To_Darkness
    name = "Door to Darkness"
    requires = list("Coating Enchantment")

/knowledgePaths/magic/enchanting/Magical_Forging
    name = "Magical Forging"
    requires = list("Door to Darkness")

/knowledgePaths/magic/enchanting/Soul_Infusion
    name = "Soul Infusion"
    requires = list("Magical Forging")
/*
/knowledgePaths/magic/enchanting/RitualMagic
    name = "RitualMagic"
    breakthrough = TRUE
    requires = list("ToolEnchantment")
/knowledgePaths/magic/enchanting/Introductory_Ritual_Magics
    name = "Introductory Ritual Magics"
    requires = list("RitualMagic")
*/
/knowledgePaths/magic/enchanting/TomeCreation
    name = "TomeCreation"
    breakthrough = TRUE
    requires = list("ArmamentEnchantment","Magical Communication")
/*
/knowledgePaths/magic/enchanting/Tome_Cleansing
    name = "Tome Cleansing"
    requires = list("Tome Expansion")
/knowledgePaths/magic/enchanting/Tome_Security
    name = "Tome Security"
    requires = list("Tome Cleansing")

/knowledgePaths/magic/enchanting/Tome_Translation
    name = "Tome Translation"
    requires = list("Tome Security", "Tome Excerpts")
/knowledgePaths/magic/enchanting/Tome_Expansion
    name = "Tome Expansion"
    requires = list("TomeCreation")

/knowledgePaths/magic/enchanting/Tome_Binding // last one, only for legendary tiered tomes
    name = "Tome Binding"
    requires = list("Tome Translation")
/knowledgePaths/magic/enchanting/Tome_Excerpts
    name = "Tome Excerpts"
    requires = list("Tome Expansion")
/knowledgePaths/magic/enchanting/CrestCreation
    name = "CrestCreation"
    breakthrough = TRUE
    requires = list("Tome Translation")
/knowledgePaths/magic/enchanting/Crest_Expert
    name = "Crest Expert"
    requires = list("CrestCreation")
/knowledgePaths/magic/enchanting/Crest_Master
    name = "Crest Master"
    requires = list("Crest Expert")
/knowledgePaths/magic/enchanting/Crest_Grandmaster
    name = "Crest Grandmaster"
    requires = list("Crest Master")
/knowledgePaths/magic/enchanting/Crest_Legend
    name = "Crest Legend"
    requires = list("Crest Grandmaster")
    description = "Buying this will allow you to put another spell into a crest. It can be purchased an infinite number of times."
    // make this go up to 10 or something
*/