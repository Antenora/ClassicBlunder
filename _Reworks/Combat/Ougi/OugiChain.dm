#if fexists("../../../Icons/Private/Ougi/ougi_chain_ring.dmi") || fexists("Icons/Private/Ougi/ougi_chain_ring.dmi")
#define OUGI_CHAIN_RING_ART 'Icons/Private/Ougi/ougi_chain_ring.dmi'
#else
#define OUGI_CHAIN_RING_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../Icons/Private/Ougi/ougi_chain_tip.dmi") || fexists("Icons/Private/Ougi/ougi_chain_tip.dmi")
#define OUGI_CHAIN_TIP_ART 'Icons/Private/Ougi/ougi_chain_tip.dmi'
#else
#define OUGI_CHAIN_TIP_ART OUGI_ART_FALLBACK
#endif

#define OUGI_RING_PIECES 36
#define OUGI_RING_STEP 10
#define OUGI_RING_SUB 5
#define OUGI_RING_BOX 64
#define OUGI_RING_TIP 176

globalTracker
	var/tmp
		list/OugiChains
		OUGI_CHAIN_MAX = 4
		OUGI_CHAIN_TICK_DS = 2
		OUGI_CHAIN_BREATH_DS = 10
		OUGI_BURST_GAP_DS = 2
		OUGI_BURST_WAIT_DS = 300
		OUGI_RING_RADIUS = 150
		OUGI_RING_FROM = 80
		OUGI_RING_GROW_DS = 4
		OUGI_RING_TIP_STEPS = 72
		OUGI_RING_TIP_FADE_DS = 3
		OUGI_RING_CENTER_X = 16
		OUGI_RING_CENTER_Y = 16

mob
	var/tmp
		list/ougi_floors
		ougi_chain_passing = 0

/datum/ougi_scene
	var/tmp/datum/ougi_chain/ougi_chain

proc/OugiChainsList()
	if(!glob.OugiChains) glob.OugiChains = list()
	return glob.OugiChains

proc/OugiChainForParty(Party/P)
	if(!P) return null
	for(var/datum/ougi_chain/C in OugiChainsList())
		if(C.live && C.party == P && !C.preview) return C
	return null

proc/OugiChainSceneExit(datum/ougi_scene/S)
	if(!S) return 0
	var/datum/ougi_chain/C = S.ougi_chain
	if(!C || !C.live || C.scene != S) return 0
	return C.SceneExit(S)

mob/proc/OugiFloorChain()
	if(!ougi_floors) return null
	for(var/datum/ougi_chain/C in ougi_floors)
		if(C.live) return C
	ougi_floors = null
	return null

mob/LoseHealth(val)
	var/datum/ougi_chain/C = ougi_floors ? OugiFloorChain() : null
	if(C && isnum(val) && val > 0)
		var/room = max(0, Health - 1)
		if(val > room)
			C.deficit += val - room
			val = room
	..(val)

mob/Unconscious(mob/P, text)
	var/datum/ougi_chain/C = ougi_floors ? OugiFloorChain() : null
	if(C && !KO)
		if(Health < 1)
			C.deficit += 1 - Health
			Health = 1
		return
	return ..()

mob/proc/OugiPartyPeers()
	if(!party) return 0
	for(var/mob/Players/M in party.members)
		if(M != src) return 1
	return 0

mob/proc/OugiChainPassThrough()
	ougi_chain_passing = 1
	var/ok = 0
	try
		ok = UseOugi()
	catch(var/exception/E)
		world.log << "OUGI: chain press by [src] failed: [E] ([E.file]:[E.line])"
	ougi_chain_passing = 0
	return ok

mob/proc/OugiChainOffer()
	if(ougi_chain_passing) return 0
	if(!istype(src, /mob/Players) || !party) return 0
	var/datum/ougi_chain/C = OugiChainForParty(party)
	if(!C) return OugiChainStart()
	if(src in C.members)
		src << "Your Ougi is already in this chain."
		return 1
	if(C.IsQueued(src))
		src << "Your Ougi is already queued."
		return 1
	if(OugiLock && OugiLock == C.scene && C.state == "scene")
		return OugiChainQueue(C)
	if(ismob(Target) && Target != C.target)
		src << "Your party is already chaining on [C.target]."
		return 1
	if(C.state == "window" && (!C.scene || C.scene.ended))
		return OugiChainWindowPress(C)
	src << "Wait for the current Ougi to end."
	return 1

