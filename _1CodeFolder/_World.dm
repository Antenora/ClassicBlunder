var/list/PermaKeys=list("Marlin1", "Kalvin9899", "Dadafas1", "Miscreated", "Toefiejin", "StrangeBanana", "Cool pro", "Ss4toby", "Uwuesketit", "Sarutabaruta", "Pigepic", "WarHorse76", "George Bush Did 911", "Xaithyl", "Yoshima Monomyth", "Naviel", "Greg76", "Sekots", "TienShenhan", "WhatIsOriginality", "Solobb-", "Xerif", "MikaNX", "Tusk Act 4", "Vaina", "ProtoZSX", "Revelution", "Higashikata Josuke", "BDSMLover92", "Justbroli",)
var/list/PermaIPs=list("143.244.44.185", "73.132.147.113", "77.175.168.164", "74.105.35.124", "81.132.77.65", "64.130.69.214", "65.185.161.235", "108.61.39.115", "75.65.2.4", "24.50.233.176", "50.39.120.226", "135.180.40.74", "86.181.159.231", "45.36.32.84", "198.85.212.230", "74.88.65.98", "76.23.208.95", "66.172.248.64", "185.156.175.35", "136.62.42.182", "68.8.92.94", "109.246.123.195", "24.36.113.151", "67.198.127.237", "82.34.152.124", "121.223.199.102", "174.108.20.140", "179.43.133.139", "174.108.20.140", "73.47.207.244", "71.64.147.189", "70.35.179.6", "69.10.118.103", "86.19.157.156")
var/list/PermaComps=list("1280524509 ", "3488379531", "1990235738", "1662279420", "835666311", "3995897142", "3272450259", "1395820860", "1629772640", "3856341027", "938246607", "975079193", "1526134833", "4102036161", "3446557113", "3878049361", "2311757843", "3649180149", "991955925", "2016627605", "3836126501", "4003197390", "4145629418", "1476716854", "4229503323", "1353023831", "348890025", "308161406", "729772691", "1049091416", "2196626777", "2781360184", "3770567560", "961693842")
var/tmp/list/players = list()
var/tmp/list/admins = list()

world
	name="The Jesse Experienceth: Requiem"
	status="The Fourth Fate"
	turf=/turf/Special/Blank
	mob= /mob/Creation
	hub="AmatsuDarkfyre.RoleplayRebirth"
	hub_password="silverion"
	fps=20
	cache_lifespan=2
	view=12
	OpenPort()
		..()
		world<<"World Link: byond://[address]:[port]."
	New()
		..()

		world.log = file("debug_log.txt")
		world.log << ""
		world.log << "-------"
		world.log << "[time2text(world.timeofday,"DDD MMM DD hh:mm YYYY",-5)]"
		world.log << "-------"
		world.log << "//\[info]: World Initialized!"
		world.log << "//\[info]: [world.name]"

		LOGscheduler.start()

		WorldLoading=1
		spawn(100)GlobalSave()

		spawn(10)

			BootWorld("Load")
		BuildGeneralMagicDatabase()
		BuildGeneralWeaponryDatabase()
		GeneratePlayActionDatabase()
		//initRitualDatabase()

		generateSwapMaps()
	Del()
		..()

proc
	generateSwapMaps()
		if(!fexists("Maps/UBW.sav"))
			SwapMaps_SaveChunk("UBW", locate(1,71,1), locate(61, 121,1))
			SwapMaps_Save("UBW")


proc/GlobalSave()
	set background=1
	sleep(216000)
	world<< "<b><HTML><FONT COLOR=#FF0000>T</FONT><FONT COLOR=#FF2900>h</FONT><FONT COLOR=#FF5200>e</FONT><FONT COLOR=#FF7B00> </FONT><FONT COLOR=#FFA400>w</FONT><FONT COLOR=#FFCD00>o</FONT><FONT COLOR=#FFF600>r</FONT><FONT COLOR=#FFff00>l</FONT><FONT COLOR=#D6ff00>d</FONT><FONT COLOR=#ADff00> </FONT><FONT COLOR=#84ff00>i</FONT><FONT COLOR=#5Bff00>s</FONT><FONT COLOR=#32ff00> </FONT><FONT COLOR=#09ff00>s</FONT><FONT COLOR=#00ff00>a</FONT><FONT COLOR=#00ff29>v</FONT><FONT COLOR=#00ff52>i</FONT><FONT COLOR=#00ff7B>n</FONT><FONT COLOR=#00ffA4>g</FONT><FONT COLOR=#00ffCD>.</FONT><FONT COLOR=#00ffF6> </FONT><FONT COLOR=#00ffff>P</FONT><FONT COLOR=#00F6ff>r</FONT><FONT COLOR=#00CDff>e</FONT><FONT COLOR=#00A4ff>p</FONT><FONT COLOR=#007Bff>a</FONT><FONT COLOR=#0052ff>r</FONT><FONT COLOR=#0029ff>e</FONT><FONT COLOR=#0000ff> </FONT><FONT COLOR=#0900ff>y</FONT><FONT COLOR=#3200ff>o</FONT><FONT COLOR=#5B00ff>u</FONT><FONT COLOR=#8400ff>r</FONT><FONT COLOR=#AD00ff>s</FONT><FONT COLOR=#D600ff>e</FONT><FONT COLOR=#FF00ff>l</FONT><FONT COLOR=#FF00F6>f</FONT><FONT COLOR=#FF00CD>!</FONT></HTML></b>"
	for(var/mob/Players/Q in players)
		if(Q.Savable&&Q.client!=null)
			Q.client.SaveChar()
	BootWorld("Save")
	.()

