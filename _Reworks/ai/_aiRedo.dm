#define AI_MOVE_SPEED 1 + ( 0.5 * sqrt(max(1,passive_handler.Get("Godspeed"))))
#define AI_SPEED_TOTAL SpdMod + SpdAscension + SpdChaos * SpdMultTotal

/mob/Player/AI/var/tmp/last_activity = 0
/mob/Player/AI/var/tmp/reaction_time = 2
/mob/Player/AI/var/tmp/intelligence = 1
/mob/Player/AI/var/tmp/fleeing = FALSE
/mob/Player/AI/var/tmp/obj/Skills/zanzo = null
/mob/Player/AI/var/tmp/obj/Skills/dd = null
/mob/Player/AI/var/tmp/mob/targetted = null
/mob/Player/AI/var/tmp/inloop = FALSE
/mob/Player/AI/proc/findZanzo()
	for(var/obj/Skills/Zanzoken/z in src)
		return z
	AddSkill(new/obj/Skills/Zanzoken)
	zanzo = locate(/obj/Skills/Zanzoken) in src
/mob/Player/AI/proc/AiBehavior()
	var/ignoreActivity = FALSE
	if(ai_hostility>=2)
		ignoreActivity = TRUE
	if(last_activity+300 < world.time && !ignoreActivity) //if last activity was over 10 seconds ago. 30 sec now.
		ai_state = "Idle"
		ticking_ai.Remove(src)
		inloop = FALSE
		return
	inloop = TRUE
	if(!zanzo)
		zanzo = findZanzo()
	if(!dd)
		dd = locate(/obj/Skills/Dragon_Dash) in src
	//start flow chart
	switch(ai_state)
		if("Idle")
			Idle()
		if("Chase")
			Chase()
		if("Attack")
			Attack()
		if("Rest")
			Rest()
		if("Flee")
			Flee()
		if("Wander")
			Wander()
		else
			Idle()



	//end flow chart

/mob/Player/AI/proc/Idle()
	ai_state = "Idle"
	icon_state = ""
	fleeing = FALSE
	if(ai_follow && ai_owner && ai_owner.icon_state != "Meditate")
		if(icon_state == "Meditate")
			icon_state = ""
		if(!ai_owner)
			EndLife(0)
			return
		if(world.time >= next_move)
			var prev_loc = loc
			if(ai_owner.z != src.z)
				loc = locate(ai_owner.x, ai_owner.y,ai_owner.z)
			next_move = world.time + 5
			if(get_dist(src, src.ai_owner)>=10)
				src.density=0
				step_towards(src, src.ai_owner, 2)
				src.density=1
				next_move = world.time+2

			var/ai_len = ai_owner.ai_followers.Find(src)

			step_towards(src, src.ai_owner, 2 + round(ai_len/5))
			step_away(src, src.ai_owner, 1 + round(ai_len/5))
			if(loc == prev_loc) dir = src.ai_owner.dir //Make ai nicely face same dir as the owner.
	else
		if(Target)
			if(!fleeing)
				Chase()
			else if(Health <= 5)
				Flee()
		else //move aboe to something else and keep this as just idling, right now it is handling everything
			if(Health <= 5 &&!(Health >= 25))
				Rest()
			else if(ai_hostility >= 2)
				Wander()

/mob/Player/AI/proc/Wander()
	ai_state = "Wander"
	if(world.time >= next_move)
		step(src, pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,SOUTHWEST,NORTHEAST,SOUTHEAST))
		next_move = world.time + MovementSpeed()*10
		if(src.hostile>=2)
			src.FindTarget1()
		if(src.Target)
			Chase()

/mob/Player/AI/proc/FindTarget1()
	/*look for a target if there isnt one. do nothing if one is not found
	if there is a target and there is not another around, return same target
	if there is a target and there is another around, return the closest one*/
	for(var/mob/enemy in view(ai_vision, src))
		if(!enemy.client) continue
		if(enemy.invisibility > see_invisible) continue
		if(AllianceCheck(enemy)) continue
		if(istype(enemy, /mob/Player/AI)) continue
		if(Target)
			if(get_dist(src, enemy) < get_dist(src, Target))
				SetTarget(enemy)
		else
			SetTarget(enemy)

