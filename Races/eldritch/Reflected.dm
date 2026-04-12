mob/var
	EldritchPacted = 0
	ReflectedPactType="None"
	ReflectedPactOwner = null
	ChrysalisActive = 0
	ChrysalisExpiry = 0
	BaredSoul = 0
	WithYouInDarkness = 0

mob/proc/applyPactBonuses()
	if(!passive_handler)
		return
	switch(ReflectedPactType)
		if("Power")
			StrAscension += 1
			OffAscension += 0.5
			SpdAscension += 0.25
			passive_handler.Increase("Steady", 2)
			passive_handler.Increase("Momentum", 2)
		if("Knowledge")
			ForAscension += 1
			OffAscension += 0.5
			EndAscension += 0.25
			passive_handler.Increase("KiControlMastery", 2)
			passive_handler.Increase("ManaGeneration", 5)
			passive_handler.Increase("EnergyGeneration", 25)
		if("Ambition")
			SpdAscension += 1
			DefAscension += 0.5
			EndAscension += 0.25
			passive_handler.Increase("BlurringStrikes", 1)
			passive_handler.Increase("Fury", 2)
		if("Survival")
			EndAscension += 1
			DefAscension += 0.5
			SpdAscension += 0.25
			passive_handler.Increase("Harden", 2)
			passive_handler.Increase("CallousedHands", 0.5)
		if("Devotion")
			StrAscension += 0.5
			ForAscension += 0.5
			SpdAscension += 0.5
			EndAscension += 0.5
			passive_handler.Increase("TechniqueMastery", 2)
			passive_handler.Increase("MovementMastery", 5)

mob/proc/removePactBonuses()
	if(!passive_handler)
		return
	switch(ReflectedPactType)
		if("Power")
			StrAscension -= 1
			OffAscension -= 0.5
			SpdAscension -= 0.25
			passive_handler.Decrease("Steady", 2)
			passive_handler.Decrease("Momentum", 2)
		if("Knowledge")
			ForAscension -= 1
			OffAscension -= 0.5
			EndAscension -= 0.25
			passive_handler.Decrease("KiControlMastery", 2)
			passive_handler.Decrease("ManaGeneration", 5)
			passive_handler.Decrease("EnergyGeneration", 25)
		if("Ambition")
			SpdAscension -= 1
			DefAscension -= 0.5
			EndAscension -= 0.25
			passive_handler.Decrease("BlurringStrikes", 1)
			passive_handler.Decrease("Fury", 2)
		if("Survival")
			EndAscension -= 1
			DefAscension -= 0.5
			SpdAscension -= 0.25
			passive_handler.Decrease("Harden", 2)
			passive_handler.Decrease("CallousedHands", 0.5)
		if("Devotion")
			StrAscension -= 0.5
			ForAscension -= 0.5
			SpdAscension -= 0.5
			EndAscension -= 0.5
			passive_handler.Decrease("TechniqueMastery", 2)
			passive_handler.Decrease("MovementMastery", 5)

mob/proc/applyWithYouInDarkness()
	if(!passive_handler)
		return
	WithYouInDarkness = 1
	passive_handler.Increase("DebuffResistance", 0.1)
	passive_handler.Increase("PureReduction", 1)
	passive_handler.Increase("Void", 1)

mob/proc/removeWithYouInDarkness()
	if(!passive_handler)
		return
	WithYouInDarkness = 0
	passive_handler.Decrease("DebuffResistance", 0.1)
	passive_handler.Decrease("PureReduction", 1)
	passive_handler.Decrease("Void", 1)

mob/proc/applyBaredSoulBonuses()
	if(!passive_handler)
		return
	switch(ReflectedPactType)
		if("Power")
			StrAscension += 0.5
			OffAscension += 0.25
			passive_handler.Increase("PureDamage", 1)
		if("Knowledge")
			ForAscension += 0.5
			OffAscension += 0.25
			passive_handler.Increase("ManaGeneration", 3)
		if("Ambition")
			SpdAscension += 0.5
			DefAscension += 0.25
			passive_handler.Increase("AttackSpeed", 1)
		if("Survival")
			EndAscension += 0.5
			DefAscension += 0.25
			passive_handler.Increase("Harden", 1)
		if("Devotion")
			StrAscension += 0.25
			ForAscension += 0.25
			SpdAscension += 0.25
			EndAscension += 0.25
			passive_handler.Increase("BuffMastery", 2)
	// Baring the soul strips eldritch protection
	passive_handler.Decrease("PureReduction", 1)

