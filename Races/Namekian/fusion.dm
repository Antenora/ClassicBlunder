/obj/Skills/Utility/Namekian/Namekian_Fusion
	name = "Namekian Fusion"
	desc = "Take a willing Namekian standing beside you into your body for good. Both of you must agree. Their character can never be played again and their player makes a new one, while you gain a permanent boost to all six stats."
	Copyable = 0
	var/FusionReach = 1
	var/FusionTimeout = 600
	var/FusionLogoutDelay = 15
	var/list/FusionFlash = list(0.6, 1, 0.6)
	var/FusionFlashTime = 5

	verb/Namekian_Fusion()
		set name = "Namekian Fusion"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			return
		User.NamekFusionStart(src)

/obj/Skills/Utility/Namekian/Inner_Voice
	name = "Inner Voice"
	desc = "Speak aloud with the voice of someone you carry within."
	Copyable = 0

	verb/Inner_Voice()
		set name = "Inner Voice"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			return
		User.NamekInnerVoice()

/mob/var/tmp/NamekFusionBusyUntil = 0

/proc/NamekFusionStep(slot)
	var/list/steps = NAMEK_FUSION_STEPS
	if(!isnum(slot) || slot < 1 || slot > steps.len)
		return 0
	return steps[slot]

/mob/proc/NamekFusionCount()
	return islist(src.NamekFusions) ? src.NamekFusions.len : 0

/mob/proc/NamekFusionNames()
	var/list/out = list()
	if(islist(src.NamekFusions))
		for(var/list/e in src.NamekFusions)
			out += "[e["name"]]"
	return out

/mob/proc/NamekFusionLine()
	var/list/names = NamekFusionNames()
	if(!names.len)
		return null
	return "Carries [jointext(names, ", ")] within"

/mob/proc/NamekFusionFreeSlot()
	if(NamekFusionCount() >= glob.NamekFusionCap)
		return 0
	var/list/held = list()
	if(islist(src.NamekFusions))
		for(var/list/e in src.NamekFusions)
			held += e["slot"]
	for(var/i = 1, i <= glob.NamekFusionCap, i++)
		if(!(i in held))
			return i
	return 0

/mob/proc/NamekFusionWanted()
	if(!NamekIsNamek() || !islist(src.NamekFusions))
		return 0
	var/total = 0
	for(var/list/e in src.NamekFusions)
		total += NamekFusionStep(e["slot"])
	return total

/mob/proc/NamekSyncFusion()
	if(!src.passive_handler)
		return
	var/target = NamekFusionWanted()
	var/delta = target - src.NamekFusionSteps
	if(delta)
		NamekMoveMagnified(delta)
		src.NamekFusionSteps = target

/mob/proc/NamekFusionSyncVoice()
	var/obj/Skills/have = NamekFindSkillExact(/obj/Skills/Utility/Namekian/Inner_Voice)
	var/want = NamekFusionCount() > 0
	if(want && !have)
		src.AddSkill(new /obj/Skills/Utility/Namekian/Inner_Voice)
	else if(!want && have)
		src.DeleteSkill(have)
	else
		return
	if(src.client)
		src.client.RefreshHotbar()

/mob/proc/NamekFusionTargets(reach)
	var/list/out = list()
	for(var/mob/Players/P in oview(reach, src))
		if(P == src || !P.client)
			continue
		if(!P.NamekIsNamek() || P.NamekAssimilated)
			continue
		out += P
	return out

/mob/proc/NamekFusionStart(obj/Skills/Utility/Namekian/Namekian_Fusion/S)
	if(!S || !src.client)
		return
	if(src.NamekFusionBusyUntil > world.time)
		src << "<font color=red>You are already in the middle of a fusion.</font>"
		return
	src.NamekFusionBusyUntil = world.time + S.FusionTimeout * 5
	NamekFusionOffer(S)
	src.NamekFusionBusyUntil = 0

