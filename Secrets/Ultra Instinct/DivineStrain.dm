/obj/Skills/Buffs/TemporaryDebuffs/Mortal_Instinct_Debuff/ClearMind
	BuffName = "Clear Mind"
	desc = "Your mind is freed and your heart is pure, preventing you from angering."
	Slotless = 1
	Copyable = 0
	TimerLimit = 1209600 // two weeks?! (yes)
	passives = list("NoAnger" = 1)
	AngerMult = 0.75 //so that CalmAnger and associated debuffs can't benefit you unless you have like. 200% anger. but if you manage to combine the mechanics in such a ridiculous way then i kinda think you've earned it.
	ActiveMessage = "is overwhelmed by divine pressure!"
	OffMessage = "is no longer overwhelmed by divine pressure."
	TextColor = "#d4aaff"
	start_time = 0
	expire_time = 0
	var/cloud_start = 0
	var/cloud_expire = 0

	New(mob/User)
		..()
		if(User)
			if(!expire_time)
				start_time = world.realtime
				expire_time = start_time + TimerLimit
			if(world.realtime >= expire_time)
				src.AutoRemove(User)
				return
			src.AutoTrigger(User)

	proc/AutoTrigger(mob/User)
		if(!User) return
		OMsg(User, "[User] [ActiveMessage]")
		Log("Admin", "[ExtractInfo(User)] received Mortal Instinct adaptation debuff (14d duration).")

		spawn()
			while(User && src in User.contents)
				if(world.realtime >= expire_time)
					src.AutoRemove(User)
					break
				sleep(600)

	proc/AutoRemove(mob/User)
		if(!User) return
		OMsg(User, "[User] [OffMessage]")
		Log("Admin", "[ExtractInfo(User)]'s Mortal Instinct adaptation debuff has expired (14d complete).")
		del(src)

	proc/GetRemainingTime()
		var/time_left = max(expire_time - world.realtime, 0)
		return time_left

	verb/CloudedHeart()
		set name = "Clouded Heart"
		set desc = "Suppress your divine state for one hour, allowing mortal emotion to surface."
		set category = "Skills"
		var/mob/User = usr
		if(!User) return
		if(User.CloudedHeartActive)
			User << "<font color='#ffb3c6'><b>Your heart is already clouded. Wait until your emotions settle.</b></font>"
			return

		if(!src.cloud_start) src.cloud_start = 0
		if(!src.cloud_expire) src.cloud_expire = 0

		if(world.realtime < src.cloud_expire)
			var/time_left = round((src.cloud_expire - world.realtime) / 600)
			User << "<font color='#ffb3c6'><b>Your divine heart is still recovering. Wait [time_left] more minutes.</b></font>"
			return

		User.CloudedHeartActive = TRUE
		src.cloud_start = world.realtime
		src.cloud_expire = src.cloud_start + 36000
		src.Cooldown(1, 3600, User)

		var/hadClearMind = FALSE
		var/hadDivineStrain = FALSE
		var/clearMindTimeLeft = 0

		for(var/obj/Skills/Buffs/TemporaryDebuffs/Mortal_Instinct_Debuff/DivineStrain/D in User.contents)
			del(D)
			hadDivineStrain = TRUE

		for(var/obj/Skills/Buffs/TemporaryDebuffs/Mortal_Instinct_Debuff/ClearMind/C in User.contents)
			clearMindTimeLeft = C.GetRemainingTime()
			del(C)
			hadClearMind = TRUE

		if(hadClearMind || hadDivineStrain)
			User << "<font color='#c87aff'><b>Your divine calm fades, and mortal emotion clouds your heart...</b></font>"
			OMsg(User, "[User]'s divine aura dims beneath mortal doubt.")
			Log("Admin", "[ExtractInfo(User)] activated Clouded Heart: divine effects suppressed for 1 hour.")

		else

			User << "<font color='#d4aaff'><b>The divine strain stirs as your heart clouds over.</b></font>"
			OMsg(User, "[User]'s divine essence shifts under emotional weight.")
			Log("Admin", "[ExtractInfo(User)] used Clouded Heart without active buffs - DivineStrain will reapply later.")

		spawn()
			while(User && User.CloudedHeartActive)
				if(world.realtime >= src.cloud_expire)
					break
				sleep(600)
			if(User)
				var/newstrain = new /obj/Skills/Buffs/TemporaryDebuffs/Mortal_Instinct_Debuff/DivineStrain(User)
				User.contents += newstrain
				User << "<font color='#d4aaff'><b>The divine flow returns as your heart clears once more.</b></font>"
				OMsg(User, "[User]'s divine strain reawakens after the heart clears.")
				Log("Admin", "[ExtractInfo(User)]'s Clouded Heart expired. DivineStrain restored!")

				if(hadClearMind)
					var/obj/Skills/Buffs/TemporaryDebuffs/Mortal_Instinct_Debuff/ClearMind/newmind = new /obj/Skills/Buffs/TemporaryDebuffs/Mortal_Instinct_Debuff/ClearMind(User)
					User.contents += newmind
					if(clearMindTimeLeft > 0)
						newmind.expire_time = world.realtime + clearMindTimeLeft
					newmind.AutoTrigger(User)
					User << "<font color='#bfefff'><b>Your thoughts settle back into divine clarity.</b></font>"
					Log("Admin", "[ExtractInfo(User)]'s ClearMind restored with previous timer intact.")
				User.CloudedHeartActive = FALSE
				src.cloud_start = 0
				src.cloud_expire = 0




/obj/Skills/Buffs/TemporaryDebuffs/Mortal_Instinct_Debuff/DivineStrain
	BuffName = "Divine Strain"
	desc = "Your mortal body is struggling to adapt to divine instinct."
	Slotless = 1
	Copyable = 0
	TimerLimit = 259200 // 72 hours
	expire_time = 0
	StrMult = 0.8
	EndMult = 0.8
	SpdMult = 0.9
	DefMult = 0.9
	OffMult = 0.85
	ForMult = 0.85
	ActiveMessage = "is overwhelmed by divine pressure!"
	OffMessage = "has fully adapted to the divine flow!"
	TextColor = "#d4aaff"

	New(mob/User)
		..()
		if(User)
			expire_time = world.realtime + TimerLimit
			src.AutoTrigger(User)

	proc/AutoTrigger(mob/User)
		if(!User) return
		OMsg(User, "[User] [ActiveMessage]")
		Log("Admin", "[ExtractInfo(User)] received Mortal Instinct adaptation debuff (72h duration).")

		spawn()
			while(User && src in User.contents)
				if(world.realtime >= expire_time)
					src.AutoRemove(User)
					break
				sleep(600)

	proc/AutoRemove(mob/User)
		if(!User) return
		OMsg(User, "[User] [OffMessage]")
		Log("Admin", "[ExtractInfo(User)]'s Mortal Instinct adaptation debuff has expired (72h complete).")
		del(src)