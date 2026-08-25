mob/var/Frozen
mob/var/tmp/Moving
mob/var/Decimals=0

mob/var/warperTimeLock = 0

globalTracker/var/SPEED_DELAY = 3
globalTracker/var/GOD_SPEED_MULT = 0.4
globalTracker/var/TOTAL_SPEED_BONUS = 0.031
globalTracker/var/MOVE_STAT_BASE = 19
globalTracker/var/SPEED_DELAY_LOWEST = 1.75
mob/proc/MovementSpeed()
	var/Spd=max(0.1,round(sqrt((src.GetSpd()+glob.MOVE_STAT_BASE)*glob.TOTAL_SPEED_BONUS),0.1))
	var/SpdMin=max(0.1,round(sqrt((passive_handler.Get("Skimming")*2+glob.MOVE_STAT_BASE)*glob.TOTAL_SPEED_BONUS),0.1))
	if(passive_handler.Get("Skimming") + is_dashing)
		if(Spd<SpdMin)
			Spd=SpdMin
	var/SpdMult = 0;
	var/Godspeed = src.HasGodspeed();
	if(src.Crippled > 10)
		var/CrippledGod=round(src.Crippled/10);
		Godspeed = min(0, Godspeed-CrippledGod);
	SpdMult = max(0.1,glob.GOD_SPEED_MULT*sqrt(max(1,Godspeed)))
	var/Delay=glob.SPEED_DELAY/(Spd*(1+SpdMult))
	if(src.Flying)
		Delay=0.25
		if(src.Attracted)
			Delay*=4
		return Delay
	else if(passive_handler.Get("Skimming") + is_dashing)
		return Delay
	if(src.HasBlastShielding())
		Delay*=3
	if(src.CanBeSlowed())
		var/CombatSlow=glob.COMBAT_SLOW_THRESHOLD/max(src.HealthPct(),1)
		if(CombatSlow>1 && !passive_handler["Undying Rage"])
			var/Adren = passive_handler.Get("Adrenaline")
			if(Adren)
				if(CombatSlow<2)
					Delay/=CombatSlow
					Delay-=Adren
				else
					Delay/=1+Adren
			else
				Delay*=CombatSlow
		if(Delay>49)
			Delay=50
		if(Delay<glob.SPEED_DELAY_LOWEST)
			Delay=glob.SPEED_DELAY_LOWEST
	if(!PmActive()) //pixel build does afterimages per tile-crossing in PmMovementTick instead
		if(src.Afterimages())
			if(prob(40*Afterimages()))
				FlashImage(src)
	if(Swim)
		if(passive_handler.Get("Fishman"))
			Delay/=2
		else
			Delay*=4
	if(src.mirror_hold_slowing)
		Delay *= 4  
	if(src.Attracted)
		Delay*=4
	if(src.SenseRobbed>=1&&(src.SenseUnlocked<=src.SenseRobbed&&src.SenseUnlocked>5))
		Delay*=(2*src.SenseRobbed)
	// Daruma-san ga Koronda is 2x move speed only when moving towards the target
	if(src.DarumaActive)
		var/turf/dahead = get_step(src, src.dir)
		if(dahead && src.DarumaMovingToward(dahead))
			Delay /= 2
	return Delay

mob/Move()
	if(src.Suspended || src.ActionLocked)
		return
	var/turf/Former_Location = loc
	if(src.Incorporeal)
		src.density=0
	if(!src.Incorporeal&&!src.passive_handler?.Get("Skimming")&&!src.is_dashing&&!isAI(src)&&!Knockback)
		for(var/obj/Turfs/Edges/A in loc)
			if((A.dir in list(dir,turn(dir,45),turn(dir,-45))))
				return
		for(var/obj/Turfs/CustomObj1/customObject in loc)
			if(customObject.edge && (customObject.dir in list(dir,turn(dir,45),turn(dir,-45))))
				return
	..()

	//turn the world-shadow with the mob instead of waiting on the 3ds loop
	if(shadow_pool && length(shadow_pool) && glob && glob.WORLD_SHADOWS)
		for(var/obj/fx_worldshadow/s in shadow_pool)
			s.RebuildSilhouette()


	if(passive_handler.Get("ForceFielded"))
		for(var/mob/m in oview(glob.FORCEFIELD_RANGE, src))
			if(passive_handler.Get("ForceFielded") == m.ckey)
				loc = Former_Location
				break

	if(!src.Incorporeal&&!src.passive_handler?.Get("Skimming")&&!src.is_dashing&&!isAI(src)&&!Knockback)
		for(var/obj/Turfs/Edges/A in loc)
			if(!(A.dir in list(dir,turn(dir,90),turn(dir,-90),turn(dir,45),turn(dir,-45))))
				loc=Former_Location
				break
		for(var/obj/Turfs/CustomObj1/customObject in loc)
			if(customObject.edge && (customObject.dir in list(dir,turn(dir,90),turn(dir,-90),turn(dir,45),turn(dir,-45))))
				loc = Former_Location
				break
/*	if(src.passive_handler.Get("Skimming"))
		var/range = passive_handler.Get("GiantSwings") ? passive_handler.Get("GiantSwings") : 1
		for(var/mob/M in oview(range, src))
			if(M != src && M.density)
				src.Melee1(dmgmulti =(0.15), forcedTarget = M)*/
	if(Bleed > 0 && !Knockback && !is_dashing && client && (!PmActive() || loc != Former_Location)) //micro-steps bleed per tile, not per slide
		WoundSelf(0.01)

	if(src.Grab && (!PmActive() || loc != Former_Location))
		src.Grab_Update()

	if(MapperWalk&&!Knockback&&Target&&istype(Target,/obj/Others/Build))
		Build_Lay(Target,src, 0, 0, 0)

	if(AFKTimer==0)
		overlays-=AFKIcon
	AFKTimer=AFKTimeLimit

	if(istype(src, /mob/Players))
		var/mob/Players/P = src
		P.resetSlothTracking()
