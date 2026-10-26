#define HEAT_BAR_Y 103
#define HEAT_BAR_W 104
#define HEAT_TRACK_L 100
#define HEAT_FILL_X 2
#define HEAT_FILL_CL 1
#define HEAT_FILL_CR 1
#define HEAT_PLATE_W 26
#define HEAT_PLATE_GAP 2
#define HEAT_DIGIT_W 6
#define HEAT_TEXT_RIGHT 4
#define HEAT_TEXT_Y -2
#define HEAT_TEXT_ON "#ffd76a"
#define HEAT_TEXT_DRY "#eb443b"

#if fexists("../../../Icons/Private/Guns/HeatEnergyPlate.png") || fexists("Icons/Private/Guns/HeatEnergyPlate.png")
#define HEAT_EPLATE_RSC 'Icons/Private/Guns/HeatEnergyPlate.png'
#else
#define HEAT_EPLATE_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/HeatPlate.png") || fexists("Icons/Private/Guns/HeatPlate.png")
#define HEAT_PLATE_RSC 'Icons/Private/Guns/HeatPlate.png'
#else
#define HEAT_PLATE_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/HeatTrack.png") || fexists("Icons/Private/Guns/HeatTrack.png")
#define HEAT_TRACK_RSC 'Icons/Private/Guns/HeatTrack.png'
#else
#define HEAT_TRACK_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/HeatFrame.png") || fexists("Icons/Private/Guns/HeatFrame.png")
#define HEAT_FRAME_RSC 'Icons/Private/Guns/HeatFrame.png'
#else
#define HEAT_FRAME_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/HeatFill.png") || fexists("Icons/Private/Guns/HeatFill.png")
#define HEAT_FILL_RSC 'Icons/Private/Guns/HeatFill.png'
#else
#define HEAT_FILL_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/HeatFillHead.png") || fexists("Icons/Private/Guns/HeatFillHead.png")
#define HEAT_FILL_HEAD_RSC 'Icons/Private/Guns/HeatFillHead.png'
#else
#define HEAT_FILL_HEAD_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/HeatLock.png") || fexists("Icons/Private/Guns/HeatLock.png")
#define HEAT_LOCK_RSC 'Icons/Private/Guns/HeatLock.png'
#else
#define HEAT_LOCK_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/HeatLockHead.png") || fexists("Icons/Private/Guns/HeatLockHead.png")
#define HEAT_LOCK_HEAD_RSC 'Icons/Private/Guns/HeatLockHead.png'
#else
#define HEAT_LOCK_HEAD_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/HeatBand.png") || fexists("Icons/Private/Guns/HeatBand.png")
#define HEAT_BAND_RSC 'Icons/Private/Guns/HeatBand.png'
#else
#define HEAT_BAND_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/HeatBandHead.png") || fexists("Icons/Private/Guns/HeatBandHead.png")
#define HEAT_BAND_HEAD_RSC 'Icons/Private/Guns/HeatBandHead.png'
#else
#define HEAT_BAND_HEAD_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/HeatMask.png") || fexists("Icons/Private/Guns/HeatMask.png")
#define HEAT_MASK_RSC 'Icons/Private/Guns/HeatMask.png'
#else
#define HEAT_MASK_RSC 'HUD/bar_fill74.png'
#endif

/proc/HeatCut(k)
	if(k >= HEAT_FILL_CL + HEAT_FILL_CR)
		return HEAT_FILL_X + k - HEAT_FILL_CR
	return HEAT_FILL_X + min(k, HEAT_FILL_CL)

/proc/HeatHeadX(k)
	if(k >= HEAT_FILL_CL + HEAT_FILL_CR)
		return HEAT_FILL_X + k - HEAT_FILL_CR
	return -1

/proc/HeatPx(heat, maxheat)
	return clamp(round(heat * HEAT_TRACK_L / max(maxheat, 1), 1), 0, HEAT_TRACK_L)

