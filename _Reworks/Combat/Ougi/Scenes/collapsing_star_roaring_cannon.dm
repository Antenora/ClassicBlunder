/datum/ougi_scene/stand_in/collapsing_star_roaring_cannon
	id = "collapsing_star_roaring_cannon"
	category = "Energy"
	stage = "mountain_dusk"
	length_ds = 58
	climax_ds = 40
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "turf Grass1 (Icons/Turfs/Grass.dmi) + building system et_ masks and bevel", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "fighters", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "screen flashes", "source" = "engine flash plate (lightcutin.dmi tinted)", "kind" = "flash", "status" = "placeholder"), list("name" = "impact rings", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "hit", "source" = "preview ring OugiHitSpark (KenShockwaveGold.dmi); live hits draw the strike's own effects", "kind" = "hit", "status" = "placeholder"), list("name" = "light", "source" = "engine light source (AddLightSource)", "kind" = "light", "status" = "placeholder"), list("name" = "energy beam", "source" = "EnergyFX feint of the beam row named in the beats", "kind" = "beam", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/stand_in/collapsing_star_roaring_cannon/Build()
	beats = list()
	B(0, "actor_face", list("who" = "attacker"))
	B(0, "actor_face", list("who" = "target"))
	B(2, "actor_move", list("who" = "attacker", "dy" = 24, "time" = 10))
	B(6, "light", list("at" = "attacker", "radius" = 5, "color" = "#ffb060", "alpha" = 200, "life" = 40))
	B(14, "cam_zoom", list("mag" = 1.15, "time" = 8))
	B(22, "actor_state", list("who" = "attacker", "state" = "Blast"))
	B(24, "beam", list("who" = "attacker", "row" = /obj/Skills/Projectile/Beams/Big/Final_Flash))
	B(30, "cam_shake", list("strength" = 4, "time" = 10))
	B(37, "flash", list("color" = "#ffffff", "in" = 1, "hold" = 1, "out" = 3))
	B(40, "hit")
	B(40, "cam_shake", list("strength" = 12, "time" = 4))
	B(40, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.5, "life" = 6, "blend" = BLEND_ADD))
	B(41, "actor_state", list("who" = "target", "state" = "KB"))
	B(42, "actor_move", list("who" = "target", "dx" = 48, "time" = 10))
	B(48, "flash", list("color" = "#ffffff", "in" = 2, "hold" = 3, "out" = 5))
	B(52, "actor_move", list("who" = "attacker", "to" = "attacker", "time" = 4))
	B(56, "actor_state", list("who" = "attacker", "state" = ""))
	B(58, "hold")
