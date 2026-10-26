#define QUINCY_ENGRAVE_LEVEL 6
#define QUINCY_ENGRAVE_REACH 2
#define QUINCY_AUSWAHLEN_COOLDOWN (24 HOURS)
#define QUINCY_AUSWAHLEN_BLOCK (24 HOURS)
#define QUINCY_SCHRIFT_SEATS 25

mob
	var
		QuincySchriftTwin
		QuincyStandspitzeOwed = 0

globalTracker
	var
		list/QuincyAuswahlenOwed = list()

var/list/QuincySchriftKitCache

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift
	name = "Schrift"
	BuffName = "Schrift"
	AlwaysOn = 1
	doNotDelete = 1
	Cooldown = 0
	Copyable = 0
	passives = list()
	var/letter
	var/schrift_name
	var/identity_line
	var/list/kit_skills = list()

	New()
		..()
		UICustomDescription = "[letter]: [schrift_name]. [QuincyCapFirst(identity_line)]."

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/A_Antithesis
	name = "A: Antithesis"
	BuffName = "A: Antithesis"
	letter = "A"
	schrift_name = "Antithesis"
	identity_line = "reverses events between two points"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/B_The_Balance
	name = "B: The Balance"
	BuffName = "B: The Balance"
	letter = "B"
	schrift_name = "The Balance"
	identity_line = "misfortune flows into the shield"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/C_The_Compulsory
	name = "C: The Compulsory"
	BuffName = "C: The Compulsory"
	letter = "C"
	schrift_name = "The Compulsory"
	identity_line = "nerves that puppet the body"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/D_The_Deathdealing
	name = "D: The Deathdealing"
	BuffName = "D: The Deathdealing"
	letter = "D"
	schrift_name = "The Deathdealing"
	identity_line = "the lethal dose"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/E_The_Explode
	name = "E: The Explode"
	BuffName = "E: The Explode"
	letter = "E"
	schrift_name = "The Explode"
	identity_line = "what it touches becomes a bomb"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/F_The_Fear
	name = "F: The Fear"
	BuffName = "F: The Fear"
	letter = "F"
	schrift_name = "The Fear"
	identity_line = "thorns that carry terror"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/G_The_Glutton
	name = "G: The Glutton"
	BuffName = "G: The Glutton"
	letter = "G"
	schrift_name = "The Glutton"
	identity_line = "the maw"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/H_The_Heat
	name = "H: The Heat"
	BuffName = "H: The Heat"
	letter = "H"
	schrift_name = "The Heat"
	identity_line = "Burner Finger"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/I_The_Iron
	name = "I: The Iron"
	BuffName = "I: The Iron"
	letter = "I"
	schrift_name = "The Iron"
	identity_line = "iron skin"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/J_The_Jail
	name = "J: The Jail"
	BuffName = "J: The Jail"
	letter = "J"
	schrift_name = "The Jail"
	identity_line = "cages that seal presence"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/L_The_Love
	name = "L: The Love"
	BuffName = "L: The Love"
	letter = "L"
	schrift_name = "The Love"
	identity_line = "hearts that command"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/M_The_Miracle
	name = "M: The Miracle"
	BuffName = "M: The Miracle"
	letter = "M"
	schrift_name = "The Miracle"
	identity_line = "damage becomes growth"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/O_The_Overkill
	name = "O: The Overkill"
	BuffName = "O: The Overkill"
	letter = "O"
	schrift_name = "The Overkill"
	identity_line = "kills feed power"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/P_The_Power
	name = "P: The Power"
	BuffName = "P: The Power"
	letter = "P"
	schrift_name = "The Power"
	identity_line = "strength"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/Q_The_Question
	name = "Q: The Question"
	BuffName = "Q: The Question"
	letter = "Q"
	schrift_name = "The Question"
	identity_line = "the objection"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/R_The_Roar
	name = "R: The Roar"
	BuffName = "R: The Roar"
	letter = "R"
	schrift_name = "The Roar"
	identity_line = "the shockwave"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/S_The_Superstar
	name = "S: The Superstar"
	BuffName = "S: The Superstar"
	letter = "S"
	schrift_name = "The Superstar"
	identity_line = "James cheers"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/T_The_Thunderbolt
	name = "T: The Thunderbolt"
	BuffName = "T: The Thunderbolt"
	letter = "T"
	schrift_name = "The Thunderbolt"
	identity_line = "lightning"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/U_The_Underbelly
	name = "U: The Underbelly"
	BuffName = "U: The Underbelly"
	letter = "U"
	schrift_name = "The Underbelly"
	identity_line = "read the Reiatsu, widen the holes"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/V_The_Visionary
	name = "V: The Visionary"
	BuffName = "V: The Visionary"
	letter = "V"
	schrift_name = "The Visionary"
	identity_line = "imagination made real"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/W_The_Wind
	name = "W: The Wind"
	BuffName = "W: The Wind"
	letter = "W"
	schrift_name = "The Wind"
	identity_line = "attacks bend away"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/X_The_X_Axis
	name = "X: The X-Axis"
	BuffName = "X: The X-Axis"
	letter = "X"
	schrift_name = "The X-Axis"
	identity_line = "pierce all things"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/Y_The_Yourself
	name = "Y: The Yourself"
	BuffName = "Y: The Yourself"
	letter = "Y"
	schrift_name = "The Yourself"
	identity_line = "copy (two holders)"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/Y_The_Yourself/Loyd
	name = "Y: The Yourself (Loyd)"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/Y_The_Yourself/Royd
	name = "Y: The Yourself (Royd)"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/Z_The_Zombie
	name = "Z: The Zombie"
	BuffName = "Z: The Zombie"
	letter = "Z"
	schrift_name = "The Zombie"
	identity_line = "blood that commands the dead"

