/obj/Skills/Buffs/SlotlessBuffs/True_Form/Demon
	passives = list("HellPower" = 0.1, "AngerAdaptiveForce" = 0.25, "TechniqueMastery" = 2, "Juggernaut" = 0.5, "FakePeace" = -1)
	Cooldown = -1
	TimerLimit = 0
	BuffName = "True Form"
	name = "True Form - Demon"
	IconLock='GenesicR.dmi'
	IconLockBlend=BLEND_MULTIPLY
	LockX=-32
	LockY=-32
	HealthThreshold = 0.0001
	var/current_charges = 1
	var/last_charge_gain = 0
	var/list/trueFormPerAsc = list( 1 = list("AngerAdaptiveForce" = 0.1, "TechniqueMastery" = 2, "Juggernaut" = 1, "Hellrisen" = 0.25, , "FakePeace" = -1), \
									2 = list("AngerAdaptiveForce" = 0.2,"TechniqueMastery" = 3, "FluidForm" = 1, "GiantForm" = 1, "Juggernaut" = 1.5, "Hellrisen" = 0.5, , "FakePeace" = -1), \
									3 = list("AngerAdaptiveForce" = 0.25,"TechniqueMastery" = 4, "FluidForm" = 1.5, "GiantForm" = 1, "Juggernaut" = 2,"Hellrisen" = 0.5, , "FakePeace" = -1), \
									4 = list("AngerAdaptiveForce" = 0.5,"TechniqueMastery" = 6, "FluidForm" = 2, "GiantForm" = 1, "Juggernaut" = 2,"Hellrisen" = 0.5, , "FakePeace" = -1))
	ActiveMessage = "<i>has unleashed their true nature!</i>"
	// jsut set the niggas hellpower to 1
	adjust(mob/p)
		for(var/passive in trueFormPerAsc[p.AscensionsAcquired])
			passives[passive] = trueFormPerAsc[p.AscensionsAcquired][passive]
		var/hellpowerdif = 1 - p.passive_handler.Get("HellPower")
		if(hellpowerdif < 0)
			hellpowerdif = 0
		passives["HellPower"] = hellpowerdif
	verb/True_Form()
		set category = "Skills"
		if(!usr.BuffOn(src))
			if(current_charges - 1 < 0)
				usr << "You have ran out of true form charges..."
				return
			adjust(usr)
			var/yesno = input(usr, "Are you sure?") in list("Yes", "No")
			if(yesno == "Yes")
				if(glob.racials.REVEALDEMONONTRUEFORM)
					OMsg(usr, "<b>[usr] has revealed their true nature as a <i>[glob.racials.DEMON_NAME]</i></b>")
				current_charges--
				usr << "You have [current_charges] charges of true form left."
			else
				return 0
		src.Trigger(usr)