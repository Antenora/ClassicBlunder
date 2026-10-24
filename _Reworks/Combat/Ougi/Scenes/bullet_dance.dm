/datum/ougi_scene/stand_in/bullet_dance
	id = "bullet_dance"
	category = "Gun"
	stage = "mountain_dusk"
	length_ds = 54
	climax_ds = 40
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "turf Dirt1 (Icons/Turfs/Dirt1.dmi) + building system et_ masks and bevel", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "fighters", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "screen flashes", "source" = "engine flash plate (lightcutin.dmi tinted)", "kind" = "flash", "status" = "placeholder"), list("name" = "impact rings", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "hit", "source" = "preview ring OugiHitSpark (KenShockwaveGold.dmi); live hits draw the strike's own effects", "kind" = "hit", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/stand_in/bullet_dance/Build()
	beats = list()
	B(0, "actor_face", list("who" = "attacker"))
	B(0, "actor_face", list("who" = "target"))
	B(4, "actor_state", list("who" = "attacker", "state" = "Blast"))
	B(8, "actor_face", list("who" = "attacker", "dir" = NORTH))
	B(8, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.2, "life" = 3, "blend" = BLEND_ADD))
	B(11, "actor_face", list("who" = "attacker", "dir" = EAST))
	B(11, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.2, "life" = 3, "blend" = BLEND_ADD))
	B(14, "actor_face", list("who" = "attacker", "dir" = SOUTH))
	B(14, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.2, "life" = 3, "blend" = BLEND_ADD))
	B(17, "actor_face", list("who" = "attacker", "dir" = WEST))
	B(17, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.2, "life" = 3, "blend" = BLEND_ADD))
	B(20, "actor_face", list("who" = "attacker", "dir" = NORTH))
	B(20, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.2, "life" = 3, "blend" = BLEND_ADD))
	B(23, "actor_face", list("who" = "attacker", "dir" = EAST))
	B(23, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.2, "life" = 3, "blend" = BLEND_ADD))
	B(26, "actor_face", list("who" = "attacker", "dir" = SOUTH))
	B(26, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.2, "life" = 3, "blend" = BLEND_ADD))
	B(29, "actor_face", list("who" = "attacker", "dir" = WEST))
	B(29, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.2, "life" = 3, "blend" = BLEND_ADD))
	B(34, "actor_face", list("who" = "attacker"))
	B(37, "flash", list("color" = "#ff9a3a", "in" = 1, "hold" = 1, "out" = 3))
	B(40, "hit")
	B(40, "cam_shake", list("strength" = 10, "time" = 4))
	B(40, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.5, "life" = 6, "blend" = BLEND_ADD))
	B(41, "actor_state", list("who" = "target", "state" = "KB"))
	B(42, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.9, "life" = 8, "blend" = BLEND_ADD))
	B(46, "actor_state", list("who" = "attacker", "state" = ""))
	B(54, "hold")