/proc/QuincyCapFirst(t)
	if(!t)
		return ""
	return uppertext(copytext(t, 1, 2)) + copytext(t, 2)

/proc/QuincySchriftLetters()
	return list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "L", "M", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")

/proc/QuincySchriftTypes()
	return list(\
		"A" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/A_Antithesis,\
		"B" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/B_The_Balance,\
		"C" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/C_The_Compulsory,\
		"D" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/D_The_Deathdealing,\
		"E" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/E_The_Explode,\
		"F" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/F_The_Fear,\
		"G" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/G_The_Glutton,\
		"H" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/H_The_Heat,\
		"I" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/I_The_Iron,\
		"J" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/J_The_Jail,\
		"L" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/L_The_Love,\
		"M" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/M_The_Miracle,\
		"O" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/O_The_Overkill,\
		"P" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/P_The_Power,\
		"Q" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/Q_The_Question,\
		"R" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/R_The_Roar,\
		"S" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/S_The_Superstar,\
		"T" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/T_The_Thunderbolt,\
		"U" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/U_The_Underbelly,\
		"V" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/V_The_Visionary,\
		"W" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/W_The_Wind,\
		"X" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/X_The_X_Axis,\
		"Y" = list(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/Y_The_Yourself/Loyd, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/Y_The_Yourself/Royd),\
		"Z" = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/Z_The_Zombie)

/proc/QuincySchriftTypeList()
	var/list/out = list()
	var/list/types = QuincySchriftTypes()
	for(var/l in types)
		if(types[l])
			out += types[l]
	return out

/proc/QuincySchriftLabelType(letter)
	var/list/types = QuincySchriftTypes()
	var/t = types[letter]
	if(islist(t))
		var/list/L = t
		t = L[1]
	return t

/proc/QuincySchriftName(letter)
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/S = QuincySchriftLabelType(letter)
	return S ? initial(S.schrift_name) : null

/proc/QuincySchriftIdentity(letter)
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/S = QuincySchriftLabelType(letter)
	return S ? initial(S.identity_line) : null

/proc/QuincySchriftKit(T)
	if(!ispath(T, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift))
		return list()
	if(!QuincySchriftKitCache)
		QuincySchriftKitCache = list()
	var/list/k = QuincySchriftKitCache[T]
	if(!islist(k))
		k = list()
		var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/S = new T
		for(var/p in S.kit_skills)
			var/pp = istext(p) ? text2path(p) : p
			if(ispath(pp, /obj/Skills) && !(pp in k))
				k += pp
		del S
		QuincySchriftKitCache[T] = k
	return k

/proc/QuincySchriftAllKits()
	var/list/out = list()
	for(var/T in QuincySchriftTypeList())
		out |= QuincySchriftKit(T)
	return out

/mob/proc/SchriftNeeded(letter)
	for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/S in src)
		if(S.letter == letter)
			return S
	return null

