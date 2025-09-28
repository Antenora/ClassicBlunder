/*
macros.dm and newMovement.dm code taken from SuperAntX SimpleMove library. =D
*/

#ifdef EXPERIMENTAL
#warn THIS IS THE NEW MOVEMENT SYSTEM. ITS STILL BROKEN. DONT PUT THIS ON THE SERVER
#endif

client
	New()
		..()
		setMacros()

	// These are here so the default movement commands don't interfere.
	North()
	South()
	East()
	West()
	Northeast()
	Northwest()
	Southeast()
	Southwest()

	proc

		//	setMacros() injects movement commands into all macro lists.
		setMacros()

			var/macros=params2list(winget(src,null,"macro"))
			for(var/m in macros)
				/*
				winset(src,"W","parent=[m];name=W;command=north")
				winset(src,"W+UP","parent=[m];name=W+UP;command=north-up")
				winset(src,"A","parent=[m];name=A;command=west")
				winset(src,"A+UP","parent=[m];name=A+UP;command=west-up")
				winset(src,"S","parent=[m];name=S;command=south")
				winset(src,"S+UP","parent=[m];name=S+UP;command=south-up")
				winset(src,"D","parent=[m];name=D;command=east")
				winset(src,"D+UP","parent=[m];name=D+UP;command=east-up")
				*/

// So, will this fancy movement system still be restricted by rules on moving, that is, if a player is frozen in place will they be prevented from moving?
// Should be, considering we havnt fucked with those procs, but lets test out to be sure.

				//	Arrow keys
				winset(src,"NORTH","parent=[m];name=NORTH;command=north")
				winset(src,"NORTH+UP","parent=[m];name=NORTH+UP;command=north-up")
				winset(src,"WEST","parent=[m];name=WEST;command=west")
				winset(src,"WEST+UP","parent=[m];name=WEST+UP;command=west-up")
				winset(src,"SOUTH","parent=[m];name=SOUTH;command=south")
				winset(src,"SOUTH+UP","parent=[m];name=SOUTH+UP;command=south-up")
				winset(src,"EAST","parent=[m];name=EAST;command=east")
				winset(src,"EAST+UP","parent=[m];name=EAST+UP;command=east-up")

				// Diagonal movement for numpad

				winset(src,"NORTHEAST","parent=[m];name=NORTHEAST;command=northeast")
				winset(src,"NORTHEAST+UP","parent=[m];name=NORTHEAST+UP;command=northeast-up")


mob/Players

	//	This will initiate movement whenever a client logs into a /mob/player.
	Login()
		..()
		spawn()
			MovementLoop()

	//	These are the actual commands players will be using for movement.
	//	They're set to instant so player inputs react as quickly, as possible.
	//	Having them hidden isn't required, it just prevents them from filling
	//	up a statpanel.
	verb
		north()
			set
				hidden=1
				instant=1
			src.keySet(NORTH)
		north_up()
			set
				hidden=1
				instant=1
			src.keyDel(NORTH)
		south()
			set
				hidden=1
				instant=1
			src.keySet(SOUTH)
		south_up()
			set
				hidden=1
				instant=1
			src.keyDel(SOUTH)
		east()
			set
				hidden=1
				instant=1
			src.keySet(EAST)
		east_up()
			set
				hidden=1
				instant=1
			src.keyDel(EAST)
		west()
			set
				hidden=1
				instant=1
			src.keySet(WEST)
		west_up()
			set
				hidden=1
				instant=1
			src.keyDel(WEST)
		northeast()
			set
				hidden=1
				instant=1
			src.keySet(NORTH)
			sleep(30)
			src.keySet(EAST)
		northeast_up()
			set
				hidden=1
				instant=1
			src.keyDel(NORTH)
			src.keyDel(EAST)