/mob/proc/NamekFusionOffer(obj/Skills/Utility/Namekian/Namekian_Fusion/S)
	if(!NamekIsNamek())
		return
	if(src.AscensionsAcquired < 2)
		src << "<font color=red>Namekian Fusion opens at your second ascension.</font>"
		return
	if(!NamekFusionFreeSlot())
		src << "<font color=red>Your body already carries as many as it can hold.</font>"
		return
	var/list/targets = NamekFusionTargets(S.FusionReach)
	if(!targets.len)
		src << "<font color=red>No Namekian stands close enough to join with you.</font>"
		return
	var/list/tlabels = PromptLabelAtoms(targets, 1)
	var/tpick = Ask(src, "Who will join with you?", "Namekian Fusion", null, "pick", tlabels, 1)
	if(isnull(tpick))
		return
	var/mob/Players/T = tlabels[tpick]
	if(!T || !(T in NamekFusionTargets(S.FusionReach)))
		return
	var/hostText = "Take [T] into your body? If [T] accepts too, neither of you can take it back: [T] can never be played again (an admin can undo it), you gain a permanent boost to all six stats, and [T]'s player makes a new character."
	if(Ask(src, hostText, "Namekian Fusion", null, "confirm", null, 1, "Join", "Cancel") != "Join")
		return
	if(!T || !(T in NamekFusionTargets(S.FusionReach)) || !NamekFusionFreeSlot())
		src << "<font color=red>The moment has passed.</font>"
		return
	if(T.NamekFusionBusyUntil > world.time)
		src << "<font color=red>[T] is already weighing a fusion.</font>"
		return
	T.NamekFusionBusyUntil = world.time + S.FusionTimeout + 50
	src << "<font color=yellow>You offer to take [T] into your body. They have [round(S.FusionTimeout / 10)] seconds to answer.</font>"
	var/deadline = world.time + S.FusionTimeout
	var/answer = NamekFusionAskTarget(T, S.FusionTimeout)
	if(T)
		T.NamekFusionBusyUntil = 0
	if(world.time >= deadline && answer != "Accept")
		src << "<font color=red>The offer passed without an answer.</font>"
		if(T)
			T << "<font color=yellow>The offer has passed. Nothing changes.</font>"
		return
	if(answer != "Accept")
		src << "<font color=red>[T] refuses.</font>"
		if(T)
			T << "<font color=yellow>You refuse. Nothing changes.</font>"
		return
	if(!src.client || !NamekIsNamek() || !T || !(T in NamekFusionTargets(S.FusionReach)) || !NamekFusionFreeSlot())
		src << "<font color=red>The moment has passed.</font>"
		if(T)
			T << "<font color=yellow>The moment has passed. Nothing changes.</font>"
		return
	NamekFusionApply(T, S)

/mob/proc/NamekFusionAskTarget(mob/T, timeout)
	if(!T || !T.client)
		return null
	var/msg = "[src] offers to take you into their body. If you accept, [T.name] becomes part of [src] for good: this character can never be played again (an admin can undo it), [src] gains a permanent boost to all six stats, and you make a new character to keep playing. The offer closes in [round(timeout / 10)] seconds."
	var/deadline = world.time + timeout
	NamekFusionOfferExpire(T.client, "Namekian Fusion", msg, timeout)
	var/answer = Ask(T, msg, "Namekian Fusion", null, "confirm", null, 1, "Accept", "Refuse")
	if(world.time > deadline)
		return null
	return answer

/proc/NamekFusionOfferExpire(client/C, title, msg, delay)
	set waitfor = 0
	sleep(delay)
	if(C && C.np_open && C.np_title == title && C.np_msg == msg)
		C.NumPromptClose(0)

/mob/proc/NamekFusionApply(mob/Players/T, obj/Skills/Utility/Namekian/Namekian_Fusion/S)
	var/slot = NamekFusionFreeSlot()
	if(!slot || !T)
		return 0
	var/stamp = time2text(world.realtime, "MM-DD-YYYY_hh-mm-ss")
	T.NamekAssimilated = 1
	T.NamekAssimilatedInto = "[src.name]"
	ArchiveSave(T)
	if(!islist(src.NamekFusions))
		src.NamekFusions = list()
	src.NamekFusions += list(list("name" = "[T.name]", "clan" = T.Class, "key" = T.ckey, "slot" = slot, "at" = stamp))
	NamekSyncFusion()
	NamekFusionSyncVoice()
	if(src.client)
		src.client.SaveChar()
	NamekFusionFlash(src, S)
	NamekFusionFlash(T, S)
	src.OMessage(10, "[T] dissolves into light and joins with [src].", "[src]([src.key]) took [T]([T.key]) in through Namekian Fusion.")
	src << "<font color=yellow>[T] becomes part of you. You carry [NamekFusionCount()] within.</font>"
	T << "<font color=yellow>You join with [src]. [T.name] lives on within [src] now. Make a new character to keep playing.</font>"
	Log("Admin", "[ExtractInfo(src)] took [ExtractInfo(T)] in through Namekian Fusion (slot [slot], +[NamekFusionStep(slot)], archive [T.name]-[stamp]).")
	NamekFusionLogOut(T, S.FusionLogoutDelay)
	return 1