/proc/QuincySchriftHolderLists(letter)
	var/list/out = list()
	if(!letter || !islist(glob.SchriftHolders))
		return out
	var/list/e = glob.SchriftHolders[letter]
	if(!islist(e) || !e.len)
		return out
	if(islist(e[1]))
		for(var/sub in e)
			if(islist(sub))
				var/list/s = sub
				if(s.len)
					out += list(s)
	else
		out += list(e)
	return out

/proc/QuincySchriftHolderOf(letter, hkey)
	for(var/list/h in QuincySchriftHolderLists(letter))
		if(h[1] == hkey)
			return h
	return null

/proc/QuincySchriftHeldCount()
	var/n = 0
	for(var/l in QuincySchriftLetters())
		var/list/h = QuincySchriftHolderLists(l)
		n += h.len
	return n

/proc/QuincySchriftFree(letter)
	if(!(letter in QuincySchriftLetters()))
		return 0
	var/list/holders = QuincySchriftHolderLists(letter)
	if(letter == "Y")
		return holders.len < 2
	return !holders.len

/proc/QuincySchriftFreeLetters()
	var/list/out = list()
	for(var/l in QuincySchriftLetters())
		if(QuincySchriftFree(l))
			out += l
	return out

/proc/QuincySchriftFreeTwin()
	var/list/taken = list()
	for(var/list/h in QuincySchriftHolderLists("Y"))
		if(h.len >= 4)
			taken += h[4]
	if(!("Loyd" in taken))
		return "Loyd"
	if(!("Royd" in taken))
		return "Royd"
	return null

/proc/QuincySchriftClaim(letter, mob/who, twin)
	if(!letter || !who || !QuincySchriftFree(letter))
		return 0
	if(!islist(glob.SchriftHolders))
		glob.SchriftHolders = list()
	if(letter == "Y")
		var/list/L = QuincySchriftHolderLists("Y")
		L += list(list(who.key, "[who.name]", world.realtime, twin))
		glob.SchriftHolders["Y"] = L
	else
		glob.SchriftHolders[letter] = list(who.key, "[who.name]", world.realtime)
	return 1

/proc/QuincySchriftUnclaim(letter, hkey)
	var/list/holders = QuincySchriftHolderLists(letter)
	if(!holders.len)
		return null
	var/list/kept = list()
	var/list/gone
	for(var/list/h in holders)
		if(!gone && (!hkey || h[1] == hkey))
			gone = h
			continue
		kept += list(h)
	if(!gone)
		return null
	if(!kept.len)
		glob.SchriftHolders -= letter
	else if(letter == "Y")
		glob.SchriftHolders["Y"] = kept
	else
		glob.SchriftHolders[letter] = kept[1]
	return gone

/proc/Free_Schrift(letter, hkey)
	var/list/gone = QuincySchriftUnclaim(letter, hkey)
	if(!gone)
		return 0
	var/mob/Players/V = QuincyOnlineByKey(gone[1])
	if(V)
		V.QuincySyncSkills()
	return 1

/proc/QuincyHoursText(ds)
	var/m = max(1, round(ds / 600))
	var/h = round(m / 60)
	m = m % 60
	if(h)
		return "[h] hour[h == 1 ? "" : "s"][m ? " [m] minute[m == 1 ? "" : "s"]" : ""]"
	return "[m] minute[m == 1 ? "" : "s"]"

/mob/proc/QuincySchriftHeld()
	if(!src.QuincySchrift)
		return 0
	for(var/list/h in QuincySchriftHolderLists(src.QuincySchrift))
		if(h[1] == src.key || h[1] == src.ckey)
			return 1
	return 0

/mob/proc/QuincySchriftTypeFor()
	if(!src.QuincySchrift)
		return null
	var/list/types = QuincySchriftTypes()
	var/t = types[src.QuincySchrift]
	if(islist(t))
		var/list/L = t
		return src.QuincySchriftTwin == "Royd" ? L[2] : L[1]
	return t

/mob/proc/QuincyAuswahlenOwedNow()
	if(!islist(glob.QuincyAuswahlenOwed))
		return 0
	return (src.key in glob.QuincyAuswahlenOwed) || (src.ckey in glob.QuincyAuswahlenOwed)

