/datum/ougi_scene/authored/burst_armed_chain
	id = "burst_armed_chain"
	category = "Armed"
	stage = "burst"
	length_ds = 15
	climax_ds = 0
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "burst stage: Grass1 ground", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "fighters", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "hard cut frames", "source" = "engine flash plate, one tick", "kind" = "cut", "status" = "placeholder"), list("name" = "impact rings", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "hit", "source" = "preview ring OugiHitSpark (KenShockwaveGold.dmi); live hits draw the strike's own effects", "kind" = "hit", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/authored/burst_armed_chain/Build()
	beats = list()
	B(0, "actor_face", list("who" = "self"))
	B(1, "ghost", list("who" = "self", "life" = 5))
	B(1, "actor_move", list("who" = "self", "to" = "target", "dx" = 44, "time" = 1.5))
	B(2, "actor_state", list("who" = "self", "state" = "Attack"))
	B(2, "cut")
	B(3, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -113, "y" = -97, "scale" = 0.3, "life" = 4, "blend" = BLEND_ADD))
	B(4, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.3, "life" = 4, "blend" = BLEND_ADD))
	B(5, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -97, "y" = -113, "scale" = 0.3, "life" = 4, "blend" = BLEND_ADD))
	B(5, "cam_shake", list("strength" = 3, "time" = 3))
	B(8, "actor_face", list("who" = "self"))
	B(9, "actor_state", list("who" = "self", "state" = ""))
	B(9, "actor_move", list("who" = "self", "to" = "self", "time" = 4))
	B(15, "hold")
