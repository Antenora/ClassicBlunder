/datum/ougi_scene/stand_in/burning_attack
	id = "burning_attack"
	category = "Energy"
	stage = "mountain_dusk"
	length_ds = 52
	climax_ds = 36
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "turf Grass1 (Icons/Turfs/Grass.dmi) + building system et_ masks and bevel", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "fighters", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "screen flashes", "source" = "engine flash plate (lightcutin.dmi tinted)", "kind" = "flash", "status" = "placeholder"), list("name" = "hard cut frames", "source" = "engine flash plate, one tick", "kind" = "cut", "status" = "placeholder"), list("name" = "impact rings", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "hit", "source" = "preview ring OugiHitSpark (KenShockwaveGold.dmi); live hits draw the strike's own effects", "kind" = "hit", "status" = "placeholder"), list("name" = "energy burst", "source" = "EnergyFX orb burst rows named in the beats", "kind" = "burst", "status" = "placeholder"), list("name" = "energy beam", "source" = "EnergyFX feint of the beam row named in the beats", "kind" = "beam", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/stand_in/burning_attack/Build()
	beats = list()
	B(0, "actor_face", list("who" = "attacker"))
	B(0, "actor_face", list("who" = "target"))
	B(4, "cut")
	B(4, "actor_state", list("who" = "attacker", "state" = "Blast"))
	B(7, "cut")
	B(7, "actor_state", list("who" = "attacker", "state" = ""))
	B(10, "cut")
	B(10, "actor_state", list("who" = "attacker", "state" = "Blast"))
	B(13, "cut")
	B(13, "actor_state", list("who" = "attacker", "state" = ""))
	B(16, "cut")
	B(16, "actor_state", list("who" = "attacker", "state" = "Blast"))
	B(19, "actor_state", list("who" = "attacker", "state" = "Blast"))
	B(22, "beam", list("who" = "attacker", "row" = /obj/Skills/Projectile/Beams/Big/Final_Flash))
	B(33, "flash", list("color" = "#ffb03a", "in" = 1, "hold" = 1, "out" = 3))
	B(36, "hit")
	B(36, "cam_shake", list("strength" = 8, "time" = 4))
	B(36, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.5, "life" = 6, "blend" = BLEND_ADD))
	B(37, "actor_state", list("who" = "target", "state" = "KB"))
	B(40, "burst", list("at" = "target", "radius" = 3, "row" = /obj/Skills/Projectile/Spirit_Ball))
	B(44, "actor_state", list("who" = "attacker", "state" = ""))
	B(52, "hold")