/mob/proc/QuincyAuswahlenOwedClear()
	if(!islist(glob.QuincyAuswahlenOwed))
		return
	glob.QuincyAuswahlenOwed -= src.key
	glob.QuincyAuswahlenOwed -= src.ckey

/mob/proc/QuincySchriftLost()
	var/letter = src.QuincySchrift
	src.QuincySchrift = null
	src.QuincySchriftTwin = null
	if(QuincyAuswahlenOwedNow())
		QuincyAuswahlenOwedClear()
		src.QuincyVollstandigBlockedUntil = world.realtime + QUINCY_AUSWAHLEN_BLOCK
		src.QuincyStandspitzeOwed = 1
		src << "<font color=#9fd8ff><b>Auswahlen. The Kaiser has torn the letter [letter] from your soul.</b></font>"
	else
		src << "<font color=yellow>The letter [letter] fades from your soul.</font>"

/mob/proc/QuincyDropSkill(obj/Skills/S)
	if(!S)
		return
	if(istype(S, /obj/Skills/Buffs) && src.BuffOn(S))
		var/obj/Skills/Buffs/B = S
		B.Trigger(src, 1)
	src.DeleteSkill(S)

/mob/proc/QuincyKeepSkill(T, want)
	var/obj/Skills/have = QuincyOwnedSkill(T)
	if(want && !have)
		src.AddSkill(new T)
	else if(!want && have)
		QuincyDropSkill(have)

/mob/proc/QuincySchriftKitSync(want)
	var/list/mine = want ? QuincySchriftKit(want) : list()
	for(var/p in QuincySchriftAllKits())
		var/obj/Skills/have = QuincyOwnedSkill(p)
		if(p in mine)
			if(!have)
				src.AddSkill(new p)
		else if(have)
			QuincyDropSkill(have)

/mob/proc/QuincyStandspitzeSync()
	if(src.QuincyStandspitzeOwed)
		src.QuincyStandspitzeOwed = 0
		if(!(locate(/obj/Items/Standspitze) in src))
			new /obj/Items/Standspitze(src)
			src << "<font color=#9fd8ff>A silver arrowhead is left in your hand: the Standspitze. Strike the Kaiser with it and The Almighty goes dark.</font>"
	QuincyKeepSkill(/obj/Skills/Projectile/Quincy/Standspitze, (locate(/obj/Items/Standspitze) in src) ? 1 : 0)

/mob/proc/QuincySchriftSync()
	if(src.QuincyRank == "Kaiser" && !QuincyHoldsSeat())
		src.QuincyRank = null
		src << "<font color=yellow>The throne of the Quincy is no longer yours.</font>"
	var/kaiser = QuincyIsQuincy() && QuincyIsKaiser()
	QuincyKeepSkill(/obj/Skills/Buffs/SlotlessBuffs/The_Almighty, kaiser)
	QuincyKeepSkill(/obj/Skills/Quincy/Blut_Vene_Anhaben, kaiser && src.QuincyLevel >= QUINCY_ANHABEN_LEVEL)
	if(src.QuincySchrift && !QuincySchriftHeld())
		QuincySchriftLost()
	var/want = QuincyIsQuincy() ? QuincySchriftTypeFor() : null
	var/kept = 0
	var/list/drop = list()
	for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/S in src)
		if(want && !kept && S.type == want)
			kept = 1
			continue
		drop += S
	for(var/obj/Skills/S in drop)
		QuincyDropSkill(S)
	if(want && !kept)
		src.AddSkill(new want)
	QuincySchriftKitSync(want)
	QuincyStandspitzeSync()

/mob/Players/QuincySyncSkills()
	..()
	QuincySchriftSync()

/mob/Players/QuincyFreeRegistry()
	..()
	QuincyAuswahlenOwedClear()
	var/list/kits = QuincySchriftAllKits()
	var/list/drop = list()
	for(var/obj/Skills/S in src)
		if(istype(S, /obj/Skills/Buffs/SlotlessBuffs/The_Almighty) || istype(S, /obj/Skills/Buffs/SlotlessBuffs/Auswahlen_Surge) || istype(S, /obj/Skills/Quincy/Blut_Vene_Anhaben))
			drop += S
		else if(istype(S, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift) || istype(S, /obj/Skills/Buffs/SlotlessBuffs/Vollstandig) || istype(S, /obj/Skills/Projectile/Quincy/Standspitze))
			drop += S
		else if(S.type in kits)
			drop += S
	for(var/obj/Skills/S in drop)
		QuincyDropSkill(S)
	for(var/obj/Items/Standspitze/I in src)
		del I
	src.QuincySchriftTwin = null
	src.QuincyStandspitzeOwed = 0
	AlmightySightStop()
	src.AlmightyKnown = null