mob/proc/OugiChainStart()
	if(!OugiPartyPeers()) return 0
	var/ok = OugiChainPassThrough()
	var/datum/ougi_scene/S = OugiLock
	if(ok && S && S.attacker == src && !S.preview && S.target && !S.ougi_chain)
		var/datum/ougi_chain/C = new(src, S.target, party)
		C.Attach(src, S)
	return 1

mob/proc/OugiChainRefusal(obj/Skills/Ougi/O)
	var/saga = O.OugiSagaRefusal(src)
	if(saga) return saga
	var/gear = O.OugiGearRefusal(src)
	if(gear) return gear
	if(!OugiSceneById(O.OugiScene)) return "This Ougi has no scene yet."
	if(Tension < getTensionCap()) return "Your Tension is not full yet."
	if(HasTensionLock()) return "Your Tension is locked right now."
	if(KO || Stunned) return "You cannot use an Ougi right now."
	if(world.time < ougi_cd_until) return "Your Ougi is not ready yet ([round((ougi_cd_until - world.time) / 10)]s)."
	return null

mob/proc/OugiChainQueue(datum/ougi_chain/C)
	if(C.state != "scene")
		src << "Wait for the current Ougi to end."
		return 1
	var/obj/Skills/Ougi/O = OugiEquipped()
	if(!O)
		src << "Equip an Ougi first."
		return 1
	if(C.members.len + C.queued.len >= glob.OUGI_CHAIN_MAX)
		src << "The chain is full."
		return 1
	var/why = OugiChainRefusal(O)
	if(why)
		src << why
		return 1
	var/pre = OugiTensionWouldTransform()
	Tension = 0
	tempTensionLock = glob.OUGI_TENSION_LOCK_S
	C.queued += list(list(src, O, pre))
	src << "You will follow [C.initiator]'s Ougi."
	C.BadgeSync()
	return 1

mob/proc/OugiChainWindowPress(datum/ougi_chain/C)
	var/obj/Skills/Ougi/O = OugiEquipped()
	if(!O) return 0
	if(C.members.len >= glob.OUGI_CHAIN_MAX)
		src << "The chain is full."
		return 1
	var/mob/T = C.target
	if(!T || T.z != z || get_dist(src, T) > glob.OUGI_LOCK_RANGE)
		src << "Your target is too far away."
		return 1
	Target = T
	var/r = O.OugiRange
	O.OugiRange = max(r, glob.OUGI_LOCK_RANGE)
	var/ok = OugiChainPassThrough()
	O.OugiRange = r
	var/datum/ougi_scene/S = OugiLock
	if(ok && S && S.attacker == src && S.target == T && !S.ougi_chain)
		C.Attach(src, S)
	return 1

/datum/ougi_chain
	var
		Party/party
		mob/target
		mob/initiator
		list/members = list()
		list/categories = list()
		list/finishers = list()
		list/queued = list()
		datum/ougi_scene/scene
		state = "scene"
		live = 0
		preview = 0
		dealt = 0
		deficit = 0
		hp_mark = 0
		def_mark = 0
		window_until = 0
		window_left = 0
		window_z = 0
		window_shown = 0
		wait_since = 0
		badge_count = 0
		obj/ougi_screen/chain_badge/badge
		list/badge_clients = list()
		obj/ougi_chain_ring/ring
		list/temp_mobs = list()

/datum/ougi_chain/New(mob/I, mob/T, Party/P, is_preview = 0)
	..()
	initiator = I
	target = T
	party = P
	preview = is_preview
	live = 1
	var/list/L = OugiChainsList()
	L += src
	if(T && !preview)
		if(!T.ougi_floors) T.ougi_floors = list()
		T.ougi_floors |= src
	spawn() Ticker()

