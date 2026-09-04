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
			if(enemy.BusterTech.CounterNova)
				var/obj/Skills/Projectile/CB = enemy.BusterTech
				var/turf/nt = get_step(enemy, 0)
				for(var/d in list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
					var/obj/Skills/Projectile/nb = new CB.type
					nb.TempDamage = CB.DamageMult
					nb.SpawnPosition = nt
					new /obj/Skills/Projectile/_Projectile(enemy, nb, nt, 0.5, 0, 0, d)
				CB.Cooldown(1, null, enemy)
				CB.Charging = 0
				enemy.BusterTech = null
				enemy.BusterCharging = 0
				enemy.Chargez("Remove")
				if(enemy.held_skill == CB)
					enemy.ForceClearHeldChargeState()
			else
				var/obj/Skills/Projectile/CB2 = enemy.BusterTech
				enemy.UseProjectile(CB2, noGCD = TRUE)
				if(enemy.held_skill == CB2)
					enemy.ForceClearHeldChargeState()
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
				if(enemy.passive_handler["Determination(Purple)"])
					enemy.HealMana(enemy.SagaLevel / 60, 1)
					if(enemy.ManaAmount>=100 && enemy.RebirthHeroType=="Cyan"&&!enemy.passive_handler["Determination(White)"])
						enemy.passive_handler.Set("Determination(Green)", 1)
						enemy.passive_handler.Set("Determination(Purple)", 0)
						enemy<<"Your SOUL color shifts to green!"
				if(enemy.passive_handler["Determination"])
					enemy.HealMana(enemy.SagaLevel / 60, 1)
				else
					enemy.HealMana(enemy.SagaLevel / 15, 1)
			if(. && enemy.CanAttack())
				#if DEBUG_DAMAGE
				log2text("Counter damage", "[CounterDamage(.)]", "damageDebugs.txt", "[ckey]/[name] :: enemy: [enemy.ckey]/[enemy.name]")
				#endif
				var/counter_mult = CounterDamage(.)
				enemy.Melee1(counter_mult, 2, 0,0, null, null, 0,0,2,1,0,1)



