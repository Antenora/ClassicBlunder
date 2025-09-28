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


				//	Arrow keys
				winset(src,"NORTH","parent=[m];name=NORTH;command=north")
				winset(src,"NORTH+UP","parent=[m];name=NORTH+UP;command=north-up")
				winset(src,"WEST","parent=[m];name=WEST;command=west")
				winset(src,"WEST+UP","parent=[m];name=WEST+UP;command=west-up")
				winset(src,"SOUTH","parent=[m];name=SOUTH;command=south")
				winset(src,"SOUTH+UP","parent=[m];name=SOUTH+UP;command=south-up")
				winset(src,"EAST","parent=[m];name=EAST;command=east")
				winset(src,"EAST+UP","parent=[m];name=EAST+UP;command=east-up")
				//keypad maybe??
				winset(src,"NORTHEAST","parent=[m];name=NORTHEAST;command=northeast")
				winset(src,"NORTHEAST+UP","parent=[m];name=NORTHEAST+UP;command=northeast-up")
				winset(src,"NORTHWEST","parent=[m];name=NORTHWEST;command=northwest")
				winset(src,"NORTHWEST+UP","parent=[m];name=NORTHWEST+UP;command=northwest-up")
				winset(src,"SOUTHWEST","parent=[m];name=SOUTHWEST;command=southwest")
				winset(src,"SOUTHWEST+UP","parent=[m];name=SOUTHWEST+UP;command=southwest-up")
				winset(src,"SOUTHEAST","parent=[m];name=SOUTHEAST;command=southeast")
				winset(src,"SOUTHEAST+UP","parent=[m];name=SOUTHEAST+UP;command=southeast-up")


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
			set hidden = 1
			set instant = 1
			/*if(src.Knockback)
				for(var/obj/Skills/Aerial_Recovery/x in src)
					src.SkillX("Aerial Recovery",x)*/
			src.keySet(NORTH)
		north_up()
			set hidden=1
			set instant=1

			src.keyDel(NORTH)
		south()
			set hidden=1
			set instant=1
			/*if(src.Knockback)
				for(var/obj/Skills/Aerial_Recovery/x in src)
					src.SkillX("Aerial Recovery",x)*/
			src.keySet(SOUTH)
		south_up()
			set hidden=1
			set instant=1
			src.keyDel(SOUTH)
		east()
			set hidden=1
			set instant=1
			/*if(src.Knockback)
				for(var/obj/Skills/Aerial_Recovery/x in src)
					src.SkillX("Aerial Recovery",x)*/
			src.keySet(EAST)
		east_up()
			set hidden=1
			set instant=1
			src.keyDel(EAST)
		west()
			set hidden=1
			set instant=1
			/*if(src.Knockback)
				for(var/obj/Skills/Aerial_Recovery/x in src)
					src.SkillX("Aerial Recovery",x)*/
			src.keySet(WEST)
		west_up()
			set hidden=1
			set instant=1
			src.keyDel(WEST)
		northeast()
			set hidden=1
			set instant=1
			/*if(src.Knockback)
				for(var/obj/Skills/Aerial_Recovery/x in src)
					src.SkillX("Aerial Recovery",x)*/
			src.keySet(EAST)
			src.keySet(NORTH)
		northeast_up()
			set hidden=1
			set instant=1
			src.keyDel(EAST)
			src.keyDel(NORTH)
		southwest()
			set hidden=1
			set instant=1
			/*if(src.Knockback)
				for(var/obj/Skills/Aerial_Recovery/x in src)
					src.SkillX("Aerial Recovery",x)*/
			src.keySet(WEST)
			src.keySet(SOUTH)
		southwest_up()
			set hidden=1
			set instant=1
			src.keyDel(WEST)
			src.keyDel(SOUTH)
		southeast()
			set hidden=1
			set instant=1
			/*if(src.Knockback)
				for(var/obj/Skills/Aerial_Recovery/x in src)
					src.SkillX("Aerial Recovery",x)*/
			src.keySet(EAST)
			src.keySet(SOUTH)
		southeast_up()
			set hidden=1
			set instant=1
			src.keyDel(EAST)
			src.keyDel(SOUTH)
		northwest()
			set hidden=1
			set instant=1
			/*if(src.Knockback)
				for(var/obj/Skills/Aerial_Recovery/x in src)
					src.SkillX("Aerial Recovery",x)*/
			src.keySet(WEST)
			src.keySet(NORTH)
		northwest_up()
			set hidden=1
			set instant=1
			src.keyDel(WEST)
			src.keyDel(NORTH)

	var
		tmp
			key1=0
			key2=0
			key3=0
			key4=0

