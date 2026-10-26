proc/OugiLockApply(datum/ougi_scene/S, mob/M)
	if(!S || !M) return 0
	if(M.OugiLock) return 0
	if(M.Observing == 2) return 0
	M.OugiLock = S
	_CoatClear(M)
	M.ougi_was_rp = M.PureRPMode ? 1 : 0
	if(!M.ougi_was_rp)
		M.ougi_prev_stasis = M.Stasis
		if(istype(M, /mob/Player/AI))
			var/mob/Player/AI/A = M
			M.ougi_prev_stall = A.ai_stall
		M.CutsceneModeOn(1)
		OugiHoldMob(M)
	S.locked |= M
	return 1

proc/OugiHoldMob(mob/M)
	if(!M || M.ougi_was_rp) return
	if(M.Stasis < OUGI_HOLD_STASIS) M.Stasis = OUGI_HOLD_STASIS
	if(istype(M, /mob/Player/AI))
		var/mob/Player/AI/A = M
		if(A.ai_stall < OUGI_HOLD_STALL) A.ai_stall = OUGI_HOLD_STALL

proc/OugiLockRelease(datum/ougi_scene/S, mob/M)
	if(!M || M.OugiLock != S) return 0
	if(M.client) OugiClientRestore(M.client, S)
	if(!M.ougi_was_rp)
		M.Stasis = M.ougi_prev_stasis
		if(istype(M, /mob/Player/AI))
			var/mob/Player/AI/A = M
			A.ai_stall = M.ougi_prev_stall
		if(M.PureRPMode) M.CutsceneModeOff()
	M.ougi_was_rp = 0
	M.ougi_prev_stasis = 0
	M.ougi_prev_stall = 0
	M.OugiLock = null
	if(S) S.locked -= M
	return 1

// ckeys that left mid-Ougi
var/list/ougi_dc_ckeys = list()

//thios is a temp solution, it just stops the ougi for everyone and then reset whoever left back to their og position pre ougi
mob/proc/OugiLogoutRelease()
	var/datum/ougi_scene/S = OugiLock
	if(!S) return
	if(ckey) ougi_dc_ckeys[ckey] = world.time

	if(S.live && !S.ended && (src == S.attacker || src == S.target)) S.End(1)
	if(OugiLock != S) return
	if(src in S.actors)
		S.ReturnActor(src)
		S.actors -= src
	OugiLockRelease(S, src)
	S.watchers -= src

mob/proc/OugiLoginRestore(was_ougi = 0)
	if(OugiLock && !(OugiLock in OugiLiveList())) OugiLock = null
	if(OugiLock) return
	if(CutsceneWatch && PureRPMode && !(client && client.cutscene_active))
		if(Stasis == OUGI_HOLD_STASIS) Stasis = 0
		CutsceneModeOff()
	OugiLoginLeaveRoom(was_ougi)
	if(client && ckey && ougi_dc_ckeys[ckey])
		ougi_dc_ckeys -= ckey
		var/client/C = client
		spawn(20) OugiClientFreshReset(C)


proc/OugiClientFreshReset(client/C)
	if(!C || !C.mob || C.mob.OugiLock) return
	OugiClientDim(C, 0)
	OugiClientClearActorPlates(C)
	OugiClientClearFlashFX(C)
	OugiClientClearBackdrop(C)
	OugiClientWorldTransform(C, 1, 0, 0, 0)
	OugiClientSharpFx(C, 0)
	C.ougi_in_display = 0
	C.cutscene_active = TRUE
	C.EndCutsceneDisplay()
	C.fps = C.mob.EffectiveClientFPS()

mob/Players/Login()
	var/was_ougi = OugiIsRoomMap(in_tmp_map)
	..()
	OugiLoginRestore(was_ougi)

proc/OugiReleaseAll()
	var/n = 0
	var/list/live = OugiLiveList()
	for(var/datum/ougi_scene/S in live.Copy())
		S.End(1)
		n++
	for(var/mob/M in world)
		if(M.OugiLock)
			var/datum/ougi_scene/L = M.OugiLock
			if(L.room) L.ReturnActor(M)
			OugiLockRelease(L, M)
			M.OugiLock = null
			n++
	for(var/datum/ougi_room/R in OugiRoomsList())
		OugiRoomRelease(R)
	return n


proc/OugiIsRoomMap(id)
	return istext(id) && copytext(id, 1, 6) == "ougi_"


mob/Players/Write(savefile/F)
	..()
	if(!OugiIsRoomMap(in_tmp_map)) return
	if(!isnull(PrevX) && !isnull(PrevY) && !isnull(PrevZ))
		F["x"] << PrevX
		F["y"] << PrevY
		F["z"] << PrevZ
	F.dir.Remove("in_tmp_map")
	F["pixel_x"] << ougi_return_pixel_x
	F["pixel_y"] << ougi_return_pixel_y
	F["pixel_z"] << ougi_return_pixel_z
	if(ougi_return_transform) F["transform"] << ougi_return_transform
	else F.dir.Remove("transform")
	if(!isnull(ougi_return_layer)) F["layer"] << ougi_return_layer
	if(!isnull(ougi_return_state)) F["icon_state"] << ougi_return_state
	var/datum/ougi_scene/S = OugiLock
	if(S && S.ougi_alpha_orig && !isnull(S.ougi_alpha_orig[src])) F["alpha"] << S.ougi_alpha_orig[src]
	F.dir.Remove("color")


mob/proc/OugiLoginLeaveRoom(was_ougi = 0)
	if(OugiLock || !(was_ougi || OugiIsRoomMap(in_tmp_map))) return
	if(OugiIsRoomMap(in_tmp_map))
		in_tmp_map = null
		var/turf/T = (!isnull(PrevX) && !isnull(PrevY) && !isnull(PrevZ)) ? locate(PrevX, PrevY, PrevZ) : null
		if(T) loc = OugiFreeTurfNear(T, src) || T
	PrevX = null
	PrevY = null
	PrevZ = null
	animate(src)
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)
	pixel_z = initial(pixel_z)
	transform = null
	alpha = 255
	color = null
	layer = initial(layer)
	UpdateStandingLayer()
	if(!KO) icon_state = ""
	src << "<font color=#ffd278>You were saved mid-Ougi; you have been put back where the Ougi started.</font>"
