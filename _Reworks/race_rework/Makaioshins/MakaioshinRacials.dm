/obj/Skills/Buffs/SlotlessBuffs/Falldown_Mode/Makaioshin
	passives = list("HellPower" = 0.1, "AngerAdaptiveForce" = 0.25, "TechniqueMastery" = 2, "Juggernaut" = 0.5, "FakePeace" = -1)
	Cooldown = -1
	TimerLimit = 0
	BuffName = "Falldown Mode"
	name = "Falldown Mode"
	IconLock='GenesicR.dmi'
	IconLockBlend=BLEND_MULTIPLY
	LockX=-32
	LockY=-32
	HealthThreshold = 0.0001
	var/current_charges = 1
	var/last_charge_gain = 0
	var/list/trueFormPerAsc = list( 1 = list("AngerAdaptiveForce" = 0.1, "TechniqueMastery" = 2, "Juggernaut" = 1, "Hellrisen" = 0.25, , "FakePeace" = -1), \
									2 = list("AngerAdaptiveForce" = 0.2,"TechniqueMastery" = 3, "FluidForm" = 1, "Juggernaut" = 1.5, "Hellrisen" = 0.5, , "FakePeace" = -1), \
									3 = list("AngerAdaptiveForce" = 0.25,"TechniqueMastery" = 4, "FluidForm" = 1.5, "Juggernaut" = 2,"Hellrisen" = 0.5, , "FakePeace" = -1), \
									4 = list("AngerAdaptiveForce" = 0.5,"TechniqueMastery" = 6, "FluidForm" = 2, "Juggernaut" = 2,"Hellrisen" = 0.5, , "FakePeace" = -1))
	ActiveMessage = "has resolved their contradictory nature!"// Darkness and light, once wandering through creation, gather together and open the door to their truth! <b>Become as one, [usr.name] and [usr.TrueName]!</b></i>"

	adjust(mob/p)
		for(var/passive in trueFormPerAsc[p.AscensionsAcquired])
			passives[passive] = trueFormPerAsc[p.AscensionsAcquired][passive]
		var/hellpowerdif = 1 - p.passive_handler.Get("HellPower")
		if(hellpowerdif < 0)
			hellpowerdif = 0
		passives["HellPower"] = hellpowerdif
	verb/Falldown_Mode()
		set category = "Skills"
		if(!usr.BuffOn(src))
			if(current_charges - 1 < 0)
				usr << "You have ran out of true form charges..."
				return
			adjust(usr)
			var/yesno = input(usr, "Are you sure?") in list("Yes", "No")
			if(yesno == "Yes")
				current_charges--
				usr << "You have [current_charges] charges of true form left."
			else
				return 0
		ActiveMessage = "has resolved their contradictory nature! Darkness and light, once wandering through creation, gather together and open the door to  truth! <b>Become as one, [usr.name] and [usr.TrueName]!</b></i>"
		src.Trigger(usr)
/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles //weaker versions for Makaioshins and Celestials
	Selfless_State
		Copyable=0
		passives = list("Flow" = 1, "Deflection" = 1, "Soft Style" = 1)
		StyleSpd=1.15
		StyleDef=1.15
		BladeFisting=1
		SignatureTechnique=1
		StyleActive="Selfless State"
		verb/Selfless_State()
			set hidden=1
			src.Trigger(usr)
	Incomplete_Ultra_Instinct
		Copyable=0
		passives = list("Deflection" = 1, "Soft Style" = 1, "Flow" = 2, "Instinct" = 1, "CounterMaster" = 1)
		StyleSpd=1.25
		StyleOff=1.15
		StyleDef=1.25
		BladeFisting=1
		SignatureTechnique=2
		StyleActive="Ultra Instinct (In-Training)"
		verb/Incomplete_Ultra_Instinct()
			set hidden=1
			src.Trigger(usr)
	Ultra_Instinct
		Copyable=0
		passives = list("Deflection" = 1, "Soft Style" = 1, "Flow" = 2, "Instinct" = 2, "CounterMaster" = 2, "Godspeed" = 1)
		StyleSpd=1.3
		StyleOff=1.35
		StyleDef=1.35
		SignatureTechnique=3
		BladeFisting=1
		StyleActive="Ultra Instinct (Complete)"
		verb/Ultra_Instinct()
			set hidden=1
			src.Trigger(usr)
	Perfected_Ultra_Instinct
		Copyable=0
		passives = list("Deflection" = 1, "Soft Style" = 1, "LikeWater" = 4, "Flow" = 3, "Instinct" = 3, "CounterMaster" = 3, "Godspeed" = 1)
		StyleSpd=1.5
		StyleOff=1.5
		StyleDef=1.5
		SignatureTechnique=4
		BladeFisting=1
		StyleActive="Perfected Ultra Instinct"
		verb/Perfected_Ultra_Instinct()
			set hidden=1
			src.Trigger(usr)