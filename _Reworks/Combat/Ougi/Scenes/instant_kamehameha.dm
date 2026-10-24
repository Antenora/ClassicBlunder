/datum/ougi_scene/stand_in/instant_kamehameha
	id = "instant_kamehameha"
	category = "Energy"
	stage = "mountain_dusk"
	length_ds = 52
	climax_ds = 26
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "turf Grass1 (Icons/Turfs/Grass.dmi) + building system et_ masks and bevel", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "fighters", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "screen flashes", "source" = "engine flash plate (lightcutin.dmi tinted)", "kind" = "flash", "status" = "placeholder"), list("name" = "hard cut frames", "source" = "engine flash plate, one tick", "kind" = "cut", "status" = "placeholder"), list("name" = "impact rings", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "hit", "source" = "preview ring OugiHitSpark (KenShockwaveGold.dmi); live hits draw the strike's own effects", "kind" = "hit", "status" = "placeholder"), list("name" = "light", "source" = "engine light source (AddLightSource)", "kind" = "light", "status" = "placeholder"), list("name" = "energy beam", "source" = "EnergyFX feint of the beam row named in the beats", "kind" = "beam", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/stand_in/instant_kamehameha/Build()
	beats = list()
	B(0, "actor_face", list("who" = "attacker"))
	B(0, "actor_face", list("who" = "target"))
	B(2, "light", list("at" = "attacker", "radius" = 2, "color" = "#3a8dff", "alpha" = 160, "life" = 14))
	B(4, "actor_state", list("who" = "attacker", "state" = "Blast"))
	B(14, "cut")
	B(14, "ghost", list("who" = "attacker", "life" = 4, "alpha" = 140))
	B(15, "actor_move", list("who" = "attacker", "to" = "target", "dx" = -24, "time" = 1))
	B(18, "beam", list("who" = "attacker", "row" = /obj/Skills/Projectile/Beams/Kamehameha))
	B(23, "flash", list("color" = "#9ad8ff", "in" = 1, "hold" = 1, "out" = 3))
	B(26, "hit")
	B(26, "cam_shake", list("strength" = 10, "time" = 4))
	B(26, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.5, "life" = 6, "blend" = BLEND_ADD))
	B(27, "actor_state", list("who" = "target", "state" = "KB"))
	B(28, "actor_move", list("who" = "target", "dx" = 64, "time" = 12))
	B(40, "flash", list("color" = "#ffffff", "in" = 2, "hold" = 3, "out" = 5))
	B(44, "actor_move", list("who" = "attacker", "to" = "attacker", "time" = 4))
	B(48, "actor_state", list("who" = "attacker", "state" = ""))
	B(52, "hold")