/mob/proc/QuincyEngraveTargets()
	var/list/out = list()
	for(var/mob/Players/P in oview(QUINCY_ENGRAVE_REACH, src))
		if(P == src || !P.client)
			continue
		if(!P.QuincyIsQuincy() || P.QuincyHeritage != "Echt" || P.QuincyLevel < QUINCY_ENGRAVE_LEVEL || P.QuincySchrift)
			continue
		out += P
	return out

/mob/proc/QuincyEngrave(mob/T, letter)
	if(!T || !QuincySchriftFree(letter))
		return 0
	var/twin = letter == "Y" ? QuincySchriftFreeTwin() : null
	if(letter == "Y" && !twin)
		return 0
	if(!QuincySchriftClaim(letter, T, twin))
		return 0
	T.QuincySchrift = letter
	T.QuincySchriftTwin = twin
	world << "<font color=#9fd8ff><b>[T] drinks the Kaiser's blood. The letter [letter], [QuincySchriftName(letter)], is carved into their soul.</b></font>"
	T.QuincySyncSkills()
	Log("Admin", "[ExtractInfo(src)] engraved the Schrift [letter][twin ? " ([twin])" : ""] into [ExtractInfo(T)].", 1)
	return 1

/mob/proc/QuincyEngraveStart()
	if(!QuincyIsKaiser())
		src << "Only the Kaiser can engrave a Schrift."
		return
	var/list/targets = QuincyEngraveTargets()
	if(!targets.len)
		src << "No Echt Quincy at Signature Mastery Level 6 without a letter stands within reach."
		return
	var/list/tl = PromptLabelAtoms(targets, 1)
	var/tp = Ask(src, "Whose soul will you engrave?", "Engrave Schrift", null, "pick", tl, 1)
	if(isnull(tp))
		return
	var/mob/Players/T = tl[tp]
	if(!T || !(T in QuincyEngraveTargets()))
		return
	var/list/free = QuincySchriftFreeLetters()
	if(!free.len)
		src << "Every letter is already carved into a soul."
		return
	var/list/ll = list()
	for(var/l in free)
		ll["[l]: [QuincySchriftName(l)], [QuincySchriftIdentity(l)]"] = l
	var/lp = Ask(src, "Which letter do you carve into [T]?", "Engrave Schrift", null, "pick", ll, 1)
	if(isnull(lp))
		return
	var/letter = ll[lp]
	var/answer = Ask(T, "The Kaiser holds out a cup of their blood. Drink, and the letter [letter] is carved into your soul. Accept?", "Schrift", null, "confirm", null, 1, "Accept", "Refuse")
	if(answer != "Accept")
		src << "<font color=red>[T] refuses the cup.</font>"
		if(T)
			T << "<font color=yellow>You refuse. Nothing changes.</font>"
		return
	if(!QuincyIsKaiser() || !T || !(T in QuincyEngraveTargets()))
		return
	if(!QuincySchriftFree(letter))
		src << "<font color=red>That letter was carved into another soul while you waited.</font>"
		return
	QuincyEngrave(T, letter)

/mob/proc/QuincyAuswahlen(letter, hkey)
	var/list/gone = QuincySchriftUnclaim(letter, hkey)
	if(!gone)
		src << "<font color=red>That letter has already returned to the pool.</font>"
		return 0
	if(!islist(glob.QuincyAuswahlenOwed))
		glob.QuincyAuswahlenOwed = list()
	glob.QuincyAuswahlenOwed |= gone[1]
	glob.QuincyAuswahlenAt = world.realtime
	var/mob/Players/V = QuincyOnlineByKey(gone[1])
	if(V)
		V.QuincySyncSkills()
	QuincyAuswahlenSurge()
	world << "<font color=#9fd8ff><b>The Kaiser calls Auswahlen. The letter [letter], [QuincySchriftName(letter)], is torn from [gone[2]]'s soul.</b></font>"
	Log("Admin", "[ExtractInfo(src)] called Auswahlen on [gone[2]] ([gone[1]]) and took back the Schrift [letter].", 1)
	return 1

