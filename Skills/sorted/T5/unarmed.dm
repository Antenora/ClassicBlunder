/obj/Skills/var/HarderTheyFall = 0
/obj/Skills/Grapple/The_Show_Stopper
	SkillCost=TIER_5_COST
	Copyable=6
	Stunner=5
	DamageMult=12
	HarderTheyFall=5
	Crippling = 50
	StrRate=2
	ForRate=0
	Effect="ShowStopper"
	Cooldown=150
	OneAndDone=1
	verb/The_Show_Stopper()
		set category="Skills"
		src.Activate(usr)



/obj/Skills/AutoHit/Meteor_Strike
	UnarmedOnly = 1
	SkillCost = TIER_5_COST
	Copyable = 6
	Area = "Around Target"
	StrOffense = 2
	DamageMult = 20
	Distance = 12
	DistanceAround = 7
	Cooldown = 75
	verb/Meteor_Strike()
		set category = "Skills"
		MeteorStrike(usr, src)

proc/MeteorStrike(mob/attacker, obj/Skills/AutoHit/Meteor_Strike/Z)
	set waitfor = 0
	if(!attacker || !attacker.client) return
	if(attacker.HeldSkillBlocksAction(Z)) return
	if(Z.Using) return
	if(!attacker.CanAttack(1.5)) return
	if(Z.UnarmedOnly)
		var/obj/Items/Sword/s = attacker.EquippedSword()
		if(s && !attacker.HasBladeFisting())
			attacker << "You can't have a sword equipped and use Meteor Strike!"
			return
	if(!attacker.Target || attacker.Target == attacker)
		attacker << "You need a target to use Meteor Strike!"
		return
	if(attacker.Target.z != attacker.z)
		attacker << "Your target is on a different z-level!"
		return
	if(get_dist(attacker, attacker.Target) > Z.Distance)
		attacker << "Your target is not in range!"
		return
	Z.adjust(attacker)
	Z.SpellSlotModification()
	Z.Cooldown(1, null, attacker)

	var/savedColor = attacker.color
	var/savedPixelZ = attacker.pixel_z

	OMsg(attacker, "<b>[attacker] launches themselves sky high!</b>")

	// Rise animation
	animate(attacker, pixel_z = savedPixelZ + 300, time = 2, easing = QUAD_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(attacker, color = "#FF6600", alpha = 200, time = 2)
	sleep(2)
	animate(attacker, alpha = 0, time = 1)
	sleep(1)

	// Set actual values after fade
	attacker.alpha = 0
	attacker.pixel_z = savedPixelZ + 300
	attacker.color = "#FF6600"
	animate(attacker)

	// Force all mobs currently targeting the attacker to drop their target
	var/list/targetters = attacker.BeingTargetted.Copy()
	for(var/mob/m in targetters)
		m.RemoveTarget()

	// Airborne state  (untargetable, blocks all outgoing actions, blocks incoming damage, density=0)
	attacker.Airborne = 1
	attacker.AirborneInterrupted = 1
	attacker.density = 0

	sleep(50)

	if(!attacker) return
	attacker.Airborne = 0
	attacker.AirborneInterrupted = 0
	attacker.density = 1

	// Crash at target if still valid, otherwise land at current position
	var/mob/crashTarget = attacker.Target
	var/turf/crashLoc
	if(crashTarget && crashTarget != attacker && crashTarget.z == attacker.z)
		crashLoc = get_turf(crashTarget)
	else
		crashLoc = get_turf(attacker)

	// Teleport to crash site while still invisible
	attacker.loc = crashLoc

	// descent
	attacker.pixel_z = savedPixelZ + 300
	attacker.color = "#FF6600"
	attacker.alpha = 200
	animate(attacker, pixel_z = savedPixelZ, time = 2, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	animate(attacker, color = savedColor, alpha = 255, time = 2)
	sleep(2)

	// Restore visuals
	attacker.pixel_z = savedPixelZ
	attacker.color = savedColor
	attacker.alpha = 255
	animate(attacker)

	OMsg(attacker, "<b>[attacker] comes crashing down like a meteor!</b>")

	// Impact effects
	attacker.Quake(50)
	var/turf/T = get_turf(attacker)
	Bang(T, Size = 3, Offset = 6, Vanish = 4)
	KenShockwave(attacker, icon = 'fevKiai.dmi', Size = 5, Blend = 1, Time = 12)

	attacker.AroundTarget(null, Z, crashLoc)

/mob/var/tmp/last_jump_animation = 0


proc/ShowStopper(mob/attacker, mob/defender, effectMult)
	attacker.Frozen=2
	defender.Frozen=2
	var/turf/target_loc = locate(attacker.x+effectMult,attacker.y+effectMult,attacker.z)
	attacker.SS_Animation_A(target_loc)
	defender.SS_Animation_D(target_loc)
	sleep(2 * get_dist(attacker, target_loc))
	attacker.Frozen=0
	defender.icon_state = "KO"
	defender.Frozen=0
// CREDIT: Xerif

/mob/proc/SS_Animation_A(turf/target_turf)
	set waitfor = FALSE
	last_jump_animation = world.time
	var/pixel_x_location = round(1 + ((x - target_turf.x) * -32), 16)
	var/pixel_y_location = round(1 + ((y - target_turf.y) * -32), 16)
	var/jump_time = 2 * get_dist(src, target_turf)
	var/matrix/M = matrix()
	M.Translate(0, 100)
	dir = get_dir(src, target_turf)
	var/image/I = image(src, icon_state = "", layer = 9001)
	I.loc = src
	I.override = 1
	world << I
	var/image/shadow = image('small_shadow.dmi')
	shadow.loc = src
	shadow.alpha = 0
	world << shadow
	var/finalTrans = turn(matrix(), -67)
	var/halfWay = turn(matrix(), -67)
	animate(I, transform = finalTrans, pixel_z = 100, time = jump_time / 2, easing = QUAD_EASING|EASE_OUT)
	animate(transform = turn(halfWay, -67), pixel_z = 0, time = jump_time / 2, easing = QUAD_EASING|EASE_IN)
	animate(src, pixel_x = pixel_x_location, pixel_y = pixel_y_location, time = jump_time, easing = LINEAR_EASING)
	if(client)
		animate(client, pixel_x = pixel_x_location, pixel_y = pixel_y_location, time = jump_time, easing = LINEAR_EASING)
	animate(shadow, alpha = 100, time = jump_time / 2, easing = QUAD_EASING|EASE_OUT)
	animate(alpha = 0, time = jump_time / 2, easing = QUAD_EASING|EASE_IN)
	var/old = animate_movement
	animate_movement = 0
	sleep(jump_time)
	del(I)
	del(shadow)
	transform = null
	pixel_x = 0
	pixel_y = 0
	if(client)
		client.pixel_x = 0
		client.pixel_y = 0
	//src.loc = target_turf
	Crater(src, 0.75)
	Dust(target_turf, 4, 4)
	spawn(1)
		animate_movement = old
		layer = 4
/mob/proc/SS_Animation_D(turf/target_turf)
	set waitfor = FALSE
	last_jump_animation = world.time
	var/pixel_x_location = round(1 + ((x - target_turf.x) * -32), 16)
	var/pixel_y_location = round(1 + ((y - target_turf.y) * -32), 16)
	var/jump_time = 2 * get_dist(src, target_turf)
	dir = get_dir(src, target_turf)
	var/image/I = image(src, icon_state = "", layer = 9000)
	I.loc = src
	I.override = 1
	world << I
	var/image/shadow = image('small_shadow.dmi')
	shadow.loc = src
	shadow.alpha = 0
	world << shadow
	var/finalTrans = turn(matrix(), -45)
	var/halfWay = turn(matrix(), -45)
	animate(I, transform = finalTrans, pixel_z = 100,  time = jump_time / 2, easing = QUAD_EASING|EASE_OUT)
	animate(transform = turn(halfWay, -45), pixel_z = 0, time = jump_time / 2, easing = QUAD_EASING|EASE_IN)
	animate(src, pixel_x = pixel_x_location, pixel_y = pixel_y_location, time = jump_time, easing = LINEAR_EASING)
	if(client)
		animate(client, pixel_x = pixel_x_location, pixel_y = pixel_y_location, time = jump_time, easing = LINEAR_EASING)
	animate(shadow, alpha = 100, time = jump_time / 2, easing = QUAD_EASING|EASE_OUT)
	animate(alpha = 0, time = jump_time / 2, easing = QUAD_EASING|EASE_IN)
	var/old = animate_movement
	animate_movement = 0
	sleep(jump_time)
	del(shadow)
	animate(I, transform = null, time = 1, easing = QUAD_EASING|EASE_IN)
	del(I)

	transform = null
	pixel_x = 0
	pixel_y = 0
	if(client)
		client.pixel_x = 0
		client.pixel_y = 0

	//src.loc = target_turf

	spawn(1)
		animate_movement = old
		layer = 4