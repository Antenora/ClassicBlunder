obj/Effects/SpiritCommandFX
	Lifetime = -1
	Grabbable = 0
	Destructable = 0
	Savable = 0
	gfx_transient_visual = 1
	mouse_opacity = 0
	layer = EFFECTS_LAYER
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

	proc/Play(mob/User, FXIcon, FXState, FXColor, Duration, FXScale, OffsetX, OffsetY)
		if(!User || !FXIcon)
			del src
			return
		Target = User
		icon = FXIcon
		icon_state = FXState
		color = FXColor
		var/icon/art = icon(FXIcon, FXState)
		pixel_x = (world.icon_size - art.Width()) / 2 + OffsetX
		pixel_y = (world.icon_size - art.Height()) / 2 + OffsetY
		transform = matrix() * FXScale
		User.vis_contents += src
		animate(src, alpha = 0, time = max(1, Duration), transform = matrix() * (FXScale * 1.4))
		spawn(max(1, Duration) + 1)
			if(src)
				EffectFinish()
				del src

obj/Skills/Buffs/SpiritCommands
	var/SpiritFXIcon = 'Icons/Effects/KenShockwave.dmi'
	var/SpiritFXState = ""
	var/SpiritFXColor = "#FFD966"
	var/SpiritFXDuration = 10 //deciseconds timer, so 10 = 1 second
	var/SpiritFXScale = 0.25
	var/SpiritFXOffsetX = 0
	var/SpiritFXOffsetY = 0

	proc/PlaySpiritGraphics(mob/User)
		if(!User || !SpiritFXIcon) return
		var/obj/Effects/SpiritCommandFX/F = new
		F.Play(User, SpiritFXIcon, SpiritFXState, SpiritFXColor, SpiritFXDuration, SpiritFXScale, SpiritFXOffsetX, SpiritFXOffsetY)



mob/proc/GetActiveSpiritCommands() // for CharacterCard
	var/list/out = list()
	RefreshSpiritCommandStates()

	if(SpiritNextDamageMult > 1)
		if(SpiritNextDamageMult >= 2.2)
			for(var/obj/Skills/Buffs/SpiritCommands/Instant/Soul/S in src)
				out += S
				break
		else
			for(var/obj/Skills/Buffs/SpiritCommands/Instant/Valor/V in src)
				out += V
				break

	if(SpiritFlashReady || SpiritFlashUntil)
		for(var/obj/Skills/Buffs/SpiritCommands/Instant/Flash/F in src)
			out += F
			break

	if(SpiritBullseyeReady || SpiritBullseyeUntil)
		for(var/obj/Skills/Buffs/SpiritCommands/Instant/Bullseye/B in src)
			out += B
			break

	if(SpiritPersistReady || SpiritPersistUntil)
		for(var/obj/Skills/Buffs/SpiritCommands/Instant/Persist/P in src)
			out += P
			break

	return out

// WILL METER
//SPIRAL TYPE


obj/WillMeterText
	mouse_opacity = 0
	plane = HUD_PLANE
	layer = 4
	maptext_height = 20

	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

client/var/tmp
	obj/WillMeterText/willMeterText
	obj/WillMeterText/willMeterSP
	willMeterShownFrame = -1
	willMeterTargetFrame = 0
	willMeterAnimating = FALSE

obj/WillMeter
	mouse_opacity = 0
	var/tmp/last_fill_state = -1

client/var/tmp
	obj/WillMeter/willMeterBack
	obj/WillMeter/willMeterFill
	obj/WillMeter/willMeterRainbow

var/global/list/WillMeterFillCache = list()
var/global/list/WillMeterRainbowCache = list()

proc/CacheWillMeterIcons()
	if(WillMeterFillCache.len == 21 && WillMeterRainbowCache.len == 21)
		return
	for(var/i = 0 to 20)
		var/state = "[i]"
		if(!WillMeterFillCache[state])
			WillMeterFillCache[state] = icon('willgauge_spiral_fill.dmi', state)
	for(var/i = 1 to 21)
		var/state = "[i]"
		if(!WillMeterRainbowCache[state])
			WillMeterRainbowCache[state] = icon('willgauge_spiral_fill_rainbow.dmi', state)


