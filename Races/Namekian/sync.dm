/mob/proc/NamekMoveMagnified(amount)
	if(!amount || !src.passive_handler)
		return
	var/list/move = list("MagnifiedStr" = amount, "MagnifiedEnd" = amount, "MagnifiedFor" = amount, "MagnifiedSpd" = amount, "MagnifiedOff" = amount, "MagnifiedDef" = amount)
	src.passive_handler.increaseList(move)

/mob/proc/NamekSyncPower()
	if(!NamekIsNamek() || !src.passive_handler)
		return
	var/target = NamekShare(src) * NamekLadderBody(src.Potential)
	var/delta = target - src.NamekEvoApplied
	if(delta)
		NamekMoveMagnified(delta)
		src.NamekEvoApplied = target
	if(src.Potential >= NAMEK_FORM_POTENTIAL)
		src.transUnlocked = max(src.transUnlocked, 1)

/mob/proc/NamekWantedSkillTypes()
	var/list/want = list()
	var/list/drop = list()
	for(var/list/row in NamekSkillRows)
		if(row[1] && row[1] != src.Class)
			continue
		if(row[2] && row[2] != src.NamekPath)
			continue
		if(row[3] > src.AscensionsAcquired)
			continue
		var/T = text2path(row[4])
		if(!ispath(T))
			continue
		want |= T
		if(row.len >= 5 && row[5])
			var/R = text2path(row[5])
			if(ispath(R))
				drop |= R
	want -= drop
	return want

/mob/proc/NamekFindSkillExact(T)
	for(var/obj/Skills/S in src.contents)
		if(S.type == T)
			return S
	return null

/mob/proc/NamekDropSkill(obj/Skills/S)
	if(!S)
		return
	if(istype(S, /obj/Skills/Buffs) && src.BuffOn(S))
		var/obj/Skills/Buffs/B = S
		B.Trigger(src, Override = 1)
	src.DeleteSkill(S)

/mob/proc/NamekSyncSkills()
	if(!NamekIsNamek())
		return
	var/list/want = NamekWantedSkillTypes()
	var/changed = 0
	for(var/T in NamekManagedSkillTypes())
		var/obj/Skills/have = NamekFindSkillExact(T)
		if((T in want) && !have)
			src.AddSkill(new T)
			changed = 1
		else if(!(T in want) && have)
			NamekDropSkill(have)
			changed = 1
	if(changed && src.client)
		src.client.RefreshHotbar()

/mob/proc/NamekSyncForms()
	if(!NamekIsNamek() || !src.race || !islist(src.race.transformations))
		return
	var/keep = text2path(NamekFormForClan(src.Class))
	for(var/transformation/t in src.race.transformations.Copy())
		if(!istype(t, /transformation/namekian))
			continue
		if(keep && t.type == keep)
			continue
		if(t.is_active)
			continue
		src.race.transformations -= t
		del t

/mob/proc/NamekSyncAll()
	if(!NamekIsNamek())
		return
	NamekSyncPower()
	NamekSyncForms()
	NamekSyncSkills()

/mob/proc/NamekReleaseAll()
	if(src.NamekEvoApplied)
		NamekMoveMagnified(-src.NamekEvoApplied)
		src.NamekEvoApplied = 0
	for(var/T in NamekManagedSkillTypes())
		var/obj/Skills/have = NamekFindSkillExact(T)
		if(have)
			NamekDropSkill(have)
	src.NamekPath = null
	if(src.client)
		src.client.RefreshHotbar()

/mob/proc/NamekSetPath(newpath)
	if(!NamekIsNamek() || src.NamekPath == newpath)
		return 0
	var/top = min(src.AscensionsAcquired, 6)
	for(var/i = 1, i <= top, i++)
		var/list/had = NamekPathPassives(src.NamekPath, i)
		if(had.len)
			src.passive_handler.decreaseList(had)
		var/list/gain = NamekPathPassives(newpath, i)
		if(gain.len)
			src.passive_handler.increaseList(gain)
	src.NamekPath = newpath
	if(src.race && islist(src.race.ascensions))
		for(var/ascension/namekian/a in src.race.ascensions)
			if(!a.applied)
				continue
			a.simulateChoiceMutation(src)
			if(a.NamekIndex() != 1)
				continue
			if(newpath && NamekPathType(newpath))
				var/subtype = NamekPathType(newpath)
				var/ascension/sub_ascension/namekian/sub = new subtype
				sub.passives = NamekPathPassives(newpath, 1)
				sub.applied = TRUE
				a.choiceSelected = sub
			else
				a.choiceSelected = null
	NamekSyncAll()
	return 1

/mob/Players/CheckAscensions()
	..()
	if(NamekIsNamek())
		NamekSyncAll()

/mob/Players/Login()
	..()
	spawn(20)
		if(src && NamekIsNamek())
			NamekSyncAll()
