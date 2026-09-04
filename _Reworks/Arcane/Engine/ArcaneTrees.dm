var/list/ARCANE_TREES = list(\
	"Fire" = list(\
		"folder" = "fire",\
		"accent" = "#ffe4e0",\
		"nodes" = list(\
			"ENTRY" = list(284, 512, 1, "autohit"),\
			"21" = list(178, 472, 1, "aoe"),\
			"22" = list(390, 473, 1, "line"),\
			"31" = list(141, 378, 2, "debuff"),\
			"32" = list(440, 341, 2, "line"),\
			"41" = list(155, 236, 3, "aoe"),\
			"42" = list(393, 197, 3, "projectile"),\
			"51" = list(212, 330, 3, "buff"),\
			"52" = list(382, 315, 3, "autohit"),\
			"61" = list(203, 145, 4, "aoe"),\
			"62" = list(291, 145, 4, "line"),\
			"CROWN" = list(239, 36, 5, "line"),\
			"N1" = list(415, 407, 1, "projectile"),\
			"N2" = list(148, 307, 2, "buff"),\
			"N3" = list(351, 257, 4, "aoe"),\
			"N4" = list(321, 201, 4, "autohit"),\
			"N5" = list(209, 267, 3, "line"),\
			"N6" = list(265, 90, 5, "autohit"),\
			"N7" = list(206, 206, 4, "projectile"),\
			"N8" = list(416, 269, 2, "projectile"),\
			"SHELF_M1" = list(112, 616, 2, "mage passive"),\
			"SHELF_M2" = list(160, 616, 4, "mage passive"),\
			"SHELF_P" = list(284, 616, 5, "pinnacle"),\
			"SHELF_S2" = list(408, 616, 4, "spell passive"),\
			"SHELF_S1" = list(456, 616, 3, "spell passive")\
		),\
		"links" = list(\
			list("ENTRY", "21"),\
			list("ENTRY", "22"),\
			list("41", "51"),\
			list("42", "52"),\
			list("61", "CROWN"),\
			list("21", "31"),\
			list("22", "N1"),\
			list("N1", "32"),\
			list("31", "N2"),\
			list("N2", "41"),\
			list("52", "N3"),\
			list("N3", "N4"),\
			list("N4", "62"),\
			list("51", "N5"),\
			list("62", "N6"),\
			list("N6", "CROWN"),\
			list("N5", "N7"),\
			list("N7", "61"),\
			list("32", "N8"),\
			list("N8", "42")\
		)),\
	"Water" = list(\
		"folder" = "water",\
		"accent" = "#c5c1ff",\
		"nodes" = list(\
			"ENTRY" = list(284, 512, 1, "buff"),\
			"21" = list(164, 480, 1, "autohit"),\
			"22" = list(404, 480, 1, "debuff"),\
			"31" = list(104, 386, 2, "autohit"),\
			"32" = list(464, 386, 2, "debuff"),\
			"41" = list(120, 260, 3, "projectile"),\
			"42" = list(448, 260, 3, "autohit"),\
			"CENTER" = list(284, 328, 2, "projectile"),\
			"61" = list(188, 152, 4, "debuff"),\
			"62" = list(380, 152, 4, "buff"),\
			"TOP" = list(284, 52, 4, "autohit"),\
			"CROWN" = list(284, 208, 5, "buff"),\
			"N1" = list(224, 404, 1, "projectile"),\
			"N2" = list(344, 404, 2, "buff"),\
			"N3" = list(202, 294, 3, "debuff"),\
			"N4" = list(366, 294, 3, "buff"),\
			"N5" = list(284, 130, 5, "debuff"),\
			"N6" = list(154, 206, 4, "projectile"),\
			"N7" = list(414, 206, 4, "autohit"),\
			"N8" = list(112, 323, 3, "projectile"),\
			"SHELF_M1" = list(112, 616, 2, "mage passive"),\
			"SHELF_M2" = list(160, 616, 4, "mage passive"),\
			"SHELF_P" = list(284, 616, 5, "pinnacle"),\
			"SHELF_S2" = list(408, 616, 4, "spell passive"),\
			"SHELF_S1" = list(456, 616, 3, "spell passive")\
		),\
		"links" = list(\
			list("ENTRY", "21"),\
			list("ENTRY", "22"),\
			list("21", "31"),\
			list("22", "32"),\
			list("32", "42"),\
			list("61", "TOP"),\
			list("62", "TOP"),\
			list("21", "N1"),\
			list("N1", "CENTER"),\
			list("22", "N2"),\
			list("N2", "CENTER"),\
			list("41", "N3"),\
			list("N3", "CENTER"),\
			list("42", "N4"),\
			list("N4", "CENTER"),\
			list("TOP", "N5"),\
			list("N5", "CROWN"),\
			list("41", "N6"),\
			list("N6", "61"),\
			list("42", "N7"),\
			list("N7", "62"),\
			list("31", "N8"),\
			list("N8", "41")\
		)),\
	"Ice" = list(\
		"folder" = "ice",\
		"accent" = "#48aae8",\
		"nodes" = list(\
			"RING_U" = list(284, 228, 3, "line"),\
			"RING_UR" = list(332, 256, 3, "debuff"),\
			"RING_LR" = list(332, 312, 2, "projectile"),\
			"RING_D" = list(284, 340, 2, "line"),\
			"RING_LL" = list(236, 312, 2, "aoe"),\
			"RING_UL" = list(236, 256, 3, "projectile"),\
			"MID_U" = list(284, 170, 5, "aoe"),\
			"MID_D" = list(284, 398, 1, "projectile"),\
			"MID_UR" = list(383, 227, 3, "aoe"),\
			"MID_LR" = list(383, 341, 2, "debuff"),\
			"MID_LL" = list(185, 341, 2, "projectile"),\
			"MID_UL" = list(185, 227, 4, "debuff"),\
			"CROWN" = list(284, 56, 5, "projectile"),\
			"ENTRY" = list(284, 512, 1, "debuff"),\
			"TIP_UR" = list(481, 170, 4, "aoe"),\
			"TIP_LR" = list(481, 398, 3, "aoe"),\
			"TIP_LL" = list(87, 398, 3, "line"),\
			"TIP_UL" = list(87, 170, 4, "line"),\
			"V_L" = list(236, 132, 4, "debuff"),\
			"V_R" = list(332, 132, 4, "projectile"),\
			"W_L" = list(236, 436, 1, "aoe"),\
			"W_R" = list(332, 436, 1, "line"),\
			"SHELF_M1" = list(112, 616, 2, "mage passive"),\
			"SHELF_M2" = list(160, 616, 4, "mage passive"),\
			"SHELF_P" = list(284, 616, 5, "pinnacle"),\
			"SHELF_S2" = list(408, 616, 4, "spell passive"),\
			"SHELF_S1" = list(456, 616, 3, "spell passive")\
		),\
		"links" = list(\
			list("RING_U", "RING_UR"),\
			list("RING_UR", "RING_LR"),\
			list("RING_LR", "RING_D"),\
			list("RING_D", "RING_LL"),\
			list("RING_LL", "RING_UL"),\
			list("RING_UL", "RING_U"),\
			list("RING_U", "MID_U"),\
			list("MID_U", "CROWN"),\
			list("RING_D", "MID_D"),\
			list("MID_D", "ENTRY"),\
			list("RING_UR", "MID_UR"),\
			list("MID_UR", "TIP_UR"),\
			list("RING_LR", "MID_LR"),\
			list("MID_LR", "TIP_LR"),\
			list("RING_LL", "MID_LL"),\
			list("MID_LL", "TIP_LL"),\
			list("RING_UL", "MID_UL"),\
			list("MID_UL", "TIP_UL"),\
			list("MID_U", "V_L"),\
			list("MID_U", "V_R"),\
			list("MID_D", "W_L"),\
			list("MID_D", "W_R")\
		)),\
	"Wind" = list(\
		"folder" = "air",\
		"accent" = "#d2fbc7",\
		"nodes" = list(\
			"ENTRY" = list(284, 511, 1, "projectile"),\
			"SOUTH2" = list(264, 448, 1, "line"),\
			"SOUTH3" = list(244, 385, 2, "projectile"),\
			"EAST" = list(56, 281, 2, "autohit"),\
			"EAST2" = list(119, 261, 3, "buff"),\
			"EAST3" = list(182, 241, 3, "autohit"),\
			"WEST" = list(516, 281, 2, "buff"),\
			"WEST2" = list(453, 301, 2, "line"),\
			"WEST3" = list(390, 321, 3, "projectile"),\
			"CROWN" = list(284, 51, 5, "line"),\
			"NORTH2" = list(304, 114, 5, "projectile"),\
			"NORTH3" = list(324, 177, 4, "line"),\
			"N1" = list(363, 433, 1, "buff"),\
			"N2" = list(437, 203, 4, "projectile"),\
			"N3" = list(134, 359, 1, "autohit"),\
			"N4" = list(206, 129, 4, "buff"),\
			"N5" = list(317, 353, 3, "autohit"),\
			"N6" = list(357, 249, 4, "buff"),\
			"N7" = list(213, 313, 3, "line"),\
			"N8" = list(253, 209, 4, "autohit"),\
			"SHELF_M1" = list(112, 616, 2, "mage passive"),\
			"SHELF_M2" = list(160, 616, 4, "mage passive"),\
			"SHELF_P" = list(284, 616, 5, "pinnacle"),\
			"SHELF_S2" = list(408, 616, 4, "spell passive"),\
			"SHELF_S1" = list(456, 616, 3, "spell passive")\
		),\
		"links" = list(\
			list("ENTRY", "SOUTH2"),\
			list("SOUTH2", "SOUTH3"),\
			list("EAST", "EAST2"),\
			list("EAST2", "EAST3"),\
			list("WEST", "WEST2"),\
			list("WEST2", "WEST3"),\
			list("CROWN", "NORTH2"),\
			list("NORTH2", "NORTH3"),\
			list("SOUTH2", "EAST2"),\
			list("EAST2", "NORTH2"),\
			list("NORTH2", "WEST2"),\
			list("WEST2", "SOUTH2"),\
			list("WEST", "N1"),\
			list("N1", "ENTRY"),\
			list("CROWN", "N2"),\
			list("N2", "WEST"),\
			list("ENTRY", "N3"),\
			list("N3", "EAST"),\
			list("EAST", "N4"),\
			list("N4", "CROWN"),\
			list("WEST3", "N5"),\
			list("N5", "SOUTH3"),\
			list("NORTH3", "N6"),\
			list("N6", "WEST3"),\
			list("SOUTH3", "N7"),\
			list("N7", "EAST3"),\
			list("EAST3", "N8"),\
			list("N8", "NORTH3")\
		)),\
	"Lightning" = list(\
		"folder" = "lightning",\
		"accent" = "#ffc440",\
		"nodes" = list(\
			"TL" = list(196, 64, 5, "projectile"),\
			"CROWN" = list(284, 48, 5, "line"),\
			"TR" = list(372, 64, 4, "line"),\
			"R1" = list(320, 216, 3, "autohit"),\
			"R2" = list(400, 216, 3, "line"),\
			"ENTRY" = list(284, 512, 1, "aoe"),\
			"L1" = list(248, 312, 2, "autohit"),\
			"L2" = list(168, 312, 3, "autohit"),\
			"N1" = list(182, 188, 4, "autohit"),\
			"N2" = list(361, 317, 2, "line"),\
			"N3" = list(322, 414, 1, "line"),\
			"N4" = list(346, 140, 4, "aoe"),\
			"N5" = list(260, 380, 2, "aoe"),\
			"N6" = list(175, 250, 3, "projectile"),\
			"N7" = list(189, 126, 4, "projectile"),\
			"N8" = list(272, 446, 1, "projectile"),\
			"N9" = list(380, 266, 3, "aoe"),\
			"N10" = list(342, 366, 2, "projectile"),\
			"SHELF_M1" = list(112, 616, 2, "mage passive"),\
			"SHELF_M2" = list(160, 616, 4, "mage passive"),\
			"SHELF_P" = list(284, 616, 5, "pinnacle"),\
			"SHELF_S2" = list(408, 616, 4, "spell passive"),\
			"SHELF_S1" = list(456, 616, 3, "spell passive")\
		),\
		"links" = list(\
			list("TL", "CROWN"),\
			list("CROWN", "TR"),\
			list("R1", "R2"),\
			list("L1", "L2"),\
			list("N3", "ENTRY"),\
			list("TR", "N4"),\
			list("N4", "R1"),\
			list("N5", "L1"),\
			list("L2", "N6"),\
			list("N6", "N1"),\
			list("N1", "N7"),\
			list("N7", "TL"),\
			list("ENTRY", "N8"),\
			list("N8", "N5"),\
			list("R2", "N9"),\
			list("N9", "N2"),\
			list("N2", "N10"),\
			list("N10", "N3")\
		)),\
	"Earth" = list(\
		"folder" = "earth",\
		"accent" = "#fff7e3",\
		"nodes" = list(\
			"ENTRY" = list(284, 512, 1, "autohit"),\
			"12" = list(164, 480, 1, "buff"),\
			"13" = list(404, 480, 1, "debuff"),\
			"21" = list(284, 384, 2, "buff"),\
			"22" = list(164, 352, 2, "aoe"),\
			"23" = list(404, 352, 3, "aoe"),\
			"31" = list(284, 256, 3, "aoe"),\
			"32" = list(164, 224, 4, "aoe"),\
			"33" = list(404, 224, 4, "buff"),\
			"CROWN" = list(284, 128, 5, "autohit"),\
			"42" = list(164, 96, 5, "debuff"),\
			"43" = list(404, 96, 4, "buff"),\
			"N1" = list(284, 448, 1, "aoe"),\
			"N2" = list(164, 416, 2, "debuff"),\
			"N3" = list(404, 416, 2, "autohit"),\
			"N4" = list(284, 320, 3, "autohit"),\
			"N5" = list(164, 288, 3, "buff"),\
			"N6" = list(404, 288, 3, "debuff"),\
			"N7" = list(284, 192, 4, "autohit"),\
			"N8" = list(164, 160, 4, "debuff"),\
			"SHELF_M1" = list(112, 616, 2, "mage passive"),\
			"SHELF_M2" = list(160, 616, 4, "mage passive"),\
			"SHELF_P" = list(284, 616, 5, "pinnacle"),\
			"SHELF_S2" = list(408, 616, 4, "spell passive"),\
			"SHELF_S1" = list(456, 616, 3, "spell passive")\
		),\
		"links" = list(\
			list("ENTRY", "12"),\
			list("ENTRY", "13"),\
			list("21", "22"),\
			list("21", "23"),\
			list("31", "32"),\
			list("31", "33"),\
			list("33", "43"),\
			list("CROWN", "42"),\
			list("CROWN", "43"),\
			list("ENTRY", "N1"),\
			list("N1", "21"),\
			list("12", "N2"),\
			list("N2", "22"),\
			list("13", "N3"),\
			list("N3", "23"),\
			list("21", "N4"),\
			list("N4", "31"),\
			list("22", "N5"),\
			list("N5", "32"),\
			list("23", "N6"),\
			list("N6", "33"),\
			list("31", "N7"),\
			list("N7", "CROWN"),\
			list("32", "N8"),\
			list("N8", "42")\
		)),\
	"Light" = list(\
		"folder" = "light",\
		"accent" = "#fde3cb",\
		"nodes" = list(\
			"ENTRY" = list(284, 512, 1, "projectile"),\
			"12" = list(284, 448, 1, "line"),\
			"13" = list(284, 384, 1, "buff"),\
			"21" = list(60, 288, 4, "autohit"),\
			"22" = list(124, 288, 3, "buff"),\
			"23" = list(188, 288, 2, "autohit"),\
			"31" = list(508, 288, 4, "buff"),\
			"32" = list(444, 288, 3, "line"),\
			"33" = list(380, 288, 3, "projectile"),\
			"CROWN" = list(284, 64, 5, "line"),\
			"42" = list(284, 128, 5, "projectile"),\
			"43" = list(284, 192, 4, "buff"),\
			"N1" = list(284, 288, 3, "autohit"),\
			"N2" = list(236, 336, 2, "buff"),\
			"N3" = list(332, 336, 2, "line"),\
			"N4" = list(236, 240, 3, "autohit"),\
			"N5" = list(332, 240, 4, "line"),\
			"N6" = list(284, 336, 2, "projectile"),\
			"N7" = list(284, 240, 4, "projectile"),\
			"SHELF_M1" = list(112, 616, 2, "mage passive"),\
			"SHELF_M2" = list(160, 616, 4, "mage passive"),\
			"SHELF_P" = list(284, 616, 5, "pinnacle"),\
			"SHELF_S2" = list(408, 616, 4, "spell passive"),\
			"SHELF_S1" = list(456, 616, 3, "spell passive")\
		),\
		"links" = list(\
			list("ENTRY", "12"),\
			list("12", "13"),\
			list("21", "22"),\
			list("22", "23"),\
			list("23", "33"),\
			list("31", "32"),\
			list("32", "33"),\
			list("CROWN", "42"),\
			list("42", "43"),\
			list("13", "N2"),\
			list("N2", "23"),\
			list("13", "N3"),\
			list("N3", "33"),\
			list("23", "N4"),\
			list("N4", "43"),\
			list("33", "N5"),\
			list("N5", "43"),\
			list("13", "N6"),\
			list("N6", "N1"),\
			list("N1", "N7"),\
			list("N7", "43")\
		)),\
	"Dark" = list(\
		"folder" = "dark",\
		"accent" = "#eaccfc",\
		"nodes" = list(\
			"ENTRY" = list(284, 512, 1, "debuff"),\
			"11" = list(160, 477, 2, "autohit"),\
			"12" = list(408, 489, 1, "autohit"),\
			"21" = list(66, 376, 2, "line"),\
			"22" = list(323, 381, 3, "projectile"),\
			"23" = list(427, 399, 2, "projectile"),\
			"24" = list(519, 375, 2, "autohit"),\
			"3" = list(231, 324, 3, "autohit"),\
			"41" = list(60, 237, 3, "projectile"),\
			"42" = list(158, 238, 4, "line"),\
			"51" = list(97, 110, 4, "autohit"),\
			"52" = list(166, 134, 5, "autohit"),\
			"CROWN" = list(188, 47, 5, "debuff"),\
			"N1" = list(63, 306, 3, "debuff"),\
			"N2" = list(113, 426, 2, "debuff"),\
			"N3" = list(78, 174, 3, "line"),\
			"N4" = list(222, 494, 1, "line"),\
			"N5" = list(346, 500, 1, "projectile"),\
			"N6" = list(194, 281, 4, "projectile"),\
			"N7" = list(142, 78, 4, "debuff"),\
			"N8" = list(277, 352, 3, "line"),\
			"SHELF_M1" = list(112, 616, 2, "mage passive"),\
			"SHELF_M2" = list(160, 616, 4, "mage passive"),\
			"SHELF_P" = list(284, 616, 5, "pinnacle"),\
			"SHELF_S2" = list(408, 616, 4, "spell passive"),\
			"SHELF_S1" = list(456, 616, 3, "spell passive")\
		),\
		"links" = list(\
			list("12", "24"),\
			list("22", "23"),\
			list("23", "24"),\
			list("42", "52"),\
			list("52", "CROWN"),\
			list("21", "N1"),\
			list("N1", "41"),\
			list("11", "N2"),\
			list("N2", "21"),\
			list("41", "N3"),\
			list("N3", "51"),\
			list("ENTRY", "N4"),\
			list("N4", "11"),\
			list("ENTRY", "N5"),\
			list("N5", "12"),\
			list("3", "N6"),\
			list("N6", "42"),\
			list("51", "N7"),\
			list("N7", "CROWN"),\
			list("22", "N8"),\
			list("N8", "3")\
		)),\
	"Space" = list(\
		"folder" = "space",\
		"accent" = "#fcd9e9",\
		"nodes" = list(\
			"ENTRY" = list(284, 512, 1, "projectile"),\
			"21" = list(220, 416, 1, "aoe"),\
			"22" = list(348, 416, 2, "projectile"),\
			"31" = list(156, 320, 3, "debuff"),\
			"32" = list(284, 320, 3, "projectile"),\
			"33" = list(412, 320, 3, "aoe"),\
			"41" = list(92, 224, 4, "autohit"),\
			"42" = list(220, 224, 4, "debuff"),\
			"43" = list(348, 224, 3, "aoe"),\
			"44" = list(476, 224, 3, "autohit"),\
			"5" = list(284, 144, 5, "projectile"),\
			"CROWN" = list(284, 56, 5, "debuff"),\
			"N1" = list(284, 232, 4, "autohit"),\
			"N2" = list(156, 224, 4, "projectile"),\
			"N3" = list(412, 224, 4, "aoe"),\
			"N4" = list(252, 464, 1, "autohit"),\
			"N5" = list(316, 464, 1, "debuff"),\
			"N6" = list(188, 368, 2, "aoe"),\
			"N7" = list(252, 368, 2, "autohit"),\
			"N8" = list(316, 368, 2, "debuff"),\
			"SHELF_M1" = list(112, 616, 2, "mage passive"),\
			"SHELF_M2" = list(160, 616, 4, "mage passive"),\
			"SHELF_P" = list(284, 616, 5, "pinnacle"),\
			"SHELF_S2" = list(408, 616, 4, "spell passive"),\
			"SHELF_S1" = list(456, 616, 3, "spell passive")\
		),\
		"links" = list(\
			list("22", "33"),\
			list("31", "41"),\
			list("31", "42"),\
			list("32", "42"),\
			list("32", "43"),\
			list("33", "43"),\
			list("33", "44"),\
			list("42", "5"),\
			list("43", "5"),\
			list("5", "CROWN"),\
			list("32", "N1"),\
			list("N1", "5"),\
			list("41", "N2"),\
			list("N2", "42"),\
			list("43", "N3"),\
			list("N3", "44"),\
			list("ENTRY", "N4"),\
			list("N4", "21"),\
			list("ENTRY", "N5"),\
			list("N5", "22"),\
			list("21", "N6"),\
			list("N6", "31"),\
			list("21", "N7"),\
			list("N7", "32"),\
			list("22", "N8"),\
			list("N8", "32")\
		)),\
	"Time" = list(\
		"folder" = "time",\
		"accent" = "#dcfff9",\
		"nodes" = list(\
			"ENTRY" = list(284, 512, 1, "line"),\
			"11" = list(112, 427, 3, "line"),\
			"12" = list(223, 427, 1, "aoe"),\
			"13" = list(345, 427, 2, "buff"),\
			"14" = list(456, 427, 3, "aoe"),\
			"21" = list(54, 359, 4, "aoe"),\
			"22" = list(514, 359, 4, "buff"),\
			"31" = list(112, 292, 4, "buff"),\
			"32" = list(223, 292, 3, "buff"),\
			"33" = list(345, 292, 5, "line"),\
			"34" = list(456, 292, 4, "debuff"),\
			"CROWN" = list(284, 214, 5, "debuff"),\
			"N1" = list(284, 360, 2, "aoe"),\
			"N2" = list(168, 427, 2, "debuff"),\
			"N3" = list(400, 427, 2, "line"),\
			"N4" = list(168, 292, 3, "debuff"),\
			"N5" = list(400, 292, 4, "line"),\
			"N6" = list(254, 470, 1, "buff"),\
			"N7" = list(314, 470, 1, "debuff"),\
			"N8" = list(254, 253, 3, "aoe"),\
			"SHELF_M1" = list(112, 616, 2, "mage passive"),\
			"SHELF_M2" = list(160, 616, 4, "mage passive"),\
			"SHELF_P" = list(284, 616, 5, "pinnacle"),\
			"SHELF_S2" = list(408, 616, 4, "spell passive"),\
			"SHELF_S1" = list(456, 616, 3, "spell passive")\
		),\
		"links" = list(\
			list("13", "32"),\
			list("14", "22"),\
			list("21", "31"),\
			list("22", "34"),\
			list("33", "CROWN"),\
			list("11", "21"),\
			list("12", "N1"),\
			list("N1", "33"),\
			list("11", "N2"),\
			list("N2", "12"),\
			list("13", "N3"),\
			list("N3", "14"),\
			list("31", "N4"),\
			list("N4", "32"),\
			list("33", "N5"),\
			list("N5", "34"),\
			list("ENTRY", "N6"),\
			list("N6", "12"),\
			list("ENTRY", "N7"),\
			list("N7", "13"),\
			list("32", "N8"),\
			list("N8", "CROWN")\
		))\
)

