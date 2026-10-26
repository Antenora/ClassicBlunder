#if fexists("../../../../Icons/Private/Ougi/giga_drill_break/spiral_meter.dmi") || fexists("Icons/Private/Ougi/giga_drill_break/spiral_meter.dmi")
#define GDB_SPIRAL_METER_ART 'Icons/Private/Ougi/giga_drill_break/spiral_meter.dmi'
#else
#define GDB_SPIRAL_METER_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/giga_drill_break/shades.dmi") || fexists("Icons/Private/Ougi/giga_drill_break/shades.dmi")
#define GDB_SHADES 'Icons/Private/Ougi/giga_drill_break/shades.dmi'
#else
#define GDB_SHADES OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/giga_drill_break/gdb_background1.dmi") || fexists("Icons/Private/Ougi/giga_drill_break/gdb_background1.dmi")
#define GDB_BG1_ART 'Icons/Private/Ougi/giga_drill_break/gdb_background1.dmi'
#else
#define GDB_BG1_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/giga_drill_break/handcloseup.dmi") || fexists("Icons/Private/Ougi/giga_drill_break/handcloseup.dmi")
#define GDB_HAND 'Icons/Private/Ougi/giga_drill_break/handcloseup.dmi'
#else
#define GDB_HAND OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/omnislash_version_5/os_speed.dmi") || fexists("Icons/Private/Ougi/omnislash_version_5/os_speed.dmi")
#define GDB_OS_SPEED_ART 'Icons/Private/Ougi/omnislash_version_5/os_speed.dmi'
#else
#define GDB_OS_SPEED_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/giga_drill_break/drillhandclose.dmi") || fexists("Icons/Private/Ougi/giga_drill_break/drillhandclose.dmi")
#define GDD_DRILLHAND 'Icons/Private/Ougi/giga_drill_break/drillhandclose.dmi'
#else
#define GDD_DRILLHAND OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/giga_drill_break/drillFront.dmi") || fexists("Icons/Private/Ougi/giga_drill_break/drillFront.dmi")
#define GDB_DRILLFRONT 'Icons/Private/Ougi/giga_drill_break/drillFront.dmi'
#else
#define GDB_DRILLFRONT OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/giga_drill_break/drillupwards.dmi") || fexists("Icons/Private/Ougi/giga_drill_break/drillupwards.dmi")
#define GDB_DRILLUP 'Icons/Private/Ougi/giga_drill_break/drillupwards.dmi'
#else
#define GDB_DRILLUP OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/giga_drill_break/lastbreak.dmi") || fexists("Icons/Private/Ougi/giga_drill_break/lastbreak.dmi")
#define GDB_LASTB 'Icons/Private/Ougi/giga_drill_break/lastbreak.dmi'
#else
#define GDB_LASTB OUGI_ART_FALLBACK
#endif

#if fexists("../../../../Icons/Private/Ougi/giga_drill_break/finalbg.dmi") || fexists("Icons/Private/Ougi/giga_drill_break/finalbg.dmi")
#define GDB_FINALB 'Icons/Private/Ougi/giga_drill_break/finalbg.dmi'
#else
#define GDB_FINALB OUGI_ART_FALLBACK
#endif

/datum/ougi_scene/stand_in/giga_drill_break
	id = "giga_drill_break"
	category = "Energy"
	stage = "mountain_dusk"
	length_ds = 187.5
	climax_ds = 25
	icon_defines = list("GDB_BG1_ART" = GDB_BG1_ART, "GDB_DRILLFRONT" = GDB_DRILLFRONT, "GDB_DRILLUP" = GDB_DRILLUP, "GDB_FINALB" = GDB_FINALB, "GDB_HAND" = GDB_HAND, "GDB_LASTB" = GDB_LASTB, "GDB_OS_SPEED_ART" = GDB_OS_SPEED_ART, "GDB_SHADES" = GDB_SHADES, "GDB_SPIRAL_METER_ART" = GDB_SPIRAL_METER_ART, "GDD_DRILLHAND" = GDD_DRILLHAND)

