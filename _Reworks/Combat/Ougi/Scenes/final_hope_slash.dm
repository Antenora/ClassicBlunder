#if fexists("../../../../Icons/Private/Ougi/final_hope_slash/fhs_blade.dmi") || fexists("Icons/Private/Ougi/final_hope_slash/fhs_blade.dmi")
#define OUGI_FHS_BLADE_ART 'Icons/Private/Ougi/final_hope_slash/fhs_blade.dmi'
#else
#define OUGI_FHS_BLADE_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/final_hope_slash/fhs_aura.dmi") || fexists("Icons/Private/Ougi/final_hope_slash/fhs_aura.dmi")
#define OUGI_FHS_AURA_ART 'Icons/Private/Ougi/final_hope_slash/fhs_aura.dmi'
#else
#define OUGI_FHS_AURA_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/final_hope_slash/fhs_slash.dmi") || fexists("Icons/Private/Ougi/final_hope_slash/fhs_slash.dmi")
#define OUGI_FHS_SLASH_ART 'Icons/Private/Ougi/final_hope_slash/fhs_slash.dmi'
#else
#define OUGI_FHS_SLASH_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/final_hope_slash/fhs_sphere.dmi") || fexists("Icons/Private/Ougi/final_hope_slash/fhs_sphere.dmi")
#define OUGI_FHS_SPHERE_ART 'Icons/Private/Ougi/final_hope_slash/fhs_sphere.dmi'
#else
#define OUGI_FHS_SPHERE_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/final_hope_slash/fhs_column.dmi") || fexists("Icons/Private/Ougi/final_hope_slash/fhs_column.dmi")
#define OUGI_FHS_COLUMN_ART 'Icons/Private/Ougi/final_hope_slash/fhs_column.dmi'
#else
#define OUGI_FHS_COLUMN_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/final_hope_slash/fhs_bolt.dmi") || fexists("Icons/Private/Ougi/final_hope_slash/fhs_bolt.dmi")
#define OUGI_FHS_BOLT_ART 'Icons/Private/Ougi/final_hope_slash/fhs_bolt.dmi'
#else
#define OUGI_FHS_BOLT_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/final_hope_slash/fhs_wound.dmi") || fexists("Icons/Private/Ougi/final_hope_slash/fhs_wound.dmi")
#define OUGI_FHS_WOUND_ART 'Icons/Private/Ougi/final_hope_slash/fhs_wound.dmi'
#else
#define OUGI_FHS_WOUND_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/final_hope_slash/fhs_wake.dmi") || fexists("Icons/Private/Ougi/final_hope_slash/fhs_wake.dmi")
#define OUGI_FHS_WAKE_ART 'Icons/Private/Ougi/final_hope_slash/fhs_wake.dmi'
#else
#define OUGI_FHS_WAKE_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/final_hope_slash/fhs_wake_rise.dmi") || fexists("Icons/Private/Ougi/final_hope_slash/fhs_wake_rise.dmi")
#define OUGI_FHS_WAKE_RISE_ART 'Icons/Private/Ougi/final_hope_slash/fhs_wake_rise.dmi'
#else
#define OUGI_FHS_WAKE_RISE_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/final_hope_slash/fhs_ink.dmi") || fexists("Icons/Private/Ougi/final_hope_slash/fhs_ink.dmi")
#define OUGI_FHS_INK_ART 'Icons/Private/Ougi/final_hope_slash/fhs_ink.dmi'
#else
#define OUGI_FHS_INK_ART OUGI_ART_FALLBACK
#endif

