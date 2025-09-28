/*

shar, mange and rinnegan all stack atop of each other, keep that in mind!!!

*/

/obj/Skills/Buffs/var/DevaPull // for deva path, pull people in instead of warping to them

/mob/var/devaCounter = 0

/mob/proc/findRinne()
    if(Saga != "Sharingan") return
    return GetSlotless("Rinnegan")


/obj/Skills/Buffs/SlotlessBuffs/Rinnegan
    SBuffNeeded = "Sharingan"
    Cooldown = -1
    SeeInvisible = 20
    Void = 1
    BuffMastery = 3
    IconLock='RinneganEyes.dmi'
    BuffTechniques=list("/obj/Skills/Six_Paths_of_Pain")
    ActiveMessage="ascends into enlightment as their eyes perceive all six paths of Samsara!"
    OffMessage="closes their eyes to the truth of the world..."
    verb/Rinnegan()
        set category="Skills"
        resetToDefault(usr)
        adjust(usr)
        src.Trigger(usr)
    // idk wound drain was here
    var/activePath = "Deva"


    proc/resetToDefault()
        //asura
        Mechanized = 0
        HybridStrike = 0
        StrMult = 1
        EndMult = 1
        OffMult = 1
        DefMult = 1
        DoubleStrike = 0
        TripleStrike = 0
        // Human
        StealsStats = 0
        Erosion = 0
        LifeSteal = 0
        // Preta
        BulletKill = 0
        EnergySteal = 0
        ManaSteal = 0
        ElementalDefense = "None"
        // Deva
        DevaPull = 0
        NoWhiff = 0



    adjust(mob/p)
        // they r just sagalevel 8
        var/pot = p.Potential
        GodKi = p / 100
        switch(activePath)
            if("Asura")
                // mechanical
                Mechanized=1
                HybridStrike = pot / 20 // double dmg at 100 pot
                SpiritHand = pot / 25 // Str + For at 100 pot
                ForMult = 1.3
                OffMult = 1.2
                EndMult = 1.3
                DoubleStrike = 2
                TripleStrike = 1
            if("Human")
                StealsStats = pot / 20
                ElementalOffense = "Void"
                Erosion = pot / 50
                LifeSteal = pot

            if("Preta")
                BulletKill = 1
                EnergySteal = pot
                ManaSteal = pot
                ElementalDefense = "Void"
                EndMult = 1.4
            if("Deva")
                // should be main fighting vs asura tbh
                // maybe mechanic that pulls people in instead of warping to them (reverse iaido)
                DevaPull = 1
                StrMult = 1.4
                EndMult = 1.4
                OffMult = 1.1
                DefMult = 1.1
                NoWhiff = 1
                NoMiss = 1

    proc/swapPath(path, mob/p)
        activePath = path
        Trigger(p, Override = 1)
        adjust(p)
        sleep(1)
        Trigger(p, Override = 1)








/*

Sharingan
			OffMult=1.2
			DefMult=1.3
			Maki = 1
			CalmAnger = 1
			PUSpike=10
					if(usr.SagaLevel>=3)
						if(usr.SharinganEvolution=="Resolve")
							OffMult=1.4
							DefMult=1.4
							SureDodgeTimerLimit=15
							LikeWater=2
							Instinct=2
							Flow=2
							FluidForm=1
							PUSpike=25
						else
							src.OffMult=1.3
							src.DefMult=1.3
							src.SureDodgeTimerLimit=20
							src.Instinct=2
							src.Flow=2
							src.FluidForm=1
							src.FatigueDrain=0


Mangekyou_Sharingan
			TaxThreshold=0.2
			OffTaxDrain=0.0003
			DefTaxDrain=0.0003
			SBuffNeeded="Sharingan"
			BuffMastery=5
			Cooldown=-1
			Deflection=1
			Flow=1
			ActiveMessage="gives into hatred; their tomoe twist into a kaleidoscope pattern!"
			OffMessage="closes their eyes with a pained look..."
			verb/Mangekyou_Sharingan()
				set category="Skills"
							src.Instinct=1
						if("Resolve")
							src.LikeWater=usr.SagaLevel / 2
							src.Flow=2
							src.Instinct=2
							src.Deflection= 1 + usr.SagaLevel / 4
							src.Duelist=1
							Godspeed= usr.SagaLevel / 4
				src.Trigger(usr)
		Rinnegan
			SBuffNeeded="Sharingan"
			WoundDrain=0.05
			GodKi=0.5
			Cooldown=-1
			IconLock='RinneganEyes.dmi'
			BuffTechniques=list("/obj/Skills/Six_Paths_of_Pain")
			ActiveMessage="ascends into enlightment as their eyes perceive all six paths of Samsara!"
			OffMessage="closes their eyes to the truth of the world..."
			verb/Rinnegan()
				set category="Skills"
				src.Trigger(usr)

                */