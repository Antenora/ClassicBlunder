/var/game_loop/launchLoop = new(1 , "launchLoop")
/mob/var/tmp/LaunchImmune = FALSE
/proc/getLaunchLockOut(mob/player)
	var/mod = 1 + (player.passive_handler.Get("Juggernaut") * 0.25) + (player.HasMythical() * 0.25)
	return glob.LAUNCH_LOCKOUT * mod

/proc/applyLaunch(mob/target, time)
	if(istype(target, /mob/Player/AI ))
		return // TODO: MAKE AI LAUNCHABLE
	if(target.LaunchImmune)
		return
	if(world.time < target.Grounded)
		return
	if(target.Launched>0)
		if(target.startOfLaunch + glob.MAX_LAUNCH_TIME > world.time)
			return
		else
			target.Launched += clamp(time * 2.5 , 1, 10)
			return
	else
		target.Frozen=1
		target.startOfLaunch = world.time
		target.Launched = 10 * time // 1 second per time
	target.Grounded = 0
	target.ForceCancelBeam()
	target.ForceCancelBuster()
	launchLoop+=target


proc/LaunchEffect(mob/player, mob/target, time, delay)
	if(istype(target, /mob/Body))
		if(player.Frozen)
			player.Frozen = 0
			return
		return
	if(target.ContinuousAttacking)
		for(var/obj/Skills/Projectile/p in target.contents)
			if(p.ContinuousOn && !p.StormFall)
				target.UseProjectile(p)
			continue
	if(delay)
		sleep(delay)
		player.Frozen = 0
		player.NextAttack=0
		flick("Attack",player)
		KenShockwave(target, Size = 1)

	applyLaunch(target, time)

proc/LaunchEnd(mob/player)
	player.Frozen = 0
	player.Launched = 0 // assuming the launch has ended completely
	player.Grounded = world.time + getLaunchLockOut(player)
	animate(player, pixel_z=0,time=3, easing=SINE_EASING, flags=ANIMATION_END_NOW)
	if(!player.KO && !player.Knockback)
		player.icon_state =""
	if(player.KO && !player.Knockback)
		player.icon_state = "KO"
	launchLoop-=player

/mob/Players/proc/launchLoop()
	if(PureRPMode) return
	if(Launched>0)
		if(Launched > 10)
			animate(src, pixel_z=min(pixel_z+2,16), icon_state="KB", easing=SINE_EASING, time=1)
			Launched--
		else
			Launched-=2
		animate(src, pixel_z=max(pixel_z-2,0), icon_state="KB", easing=SINE_EASING, time=1)
	if(Launched <= 0)
		LaunchEnd(src)


//ADMIN VERBS
/mob/Admin3/verb/alterLaunchLockout()
	set category = "Admin"
	set name = "Change Launch Lockout"
	var/num = input("Enter new Launch Lockout time (in seconds):") as num
	if(num>0)
		glob.LAUNCH_LOCKOUT = num * 10
		world << "Launch Lockout time set to [num/10] seconds."

/mob/Admin3/verb/alterMaxLaunchTime()
	set category = "Admin"
	set name = "Change Max Launch Time"
	var/num = input("Enter new Max Launch time (in seconds):") as num
	if(num>0)
		glob.MAX_LAUNCH_TIME = num * 10
		world << "Max Launch time set to [num/10] seconds."