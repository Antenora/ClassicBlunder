var/list/ritualDatabase = list()
proc/initRitualDatabase()
	for(var/r in subtypesof(/ritual/))
		var/ritual/ritual = new r
		ritualDatabase += ritual

ritual
	var/name = "Base Ritual"
	var/list/components = list()
	var/list/consumedComponents = list()
	var/manaCost = 100
	var/fragmentCost = 0
	var/list/associatedKnowledges = list()

	proc/checkComponents(obj/Magic_Circle/circle)
		var/componentsFound = 0
		if(length(components) == 0)
			return 0
		for(var/atom/i in range(1, circle))
			if(i.type in components)
				componentsFound += 1
		return componentsFound
	
	proc/checkKnowledges(mob/p)
		var/checkedKnowledges = 0
		if(length(associatedKnowledges) == 0)
			return 0
		for(var/k in associatedKnowledges)
			if(k in p.knowledgeTracker.learnedMagic)
				checkedKnowledges += 1
		return checkedKnowledges

	proc/checkFragmentCost(obj/Magic_Circle/circle)
		var/fragmentsFound = 0
		if(fragmentCost == 0)
			return 1
		for(var/atom/i in range(1, circle))
			if(istype(i, /obj/Items/mineral))
				var/obj/Items/mineral/mineral = i
				fragmentsFound += mineral.value
		if(fragmentsFound >= fragmentCost)
			return 1
		return 0

	proc/takeFragmentCost(obj/Magic_Circle/circle)
		var/fragmentsFound = 0
		for(var/atom/i in range(1, circle))
			if(istype(i,/obj/Items/mineral))
				var/obj/Items/mineral/mineral = i
				fragmentsFound += mineral.value
				mineral.Reduce(fragmentCost)
				if(fragmentsFound >= fragmentCost)
					return

	proc/checkRitualRequirements(obj/Magic_Circle/circle, mob/p)
		if(checkManaCost(circle, p) && checkComponents(circle) == length(components) && checkKnowledges(p) == length(associatedKnowledges) && checkFragmentCost(circle))
			return 1
		return 0
	
	proc/checkManaCost(obj/Magic_Circle/circle, mob/p)
		var/ManaTotal = 0
		for(var/obj/Items/Enchantment/PhilosopherStone/PS in oview(1,circle))
			ManaTotal += PS.CurrentCapacity
		if(p.HasManaCapacity(max(0,manaCost-ManaTotal), TRUE))
			return 1
		return 0

	proc/takeManaCost(obj/Magic_Circle/circle, mob/p)
		var/remainingManaCost = manaCost
		for(var/obj/Items/Enchantment/PhilosopherStone/PS in oview(1,circle))
			if(remainingManaCost==PS.CurrentCapacity)
				remainingManaCost=0
				PS.CurrentCapacity=0
			else if(remainingManaCost>PS.CurrentCapacity)
				remainingManaCost-=PS.CurrentCapacity
				PS.CurrentCapacity=0
			else if(PS.CurrentCapacity>remainingManaCost)
				PS.CurrentCapacity-=remainingManaCost
				remainingManaCost=0
		if(remainingManaCost>0)
			p.TakeManaCapacity(remainingManaCost, TRUE)

	proc/takeRitualComponents(obj/Magic_Circle/circle, mob/p)
		for(var/atom/i in checkComponents(circle))
			if(i.type in consumedComponents)
				del i

	proc/performRitual(obj/Magic_Circle/circle, mob/p)
		if(checkRitualRequirements(circle, p))
			// Visual effects for spinning and lightning
			spawn(0)
				var/spin_duration = 50 // 5 seconds at 10 ticks per second
				var/angle_step = 360 / spin_duration
				for(var/i = 1 to spin_duration)
					circle.transform = turn(circle.transform, angle_step) // Rotate the circle

			// Disintegrate components and fragments
			for(var/atom/i in checkComponents(circle))
				if(i.type in consumedComponents)
					createDisintegrationEffect(i) // Create disintegration effect
					sleep(10) // Wait for the disintegration effect

			takeManaCost(circle, p)
			takeRitualComponents(circle, p)
			takeFragmentCost(circle)
			ritualEffect(circle, p)
	
	proc/ritualEffect(obj/Magic_Circle/circle, mob/p)
		return

	Sword_Enchanting
		name = "Sword Enchanting"
		components = list(/obj/Items/Sword)
		fragmentCost = 1000

		ritualEffect(obj/Magic_Circle/circle, mob/p)
			for(var/obj/Items/Sword/sword in oview(1,circle))
				sword.Ascended++
				break

proc/createDisintegrationEffect(atom/movable/component)
	component.particles = new/particles(
			icon = component.icon,
			icon_state = component.icon_state,
			duration = 10,
			fade = 1,
			alpha = 255,
			alpha_step = -25.5, // Gradually reduce alpha to 0 over 10 ticks
			size = 32,
			x = 0,
			y = 0
		)