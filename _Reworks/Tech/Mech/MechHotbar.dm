mob/var/tmp/obj/Items/Mech/mech_loadout

/obj/Items/Mech/proc/MechLoadoutTypes()
	if(!islist(loadout_types) || loadout_types.len != HOTBAR_SLOTS)
		var/list/L = new/list(HOTBAR_SLOTS)
		for(var/i = 1 to min(length(loadout_types), HOTBAR_SLOTS))
			L[i] = loadout_types[i]
		loadout_types = L
	return loadout_types

/obj/Items/Mech/proc/MechShortcutsNew()
	MechEnsureSkills()
	shortcuts = new /shortcut
	shortcuts.shortcut1 = part_kept[/obj/Skills/Mech/Dismount]
	shortcuts.shortcut2 = part_kept[/obj/Skills/Mech/Refuel]

mob/proc/MechShortcutsOn(obj/Items/Mech/R)
	if(!R) return
	if(!R.shortcuts) R.MechShortcutsNew()
	if(!pilot_shortcuts)
		pilot_shortcuts = (shortcuts && shortcuts != R.shortcuts) ? shortcuts : new /shortcut
	R.shortcuts.keybinds = pilot_shortcuts.keybinds
	MechLoadoutResolve(R)
	shortcuts = R.shortcuts
	if(client) client.RefreshHotbar()

mob/proc/MechLoadoutResolve(obj/Items/Mech/R)
	var/list/L = R.MechLoadoutTypes()
	for(var/i = 1 to HOTBAR_SLOTS)
		var/p = L[i]
		if(!p) continue
		if(R.shortcuts.vars["shortcut[i]"]) continue
		var/obj/Skills/S = locate(p) in src
		if(S && IsMechCompatible(S))
			R.shortcuts.vars["shortcut[i]"] = S
			L[i] = null

mob/proc/MechShortcutsOff(obj/Items/Mech/R)
	if(R && R.shortcuts)
		var/list/L = R.MechLoadoutTypes()
		var/list/own = R.MechKeptSkills()
		for(var/i = 1 to HOTBAR_SLOTS)
			var/obj/Skills/S = R.shortcuts.vars["shortcut[i]"]
			if(!S) continue
			if(S in own)
				L[i] = null
				continue
			L[i] = S.type
			R.shortcuts.vars["shortcut[i]"] = null
		if(pilot_shortcuts && R.shortcuts.keybinds != pilot_shortcuts.keybinds)
			pilot_shortcuts.keybinds = R.shortcuts.keybinds
		R.shortcuts.keybinds = null
	shortcuts = pilot_shortcuts ? pilot_shortcuts : new /shortcut
	pilot_shortcuts = null
	if(client) client.RefreshHotbar()

mob/proc/MechMenuFits(obj/Skills/S, type_filter)
	if(!S || !SkillMenuVisible(S) || S.IsSpell) return 0
	if(type_filter && type_filter != "All" && SkillMenuType(S) != type_filter) return 0
	return 1

mob/Players/MechMenuSkills(type_filter)
	var/obj/Items/Mech/R = mech ? mech : mech_loadout
	if(!R) return null
	. = list()
	for(var/obj/Skills/S in R.MechKeptSkills())
		if(MechMenuFits(S, type_filter)) . += S
	if(!mech) return
	for(var/obj/Skills/S in contents)
		if(S in .) continue
		if(!IsMechCompatible(S)) continue
		if(MechMenuFits(S, type_filter)) . += S

mob/proc/MechLoadoutOpen(obj/Items/Mech/R)
	if(!R || mech) return
	if(client && client.skmenu_open) client.CloseSkillMenu()
	if(mech_loadout) MechLoadoutClose()
	R.MechEnsureSkills()
	if(!R.shortcuts) R.MechShortcutsNew()
	pilot_shortcuts = shortcuts ? shortcuts : new /shortcut
	R.shortcuts.keybinds = pilot_shortcuts.keybinds
	mech_loadout = R
	shortcuts = R.shortcuts
	src << "[R]'s loadout: drag its skills onto the hotbar, then close the skill menu."
	if(client)
		client.RefreshHotbar()
		client.OpenSkillMenu()

mob/proc/MechLoadoutClose()
	var/obj/Items/Mech/R = mech_loadout
	mech_loadout = null
	if(R && R.shortcuts)
		var/list/L = R.MechLoadoutTypes()
		for(var/i = 1 to HOTBAR_SLOTS)
			if(R.shortcuts.vars["shortcut[i]"]) L[i] = null
		if(pilot_shortcuts && R.shortcuts.keybinds != pilot_shortcuts.keybinds)
			pilot_shortcuts.keybinds = R.shortcuts.keybinds
		R.shortcuts.keybinds = null
	if(pilot_shortcuts)
		shortcuts = pilot_shortcuts
		pilot_shortcuts = null
	if(client) client.RefreshHotbar()

client/CloseSkillMenu()
	..()
	if(mob && mob.mech_loadout) mob.MechLoadoutClose()

mob/Players/Logout()
	if(mech_loadout) MechLoadoutClose()
	return ..()

/obj/LifeSkills/Station/MechBay/MechBayLoadout(mob/M, obj/Items/Mech/R)
	if(!M || !R) return
	if(M.mech)
		M << "Open [M.mech]'s loadout from the skill menu while you pilot it."
		return
	if(!MechBayValid(M, R)) return
	M.MechLoadoutOpen(R)
