#define AMMO_LARGE 1

#define AMMO_BAR_Y 103
#define AMMO_BAR_PAD 2
#define AMMO_MAX_SLOTS 60
#define AMMO_SPENT_FADE 4
#define AMMO_DRY_ALPHA 110

#if AMMO_LARGE

#define AMMO_SLOT_PITCH 4

#if fexists("../../../Icons/Private/Guns/AmmoPlateL.dmi") || fexists("Icons/Private/Guns/AmmoPlateL.dmi")
#define AMMO_PLATE_RSC 'Icons/Private/Guns/AmmoPlateL.dmi'
#else
#define AMMO_PLATE_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/AmmoFrameL.dmi") || fexists("Icons/Private/Guns/AmmoFrameL.dmi")
#define AMMO_FRAME_RSC 'Icons/Private/Guns/AmmoFrameL.dmi'
#else
#define AMMO_FRAME_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/AmmoLitL.png") || fexists("Icons/Private/Guns/AmmoLitL.png")
#define AMMO_LIT_RSC 'Icons/Private/Guns/AmmoLitL.png'
#else
#define AMMO_LIT_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/AmmoSpentL.png") || fexists("Icons/Private/Guns/AmmoSpentL.png")
#define AMMO_SPENT_RSC 'Icons/Private/Guns/AmmoSpentL.png'
#else
#define AMMO_SPENT_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/AmmoMaskL.png") || fexists("Icons/Private/Guns/AmmoMaskL.png")
#define AMMO_MASK_RSC 'Icons/Private/Guns/AmmoMaskL.png'
#else
#define AMMO_MASK_RSC 'HUD/bar_fill74.png'
#endif

#else

#define AMMO_SLOT_PITCH 3

#if fexists("../../../Icons/Private/Guns/AmmoPlate.dmi") || fexists("Icons/Private/Guns/AmmoPlate.dmi")
#define AMMO_PLATE_RSC 'Icons/Private/Guns/AmmoPlate.dmi'
#else
#define AMMO_PLATE_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/AmmoFrame.dmi") || fexists("Icons/Private/Guns/AmmoFrame.dmi")
#define AMMO_FRAME_RSC 'Icons/Private/Guns/AmmoFrame.dmi'
#else
#define AMMO_FRAME_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/AmmoLit.png") || fexists("Icons/Private/Guns/AmmoLit.png")
#define AMMO_LIT_RSC 'Icons/Private/Guns/AmmoLit.png'
#else
#define AMMO_LIT_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/AmmoSpent.png") || fexists("Icons/Private/Guns/AmmoSpent.png")
#define AMMO_SPENT_RSC 'Icons/Private/Guns/AmmoSpent.png'
#else
#define AMMO_SPENT_RSC 'HUD/bar_fill74.png'
#endif

#if fexists("../../../Icons/Private/Guns/AmmoMask.png") || fexists("Icons/Private/Guns/AmmoMask.png")
#define AMMO_MASK_RSC 'Icons/Private/Guns/AmmoMask.png'
#else
#define AMMO_MASK_RSC 'HUD/bar_fill74.png'
#endif

#endif

#define AMMO_STRIP_W (AMMO_SLOT_PITCH * AMMO_MAX_SLOTS + AMMO_BAR_PAD + 1)

/proc/AmmoBarWidth(n)
	return AMMO_SLOT_PITCH * n + AMMO_BAR_PAD + 1

/proc/AmmoCut(k)
	return AMMO_SLOT_PITCH * k + 1

