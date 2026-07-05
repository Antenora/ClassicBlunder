obj/SaySpark
	icon='Say Spark.dmi'
	layer=EFFECTS_LAYER
	var/AnimateStuff=1
	New()
		Sparky()
		spawn(25)
			animate(src,alpha=0,time=10)
			spawn(10)
				del src
	proc
		Sparky()
			spawn(1)
				animate(src,pixel_x=rand(-1*AnimateStuff,1*AnimateStuff),pixel_y=rand(0,1*AnimateStuff))
				spawn(1)
					animate(src,pixel_x=0,pixel_y=0)
					Sparky()

mob/proc/Say_Spark(Jumpy=1)
	var/obj/SaySpark/SS=new
	src.vis_contents+=SS
	SS.AnimateStuff=Jumpy


obj/InstinctSpark
	icon='Instinct Spark.dmi'
	layer=EFFECTS_LAYER
	var/AnimateStuff=1
	New()
		Sparky()
		spawn(25)
			animate(src,alpha=0,time=10)
			spawn(10)
				del src
	proc
		Sparky()
			spawn(1)
				animate(src,pixel_x=rand(-1*AnimateStuff,1*AnimateStuff),pixel_y=rand(0,1*AnimateStuff))
				spawn(1)
					animate(src,pixel_x=0,pixel_y=0)
					Sparky()

mob/proc/Instinct_Spark(Jumpy=1)
	var/obj/InstinctSpark/IS=new
	src.vis_contents+=IS
	IS.AnimateStuff=Jumpy
