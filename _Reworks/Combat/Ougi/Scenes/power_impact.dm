/datum/ougi_scene/stand_in/power_impact
	id = "power_impact"
	category = "Energy"
	stage = "mountain_dusk"
	length_ds = 48
	climax_ds = 30
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "turf Grass1 (Icons/Turfs/Grass.dmi) + building system et_ masks and bevel", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "fighters", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "screen flashes", "source" = "engine flash plate (lightcutin.dmi tinted)", "kind" = "flash", "status" = "placeholder"), list("name" = "impact rings", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "hit", "source" = "preview ring OugiHitSpark (KenShockwaveGold.dmi); live hits draw the strike's own effects", "kind" = "hit", "status" = "placeholder"), list("name" = "light", "source" = "engine light source (AddLightSource)", "kind" = "light", "status" = "placeholder"), list("name" = "energy burst", "source" = "EnergyFX orb burst rows named in the beats", "kind" = "burst", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/stand_in/power_impact/Build()
	beats = list()
	B(0, "actor_face", list("who" = "attacker"))
	B(0, "actor_face", list("who" = "target"))
	B(4, "light", list("at" = "attacker", "radius" = 2, "color" = "#ff3a3a", "alpha" = 180, "life" = 10))
	B(10, "actor_state", list("who" = "attacker", "state" = "Blast"))
	B(18, "burst", list("at" = "target", "radius" = 2, "row" = /obj/Skills/Projectile/Supernova))
	B(27, "flash", list("color" = "#ff3a3a", "in" = 1, "hold" = 1, "out" = 3))
	B(30, "hit")
	B(30, "cam_shake", list("strength" = 8, "time" = 4))
	B(30, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.5, "life" = 6, "blend" = BLEND_ADD))
	B(31, "actor_state", list("who" = "target", "state" = "KB"))
	B(31, "burst", list("at" = "target", "radius" = 4, "row" = /obj/Skills/Projectile/Supernova))
	B(38, "actor_state", list("who" = "attacker", "state" = ""))
	B(48, "hold")
