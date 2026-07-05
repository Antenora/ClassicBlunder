/*

alright so we have shit like this esssentially
            Randomly pick a sub type until u have them all
        -> weapons
        -> armor
Forge   -> weighted clothes     -> Repair (need atleast 3 in forging) -> other paths
        -> smelting
        -> lock smithing

but i think we can do something like

Medicine
Repair                                      -> light alloys
                                                    -> shock absorbers (armor + Repair)             Molecular Tec (advanced + shock)
                    -> Weapons -> Repair    ->
Forge -> Smelting   -> Weighted Clothing - > Armor -> Engineering -> Modular WEaponry (weapons + Engineering)
                                                    -> Advanced Plating (armor + repair)
                    -> LockSmithing

engineering - > Hazard Suits (Medicine + Engineering)
            - > Force Shielding (Shock Absorbers + Engineering)
            - > Power Generators (Molecular Technology + Engineering)    - > Jet Propulstion (Light Alloys + Power Generators) - > Cyber Engineering
Cyber Engineering (Jet Propulsion)  -> Cyber Augmentations (Cyber Engineering)
                                    -> Neuron Manipulation (Cyber Engineering) -> War Crimes (Neuron Manipulation + Cyber Augmentations) -> Singularity (War Crimes)



Cyber augments give base stat boons ( should b capped)
Neuron Manipulation give the modules
War Crimes give the punishment shit

Singularity is shit like ripper, overdrive, etc

Medicine -> MedKits, Fast Acting Medicine
MedKits -> Anesthetics          Enhancers (automated + anesthetics)
Fast Actig -> Automed dispensers



*/


/mob/Admin3/verb/EditTechnology(mob/player in players)
    set name = "Edit Technology"
    if(!player.client) return
    if(player.knowledgeTracker)
        var/atom/A = player.knowledgeTracker
        var/Edit="<html><Edit><body bgcolor=#000000 text=#339999 link=#99FFFF>"
        var/list/B=new
        Edit+="[A]<br>[A.type]"
        Edit+="<table width=10%>"
        for(var/C in A.vars) B+=C
        for(var/C in B)
            Edit+="<td><a href=byond://?src=\ref[A];action=edit;var=[C]>"
            Edit+=C
            Edit+="<td>[Value(A.vars[C])]</td></tr>"
        Edit += "</html>"
        usr<<browse(Edit,"window=[A];size=450x600")


