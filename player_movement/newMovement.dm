#define EXPERIMENTAL

#ifdef EXPERIMENTAL
#warn THIS IS THE NEW MOVEMENT SYSTEM. ITS STILL BROKEN. DONT PUT THIS ON THE SERVER
#endif

/*
macros.dm and newMovement.dm code taken from SuperAntX SimpleMove library. =D

I cant find this library on BYOND anymore, might just be me though.
Anyway, lets try it out. Compile and run this shiz.
NOTHING IS ON FIRE
Recompile and try again?
Or blind deploy and watch the panic
lol
*/

mob
	Players
		//	This is just so tile transitions animate smoothly.
		animate_movement=SLIDE_STEPS
		var
			//	How many ticks to wait between steps.
			//	Must be a positive number or 0.
			move_delay=1

			//	If movement needs to be disabled for some reason.
			//move_disabled=0

			//	This will prevent multiple instances of MovementLoop() from running.
			move_int=0

			//	These track which directions the player wants to move in.
			tmp
				key1=0
				key2=0
				key3=0
				key4=0

		proc
			//	MovementLoop() is the main process which handles movement.
			//	It does a few simple checks to see if the player wants to
			//	move, can move, and is able to move. Once the player moves
			//	it will delay itself for a moment until the player is able
			//	to step again.
			MovementLoop()
				var/loop_delay=0
				while(src)
					if(loop_delay>=1)
						sleep(world.tick_lag)
						loop_delay--
					else
						if(key1||key2||key3||key4)
							if(Move_Requirements())
								if(stepDiagonal())
									loop_delay+=move_delay
						sleep(world.tick_lag)

			//	canMove() is where you're able to prevent the player from moving.
			//	Use it for things like being dead, stunned, in a cutscene, and so on.

			// USE MOVE_REQUIREMENTS INSTEAD!!!
			/*
			canMove()
				if(Frozen||KO)return FALSE
				return TRUE
			*/

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
				var
					dir_x
					dir_y
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
					if(dir_y)
						step(src,dir_x)
						step(src,dir_y)

						//	If you don't want diagonal steps broken in two use this line.
						//step(src,dir_x+dir_y)

						dir=dir_x+dir_y
						return 1
					else
						step(src,dir_x)
						dir=dir_x
						return 1
				else
					if(dir_y)
						step(src,dir_y)
						dir=dir_y
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