
mob/proc/getExtraVoidChance(extraChance = 0)
	var/Chance = 0
	if(Saga == "King of Braves")
		Chance += SagaLevel * 1.5
	if(ClothBronze == "Phoenix")
		Chance += SagaLevel * 2
	return Chance

mob/proc/getVoidRolls(extraRolls = 0)
	var/rolls = 1 + extraRolls
	if(Saga == "King of Braves")
		rolls += 1
	if(ClothBronze == "Phoenix")
		if(totalExtraVoidRolls >= 1)
			rolls += totalExtraVoidRolls
			totalExtraVoidRolls--
	return rolls

mob/proc/RollVoidForAbsorb()
	if(NoVoid) return FALSE
	if(!glob.VoidsAllowed) return FALSE
	var/Chance = getExtraVoidChance()
	var/rolls = getVoidRolls()
	while(rolls > 0)
		var/roll = rand(Chance, 100)
		if(roll >= 100-glob.VoidChance)
			return TRUE
		rolls--
	return FALSE

/mob/Admin3/verb/AdminVoid()
	set category = "Admin"
	set name = "Void"
	var/list/actions = list(
		"Admin-kill with free void",
		"Change target's extra void chance"
	)
	if(usr.Admin >= 4)
		actions += list(
			"Toggle target's NoVoid flag (Owner)",
			"Set global void chance (Owner)",
			"Toggle voids allowed (Owner)",
			"Change void location (Owner)"
		)
	actions += "Cancel"
	var/choice = input(usr, "Void action:", "Void") as null|anything in actions
	if(!choice || choice == "Cancel") return
	switch(choice)
		if("Admin-kill with free void")
			var/mob/A = input(usr, "Auto-void-kill whom?", "Void") in players
			if(!A) return
			A.Death(null, "ADMIN", 0, 0, 0, 0, 1)
			Log("Admin", "<font color=red>[ExtractInfo(usr)] admin-killed [ExtractInfo(A)] (Free Void)")
		if("Change target's extra void chance")
			var/mob/A = input(usr, "Change whose void chance?", "Void") in players
			if(!A) return
			A.extraVoidChance = input("How much extra void chance do you want to give [ExtractInfo(A)]? (0-100)", A.extraVoidChance, 0, 100) as num
			Log("Admin", "<font color=red>[ExtractInfo(usr)] changed [ExtractInfo(A)]'s void chance to [A.extraVoidChance]")
		if("Toggle target's NoVoid flag (Owner)")
			if(usr.Admin < 4) return
			var/mob/m = input(usr, "Toggle NoVoid on whom?", "Void") in players
			if(!m) return
			if(m.NoVoid)
				m.NoVoid = 0
				usr << "You let [m] void again..."
			else
				m.NoVoid = 1
				usr << "[m] is not gonna void anymore."
		if("Set global void chance (Owner)")
			if(usr.Admin < 4) return
			var/m = input(src, "What do you want to set Void Chance to? (currently [glob.VoidChance]%)", "Void Chance") as num
			glob.VoidChance = m
			world << "<font color='green'>Void Chance set to [m]%!</font color>"
			Log("Admin", "[ExtractInfo(src)] set Void Chance to [m]%!")
		if("Toggle voids allowed (Owner)")
			if(usr.Admin < 4) return
			if(glob.VoidsAllowed)
				glob.VoidsAllowed = 0
				world << "<font color='red'>Voiding from death has been disabled.</font>"
			else
				glob.VoidsAllowed = 1
				world << "<font color='green'>Voiding from death has been enabled.</font>"
		if("Change void location (Owner)")
			if(usr.Admin < 4) return
			var/x = input(usr, "X for void?") as num|null
			var/y = input(usr, "Y for void?") as num|null
			var/z = input(usr, "Z for void?") as num|null
			if(!x || !y || !z) return
			glob.VOID_LOCATION = list(x, y, z)
			glob.currentlyVoidingLoc = list(x, y, z)
/mob/var/extraVoidChance = 0

/mob/proc/applyVoidNerf()
	if(src.passive_handler.Get("Undying"))
		return
	if(glob.VoidMaim||!src)
		Maimed++
		recordMaim(null, "Survived Void")
		src << "After managing to survive, you're left with a maim."
	if(glob.VoidCut)
		var/highestStat = 0
		var/highestStatName = ""
		for(var/i in 1 to 5)
			if(BaseStr() > highestStat)
				highestStat = GetStr()
				highestStatName = "Str"
			if(BaseEnd() > highestStat)
				highestStat = GetEnd()
				highestStatName = "End"
			if(BaseFor() > highestStat)
				highestStat = GetFor()
				highestStatName = "For"
			if(BaseDef() > highestStat)
				highestStat = GetDef()
				highestStatName = "Def"
			if(BaseOff() > highestStat)
				highestStat = GetOff()
				highestStatName = "Off"
		var/statCutAmount = clamp(0, glob.VoidCut / 100, 1)
		vars["[highestStatName]Cut"] += statCutAmount
		src<<"After managing to survive, you are left with a permanent injury. Your [highestStatName] is cut by [statCutAmount]%."



