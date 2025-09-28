/obj/Skills/Buffs/SpecialBuff/Hellspawn/DemonicTakeOver
    adjust(mob/p)
        var/demonicInfluence = p.passive_handler.Get("DemonicInfluence")
        var/desperation = p.passive_handler.Get("Desperation")
        if(desperation<=0)
            desperation = 0.5
        passives = list("DemonicInfluence" -demonicInfluence, "HellPower" = demonicInfluence, "AngerAdaptiveForce" = desperation/10)