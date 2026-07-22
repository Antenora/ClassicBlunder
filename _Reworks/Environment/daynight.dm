//LIGHTING_PLANE lives here because daynight.dm is included first
#define LIGHTING_PLANE 2 //additive light overlays render here + get the master's smoothing blur
#define BASE_LIGHTING_PLANE 4 //MR ambient base lives here UNBLURRED (blurring an opaque base rims its edges)
#define DN_BLANKET_LAYER 6.5 //plane-0 multiply blanket (MR OFF): above mobs, below the HUD stack
#define DN_BASE_LAYER 1 //ambient base layer (MR ON): below the light overlays relayed in at 6.55

globalTracker
	var/tmp
		DAY_NIGHT = TRUE 
		DN_CYCLE_MINUTES = 120 //full day length in real minutes
		//multiply-reveal: darkness moves into the lighting buffer and the relay multiplies it back; off = classic additive
		MULTIPLY_REVEAL = TRUE
		LIGHT_CAVE_COLOR = "#2b2b33" //opaque cave base under multiply-reveal
		//full-moon cold override
		MOON_EVENT = TRUE
		MOON_GRADE_COLOR = "#7898e8" //strong silver-blue ambient lift over the ordinary #566294 night
		MOON_FILL_COLOR = "#8fb9ff" //subtle additive outdoor fill, applied client-side below combat FX
		MOON_FILL_ALPHA = 24
		MOON_EVENT_PHASE = 0.64 //DnPhase the natural moon waits for - keeps the event inside the night plateau (0.58-0.88)
		MOON_EVENT_RAMP = 1200 //ds; matches the MoonWarning->MoonTrigger gap so the sky lands with Oozaru and other moon procs
		MOON_EVENT_HOLD = 6000
		MOON_EVENT_FADE = 1800

area
	var/sees_sky = 0 //areas open to the sky: day/night + weather apply
	var/dark_cave = 0 //baked-dark cave/underground (Dark.dmi): full light strength, reveal surface
	var/_dn_orig_layer = 0 //cave's map-defined layer, captured so MR-OFF can restore it

//all outdoor terrain sees sky, the no-sun zones opt back out below
area/Outside/sees_sky = 1
area/Outside/Planet/Afterlife/sees_sky = 0
area/Outside/Planet/Heaven/sees_sky = 0
area/Outside/Planet/Hell/sees_sky = 0
area/Outside/Planet/Danger/sees_sky = 0
area/Outside/Planet/HBTC/sees_sky = 0
area/Outside/Planet/Void/sees_sky = 0
area/Outside/Planet/Rave/sees_sky = 0
area/Outside/PirateColonyOutside/sees_sky = 1
area/Outside/Planet/Earth/sees_sky = 1
area/Outside/Planet/Earth/Underwater/sees_sky = 0
area/Outside/Planet/Earth/EarthUnderground/sees_sky = 0
area/Outside/Planet/Namek/sees_sky = 1
area/Outside/Planet/Namek/NamekUnderwater/sees_sky = 0
area/Outside/Planet/Namek/NamekUnderground/sees_sky = 0
area/Outside/Planet/Vegeta/sees_sky = 1
area/Outside/Planet/Vegeta/VegetaUnderwater/sees_sky = 0
area/Outside/Planet/Vegeta/VegetaUnderground/sees_sky = 0
area/Outside/Planet/Ice/sees_sky = 1
area/Outside/Planet/Ice/IceUnderwater/sees_sky = 0
area/Outside/Planet/Ice/IceUnderground/sees_sky = 0
area/Outside/Planet/Arconia/sees_sky = 1
area/Outside/Planet/Arconia/ArconiaUnderwater/sees_sky = 0
area/Outside/Planet/Arconia/ArconiaUnderground/sees_sky = 0
area/Outside/Planet/Sanctuary/sees_sky = 1
area/Outside/Planet/Sanctuary/SanctuaryUnderwater/sees_sky = 0
area/Outside/Planet/Sanctuary/SanctuaryUnderground/sees_sky = 0
area/Outside/Planet/AlienRuin/sees_sky = 1
area/Outside/Planet/AlienRuin/ARUnderground/sees_sky = 0
area/Outside/Planet/AlienGrassland/sees_sky = 1
area/Outside/Planet/AlienGrassland/AGUnderground/sees_sky = 0
area/Outside/Planet/AlienOcean/sees_sky = 1
area/Outside/Planet/AlienOcean/AOUnderwater/sees_sky = 0
area/Outside/Planet/AlienOcean/AOUnderground/sees_sky = 0
area/Outside/Planet/AlienArctic/sees_sky = 1
area/Outside/Planet/AlienArctic/AAUnderground/sees_sky = 0
area/Outside/Planet/AlienDesolate/sees_sky = 1
area/Outside/Planet/AlienDesolate/ADUnderground/sees_sky = 0