/proc/NamekFusionFlash(mob/M, obj/Skills/Utility/Namekian/Namekian_Fusion/S)
	if(!M || !S || !islist(S.FusionFlash) || S.FusionFlash.len < 3)
		return
	var/list/f = S.FusionFlash
	animate(M, color = list(1,0,0, 0,1,0, 0,0,1, f[1],f[2],f[3]), time = S.FusionFlashTime)
	animate(color = M.MobColor, time = S.FusionFlashTime)

/proc/NamekFusionLogOut(mob/T, delay)
	set waitfor = 0
	sleep(delay)
	if(T && T.client)
		del T.client

/mob/proc/NamekFusionRefuse()
	src.Savable = 0
	src << "<font color=yellow>This body exists within [src.NamekAssimilatedInto ? src.NamekAssimilatedInto : "another Namekian"] now.</font>"
	NamekFusionLogOut(src, 10)

/mob/Players/Login()
	if(src.NamekAssimilated)
		NamekFusionRefuse()
		return
	..()
	spawn(25)
		if(src)
			NamekSyncFusion()
			NamekFusionSyncVoice()

/mob/proc/NamekFusionIndex(list/E)
	if(!islist(src.NamekFusions) || !islist(E))
		return 0
	for(var/i = 1, i <= src.NamekFusions.len, i++)
		if(src.NamekFusions[i] == E)
			return i
	return 0

/mob/proc/NamekFusionRemove(list/E)
	var/found = NamekFusionIndex(E)
	if(!found)
		return 0
	src.NamekFusions.Cut(found, found + 1)
	NamekSyncFusion()
	NamekFusionSyncVoice()
	if(src.client)
		src.client.SaveChar()
	return 1

/proc/NamekFusionUnlockSave(ckey, name)
	var/path = "Saves/Players/[ckey]"
	if(!length("[ckey]") || !fexists(path))
		return "missing"
	var/savefile/F = new(path)
	var/saved
	F["name"] >> saved
	if("[saved]" != "[name]")
		return "rerolled"
	F.cd = "/mob/.0"
	var/flag
	F["NamekAssimilated"] >> flag
	if(!flag)
		return "rerolled"
	F["NamekAssimilated"] << 0
	F["NamekAssimilatedInto"] << null
	return "unlocked"

/proc/NamekFusionArchivePath(list/E)
	if(!E["at"])
		return "Saves/Players/Archives/[E["key"]]/"
	return "Saves/Players/Archives/[E["key"]]/[E["name"]]-[E["at"]]"

/mob/GetCharMenuData()
	. = ..()
	var/line = NamekFusionLine()
	if(!line || !islist(.))
		return
	var/list/D = .
	var/id = "[D["identity"]]"
	var/lead = (src.race && src.race.name) ? "[src.race.name]" : ""
	if(length(lead) && findtext(id, lead) == 1)
		D["identity"] = "[lead] - [line][copytext(id, length(lead) + 1)]"
	else
		D["identity"] = length(id) ? "[line] - [id]" : line