/datum/ougi_chain/proc/FinisherBeats(cat)
	var/datum/ougi_scene/F = OugiSceneById(initiator ? finishers[initiator] : null)
	if(F && F.beats && F.beats.len) return F.beats
	return OugiBurstModule(cat, "finisher")

/datum/ougi_chain/proc/IsQueued(mob/M)
	for(var/list/e in queued)
		if(e[1] == M) return 1
	return 0

/datum/ougi_chain/proc/Count()
	return members.len + queued.len

/datum/ougi_chain/proc/Attach(mob/M, datum/ougi_scene/S)
	if(!(M in members))
		members += M
		categories[M] = S.ougi ? S.ougi.OugiCategory : S.category
		if(S.ougi && S.ougi.BurstFinisherScene) finishers[M] = S.ougi.BurstFinisherScene
	if(state == "window") window_left = max(0, window_until - world.time)
	scene = S
	S.ougi_chain = src
	state = "scene"
	hp_mark = target ? target.Health : 0
	def_mark = deficit
	RingHideAll()
	BadgeSync()

/datum/ougi_chain/proc/Measure()
	if(!target) return
	dealt += max(0, hp_mark - target.Health) + max(0, deficit - def_mark)
	hp_mark = target.Health
	def_mark = deficit

/datum/ougi_chain/proc/Prune()
	var/list/keep = list()
	for(var/mob/M in members)
		if(M && (preview || M.party == party)) keep += M
		else if(M) categories -= M
	members = keep
	if(!initiator || !(initiator in members))
		initiator = members.len ? members[1] : null

/datum/ougi_chain/proc/Refund(mob/M)
	if(!M) return
	M.Tension = M.getTensionCap()
	M.tempTensionLock = 0

/datum/ougi_chain/proc/PopNext()
	while(queued.len)
		var/list/e = queued[1]
		queued.Cut(1, 2)
		var/mob/M = e[1]
		var/obj/Skills/Ougi/O = e[2]
		if(!M) continue
		if(!O || O.loc != M || M.party != party)
			Refund(M)
			continue
		var/why = O.OugiGearRefusal(M)
		if(!why && !OugiSceneById(O.OugiScene)) why = "This Ougi has no scene yet."
		if(why)
			M << "Your Ougi was skipped: [why]"
			Refund(M)
			continue
		return e
	return null

/datum/ougi_chain/proc/AnyoneLeft()
	if(!party || members.len >= glob.OUGI_CHAIN_MAX) return 0
	for(var/mob/Players/M in party.members)
		if(M in members) continue
		if(M.OugiEquipped()) return 1
	return 0

/datum/ougi_chain/proc/SceneExit(datum/ougi_scene/S)
	if(state == "burst") return 0
	Measure()
	Prune()
	if(!target || !members.len) return 0
	var/list/e = PopNext()
	while(e)
		if(HandoffQueued(S, e)) return 1
		e = PopNext()
	if(AnyoneLeft())
		state = "window"
		window_until = world.time + OUGI_WIPE_HOLD_DS + OUGI_WIPE_OUT_DS + glob.OUGI_CHAIN_WINDOW_S * 10
		window_left = 0
		window_shown = 0
		BadgeClear()
		return 0
	if(members.len < 2)
		state = "resolve"
		BadgeClear()
		return 0
	var/datum/ougi_scene/burst/B = OugiBurstMake(src)
	var/datum/ougi_room/old = S.room
	OugiRoomRelease(old)
	var/datum/ougi_room/R = OugiRoomAcquire("burst")
	if(!R) R = OugiRoomAcquire("void")
	if(!R)
		if(old) old.busy = 1
		ApplyFinisher(S)
		state = "finish"
		BadgeClear()
		return 0
	B.room = R
	state = "burst"
	BadgeClear()
	Announce()
	Handoff(S, B)
	return 1

