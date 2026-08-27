/obj/Skills/Buffs/Ki_Control/Cursed_Energy
	BuffName = "Cursed Energy"
    passives = list("KiControl" = 1,    "ManaGeneration" =1. "[selectedPassive]" = 1, "EnergyLeak" = 1)
    ActiveMessage = "enhances their body with Cursed Energy!"
    OffMessage = "loosens the control on their Cursed Energy."
    adjust(mob/P)
        passives["[selectedPassive]"] = 1
        passives["SpiritPower"] = 0.25 * P.SagaLevel
        passives["ManaGeneration"] = 1
        passives["EnergyLeak"] = 1
    init(mob/p)
        if(altered) return
        if(selectedPassive == "None")
            p.PoweredFormSetup()
        vars["[selectedStats[1]]Mult"] = 1.3
        vars["[selectedStats[2]]Mult"] = 1.3
        vars["[selectedStats[3]]Mult"] = 1.3
    Trigger(mob/P, Override = FALSE)
        init(P)
        if(!P.BuffOn(src))
            adjust(P)
        ..()


