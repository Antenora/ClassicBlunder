#define HOGYOKU_REACH 2

/obj/Items/Hogyoku
	name = "Hogyoku"
	desc = "It is listening for what you want."
	icon = 'Icons/LifeSkills/Geode.dmi'
	icon_state = "geode"
	Savable = 1
	Grabbable = 1
	Destructable = 0
	Stealable = 0
	PermEquip = 1
	Unobtainable = 1
	Cost = 0

	Click()
		if(!usr || src.loc != usr)
			return
		usr.HogyokuUse(src)

/proc/HollowResurreccionIds()
	var/list/out = list()
	for(var/T in typesof(/obj/Skills/Buffs/SpecialBuffs/Resurreccion) - /obj/Skills/Buffs/SpecialBuffs/Resurreccion)
		var/obj/Skills/Buffs/SpecialBuffs/Resurreccion/R = T
		var/id = initial(R.res_id)
		if(id && !(id in out))
			out[id] = T
	return out

/proc/HollowResurreccionHolder(id)
	if(!id || !islist(glob.ResurreccionHolders))
		return null
	return glob.ResurreccionHolders[id]

/proc/HollowResurreccionUnclaimed()
	var/list/all = HollowResurreccionIds()
	var/list/out = list()
	for(var/id in all)
		if(!HollowResurreccionHolder(id))
			out[id] = all[id]
	return out

/proc/HollowResurreccionClaim(id, mob/who)
	if(!id || !who)
		return 0
	if(!islist(glob.ResurreccionHolders))
		glob.ResurreccionHolders = list()
	if(glob.ResurreccionHolders[id])
		return 0
	glob.ResurreccionHolders[id] = list(who.key, "[who.name]", world.realtime)
	return 1

/proc/HollowResurreccionFree(id)
	if(!id || !islist(glob.ResurreccionHolders))
		return 0
	if(!glob.ResurreccionHolders[id])
		return 0
	var/list/entry = glob.ResurreccionHolders[id]
	glob.ResurreccionHolders -= id
	for(var/mob/Players/P in players)
		if(P.key == entry[1] && P.HollowResId == id)
			P.HollowSealReleases()
			P.HollowResId = null
			P.HollowSyncSkills()
			P << "<font color=yellow>Your Resurreccion has been taken back.</font>"
	return 1

/mob/proc/HogyokuTargets()
	var/list/out = list()
	for(var/mob/Players/P in oview(HOGYOKU_REACH, src))
		if(P == src || !P.client)
			continue
		if(!P.HollowIsHollow() || P.HollowResId)
			continue
		if(P.HollowArrancar == HOLLOW_ARRANCAR_HOGYOKU)
			continue
		if(HollowStageOrder(P.HollowStage) < 1)
			continue
		out += P
	return out

/mob/proc/HogyokuUse(obj/Items/Hogyoku/H)
	if(!H || H.loc != src)
		return
	var/list/targets = src.HogyokuTargets()
	if(!targets.len)
		src << "<font color=red>Nothing within reach is hollow enough to be remade.</font>"
		return
	var/list/tlabels = PromptLabelAtoms(targets, 1)
	var/tpick = Ask(src, "Who will you shape?", "Hogyoku", null, "pick", tlabels, 1)
	if(isnull(tpick))
		return
	var/mob/Players/T = tlabels[tpick]
	if(!T || !(T in src.HogyokuTargets()))
		return
	var/list/free = HollowResurreccionUnclaimed()
	if(!free.len)
		src << "<font color=red>Every Resurreccion has already been given away.</font>"
		return
	var/list/rlabels = list()
	for(var/id in free)
		var/obj/Skills/Buffs/SpecialBuffs/Resurreccion/R = free[id]
		rlabels["[initial(R.BuffName)]: [initial(R.identity_line)]"] = id
	var/rpick = Ask(src, "Which release does it press into [T]?", "Hogyoku", null, "pick", rlabels, 1)
	if(isnull(rpick))
		return
	var/id = rlabels[rpick]
	var/obj/Skills/Buffs/SpecialBuffs/Resurreccion/RT = free[id]
	var/warn = "[src] is holding the Hogyoku against you, offering [initial(RT.BuffName)]. If you accept: you become an Arrancar for good, your evolution stops at your current class, and the release itself opens at your third ascension."
	var/answer = Ask(T, warn, "The Hogyoku", null, "confirm", null, 1, "Accept", "Refuse")
	if(answer != "Accept")
		src << "<font color=red>[T] refuses.</font>"
		T << "<font color=yellow>You refuse. Nothing changes.</font>"
		return
	if(HollowResurreccionHolder(id))
		src << "<font color=red>That release was claimed while you were asking.</font>"
		return
	if(!T || !T.HollowIsHollow() || T.HollowResId)
		return
	if(!HollowResurreccionClaim(id, T))
		src << "<font color=red>That release was claimed while you were asking.</font>"
		return
	T.HollowResId = id
	if(!T.HollowArrancar)
		T.HollowBecomeArrancar(HOLLOW_ARRANCAR_HOGYOKU)
		T.HollowConvertBody()
	else
		T.HollowSyncSkills()
	Log("Admin", "[ExtractInfo(src)] used the Hogyoku on [ExtractInfo(T)] and granted [id].", 1)

/proc/HogyokuFind()
	for(var/obj/Items/Hogyoku/H in world)
		return H
	return null

