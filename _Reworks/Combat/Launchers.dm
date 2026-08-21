/var/game_loop/launchLoop = new(1 , "launchLoop")
/mob/var/tmp/LaunchImmune = FALSE
/mob/var/tmp/launch_total = 0	//starting Launched value - height ratio anchors to it
/proc/getLaunchLockOut(mob/player)
	var/mod = 1 + (player.passive_handler.Get("Juggernaut") * 0.25)
	return glob.LAUNCH_LOCKOUT * mod

/proc/applyLaunch(mob/target, time)
	if(istype(target, /mob/Player/AI ) && !istype(target, /mob/Player/AI/TestDummy))
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
			target.launch_total = max(target.launch_total, target.Launched)	//re-launch pops them back to peak
			target.AngerCCEvent()
			return
	else
		target.Frozen=1
		target.startOfLaunch = world.time
		target.Launched = 10 * time
		target.launch_total = target.Launched
		//pop up fast, sink slow. the world shadow stays pinned + shrinks off pixel_z on its own
		animate(target, pixel_z = glob.LAUNCH_LIFT_PX, time = 2, easing = SINE_EASING|EASE_OUT)
	target.AngerCCEvent()
	target.Grounded = 0
	target.ForceCancelBeam()
	target.ForceCancelBuster()
	launchLoop+=target


proc/LaunchEffect(mob/player, mob/target, time, delay)
	if(!player || !target) return
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
		if(!player) return
		player.NextAttack=0
		flick("Attack",player)
		if(target)
			KenShockwave(target, Size = 1)
	// _AutoHitX.dm sets player.Frozen=3 before calling this proc. Always reset
	// it — the previous code only cleared inside if(delay), so any caller that
	// passed delay=0 (HitSparkCount or HitSparkDelay being 0) left the user
	// stuck at Frozen=3 with no recovery. Surfaced via Dragon Rush which has
	// HitSparkDelay unset (0) by default.
	player.Frozen = 0
	if(!target) return

	applyLaunch(target, time)

proc/LaunchEnd(mob/player, slam = 0)
	player.Frozen = 0
	player.Launched = 0 // assuming the launch has ended completely
	if(!player.Stunned)
		player.cc_combo_hits = 0
	player.Grounded = world.time + getLaunchLockOut(player)
	//touchdown dust - harder if they were cut down from height (breaks)
	var/drop = player.pixel_z / max(glob.LAUNCH_LIFT_PX, 1)
	player.launch_total = 0
	if(!slam)	//dunks run their own drop + dust via DunkSlam
		animate(player, pixel_z=0,time=3, easing=SINE_EASING, flags=ANIMATION_END_NOW)
		spawn(3)
			if(player && !player.Launched)
				Landfall(player, clamp(drop, 0.25, 1))
	if(!player.KO && !player.Knockback)
		player.icon_state =""
	if(player.KO && !player.Knockback)
		player.icon_state = "KO"
	launchLoop-=player

//dunk: rise level with the launched target, hang while the hit lands, then slam both down hard
proc/DunkSlam(mob/dunker, mob/target)
	set waitfor = 0
	if(!dunker || !target) return
	var/peak = max(target.pixel_z, 12)
	animate(dunker, pixel_z = peak, time = 2, easing = BACK_EASING|EASE_OUT, flags = ANIMATION_END_NOW)
	sleep(4)	//the strike lands up there
	if(!dunker || !target) return
	LaunchEnd(target, slam = 1)	//clear the float loop first so nothing fights the drop
	animate(target, pixel_z = 0, time = 1, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_END_NOW)
	animate(dunker, pixel_z = 0, time = 1, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_END_NOW)
	sleep(1)
	if(target)
		Landfall(target, 1)
		target.Earthquake(10, -4,4,-4,4, 0, 0)
	if(dunker)
		Landfall(dunker, 0.6)
		dunker.Earthquake(8, -4,4,-4,4, 0, 0)

/mob/Players/proc/launchLoop()
	if(PureRPMode) return
	if(Launched>0)
		icon_state = "KB"
		//height tracks time left: half the status gone = halfway back down
		var/ratio = launch_total > 0 ? clamp(Launched / launch_total, 0, 1) : 0
		animate(src, pixel_z = round(glob.LAUNCH_LIFT_PX * ratio), easing = LINEAR_EASING, time = 1)
		if(Launched > 10)
			Launched--
		else
			Launched-=2
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