var/list/ARCANE_PAGES = list()
var/ARCANE_PAGES_BUILT = 0

globalTracker/var
	list/MAGE_TIER_INVEST = list(0, 0, 4, 8, 12)

proc/ArcaneRegisterPage(element, key, path)
	if(!ARCANE_PAGES[element]) ARCANE_PAGES[element] = list()
	var/list/E = ARCANE_PAGES[element]
	E[key] = path

proc/BuildArcanePageRegistry()
	if(ARCANE_PAGES_BUILT) return
	ARCANE_PAGES_BUILT = 1
	for(var/t in typesof(/obj/Skills))
		var/obj/Skills/S = t
		if(!initial(S.IsSpell)) continue
		var/e = initial(S.SpellElement)
		var/k = initial(S.PageKey)
		if(!e || !k) continue
		ArcaneRegisterPage(e, k, t)

proc/ArcanePagePath(element, key)
	BuildArcanePageRegistry()
	var/list/E = ARCANE_PAGES[element]
	if(!E) return null
	return E[key]

proc/ArcanePageKeyFor(element, path)
	BuildArcanePageRegistry()
	var/list/E = ARCANE_PAGES[element]
	if(!E) return null
	for(var/k in E)
		if(E[k] == path) return k
	return null

proc/ArcaneTree(element)
	return ARCANE_TREES[element]

