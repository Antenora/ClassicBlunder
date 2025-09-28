var/list/worldObjectList = new // Looped through during the saving of objects

/mob/Admin4/verb/checkworldObjectList()
	for(var/obj/x in worldObjectList)
		if(x.Savable)
			if(!x || !x.loc)
				worldObjectList.Remove(x)

proc/find_savableObjects()
	for(var/obj/_object in world) // Find all objects in the world
		if(!_object.z||_object.z==0) continue
		if(_object in global.worldObjectList)
			if(!_object.z||_object.z==0)
				global.worldObjectList-=_object
				del(_object)
			else continue // If it's already in the world object list, skip it.
		if(_object.Savable==1) global.worldObjectList+=_object // If it's NOT, and we want it saved, add it to the world object list.

proc/Save_Custom_Turfs()
	set background = 1
	world<<"<small>Server: Saving Custom Turfs..."
	var/Amount=0
	var/E=1
	var/savefile/F=new("Saves/Map/CustomTurfs[E]")
	var/list/Types=new
	var/list/Healths=new
	var/list/Levels=new
	var/list/Builders=new
	var/list/Xs=new
	var/list/Ys=new
	var/list/Zs=new
	var/list/Icons=new
	var/list/Icons_States=new
	var/list/Densitys=new
	var/list/isRoof=new
	var/list/Opacitys=new
	var/list/FlyOver=new
	var/list/isOutside=new
	var/list/isUnderwater=new
	var/list/LogPEndurance=new
	var/list/Destructable=new
	for(var/turf/CustomTurf/A in CustomTurfs)
		if(A)
			Types+=A.type
			Healths+="[num2text(round(A.Health),100)]"
			Levels+="[num2text(A.Level,100)]"
			Builders+=A.Builder
			Xs+=A.x
			Ys+=A.y
			Zs+=A.z
			//var/savedIcon = (resourceManager.GetResourceName(A.icon) || resourceManager.GenerateDynResource(A.icon))

			//Icons+=savedIcon
			Icons += A.icon
			Icons_States+=A.icon_state
			Densitys+=A.density
			isRoof+=A.Roof
			Opacitys+=A.opacity
			FlyOver+=A.FlyOverAble
			isOutside+=A.isOutside
			isUnderwater+=A.isUnderwater
			Destructable+=A.Destructable
			Amount+=1
			if(Amount % 20000 == 0)
				F["Types"]<<Types
				F["Healths"]<<Healths
				F["Levels"]<<Levels
				F["Builders"]<<Builders
				F["Xs"]<<Xs
				F["Ys"]<<Ys
				F["Zs"]<<Zs
				F["Icons"]<<Icons
				F["Icons_States"]<<Icons_States
				F["Densitys"]<<Densitys
				F["isRoof"]<<isRoof
				F["Opacitys"]<<Opacitys
				F["FlyOver"]<<FlyOver
				F["isOutside"]<<isOutside
				F["isUnderwater"]<<isUnderwater
				F["LogPEndurance"]<<LogPEndurance
				F["Destructable"]<<Destructable
				E ++
				F=new("Saves/Map/CustomTurfs[E]")
				Types=new
				Healths=new
				Levels=new
				Builders=new
				Xs=new
				Ys=new
				Zs=new
				Icons=new
				Icons_States=new
				Densitys=new
				isRoof=new
				Opacitys=new
				FlyOver=new
				isOutside=new
				isUnderwater=new
				LogPEndurance=new
				Destructable=new

	if(Amount % 20000 != 0)
		F["Types"]<<Types
		F["Healths"]<<Healths
		F["Levels"]<<Levels
		F["Builders"]<<Builders
		F["Xs"]<<Xs
		F["Ys"]<<Ys
		F["Zs"]<<Zs
		F["Icons"]<<Icons
		F["Icons_States"]<<Icons_States
		F["Densitys"]<<Densitys
		F["isRoof"]<<isRoof
		F["Opacitys"]<<Opacitys
		F["FlyOver"]<<FlyOver
		F["isOutside"]<<isOutside
		F["isUnderwater"]<<isUnderwater
		F["LogPEndurance"]<<LogPEndurance
		F["Destructable"]<<Destructable

	world<<"<small>Server: Custom Turfs Saved([Amount])."

