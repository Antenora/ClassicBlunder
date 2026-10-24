#if fexists("../../../Icons/Private/Backdrops/space_blue.dmi") || fexists("Icons/Private/Backdrops/space_blue.dmi")
#define OUGI_BD_SPACE_BLUE_ART 'Icons/Private/Backdrops/space_blue.dmi'
#else
#define OUGI_BD_SPACE_BLUE_ART OUGI_ART_FALLBACK
#endif

/datum/ougi_backdrop/space_blue
	id = "space_blue"
	icon = OUGI_BD_SPACE_BLUE_ART
	layer_w = 272
	layer_h = 160
	scale = 4
	overlap = 320
	layers = list(list("back", 0.04, 0), list("stars", 0.06, 0))
