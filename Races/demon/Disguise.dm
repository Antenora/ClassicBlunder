/datum/demon_identity
	var/identity_name = ""
	var/icon/identity_icon = null
	var/identity_icon_x = 0
	var/identity_icon_y = 0
	var/identity_profile = null
	var/identity_text_color = null
	var/identity_scent = null

/obj/Skills/Buffs/SlotlessBuffs/Racial/Demon/Disguise
	BuffName = "Disguise"
	Cooldown = -1
	TimerLimit = 0
	passives = list()
	ActiveMessage = "shifts their appearance, becoming someone else entirely."
	OffMessage = "drops their disguise, revealing their true self."
	var/list/identities = list()
	var/datum/demon_identity/active_identity = null
	var/old_scent = null

	Trigger(mob/User, Override = FALSE)
		var/was_on = User.BuffOn(src)
		. = ..()
		var/is_on = User.BuffOn(src)
		// Scent swap on activation
		if(!was_on && is_on && active_identity)
			if(active_identity.identity_scent)
				old_scent = User.custom_scent
				User.custom_scent = active_identity.identity_scent
		// Scent restore on deactivation
		else if(was_on && !is_on)
			if(old_scent != null)
				User.custom_scent = old_scent
				old_scent = null
			else if(active_identity && active_identity.identity_scent)
				User.custom_scent = null

	verb/Create_Identity()
		set category = "Roleplay"
		set hidden = 1
		set name = "Create Identity"
		if(!usr || usr.Dead) return
		if(identities.len >= 5)
			usr << "You can only maintain up to 5 disguise identities. Delete one first."
			return
		var/new_name = input(usr, "What name will this identity go by?", "Create Identity") as text|null
		if(!new_name) return
		for(var/datum/demon_identity/existing in identities)
			if(existing.identity_name == new_name)
				usr << "You already have an identity named [new_name]."
				return
		var/datum/demon_identity/id = new()
		id.identity_name = new_name
		id.identity_icon = input(usr, "What icon will this identity use? (Cancel for no icon change)", "Create Identity") as icon|null
		if(id.identity_icon)
			id.identity_icon_x = input(usr, "Pixel X offset.", "Create Identity") as num
			id.identity_icon_y = input(usr, "Pixel Y offset.", "Create Identity") as num
		id.identity_profile = input(usr, "Write a profile description for this identity. (Cancel for none)", "Create Identity") as message|null
		id.identity_text_color = input(usr, "Pick a text color for this identity. (Cancel for default)", "Create Identity") as color|null
		var/pick_scent = input(usr, "Choose a scent for this identity?", "Create Identity") in list("Yes", "No")
		if(pick_scent == "Yes")
			var/category = input(usr, "What scent category?") in scents
			id.identity_scent = input(usr, "What scent?") in scents[category]
		identities += id
		active_identity = id
		usr << "Identity <b>[new_name]</b> created and selected."

	verb/Select_Identity()
		set category = "Roleplay"
		set hidden = 1
		set name = "Select Identity"
		if(!usr || usr.Dead) return
		if(!identities.len)
			usr << "You have no saved identities. Use Create Identity first."
			return
		if(usr.BuffOn(src))
			usr << "Drop your current disguise before switching identities."
			return
		var/list/names = list()
		for(var/datum/demon_identity/id in identities)
			names += id.identity_name
		var/choice = input(usr, "Which identity do you want to use?", "Select Identity") in names + list("Cancel")
		if(choice == "Cancel") return
		for(var/datum/demon_identity/id in identities)
			if(id.identity_name == choice)
				active_identity = id
				usr << "Identity set to <b>[choice]</b>."
				return

	verb/Delete_Identity()
		set category = "Roleplay"
		set hidden = 1
		set name = "Delete Identity"
		if(!usr || usr.Dead) return
		if(!identities.len)
			usr << "You have no saved identities."
			return
		var/list/names = list()
		for(var/datum/demon_identity/id in identities)
			names += id.identity_name
		var/choice = input(usr, "Which identity do you want to delete?", "Delete Identity") in names + list("Cancel")
		if(choice == "Cancel") return
		for(var/datum/demon_identity/id in identities)
			if(id.identity_name == choice)
				if(usr.BuffOn(src) && active_identity == id)
					usr << "You can't delete your active disguise. Drop it first."
					return
				identities -= id
				if(active_identity == id)
					active_identity = null
				usr << "Identity <b>[choice]</b> deleted."
				del(id)
				return

	verb/Disguise()
		set category = "Roleplay"
		set hidden = 1
		if(!usr || usr.Dead) return
		if(!active_identity)
			usr << "You have no identity selected. Use Create Identity or Select Identity first."
			return
		if(!usr.BuffOn(src))
			if(usr.Imitating)
				usr << "You cannot disguise yourself while imitating someone."
				return
			if(usr.isInDemonDevilTrigger())
				usr << "You cannot disguise yourself while in Devil Trigger."
				return
			if(usr.CheckSlotless("True Form"))
				usr << "You cannot disguise yourself while in True Form."
				return
			NameFake = active_identity.identity_name
			if(active_identity.identity_icon)
				icon = active_identity.identity_icon
				pixel_x = active_identity.identity_icon_x
				pixel_y = active_identity.identity_icon_y
				IconReplace = 1
			else
				IconReplace = 0
			if(active_identity.identity_profile)
				ProfileChange = active_identity.identity_profile
			else
				ProfileChange = null
			if(active_identity.identity_text_color)
				FakeTextColor = active_identity.identity_text_color
			else
				FakeTextColor = null
		src.Trigger(usr)

