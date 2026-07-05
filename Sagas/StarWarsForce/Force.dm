///////////////////////////////////////////////////////////////////
//Force Abilities/////////
//////////////////////////////////////////////////////////////////
mob/var/ForceBar = 100

mob/proc/LoseForce(amount)
	if(ForceBar == 0) return
	ForceBar -= amount
	if(ForceBar < 0)
		ForceBar = 0


mob/proc
    Mind_Trick(mob/M in get_dist(src,src.dir))
        if(!Target)
            src << "You must have a target to trick!"
            return
        if (ForceBar<1)
            usr <<"YOU DO NOT HAVE ENOUGH FORCE!"
            return
        else
            var/dur=10
            while((dur)>0)
                usr.dir=pick(NORTH,SOUTH,WEST,EAST)
                src <<"You are under a Mind Trick!"
                dur--
            ForceBar-=10


mob/proc
    ChoseSideOfForce()
        switch (input(usr,"Which side of the force do you feel the calling for?") in list ("Dark","Light"))
            if("Dark")
                usr.DarkSide=1
            if("Light")
                usr.LightSide=1