/datum/ougi_scene/stand_in/final_hope_slash
	id = "final_hope_slash"
	category = "Armed"
	stage = "mountain_dusk"
	length_ds = 144
	climax_ds = 112.5
	surfaces = list(list("name" = "room ground and plateau rim", "source" = "turf Dirt1 (Icons/Turfs/Dirt1.dmi) + building system et_ masks and bevel", "kind" = "stage"), list("name" = "backdrop", "source" = "mountain_dusk (OUGI_BD_MOUNTAIN_DUSK_ART, Icons/Private/Backdrops)", "kind" = "stage"), list("name" = "fighters", "source" = "the fighters' own sprites (idle, Attack, Flight, KB, KO), turned by actor_turn; no sword is drawn (owner ruling 2026-10-21); rage gold and the orb's dark silhouette by actor_tint", "kind" = "actor"), list("name" = "super flash, W1 wipe, N1 crest plate", "source" = "landed transitions (ougi_focus_gold, ougi_ring, ougi_wipe_*, ougi_nameplate)", "kind" = "transition"), list("name" = "the spirit blade (body)", "source" = "OUGI_FHS_BLADE_ART *_b: my flat rhombus blade with a chisel tip and a bevel plane, shaped from the clip at 9.1 s, surfaced with the pack's ICE_03 crystal facets (bevel lit with ICE_W), outlined in its own darkened texture; while it forms, the pack's NoiseElectro01 crackle in cyan, white and gold; white-hot at 13.7 s; erodes by the ICE_W facets", "kind" = "fx", "match" = list("icon" = OUGI_FHS_BLADE_ART, "blend" = null)), list("name" = "the spirit blade (light)", "source" = "OUGI_FHS_BLADE_ART *_l: the pack's painted cartoon lightning (blue_lightning_3_sheet, gold_lightning_3_sheet, the FX_CartoonLightning prefabs' art) along the blade, the pack's Light_glow_07 star flare at the hilt, the blade's own facet glow", "kind" = "fx", "match" = list("icon" = OUGI_FHS_BLADE_ART, "blend" = BLEND_ADD)), list("name" = "Trunks' aura", "source" = "OUGI_FHS_AURA_ART: the approved AuraFX construction (aurafx3 field9, the landed engine aura: one connected egg grown from the body, mirrored regular spikes, Trail_f01 wisps, Ses_Trail_Mask rim fibers), in Trunks' canon blue, built on his Attack pose; ignite, steady, the flight comet streaming back on the drag, out", "kind" = "fx", "match" = list("icon" = OUGI_FHS_AURA_ART)), list("name" = "opening cuts", "source" = "OUGI_FHS_SLASH_ART: the pack prefab FX_MagicSlash02_Fire ported layer for layer by the Great Aether packslash renderer, rolled and tilted per canon arc and pivoted on the hand (rising cut, flat cut); the crossing cut is the approved blade hitspark lines", "kind" = "fx", "match" = list("icon" = OUGI_FHS_SLASH_ART)), list("name" = "the orb", "source" = "OUGI_FHS_SPHERE_ART: kept as the owner liked it (EnergyFX beam material shell and fill, Electro_02 lightning); now waits in the sky, brightens, and collapses into the blade", "kind" = "fx", "match" = list("icon" = OUGI_FHS_SPHERE_ART)), list("name" = "travel wakes", "source" = "OUGI_FHS_WAKE_ART and OUGI_FHS_WAKE_RISE_ART: the approved Armed travel wake (Omnislash wake_os, the Mech Trails recipe: Trail_f01 wisps, sf_noise_clouds_01 breakup, smoke under additive light), world-anchored along the dash, the rise, the dive and the drag", "kind" = "fx", "match" = list("icon" = OUGI_FHS_WAKE_ART)), list("name" = "rise wake", "source" = "OUGI_FHS_WAKE_RISE_ART: the same approved wake on the rise", "kind" = "fx", "match" = list("icon" = OUGI_FHS_WAKE_RISE_ART)), list("name" = "the rising pillar", "source" = "OUGI_FHS_COLUMN_ART: EnergyFX beam material column (the owner's law for pillars) erupting around the victim from the wound, held, dissolved from the top; no base band (owner 2026-10-21)", "kind" = "fx", "match" = list("icon" = OUGI_FHS_COLUMN_ART)), list("name" = "the wound", "source" = "OUGI_FHS_WOUND_ART: a vertical wound through the target's middle left by the upswing, surfaced with the pack's painted line_lightning02_blue2 (white-hot line with cyan crackle) flowing along it and the pack's FineLightning_03 strands branching off; opens, crackles, bursts into the pillar", "kind" = "fx", "match" = list("icon" = OUGI_FHS_WOUND_ART)), list("name" = "the last crackle", "source" = "OUGI_FHS_BOLT_ART: the pack's painted blue cartoon lightning, vertical, where the pillar stood", "kind" = "fx", "match" = list("icon" = OUGI_FHS_BOLT_ART)), list("name" = "impact frame ink", "source" = "OUGI_FHS_INK_ART: the pack's painted ink_05 stroke as radial shards, smears along the cut and one vertical slash line (the approved brush calligraphy warp)", "kind" = "fx", "match" = list("icon" = OUGI_FHS_INK_ART)), list("name" = "hit sparks", "source" = "approved hitspark generator approved_v1, Blade, Impact, Lightning, Light and Fire families Tier 3 (OUGI_SPARK_*_ART)", "kind" = "fx"), list("name" = "the gathering streaks", "source" = "charge op: EnergyFX comet streaks converging on the orb from far out (reach 320), Kamehameha blue #3a8dff", "kind" = "charge"), list("name" = "afterimages", "source" = "engine ghost op with the approved Armed blue color matrix (lane 143)", "kind" = "actor"), list("name" = "impact frame rooms", "source" = "engine tint op, black then white matrices, fighters excluded", "kind" = "tint"), list("name" = "impact frame figures", "source" = "engine actor_tint op, white then black", "kind" = "actor_tint"), list("name" = "flash", "source" = "engine flash plate (lightcutin.dmi)", "kind" = "flash"), list("name" = "climax hit", "source" = "hit op with the approved lightning spark family", "kind" = "hit"), list("name" = "lights", "source" = "engine light source (AddLightSource), gold and blue, on the attacker only", "kind" = "light"))
	icon_defines = list("OUGI_FHS_AURA_ART" = OUGI_FHS_AURA_ART, "OUGI_FHS_BLADE_ART" = OUGI_FHS_BLADE_ART, "OUGI_FHS_BOLT_ART" = OUGI_FHS_BOLT_ART, "OUGI_FHS_COLUMN_ART" = OUGI_FHS_COLUMN_ART, "OUGI_FHS_INK_ART" = OUGI_FHS_INK_ART, "OUGI_FHS_SLASH_ART" = OUGI_FHS_SLASH_ART, "OUGI_FHS_SPHERE_ART" = OUGI_FHS_SPHERE_ART, "OUGI_FHS_WAKE_ART" = OUGI_FHS_WAKE_ART, "OUGI_FHS_WAKE_RISE_ART" = OUGI_FHS_WAKE_RISE_ART, "OUGI_FHS_WOUND_ART" = OUGI_FHS_WOUND_ART, "OUGI_SPARK_BLADE_ART" = OUGI_SPARK_BLADE_ART, "OUGI_SPARK_FIRE_ART" = OUGI_SPARK_FIRE_ART, "OUGI_SPARK_IMPACT_ART" = OUGI_SPARK_IMPACT_ART, "OUGI_SPARK_LIGHTNING_ART" = OUGI_SPARK_LIGHTNING_ART, "OUGI_SPARK_LIGHT_ART" = OUGI_SPARK_LIGHT_ART)