particles/confetti
	width = 126
	height = 126
	count = 75
	spawning = 25
	bound1 = list(-256, -256, -256)
	lifespan = 30
	fade = 15
	position = generator("box", list(-1,1,0), list(1,1,1))
	velocity = list(generator("sphere", -1, 1), generator("sphere", 1, 4), generator("sphere", -1, 1))
	rotation = generator("sphere", 0, 360)
	spin = 30
	scale = generator("num", 2,4)
	gradient = list(0, "#f00", 1, "#ff0", 2, "#0f0", 3, "#0ff", 4, "#00f", 5, "#f0f", 6, "#f00", "loop")
	color_change = 0.1
	gravity = list(0, -0.01)
	friction = generator("sphere", 0.01, 0.3)
	drift = generator("sphere", 0, 2)
obj/confetti
	layer = FLY_LAYER
	particles = new/particles/confetti

proc/PinataExplosion(atom/movable/source)
	set waitfor = 0
	var/obj/confetti/c  = new()
	source.vis_contents += c
	sleep(30) //TODO REPLACE THIS WITH A LOOp
	source.vis_contents -= c
	c.loc = null

/mob/var/void_timer = 0
/mob/var/voiding = FALSE
mob/proc/StartFresh()
	Burn = 0
	Poison = 0
	Slow = 0
	Shatter = 0
	Sheared = 0
	TotalFatigue = 0
	TotalCapacity = 0
	TotalInjury = 0
	InjuryAnnounce = 0

/mob/proc/makeCorpse(oldLoc)
	Stunned = 0
	if(src.passive_handler.Get("Undying")||glob.VoidChance>=90)
		return
	var/mob/Body/corpse = new()
	corpse.race = new/race/human()
	corpse.appearance = appearance
	corpse.transform = matrix(-90, MATRIX_ROTATE)
	corpse.overlays += icon('Injured Blood.dmi')
	corpse.overlays += icon('EyesDragon.dmi') // this is to stop blinking and give a more 'dead eye' look.
	corpse.name = "Corpse of [src]"
	corpse.loc = oldLoc
/*	PinataExplosion(corpse)
	OMsg(src, "[src]'s body explodes into a shower of confetti and loot!")*/
	corpse.Body = Body
	corpse.EnergyMax=src.EnergyMax
	corpse.Energy=src.Energy
	corpse.Power=src.Power
	corpse.StrMod=src.GetStr()
	corpse.EndMod=src.GetEnd()
	corpse.ForMod=src.GetFor()
	corpse.DeathKillerTargets=src.key//used for Death Killer
	corpse.Savable=1
	var/list/lootTable = list()
	for(var/obj/Items/I in src)
		if(istype(I, /obj/Items/Magatama))
			continue
		if(I.suffix == "*Equipped*")
			I.ObjectUse(src)
		if(I.Stealable)
			lootTable+=I
		I.loc = corpse

	for(var/x in 1 to rand(1,4))
		if(lootTable.len == 0)
			break
		if(lootTable)
			var/obj/Items/I = lootTable[rand(1,lootTable.len)]
			lootTable-=I
			I.Move(corpse)
			corpse.contents+=I
	for(var/obj/Money/cash in src)
		var/randDivisor = rand(1,3)
		if(cash.Level)
			var/obj/Money/newcash = new(corpse.loc)
			newcash.Level=(cash.Level-1)/randDivisor
			newcash.name = "[Commas(round(newcash.Level))] [glob.progress.MoneyName]"
			src.TakeMoney(newcash.Level)
	var/totalMineralValue = 0
	for(var/obj/Items/mineral/m in src)
		totalMineralValue += m.value
		del(m)
	if(totalMineralValue)
		var/obj/Items/mineral/m = new(corpse.loc)
		m.value = totalMineralValue
		m.name = "[Commas(round(m.value))] Mana Bits"
		m.assignState()
	overlays -= 'Halo.dmi'

/mob/var/totalExtraVoidRolls = 0
#define SPIRITS_NAMES list("Goetic Virtue", "Stellar Constellation", "Elven Sanctuary")