/knowledgePaths
    var/name = "Not Obtainable"
    var/breakthrough = FALSE
    var/list/requires = list("Not Obtainable")
    var/unlocks
    var/description = "This description wasn't filled out."
    tech
        Forge
            name = "Forge"
            breakthrough = TRUE
            description = "Increases Forging talent. Doesn't provide any items.\nNeeded in order to gain Smelting.";
            requires = list()

        Smelting
            name = "Smelting"
            breakthrough = TRUE
            description = "Gives the Smelt object, allowing you to melt down items for 50% of their original value.\nNeeded in order to gain Weapons, Weighted Clothing, Enhancement, and Light Alloys."
            requires = list("Forge")

        Weapons
            name = "Weapons"
            description = "Allows access to Swords from Access Technology menu.\nNeeded in order to gain Repair, and Modular Weaponry."
            requires = list("Smelting")

        Weighted_Clothing
            name = "Weighted Clothing"
            description = "Allows access to weights from Access Technology menu.\nNeeded in order to gain Armor."
            requires = list("Smelting")

        Armor
            name = "Armor"
            description = "Allows access to Armors from Access Technology menu.\nNeeded in order to gain Engineering and Advanced Plating."
            requires = list("Weighted Clothing")
        Repair
            name = "Repair"
            description = "Gives the Repair object, allowing you to reforge broken swords / staves / armors.\nNeeded in order to gain Advanced Plating, and Shock Absorbers."
            requires = list("Weapons")
        Enhancement
            name = "Enhancement"
            description = "Increases Forging talent. Gives the Upgrade Equipment object, allowing you to upgrade swords and armor.\nDoesn't unlock any specific technology."
            requires = list("Smelting")

        Engineering
            name = "Engineering"
            breakthrough = TRUE
            description = "Increases Forging talent and allows reinforced doors, laser gates, digital keys, remotes, safes and air masks to be accessed in Access Technology.\nNeeded in order to gain Modular Weaponry, Power Generators, Hazard Suits, and Force Shielding."
            requires = list("Armor")

        Advanced_Plating
            name = "Advanced Plating"
            description = "Allows access to ceramic plating, resistant coating, and refractive plating in Access Technology menu."
            requires = list("Armor", "Repair")

        Modular_Weaponry
            name = "Modular Weaponry"
            description = "Allows access to trick weapon kit, fiber bonding agents, and quicksilver alloys in Access Technology menu.\nDoesn't unlock any specific technology."
            requires = list("Engineering", "Weapons")

        Power_Generators
            name = "Power Generators"
            description = "Allows access to charging stations in Access Technology menu.\nNeeded for Jet Propulsion."
            requires = list("Engineering")

        Jet_Propulsion
            name = "Jet Propulsion"
            description = "Allows access to jet boots in Access Technology menu.\nNeeded for CyberEngineering."
            requires = list("Power Generators")

        Cyber_Engineering
            name = "CyberEngineering"
            breakthrough = TRUE
            description = "Needed for Cyber Augmentations. Doesn't unlock anything by itself..."
            requires = list("Jet Propulsion")

        Cyber_Augmentations
            name = "Cyber Augmentations"
            description = "Grants the Augmentation object. Unlocks Enhanced Stat Modules for Cyberization.\nNeeded for War Crimes."
            requires = list("CyberEngineering")

        Neuron_Manipulation
            name = "Neuron Manipulation"
            description = "Unlocks a long list of modules for Cyberization. Internal Comms Suite, Blade Mode, Taser Strike, Machine Gun Flurry, Rocket Punch\
            Stealth Systems, Nano Boost, Combat CPU, Reconstructive Nanobots, Internal Life Support, and Energy Assimilators.\nNeeded for War Crimes."
            requires = list("CyberEngineering")

        War_Crimes
            name = "War Crimes"
            description = "Allows for nonconsensual implantation of cybernetics (yuck). Allows access to Controller Chip in Access Technology. Unlocks a short list of modules for Cyberization. Punishment Chip, Failsafe Circuit, Explosive Implantation. Girlframes, eat your heart out."
            requires = list("Neuron Manipulation", "Cyber Augmentations")

        Singularity
            name = "Singularity"
            description = "Unlocks a number of buff modules for Cyberization. Ripper Mode, Armstrong Augmentation, Ray Gear, Infinity Drive, Overdrive. Only one of these can be installed.\nDoes not unlock any further technology."
            requires = list("Neuron Manipulation", "Cyber Augmentations")

        Hazard_Suits
            name = "Hazard Suits"
            description = "Allows access to Hazard Suits in Access Technology menu\nDoesn't unlock any further technology."
            requires = list("Engineering", "Medicine")

        Force_Shielding
            name = "Force Shielding"
            description = "Allows access to deflector shields in Access Technology menu.\nDoesn't unlock any further technology."
            requires = list("Engineering", "Advanced Plating")

        Medicine
            name = "Medicine"
            breakthrough = TRUE
            description = "Allows access to perfume, soap, and first aid kits in Access Technology menu.\nNeeded for Hazard Suits, MedKits, Fast Acting Medicine."
            requires = list()

        MedKits
            name = "Medkits"
            description = "Allows access to Medkits in Access Technology... Yep.\nNeeded for Anesthetics."
            requires = list("Medicine")

        Fast_Acting_Medicine
            name = "Fast Acting Medicine"
            description = "Allows access to antivenom, isothemic spray, sealing spray, and focus stabilizer in Access Technology menu.\nNeeded for Automated Dispensers."
            requires = list("Medicine")

        Anesthetics
            name = "Anesthetics"
            description = "Allows access to painkillers in Access Technology menu.\nNeeded for Enhancers."
            requires = list("Medkits")

        Automated_Dispensers
            name = "Automated Dispensers"
            description = "Allows access to automated aid dispensers in Access Technology menu.\nNeeded for Enhancers."
            requires = list("Fast Acting Medicine")

        Enhancers
            name = "Enhancers"
            description = "Allows access to steroids in Access Technology menu.\nNo further technology unlocks."
            requires = list("Automated Dispensers", "Anesthetics")


        ImprovedMedicalTechnology
            name = "ImprovedMedicalTechnology"
            breakthrough = TRUE
            description = "Grants the Surgery object for treating long term injuries.\nNeeded for Regenerative Medicine."
            requires = list("Automated Dispensers")

        Regenerative_Medicine
            name = "Regenerative Medicine"
            description = "Allows access to revitalization serum and super soldier serum in Access Technology menu.\nNeeded for Regenerator Tanks, Genetic Medicine, and Revival Protocol."
            requires = list("ImprovedMedicalTechnology")

        Regenerator_Tanks
            name = "Regenerator Tanks"
            description = "Allows access to regenerator tanks in Access Technology. Were you expecting something different?\nNo further technology unlocks."
            requires = list("Regenerative Medicine")

        Genetic_Manipulation
            name = "Genetic Manipulation"
            description = "It unlocks the delusion that this game will one day have a genetic system that rivals SS13. It's not gonna happen. Uh... Also you need it to learn Revival Protocol and Prosthetic Limbs."
            requires = list("Regenerative Medicine")

        Revial_Protocol
            name = "Revival Protocol"
            description = "Grants the Revival Protocol object.\nNo further technology unlocks."
            requires = list("Genetic Manipulation", "Regenerative Medicine")

        Prosthetic_Limbs
            name = "Prosthetic Limbs"
            description = "Allows access to prosthetic limbs in Access Technology menu.\nNeeded for Vehicular Power Armor."
            requires = list("Genetic Manipulation")


        Telecommunications
            name = "Telecommunications"
            requires = list()
            description = "Allows access to communicators and PDAs in Access Technology menu.\nNeeded for Local Range Devices and Surveilance."
            breakthrough = TRUE

        Local_Range_Devices
            name = "Local Range Devices"
            description = "Allows access to binoculars, doorbells, and speakers in Access Technology menu.\nNeeded for Wide Area Transmission."
            requires = list("Telecommunications")

        Wide_Area_Transmission
            name = "Wide Area Transmission"
            description = "Insert funny riff on how this gives nothing. Needed for Drones and Advanced Transmission Technology."
            requires = list("Local Range Devices")

        Surveilance
            name = "Surveilance"
            description = "Makes you think about the state of the world, huh? Nothing else, though. Needed for Espionage Equipment, Drones, and Advanced Transmission Technology."
            requires = list("Telecommunications")

        Espionage_Equipment
            name = "Espionage Equipment"
            description = "Grants the Espionage Scan object. Allows access to hacking devices and wiretaps.\nNo further technology unlocks."
            requires = list("Surveilance")

        Drones
            name = "Drones"
            description = "Nope...nothing. No further technology unlocks."
            requires = list("Surveilance", "Wide Area Transmission")

        AdvancedTransmissionTechnology
            breakthrough = TRUE
            name = "AdvancedTransmissionTechnology"
            description = "Allows you to spend more RPP to buy Scouters! Yay!!"
            requires = list("Wide Area Transmission", "Surveilance")

        Scouters
            name = "Scouters"
            description = "At long last, you can do the meme. Allows access to scouters in Access Technology.\nNeeded for Combat Scanning."
            requires = list("AdvancedTransmissionTechnology")

        Combat_Scanning
            name = "Combat Scanning"
            description = "Allows you a very powerful tool for gaining skills... Except... That part of the tech tree isn't in anymore!\nNeeded for Vehicular Power Armor."
            requires = list("Scouters", "Neuron Manipulation")


        MilitaryTechnology
            name = "MilitaryTechnology"
            requires = list()
            description = "Allows access to plasma blaster through Access Technology menu.\nNeeded for Assault Weaponry."
            breakthrough = TRUE

        Assault_Weaponry
            name = "Assault Weaponry"
            description = "Allows access to plasma rifle though Access Technology menu.\nNeeded for Missile Weaponry, and Melee Weaponry."
            requires = list("MilitaryTechnology")

        Missile_Weaponry
            name = "Missile Weaponry"
            description = "Allows access to missile launcher through Access Technology menu.\nNo further technology unlocks."
            requires = list("Assault Weaponry")

        Melee_Weaponry
            name = "Melee Weaponry"
            description = "Allows access to progressive blade through Access technology menu. 🏳‍🌈\nNeeded for Thermal Weaponry."
            requires = list("Assault Weaponry")

        Thermal_Weaponry
            name = "Thermal Weaponry"
            description = "Allows access to incinerator and freezing ray through Access Technology menu.\nNeeded for Blast Shielding and Military Engineering."
            requires = list("Melee Weaponry")

        Blast_Shielding
            name = "Blast Shielding"
            description = "Allows access to blast shield through Access Technology menu.\nNeeded for Vehicular Power Armor."
            requires = list("Thermal Weaponry")

        MilitaryEngineering
            name = "MilitaryEngineering"
            breakthrough = TRUE
            description = "Increases Forging talent. Allows access to powered exoskeleton through Access Technology menu.\nNeeded for Armorpiercing Weaponry."
            requires = list("Thermal Weaponry")

        Armorpiercing_Weaponry
            name = "Armorpiercing Weaponry"
            description = "Allows access to pile bunker through Access Technology menu.\nNeeded for Impact Weaponry."
            requires = list("MilitaryEngineering")

        Impact_Weaponry
            name = "Impact Weaponry"
            description = "Allows access to blast fist through Access Technology menu.\nNeeded for Hydraulic Weaponry."
            requires = list("Armorpiercing Weaponry")
        Hydraulic_Weaponry
            name = "Hydraulic Weaponry"
            description = "Allows access to power claw through Access Technology menu.\nNeeded for Vehicular Power Armor."
            requires = list("Impact Weaponry")

        Vehicular_Power_Armor
            name = "Vehicular Power Armor"
            description = "Allows access to mobile suit through Access Technology menu.\nNo further technology unlocks."
            requires = list("Hydraulic Weaponry", "Blast Shielding", "Combat Scanning", "Prosthetic Limbs" )

        Culinary_Basics
            name="Culinary Basics"
            requires = list();
            description = "Learn the basics of getting yourself fed. Or drunk."

        Piloting_Foundations
            name="Piloting Foundations"
            requires = list();
            description = "Learn how to pilot War Machines,like Powered Armor and Mobile Suits.";