client/proc/SetWillMeterFrame(frame)
	if(!willMeterFill || !willMeterRainbow) return

	var/first_state = clamp(frame, 0, 20)
	var/second_state = 1 + clamp(frame - 20, 0, 20)

	var/icon/white_icon = WillMeterFillCache["[first_state]"]
	if(white_icon)
		if(willMeterFill.icon != white_icon)
			willMeterFill.icon = white_icon
		willMeterFill.icon_state = ""

	var/icon/rainbow_icon = WillMeterRainbowCache["[second_state]"]
	if(rainbow_icon)
		if(willMeterRainbow.icon != rainbow_icon)
			willMeterRainbow.icon = rainbow_icon
		willMeterRainbow.icon_state = ""

	willMeterRainbow.alpha = frame > 20 ? 255 : 0


client/proc/AnimateWillMeter()
	set waitfor = 0
	if(willMeterAnimating) return
	willMeterAnimating = TRUE

	while(willMeterShownFrame != willMeterTargetFrame)
		if(!mob || !mob.WillPowered() || !willMeterFill || !willMeterRainbow)
			break

		if(willMeterShownFrame < willMeterTargetFrame)
			willMeterShownFrame++
		else
			willMeterShownFrame--

		SetWillMeterFrame(willMeterShownFrame)
		sleep(1)

	willMeterAnimating = FALSE

client/proc/updateWillMeter()
	if(!mob || !mob.WillPowered())
		screen -= willMeterBack
		screen -= willMeterFill
		screen -= willMeterRainbow
		screen -= willMeterText
		screen -= willMeterSP
		return

	CacheWillMeterIcons()

	if(!willMeterBack) willMeterBack = new()
	if(!willMeterFill) willMeterFill = new()
	if(!willMeterRainbow) willMeterRainbow = new()

	if(!willMeterText)
		willMeterText = new()
		var/icon/back_art = icon('willgauge_spiral_back.png')
		willMeterText.maptext_width = back_art.Width()
		willMeterText.maptext_y = -10
	if(!willMeterSP)
		willMeterSP = new()
		var/icon/back_art = icon('willgauge_spiral_back.png')
		willMeterSP.maptext_width = back_art.Width()
		willMeterSP.maptext_y = -20

	var/meter_loc = "CENTER+9,BOTTOM+0.7"

	willMeterBack.screen_loc = meter_loc
	willMeterFill.screen_loc = meter_loc
	willMeterRainbow.screen_loc = meter_loc

	willMeterBack.plane = HUD_PLANE
	willMeterFill.plane = HUD_PLANE
	willMeterRainbow.plane = HUD_PLANE

	willMeterBack.layer = 1
	willMeterFill.layer = 2
	willMeterRainbow.layer = 3

	willMeterBack.invisibility = 0
	willMeterFill.invisibility = 0
	willMeterRainbow.invisibility = 0

	willMeterBack.alpha = 255
	willMeterFill.alpha = 255

	willMeterBack.icon = 'willgauge_spiral_back.png'
	willMeterBack.icon_state = ""

	var/will = clamp(mob.Will, 100, 220)

	willMeterTargetFrame = clamp(round((will - 100) / 3), 0, 40)

	if(willMeterShownFrame < 0)
		willMeterShownFrame = willMeterTargetFrame

	SetWillMeterFrame(willMeterShownFrame)
	AnimateWillMeter()

	if(!(willMeterBack in screen))
		screen += willMeterBack
	if(!(willMeterFill in screen))
		screen += willMeterFill
	if(!(willMeterRainbow in screen))
		screen += willMeterRainbow

	willMeterText.screen_loc = meter_loc
	var/display_will = round(mob.Will, 0.1)
	willMeterText.maptext = "<center><span style=\"[SHUD_FONT_STYLE]; color:#ffffff\">[display_will]</span></center>"

	willMeterSP.screen_loc = meter_loc
	var/display_SP = "[mob.Spirit]/[mob.SpiritMax]"
	willMeterSP.maptext = "<center><span style=\"[SHUD_FONT_STYLE]; color:#ffffff\">[display_SP] SP</span></center>"

	if(!(willMeterText in screen))
		screen += willMeterText
	if(!(willMeterSP in screen))
		screen += willMeterSP