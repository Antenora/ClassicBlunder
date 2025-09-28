globalTracker/var/TRACKING_BURNING = FALSE
globalTracker/var/TRACKING_POISON = FALSE
mob/var/currentBurn = 0
mob/var/currentPoi = 0 

/mob/Admin4/verb/fillTension()
	set category = "Debug"
	Tension = 100
/mob/Admin3/verb/Admin_Screen_Size()
	set category="Other"
	set hidden=1
	if(!(world.time > usr.verb_delay)) return
	usr.verb_delay=world.time+1
	var/screenx=input("Enter the width of the screen, max is 999.") as num
	screenx=min(max(1,screenx),999)
	var/screeny=input("Enter the height of the screen, max is 999.") as num
	screeny=min(max(1,screeny),999)
	client.view="[screenx]x[screeny]"
	src.ScreenSize = "[screenx]x[screeny]"


/mob/Admin3/verb/trackburning()
	set category = "Debug"
	glob.TRACKING_BURNING = !glob.TRACKING_BURNING
	if(!glob.TRACKING_BURNING)
		currentBurn = 0

/mob/Admin3/verb/trackpoison()
	set category = "Debug"
	glob.TRACKING_POISON = !glob.TRACKING_POISON
	if(!glob.TRACKING_POISON)
		currentPoi = 0