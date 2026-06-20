proc/getBakudoSpells()
	return list(
		list("name"="Sai",
		     "path"="/obj/Skills/AutoHit/Bakudo/Sai",
		     "tier"=1, "requires"=null),
		list("name"="Hainawa",
		     "path"="/obj/Skills/Bakudo/Hainawa",
		     "tier"=1, "requires"=null),
		list("name"="Seki",
		     "path"="/obj/Skills/Buffs/ActiveBuffs/Bakudo/Seki",
		     "tier"=1, "requires"=null),
		list("name"="Shitotsu Sansen",
		     "path"="/obj/Skills/Projectile/Bakudo/Shitotsu_Sansen",
		     "tier"=2, "requires"=null),
		list("name"="Enkousen",
		     "path"="/obj/Skills/Buffs/ActiveBuffs/Bakudo/Enkousen",
		     "tier"=2, "requires"=null),
		list("name"="Rikujoukourou",
		     "path"="/obj/Skills/AutoHit/Bakudo/Rikujoukourou",
		     "tier"=3, "requires"=null),
		list("name"="Hyapporankan",
		     "path"="/obj/Skills/Projectile/Bakudo/Hyapporankan",
		     "tier"=3, "requires"=null),
		list("name"="Sajou Sabaku",
		     "path"="/obj/Skills/AutoHit/Bakudo/Sajou_Sabaku",
		     "tier"=3, "requires"=null),
		list("name"="Touzanshou",
		     "path"="/obj/Skills/AutoHit/Bakudo/Touzanshou",
		     "tier"=4, "requires"=null),
		list("name"="Tenteikura",
		     "path"="/obj/Skills/Bakudo/Tenteikura",
		     "tier"=4, "requires"=null),
		list("name"="Kuyou Shibari",
		     "path"="/obj/Skills/Bakudo/Kuyou_Shibari",
		     "tier"=5, "requires"=null),
		list("name"="Danku",
		     "path"="/obj/Skills/Bakudo/Danku",
		     "tier"=5, "requires"=null)
	)

proc/getHohoSkills()
	return list(
		list("name"="Shunpo",
		     "path"="/obj/Skills/Hoho/Shunpo",
		     "tier"=1, "requires"=null),
		list("name"="Shunpo Mastery I",
		     "path"="/obj/Skills/Hoho/Shunpo_Upgrade1",
		     "tier"=1, "requires"="/obj/Skills/Hoho/Shunpo"),
		list("name"="Shunpo Mastery II",
		     "path"="/obj/Skills/Hoho/Shunpo_Upgrade2",
		     "tier"=2, "requires"="/obj/Skills/Hoho/Shunpo_Upgrade1"),
		list("name"="Shunpo Mastery III",
		     "path"="/obj/Skills/Hoho/Shunpo_Upgrade3",
		     "tier"=3, "requires"="/obj/Skills/Hoho/Shunpo_Upgrade2"),
		list("name"="Shunpo Mastery IV",
		     "path"="/obj/Skills/Hoho/Shunpo_Upgrade4",
		     "tier"=4, "requires"="/obj/Skills/Hoho/Shunpo_Upgrade3"),
		list("name"="Senka",
		     "path"="/obj/Skills/AutoHit/Hoho/Senka",
		     "tier"=2, "requires"="/obj/Skills/Hoho/Shunpo_Upgrade1"),
		list("name"="Utsusemi",
		     "path"="/obj/Skills/Hoho/Utsusemi",
		     "tier"=3, "requires"="/obj/Skills/Hoho/Shunpo_Upgrade2"),
		list("name"="Speed Clones",
		     "path"="/obj/Skills/Hoho/Speed_Clones",
		     "tier"=4, "requires"="/obj/Skills/Hoho/Utsusemi")
	)

