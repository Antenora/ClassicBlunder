// Co-opting my own code for the flask system, epic I know
// Also magic level was disabled when I made this so if you want to integrate it and turn that on, don't ask me to do it
// DELETED TRANSFORMATION AND PHILTER POTS FROM THE TECH TREE. THEY ARE NOT USED IN FLASKS ANYWAY.

/knowledgePaths/magic/alchemy   

//FLASKS
/knowledgePaths/magic/alchemy/Basic_Alchemy //T0 Flask + Unlocks Herbs
    name = "Basic Alchemy"
    description = "Basic Alchemy is the essential knowledge behind the alchemical arts. The Thaumaturge is now capable of creating expensive flasks capable of storing powerful concotions."
    requires = list()
/knowledgePaths/magic/alchemy/Flask_Accumen //T1 Flask Upgrade
    name = "Flask Accumen"
    description = "Flask Accumen is the intermediate knowledge behind Flaskmaking. The Thaumaturge's flask can filter contanimants better, bettering the effects of the concoction and reducing the downsides."
    requires = list("Basic Alchemy")
/knowledgePaths/magic/alchemy/Flask_Mastery //T2 Flask Upgrade
    name = "Flask Mastery"
    description = "Flask Mastery is the zenith of knowledge behind Flaskmaking. The Thaumaturge's flask can filter MOST contaminants, their concoctions are the strongest you can find."
    requires = list("Flask Accumen")

//HERBS
/knowledgePaths/magic/alchemy/Refreshment_Herbs 
    name = "Refreshment Herbs"
    description = "Refreshmen Herbs are procured for their ability to revitalize the ENERGY of subjects. It will subtract MANA from the subject."
    requires = list("Basic Alchemy")
/*  (Currently not capable of balancing)
/knowledgePaths/magic/alchemy/Healing_Herbs  
    name = "Healing Herbs"
    description = "Healing herbs are procured for their ability to rejuvenate the HEALTH of subjects. It will will subtract ENERGY and MANA from the subject."
    requires = list("Basic Alchemy")
    */
/knowledgePaths/magic/alchemy/Magic_Herbs 
    name = "Magic Herbs"
    description = "Magic herbs are procured for their ability to restore the MANA of subjects. It will subtract ENERGY from the subject."
    requires = list("Basic Alchemy")
/*CURRENTLY DISABLED, Flasks.DM still has a var to accomodate toxin but they are also commented ut
/knowledgePaths/magic/alchemy/Toxic_Herbs //I like this mechanic but needs a balance lookover first.
    name = "Toxic Herbs"
    description = "Toxic herbs deal damage to yourself when used in a potion, but reduce the potion cooldown by half."
    requires = list("Basic Alchemy")*/
/knowledgePaths/magic/alchemy/Stimulant_Herbs
    name = "Stimulant Herbs"
    description = "Magic herbs are procured for their ability to incite violence within the subject, allowing them to channel raw offensive power. This comes at the downside of leaving one more vulnerable to retaliation."
    requires = list("Basic Alchemy")
/knowledgePaths/magic/alchemy/Relaxant_Herbs
    name = "Relaxant Herbs"
    description = "Relaxant herbs are procured for their ability to incite relaxation within the subject, allowing them to evade strikes better. This comes at the downside of decreasing offensive cabilities."
    requires = list("Basic Alchemy")
/knowledgePaths/magic/alchemy/Numbing_Herbs
    name = "Numbing Herbs"
    description = "Numbing herbs are procured for their ability to dull the pain of a subject, allowing them to resist damage. This comes at the cost of slowing down movements and reaction time. "
    requires = list("Basic Alchemy")
/knowledgePaths/magic/alchemy/Quicksilver_Herbs // Thank you for the suggestion Jumpy
    name = "Quicksilver Herbs"
    description = "Quicksilver Herbs are procured for their ability to enhance the speed of a subject. This comes at the expense of their offensive power."
    requires = list("Basic Alchemy")
/knowledgePaths/magic/alchemy/Hallucinogens
    name = "Hallucinogens"
    description = "Hallucingens are procured as a means to instill the delusion of anger in a subject. This comes at the expense of heavily compromising defense in the name of ANGER fueled might."
    requires = list("Basic Alchemy")
/* OLD OPTION STUFF
/knowledgePaths/magic/alchemy/Distillation_Process
    name = "Distillation Process"
    description = "No fucking clue rn lol, will update when I figure it out."
    requires = list("Basic Alchemy")*/ 