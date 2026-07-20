obj/Skills/Projectile/_Projectile
	var/tmp
		UsesPixelCollision = FALSE
		list/LastHitAt
		HitInterval = 1
		pc_lastdir = 0
		pm_substep = 0 //ticks per tile under engine pixel movement; 0 = tile stepping
		icon_var_scale = 1 //IconVariance random art-scale roll, so the box matches the drawn size
		beam_chain/chain

	proc/SetupPixelHitbox(obj/Skills/Projectile/Z, DirOverride=0)
		density = 0 //contact via sweep; walls handled in PixelWallCheck
		LastHitAt = list()
		HitInterval = max(Speed, world.tick_lag)
		if(PmActive() && Owner && (loc == Owner.loc || loc == get_step(Owner, DirOverride || Owner.dir)))
			step_x = Owner.step_x //mid-tile casters: launch from the sprite, not the tile
			step_y = Owner.step_y
		pm_substep = 0
		if(PmActive() && Area != "Beam" && !Static && !StormFall)
			pm_substep = max(1, round(Speed / world.tick_lag))
			step_size = max(1, round(32 / pm_substep)) //step()'s px arg does nothing - step_size is what moves
		var/s = 1
		if(Z.IconSize != 1)
			s = Z.TempSize || Z.IconSize
		s *= icon_var_scale
		if(Z.IconSizeGrowTo) //grow-anim skills
			s = Z.IconSizeGrowTo
		var/fitdir = DisplayedCardinal(DirOverride || (Owner ? Owner.dir : dir), SOUTH)
		ApplySkillHitbox(src.icon, fitdir, s, Z.HitboxW, Z.HitboxH, Z.HitboxX, Z.HitboxY, Z.FireOffsetX, Z.FireOffsetY)
		pc_lastdir = fitdir
		if(Area == "Beam" && Owner)
			animate_movement = NO_STEPS //segments arrive in lockstep, no glide, as old BeamGraphics set
			//key on the TRUE travel dir - a diagonal volley arm collapsed to a cardinal would share its chain
			var/truedir = DirOverride || (Owner ? Owner.dir : dir)
			chain = Owner.BeamChainFor(truedir)
			chain.Register(src)

	proc/OnContact(atom/a)
		if(Killed || Distance < 0) return
		if(glob.PIXEL_DEBUG) world.log << "PXC: [src] at ([x],[y]) Bump -> [a] ([a.type]) at ([a.x],[a.y])"
		src.Bump(a)

	//shared filters for every contact candidate from the sweep
	proc/TryPixelContact(atom/movable/a)
		if(Killed || Distance < 0 || a == src) return
		if(src.Homing && a == src.Homing && a.loc == src.loc)
			//co-tile with the locked target always hits - tiny masks can miss point blank
			if(RehitEligible(LastHitAt, a, HitInterval))
				OnContact(a)
			return
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

	proc/StaticRadiusSweep()
		for(var/atom/movable/a in view(src.Radius, src))
			if(a == src) continue
			if(istype(a, /obj/Skills/Projectile/_Projectile))
				var/obj/Skills/Projectile/_Projectile/p = a
				if(p.Owner == src.Owner) continue
				if(!RehitEligible(LastHitAt, p, HitInterval)) continue
				OnContact(p)
			else if(a == src.Owner)
				if(src.Backfire) OnContact(a)
			else if(a.Owner == src.Owner)
				continue
			else if(src.StormFall && a.pixel_z != src.pixel_z)
				continue
			else if(ismob(a))
				var/mob/m = a
				if(m.density && RehitEligible(LastHitAt, m, HitInterval))
					OnContact(m)
			else if(a.density)
				OnContact(a)
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

	//32px per Speed spread over per-tick slides, contact sampled at the true drawn position
	proc/PmTravel()
		//dir is fixed for the whole slide set - re-aiming every micro-step makes homers spasm on overshoot
		for(var/i = 1, i <= pm_substep, i++)
			sleep(world.tick_lag)
			if(Killed || Distance <= 0) return
			var/shown = DisplayedCardinal(dir, pc_lastdir)
			if(isfile(icon) && icon != hb_icon)
				ApplySkillHitbox(icon, shown, hb_scale, hb_ovW, hb_ovH, hb_ovX, hb_ovY, hb_offX, hb_offY)
			else if(shown != pc_lastdir)
				ReapplyHitboxForDir(shown)
			pc_lastdir = shown
			step(src, src.dir) //moves step_size px, set at hitbox setup
			PixelWallCheck()
			if(Killed || Distance <= 0) return
			PixelContactSweep()

	proc/PixelLife()
		Cooldown=-1 //Keeps active projectiles from moving onto the player during their movements.
		pc_lastdir = DisplayedCardinal(dir, pc_lastdir) //dir is only final once the spawn block ran
		ReapplyHitboxForDir(pc_lastdir)
		if(glob.PIXEL_DEBUG) world.log << "PXC: [src] PixelLife start dir=[dir] box=[vhb_w]x[vhb_h] scale=[hb_scale] icon=[icon] mask=[vhb_mask ? "y" : "n"] dist=[Distance]"
		if(pm_substep) //pre-move sample so point-blank casts hit a mob on the spawn tile
			PixelContactSweep()
			if(Killed || Distance <= 0)
				if(Owner) Owner.active_projectiles -= src
				ProjectileFinish()
				return
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
			if((src.HyperHoming && src.Homing) || (src.HomingCharge && !src.Homing))
				//bump the locked target whenever it sits within Radius tiles
				var/mob/htgt = forcedTarget || (src.Owner ? src.Owner.Target : null)
				if(ismob(htgt) && (htgt in view(max(1, src.Radius), src)) && RehitEligible(LastHitAt, htgt, HitInterval))
					OnContact(htgt)
			if(src.ProjectileSpin)
				if(!src.transform)
					src.transform = matrix()
				src.transform = src.transform.Turn(src.ProjectileSpin)
			if(!pm_substep) //substep mode sleeps+sweeps per tick inside PmTravel instead
				sleep(src.Speed)
				if((src.Static || src.StormFall) && src.Radius>0) //proximity bomb / falling meteor: Radius tiles, not the ink footprint
					StaticRadiusSweep()
				else
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
					if(pm_substep)
						PmTravel()
					else
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
