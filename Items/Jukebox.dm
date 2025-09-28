
var/list/jukebox_includes=list('Sounds/music/jukebox/MJ+2540+5.mid',\
	'Sounds/music/jukebox/dragon7+2320+5.mid',,\
	'Sounds/music/jukebox/BloodyStream+930+5.ogg',\
	'Sounds/music/jukebox/fairfrozen+2790+5.ogg',\
	'Sounds/music/jukebox/legendary wond+1440+5.mid',\
	'Sounds/music/jukebox/maple dream+1930+5.mid',\
	'Sounds/music/jukebox/scarlet symphony+2130+5.mid',\
	'Sounds/music/jukebox/woods of mystery+1870+5.ogg'\
)

obj/Items/Tech/Jukebox
	name = "jukebox"
	desc = "A classic music player."
	icon = 'Icons/Objects/jukebox.dmi'
	icon_state = "jukebox"
	density = TRUE
	var/list/permissions = list()
	var/HearingRange = 10
	var/active = FALSE
	var/list/rangers = list()
	var/stop = 0
	var/list/songs = list()
	var/track/selection = null
	New()
		. = ..()
		Initialize()

obj/Items/Tech/Jukebox/Disco
	name = "radiant dance machine mark IV"
	desc = "The first three prototypes were discontinued after mass casualty incidents."
	icon_state = "disco"
	var/list/spotlights = list()
	var/list/sparkles = list()


track
	var/song_name = "generic"
	var/song_path = null
	var/song_length = 0
	var/song_beat = 0

	New(name, path, length, beat)
		song_name = name
		song_path = path
		song_length = length
		song_beat = beat

obj/Items/Tech/Jukebox/proc/Initialize()
	return
	var/list/tracks = jukebox_includes
	for(var/S in tracks)
		var/track/T = new()
		T.song_path = file(S)
		var/filtext = "[S]"
		var/list/L = splittext(filtext,"+")
		T.song_name = L[1]
		T.song_length = text2num(L[2])
		T.song_beat = text2num(L[3])
		songs += T

	if(songs.len)
		selection = pick(songs)

obj/Items/Tech/Jukebox/verb/Upload_Track()
	set src in view(1)
	if(!usr.ckey in permissions)
		usr << "Hands off!"
		return
	var/new_track = input("New Track") as file | null
	if(!new_track) return
	if((length(new_track) > 100000))
		usr <<"This file exceeds the limit of 100KB. It cannot be used."
		return
	var/track/T = new()
	T.song_path = file(new_track)
	var/filtext = "[new_track]"
	if(!findtext(filtext,".ogg") && !findtext(filtext, ".mid"))
		usr << "Wrong file type. Use .ogg or .mid"
		return
	var/list/L = splittext(filtext,"+")
	if(!L[2] || !L[3])
		usr << "File name must be formated at song name+song length in deciseconds+song beat.ogg"
		return
	T.song_name = L[1]
	T.song_length = text2num(L[2])
	T.song_beat = text2num(L[3])
	songs += T

obj/Items/Tech/Jukebox/verb/Check_Track()
	set src in view(1)
	usr << "Track Selected: [selection.song_name]<br>"
	usr << "Track Length: [selection.song_length]<br><br>"

obj/Items/Tech/Jukebox/verb/BREAK_IT_DOWN()
	set src in view(1)
	if(permissions.len && !usr.ckey in permissions)
		usr << "Hands off!"
	Action("on")

obj/Items/Tech/Jukebox/verb/SHUT_IT_DOWN()
	set src in view(1)
	if(permissions.len && !usr.ckey in permissions)
		usr << "Hands off!"
	Action("off")

obj/Items/Tech/Jukebox/verb/Set_Track()
	set src in view(1)
	if(permissions.len && !usr.ckey in permissions)
		usr << "Hands off!"
	if(!songs.len)
		Initialize()
	Action("select")

obj/Items/Tech/Jukebox/proc/Action(var/action)
	switch(action)
		if("off")
			if(active)
				stop = 0

		if("on")
			if(!active)
				if(stop > world.time)
					usr << "Error: The device is still resetting from the last activation."
					return
				LETSJAM()

		if("select")
			if(active)
				usr << "Error: You cannot change the song until the current one is over."
				return

			var/list/available = list()
			for(var/track/S in songs)
				available[S.song_name] = S
			var/selected = input(usr, "Choose your song", "Track:") as null|anything in available
			if(!selected || !istype(available[selected], /track))
				return
			selection = available[selected]

obj/Items/Tech/Jukebox/proc/LETSJAM() //activate music
	active = TRUE
	icon_state = "jukebox-active"
	global_loop.Add(src)
	stop = world.time + selection.song_length

