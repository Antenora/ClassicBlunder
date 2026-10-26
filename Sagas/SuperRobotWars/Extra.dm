obj/GuardAura
	icon = null // Replace with your shield DMI.
	icon_state = ""
	mouse_opacity = 0
	Grabbable = 0
	Destructable = 0
	Savable = 0
	gfx_transient_visual = 1
	appearance_flags = RESET_COLOR | RESET_ALPHA

mob/var/tmp/obj/GuardAura/guard_aura

mob/proc/HasSpecialGuard()
	if(passive_handler.Get("ATFieldGuard") && Will >= 110 && mech)
		return 1
	else
		return 0

mob/proc/ShowGuardAura()
	if(!Guarding)
		return
	var/sG = HasSpecialGuard()
	if(!sG)
		return
	if(guard_aura)
		return
	var/gIcon = null
	var/gState = ""
	switch(sG)
		if(1)
			gIcon = 'ATFieldBarrier.dmi'
			gState = ""
	if(!gIcon)
		return
	var/list/states = icon_states(gIcon)
	if(!(gState in states))
		return

	var/obj/GuardAura/A = new
	A.icon = gIcon
	A.icon_state = gState
	A.alpha = 255
	A.invisibility = 0

	var/list/offset = EffectPixelCenter(src, gIcon, gState, SOUTH)
	A.pixel_x = offset[1]+16 // i give up :tm:
	A.pixel_y = offset[2]

	A.plane = plane
	A.layer = layer + 0.1

	guard_aura = A
	vis_contents += A

mob/proc/HideGuardAura()
	if(!guard_aura) return

	var/obj/GuardAura/A = guard_aura
	guard_aura = null
	vis_contents -= A
	del A


proc/EffectPixelCenter(atom/source, effect_icon, effect_state = "", effect_dir = SOUTH)
	if(!source || !source.icon || !effect_icon)
		return list(0, 0)

	var/icon/source_art = icon(source.icon, source.icon_state, source.dir)
	var/icon/effect_art = icon(effect_icon, effect_state, effect_dir)

	return list(
		source.pixel_x + round((source_art.Width() - effect_art.Width()) / 2),
		source.pixel_y + round((source_art.Height() - effect_art.Height()) / 2)
	)