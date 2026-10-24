/datum/ougi_scene/authored/burst_gun_finisher
	id = "burst_gun_finisher"
	category = "Gun"
	stage = "burst"
	length_ds = 30
	climax_ds = 19
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "burst stage: Grass1 ground", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "fighters", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "screen flashes", "source" = "engine flash plate (lightcutin.dmi tinted)", "kind" = "flash", "status" = "placeholder"), list("name" = "impact rings", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "hit", "source" = "preview ring OugiHitSpark (KenShockwaveGold.dmi); live hits draw the strike's own effects", "kind" = "hit", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/authored/burst_gun_finisher/Build()
	beats = list()
	B(0, "actor_face", list("who" = "self"))
	B(0, "actor_face", list("who" = "target"))
	B(2, "actor_state", list("who" = "self", "state" = "Blast"))
	B(3, "cam_zoom", list("mag" = 1.15, "time" = 3))
	B(4, "slowmo", list("scale" = 2))
	B(5, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -129, "y" = -95, "scale" = 0.18, "life" = 6, "blend" = BLEND_ADD))
	B(5, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -117, "y" = -101, "scale" = 0.18, "life" = 6, "blend" = BLEND_ADD))
	B(5, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.18, "life" = 6, "blend" = BLEND_ADD))
	B(5, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -93, "y" = -109, "scale" = 0.18, "life" = 6, "blend" = BLEND_ADD))
	B(5, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -81, "y" = -115, "scale" = 0.18, "life" = 6, "blend" = BLEND_ADD))
	B(8, "cam_shake", list("strength" = 3, "time" = 3))
	B(10, "slowmo", list("scale" = 1))
	B(12, "cam_move", list("to" = "target", "time" = 4))
	B(14, "cam_zoom", list("mag" = 1.6, "time" = 3))
	B(17, "flash", list("color" = "#ffffff", "in" = 1, "hold" = 1, "out" = 3))
	B(19, "hit")
	B(19, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.6, "life" = 6, "blend" = BLEND_ADD))
	B(19, "cam_shake", list("strength" = 7, "time" = 4))
	B(19, "actor_state", list("who" = "target", "state" = "KB"))
	B(21, "cam_zoom", list("mag" = 1, "time" = 4))
	B(21, "cam_move", list("to" = "camera", "time" = 5))
	B(26, "actor_state", list("who" = "self", "state" = ""))
	B(30, "hold")
