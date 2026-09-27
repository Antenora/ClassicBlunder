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

	lastWillMeterValue = null
	lastWillMeterSpirit = null
	lastWillMeterSpiritMax = null
	willMeterVisible = FALSE


obj/WillMeter
	mouse_opacity = 0
	plane = HUD_PLANE
	var/tmp/last_fill_state = -1
obj/WillMeter/Back
	icon = 'willgauge_spiral_back.png'
	layer = 1
obj/WillMeter/Fill
	icon = 'willgauge_spiral_fill.dmi'
	icon_state = "0"
	layer = 2
obj/WillMeter/Rainbow
	icon = 'willgauge_spiral_fill_rainbow.dmi'
	icon_state = "1"
	layer = 3
	alpha = 0


client/var/tmp
	obj/WillMeter/willMeterBack
	obj/WillMeter/willMeterFill
	obj/WillMeter/willMeterRainbow


client/var/tmp/willMeterResourcesLoaded = FALSE

client/proc/LoadWillMeterResources()
	if(willMeterResourcesLoaded)
		return

	willMeterResourcesLoaded = TRUE

	src << load_resource(
		'willgauge_spiral_back.png',
		'willgauge_spiral_fill.dmi',
		'willgauge_spiral_fill_rainbow.dmi',
		-1
	)


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


client/proc/InitializeWillMeter()
	LoadWillMeterResources()
	if(willMeterBack && willMeterFill && willMeterRainbow && willMeterText && willMeterSP)
		return
	if(willMeterBack)
		return

	var/meter_loc = "CENTER+9,BOTTOM+0.7"

	willMeterBack = new /obj/WillMeter/Back()
	willMeterFill = new /obj/WillMeter/Fill()
	willMeterRainbow = new /obj/WillMeter/Rainbow()

	willMeterText = new()
	willMeterSP = new()

	willMeterBack.screen_loc = meter_loc
	willMeterFill.screen_loc = meter_loc
	willMeterRainbow.screen_loc = meter_loc
	willMeterText.screen_loc = meter_loc
	willMeterSP.screen_loc = meter_loc

	var/icon/back_art = icon('willgauge_spiral_back.png')

	willMeterText.maptext_width = back_art.Width()
	willMeterText.maptext_y = -10

	willMeterSP.maptext_width = back_art.Width()
	willMeterSP.maptext_y = -20



client/proc/SetWillMeterFrame(frame)
	if(!willMeterFill || !willMeterRainbow)
		return

	frame = clamp(round(frame), 0, 40)

	var/first_state = clamp(frame, 0, 20)
	var/second_state = 1 + clamp(frame - 20, 0, 20)

	if(willMeterFill.last_fill_state != first_state)
		willMeterFill.last_fill_state = first_state
		willMeterFill.icon_state = "[first_state]"
	if(willMeterRainbow.last_fill_state != second_state)
		willMeterRainbow.last_fill_state = second_state
		willMeterRainbow.icon_state = "[second_state]"

	var/rainbow_alpha = frame > 20 ? 255 : 0
	if(willMeterRainbow.alpha != rainbow_alpha)
		willMeterRainbow.alpha = rainbow_alpha


client/proc/updateWillMeter()
	if(!mob || !mob.WillPowered())
		HideWillMeter()
		return

	InitializeWillMeter()
	ShowWillMeter()

	var/will = clamp(mob.Will, 100, 220)

	willMeterTargetFrame = clamp(round((will - 100) / 3), 0, 40)

	if(willMeterShownFrame < 0)
		willMeterShownFrame = willMeterTargetFrame

	SetWillMeterFrame(willMeterShownFrame)
	AnimateWillMeter()
	var/display_will = round(mob.Will, 0.1)

	if(lastWillMeterValue != display_will)
		lastWillMeterValue = display_will
		willMeterText.maptext = "<center><span style=\"[SHUD_FONT_STYLE]; color:#ffffff\">[display_will]</span></center>"
	if(lastWillMeterSpirit != mob.Spirit || lastWillMeterSpiritMax != mob.SpiritMax)
		lastWillMeterSpirit = mob.Spirit
		lastWillMeterSpiritMax = mob.SpiritMax
		willMeterSP.maptext = "<center><span style=\"[SHUD_FONT_STYLE]; color:#ffffff\">[mob.Spirit]/[mob.SpiritMax] SP</span></center>"



client/proc/ShowWillMeter()
	if(willMeterVisible)
		return

	if(willMeterBack)
		screen += willMeterBack
	if(willMeterFill)
		screen += willMeterFill
	if(willMeterRainbow)
		screen += willMeterRainbow
	if(willMeterText)
		screen += willMeterText
	if(willMeterSP)
		screen += willMeterSP

	willMeterVisible = TRUE


client/proc/HideWillMeter()
	if(!willMeterVisible)
		return
	screen -= willMeterBack
	screen -= willMeterFill
	screen -= willMeterRainbow
	screen -= willMeterText
	screen -= willMeterSP

	willMeterVisible = FALSE