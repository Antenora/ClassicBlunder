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
	if(target.passive_handler.Get("Trample") && target.is_dashing)
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
		target.Launched = 10 * time * target.getControlResistValue()// 1 second per time
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
		player.NextAttack=0
		flick("Attack",player)
		KenShockwave(target, Size = 1)
	// _AutoHitX.dm sets player.Frozen=3 before calling this proc. Always reset
	// it — the previous code only cleared inside if(delay), so any caller that
	// passed delay=0 (HitSparkCount or HitSparkDelay being 0) left the user
	// stuck at Frozen=3 with no recovery. Surfaced via Dragon Rush which has
	// HitSparkDelay unset (0) by default.
	player.Frozen = 0

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
	if(!src.Alert("Are you sure you want to change launch lockout time?")) return
	var/num = input("Enter new Launch Lockout time (in seconds):") as num
	if(num>0)
		glob.LAUNCH_LOCKOUT = num * 10
		world << "Launch Lockout time set to [num/10] seconds."

/mob/Admin3/verb/alterMaxLaunchTime()
	set category = "Admin"
	set name = "Change Max Launch Time"
	if(!src.Alert("Are you sure you want to alter max launch time?")) return
	var/num = input("Enter new Max Launch time (in seconds):") as num
	if(num>0)
		glob.MAX_LAUNCH_TIME = num * 10
		world << "Max Launch time set to [num/10] seconds."