proc/Load_Custom_Turfs()
	set background = 1
	if(fexists("Saves/Map/CustomTurfs1"))
		world<<"<small>Server: Loading Custom Turfs..."
		var/Amount=0
		var/DebugAmount= 0
		var/E=1
		load
		if(!fexists("Saves/Map/CustomTurfs[E]"))
			goto end
		var/savefile/F=new("Saves/Map/CustomTurfs[E]")
		sleep(1)
		var/list/Types=F["Types"]
		var/list/Healths=F["Healths"]
		var/list/Levels=F["Levels"]
		var/list/Builders=F["Builders"]
		var/list/Xs=F["Xs"]
		var/list/Ys=F["Ys"]
		var/list/Zs=F["Zs"]
		var/list/Icons=F["Icons"]
		var/list/Icons_States=F["Icons_States"]
		var/list/Densitys=F["Densitys"]
		var/list/isRoof=F["isRoof"]
		var/list/Opacitys=F["Opacitys"]
		var/list/FlyOver=F["FlyOver"]
		var/list/isOutside=F["isOutside"]
		var/list/isUnderwater=F["isUnderwater"]
		var/list/Destructable=F["Destructable"]
		Amount = 0
		for(var/A in Types)
			Amount+=1
			DebugAmount += 1
			var/turf/CustomTurf/T=new A(locate(text2num(list2params(Xs.Copy(Amount,Amount+1))),text2num(list2params(Ys.Copy(Amount,Amount+1))),text2num(list2params(Zs.Copy(Amount,Amount+1)))))
			T.icon = Icons[Amount]
			//T.icon = resourceManager.GetResourceByName(Icons[Amount])
			T.icon_state= Icons_States[Amount]
			T.density=text2num(list2params(Densitys.Copy(Amount,Amount+1)))
			T.opacity=text2num(list2params(Opacitys.Copy(Amount,Amount+1)))
			T.Roof=text2num(list2params(isRoof.Copy(Amount,Amount+1)))
			T.Health=text2num(list2params(Healths.Copy(Amount,Amount+1)))
			T.Level=text2num(list2params(Levels.Copy(Amount,Amount+1)))
			T.Builder=list2params(Builders.Copy(Amount,Amount+1))
			T.FlyOverAble=text2num(list2params(FlyOver.Copy(Amount,Amount+1)))
			T.isOutside=text2num(list2params(isOutside.Copy(Amount,Amount+1)))
			T.isUnderwater=text2num(list2params(isUnderwater.Copy(Amount,Amount+1)))
			T.Destructable=text2num(list2params(Destructable.Copy(Amount,Amount+1)))
			CustomTurfs+=T // Turfs is the global list for all objects placed by players.

			for(var/obj/Turfs/Edges/B in T) if(!B.Builder) del(B)
			for(var/obj/Turfs/Surf/B in T) if(!B.Builder) del(B)
			for(var/obj/Turfs/Trees/B in T) if(!B.Builder) del(B)
			for(var/obj/Turfs/B in T) if(!B.Builder) del(B)

			if(Amount == 20000)
				sleep(1)
				break

		if(Amount == 20000)
			E ++
			goto load

		end
		world<<"<small>Server: Custom Turfs Loaded ([DebugAmount] in [E] Files.)"

proc/Save_Turfs()
	set background = 1
	world<<"<small>Server: Saving Map..."
	var/Amount=0
	var/E=1
	var/savefile/F=new("Saves/Map/File[E]")
	var/list/Types=new
	var/list/Healths=new
	var/list/Levels=new
	var/list/Builders=new
	var/list/Xs=new
	var/list/Ys=new
	var/list/Zs=new
	var/list/FlyOver=new
	var/list/isOutside=new
	var/list/isUnderwater=new
	var/list/LogPEndurance=new
	var/list/Destructable=new

//	debuglog << "[__FILE__]:[__LINE__] We got this far for mapfile[E]"

	for(var/turf/A in Turfs)
		if(A)
			Types+=A.type
			Healths+="[num2text(round(A.Health),100)]"
			Levels+="[num2text(A.Level,100)]"
			Builders+=A.Builder
			Xs+=A.x
			Ys+=A.y
			Zs+=A.z
			FlyOver+=A.FlyOverAble
			isOutside+=A.isOutside
			isUnderwater+=A.isUnderwater
			Destructable+=A.Destructable
			Amount+=1
			if(Amount % 20000 == 0)
				F["Types"]<<Types
				F["Healths"]<<Healths
				F["Levels"]<<Levels
				F["Builders"]<<Builders
				F["Xs"]<<Xs
				F["Ys"]<<Ys
				F["Zs"]<<Zs
				F["FlyOver"]<<FlyOver
				F["isOutside"]<<isOutside
				F["isUnderwater"]<<isUnderwater
				F["LogPEndurance"]<<LogPEndurance
				F["Destructable"]<<Destructable
				E ++
				F=new("Saves/Map/File[E]")
				Types=new
				Healths=new
				Levels=new
				Builders=new
				Xs=new
				Ys=new
				Zs=new
				FlyOver=new
				isOutside=new
				isUnderwater=new
				LogPEndurance=new
				Destructable=new

