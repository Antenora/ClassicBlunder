mob/var/tmp/list/beam_chains

mob/proc/BeamChainFor(d)
	if(!beam_chains) beam_chains = list()
	var/beam_chain/c = beam_chains["[d]"]
	if(!c)
		c = new/beam_chain(src, d)
		beam_chains["[d]"] = c
	return c

beam_chain
	var/tmp
		mob/owner
		dirkey
		list/segments = list() //spawn order; [1] = oldest = front
		last_update = 0

	New(mob/M, d)
		owner = M
		dirkey = d

	proc/Register(obj/Skills/Projectile/_Projectile/s)
		segments += s

	proc/Unregister(obj/Skills/Projectile/_Projectile/s)
		segments -= s
		if(!segments.len)
			if(owner && owner.beam_chains)
				owner.beam_chains -= "[dirkey]"
			owner = null
			return
		UpdateStates(TRUE) //front died: immediate head handoff

	proc/UpdateStates(force)
		if(!force && last_update == world.time) return
		last_update = world.time
		var/firing = (owner && owner.Beaming == 2)
		var/n = segments.len
		for(var/i = 1, i <= n, i++)
			var/obj/Skills/Projectile/_Projectile/s = segments[i]
			if(s.Stream) continue 
			if(i == n && firing)
				s.icon_state = "origin"
				s.layer = 5
			else if(i == n && !firing)
				s.icon_state = "end"
				s.layer = 5
			else if(i == 1)
				if(s.Distance && !s.Piercing && s.BeamAheadBlocked())
					s.icon_state = "struggle"
					s.layer = 5
				else
					s.icon_state = "head"
					s.layer = 4
			else
				s.icon_state = "tail"
				s.layer = 4

obj/Skills/Projectile/_Projectile/proc/BeamAheadBlocked()
	var/turf/ahead = get_step(src, dir)
	if(!ahead) return FALSE
	for(var/mob/m in ahead)
		if(m.density && m != Owner) return TRUE
	for(var/obj/Skills/Projectile/_Projectile/p in ahead)
		if(p.Owner != src.Owner) return TRUE
	return FALSE