globalTracker/var/BASE_LOOP_DELAY = 1.25
globalTracker/var/GODSPEED_NEEDED = 999
globalTracker/var/SPEED_NEEDED = 999
globalTracker/var/DIAG_LOOP_DELAY = 1.15
globalTracker/var/GODSPEED_LOOP_DELAY = 0.8


mob
	var
		assigningStats=FALSE
		droidFormerEnergysignature=FALSE
		MasterCrafts=0
	Players
		//	This is just so tile transitions animate smoothly.
		animate_movement=SLIDE_STEPS
		var
			//	How many ticks to wait between steps.
			//	Must be a positive number or 0.
			move_delay=1

			//	If movement needs to be disabled for some reason.
			move_disabled=0

			move_speed = 1
			//	This will prevent multiple instances of MovementLoop() from running.
			move_int=0
			//	These track which directions the player wants to move in.
		/*	tmp
				key1=0
				key2=0
				key3=0
				key4=0*/

		proc
			//	MovementLoop() is the main process which handles movement.
			//	It does a few simple checks to see if the player wants to
			//	move, can move, and is able to move. Once the player moves
			//	it will delay itself for a moment until the player is able
			//	to step again.
			MovementLoop()
				var/loop_delay=glob.BASE_LOOP_DELAY
				while(src)
					if(src.pixel_z&&(key1||key2||key3||key4)&&!src.Stasis&&!src.Launched&&!src.Stunned&&!src.PoweringUp)
						if(!src.EquippedFlyingDevice())
							flick("Flight",src)
					if(key1||key2||key3||key4)
						if(canMove())
							/*stepDiagonal()  Test this sometime
							loop_delay+=MovementSpeed()*/
							if(stepDiagonal())
								if(SlotlessBuffs.len>0)
									// only check if there are active slotless
									var/afterimages = passive_handler.Get("CoolerAfterImages")
									if(afterimages)
										coolerFlashImage(src, afterimages)
								loop_delay = glob.BASE_LOOP_DELAY
								if(HasGodspeed()>=glob.GODSPEED_NEEDED || GetSpd(1)>=glob.SPEED_NEEDED)
									loop_delay = glob.GODSPEED_LOOP_DELAY
								if(dir==NORTHEAST||dir==NORTHWEST||dir==SOUTHEAST||dir==SOUTHWEST)
									loop_delay *= glob.DIAG_LOOP_DELAY
								move_speed = MovementSpeed()
								var/delay = loop_delay + move_speed
								if(src.Crippled)
									delay*=glob.MAX_CRIPPLE_MULT*(Crippled/glob.CRIPPLE_DIVISOR)
								if(passive_handler["Don't Move"])
									LoseHealth(glob.RUPTURED_MOVE_DMG * passive_handler["Don't Move"])
									loop_delay/=2
									animate(src, color = "#850000")
									animate(src, color = src.MobColor, time=world.tick_lag * (delay))
								sleep(world.tick_lag * (delay))
								continue
					sleep(world.tick_lag)
					// if(loop_delay>=1)
					// 	sleep(world.tick_lag)
					// 	loop_delay--
					// else
					// 	if(key1||key2||key3||key4)
					// 		if(Control)
					// 			step(Control,key1)
					// 		if(canMove())
					// 			/*stepDiagonal()  Test this sometime
					// 			loop_delay+=MovementSpeed()*/
					// 			if(stepDiagonal())
					// 				loop_delay+=MovementSpeed()
					// 	sleep(world.tick_lag)

			//	canMove() is where you're able to prevent the player from moving.
			//	Use it for things like being dead, stunned, in a cutscene, and so on.
			canMove()