mob/proc/removeBaredSoulBonuses()
	if(!passive_handler)
		return
	switch(ReflectedPactType)
		if("Power")
			StrAscension -= 0.5
			OffAscension -= 0.25
			passive_handler.Decrease("PureDamage", 1)
		if("Knowledge")
			ForAscension -= 0.5
			OffAscension -= 0.25
			passive_handler.Decrease("ManaGeneration", 3)
		if("Ambition")
			SpdAscension -= 0.5
			DefAscension -= 0.25
			passive_handler.Decrease("AttackSpeed", 1)
		if("Survival")
			EndAscension -= 0.5
			DefAscension -= 0.25
			passive_handler.Decrease("Harden", 1)
		if("Devotion")
			StrAscension -= 0.25
			ForAscension -= 0.25
			SpdAscension -= 0.25
			EndAscension -= 0.25
			passive_handler.Decrease("BuffMastery", 2)
	passive_handler.Increase("PureReduction", 1)
	BaredSoul = 0

mob/proc/enterChrysalis()
	ChrysalisActive = 1
	// 2 OOC days in deciseconds: 2 * 24 * 60 * 60 * 10 = 1728000
	ChrysalisExpiry = world.realtime + 1728000
	// Prevent actual death — stabilize at 1 HP
	Health = 1
	KO = 0
	Dead = 0
	MortallyWounded = 0
	// Frozen=2 blocks all skills via SkillX() gate; move_disabled blocks the movement loop
	// Observe and Telepathy are verbs that bypass SkillX, so they still work in chrysalis
	Frozen = 2
	if(istype(src, /mob/Players))
		var/mob/Players/P = src
		P.move_disabled = 1
	// Spawn visible chrysalis shell at mob location for outside interaction
	var/obj/ChrysalisShell/shell = new(src.loc)
	shell.occupant = src
	OMsg(src, "[src] is encased in a shimmering chrysalis of eldritch energy!")
	src << "Your body is encased in a protective chrysalis. You can still Observe and use Telepathy."
	// Start background timer that checks for expiry every 60 seconds
	spawn()
		chrysalisTimerCheck()

mob/proc/exitChrysalis(mob/breaker)
	if(!ChrysalisActive)
		return
	ChrysalisActive = 0
	ChrysalisExpiry = 0
	// Restore mobility
	Frozen = 0
	if(istype(src, /mob/Players))
		var/mob/Players/P = src
		P.move_disabled = 0
	// Remove chrysalis shell obj
	for(var/obj/ChrysalisShell/shell in src.loc)
		if(shell.occupant == src)
			del shell
	Health = max(Health, 1)
	Conscious()
	if(breaker)
		// Breaker pays the cost — handle pacting consequences
		if(!breaker.EldritchPacted)
			// Non-Pacted breaker becomes Pacted to the chrysalis Eldritch
			var/list/PactTypes = list("Devotion (Balanced)", "Power (Strength)", "Knowledge (Force)", "Ambition (Speed)", "Survival (Endurance)")
			var/pactChoice = input(breaker, "Breaking the chrysalis binds you in a pact. What type of pact do you accept?", "Pact Type") as null|anything in PactTypes
			if(!pactChoice)
				pactChoice = "Devotion (Balanced)"
			switch(pactChoice)
				if("Devotion (Balanced)")
					breaker.ReflectedPactType = "Devotion"
				if("Power (Strength)")
					breaker.ReflectedPactType = "Power"
				if("Knowledge (Force)")
					breaker.ReflectedPactType = "Knowledge"
				if("Ambition (Speed)")
					breaker.ReflectedPactType = "Ambition"
				if("Survival (Endurance)")
					breaker.ReflectedPactType = "Survival"
			breaker.EldritchPacted = 1
			breaker.ReflectedPactOwner = src.key
			breaker.applyPactBonuses()
			breaker << "Eldritch power flows through you. Your pact type is [breaker.ReflectedPactType]."
			OMsg(src, "[breaker] shatters [src]'s chrysalis, forging a pact in the process!")
		else
			// Already Pacted — becomes a Bared Soul with amplified bonuses and vulnerability
			breaker.BaredSoul = 1
			breaker.applyBaredSoulBonuses()
			breaker << "The chrysalis shatters and eldritch power surges through your existing pact. You have become a Bared Soul."
			OMsg(src, "[breaker] shatters [src]'s chrysalis!")
	else
		// Natural dissolution after 2 OOC days
		OMsg(src, "[src]'s chrysalis dissolves, and they emerge renewed.")
	src << "Your chrysalis has dissolved. You are free."

mob/proc/chrysalisTimerCheck()
	while(src && ChrysalisActive)
		if(world.realtime >= ChrysalisExpiry)
			exitChrysalis()
			return
		sleep(600)

