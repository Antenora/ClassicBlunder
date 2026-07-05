/mob/var/StyleRating = 0
/mob/var/tmp/StyleRatingExpiry = 0
/mob/var/tmp/StyleRatingDecaying = FALSE
/mob/var/tmp/StyleRatingLastWasPose = FALSE
/mob/var/tmp/StyleRatingRPPauseRemainder = 0

/mob/proc/getStyleRank()
    switch(StyleRating)
        if(1) return "D"
        if(2) return "C"
        if(3) return "B"
        if(4) return "A"
        if(5) return "S"
        if(6) return "SS"
        if(7) return "SSS"
    return ""

/mob/proc/getStyleBonusMult()
    if(passive_handler.Get("Smokin' Sick Style!!!"))
        return 2
    if(passive_handler.Get("Smokin'!"))
        return 1.5
    return 1

/mob/proc/gainStyleRating(n = 1, wasPose = FALSE)
    if(!passive_handler.Get("Stylish")) return
    if(wasPose && StyleRatingLastWasPose) return
    StyleRatingLastWasPose = wasPose
    StyleRating = min(StyleRating + n, 7)
    StyleRatingExpiry = world.time + Second(30)
    client?.updateStyleRating()
    startStyleRatingDecay()
    pauseStyleRatingExpiryForRP()

/mob/proc/demonCelestialStyleRatingFreezesInRP()
    return isRace(CELESTIAL) && CelestialAscension == "Demon"

/mob/proc/pauseStyleRatingExpiryForRP()
    if(!demonCelestialStyleRatingFreezesInRP()) return
    if(!PureRPMode) return
    if(StyleRating <= 0) return
    StyleRatingRPPauseRemainder = max(0, StyleRatingExpiry - world.time)
    StyleRatingExpiry = world.time + 999999999

/mob/proc/resumeStyleRatingExpiryAfterRP()
    if(!demonCelestialStyleRatingFreezesInRP()) return
    if(StyleRating <= 0)
        StyleRatingRPPauseRemainder = 0
        return
    if(StyleRatingRPPauseRemainder > 0)
        StyleRatingExpiry = world.time + StyleRatingRPPauseRemainder
    else
        StyleRatingExpiry = world.time
    StyleRatingRPPauseRemainder = 0

/mob/proc/startStyleRatingDecay()
    if(StyleRatingDecaying) return
    StyleRatingDecaying = TRUE
    spawn()
        while(StyleRating > 0)
            sleep(10)
            if(demonCelestialStyleRatingFreezesInRP() && PureRPMode)
                continue
            if(StyleRating > 0 && world.time >= StyleRatingExpiry)
                resetStyleRating()
                break
        StyleRatingDecaying = FALSE

/mob/proc/resetStyleRating()
    StyleRating = 0
    StyleRatingLastWasPose = FALSE
    StyleRatingRPPauseRemainder = 0
    lastInnovationDemonMagic = null
    client?.updateStyleRating()

/client/var/tmp/obj/styleRatingHolder = new()

/client/proc/updateStyleRating()
    if(styleRatingHolder)
        if(mob.StyleRating > 0)
            if(!(styleRatingHolder in screen))
                styleRatingHolder.screen_loc = "RIGHT-0.25,BOTTOM+1.80"
                screen += styleRatingHolder
            styleRatingHolder.icon = 'Icons/StyleAssets.dmi'
            styleRatingHolder.icon_state = mob.getStyleRank()
            styleRatingHolder.maptext = ""
            styleRatingHolder.layer = FLOAT_LAYER
            styleRatingHolder.appearance_flags = PIXEL_SCALE
            styleRatingHolder.filters = null
            if(mob.StyleRating >= 5)
                styleRatingHolder.filters = list(filter(type="drop_shadow", x=0, y=0, size=2, offset=1, color="#ff2222"))
        else
            styleRatingHolder.filters = null
            screen -= styleRatingHolder
