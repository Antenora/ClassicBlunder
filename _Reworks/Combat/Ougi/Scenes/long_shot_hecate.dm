/datum/ougi_scene/stand_in/long_shot_hecate
	id = "long_shot_hecate"
	category = "Gun"
	stage = "mountain_dusk"
	length_ds = 54
	climax_ds = 34
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "turf Dirt1 (Icons/Turfs/Dirt1.dmi) + building system et_ masks and bevel", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "fighters", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "screen flashes", "source" = "engine flash plate (lightcutin.dmi tinted)", "kind" = "flash", "status" = "placeholder"), list("name" = "impact rings", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "hit", "source" = "preview ring OugiHitSpark (KenShockwaveGold.dmi); live hits draw the strike's own effects", "kind" = "hit", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/stand_in/long_shot_hecate/Build()
	beats = list()
	B(0, "actor_face", list("who" = "attacker"))
	B(0, "actor_face", list("who" = "target"))
	B(2, "cam_move", list("to" = "attacker", "time" = 6))
	B(2, "cam_zoom", list("mag" = 1.3, "time" = 6))
	B(16, "actor_state", list("who" = "attacker", "state" = "Blast"))
	B(26, "cam_move", list("to" = "target", "time" = 4))
	B(26, "cam_zoom", list("mag" = 1.1, "time" = 4))
	B(31, "flash", list("color" = "#ffffff", "in" = 1, "hold" = 1, "out" = 3))
	B(34, "hit")
	B(34, "cam_shake", list("strength" = 6, "time" = 4))
	B(34, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.5, "life" = 6, "blend" = BLEND_ADD))
	B(35, "actor_state", list("who" = "target", "state" = "KB"))
	B(40, "cam_move", list("to" = "camera", "time" = 6))
	B(40, "cam_zoom", list("mag" = 1, "time" = 6))
	B(46, "actor_state", list("who" = "attacker", "state" = ""))
	B(54, "hold")
