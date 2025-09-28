obj/gold
	icon = 'Goldpile.dmi'
	density = 0
	Destructable = FALSE
	Grabbable = FALSE
	var/tmp/mob/originalOwner
	var/tmp/mob/sourceOfDropping
	var/amount = 0

	proc/createPile(mob/owner, mob/causer, _x,_y,_z, removeOnLeak = FALSE)
		loc = locate(owner.x, owner.y, owner.z)
		alpha = 0
		originalOwner = owner
		sourceOfDropping = causer
		for(var/obj/Money/m in originalOwner)
			amount = rand(1,m.Level/(glob.racials.GAJACASHDROPDIVISOR-(1+causer.AscensionsAcquired * 10)))
			amount = round(amount, 1)
			m.Level -= amount
		if(removeOnLeak)
			del src
		else
			name = "[Commas(amount)] coins!"
			flyingOutAnimation(_x, _y)
			loc = locate(_x, _y, _z)
			pixel_x = 0
			pixel_y = 0
			pixel_z = 0
	Cross(atom/obstacle)
		..()
		if(istype(obstacle, /mob/Players))
			var/mob/Players/p = obstacle
			if(sourceOfDropping == p)
				OMsg(sourceOfDropping, "[sourceOfDropping] steals the lost coinage!")
				for(var/obj/Money/m in sourceOfDropping)
					m.Level += amount
				src.loc = null
				del src
				return TRUE
			else if(p == originalOwner)
				OMsg(p , "[p] picks up their lost coinage!")
				for(var/obj/Money/m in originalOwner)
					m.Level += amount
				src.loc = null
				del src
				return TRUE

	proc/flyingOutAnimation(landingX, landingY)
		// it isn't so much about the x/y it needs to animate and move with like pixel or a matrix ro something
		sleep(1)
		alpha = 155
		var/halfwayX = (landingX-x)/2
		var/halfwayY = (landingY-y)/2
		animate(src, pixel_x = halfwayX*32, pixel_y = halfwayY*32, pixel_z=16, time = 5, easing = SINE_EASING | EASE_IN)
		animate(alpha = 255, time = 3)
		sleep(5)
		animate(src, pixel_x = pixel_x + (halfwayX*32), pixel_y = pixel_y + (halfwayY*32), pixel_z=0, time = 5, easing = BOUNCE_EASING,flags = ANIMATION_END_NOW)
		sleep(5)