/datum/ougi_chain/proc/HandoffQueued(datum/ougi_scene/S, list/e)
	var/mob/M = e[1]
	var/obj/Skills/Ougi/O = e[2]
	var/datum/ougi_scene/T = OugiSceneById(O.OugiScene)
	var/datum/ougi_room/old = S.room
	OugiRoomRelease(old)
	var/datum/ougi_room/R = OugiRoomAcquire(O.OugiStage, O.OugiGround)
	if(!R) R = OugiRoomAcquire("void")
	if(!R)
		if(old) old.busy = 1
		M << "Your Ougi was skipped: no stage was free."
		Refund(M)
		return 0
	var/datum/ougi_scene/NS = new T.type
	NS.attacker = M
	NS.target = target
	NS.ougi = O
	NS.room = R
	NS.climax_mult = O.OugiClimaxMult(M)
	NS.run_prelude = e[3]
	O.Using = 1
	members += M
	categories[M] = O.OugiCategory
	if(O.BurstFinisherScene) finishers[M] = O.BurstFinisherScene
	OMsgChain("<b>[M] follows with [O.name]!</b>")
	Handoff(S, NS)
	return 1

/datum/ougi_chain/proc/OMsgChain(msg)
	var/list/to_tell = list()
	if(scene) to_tell |= scene.locked
	if(target) to_tell |= target
	for(var/mob/M in to_tell)
		M << msg

/datum/ougi_chain/proc/Handoff(datum/ougi_scene/S, datum/ougi_scene/NS)
	NS.ougi_chain = src
	NS.wipe_from = -S.wipe_from
	NS.reduced_motion = S.reduced_motion.Copy()
	S.RestoreWeather()
	S.LeaveRoom()
	S.actors = list()
	S.room = null
	NS.watchers = S.watchers.Copy()
	NS.watchers |= NS.attacker
	for(var/mob/W in S.locked.Copy())
		W.OugiLock = NS
		NS.locked |= W
	S.locked = list()
	NS.clients = S.clients.Copy()
	S.clients = list()
	for(var/client/C in NS.clients)
		if(S.flash_plate) C.screen -= S.flash_plate
		if(S.nameplate) C.screen -= S.nameplate
		OugiClientWorldTransform(C, 1, 0, 0, 0)
	var/list/live = OugiLiveList()
	live |= NS
	scene = NS
	if(state != "burst") state = "scene"
	hp_mark = target ? target.Health : 0
	def_mark = deficit
	NS.EnterRoom()
	for(var/client/C in NS.clients)
		OugiClientEnterDisplay(C, NS)
	S.End(0)
	BadgeSync()
	NS.OugiChainBegin(0)

/datum/ougi_chain/proc/Announce()
	var/n = members.len
	var/msg = (n >= 4) ? "<b>FULL BURST!</b>" : "<b>CHAIN BURST!</b>"
	var/list/to_tell = list()
	if(party) to_tell |= party.members
	to_tell |= members
	if(target) to_tell |= target
	for(var/mob/M in to_tell)
		M << msg

/datum/ougi_chain/proc/Ticker()
	while(live)
		try
			Tick()
		catch(var/exception/E)
			world.log << "OUGI: chain tick failed: [E] ([E.file]:[E.line])"
			Abort()
		sleep(glob.OUGI_CHAIN_TICK_DS)

/datum/ougi_chain/proc/Tick()
	Prune()
	if(!target || !members.len)
		Abort()
		return
	switch(state)
		if("scene")
			if(!scene || scene.ended) SceneLost()
			else BadgeSync()
		if("burst")
			if(!scene || scene.ended) Finish()
		if("finish")
			if(!scene || scene.ended) Finish()
		if("resolve")
			if(!scene || scene.ended) Resolve()
		if("pending")
			TryBurst()
		if("window")
			if(scene && !scene.ended) return
			if(!window_shown)
				window_shown = 1
				window_z = target.z
				RingShowAll()
			if(target.KO || target.z != window_z || !target.loc)
				Resolve()
				return
			if(world.time >= window_until || !AnyoneLeft()) CloseWindow()

/datum/ougi_chain/proc/SceneLost()
	var/datum/ougi_scene/S = scene
	if(S && S.fizzled && S.attacker && S.attacker != initiator && (S.attacker in members))
		members -= S.attacker
		categories -= S.attacker
		if(window_left > 0 && AnyoneLeft())
			state = "window"
			window_until = world.time + window_left
			window_shown = 0
			return
		CloseWindow()
		return
	if(S && S.fizzled && members.len <= 1)
		Done()
		return
	Resolve()

