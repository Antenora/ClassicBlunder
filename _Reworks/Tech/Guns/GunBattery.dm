obj/Items/Battery
	name = "Battery"
	desc = "A charged energy cell in a snap-in housing. Hold Reload with an energy gun equipped to swap one in and fill the gun to full."
	icon = 'Icons/Technology/Gear/powerpack.dmi'
	Stackable = 1

/datum/craft_recipe/lifecraft/tech/field/battery
	id = "tech_battery"
	label = "Battery"
	tier = 5
	knowledge_req = "Energy Weaponry"
	result_type = /obj/Items/Battery
	result_count = GUN_BATTERY_PER_RUN
	slotspec = list(\
		list("Cell", 1, TECH_MAT_CELL, 1),\
		list("Wiring", 2, TECH_MAT_WIRING, 1))

/mob/var/tmp/gun_battery_token = 0

mob/proc/GunBatteryStack()
	for(var/obj/Items/Battery/B in src)
		if(B.TotalStack > 0)
			return B
	return null

mob/proc/GunBatterySwapTime(obj/Items/Gun/G)
	var/base = GunClassReloadTick(G.GunClass)
	var/scale = base > 0 ? G.ReloadTick(src) / base : 1
	return GUN_HANDGUN_RELOAD_TICK * GUN_BATTERY_SWAP_ROUNDS * scale

mob/GunBatteryReload(obj/Items/Gun/G)
	if(!G || !G.energy_gun || G.mech_only || Reloading)
		return 0
	G.EnergySync()
	if(G.energy >= GUN_ENERGY_MAX)
		src << "Your [G.name] is already fully charged."
		return 0
	if(KO || Stunned || Knockbacked || Suspended || Stasis || Frozen || TimeFrozen)
		return 0
	if(!GunBatteryStack())
		src << "You have no Battery for your [G.name]."
		return 0
	Reloading = 1
	if(GunIsSuppressed())
		src << "<b>You start swapping a Battery.</b>"
	else
		OMsg(src, "<b>[src] starts swapping a Battery.</b>")
	GunBatteryLoop(G, ++gun_battery_token)
	return 1

mob/proc/GunBatteryLoop(obj/Items/Gun/G, token)
	set waitfor = 0
	var/step = GunBatterySwapTime(G) / GUN_BATTERY_SWAP_ROUNDS
	var/done = 0
	for(var/i = 1 to GUN_BATTERY_SWAP_ROUNDS)
		sleep(step * SlowMoDelayMult(src))
		if(token != gun_battery_token || !Reloading || EquippedGun() != G)
			break
		if(KO || Stunned || Knockbacked || Suspended || Stasis || Frozen || TimeFrozen)
			break
		if(i == GUN_BATTERY_SWAP_ROUNDS)
			done = 1
	if(token != gun_battery_token)
		return
	Reloading = 0
	if(!done)
		return
	var/obj/Items/Battery/B = GunBatteryStack()
	if(!B)
		src << "You are out of Batteries."
		return
	B.TotalStack--
	B.suffix = "[B.TotalStack]"
	if(B.TotalStack <= 0)
		del B
	G.energy = GUN_ENERGY_MAX
	G.EnergyReset()
	G.DryWarned = 0
	GunRefillSkill(G)
	src << "Your [G.name] is fully charged."
	if(client)
		client.BuildInvPage()
