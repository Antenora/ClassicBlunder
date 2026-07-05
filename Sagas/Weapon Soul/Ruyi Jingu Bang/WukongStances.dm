

/obj/Skills/Buffs/SlotlessBuffs
    Dadao
        Pursuer = 1
        NoWhiff = 1
        Cooldown = 5
        PowerPole = 1
        ActiveMessage = "swings their staff around, entering the Dadao stance!"
        proc/init(mob/p)
            if(altered) return
            var/sLevel = p.SagaLevel
            passives = list("Pursuer" = sLevel, "NoWhiff" = 1, "PowerPole" = sLevel)
            NoWhiff = 1
        verb/Dadao_Stance()
            set category = "Skills"
            set name = "Dadao Stance"
            init(usr)
            if(usr.CheckSlotless("Huadong"))
                ActiveMessage = "quickly swaps to the Dadao stance!"
                var/obj/Skills/Buffs/SlotlessBuffs/s = usr.CheckSlotless("Huadong")
                if(usr.BuffOn(s))
                    s.Trigger(usr, 1)
                sleep(2)
            src.Trigger(usr)
    Huadong
        HardStyle = 1
        GiantSwings = 1
        Cooldown = 5
        ActiveMessage = "swings their staff around, entering the Huadong stance!"
        proc/init(mob/p)
            if(altered) return
            var/sLevel = p.SagaLevel
            passives = list("HardStyle" = sLevel, "Crushing" = sLevel*2, "GiantSwings" = clamp(sLevel,2,6), "Brutalize" = 0.05 * sLevel)
        verb/Huadong_Stance()
            set category = "Skills"
            set name = "Huadong Stance"
            init(usr)
            if(usr.CheckSlotless("Dadao"))
                ActiveMessage = "quickly swaps to the Huadong stance!"
                var/obj/Skills/Buffs/SlotlessBuffs/s = usr.CheckSlotless("Dadao")
                if(usr.BuffOn(s))
                    s.Trigger(usr, 1)
                sleep(2)
            src.Trigger(usr)