/datum/ougi_chain/proc/CloseWindow()
	RingHideAll()
	if(members.len >= 2)
		state = "pending"
		wait_since = world.time
		TryBurst()
	else
		Resolve()

/datum/ougi_chain/proc/BurstWatchers()
	var/list/L = list()
	if(preview)
		L |= members
		L |= target
		return L
	L |= OugiWouldWatch(target, null, glob.OUGI_LOCK_RANGE)
	for(var/mob/M in members)
		L |= OugiWouldWatch(M, null, glob.OUGI_LOCK_RANGE)
	return L

/datum/ougi_chain/proc/TryBurst()
	var/list/watch = BurstWatchers()
	var/blocked = 0
	for(var/mob/M in watch)
		if(M.OugiLock) blocked = 1
	for(var/mob/M in members)
		if(M.in_tmp_map) blocked = 1
	if(target.in_tmp_map) blocked = 1
	var/datum/ougi_room/R
	if(!blocked)
		R = OugiRoomAcquire("burst")
		if(!R) R = OugiRoomAcquire("void")
	if(!R)
		if(world.time - wait_since > glob.OUGI_BURST_WAIT_DS)
			ApplyFinisher(null)
			Finish()
		return
	var/datum/ougi_scene/burst/B = OugiBurstMake(src)
	B.room = R
	B.watchers = watch
	B.ougi_chain = src
	var/list/live = OugiLiveList()
	live |= B
	scene = B
	state = "burst"
	Announce()
	B.OugiChainBegin(1)

/datum/ougi_chain/proc/LiftFloor()
	if(target && target.ougi_floors)
		target.ougi_floors -= src
		if(!target.ougi_floors.len) target.ougi_floors = null

/datum/ougi_chain/proc/LandOn(mob/A, amount)
	if(!target || amount <= 0) return
	target.LoseHealth(amount)
	if(target && target.Health <= 0 && !target.KO) target.Unconscious(A)

/datum/ougi_chain/proc/ApplyFinisher(datum/ougi_scene/S)
	var/n = clamp(members.len, 2, glob.OUGI_BURST_CONST.len - 1)
	var/bonus = dealt * glob.OUGI_BURST_CONST[n + 1]
	var/def = deficit
	LiftFloor()
	deficit = 0
	var/mob/A = (S && S.attacker) ? S.attacker : initiator
	var/mob/T = target
	if(preview || !A || !T) return
	var/st_a = A.Stasis
	var/st_t = T.Stasis
	var/mp = T.mirror_parry_active
	var/mr = T.mirror_reflect_active
	var/rg = T.passive_handler ? T.passive_handler.Get("RoyalGuarding") : 0
	A.Stasis = 0
	T.Stasis = 0
	T.mirror_parry_active = FALSE
	T.mirror_reflect_active = FALSE
	if(rg) T.passive_handler.Set("RoyalGuarding", 0)
	if(def > 0) T.LoseHealth(def)
	if(T && bonus > 0)
		var/strike/K = new(A, T, bonus)
		K.pierce = 1
		A.ResolveStrike(K)
	if(T && T.Health <= 0 && !T.KO) T.Unconscious(A)
	if(T)
		T.mirror_parry_active = mp
		T.mirror_reflect_active = mr
		if(rg && T.passive_handler) T.passive_handler.Set("RoyalGuarding", rg)
		T.Stasis = st_t
	if(A) A.Stasis = st_a

/datum/ougi_chain/proc/Resolve()
	var/def = deficit
	deficit = 0
	LiftFloor()
	if(!preview) LandOn(initiator, def)
	Done()

/datum/ougi_chain/proc/Finish()
	if(!preview)
		for(var/mob/M in members)
			M.ougi_cd_until = world.time + glob.OUGI_COOLDOWN_S * 10
	Done()

/datum/ougi_chain/proc/Abort()
	if(scene && scene.live) scene.End(1)
	if(target && deficit > 0 && !preview)
		var/def = deficit
		deficit = 0
		LiftFloor()
		LandOn(initiator, def)
	Done()