/atom/movable/shud/heatbar
	icon = HEAT_PLATE_RSC
	mouse_opacity = 0
	var/atom/movable/shud/orbpart/track
	var/atom/movable/shud/orbpart/band
	var/atom/movable/shud/orbpart/bandhead
	var/atom/movable/shud/orbpart/fill
	var/atom/movable/shud/orbpart/fillhead
	var/atom/movable/shud/orbpart/frame
	var/atom/movable/shud/orbpart/eplate
	var/atom/movable/shud/slottext/etext
	var/shown = 0
	var/band_on = 0
	var/plate_on = 0
	var/last_energy = -1
	var/obj/Items/last_src
	var/last_heat = -1
	var/last_tick = -1
	var/last_over = -1
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")
		track = HeatPart(HEAT_TRACK_RSC, 0.05)
		band = HeatPart(HEAT_BAND_RSC, 0.1)
		band.filters = filter(type="alpha", icon=HEAT_MASK_RSC, x = -HEAT_BAR_W)
		bandhead = HeatPart(HEAT_BAND_HEAD_RSC, 0.15)
		fill = HeatPart(HEAT_FILL_RSC, 0.2)
		fill.filters = filter(type="alpha", icon=HEAT_MASK_RSC, x = -HEAT_BAR_W)
		fillhead = HeatPart(HEAT_FILL_HEAD_RSC, 0.25)
		frame = HeatPart(HEAT_FRAME_RSC, 0.3)
		eplate = HeatPart(HEAT_EPLATE_RSC, 0.3)
		eplate.pixel_x = HEAT_BAR_W + HEAT_PLATE_GAP
		eplate.filters = filter(type="outline", size=1, color="#000000")
		etext = new
		etext.layer = SHUD_LAYER + 0.35
		etext.maptext_height = 16
		etext.maptext_y = HEAT_TEXT_Y
		vis_contents += etext
		SetShown(0)
	Del()
		for(var/atom/movable/o in vis_contents)
			vis_contents -= o
			del o
		track = null
		band = null
		bandhead = null
		fill = null
		fillhead = null
		frame = null
		eplate = null
		etext = null
		last_src = null
		..()
	proc/HeatPart(rsc, lay)
		var/atom/movable/shud/orbpart/p = new
		p.icon = rsc
		p.layer = SHUD_LAYER + lay
		p.mouse_opacity = 0
		vis_contents += p
		return p
	proc/SetShown(on)
		shown = on
		alpha = on ? 255 : 0
		frame.alpha = alpha
		if(!on)
			track.alpha = 0
			band.alpha = 0
			bandhead.alpha = 0
			fill.alpha = 0
			fillhead.alpha = 0
			SetEnergy(0)
			last_src = null
			last_heat = -1
			last_tick = -1
			last_over = -1
	proc/SetEnergy(on, value = 0)
		plate_on = on
		eplate.alpha = (on && shown) ? 255 : 0
		etext.alpha = eplate.alpha
		if(!on)
			last_energy = -1
			return
		var/n = max(0, round(value))
		if(n == last_energy)
			return
		last_energy = n
		var/len = length("[n]")
		etext.maptext_width = HEAT_DIGIT_W * len + 2
		etext.pixel_x = HEAT_BAR_W + HEAT_PLATE_GAP + HEAT_PLATE_W - HEAT_TEXT_RIGHT - HEAT_DIGIT_W * len
		etext.maptext = "<span style=\"[SHUD_FONT_STYLE]; color:[n > 0 ? HEAT_TEXT_ON : HEAT_TEXT_DRY]\">[n]</span>"
	proc/Idle()
		track.alpha = 0
		fill.alpha = 0
		fillhead.alpha = 0
		BandOff()
	proc/BandOff()
		band_on = 0
		band.alpha = 0
		bandhead.alpha = 0
	proc/Ride(atom/movable/shud/orbpart/strip, atom/movable/shud/orbpart/head, k0, k1, time)
		strip.alpha = 255
		strip.filters = filter(type="alpha", icon=HEAT_MASK_RSC, x = HeatCut(k0) - HEAT_BAR_W)
		var/hx = HeatHeadX(k0)
		head.alpha = hx < 0 ? 0 : 255
		head.pixel_x = max(hx, 0)
		if(time <= 0 || k1 == k0)
			return
		animate(strip.filters[1], x = HeatCut(k1) - HEAT_BAR_W, time = time)
		var/hx1 = HeatHeadX(k1)
		if(hx1 >= 0)
			animate(head, pixel_x = hx1, time = time)
		else if(hx >= 0)
			animate(head, pixel_x = HEAT_FILL_X + HEAT_FILL_CL, time = time)
			animate(alpha = 0, time = 0)
	proc/Show(obj/Items/S, heat, maxheat, drop, rem, over, tick)
		var/k0 = HeatPx(heat, maxheat)
		var/k1 = rem > 0 ? HeatPx(max(0, heat - drop), maxheat) : k0
		fill.icon = over ? HEAT_LOCK_RSC : HEAT_FILL_RSC
		fillhead.icon = over ? HEAT_LOCK_HEAD_RSC : HEAT_FILL_HEAD_RSC
		if(!over)
			BandOff()
		else if(!band_on || last_over != 1 || S != last_src)
			band_on = 1
			Ride(band, bandhead, k0, k0, 0)
		else if(tick != last_tick)
			Ride(band, bandhead, HeatPx(last_heat, maxheat), k0, GUN_HEAT_POLL)
		if(k0 <= 0 && !band_on)
			Idle()
			return
		track.alpha = 255
		if(k0 <= 0)
			fill.alpha = 0
			fillhead.alpha = 0
			return
		Ride(fill, fillhead, k0, k1, rem)