/mob/proc/NamekInnerVoice()
	var/list/names = NamekFusionNames()
	if(!names.len)
		src << "<font color=red>You carry no one within.</font>"
		return
	var/who = names[1]
	if(names.len > 1)
		who = Ask(src, "Whose voice?", "Inner Voice", null, "pick", names, 1)
		if(isnull(who))
			return
	var/T = Ask(src, "What does [who] say?", "Inner Voice", null, "text", null, 1)
	if(!T || !length(T))
		return
	T = src.redactBannedWords(T)
	var/message = html_encode(T)
	var/header = "[ChatPortraitTag(src)]<font color=[src.Text_Color]>[src.name]"
	var/list/wit = list()
	for(var/mob/hearer in hearers(SAY_RADIUS, src))
		if(!hearer.client)
			continue
		hearer.client.EnsurePortrait(src)
		if(hearer.SenseRobbed >= 4)
			continue
		hearer.client.outputToChat("[header][hearer.Controlz(src)] speaks with [who]'s voice: [message]", IC_OUTPUT)
		wit += hearer
	LogEvent("say", src, message, wit, null, list("noun" = "speaks with [who]'s voice:"))
	AdminListenBroadcast(src, "[src.name] speaks with [who]'s voice: [message]")
	src.Say_Spark()

/mob/Admin3/verb/Undo_Fusion()
	set category = "Admin"
	set name = "Undo Fusion"
	var/list/pool = list()
	for(var/mob/Players/P in players)
		if(P.NamekFusionCount())
			pool += P
	if(!pool.len)
		usr << "<font color=red>Nobody online carries anyone through Namekian Fusion.</font>"
		return
	var/list/lab = PromptLabelAtoms(pool, 1)
	var/hpick = Ask(usr, "Whose fusion?", "Undo Fusion", null, "pick", lab, 1)
	if(isnull(hpick))
		return
	var/mob/Players/H = lab[hpick]
	if(!H || !H.NamekFusionCount())
		return
	var/list/elab = list()
	for(var/list/e in H.NamekFusions)
		elab["[e["name"]] ([e["key"]], [e["clan"] ? e["clan"] : "no clan"], +[NamekFusionStep(e["slot"])])"] = e
	var/epick = Ask(usr, "Which character goes free?", "Undo Fusion", null, "pick", elab, 1)
	if(isnull(epick))
		return
	var/list/E = elab[epick]
	if(!H.NamekFusionIndex(E))
		return
	var/amt = NamekFusionStep(E["slot"])
	if(Ask(usr, "Free [E["name"]] from [H]? [H] loses [amt] on all six stats, and [E["name"]] can log in again if [E["key"]] still holds that character.", "Undo Fusion", null, "confirm", null, 1, "Undo", "Cancel") != "Undo")
		return
	if(!H || !H.NamekFusionIndex(E))
		return
	var/result = NamekFusionUnlockSave(E["key"], E["name"])
	H.NamekFusionRemove(E)
	H << "<font color=yellow>An admin has separated [E["name"]] from you. You carry [H.NamekFusionCount()] within.</font>"
	switch(result)
		if("unlocked")
			usr << "<font color=yellow>[E["name"]] is free and can log in on [E["key"]] again. [H] lost [amt].</font>"
		if("rerolled")
			usr << "<font color=yellow>[H] lost [amt]. [E["key"]] now holds another character, so its save was left alone. [E["name"]]'s record is the archive copy [NamekFusionArchivePath(E)].</font>"
		else
			usr << "<font color=yellow>[H] lost [amt]. [E["key"]] has no save at all. [E["name"]]'s record is the archive copy [NamekFusionArchivePath(E)].</font>"
	Log("Admin", "[ExtractInfo(usr)] undid [ExtractInfo(H)]'s Namekian Fusion with [E["name"]] ([E["key"]], -[amt]): [result].")

/mob/Admin3/verb/Fusion_Report()
	set category = "Admin"
	set name = "Fusion Report"
	var/list/rows = list()
	for(var/mob/Players/P in players)
		if(!P.NamekFusionCount())
			continue
		var/list/names = list()
		for(var/list/e in P.NamekFusions)
			names += "[e["name"]] ([e["key"]], +[NamekFusionStep(e["slot"])])"
		rows[++rows.len] = list("t" = "[P.key]", "tn" = "[P.name]", "t2" = jointext(names, ", "), "c" = list("[P.NamekFusionCount()] / [glob.NamekFusionCap]", "[round(P.NamekFusionSteps, 0.01)]"))
	usr.client?.TableShow("namekian:fusion", "NAMEKIAN", "Namekian fusions", "[rows.len] hosts online", list(list("l" = "HOST", "a" = "l"), list("l" = "CARRIES", "a" = "r"), list("l" = "STEP", "a" = "r")), rows, "", null, list("nosort" = 1))