/datum/ougi_scene/stand_in/giga_drill_break/Build()
	beats = list()
	B(0, "aura", list("who" = "attacker", "phase" = "appear"))
	B(0, "aura", list("who" = "attacker", "phase" = "off"))
	B(0, "actor_face", list("who" = "attacker"))
	B(0, "actor_face", list("who" = "target"))
	B(0, "actor_move", list("dx" = -299, "dy" = 5, "time" = 0))
	B(0, "actor_move", list("dx" = 247, "dy" = 1, "time" = 0, "who" = "target"))
	B(0, "fx", list("icon" = GDB_SPIRAL_METER_ART, "life" = 17.4, "scale" = 1.35, "x" = -816, "y" = -246, "restart" = 1))
	B(17, "fx", list("at" = "camera", "icon" = GDB_SHADES, "x" = -286, "y" = -249, "life" = 12.5, "state" = "shade", "keys" = list(list("t" = 0.5, "x" = 149, "y" = 140.333, "scale" = 7, "sx" = 1, "sy" = 1, "angle" = -60, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 1.5, "x" = 447, "y" = 421, "scale" = 1, "sx" = 1, "sy" = 1, "angle" = 180, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 9.5, "x" = 481, "y" = 410, "scale" = 1, "sx" = 1, "sy" = 1, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear", "angle" = -280), list("t" = 12.5, "x" = 457, "y" = 45, "scale" = 35.369, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "sine_in")), "scale" = 10, "under" = 0))
	B(17, "cut", list("color" = "ember"))
	B(17, "fx", list("at" = "camera", "blend" = BLEND_DEFAULT, "icon" = GDB_BG1_ART, "life" = 32, "under" = 1, "x" = -461, "y" = -296, "scale" = 1.5, "keys" = list(list("t" = 6.5, "x" = -206.556, "y" = -29.611, "scale" = 1.5, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 9, "x" = -286, "y" = -41, "scale" = 1.5, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 11, "x" = -127, "y" = -2, "scale" = 1.3, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 16, "x" = -206.556, "y" = -29.611, "scale" = 1.2, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"))))
	B(28, "actor_face", list("who" = "attacker", "dx" = 0, "dy" = 0, "time" = 0, "dir" = SOUTH))
	B(28.5, "actor_move", list("who" = "attacker", "dx" = 600, "time" = 0, "dy" = 600))
	B(29, "actor_scale", list("who" = "attacker", "dx" = 0, "dy" = 0, "time" = 0, "scale" = 100))
	B(29.5, "actor_move", list("who" = "attacker", "dx" = 200, "time" = 0, "dy" = 600))
	B(29.5, "fx", list("at" = "camera", "icon" = GDB_HAND, "x" = -48, "y" = -48, "scale" = 8, "keys" = list(list("t" = 8.5, "x" = -56, "y" = -1, "scale" = 8, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear")), "life" = 7))
	B(30, "actor_move", list("who" = "attacker", "dy" = 600, "dx" = 180, "time" = 5))
	B(36.5, "actor_face", list("who" = "attacker", "dx" = 0, "dy" = 0, "time" = 0, "dir" = WEST))
	B(36.5, "actor_move", list("who" = "attacker", "dy" = -284, "dx" = 285, "ease" = "linear", "time" = 0))
	B(36.5, "actor_scale", list("who" = "attacker", "dx" = 0, "dy" = 0, "time" = 5, "scale" = 2, "ease" = "sine_in"))
	B(38, "fx", list("at" = "camera", "icon" = GDB_OS_SPEED_ART, "x" = -80, "y" = -80, "life" = 10, "scale" = 3.796, "angle" = 140))
	B(38, "actor_state", list("who" = "attacker", "dx" = 0, "dy" = 0, "time" = 3, "state" = "Attack"))
	B(38, "fx", list("life" = 11, "at" = "camera", "icon" = GDB_SHADES, "state" = "RotStr", "skew_x" = -20, "scale" = 35.431, "keys" = list(list("t" = 4, "x" = 70, "y" = -30, "scale" = 4.545, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = -20, "skew_y" = 0, "alpha" = 255, "ease" = "sine_out"), list("t" = 10, "x" = -2, "y" = -32, "scale" = 7.242, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = -20, "skew_y" = 0, "alpha" = 255, "ease" = "sine_out")), "x" = -159, "y" = -30))
	B(41, "actor_fade", list("who" = "attacker", "dx" = 0, "dy" = 0, "time" = 3))
	B(49, "fx", list("at" = "camera", "blend" = BLEND_DEFAULT, "icon" = GDB_BG1_ART, "under" = 1, "x" = -608, "y" = -322, "scale" = 1, "state" = "blue2", "life" = 23))
	B(49, "fx", list("at" = "camera", "icon" = GDB_SHADES, "x" = 403, "y" = -91, "state" = "RotStr", "scale" = 4, "skew_x" = -45, "keys" = list(list("t" = 3, "x" = -363, "y" = 90, "scale" = 4, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = -45, "skew_y" = 0, "alpha" = 255, "ease" = "sine_out"), list("t" = 6, "x" = -386, "y" = 92, "scale" = 4, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = -45, "skew_y" = 0, "alpha" = 255, "ease" = "sine_out")), "life" = 7))
	B(56, "fx", list("at" = "camera", "icon" = GDB_SHADES, "x" = -16, "y" = -16, "life" = 3, "state" = "shade", "blend" = BLEND_ADD, "scale" = 4, "keys" = list(list("t" = 2, "x" = -73, "y" = 41, "scale" = 4, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "sine_out"))))
	B(56, "fx", list("at" = "camera", "icon" = GDB_SHADES, "x" = -16, "y" = -16, "life" = 3, "state" = "shade", "blend" = BLEND_ADD, "scale" = 4, "keys" = list(list("t" = 2, "x" = 106, "y" = -46, "scale" = 4, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "sine_out"))))
	B(59, "fx", list("at" = "camera", "icon" = GDB_SHADES, "x" = -84, "y" = 30, "life" = 3, "state" = "shade", "scale" = 4, "keys" = list(list("t" = 1.5, "x" = 0, "y" = 0, "scale" = 4, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 3, "x" = 0, "y" = 0, "scale" = 4, "sx" = 1, "sy" = 1, "angle" = 180, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "sine_in"))))
	B(59, "fx", list("at" = "camera", "icon" = GDB_SHADES, "x" = 85, "y" = -61, "life" = 3, "state" = "shade", "scale" = 4, "keys" = list(list("t" = 1.5, "x" = 0, "y" = 0, "scale" = 4, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 3, "x" = 0, "y" = 0, "scale" = 4, "sx" = 1, "sy" = 1, "angle" = 180, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "sine_in"))))
	B(62, "fx", list("at" = "camera", "icon" = GDB_SHADES, "x" = -101, "y" = 35, "life" = 10, "state" = "RotStr", "scale" = 4, "skew_x" = -45, "keys" = list(list("t" = 6, "x" = 0, "y" = 0, "scale" = 4, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = -45, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 7.5, "x" = -514, "y" = 164, "scale" = 4, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = -45, "skew_y" = 0, "alpha" = 255, "ease" = "sine_out"))))
	B(62, "fx", list("at" = "camera", "icon" = GDB_SHADES, "x" = 79, "y" = -75, "life" = 10, "state" = "RotStr", "scale" = 4, "skew_x" = -45, "keys" = list(list("t" = 6, "x" = 0, "y" = 0, "scale" = 4, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = -45, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 7.5, "x" = -642, "y" = 148, "scale" = 4, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = -45, "skew_y" = 0, "alpha" = 255, "ease" = "sine_out"))))
	B(72, "fx", list("at" = "camera", "blend" = BLEND_DEFAULT, "icon" = GDB_BG1_ART, "under" = 1, "x" = -265, "y" = -80, "state" = "blue2", "angle" = 150, "scale" = 1.5, "life" = 20))
	B(72, "fx", list("at" = "camera", "blend" = BLEND_DEFAULT, "icon" = GDB_BG1_ART, "under" = 0, "x" = -477, "y" = -323, "life" = 1, "angle" = 0, "scale" = 1, "state" = "bg1empty", "layer" = 1, "flip" = 0))
	B(72, "fx", list("at" = "camera", "icon" = GDB_SHADES, "x" = -220, "y" = -107, "life" = 10, "state" = "RotStr", "skew_x" = -60, "skew_y" = 0, "angle" = 50, "scale" = 4, "layer" = 10, "keys" = list(list("t" = 0.5, "x" = 0, "y" = 0, "scale" = 4, "sx" = 1, "sy" = 1, "angle" = 50, "skew_x" = -60, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 9.5, "x" = 0, "y" = 0, "scale" = 3.5, "sx" = 1, "sy" = 1, "angle" = 50, "skew_x" = -60, "skew_y" = 0, "alpha" = 255, "ease" = "linear"))))
	B(72, "fx", list("at" = "camera", "icon" = GDB_SHADES, "x" = 237, "y" = -17, "life" = 10, "state" = "RotStr", "skew_x" = 60, "skew_y" = 0, "layer" = 10, "angle" = -50, "scale" = 5, "keys" = list(list("t" = 0.5, "x" = 0, "y" = 0, "scale" = 5, "sx" = 1, "sy" = 1, "angle" = -50, "skew_x" = 60, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 9.5, "x" = 0, "y" = 0, "sx" = 1, "sy" = 1, "angle" = -50, "skew_x" = 60, "skew_y" = 0, "alpha" = 255, "ease" = "linear", "scale" = 4.5))))
	B(72, "actor_move", list("dx" = -252, "dy" = -217, "time" = 0, "who" = "target"))
	B(72, "actor_face", list("dx" = -339, "dy" = -206, "time" = 0, "who" = "target", "dir" = SOUTH))
	B(72.5, "actor_move", list("dx" = -194, "dy" = -219, "time" = 10, "who" = "target", "ease" = "linear"))
	B(72.5, "actor_scale", list("dx" = -314, "dy" = -207, "time" = 10, "who" = "target", "ease" = "linear", "scale" = 10))
	B(73, "fx", list("at" = "camera", "blend" = BLEND_DEFAULT, "icon" = GDB_BG1_ART, "under" = 1, "x" = -477, "y" = -323, "life" = 9, "angle" = 0, "scale" = 1, "state" = "bg1empty", "layer" = 1, "flip" = 0))
	B(82, "cut", list("color" = "ember"))
	B(82.5, "actor_move", list("dx" = -298, "dy" = 177, "time" = 0, "who" = "target", "ease" = "linear"))
	B(82.5, "actor_scale", list("dx" = -314, "dy" = -207, "time" = 0, "who" = "target", "ease" = "linear", "scale" = 30))
	B(82.5, "actor_state", list("dx" = -298, "dy" = 177, "time" = 0, "who" = "target", "ease" = "linear", "state" = "KB"))
	B(83, "fx", list("at" = "camera", "icon" = GDB_SHADES, "x" = -289, "y" = -276, "state" = "shade", "layer" = 3, "scale" = 15, "keys" = list(list("t" = 0.5, "x" = 0, "y" = 0, "scale" = 20, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 1, "x" = 784, "y" = 293, "scale" = 20, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear")), "life" = 2))
	B(84, "actor_move", list("dx" = 146, "dy" = -154, "time" = 0, "who" = "target", "ease" = "linear"))
	B(84, "actor_scale", list("dx" = -314, "dy" = -207, "time" = 0, "who" = "target", "ease" = "linear", "scale" = 29))
	B(84, "fx", list("at" = "camera", "icon" = 'Icons/NSE/Hitsparks/Hit_Effect_Divine.dmi', "x" = 21, "y" = -32, "life" = 3, "scale" = 20, "restart" = 1))
	B(84.5, "fx", list("at" = "camera", "icon" = GDB_SHADES, "x" = -163, "y" = 215, "state" = "shade", "layer" = 3, "scale" = 15, "keys" = list(list("t" = 0.5, "x" = 0, "y" = 0, "scale" = 20, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 1, "x" = 509, "y" = -682, "scale" = 20, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear")), "life" = 2, "angle" = 50))
	B(85, "actor_scale", list("dx" = -314, "dy" = -207, "time" = 0, "who" = "target", "ease" = "linear", "scale" = 32))
	B(85, "actor_move", list("dx" = -223, "dy" = 118, "time" = 0, "who" = "target", "ease" = "linear"))
	B(87, "fx", list("at" = "camera", "icon" = 'Icons/NSE/Hitsparks/Hit_Effect_Divine.dmi', "x" = -138, "y" = -89, "life" = 3, "scale" = 16.529, "restart" = 1))
	B(88, "fx", list("at" = "camera", "icon" = GDB_SHADES, "x" = 393, "y" = 112, "state" = "shade", "layer" = 3, "scale" = 15, "keys" = list(list("t" = 0.5, "x" = 0, "y" = 0, "scale" = 20, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 1, "x" = -859, "y" = -176, "scale" = 20, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear")), "life" = 2))
	B(88, "fx", list("at" = "camera", "icon" = 'Icons/NSE/Hitsparks/Hit_Effect_Divine.dmi', "x" = 21, "y" = -32, "life" = 3, "scale" = 20, "restart" = 1))
	B(89, "actor_move", list("dx" = -130, "dy" = -19, "time" = 0, "who" = "target", "ease" = "linear"))
	B(89, "actor_scale", list("dx" = -314, "dy" = -207, "time" = 0, "who" = "target", "ease" = "linear", "scale" = 32))
	B(89.5, "fx", list("at" = "camera", "icon" = GDB_SHADES, "x" = 430, "y" = 396, "state" = "shade", "layer" = 3, "scale" = 15, "keys" = list(list("t" = 0.5, "x" = 0, "y" = 0, "scale" = 20, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 1, "x" = -595, "y" = -983, "scale" = 20, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear")), "life" = 2, "angle" = 50))
	B(90.5, "actor_state", list("dx" = -298, "dy" = 177, "time" = 0, "who" = "target", "ease" = "linear", "state" = "KB"))
	B(90.5, "actor_scale", list("dx" = -314, "dy" = -207, "time" = 0, "who" = "target", "ease" = "linear", "scale" = 30))
	B(90.5, "actor_move", list("dx" = -298, "dy" = 177, "time" = 0, "who" = "target", "ease" = "linear"))
	B(92, "actor_scale", list("dx" = -314, "dy" = -207, "time" = 0, "who" = "target", "ease" = "linear", "scale" = 29))
	B(92, "actor_move", list("dx" = 20, "dy" = -28, "time" = 0, "who" = "target", "ease" = "linear"))
	B(92, "fx", list("at" = "camera", "blend" = BLEND_DEFAULT, "icon" = GDB_BG1_ART, "under" = 1, "x" = -525, "y" = -320, "angle" = 0, "scale" = 1.091, "state" = "galaxy", "keys" = list(list("t" = 0.5, "x" = 0, "y" = 0, "scale" = 2.83, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 2.5, "x" = -183, "y" = 82, "scale" = 1.6, "sx" = 1, "sy" = 1, "angle" = 50, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 15, "x" = -221, "y" = 89, "scale" = 1.6, "sx" = 1, "sy" = 1, "angle" = 80, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear")), "life" = 15))
	B(93, "actor_move", list("dx" = -77, "dy" = 211, "time" = 0, "who" = "target", "ease" = "linear"))
	B(93, "actor_scale", list("dx" = -314, "dy" = -207, "time" = 0, "who" = "target", "ease" = "linear", "scale" = 32))
	B(93.5, "actor_scale", list("dx" = -314, "dy" = -207, "time" = 1, "who" = "target", "ease" = "sine_in", "scale" = 5))
	B(93.5, "actor_move", list("dx" = -229, "dy" = 58, "time" = 0, "who" = "target", "ease" = "linear"))
	B(93.5, "fx", list("icon" = GDB_SHADES, "x" = -156, "y" = -73, "life" = 13, "state" = "shade", "scale" = 10, "under" = 0, "angle" = -10, "keys" = list(list("t" = 1, "x" = 106, "y" = 19, "scale" = 3, "sx" = 1, "sy" = 1, "angle" = -10, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"))))
	B(93.5, "fx", list("icon" = GDB_SHADES, "x" = 135, "y" = -94, "life" = 13, "state" = "shade", "scale" = 10, "under" = 0, "angle" = -180, "keys" = list(list("t" = 1, "x" = -109, "y" = 65, "scale" = 3, "sx" = 1, "sy" = 1, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"))))
	B(94, "actor_state", list("dx" = -298, "dy" = 177, "time" = 0, "who" = "target", "ease" = "linear"))
	B(94.5, "cam_shake")
	B(106.5, "fx", list("at" = "camera", "blend" = BLEND_DEFAULT, "icon" = GDB_BG1_ART, "under" = 1, "x" = -621, "y" = 161, "state" = "blue2", "life" = 27, "scale" = 1.5, "angle" = 75, "keys" = list(list("t" = 0, "x" = 0, "y" = 0, "scale" = 1.5, "sx" = 1, "sy" = 1, "angle" = 75, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"))))
	B(106.5, "actor_move", list("dx" = -605, "dy" = 39, "time" = 0, "who" = "target", "ease" = "linear"))
	B(106.5, "fx", list("at" = "camera", "icon" = GDD_DRILLHAND, "x" = -48, "y" = -69, "life" = 16, "scale" = 6.5, "restart" = 1, "keys" = list(list("t" = 0, "x" = 0, "y" = 0, "scale" = 6.5, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 11, "x" = -4, "y" = 31, "scale" = 6.5, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"))))
	B(121, "actor_move", list("who" = "attacker", "dy" = -230, "dx" = 141, "ease" = "linear", "time" = 0))
	B(121, "actor_fade", list("who" = "attacker", "dx" = 0, "dy" = 0, "time" = 0, "alpha" = 255))
	B(121, "actor_face", list("who" = "attacker", "dx" = 0, "dy" = 0, "time" = 0, "dir" = SOUTH))
	B(121, "actor_state", list("who" = "attacker", "state" = "Flight"))
	B(121, "actor_scale", list("who" = "attacker", "time" = 0, "scale" = 4, "ease" = "sine_in"))
	B(121, "fx", list("at" = "camera", "blend" = BLEND_DEFAULT, "icon" = GDB_BG1_ART, "under" = 1, "x" = -673, "y" = -339, "life" = 9, "angle" = 0, "scale" = 1, "state" = "bg1empty", "layer" = 1, "flip" = 0, "keys" = list(list("t" = 0, "scale" = 2, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear", "y" = 250, "x" = -200), list("t" = 8.5, "x" = 0, "y" = -105, "scale" = 1, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"))))
	B(121, "fx", list("life" = 12.5, "icon" = GDB_DRILLFRONT, "at" = "attacker", "x" = -26, "y" = -19, "scale" = 2, "keys" = list(list("t" = 0, "x" = 0, "y" = 0, "scale" = 2, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 2.5, "x" = -17, "y" = 112, "scale" = 3.897, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "sine_in"), list("t" = 8.5, "x" = -40, "y" = 123, "scale" = 6.569, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "sine_in"), list("t" = 12.5, "x" = -426, "y" = 590, "scale" = 44.197, "sx" = 1, "sy" = 1, "angle" = 0, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "sine_in"))))
	B(121.5, "actor_scale", list("who" = "attacker", "time" = 2, "scale" = 8, "ease" = "sine_in"))
	B(121.5, "actor_move", list("who" = "attacker", "dy" = -97, "dx" = 141, "time" = 2, "ease" = "sine_in"))
	B(123.5, "actor_move", list("who" = "attacker", "dy" = -57, "dx" = 141, "time" = 7, "ease" = "linear"))
	B(123.5, "actor_scale", list("who" = "attacker", "time" = 7, "scale" = 9))
	B(131.5, "actor_scale", list("who" = "attacker", "time" = 2, "scale" = 100))
	B(131.5, "actor_move", list("who" = "attacker", "dx" = 159, "time" = 2, "ease" = "linear", "dy" = 1000))
	B(133.5, "actor_move", list("who" = "attacker", "dx" = 456, "time" = 0, "ease" = "linear", "dy" = -239))
	B(133.5, "actor_face", list("who" = "attacker", "dx" = 0, "dy" = 0, "time" = 0))
	B(133.5, "actor_turn", list("who" = "attacker", "dx" = 0, "dy" = 0, "time" = 0, "angle" = 35))
	B(133.5, "fx", list("at" = "camera", "blend" = BLEND_DEFAULT, "icon" = GDB_BG1_ART, "under" = 1, "x" = -608, "y" = -322, "scale" = 1, "state" = "blue2", "life" = 10.5, "angle" = -180))
	B(133.5, "fx", list("at" = "attacker", "life" = 5, "icon" = GDB_DRILLUP, "x" = -65, "y" = -50, "scale" = 6, "keys" = list(list("t" = 0.5, "x" = 0, "y" = 0, "scale" = 6, "sx" = 1, "sy" = 1, "angle" = -20, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"), list("t" = 5.5, "x" = -327, "y" = 161, "scale" = 4, "sx" = 1, "sy" = 1, "angle" = -20, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "sine_in")), "angle" = -20))
	B(133.5, "actor_scale", list("who" = "attacker", "time" = 0, "scale" = 4))
	B(133.5, "actor_move", list("dx" = -340, "dy" = 86, "time" = 0, "who" = "target", "ease" = "linear"))
	B(133.5, "fx", list("icon" = GDB_SHADES, "x" = -30, "y" = -34, "life" = 10.5, "state" = "shade", "scale" = 1, "under" = 0, "angle" = -10, "keys" = list(list("t" = 10.5, "x" = 0, "y" = 0, "scale" = 2, "sx" = 1, "sy" = 1, "angle" = -10, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"))))
	B(133.5, "fx", list("icon" = GDB_SHADES, "x" = -1, "y" = -6, "life" = 10.5, "state" = "shade", "scale" = 1, "under" = 0, "angle" = -180, "keys" = list(list("t" = 10.5, "x" = 19, "y" = -2, "scale" = 2, "sx" = 1, "sy" = 1, "angle" = -180, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"))))
	B(133.5, "actor_scale", list("dx" = -314, "dy" = -207, "time" = 0, "who" = "target", "ease" = "linear", "scale" = 2))
	B(134, "actor_move", list("who" = "attacker", "dx" = 152, "dy" = -64, "time" = 5))
	B(134, "actor_move", list("dx" = -328, "dy" = 77, "time" = 10, "who" = "target", "ease" = "linear"))
	B(134, "actor_scale", list("dx" = -314, "dy" = -207, "time" = 10, "who" = "target", "ease" = "linear", "scale" = 4))
	B(134, "actor_scale", list("who" = "attacker", "time" = 5, "scale" = 3))
	B(138.5, "fx", list("at" = "attacker", "icon" = GDB_DRILLUP, "x" = 22, "y" = -108, "state" = "boost", "angle" = -20, "scale" = 5, "life" = 5.5))
	B(144, "cut", list("color" = "ember"))
	B(144.5, "fx", list("at" = "camera", "life" = 10, "icon" = GDB_LASTB, "x" = -90, "y" = -56, "scale" = 6, "restart" = 1))
	B(144.5, "actor_move", list("dx" = -603, "dy" = 56, "time" = 1, "who" = "target", "ease" = "linear"))
	B(149.5, "hit")
	B(153.5, "flash", list("at" = "target", "life" = 10, "hold" = 3))
	B(153.5, "actor_move", list("who" = "attacker", "dx" = 293, "dy" = 163, "time" = 0))
	B(153.5, "actor_face", list("who" = "attacker", "dx" = 0, "dy" = 0, "time" = 0, "dir" = NORTH))
	B(153.5, "actor_turn", list("who" = "attacker", "dx" = 0, "dy" = 0, "time" = 0, "angle" = 0))
	B(153.5, "actor_state", list("who" = "attacker"))
	B(157.5, "cam_move", list("to" = "camera", "time" = 0, "dx" = 46, "dy" = 242))
	B(157.5, "fx", list("at" = "camera", "life" = 30, "icon" = GDB_FINALB, "x" = -273, "y" = -79, "scale" = 1, "keys" = list(list("t" = 30, "x" = 0, "y" = 0, "scale" = 1.2, "sx" = 1, "sy" = 1, "angle" = 5, "skew_x" = 0, "skew_y" = 0, "alpha" = 255, "ease" = "linear"))))
	B(181, "fx", list("at" = "camera", "life" = 4, "icon" = GDB_FINALB, "state" = "flash", "x" = -273, "y" = -77, "restart" = 1))
	B(184, "flash", list("at" = "target", "life" = 10, "hold" = 6))
	B(187.5, "hold")
