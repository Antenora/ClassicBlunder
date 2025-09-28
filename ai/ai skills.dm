


mob/Player/AI/proc/PlayAction(var/id)
	set waitfor=0
	if(!play_action_generated) GeneratePlayActionDatabase()
	var/ai_play_action/a = play_action_database[id]
	if(a)
		if(play_action) play_action.End(src)
		a.SetupPlayAction(src)
		play_action_timeout=world.time + a.default_timeout
		play_action = a

mob/Player/AI/var/tmp/play_action_timeout

var/list/play_action_database = list()

var/play_action_generated
proc/GeneratePlayActionDatabase()
	if(play_action_generated) return
	var/list/derieved = typesof(/ai_play_action)
	for(var/index = 1 to derieved.len)
		var/ai_play_action/a = derieved[index]
		a = new a
		if(!a.id)
			continue
		play_action_database[a.id] = a //Add a copy to the global list
	play_action_generated=1

ai_play_action
	var/default_timeout = 50
	var/id
	proc/PreUpdate(mob/Player/AI/a)
		if(!a) return 0
		if(a.play_action!=src)End(a)
		if(!a.play_action_timeout) a.play_action_timeout = world.time + default_timeout
		if(world.time >= a.play_action_timeout)
			End(a)
		return 1
	proc/SetupPlayAction(mob/Player/AI/a)
	proc/End(mob/Player/AI/a)
		a.target_position = null
		a.play_action = null
		a.play_action_timeout=0

	NymphReverseDashSupport
		id="NymphReverseDashSupport"
		SetupPlayAction(mob/Player/AI/Nympharum/a)
			a.target_position = a.ai_owner.loc
			a.NymphCry(a.message_reverse_dash,yell=1)
		Update(mob/Player/AI/Nympharum/a)
			if(PreUpdate(a))
				if(world.time >= a.next_move && a.Move_Requirements())
					var/image/i = image(a.ai_owner.is_arcane_beast.dash_effect, loc=a.loc)
					viewers(a) << i
					animate(i, alpha=0, time=30)
					spawn(30) del i
					a.density=0
					step_to(a, a.target_position)
					a.next_move = world.time + 1
				if(a.loc == a.target_position)
					if(a.bond_savior)
						var/obj/Skills/Projectile/Arcane_Burst/p = locate(/obj/Skills/Projectile/Arcane_Burst) in a
						if(p)
							a.UseProjectile(p)
						End(a)
					else
						var/obj/Skills/Projectile/Arcane_Landmine/p = locate(/obj/Skills/Projectile/Arcane_Landmine) in a
						if(p)
							a.UseProjectile(p)
						End(a)
					return
	NymphDragonDashSupport
		id="NymphDragonDashSupport"
		default_timeout=10
		SetupPlayAction(mob/Player/AI/Nympharum/a)
			a.NymphCry(a.message_dragon_dash,yell=1)
			a.SetTarget(a.ai_owner.Target)
			spawn
				var/obj/o = locate(/obj/Skills/Projectile/Arcane_Spray) in a
				if(o)
					for(var/x = 1 to (3+(2*a.ai_owner.is_arcane_beast.Mastery)))
						a.UseProjectile(o)
						sleep(1)
		Update(mob/Player/AI/Nympharum/a)
			if(PreUpdate(a))
				step_to(a,a.ai_owner)