proc/ArcaneTreeNodes(element)
	var/list/T = ARCANE_TREES[element]
	return T ? T["nodes"] : null

proc/ArcaneTreeLinks(element)
	var/list/T = ARCANE_TREES[element]
	return T ? T["links"] : null

proc/ArcaneTreeAccent(element)
	var/list/T = ARCANE_TREES[element]
	return T ? T["accent"] : "#ffe2b0"

proc/ArcaneNodeNeighbours(element, key)
	var/list/out = list()
	var/list/links = ArcaneTreeLinks(element)
	if(!links) return out
	for(var/list/l in links)
		if(l[1] == key) out += l[2]
		else if(l[2] == key) out += l[1]
	return out

proc/ArcaneTreeFile(element)
	var/list/T = ARCANE_TREES[element]
	if(!T) return null
	switch(T["folder"])
		if("fire") return '_Reworks/Arcane/Icons/fire/tree.png'
		if("water") return '_Reworks/Arcane/Icons/water/tree.png'
		if("ice") return '_Reworks/Arcane/Icons/ice/tree.png'
		if("air") return '_Reworks/Arcane/Icons/air/tree.png'
		if("lightning") return '_Reworks/Arcane/Icons/lightning/tree.png'
		if("earth") return '_Reworks/Arcane/Icons/earth/tree.png'
		if("light") return '_Reworks/Arcane/Icons/light/tree.png'
		if("dark") return '_Reworks/Arcane/Icons/dark/tree.png'
		if("space") return '_Reworks/Arcane/Icons/space/tree.png'
		if("time") return '_Reworks/Arcane/Icons/time/tree.png'
	return null

