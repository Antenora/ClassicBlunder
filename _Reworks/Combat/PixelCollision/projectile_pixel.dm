obj/Skills/Projectile/_Projectile
	var/tmp
		UsesPixelCollision = FALSE
		list/LastHitAt
		HitInterval = 1
		pc_lastdir = 0
		pm_substep = 0 //ticks per tile under engine pixel movement; 0 = tile stepping
		icon_var_scale = 1 //IconVariance random art-scale roll, so the box matches the drawn size
		pc_basescale = 1
		beam_chain/chain
		mob/instant_pin
		instant_pinning = 0

	proc/SetupPixelHitbox(obj/Skills/Projectile/Z, DirOverride=0)
		density = 0 //contact via sweep; walls handled in PixelWallCheck
		LastHitAt = list()
		HitInterval = max(Speed, world.tick_lag)
		//beams are excluded
		if(PmActive() && Area != "Beam" && Owner && (loc == Owner.loc || loc == get_step(Owner, DirOverride || Owner.dir)))
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
		pc_basescale = s
		if(Z.IconSizeGrowTo) //grow-anim skills
			s = Z.IconSizeGrowTo
		var/fitdir = DisplayedCardinal(DirOverride || (Owner ? Owner.dir : dir), SOUTH)
		ApplySkillHitbox(src.icon, fitdir, s, Z.HitboxW, Z.HitboxH, Z.HitboxX, Z.HitboxY, Z.FireOffsetX, Z.FireOffsetY)
		pc_lastdir = fitdir
		if(Area == "Beam" && Owner)
			animate_movement = NO_STEPS //segments arrive in lockstep, no glide, as old BeamGraphics set
			if(!beam_owner)
				//key on the TRUE travel dir - a diagonal volley arm collapsed to a cardinal would share its chain
				var/truedir = DirOverride || (Owner ? Owner.dir : dir)
				chain = Owner.BeamChainFor(truedir, SkillPath)
				chain.Register(src)

	proc/OnContact(atom/a)
		if(Killed || Distance < 0) return
		if(ContactFuse && ismob(a))
			if(!fuse_at)
				fuse_at = world.time + ContactFuse
				EnergyFXProjectileFuse(src, a)
				return
			if(world.time < fuse_at) return
		if(glob.PIXEL_DEBUG) world.log << "PXC: [src] at ([x],[y]) Bump -> [a] ([a.type]) at ([a.x],[a.y])"
		if(InstantTravel && !instant_pinning && !instant_pin && ismob(a) && MultiHit && !Piercing) instant_pin = a
		src.Bump(a)

	proc/InstantPinHits()
		var/mob/m = instant_pin
		instant_pin = null
		instant_pinning = 1
		var/n = 0
		while(m && !Killed && Distance > 0 && n++ < 64)
			var/before = MultiHit
			OnContact(m)
			if(MultiHit == before) break
		instant_pinning = 0

	proc/SweepAllySkip(mob/m)
		if(!Owner || !m || m == Owner) return FALSE
		if(Owner.inParty(m.ckey)) return TRUE
		if(Owner in m.ai_followers) return TRUE
		if(istype(Owner, /mob/Player/AI))
			var/mob/Player/AI/oai = Owner
			if(!oai.ai_team_fire && oai.AllianceCheck(m)) return TRUE
		if(istype(m, /mob/Player/AI))
			var/mob/Player/AI/mai = m
			if(!mai.ai_team_fire && mai.AllianceCheck(Owner)) return TRUE
		return FALSE

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
			if(m.proj_immune_until > world.time)
				return
			if(!m.density)
				if(glob.PIXEL_DEBUG) world.log << "PXC: [src] skip [m] (not dense)"
				return
			if(!RehitEligible(LastHitAt, m, HitInterval)) return
			OnContact(m)
		else if(a.density && !ArcShot)
			OnContact(a)

	proc/PixelContactSweep()
		for(var/atom/movable/a in range(HitboxSweepRange(), src) | BigBodiesNear(src, HitboxSweepRange()))
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
				if(m.density && !SweepAllySkip(m) && RehitEligible(LastHitAt, m, HitInterval))
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
		RefitGrowScale()
		step(src, src.dir) //runs the Move() override (Trail/Divide/Distance--)
		PixelWallCheck()

	proc/PixelWallCheck()
		if(ArcShot)
			return
		var/turf/t = loc
		if(istype(t) && t.density)
			OnContact(t)

	//32px per Speed spread over per-tick slides, contact sampled at the true drawn position
	proc/PmTravel()
		//dir is fixed for the whole slide set - re-aiming every micro-step makes homers spasm on overshoot
		for(var/i = 1, i <= pm_substep, i++)
			if(!InstantTravel || fuse_at) sleep(world.tick_lag)
			if(Killed || Distance <= 0) return
			if(fuse_at && world.time < fuse_at)
				i--
				continue
			var/shown = DisplayedCardinal(dir, pc_lastdir)
			if(isfile(icon) && icon != hb_icon)
				ApplySkillHitbox(icon, shown, hb_scale, hb_ovW, hb_ovH, hb_ovX, hb_ovY, hb_offX, hb_offY)
			else if(shown != pc_lastdir)
				ReapplyHitboxForDir(shown)
			pc_lastdir = shown
			RefitGrowScale()
			step(src, src.dir) //moves step_size px, set at hitbox setup
			PixelWallCheck()
			if(Killed || Distance <= 0) return
			if(drive_mob)
				DriveStep()
				if(Killed || Distance <= 0) return
			PixelContactSweep()
			if(instant_pin) InstantPinHits()
			if(efx_shot) efx_shot.FlightTick(src)
			EnergyFXProjectileTick(src)

	proc/HomingBroken(atom/target)
		return 0

	proc/EmitBit(bi = 0)
		var/turf/at = src.loc
		var/sx = src.step_x
		var/sy = src.step_y
		var/mob/own = src.Owner
		var/ocx = (src.x - 1) * 32 + src.step_x + 16 + src.vhb_ax
		var/ocy = (src.y - 1) * 32 + src.step_y + 16 + src.vhb_ay
		if((src.Killed || !isturf(at) || !own) && src.emit_last)
			at = src.emit_last[1]
			sx = src.emit_last[2]
			sy = src.emit_last[3]
			own = src.emit_last[4]
			ocx = src.emit_last[5]
			ocy = src.emit_last[6]
		if(!src.EmitChild || !own || !isturf(at)) return
		var/obj/Skills/Projectile/_Projectile/eb = own.Blast(src.EmitChild, at, 0)
		if(eb && eb.loc == at)
			eb.step_x = sx
			eb.step_y = sy
		if(eb)
			eb.emit_parent = src
			eb.emit_index = bi
			eb.kick_px = ocx
			eb.kick_py = ocy
			if(src.emit_angles && bi >= 0 && bi < src.emit_angles.len)
				eb.kick_angle = src.emit_angles[bi + 1]
		if(eb && own.Target && ismob(own.Target) && own.Target != own)
			eb.Homing = own.Target
			eb.forcedTarget = own.Target

	proc/KickPlace(px, py)
		var/gx = round(px - 16 - vhb_ax, 1)
		var/gy = round(py - 16 - vhb_ay, 1)
		var/tx = round(gx / 32) + 1
		var/ty = round(gy / 32) + 1
		var/turf/T = locate(tx, ty, src.z)
		if(!T || T.density) return 0
		src.loc = T
		src.step_x = gx - (tx - 1) * 32
		src.step_y = gy - (ty - 1) * 32
		return 1

	proc/KickLife()
		var/list/K = KICK_PATH
		var/mob/T = ismob(src.Homing) ? src.Homing : null
		var/a = src.kick_angle
		var/zz = src.z
		var/px = (isnull(src.kick_px) ? (src.x - 1) * 32 + src.step_x + 16 + vhb_ax : src.kick_px) + cos(a) * K["r0"]
		var/py = (isnull(src.kick_py) ? (src.y - 1) * 32 + src.step_y + 16 + vhb_ay : src.kick_py) + sin(a) * K["r0"]
		src.kick_px = px
		src.kick_py = py
		if(!KickPlace(px, py)) return
		var/dt = K["dt"]
		var/sub = max(1, round(world.tick_lag / 10 / dt, 1))
		var/t = 0
		var/turn = K["turn"] * dt
		while(!src.Killed && src.Distance > 0 && t < K["t_max"])
			sleep(world.tick_lag)
			if(src.Killed || src.Distance <= 0 || src.z != zz) break
			if(T && (!T.loc || T.z != zz)) T = null
			var/reached = 0
			for(var/i = 1 to sub)
				t += dt
				var/v = K["v1"] + (K["v0"] - K["v1"]) * 2.718281828 ** (-t / K["tau"])
				if(T && t > K["delay"])
					var/da = arctan((T.x - 1) * 32 + T.step_x + 16 - px, (T.y - 1) * 32 + T.step_y + 16 - py) - a
					while(da >= 180) da -= 360
					while(da < -180) da += 360
					a += clamp(da, -turn, turn)
				px += cos(a) * v * dt
				py += sin(a) * v * dt
				if(T && ((T.x - 1) * 32 + T.step_x + 16 - px) ** 2 + ((T.y - 1) * 32 + T.step_y + 16 - py) ** 2 <= K["hit_r"] ** 2)
					reached = 1
					break
				if(t >= K["t_max"]) break
			src.kick_px = px
			src.kick_py = py
			src.kick_angle = a
			if(!KickPlace(px, py)) break
			EnergyFXProjectileTick(src)
			if(reached)
				var/mob/own0 = src.Owner
				OnContact(T)
				if(!src.Killed && src.Distance > 0 && src.Owner != own0) return 1
				break
		if(!src.Killed) src.Distance = 0
		return 0

	proc/PixelLife()
		Cooldown=-1 //Keeps active projectiles from moving onto the player during their movements.
		pc_lastdir = DisplayedCardinal(dir, pc_lastdir) //dir is only final once the spawn block ran
		ReapplyHitboxForDir(pc_lastdir)
		if(!isnull(FlightAngle))
			AngleBegin()
		if(glob.PIXEL_DEBUG) world.log << "PXC: [src] PixelLife start dir=[dir] box=[vhb_w]x[vhb_h] scale=[hb_scale] icon=[icon] mask=[vhb_mask ? "y" : "n"] dist=[Distance]"
		if(beam_owner)
			return
		if(Area == "Beam" && !Stream && chain && chain.controlled)
			return
		if(EmitChild && EmitCount > 0 && !emit_angles)
			var/obj/Skills/Projectile/ec = EmitChild
			if(istype(ec) && ec.KickPath)
				emit_total = EmitCount
				emit_angles = list()
				for(var/i = 1 to EmitCount)
					emit_angles += pick(0, 45, 90, 135, 180, 225, 270, 315) + rand() * 28 - 14
		if(KickPath && !KickLife())
			if(Owner) Owner.active_projectiles -= src
			ProjectileFinish()
			return
		if(pm_substep) //pre-move sample so point-blank casts hit a mob on the spawn tile
			PixelContactSweep()
			if(instant_pin) InstantPinHits()
			if(Killed || Distance <= 0)
				if(Owner) Owner.active_projectiles -= src
				ProjectileFinish()
				return
		if(efx_shot) efx_shot.Launch(src)
		var/igd = 0
		while(src.Distance>0 || (src.clash_lock && !src.clash_lock.ended))
			if(InstantTravel && ++igd > 4 * (DistanceMax + 8))
				Distance = 0
				break
			if(src.clash_lock)
				if(src.clash_lock.ended) //struggle is over and never cleared us: self-heal
					src.clash_lock = null
				else //frozen: no sweeps, no steps. tick-rate poll so the whole
					sleep(world.tick_lag) //column resumes together - no gaps, no lag
					continue
			if(src.Area=="Beam" && chain)
				chain.UpdateStates()
			if(src.EdgeOfMapProjectile())
				Distance=0
				break
			if(src.Homing)
				if(ismob(src.Homing))
					var/mob/hm = src.Homing
					if(!hm.loc || hm.z != src.z)
						Distance=0
				else if(!src.Owner || !src.Owner.Target)
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
				if(ismob(htgt) && !SweepAllySkip(htgt) && (htgt in view(max(1, src.Radius), src)) && RehitEligible(LastHitAt, htgt, HitInterval))
					OnContact(htgt)
			if(src.ProjectileSpin)
				if(!src.transform)
					src.transform = matrix()
				src.transform = src.transform.Turn(src.ProjectileSpin)
			if(!pm_substep) //substep mode sleeps+sweeps per tick inside PmTravel instead
				sleep(src.Speed)
				if(src.clash_lock) //locked while we slept: no wake sweep, no wake step
					continue
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
				if(from_skill) SpellFlightStep()
				if(src.Homing && HomingBroken(src.Homing)) src.Homing = 0
				if(src.FollowFacing && src.Owner)
					src.dir = src.Owner.dir
				else if(src.Homing)
					if(isnull(src.FlightAngle))
						src.dir=get_dir(src, src.Homing)
					else
						src.FlightAngle = src.AngleToward(src.Homing)
						src.dir = GunAngleDir(src.FlightAngle)
				else
					if(src.RandomPath==2)
						var/ODir=src.dir
						while(src.dir==ODir)
							src.dir=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH)
				if(!src.Static&&!src.StormFall)
					if(!isnull(src.FlightAngle))
						AngleTravel()
					else if(pm_substep)
						PmTravel()
					else
						PixelStep()
						EnergyFXProjectileTick(src)
				else
					src.Distance--
					if(src.ContactFuse && src.Distance <= 0 && (!src.fuse_at || world.time < src.fuse_at))
						if(!src.fuse_at)
							src.fuse_at = world.time + src.ContactFuse
							EnergyFXProjectileFuse(src, null)
						src.Distance = 1
					if(src.ContactFuse && src.fuse_at && world.time >= src.fuse_at + src.HitInterval)
						src.Distance = 0
					if(src.StormFall && !src.storm_dropped)
						animate(src, pixel_z=-1, flags=ANIMATION_RELATIVE)
			else
				if(!src.clash_lock) //a clash formed mid-iteration: no extra step into the enemy beam
					PixelStep() //32px per Speed sleep = old walk() rate
			if(src.EmitChild && src.EmitCount > 0 && src.Owner && !src.Killed && isturf(src.loc))
				src.emit_last = list(src.loc, src.step_x, src.step_y, src.Owner, (src.x - 1) * 32 + src.step_x + 16 + src.vhb_ax, (src.y - 1) * 32 + src.step_y + 16 + src.vhb_ay)
				for(var/e = 0, e < src.EmitEvery && src.EmitCount > 0, e++)
					var/bi = src.emit_total - src.EmitCount
					if(e && src.EmitStagger)
						spawn(src.EmitStagger * e)
							src.EmitBit(bi)
					else
						src.EmitBit(bi)
					src.EmitCount--
		if(Owner) Owner.active_projectiles -= src
		ProjectileFinish()
		return
