/obj/Skills/Buffs/NuStyle/UnarmedStyle
    Heavenly_Demon_T3
        name = "Heavenly Demon's Chaotic Way of Shattered Realms"
        StyleActive = "Heavenly Demon's Chaotic Way of Shattered Realms"
        SignatureTechnique=3
        Copyable=0
        passives = list("Conductor" = 90, "Antsy" = 10, "CounterMaster" = 5, "SwordPunching" = 1, "NeedsSword" = 0, "NoSword" = 1)
        NeedsSword=0
        NoSword=1
        SwordPunching=1
        StyleStr=1
        StyleEnd=1
        StyleOff=1
        StyleDef=1
        StyleFor=1
        Finisher="/obj/Skills/Queue/Finisher/Cycle_of_Samsara"
        verb/Heavenly_Demons_Chaotic_Way_of_Shattered_Realms()
            set hidden=1
            src.Trigger(usr)
    Jeet_Kune_Do
        SignatureTechnique=3
        // no ideas as of yet
        StyleEnd = 1.25
        StyleDef = 1.25
        StyleSpd = 1.25
        StyleStr = 1.25
        StyleActive="Jeet Kune Do"
        passives = list("LikeWater" = 4, "Fa Jin" = 3, "Interception" = 3, "Sunyata" = 3 , "Gum Gum" = 1, "Acupuncture" = 2, \
                        "Flow" = 2, "Instinct" = 2, "Momentum" = 1.5, "Hardening" = 1.5, "Pressure" = 2, "Soft Style" = 1, \
                        "FluidForm" = 1)
        Finisher="/obj/Skills/Queue/Finisher/Be_Water"
        verb/Jeet_Kune_Do()
            set hidden=1
            src.Trigger(usr)
    All_Star_Wrestling
        SignatureTechnique=3
        StyleEnd=1.5
        StyleStr=1.5
        passives = list("Heavy Strike" = "Wrestling", "Muscle Power" = 6, "Grippy" = 5, \
                        "Scoop" = 3, "Iron Grip" = 1, "DeathField" = 5, "Gum Gum" = 2, "Hardening" = 2, \
                        "Momentum" = 2)
        StyleActive="All Star Wrestling"
        Finisher="/obj/Skills/Queue/Finisher/Big_Boot"
        verb/All_Star_Wrestling()
            set hidden=1
            src.Trigger(usr)
    
    Flying_Thunder_God
        SignatureTechnique=3
        passives = list("Flying Thunder God" = 1, "BlurringStrike" = 1, "Fury" = 1.5, "Fa Jin" = 2, "Instinct" = 2, "Secret Knives" = "FTG", "Tossing" = 2, \
        "SwordPunching" = 1, "NeedsSword" = 0, "NoSword" = 1)
        // make it so every cooldown like iaido, also make the tracker appear on hud
        // make an animation for the tp
        StyleSpd = 1.5
        StyleOff = 1.5
        StyleActive="Flying Thunder God"
        Finisher="/obj/Skills/Queue/Finisher/Be_Water" //TODO: make a finisher here
        verb/Flying_Thunder_God()
            set hidden=1
            src.Trigger(usr)