
/mob/var/tmp/last_stunned = 0

proc
	Stun(mob/m,amount=5, ignoreImmune = FALSE)
		if(!m)
			return
		if(!m.client)
			return
		if(m.InUBW&&m.MadeOfSwords)
			return
		if(m.StunImmune && !ignoreImmune)
			return
		if(m.CheckSlotless("Great Ape"))
			amount *= 0.75
		if(m.HasMythical() > 0.25 || m.passive_handler.Get("Juggernaut"))
			var/mod = (m.HasMythical() * 0.5) + m.passive_handler.Get("Juggernaut") * 0.25
			amount /= 1 + mod

		if(m.HasDebuffResistance())
			amount/=(m.GetDebuffResistance()*0.75)
		if(m.ContinuousAttacking)
			for(var/obj/Skills/Projectile/p in m.contents)
				if(p.ContinuousOn && !p.StormFall)
					m.UseProjectile(p)
				continue
		var/Stun_Amount=world.time+(amount*10)
		if(m.Stunned)
			m.Stunned+=(amount*4)
			if(m.Stunned > m.last_stunned + glob.MAX_STUN_ADDITION)
				m.Stunned = m.last_stunned + glob.MAX_STUN_ADDITION
		else
			var/obj/Effects/Stun/S=new
			S.appearance_flags=66
			m.Stunned=Stun_Amount
			m.last_stunned = world.time
			if(m.Stunned > m.last_stunned + glob.MAX_STUN_TIME)
				m.Stunned = m.last_stunned + glob.MAX_STUN_TIME
			m.overlays+=S
			m.ForceCancelBeam()
			m.ForceCancelBuster()
	StunCheck(mob/mob)

		if(mob.Stunned)
			if(mob.Stunned<=world.time || mob.last_stunned + glob.MAX_STUN_TIME < world.time)
				var/obj/Effects/Stun/S=new
				S.appearance_flags=66
				mob.overlays-=S
				mob.Stunned=0
				mob.overlays-='IceCoffin.dmi'
				var/mod = (mob.HasMythical() * 0.5) + mob.passive_handler.Get("Juggernaut") * 0.25
				mob.StunImmune=world.time+(glob.STUN_IMMUNE_TIMER*(1+mod))
				mob << "You can't be stunned for another [glob.STUN_IMMUNE_TIMER*(1+mod)/10]"
				if(mob.passive_handler["Shellshocked"])
					mob.passive_handler.Set("Shellshocked", 0)
					mob << "You are no longer Shellshocked..."
			else
				return 1
	StunClear(mob/mob)
		if(mob.Stunned)
			if(mob.CheckSlotless("Mind Dominated") || mob.passive_handler["Shellshocked"]) // this should b some passive that causes this
			// however, fuck you
				mob << "You feel unable to clear your head."
			else
				var/obj/Effects/Stun/S=new
				S.appearance_flags=66
				mob.overlays-=S
				mob.Stunned=0
				mob.overlays-='IceCoffin.dmi'
				var/mod = (mob.HasMythical() * 0.5) + mob.passive_handler.Get("Juggernaut") * 0.25
				mob.StunImmune=world.time+(glob.STUN_IMMUNE_TIMER*(1+mod))
				mob << "You can't be stunned for another [glob.STUN_IMMUNE_TIMER*(1+mod)/10]"
	StunImmuneCheck(mob/mob)
		if(mob.StunImmune)
			if(mob.StunImmune<world.time)
				mob.StunImmune=0
			else
				return 1
