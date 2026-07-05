/particles/energy
	icon = 'testElec.dmi'
	icon_state = list("1"=1, "2"=1,"3"=1,"4"=1)
	width = 1000
	height = 1000
	spawning = 3
	count = 1000
	grow = 0.1
	scale = 0.5
	gravity = list(0,2)
	lifespan = 15
	fade = 3
	position = generator("vector", list(0,0), list(0,0))
	friction = 0.1
	drift = generator("box", list(-6, -6), list(6, 6))
	//spin = generator("num", -90,90)
	color = "#57004f"
/particles/energy2
	icon = 'turq_haze.dmi'
	width = 1000
	height = 1000
	spawning = 50
	count = 1500
	grow = 0.2
	scale = 0.3
	gravity = list(0,16)
	lifespan = 64
	fade = 32
	position = generator("vector", list(-64,-40), list(64,-40))
	friction = 0.33
	drift = generator("circle", list(-8, -8), list(8, 8))
	spin = generator("num", -45,45)
	// color = rgb(56, 176, 255, 255)
/obj/emitter
	appearance_flags = PIXEL_SCALE
	layer = FLY_LAYER
	proc/fadeOut()
		animate(src, alpha = 0, time = 10)
	energy
		particles = new/particles/energy
		layer = FLY_LAYER+0.1
	energy2
		layer =FLY_LAYER
		New()
			. = ..()
			filters = list(filter(type="outline", size = 1, flags = OUTLINE_SQUARE, color = rgb(255,255,255)) , \
							filter(type="motion_blur",y = 8/5, x = 8/10))
		particles = new/particles/energy2


/datum/effect
	parent_type = /atom/movable
	var/list/tmp/emitters = list()
	var/tmp/lifespan
	var/tmp/maxLifespan
	var/tmp/mob/source
	New(atom/movable/owner, duration, list/params)
		lifespan = duration
		maxLifespan = duration
		AssignValues(params)
		for(var/obj/emitter/x in emitters)
			if(owner)
				owner.vis_contents+=x
		source = owner
		ticking_generic += src
	proc/AssignValues(list/params)
		for(var/x in emitters[1].particles.vars)
			for(var/y in params)
				if(y == "appearance_flags")
					emitters[1].vars["appearance_flags"] = params["appearance_flags"]
				if(y == x)
					emitters[1].particles.vars[x] = params["[y]"]
	proc/deleteEmitters()
		for(var/obj/emitter/x in emitters)
			if(source)
				source.vis_contents -= x
			del x
		ticking_generic -= src
		del src
	proc/removeEmitters()
		for(var/obj/emitter/x in emitters)
			x.fadeOut()
	Update()
		if(lifespan == maxLifespan/8)
			removeEmitters()
		if(lifespan-- <= 0)
			deleteEmitters()
	Test
		emitters = list(new/obj/emitter/energy)
	Test2
		emitters = list(new/obj/emitter/energy2)

/*
/mob/verb/emit(n as num)
	var/datum/effect/Test2/t2 = new(src,n)
	animate(t2.emitters[1], alpha = 120, time = n / 2)
	sleep(n/2)
	animate(t2.emitters[1], alpha = 0, time = n / 4)
*/