/datum/demon_ego
	var/ego_name = ""
	var/icon/ego_icon = null
	var/ego_icon_x = 0
	var/ego_icon_y = 0
	var/ego_profile = null
	var/ego_text_color = null
	var/ego_scent = null
	var/ego_circle = null

/obj/Skills/Buffs/SlotlessBuffs/Racial/Demon/AlterEgo
	BuffName = "Alter Ego"
	Cooldown = -1
	TimerLimit = 0
	passives = list()
	ActiveMessage = "shifts their appearance, becoming someone else entirely."
	OffMessage = "shifts their appearance, becoming someone else entirely."
	var/list/egos = list()
	var/datum/demon_ego/active_ego = null
	var/old_scent = null
	var/old_circle = null

	Trigger(mob/User, Override = FALSE)
		var/was_on = User.BuffOn(src)
		. = ..()
		var/is_on = User.BuffOn(src)
		// Scent swap on activation
		if(!was_on && is_on && active_ego)
			if(active_ego.ego_scent)
				old_scent = User.custom_scent
				User.custom_scent = active_ego.ego_scent
			if(active_ego.ego_circle)
				old_circle = User.SpawnArea
				User.SpawnArea = active_ego.ego_circle
		// Scent restore on deactivation
		else if(was_on && !is_on)
			if(old_scent != null)
				User.custom_scent = old_scent
				old_scent = null
			else if(active_ego && active_ego.ego_scent)
				User.custom_scent = null
			if(old_circle != null)
				User.SpawnArea = old_circle
				old_circle = null
			else if(active_ego && active_ego.ego_circle)
				User.SpawnArea = null
	verb/Create_Ego()
		set category = "Roleplay"
		set hidden = 1
		set name = "Create Ego"
		if(!usr || usr.Dead) return
		if(egos.len >= 1)
			usr << "You can only maintain up to one ego. Delete one first."
			return
		var/new_name = input(usr, "What name will this ego go by?", "Create Ego") as text|null
		if(!new_name) return
		for(var/datum/demon_ego/existing in egos)
			if(existing.ego_name == new_name)
				usr << "You already have an ego named [new_name]."
				return
		var/datum/demon_ego/id = new()
		id.ego_name = new_name
		id.ego_icon = input(usr, "What icon will this ego use? (Cancel for no icon change)", "Create Ego") as icon|null
		if(id.ego_icon)
			id.ego_icon_x = input(usr, "Pixel X offset.", "Create Ego") as num
			id.ego_icon_y = input(usr, "Pixel Y offset.", "Create Ego") as num
		id.ego_profile = input(usr, "Write a profile description for this ego. (Cancel for none)", "Create Ego") as message|null
		id.ego_text_color = input(usr, "Pick a text color for this ego. (Cancel for default)", "Create Ego") as color|null
		var/pick_scent = input(usr, "Choose a scent for this ego?", "Create Ego") in list("Yes", "No")
		if(pick_scent == "Yes")
			var/category = input(usr, "What scent category?") in scents
			id.ego_scent = input(usr, "What scent?") in scents[category]
		id.ego_circle = input(usr, "What Origin will this ego go by?", "Create Ego") as text|null
		egos += id
		active_ego = id
		usr << "Ego <b>[new_name]</b> created and selected."

	verb/Select_Ego()
		set category = "Roleplay"
		set hidden = 1
		set name = "Select Ego"
		if(!usr || usr.Dead) return
		if(!egos.len)
			usr << "You have no saved egos. Use Create Ego first."
			return
		if(usr.BuffOn(src))
			usr << "Drop your current ego."
			return
		var/list/names = list()
		for(var/datum/demon_ego/id in egos)
			names += id.ego_name
		var/choice = input(usr, "Which ego do you want to use?", "Select Ego") in names + list("Cancel")
		if(choice == "Cancel") return
		for(var/datum/demon_ego/id in egos)
			if(id.ego_name == choice)
				active_ego = id
				usr << "Ego set to <b>[choice]</b>."
				return

	verb/Delete_Ego()
		set category = "Roleplay"
		set hidden = 1
		set name = "Delete Ego"
		if(!usr || usr.Dead) return
		if(!egos.len)
			usr << "You have no saved egos."
			return
		var/list/names = list()
		for(var/datum/demon_ego/id in egos)
			names += id.ego_name
		var/choice = input(usr, "Which ego do you want to delete?", "Delete Ego") in names + list("Cancel")
		if(choice == "Cancel") return
		for(var/datum/demon_ego/id in egos)
			if(id.ego_name == choice)
				if(usr.BuffOn(src) && active_ego == id)
					usr << "You can't delete your active ego. Drop it first."
					return
				egos -= id
				if(active_ego == id)
					active_ego = null
				usr << "Ego <b>[choice]</b> deleted."
				del(id)
				return

	verb/AlterEgo()
		set category = "Roleplay"
		set hidden = 1
		if(!usr || usr.Dead) return
		if(!active_ego)
			usr << "You have no ego selected. Use Create Ego or Select Ego first."
			return
		if(!usr.BuffOn(src))
			if(usr.Imitating)
				usr << "You cannot shift yourself while imitating someone."
				return
			NameFake = active_ego.ego_name
			if(active_ego.ego_icon)
				icon = active_ego.ego_icon
				pixel_x = active_ego.ego_icon_x
				pixel_y = active_ego.ego_icon_y
				IconReplace = 1
			else
				IconReplace = 0
			if(active_ego.ego_profile)
				ProfileChange = active_ego.ego_profile
			else
				ProfileChange = null
			if(active_ego.ego_text_color)
				FakeTextColor = active_ego.ego_text_color
			else
				FakeTextColor = null
		if(usr.BuffOn(src))
			if(usr.Imitating)
				usr << "You cannot shift yourself while imitating someone."
				return
		src.Trigger(usr)