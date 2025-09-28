/mob/proc/counterWarp(obj/Items/Sword/s, obj/Items/Sword/s2, obj/Items/Sword/s3)
	var/reqCounter = 0
	return reqCounter

/mob/proc/counterShit(mob/enemy, ignore)
	. = 0
	var/obj/Skills/Queue/q = enemy.AttackQueue
	var/counter = 0
	if(q)
		counter = q.Counter || q.CounterTemp ? 1 : 0
	var/buster = enemy.BusterTech && enemy.BusterTech.CounterShot ? 1 : 0
	var/ccd = enemy.Stunned || enemy.Launched ? 1 : 0
	if( ((q && counter) || buster) && !ccd &&!ignore)
		enemy.dir = get_dir(enemy, src)
		if(buster)
			enemy.UseProjectile(enemy.BusterTech)
		else
			if(!AttackQueue || (!AttackQueue && (AttackQueue.Counter|| AttackQueue.CounterTemp )))
				#if DEBUG_DAMAGE
				log2text("Counter Starting (counter/temp/dmgmult)", "[q.Counter] / [q.CounterTemp] / [q.DamageMult]", "damageDebugs.txt", "[ckey]/[name] :: enemy: [enemy.ckey]/[enemy.name]")
				#endif
				. = q.Counter + q.CounterTemp
				#if DEBUG_DAMAGE
				log2text("Counter End", ., "damageDebugs.txt", "[ckey]/[name] :: enemy: [enemy.ckey]/[enemy.name]")
				#endif
			if(enemy.UsingAnsatsuken())
				enemy.HealMana(enemy.SagaLevel / 15, 1)
			if(enemy.SagaLevel>1&&enemy.Saga=="Path of a Hero: Rebirth")
				if(enemy.passive_handler["Determination"])
					enemy.HealMana(enemy.SagaLevel / 60, 1)
				else
					enemy.HealMana(enemy.SagaLevel / 15, 1)
			if(. && enemy.CanAttack())
				#if DEBUG_DAMAGE
				log2text("Counter damage", "[CounterDamage(.)]", "damageDebugs.txt", "[ckey]/[name] :: enemy: [enemy.ckey]/[enemy.name]")
				#endif
				enemy.Melee1(CounterDamage(.), 2, 0,0, null, null, 0,0,2,1,0,1)



