obj/Items/var/tmp/heat = 0
obj/Items/var/tmp/overheated = 0
obj/Items/var/tmp/heat_loop = 0
obj/Items/var/tmp/heat_tick = 0

var/heat_loop_seq = 0
var/list/heat_mech_types = list()

mob/proc/HeatMechRecord()
	var/has = heat_mech_types[type]
	if(isnull(has))
		has = ("mech" in vars) ? 1 : 0
		heat_mech_types[type] = has
	if(!has)
		return null
	var/obj/Items/Mech/R = vars["mech"]
	return istype(R) ? R : null

mob/HeatSource()
	var/obj/Items/Mech/R = HeatMechRecord()
	if(R)
		return R
	var/obj/Items/Gun/G = EquippedGun()
	if(G && G.energy_gun && !G.mech_only)
		return G
	return null

mob/HeatNow()
	var/obj/Items/S = HeatSource()
	return S ? S.heat : 0

mob/HeatMax()
	return HeatMaxOf(HeatSource())

mob/proc/HeatMaxOf(obj/Items/S)
	if(istype(S, /obj/Items/Mech))
		var/obj/Items/Mech/R = S
		return max(1, R.IntrinsicNumber("capacity", src, GUN_HEAT_MAX * max(MechHeatMaxMult(), 0.1)))
	return GUN_HEAT_MAX

mob/Overheated()
	var/obj/Items/S = HeatSource()
	return S ? S.overheated : 0

mob/HeatDissipation()
	return HeatDissipationOf(HeatSource())

mob/proc/HeatDissipationOf(obj/Items/S)
	if(istype(S, /obj/Items/Mech))
		var/obj/Items/Mech/R = S
		var/amount = max(0, (MECH_HEAT_DISSIPATION + MechDissipationFlat()) * MechDissipationMult())
		return R.IntrinsicNumber("cooling", src, amount)
	if(S)
		return GUN_HEAT_DISSIPATION
	return 0

mob/HeatAdd(n)
	var/obj/Items/S = HeatSource()
	if(!S || n <= 0)
		return 0
	var/cap = HeatMaxOf(S)
	S.heat = min(cap, S.heat + n)
	if(S.heat >= cap && !S.overheated)
		S.overheated = 1
		src << "<b>Your [S.name] overheats and locks until it cools completely.</b>"
	HeatLoop(S)
	if(client)
		client.RefreshHeatHUD()
	return S.heat

mob/HeatClear()
	var/obj/Items/S = HeatSource()
	if(!S)
		return
	S.heat = 0
	S.overheated = 0
	S.heat_loop = 0
	if(client)
		client.RefreshHeatHUD()

mob/proc/HeatDrop(n)
	var/obj/Items/S = HeatSource()
	if(!S || n <= 0 || S.heat <= 0)
		return 0
	S.heat = max(0, S.heat - n)
	if(S.heat <= 0 && S.overheated)
		S.overheated = 0
		src << "Your [S.name] has cooled down."
	if(client)
		client.RefreshHeatHUD()
	return S.heat

mob/proc/HeatLoop(obj/Items/S)
	set waitfor = 0
	if(!S || S.heat <= 0)
		return
	if(S.heat_loop && world.time - S.heat_tick <= GUN_HEAT_POLL * 2)
		return
	var/token = ++heat_loop_seq
	S.heat_loop = token
	S.heat_tick = world.time
	while(S && S.heat_loop == token && S.heat > 0)
		sleep(GUN_HEAT_POLL)
		if(!S || S.heat_loop != token)
			return
		S.heat_tick = world.time
		S.heat = max(0, S.heat - HeatDissipationOf(S) * GUN_HEAT_POLL / 10)
		if(S.heat <= 0 && S.overheated)
			S.overheated = 0
			src << "Your [S.name] has cooled down."
	if(S && S.heat_loop == token)
		S.heat_loop = 0
