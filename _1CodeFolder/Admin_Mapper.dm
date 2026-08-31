/mob/Admin3/verb/ADMINSetallRoofsToDense()
	set category="Mapper"
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
		MapperSight
		MapperWalk
		MapperWaterWalk = FALSE
		BuildOverwrite=0
		WarperOverwrite=0
		Bino=0
		useCustomObjSettings = FALSE
		useCustomTurfSettings = FALSE
	Mapper
		verb/Make_All_Objs_Ungrabable()
			for(var/obj/Turfs/CustomObj1/cObj in world)
				if(cObj.Builder == src.ckey)
					cObj.Grabbable = 0
			src<<"All your CUSTOM objects are now ungrabable."
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
		verb/Mapper_Fade(atom/A in world)
			set name="Mapper Fade Visibility"
			set category="Mapper"
			if(istype(A, /mob)||istype(A, /area))
				src << "Nah."
				return
			var/opacityGoal=input("Final Opacity (0 to 255)","[src]") as num
			var/timeGoal=input("Fade Time (in ticks)","[src]") as num
			animate(A, alpha = opacityGoal, time = timeGoal)

		verb/ToggleBuildMode()
			set category = "Mapper"
			client.BuildSessionToggle()
