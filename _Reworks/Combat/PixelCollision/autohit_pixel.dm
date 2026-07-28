obj/AutoHitter
	var/tmp
		UsesPixelCollision = FALSE
		list/LastHitAt
		HitInterval = 1
		pc_lastdir = 0

	proc/AH_SetupPixel(obj/Skills/AutoHit/Z)
		UsesPixelCollision = TRUE
		density = 0 //contact via sweep
		LastHitAt = list()
		HitInterval = max(Slow*world.tick_lag, world.tick_lag)
		if(PmActive() && Owner && (loc == Owner.loc || loc == get_step(Owner, Owner.dir)))
			step_x = Owner.step_x //mid-tile casters: strike from the sprite, not the tile
			step_y = Owner.step_y
		var/s = 1
		var/fitIcon = null
		if(ObjIcon && Z)
			fitIcon = Z.Icon
			s = Z.Size || 1
		ApplySkillHitbox(fitIcon, dir, s, Z ? Z.HitboxW : 0, Z ? Z.HitboxH : 0, Z ? Z.HitboxX : -1, Z ? Z.HitboxY : -1, Z ? Z.FireOffsetX : 0, Z ? Z.FireOffsetY : 0)
		pc_lastdir = dir

	proc/AH_InheritPixel(obj/AutoHitter/AH)
		UsesPixelCollision = TRUE
		density = 0
		LastHitAt = list()
		HitInterval = AH.HitInterval
		if(PmActive())
			step_x = AH.step_x //offshoots fan out from the parent's true position
			step_y = AH.step_y
		ApplySkillHitbox(AH.hb_icon, dir, AH.hb_scale, AH.hb_ovW, AH.hb_ovH, AH.hb_ovX, AH.hb_ovY, AH.hb_offX, AH.hb_offY)
		pc_lastdir = dir

	//zone damage as a true circle
	proc/AH_ZoneDamage(atom/epicenter, R, annulus=FALSE, los=TRUE)
		if(!epicenter || R < 0) return
		//tile-locked to match the VFX ring, not the caster's mid-tile sprite
		var/turf/e = get_turf(epicenter)
		if(!e) return
		var/cx = (e.x-1)*32 + 16
		var/cy = (e.y-1)*32 + 16
		for(var/mob/m in (los ? view(R+1, epicenter) : range(R+1, epicenter)))
			if(!hitSelf && m == Owner) continue
			if(!CircleHitsBounds(cx, cy, 32*R, m)) continue
			if(annulus && R > 1 && CircleHitsBounds(cx, cy, 32*(R-1), m)) continue
			src.Damage(m)

	proc/AH_TryContact(mob/m)
		if(!istype(m) || !m.density) return
		if(!hitSelf && m == Owner) return
		if(!RehitEligible(LastHitAt, m, HitInterval)) return
		spawn()
			src.Damage(m)
			if(src.NoPierce)
				endLife()

	proc/AH_ContactSweep()
		for(var/mob/m in range(HitboxSweepRange(), src))
			if(!HitboxesOverlap(src, m)) continue
			AH_TryContact(m)

	proc/AH_PixelStep()
		var/shown = DisplayedCardinal(dir, pc_lastdir)
		if(shown != pc_lastdir)
			ReapplyHitboxForDir(shown)
			pc_lastdir = shown
		var/turf/n = get_step(src, dir)
		var/blocked = !n || n.density //walls still stop strikes, like density used to
		if(!blocked)
			for(var/obj/o in n)
				if(o.density && !istype(o, /obj/AutoHitter) && !istype(o, /obj/Skills/Projectile/_Projectile))
					blocked = TRUE
					break
		if(!blocked)
			step(src, src.dir)
		AH_ContactSweep()
