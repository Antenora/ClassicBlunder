/obj/Skills/Buffs/NuStyle/SwordStyle
    Ittoryu_Style
        passives = list("Musoken" = 1)
        StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Fencing_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Nito_Ichi_Style",\
        "/obj/Skills/Buffs/NuStyle/SwordStyle/Gladiator_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Iaido_Style",\
        "/obj/Skills/Buffs/NuStyle/SwordStyle/Ulfberht_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Kunst_des_Fechtens",\
        "/obj/Skills/Buffs/NuStyle/SwordStyle/Chain_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Fist_of_Khonshu")
        StyleStr = 1.15
        StyleOff = 1.15
        StyleActive="Ittoryu"
        Finisher="/obj/Skills/Queue/Finisher/Shishi_Sonson"
        verb/Ittoryu_Style()
            set hidden=1
            src.Trigger(usr)
    Fencing_Style
        StyleSpd=1.15
        StyleOff=1.15
        StyleActive="Fencing"
        passives = list("Parry" = 1)
        StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Ittoryu_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Nito_Ichi_Style",\
        "/obj/Skills/Buffs/NuStyle/SwordStyle/Gladiator_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Dardi_Style")
        Finisher="/obj/Skills/Queue/Finisher/La_Rapiere_des_Sorel"
        verb/Fencing_Style()
            set hidden=1
            src.Trigger(usr)
    Ulfberht_Style
        StyleStr=1.3
        StyleEnd=0.85
        StyleOff=1.15
        StyleActive="Ulfberht"
        StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Ittoryu_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Kunst_des_Fechtens")
        passives = list("Half-Sword" = 1)
        Finisher="/obj/Skills/Queue/Finisher/Skofnung"
        verb/Ulfberht_Style()
            set hidden=1
            src.Trigger(usr)
    Gladiator_Style
        StyleOff = 1.1
        StyleEnd = 1.1
        StyleDef = 1.1
        StyleActive="Gladiator"
        passives = list("Disarm" = 1)
        StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Fencing_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Dardi_Style",\
        "/obj/Skills/Buffs/NuStyle/SwordStyle/Ittoryu_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Iaido_Style")
        Finisher="/obj/Skills/Queue/Finisher/Challenge"
        verb/Gladiator_Style()
            set hidden=1
            src.Trigger(usr)
    Chain_Style
        passives = list()
        StyleStr=1.1
        StyleDef=1.1
        StyleOff=1.1
        StyleActive="Chain"
        passives = list("Extend" = 1)
        StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Ittoryu_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Fist_of_Khonshu")
        Finisher="/obj/Skills/Queue/Finisher/Grand_Cross"
        verb/Chain_Style()
            set hidden=1
            src.Trigger(usr)