/mob/Player/AI/proc/Chase()
	if(isCrowdControlled())
		return
	ai_state = "Chase"
	if(isai(Target))
		RemoveTarget()
		Idle()
		return
	fleeing = FALSE
	if(!Target)
		Idle()
	if((Target.WindingUp||Target.AutoHitting)&&!fleeing)
		Flee()
	if(!fleeing)
		var/dist_to_target = get_dist(src, Target)
		if(Target.KO)
			FindTarget1()
			return
		if(AutoHitting)
			GoAfterTarget()
		else if(dist_to_target <= 10)
			GoAfterTarget()
			dir = get_dir(src,Target)
			//melee
			if(dist_to_target <= 1)
				Attack("melee")
			else
				Attack("ranged")
			last_activity = world.time
		else
			GoAfterTarget()
			if(dist_to_target >= ai_vision * 5)
				//do not set last activity
				if(shifts_target && targetting + 150 < world.time)
					FindTarget1()
					targetting = world.time
				if(last_activity + 300 < world.time)
					RemoveTarget()
					Idle()
			//maybe ranged proc here
			Attack("ranged")
			last_activity = world.time

/proc/skimOppdir(step)
	switch(step)
		if(NORTH)
			step = pick(NORTH, NORTHEAST, NORTHWEST)
		if(SOUTH)
			step = pick(SOUTH, SOUTHEAST, SOUTHWEST)
		if(EAST)
			step = pick(EAST, NORTHEAST, SOUTHEAST)
		if(WEST)
			step = pick(NORTHWEST, SOUTHWEST, WEST)
		if(NORTHEAST)
			step = pick(NORTH, EAST, NORTHEAST)
		if(NORTHWEST)
			step = pick(NORTH, WEST, NORTHWEST)
		if(SOUTHEAST)
			step = pick(EAST, SOUTH, SOUTHEAST)
		if(SOUTHWEST)
			step = pick(WEST, SOUTH, SOUTHWEST)
	return step


/proc/skimAround(step)
	switch(step)
		if(SOUTH)
			step = pick(NORTHEAST, NORTHWEST, WEST, EAST)
		if(NORTH)
			step = pick(SOUTHEAST, SOUTHWEST, WEST, EAST)
		if(WEST)
			step = pick(NORTHEAST, SOUTHEAST, NORTH, SOUTH)
		if(EAST)
			step = pick(NORTHWEST, SOUTHWEST, NORTH, SOUTH)
		if(SOUTHWEST)
			step = pick(SOUTH, SOUTHEAST, WEST)
		if(SOUTHEAST)
			step = pick(SOUTH, SOUTHWEST, EAST)
		if(NORTHWEST)
			step = pick(NORTH, NORTHEAST, WEST)
		if(NORTHEAST)
			step = pick(NORTH, NORTHWEST, EAST)
	return step


/mob/Player/AI/proc/GoAfterTarget()
	if(Move_Requirements() && next_move < world.time)
		switch(ai_movement_type)
			if("ranged")
				if(get_dist(src, Target) >= pick(6,7,8))
					step_to(src, Target,, 32 * (5 / (AI_SPEED_TOTAL * (AI_MOVE_SPEED))))
				else
					step_to(src, get_step(src,skimAround(get_dir(src, Target))),, 32 * (5 / (AI_SPEED_TOTAL * (AI_MOVE_SPEED))))

			if("melee")
				step_to(src, get_step(src, skimOppdir(get_dir(src, Target))),, 32 * (5 / (AI_SPEED_TOTAL * (AI_MOVE_SPEED))))

		dir = get_dir(src, Target)
		next_move = world.time + 1