//				if(Control) return TRUE
				//if(!Allow_Move()) return FALSE
				if(move_disabled || passive_handler["Snared"]>0)
					return FALSE
				return TRUE


			//	stepDiagonal() checks all the keys the player is holding then
			//	mixes them together into diagonal steps. In cases where both
			//	keys for one axis are being pressed they are both ignored.
			//
			//	In order to prevent players from getting stuck on walls when
			//	stepping into them diagonally, diagonal steps are broken into
			//	two different steps along the x and y axes.
			//
			//	After stepping the player's direction is corrected and it reports
			//	back if the player was able to step or not so MovementLoop() knows
			//	when to apply a step delay.
			stepDiagonal()
				var/dir_x
				var/dir_y
				switch(key1)
					if(NORTH)if(key2!=SOUTH&&key3!=SOUTH&&key4!=SOUTH)dir_y=NORTH
					if(SOUTH)if(key2!=NORTH&&key3!=NORTH&&key4!=NORTH)dir_y=SOUTH
					if(EAST)if(key2!=WEST&&key3!=WEST&&key4!=WEST)dir_x=EAST
					if(WEST)if(key2!=EAST&&key3!=EAST&&key4!=EAST)dir_x=WEST
				switch(key2)
					if(NORTH)if(key1!=SOUTH&&key3!=SOUTH&&key4!=SOUTH)dir_y=NORTH
					if(SOUTH)if(key1!=NORTH&&key3!=NORTH&&key4!=NORTH)dir_y=SOUTH
					if(EAST)if(key1!=WEST&&key3!=WEST&&key4!=WEST)dir_x=EAST
					if(WEST)if(key1!=EAST&&key3!=EAST&&key4!=EAST)dir_x=WEST
				switch(key3)
					if(NORTH)if(key1!=SOUTH&&key2!=SOUTH&&key4!=SOUTH)dir_y=NORTH
					if(SOUTH)if(key1!=NORTH&&key2!=NORTH&&key4!=NORTH)dir_y=SOUTH
					if(EAST)if(key1!=WEST&&key2!=WEST&&key4!=WEST)dir_x=EAST
					if(WEST)if(key1!=EAST&&key2!=EAST&&key4!=EAST)dir_x=WEST
				switch(key4)
					if(NORTH)if(key1!=SOUTH&&key2!=SOUTH&&key3!=SOUTH)dir_y=NORTH
					if(SOUTH)if(key1!=NORTH&&key2!=NORTH&&key3!=NORTH)dir_y=SOUTH
					if(EAST)if(key1!=WEST&&key2!=WEST&&key3!=WEST)dir_x=EAST
					if(WEST)if(key1!=EAST&&key2!=EAST&&key3!=EAST)dir_x=WEST

				if(dir_x)
					if(prob(src.Confused) || passive_handler.Get("Manic") ? prob(passive_handler.Get("Manic") * 5) : 0)
						dir_x = pick(DIRSX)
					if(dir_y)
						if(prob(src.Confused) || passive_handler.Get("Manic") ? prob(passive_handler.Get("Manic") * 5) : 0)
							dir_y = pick(DIRSY)

						//	If you don't want diagonal steps broken in two use this line.
						if(src.Beaming!=2&&!src.Stasis&&!src.Frozen&&!src.Launched&&!src.Stunned&&!src.PoweringUp)
							src.dir=dir_x+dir_y
						if(src.Attracted&&get_dist(src, src.AttractedTo)>=3)
							src.dir=get_dir(src, src.AttractedTo)
						if(src.Allow_Move(src.dir))
							step(src,src.dir)
						else
							return 0


						return 1
					else
						if(prob(src.Confused) || passive_handler.Get("Manic") ? prob(passive_handler.Get("Manic") * 5) : 0)
							dir_x = pick(DIRSX)
						if(src.Beaming!=2&&!src.Stasis&&!src.Frozen&&!src.Launched&&!src.Stunned&&!src.PoweringUp)
							src.dir=dir_x
						if(src.Attracted&&get_dist(src, src.AttractedTo)>=3)
							src.dir=get_dir(src, src.AttractedTo)
						if(src.Allow_Move(src.dir))
							step(src,src.dir)

						return 1
				else
					if(dir_y)
						if(prob(src.Confused) || passive_handler.Get("Manic") ? prob(passive_handler.Get("Manic") * 5) : 0)
							dir_y = pick(DIRSY)
						if(src.Beaming!=2&&!src.Stasis&&!src.Frozen&&!src.Launched&&!src.Stunned&&!src.PoweringUp)
							src.dir=dir_y
						if(src.Attracted&&get_dist(src, src.AttractedTo)>=3)
							src.dir=get_dir(src, src.AttractedTo)
						if(src.Allow_Move(src.dir))
							step(src,src.dir)
						else
							return 0
						return 1
					else return 0

			//	keySet() and keyDel() are used to change the order in which the player
			//	has pressed their movement keys. It's crucial to preserve the sequence
			//	of key presses in order to determine which directions are prioritized.
			keySet(dir)
				if(key1)
					if(key2)
						if(key3)key4=dir
						else key3=dir
					else key2=dir
				else key1=dir

			keyDel(dir)
				if(key1==dir)
					key1=key2
					key2=key3
					key3=key4
					key4=0
				else
					if(key2==dir)
						key2=key3
						key3=key4
						key4=0
					else
						if(key3==dir)
							key3=key4
							key4=0
						else key4=0