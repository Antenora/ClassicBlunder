
/* How to use Yota.Shockwave...

 All that is needed, is the following line!

  new/shockwave(loc,icon)

 This creates a ring of the icon arround the loc, and flys outward.
 You may want some more control though.  Params like Ticks, Speed,
 and Amount will give you that.

 Here is complete info on the paramiters...

                 [type] Name            (Default)  -Explanation
  new/shockwave(
                 [atom] Loc             (Required) -The centerpoint.
                 [icon] Icon            (Required) -The icon to be used.
                  [num] Ticks           (10)       -The number of ticks the ring will fly.  A negative number makes it unlimited.
                  [num] Speed           (20)       -The rate per tick the ring will fly out.
                  [num] Amount         (20)       -The number of projectiles to shoot out.  Multiples of 4 are suggested for symmetry. (Note: This is NOT the same as the 'density' variable!)
              [boolean] StopAtMob       (0)        -Will the projectile dissapear when a mob is hit?
          [string|path] MobCall         (null)     -Will call the colliding mob's procedure.
   [(associative) list] MobCallArg      (list())   -These will be the arguments for the mob's call.
              [boolean] StopAtObj       (0)        -Will the projectile dissapear when an obj is hit?
          [string|path] ObjCall         (null)     -Will call the colliding obj's procedure.
   [(associative) list] ObjCallArg      (list())   -These will be the arguments for the obj's call.
              [boolean] StopAtDenseTurf (0)        -With this enabled, the blast will stop when a solid turf is hit.
              [boolean] StopAtOpacTurf (0)
          [string|path] TurfCall        (null)     -Will call the procedure of the turf the object is hovering.
   [(associative) list] TurfCallArg     (list())   -These will be the arguments for the turf's call.
                  [mob] Source          (null)     -This mob will take the roll as usr in called procedures.  When set to null, the projectile itself will become usr.
                                                     )

 Here's some misc.
ormation, returning DELETE_PROJ in one of the
 procedures called from MobCall or ObjCall will delete they attacking
 projectile even if the StopAt.. params are false.
  DELETE_PROJ is a macro for "delSW".

 Also note that [(associative) list] does not mean the list must be
 associative.  It is optional.
*/

#define DELETE_PROJ "delSW"

shockwave/New(
 atom/Loc=usr,
 icon/Icon,
 Ticks=10,
 Speed=20,
 Amount=8,
 StopAtMob=0,
 MobCall=null,
 list/MobCallArg=list(),
 StopAtObj=0,
 ObjCall=null,
 list/ObjCallArg=list(),
 TurfCall=null,
 list/TurfCallArg=list(),
 StopAtDenseTurf=0,
 StopAtOpacTurf=1,
 mob/Source=null)
	var/dirstep=180/Amount*2
	var/lastdir=0
	if(isarea(Loc)) return
	while(!isturf(Loc))
		Loc = Loc.loc
		//sleep(0.1)
	while(lastdir<360)
		new/obj/shockwave(Loc,Icon,lastdir,Ticks,Speed,StopAtMob,MobCall,MobCallArg,StopAtObj,ObjCall,ObjCallArg,StopAtDenseTurf,StopAtOpacTurf,TurfCall,TurfCallArg,Source)
		lastdir+=dirstep
		//sleep(0.1)

obj/shockwave
	Savable=0
	Buildable=0
	animate_movement=0
	mouse_opacity=0
	layer=EFFECTS_LAYER
	appearance_flags=NO_CLIENT_COLOR
	New(
	 turf/Loc,
	 icon/Icon,
	 Direction,
	 Ticks,
	 Speed,
	 StopAtMob,
	 MobCall,
	 list/MobCallArg,
	 StopAtObj,
	 ObjCall,
	 list/ObjCallArg,
	 StopAtDenseTurf,
	 StopAtOpacTurf,
	 TurfCall,
	 list/TurfCallArg,
	 mob/Source)
		..(Loc)
		icon=Icon
		if(Source) usr=Source
		else usr=src
		var/vel_x = 0
		var/vel_y = 0
		var/pos_x = pixel_x
		var/pos_y = pixel_y
		var/list/Called = new
		vel_x = cos(Direction) * Speed
		vel_y = sin(Direction) * Speed
		spawn
			while(Ticks>0)
				pos_x+=vel_x
				pos_y+=vel_y
				if(pos_x > 16)
					pos_x -= 32
					x++
				if(pos_x < -16)
					pos_x += 32
					x--
				if(pos_y > 16)
					pos_y -= 32
					y++
				if(pos_y < -16)
					pos_y += 32
					y--

				if(!loc) del src
				if(TurfCall) if(!(loc in Called)) {call(loc,TurfCall)(arglist(TurfCallArg));Called+=loc}
				var/list/atom/movable/AL=new
				for(var/atom/movable/A in loc) if(!istype(A,/obj/shockwave)) AL += A
				AL += Source
				if(MobCall)
					if(locate(/mob)in AL)for(var/mob/M in loc) if(!(M in Called))
						if(call(M,MobCall)(arglist(MobCallArg)) == DELETE_PROJ && !StopAtMob) Ticks = 0
						Called+=M
				if(ObjCall)
					if(locate(/obj)in AL)for(var/obj/O in loc) if(!(O in Called))
						if(call(O,ObjCall)(arglist(ObjCallArg)) == DELETE_PROJ && !StopAtObj) Ticks = 0
						Called+=O


				if(StopAtMob)if(locate(/mob)in AL)  del src
				if(StopAtObj)if(locate(/obj)in AL)  del src
				if(StopAtDenseTurf) if(loc.density) del src
				if(StopAtOpacTurf)if(loc.opacity)del src


				pixel_x = pos_x
				pixel_y = pos_y
				sleep(1)
				Ticks--
			if(src)del src