var/WorldLoading

var/list/LockedRaces=list()

mob/proc/CheckUnlock(race/_race)
	if(_race.removed) return 0
	if(src.Admin) return 1
	if(_race.locked)
		for(var/i in glob.LockedRaces)
			if(ckey(i)==ckey && glob.LockedRaces[i] == _race.name)
				return 1
	if(!_race.locked)
		return 1
	return 0

proc/BootWorld(var/blah)
	switch(blah)
		if("Load")
			BootFile("All","Load")
			Load_Turfs()
			Load_Custom_Turfs()
			Load_Objects()
			Load_Bodies()
			LoadIRLNPCs()
			spawn()
				if(!celestialObjectTicks) celestialObjectTicks = Hour(12)/10
				CelestialBodiesLoop()
			spawn()Add_Builds()
			spawn()MakeSkillTreeList()
			spawn()MakeKnowledgeTreeList()
			spawn()Add_Customizations()
			spawn()Add_Technology()
			spawn()Add_Enchantment()
			spawn()InitializeSigCombos()
			globalStorage = new()
			generateVersionDatum()
			spawn()
				global.global_loop = new()
				global.ai_loop = new()
				global.travel_loop = new()
				global.ai_tracker_loop = new()
			WorldLoading=0
			Reports("Load")
			find_savableObjects()

		if("Save")
			BootFile("All","Save")
			Reports("Save")
			find_savableObjects()

			Save_Turfs()
			Save_Custom_Turfs()
			Save_Bodies()
			SaveIRLNPCs()
		//	resourceManager.SaveToSavefile()
			spawn() Save_Objects()


proc/BootFile(var/file,var/op)
	set background=1
	world<<"<small>Server: ([op])ing [file]"
	switch(file)
		if("Admins")
			if(op=="Load")
				if(fexists("Saves/Admins"))
					var/savefile/F=new("Saves/Admins")
					F["Admins"]>>Admins
				if(fexists("Saves/Mappers"))
					var/savefile/F=new("Saves/Mappers")
					F["Mappers"]>>Mappers

			if(op=="Save")
				var/savefile/F=new("Saves/Admins")
				F["Admins"]<<Admins
				var/savefile/M=new("Saves/Mappers")
				M["Mappers"]<<Mappers
		if("Misc")
			if(op=="Load")
				if(fexists("Saves/globals"))
					var/savefile/F=new("Saves/globals")
					F["glob"]>>glob
					F["globProgress"]>>glob.progress
					if(!length(redactedwords) < 1)
						redactedwords = list()
					archive = new()
					if(F["archive"])
						F["archive"]>>archive
					archive.loadAGs()

				if(fexists("Saves/Rules"))
					var/savefile/S=new("Saves/Rules")
					S["Saves/Rules"]>>Rules
				if(fexists("Saves/Story"))
					var/savefile/S=new("Saves/Story")
					S["Saves/Story"]>>Story
				if(fexists("Saves/Ranks"))
					var/savefile/S=new("Saves/Ranks")
					S["Saves/Ranks"]>>Ranks
				if(fexists("Saves/AdminNotes"))
					var/savefile/S=new("Saves/AdminNotes")
					S["Saves/AdminNotes"]>>AdminNotes
			if(op=="Save")
				var/savefile/globalSave = new("Saves/globals")
				globalSave["glob"]<<glob
				globalSave["globProgress"]<<glob.progress
				var/savefile/F=new("Saves/Misc")
				// F["intimRatio"]<<INTIMRATIO
				if(archive)
					archive.AGs = list() // this will delete the AGs list, it should just track whatever is in game vs whatever exist period to avoid any issues
					F["archive"] << archive
				if(!length(redactedwords) < 1)
					redactedwords = list()
				F["redacted"]<<global.redactedwords
				var/savefile/S=new("Saves/Rules")
				S["Saves/Rules"]<<Rules
				var/savefile/Z=new("Saves/Story")
				Z["Saves/Story"]<<Story
				var/savefile/E=new("Saves/Ranks")
				E["Saves/Ranks"]<<Ranks
				var/savefile/W=new("Saves/AdminNotes")
				W["Saves/AdminNotes"]<<AdminNotes
		if("Bans")
			switch(op)
				if("Save")
					if(Punishments)
						var/savefile/S=new("Saves/Punishment")
						S["Punishments"]<<Punishments
				if("Load")
					if(fexists("Saves/Punishment"))
						var/savefile/S=new("Saves/Punishment")
						S["Punishments"]>>Punishments
		if("All")
			if(op=="Save")
				BootFile("Admins","Save")
				BootFile("Misc","Save")
				BootFile("Bans","Save")
			if(op=="Load")
				BootFile("Admins","Load")
				BootFile("Misc","Load")
				BootFile("Bans","Load")
	world<<"<small>Server: [file] ([op])ed"