proc/ArcanePoweredIcon(element)
	var/list/T = ARCANE_TREES[element]
	if(!T) return null
	switch(T["folder"])
		if("fire") return '_Reworks/Arcane/Icons/fire/powered icon.png'
		if("water") return '_Reworks/Arcane/Icons/water/powered icon.png'
		if("ice") return '_Reworks/Arcane/Icons/ice/powered icon.png'
		if("air") return '_Reworks/Arcane/Icons/air/powered icon.png'
		if("lightning") return '_Reworks/Arcane/Icons/lightning/powered icon.png'
		if("earth") return '_Reworks/Arcane/Icons/earth/powered icon.png'
		if("light") return '_Reworks/Arcane/Icons/light/powered icon.png'
		if("dark") return '_Reworks/Arcane/Icons/dark/powered icon.png'
		if("space") return '_Reworks/Arcane/Icons/space/powered icon.png'
		if("time") return '_Reworks/Arcane/Icons/time/powered icon.png'
	return null

proc/ArcaneLockedIcon(kind)
	switch(kind)
		if("aoe") return '_Reworks/Arcane/Icons/generics/unpowered aoe.png'
		if("autohit") return '_Reworks/Arcane/Icons/generics/unpowered autohit.png'
		if("buff") return '_Reworks/Arcane/Icons/generics/unpowered buff.png'
		if("debuff") return '_Reworks/Arcane/Icons/generics/unpowered debuff.png'
		if("line") return '_Reworks/Arcane/Icons/generics/unpowered line.png'
		if("mage passive") return '_Reworks/Arcane/Icons/generics/unpowered mage passive.png'
		if("projectile") return '_Reworks/Arcane/Icons/generics/unpowered projectile.png'
		if("spell passive") return '_Reworks/Arcane/Icons/generics/unpowered spell passive.png'
	return '_Reworks/Arcane/Icons/generics/unpowered pinnacle.png'

