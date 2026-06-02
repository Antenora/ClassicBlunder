mob/var/tmp/StarCrossed = FALSE
mob/var/tmp/StarCrossedX
mob/var/tmp/StarCrossedY
mob/var/tmp/StarCrossedZ

mob/proc/applyStarCrossed()
	if(!StarCrossed || !StarCrossedX || !StarCrossedY || !StarCrossedZ) return
	StarCrossed = FALSE
	if(isturf(loc))
		var/image/starcross = image('Icons/Effects/BlackHoleEnter.dmi')
		loc:overlays += starcross
		spawn(8)
			del starcross
	loc = locate(StarCrossedX, StarCrossedY, StarCrossedZ)
	if(isturf(loc))
		var/image/starcross = image('Icons/Effects/BlackHoleExit.dmi')
		loc:overlays += starcross
		spawn(8)
			del starcross