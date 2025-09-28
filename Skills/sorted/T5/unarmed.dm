/obj/Skills/var/HarderTheyFall = 0
/obj/Skills/Grapple/The_Show_Stopper
	SkillCost=TIER_5_COST
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