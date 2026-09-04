globalTracker/var
	TOME_BOB_TIME = 12
	TOME_GLOW_SIZE = 3
	TOME_OUTLINE_SIZE = 1

proc/TomeGlowColor(e)
	switch(e)
		if("Fire") return "#ff3a1e"
		if("Water") return "#2f7dff"
		if("Ice") return "#4fe3ff"
		if("Wind") return "#5fffae"
		if("Lightning") return "#ffc440"
		if("Earth") return "#c98b3a"
		if("Light") return "#ffe98a"
		if("Dark") return "#a24dff"
		if("Space") return "#5560ff"
		if("Time") return "#2fffcf"
		if("Lich") return "#8bd66b"
	return FxElementColor(e)

obj/fx_tome
	icon = 'ArcaneTomes.dmi'
	layer = MOB_LAYER + 0.2
	mouse_opacity = 0
	density = 0
	Grabbable = 0
	Destructable = 0
	Savable = 0
	gfx_transient_visual = 1
	appearance_flags = PIXEL_SCALE | KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	var/tmp
		mob/owner
		el
		closing = 0

	New(mob/o, element, side = 1)
		..(null)
		loc = null
		owner = o
		el = element
		pixel_x = 14 * side
		pixel_y = 14
		icon_state = "[el]_idle"
		ApplyGlow()
		spawn()
			flick("[el]_spawn", src)
			sleep(9)
			if(closing) return
			flick("[el]_open", src)
			sleep(13)
			if(closing) return
			Bob()
		spawn() Watch()

	proc/ApplyGlow()
		var/gc = TomeGlowColor(el)
		filters = list(filter(type="outline", size=glob.TOME_OUTLINE_SIZE, color=gc), 			filter(type="drop_shadow", x=0, y=0, size=glob.TOME_GLOW_SIZE, color=gc))

	proc/Bob()
		var/matrix/up = matrix()
		up.Translate(0, 2)
		animate(src, transform = up, time = glob.TOME_BOB_TIME, loop = -1, easing = SINE_EASING)
		animate(transform = matrix(), time = glob.TOME_BOB_TIME, easing = SINE_EASING)

	proc/Flip()
		if(closing) return
		flick("[el]_flip", src)

	proc/Dismiss()
		if(closing) return
		closing = 1
		animate(src)
		transform = null
		icon_state = "blank"
		flick("[el]_close", src)
		spawn(11)
			var/mob/o = owner
			owner = null
			if(o) o.vis_contents -= src
			loc = null

	proc/Watch()
		while(!closing && owner)
			if(!owner.CheckSlotless("Mage Grimoire"))
				Dismiss()
				return
			sleep(5)

mob/var/tmp/list/grimoire_tomes

mob/proc/TomeStateFor(e)
	if(e in ELEMENT_LIST) return e
	return "Space"

mob/proc/SummonTomes()
	DismissTomes(0)
	var/list/els = MageElements()
	if(!els.len) return
	grimoire_tomes = list()
	var/side = 1
	for(var/e in els)
		var/obj/fx_tome/T = new(src, TomeStateFor(e), side)
		vis_contents += T
		grimoire_tomes += T
		side = -side

mob/proc/DismissTomes(animated = 1)
	if(!grimoire_tomes) return
	for(var/obj/fx_tome/T in grimoire_tomes)
		if(animated)
			T.Dismiss()
		else
			T.closing = 1
			T.owner = null
			vis_contents -= T
			T.loc = null
	grimoire_tomes = null

mob/proc/TomeFlip()
	if(!grimoire_tomes) return
	for(var/obj/fx_tome/T in grimoire_tomes)
		T.Flip()

mob/proc/TomeScrubStale()
	var/list/stale
	for(var/obj/fx_tome/T in vis_contents)
		if(grimoire_tomes && (T in grimoire_tomes)) continue
		if(!stale) stale = list()
		stale += T
	if(!stale) return
	for(var/obj/fx_tome/T in stale)
		vis_contents -= T
		T.closing = 1
		T.owner = null
		T.loc = null

obj/Skills/Buffs/SlotlessBuffs/MageGrimoire
	name = "Grimoire"
	BuffName = "Mage Grimoire"
	TimerLimit = 0
	Copyable = 0
	Cooldown = 0
	NoGCD = 1
	MiscBindable = 1
	ActiveMessage = "calls forth their grimoire."
	OffMessage = "closes their grimoire."
	verb/Grimoire()
		set category = "Skills"
		Trigger(usr)
	Trigger(mob/User, Override = 0)
		if(!User) return 0
		. = ..()
		if(User.CheckSlotless("Mage Grimoire"))
			User.SummonTomes()
		else
			User.DismissTomes()
