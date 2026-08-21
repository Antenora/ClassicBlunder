/obj/Skills/Buffs/SlotlessBuffs/True_Form/Demon
	passives = list("HellPower" = 0.1,  "TechniqueMastery" = 2, "Juggernaut" = 0.5, "FakePeace" = -1)
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
/*	var/list/trueFormPerAsc = list( 1 = alist( "TechniqueMastery" = 2, "Juggernaut" = 1, "Hellrisen" = 0.25, , "FakePeace" = -1), \
									2 = alist("TechniqueMastery" = 3, "FluidForm" = 1, "GiantForm" = 1, "Juggernaut" = 1.5, "Hellrisen" = 0.5, , "FakePeace" = -1), \
									3 = alist("TechniqueMastery" = 4, "FluidForm" = 1.5, "GiantForm" = 1, "Juggernaut" = 2,"Hellrisen" = 0.5, , "FakePeace" = -1), \
									4 = alist("TechniqueMastery" = 6, "FluidForm" = 2, "GiantForm" = 1, "Juggernaut" = 2,"Hellrisen" = 0.5, , "FakePeace" = -1))*/
	ActiveMessage = "<i>has unleashed their true nature!</i>"
	// jsut set the niggas hellpower to 1
	adjust(mob/p)
		if(p.AscensionsAcquired==1)
			passives =list( "TechniqueMastery" = 2, "Juggernaut" = 1, "HellRisen" = 0.25, , "FakePeace" = -1)
		if(p.AscensionsAcquired==2)
			passives = list("TechniqueMastery" = 3, "Juggernaut" = 1.5, "HellRisen" = 0.5, , "FakePeace" = -1)
		if(p.AscensionsAcquired==3)
			passives = list("TechniqueMastery" = 4, "Juggernaut" = 2,"HellRisen" = 0.5, , "FakePeace" = -1)
		if(p.AscensionsAcquired==4)
			passives = list("TechniqueMastery" = 6, "Juggernaut" = 2,"HellRisen" = 0.5, , "FakePeace" = -1)
		var/hellpowerdif = 1 - p.passive_handler.Get("HellPower")
		if(hellpowerdif < 0)
			hellpowerdif = 0
		passives["HellPower"] = hellpowerdif
	verb/True_Form()
		set category = "Skills"
		adjust(usr)
		if(!usr.BuffOn(src))
			if(current_charges - 1 < 0)
				usr << "You have ran out of true form charges..."
				return
			adjust(usr)
			var/yesno = input(usr, "Are you sure?") in list("Yes", "No")
			if(yesno == "Yes")
				current_charges--
				usr << "You have [current_charges] charges of true form left."
				var/obj/Skills/Buffs/SlotlessBuffs/Racial/Demon/Disguise/D = locate() in usr
				if(D && usr.BuffOn(D))
					D.Trigger(usr, TRUE)
					usr << "<i>Your True Form shatters your disguise.</i>"
			else
				return 0
		src.Trigger(usr)

//Sloth AOE

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sloth_Factor
	name = "Sloth Factor"
	BuffName = "Sloth Factor"
	Cooldown = -1
	var/DamageMult = 30
	StrScaling = 1
	ForScaling = 1
	var/tmp/waveLoopRunning = FALSE

	Trigger(mob/User, Override = FALSE)
		var/wasOn = SlotlessOn
		. = ..()
		if(!wasOn && SlotlessOn && !waveLoopRunning)
			startWaveLoop(User)

	proc/startWaveLoop(mob/User)
		set waitfor = FALSE
		waveLoopRunning = TRUE
		while(SlotlessOn && User)
			spawnWave(User)
			sleep(100)
		waveLoopRunning = FALSE

	proc/spawnWave(mob/User)
		if(!User || !User.loc) return
		if(User.PureRPMode) return
		if(!User.demonDevilTriggerSinMastery()) return
		var/obj/Effects/SkillWave/S = new(User.loc)
		S.owner = User
		S.icon = 'KenShockwaveBloodlust.dmi'
		S.wave_lifetime = 30
		S.rampUp = 1
		S.meleeExclusion = 1
		S.DamageMult = DamageMult
		S.StrScaling = StrScaling
		S.ForScaling = ForScaling
		S.UsesStr = UsesStr
		S.UsesFor = UsesFor
		S.UsesSpd = UsesSpd
		S.UsesEnd = UsesEnd
		S.UsesDef = UsesDef
		S.UsesOff = UsesOff
