mob/var
	Will = 100 				// Morale Mechanic
	WillBase = 100			// Default Will you start at on med/at chargen
	WillMax = 150			// How much your Will cap out to.
	SpiritMax				// How many Spirit Points you get from Meditation
	Spirit					// Current Spirit
	WillUnlocked			// can force unlock it with specific methods like Inspired Evolution. Usually doesn't provide Spirit Commands though

mob/proc/GrantWillMechanic() // Use this to give someone access to the mechanic!
	if(WillUnlocked) return
	src << "Suddenly, beyond simple anger, your Fighting Spirit flares up-- You have unlocked the Will Gauge!"
	src << "Raise your Will by battling. Higher Will increases your stats, but going below 100 lowers them instead!"
	WillUnlocked = TRUE
	SpiritMax=15
	Spirit=15
	GrantRandomSpiritCommand(1)
	client.updateWillMeter()


mob/proc/GrantRandomSpiritCommand(tier) // commands can be randomly obtained this way
	var/list/commands
	switch(tier)
		if(1)
			commands = TIER1SPIRIT
		if(2)
			commands = TIER2SPIRIT
		if(3)
			commands = TIER3SPIRIT
		else
			return FALSE
	var/list/paths = list(
		"Focus" = /obj/Skills/Buffs/SpiritCommands/Focus,
		"Accel" = /obj/Skills/Buffs/SpiritCommands/Accel,
		"Spirit" = /obj/Skills/Buffs/SpiritCommands/Instant/Spirit,
		"Drive" = /obj/Skills/Buffs/SpiritCommands/Instant/Drive,
		"Valor" = /obj/Skills/Buffs/SpiritCommands/Instant/Valor,
		"Bullseye" = /obj/Skills/Buffs/SpiritCommands/Instant/Bullseye,
		"Soul" = /obj/Skills/Buffs/SpiritCommands/Instant/Soul,
		"Flash" = /obj/Skills/Buffs/SpiritCommands/Instant/Flash,
		"Persist" = /obj/Skills/Buffs/SpiritCommands/Instant/Persist
	)

	var/list/available = list()
	for(var/command in commands)
		var/skill_path = paths[command]
		if(skill_path && !src.FindSkill(skill_path))
			available += command
	if(!available.len)
		src << "You already know every tier [tier] Spirit Command."
		return FALSE
	var/command = pick(available)
	src.findOrAddSkill(paths[command])
	src << "You have learned the Spirit Command: [command]!"
	return TRUE


mob/proc/WillPowered()
	if(WillUnlocked)
		return TRUE
	else
		return FALSE

mob/proc/WillMaxCapacity()
	var/extraS = min(max(secretDatum.currentTier, 0), 5)
	var/extraSaga = min(max(SagaLevel, 0), 7)

	var/limit = passive_handler.Get("WillLimitBreak")
	var/ExpectedMaxWill = 150 + (limit*10) + (extraS*7) + (extraSaga*5) // General max intended would be 180, or 220 for real Simonheads. (+3 WillLimitBreak or +7.) (+7 for every Spiral tier, +5 for every KoB tier.)
	return ExpectedMaxWill

mob/proc/UpgradeMaxSpirit() // Upgrades your current Maximum Spirit Points count
	var/base = 15
	var/pot = min(max(Potential, 0), 80) / 80 * 40 // Will mechanic is only accessible with a saga or secret normally lmao. Maybe a Signature later on?
	var/secret = 0
	var/saga = 0
	if(Secret == "Spiral")
		secret = min(max(secretDatum.currentTier, 0), 5) / 5 * 25
	if(Saga == "King of Braves")
		saga = min(max(SagaLevel, 0), 7) / 7 * 25
	return min(80, round(base + pot + max(secret, saga)))


mob/proc/ClearSpiritCommands()
	// turns off spirit commands
	for(var/obj/Skills/Buffs/SpiritCommands/S in contents.Copy())
		if(istype(S, /obj/Skills/Buffs/SpiritCommands/Instant))
			continue
		if(src.BuffOn(S))
			S.Trigger(src, 1)

	SpiritNextDamageMult = 0
	SpiritDamageBoostUntil = 0

	SpiritPersistReady = FALSE
	SpiritPersistUntil = 0

	SpiritFlashReady = FALSE
	SpiritFlashUntil = 0

	SpiritBullseyeReady = FALSE
	SpiritBullseyeUntil = 0