/datum/ougi_chain/proc/Done()
	if(!live) return
	live = 0
	state = "done"
	var/list/L = OugiChainsList()
	L -= src
	LiftFloor()
	RingHideAll()
	BadgeClear()
	for(var/list/e in queued)
		Refund(e[1])
	queued = list()
	for(var/mob/M in temp_mobs)
		if(M && !M.OugiLock) del M
	temp_mobs = list()

/datum/ougi_chain/proc/RingShowAll()
	RingHideAll()
	if(preview || !target || !target.loc) return
	ring = new
	ring.Start(target, window_until)

/datum/ougi_chain/proc/RingHideAll()
	if(ring) ring.Stop()
	ring = null

/datum/ougi_chain/proc/BadgeSync()
	var/n = Count()
	if(state != "scene" || !scene || !scene.live || n < 2)
		BadgeClear()
		return
	if(!badge) badge = new
	if(n != badge_count)
		badge_count = n
		OugiChainBadgeRender(badge, n, categories[initiator])
	for(var/client/C in scene.clients)
		if(!C.ougi_in_display || (C in badge_clients)) continue
		C.screen |= badge
		badge_clients |= C

/datum/ougi_chain/proc/BadgeClear()
	for(var/client/C in badge_clients)
		if(badge) C.screen -= badge
	badge_clients = list()
	badge_count = 0

/datum/ougi_scene/proc/OugiChainPlateArgs()
	return null

/datum/ougi_scene/proc/OugiChainBegin(fresh)
	set waitfor = 0
	live = 1
	started_at = world.time
	max_ds = EstimateDs() + glob.OUGI_CHAIN_BREATH_DS
	if(fresh)
		for(var/mob/M in watchers.Copy())
			if(OugiLockApply(src, M) && M.client)
				clients |= M.client
	spawn(max_ds + 20)
		if(live)
			world.log << "OUGI: watchdog ended chained scene [id] after [max_ds + 20] ds"
			End(1)
	spawn() KeeperLoop()
	if(fresh)
		FlashIn()
		sleep(OUGI_FLASH_DS)
		if(!live) return
		if(!attacker || !target)
			End(1)
			return
		wipe_from = (attacker.x <= target.x) ? -1 : 1
		WipeCover(wipe_from)
		sleep(OUGI_WIPE_IN_DS)
		if(!live) return
		EnterRoom()
		FlashOut()
		for(var/client/C in clients)
			OugiClientEnterDisplay(C, src)
		sleep(OUGI_WIPE_HOLD_DS)
	else
		sleep(max(OUGI_WIPE_HOLD_DS, glob.OUGI_CHAIN_BREATH_DS))
	if(!live) return
	WipeReveal(wipe_from)
	sleep(OUGI_WIPE_OUT_DS)
	if(!live) return
	var/list/pa = OugiChainPlateArgs()
	spawn(OUGI_PLATE_DELAY_DS) PlateRun(pa)
	if(run_prelude) RunBeats(prelude)
	if(live) RunBeats(beats)
	if(live && !hit_done) OpHit(null)
	if(live) Exit()

proc/OugiChainBurstPreview(mob/A, mob/T, list/cast, list/cats)
	if(!A || !T || !cast || cast.len < 2) return null
	var/datum/ougi_chain/C = new(A, T, A.party, 1)
	for(var/i = 1 to cast.len)
		var/mob/M = cast[i]
		C.members += M
		C.categories[M] = cats[i]
	C.state = "pending"
	C.wait_since = world.time
	C.TryBurst()
	return C

