/obj/LifeSkills/Station/Cauldron
	name = "Cauldron"
	icon = 'Icons/LifeSkills/Forge.dmi'
	icon_state = "forge"
	desc = "A working forge. Face it and press your Interact key to smelt ore."
	Click()
		if(!usr) return
		if(get_dist(usr, src) > 1)
			usr << "You need to get closer to the forge."
			return
		usr.OpenSmelting(src)
	InteractWith(mob/M)
		if(get_dist(M, src) > 1) return 0
		M.OpenSmelting(src)
		return 1