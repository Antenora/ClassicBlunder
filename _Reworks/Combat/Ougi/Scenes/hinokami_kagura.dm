/datum/ougi_scene/stand_in/hinokami_kagura
	id = "hinokami_kagura"
	category = "Armed"
	stage = "mountain_dusk"
	length_ds = 54
	climax_ds = 42
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "turf Dirt1 (Icons/Turfs/Dirt1.dmi) + building system et_ masks and bevel", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "fighters", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "screen flashes", "source" = "engine flash plate (lightcutin.dmi tinted)", "kind" = "flash", "status" = "placeholder"), list("name" = "hard cut frames", "source" = "engine flash plate, one tick", "kind" = "cut", "status" = "placeholder"), list("name" = "impact rings", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "hit", "source" = "preview ring OugiHitSpark (KenShockwaveGold.dmi); live hits draw the strike's own effects", "kind" = "hit", "status" = "placeholder"), list("name" = "light", "source" = "engine light source (AddLightSource)", "kind" = "light", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/stand_in/hinokami_kagura/Build()
	beats = list()
	B(0, "actor_face", list("who" = "attacker"))
	B(0, "actor_face", list("who" = "target"))
	B(2, "light", list("at" = "attacker", "radius" = 3, "color" = "#ff9a3a", "alpha" = 150, "life" = 40))
	B(8, "cut")
	B(8, "actor_move", list("who" = "attacker", "to" = "target", "dx" = -24, "time" = 2))
	B(10, "actor_state", list("who" = "attacker", "state" = "Attack"))
	B(12, "actor_move", list("who" = "attacker", "to" = "target", "dx" = -24, "dy" = 0, "time" = 3))
	B(13, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.4, "life" = 8, "blend" = BLEND_ADD))
	B(16, "actor_move", list("who" = "attacker", "to" = "target", "dx" = 0, "dy" = 24, "time" = 3))
	B(17, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.4, "life" = 8, "blend" = BLEND_ADD))
	B(20, "actor_move", list("who" = "attacker", "to" = "target", "dx" = 24, "dy" = 0, "time" = 3))
	B(21, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.4, "life" = 8, "blend" = BLEND_ADD))
	B(24, "actor_move", list("who" = "attacker", "to" = "target", "dx" = 0, "dy" = -24, "time" = 3))
	B(25, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.4, "life" = 8, "blend" = BLEND_ADD))
	B(28, "actor_move", list("who" = "attacker", "to" = "target", "dx" = -24, "dy" = 0, "time" = 3))
	B(29, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.4, "life" = 8, "blend" = BLEND_ADD))
	B(32, "cam_zoom", list("mag" = 1.2, "time" = 4))
	B(39, "flash", list("color" = "#ffb03a", "in" = 1, "hold" = 1, "out" = 3))
	B(42, "hit")
	B(42, "cam_shake", list("strength" = 8, "time" = 4))
	B(42, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.5, "life" = 6, "blend" = BLEND_ADD))
	B(43, "actor_state", list("who" = "target", "state" = "KB"))
	B(46, "actor_move", list("who" = "attacker", "to" = "attacker", "time" = 4))
	B(50, "actor_state", list("who" = "attacker", "state" = ""))
	B(54, "hold")
