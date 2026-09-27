proc/CapsuleGroundClear(turf/T, mob/M)
	if(!T || T.density) return 0
	for(var/atom/movable/A in T)
		if(A.density && A != M) return 0
	for(var/atom/movable/A in bounds(T))
		if(A.density && A != M) return 0
	return 1

/obj/Items/Capsule
	name = "Capsule"
	desc = "A pocket capsule that holds one parked mech, one wreck or one Sentry Turret. Deploy it from your pack to set the machine down in front of you."
	icon = 'Icons/Technology/Tech.dmi'
	icon_state = "PodRegular"
	UpdatesDescription = 1
	var/obj/Items/stored
	var/stored_kind

	proc/Update_Description()
		CapsulePrune()
		desc = initial(desc)
		if(!stored)
			desc += "<br><br>Empty."
			return
		desc += "<br><br>Holds: [stored.name][stored_kind == "wreck" ? ", a wreck" : ""]."

	proc/CapsulePrune()
		if(stored && stored.loc != src)
			stored = null
			stored_kind = null

	proc/CapsuleTake(mob/M, obj/Items/O, kind)
		if(!O || stored) return 0
		var/obj/Items/Mech/R = O
		if(istype(R))
			R.MechGuardClear()
			MechDeployedClear(R)
		O.loc = src
		stored = O
		stored_kind = kind
		if(M)
			M << "[O] folds away into [src]."
			if(M.client) M.client.BuildInvPage()
		return 1

	proc/CapsuleDeploy(mob/M)
		if(!M || loc != M) return 0
		CapsulePrune()
		if(!stored)
			M << "[src] is empty."
			return 0
		if(M.InCombat())
			M << "You can't deploy a capsule in a fight."
			return 0
		var/obj/Items/O = stored
		var/obj/Items/Mech/R = O
		if(istype(R))
			var/obj/Items/Mech/out = MechDeployedFor(M.ckey)
			if(out && out != R)
				M << "You already have [out] deployed. Capsule it before you deploy another."
				return 0
		if(!CapsuleGroundClear(get_step(M, M.dir), M))
			M << "There is no room in front of you."
			return 0
		M << "You thumb [src] and step back."
		if(!M.MechChannel(MECH_DEPLOY_DS, null, "deployment")) return 0
		if(!src || loc != M || stored != O || M.InCombat()) return 0
		var/turf/T = get_step(M, M.dir)
		if(!CapsuleGroundClear(T, M))
			M << "There is no room in front of you."
			return 0
		if(istype(R))
			var/obj/Items/Mech/again = MechDeployedFor(M.ckey)
			if(again && again != R)
				M << "You already have [again] deployed. Capsule it before you deploy another."
				return 0
		stored = null
		stored_kind = null
		O.loc = T
		if(istype(R))
			MechDeployedSet(M, R)
			R.MechPlaced(1)
		OMsg(M, "[M] deploys [O] from a capsule.")
		if(M.client) M.client.BuildInvPage()
		return 1

/atom/movable/shud/invcapbtn
	layer = MINV_LAYER + 0.7
	mouse_opacity = 2
	maptext_height = 18
	var/obj/Items/Capsule/cap

	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1"))
			usr.client.HideItemDesc()
			return
		var/mob/M = usr
		var/obj/Items/Capsule/C = cap
		spawn()
			if(!M || !C) return
			C.CapsuleDeploy(M)
			if(M && M.client && C && C.loc == M) M.client.ShowItemDesc(C)

client/CapsuleDescButton(obj/Items/I, list/objs)
	..()
	var/obj/Items/Capsule/C = I
	if(!istype(C) || !islist(objs)) return
	C.CapsulePrune()
	if(!C.stored) return
	var/atom/movable/shud/invcapbtn/b = new
	b.cap = C
	b.maptext_width = 100
	b.maptext = "<span style=\"[MINV_FONT]; color:#8be9ff\">&#9874; Deploy</span>"
	b.screen_loc = "[InvXLoc(TECH_INV_BTN_X)],CENTER:[TECH_INV_BTN_Y]"
	objs += b

/obj/Items/Tech/Sentry_Turret
	DeviceActions(mob/M)
		. = ..()
		if(isturf(loc) && DeviceIsOwner(M)) . += "Capsule"

	DeviceAct(mob/M, act)
		if(act == "Capsule")
			TurretCapsuleUp(M)
			return
		..()

	proc/TurretCapsuleUp(mob/M)
		if(!M || !isturf(loc) || !DeviceIsOwner(M)) return
		if(M.InCombat())
			M << "You can't pack a turret away in a fight."
			return
		var/obj/Items/Capsule/C = M.CapsuleEmpty()
		if(!C)
			M << "You need an empty Capsule to pack [src] away."
			return
		M << "You start packing [src] into [C]."
		if(!M.MechChannel(MECH_RECALL_DS, src, "packing")) return
		if(!src || !isturf(loc) || !C || C.loc != M || C.stored || M.InCombat()) return
		if(turret_gunner) TurretDisarm()
		DeviceUnregister()
		Grabbable = 1
		C.CapsuleTake(M, src, "turret")
		OMsg(M, "[M] packs [src] into a capsule.")