/mob/Admin3/verb/Ougi_Chain_Test()
	set category = "Admin"
	set name = "Ougi-Chain-Test"
	var/list/modes = list("Fill my party's Tension and open a window", "Preview a Chain Burst (2)", "Preview a Chain Burst (3)", "Preview a Full Burst (4)")
	var/pick = Ask(usr, "Which test?", "Ougi-Chain-Test", null, "pick", modes, 1)
	if(!pick) return
	if(pick == modes[1])
		if(!usr.party)
			usr << "You need a party."
			return
		var/mob/T = usr.Target
		if(!ismob(T) || T == usr)
			usr << "You need a target."
			return
		if(OugiChainForParty(usr.party))
			usr << "Your party already has a chain running."
			return
		for(var/mob/Players/M in usr.party.members)
			M.tempTensionLock = 0
			M.Tension = M.getTensionCap()
			M.ougi_cd_until = 0
		var/datum/ougi_chain/C = new(usr, T, usr.party)
		var/obj/Skills/Ougi/O = usr.OugiEquipped()
		C.members += usr
		C.categories[usr] = O ? O.OugiCategory : "Energy"
		C.state = "window"
		C.window_until = world.time + glob.OUGI_CHAIN_WINDOW_S * 10
		usr << "Chain window open on [T] for [glob.OUGI_CHAIN_WINDOW_S]s."
		Log("Admin", "[ExtractInfo(usr)] opened an Ougi chain window on [T].")
		return
	if(usr.OugiLock)
		usr << "You are inside an Ougi already."
		return
	var/n = (pick == modes[2]) ? 2 : ((pick == modes[3]) ? 3 : 4)
	var/list/order = list("Unarmed", "Armed", "Gun", "Energy")
	var/obj/Skills/Ougi/E = usr.OugiEquipped()
	var/first = E ? E.OugiCategory : "Energy"
	order -= first
	order.Insert(1, first)
	var/mob/Player/AI/TestDummy/D
	for(var/mob/Player/AI/TestDummy/old in world)
		if(old.ai_owner == usr && old.z == usr.z && get_dist(old, usr) <= 10) D = old
	var/list/made = list()
	if(!D)
		D = OugiChainDummyAt(usr, get_step(usr, usr.dir))
		made += D
	var/list/cast = list(usr)
	var/list/cats = list(first)
	for(var/i = 2 to n)
		var/mob/Player/AI/TestDummy/M = OugiChainDummyAt(usr, locate(usr.x - i + 1, usr.y - 1, usr.z))
		made += M
		cast += M
		cats += order[i]
	var/datum/ougi_chain/C = OugiChainBurstPreview(usr, D, cast, cats)
	if(C) C.temp_mobs = made
	usr << OUGI_BURST_RULE_MOCKUP
	usr << OUGI_BURST_RULE_ASSETS

proc/OugiChainDummyAt(mob/owner, turf/spot)
	var/mob/Player/AI/TestDummy/D = new
	D.loc = spot ? spot : owner.loc
	D.ai_owner = owner
	D.ai_hostility = 0
	D.ai_wander = 0
	D.ai_state = "Idle"
	return D

/obj/ougi_chain_ring
	name = "chain chance"
	mouse_opacity = 0
	density = 0
	Savable = 0
	Grabbable = 0
	gfx_transient_visual = 1
	layer = FLY_LAYER
	appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA | KEEP_APART
	var
		list/pieces
		list/piece_state
		obj/ougi_chain_ring_part/tip
		mob/host
		t0 = 0
		window = 100
		live = 0

/obj/ougi_chain_ring_part
	mouse_opacity = 0
	density = 0
	Savable = 0
	Grabbable = 0
	gfx_transient_visual = 1
	layer = FLY_LAYER
	blend_mode = BLEND_ADD
	appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_APART

proc/OugiRingBoxX(i)
	return floor(glob.OUGI_RING_RADIUS * sin((i + 0.5) * OUGI_RING_STEP) + 0.5)

proc/OugiRingBoxY(i)
	return floor(glob.OUGI_RING_RADIUS * cos((i + 0.5) * OUGI_RING_STEP) + 0.5)

proc/OugiRingPieceState(i, a)
	if(a >= (i + 1) * OUGI_RING_STEP) return null
	if(a < i * OUGI_RING_STEP) return "p[i]"
	var/k = min(OUGI_RING_SUB - 1, floor((a - i * OUGI_RING_STEP) / (OUGI_RING_STEP / OUGI_RING_SUB)))
	return "p[i]_[k]"

proc/OugiRingRadiusAt(ds)
	var/p = clamp(ds / max(glob.OUGI_RING_GROW_DS, 0.1), 0, 1)
	p = 1 - (1 - p) * (1 - p)
	return glob.OUGI_RING_FROM + (glob.OUGI_RING_RADIUS - glob.OUGI_RING_FROM) * p

