mob/Players/proc/ExamineInflol(mob/p)
	src.Examine(p)




mob/Click()
	if(usr.client.macros.IsPressed("Alt") && usr.Observing)
		usr?:ExamineInflol(src)
	if(glob.CANT_CLICK_INVS && !usr.Admin)
		if((!glob.ADMIN_INVIS_ONLY && (src.invisibility >= usr)) || src.AdminInviso)
			return
	if(glob.LIMIT_CLICKS && !usr.Admin)
		if((glob.CLICK_SAME_Z_FORCE && src.z != usr.z) || get_dist(src, usr) > glob.MAX_CLICK_DISTANCE)
			usr << "You are either not on the same z, or the person is too far."
			return
	if(usr.Target!=src)
		for(var/sb in usr.SlotlessBuffs)
			var/obj/Skills/Buffs/b = usr.SlotlessBuffs[sb]
			if(b)
				if(b.TargetOverlay)
					var/image/im=image(icon=b.TargetOverlay, pixel_x=b.TargetOverlayX, pixel_y=b.TargetOverlayY)
					im.transform*=b.OverlaySize
					usr.overlays-=im
					if(usr.Target)
						usr.Target.overlays-=im
		if(istype(usr.Target, /obj/Others/Build))
			var/obj/Others/Build/B=usr.Target
			if(B.Temp)
				del usr.Target
		usr.SetTarget(src)
		for(var/sb in usr.SlotlessBuffs)
			var/obj/Skills/Buffs/b = usr.SlotlessBuffs[sb]
			if(b)
				if(b.TargetOverlay)
					var/image/im=image(icon=b.TargetOverlay, pixel_x=b.TargetOverlayX, pixel_y=b.TargetOverlayY)
					im.transform*=b.OverlaySize
					usr.Target.overlays+=im
		usr<<"<font color=green>Now targeting [src]!"
		if(usr!=src)
			if(usr.SpecialBuff)
				if(usr.SpecialBuff.BuffName=="Kyoukaken")
					usr.Kyoukaken("On")
		else
			usr.Kyoukaken("Off")
		usr.AdaptationCounter=0
		usr.AdaptationTarget=null
		usr.AdaptationAnnounce=null
	else
		for(var/sb in usr.SlotlessBuffs)
			var/obj/Skills/Buffs/b = usr.SlotlessBuffs[sb]
			if(b)
				if(b.TargetOverlay)
					var/image/im=image(icon=b.TargetOverlay, pixel_x=b.TargetOverlayX, pixel_y=b.TargetOverlayY)
					im.transform*=b.OverlaySize
					usr.overlays-=im
					if(usr.Target)
						usr.Target.overlays-=im
		usr.RemoveTarget()
		usr<<"<font color=red>Targeting disabled."
		if(usr.SpecialBuff)
			if(usr.SpecialBuff.BuffName=="Kyoukaken")
				usr.Kyoukaken("Off")
		usr.AdaptationCounter=0
		usr.AdaptationTarget=null
		usr.AdaptationAnnounce=null
	..()


