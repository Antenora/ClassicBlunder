/datum/ougi_scene/stand_in/high_noon
	id = "high_noon"
	category = "Gun"
	stage = "mountain_dusk"
	length_ds = 50
	climax_ds = 32
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "turf Dirt1 (Icons/Turfs/Dirt1.dmi) + building system et_ masks and bevel", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "attacker and target bodies", "source" = "the fighters' own sprites (Lab: base frisky-male_tan_brown.dmi)", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "sun-glare flash and climax flash", "source" = "engine flash plate (lightcutin.dmi tinted)", "kind" = "flash", "status" = "placeholder"), list("name" = "climax ring", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "preview hit ring", "source" = "OugiHitSpark: KenShockwaveGold.dmi", "kind" = "hit", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/stand_in/high_noon/Build()
	beats = list()
	B(0, "actor_face", list("who" = "attacker"))
	B(0, "actor_face", list("who" = "target"))
	B(2, "cam_zoom", list("mag" = 1.25, "time" = 14))
	B(4, "flash", list("color" = "#ffe8b0", "in" = 6, "hold" = 10, "out" = 6))
	B(26, "actor_state", list("who" = "attacker", "state" = "Blast"))
	B(29, "flash", list("color" = "#ffffff", "in" = 1, "hold" = 1, "out" = 3))
	B(32, "hit")
	B(32, "cam_shake", list("strength" = 4, "time" = 4))
	B(32, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.5, "life" = 6, "blend" = BLEND_ADD))
	B(33, "actor_state", list("who" = "target", "state" = "KB"))
	B(36, "cam_zoom", list("mag" = 1, "time" = 6))
	B(40, "actor_state", list("who" = "attacker", "state" = ""))
	B(50, "hold")