proc/getHadoSpells()
	return list(
		list("name"="Sho",
		     "path"="/obj/Skills/Projectile/Hado/Sho",
		     "tier"=1, "requires"=null),
		list("name"="Byakurai",
		     "path"="/obj/Skills/Projectile/Hado/Byakurai",
		     "tier"=1, "requires"=null),
		list("name"="Tsuzuri Raiden",
		     "path"="/obj/Skills/Buffs/ActiveBuffs/Hado/Tsuzuri_Raiden",
		     "tier"=1, "requires"=null),
		list("name"="Shakkahou",
		     "path"="/obj/Skills/Projectile/Hado/Shakkahou",
		     "tier"=2, "requires"=null),
		list("name"="Oukasen",
		     "path"="/obj/Skills/Projectile/Hado/Oukasen",
		     "tier"=2, "requires"=null),
		list("name"="Soukatsui",
		     "path"="/obj/Skills/Projectile/Hado/Soukatsui",
		     "tier"=2, "requires"=null),
		list("name"="Haien",
		     "path"="/obj/Skills/Projectile/Hado/Haien",
		     "tier"=3, "requires"=null),
		list("name"="Tenran",
		     "path"="/obj/Skills/Projectile/Hado/Tenran",
		     "tier"=3, "requires"=null),
		list("name"="Raikouhou",
		     "path"="/obj/Skills/AutoHit/Hado/Raikouhou",
		     "tier"=4, "requires"=null),
		list("name"="Souren Soukatsui",
		     "path"="/obj/Skills/Projectile/Hado/Souren_Soukatsui",
		     "tier"=4,
		     "requires"="/obj/Skills/Projectile/Hado/Soukatsui"),
		list("name"="Zangerin",
		     "path"="/obj/Skills/AutoHit/Hado/Zangerin",
		     "tier"=4, "requires"=null),
		list("name"="Hiryu Gekizoku Shinten Raihou",
		     "path"="/obj/Skills/Projectile/Hado/Hiryu",
		     "tier"=5, "requires"=null),
		list("name"="Senju Kouten Taihou",
		     "path"="/obj/Skills/Projectile/Hado/Senju_Kouten_Taihou",
		     "tier"=5, "requires"=null),
		list("name"="Itto Kaso",
		     "path"="/obj/Skills/AutoHit/Hado/Itto_Kaso",
		     "tier"=5, "requires"=null)
	)

// Returns which pick slot is currently available for this user and the associated tier cap.
// Slots are consumed in ascending order (SL1 before SL3, etc.).
proc/getKidoPickSlot(mob/User)
	if(User.SagaLevel >= 1 && User.KidoSL1Picks < 2)
		return list("tierCap"=1, "slot"="KidoSL1Picks")
	if(User.SagaLevel >= 3 && User.KidoSL3Picks < 2)
		return list("tierCap"=2, "slot"="KidoSL3Picks")
	if(User.SagaLevel >= 5 && User.KidoSL5Picks < 1)
		return list("tierCap"=3, "slot"="KidoSL5Picks")
	if(User.SagaLevel >= 6 && User.KidoSL6Picks < 1)
		return list("tierCap"=4, "slot"="KidoSL6Picks")
	if(User.SagaLevel >= 7 && User.KidoSL7Picks < 1)
		return list("tierCap"=5, "slot"="KidoSL7Picks")
	return null

// How many picks remain in the current slot after a pick is spent.
proc/getKidoPicksRemaining(mob/User)
	if(User.SagaLevel >= 1 && User.KidoSL1Picks < 2)
		return 2 - User.KidoSL1Picks - 1
	if(User.SagaLevel >= 3 && User.KidoSL3Picks < 2)
		return 2 - User.KidoSL3Picks - 1
	return 0

