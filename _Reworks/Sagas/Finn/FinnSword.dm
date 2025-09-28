/obj/Items/Sword/Medium/Legendary
    icon = 'LightSword.dmi'
    FinnSword
        name = "Scarlet"
        Ascended = 0
        ShatterMax=9000
        ShatterCounter=9000
        DamageEffectiveness = 1.1
        AccuracyEffectiveness = 0.7
        SpeedEffectiveness = 1
        Saga = "Hero"
        proc/Evolve(tier)
            switch(tier)
                if(3)
                    name = "Root Sword"
                    Ascended = 2
                    ShatterMax=9000
                    ShatterCounter=9000
                    DamageEffectiveness = 1.2
                    AccuracyEffectiveness = 0.8
                    SpeedEffectiveness = 1
                if(4)
                    name = "Demon Sword"
                    Ascended = 3
                    ShatterMax=9000
                    ShatterCounter=9000
                    DamageEffectiveness = 1.3
                    AccuracyEffectiveness = 0.9
                    SpeedEffectiveness = 1.1
                if(6)
                    name = "Grass Sword"
                    Ascended = 5
                    ShatterMax=9000
                    ShatterCounter=9000
                    DamageEffectiveness = 1.4
                    AccuracyEffectiveness = 1
                    SpeedEffectiveness = 1.2
                if(8)
                    name = "Finn Sword"
                    Ascended = 6
                    ShatterMax=9000
                    ShatterCounter=9000
                    DamageEffectiveness = 1.5
                    AccuracyEffectiveness = 1.1
                    SpeedEffectiveness = 1.3
            