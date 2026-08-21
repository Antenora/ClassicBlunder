mob/var/tmp/list/beam_chains

mob/proc/BeamChainFor(d, path)
	if(!beam_chains) beam_chains = list()
	var/key = "[d]:[path]"
	var/beam_chain/c = beam_chains[key]
	if(c && (world.time - c.last_fed) > 2) //previous pour, still dying - start fresh
		beam_chains -= key
		c = null
	if(!c)
		c = new/beam_chain(src, d)
		c.chainkey = key
		beam_chains[key] = c
	return c

var/list/_beam_state_cache = list() 

proc/BeamState(obj/Skills/Projectile/_Projectile/s, want, fallback)
	if(!s || !s.icon) return want
	var/key = "[s.icon]:[want]"
	var/has = _beam_state_cache[key]
	if(isnull(has))
		has = (want in icon_states(s.icon)) ? 1 : 0
		_beam_state_cache[key] = has
	return has ? want : fallback

beam_chain
	var/tmp
		mob/owner
		dirkey
		list/segments = list() //spawn order; [1] = oldest = front
		last_update = 0
		last_fed = 0 //when this chain last received a segment
		controlled = 0 
		step_delay = 0.5
		chainkey
		last_drive = 0 

	New(mob/M, d)
		owner = M
		dirkey = d

	proc/Register(obj/Skills/Projectile/_Projectile/s)
		segments += s
		last_fed = world.time
		if(segments.len == 1 && !s._fx_glowed) //front segment = beam head
			s._fx_glowed = 1
			FxAttachLight(s, null)
		if(controlled && last_drive && (world.time - last_drive) > step_delay * 4)
			controlled = 0
		if(!s.Stream)
			step_delay = max(s.Speed, world.tick_lag) 
			if(!controlled)
				controlled = 1
				last_drive = world.time
				spawn() Drive()
		UpdateStates(TRUE) 
	proc/Drive()
		set waitfor = 0
		var/fails = 0
		while(segments.len)
			sleep(step_delay)
			last_drive = world.time
			if(!segments.len) break
			try
				Advance()
				fails = 0
			catch(var/exception/e)
				world.log << "BEAM: chain Advance failed ([e])"
				if(++fails >= 3)
					for(var/obj/Skills/Projectile/_Projectile/s in segments.Copy())
						if(s) s.BeamRetire()
					break
		controlled = 0
	proc/Partition(list/spent)
		var/list/out = list()
		for(var/obj/Skills/Projectile/_Projectile/s in segments.Copy())
			if(!s || !s.loc)
				segments -= s
				continue
			if(s.Stream) continue
			if(s.Killed || s.Distance <= 0)
				spent += s
				continue
			out += s
		return out
	proc/Advance()
		var/list/spent = list()
		var/list/live = Partition(spent)
		if(!live.len && !spent.len) return
		var/frozen = 0
		for(var/obj/Skills/Projectile/_Projectile/s in live)
			if(!s.clash_lock) continue
			if(s.clash_lock.ended)
				s.clash_lock = null //struggle over and it never cleared us: self-heal
			else
				frozen = 1
		if(frozen) return //the clash controller owns the column while it lasts
		for(var/obj/Skills/Projectile/_Projectile/s in spent)
			s.BeamRetire()
		if(!live.len) return
		for(var/obj/Skills/Projectile/_Projectile/s in live) //contact first, as before
			if(!s.loc || s.Killed) continue
			s.PixelContactSweep()
		var/list/retire
		for(var/obj/Skills/Projectile/_Projectile/s in live)
			if(!s.loc || s.Killed || s.Distance <= 0) continue
			if(s.FadeOut && s.FadeOut >= s.Distance)
				animate(s, alpha = 0, time = max(1, s.FadeOut * s.Speed), flags = ANIMATION_PARALLEL)
				s.FadeOut = 0
			s.PixelStep() //through Move(): Trail/Divide/water/edge-of-map/Distance--
			//(no blocked-step compensator: step() enters Move() even when the move is
			//refused, and Move() decrements before calling ..(), so a wall already ages it)
			if(s.Distance <= 0)
				if(!retire) retire = list()
				retire += s
		if(retire)
			for(var/obj/Skills/Projectile/_Projectile/s in retire)
				s.BeamRetire()
		Repin() //re-pin the column, then relabel it

	proc/Unregister(obj/Skills/Projectile/_Projectile/s)
		segments -= s
		if(!segments.len)
			if(owner && owner.beam_chains)
				owner.beam_chains -= (chainkey ? chainkey : "[dirkey]")
			owner = null
			return
		Repin() //front died: close the hole, then hand off the head
		var/obj/Skills/Projectile/_Projectile/front = segments[1]
		if(front && !front._fx_glowed) //glow follows the head
			front._fx_glowed = 1
			FxAttachLight(front, null)
	proc/EnforceColumn()
		var/n = segments.len
		if(n < 2) return
		var/obj/Skills/Projectile/_Projectile/front = segments[1]
		if(!front || !front.loc || front.clash_lock) return //a struggle owns the column
		var/back = turn(front.dir, 180)
		var/turf/T = get_turf(front)
		var/list/strays
		for(var/i = 2, i <= n, i++)
			T = get_step(T, back)
			if(!T) return
			var/obj/Skills/Projectile/_Projectile/s = segments[i]
			if(!s || !s.loc || s.Stream || s.clash_lock) continue
			if(s.pc_lastdir && s.dir != front.dir)
				if(!strays) strays = list()
				strays += s
				continue
			if(s.loc != T) s.loc = T
			if(s.step_x || s.step_y) //sub-tile drift copied off a moving caster
				s.step_x = 0
				s.step_y = 0
		if(strays)
			for(var/obj/Skills/Projectile/_Projectile/s in strays)
				s.chain = null
				segments -= s
				s.BeamRetire()
	proc/UpdateStates(force)
		if(!force && last_update == world.time) return
		last_update = world.time
		Relabel()

	proc/Repin()
		EnforceColumn()
		Relabel()

	proc/Relabel()
		var/firing = (owner && owner.Beaming == 2 && world.time - last_fed <= 2)
		var/n = segments.len
		for(var/i = 1, i <= n, i++)
			var/obj/Skills/Projectile/_Projectile/s = segments[i]
			if(s.Stream) continue
			if(i == n && firing)
				s.icon_state = BeamState(s, "origin", "tail")
				s.layer = 5
			else if(i == n && !firing)
				s.icon_state = BeamState(s, "end", "tail")
				s.layer = 5
			else if(i == 1)
				if(s.Distance && !s.Piercing && s.BeamAheadBlocked())
					s.icon_state = BeamState(s, "struggle", "head")
					s.layer = 5
				else
					s.icon_state = BeamState(s, "head", "tail")
					s.layer = 4
			else
				s.icon_state = "tail"
				s.layer = 4

//the terminus the per-segment loop used to run when its Distance ran out
obj/Skills/Projectile/_Projectile/proc/BeamRetire()
	if(Owner) Owner.active_projectiles -= src
	ProjectileFinish()

obj/Skills/Projectile/_Projectile/proc/BeamAheadBlocked()
	if(UsesPixelCollision && vhb_w > 0)
		//struggle needs real ink overlap
		for(var/atom/movable/a in range(HitboxSweepRange(), src))
			if(a == src || a == Owner) continue
			if(ismob(a))
				var/mob/m = a
				if(m.density && HitboxesOverlap(src, m)) return TRUE
			else if(istype(a, /obj/Skills/Projectile/_Projectile))
				var/obj/Skills/Projectile/_Projectile/p = a
				if(p.Owner != src.Owner && HitboxesOverlap(src, p)) return TRUE
		var/turf/ta = get_step(src, dir)
		if(ta && ta.density) return TRUE 
		return FALSE
	var/turf/ahead = get_step(src, dir)
	if(!ahead) return FALSE
	for(var/mob/m in ahead)
		if(m.density && m != Owner) return TRUE
	for(var/obj/Skills/Projectile/_Projectile/p in ahead)
		if(p.Owner != src.Owner) return TRUE
	return FALSE
