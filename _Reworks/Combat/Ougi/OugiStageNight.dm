#if fexists("../../../Icons/Private/Backdrops/forest_night.dmi") || fexists("Icons/Private/Backdrops/forest_night.dmi")
#define OUGI_BD_FOREST_NIGHT_ART 'Icons/Private/Backdrops/forest_night.dmi'
#else
#define OUGI_BD_FOREST_NIGHT_ART OUGI_ART_FALLBACK
#endif
#define OUGI_FX_LIT_LAYER (MOB_LAYER + 0.4)

/datum/ougi_backdrop/forest_night
	id = "forest_night"
	icon = OUGI_BD_FOREST_NIGHT_ART
	layer_w = 640
	layer_h = 480
	scale = 1
	overlap = 168
	layers = list(list("sky", 0.02, 0), list("moon_stars", 0.04, 0), list("clouds", 0.08, 3), list("peaks", 0.15, 0), list("foothills", 0.35, 0), list("forest", 0.6, 0))

/datum/ougi_stage
	var/dn_fixed

/datum/ougi_stage/forest_night
	id = "forest_night"
	ground_turf = /turf/OugiStage/Ground/Grass
	backdrop = "forest_night"
	room_w = 41
	env_profile = "default"
	dn_fixed = "night"

proc/OugiRoomApplyClock(datum/ougi_room/R)
	if(!R || !R.A || !R.stage || !R.stage.dn_fixed) return
	var/area/A = R.A
	if(A.dn_fixed == R.stage.dn_fixed && A.sees_sky && (A in _dn_sky_areas)) return
	A.dn_fixed = R.stage.dn_fixed
	A.sees_sky = 1
	DnManageArea(A, 1)

/datum/ougi_scene/EnterRoom()
	OugiRoomApplyClock(room)
	..()

/datum/ougi_scene/OpFX(list/a)
	var/obj/Effects/OugiFX/F = ..()
	if(F && ArgNum(a, "lit", 0) && !ArgNum(a, "under", 0))
		F.plane = FLOAT_PLANE
		F.layer = OUGI_FX_LIT_LAYER
	return F
