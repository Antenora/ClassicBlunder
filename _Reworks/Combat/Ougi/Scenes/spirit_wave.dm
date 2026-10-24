/datum/ougi_scene/stand_in/spirit_wave
	id = "spirit_wave"
	category = "Energy"
	stage = "mountain_dusk"
	length_ds = 48
	climax_ds = 28
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "turf Grass1 (Icons/Turfs/Grass.dmi) + building system et_ masks and bevel", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "fighters", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "screen flashes", "source" = "engine flash plate (lightcutin.dmi tinted)", "kind" = "flash", "status" = "placeholder"), list("name" = "hard cut frames", "source" = "engine flash plate, one tick", "kind" = "cut", "status" = "placeholder"), list("name" = "impact rings", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "hit", "source" = "preview ring OugiHitSpark (KenShockwaveGold.dmi); live hits draw the strike's own effects", "kind" = "hit", "status" = "placeholder"), list("name" = "light", "source" = "engine light source (AddLightSource)", "kind" = "light", "status" = "placeholder"), list("name" = "energy burst", "source" = "EnergyFX orb burst rows named in the beats", "kind" = "burst", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/stand_in/spirit_wave/Build()
	beats = list()
	B(0, "actor_face", list("who" = "attacker"))
	B(0, "actor_face", list("who" = "target"))
	B(4, "cut")
	B(4, "actor_move", list("who" = "attacker", "to" = "target", "dx" = -20, "time" = 6))
	B(12, "light", list("at" = "attacker", "radius" = 3, "color" = "#3ea8fa", "alpha" = 170, "life" = 16))
	B(20, "actor_state", list("who" = "attacker", "state" = "Blast"))
	B(22, "burst", list("at" = "target", "radius" = 2, "row" = /obj/Skills/Projectile/Spirit_Gun_Mega))
	B(25, "flash", list("color" = "#9ad8ff", "in" = 1, "hold" = 1, "out" = 3))
	B(28, "hit")
	B(28, "cam_shake", list("strength" = 8, "time" = 4))
	B(28, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.5, "life" = 6, "blend" = BLEND_ADD))
	B(29, "actor_state", list("who" = "target", "state" = "KB"))
	B(30, "actor_move", list("who" = "target", "dx" = 48, "time" = 10))
	B(36, "actor_move", list("who" = "attacker", "to" = "attacker", "time" = 4))
	B(40, "actor_state", list("who" = "attacker", "state" = ""))
	B(48, "hold")