mob/proc/TwoWayTelepath(var/mob/who, anon)
	var/blah=input("What do you want to say to [who]?") as text|null
	if(!anon)
		for(var/obj/Skills/Utility/Telepathy/t in src)
			if(t.anonymous)
				anon=1
				break
	if(blah)
		if(who.Secret == "Heavenly Restriction" && who.secretDatum?:hasRestriction("Senses"))
			who << "You feel a faint buzz in your head..."

		Log(who.ChatLog(),"(Telepath from [src] to [who]): [blah]")
		Log(src.ChatLog(),"(Telepath from [src] to [who]): [blah]")
		Log("Telepath","(Telepath from [src] to [who]): [blah]")

		src<< output("<font color=#99FF99><b>(Telepath)</b></font>- To  <a href=?src=\ref[who];action=MasterControl;do=TPM>[who]</a href> :[blah]", "output")
		src<< output("<font color=#99FF99><b>(Telepath)</b></font>- To  <a href=?src=\ref[who];action=MasterControl;do=TPM>[who]</a href> :[blah]", "icchat")

		if(who.HearThoughts)
			if(who.Secret == "Heavenly Restriction" && who.secretDatum?:hasRestriction("Senses"))
				goto HeavenlyRestrictionSKIP
			if(anon)
				who << output("<font color=#6cd2f8><i> A voice in your head says: \"[blah]\"", "output")
				who << output("<font color=#6cd2f8><i> A voice in your head says: \"[blah]\"", "icchat")
			else
				who << output("<font color=#99FF99><b>(Telepath)</b></font>- From  <a href=?src=\ref[src];action=MasterControl;do=TPM>[src]</a href> :[blah]", "output")
				who << output("<font color=#99FF99><b>(Telepath)</b></font>- From  <a href=?src=\ref[src];action=MasterControl;do=TPM>[src]</a href> :[blah]", "icchat")

		HeavenlyRestrictionSKIP

		for(var/mob/Players/m in hearers(25,src))
			if(m.HasTelepathy() && !isRace(SHINJIN))
				if(m.HearThoughts&&src!=m)
					if(anon)
						m << output("<font color=#6cd2f8><i> A voice in your head says: \"[blah]\"", "output")
						m << output("<font color=#6cd2f8><i> A voice in your head says: \"[blah]\"", "icchat")
					else
						m<<output("<font color=#99FF99><b>(Telepath)</b></font>- <a href=?src=\ref[src];action=MasterControl;do=TPM>[src]</a href> To <a href=?src=\ref[who];action=MasterControl;do=TPM>[who]</a href> :[blah]", "output")
						m<<output("<font color=#99FF99><b>(Telepath)</b></font>- <a href=?src=\ref[src];action=MasterControl;do=TPM>[src]</a href> To <a href=?src=\ref[who];action=MasterControl;do=TPM>[who]</a href> :[blah]", "icchat")

						m<< output("<font color=#99FF99><b>(Telepath)</b></font>- From  <a href=?src=\ref[src];action=MasterControl;do=TPM>[src]</a href> :[blah]", "output")
						m<< output("<font color=#99FF99><b>(Telepath)</b></font>- From  <a href=?src=\ref[src];action=MasterControl;do=TPM>[src]</a href> :[blah]", "icchat")


mob/proc/SetTarget(atom/target)
	if(ismob(Target))
		var/mob/m = Target
		m.BeingTargetted -= src
	src.Target=target
	if(ismob(target))
		var/mob/m = target
		if(!IsList(m.BeingTargetted)) m.BeingTargetted = list()
		m.BeingTargetted |= src

mob/proc/RemoveTarget()
	if(Target)
		var/mob/prev_target = Target
		Target=null
		if(ismob(prev_target))
			if(!IsList(prev_target.BeingTargetted)) prev_target.BeingTargetted = list()
			else
				prev_target.BeingTargetted -= src

mob/proc/BreakViewers() //Breaks all observes aswell as target
	if(BeingObserved)
		for(var/mob/p in BeingObserved)
			if(p.Observing >= 2) continue
			Observify(p,p)
			p << "Your view of [src] is suddenly broken!"
	for(var/mob/p in BeingTargetted)
		p.RemoveTarget()

proc/Observify(mob/P,atom/A)
	if(P.client.perspective==MOB_PERSPECTIVE)
		P.client.perspective=EYE_PERSPECTIVE
	if(P.Observing)
		for(var/mob/m in players)
			if(m.BeingObserved.len>0)
				if(P in m.BeingObserved)
					m.BeingObserved.Remove(P)
	if(A!=P)
		if(istype(A, /mob))
			A:BeingObserved.Add(P)
		P.client.eye=A
	else if(P==A)
		if(P.client.perspective==EYE_PERSPECTIVE)
			P.client.perspective=MOB_PERSPECTIVE
		P.client.eye=P


proc/Purge_Old_Saves() for(var/File in flist("Saves/"))
	var/savefile/F=new("Saves/Players/[File]")
	if(F["Last_Used"]<=world.realtime-864000*7)
		fdel("Saves/Players/[File]")

proc/Players_In_Range(atom/A,Range)
	var/Start_X=A.x-Range
	var/Start_Y=A.y-Range
	var/End_X=A.x+Range
	var/End_Y=A.y+Range
	if(Start_X<1) Start_X=1
	if(Start_Y<1) Start_Y=1
	if(End_X>world.maxx) Start_X=world.maxx
	if(End_Y>world.maxy) Start_Y=world.maxy
	var/list/Mobs=new
	for(var/mob/Players/P) if(P.z==A.z&&P.x>=Start_X&&P.x<=End_X&&P.y>=Start_Y&&P.y<=End_Y) Mobs+=P
	return Mobs

proc/Turf_Range(atom/A,Distance)
	var/list/Turfs=new
	var/Start=locate(A.x-Distance,A.y-Distance,A.z)
	var/End=locate(A.x+Distance,A.y+Distance,A.z)
	for(var/turf/Turf in block(Start,End)) Turfs+=Turf
	return Turfs

