#define DEMON_FUSION_TILE_SIZE 32

/mob/Move()
	if(demon_fusion_animating) return 0
	. = ..()

/mob/proc/DemonFusionAnimAbort()
	if(demon_fusion_anim_images && client)
		for(var/image/I in demon_fusion_anim_images)
			client.images -= I
	if(demon_fusion_anim_images)
		for(var/image/I in demon_fusion_anim_images)
			del(I)
		demon_fusion_anim_images = null
	demon_fusion_animating = FALSE

/mob/proc/DemonFusionAnimShouldAbort()
	if(!src || !client) return TRUE
	if(KO || Dead) return TRUE
	if(!demon_fusion_animating) return TRUE
	return FALSE

/mob/proc/PlayDemonFusionAnimation(name_a, name_b, result_name, list/inherited_skills)
	set waitfor = FALSE

	if(!src || !client) return
	if(KO || Dead)
		src << "<font color='#ff6666'>Fusion cancelled.</font>"
		return

	var/datum/demon_data/dd_a = DEMON_DB[name_a]
	var/datum/demon_data/dd_b = DEMON_DB[name_b]
	var/datum/demon_data/dd_r = DEMON_DB[result_name]
	if(!dd_a || !dd_b || !dd_r)
		src << "<font color='#ff6666'>Fusion cancelled (missing demon data).</font>"
		return

	// Lock state
	demon_fusion_animating = TRUE
	demon_fusion_anim_images = list()

	// Anchor the animation around the convergence point (5 tiles above player).
	var/turf/converge = locate(src.x, src.y + 5, src.z)
	if(!converge)
		// fallback to player's tile
		converge = src.loc

	// --- Image A (left ingredient) ---
	var/image/img_a = image(dd_a.demon_icon, converge, dd_a.demon_icon_state)
	img_a.appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_TOGETHER
	img_a.pixel_x = -4 * DEMON_FUSION_TILE_SIZE
	img_a.pixel_y = -3 * DEMON_FUSION_TILE_SIZE
	img_a.alpha = 0
	img_a.layer = MOB_LAYER + 10
	img_a.plane = 5
	img_a.mouse_opacity = 0

	// --- Image B (right ingredient) ---
	var/image/img_b = image(dd_b.demon_icon, converge, dd_b.demon_icon_state)
	img_b.appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_TOGETHER
	img_b.pixel_x = 4 * DEMON_FUSION_TILE_SIZE
	img_b.pixel_y = -3 * DEMON_FUSION_TILE_SIZE
	img_b.alpha = 0
	img_b.layer = MOB_LAYER + 10
	img_b.plane = 5
	img_b.mouse_opacity = 0

	// --- Dark portal (spawned later, layered above merged ingredients, below result) ---
	var/image/img_portal = image('Icons/Effects/DarkPortal.dmi', converge)
	img_portal.appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_TOGETHER
	img_portal.pixel_x = -34
	img_portal.pixel_y = -34
	img_portal.alpha = 0
	img_portal.layer = MOB_LAYER + 11
	img_portal.plane = 5
	img_portal.mouse_opacity = 0

	// --- Result demon (spawned last, layered above portal) ---
	var/image/img_r = image(dd_r.demon_icon, converge, dd_r.demon_icon_state)
	img_r.appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_TOGETHER
	img_r.pixel_x = 0
	img_r.pixel_y = 0
	img_r.alpha = 0
	img_r.color = "#000000"  // start as silhouette
	img_r.layer = MOB_LAYER + 12
	img_r.plane = 5
	img_r.mouse_opacity = 0

	demon_fusion_anim_images += img_a
	demon_fusion_anim_images += img_b
	demon_fusion_anim_images += img_portal
	demon_fusion_anim_images += img_r

	client.images += img_a
	client.images += img_b
	client.images += img_portal
	client.images += img_r

	animate(img_a, alpha = 255, time = 5, easing = SINE_EASING)
	animate(img_b, alpha = 255, time = 5, easing = SINE_EASING)
	sleep(5)
	if(DemonFusionAnimShouldAbort()) { DemonFusionAnimAbort(); return }

	// t = 5..15 : Turn pitch black
	animate(img_a, color = "#000000", time = 10, easing = SINE_EASING)
	animate(img_b, color = "#000000", time = 10, easing = SINE_EASING)
	sleep(10)
	if(DemonFusionAnimShouldAbort()) { DemonFusionAnimAbort(); return }

	// t = 15..35 : Rise and converge to center point
	animate(img_a, pixel_x = 0, pixel_y = 0, time = 20, easing = SINE_EASING)
	animate(img_b, pixel_x = 0, pixel_y = 0, time = 20, easing = SINE_EASING)
	// Portal begins to appear just before they finish converging
	sleep(15)
	if(DemonFusionAnimShouldAbort()) { DemonFusionAnimAbort(); return }

	// t = 30 : Portal fades in at convergence point
	animate(img_portal, alpha = 255, time = 5, easing = SINE_EASING)
	sleep(5)
	if(DemonFusionAnimShouldAbort()) { DemonFusionAnimAbort(); return }

	// t = 35..43 : Merged silhouettes fade out under the portal
	animate(img_a, alpha = 0, time = 8, easing = SINE_EASING)
	animate(img_b, alpha = 0, time = 8, easing = SINE_EASING)
	sleep(8)
	if(DemonFusionAnimShouldAbort()) { DemonFusionAnimAbort(); return }

	// t = 43..63 : 2 second hold on the portal
	sleep(20)
	if(DemonFusionAnimShouldAbort()) { DemonFusionAnimAbort(); return }

	// t = 63..73 : Result demon fades in as a pitch-black silhouette
	animate(img_r, alpha = 255, time = 10, easing = SINE_EASING)
	sleep(10)
	if(DemonFusionAnimShouldAbort()) { DemonFusionAnimAbort(); return }

	// t = 73..83 : Silhouette colour fades away, revealing the demon
	animate(img_r, color = "#ffffff", time = 10, easing = SINE_EASING)
	sleep(10)
	if(DemonFusionAnimShouldAbort()) { DemonFusionAnimAbort(); return }

	// Portal fades out behind the revealed demon
	animate(img_portal, alpha = 0, time = 5, easing = SINE_EASING)

	// t = 83..113 : 3 second hold on the revealed result
	sleep(30)
	if(DemonFusionAnimShouldAbort()) { DemonFusionAnimAbort(); return }

	// Cleanup + finalize
	DemonFusionAnimAbort()  // tears down images + clears flag

	// Now actually perform the data swap and message the player.
	FinalizeFusion(name_a, name_b, result_name, inherited_skills)

#undef DEMON_FUSION_TILE_SIZE
