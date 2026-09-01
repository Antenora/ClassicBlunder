#define STUDIO_PLOT_HALF 75
#define STUDIO_ASSIGN_FILE "Saves/StudioAssign.txt"

var/global/STUDIO_Z = 26
var/global/list/studioAssign
var/global/studioPrepping = 0

area/Outside/Studio
	name = "Mapper Studio"

area/Outside/Studio/sees_sky = 0

mob/var/tmp/studioRetX = 0
mob/var/tmp/studioRetY = 0
mob/var/tmp/studioRetZ = 0

/proc/BuildStudioLoad()
	if(studioAssign)
		return studioAssign
	studioAssign = list()
	if(!fexists(STUDIO_ASSIGN_FILE))
		return studioAssign
	var/t = file2text(STUDIO_ASSIGN_FILE)
	for(var/line in splittext(t, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len < 2)
			continue
		var/z = text2num(f[2])
		if(z)
			studioAssign[f[1]] = z
	return studioAssign

/proc/BuildStudioSave()
	var/list/lines = list()
	for(var/k in studioAssign)
		lines += "[k]\t[studioAssign[k]]"
	if(fexists(STUDIO_ASSIGN_FILE))
		fdel(STUDIO_ASSIGN_FILE)
	text2file(jointext(lines, "\n"), STUDIO_ASSIGN_FILE)

/proc/BuildStudioBootRestore()
	BuildStudioLoad()
	var/mz = world.maxz
	for(var/k in studioAssign)
		mz = max(mz, studioAssign[k])
	if(mz > world.maxz)
		world.maxz = mz

/proc/BuildStudioZTaken(z)
	for(var/k in studioAssign)
		if(studioAssign[k] == z)
			return 1
	return 0

/proc/BuildStudioSeedFree()
	if(STUDIO_Z > world.maxz || BuildStudioZTaken(STUDIO_Z))
		return 0
	var/turf/probe = locate(round(world.maxx / 2), round(world.maxy / 2), STUDIO_Z)
	if(!probe)
		return 0
	if(istype(probe, /turf/Special/Blank))
		return 1
	if(istype(probe.loc, /area/Outside/Studio))
		return 1
	return 0

/proc/BuildStudioAssign(ck)
	BuildStudioLoad()
	var/z = 0
	if(BuildStudioSeedFree())
		z = STUDIO_Z
	if(!z)
		world.maxz++
		z = world.maxz
	studioAssign[ck] = z
	BuildStudioSave()
	return z

/proc/BuildStudioPrepare(z)
	set waitfor = FALSE
	set background = TRUE
	if(studioPrepping)
		return
	var/cx = round(world.maxx / 2)
	var/cy = round(world.maxy / 2)
	var/turf/probe = locate(cx, cy, z)
	if(!probe)
		return
	studioPrepping = 1
	var/area/Outside/Studio/AZ = locate(/area/Outside/Studio)
	if(!AZ)
		AZ = new
	var/n = 0
	for(var/y = cy - STUDIO_PLOT_HALF to cy + STUDIO_PLOT_HALF - 1)
		for(var/x = cx - STUDIO_PLOT_HALF to cx + STUDIO_PLOT_HALF - 1)
			var/turf/T = locate(x, y, z)
			if(!T || !istype(T, /turf/Special/Blank))
				continue
			var/turf/NT = new/turf/Grass1(T)
			AZ.contents += NT
			n++
			if(n % 500 == 0)
				sleep(-1)
	studioPrepping = 0

mob/Mapper/verb/Enter_Studio()
	set category = "Mapper"
	BuildStudioLoad()
	var/z = studioAssign[usr.ckey]
	if(!z)
		z = BuildStudioAssign(usr.ckey)
		usr << "A private studio has been assigned to you (z[z]). It is yours across reboots."
	else if(z > world.maxz)
		world.maxz = z
	if(usr.z == z)
		usr << "You are already in your studio (z[z])."
		return
	var/cx = round(world.maxx / 2)
	var/cy = round(world.maxy / 2)
	var/turf/probe = locate(cx, cy, z)
	if(istype(probe, /turf/Special/Blank))
		usr << "Preparing your canvas ([STUDIO_PLOT_HALF * 2]x[STUDIO_PLOT_HALF * 2])..."
	BuildStudioPrepare(z)
	usr.studioRetX = usr.x
	usr.studioRetY = usr.y
	usr.studioRetZ = usr.z
	usr.loc = locate(cx, cy, z)
	usr << "Your Mapper Studio (z[z]). Build on the canvas, Export_Map_Region your work, Leave_Studio to return."
	Log("Mapper", "[usr] ([usr.ckey]) entered their studio (z[z]).", 1)

mob/Mapper/verb/Leave_Studio()
	set category = "Mapper"
	if(!usr.studioRetZ)
		usr << "No stored return point."
		return
	usr.loc = locate(usr.studioRetX, usr.studioRetY, usr.studioRetZ)
	usr.studioRetZ = 0
	usr << "Returned from the Studio."

mob/Admin3/verb/Free_Studio()
	set category = "Mapper"
	spawn
		var/ck = usr.HUDTextPrompt("Free whose studio? (ckey)", "")
		if(isnull(ck) || !length(ck))
			return
		ck = ckey(ck)
		BuildStudioLoad()
		if(!studioAssign[ck])
			usr << "No studio assigned to [ck]. Assigned: [studioAssign.len]."
			for(var/k in studioAssign)
				usr << "  [k] -> z[studioAssign[k]]"
			return
		var/z = studioAssign[ck]
		studioAssign -= ck
		BuildStudioSave()
		usr << "Freed [ck]'s studio claim on z[z]. Anything they built there still exists; the z is NOT reused automatically."
		Log("Mapper", "[usr] ([usr.ckey]) freed [ck]'s studio (z[z]).", 1)
