// Shadow shit
// Reworked to objs to play nicely with Katen Kyokotsu 

mob/proc/ShadowbringerPassiveActive()
	if(passive_handler)
		if(passive_handler.passives["Shadowbringer"] || passive_handler.tmp_passives["Shadowbringer"])
			return TRUE
	return FALSE

mob/Players/proc/Shadowbringer_ShouldCastShadow()
	if(AdminInviso)
		return FALSE
	if(invisibility > 0)
		return FALSE
	return TRUE

/obj/Effects/Shadowbringer_Shadow
	Lifetime = -1           
	mouse_opacity = 1
	density = 0
	Savable = 0             
	var/tmp/mob/Players/owner
	var/tmp/mob/Players/occupant
	var/tmp/shadow_cache_key

	New(mob/Players/p)
		..(null)   
		owner = p
		appearance_flags |= KEEP_TOGETHER
		color = rgb(8, 8, 10)
		alpha = 150
		layer = MOB_LAYER - 0.01
		var/matrix/T = matrix()
		T.Scale(1, -1)
		transform = T
		RefreshIcon()

	proc/RefreshIcon()
		if(!owner) return
		var/key = "[owner.icon]-[owner.icon_state]-[owner.dir]-[owner.overlays.len]"
		if(key == shadow_cache_key) return
		shadow_cache_key = key
		icon = owner.icon
		icon_state = owner.icon_state
		dir = owner.dir
		overlays.Cut()
		for(var/O in owner.overlays)
			overlays += O
		var/icon/I = icon(owner.icon, owner.icon_state, owner.dir)
		var/h = I.Height()
		if(!h) h = world.icon_size
		var/w = I.Width()
		var/bottom_gap = 0
		for(var/y = 1 to h)
			var/found = 0
			for(var/x = 1 to w)
				if(I.GetPixel(x, y))
					bottom_gap = y - 1
					found = 1
					break
			if(found) break
		pixel_x = owner.pixel_x
		pixel_y = owner.pixel_y - h + (2 * bottom_gap)

	Click(location, control, params)
		var/mob/Players/clicker = usr
		if(istype(clicker) && clicker.HideInShadowsActive && !clicker.KageoniMidTransition)
			clicker.KageoniEnterShadow(src)
			return
		..()

	proc/ReleaseOccupant()
		if(occupant)
			var/mob/Players/o = occupant
			occupant = null
			if(o.HiddenInShadow && o.CurrentShadow == src)
				o.KageoniForceRise()

	Del()
		ReleaseOccupant()
		..()

mob/Players/proc/Shadowbringer_EnsureShadow()
	for(var/obj/Effects/Shadowbringer_Shadow/stale in src.vis_contents)
		if(stale != ShadowbringerShadowObj)
			src.vis_contents -= stale
			if(stale.owner == src) stale.owner = null
			del stale
	if(!ShadowbringerShadowObj)
		ShadowbringerShadowObj = new /obj/Effects/Shadowbringer_Shadow(src)
	var/obj/Effects/Shadowbringer_Shadow/sh = ShadowbringerShadowObj
	if(!(sh in src.vis_contents))
		src.vis_contents += sh
	sh.RefreshIcon()
	if(sh.occupant)
		var/mob/Players/o = sh.occupant
		if(o.HiddenInShadow && o.CurrentShadow == sh && o.loc != src.loc)
			o.loc = src.loc

mob/Players/proc/Shadowbringer_ClearShadow()
	for(var/obj/Effects/Shadowbringer_Shadow/sh in src.vis_contents)
		src.vis_contents -= sh
		sh.ReleaseOccupant()
		sh.owner = null
		del sh
	ShadowbringerShadowObj = null

proc/Shadowbringer_Process()
	if(WorldLoading)
		return
	var/list/lit = list()
	for(var/mob/Players/S in players)
		if(!S.ShadowbringerPassiveActive())
			continue
		var/isKageoniHidden = S.HiddenInShadow || S.HideInShadowsActive
		if(!isKageoniHidden && !S.Shadowbringer_ShouldCastShadow())
			continue
		if(S.Shadowbringer_ShouldCastShadow())
			lit[S] = 1
		for(var/mob/Players/P in view(S))
			if(!P.Shadowbringer_ShouldCastShadow())
				continue
			lit[P] = 1
	for(var/mob/Players/M in players)
		if(lit[M])
			M.Shadowbringer_EnsureShadow()
		else
			var/obj/Effects/Shadowbringer_Shadow/sh = M.ShadowbringerShadowObj
			if(sh && sh.occupant)
				var/mob/Players/o = sh.occupant
				if(o.HiddenInShadow && o.CurrentShadow == sh && o.loc != M.loc)
					o.loc = M.loc
			else
				M.Shadowbringer_ClearShadow()
