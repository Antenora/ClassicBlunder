/mob/Admin3/verb/ADMINSetallRoofsToDense()
	for(var/turf/CustomTurf/T in world)
		if(T.Roof)
			T.FlyOverAble = FALSE
		else
			T.FlyOverAble = TRUE

/mob/Mapper/verb/SetallRoofsToDense()
	for(var/turf/CustomTurf/T in world)
		if(T.Builder == src.ckey)
			if(T.Roof)
				T.FlyOverAble = FALSE
			else
				T.FlyOverAble = TRUE

mob
	var
		tmp/Mapper=0
		MapperSight//Flagged by mapper sight duh
		MapperWalk
		MapperWaterWalk = FALSE
		BuildOverwrite=0
		WarperOverwrite=0
		Bino=0
		useCustomObjSettings = FALSE
		useCustomTurfSettings = FALSE
	Mapper
		verb/useCustomObjSettings()
			set category = "Mapper"
			if(usr.useCustomObjSettings == 0)
				usr.useCustomObjSettings = 1
				usr<<"You will now use custom object settings."
			else if(usr.useCustomObjSettings == 1)
				usr.useCustomObjSettings = 0
				usr<<"You will now NOT use default object settings."
		verb/useCustomTurfSettings()
			set category = "Mapper"
			if(usr.useCustomTurfSettings == 0)
				usr.useCustomTurfSettings = 1
				usr<<"You will now use custom turf settings."
			else if(usr.useCustomTurfSettings == 1)
				usr.useCustomTurfSettings = 0
				usr<<"You will now NOT use default turf settings."
		verb/customObjSettings()
			set category = "Mapper"
			var/list/options = list("Icon", "Icon State", "Opacity", "Density", "Edge", "Layer", "Pixel X", "Pixel Y")
			var/option = input("What setting would you like to change?", "Custom Object Settings") in options
			if(option=="Icon")
				var/selectedicon = input("What icon would you like to set?", "Custom Object Settings") as icon|null
				if(!selectedicon)
					return
				CustomObj1Icon = selectedicon
			if(option=="Icon State")
				var/selectediconstate = input("What icon state would you like to set? Currently [CustomObj1State]", "Custom Object Settings") as text|null
				if(!selectediconstate)
					return
				CustomObj1State = selectediconstate
			if(option=="Opacity")
				var/selectedopacity = input("Opacity?", "Custom Object Settings") in list(TRUE, FALSE)
				CustomObj1Opacity = selectedopacity
			if(option=="Density")
				var/selecteddensity = input("Density?", "Custom Object Settings") in list(TRUE, FALSE)
				CustomObj1Density = selecteddensity
			if(option == "Edge")
				var/selectededge = input("Would you like to set this as a edge?", "Custom Object Settings") in list(TRUE, FALSE)
				CustomObjEdge = selectededge
			if(option == "Layer")
				var/selectedlayer = input("Layer? Currently [CustomObj1Layer]", "Custom Object Settings") as num|null
				if(!selectedlayer) return
				CustomObj1Layer = selectedlayer
			if(option=="Pixel X")
				var/selectedpixelx = input("Pixel X?", "Custom Object Settings") as num|null
				if(!selectedpixelx)
					return
				CustomObj1X = selectedpixelx
			if(option == "Pixel Y")
				var/selectedpixely = input("Pixel Y?", "Custom Object Settings") as num|null
				if(!selectedpixely)
					return
				CustomObj1Y = selectedpixely
		verb/customTurfSettings()
			set category = "Mapper"
			var/list/options = list("Icon", "Icon State", "Opacity", "Density", "Roof")
			var/option = input("What setting would you like to change?", "Custom Turf Settings") in options
			if(option=="Icon")
				var/selectedicon = input("What icon would you like to set?", "Custom Turf Settings") as icon|null
				if(!selectedicon)
					return
				CustomTurfIcon = selectedicon
			if(option=="Icon State")
				var/selectediconstate = input("What icon state would you like to set? Currently [CustomTurfState]", "Custom Turf Settings") as text|null
				if(!selectediconstate)
					return
				CustomTurfState = selectediconstate
			if(option=="Opacity")
				var/selectedopacity = input("Opacity?", "Custom Turf Settings") in list(TRUE, FALSE)
				CustomTurfOpacity = selectedopacity
			if(option=="Density")
				var/selecteddensity = input("Density?", "Custom Turf Settings") in list(TRUE, FALSE)
				CustomTurfDensity = selecteddensity
			if(option == "Roof")
				var/selectedroof = input("Would you like to set this as a roof?", "Custom Turf Settings") in list(TRUE, FALSE)
				CustomTurfRoof = selectedroof

		verb/Build()
			set category="Mapper"
			usr.Grid("Turfs")
		verb/Make_All_Objs_Ungrabable()
			for(var/obj/Turfs/CustomObj1/cObj in world)
				if(cObj.Builder == src.ckey)
					cObj.Grabbable = 0
			src<<"All your CUSTOM objects are now ungrabable."
		verb/Mapper_Binoculars()
			set category="Mapper"
			if(Bino==0)
				usr.client.view="69x69"
				usr.Bino=1
			else
				usr.client.view="17x17"
				usr.Bino=0
		verb/Mapper_Delete(var/obj/o in view(10, usr))
			set category="Mapper"
			set name="Mapper Delete"
			if(!istype(o, /obj/Turfs) && !istype(o, /obj/KatieObj))
				return
			if(istype(o, /obj/Items/Tech/Door))
				if(o.Builder!=usr.ckey)
					return
			Log("Admin", "[ExtractInfo(usr)] deleted [o] ([o.type]).")
			del o
		verb/Build_Overwrite_Toggle()
			set category="Mapper"
			if(usr.BuildOverwrite)
				usr.BuildOverwrite=0
				usr << "You will <font color='red'>NOT</font color> delete objects by placing turfs on them."
			else
				usr.BuildOverwrite=1
				usr << "You <font color='green'>WILL</font color> delete objects by placing turfs on them."
		verb/Warper_Overwrite_Toggle()
			set category="Mapper"
			if(usr.WarperOverwrite)
				usr.WarperOverwrite=0
				usr << "You will <font color='red'>NOT</font color> delete warpers by placing turfs on them."
			else
				usr.WarperOverwrite=1
				usr << "You <font color='green'>WILL</font color> delete warpers by placing turfs on them."
		verb/Mapper_Edit(atom/A in world)
			set name="Mapper Edit"
			set category="Mapper"
			if(istype(A, /mob)||istype(A, /area))
				src << "Nah."
				return
			var/Edit="<html><Edit><body bgcolor=#000000 text=#339999 link=#99FFFF>"
			var/list/B=new
			Edit+="[A]<br>[A.type]"
			Edit+="<table width=10%>"
			B.Add("mouse_opacity","pixel_x", "pixel_y", "layer", "density", "alpha", "icon", "icon_state", "invisibility", "opacity")
			if(isobj(A))
				B.Add("Grabbable")
			if(A.type==/obj/Special/Teleporter2)
				B.Add("gotoX", "gotoY", "gotoZ")
			for(var/C in B)
				Edit+="<td><a href=byond://?src=\ref[A];action=edit;var=[C]>"
				Edit+=C
				Edit+="<td>[Value(A.vars[C])]</td></tr>"
			usr << "</html>"
			usr<<browse(Edit,"window=[A];size=450x600")
		verb/XYZ_Teleport()
			set category="Mapper"
			var/x=input("x","[src]") as num
			var/y=input("y","[src]") as num
			var/z=input("z","[src]") as num
			usr.loc=locate(x,y,z)
			Log("Admin","[ExtractInfo(src)] teleported to [x],[y],[z].")
		verb/Make_Warper()
			set category="Mapper"
			var/_x=input("Where does this lead? x", "Make Warper") as num
			var/_y=input("Where does this lead? y", "Make Warper") as num
			var/_z=input("Where does this lead? z", "Make Warper") as num
			usr.MakeWarper(_x,_y,_z)
		verb/Mapper_Sight()
			set category="Mapper"
			if(!src.MapperSight)
				usr.sight |= SEE_THRU
				usr.MapperSight=1
				usr << "You turn on your Mapper Sight."
			else
				usr.sight=null
				usr.MapperSight=0
				usr << "You turn off your Mapper Sight."
		verb/Mapper_Walk()
			set category="Mapper"
			if(!src.MapperWalk)
				usr.MapperWalk=1
				usr << "You turn on your Mapper Walk."
			else
				usr.MapperWalk=0
				usr << "You turn off your Mapper Walk."

		verb/changeHudScale()
			set category = "Mapper"

			var/x = input("What scale for mapping tool HUD?", "Mapping HUD Scale") as num
			x = clamp(x,0.25,5)
			client.hudScale = x
			client.ClearHUD()
			GenerateHUD()

		verb/ToggleBuildMode()
			set category = "Mapper"
			client.BuildModeToggle()

		verb/Toggle_Turf_Indestructable()
			set category="Mapper"
			if(!usr.TurfInvincible)
				usr.TurfInvincible=1
				usr << "You turn your indestructable turfs <font color='green'>ON</font color>."
			else
				usr.TurfInvincible=0
				usr << "You turn your indestructable turfs <font color='red'>OFF</font color>."
		verb/ToggleUngrabbable()
			set category="Mapper"
			if(src.MakeUngrabbable)
				src << "You will now <font color='red'>NOT</font color> make objects ungrabbable by default."
				src.MakeUngrabbable=0
			else
				src << "You will now <font color='green'>MAKE</font color> objects ungrabbable by default."
				src.MakeUngrabbable=1
		verb/Toggle_Fly_Over()
			set category="Mapper"
			if(!usr.IgnoreFlyOver)
				usr.IgnoreFlyOver=1
				usr << "You turn your fly through <font color='green'>ON</font color>."
			else
				usr.IgnoreFlyOver=0
				usr << "You turn your fly through <font color='red'>OFF</font color>."
		verb/Toggle_Waterwalk()
			set category="Mapper"
			if(!usr.MapperWaterWalk)
				usr.passive_handler.Increase("WaterWalk")
				MapperWaterWalk = TRUE
				usr << "You turn your water walking <font color='green'>ON</font color>."
			else
				usr.passive_handler.Decrease("WaterWalk")
				MapperWaterWalk = FALSE
				usr << "You turn your water walking <font color='red'>OFF</font color>."
		verb/Invisible_Toggle()
			set category="Mapper"
			if(usr.AdminInviso)
				usr<<"<font color='red'>You are no longer invisible.</font color>"
				usr.AdminInviso=0
				usr.invisibility=0
				usr.see_invisible=0
				animate(usr, alpha=255, time=10)
			else
				usr<<"<font color=green>You are now invisible.</font color>"
				usr.AdminInviso=1
				usr.invisibility=85
				usr.see_invisible=86
				animate(usr, alpha=50, time=10)
		verb/ToggleUnFlyable()
			set category="Mapper"
			if(src.UnFlyable)
				src.UnFlyable=0
				src << "You will now <font color='green'>NOT</font color> make turfs unflyable by default."
			else
				src.UnFlyable=1
				src << "You will now <font color='red'>MAKE</font color> turfs unflyable by default."