/mob/Admin4/verb/Spawn_Hogyoku()
	set category = "Admin"
	set name = "Spawn Hogyoku"
	var/obj/Items/Hogyoku/had = HogyokuFind()
	if(had)
		usr << "<font color=red>The Hogyoku already exists. Use Move Hogyoku instead.</font>"
		return
	var/list/pool = list()
	for(var/mob/Players/P in players)
		if(P.ckey)
			pool += P
	if(!pool.len)
		usr << "<font color=red>Nobody is online.</font>"
		return
	var/list/lab = PromptLabelAtoms(pool, 1)
	var/pick_label = Ask(usr, "Who receives the Hogyoku?", "Spawn Hogyoku", null, "pick", lab, 1)
	if(isnull(pick_label))
		return
	var/mob/Players/P = lab[pick_label]
	if(!P)
		return
	var/obj/Items/Hogyoku/H = new(P)
	glob.HogyokuExists = 1
	P << "<font color=yellow>A small orb settles into your hands. It is listening.</font>"
	usr << "<font color=yellow>Hogyoku given to [P].</font>"
	Log("Admin", "[ExtractInfo(usr)] spawned the Hogyoku on [ExtractInfo(P)]. [H]", 1)

/mob/Admin4/verb/Move_Hogyoku()
	set category = "Admin"
	set name = "Move Hogyoku"
	var/obj/Items/Hogyoku/H = HogyokuFind()
	if(!H)
		usr << "<font color=red>The Hogyoku does not exist yet.</font>"
		return
	var/list/pool = list()
	for(var/mob/Players/P in players)
		if(P.ckey)
			pool += P
	if(!pool.len)
		usr << "<font color=red>Nobody is online.</font>"
		return
	var/list/lab = PromptLabelAtoms(pool, 1)
	var/pick_label = Ask(usr, "Who holds the Hogyoku now?", "Move Hogyoku", null, "pick", lab, 1)
	if(isnull(pick_label))
		return
	var/mob/Players/P = lab[pick_label]
	if(!P)
		return
	H.loc = P
	P << "<font color=yellow>A small orb settles into your hands. It is listening.</font>"
	usr << "<font color=yellow>Hogyoku moved to [P].</font>"
	Log("Admin", "[ExtractInfo(usr)] moved the Hogyoku to [ExtractInfo(P)].", 1)

/mob/Admin4/verb/Destroy_Hogyoku()
	set category = "Admin"
	set name = "Destroy Hogyoku"
	var/obj/Items/Hogyoku/H = HogyokuFind()
	if(!H)
		usr << "<font color=red>The Hogyoku does not exist.</font>"
		return
	var/confirm = Ask(usr, "Destroy the Hogyoku? Resurrecciones already given out are not affected.", "Destroy Hogyoku", null, "confirm", null, 1, "Destroy", "Cancel")
	if(confirm != "Destroy")
		return
	Log("Admin", "[ExtractInfo(usr)] destroyed the Hogyoku.", 1)
	del H
	glob.HogyokuExists = 0
	usr << "<font color=yellow>The Hogyoku is gone.</font>"

/mob/Admin3/verb/Resurreccion_Registry()
	set category = "Admin"
	set name = "Resurreccion Registry"
	var/list/all = HollowResurreccionIds()
	var/list/rows = list()
	for(var/id in all)
		var/obj/Skills/Buffs/SpecialBuffs/Resurreccion/R = all[id]
		var/list/entry = HollowResurreccionHolder(id)
		var/holder = "unclaimed"
		var/hkey = "-"
		var/when = "-"
		var/online = "-"
		if(islist(entry) && entry.len >= 3)
			hkey = "[entry[1]]"
			holder = "[entry[2]]"
			when = "[time2text(entry[3], "YYYY-MM-DD")]"
			online = "no"
			for(var/mob/Players/P in players)
				if(P.key == entry[1])
					online = "yes"
					break
		rows[++rows.len] = list("t" = "[initial(R.BuffName)]", "t2" = "[initial(R.identity_line)]", "h" = "?src=\ref[usr];action=HollowFreeRes;resid=[id]", "c" = list(holder, hkey, when, online))
	usr.client?.TableShow("hollow:registry", "HOLLOW", "Resurreccion registry", "[rows.len] total", list(list("l" = "RELEASE", "a" = "l"), list("l" = "HOLDER", "a" = "l"), list("l" = "KEY", "a" = "l"), list("l" = "GIVEN", "a" = "l"), list("l" = "ONLINE", "a" = "l")), rows, "a release to free it", null, list("nosort" = 1))

/mob/Topic(href, href_list[])
	if(href_list["action"] == "HollowFreeRes")
		if(usr != src || !usr.Admin || usr.Admin < 3)
			return
		var/id = href_list["resid"]
		var/list/entry = HollowResurreccionHolder(id)
		if(!entry)
			usr << "<font color=red>That release is already unclaimed.</font>"
			return
		var/confirm = Ask(usr, "Free [id] from [entry[2]] ([entry[1]])? They lose the release and it goes back into the pool.", "Free Resurreccion", null, "confirm", null, 1, "Free It", "Cancel")
		if(confirm != "Free It")
			return
		HollowResurreccionFree(id)
		Log("Admin", "[ExtractInfo(usr)] freed Resurreccion [id] from [entry[2]] ([entry[1]]).", 1)
		usr << "<font color=yellow>[id] is unclaimed again.</font>"
		return
	..()
