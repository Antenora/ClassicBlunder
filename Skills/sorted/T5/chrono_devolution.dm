/obj/Skills/AutoHit/Chrono_Devolution
	SkillCost=TIER_5_COST
	Copyable=6
	SignatureTechnique=5
	Area="Target"
	Distance=10
	EnergyCost=30
	ForScaling=1
	StrScaling=0
	DamageMult=40
	Cooldown=-1
	CanBeDodged=0
	CanBeBlocked=0
	GuardBreak=1
	AllOutAttack=1
	HitSparkIcon='BLANK.dmi'
	WindupMessage="reaches out toward their target's timeline..."
	ActiveMessage="rewinds their target's personal history, ripping them back to an earlier state of being!"
	BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Chrono_Devolution"
	verb/Chrono_Devolution()
		set category="Skills"
		if(!usr.Activate(src))
			return
		playChronoDevolutionVisual(usr, usr.Target)

// Visual

var/global/list/CHRONO_DEV_GREYSCALE_MATRIX = list(
	0.33, 0.33, 0.33,
	0.33, 0.33, 0.33,
	0.33, 0.33, 0.33,
	0,    0,    0)

/proc/playChronoDevolutionVisual(mob/user, atom/target)
	set waitfor = FALSE
	if(!target) return

	var/max_radius = 10
	var/apply_hold = 5
	var/ring_delay = 3

	for(var/cycle in 1 to 3)
		var/turf/origin = get_turf(target)
		if(!origin) return

		var/list/rings = list()
		for(var/i in 1 to max_radius + 1)
			rings += list(list())

		for(var/turf/T in range(max_radius, origin))
			var/dx = T.x - origin.x
			var/dy = T.y - origin.y
			var/dist = sqrt(dx*dx + dy*dy)
			if(dist > max_radius) continue
			var/r = round(dist + 0.5) // nearest-int ring index, biased outward
			if(r < 0) r = 0
			if(r > max_radius) r = max_radius
			var/list/slot = rings[r + 1]
			slot += T

		var/list/tile_orig = list()
		var/list/atom_orig = list()

		// Paint everything grey, innermost ring first so layered visuals update
		// in a predictable order.
		for(var/r in 0 to max_radius)
			var/list/slot = rings[r + 1]
			for(var/turf/T in slot)
				if(!T) continue
				tile_orig[T] = T.color
				animate(T, color = CHRONO_DEV_GREYSCALE_MATRIX, time = 1)
				for(var/atom/movable/A in T)
					if(A == user) continue
					if(A in atom_orig) continue
					atom_orig[A] = A.color
					animate(A, color = CHRONO_DEV_GREYSCALE_MATRIX, time = 1)

		sleep(apply_hold)

		// Shrink the greyscale zone back toward the origin, ring by ring.
		for(var/r = max_radius, r >= 0, r--)
			var/list/slot = rings[r + 1]
			for(var/turf/T in slot)
				if(!T) continue
				if(T in tile_orig)
					animate(T, color = tile_orig[T], time = ring_delay)
					tile_orig -= T
				for(var/atom/movable/A in T)
					if(A in atom_orig)
						animate(A, color = atom_orig[A], time = ring_delay)
						atom_orig -= A
			sleep(ring_delay)

		// Final sweep: anything that moved out of the zone or wasn't caught
		// during ring restoration gets its original color forced back.
		for(var/turf/T as anything in tile_orig)
			if(T) T.color = tile_orig[T]
		for(var/atom/movable/A as anything in atom_orig)
			if(A) A.color = atom_orig[A]

/mob/proc/forceRevertAll()
	var/safety = 10
	while(transActive > 0 && safety-- > 0)
		var/prev = transActive
		Revert()
		if(transActive >= prev)
			break

// Builds a snapshot capturing one ascension's full contribution
/proc/_chronoAscensionSnapshot(ascension/a)
	var/list/snap = list(
		"powerAdd" = 0,
		"strength" = 0,
		"endurance" = 0,
		"force" = 0,
		"offense" = 0,
		"defense" = 0,
		"speed" = 0,
		"recovery" = 0,
		"intelligenceAdd" = 0,
		"imaginationAdd" = 0,
		"angerPoint" = 0,
		"pilotingProwess" = 0,
		"cyberizeModAdd" = 0,
		"enhanceChips" = 0,
		"rppAdd" = 0,
		"ecoAdd" = 0,
		"passives" = list())
	if(!a) return snap
	_chronoAccumulateAscension(a, snap)
	if(a.choiceSelected)
		var/ascension/sub = a.choiceSelected
		if(sub)
			_chronoAccumulateAscension(sub, snap)
	return snap

/proc/_chronoAccumulateAscension(ascension/a, list/snap)
	if(!a || !islist(snap)) return
	snap["powerAdd"]        += a.powerAdd
	snap["strength"]        += a.strength
	snap["endurance"]       += a.endurance
	snap["force"]           += a.force
	snap["offense"]         += a.offense
	snap["defense"]         += a.defense
	snap["speed"]           += a.speed
	snap["recovery"]        += a.recovery
	snap["intelligenceAdd"] += a.intelligenceAdd
	snap["imaginationAdd"]  += a.imaginationAdd
	if(a.angerPoint)
		snap["angerPoint"]  += a.angerPoint
	snap["pilotingProwess"] += a.pilotingProwess
	snap["cyberizeModAdd"]  += a.cyberizeModAdd
	snap["enhanceChips"]    += a.enhanceChips
	snap["rppAdd"]          += a.rppAdd
	snap["ecoAdd"]          += a.ecoAdd
	if(islist(a.passives))
		var/list/pmap = snap["passives"]
		for(var/p in a.passives)
			var/v = a.passives[p]
			if(!isnum(v)) continue
			pmap[p] = (isnum(pmap[p]) ? pmap[p] : 0) + v

