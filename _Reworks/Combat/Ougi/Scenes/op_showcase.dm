/datum/ougi_scene/authored/op_showcase
	id = "op_showcase"
	category = "Energy"
	stage = "mountain_dusk"
	length_ds = 100
	climax_ds = 36
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "turf Grass1 + building system et_ masks and bevel", "kind" = "stage", "status" = "placeholder"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART)", "kind" = "stage", "status" = "placeholder"), list("name" = "attacker and target bodies", "source" = "the fighters' own sprites", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions", "kind" = "transition"), list("name" = "held beam", "source" = "EnergyFX row Kamehameha (EFX92 KAME relook art)", "kind" = "beam_hold", "status" = "placeholder"), list("name" = "trail strip", "source" = "Icons/Effects/ExcaliTrail.dmi (tracked, any DMI for the op test)", "kind" = "trail", "status" = "placeholder"), list("name" = "hit spark", "source" = "Icons/Private/Ougi/sparks/impact.dmi (approved_v1 Impact T3 bake)", "kind" = "hit"), list("name" = "thrown prop", "source" = "OUGI_STANDIN_ICON RPMode.dmi On", "kind" = "prop", "status" = "placeholder"), list("name" = "bullet and vertex sparks", "source" = "OUGI_STANDIN_ICON RPMode.dmi On; sparks/energy.dmi", "kind" = "bullet", "status" = "placeholder"), list("name" = "lightning spark by define", "source" = "Icons/Private/Ougi/sparks/lightning.dmi via OUGI_SPARK_LIGHTNING_ART", "kind" = "fx", "status" = "placeholder"), list("name" = "earth spark under the target", "source" = "Icons/Private/Ougi/sparks/earth.dmi via OUGI_SPARK_EARTH_ART, drawn below the fighters (under 1)", "kind" = "fx", "match" = list("under" = 1), "status" = "placeholder"), list("name" = "black impact spark", "source" = "Icons/Private/Ougi/sparks/impact.dmi via OUGI_SPARK_IMPACT_ART, color matrix all zero (fx color)", "kind" = "fx", "match" = list("icon" = OUGI_SPARK_IMPACT_ART), "status" = "placeholder"), list("name" = "energy spark under the tint", "source" = "Icons/Private/Ougi/sparks/energy.dmi via OUGI_SPARK_ENERGY_ART, listed before the tint so the tint colors it", "kind" = "fx", "match" = list("icon" = OUGI_SPARK_ENERGY_ART), "status" = "placeholder"), list("name" = "monochrome tint", "source" = "color matrix mono (turfs, actors, backdrop)", "kind" = "tint", "status" = "placeholder"), list("name" = "fighter silhouettes", "source" = "color matrix all zero on the fighters only (actor_tint)", "kind" = "actor_tint", "status" = "placeholder"), list("name" = "backdrop swap", "source" = "void, then sky_pink (OUGI_BD_SKY_PINK_ART, Icons/Private/Backdrops), then mountain_dusk", "kind" = "backdrop_swap", "status" = "placeholder"))
	icon_defines = list("OUGI_SPARK_EARTH_ART" = OUGI_SPARK_EARTH_ART, "OUGI_SPARK_ENERGY_ART" = OUGI_SPARK_ENERGY_ART, "OUGI_SPARK_IMPACT_ART" = OUGI_SPARK_IMPACT_ART, "OUGI_SPARK_LIGHTNING_ART" = OUGI_SPARK_LIGHTNING_ART, "OUGI_STANDIN_ICON" = OUGI_STANDIN_ICON)

/datum/ougi_scene/authored/op_showcase/Build()
	beats = list()
	B(0, "actor_face", list("who" = "attacker"))
	B(0, "actor_face", list("who" = "target"))
	B(2, "actor_state", list("who" = "attacker", "state" = "Blast"))
	B(2, "beam_hold", list("who" = "attacker", "from" = "attacker", "to" = "target", "row" = /obj/Skills/Projectile/Beams/Kamehameha, "charge_ds" = 0, "hold_ds" = 20, "release_ds" = 4, "width" = 1))
	B(30, "actor_state", list("who" = "attacker", "state" = ""))
	B(30, "trail", list("who" = "attacker", "path" = list("target", list(0, 64), "attacker"), "texture" = 'Icons/Effects/ExcaliTrail.dmi', "width" = 16, "life" = 6, "time" = 4, "blend" = BLEND_ADD))
	B(32, "ghost", list("who" = "attacker", "dx" = -12, "dy" = 6, "state" = "Blast", "life" = 6, "alpha" = 140))
	B(32, "ghost", list("who" = "attacker", "dx" = 8, "dy" = 0, "state" = "Blast", "crop" = list(16, 8, 31, 20), "life" = 6, "alpha" = 200))
	B(34, "ghost", list("who" = "attacker", "dx" = 244, "dy" = 0, "state" = "Attack", "crop" = list(16, 8, 31, 20), "front" = 1, "life" = 4, "alpha" = 220))
	B(36, "hit", list("spark" = "impact", "ring" = 0))
	B(44, "prop", list("who" = "attacker", "icon" = OUGI_STANDIN_ICON, "state" = "On", "dx" = 0, "dy" = 16, "throw_to" = "target", "time" = 6, "life" = 4, "arc" = 48))
	B(50, "fx", list("at" = "target", "icon" = OUGI_SPARK_LIGHTNING_ART, "state" = "", "life" = 10))
	B(52, "fx", list("at" = "target", "icon" = OUGI_SPARK_EARTH_ART, "state" = "", "life" = 8, "under" = 1))
	B(54, "fx", list("at" = "target", "icon" = OUGI_SPARK_IMPACT_ART, "state" = "", "life" = 8, "color" = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)))
	B(56, "bullet", list("from" = "attacker", "path" = list("ally1", "ally2", "ally3", "target"), "icon" = OUGI_STANDIN_ICON, "state" = "On", "speed" = 96, "spark" = "energy", "life" = 2))
	B(66, "fx", list("at" = "attacker", "icon" = OUGI_SPARK_ENERGY_ART, "state" = "", "life" = 8))
	B(66, "tint", list("color" = "mono", "in" = 2, "hold" = 8, "out" = 2, "actors" = 1))
	B(70, "actor_move", list("who" = "attacker", "to" = "target", "dx" = -12, "time" = 2))
	B(70, "actor_scale", list("who" = "target", "scale" = 2, "time" = 2))
	B(70, "actor_turn", list("who" = "target", "angle" = 135, "time" = 2))
	B(76, "actor_turn", list("who" = "target", "angle" = 90, "time" = 6, "easing" = "quad_in"))
	B(80, "backdrop_swap", list("backdrop" = "void", "time" = 4))
	B(80, "actor_tint", list("who" = "both", "color" = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), "in" = 1, "hold" = 6, "out" = 2))
	B(84, "backdrop_swap", list("backdrop" = "sky_pink", "time" = 4))
	B(88, "backdrop_swap", list("backdrop" = "mountain_dusk", "time" = 4))
	B(90, "actor_move", list("who" = "attacker", "to" = "attacker", "dx" = 0, "time" = 8, "walk" = 1))
	B(100, "hold")
