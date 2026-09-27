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


/mob/Admin3/verb/EditTechnology()
    set name = "Edit Technology"
    var/mob/player = PromptArg(usr, args, 1, "Edit Technology", "players")
    if(isnull(player)) return
    if(!player.client) return
    if(player.knowledgeTracker)
        var/atom/A = player.knowledgeTracker
        var/list/B = list()
        for(var/C in A.vars) B += C
        usr.client?.SheetShow("edit:\ref[A]", "EDIT", "[A]", "[A.type]", SheetVarRows(A, B), "a name to edit")


/knowledgePaths
    var/name = "Not Obtainable"
    var/breakthrough = FALSE
    var/list/requires = list("Not Obtainable")
    var/list/requires_any = list()
    var/tier = 0
    var/bench
    var/unlocks
    var/description = "This description wasn't filled out."
    tech
        Engineering
            name = "Engineering"
            bench = "Engineer"
            tier = 0
            breakthrough = TRUE
            description = "Unlocks keys, door passes, security and reinforced doors, laser gates, safes, alarms, lamps and the Door Repair Kit."
            requires = list()

        Fabrication
            name = "Fabrication"
            bench = "Engineer"
            tier = 1
            description = "Unlocks the advanced parts every builder needs: Circuit Board, Servo, Power Cell, Lens, Nanites and the Power Pack."
            requires = list("Engineering")

        Power_Generators
            name = "Power Generators"
            bench = "Engineer"
            tier = 2
            description = "Unlocks the Charging Station and the Fuel Cell."
            requires = list("Fabrication")

        Hazard_Suits
            name = "Hazard Suits"
            bench = "Engineer"
            tier = 3
            description = "Unlocks the Hazard Suit and the Sealed Suit."
            requires = list("Power Generators")

        Field_Gadgets
            name = "Field Gadgets"
            bench = "Engineer"
            tier = 3
            description = "Unlocks the Auto-Sprinkler, Ore Scanner, Fish Finder and Botanical Analyzer."
            requires = list("Power Generators")

        Force_Shielding
            name = "Force Shielding"
            bench = "Engineer"
            tier = 4
            description = "Unlocks the Deflector Shield, Bubble Shield and Force Field Emitter."
            requires = list()
            requires_any = list("Hazard Suits", "Field Gadgets")

        Automated_Defenses
            name = "Automated Defenses"
            bench = "Engineer"
            tier = 4
            description = "Unlocks the Sentry Turret."
            requires = list()
            requires_any = list("Hazard Suits", "Field Gadgets")

        EM_Wave_Projectors
            name = "EM Wave Projectors"
            bench = "Engineer"
            tier = 4
            description = "Unlocks the Projector Tower, the Portable Projector and its five emitters."
            requires = list()
            requires_any = list("Hazard Suits", "Field Gadgets")

        Drones
            name = "Drones"
            bench = "Engineer"
            tier = 4
            description = "Unlocks the Drone."
            requires = list()
            requires_any = list("Hazard Suits", "Field Gadgets")

        Teleportation
            name = "Teleportation"
            bench = "Engineer"
            tier = 5
            description = "Unlocks Teleport Pads."
            requires = list()
            requires_any = list("Force Shielding", "Automated Defenses", "EM Wave Projectors", "Drones")

        Telecommunications
            name = "Telecommunications"
            bench = "Operative"
            tier = 0
            breakthrough = TRUE
            description = "Unlocks the Communicator, Speaker, Doorbell, Binoculars, PDA and Jukebox."
            requires = list()

        Scouters
            name = "Scouters"
            bench = "Operative"
            tier = 2
            description = "Unlocks every Scouter tier and the Dragon Radar."
            requires = list("Telecommunications")

        Espionage_Equipment
            name = "Espionage Equipment"
            bench = "Operative"
            tier = 2
            description = "Unlocks the Wiretap, Tracker Tag and Bug Sweeper."
            requires = list("Telecommunications")

        Wide_Area_Transmission
            name = "Wide Area Transmission"
            bench = "Operative"
            tier = 3
            description = "Unlocks the Transmission Tower and the Beacon."
            requires = list()
            requires_any = list("Scouters", "Espionage Equipment")

        Intrusion_Tools
            name = "Intrusion Tools"
            bench = "Operative"
            tier = 3
            description = "Unlocks the Hacking Device and the handheld Jammer."
            requires = list()
            requires_any = list("Scouters", "Espionage Equipment")

        Obfuscation_Equipment
            name = "Obfuscation Equipment"
            bench = "Operative"
            tier = 4
            description = "Unlocks the Cloak and the Cloak Controls."
            requires = list()
            requires_any = list("Wide Area Transmission", "Intrusion Tools")

        Combat_Scanning
            name = "Combat Scanning"
            bench = "Operative"
            tier = 4
            description = "Unlocks the Combat Scanner mode, the Security Camera and its Display."
            requires = list("Scouters")

        Technique_Analysis
            name = "Technique Analysis"
            bench = "Operative"
            tier = 5
            description = "Unlocks technique downloads and the discs that carry them."
            requires = list()
            requires_any = list("Obfuscation Equipment", "Combat Scanning")

        Military_Technology
            name = "Military Technology"
            bench = "Gunsmith"
            tier = 0
            breakthrough = TRUE
            description = "Unlocks the Handgun, the USP, the Red 9, Pistol rounds and Training Rounds."
            requires = list()

        Assault_Weaponry
            name = "Assault Weaponry"
            bench = "Gunsmith"
            tier = 2
            description = "Unlocks the SMG, the TMP, the Shotgun, Rifle rounds and Shells."
            requires = list("Military Technology")

        Demolitions
            name = "Demolitions"
            bench = "Gunsmith"
            tier = 2
            description = "Unlocks Frag, Smoke, Flash and Gas grenades, plus Caltrops, the Flare and the Bola."
            requires = list("Military Technology")

        Munitions
            name = "Munitions"
            bench = "Gunsmith"
            tier = 3
            description = "Unlocks the special round types and the Magnum."
            requires = list()
            requires_any = list("Assault Weaponry", "Demolitions")

        Weapon_Modding
            name = "Weapon Modding"
            bench = "Gunsmith"
            tier = 3
            description = "Unlocks all eight gun mods, Ballistic Weave and the Glock 18C."
            requires = list()
            requires_any = list("Assault Weaponry", "Demolitions")

        Heavy_Weaponry
            name = "Heavy Weaponry"
            bench = "Gunsmith"
            tier = 4
            description = "Unlocks the Missile Launcher, Chemical Mortar, Incinerator, Freeze Ray, Tactical, Dualwield and Punisher."
            requires = list()
            requires_any = list("Munitions", "Weapon Modding")

        Electronic_Warfare
            name = "Electronic Warfare"
            bench = "Gunsmith"
            tier = 4
            description = "Unlocks the EMP grenade, EMP mine, EMP rounds, the Frag mine and the Breaching Charge."
            requires = list()
            requires_any = list("Munitions", "Weapon Modding")

        Energy_Weaponry
            name = "Energy Weaponry"
            bench = "Gunsmith"
            tier = 5
            description = "Unlocks the energy guns and the Heat Sink."
            requires = list()
            requires_any = list("Heavy Weaponry", "Electronic Warfare")

        Heavy_Ordnance
            name = "Heavy Ordnance"
            bench = "Gunsmith"
            tier = 5
            description = "Unlocks the Ultra Laser, Missile Massacre and their mounts."
            requires = list()
            requires_any = list("Heavy Weaponry", "Electronic Warfare")

        Military_Engineering
            name = "Military Engineering"
            bench = "Mechanist"
            tier = 0
            breakthrough = TRUE
            description = "Unlocks the Hoverboard and the powered tools."
            requires = list()

        Piloting_Foundations
            name = "Piloting Foundations"
            bench = "Mechanist"
            tier = 1
            description = "Grants a point of Piloting Prowess and the license to pilot war machines."
            requires = list("Military Engineering")

        Jet_Propulsion
            name = "Jet Propulsion"
            bench = "Mechanist"
            tier = 2
            description = "Unlocks Jet Boots and the Jet Pack."
            requires = list("Piloting Foundations")

        Melee_Weaponry
            name = "Melee Weaponry"
            bench = "Mechanist"
            tier = 3
            description = "Unlocks the Progressive Blade and the Lightsaber forms."
            requires = list("Jet Propulsion")

        Powered_Exoskeletons
            name = "Powered Exoskeletons"
            bench = "Mechanist"
            tier = 3
            description = "Unlocks the Exosuit and its integration."
            requires = list("Jet Propulsion")

        Weapon_Modules
            name = "Weapon Modules"
            bench = "Mechanist"
            tier = 3
            description = "Unlocks the Blast Fist, Power Fist, Pile Bunker, Chainsaw, Power Claw and Hook Grip Claw."
            requires = list("Jet Propulsion")

        Powered_Armor_Specialization
            name = "Powered Armor Specialization"
            bench = "Mechanist"
            tier = 4
            description = "Unlocks the Burst, Burly and Blitz armor specializations."
            requires = list()
            requires_any = list("Melee Weaponry", "Powered Exoskeletons", "Weapon Modules")

        Mech_Fabrication
            name = "Mech Fabrication"
            bench = "Mechanist"
            tier = 4
            description = "Unlocks mech components, the Mech Bay and Capsules."
            requires = list()
            requires_any = list("Melee Weaponry", "Powered Exoskeletons", "Weapon Modules")

        Vehicular_Power_Armor
            name = "Vehicular Power Armor"
            bench = "Mechanist"
            tier = 5
            description = "Unlocks Mobile Suit assembly and the Limit Mode drives."
            requires = list("Powered Armor Specialization", "Mech Fabrication")

        Cyber_Engineering
            name = "Cyber Engineering"
            bench = "Cyberneticist"
            tier = 0
            breakthrough = TRUE
            description = "Unlocks the Frame Repair Kit and the Prosthetic Limb."
            requires = list()

        Cyber_Augmentations
            name = "Cyber Augmentations"
            bench = "Cyberneticist"
            tier = 1
            description = "Grants the install skill for non-Androids and unlocks the six Stat chips."
            requires = list("Cyber Engineering")

        Combat_Routines
            name = "Combat Routines"
            bench = "Cyberneticist"
            tier = 2
            description = "Unlocks Taser Strike, Rocket Punch, Internal Comms, the Internal Scouter and Machine Gun Flurry."
            requires = list("Cyber Augmentations")

        Neuron_Manipulation
            name = "Neuron Manipulation"
            bench = "Cyberneticist"
            tier = 3
            description = "Unlocks Nano Boost, Combat CPU, Stealth Systems, Reconstructive Nanobots, Blade Mode, Life Support, Energy Assimilators, the Targeting CPU and the Maintenance Pod."
            requires = list("Combat Routines")

        Cybernetic_Mainframe
            name = "Cybernetic Mainframe"
            bench = "Cyberneticist"
            tier = 4
            description = "Unlocks the Mainframe and its merged integration."
            requires = list("Neuron Manipulation")

        War_Crimes
            name = "War Crimes"
            bench = "Cyberneticist"
            tier = 4
            description = "Unlocks the Punishment Chip, Failsafe Circuit, Explosive Implantation and the Chip Controller."
            requires = list("Neuron Manipulation")

        Singularity
            name = "Singularity"
            bench = "Cyberneticist"
            tier = 5
            description = "Unlocks the Military Frames."
            requires = list()
            requires_any = list("Cybernetic Mainframe", "War Crimes")

        Core_Transplant
            name = "Core Transplant"
            bench = "Cyberneticist"
            tier = 5
            description = "Unlocks the procedure that changes an Android Core."
            requires = list()
            requires_any = list("Cybernetic Mainframe", "War Crimes")

        Medicine
            name = "Medicine"
            bench = "Medic"
            tier = 0
            breakthrough = TRUE
            description = "Unlocks bandages, the First Aid Kit and the Medical Scanner."
            requires = list()

        Fast_Acting_Medicine
            name = "Fast Acting Medicine"
            bench = "Medic"
            tier = 2
            description = "Unlocks Antivenom, Cooling Spray, Sealing Spray, the Focus Stabilizer, Coagulant Spray, Restorative Salve and Anesthetics."
            requires = list("Medicine")

        Trauma_Care
            name = "Trauma Care"
            bench = "Medic"
            tier = 2
            description = "Unlocks the Trauma Kit, Painkillers, the Emergency Autoinjector and the Aid Station."
            requires = list("Medicine")

        Medkits
            name = "Medkits"
            bench = "Medic"
            tier = 2
            description = "Unlocks the Medkit and the Defibrillator."
            requires = list("Medicine")

        Enhancers
            name = "Enhancers"
            bench = "Medic"
            tier = 3
            description = "Unlocks the Steroid."
            requires = list()
            requires_any = list("Fast Acting Medicine", "Trauma Care", "Medkits")

        Improved_Medical_Technology
            name = "Improved Medical Technology"
            bench = "Medic"
            tier = 3
            description = "Grants the Surgery kit for treating long term injuries."
            requires = list()
            requires_any = list("Fast Acting Medicine", "Trauma Care", "Medkits")

        Regenerative_Medicine
            name = "Regenerative Medicine"
            bench = "Medic"
            tier = 4
            description = "Unlocks the Revitalization, Genome Enhance, Super Soldier and Genome Warp Serums."
            requires = list()
            requires_any = list("Enhancers", "Improved Medical Technology")

        Regenerator_Tanks
            name = "Regenerator Tanks"
            bench = "Medic"
            tier = 4
            description = "Unlocks the Regen Tank and its healing fluid."
            requires = list()
            requires_any = list("Enhancers", "Improved Medical Technology")

        Genetic_Manipulation
            name = "Genetic Manipulation"
            bench = "Medic"
            tier = 5
            description = "Unlocks the Cloning Tank."
            requires = list()
            requires_any = list("Regenerative Medicine", "Regenerator Tanks")

        Revival_Protocol
            name = "Revival Protocol"
            bench = "Medic"
            tier = 5
            description = "Unlocks Revival."
            requires = list()
            requires_any = list("Regenerative Medicine", "Regenerator Tanks")
