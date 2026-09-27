#define TRACKER_TAG_TIME 6000
#define TRACKER_TAG_CHANNEL 20
#define SWEEPER_COOLDOWN 300

mob/var/tmp/tracker_tag_until = 0
mob/var/tmp/tracker_tag_by
mob/var/tmp/sweeper_next = 0

mob/proc/IsTrackerTagged()
	return tracker_tag_until > world.time

mob/proc/TrackerTagClear()
	if(!IsTrackerTagged()) return 0
	tracker_tag_until = 0
	tracker_tag_by = null
	return 1

mob/proc/EspionageTechRefused()
	if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Science"))
		src << "The device will not work in your hands."
		return 1
	return 0

/obj/Items/Tech/Tracker_Tag
	name = "Tracker Tag"
	desc = "A tiny transmitter. Target someone within a tile and use it out of a fight: after a 2 second channel it clings to them, and for 10 minutes your equipped Scouter shows their direction and distance every 5 seconds while they are on your map. A Bug Sweeper or a Jammer defeats it."
	icon = 'device.dmi'
	icon_state = "signaller"
	TechType = "Telecommunications"
	SubType = "Espionage Equipment"
	Stackable = 1

	Click()
		if(loc != usr)
			return ..()
		if(Using)
			usr << "You are already fixing a tag on someone."
			return
		spawn() TagUse(usr)

	proc/TagTarget(mob/M)
		var/mob/T = M.Target
		if(!ismob(T) || T == M || T.Dead || !T.loc || T.z != M.z || get_dist(M, T) > 1) return null
		return T

	proc/TagUse(mob/M)
		if(!M || loc != M || M.EspionageTechRefused()) return
		if(M.KO || M.InCombat())
			M << "You cannot tag someone in a fight."
			return
		var/mob/T = TagTarget(M)
		if(!T)
			M << "Target someone within a tile first."
			return
		Using = 1
		var/start = world.time
		M << "You start fixing a tracker tag onto [T]..."
		while(world.time < start + TRACKER_TAG_CHANNEL)
			sleep(2)
			if(!src || !M || loc != M || M.KO || M.InCombat() || M.last_damaged_time > start || TagTarget(M) != T)
				if(src) Using = 0
				if(M) M << "You lose your chance to tag [T]."
				return
		Using = 0
		T.tracker_tag_until = world.time + TRACKER_TAG_TIME
		T.tracker_tag_by = M.DeviceKey()
		M << "The tag clings to [T]. Your Scouter will follow them for [TRACKER_TAG_TIME / 600] minutes."
		if(Stackable && TotalStack > 1)
			TotalStack--
			suffix = "[TotalStack]"
			if(M.client) M.client.BuildInvPage()
			return
		loc = null
		if(M.client) M.client.BuildInvPage()
		del src

/obj/Items/Tech/Bug_Sweeper
	name = "Bug Sweeper"
	desc = "Sweeps you, and the target within a tile of you, for tracker tags, and destroys every planted wiretap in sight. It needs 30 seconds between sweeps and no power."
	icon = 'device.dmi'
	icon_state = "t-ray0"
	TechType = "Telecommunications"
	SubType = "Espionage Equipment"

	Click()
		if(loc != usr)
			return ..()
		SweepUse(usr)

	proc/SweepUse(mob/M)
		if(!M || loc != M || M.EspionageTechRefused()) return
		if(M.KO) return
		if(world.time < M.sweeper_next)
			M << "[src] is still cooling down."
			return
		M.sweeper_next = world.time + SWEEPER_COOLDOWN
		flick("t-ray1", src)
		var/list/swept = list(M)
		var/mob/T = M.Target
		if(ismob(T) && T != M && T.z == M.z && get_dist(M, T) <= 1) swept += T
		var/tags = 0
		for(var/mob/X in swept)
			if(X.TrackerTagClear()) tags++
		var/taps = 0
		for(var/atom/movable/A in view(M))
			if(istype(A, /obj/Items/Tech/Planted_Wiretap))
				taps++
				del A
				continue
			if(!ismob(A)) continue
			for(var/obj/Items/Tech/Planted_Wiretap/W in A)
				taps++
				del W
		M << "The sweep destroys [taps] wiretap[taps == 1 ? "" : "s"] nearby and clears [tags] tracker tag[tags == 1 ? "" : "s"]."
