/var/game_loop/homingLoop = new(0, "homingLoop")



/obj/Skills/Projectile/_Projectile/proc/SetUp()
	. = TRUE
	if(Area == "Beam")
		BeamGraphics()
	if(EdgeOfMapProjectile())
		Distance = 0
		return FALSE
	

/obj/Skills/Projectile/_Projectile/proc/Homing()
	if(Homing)
		if(!Owner.Target)
			Distance = 0
		if(LosesHoming)
			if(RandomPath)
				var/list/Dirs=list(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH)
				Dirs.Remove(turn(src.dir, 135))
				Dirs.Remove(turn(src.dir, 180))
				Dirs.Remove(turn(src.dir, 225))
				src.dir=pick(Dirs)
			Homing=0
			LosesHoming = 0
	if(HomingCharge&&!HomingChargeSpent)
		HomingCharge -= 1
		HomingChargeSpent = 1
		if(HomingCharge <= 0)

			ProjectileFinish()
			return
		if(Owner)
			if(Owner.Target && Owner.Target != Owner)
				Homing = Owner.Target
			Distance = DistanceMax
			HomingChargeSpent = 0
	if(HyperHoming && Homing || HomingCharge)
		if(Owner)
			if(Owner.Target&&ismob(Owner.Target))
				if(Owner.Target in view(Radius, src))
					Bump(Owner.Target)
	else
		for(var/atom/a in view(Radius, src))
			if(StormFall&&a.pixel_z!=pixel_z)
				continue
			if(a==Owner&&!Backfire)
				continue
			if(a.Owner==Owner)
				continue
			if(a==src)
				continue
			if(istype(a, /mob) && a.density)
				Bump(a)
			else
				if(a.density)
					if(loc == a || a.loc == loc)
						Bump(a)
		for(var/obj/Skills/Projectile/_Projectile/p in view(Radius, src))
			if(p.Owner == Owner)
				continue
			if(p == src)
				continue
			Bump(p)
			
/obj/Skills/Projectile/_Projectile/proc/MoveProj()
	if(Area != "Beam")
		if(Homing)
			dir = get_dir(src, Homing)
		else
			if(RandomPath == 2)
				var/Odir = dir
				while(Odir == dir)
					dir = pick(list(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH))
		if(!Static&&!StormFall)
			src.step_size = (Speed*16) * world.tick_lag
			step(src,dir)
		else
			Distance--
			if(StormFall)
				animate(src, pizel_z =-1, flags=ANIMATION_RELATIVE)
	else
		walk(src, dir, Speed)
		

/obj/Skills/Projectile/_Projectile/proc/homingLoop()
	Cooldown = -1 // ???
	if(Distance > 0)
		if(SetUp())
			Homing()
			if(FadeOut && FadeOut >= Distance)
				animate(src, alpha=0, time=max(1,FadeOut*Speed), flags=ANIMATION_PARALLEL)
			if(0 >= Distance)
				return
			MoveProj()
	else
		ProjectileFinish()