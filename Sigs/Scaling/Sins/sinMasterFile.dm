/mob/Admin3/verb/Give_Sin()
    set category = "Admin"
    if(!src.Alert("Are you sure you want to give a Demon a Sin?")) return
    var/mob/P = Ask(src, "Give sin to who?", "", null, "pick", players, 0)
    if(!P.isRace(/race/demon))
        src << "<font color=red>[P] is not a Demon.</font>"
        return
    var/sinToGive = Ask(src, "What sin to give?", "", null, "pick", list("Gluttony", "Greed", "Lust", "Pride", "Sloth", "Wrath", "Envy"), 0)
    switch(sinToGive)
        if("Gluttony")
            P.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Sin/Gluttony)
            P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Sin/Gluttony/Digestion)
            P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Sin/Gluttony/Consumption)
            P.AddSkill(new/obj/Skills/AutoHit/Sin/Gluttony/Regurgitate)
            if(!P.majinAbsorb)
                P.AddSkill(new/obj/Skills/Absorb)