/mob/proc/QuincyAuswahlenStart()
	if(!QuincyIsKaiser())
		src << "Only the Kaiser can call Auswahlen."
		return
	var/left = glob.QuincyAuswahlenAt + QUINCY_AUSWAHLEN_COOLDOWN - world.realtime
	if(glob.QuincyAuswahlenAt && left > 0)
		src << "Auswahlen can be called again in [QuincyHoursText(left)]."
		return
	var/list/opts = list()
	for(var/l in QuincySchriftLetters())
		for(var/list/h in QuincySchriftHolderLists(l))
			if(h.len < 2)
				continue
			opts["[l]: [QuincySchriftName(l)], [h[2]] ([h[1]])"] = list(l, h[1])
	if(!opts.len)
		src << "No soul carries a letter."
		return
	var/pick = Ask(src, "Whose letter do you take back?", "Auswahlen", null, "pick", opts, 1)
	if(isnull(pick))
		return
	var/list/c = opts[pick]
	var/confirm = Ask(src, "Call Auswahlen on [pick]? The letter returns to the pool, and Auswahlen cannot be called again for 24 hours.", "Auswahlen", null, "confirm", null, 1, "Auswahlen", "Cancel")
	if(confirm != "Auswahlen" || !QuincyIsKaiser())
		return
	QuincyAuswahlen(c[1], c[2])

/obj/Skills/Buffs/SlotlessBuffs/The_Almighty/verb/Engrave_Schrift()
	set name = "Engrave Schrift"
	set category = "Skills"
	usr.QuincyEngraveStart()

/obj/Skills/Buffs/SlotlessBuffs/The_Almighty/verb/Auswahlen()
	set name = "Auswahlen"
	set category = "Skills"
	usr.QuincyAuswahlenStart()

/mob/Admin4/verb/Schrift_Registry()
	set category = "Admin"
	set name = "Schrift Registry"
	var/list/rows = list()
	for(var/l in QuincySchriftLetters())
		var/sname = "[QuincySchriftName(l)]"
		var/list/holders = QuincySchriftHolderLists(l)
		if(!holders.len)
			rows[++rows.len] = list("t" = l, "c" = list(sname, "-", "unclaimed", "-", "-"))
			continue
		for(var/list/h in holders)
			var/tag = (l == "Y" && h.len >= 4 && h[4]) ? "Y ([h[4]])" : l
			var/when = h.len >= 3 ? "[time2text(h[3], "YYYY-MM-DD")]" : "-"
			var/online = QuincyOnlineByKey(h[1]) ? "yes" : "no"
			rows[++rows.len] = list("t" = tag, "h" = "?src=\ref[usr];action=QuincyFreeSchrift;letter=[l];hkey=[url_encode("[h[1]]")]", "c" = list(sname, "[h[1]]", "[h[2]]", when, online))
	usr.client?.TableShow("quincy:schrift", "QUINCY", "Schrift registry", "[QuincySchriftHeldCount()] of [QUINCY_SCHRIFT_SEATS] held", list(list("l" = "LETTER", "a" = "l"), list("l" = "SCHRIFT", "a" = "l"), list("l" = "HOLDER", "a" = "l"), list("l" = "NAME", "a" = "l"), list("l" = "DATE", "a" = "l"), list("l" = "ONLINE", "a" = "l")), rows, "a holder's letter to free it", null, list("nosort" = 1))

/mob/Topic(href, href_list[])
	if(href_list["action"] == "QuincyFreeSchrift")
		if(usr != src || !usr.Admin || usr.Admin < 4)
			return
		var/letter = href_list["letter"]
		var/hkey = href_list["hkey"]
		var/list/h = QuincySchriftHolderOf(letter, hkey)
		if(!h)
			usr << "<font color=red>That letter is already free.</font>"
			return
		var/confirm = Ask(usr, "Free the letter [letter] from [h[2]] ([h[1]])? They lose the Schrift and it returns to the pool.", "Free Schrift", null, "confirm", null, 1, "Free It", "Cancel")
		if(confirm != "Free It")
			return
		if(Free_Schrift(letter, hkey))
			Log("Admin", "[ExtractInfo(usr)] freed the Schrift [letter] from [h[2]] ([h[1]]).", 1)
			usr << "<font color=yellow>The letter [letter] is free again.</font>"
		return
	..()