mob/proc/Void(override, zombie, forceVoid, extraChance = 0, extraRolls = 0)
	var/actuallyDead
	var/Chance = getExtraVoidChance(extraChance)
	if(forceVoid) Chance = 100
	var/rolls = getVoidRolls(extraRolls)
	var/oldLoc = loc
	if(Chance >= 100)
		Chance = 100
	if(override)
		Chance = 0

	if(secretDatum && secretDatum.name in SPIRITS_NAMES)
		extraChance -= Potential/4 + (secretDatum.currentTier * 5)
		src<<"You have [extraChance] reduced void chance from your REDACTED" //TODO: leaving as a note to change if needed

	// handle the rolling here maybe
	var/NotYet=0
	if(src.passive_handler.Get("Undying")||src.passive_handler.Get("Reflected"))
		NotYet=1
	if(override&&!NotYet)
		if(zombie)
			actuallyDead = 0
			src<<"You get past it all"
			OMessage(0,"","<font color=red>[src] is zombie'd out")
			//OMSg(src, "[src] stands right back up, as if nothing happened.")
			return
		else
			actuallyDead = 1
			new/obj/readPrayers(src)
			if(NoSoul)
				src<<"You feel your life flash before your eyes, and then in an abrupt snap -- nothingness."
				if(istype(src, /mob/Players/))
					ArchiveSave(src)
				src.loc=locate(glob.NO_SOUL_LOCATION[1], glob.NO_SOUL_LOCATION[2], glob.NO_SOUL_LOCATION[3])
				makeCorpse(oldLoc)
				sleep(10)
				overlays += 'halo.dmi'
			else
				src<<"You sustain the injuries detailed in your death -- as the pain fades, you awaken in the afterlife. Alone, but not for long."
				src.loc=locate(glob.DEATH_LOCATION[1], glob.DEATH_LOCATION[2], glob.DEATH_LOCATION[3])
				if(src.isRace(DEMON)||src.isRace(ELDRITCH)||src.Damned||hasEldritchPower())
					src.Damned=0
					src.loc=locate(198, 238, 8)
				if(istype(src, /mob/Players/))
					ArchiveSave(src)
				Dead = 1
				makeCorpse(oldLoc)
				sleep(10)
				src.overlays += 'halo.dmi'
			return


	makeCorpse(oldLoc)


	if(glob.VoidsAllowed||NotYet)

		if(forceVoid)
			// there is no need to roll
			actuallyDead = 0
		else
			while(rolls>0)
				var/roll = rand(Chance, 100)
				if(roll >= 100-glob.VoidChance)
					if(glob.SHOW_VOID_ROLL)
						src<<"You rolled a [roll] and the roll to beat was [100-glob.VoidChance]! Congratulations, you have voided!"
					rolls = 0
					actuallyDead = 0
					break
				else
					rolls--
					actuallyDead = 1
					if(glob.SHOW_VOID_ROLL)
						src<<"You rolled a [roll] and the roll to beat was [100-glob.VoidChance]! You have died!"
				if(rolls<0)
					rolls = 0
		if(NotYet)
			src<<"<b>But... it's not over for you yet, [src]!!!!</b>"
			actuallyDead=0
		// forced void
		if(actuallyDead)
			if(NoSoul)
				src<<"You feel your life flash before your eyes, and then in an abrupt snap -- nothingness."
				if(istype(src, /mob/Players/))
					ArchiveSave(src)
				src.loc=locate(glob.NO_SOUL_LOCATION[1], glob.NO_SOUL_LOCATION[2], glob.NO_SOUL_LOCATION[3])
			else
				src<<"You sustain the injuries detailed in your death -- as the pain fades, you awaken in the afterlife. Alone, but not for long."
				src.loc=locate(glob.DEATH_LOCATION[1], glob.DEATH_LOCATION[2], glob.DEATH_LOCATION[3])
				if(src.isRace(DEMON)||src.isRace(ELDRITCH)||src.Damned||hasEldritchPower())
					src.Damned=0
					src.loc=locate(198, 238, 8)
				if(istype(src, /mob/Players/))
					ArchiveSave(src)
				Dead = 1
				src.overlays += 'halo.dmi'
		else
			// voided
			src << glob.VOID_MESSAGE
			void_timer = world.realtime + glob.VOID_TIME
			if(NotYet)
				void_timer = world.realtime + 50
			voiding = TRUE
			Conscious()
			if(NotYet&&src.passive_handler.Get("Reflected"))
				src.ReflectedFrozen=1
				src.ReflectedFrozenTimer=world.time + 48 HOURS
				src<<"<b>Your body yet refuses to leave this world. You are frozen in place, while recovering from your injuries.</b>"
			else
				src.loc = locate(glob.VOID_LOCATION[1], glob.VOID_LOCATION[2], glob.VOID_LOCATION[3])
				if(NotYet)
					src<<"Your story has not yet ended. Cast the final die, and awaken anew."
					src.AddSkill(new/obj/Skills/Utility/TheUndying)
					src.UndyingLoc=oldLoc
				applyVoidNerf()
	if(src.Grab)
		src.Grab_Release()
	var/mob/m=src.IsGrabbed()
	if(m)
		m.Grab_Release()
	StartFresh()
	Stunned  = 0
	if(NoSoul && !forceVoid && !zombie)
		src<<"You have no soul contained within your body; you are embracing nothingness"
		if(istype(src, /mob/Players/))
			ArchiveSave(src)
		src.loc = locate(glob.NO_SOUL_LOCATION[1], glob.NO_SOUL_LOCATION[2], glob.NO_SOUL_LOCATION[3])
		return