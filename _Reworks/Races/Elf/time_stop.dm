/obj/Skills/Buffs/SlotlessBuffs/Elf/Time_Stop
	var/tmp/TimeStopped = 0
	var/tmp/mob/owner = null
	var/TriggerMessage = "Fall."
	Mastery = 1
	passives = list("CoolerAfterImages" = 4, "Godspeed" = 4, "Adrenaline" = 4,"LimitBroken" = 1) // make sure u go fast
	Cooldown=-1
	proc/applyTimeEffect(mob/p)
		var/asc = p.AscensionsAcquired
		if(asc < 1)
			asc = 1
		for(var/mob/M in view(4 + (4 * p.AscensionsAcquired), p))
			if(M.client)
				spawn()animate(M.client, color = list(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1), time = 7)
				if(M == p)
					continue
				M.Frozen=1
				M.TimeFrozen=1
		sleep(10)
		for(var/mob/M in view(4 + (4 * p.AscensionsAcquired), p))
			if(M.client)
				spawn()animate(M.client, color = null, time = 3)
				spawn()animate(M.client, color = list(0.6,0,0.1, 0,0.6,0.1, 0,0,0.7, 0,0,0), time = 3)
	proc/EndTimeStop(mob/p)
		if(p.TimeStop)
			p.TimeStop=0
			TimeStopped=0
			for(var/mob/B in world)
				if(B.TimeFrozen)
					B.TimeFrozen=0
					B.Frozen=0
				if(B.client)
					spawn()animate(B.client, color = null, time = 3)
			Trigger(p, 1)
			Cooldown()

	proc/StartTimeStop(mob/p)
		p.client.sayProc("...")
		applyTimeEffect(p)
		p.client.sayProc("[TriggerMessage]", YELL)
		p.TimeStop=1
		TimeStopped=0
		ticking_generic+=src

	adjust(mob/p)
		if(!altered)
			Mastery = clamp(p.AscensionsAcquired,1,5)
			TimerLimit = Mastery*(glob.TIMESTOP_MULTIPLIER/10)


	verb/Power_Word_Stop()
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		var/t = Trigger(usr)
		// if this passes
		if(t && !src.Using)
			StartTimeStop(usr)
	verb/Change_Stop_Trigger()
		set category = "Utility"
		TriggerMessage = input(usr, "the message") as text
		if(length(TriggerMessage) >= 150)
			TriggerMessage = "Fall."

	Trigger(var/mob/User, Override=0)
		owner = User
		if(!Override && User.passive_handler.Get("Silenced"))
			User << "You can't use [src] you are silenced!"
			return 0
		if(!Override && User.BuffingUp)
			return 0
		if(!Override)
			User.BuffingUp++
		if((User.Health - 0.5 + (0.5 * User.AscensionsAcquired)) <= 0)
			User << "Not enough health."
			return 0
		User.UseBuff(src, Override)
		User.Health -= 0.5 + (0.5 * User.AscensionsAcquired)
		User.BuffingUp=0
		if(!src.BuffName)
			src.BuffName="[src.name]"
		return 1

	Update()
		TimeStopped++
		if(TimeStopped>=Mastery*glob.TIMESTOP_MULTIPLIER) // 100 = 1 second roughly
			// per tick this will gain 1, 100 ticks should = 1 second
			EndTimeStop(owner)
			TimeStopped=0
			ticking_generic-=src