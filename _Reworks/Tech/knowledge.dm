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
            requires = list()

        Smelting
            name = "Smelting"
            breakthrough = TRUE
            requires = list("Forge")

        Weapons
            name = "Weapons"
            requires = list("Smelting")

        Weighted_Clothing
            name = "Weighted Clothing"
            requires = list("Smelting")

        Armor
            name = "Armor"
            requires = list("Weighted Clothing")
        Repair
            name = "Repair"
            requires = list("Weapons")
        Enhancement
            name = "Enhancement"
            requires = list("Smelting")

        Engineering
            name = "Engineering"
            breakthrough = TRUE
            requires = list("Armor")

        Advanced_Plating
            name = "Advanced Plating"
            requires = list("Armor", "Repair")

        Shock_Absorbers
            name = "Shock Absorbers"
            requires = list("Armor", "Repair")

        Molecular_Technology
            name = "Molecular Technology"
            requires = list("Advanced Plating", "Shock Absorbers")

        Modular_Weaponry
            name = "Modular Weaponry"
            requires = list("Engineering", "Weapons")

        Light_Alloys
            name = "Light Alloys"
            requires = list("Smelting")

        Power_Generators
            name = "Power Generators"
            requires = list("Molecular Technology", "Engineering")

        Jet_Propulsion
            name = "Jet Propulsion"
            requires = list("Power Generators", "Light Alloys")

        Cyber_Engineering
            name = "CyberEngineering"
            breakthrough = TRUE
            requires = list("Jet Propulsion")

        Cyber_Augmentations
            name = "Cyber Augmentations"
            requires = list("CyberEngineering")

        Neuron_Manipulation
            name = "Neuron Manipulation"
            requires = list("CyberEngineering")

        War_Crimes
            name = "War Crimes"
            requires = list("Neuron Manipulation", "Cyber Augmentations")

        Singularity
            name = "Singularity"
            requires = list("War Crimes")

        Hazard_Suits
            name = "Hazard Suits"
            requires = list("Engineering", "Medicine")

        Force_Shielding
            name = "Force Shielding"
            requires = list("Engineering", "Shock Absorbers")

        Medicine
            name = "Medicine"
            breakthrough = TRUE
            requires = list()

        MedKits
            name = "Medkits"
            requires = list("Medicine")

        Fast_Acting_Medicine
            name = "Fast Acting Medicine"
            requires = list("Medicine")

        Anesthetics
            name = "Anesthetics"
            requires = list("Medkits")

        Automated_Dispensers
            name = "Automated Dispensers"
            requires = list("Fast Acting Medicine")

        Enhancers
            name = "Enhancers"
            requires = list("Automated Dispensers", "Anesthetics")


        ImprovedMedicalTechnology
            name = "ImprovedMedicalTechnology"
            breakthrough = TRUE
            requires = list("Automated Dispensers")

        Regenerative_Medicine
            name = "Regenerative Medicine"
            requires = list("ImprovedMedicalTechnology")

        Regenerator_Tanks
            name = "Regenerator Tanks"
            requires = list("Regenerative Medicine")

        Genetic_Manipulation
            name = "Genetic Manipulation"
            requires = list("Regenerative Medicine")

        Revial_Protocol
            name = "Revival Protocol"
            requires = list("Genetic Manipulation", "Regenerative Medicine")

        Prosthetic_Limbs
            name = "Prosthetic Limbs"
            requires = list("Genetic Manipulation")


        Telecommunications
            name = "Telecommunications"
            requires = list()
            breakthrough = TRUE

        Local_Range_Devices
            name = "Local Range Devices"
            requires = list("Telecommunications")

        Wide_Area_Transmission
            name = "Wide Area Transmission"
            requires = list("Local Range Devices")

        Surveilance
            name = "Surveilance"
            requires = list("Telecommunications")

        Espionage_Equipment
            name = "Espionage Equipment"
            requires = list("Surveilance")

        Drones
            name = "Drones"
            requires = list("Surveilance", "Wide Area Transmission")

        AdvancedTransmissionTechnology
            breakthrough = TRUE
            name = "AdvancedTransmissionTechnology"
            requires = list("Wide Area Transmission", "Surveilance")

        Scouters
            name = "Scouters"
            requires = list("AdvancedTransmissionTechnology")

        Combat_Scanning
            name = "Combat Scanning"
            requires = list("Scouters", "Neuron Manipulation")


        MilitaryTechnology
            name = "MilitaryTechnology"
            requires = list()
            breakthrough = TRUE

        Assault_Weaponry
            name = "Assault Weaponry"
            requires = list("MilitaryTechnology")

        Missile_Weaponry
            name = "Missile Weaponry"
            requires = list("Assault Weaponry")

        Melee_Weaponry
            name = "Melee Weaponry"
            requires = list("Assault Weaponry")

        Thermal_Weaponry
            name = "Thermal Weaponry"
            requires = list("Melee Weaponry")

        Blast_Shielding
            name = "Blast Shielding"
            requires = list("Thermal Weaponry")

        MilitaryEngineering
            name = "MilitaryEngineering"
            breakthrough = TRUE
            requires = list("Thermal Weaponry")

        Armorpiercing_Weaponry
            name = "Armorpiercing Weaponry"
            requires = list("MilitaryEngineering")

        Impact_Weaponry
            name = "Impact Weaponry"
            requires = list("Armorpiercing Weaponry")
        Hydraulic_Weaponry
            name = "Hydraulic Weaponry"
            requires = list("Impact Weaponry")

        Vehicular_Power_Armor
            name = "Vehicular Power Armor"
            requires = list("Hydraulic Weaponry", "Blast Shielding", "Combat Scanning", "Prosthetic Limbs" )