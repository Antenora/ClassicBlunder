obj/Skills/Feva
	AfterImage

proc
	Jitters(mob/A)
		var/BaseX=A.pixel_x
		var/BaseY=A.pixel_y
		animate(A,pixel_x=BaseX+rand(-4,4),pixel_y=BaseY+rand(-4,4),time=1)
		spawn(1)
			if(prob(70))
				AfterImage(A)
			animate(A,pixel_x=BaseX,pixel_y=BaseY,time=1)