/mob/Player/AI/proc/Attack(t)
	switch(t)
		if("melee")
			var/obj/Skills/use = FALSE
			if((world.time > ai_next_skill)&&!AttackQueue)
				if(prob(50) && world.time > ai_next_qeueuable && Queues.len)
					var/obj/Skills/Queue/q = pick(Queues)
					if(!q.Using)
						dir = get_dir(src, Target)
						SetQueue(q)
						use = q
						ai_next_qeueuable = (world.time+50)/ai_spammer

				if(prob(50) && world.time > ai_next_projectile && Projectiles.len&&!use)
					var/obj/Skills/Projectile/p = pick(Projectiles)
					if(!p.Using)
						dir = get_dir(src, Target)
						UseProjectile(p)
						use = p
						ai_next_projectile = (world.time+50)/ai_spammer

				if(world.time > ai_next_autohit && !use && AutoHits.len)
					var/obj/Skills/AutoHit/a = pick(AutoHits)
					if(!a.Using)
						if(a.Area in list("Arc","Circle"))
							dir = get_dir(src, Target)
							Activate(a)
							ai_next_autohit = (world.time+20)/ai_spammer
						else if(a.Area in list("Strike","Wave", "Wide Wave"))
							if(get_dist(src, Target) <= a.Rush+a.Distance+pick(-1,-1,0,0,0))
								if(prob(ai_accuracy/2))
									step(src, get_dir(src, Target))
								dir = get_dir(src, Target)
								if(prob(ai_accuracy/2))
									if(src in block(Target.x - 1, Target.y-1, Target.z, Target.x + 1, Target.y +1))
										Activate(a)
										use = a
										ai_next_autohit = (world.time+20)/ai_spammer
								else if(x == Target.x || y == Target.y)
									Activate(a)
									use = a
									ai_next_autohit = (world.time+20)/ai_spammer
						else if(a.Area in list("Target","Around Target"))
							if(get_dist(src,Target) <= a.Distance - pick(0,0,-1,-1,-2))
								Activate(a)
								use = a
								ai_next_autohit = (world.time+20)/ai_spammer

				if(use) ai_next_skill = (world.time + (use.Copyable ? use.Copyable * 5 : 50)) / ai_spammer

			for(var/mob/a in HitCheck())
				dir = get_dir(src, a)
				Melee1(GLOBAL_AI_DAMAGE)

		if("ranged")

			if((world.time > ai_next_skill)&&!AttackQueue)
				var/obj/Skills/use = FALSE

				if(world.time > ai_next_projectile && Projectiles.len&&!use)
					var/obj/Skills/Projectile/p = pick(Projectiles)
					if(!p.Using)
						dir = get_dir(src, Target)
						UseProjectile(p)
						use = p
						ai_next_projectile = (world.time+50)/ai_spammer
						ai_state = "Chase"

				if(world.time > ai_next_qeueuable && Queues.len)
					var/obj/Skills/Queue/q = pick(Queues)
					if(!q.Using)
						dir = get_dir(src, Target)
						SetQueue(q)
						use = q
						ai_next_qeueuable = (world.time+50)/ai_spammer
						ai_state = "Chase"

				if(world.time > ai_next_autohit && !use && AutoHits.len)
					var/obj/Skills/AutoHit/a = pick(AutoHits)
					if(!a.Using)
						if(a.Area in list("Target","Around Target"))
							if(get_dist(src,Target) <= a.Distance - pick(0,0,-1,-1,-2))
								Activate(a)
								use = a
								ai_next_autohit = (world.time+20)/ai_spammer
								ai_state = "Chase"

				if(use) ai_next_skill = (world.time + (use.Copyable ? use.Copyable * 5 : 50)) / ai_spammer

				if((prob(50) || AttackQueue) && world.time > ((last_zanzo + 50) / ai_spammer))
					if(get_dist(src, Target) >= 1 || AttackQueue)
						SkillX("Zanzoken", zanzo, 1)
						if(prob(25)&&!dd.Using)
							SkillX("DragonDash", dd)
					else
						SkillX("After Image Strike", zanzo)
					last_zanzo = world.time

	ai_state = "Chase"






/mob/Player/AI/proc/Rest()
	ai_state = "Rest"
	if(Health >= 75*(1-src.HealthCut))
		ai_state = "Idle"
		Idle()
	else
		icon_state = "Meditate"
		Health += (rand(0,2)/10) * RecovMod

/mob/Player/AI/proc/Flee()
	ai_state = "Flee"
	if(!Target)
		Idle()
	if(!fleeing)
		fleeing = TRUE
	var/dist_to_target = get_dist(src, Target)
	if(dist_to_target <= ai_vision)
		//move away from target
		last_activity = world.time
		if(Move_Requirements() && next_move < world.time)
			step_away(src, Target, 20, 32 * (5 / (AI_SPEED_TOTAL * (AI_MOVE_SPEED))))
			dir = get_dir(Target,src)
			next_move = world.time + 1
	if(!Target.WindingUp&&!Target.AutoHitting&&Health>5)
		fleeing = FALSE
		Chase()

/mob/Player/proc/isCrowdControlled()
	if(Launched || Stunned || icon_state == "KB")
		return TRUE
	return FALSE


/*
start
	Idle
		if target
			if not_scared
				chase
			else if health < 10
				flee
		else
			if health < 10
				rest
			else
				if super_hostile && target within range
					find_target
				else
					Idle
		if last_activity was over 10 seconds ago, remove from loop

		add back to the loop when somebody enters the range if they are super hostile ( keep super hostile in the loop)
		of if they hit it

		for super hostile don't let them move if they are inactive, just detect mobs

		player damage makes last_activity reset, every tick last_activity goes up by 1
		(there is an issue where pp lcan hit once run till inactive and rest and then hit again and it will still be active)
		(doubt somebody is this insane to do this but it is something that can happen)

	find_target
		look for a target in range
		when found set target and proc chase
		if not found proc Idle

	chase
		if target
			move to target
			if target is within 1 tile
				normal attack (melee)
			else
				ranged attack

	attack
		normal attack
		or
		proj attack

	rest
		meditate and heal
		if(health >= max)
			proc Idle
	flee
		move away from target
		trigger running away var
		if target is not in range
			proc Idle
*/