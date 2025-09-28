mob/var/Frozen
mob/var/tmp/Moving
mob/var/Decimals=0

mob/var/warperTimeLock = 0

proc
	PlanetEnterBump(var/A,var/Q)
		if(istype(A,/obj/Items/Tech/Door))
			var/obj/Items/Tech/Door/B=A
			var/mob/M=Q
			if(B.Password)
				if(B.GodDoor)
					if(M.Spawn==B.Password)
						B.Open()
				else
					if(B.Password&&!B.AutoOpen)
						var/happened
						if(!happened)
							var/eee
							for(var/obj/Items/Tech/Door_Pass/L in Q)
								if(L.Password==B.Password)
									B.Open()
									if(istype(B,/obj/Items/Tech/Door/LazerDoor))
										if(B.DoorID)
											for(var/obj/Items/Tech/Door/LazerDoor/X in world)
												if(X.DoorID==B.DoorID)
													X.Open()
									eee=1
							for(var/obj/Items/Tech/Digital_Key/C in Q)
								if(C.Password==B.Password||C.Password2==B.Password||C.Password3==B.Password)
									B.Open()
									if(istype(B,/obj/Items/Tech/Door/LazerDoor))
										if(B.DoorID)
											for(var/obj/Items/Tech/Door/LazerDoor/X in world)
												if(X.DoorID==B.DoorID)
													X.Open()
									eee=1
							if(!eee&&!Q:Knockbacked)
								var/Guess=input(Q,"You must know the password to enter here") as text
								if(Guess==B.Password)
									B.Open()
									if(istype(B,/obj/Items/Tech/Door/LazerDoor))
										if(B.DoorID)
											for(var/obj/Items/Tech/Door/LazerDoor/X in world)
												if(X.DoorID==B.DoorID)
													X.Open()
								else
									if(istype(B,/obj/Items/Tech/Door/LazerDoor))
										Q << "The lazer door burns your hand!"
										Q:AddBurn(1)
					else
						B.Open()
			else
				B.Open()
globalTracker/var/SPEED_DELAY = 3
globalTracker/var/GOD_SPEED_MULT = 0.2
globalTracker/var/TOTAL_SPEED_BONUS = 0.4
globalTracker/var/SPEED_DELAY_LOWEST = 1.75
mob/proc/MovementSpeed()
	var/Spd=max(0.1,round(sqrt(src.GetSpd(glob.TOTAL_SPEED_BONUS)),0.1))
	var/SpdMult = 0
	if(HasGodspeed())
		SpdMult = max(0.1,glob.GOD_SPEED_MULT*sqrt(max(1,src.HasGodspeed())))
	var/Delay=glob.SPEED_DELAY/(Spd*(1+SpdMult))
	if(src.Flying)
		Delay=0.25
		if(src.Attracted)
			Delay*=4
		return Delay
	else if(passive_handler.Get("Skimming") + is_dashing)
		Delay=0.75/sqrt(passive_handler.Get("Skimming") + is_dashing)
		if(src.Attracted)
			Delay*=4
		return Delay
	if(src.HasBlastShielding())
		Delay*=3
	if(src.CanBeSlowed())
		var/CombatSlow=10/max(src.Health,1)
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
	if(src.Afterimages())
		if(prob(40*Afterimages()))
			FlashImage(src)
	if(Swim)
		if(passive_handler.Get("Fishman"))
			Delay/=2
		else
			Delay*=4
	if(src.Attracted)
		Delay*=4
	if(src.SenseRobbed>=1&&(src.SenseUnlocked<=src.SenseRobbed&&src.SenseUnlocked>5))
		Delay*=(2*src.SenseRobbed)
	return Delay

mob/Move()
	var/turf/Former_Location = loc
	if(src.Incorporeal)
		src.density=0
	if(!src.Incorporeal&&!src.passive_handler.Get("Skimming")&&!src.is_dashing&&!isai(src)&&!Knockback)
		for(var/obj/Turfs/Edges/A in loc)
			if((A.dir in list(dir,turn(dir,45),turn(dir,-45))))
				return
		for(var/obj/Turfs/CustomObj1/customObject in loc)
			if(customObject.edge && (customObject.dir in list(dir,turn(dir,45),turn(dir,-45))))
				return
	..()

	if(!src.Incorporeal&&!src.passive_handler.Get("Skimming")&&!src.is_dashing&&!isai(src)&&!Knockback)
		for(var/obj/Turfs/Edges/A in loc)
			if(!(A.dir in list(dir,turn(dir,90),turn(dir,-90),turn(dir,45),turn(dir,-45))))
				loc=Former_Location
				break
		for(var/obj/Turfs/CustomObj1/customObject in loc)
			if(customObject.edge && (customObject.dir in list(dir,turn(dir,90),turn(dir,-90),turn(dir,45),turn(dir,-45))))
				loc = Former_Location
				break

	if(src.Grab)
		src.Grab_Update()

	if(MapperWalk&&!Knockback&&Target&&istype(Target,/obj/Others/Build))
		Build_Lay(Target,src, 0, 0, 0)

	if(AFKTimer==0)
		overlays-=AFKIcon
	AFKTimer=AFKTimeLimit