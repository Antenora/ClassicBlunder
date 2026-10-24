/datum/ougi_scene/authored/burst_unarmed_finisher
	id = "burst_unarmed_finisher"
	category = "Unarmed"
	stage = "burst"
	length_ds = 30
	climax_ds = 19
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "burst stage: Grass1 ground", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "fighters", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "screen flashes", "source" = "engine flash plate (lightcutin.dmi tinted)", "kind" = "flash", "status" = "placeholder"), list("name" = "hard cut frames", "source" = "engine flash plate, one tick", "kind" = "cut", "status" = "placeholder"), list("name" = "impact rings", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "hit", "source" = "preview ring OugiHitSpark (KenShockwaveGold.dmi); live hits draw the strike's own effects", "kind" = "hit", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/authored/burst_unarmed_finisher/Build()
	beats = list()
	B(0, "actor_face", list("who" = "self"))
	B(0, "actor_face", list("who" = "target"))
	B(2, "ghost", list("who" = "self", "life" = 4))
	B(2, "actor_move", list("who" = "self", "to" = "target", "dx" = -20, "time" = 2))
	B(4, "actor_state", list("who" = "self", "state" = "Attack"))
	B(5, "cut")
	B(5, "actor_state", list("who" = "target", "state" = "KB"))
	B(5, "actor_move", list("who" = "target", "to" = "target", "dy" = 72, "time" = 4))
	B(6, "cam_move", list("to" = "target", "dy" = 48, "time" = 5))
	B(8, "ghost", list("who" = "self", "life" = 4))
	B(9, "actor_move", list("who" = "self", "to" = "target", "dy" = 112, "time" = 2))
	B(12, "cam_zoom", list("mag" = 1.2, "time" = 3))
	B(16, "flash", list("color" = "#ffffff", "in" = 1, "hold" = 1, "out" = 3))
	B(18, "actor_move", list("who" = "target", "to" = "target", "time" = 1))
	B(18, "actor_move", list("who" = "self", "to" = "target", "dy" = 28, "time" = 1))
	B(19, "hit")
	B(19, "cam_shake", list("strength" = 8, "time" = 5))
	B(19, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.6, "life" = 6, "blend" = BLEND_ADD))
	B(20, "cam_move", list("to" = "camera", "time" = 5))
	B(22, "cam_zoom", list("mag" = 1, "time" = 4))
	B(24, "actor_move", list("who" = "self", "to" = "self", "time" = 4))
	B(28, "actor_state", list("who" = "self", "state" = ""))
	B(30, "hold")
