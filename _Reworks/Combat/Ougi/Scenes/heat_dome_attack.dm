/datum/ougi_scene/stand_in/heat_dome_attack
	id = "heat_dome_attack"
	category = "Energy"
	stage = "mountain_dusk"
	length_ds = 50
	climax_ds = 34
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "turf Grass1 (Icons/Turfs/Grass.dmi) + building system et_ masks and bevel", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "fighters", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "screen flashes", "source" = "engine flash plate (lightcutin.dmi tinted)", "kind" = "flash", "status" = "placeholder"), list("name" = "impact rings", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "hit", "source" = "preview ring OugiHitSpark (KenShockwaveGold.dmi); live hits draw the strike's own effects", "kind" = "hit", "status" = "placeholder"), list("name" = "light", "source" = "engine light source (AddLightSource)", "kind" = "light", "status" = "placeholder"), list("name" = "energy burst", "source" = "EnergyFX orb burst rows named in the beats", "kind" = "burst", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/stand_in/heat_dome_attack/Build()
	beats = list()
	B(0, "actor_face", list("who" = "attacker"))
	B(0, "actor_face", list("who" = "target"))
	B(4, "actor_state", list("who" = "attacker", "state" = "Blast"))
	B(4, "light", list("at" = "attacker", "radius" = 3, "color" = "#9ad8ff", "alpha" = 150, "life" = 20))
	B(12, "burst", list("at" = "target", "radius" = 3, "row" = /obj/Skills/Projectile/Big_Bang_Attack))
	B(22, "cam_zoom", list("mag" = 1.15, "time" = 6))
	B(28, "burst", list("at" = "target", "radius" = 4, "row" = /obj/Skills/Projectile/Big_Bang_Attack))
	B(31, "flash", list("color" = "#c8e8ff", "in" = 1, "hold" = 1, "out" = 3))
	B(34, "hit")
	B(34, "cam_shake", list("strength" = 10, "time" = 4))
	B(34, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.5, "life" = 6, "blend" = BLEND_ADD))
	B(35, "actor_state", list("who" = "target", "state" = "KB"))
	B(36, "actor_move", list("who" = "target", "dy" = 48, "time" = 8))
	B(44, "actor_state", list("who" = "attacker", "state" = ""))
	B(50, "hold")