client/var/tmp/atom/movable/shud/heatbar/heat_bar

client/InitHeatHUD()
	ResetHeatHUD()
	if(!mob) return
	heat_bar = new
	screen += heat_bar
	PositionHeatHUD()
	RefreshHeatHUD()

client/ResetHeatHUD()
	if(!heat_bar) return
	screen -= heat_bar
	del heat_bar
	heat_bar = null

client/PositionHeatHUD()
	if(!heat_bar) return
	var/cx = GunBarCenterX()
	if(isnull(cx)) return
	var/total = HEAT_BAR_W + (heat_bar.plate_on ? HEAT_PLATE_GAP + HEAT_PLATE_W : 0)
	heat_bar.screen_loc = "1:[cx - round(total / 2)],SOUTH:[HEAT_BAR_Y]"

client/RefreshHeatHUD()
	if(!heat_bar || !mob) return
	var/obj/Items/S = mob.HeatSource()
	if(!S)
		if(heat_bar.shown)
			heat_bar.SetShown(0)
		return
	if(!heat_bar.shown)
		heat_bar.SetShown(1)
		PositionHeatHUD()
	var/obj/Items/Gun/G = S
	var/eon = (istype(G) && G.energy_gun && !G.mech_only) ? 1 : 0
	if(eon != heat_bar.plate_on)
		heat_bar.SetEnergy(eon, eon ? G.energy : 0)
		PositionHeatHUD()
	else if(eon)
		heat_bar.SetEnergy(1, G.energy)
	if(S == heat_bar.last_src && S.heat == heat_bar.last_heat && S.heat_tick == heat_bar.last_tick && S.overheated == heat_bar.last_over)
		return
	var/rem = 0
	if(S.heat > 0 && S.heat_loop)
		rem = max(1, S.heat_tick + GUN_HEAT_POLL - world.time)
	var/drop = mob.HeatDissipationOf(S) * GUN_HEAT_POLL / 10
	heat_bar.Show(S, S.heat, mob.HeatMaxOf(S), drop, rem, S.overheated, S.heat_tick)
	heat_bar.last_src = S
	heat_bar.last_heat = S.heat
	heat_bar.last_tick = S.heat_tick
	heat_bar.last_over = S.overheated