//	debuglog << "[__FILE__]:[__LINE__] We got this far for mapfile[E]"

	if(Amount % 20000 != 0)
		F["Types"]<<Types
		F["Healths"]<<Healths
		F["Levels"]<<Levels
		F["Builders"]<<Builders
		F["Xs"]<<Xs
		F["Ys"]<<Ys
		F["Zs"]<<Zs
		F["FlyOver"]<<FlyOver
		F["isOutside"]<<isOutside
		F["isUnderwater"]<<isUnderwater
		F["LogPEndurance"]<<LogPEndurance
		F["Destructable"]<<Destructable

//	debuglog << "[__FILE__]:[__LINE__] Map saved mapfile[E] :: Total amount of crap: [Amount]"

	world<<"<small>Server: Map Saved([Amount])."

proc/Load_Turfs()
	set background = 1
	if(fexists("Saves/Map/File1"))
		world<<"<small>Server: Loading Map..."
		var/Amount=0
		var/DebugAmount= 0
		var/E=1
		load
		if(!fexists("Saves/Map/File[E]"))
			goto end
		var/savefile/F=new("Saves/Map/File[E]")
		sleep(1)
		var/list/Types=F["Types"]
		var/list/Healths=F["Healths"]
		var/list/Levels=F["Levels"]
		var/list/Builders=F["Builders"]
		var/list/Xs=F["Xs"]
		var/list/Ys=F["Ys"]
		var/list/Zs=F["Zs"]
		var/list/FlyOver=F["FlyOver"]
		var/list/isOutside=F["isOutside"]
		var/list/isUnderwater=F["isUnderwater"]
		var/list/Destructable=F["Destructable"]
		Amount = 0
		for(var/A in Types)
			Amount+=1
			DebugAmount += 1
			var/turf/T=new A(locate(text2num(list2params(Xs.Copy(Amount,Amount+1))),text2num(list2params(Ys.Copy(Amount,Amount+1))),text2num(list2params(Zs.Copy(Amount,Amount+1)))))
			T.Health=text2num(list2params(Healths.Copy(Amount,Amount+1)))
			T.Level=text2num(list2params(Levels.Copy(Amount,Amount+1)))
			T.Builder=list2params(Builders.Copy(Amount,Amount+1))
			T.FlyOverAble=text2num(list2params(FlyOver.Copy(Amount,Amount+1)))
			T.isOutside=text2num(list2params(isOutside.Copy(Amount,Amount+1)))
			T.isUnderwater=text2num(list2params(isUnderwater.Copy(Amount,Amount+1)))
			T.Destructable=text2num(list2params(Destructable.Copy(Amount,Amount+1)))
			if(istype(T,/turf/Special/EventStars))
				T.icon_state="[rand(1,2500)]"
			Turfs+=T // Turfs is the global list for all objects placed by players.

			for(var/obj/Turfs/Edges/B in T) if(!B.Builder) del(B)
			for(var/obj/Turfs/Surf/B in T) if(!B.Builder) del(B)
			for(var/obj/Turfs/Trees/B in T) if(!B.Builder) del(B)
			for(var/obj/Turfs/B in T) if(!B.Builder) del(B)

			if(Amount == 20000)
				sleep(1)
				break

		if(Amount == 20000)
			E ++
			goto load

		end
		world<<"<small>Server: Map Loaded ([DebugAmount] in [E] Files.)"
//	spawn()SpawnMaterial()