obj/Items/Tech/Jukebox/Disco/LETSJAM()
	..()
	icon_state="disco-active"
	//DanceSetup()
	//LightsSpin()

obj/Items/Tech/Jukebox/Update()
	if(world.time < stop && active)
		var/sound/song_played = sound(selection.song_path)

		for(var/mob/M in range(HearingRange,src))
			if(!M.client)
				continue
			if(!(M in rangers))
				rangers[M] = TRUE
				M.playsound_local(locate(M.x,M.y,M.z), null, 75, channel = 1021, S = song_played)
		for(var/mob/L in rangers)
			if(get_dist(src,L) > HearingRange)
				rangers -= L
				if(!L || !L.client)
					continue
				if(L.dancing) L.transform = L.dancing
				L.stop_sound_channel(1021)
	else if(active)
		active = FALSE
		global_loop.Remove(src)
		dance_over()
		icon_state = initial(icon_state)
		stop = world.time + 100

obj/Items/Tech/Jukebox/proc/dance_over()
	for(var/mob/L in rangers)
		if(!L || !L.client)
			continue
		L.stop_sound_channel(1021)
		if(L.dancing) L.transform = L.dancing
	rangers = list()

obj/Items/Tech/Jukebox/Disco/Update()
	. = ..()
	if(active)
		for(var/mob/M in rangers)
			if(prob(1))

				dance(M)

mob/var/tmp/dancing

obj/Items/Tech/Jukebox/Disco/proc/dance(var/mob/M) //Show your moves
	set waitfor = FALSE
	switch(rand(0,9))
		if(0 to 1)
			dance2(M)
		if(2 to 3)
			dance3(M)
		if(4 to 6)
			dance4(M)
		if(7 to 9)
			dance5(M)

obj/Items/Tech/Jukebox/Disco/proc/dance2(var/mob/M)
	for(var/i = 1, i < 10, i++)
		for(var/d in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
			M.dir=d
			if(i == WEST)
				M.SpinAnimation(7,1)
			sleep(1)
		sleep(20)
	M.transform=M.dancing

obj/Items/Tech/Jukebox/Disco/proc/dance3(var/mob/M)
	var/matrix/initial_matrix = matrix(M.transform)
	for (var/i in 1 to 75)
		if (!M)
			return
		switch(i)
			if (1 to 15)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (16 to 30)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(1,-1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (31 to 45)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-1,-1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (46 to 60)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-1,1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (61 to 75)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(1,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
		M.dir = (turn(M.dir, 90))
		switch (M.dir)
			if (NORTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (SOUTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,-3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (EAST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (WEST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
		sleep(1)
	M.transform=M.dancing


obj/Items/Tech/Jukebox/Disco/proc/dance4(var/mob/M)
	var/speed = rand(1,3)
	set waitfor = 0
	var/time = 30
	while(time)
		sleep(speed)
		for(var/i in 1 to speed)
			if(!M.dancing) return
			M.dir = (pick(NORTH,SOUTH,EAST,WEST))
			for(var/mob/NS in rangers)
				var/matrix/m = NS.transform
				m = turn(m, i%2==0 ? 90 : -90)
				animate(NS, transform=m, time=1)
		 time--
	M.transform=M.dancing

obj/Items/Tech/Jukebox/Disco/proc/dance5(var/mob/M)
	animate(M, transform = turn(transform, 180), time = 1, loop = 0)
	var/matrix/initial_matrix = matrix(M.transform)
	for (var/i in 1 to 60)
		if (!M)
			return
		if (i<31)
			initial_matrix = matrix(M.transform)
			initial_matrix.Translate(0,1)
			animate(M, transform = initial_matrix, time = 1, loop = 0)
		if (i>30)
			initial_matrix = matrix(M.transform)
			initial_matrix.Translate(0,-1)
			animate(M, transform = initial_matrix, time = 1, loop = 0)
		M.dir = (turn(M.dir, 90))
		switch (M.dir)
			if (NORTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (SOUTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,-3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (EAST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (WEST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
		sleep(1)
	M.transform=M.dancing


/atom/proc/SpinAnimation(speed = 10, loops = -1, clockwise = 1, segments = 3)
	if(!segments)
		return
	var/segment = 360/segments
	if(!clockwise)
		segment = -segment
	var/list/matrices = list()
	for(var/i in 1 to segments-1)
		var/matrix/M = matrix(transform)
		M.Turn(segment*i)
		matrices += M
	var/matrix/last = matrix(transform)
	matrices += last

	speed /= segments

	animate(src, transform = matrices[1], time = speed, loops)
	for(var/i in 2 to segments) //2 because 1 is covered above
		animate(transform = matrices[i], time = speed)
		//doesn't have an object argument because this is "Stacking" with the animate call above
		//3 billion% intentional