/obj/ougi_chain_ring/proc/Start(mob/T, ends_at)
	if(!T) return
	host = T
	t0 = world.time
	window = max(10, ends_at - world.time)
	live = 1
	var/s0 = glob.OUGI_RING_FROM / glob.OUGI_RING_RADIUS
	pieces = list()
	piece_state = list()
	for(var/i = 0 to OUGI_RING_PIECES - 1)
		var/obj/ougi_chain_ring_part/P = new
		P.icon = OUGI_CHAIN_RING_ART
		P.icon_state = "p[i]"
		var/bx = OugiRingBoxX(i)
		var/by = OugiRingBoxY(i)
		P.pixel_x = glob.OUGI_RING_CENTER_X + bx - OUGI_RING_BOX / 2
		P.pixel_y = glob.OUGI_RING_CENTER_Y + by - OUGI_RING_BOX / 2
		var/matrix/M = matrix()
		M.Scale(s0)
		M.Translate((1 - s0) * -bx, (1 - s0) * -by)
		P.transform = M
		pieces += P
		piece_state += "p[i]"
		vis_contents += P
	tip = new
	tip.icon = OUGI_CHAIN_TIP_ART
	tip.layer = FLY_LAYER + 0.01
	tip.pixel_x = glob.OUGI_RING_CENTER_X - OUGI_RING_TIP / 2
	tip.pixel_y = glob.OUGI_RING_CENTER_Y + glob.OUGI_RING_FROM - OUGI_RING_TIP / 2
	vis_contents += tip
	T.vis_contents += src
	spawn(world.tick_lag) Animate()
	spawn() Loop()

/obj/ougi_chain_ring/proc/Animate()
	if(!live) return
	for(var/obj/ougi_chain_ring_part/P in pieces)
		animate(P, transform = matrix(), time = glob.OUGI_RING_GROW_DS, easing = QUAD_EASING | EASE_OUT)
	var/n = max(8, glob.OUGI_RING_TIP_STEPS)
	var/left = window - (world.time - t0)
	var/dt = max(world.tick_lag, left / n)
	var/first = 1
	for(var/k = 1 to n)
		var/ds = (world.time - t0) + k * dt
		var/ang = 360 * clamp(ds / window, 0, 1)
		var/r = OugiRingRadiusAt(ds)
		var/px = glob.OUGI_RING_CENTER_X + round(r * sin(ang), 1) - OUGI_RING_TIP / 2
		var/py = glob.OUGI_RING_CENTER_Y + round(r * cos(ang), 1) - OUGI_RING_TIP / 2
		if(first)
			animate(tip, pixel_x = px, pixel_y = py, time = dt)
			first = 0
		else
			animate(pixel_x = px, pixel_y = py, time = dt)
	var/matrix/big = matrix()
	big.Scale(1.08)
	animate(tip, transform = big, time = 3, loop = -1, flags = ANIMATION_PARALLEL)
	animate(transform = matrix(), time = 3)

/obj/ougi_chain_ring/proc/Loop()
	while(live)
		var/a = 360 * (world.time - t0) / window
		if(a >= 360)
			for(var/obj/ougi_chain_ring_part/P in pieces)
				P.alpha = 0
			if(tip) animate(tip, alpha = 0, time = glob.OUGI_RING_TIP_FADE_DS, flags = ANIMATION_PARALLEL)
			sleep(glob.OUGI_RING_TIP_FADE_DS)
			Stop()
			return
		for(var/i = 1 to pieces.len)
			var/st = OugiRingPieceState(i - 1, a)
			if(st == piece_state[i]) continue
			piece_state[i] = st
			var/obj/ougi_chain_ring_part/P = pieces[i]
			if(st) P.icon_state = st
			else P.alpha = 0
		sleep(world.tick_lag)

/obj/ougi_chain_ring/proc/Stop()
	if(!live && !pieces) return
	live = 0
	if(host) host.vis_contents -= src
	host = null
	vis_contents.Cut()
	for(var/obj/O in pieces)
		del O
	pieces = null
	if(tip) del tip
	tip = null
	spawn(1) del src