proc/Turf_Circle(turf/center,radius)
	. = list()
	while(center&&!isturf(center)) center=center.loc
	if(!center) return list()
	var/x=center.x,y=center.y,z=center.z
	var/dx,dy,rsq
	var/x1,x2,y1,y2
	rsq=radius*(radius+1)
	for(dy=0,dy<=radius,++dy)
		dx=round(sqrt(rsq-dy*dy))
		y1=y-dy
		y2=y+dy
		x1=max(x-dx,1)
		x2=min(x+dx,world.maxx)
		if(x1>x2) continue  // this should never happen, but just in case...
		if(y1>0&&y1!=y)
			. +=block(locate(x1,y1,z),locate(x2,y1,z))
		if(y2 <= world.maxy)
			. +=block(locate(x1,y2,z),locate(x2,y2,z))

proc/Turf_Circle_Edge(turf/center,radius)
	. = list()
	while(center&&!isturf(center)) center=center.loc
	if(!center) return list()
	var/x=center.x,y=center.y,z=center.z
	var/dx,dy,rsq
	var/x1,x2,x3,x4,x5,x6,x7,y1,y2
	rsq=radius*(radius+1)
	for(dy=0,dy<=radius,++dy)
		dx=round(sqrt(rsq-dy*dy))
		y1=y-dy
		y2=y+dy
		x1=max(x-dx,1)
		x2=min(x+dx,world.maxx)
		if(dy==radius-1)
			x3=max(x-dx+1,1)
			x4=min(x+dx-1,world.maxx)
		else if(dy==radius)
			x5=max(x-dx+1,1)
			x6=x
			x7=min(x+dx-1,world.maxx)
		if(x1>x2) continue  // this should never happen, but just in case...
		if(y1>0&&y1!=y)
			. +=locate(x1,y1,z)
			. +=locate(x2,y1,z)
			. +=locate(x3,y1,z)
			. +=locate(x4,y1,z)
			. +=locate(x5,y1,z)
			. +=locate(x6,y1,z)
			. +=locate(x7,y1,z)
		if(y2 <= world.maxy)
			. +=locate(x1,y2,z)
			. +=locate(x2,y2,z)
			. +=locate(x3,y2,z)
			. +=locate(x4,y2,z)
			. +=locate(x5,y2,z)
			. +=locate(x6,y2,z)
			. +=locate(x7,y2,z)

mob/proc/File_Size(file)
	var/size=length(file)
	if(!size||!isnum(size)) return
	var/ending="Byte"
	if(size>=1024)
		size/=1024
		ending="KB"
		if(size>=1024)
			size/=1024
			ending="MB"
			if(size>=1024)
				size/=1024
				ending="GB"
	var/end=round(size)
	return "[Commas(end)] [ending]\s"

proc/Commas(A)
	var/Number=num2text(round(A,1),20)
	for(var/i=length(Number)-2,i>1,i-=3) Number="[copytext(Number,1,i)]'[copytext(Number,i)]"
	return Number

proc/IsOdd(n)
	return n%2
proc/IsEven(n)
	return !(n%2)

proc/Direction(A)
	switch(A)
		if(1) return "North"
		if(2) return "South"
		if(4) return "East"
		if(5) return "Northeast"
		if(6) return "Southeast"
		if(8) return "West"
		if(9) return "Northwest"
		if(10) return "Southwest"
		if("North") return 1
		if("South") return 2
		if("East") return 4
		if("Northeast") return 5
		if("Southeast") return 6
		if("West") return 8
		if("Northwest") return 9
		if("Southwest") return 10

proc/
	dir2angle(dir)
		switch(dir)
			if(NORTH)
				return 0
			if(NORTHEAST)
				return 45
			if(EAST)
				return 90
			if(SOUTHEAST)
				return 135
			if(SOUTH)
				return 180
			if(SOUTHWEST)
				return 225
			if(WEST)
				return 270
			if(NORTHWEST)
				return 315

proc/
	GetAngle(atom/a, atom/b) //Find the angle between two atoms.
		. = atan2((b.y*32) - (a.y*32), (b.x*32) - (a.x*32))
	atan2(x, y, d)
		if(d)
			if(istype(x, /list))
				if(isnull(d)) d = y
				y = x[2]
				x = x[1]
			if(!(x || y)) return 0
			if(isnull(d)) d = sqrt(x * x + y * y)
			return x >= 0 ? arccos(y / d) : 360 - arccos(y / d)
		else if(!x && !y) return 0
		else return y >= 0 ? arccos(x / sqrt(x * x + y * y)) : -arccos(x / sqrt(x * x + y * y))
	clamp_angle(angle)
		. = angle % 360 + angle - round(angle)
		if(. >= 360) . -= 360
		if(. <    0) . += 360