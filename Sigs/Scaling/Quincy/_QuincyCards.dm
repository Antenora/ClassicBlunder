#if fexists("../../../Icons/Private/Quincy/Cards/QuincyCards.dmi") || fexists("Icons/Private/Quincy/Cards/QuincyCards.dmi")
#define QUINCY_CARD_ICON 'Icons/Private/Quincy/Cards/QuincyCards.dmi'
#else
#define QUINCY_CARD_ICON 'Icons/Blasts/LightStrike.dmi'
#endif

#define QUINCY_CARD_BACK "backA"
#define QUINCY_CARD_FRAMES 4

/proc/QuincyCardFaces()
	return list(\
		"Blessing" = "face20",\
		"Strike" = "face05",\
		"Curse" = "face29",\
		"Meteor" = "face33",\
		"Steel Body" = "face10",\
		"Healed" = "face07",\
		"Clone" = "face25",\
		"Void" = "face37",\
		"Overreach" = "face12")

/proc/QuincyCardFace(category)
	var/list/f = QuincyCardFaces()
	var/s = f[category]
	return s ? s : "face20"
