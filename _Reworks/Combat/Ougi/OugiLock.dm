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

mob/proc/OugiLogoutRelease()
	var/datum/ougi_scene/S = OugiLock
	if(!S) return
	if(src in S.actors)
		S.ReturnActor(src)
		S.actors -= src
	OugiLockRelease(S, src)
	S.watchers -= src

mob/proc/OugiLoginRestore()
	if(OugiLock && !(OugiLock in OugiLiveList())) OugiLock = null
	if(OugiLock) return
	if(CutsceneWatch && PureRPMode && !(client && client.cutscene_active))
		if(Stasis == OUGI_HOLD_STASIS) Stasis = 0
		CutsceneModeOff()

mob/Players/Login()
	..()
	OugiLoginRestore()

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