var/list/Builds=new // Builds is a list used to display icons in the buildpanel for players. This is NOT the things they have already built!
var/list/AdminBuilds=new //This is for /turf/Special, which is (normally) admin accessable only.
proc/Add_Builds()
	var/obj/Turfs/CustomObj1/customobj = new
	var/obj/Others/Build/E = new
	E.icon = customobj.icon
	E.icon_state = customobj.icon_state
	E.Creates = customobj.type
	E.name ="-[customobj.name]-"
	Builds += E
	var/turf/CustomTurf/customturf = new(locate(1,1,1))
	var/obj/Others/Build/J = new
	J.icon = customturf.icon
	J.icon_state = customturf.icon_state
	J.Creates = customturf.type
	J.name ="-[customturf.name]-"
	Builds += J
	for(var/A in subtypesof(/obj/Turfs))
		var/obj/B = new A
		if(B.Buildable&& B.name!="DBR")
			var/obj/Others/Build/C=new
			C.icon=B.icon
			C.icon_state=B.icon_state
			C.Creates=B.type
			C.name="-[B.name]-"
			Builds+=C
	for(var/A in subtypesof(/obj/KatieObj))
		var/obj/B=new A
		var/obj/Others/Build/C=new
		C.icon=B.icon
		C.icon_state=B.icon_state
		C.Creates=B.type
		C.name="-[B.name]-"
		Builds+=C

	for(var/A in subtypesof(/turf))
		var/turf/C=new A(locate(1,1,1))
		if(C.Buildable && C.name!="DBR")

			var/obj/Others/Build/B=new
			B.icon=C.icon
			B.icon_state=C.icon_state
			B.Creates=C.type
			B.name="-[C.name]-"
			Builds+=B
		del(C)

/obj/Turfs/Newturfs
	Industrial
		name = "Industrial"
		icon = 'Mapping/NewIcons/Industrial.dmi'
	IndustrialBridge
		name = "Industrial Bridge"
		icon = 'Mapping/NewIcons/IndustrialBridge.dmi'
	IndustrialFences
		name = "Industrial Fences"
		icon = 'Mapping/NewIcons/IndustrialFences.dmi'
	IndustrialHouses
		name = "Industrial Houses"
		icon = 'Mapping/NewIcons/IndustrialHouses.dmi'
	IndustrialRoad
		name = "Industrial Road"
		icon = 'Mapping/NewIcons/IndustrialRoad.dmi'
	IndustrialProps
		name = "Industrial Props"
		icon = 'Mapping/NewIcons/IndustrialProps.dmi'
	IndustrialShops
		name = "Industrial Shops"
		icon = 'Mapping/NewIcons/IndustrialShops.dmi'
	IndustrialWall
		name = "Industrial Wall"
		icon = 'Mapping/NewIcons/IndustrialWall.dmi'




obj/Others/Build
	var/Creates
	var/Temp//if this is flagged, deletes the object when target switches
	verb/IndoorOutdoorToggle()
		set src in world
		if(usr.Inside==0)
			usr.Inside=1
			usr<<"You will now build 'inside' turfs that will not be affected by weather."
		else if(usr.Inside==1)
			usr.Inside=0
			usr<<"You will now build 'outside' turfs that will be affected by weather."
	verb/ShallowToggle()
		set src in world
		if(usr.ShallowMode==0)
			usr.ShallowMode=1
			usr<<"You will now build 'shallow' water that will not drain your energy when entered."
		else if(usr.ShallowMode==1)
			usr.ShallowMode=0
			usr<<"You will now build water tiles that drain your energy when entered."
	verb/UnderwaterToggle()
		set src in world
		if(usr.UnderwaterMode==0)
			usr.UnderwaterMode=1
			usr<<"You will now build Underwater tiles if on the proper Z plane."
		else if(usr.UnderwaterMode==1)
			usr.UnderwaterMode=0
			usr<<"You will now build Underground tiles if on the proper Z plane."


	Click()
		if(!usr.BuildGiven&&!usr.Mapper&&!usr.Admin)
			usr<<"The Build verb has yet to be enabled for you. Unlock Fly to proceed."
			return
		if(istype(src,/turf/IconsX/Icon59))
			return
		if(usr.Target==src)
			for(var/sb in usr.SlotlessBuffs)
				var/obj/Skills/Buffs/b = usr.SlotlessBuffs[sb]
				if(b)
					if(b.TargetOverlay)
						var/image/im=image(icon=b.TargetOverlay, pixel_x=b.TargetOverlayX, pixel_y=b.TargetOverlayY)
						im.transform*=b.OverlaySize
						usr.overlays-=im
						if(usr.Target)
							usr.Target.overlays-=im
			if(usr.SpecialBuff)
				if(usr.SpecialBuff.BuffName=="Kyoukaken")
					usr.Kyoukaken("Off")
			usr<<"You have deselected [src]"
			usr.RemoveTarget()
			return
		if(usr.Target!=src)
			for(var/sb in usr.SlotlessBuffs)
				var/obj/Skills/Buffs/b = usr.SlotlessBuffs[sb]
				if(b)
					if(b.TargetOverlay)
						var/image/im=image(icon=b.TargetOverlay, pixel_x=b.TargetOverlayX, pixel_y=b.TargetOverlayY)
						im.transform*=b.OverlaySize
						usr.overlays-=im
						if(usr.Target)
							usr.Target.overlays-=im
			if(usr.SpecialBuff)
				if(usr.SpecialBuff.BuffName=="Kyoukaken")
					usr.Kyoukaken("Off")
			if(istype(usr.Target, /obj/Others/Build))
				var/obj/Others/Build/B=usr.Target
				if(B.Temp)
					del usr.Target
			usr.RemoveTarget()
			usr.Target=src
			usr<<"You have selected [src]"
			usr.AdaptationCounter=0
			usr.AdaptationTarget=null
			usr.AdaptationAnnounce=null


