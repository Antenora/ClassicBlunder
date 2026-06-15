/obj/Skills/Buffs/SlotlessBuffs/Racial/Demon/Gluttonous_Feast
	BuffName = "Gluttonous Feast"
	Cooldown = 60
	TimerLimit = 0
	ActiveMessage = "draws in the surrounding attacks in a gluttonous feast!"

	var/list/feast_projectiles

	verb/Gluttonous_Feast()
		set category = "Skills"
		if(!usr || usr.Dead) return
		if(!usr.demonDevilTriggerSinMastery())
			usr << "You cannot access this power yet."
			return
		Trigger(usr)

	Trigger(mob/User, Override = FALSE)
		if(!User || User.Dead) return
		if(!User.demonDevilTriggerSinMastery()) return
		if(feast_projectiles)
			feast_projectiles.Cut()
		else
			feast_projectiles = list()

		for(var/obj/Skills/Projectile/_Projectile/p in view(User))
			if(p in feast_projectiles) continue
			neutralize_projectile(p, User)
			feast_projectiles += p

		if(!feast_projectiles.len)
			return

		pull_in_and_consume(User)

	proc/neutralize_projectile(obj/Skills/Projectile/_Projectile/p, mob/User)
		// Flag as killed so ProjectileFinish skips explosions/clusters/trails
		p.Killed = 1
		// Set distance to -1 so the Life/homingLoop exits
		p.Distance = -1
		walk(p, 0)
		p.Homing = null
		p.HomingCharge = 0
		p.HomingChargeSpent = 0
		p.HyperHoming = 0
		p.LosesHoming = 0
		p.Static = 1
		p.StormFall = 0
		p.RandomPath = 0
		p.density = 0
		p.Damage = 0
		p.Backfire = 0
		p.MultiHit = 0
		p.Explode = 0
		p.Cluster = 0
		p.SurroundBurst = 0
		p.Piercing = 0
		p.Striking = 0
		p.Slashing = 0
		// Detach from owner's active_projectiles so it won't be referenced
		if(p.Owner)
			p.Owner.active_projectiles -= p
			p.Owner = null
		p.color = rgb(0,0,0)

	proc/pull_in_and_consume(mob/User)
		if(!User || !feast_projectiles || !feast_projectiles.len) return

		var/mob/center = User
		var/steps = 10
		var/sleep_time = 2

		spawn()
			for(var/i = 1 to steps)
				if(!center) break
				for(var/obj/Skills/Projectile/_Projectile/p in feast_projectiles)
					if(!p) continue
					if(p.loc && p.z == center.z)
						step_towards(p, center)
				sleep(sleep_time)

			var/consumed = 0
			for(var/obj/Skills/Projectile/_Projectile/p in feast_projectiles)
				if(!p) continue
				p.loc = center.loc
				var/alpha_steps = 5
				var/alpha_step = round(255 / alpha_steps)
				for(var/a = 1 to alpha_steps)
					if(!p) break
					p.alpha = max(0, p.alpha - alpha_step)
					sleep(1)
				if(p)
					del(p)
					consumed++

			if(consumed && istype(center, /mob/Players))
				var/mob/Players/P = center
				if(P.demonDevilTriggerSinMastery() && P.passive_handler && P.passive_handler.Get("GluttonyFactor"))
					if(!P.DevilTriggerSinDamageBonus)
						P.DevilTriggerSinDamageBonus = 0
					P.DevilTriggerSinDamageBonus += (0.25 * consumed) * P.passive_handler.Get("GluttonyFactor")

/obj/Skills/AutoHit/I_Want_To_Be_Like_You
	Area = "Target"
	Distance = 10
	Cooldown = 1
	verb/I_Want_To_Be_Like_You()
		set category = "Skills"
		set name = "I Want to Be Like You"
		if(!usr || usr.Dead) return
		if(!usr.demonDevilTriggerSinMastery())
			usr << "You cannot access this power yet."
			return
		usr.Activate(src)

/obj/Skills/Buffs/SlotlessBuffs/Racial/Demon/Object_of_Desire
	BuffName = "Object of Desire"
	Cooldown = 60
	TimerLimit = 0

	verb/Object_of_Desire()
		set category = "Skills"
		set name = "Object of Desire"
		if(!usr || usr.Dead) return
		if(!usr.demonDevilTriggerSinMastery())
			usr << "You cannot access this power yet."
			return
		if(cooldown_remaining > 0)
			usr << "Object of Desire is still on cooldown!"
			return
		if(!usr.Target)
			usr << "You need a target to use Object of Desire."
			return
		if(usr.Target == usr)
			usr << "You cannot charm yourself."
			return
		Trigger(usr)

	Trigger(mob/User, Override = FALSE)
		if(!User || !User.Target) return
		if(!User.demonDevilTriggerSinMastery()) return
		var/mob/target = User.Target
		if(!target.applyCharmed(User, 5))
			User << "[target] is already Charmed."
			return
		OMsg(target, "[User] ensnares [target] with an irresistible desire!")
		Cooldown(1, 0, User)