/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form
	var/tmp/KidoSelecting = FALSE

	verb/Learn_Hado()
		set name = "Learn Hado"
		set category = "Shinigami"
		var/mob/User = usr
		if(User.Saga != "Shinigami")
			return

		if(KidoSelecting)
			User << "You are already selecting a Kidō spell."
			return
		KidoSelecting = TRUE

		var/list/pickSlot = getKidoPickSlot(User)
		if(!pickSlot)
			User << "You have no Hadō selections available."
			KidoSelecting = FALSE
			return

		var/tierCap = pickSlot["tierCap"]

		var/list/options = list()
		for(var/list/spell in getHadoSpells())
			if(spell["tier"] > tierCap) continue
			var/path = text2path(spell["path"])
			if(!path) continue
			if(locate(path, User)) continue
			if(spell["requires"])
				var/reqPath = text2path(spell["requires"])
				if(!locate(reqPath, User)) continue
			options[spell["name"]] = path

		if(!options.len)
			User << "You have already learned all eligible Hadō (Tier [tierCap] or lower)."
			KidoSelecting = FALSE
			return

		var/choice = input(User, "Select a Hadō spell to learn. (Tier [tierCap] cap)", "Learn Hadō") as null|anything in options
		if(!choice)
			KidoSelecting = FALSE
			return

		var/chosenPath = options[choice]
		User.AddSkill(new chosenPath)
		User << "You learn <b>[choice]</b>!"

		var/slot = pickSlot["slot"]
		switch(slot)
			if("KidoSL1Picks") User.KidoSL1Picks++
			if("KidoSL3Picks") User.KidoSL3Picks++
			if("KidoSL5Picks") User.KidoSL5Picks++
			if("KidoSL6Picks") User.KidoSL6Picks++
			if("KidoSL7Picks") User.KidoSL7Picks++

		var/remaining = 0
		switch(slot)
			if("KidoSL1Picks") remaining = 2 - User.KidoSL1Picks
			if("KidoSL3Picks") remaining = 2 - User.KidoSL3Picks
		if(remaining > 0)
			User << "You have [remaining] Hadō selection\s remaining."

		KidoSelecting = FALSE

	verb/Learn_Bakudo()
		set name = "Learn Bakudo"
		set category = "Shinigami"
		var/mob/User = usr
		if(User.Saga != "Shinigami")
			return

		if(KidoSelecting)
			User << "You are already selecting a Kidō spell."
			return
		KidoSelecting = TRUE

		var/list/pickSlot = getKidoPickSlot(User)
		if(!pickSlot)
			User << "You have no Bakudō selections available."
			KidoSelecting = FALSE
			return

		var/tierCap = pickSlot["tierCap"]

		var/list/options = list()
		for(var/list/spell in getBakudoSpells())
			if(spell["tier"] > tierCap) continue
			var/path = text2path(spell["path"])
			if(!path) continue
			if(locate(path, User)) continue
			if(spell["requires"])
				var/reqPath = text2path(spell["requires"])
				if(!locate(reqPath, User)) continue
			options[spell["name"]] = path

		if(!options.len)
			User << "You have already learned all eligible Bakudō (Tier [tierCap] or lower)."
			KidoSelecting = FALSE
			return

		var/choice = input(User, "Select a Bakudō spell to learn. (Tier [tierCap] cap)", "Learn Bakudō") as null|anything in options
		if(!choice)
			KidoSelecting = FALSE
			return

		var/chosenPath = options[choice]
		User.AddSkill(new chosenPath)
		User << "You learn <b>[choice]</b>!"

		var/slot = pickSlot["slot"]
		switch(slot)
			if("KidoSL1Picks") User.KidoSL1Picks++
			if("KidoSL3Picks") User.KidoSL3Picks++
			if("KidoSL5Picks") User.KidoSL5Picks++
			if("KidoSL6Picks") User.KidoSL6Picks++
			if("KidoSL7Picks") User.KidoSL7Picks++

		var/remaining = 0
		switch(slot)
			if("KidoSL1Picks") remaining = 2 - User.KidoSL1Picks
			if("KidoSL3Picks") remaining = 2 - User.KidoSL3Picks
		if(remaining > 0)
			User << "You have [remaining] Bakudō selection\s remaining."

		KidoSelecting = FALSE

	verb/Learn_Hoho()
		set name = "Learn Hoho"
		set category = "Shinigami"
		var/mob/User = usr
		if(User.Saga != "Shinigami")
			return

		if(KidoSelecting)
			User << "You are already selecting a Kidō skill."
			return
		KidoSelecting = TRUE

		var/list/pickSlot = getKidoPickSlot(User)
		if(!pickSlot)
			User << "You have no Hohō selections available."
			KidoSelecting = FALSE
			return

		var/tierCap = pickSlot["tierCap"]

		var/list/options = list()
		for(var/list/skill in getHohoSkills())
			if(skill["tier"] > tierCap) continue
			var/path = text2path(skill["path"])
			if(!path) continue
			if(locate(path, User)) continue
			if(skill["requires"])
				var/reqPath = text2path(skill["requires"])
				if(!locate(reqPath, User)) continue
			options[skill["name"]] = path

		if(!options.len)
			User << "You have already learned all eligible Hohō (Tier [tierCap] or lower)."
			KidoSelecting = FALSE
			return

		var/choice = input(User, "Select a Hohō skill to learn. (Tier [tierCap] cap)", "Learn Hohō") as null|anything in options
		if(!choice)
			KidoSelecting = FALSE
			return

		var/chosenPath = options[choice]
		User.AddSkill(new chosenPath)
		User << "You learn <b>[choice]</b>!"

		var/slot = pickSlot["slot"]
		switch(slot)
			if("KidoSL1Picks") User.KidoSL1Picks++
			if("KidoSL3Picks") User.KidoSL3Picks++
			if("KidoSL5Picks") User.KidoSL5Picks++
			if("KidoSL6Picks") User.KidoSL6Picks++
			if("KidoSL7Picks") User.KidoSL7Picks++

		var/remaining = 0
		switch(slot)
			if("KidoSL1Picks") remaining = 2 - User.KidoSL1Picks
			if("KidoSL3Picks") remaining = 2 - User.KidoSL3Picks
		if(remaining > 0)
			User << "You have [remaining] Hohō selection\s remaining."

		KidoSelecting = FALSE

	verb/Learn_Hakuda()
		set name = "Learn Hakuda"
		set category = "Shinigami"
		usr << "Hakuda instruction is not yet available."