/atom/movable/shud/ammobar
	icon = AMMO_PLATE_RSC
	mouse_opacity = 0
	var/atom/movable/shud/orbpart/spent
	var/atom/movable/shud/orbpart/lit
	var/atom/movable/shud/orbpart/frame
	var/shown_mag = 0
	var/shown_loaded = -1
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")
		spent = new
		spent.icon = AMMO_SPENT_RSC
		spent.layer = SHUD_LAYER + 0.1
		spent.alpha = 0
		spent.filters = filter(type="alpha", icon=AMMO_MASK_RSC, x = -AMMO_STRIP_W)
		lit = new
		lit.icon = AMMO_LIT_RSC
		lit.layer = SHUD_LAYER + 0.2
		lit.filters = filter(type="alpha", icon=AMMO_MASK_RSC, x = -AMMO_STRIP_W)
		frame = new
		frame.icon = AMMO_FRAME_RSC
		frame.layer = SHUD_LAYER + 0.3
		vis_contents += spent
		vis_contents += lit
		vis_contents += frame
	Del()
		for(var/atom/movable/o in vis_contents)
			vis_contents -= o
			del o
		spent = null
		lit = null
		frame = null
		..()
	proc/SetShown(on, dry)
		var/a = on ? 255 : 0
		alpha = a
		if(lit) lit.alpha = a
		if(frame) frame.alpha = on ? (dry ? AMMO_DRY_ALPHA : 255) : 0
		if(!on && spent) spent.alpha = 0
	proc/SetMag(n)
		if(n == shown_mag) return
		shown_mag = n
		icon_state = "[n]"
		if(frame) frame.icon_state = "[n]"
		shown_loaded = -1
	proc/SetLoaded(n)
		if(n == shown_loaded) return
		var/prev = shown_loaded
		shown_loaded = n
		var/cut = AmmoCut(n) - AMMO_STRIP_W
		lit.filters = filter(type="alpha", icon=AMMO_MASK_RSC, x = cut)
		if(prev > n)
			spent.alpha = 255
			spent.filters = filter(type="alpha", icon=AMMO_MASK_RSC, x = AmmoCut(prev) - AMMO_STRIP_W)
			animate(spent.filters[1], x = cut, time = AMMO_SPENT_FADE, easing = SINE_EASING)
			animate(spent, alpha = 0, time = AMMO_SPENT_FADE, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
		else
			spent.alpha = 0

client/var/tmp/atom/movable/shud/ammobar/ammo_bar

client/proc/InitHeatHUD()
	return

client/proc/ResetHeatHUD()
	return

client/proc/PositionHeatHUD()
	return

client/proc/RefreshHeatHUD()
	return

client/proc/GunBarCenterX()
	var/list/v = splittext("[view]", "x")
	if(v.len < 2) return null
	var/tw = text2num(v[1])
	if(!tw) return null
	return round((tw * world.icon_size) / 2) + BELT_ROW_LEFT + round(BELT_SLOTS * BELT_PITCH / 2)

client/InitAmmoHUD()
	ResetAmmoHUD()
	if(!mob) return
	ammo_bar = new
	ammo_bar.SetShown(0)
	screen += ammo_bar
	InitHeatHUD()
	RefreshAmmoHUD()

client/ResetAmmoHUD()
	ResetHeatHUD()
	if(!ammo_bar) return
	screen -= ammo_bar
	del ammo_bar
	ammo_bar = null

client/PositionAmmoHUD()
	PositionHeatHUD()
	if(!ammo_bar || ammo_bar.shown_mag <= 0) return
	var/cx = GunBarCenterX()
	if(isnull(cx)) return
	ammo_bar.screen_loc = "1:[cx - round(AmmoBarWidth(ammo_bar.shown_mag) / 2)],SOUTH:[AMMO_BAR_Y]"

client/RefreshAmmoHUD()
	RefreshHeatHUD()
	if(!ammo_bar) return
	var/obj/Items/Gun/G = mob ? mob.EquippedGun() : null
	if(!G || G.MagSize <= 0 || G.energy_gun || G.mech_only || mob.HeatSource())
		if(ammo_bar.shown_mag)
			ammo_bar.shown_mag = 0
			ammo_bar.shown_loaded = -1
			ammo_bar.SetShown(0)
		return
	var/mag = min(G.MagSize, AMMO_MAX_SLOTS)
	var/loaded = min(max(G.Loaded, 0), mag)
	if(mag != ammo_bar.shown_mag)
		ammo_bar.SetMag(mag)
		PositionAmmoHUD()
	if(loaded != ammo_bar.shown_loaded)
		ammo_bar.SetLoaded(loaded)
		ammo_bar.SetShown(1, loaded <= 0)
