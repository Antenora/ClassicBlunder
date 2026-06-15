

//changed these to line up with ~10 potential after intended SSj Levels (recorded in saiyan/transformations.dm and below)
#define ASCENSION_ONE_POTENTIAL 10 //Sub-SSj Level
#define ASCENSION_TWO_POTENTIAL 25 //SSj1
#define ASCENSION_THREE_POTENTIAL 40 //SSj2

//This is kind of gonna be a lull period for Ascension races. Tough beans...

#define ASCENSION_FOUR_POTENTIAL 60 //Balanced against SSjG / Golden Oozaru; we're skipping SSj3 specific tier
#define ASCENSION_FIVE_POTENTIAL 75 //SSj4; ascension races catch up a bit quicker on this trans level because they had a slog for the previous ascension
#define ASCENSION_SIX_POTENTIAL 90 //SSjG - Blue Evolved; and we're back to typical ascension race progression

//If you want an ascension race to go beyond asc 6 or match SSj4LB, you're going to have to commit a bit of "Plot"

/*word of Jesse on intended Potentials for SSj unlocks (distinct from auto unlocks!!) - as of 2026.02.08
SSj1 - ~20
SSj2 - ~35
SSj3 - ~45
SSjG / Golden Oozaru - ~60
SSj4 / SSjB - ~70
SSj4LB / BE - ~80
These are idealized values and if your app is denied when the wipe is around the desired potential range, it does not mean the admin team hates you
*/



ascension
	Read(F)
		..()
		// death becomes u
		if(!choiceSelected)
			var/path = "[type]"
			var/ascension/a = new path
			for(var/x in a.passives)
				passives[x] = a.passives[x]
			if(isnull(passives))
				world.log << "Hey. [src] didnt get passives."
				passives = list()

	var
		powerAdd = 0
		strength = 0
		endurance = 0
		force = 0
		offense = 0
		defense = 0
		speed = 0
		recovery = 0
		learning = 0
		intelligenceAdd = 0
		imaginationAdd = 0
		anger = 0
		unlock_potential = 1
		intimidation = 0
		intimidationMult = 1
		pilotingProwess = 0
		cyberizeModAdd = 0
		enhanceChips = 0
		rppAdd = 0
		ecoAdd = 0

		angerPoint
		new_anger_message

		list/skills = list()
		list/passives = list()

		choiceTitle = "Ascension Selection"
		choiceMessage = ""
		list/choices = list()
		ascension/choiceSelected
		tmp/pickingChoice = FALSE

		on_ascension_message

		applied = FALSE

	proc
		revertAscension(mob/owner)
			if(!applied || pickingChoice) return

			owner.PotentialRate -= powerAdd
			owner.StrAscension -= strength
			owner.EndAscension -= endurance
			owner.ForAscension -= force
			owner.OffAscension -= offense
			owner.DefAscension -= defense
			owner.SpdAscension -= speed
			owner.RecovAscension -=  recovery

			if(skills.len > 0)
				for(var/obj/Skills/added_skill in skills)
					if(!locate(added_skill,owner)) continue
					owner.DeleteSkill(new added_skill)

			if(passives.len > 0)
				owner.passive_handler.decreaseList(passives)

			if(angerPoint)
				owner.AngerPoint -= angerPoint

			if(new_anger_message)
				if(owner.race.ascensions[owner.AscensionsAcquired-1].new_anger_message)
					owner.AngerMessage = owner.race.ascensions[owner.AscensionsAcquired-1].new_anger_message
				else
					owner.AngerMessage = "becomes angry!"

			if(anger != 0)
				owner.NewAnger(owner.AngerMax-anger)

			owner.Intimidation -= intimidation
			owner.Intimidation /= intimidationMult

			owner.Intelligence -= intelligenceAdd
			owner.Imagination -= imaginationAdd

			owner.CyberizeMod -= cyberizeModAdd

			owner.RPPMult -= rppAdd
			owner.EconomyMult -= ecoAdd
			owner.PilotingProwess -= pilotingProwess
			owner.EnhanceChipsMax -= enhanceChips
			owner.AscensionsAcquired-=1

			if(choiceSelected)
				var/ascension/choiceAsc = choiceSelected
				choiceAsc.revertAscension(owner)
				choiceSelected = null

			owner.SetCyberCancel()

			applied = FALSE

		onAscension(mob/owner)
			DEBUGMSG("onAscension firing");
			. = TRUE
			if(applied || pickingChoice) return FALSE
			owner << on_ascension_message
			choiceSelection(owner)
			if(choices && choices.len > 0 && !choiceSelected) return FALSE
			applied = TRUE

			owner.PotentialRate += powerAdd
			owner.StrAscension += strength
			owner.EndAscension += endurance
			owner.ForAscension += force
			owner.OffAscension += offense
			owner.DefAscension += defense
			owner.SpdAscension += speed
			owner.RecovAscension +=  recovery

			if(skills.len > 0)
				for(var/added_skill in skills)
					if(locate(added_skill,owner)) continue
					owner.AddSkill(new added_skill)

			if(passives.len > 0)
				owner.passive_handler.increaseList(passives)

			if(angerPoint)
				owner.AngerPoint += angerPoint

			if(new_anger_message)
				owner.AngerMessage = new_anger_message

			if(anger != 0)
				owner.NewAnger(owner.AngerMax+anger)

			owner.Intimidation += intimidation
			owner.IntimidationMult += intimidationMult

			owner.Intelligence += intelligenceAdd
			owner.Imagination += imaginationAdd

			owner.CyberizeMod += cyberizeModAdd

			owner.RPPMult += rppAdd
			owner.EconomyMult += ecoAdd
			owner.PilotingProwess += pilotingProwess
			owner.EnhanceChipsMax += enhanceChips

			if(!istype(src, /ascension/sub_ascension))
				owner.AscensionsAcquired+=1

			if(choiceSelected)
				var/ascension/choiceAsc = new choiceSelected
				choiceAsc.onAscension(owner)
				choiceSelected = choiceAsc;

			owner.SetCyberCancel()
			DEBUGMSG("onAscension complete");
			postAscension(owner)

		postAscension(mob/owner)
			DEBUGMSG("postAscension firing");

		choiceSelection(mob/owner)
			if(owner.isRace(BEASTKIN) && owner.AscensionsAcquired >= 2 && !choiceSelected)
				if(!pickingChoice) owner.race.ascensions[owner.AscensionsAcquired+1].choices = owner.getRiftAscensionOptions();
			if(!choices) return
			if(choices.len == 0 || choiceSelected || pickingChoice) return
			pickingChoice = TRUE
			var/selected = input(owner, choiceMessage, choiceTitle) in choices
			choiceSelected = choices[selected]
			pickingChoice = FALSE

		checkAscensionUnlock(mob/target,potential)
			if(target.AscensionsUnlocked > target.AscensionsAcquired) return 1
			if(unlock_potential==-1 || applied) return 0
			if(potential >= unlock_potential)
				return 1
			return 0

		// Applies any conditional mutations to this ascension's stat/passive vars
		// based on owner state (Class, prior sub-ascension choices, etc).
		// Base impl is a no-op. Overridden in races whose per-ascension stats
		// depend on owner state instead of being purely static field values.
		// Called from onAscension BEFORE ..() so the parent can apply the
		// mutated vars, and also callable in isolation for stat previews.
		simulateChoiceMutation(mob/owner)
			return

