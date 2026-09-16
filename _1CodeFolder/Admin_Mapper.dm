/proc/MapperRoofSweep(mob/M, onlyCkey)
	set waitfor = FALSE
	set background = TRUE
	var/list/snap = CustomTurfs.Copy()
	var/n = 0
	var/hit = 0
	for(var/turf/CustomTurf/T in snap)
		n++
		if(n % 400 == 0)
			sleep(-1)
		if(onlyCkey && T.Builder != onlyCkey)
			continue
		T.FlyOverAble = T.Roof ? FALSE : TRUE
		hit++
	M << "Roof pass done: [hit] custom turfs updated."

/mob/Admin3/verb/ADMINSetallRoofsToDense()
	set category="Mapper"
	MapperRoofSweep(usr, null)

/mob/Mapper/verb/SetallRoofsToDense()
	set category="Mapper"
	MapperRoofSweep(usr, usr.ckey)

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
		verb/Mapper_Edit()
			set name="Mapper Edit"
			set category="Mapper"
			var/atom/A = PromptVerbAtom(usr, args, "Mapper Edit")
			if(!A)
				return
			if(istype(A, /mob)||istype(A, /area))
				src << "Nah."
				return
			var/list/B=new
			B.Add("mouse_opacity","pixel_x", "pixel_y", "layer", "density", "alpha", "icon", "icon_state", "invisibility", "opacity")
			if(isobj(A))
				B.Add("Grabbable")
			if(A.type==/obj/Special/Teleporter2)
				B.Add("gotoX", "gotoY", "gotoZ")
			usr.client?.SheetShow("edit:\ref[A]", "EDIT", "[A]", "[A.type]", SheetVarRows(A, B, null, 0), "a name to edit")
		verb/Mapper_Fade()
			set name="Mapper Fade Visibility"
			set category="Mapper"
			var/atom/A = PromptVerbAtom(usr, args, "Mapper Fade Visibility")
			if(!A)
				return
			if(istype(A, /mob)||istype(A, /area))
				src << "Nah."
				return
			var/opacityGoal=Ask(usr, "Final Opacity (0 to 255)", "[src]", null, "num", null, 0)
			var/timeGoal=Ask(usr, "Fade Time (in ticks)", "[src]", null, "num", null, 0)
			animate(A, alpha = opacityGoal, time = timeGoal)

		verb/ToggleBuildMode()
			set category = "Mapper"
			client.BuildSessionToggle()