var/list/_dn_sky_areas = list()
var/list/_dn_cave_areas = list()
var/_dn_offset = 0
var/_moon_event_from = 0 //world.time the ramp-in started
var/_moon_event_until = 0 //world.time deadline - the ONLY moon-event state. 0 or past = inactive
var/icon/_env_white
var/_dn_boot = _DnBoot()

proc/EnvWhiteIcon()
	if(!_env_white)
		_env_white = new('sandstorm.dmi')
		_env_white.DrawBox("#ffffff", 1, 1, 32, 32)
	return _env_white

proc/_DnBoot()
	spawn(50)
		_DnSetup()
		_DnLoop()
	return 1

proc/_DnSetup()
	for(var/area/A in world)
		if(A.sees_sky)
			if(A.icon) continue 
			_dn_sky_areas += A
		else if(A.icon == 'Dark.dmi') //baked-dark cave/underground: a multiply-reveal surface
			A.dark_cave = 1
			A._dn_orig_layer = A.layer
			_dn_cave_areas += A
	_DnApplyMode()

//set every managed area up for the current MR mode: off = classic plane-0 multiply, on = opaque base in the lighting buffer
proc/_DnApplyMode()
	var/mr = glob && glob.MULTIPLY_REVEAL
	var/skycol = (glob && glob.DAY_NIGHT) ? DnColorNow() : "#ffffff" //day/night off -> white base (no-op), not the clock phase
	for(var/area/A in _dn_sky_areas)
		A.icon = EnvWhiteIcon()
		A.color = skycol
		if(mr)
			A.plane = BASE_LIGHTING_PLANE //unblurred base plane - blurring it would rim the edges
			A.layer = DN_BASE_LAYER
			A.blend_mode = BLEND_OVERLAY //opaque base; the ONE multiply is at the relay
		else
			A.plane = 0
			A.layer = DN_BLANKET_LAYER
			A.blend_mode = BLEND_MULTIPLY //classic plane-0 darkening
	for(var/area/A in _dn_cave_areas)
		if(mr)
			A.icon = EnvWhiteIcon()
			A.color = glob.LIGHT_CAVE_COLOR
			A.plane = BASE_LIGHTING_PLANE
			A.layer = DN_BASE_LAYER
			A.blend_mode = BLEND_OVERLAY
		else
			A.icon = 'Dark.dmi'
			A.color = null
			A.plane = 0
			A.layer = A._dn_orig_layer
			A.blend_mode = BLEND_DEFAULT

proc/DnPhase()
	var/cyc = max(1, glob ? glob.DN_CYCLE_MINUTES : 120) * 600
	var/p = ((world.time + _dn_offset) % cyc) / cyc
	return p < 0 ? p + 1 : p

//piecewise palette: long day, short dusk, long night, short dawn
proc/_DnClockColor()
	var/p = DnPhase()
	if(p < 0.42) return "#ffffff"
	if(p < 0.50) return DnLerp("#ffffff", "#d98f66", (p-0.42)/0.08)
	if(p < 0.58) return DnLerp("#d98f66", "#566294", (p-0.50)/0.08)
	if(p < 0.88) return "#566294" //deep moonlit blue (~39% brightness) so warm lights read
	if(p < 0.94) return DnLerp("#566294", "#e8bfa8", (p-0.88)/0.06)
	return DnLerp("#e8bfa8", "#ffffff", (p-0.94)/0.06)

