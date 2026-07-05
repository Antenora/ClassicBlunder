/obj/Skills/Buffs/NuStyle/MortalUI

	Mortal_Instinct_Style
		Copyable = 0
		NeedsSword=0
		NoSword=1
		StyleActive = "Mortal Instinct (Incomplete)"
		passives = list("Deflection" = 0.5, "SoftStyle" = 1, "Flow" = 1, "Instinct" = 0.5, "CounterMaster" = 0.25,"UnarmedDamage"=2)
		StyleSpd = 1.05
		StyleOff = 1.1
		StyleDef = 1.1
		IconLock='AuraMysticBig.dmi'
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SagaSignature = 1
		SignatureTechnique = 1
		verb/Incomplete_Mortal_Ultra_Instinct()
			set hidden = 1
			src.Trigger(usr)

	Incomplete_Ultra_Instinct_Style
		Copyable=0
		NeedsSword=0
		NoSword=1
		StyleActive="Mortal Ultra Instinct (In-Training)"
		passives = list("Deflection" = 1, "SoftStyle" = 1, "Flow" = 3, "Instinct" = 1, "CounterMaster" = 1,"UnarmedDamage"=3)
		StyleSpd=1.25
		StyleOff=1.15
		StyleDef=1.25
		IconLock='AuraMysticBig.dmi'
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SagaSignature = 1
		SignatureTechnique = 2
		adjust(mob/p)
			if(p.isRace(CELESTIAL))
				StyleStr=1.15
				StyleFor=1.15
				StyleSpd=1.45
				StyleOff=1.45
				StyleDef=1.45
				passives = list("Deflection" = 1, "SoftStyle" = 1, "Flow" = 3, "Instinct" = 1, "CounterMaster" = 1,"UnarmedDamage"=3)
		verb/Incomplete_Ultra_Instinct()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)

	Ultra_Instinct_Style
		Copyable = 0
		NeedsSword=0
		NoSword=1
		StyleActive = "Mortal Ultra Instinct"
		passives = list("Deflection" = 1, "SoftStyle" = 1, "Flow" = 2, "Instinct" = 2, "CounterMaster" = 2, "Godspeed" = 1,"UnarmedDamage"=4)
		StyleSpd = 1.5
		StyleOff = 1.5
		StyleDef = 1.5
		IconLock='GentleDivine.dmi'
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SagaSignature = 1
		SignatureTechnique = 3
		adjust(mob/p)
			if(p.isRace(CELESTIAL))
				StyleStr=1.35
				StyleFor=1.35
				StyleSpd=1.75
				StyleOff=1.75
				StyleDef=1.75
				passives = list("Deflection" = 1, "SoftStyle" = 1, "Flow" = 3, "Instinct" = 1, "CounterMaster" = 1,"UnarmedDamage"=4)
		verb/Mortal_Ultra_Instinct()
			set hidden = 1
			adjust(usr)
			src.Trigger(usr)

	Perfected_Ultra_Instinct_Style
		Copyable = 0
		NeedsSword=0
		NoSword=1
		StyleActive = "Perfected Ultra Instinct"
		passives = list("LikeWater" = 3, "Flow" = 3, "Instinct" = 3, "CounterMaster" = 3, "Godspeed" = 1, "PUSpike" = 25,"UnarmedDamage"=5, "SoftStyle" = 1,"Deflection" = 1)
		StyleSpd = 1.6
		StyleOff = 1.55
		StyleDef = 1.6
		IconLock='GentleDivine.dmi'
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SagaSignature = 1
		SignatureTechnique = 4
		PUSpike = 25
		adjust(mob/p)
			if(p.isRace(CELESTIAL))
				StyleStr = 1.45
				StyleFor = 1.45
				StyleSpd = 2
				StyleOff = 2
				StyleDef = 2
				passives = list("Deflection" = 1, "SoftStyle" = 1, "Flow" = 3, "Instinct" = 1, "CounterMaster" = 1,"UnarmedDamage"=5)
		verb/Perfected_Mortal_Ultra_Instinct()
			set hidden = 1
			adjust(usr)
			src.Trigger(usr)
