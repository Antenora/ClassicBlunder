/datum/ougi_scene/authored/burst_unarmed_chain
	id = "burst_unarmed_chain"
	category = "Unarmed"
	stage = "burst"
	length_ds = 15
	climax_ds = 0
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "burst stage: Grass1 ground", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage", "status" = "placeholder"), list("name" = "fighters", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "impact rings", "source" = "OUGI_RING_ICON KenShockwaveGold.dmi additive", "kind" = "fx", "match" = list("icon" = OUGI_RING_ICON), "status" = "placeholder"), list("name" = "hit", "source" = "preview ring OugiHitSpark (KenShockwaveGold.dmi); live hits draw the strike's own effects", "kind" = "hit", "status" = "placeholder"))
	icon_defines = list("OUGI_RING_ICON" = OUGI_RING_ICON)

/datum/ougi_scene/authored/burst_unarmed_chain/Build()
	beats = list()
	B(0, "actor_face", list("who" = "self"))
	B(0, "ghost", list("who" = "self", "life" = 4))
	B(1, "actor_move", list("who" = "self", "to" = "target", "dx" = -20, "time" = 2))
	B(3, "actor_state", list("who" = "self", "state" = "Attack"))
	B(3, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -111, "y" = -101, "scale" = 0.2, "life" = 3, "blend" = BLEND_ADD))
	B(5, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -99, "y" = -107, "scale" = 0.2, "life" = 3, "blend" = BLEND_ADD))
	B(5, "cam_shake", list("strength" = 2, "time" = 2))
	B(7, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -109, "y" = -111, "scale" = 0.25, "life" = 3, "blend" = BLEND_ADD))
	B(9, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -101, "y" = -99, "scale" = 0.25, "life" = 3, "blend" = BLEND_ADD))
	B(11, "fx", list("at" = "target", "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = 0.35, "life" = 4, "blend" = BLEND_ADD))
	B(11, "cam_shake", list("strength" = 4, "time" = 3))
	B(12, "actor_state", list("who" = "self", "state" = ""))
	B(12, "actor_move", list("who" = "self", "to" = "self", "time" = 3))
	B(15, "hold")
