mob/Players
	Savable=0
	Write(savefile/A)
		..()
		A["x"]<<x
		A["y"]<<y
		A["z"]<<z
	Read(savefile/A)
		..()
		loc=locate(A["x"],A["y"],A["z"])

	Bump(mob/A)
/*		if(istype(A, /obj/Skills/Projectile/Beams))
			src.loc=A.loc
			//A.Bump(src)
			return*/

		if(istype(A,/obj/Special/Teleporter2)&&!(istype(A, /obj/Special/Teleporter2/SpecialTele)))
			var/obj/Special/Teleporter2/_tp=A
			for(var/obj/Items/Tech/Door/D in locate(_tp.gotoX,_tp.gotoY,_tp.gotoZ))
				del D//Clear doors on the tile linked to by the warper.
			src.loc=locate(_tp.gotoX,_tp.gotoY,_tp.gotoZ)
			if(_tp.SetSpawn != null)
				information.setFaction(_tp.SetSpawn)
		if(istype(A,/obj/Special/Teleporter2/SpecialTele))
			if(!warperTimeLock)
				var/obj/Special/Teleporter2/tele=A
				var/newz
				if(tele.type==/obj/Special/Teleporter2/SpecialTele/GoAbove)
					newz=tele.z-1
				if(tele.type==/obj/Special/Teleporter2/SpecialTele/GoBelow)
					newz=tele.z+1
				if(tele.type==/obj/Special/Teleporter2/SpecialTele/GoDeep)
					newz=tele.z+2
				if(tele.type==/obj/Special/Teleporter2/SpecialTele/GoHigh)
					newz=tele.z-2
				src.loc=locate(tele.x, tele.y, newz)
				if(tele.warperTimeLock)
					warperTimeLock = tele.warperTimeLock

		if(istype(A,/obj/Effects/PocketPortal))
			for(var/obj/Effects/PocketExit/Q in world)
				if(Q.Password==A.Password)
					src.loc=locate(Q.x,Q.y-1,Q.z)
					break

		if(istype(A,/obj/Effects/PocketExit))
			for(var/obj/Effects/PocketPortal/Q in world)
				if(Q.Password==A.Password)
					src.loc=locate(Q.x,Q.y-1,Q.z)
					break
				src<<"Unable to travel to portal...attempting portal to generator..."
			for(var/obj/Items/Enchantment/PocketDimensionGenerator/B in world)
				if(B.DimensionType==A.Password)
					src.loc=locate(B.x,B.y-1,B.z)
					break
				src<<"Unable to exit dimension! Contact admins."

		if(istype(A,/obj/Turfs/RoofGlass))
			return

		if(istype(A,/obj/Items/Enchantment/Portal))
			var/obj/Items/Enchantment/Portal/PortalScan=A
			if(PortalScan.Password==null)
				return
			for(var/obj/Items/Enchantment/Portal/B in world)
				if(B.Password==PortalScan.Password&&B!=PortalScan&&B.z)
					src.loc=locate(B.x,B.y,B.z)
					break

		PlanetEnterBump(A,src)

