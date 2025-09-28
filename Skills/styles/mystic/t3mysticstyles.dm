/obj/Skills/Buffs/NuStyle/MysticStyle
// TODO: Deterioration - make energy/mana cost more
// 
    Oblivion_Storm
        SignatureTechnique = 3
        passives = list("DemonicInfusion" = 1,, "IceHerald" = 1, "ThunderHerald" = 1, "Heavy Strike" = "HellfireInferno", \
                        "Chaos" = 15, "Scorching" = 15, "Combustion" = 80, "IceAge" = 25, "SpiritFlow" = 4, "Familiar" = 3,\
                        "CriticalChance" = 35, "CriticalDamage" = 0.25,"Hardening" = 2, "AirBend" = 2, "WaveDancer" = 2)
        StyleFor = 1.6
        StyleSpd = 1.2
        StyleOff = 1.2
        StyleActive = "Oblivion Storm"
        Finisher="/obj/Skills/Queue/Finisher/Soul_Seller"
        verb/Oblivion_Storm()
			set hidden=1
			src.Trigger(usr)
    Annihilation
        SignatureTechnique = 3
        passives = list("Atomizer" = 1, "BetterAim" = 3, "SuperCharge" = 2, "Familiar" = 3, "SpiritFlow" = 4, \
                        "ThunderHerald" = 1, "CriticalChance" = 25, "CriticalDamage" = 0.1, "Godspeed" = 3, "AirBend" = 2, \
                        "Hardening" = 2, "Scorching" = 8, "Shattering" = 8, "Shocking" = 8, "Freezing" = 8)
        StyleFor = 1.5
        StyleOff = 1.5
        StyleActive = "Annihilation"
        Finisher="/obj/Skills/Queue/Finisher/Atomic_Dismantling"
        verb/Annihilation()
			set hidden=1
			src.Trigger(usr)
    Omnimancer
        SignatureTechnique = 3
        passives = list("Deterioration" = 1, "Erosion" = 0.15, "SpiritFlow" = 4, "Amplify" = 3, "LikeWater" = 4)
        ElementalDefense = "Void"
        ElementalOffense = "Void"
        StyleFor = 1.3
        StyleOff = 1.15
        StyleDef = 1.15
        StyleActive="Singularity"
        proc/swap_stance(o)
            switch(o)
                if("blizzard")
                    ElementalOffense = "Water"
                    ElementalDefense = "Wind"
                    ElementalClass = list("Wind","Water")
                    BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Water"
                    passives = list("IceHerald" = 1,"Familiar" = 2, "ThunderHerald" = 1, "CriticalChance" = 20, "CriticalDamage" = 0.2, "SpiritFlow" = 4, "Hardening" = 2, \
                                    "Freezing" = 5, "Shocking" = 5, "AirBend" = 2, "WaveDancer" = 1.5)
                    Finisher="/obj/Skills/Queue/Finisher/Frostfist"
                    StyleActive = "Blizzard"
                    StyleOff=1.15
                    StyleSpd=1.15
                    StyleFor=1.3
                if("hellfire")
                    passives = list("SpiritFlow" = 4, "Familiar" = 2, "Combustion" = 60, "Heavy Strike" = "Inferno",\
						"Scorching" = 1)
                    ElementalOffense = "HellFire"
                    ElementalDefense = "Fire"
                    ElementalClass = "Fire"
                    BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Fire"
                    StyleFor = 1.6
                    Finisher="/obj/Skills/Queue/Finisher/Deal_with_the_Devil"
                    var/obj/Skills/demonSkill = FALSE
                    Trigger(mob/User, Override)
                        if(!demonSkill)
                            var/inp = input(User, "What demon skill do you want?") in list("/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/Hellstorm", "/obj/Skills/Projectile/Magic/HellFire/Hellpyre", "/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/OverHeat")
                            BuffTechniques = list(inp)
                            demonSkill = inp
                        sleep(2)
                        ..()
                    StyleActive = "Hellfire"
                if("plasma")
                    ElementalOffense = "Wind"
                    ElementalDefense = "Fire"
                    ElementalClass = list("Fire","Wind")
                    StyleFor = 1.3
                    StyleSpd = 1.3
                    BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Earth"
                    passives = list("SuperCharge" = 1,"Familiar" = 2, "SpiritFlow" = 4, "ThunderHerald" = 1, "CriticalChance" = 20, "CriticalDamage" = 0.1, \
                                    "Godspeed" = 2, "AirBend" = 1.5, "Hardening" = 2, "Burning" = 2, "Shattering" = 5, "Shocking" = 2, "Chilling" = 2)
                    Finisher="/obj/Skills/Queue/Finisher/Mega_Arm" // Super_mega_buster
                    StyleActive = "Plasma"
                if("singularity")
                    passives = list("Deterioration" = 1, "Erosion" = 0.15, "SpiritFlow" = 4, "Amplify" = 3, "LikeWater" = 4, /* ??? */)
                    ElementalDefense = "Void"
                    ElementalOffense = "Void"
                    StyleFor = 1.3
                    StyleOff = 1.15
                    StyleDef = 1.15
                    StyleActive="Singularity"
                    Finisher="/obj/Skills/Queue/Finisher/The_Void"
        verb/Blizzard_Stance()
            set category="Stances"
			if(usr.BuffOn(src))
				turnOff(usr)
			swap_stance("blizzard")
			Trigger(usr, 1)
			giveBackTension(usr)
        verb/Hellfire_Stance()
            set category="Stances"
			if(usr.BuffOn(src))
				turnOff(usr)
			swap_stance("hellfire")
			Trigger(usr, 1)
			giveBackTension(usr)
        verb/Plasma_Stance()
            set category="Stances"
			if(usr.BuffOn(src))
				turnOff(usr)
			swap_stance("plasma")
			Trigger(usr, 1)
			giveBackTension(usr)
        verb/Singularity_Stance()
            set category="Stances"
			if(usr.BuffOn(src))
				turnOff(usr)
			swap_stance("singularity")
			Trigger(usr, 1)
			giveBackTension(usr)
            