client
	default_verb_category=null
	perspective=MOB_PERSPECTIVE
	//ACTUAL LOGOUT
	Del()
		prefs.savePrefs(ckey)
		src.LoginLog("LOGOUT")

		if(mob)
			mob.removeBlobBuffs()
			if(mob.party)
				mob.party.remove_member(mob)

			mob.RemoveWaterOverlay()
			var/image/A=image(icon='Say Spark.dmi',pixel_y=6)
			mob.overlays-=A
			var/obj/Effects/Stun/S=new
			S.appearance_flags=66
			mob.overlays-=S
			mob.Stunned=0
			mob.Auraz("Remove")
			mob.PoweringUp=0
			mob.PoweringDown=0
			mob.AfterImageStrike=0
			mob.Grounded=0
			for(var/x in hud_ids)
				remove_hud(x)
			mob.AppearanceOff()
			for(var/obj/fa_jin/fa in mob.vis_contents)
				mob.vis_contents -= fa
				del fa // hrm
			if(mob.Savable)
				mob.client.SaveChar()
			sleep(10)
			del(mob)
	New()
		if(src.key in global.PermaKeys)
			del(src)
			return
		for(var/x in global.PermaIPs)
			if(text2num(x)==src.address)
				del(src)
				return
		for(var/x in global.PermaComps)
			if(text2num(x)==src.computer_id)
				del(src)
				return
		prefs.loadPrefs(ckey)
		..()
		src << browse(glob.getMOTD(), "size=600x1000,window=motd" )
		src.LoginLog("<font color=blue>logged in.</font color>")




mob/proc/Allow_Move(D)
	if(!Move_Requirements())
		return
	if((src.Beaming||src.BusterTech)&&!src.HasMovingCharge())
		if(src.Beaming!=2)
			src.dir=D
			return
	if(src.Beaming==2)
		return
	if(src.PoweringUp)
		return
	if(src.PoweringDown)
		return

	for(var/mob/P in range(1,usr)) if(P.Grab==usr)
		var/Grab_Escape = min(60, max(10, world.time - P.GrabTime))
		var/brolic = P.CheckSlotless("Brolic Grip")
		var/grippy = P.passive_handler.Get("Grippy")
		var/ToD = P.passive_handler["Touch of Death"]
		if(brolic || grippy || ToD)
			if(brolic)
				brolic = 2 // make it 2

			grippy *= glob.GRIPPY_MOD
			Grab_Escape=Grab_Escape*( ( src.Power*src.GetStr() ) / ( P.Power*(P.GetStr() * (ToD + brolic + grippy)) ) )
		else
			Grab_Escape=Grab_Escape*((src.Power*src.GetStr())/(P.Power*P.GetStr()))
		if(prob(Grab_Escape))
			view(P)<<"[usr] breaks free of [P]!"
			P.Grab_Release()
		else
			view(P)<<"[usr] struggles against [P]!"
		sleep(10)
		return
	return 1
mob/proc/Move_Requirements()
	if(!Stasis&&!TimeFrozen&&!Frozen&&!Stunned&&!Moving&&!Launched&&!Knockbacked&&!KO&&!WindingUp)
		if(src.icon_state=="Meditate"||src.icon_state=="Train")
			if(src.Flying)
				return 1
			return 0
		return 1

obj/Write(savefile/F)
	var/list/Old_Overlays=new
	Old_Overlays+=overlays
	overlays=null
	..()
	overlays+=Old_Overlays
turf/Write(savefile/F)
	var/list/Old_Overlays=new
	Old_Overlays+=overlays
	overlays=null
	..()
	overlays+=Old_Overlays