obj/ChrysalisShell
	name = "Chrysalis"
	desc = "A shimmering chrysalis of eldritch energy. Something stirs within."
	icon = 'enchantmenticons.dmi'
	icon_state = "Barrier"
	color = "#6600CC"
	density = 0
	layer = 5
	var/mob/occupant

	verb/Break_Chrysalis()
		set category = "Other"
		set src in oview(1)
		if(!occupant || !occupant.ChrysalisActive)
			usr << "This chrysalis has already dissolved."
			return
		var/Cost = 10 * glob.progress.EconomyCost
		var/Confirm = alert(usr, "Breaking this chrysalis will cost [Commas(Cost)] mana fragments and will bind you in a pact. Proceed?", "Break Chrysalis", "Yes", "No")
		if(Confirm == "No")
			return
		if(!usr.HasMoney(Cost))
			usr << "You don't have enough fragments. It requires [Commas(Cost)]."
			return
		if(get_dist(usr, src) > 1)
			usr << "You've moved too far away from the chrysalis."
			return
		if(!occupant || !occupant.ChrysalisActive)
			usr << "The chrysalis has already dissolved."
			return
		usr.TakeMoney(Cost)
		occupant.exitChrysalis(usr)

obj/Skills/Utility
	Offer_Pact
		desc="Offer a pact for power to a nearby person."
		verb/Offer_Pact()
			set category="Utility"
			if(src.Using)
				return
			src.Using=1
			if(!usr.hasSecret("Eldritch (Reflected)"))
				usr << "Only a Reflected Eldritch can offer pacts."
				src.Using=0
				return
			var/Cost=1*glob.progress.EconomyCost
			var/list/mob/Players/Options=list()
			for(var/mob/Players/P in oview(1, usr))
				if(P.EldritchPacted)
					continue
				Options.Add(P)
			if(Options.len<1)
				usr << "There's nobody nearby to pact!"
				src.Using=0
				return
			var/mob/Players/Choice=input(usr, "Who do you wish to offer a pact to?", "Offer Pact") as null|anything in Options
			if(!Choice)
				src.Using=0
				return
			var/Confirm=alert(usr, "Do you wish to offer [Choice] a pact? It will cost [Commas(Cost)] mana fragments.", "Offer Pact", "Yes", "No")
			if(Confirm=="No")
				src.Using=0
				return
			if(!usr.HasMoney(Cost))
				usr << "You don't have enough fragments. It requires [Commas(Cost)]."
				src.Using=0
				return
			//Target must accept
			var/TargetConfirm=alert(Choice, "[usr] is offering you a pact for power. Do you accept?", "Eldritch Pact", "Accept", "Refuse")
			if(!usr || !usr.client)
				src.Using=0
				return
			if(TargetConfirm=="Refuse")
				usr << "[Choice] has refused your pact."
				src.Using=0
				return
			if(!Choice || !Choice.client)
				usr << "The target is no longer available."
				src.Using=0
				return
			if(get_dist(usr, Choice) > 1)
				usr << "[Choice] has moved too far away."
				src.Using=0
				return
			OMsg(usr, "[usr] begins weaving a pact to grant [Choice] power...")
			var/list/PactTypes=list("Devotion (Balanced)", "Power (Strength)", "Knowledge (Force)", "Ambition (Speed)", "Survival (Endurance)")
			var/choice2=input(Choice, "What type of pact do you wish to accept?", "Pact Type") as null|anything in PactTypes
			if(!choice2)
				usr << "[Choice] could not decide on a pact."
				src.Using=0
				return
			if(!usr || !usr.client)
				src.Using=0
				return
			if(!Choice || !Choice.client)
				usr << "The target is no longer available."
				src.Using=0
				return
			if(get_dist(usr, Choice) > 1)
				usr << "[Choice] has moved too far away."
				src.Using=0
				return
			//Take payment only after everything is confirmed
			usr.TakeMoney(Cost)
			switch(choice2)
				if("Devotion (Balanced)")
					Choice.ReflectedPactType="Devotion"
				if("Power (Strength)")
					Choice.ReflectedPactType="Power"
				if("Knowledge (Force)")
					Choice.ReflectedPactType="Knowledge"
				if("Ambition (Speed)")
					Choice.ReflectedPactType="Ambition"
				if("Survival (Endurance)")
					Choice.ReflectedPactType="Survival"
			Choice.EldritchPacted=1
			Choice.ReflectedPactOwner=usr.key
			Choice.applyPactBonuses()
			OMsg(usr, "[usr] has forged a pact with [Choice], granting them the gift of [Choice.ReflectedPactType]!")
			Choice << "You feel eldritch power flow through you. Your pact type is [Choice.ReflectedPactType]."
			src.Using=0

	Revoke_Pact
		desc="Revoke a pact you have granted, stripping its power."
		verb/Revoke_Pact()
			set category="Utility"
			if(src.Using)
				return
			src.Using=1
			if(!usr.hasSecret("Eldritch (Reflected)"))
				usr << "Only a Reflected Eldritch can revoke pacts."
				src.Using=0
				return
			var/list/mob/Players/Pacted=list()
			for(var/mob/Players/P in world)
				if(P.EldritchPacted && P.ReflectedPactOwner == usr.key)
					Pacted.Add(P)
			if(Pacted.len < 1)
				usr << "You have no active pacts."
				src.Using=0
				return
			var/mob/Players/Target=input(usr, "Whose pact do you wish to revoke?", "Revoke Pact") as null|anything in Pacted
			if(!Target)
				src.Using=0
				return
			Target.removePactBonuses()
			if(Target.BaredSoul)
				Target.removeBaredSoulBonuses()
			if(Target.WithYouInDarkness)
				Target.removeWithYouInDarkness()
			Target.EldritchPacted = 0
			Target.ReflectedPactType = "None"
			Target.ReflectedPactOwner = null
			Target << "The eldritch power drains from your body as your pact is revoked."
			OMsg(usr, "[usr] severs the pact with [Target], stripping them of eldritch power.")
			src.Using=0

	Refresh
		desc="Cleanse the accumulated stat taxes from yourself or a pacted ally."
		Cooldown=30
		verb/Refresh()
			set category="Utility"
			if(src.Using)
				return
			src.Using=1
			if(!usr.hasSecret("Eldritch (Reflected)"))
				usr << "Only a Reflected Eldritch can use Refresh."
				src.Using=0
				return
			// Build target list: self + pacted allies within reach
			var/list/mob/Players/Options = list(usr)
			for(var/mob/Players/P in oview(1, usr))
				if(P.EldritchPacted && P.ReflectedPactOwner == usr.key)
					Options.Add(P)
			var/mob/Players/Target = usr
			if(Options.len > 1)
				Target = input(usr, "Whose stat taxes do you wish to cleanse?", "Refresh") as null|anything in Options
				if(!Target)
					src.Using=0
					return
			if(Target != usr && get_dist(usr, Target) > 1)
				usr << "[Target] has moved too far away."
				src.Using=0
				return
			// Clear all stat tax values
			Target.StrTax = 0
			Target.EndTax = 0
			Target.SpdTax = 0
			Target.ForTax = 0
			Target.OffTax = 0
			Target.DefTax = 0
			Target.RecovTax = 0
			if(Target == usr)
				usr << "You purge the accumulated strain from your body."
			else
				Target << "[usr] cleanses the strain from your body."
				usr << "You cleanse [Target]'s accumulated stat taxes."
			OMsg(usr, "[usr] radiates a brief pulse of eldritch energy, refreshing [Target == usr ? "themselves" : "[Target]"].")
			// 30 second cooldown
			spawn(300)
				src.Using=0

	Eldritch_Domain
		desc="Manifest a domain of eldritch influence, empowering yourself and nearby pacted allies."
		Cooldown=120
		verb/Eldritch_Domain()
			set category="Utility"
			if(src.Using)
				return
			src.Using = 1
			if(!usr.hasSecret("Eldritch (Reflected)"))
				usr << "Only a Reflected Eldritch can manifest a domain."
				src.Using = 0
				return
			var/mob/caster = usr
			var/list/mob/Players/affected = list()
			for(var/mob/Players/P in range(7, caster))
				if(P == caster)
					continue
				if(P.EldritchPacted && P.ReflectedPactOwner == caster.key && P.passive_handler)
					affected.Add(P)
					P.passive_handler.Increase("DebuffResistance", 0.2)
					P.passive_handler.Increase("ManaGeneration", 3)
					P << "You feel [caster]'s eldritch domain settle around you, bolstering your defenses."
			if(caster.passive_handler)
				caster.passive_handler.Increase("PureReduction", 1)
				caster.passive_handler.Increase("BuffMastery", 2)
			OMsg(caster, "[caster] manifests their eldritch domain! The air shimmers with otherworldly energy.")
			caster << "Your domain takes shape around you."
			// Domain lasts 30 seconds then cleans up
			spawn(300)
				for(var/mob/Players/P in affected)
					if(P && P.passive_handler)
						P.passive_handler.Decrease("DebuffResistance", 0.2)
						P.passive_handler.Decrease("ManaGeneration", 3)
				if(caster && caster.passive_handler)
					caster.passive_handler.Decrease("PureReduction", 1)
					caster.passive_handler.Decrease("BuffMastery", 2)
				if(caster)
					OMsg(caster, "[caster]'s eldritch domain fades.")
					caster << "Your domain dissipates."
			// 120 second total cooldown
			spawn(1200)
				src.Using = 0

	Dream_Realization
		desc="Teleport to a pacted ally, or summon them to you."
		Cooldown=60
		verb/Dream_Realization()
			set category="Utility"
			if(src.Using)
				return
			src.Using=1
			if(!usr.hasSecret("Eldritch (Reflected)"))
				usr << "Only a Reflected Eldritch can use Dream Realization."
				src.Using=0
				return
			// Gather all pacted PCs in the world
			var/list/mob/Players/Pacted = list()
			for(var/mob/Players/P in world)
				if(P == usr)
					continue
				if(P.EldritchPacted && P.ReflectedPactOwner == usr.key)
					Pacted.Add(P)
			if(Pacted.len < 1)
				usr << "You have no pacted allies to reach."
				src.Using=0
				return
			var/Mode = alert(usr, "Do you wish to teleport to a pacted ally, or summon one to you?", "Dream Realization", "Teleport To", "Summon", "Cancel")
			if(Mode == "Cancel")
				src.Using=0
				return
			var/mob/Players/Target = input(usr, "Choose a pacted ally.", "Dream Realization") as null|anything in Pacted
			if(!Target)
				src.Using=0
				return
			if(!Target.client)
				usr << "[Target] is no longer available."
				src.Using=0
				return
			if(Mode == "Teleport To")
				if(!Target.loc)
					usr << "[Target] cannot be reached."
					src.Using=0
					return
				OMsg(usr, "[usr] fades into a shimmer of eldritch light...")
				usr.loc = Target.loc
				OMsg(usr, "[usr] materializes beside [Target] in a ripple of otherworldly energy.")
				usr << "You emerge beside [Target]."
			else
				// Summon mode — requires target consent
				var/Consent = alert(Target, "[usr] wishes to summon you to their location. Do you accept?", "Dream Realization", "Accept", "Refuse")
				if(Consent == "Refuse")
					usr << "[Target] refused your summon."
					src.Using=0
					return
				if(!usr || !usr.client)
					src.Using=0
					return
				if(!Target || !Target.client)
					usr << "[Target] is no longer available."
					src.Using=0
					return
				if(!usr.loc)
					src.Using=0
					return
				OMsg(Target, "[Target] is pulled through a ripple of eldritch energy...")
				Target.loc = usr.loc
				OMsg(usr, "[Target] materializes beside [usr] in a shimmer of otherworldly light.")
				Target << "You are pulled to [usr]'s side."
			// 60 second cooldown
			spawn(600)
				src.Using=0

	With_You_In_Darkness
		desc="Enshroud a pacted ally in eldritch protection, granting them passive defenses."
		verb/With_You_In_Darkness()
			set category="Utility"
			if(src.Using)
				return
			src.Using=1
			if(!usr.hasSecret("Eldritch (Reflected)"))
				usr << "Only a Reflected Eldritch can use this."
				src.Using=0
				return
			var/list/mob/Players/Pacted = list()
			for(var/mob/Players/P in world)
				if(P == usr)
					continue
				if(P.EldritchPacted && P.ReflectedPactOwner == usr.key)
					Pacted.Add(P)
			if(Pacted.len < 1)
				usr << "You have no pacted allies."
				src.Using=0
				return
			var/mob/Players/Target = input(usr, "Choose a pacted ally to enshroud.", "With You in Darkness") as null|anything in Pacted
			if(!Target)
				src.Using=0
				return
			if(Target.WithYouInDarkness)
				Target.removeWithYouInDarkness()
				Target << "The eldritch shroud around you fades."
				usr << "You withdraw your protection from [Target]."
				OMsg(usr, "The dark aura around [Target] dissipates.")
			else
				Target.applyWithYouInDarkness()
				Target << "You feel an eldritch presence settle around you, shielding you from harm."
				usr << "You enshroud [Target] in eldritch protection."
				OMsg(usr, "A subtle dark aura settles around [Target].")
			src.Using=0

	Bared_Souls
		desc="Deepen the pact with a willing ally, granting more power at the cost of vulnerability."
		verb/Bared_Souls()
			set category="Utility"
			if(src.Using)
				return
			src.Using = 1
			if(!usr.hasSecret("Eldritch (Reflected)"))
				usr << "Only a Reflected Eldritch can use this."
				src.Using = 0
				return
			var/list/mob/Players/Options = list()
			for(var/mob/Players/P in world)
				if(P == usr)
					continue
				if(P.EldritchPacted && P.ReflectedPactOwner == usr.key && !P.BaredSoul)
					Options.Add(P)
			if(Options.len < 1)
				usr << "You have no pacted allies eligible to become Bared Souls."
				src.Using = 0
				return
			var/mob/Players/Target = input(usr, "Whose pact do you wish to deepen? They gain power but lose eldritch protection.", "Bared Souls") as null|anything in Options
			if(!Target)
				src.Using = 0
				return
			if(!Target.client)
				usr << "[Target] is no longer available."
				src.Using = 0
				return
			var/Consent = alert(Target, "[usr] wishes to deepen your pact, making you a Bared Soul. You will gain additional power but become vulnerable to Pure damage. Accept?", "Bared Souls", "Accept", "Refuse")
			if(Consent == "Refuse")
				usr << "[Target] refused to bare their soul."
				src.Using = 0
				return
			if(!usr || !usr.client)
				src.Using = 0
				return
			if(!Target || !Target.client)
				usr << "[Target] is no longer available."
				src.Using = 0
				return
			if(!Target.EldritchPacted || Target.ReflectedPactOwner != usr.key)
				usr << "[Target] is no longer pacted to you."
				src.Using = 0
				return
			if(Target.BaredSoul)
				usr << "[Target] is already a Bared Soul."
				src.Using = 0
				return
			Target.BaredSoul = 1
			Target.applyBaredSoulBonuses()
			Target << "Eldritch power surges through your deepened pact. You feel both stronger and more exposed."
			usr << "You have deepened [Target]'s pact. They are now a Bared Soul."
			OMsg(usr, "[usr] deepens the pact with [Target], eldritch energy crackling between them.")
			src.Using = 0

	Altered_Nature
		desc="Redistribute a passive between your pacted allies."
		Cooldown=60
		verb/Altered_Nature()
			set category="Utility"
			if(src.Using)
				return
			src.Using = 1
			if(!usr.hasSecret("Eldritch (Reflected)"))
				usr << "Only a Reflected Eldritch can use this."
				src.Using = 0
				return
			var/list/mob/Players/Pacted = list()
			for(var/mob/Players/P in world)
				if(P == usr)
					continue
				if(P.EldritchPacted && P.ReflectedPactOwner == usr.key)
					Pacted.Add(P)
			if(Pacted.len < 2)
				usr << "You need at least two pacted allies to redistribute passives."
				src.Using = 0
				return
			var/mob/Players/Source = input(usr, "Select the ally to take a passive from.", "Altered Nature - Source") as null|anything in Pacted
			if(!Source)
				src.Using = 0
				return
			if(!Source.passive_handler)
				usr << "[Source] has no passives to transfer."
				src.Using = 0
				return
			var/list/available = list()
			for(var/passive_name in Source.passive_handler.passives)
				if(Source.passive_handler.passives[passive_name] >= 1)
					available.Add(passive_name)
			if(available.len < 1)
				usr << "[Source] has no passives with enough value to transfer."
				src.Using = 0
				return
			var/chosen_passive = input(usr, "Which passive do you wish to transfer from [Source]?", "Altered Nature - Passive") as null|anything in available
			if(!chosen_passive)
				src.Using = 0
				return
			var/list/mob/Players/Targets = Pacted.Copy()
			Targets.Remove(Source)
			if(Targets.len < 1)
				usr << "There is no other pacted ally to receive the passive."
				src.Using = 0
				return
			var/mob/Players/Target = input(usr, "Select the ally to receive [chosen_passive].", "Altered Nature - Target") as null|anything in Targets
			if(!Target)
				src.Using = 0
				return
			if(!Target.passive_handler)
				usr << "[Target] cannot receive passives."
				src.Using = 0
				return
			if(!Source.passive_handler || Source.passive_handler.Get(chosen_passive) < 1)
				usr << "[Source] no longer has enough [chosen_passive] to transfer."
				src.Using = 0
				return
			Source.passive_handler.Decrease(chosen_passive, 1)
			Target.passive_handler.Increase(chosen_passive, 1)
			Source << "[usr] transfers some of your [chosen_passive] to [Target]."
			Target << "[usr] grants you [chosen_passive] drawn from [Source]'s nature."
			usr << "You transfer 1 [chosen_passive] from [Source] to [Target]."
			OMsg(usr, "[usr] weaves eldritch threads between [Source] and [Target], altering their nature.")
			spawn(600)
				src.Using = 0

	Glimpse_Inside
		desc="Grant a pacted ally a glimpse of eldritch power, awakening or advancing their secret."
		Cooldown=120
		verb/Glimpse_Inside()
			set category="Utility"
			if(src.Using)
				return
			src.Using = 1
			if(!usr.hasSecret("Eldritch (Reflected)"))
				usr << "Only a Reflected Eldritch can use this."
				src.Using = 0
				return
			var/list/mob/Players/Options = list()
			for(var/mob/Players/P in oview(1, usr))
				if(P.EldritchPacted && P.ReflectedPactOwner == usr.key)
					Options.Add(P)
			if(Options.len < 1)
				usr << "There are no pacted allies nearby."
				src.Using = 0
				return
			var/mob/Players/Target = input(usr, "Whose inner potential do you wish to unlock?", "Glimpse Inside") as null|anything in Options
			if(!Target)
				src.Using = 0
				return
			if(!Target.client)
				usr << "[Target] is no longer available."
				src.Using = 0
				return
			if(get_dist(usr, Target) > 1)
				usr << "[Target] has moved too far away."
				src.Using = 0
				return
			var/Consent = alert(Target, "[usr] wishes to grant you a glimpse of eldritch power. This will affect your secret abilities. Accept?", "Glimpse Inside", "Accept", "Refuse")
			if(Consent == "Refuse")
				usr << "[Target] refused the glimpse."
				src.Using = 0
				return
			if(!usr || !usr.client)
				src.Using = 0
				return
			if(!Target || !Target.client)
				usr << "[Target] is no longer available."
				src.Using = 0
				return
			if(get_dist(usr, Target) > 1)
				usr << "[Target] has moved too far away."
				src.Using = 0
				return
			if(!Target.Secret)
				Target.Secret = "Eldritch"
				Target.giveSecret("Eldritch")
				Target << "A flood of eldritch knowledge washes over you. You have awakened to the Eldritch secret!"
				usr << "You grant [Target] a glimpse into the eldritch depths, awakening their hidden potential."
				OMsg(usr, "[usr] places a hand on [Target]'s forehead, and eldritch energy pulses between them.")
			else
				if(Target.secretDatum.currentTier >= Target.secretDatum.maxTier)
					usr << "[Target]'s secret has already reached its peak."
					src.Using = 0
					return
				Target.secretDatum.tierUp(1, Target)
				Target << "Eldritch insight deepens your understanding. Your [Target.Secret] has advanced!"
				usr << "You guide [Target]'s [Target.Secret] to a higher tier."
				OMsg(usr, "[usr] channels eldritch insight into [Target], amplifying their secret potential.")
			spawn(1200)
				src.Using = 0

	Reclamation
		desc="Reclaim a pact, stripping the target of its power and temporarily absorbing those bonuses yourself."
		verb/Reclamation()
			set category="Utility"
			if(src.Using)
				return
			src.Using = 1
			if(!usr.hasSecret("Eldritch (Reflected)"))
				usr << "Only a Reflected Eldritch can reclaim pacts."
				src.Using = 0
				return
			var/list/mob/Players/Pacted = list()
			for(var/mob/Players/P in world)
				if(P.EldritchPacted && P.ReflectedPactOwner == usr.key)
					Pacted.Add(P)
			if(Pacted.len < 1)
				usr << "You have no active pacts to reclaim."
				src.Using = 0
				return
			var/mob/Players/Target = input(usr, "Whose pact do you wish to reclaim?", "Reclamation") as null|anything in Pacted
			if(!Target)
				src.Using = 0
				return
			var/mob/caster = usr
			var/reclaimed_type = Target.ReflectedPactType
			// Strip everything from target
			Target.removePactBonuses()
			if(Target.BaredSoul)
				Target.removeBaredSoulBonuses()
			if(Target.WithYouInDarkness)
				Target.removeWithYouInDarkness()
			Target.EldritchPacted = 0
			Target.ReflectedPactType = "None"
			Target.ReflectedPactOwner = null
			Target << "The eldritch power drains from your body as your pact is reclaimed."
			OMsg(caster, "[caster] reclaims the pact from [Target], absorbing its power!")
			// Temporarily gain the reclaimed pact's bonuses
			caster.ReflectedPactType = reclaimed_type
			caster.applyPactBonuses()
			caster.ReflectedPactType = "None"
			caster << "You absorb the reclaimed [reclaimed_type] pact energy. It surges through you."
			var/buff_type = reclaimed_type
			spawn(600)
				if(caster)
					caster.ReflectedPactType = buff_type
					caster.removePactBonuses()
					caster.ReflectedPactType = "None"
					caster << "The reclaimed pact energy fades from your body."
				src.Using = 0

	Shared_Dreaming
		desc="Project your eldritch essence through the dream, empowering all pacted allies worldwide."
		Cooldown=180
		verb/Shared_Dreaming()
			set category="Utility"
			if(src.Using)
				return
			src.Using = 1
			if(!usr.hasSecret("Eldritch (Reflected)"))
				usr << "Only a Reflected Eldritch can share dreams."
				src.Using = 0
				return
			var/mob/caster = usr
			var/list/mob/Players/affected = list()
			for(var/mob/Players/P in world)
				if(P == caster)
					continue
				if(P.EldritchPacted && P.ReflectedPactOwner == caster.key && P.passive_handler)
					affected.Add(P)
					P.passive_handler.Increase("PureDamage", 1)
					P.passive_handler.Increase("PureReduction", 1)
					P.passive_handler.Increase("DebuffResistance", 0.2)
					P.passive_handler.Increase("CriticalChance", 5)
					P.passive_handler.Increase("BuffMastery", 2)
					P << "You feel [caster]'s presence wash over you in a waking dream, bolstering your power."
			if(affected.len < 1)
				caster << "You have no pacted allies to reach."
				src.Using = 0
				return
			OMsg(caster, "[caster] closes their eyes and projects their essence outward through the dream...")
			caster << "You project your eldritch essence to all pacted allies."
			spawn(300)
				for(var/mob/Players/P in affected)
					if(P && P.passive_handler)
						P.passive_handler.Decrease("PureDamage", 1)
						P.passive_handler.Decrease("PureReduction", 1)
						P.passive_handler.Decrease("DebuffResistance", 0.2)
						P.passive_handler.Decrease("CriticalChance", 5)
						P.passive_handler.Decrease("BuffMastery", 2)
				if(caster)
					OMsg(caster, "The shared dream fades.")
					caster << "Your projected essence returns to you."
			spawn(1800)
				src.Using = 0

	True_Reflection
		desc="Draw upon the reflection of every pact you have forged, absorbing their combined power."
		Cooldown=300
		verb/True_Reflection()
			set category="Utility"
			if(src.Using)
				return
			src.Using = 1
			if(!usr.hasSecret("Eldritch (Reflected)"))
				usr << "Only a Reflected Eldritch can manifest their True Reflection."
				src.Using = 0
				return
			var/mob/caster = usr
			var/list/types_applied = list()
			for(var/mob/Players/P in world)
				if(P.EldritchPacted && P.ReflectedPactOwner == caster.key)
					if(!(P.ReflectedPactType in types_applied))
						types_applied.Add(P.ReflectedPactType)
			if(types_applied.len < 1)
				caster << "You have no pacts to reflect."
				src.Using = 0
				return
			for(var/ptype in types_applied)
				caster.ReflectedPactType = ptype
				caster.applyPactBonuses()
			caster.ReflectedPactType = "None"
			caster << "You see yourself reflected in every pact you've forged. Their power flows through you."
			OMsg(caster, "[caster]'s form shimmers as the reflections of every pact converge upon them!")
			spawn(600)
				if(caster)
					for(var/ptype in types_applied)
						caster.ReflectedPactType = ptype
						caster.removePactBonuses()
					caster.ReflectedPactType = "None"
					caster << "The reflections fade. The borrowed power returns to its source."
					OMsg(caster, "[caster]'s shimmering form settles back to normal.")
			spawn(3000)
				src.Using = 0

	Eldritch_Covenant
		desc="Forge the ultimate bond, elevating yourself and all pacted allies to their peak."
		Cooldown=300
		verb/Eldritch_Covenant()
			set category="Utility"
			if(src.Using)
				return
			src.Using = 1
			if(!usr.hasSecret("Eldritch (Reflected)"))
				usr << "Only a Reflected Eldritch can invoke the Covenant."
				src.Using = 0
				return
			var/mob/caster = usr
			var/list/mob/Players/affected = list()
			for(var/mob/Players/P in world)
				if(P == caster)
					continue
				if(P.EldritchPacted && P.ReflectedPactOwner == caster.key && P.passive_handler)
					affected.Add(P)
					P.StrAscension += 0.5
					P.ForAscension += 0.5
					P.SpdAscension += 0.5
					P.EndAscension += 0.5
					P.passive_handler.Increase("PureDamage", 2)
					P.passive_handler.Increase("PureReduction", 2)
					P.passive_handler.Increase("DebuffResistance", 0.3)
					P << "An overwhelming surge of eldritch power courses through your pact."
			if(affected.len < 1)
				caster << "You have no pacted allies to empower."
				src.Using = 0
				return
			if(caster.passive_handler)
				caster.StrAscension += 0.5
				caster.ForAscension += 0.5
				caster.SpdAscension += 0.5
				caster.EndAscension += 0.5
				caster.passive_handler.Increase("PureDamage", 2)
				caster.passive_handler.Increase("PureReduction", 2)
				caster.passive_handler.Increase("DebuffResistance", 0.3)
			OMsg(caster, "[caster] invokes the Eldritch Covenant! Reality warps as pact energy surges to its apex!")
			caster << "You invoke the Covenant. Every bond resonates at its peak."
			spawn(600)
				for(var/mob/Players/P in affected)
					if(P && P.passive_handler)
						P.StrAscension -= 0.5
						P.ForAscension -= 0.5
						P.SpdAscension -= 0.5
						P.EndAscension -= 0.5
						P.passive_handler.Decrease("PureDamage", 2)
						P.passive_handler.Decrease("PureReduction", 2)
						P.passive_handler.Decrease("DebuffResistance", 0.3)
				if(caster && caster.passive_handler)
					caster.StrAscension -= 0.5
					caster.ForAscension -= 0.5
					caster.SpdAscension -= 0.5
					caster.EndAscension -= 0.5
					caster.passive_handler.Decrease("PureDamage", 2)
					caster.passive_handler.Decrease("PureReduction", 2)
					caster.passive_handler.Decrease("DebuffResistance", 0.3)
				if(caster)
					OMsg(caster, "The Eldritch Covenant's power subsides.")
					caster << "The Covenant ends. The bonds settle."
			spawn(3000)
				src.Using = 0
