mob/Player/AI/TestDummy
	name = "Test Dummy"

	Update()
		Health = 100
		TotalInjury = 0
		TotalFatigue = 0
		if(KO) Conscious()
		..()

/mob/Admin2/verb/Summon_Test_Dummy()
	set category = "Admin"
	for(var/mob/Player/AI/TestDummy/old in world)
		if(old.ai_owner == usr) del(old)
	var/mob/Player/AI/TestDummy/d = new
	var/turf/spot = get_step(usr, usr.dir)
	d.loc = spot ? spot : usr.loc
	d.ai_owner = usr		//keeps it ticking + blocks AI auto-death on KO
	d.ai_hostility = 0		
	d.ai_wander = 0
	d.ai_state = "Idle"
	usr << "Dummy up."

/mob/Admin2/verb/Dismiss_Test_Dummy()
	set category = "Admin"
	var/found = 0
	for(var/mob/Player/AI/TestDummy/d in world)
		if(d.ai_owner == usr)
			found = 1
			del(d)
	if(!found)
		for(var/mob/Player/AI/TestDummy/d in world)
			found = 1
			del(d)
	usr << (found ? "Dummy down." : "No dummy out.")