proc/ArcaneKindIcon(element, kind)
	var/list/T = ARCANE_TREES[element]
	if(!T) return ArcaneLockedIcon(kind)
	switch(T["folder"])
		if("fire")
			switch(kind)
				if("aoe") return '_Reworks/Arcane/Icons/fire/aoe.png'
				if("autohit") return '_Reworks/Arcane/Icons/fire/autohit.png'
				if("buff") return '_Reworks/Arcane/Icons/fire/buff.png'
				if("debuff") return '_Reworks/Arcane/Icons/fire/debuff.png'
				if("line") return '_Reworks/Arcane/Icons/fire/line.png'
				if("mage passive") return '_Reworks/Arcane/Icons/fire/mage passive.png'
				if("projectile") return '_Reworks/Arcane/Icons/fire/projectile.png'
				if("spell passive") return '_Reworks/Arcane/Icons/fire/spell passive.png'
				if("pinnacle") return '_Reworks/Arcane/Icons/fire/pinnacle icon.png'
		if("water")
			switch(kind)
				if("aoe") return '_Reworks/Arcane/Icons/water/aoe.png'
				if("autohit") return '_Reworks/Arcane/Icons/water/autohit.png'
				if("buff") return '_Reworks/Arcane/Icons/water/buff.png'
				if("debuff") return '_Reworks/Arcane/Icons/water/debuff.png'
				if("line") return '_Reworks/Arcane/Icons/water/line.png'
				if("mage passive") return '_Reworks/Arcane/Icons/water/mage passive.png'
				if("projectile") return '_Reworks/Arcane/Icons/water/projectile.png'
				if("spell passive") return '_Reworks/Arcane/Icons/water/spell passive.png'
				if("pinnacle") return '_Reworks/Arcane/Icons/water/pinnacle icon.png'
		if("ice")
			switch(kind)
				if("aoe") return '_Reworks/Arcane/Icons/ice/aoe.png'
				if("autohit") return '_Reworks/Arcane/Icons/ice/autohit.png'
				if("buff") return '_Reworks/Arcane/Icons/ice/buff.png'
				if("debuff") return '_Reworks/Arcane/Icons/ice/debuff.png'
				if("line") return '_Reworks/Arcane/Icons/ice/line.png'
				if("mage passive") return '_Reworks/Arcane/Icons/ice/mage passive.png'
				if("projectile") return '_Reworks/Arcane/Icons/ice/projectile.png'
				if("spell passive") return '_Reworks/Arcane/Icons/ice/spell passive.png'
				if("pinnacle") return '_Reworks/Arcane/Icons/ice/pinnacle icon.png'
		if("air")
			switch(kind)
				if("aoe") return '_Reworks/Arcane/Icons/air/aoe.png'
				if("autohit") return '_Reworks/Arcane/Icons/air/autohit.png'
				if("buff") return '_Reworks/Arcane/Icons/air/buff.png'
				if("debuff") return '_Reworks/Arcane/Icons/air/debuff.png'
				if("line") return '_Reworks/Arcane/Icons/air/line.png'
				if("mage passive") return '_Reworks/Arcane/Icons/air/mage passive.png'
				if("projectile") return '_Reworks/Arcane/Icons/air/projectile.png'
				if("spell passive") return '_Reworks/Arcane/Icons/air/spell passive.png'
				if("pinnacle") return '_Reworks/Arcane/Icons/air/pinnacle icon.png'
		if("lightning")
			switch(kind)
				if("aoe") return '_Reworks/Arcane/Icons/lightning/aoe.png'
				if("autohit") return '_Reworks/Arcane/Icons/lightning/autohit.png'
				if("buff") return '_Reworks/Arcane/Icons/lightning/buff.png'
				if("debuff") return '_Reworks/Arcane/Icons/lightning/debuff.png'
				if("line") return '_Reworks/Arcane/Icons/lightning/line.png'
				if("mage passive") return '_Reworks/Arcane/Icons/lightning/mage passive.png'
				if("projectile") return '_Reworks/Arcane/Icons/lightning/projectile.png'
				if("spell passive") return '_Reworks/Arcane/Icons/lightning/spell passive.png'
				if("pinnacle") return '_Reworks/Arcane/Icons/lightning/pinnacle icon.png'
		if("earth")
			switch(kind)
				if("aoe") return '_Reworks/Arcane/Icons/earth/aoe.png'
				if("autohit") return '_Reworks/Arcane/Icons/earth/autohit.png'
				if("buff") return '_Reworks/Arcane/Icons/earth/buff.png'
				if("debuff") return '_Reworks/Arcane/Icons/earth/debuff.png'
				if("line") return '_Reworks/Arcane/Icons/earth/line.png'
				if("mage passive") return '_Reworks/Arcane/Icons/earth/mage passive.png'
				if("projectile") return '_Reworks/Arcane/Icons/earth/projectile.png'
				if("spell passive") return '_Reworks/Arcane/Icons/earth/spell passive.png'
				if("pinnacle") return '_Reworks/Arcane/Icons/earth/pinnacle icon.png'
		if("light")
			switch(kind)
				if("aoe") return '_Reworks/Arcane/Icons/light/aoe.png'
				if("autohit") return '_Reworks/Arcane/Icons/light/autohit.png'
				if("buff") return '_Reworks/Arcane/Icons/light/buff.png'
				if("debuff") return '_Reworks/Arcane/Icons/light/debuff.png'
				if("line") return '_Reworks/Arcane/Icons/light/line.png'
				if("mage passive") return '_Reworks/Arcane/Icons/light/mage passive.png'
				if("projectile") return '_Reworks/Arcane/Icons/light/projectile.png'
				if("spell passive") return '_Reworks/Arcane/Icons/light/spell passive.png'
				if("pinnacle") return '_Reworks/Arcane/Icons/light/pinnacle icon.png'
		if("dark")
			switch(kind)
				if("aoe") return '_Reworks/Arcane/Icons/dark/aoe.png'
				if("autohit") return '_Reworks/Arcane/Icons/dark/autohit.png'
				if("buff") return '_Reworks/Arcane/Icons/dark/buff.png'
				if("debuff") return '_Reworks/Arcane/Icons/dark/debuff.png'
				if("line") return '_Reworks/Arcane/Icons/dark/line.png'
				if("mage passive") return '_Reworks/Arcane/Icons/dark/mage passive.png'
				if("projectile") return '_Reworks/Arcane/Icons/dark/projectile.png'
				if("spell passive") return '_Reworks/Arcane/Icons/dark/spell passive.png'
				if("pinnacle") return '_Reworks/Arcane/Icons/dark/pinnacle icon.png'
		if("space")
			switch(kind)
				if("aoe") return '_Reworks/Arcane/Icons/space/aoe.png'
				if("autohit") return '_Reworks/Arcane/Icons/space/autohit.png'
				if("buff") return '_Reworks/Arcane/Icons/space/buff.png'
				if("debuff") return '_Reworks/Arcane/Icons/space/debuff.png'
				if("line") return '_Reworks/Arcane/Icons/space/line.png'
				if("mage passive") return '_Reworks/Arcane/Icons/space/mage passive.png'
				if("projectile") return '_Reworks/Arcane/Icons/space/projectile.png'
				if("spell passive") return '_Reworks/Arcane/Icons/space/spell passive.png'
				if("pinnacle") return '_Reworks/Arcane/Icons/space/pinnacle icon.png'
		if("time")
			switch(kind)
				if("aoe") return '_Reworks/Arcane/Icons/time/aoe.png'
				if("autohit") return '_Reworks/Arcane/Icons/time/autohit.png'
				if("buff") return '_Reworks/Arcane/Icons/time/buff.png'
				if("debuff") return '_Reworks/Arcane/Icons/time/debuff.png'
				if("line") return '_Reworks/Arcane/Icons/time/line.png'
				if("mage passive") return '_Reworks/Arcane/Icons/time/mage passive.png'
				if("projectile") return '_Reworks/Arcane/Icons/time/projectile.png'
				if("spell passive") return '_Reworks/Arcane/Icons/time/spell passive.png'
				if("pinnacle") return '_Reworks/Arcane/Icons/time/pinnacle icon.png'
	return ArcaneLockedIcon(kind)