//clock color plus the moon grade; every path that paints the sky goes through here
proc/DnColorNow()
	var/c = _DnClockColor()
	var/k = MoonEventK()
	return k > 0 ? DnLerp(c, glob.MOON_GRADE_COLOR, k) : c

//0 = broad daylight, 1 = deep night (used by the light-glow system in fxplane.dm)
proc/DnDarknessFrac()
	if(!glob || !glob.DAY_NIGHT) return 0
	var/p = DnPhase()
	if(p < 0.42) return 0
	if(p < 0.58) return (p - 0.42) / 0.16
	if(p < 0.88) return 1
	return max(0, 1 - (p - 0.88) / 0.12)

//how dark it is where T sits: sky areas follow the clock, baked-dark zones are always dim
proc/LightDarkFrac(turf/T)
	if(!T) return 0
	var/area/A = T.loc
	if(!A) return 0
	if(A.sees_sky) return DnDarknessFrac()
	if(A.dark_cave) return 1 //baked-dark caves: the DARKEST - full light strength (both modes)
	if(A.icon) //underwater tints: dark in additive mode, but NOT a multiply-reveal surface
		return (glob && glob.MULTIPLY_REVEAL) ? 0 : 1
	return 0 //opted-out sky-less areas (Heaven/Hell/etc.): never dark

proc/DnLerp(c1, c2, t)
	t = clamp(t, 0, 1)
	var/r1 = text2num(copytext(c1,2,4),16); var/g1 = text2num(copytext(c1,4,6),16); var/b1 = text2num(copytext(c1,6,8),16)
	var/r2 = text2num(copytext(c2,2,4),16); var/g2 = text2num(copytext(c2,4,6),16); var/b2 = text2num(copytext(c2,6,8),16)
	return rgb(round(r1+(r2-r1)*t), round(g1+(g2-g1)*t), round(b1+(b2-b1)*t))

proc/DnLerpNum(a, b, t)
	return a + (b - a) * clamp(t, 0, 1)

//0 = normal sky, 1 = full moon. derived from world.time every call, never stored - the event always releases by decay
proc/MoonEventK()
	if(!glob || !glob.MOON_EVENT) return 0
	if(!_moon_event_until || world.time >= _moon_event_until) return 0
	var/inK = glob.MOON_EVENT_RAMP > 0 ? clamp((world.time - _moon_event_from) / glob.MOON_EVENT_RAMP, 0, 1) : 1
	inK = 1 - (1 - inK) * (1 - inK) //ease out: moonrise reads early, but still peaks with MoonTrigger
	var/outK = glob.MOON_EVENT_FADE > 0 ? clamp((_moon_event_until - world.time) / glob.MOON_EVENT_FADE, 0, 1) : 1
	var/k = min(inK, outK)
	k = k * k * (3 - 2 * k) //smoothstep: the world creeps into it rather than sliding
	return k * DnDarknessFrac()

proc/MoonEventBegin(immediate = FALSE)
	if(immediate)
		_moon_event_from = world.time - glob.MOON_EVENT_RAMP
		_moon_event_until = world.time + glob.MOON_EVENT_HOLD + glob.MOON_EVENT_FADE
		return
	if(!_moon_event_until || world.time >= _moon_event_until) //only (re)start the ramp if not already running:
		_moon_event_from = world.time //restamping mid-event would slide the sky BACK to 0 and re-ramp
	_moon_event_until = world.time + glob.MOON_EVENT_RAMP + glob.MOON_EVENT_HOLD + glob.MOON_EVENT_FADE

proc/MoonWaitForNight()
	if(!glob || !glob.DAY_NIGHT) return
	var/p = DnPhase()
	if(p >= glob.MOON_EVENT_PHASE && p < 0.72) return //already moonrise: go now
	var/dp = glob.MOON_EVENT_PHASE - p
	if(dp < 0) dp += 1
	sleep(dp * max(1, glob.DN_CYCLE_MINUTES) * 600)

