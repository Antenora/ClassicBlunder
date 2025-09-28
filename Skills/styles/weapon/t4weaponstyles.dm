/obj/Skills/Buffs/NuStyle/SwordStyle
    Way_of_the_Kensei
        SignatureTechnique = 4
        StyleOff=1.5
        StyleStr=1.5
        StyleSpd=1.25
        StyleDef=1.25
        passives = list("Kensei" = 1, "The Way" = 1, "Sword Master" = 1, "LikeWater" = 6, "SweepingStrike" = 1, "DoubleStrike" = 3, "BlurringStrikes" = 1.5, \
                        "Zornhau" = 3, "Half-Sword" = 2, "Rage" = 1, "TripleStrike" = 1, "Iaijutsu" = 5, "Musoken" = 1, "Fury" = 3, "Momentum" = 3, "Hardening" = 3, \
                        "Parry" = 3, "Disarm" = 2, "Deflection" = 2, "Pressure" = 4)
        StyleActive="Way of the Kensei"
        verb/Way_of_the_Kensei()
            set hidden=1
            src.Trigger(usr)
    Kyutoryu
        SignatureTechnique = 4
        StyleActive="Kyutoryu"
        StyleSpd=2
        StyleStr=1.5
        passives = list("AsuraStrike" = 1, "TripleStrike" = 2, "DoubleStrike" = 3, "Iaijutsu" = 3, \
                        "Fury" = 5, "NeedsSecondSword" = 1, "NeedsThirdSword" = 1, "BlurringStrikes" = 2, "SweepingStrikes" = 1, \
                        "Iaijutsu" = 3, "Disarm" = 3, "Parry" = 3, "Fury" = 5, "Unnerve" = 2, "Pressure" = 2 )
        verb/Kyutoryu()
            set hidden=1
            src.Trigger(usr)
    War_God
        SignatureTechnique = 4
        StyleActive="Kratos"
        StyleOff=1.5
        StyleStr=2
        StyleEnd=1.5
        passives = list("DisableGodKi" = 1, "Deicide" = 10, "Rage" = 5, "Half-Sword" = 5, "Zornhau" = 5, "FavoredPrey" = "Everything", \
                        "Shearing" = 10, "Deflection" = 5, "Disarm" = 3,"Parry" = 5, "Momentum" = 5, "Hardening" = 5, \
                        "Secret Knives" = "GodSlayer", "Tossing" = 5, "Pressure" = 5, "Unnerve" = 5)
                        // either throw swords at them, or runes, depending on icon_state do a different effect
        verb/War_God()
            set hidden=1
            src.Trigger(usr)

