client
	New()
		..()

		// setMacros() retired, ApplyKeybinds (SkillMenuHotbar) is what is used now
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

			var/raw=winget(src,null,"macro")
			if(!raw) return
			var/list/macros=params2list(raw)
			if(!macros || !macros.len) return
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


mob/var/tmp/dir_locked = 0

mob/Players

	//	This will initiate movement whenever a client logs into a /mob/player.
	Login()
		..()
		BeamsKill() 
		if(!ChrysalisActive)
			Frozen = 0
		// Re-apply chrysalis state on reconnect (timer loop and shell obj are lost on restart)
		if(ChrysalisActive)
			if(world.realtime >= ChrysalisExpiry)
				exitChrysalis()
			else
				Frozen = 2
				move_disabled = 1
				var/obj/ChrysalisShell/shell = new(src.loc)
				shell.occupant = src
				spawn()
					chrysalisTimerCheck()
		spawn()
			MovementLoop()

	//	instant so inputs land fast, hidden keeps them off the statpanel
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
			//	ticks to wait between steps
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
			MovementLoop()
				var/loop_delay=glob.BASE_LOOP_DELAY
				while(src)
					if(src.pixel_z&&(key1||key2||key3||key4)&&(!PmActive()||pm_crossed)&&!src.Stasis&&!src.Launched&&!src.Stunned&&!src.Suspended&&!src.ActionLocked&&!src.PoweringUp)
						if(!src.EquippedFlyingDevice())
							flick("Flight",src)
					if(key1||key2||key3||key4)
						//rooted pivot
						if((IsGuarding() || IsChargingEnergy()) && !dir_locked)
							var/hd = heldDir()
							if(hd) dir = hd
							sleep(world.tick_lag)
							continue
						if(canMove())
							if(PmActive()) //pixel build: per-tick micro-steps, same net speed
								PmMovementTick()
								sleep(world.tick_lag)
								continue
							/*stepDiagonal()  Test this sometime
							loop_delay+=MovementSpeed()*/
							if(stepDiagonal())
								glide_size = 0 //auto-glide here, also heals a stale pixel-build glide_size from an old save
								if(SlotlessBuffs.len>0)
									var/ai_skin = passive_handler.Get("AfterImageSkin")
									if(ai_skin)
										var/ai_count = passive_handler.Get("AfterImages")
										if(ai_count)
											switch(ai_skin)
												if("Cooler") coolerFlashImage(src, ai_count)
												if("Rainbow") rainbowFlashImage(src, ai_count)
								loop_delay = glob.BASE_LOOP_DELAY
								if(dir==NORTHEAST||dir==NORTHWEST||dir==SOUTHEAST||dir==SOUTHWEST)
									loop_delay *= glob.DIAG_LOOP_DELAY
								move_speed = MovementSpeed()
								var/delay = loop_delay + move_speed
								if(src.Crippled)
									var/debuffRev = src.GetDebuffReversal();
									if(debuffRev)
										//an awful fate has been invoked by Seraphite...
										//when you run faster than light, all you can see is darkness...
										var/fastCrippleEffect = (1 + ((glob.MAX_CRIPPLE_MULT * (Crippled / glob.CRIPPLE_DIVISOR) / 2) * debuffRev))//this value is smaller than the slow effect
										delay /= fastCrippleEffect;
									else
										var/slowCrippleEffect = (1 + (glob.MAX_CRIPPLE_MULT*(Crippled/glob.CRIPPLE_DIVISOR)));
										delay *= slowCrippleEffect;
								if(passive_handler["Don't Move"])
									LoseHealth(glob.RUPTURED_MOVE_DMG * passive_handler["Don't Move"])
									loop_delay/=2
									animate(src, color = "#850000")
									animate(src, color = src.MobColor, time=world.tick_lag * (delay))
								sleep(world.tick_lag * (delay))
								continue
					sleep(world.tick_lag)

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
					// if(loop_delay>=1)
					// 	sleep(world.tick_lag)
			canMove()
//				if(Control) return TRUE
				//if(!Allow_Move()) return FALSE
				if(move_disabled || passive_handler["Snared"]>0)
					return FALSE
				if(splat_stagger_until > world.time)
					return FALSE
				if(IsGuarding() || IsChargingEnergy())
					return FALSE
				return TRUE


			//	merges held keys into diagonals, split into x/y steps so you don't stick on walls
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
						var/step_d=dir_x+dir_y
						if(!src.dir_locked&&src.Beaming!=2&&!src.Stasis&&!src.Frozen&&!src.Launched&&!src.Stunned&&!src.Suspended&&!src.ActionLocked&&!src.PoweringUp)
							src.dir=step_d
						if(src.Attracted&&get_dist(src, src.AttractedTo)>=3)
							src.dir=get_dir(src, src.AttractedTo)
							step_d=src.dir
						var/locked_dir=0
						if(src.dir_locked)
							locked_dir=src.dir
						if(src.Allow_Move(step_d))
							step(src,step_d)
							if(locked_dir)
								src.dir=locked_dir
						else
							return 0


						return 1
					else
						if(prob(src.Confused) || passive_handler.Get("Manic") ? prob(passive_handler.Get("Manic") * 5) : 0)
							dir_x = pick(DIRSX)
						var/step_d=dir_x
						if(!src.dir_locked&&src.Beaming!=2&&!src.Stasis&&!src.Frozen&&!src.Launched&&!src.Stunned&&!src.Suspended&&!src.ActionLocked&&!src.PoweringUp)
							src.dir=step_d
						if(src.Attracted&&get_dist(src, src.AttractedTo)>=3)
							src.dir=get_dir(src, src.AttractedTo)
							step_d=src.dir
						var/locked_dir=0
						if(src.dir_locked)
							locked_dir=src.dir
						if(src.Allow_Move(step_d))
							step(src,step_d)
							if(locked_dir)
								src.dir=locked_dir

						return 1
				else
					if(dir_y)
						if(prob(src.Confused) || passive_handler.Get("Manic") ? prob(passive_handler.Get("Manic") * 5) : 0)
							dir_y = pick(DIRSY)
						var/step_d=dir_y
						if(!src.dir_locked&&src.Beaming!=2&&!src.Stasis&&!src.Frozen&&!src.Launched&&!src.Stunned&&!src.Suspended&&!src.ActionLocked&&!src.PoweringUp)
							src.dir=step_d
						if(src.Attracted&&get_dist(src, src.AttractedTo)>=3)
							src.dir=get_dir(src, src.AttractedTo)
							step_d=src.dir
						var/locked_dir=0
						if(src.dir_locked)
							locked_dir=src.dir
						if(src.Allow_Move(step_d))
							step(src,step_d)
							if(locked_dir)
								src.dir=locked_dir
						else
							return 0
						return 1
					else return 0

			//	key press order decides which dirs win
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

//merged held-key direction
mob/proc/heldDir()
	return 0
mob/Players/heldDir()
	var/dir_x = 0
	var/dir_y = 0
	var/north_held = (key1==NORTH||key2==NORTH||key3==NORTH||key4==NORTH)
	var/south_held = (key1==SOUTH||key2==SOUTH||key3==SOUTH||key4==SOUTH)
	var/east_held  = (key1==EAST ||key2==EAST ||key3==EAST ||key4==EAST )
	var/west_held  = (key1==WEST ||key2==WEST ||key3==WEST ||key4==WEST )
	if(north_held && !south_held) dir_y = NORTH
	else if(south_held && !north_held) dir_y = SOUTH
	if(east_held && !west_held) dir_x = EAST
	else if(west_held && !east_held) dir_x = WEST
	return dir_x + dir_y