/datum/ougi_scene/stand_in/final_hope_slash/Build()
	beats = list()
	B(0, "actor_face", list("who" = "attacker", "dir" = EAST))
	B(0, "actor_face", list("who" = "target", "dir" = WEST))
	B(0, "actor_move", list("who" = "attacker", "dy" = -20, "time" = 0))
	B(0, "actor_move", list("who" = "target", "dy" = -20, "time" = 0))
	B(0, "cam_move", list("to" = "camera", "dx" = 0, "dy" = 40, "time" = 0))
	B(0, "cam_zoom", list("mag" = 2, "time" = 1))
	B(2, "actor_state", list("who" = "attacker", "state" = "Flight"))
	B(2, "actor_move", list("who" = "attacker", "dx" = 220, "dy" = -20, "time" = 4))
	B(2, "fx", list("at" = "camera", "icon" = OUGI_FHS_WAKE_ART, "state" = "h1s", "x" = -226, "y" = -100, "life" = 11))
	B(2, "fx", list("at" = "camera", "icon" = OUGI_FHS_WAKE_ART, "state" = "h1l", "x" = -226, "y" = -100, "life" = 11, "blend" = BLEND_ADD))
	B(2, "cam_move", list("to" = "camera", "dx" = 70, "dy" = 40, "time" = 4, "easing" = "sine"))
	B(2, "cam_zoom", list("mag" = 2.6, "time" = 4))
	B(6, "actor_state", list("who" = "attacker", "state" = "Attack"))
	B(6, "actor_move", list("who" = "attacker", "dx" = 228, "dy" = 2, "time" = 2))
	B(6, "fx", list("at" = "attacker", "icon" = OUGI_FHS_SLASH_ART, "state" = "rise", "life" = 6, "attach" = 1, "blend" = BLEND_ADD, "x" = -69, "y" = -81))
	B(6.5, "fx", list("at" = "target", "icon" = OUGI_SPARK_BLADE_ART, "state" = "", "x" = -89, "y" = -21, "life" = 10))
	B(6.5, "actor_state", list("who" = "target", "state" = "KB"))
	B(6.5, "actor_move", list("who" = "target", "dx" = 6, "dy" = -10, "time" = 2))
	B(6.5, "cam_shake", list("strength" = 2, "time" = 2))
	B(8.5, "fx", list("at" = "target", "icon" = OUGI_SPARK_BLADE_ART, "state" = "", "x" = -87, "y" = -17, "life" = 10))
	B(8.5, "cam_shake", list("strength" = 2, "time" = 2))
	B(8.8, "fx", list("at" = "target", "icon" = OUGI_SPARK_BLADE_ART, "state" = "", "x" = -91, "y" = -25, "life" = 10, "flip" = 1))
	B(9.5, "actor_move", list("who" = "attacker", "dx" = 226, "dy" = -20, "time" = 2))
	B(10, "fx", list("at" = "attacker", "icon" = OUGI_FHS_SLASH_ART, "state" = "flat", "life" = 6, "attach" = 1, "blend" = BLEND_ADD, "x" = -69, "y" = -81))
	B(10.5, "fx", list("at" = "target", "icon" = OUGI_SPARK_IMPACT_ART, "state" = "", "x" = -186, "y" = -67, "life" = 10))
	B(10.5, "cam_shake", list("strength" = 3, "time" = 2))
	B(11.5, "actor_tint", list("who" = "both", "color" = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1), "in" = 0, "hold" = 1, "out" = 0))
	B(11.5, "tint", list("color" = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), "in" = 0, "hold" = 1.5, "out" = 0, "actors" = 0))
	B(11.5, "fx", list("at" = "target", "icon" = OUGI_FHS_INK_ART, "state" = "shards", "life" = 1, "under" = 1, "x" = -194, "y" = -194))
	B(12.5, "actor_tint", list("who" = "both", "color" = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), "in" = 0, "hold" = 0.5, "out" = 0))
	B(13, "actor_move", list("who" = "attacker", "dx" = 240, "dy" = -20, "time" = 1))
	B(13.5, "fx", list("at" = "target", "icon" = OUGI_SPARK_IMPACT_ART, "state" = "", "x" = -190, "y" = -63, "life" = 10))
	B(13.5, "actor_state", list("who" = "target", "state" = "Flight"))
	B(13.5, "actor_move", list("who" = "target", "dx" = 232, "dy" = 70, "time" = 4))
	B(13.5, "cam_shake", list("strength" = 4, "time" = 3))
	B(16, "actor_state", list("who" = "attacker", "state" = ""))
	B(16, "cam_move", list("to" = "camera", "dx" = 112, "dy" = 30, "time" = 3, "easing" = "sine"))
	B(16, "cam_zoom", list("mag" = 2.8, "time" = 3))
	B(17, "actor_tint", list("who" = "attacker", "color" = list(1, 0.12, 0, 0.08, 0.95, 0, 0, 0, 0.72, 0.12, 0.07, 0), "in" = 2, "hold" = 3, "out" = 2))
	B(17, "light", list("at" = "attacker", "radius" = 2, "color" = "#ffd23a", "alpha" = 160, "life" = 6))
	B(18, "cam_zoom", list("mag" = 3, "time" = 5))
	B(19, "cam_shake", list("strength" = 1, "time" = 4))
	B(23, "actor_state", list("who" = "attacker", "state" = "Attack"))
	B(23, "cam_move", list("to" = "camera", "dx" = 100, "dy" = 140, "time" = 4, "easing" = "sine"))
	B(23, "cam_zoom", list("mag" = 2.2, "time" = 4))
	B(23.5, "actor_move", list("who" = "attacker", "dx" = 220, "dy" = 150, "time" = 3))
	B(23.5, "fx", list("at" = "camera", "icon" = OUGI_FHS_WAKE_RISE_ART, "state" = "v1s", "x" = 54, "y" = -47, "life" = 9))
	B(23.5, "fx", list("at" = "camera", "icon" = OUGI_FHS_WAKE_RISE_ART, "state" = "v1l", "x" = 54, "y" = -47, "life" = 9, "blend" = BLEND_ADD))
	B(26, "fx", list("at" = "attacker", "icon" = OUGI_FHS_SPHERE_ART, "state" = "in_b", "life" = 4, "x" = -64, "y" = -62, "attach" = 1, "under" = 1))
	B(26, "fx", list("at" = "attacker", "icon" = OUGI_FHS_SPHERE_ART, "state" = "in_l", "life" = 4, "blend" = BLEND_ADD, "x" = -64, "y" = -62, "attach" = 1, "under" = 1))
	B(26, "charge", list("who" = "attacker", "phase" = "build", "dx" = 0, "dy" = 2, "radius" = 22, "color" = "#3a8dff", "time" = 18, "reach" = 320, "core_scale" = 1))
	B(26, "charge", list("who" = "attacker", "phase" = "hold"))
	B(26, "light", list("at" = "attacker", "radius" = 4, "color" = "#3a8dff", "alpha" = 120, "life" = 10))
	B(26, "cam_move", list("to" = "camera", "dx" = 100, "dy" = 130, "time" = 6, "easing" = "sine"))
	B(26, "cam_zoom", list("mag" = 2, "time" = 6))
	B(27, "actor_tint", list("who" = "attacker", "color" = list(0.16, 0.2, 0.42, 0.1, 0.16, 0.38, 0.06, 0.1, 0.28, 0.02, 0.04, 0.14), "in" = 2, "hold" = 19, "out" = 1))
	B(30, "fx", list("at" = "attacker", "icon" = OUGI_FHS_SPHERE_ART, "state" = "hold_b", "life" = 14, "x" = -64, "y" = -62, "attach" = 1, "under" = 1))
	B(30, "fx", list("at" = "attacker", "icon" = OUGI_FHS_SPHERE_ART, "state" = "hold_l", "life" = 14, "blend" = BLEND_ADD, "x" = -64, "y" = -62, "attach" = 1, "under" = 1))
	B(34, "cam_move", list("to" = "camera", "dx" = 100, "dy" = 156, "time" = 8, "easing" = "sine"))
	B(34, "cam_zoom", list("mag" = 2.8, "time" = 8))
	B(36, "light", list("at" = "attacker", "radius" = 5, "color" = "#3a8dff", "alpha" = 170, "life" = 8))
	B(40, "cam_shake", list("strength" = 2, "time" = 6))
	B(44, "fx", list("at" = "attacker", "icon" = OUGI_FHS_SPHERE_ART, "state" = "peak_b", "life" = 3, "x" = -64, "y" = -62, "attach" = 1, "under" = 1))
	B(44, "fx", list("at" = "attacker", "icon" = OUGI_FHS_SPHERE_ART, "state" = "peak_l", "life" = 3, "blend" = BLEND_ADD, "x" = -64, "y" = -62, "attach" = 1, "under" = 1))
	B(44, "light", list("at" = "attacker", "radius" = 6, "color" = "#58d8ff", "alpha" = 230, "life" = 4.5))
	B(46, "charge", list("who" = "attacker", "phase" = "implode"))
	B(47, "fx", list("at" = "attacker", "icon" = OUGI_FHS_SPHERE_ART, "state" = "absorb_b", "life" = 2, "x" = -64, "y" = -62, "attach" = 1, "under" = 1))
	B(47, "fx", list("at" = "attacker", "icon" = OUGI_FHS_SPHERE_ART, "state" = "absorb_l", "life" = 2, "blend" = BLEND_ADD, "x" = -64, "y" = -62, "attach" = 1, "under" = 1))
	B(48.5, "flash", list("color" = "#ffffff", "alpha" = 255, "in" = 0, "hold" = 0.5, "out" = 1.5))
	B(48.5, "charge", list("who" = "attacker", "phase" = "release", "time" = 2))
	B(49, "fx", list("at" = "attacker", "icon" = OUGI_FHS_AURA_ART, "state" = "ignite_b", "life" = 4, "x" = -72, "y" = -32, "attach" = 1))
	B(49, "fx", list("at" = "attacker", "icon" = OUGI_FHS_AURA_ART, "state" = "ignite_l", "life" = 4, "blend" = BLEND_ADD, "x" = -72, "y" = -32, "attach" = 1))
	B(49, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "form_b", "life" = 4, "x" = -133, "y" = -145, "attach" = 1))
	B(49, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "form_l", "life" = 4, "blend" = BLEND_ADD, "x" = -133, "y" = -145, "attach" = 1))
	B(49, "cam_move", list("to" = "camera", "dx" = 150, "dy" = 140, "time" = 6, "easing" = "sine"))
	B(49, "cam_zoom", list("mag" = 2.2, "time" = 6))
	B(53, "fx", list("at" = "attacker", "icon" = OUGI_FHS_AURA_ART, "state" = "attack_b", "life" = 18, "x" = -72, "y" = -32, "attach" = 1))
	B(53, "fx", list("at" = "attacker", "icon" = OUGI_FHS_AURA_ART, "state" = "attack_l", "life" = 18, "blend" = BLEND_ADD, "x" = -72, "y" = -32, "attach" = 1))
	B(53, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "settle_b", "life" = 3, "x" = -133, "y" = -145, "attach" = 1))
	B(53, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "settle_l", "life" = 3, "blend" = BLEND_ADD, "x" = -133, "y" = -145, "attach" = 1))
	B(56, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "flare_b", "life" = 3, "x" = -133, "y" = -145, "attach" = 1))
	B(56, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "flare_l", "life" = 3, "blend" = BLEND_ADD, "x" = -133, "y" = -145, "attach" = 1))
	B(56, "cam_shake", list("strength" = 2, "time" = 3))
	B(59, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "hold_b", "life" = 12, "x" = -133, "y" = -145, "attach" = 1))
	B(59, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "hold_l", "life" = 12, "blend" = BLEND_ADD, "x" = -133, "y" = -145, "attach" = 1))
	B(59, "cam_move", list("to" = "camera", "dx" = 160, "dy" = 150, "time" = 7, "easing" = "sine"))
	B(59, "cam_zoom", list("mag" = 2, "time" = 7))
	B(66, "cam_move", list("to" = "camera", "dx" = 112, "dy" = 168, "time" = 3, "easing" = "sine"))
	B(66, "cam_zoom", list("mag" = 3, "time" = 3))
	B(67, "cam_shake", list("strength" = 2, "time" = 4))
	B(71, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "tilt_b", "life" = 2, "x" = -133, "y" = -145, "attach" = 1))
	B(71, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "tilt_l", "life" = 2, "blend" = BLEND_ADD, "x" = -133, "y" = -145, "attach" = 1))
	B(71, "fx", list("at" = "attacker", "icon" = OUGI_FHS_AURA_ART, "state" = "drag_b", "life" = 19, "x" = -72, "y" = -32, "attach" = 1))
	B(71, "fx", list("at" = "attacker", "icon" = OUGI_FHS_AURA_ART, "state" = "drag_l", "life" = 19, "blend" = BLEND_ADD, "x" = -72, "y" = -32, "attach" = 1))
	B(71, "cam_move", list("to" = "camera", "dx" = 330, "dy" = 100, "time" = 7, "easing" = "sine"))
	B(71, "cam_zoom", list("mag" = 2.2, "time" = 7))
	B(73, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "drive_b", "life" = 6, "x" = -133, "y" = -145, "attach" = 1, "under" = 1))
	B(73, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "drive_l", "life" = 6, "blend" = BLEND_ADD, "x" = -133, "y" = -145, "attach" = 1, "under" = 1))
	B(73, "actor_move", list("who" = "attacker", "dx" = 402, "dy" = 71, "time" = 5))
	B(73, "fx", list("at" = "camera", "icon" = OUGI_FHS_WAKE_ART, "state" = "h2s", "x" = -25, "y" = 30, "life" = 13))
	B(73, "fx", list("at" = "camera", "icon" = OUGI_FHS_WAKE_ART, "state" = "h2l", "x" = -25, "y" = 30, "life" = 13, "blend" = BLEND_ADD))
	B(73.5, "ghost", list("who" = "attacker", "life" = 4, "alpha" = 170, "color" = list(0.12, 0.186, 0.3, 0.236, 0.366, 0.59, 0.044, 0.068, 0.11, 0.04, 0.18, 0.55)))
	B(75, "ghost", list("who" = "attacker", "life" = 4, "alpha" = 150, "color" = list(0.12, 0.186, 0.3, 0.236, 0.366, 0.59, 0.044, 0.068, 0.11, 0.04, 0.18, 0.55)))
	B(76.5, "ghost", list("who" = "attacker", "life" = 4, "alpha" = 130, "color" = list(0.12, 0.186, 0.3, 0.236, 0.366, 0.59, 0.044, 0.068, 0.11, 0.04, 0.18, 0.55)))
	B(78, "actor_state", list("who" = "target", "state" = "KB"))
	B(78, "fx", list("at" = "target", "icon" = OUGI_SPARK_LIGHTNING_ART, "state" = "", "x" = -29, "y" = -19, "life" = 8))
	B(78, "fx", list("at" = "target", "icon" = OUGI_SPARK_LIGHT_ART, "state" = "", "x" = -23, "y" = 3, "life" = 8, "scale" = 1.6))
	B(78, "cam_shake", list("strength" = 5, "time" = 3))
	B(79, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "drive_b", "life" = 11, "x" = -133, "y" = -145, "attach" = 1, "under" = 1))
	B(79, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "drive_l", "life" = 11, "blend" = BLEND_ADD, "x" = -133, "y" = -145, "attach" = 1, "under" = 1))
	B(79, "actor_move", list("who" = "attacker", "dx" = 572, "dy" = 61, "time" = 10))
	B(79, "actor_move", list("who" = "target", "dx" = 402, "dy" = 60, "time" = 10))
	B(79, "fx", list("at" = "camera", "icon" = OUGI_FHS_WAKE_ART, "state" = "h3s", "x" = 151, "y" = -14, "life" = 19))
	B(79, "fx", list("at" = "camera", "icon" = OUGI_FHS_WAKE_ART, "state" = "h3l", "x" = 151, "y" = -14, "life" = 19, "blend" = BLEND_ADD))
	B(79, "cam_move", list("to" = "camera", "dx" = 480, "dy" = 90, "time" = 10, "easing" = "sine"))
	B(79, "cam_zoom", list("mag" = 2.2, "time" = 10))
	B(80, "ghost", list("who" = "attacker", "life" = 4, "alpha" = 170, "color" = list(0.12, 0.186, 0.3, 0.236, 0.366, 0.59, 0.044, 0.068, 0.11, 0.04, 0.18, 0.55)))
	B(82, "ghost", list("who" = "attacker", "life" = 4, "alpha" = 156, "color" = list(0.12, 0.186, 0.3, 0.236, 0.366, 0.59, 0.044, 0.068, 0.11, 0.04, 0.18, 0.55)))
	B(84, "ghost", list("who" = "attacker", "life" = 4, "alpha" = 142, "color" = list(0.12, 0.186, 0.3, 0.236, 0.366, 0.59, 0.044, 0.068, 0.11, 0.04, 0.18, 0.55)))
	B(86, "ghost", list("who" = "attacker", "life" = 4, "alpha" = 128, "color" = list(0.12, 0.186, 0.3, 0.236, 0.366, 0.59, 0.044, 0.068, 0.11, 0.04, 0.18, 0.55)))
	B(88, "ghost", list("who" = "attacker", "life" = 4, "alpha" = 114, "color" = list(0.12, 0.186, 0.3, 0.236, 0.366, 0.59, 0.044, 0.068, 0.11, 0.04, 0.18, 0.55)))
	B(90, "cam_shake", list("strength" = 5, "time" = 3))
	B(90, "fx", list("at" = "target", "icon" = OUGI_SPARK_LIGHT_ART, "state" = "", "x" = -23, "y" = 3, "life" = 8, "scale" = 1.4))
	B(90, "fx", list("at" = "attacker", "icon" = OUGI_FHS_AURA_ART, "state" = "attack_b", "life" = 24, "x" = -72, "y" = -32, "attach" = 1))
	B(90, "fx", list("at" = "attacker", "icon" = OUGI_FHS_AURA_ART, "state" = "attack_l", "life" = 24, "blend" = BLEND_ADD, "x" = -72, "y" = -32, "attach" = 1))
	B(90, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "push_b", "life" = 9, "x" = -133, "y" = -145, "attach" = 1, "under" = 1))
	B(90, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "push_l", "life" = 9, "blend" = BLEND_ADD, "x" = -133, "y" = -145, "attach" = 1, "under" = 1))
	B(90, "cam_move", list("to" = "camera", "dx" = 500, "dy" = 80, "time" = 4, "easing" = "sine"))
	B(90, "cam_zoom", list("mag" = 2.6, "time" = 4))
	B(93, "cam_shake", list("strength" = 2, "time" = 6))
	B(95, "fx", list("at" = "target", "icon" = OUGI_SPARK_LIGHTNING_ART, "state" = "", "x" = -13, "y" = -7, "life" = 4))
	B(99, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "upswing_b", "life" = 2, "x" = -133, "y" = -145, "attach" = 1))
	B(99, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "upswing_l", "life" = 2, "blend" = BLEND_ADD, "x" = -133, "y" = -145, "attach" = 1))
	B(99, "actor_state", list("who" = "target", "state" = ""))
	B(99, "cam_move", list("to" = "camera", "dx" = 500, "dy" = 110, "time" = 3, "easing" = "sine"))
	B(99, "cam_zoom", list("mag" = 2.4, "time" = 3))
	B(99.5, "actor_move", list("who" = "target", "dx" = 402, "dy" = 68, "time" = 1))
	B(100, "fx", list("at" = "target", "icon" = OUGI_SPARK_BLADE_ART, "state" = "", "x" = -87, "y" = -25, "life" = 6))
	B(100, "cam_shake", list("strength" = 4, "time" = 3))
	B(100.5, "actor_move", list("who" = "target", "dx" = 402, "dy" = 60, "time" = 2))
	B(101, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "up_b", "life" = 3.5, "x" = -133, "y" = -145, "attach" = 1))
	B(101, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "up_l", "life" = 3.5, "blend" = BLEND_ADD, "x" = -133, "y" = -145, "attach" = 1))
	B(101, "fx", list("at" = "target", "icon" = OUGI_FHS_WOUND_ART, "state" = "open", "life" = 1.5, "attach" = 1, "blend" = BLEND_ADD, "x" = -16, "y" = -48))
	B(102.5, "fx", list("at" = "target", "icon" = OUGI_FHS_WOUND_ART, "state" = "", "life" = 9, "attach" = 1, "blend" = BLEND_ADD, "x" = -16, "y" = -48))
	B(104.5, "tint", list("color" = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), "in" = 0, "hold" = 1, "out" = 0, "actors" = 0))
	B(104.5, "actor_tint", list("who" = "both", "color" = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), "in" = 0, "hold" = 1, "out" = 0))
	B(104.5, "fx", list("at" = "target", "icon" = OUGI_FHS_INK_ART, "state" = "vline", "life" = 1, "under" = 1, "x" = -194, "y" = -194))
	B(105.5, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "upfade_b", "life" = 4, "x" = -133, "y" = -145, "attach" = 1))
	B(105.5, "fx", list("at" = "attacker", "icon" = OUGI_FHS_BLADE_ART, "state" = "upfade_l", "life" = 4, "blend" = BLEND_ADD, "x" = -133, "y" = -145, "attach" = 1))
	B(105.5, "cam_shake", list("strength" = 3, "time" = 3))
	B(105.5, "cam_move", list("to" = "camera", "dx" = 500, "dy" = 90, "time" = 3, "easing" = "sine"))
	B(105.5, "cam_zoom", list("mag" = 2.8, "time" = 3))
	B(109.5, "actor_tint", list("who" = "both", "color" = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1), "in" = 0, "hold" = 1.5, "out" = 0))
	B(109.5, "tint", list("color" = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), "in" = 0, "hold" = 1.5, "out" = 0, "actors" = 0))
	B(109.5, "fx", list("at" = "target", "icon" = OUGI_FHS_INK_ART, "state" = "shards", "life" = 1.5, "under" = 1, "x" = -194, "y" = -194))
	B(111, "actor_tint", list("who" = "both", "color" = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), "in" = 0, "hold" = 1.5, "out" = 0))
	B(111, "tint", list("color" = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1), "in" = 0, "hold" = 1.5, "out" = 0, "actors" = 0))
	B(111, "fx", list("at" = "target", "icon" = OUGI_FHS_INK_ART, "state" = "streaks", "life" = 1.5, "under" = 1, "x" = -194, "y" = -194))
	B(112.5, "hit", list("spark" = "lightning", "ring" = 0))
	B(112.5, "fx", list("at" = "target", "icon" = OUGI_FHS_WOUND_ART, "state" = "burst", "life" = 1.5, "attach" = 1, "blend" = BLEND_ADD, "x" = -16, "y" = -48))
	B(112.5, "fx", list("at" = "target", "icon" = OUGI_FHS_COLUMN_ART, "state" = "column_b", "life" = 20, "x" = -104, "y" = -80))
	B(112.5, "fx", list("at" = "target", "icon" = OUGI_FHS_COLUMN_ART, "state" = "column_l", "life" = 20, "blend" = BLEND_ADD, "x" = -104, "y" = -80))
	B(112.5, "actor_move", list("who" = "target", "dx" = 402, "dy" = 90, "time" = 16))
	B(112.5, "cam_shake", list("strength" = 6, "time" = 6))
	B(112.5, "cam_move", list("to" = "camera", "dx" = 490, "dy" = 150, "time" = 8, "easing" = "sine"))
	B(112.5, "cam_zoom", list("mag" = 1.8, "time" = 8))
	B(112.5, "fx", list("at" = "attacker", "icon" = OUGI_FHS_AURA_ART, "state" = "out_b", "life" = 4, "x" = -72, "y" = -32, "attach" = 1))
	B(112.5, "fx", list("at" = "attacker", "icon" = OUGI_FHS_AURA_ART, "state" = "out_l", "life" = 4, "blend" = BLEND_ADD, "x" = -72, "y" = -32, "attach" = 1))
	B(113.5, "fx", list("at" = "target", "icon" = OUGI_SPARK_FIRE_ART, "state" = "", "x" = -115, "y" = -38, "life" = 10, "scale" = 1.8))
	B(116, "fx", list("at" = "target", "icon" = OUGI_SPARK_FIRE_ART, "state" = "", "x" = -51, "y" = 12, "life" = 10, "scale" = 1.8, "flip" = 1))
	B(116.5, "actor_state", list("who" = "attacker", "state" = ""))
	B(118.5, "fx", list("at" = "target", "icon" = OUGI_SPARK_FIRE_ART, "state" = "", "x" = -109, "y" = 62, "life" = 10, "scale" = 1.8))
	B(129.5, "fx", list("at" = "camera", "icon" = OUGI_FHS_BOLT_ART, "state" = "crackle", "life" = 4, "blend" = BLEND_ADD, "x" = 498, "y" = 70))
	B(131.5, "actor_state", list("who" = "target", "state" = "KO"))
	B(131.5, "actor_move", list("who" = "target", "dx" = 402, "dy" = -20, "time" = 7))
	B(131.5, "actor_turn", list("who" = "target", "angle" = 180, "time" = 7))
	B(131.5, "cam_move", list("to" = "camera", "dx" = 470, "dy" = 70, "time" = 9, "easing" = "sine"))
	B(131.5, "cam_zoom", list("mag" = 2.2, "time" = 9))
	B(138.5, "cam_shake", list("strength" = 2, "time" = 2))
	B(144, "hold")