mob/proc/WillMeditateCheck()
	if(!WillPowered()) return
	if(MeditateTime < 15) return

	if(Will != WillBase)
		Will = WillBase
		src << "Your Will is back to normal."

	var/new_max = UpgradeMaxSpirit()
	if(SpiritMax < new_max)
		SpiritMax = new_max
		src << "Your maximum amount of Spirit Points has increased!"

	if(SpiritMax && Spirit != SpiritMax)
		Spirit = SpiritMax
		src << "Your Spirit Points have been restored."
	if(client)
		client.updateWillMeter()


mob/proc/AdjustWill(val)
	var/cap = WillMax
	var/cur = Will
	var/min = 50
	if(!val) return
	if(cur >= cap && val > 0) return
	if(cur <= min && val < 0) return

	val = round(val, 0.1)

	Will = clamp(Will+val, min, cap)

	client.updateWillMeter()

mob/proc/GetWillStatMult()
	if(!WillPowered()) return 0
	return (Will - 100) * (1.3 / 80) // +0.8 at 150, +1.3 at 180, +1.95 at 220

mob/GainLoop()
	set waitfor = 0
	if(client)
		if(WillPowered())
			if (WillMax != WillMaxCapacity())
				WillMax = WillMaxCapacity()
			if(Will > WillMax)
				Will = WillMax
			if(Will < 50)
				Will = 50
	return ..()


/strikeHook/willPoweredAttacker
	stage = "post"
	fire(strike/S)
		if(!S || !S.attacker || !S.defender || S.dealt <= 0) return
		if(S.didCrit) return
		var/mob/attacker = S.attacker
		var/val = S.defender.HPToPct(S.dealt)
		if(attacker.WillPowered())
			var/meterGain = min(max(val,0.1), 1)

			meterGain = round(meterGain, 0.1)

			attacker.AdjustWill(meterGain)

/strikeHook/willPoweredAttackerCrit
	stage = "crit"
	fire(strike/S)
		if(!S || !S.attacker || !S.defender || S.dealt <= 0) return
		var/mob/attacker = S.attacker
		var/val = S.defender.HPToPct(S.dealt)
		if(attacker.WillPowered())
			var/meterGain = min(max(val,0.2), 2)

			meterGain = round(meterGain, 0.1)

			attacker.AdjustWill(meterGain)


/strikeHook/willPoweredDefender
	stage = "post"
	fire(strike/S)
		if(!S || !S.defender || S.dealt <= 0) return
		if(S.didCrit) return
		var/mob/defender = S.defender
		var/val = S.defender.HPToPct(S.dealt)
		if(defender.WillPowered())
			var/meterGain = min(max(val,0.5), 1)

			meterGain = round(meterGain, 0.1)

			defender.AdjustWill(meterGain)


/strikeHook/willPoweredDefenderCrit // lose Will if you get hit by a crit
	stage = "crit"
	fire(strike/S)
		if(!S || !S.defender || S.dealt <= 0) return
		var/mob/defender = S.defender
		var/val = S.defender.HPToPct(S.dealt)
		if(defender.WillPowered())
			var/meterGain = min(max(val,0.5), 3)

			meterGain = round(meterGain, 0.1)
			meterGain = -abs(meterGain)

			defender.AdjustWill(meterGain)



//Debug Admin Commands
mob/Admin3/verb/Grant_Will_Mechanic()
	set category = "Debug"
	set name = "Grant Will Mechanic"
	if(!src.Admin) return
	var/list/players = list()
	for(var/mob/M in world)
		if(M.client)
			players += M
	var/mob/target = Ask(src, "Who should unlock the Will mechanic?", "Grant Will Mechanic", kind = "pick", choices = players, nullable = 1)
	if(!target) return
	if(target.WillUnlocked)
		src << "[target] already has the Will mechanic."
		return
	target.GrantWillMechanic()
	if(target.client)
		target.client.updateWillMeter()
	src << "Granted [target] the Will mechanic and a random tier 1 Spirit Command."


mob/Admin3/verb/Grant_Random_Spirit_Command()
	set category = "Debug"
	set name = "Grant Random Spirit Command"
	if(!src.Admin) return
	var/list/players = list()
	for(var/mob/M in world)
		if(M.client)
			players += M
	var/mob/target = Ask(src, "Who should receive a Spirit Command?", "Grant Spirit Command", kind = "pick", choices = players, nullable = 1)
	if(!target) return
	var/tier = Ask(src, "Which tier?", "Spirit Command Tier", kind = "pick", choices = list(1, 2, 3), nullable = 1)
	if(!tier || !target) return
	if(target.GrantRandomSpiritCommand(tier))
		src << "Granted [target] a random tier [tier] Spirit Command."
	else
		src << "[target] already knows every tier [tier] Spirit Command."