proc/_DnLoop()
	set waitfor = 0
	set background = 1
	while(1)
		if(glob && glob.DAY_NIGHT)
			var/target = DnColorNow()
			for(var/area/A in _dn_sky_areas)
				animate(A, color = target, time = 100)
		else
			for(var/area/A in _dn_sky_areas)
				if(A.color != "#ffffff")
					animate(A, color = "#ffffff", time = 10)
		sleep(100)

/mob/Admin2/verb/Day_Night_Toggle()
	set category = "Admin"
	set name = "Day Night Toggle"
	glob.DAY_NIGHT = !glob.DAY_NIGHT
	_DnApplyMode()
	if(glob.LIGHTING) LightingApplyAll()
	src << "Day/night cycle: [glob.DAY_NIGHT ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set day/night to [glob.DAY_NIGHT].")

/mob/Admin2/verb/Moon_Event_Toggle()
	set category = "Admin"
	set name = "Moon Event Toggle"
	glob.MOON_EVENT = !glob.MOON_EVENT
	src << "Full-moon lighting event: [glob.MOON_EVENT ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set moon event to [glob.MOON_EVENT].")

/mob/Admin2/verb/Force_Moon_Event()
	set category = "Admin"
	set name = "Force Moon Event"
	var/cyc = max(1, glob.DN_CYCLE_MINUTES) * 600
	_dn_offset = round(glob.MOON_EVENT_PHASE * cyc - (world.time % cyc))
	MoonEventBegin(TRUE)
	var/col = (glob && glob.DAY_NIGHT) ? DnColorNow() : "#ffffff" //bare DnColorNow would paint a night sky with day/night OFF
	for(var/area/A in _dn_sky_areas) //reconcile now instead of waiting out _DnLoop's 10s tick
		animate(A, color = col, time = 20)
	if(glob.LIGHTING) LightingApplyAll()
	for(var/client/C) EnvUpdateClient(C, TRUE)
	src << "Peak moonlight forced (~[round((glob.MOON_EVENT_HOLD+glob.MOON_EVENT_FADE)/600, 0.1)] min). Visual only."
	if(!glob.DAY_NIGHT) src << "<font color=orange>(Day/night is OFF, so the event is inert - nothing will show.)</font>"
	Log("Admin", "[ExtractInfo(src)] forced the moon lighting event.")

/mob/Admin2/verb/Multiply_Reveal_Toggle()
	set category = "Admin"
	set name = "Multiply Reveal Toggle"
	glob.MULTIPLY_REVEAL = !glob.MULTIPLY_REVEAL
	_DnApplyMode() //move ambient darkness between plane-0 blanket and the plane-2 buffer
	for(var/client/C) //flip every client's relay so the buffer multiplies (ON) or adds (OFF)
		if(C.fxlight_relay) FxApplyRelayBlend(C)
	FxEmissiveApplyMode() //re-seat emissive stamps for the new mode
	if(glob.LIGHTING) LightingApplyAll()
	src << "Multiply-reveal lighting: [glob.MULTIPLY_REVEAL ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set multiply-reveal to [glob.MULTIPLY_REVEAL].")

/mob/Admin2/verb/Set_Time_Of_Day()
	set category = "Admin"
	set name = "Set Time Of Day"
	var/pick = input(src, "Jump the clock to:") in list("Day","Dusk","Night","Dawn","Cancel")
	if(pick == "Cancel") return
	var/cyc = max(1, glob.DN_CYCLE_MINUTES) * 600
	var/target = 0.2
	switch(pick)
		if("Dusk") target = 0.52
		if("Night") target = 0.7
		if("Dawn") target = 0.91
	_dn_offset = round(target * cyc - (world.time % cyc))
	var/col = (glob && glob.DAY_NIGHT) ? DnColorNow() : "#ffffff" //bare DnColorNow would paint a night sky with day/night OFF
	for(var/area/A in _dn_sky_areas)
		animate(A, color = col, time = 20)
	if(glob.LIGHTING) LightingApplyAll() //clock jumps repaint now instead of waiting for _LightLoop
	src << "Time of day set to [pick]."
	Log("Admin", "[ExtractInfo(src)] set time of day to [pick].")