// Ascension preview helpers: read-only inspection of what the player WOULD
// gain if they ascended from CA (current acquired) up to TA (target, max 6).
// Works by instantiating fresh copies of each ascension and asking them to
// simulate their conditional mutations, so no game state is touched.

/proc/_ascension_stat_field(Stat)
	switch("[Stat]")
		if("Power", "power", "powerAdd", "PowerAdd") return "powerAdd"
		if("Strength", "strength", "Str", "StrAscension") return "strength"
		if("Endurance", "endurance", "End", "EndAscension") return "endurance"
		if("Force", "force", "For", "ForAscension") return "force"
		if("Offense", "offense", "Off", "OffAscension") return "offense"
		if("Defense", "defense", "Def", "DefAscension") return "defense"
		if("Speed", "speed", "Spd", "SpdAscension") return "speed"
		if("Recovery", "recovery", "Recov", "RecovAscension") return "recovery"
		if("Intellect", "intelligenceAdd", "Intelligence") return "intelligenceAdd"
		if("Imagination", "imaginationAdd") return "imaginationAdd"
		if("Anger", "anger") return "anger"
		if("Intimidation", "intimidation") return "intimidation"
		if("RPP", "rppAdd") return "rppAdd"
		if("Economy", "ecoAdd") return "ecoAdd"
		if("Piloting", "pilotingProwess") return "pilotingProwess"
		if("Cyberize", "cyberizeModAdd") return "cyberizeModAdd"
		if("EnhanceChips", "enhanceChips") return "enhanceChips"
	return null

/mob/proc/PullAscensionStats(CA, TA, Stat)
	var/AscStat = 0
	if(!race)
		return AscStat
	var/list/ascs = race.ascensions
	if(!islist(ascs) || !ascs.len)
		return AscStat
	var/statField = _ascension_stat_field(Stat)
	if(!statField)
		return AscStat
	if(isnull(CA)) CA = AscensionsAcquired
	if(isnull(TA)) TA = 6
	CA = max(CA, 0)
	TA = min(TA, ascs.len)
	TA = min(TA, 6)
	if(TA <= CA)
		return AscStat
	for(var/i = CA + 1, i <= TA, i++)
		var/ascension/template = ascs[i]
		if(!template) continue
		var/path = template.type
		var/ascension/a = new path
		a.simulateChoiceMutation(src)
		var/v = a.vars[statField]
		if(isnum(v))
			AscStat += v
		if(template.choiceSelected)
			var/subpath = template.choiceSelected
			var/ascension/sub = new subpath
			sub.simulateChoiceMutation(src)
			var/sv = sub.vars[statField]
			if(isnum(sv))
				AscStat += sv
	return AscStat

