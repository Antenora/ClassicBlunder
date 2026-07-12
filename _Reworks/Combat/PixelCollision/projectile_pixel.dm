obj/Skills/Projectile/_Projectile
	var/tmp
		UsesPixelCollision = FALSE
		list/LastHitAt
		HitInterval = 1
		pc_lastdir = 0
		beam_chain/chain

	proc/SetupPixelHitbox(obj/Skills/Projectile/Z, DirOverride=0)
		density = 0 //contact via sweep; walls handled in PixelWallCheck
		LastHitAt = list()
		HitInterval = max(Speed, world.tick_lag)
		var/s = 1
		if(Z.IconSize != 1)
			s = Z.TempSize || Z.IconSize
		if(Z.IconSizeGrowTo) //grow-anim skills
			s = Z.IconSizeGrowTo
		var/fitdir = DisplayedCardinal(DirOverride || (Owner ? Owner.dir : dir), SOUTH)
		ApplySkillHitbox(src.icon, fitdir, s, Z.HitboxW, Z.HitboxH, Z.HitboxX, Z.HitboxY, Z.FireOffsetX, Z.FireOffsetY)
		pc_lastdir = fitdir
		if(Area == "Beam" && Owner)
			animate_movement = NO_STEPS //segments arrive in lockstep, no glide, as old BeamGraphics set
			chain = Owner.BeamChainFor(fitdir)
			chain.Register(src)

	proc/OnContact(atom/a)
		if(Killed || Distance < 0) return
		if(glob.PIXEL_DEBUG) world.log << "PXC: [src] at ([x],[y]) Bump -> [a] ([a.type]) at ([a.x],[a.y])"
		src.Bump(a)

	//shared filters for every contact candidate from the sweep
	proc/TryPixelContact(atom/movable/a)
		if(Killed || Distance < 0 || a == src) return
		if(!HitboxesOverlap(src, a)) return
		if(istype(a, /obj/Skills/Projectile/_Projectile))
			var/obj/Skills/Projectile/_Projectile/p = a
			if(p.Owner == src.Owner) return
			if(!RehitEligible(LastHitAt, p, HitInterval)) return //clash once per iteration
			OnContact(p)
			return
		if(a == src.Owner && !src.Backfire) return
		if(a.Owner == src.Owner)
			if(glob.PIXEL_DEBUG) world.log << "PXC: [src] skip [a] (same Owner)"
			return
		if(src.StormFall && a.pixel_z != src.pixel_z) return
		if(ismob(a))
			var/mob/m = a
			if(!m.density)
				if(glob.PIXEL_DEBUG) world.log << "PXC: [src] skip [m] (not dense)"
				return
			if(!RehitEligible(LastHitAt, m, HitInterval)) return
			OnContact(m)
		else if(a.density)
			OnContact(a)

	proc/PixelContactSweep()
		for(var/atom/movable/a in range(HitboxSweepRange(), src))
			TryPixelContact(a)
			if(Killed || Distance < 0) return

	proc/PixelStep()
		var/shown = DisplayedCardinal(dir, pc_lastdir) //what the client is drawing, incl. sticky diagonals
		if(isfile(icon) && icon != hb_icon) //mid-flight reskin (spawn-and-grab pattern): box+mask follow the new art
			ApplySkillHitbox(icon, shown, hb_scale, hb_ovW, hb_ovH, hb_ovX, hb_ovY, hb_offX, hb_offY)
		else if(shown != pc_lastdir) //deflects/homing turns re-fit the displayed-dir data
			ReapplyHitboxForDir(shown)
		pc_lastdir = shown
		step(src, src.dir) //runs the Move() override (Trail/Divide/Distance--)
		PixelWallCheck()

	proc/PixelWallCheck()
		var/turf/t = loc
		if(istype(t) && t.density)
			OnContact(t)

	proc/PixelLife()
		Cooldown=-1 //Keeps active projectiles from moving onto the player during their movements.
		pc_lastdir = DisplayedCardinal(dir, pc_lastdir) //dir is only final once the spawn block ran
		ReapplyHitboxForDir(pc_lastdir)
		if(glob.PIXEL_DEBUG) world.log << "PXC: [src] PixelLife start dir=[dir] box=[vhb_w]x[vhb_h] scale=[hb_scale] icon=[icon] mask=[vhb_mask ? "y" : "n"] dist=[Distance]"
		while(src.Distance>0)
			if(src.Area=="Beam" && chain)
				chain.UpdateStates()
			if(src.EdgeOfMapProjectile())
				Distance=0
				break
			if(src.Homing)
				if(!src.Owner.Target)
					Distance=0
				if(forcedTarget)
					Homing = forcedTarget
				if(src.LosesHoming)
					var/Time=src.LosesHoming
					spawn(Time)
						if(src.RandomPath)
							var/list/Dirs=list(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH)
							Dirs.Remove(turn(src.dir, 135))
							Dirs.Remove(turn(src.dir, 180))
							Dirs.Remove(turn(src.dir, 225))
							src.dir=pick(Dirs)
						src.Homing=0
						src.LosesHoming=Time
					src.LosesHoming=0
				if(!src.Backfire)
					spawn(30)
						src.Backfire=1
			if(src.HomingCharge&&!src.Homing&&!src.HomingChargeSpent)
				src.HomingCharge-=1
				src.HomingChargeSpent=1
				spawn(src.HomingDelay)
					if(src.Owner)
						if(src.Owner.Target&&src.Owner.Target!=src.Owner)
							src.Homing=src.Owner.Target
						src.Distance=src.DistanceMax
						src.HomingChargeSpent=0
			if(src.ProjectileSpin)
				if(!src.transform)
					src.transform = matrix()
				src.transform = src.transform.Turn(src.ProjectileSpin)
			sleep(src.Speed)
			PixelContactSweep()
			if(FadeOut && FadeOut>=Distance)
				animate(src, alpha=0, time=max(1,FadeOut*Speed), flags=ANIMATION_PARALLEL)
				FadeOut=0
			if(0>=Distance)
				break
			if(src.Area!="Beam")
				if(src.Homing)
					src.dir=get_dir(src, src.Homing)
				else
					if(src.RandomPath==2)
						var/ODir=src.dir
						while(src.dir==ODir)
							src.dir=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH)
				if(!src.Static&&!src.StormFall)
					PixelStep()
				else
					src.Distance--
					if(src.StormFall)
						animate(src, pixel_z=-1, flags=ANIMATION_RELATIVE)
			else
				PixelStep() //32px per Speed sleep = old walk() rate
		if(Owner) Owner.active_projectiles -= src
		ProjectileFinish()
		return