/proc/makeNewBuildObj(obj/objInQuestion)
	var/obj/Others/Build/B=new
	B.icon= objInQuestion.icon
	B.icon_state=objInQuestion.icon_state
	B.density = objInQuestion.density
	B.Creates=objInQuestion.type
	B.name="-[objInQuestion.name]-"
	return B

/*
atom/Click(atom/T)
	if(usr.client.macros.IsPressed("Ctrl"))
		if(!usr.Mapper)
			return
		usr.Target = makeNewBuildObj(T)
		usr<<"You have selected [T] to build."
	else
		if(T)
			if(usr.Target&&istype(usr.Target,/obj/Others/Build))
				if(!istype(T,/obj/SkillTreeObj))
					Build_Lay(usr.Target,usr, T.x, T.y, T.z)
atom/MouseDrag(atom/T)
	//Checks to see if it's in the previous build coordinates. This stops mass building.
	if(T)
		if(T.x != usr.buildPreviousX || T.y != usr.buildPreviousY || T.z != usr.buildPreviousZ)
			if(usr.Target&&istype(usr.Target,/obj/Others/Build))
				Build_Lay(usr.Target,usr, T.x, T.y, T.z)
*/
mob/var/buildPreviousX = 0
mob/var/buildPreviousY = 0
mob/var/buildPreviousZ = 0


proc/Build_Lay(obj/Others/Build/O,mob/P, var/tmpX, var/tmpY, var/tmpZ)
	if(!P.Admin&&!P.Mapper)
		if(tmpX>0||tmpY>0||tmpZ>0)
			return//no clicky for the common man
	var/mob/L=P
	var/atom/C
	if(tmpX > 0 || tmpY> 0 || tmpZ> 0)
		P.buildPreviousX = tmpX
		P.buildPreviousY = tmpY
		P.buildPreviousZ = tmpZ
		C=new O.Creates(locate(tmpX,tmpY,tmpZ))
	else
		C=new O.Creates(locate(L.x,L.y,L.z))
	C.Builder=P.ckey
	if(P.UnFlyable)
		C.FlyOverAble=FALSE
		C.density = TRUE
	else
		C.FlyOverAble=1
	if(L.MakeUngrabbable)
		C.Grabbable=0
