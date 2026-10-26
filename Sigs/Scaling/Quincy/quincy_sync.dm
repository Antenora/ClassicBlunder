/proc/QuincyLevelLine(lvl)
	switch(lvl)
		if(2)
			return "Signature Mastery Level 2: Hirenkyaku, the Ginto tubes with Heizen and Wolke, and Seele Schneider."
		if(3)
			return "Signature Mastery Level 3: Gritz, your weapon art, and the Sanrei Glove."
		if(4)
			return "Signature Mastery Level 4: Letzt Stil. Remove the glove when the fight demands it."
		if(5)
			return "Signature Mastery Level 5: Restoration, Ransotengai, and the truth of your heritage."
		if(6)
			return "Signature Mastery Level 6: the Echt reach Vollstandig, the Gemischt perfect their craft."
		if(7)
			return "Signature Mastery Level 7: the summit of the Quincy."
	return null

/mob/proc/QuincyLevelGate(lvl)
	switch(lvl)
		if(2)
			return src.Potential >= glob.progress.SAGA_T2_POT
		if(3)
			return src.Potential >= QUINCY_SML3_POT
		if(4)
			return src.Potential >= glob.progress.SAGA_T4_POT && src.QuincyGloveMastery >= QUINCY_GLOVE_MASTERY
		if(5)
			if(src.Potential < glob.progress.SAGA_T5_POT)
				return 0
			if(!src.QuincyGloveBroken)
				src << "<font color=yellow>The glove still binds your power. Break it.</font>"
				return 0
			return 1
		if(6)
			return src.Potential >= glob.progress.SAGA_T6_POT
		if(7)
			return src.QuincyAdminPermission > 0
	return 0

/mob/proc/QuincyLevelCheck()
	if(!QuincyIsQuincy())
		return
	var/raised = 0
	while(src.QuincyLevel < QUINCY_LEVEL_MAX)
		var/next = src.QuincyLevel + 1
		if(!QuincyLevelGate(next))
			break
		if(next == 7)
			src.QuincyAdminPermission = max(0, src.QuincyAdminPermission - 1)
		src.QuincyLevel = next
		raised = 1
		var/line = QuincyLevelLine(next)
		if(line)
			src << "<font color=#9fd8ff><b>[line]</b></font>"
	if(raised)
		QuincySyncSkills()

/mob/proc/QuincyOwnedSkill(T)
	for(var/obj/Skills/S in src)
		if(S.type == T)
			return S
	return null

/mob/proc/QuincyWantsSkill(list/row)
	if(!QuincyIsQuincy())
		return 0
	if(src.QuincyLevel < row[2])
		return 0
	if(row[3] && row[3] != src.QuincyWeapon)
		return 0
	if(row[4] && row[4] != src.QuincyHeritage)
		return 0
	return 1

/mob/proc/QuincySyncSkills()
	var/list/table = QuincyManagedSkillTypes()
	for(var/T in table)
		var/obj/Skills/have = QuincyOwnedSkill(T)
		var/want = QuincyWantsSkill(table[T])
		if(want && !have)
			src.AddSkill(new T)
		else if(!want && have)
			if(istype(have, /obj/Skills/Buffs) && src.BuffOn(have))
				var/obj/Skills/Buffs/B = have
				B.Trigger(src, 1)
			src.DeleteSkill(have)
	if(src.client)
		src.client.RefreshHotbarCharges()

/mob/proc/QuincyClearStrayWeapons()
	for(var/obj/Items/Gun/Quincy/G in src)
		if(G == src.QuincyWeaponItem && src.SpecialBuff && src.SpecialBuff.MakesGun)
			continue
		if(G.suffix)
			G.PermEquip = 0
			G.GunAlignEquip(src)
		del G

/mob/Players/CheckAscensions()
	..()
	if(QuincyIsQuincy())
		QuincyLevelCheck()
		QuincySyncSkills()

/mob/Players/Login()
	..()
	spawn(20)
		if(src && QuincyIsQuincy())
			QuincyClearStrayWeapons()
			QuincySyncSkills()
