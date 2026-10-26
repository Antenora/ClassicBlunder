#define QUINCY_HIRENKYAKU_RANGE 8
#define QUINCY_HIRENKYAKU_MANA 1

obj/Skills/Buffs/var/IsVollstandig = 0

/obj/Skills/Hoho/Hirenkyaku
	name = "Hirenkyaku"
	MaxCharges = 4
	Charges = 4
	ChargeRefresh = 8
	ManaCost = 0
	var/tmp/HirenkyakuToggle = FALSE

	verb/Hirenkyaku()
		set name = "Hirenkyaku"
		set category = "Skills"
		set hidden = 1
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		src.HirenkyakuToggle = !src.HirenkyakuToggle
		if(src.HirenkyakuToggle)
			User << "Hirenkyaku active. ([src.Charges]/[src.MaxCharges] charges)"
		else
			User << "Hirenkyaku deactivated."

/mob/proc/QuincyHirenkyakuCost()
	if(src.QuincyLetztActive)
		return 0
	for(var/obj/Skills/Buffs/B in src)
		if(B.IsVollstandig && src.BuffOn(B))
			return 0
	return QUINCY_HIRENKYAKU_MANA

/proc/QuincyStepIsPit(turf/origin, turf/dest)
	if(!isturf(origin) || !isturf(dest) || origin.z != dest.z)
		return 0
	return ElevAt(dest) < ElevAt(origin)

turf/Click(turf/T)
	if(!usr || !usr.client)
		return ..()
	var/obj/Skills/Hoho/Hirenkyaku/s = locate(/obj/Skills/Hoho/Hirenkyaku) in usr.contents
	if(!s || !s.HirenkyakuToggle)
		return ..()
	if(usr.Admin >= 4 && usr.AdminOverwatchActive)
		return ..()
	if(usr.Target && istype(usr.Target, /obj/Others/Build))
		return ..()
	if(usr.client.macros && usr.client.macros.IsPressed("Ctrl"))
		return ..()
	if(!usr.Move_Requirements() || usr.KO)
		return ..()
	if(!T || !T.icon)
		return
	for(var/turf/A in view(0, usr))
		if(A == src)
			return
	if(!usr.QuincyWeaponDrawn())
		usr << "Draw your Spirit Weapon first."
		return
	if(get_dist(usr, src) > QUINCY_HIRENKYAKU_RANGE || usr.z != src.z)
		usr << "<font color='red'>Too far to step there.</font>"
		return
	if(T.density || usr.icon_state == "Meditate" || usr.Observing || usr.Beaming == 2)
		return
	if(s.Charges <= 0)
		return
	var/mana_cost = usr.QuincyHirenkyakuCost()
	if(mana_cost && usr.ManaAmount < mana_cost)
		return
	var/turf/origin = get_step(usr, 0)
	var/pit = QuincyStepIsPit(origin, src)
	var/oldSkim = usr.Skimming
	if(pit)
		usr.Skimming = 1
	VanishImage(usr)
	var/formerdir = usr.dir
	usr.Move(src)
	if(pit)
		usr.Skimming = oldSkim
	usr.dir = formerdir
	ShadowPrewarm(usr)
	if(usr.Energy < 1)
		usr.Energy = 1
	if(mana_cost)
		usr.LoseMana(mana_cost)
	s.Cooldown(1, null, usr)