/*	if(istype(C,/obj/Turfs/Door))
		C.Password=input(P,"Enter a password or leave blank") as text
		if(!C) return
		if(C.Password) if(isobj(C)) C.Grabbable=0*/
	if(istype(C,/obj/Turfs/Sign)) C.desc=input(P,"What do you want to write on the sign?") as message
	if(istype(C,/turf/Special/EventStars))
		C.icon_state="[rand(1,2500)]"
	if(usr.TurfInvincible)
		C:Destructable=0
	else
		C:Destructable=1
	if(!isturf(C))
		C.Savable=1
		worldObjectList+=C
		if(istype(C,/obj/Turfs/CustomObj1))
			var/obj/Turfs/CustomObj1/customObj=C
			if(usr.useCustomObjSettings)
				if(P.CustomObj1Icon)
					customObj.icon=P.CustomObj1Icon
				else
					customObj.icon=O.icon
				if(P.CustomObj1State)
					customObj.icon_state=P.CustomObj1State
				else
					customObj.icon_state=O.icon_state
				if(P.CustomObj1Layer)
					customObj.layer=P.CustomObj1Layer
				else
					C.layer=O.layer
				if(P.CustomObj1Density)
					customObj.density=P.CustomObj1Density
				else
					customObj.density=O.density
				if(P.CustomObj1Opacity)
					customObj.opacity=P.CustomObj1Opacity
				else
					customObj.opacity=O.opacity
				if(P.CustomObj1X)
					customObj.pixel_x=P.CustomObj1X
				else
					customObj.pixel_x=O.pixel_x
				if(P.CustomObj1Y)
					customObj.pixel_y=P.CustomObj1Y
				else
					customObj.pixel_y=O.pixel_y
				if(P.CustomObjEdge)
					customObj.edge=P.CustomObjEdge
				else
					if(istype(O,/obj/Turfs/CustomObj1))
						var/obj/Turfs/CustomObj1/CT=O
						customObj.edge=CT.edge
			else
				customObj.icon=O.icon
				customObj.icon_state=O.icon_state
				customObj.layer=O.layer
				customObj.density=O.density
				customObj.opacity=O.opacity
				customObj.pixel_x=O.pixel_x
				customObj.pixel_y=O.pixel_y
				if(istype(O,/obj/Turfs/CustomObj1))
					var/obj/Turfs/CustomObj1/CT=O
					customObj.edge=CT.edge
		else
			C.icon_state = O.icon_state

	else
		C.Savable=0
		var/turf/_turf=C
		var/turf/CustomTurf/CT=C
		if(istype(C,/turf/CustomTurf))
			C?:InitialType = "/turf/CustomTurf"
			if(usr.useCustomTurfSettings)
				if(usr.CustomTurfIcon)
					CT.icon = usr.CustomTurfIcon
				else
					CT.icon = O.icon
				if(usr.CustomTurfState)
					CT.icon_state = usr.CustomTurfState
				else
					C.icon_state = O.icon_state
				if(usr.CustomTurfRoof)
					CT.Roof = usr.CustomTurfRoof
				if(usr.CustomTurfDensity)
					CT.density = usr.CustomTurfDensity
				else
					CT.density = O.density
				if(usr.CustomTurfOpacity)
					CT.opacity = usr.CustomTurfOpacity
				else
					CT.opacity = O.opacity
			else
				CT.icon = O.icon
				CT.icon_state = O.icon_state
				CT.Roof = usr.CustomTurfRoof
				CT.density = O.density
				CT.opacity = O.opacity
		if(P.ShallowMode==1)
			_turf.Shallow=1
		if(P.BuildOverwrite)
			for(var/obj/Turfs/E in C)
				if(!istype(E, /obj/Special/Teleporter2))
					del(E)
			for(var/obj/KatieObj/E in C)
				del(E)
		if(P.WarperOverwrite)
			for(var/obj/Special/Teleporter2/q in C)
				del(q)
		if(!istype(C,/turf/CustomTurf))
			Turfs+=C
		else
			CustomTurfs+=CT

obj/var
	Saved_X
	Saved_Y
	Saved_Z

proc/Save_Objects()
	set background = 1
	world<<"<small>Server: Saving Objects..."
	var/Amount=0
	var/E=1
	var/savefile/F=new("Saves/Itemsave/File[E]")
	var/list/Types=new
	for(var/obj/A in global.worldObjectList)
		if(!A)
			world.log << "null entry"
			continue
		if(A.Savable&&A.z)
			A.Saved_X=A.x
			A.Saved_Y=A.y
			A.Saved_Z=A.z
			Types+=A
			Amount+=1
			if(Amount % 500 == 0)
				F["Types"]<<Types
				E++
				F=new("Saves/Itemsave/File[E]")
				Types=new
	if(Amount % 500 != 0)
		F["Types"]<<Types
	hacklol
	if(fexists("Saves/Itemsave/File[E++]"))
		fdel("Saves/Itemsave/File[E++]")
		world<<"<small>Server: Objects DEBUG system check: extra objects file ([E++]) deleted!"
		E++
		goto hacklol
	world<<"<small>Server: Objects Saved ([Amount])."

proc/Load_Objects()
	world<<"<small>Server: Loading Items..."
	var/amount=0
	var/filenum=0
	wowza
	filenum++
	if(fexists("Saves/Itemsave/File[filenum]"))
		var/savefile/F=new("Saves/Itemsave/File[filenum]")
		var/list/L=new
		if(length(F["Types"]) < 1)
			goto wowza
		F["Types"]>>L
		for(var/obj/A in L)
			if(!A)
				world.log << "[A] is null"
				world.log << "[amount] index"
				continue
			amount+=1
			A.loc=locate(A.Saved_X,A.Saved_Y,A.Saved_Z)
		goto wowza
	world<<"<small>Server: Items Loaded ([amount])."
//	spawn()SpawnMaterial()