/mob/proc/PullAscensionPassives(CA, TA)
	var/list/AscPassives = list()
	if(!race)
		return AscPassives
	var/list/ascs = race.ascensions
	if(!islist(ascs) || !ascs.len)
		return AscPassives
	if(isnull(CA)) CA = AscensionsAcquired
	if(isnull(TA)) TA = 6
	CA = max(CA, 0)
	TA = min(TA, ascs.len)
	TA = min(TA, 6)
	if(TA <= CA)
		return AscPassives
	for(var/i = CA + 1, i <= TA, i++)
		var/ascension/template = ascs[i]
		if(!template) continue
		var/path = template.type
		var/ascension/a = new path
		a.simulateChoiceMutation(src)
		if(islist(a.passives))
			for(var/p in a.passives)
				var/add = a.passives[p]
				if(!isnum(add)) continue
				AscPassives[p] = (isnum(AscPassives[p]) ? AscPassives[p] : 0) + add
		if(template.choiceSelected)
			var/subpath = template.choiceSelected
			var/ascension/sub = new subpath
			sub.simulateChoiceMutation(src)
			if(islist(sub.passives))
				for(var/p in sub.passives)
					var/add = sub.passives[p]
					if(!isnum(add)) continue
					AscPassives[p] = (isnum(AscPassives[p]) ? AscPassives[p] : 0) + add
	return AscPassives

/mob/Admin2/verb/Preview_Ascensions(mob/Players/p in players)
	set category = "Admin"
	set name = "Preview Ascensions"
	if(!p || !p.race)
		src << "That player has no race set."
		return
	var/list/ascs = p.race.ascensions
	if(!islist(ascs) || !ascs.len)
		src << "[p] has no ascensions defined on their race."
		return
	var/ca = p.AscensionsAcquired
	var/maxTarget = min(6, ascs.len)
	if(ca >= maxTarget)
		src << "[p] is already at max ascension ([ca]/[maxTarget])."
		return
	var/ta = input(src, "Preview ascensions for [p.key] up to which level? (current: [ca], max: [maxTarget])", "Preview Ascensions", maxTarget) as num|null
	if(isnull(ta)) return
	ta = round(ta)
	ta = max(ta, ca + 1)
	ta = min(ta, maxTarget)

	var/list/statNames = list("Power","Strength","Endurance","Force","Offense","Defense","Speed","Recovery","Intellect","Imagination","Anger","Intimidation","RPP","Economy","Piloting","Cyberize","EnhanceChips")
	var/html = "<html><head><title>Ascension Preview - [p.key]</title></head><body bgcolor=#111122 text=#e0e0e0 style='font-family:Calibri,sans-serif;font-size:10pt;padding:8px'>"
	html += "<h2 style='color:#fff;border-bottom:1px solid #444;padding-bottom:4px'>[p.key] &mdash; [p.race.name]</h2>"
	html += "<p>Class: <b>[p.Class ? p.Class : "None"]</b><br>"
	html += "Current Ascension: <b>[ca]</b> &nbsp;|&nbsp; Preview Target: <b>[ta]</b></p>"

	html += "<h3 style='color:#ffd54f;margin-top:12px'>Stat gains (from asc [ca+1] through asc [ta])</h3>"
	html += "<table border=0 cellpadding=4 cellspacing=0 style='background:#1a1a2e;width:100%'>"
	var/anyStat = 0
	for(var/statName in statNames)
		var/gain = p.PullAscensionStats(ca, ta, statName)
		if(gain == 0) continue
		anyStat = 1
		html += "<tr><td style='border-bottom:1px solid #222;color:#aaa'>[statName]</td><td style='border-bottom:1px solid #222;color:#8fd'><b>+[gain]</b></td></tr>"
	if(!anyStat)
		html += "<tr><td colspan=2 style='color:#888;font-style:italic'>No static stat gains detected in this range.</td></tr>"
	html += "</table>"

	html += "<h3 style='color:#ffd54f;margin-top:12px'>Passives (aggregated)</h3>"
	var/list/passiveGains = p.PullAscensionPassives(ca, ta)
	if(!islist(passiveGains) || !passiveGains.len)
		html += "<p style='color:#888;font-style:italic'>No passives in this range.</p>"
	else
		html += "<table border=0 cellpadding=4 cellspacing=0 style='background:#1a1a2e;width:100%'>"
		for(var/passiveName in passiveGains)
			var/val = passiveGains[passiveName]
			html += "<tr><td style='border-bottom:1px solid #222;color:#aaa'>[passiveName]</td><td style='border-bottom:1px solid #222;color:#8fd'><b>+[val]</b></td></tr>"
		html += "</table>"

	html += "<p style='color:#666;font-size:8pt;margin-top:14px'>Read-only preview. Nothing has been applied to [p.key].</p>"
	html += "</body></html>"
	src << browse(html, "window=ascpreview_[p.key];size=520x560;can_resize=1")