// Applies (sign=+1) or removes (sign=-1) the contents of an ascension snapshot
// directly to the target's persistent ascension fields.
/mob/proc/_chronoApplyAscensionSnapshot(list/snap, sign)
	if(!islist(snap)) return
	PotentialRate   += sign * snap["powerAdd"]
	StrAscension    += sign * snap["strength"]
	EndAscension    += sign * snap["endurance"]
	ForAscension    += sign * snap["force"]
	OffAscension    += sign * snap["offense"]
	DefAscension    += sign * snap["defense"]
	SpdAscension    += sign * snap["speed"]
	RecovAscension  += sign * snap["recovery"]
	Intelligence    += sign * snap["intelligenceAdd"]
	Imagination     += sign * snap["imaginationAdd"]
	PilotingProwess += sign * snap["pilotingProwess"]
	CyberizeMod     += sign * snap["cyberizeModAdd"]
	EnhanceChipsMax += sign * snap["enhanceChips"]
	RPPMult         += sign * snap["rppAdd"]
	EconomyMult     += sign * snap["ecoAdd"]
	if(snap["angerPoint"])
		AngerPoint  += sign * snap["angerPoint"]
	var/list/p = snap["passives"]
	if(islist(p) && p.len > 0 && passive_handler)
		if(sign > 0)
			passive_handler.increaseList(p)
		else
			passive_handler.decreaseList(p)

// Debuff

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Chrono_Devolution
	AlwaysOn = 1
	NeedsPassword = 1
	PauseInRP = 1
	TimerLimit = 60
	BuffName = "Chrono Devolution"
	IconLock = 'SweatDrop.dmi'
	CantTrans = TRUE
	ActiveMessage = "has been temporally devolved; their amassed power is ripped from their very being!"
	OffMessage = "feels their timeline reassert itself; their power returning to them."

	// Per-ascension snapshots
	var/list/saved_ascensions = list()
	// transActive level the target had at the moment of cast.
	var/saved_transActive = 0
	// How many transformation tiers already auto-restored.
	var/restored_transActive = 0
	// Timer value at the time of the last partial restore tick.
	var/last_restore = 0
	// Seconds between partial restores
	var/restore_interval = 10
	var/devolved = 0

	proc/captureAscensions(mob/target)
		saved_ascensions = list()
		if(!target || !target.race) return
		var/list/ascs = target.race.ascensions
		if(!islist(ascs) || !ascs.len) return
		var/cap = min(target.AscensionsAcquired, ascs.len)
		for(var/i = 1, i <= cap, i++)
			var/ascension/a = ascs[i]
			if(!a || !a.applied) continue
			var/list/snap = _chronoAscensionSnapshot(a)
			if(islist(snap))
				saved_ascensions += list(snap)

	proc/applyDevolution(mob/target)
		if(!target || devolved) return
		captureAscensions(target)
		for(var/list/snap in saved_ascensions)
			target._chronoApplyAscensionSnapshot(snap, -1)
		saved_transActive = target.transActive
		restored_transActive = 0
		last_restore = 0
		target.forceRevertAll()
		devolved = 1

	// Restore everything still owed to the target.
	proc/restoreDevolution(mob/target, autoTrans = FALSE)
		if(!target || !devolved) return
		if(islist(saved_ascensions))
			for(var/list/snap in saved_ascensions)
				target._chronoApplyAscensionSnapshot(snap, 1)
		saved_ascensions = list()
		if(autoTrans && target.race && islist(target.race.transformations))
			var/safety = 20
			while(restored_transActive < saved_transActive && safety-- > 0)
				if(!_chronoStepUpTransform(target))
					break
		devolved = 0
		saved_transActive = 0
		restored_transActive = 0
		last_restore = 0

	// Force-transform target up by exactly one tier
	proc/_chronoStepUpTransform(mob/target)
		if(!target || !target.race) return FALSE
		var/list/transes = target.race.transformations
		if(!islist(transes)) return FALSE
		var/next_idx = target.transActive + 1
		if(next_idx > transes.len) return FALSE
		var/transformation/next = transes[next_idx]
		if(!next) return FALSE
		var/prev = target.transActive
		next.transform(target, TRUE)
		if(target.transActive > prev)
			restored_transActive++
			return TRUE
		return FALSE

	GainLoop(mob/source)
		..()
		if(!devolved || !source) return
		if(PauseInRP && source.PureRPMode) return
		if(!isnum(Timer)) Timer = 0
		if(Timer - last_restore < restore_interval) return
		last_restore += restore_interval
		// Restore one ascension (oldest snapshot first)
		if(islist(saved_ascensions) && saved_ascensions.len > 0)
			var/list/snap = saved_ascensions[1]
			saved_ascensions.Cut(1, 2)
			source._chronoApplyAscensionSnapshot(snap, 1)
		// Restore one transformation tier the cast originally stripped.
		if(restored_transActive < saved_transActive)
			_chronoStepUpTransform(source)

	Trigger(mob/User, Override = FALSE)
		if(!User.BuffOn(src))
			applyDevolution(User)
		else
			// Natural expiry (Timer hit TimerLimit) gets a "full reset" that
			// also auto-transforms the target back up to where they started.
			// Forced/early deactivations (like relogging) fully reset the debuff as a just in case.
			var/natural_expiry = (isnum(Timer) && Timer >= TimerLimit)
			restoreDevolution(User, autoTrans = natural_expiry)
			Timer = 0
		..()
