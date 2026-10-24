/datum/ougi_scene/stand_in/dimension_slash
	id = "dimension_slash"
	category = "Armed"
	stage = "mountain_dusk"
	length_ds = 54
	climax_ds = 40
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "turf Dirt1 (Icons/Turfs/Dirt1.dmi) + building system et_ masks and bevel", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "fighters", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "screen flashes", "source" = "engine flash plate (lightcutin.dmi tinted)", "kind" = "flash", "status" = "placeholder"), list("name" = "hard cut frames", "source" = "engine flash plate, one tick", "kind" = "cut", "status" = "placeholder"), list("name" = "impact rings", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "hit", "source" = "preview ring OugiHitSpark (KenShockwaveGold.dmi); live hits draw the strike's own effects", "kind" = "hit", "status" = "placeholder"), list("name" = "light", "source" = "engine light source (AddLightSource)", "kind" = "light", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/stand_in/dimension_slash/Build()
	beats = list()
	B(0, "actor_face", list("who" = "attacker"))
	B(0, "actor_face", list("who" = "target"))
	B(2, "light", list("at" = "attacker", "radius" = 3, "color" = "#7a3aff", "alpha" = 160, "life" = 20))
	B(4, "cam_zoom", list("mag" = 1.1, "time" = 8))
	B(14, "actor_state", list("who" = "attacker", "state" = "Attack"))
	B(16, "cut", list("color" = "#000000"))
	B(16, "ghost", list("who" = "attacker", "life" = 6, "alpha" = 140))
	B(16, "actor_move", list("who" = "attacker", "to" = "target", "dx" = 32, "time" = 1))
	B(24, "flash", list("color" = "#000000", "in" = 1, "hold" = 4, "out" = 4))
	B(37, "flash", list("color" = "#ffffff", "in" = 1, "hold" = 1, "out" = 3))
	B(40, "hit")
	B(40, "cam_shake", list("strength" = 12, "time" = 4))
	B(40, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.5, "life" = 6, "blend" = BLEND_ADD))
	B(41, "actor_state", list("who" = "target", "state" = "KB"))
	B(46, "actor_move", list("who" = "attacker", "to" = "attacker", "time" = 4))
	B(50, "actor_state", list("who" = "attacker", "state" = ""))
	B(54, "hold")
