/mob/var/tmp/bloodGauge/vampireBlood
/obj/basemeter
    appearance_flags = KEEP_TOGETHER
    mouse_opacity = 0
    var/width = 0
    var/height = 0
    var/orientation = NORTH
    var/tmp/obj/meter/foreground/fg
    var/tmp/obj/meter/container/bg // background
    var/tmp/obj/meter/bar/fill // fill
    var/tmp/obj/meter/mask/mask
    New()
        Build()
        vis_contents.Add(mask,fg)
        ..()
    Del()
        vis_contents.Remove(mask,fg)
        bg.vis_contents -= fill
        mask.vis_contents -= bg
    proc/Build()
        fg = new()
        bg = new()
        fill = new()
        mask = new()
        bg.vis_contents += fill
        mask.vis_contents += bg
    proc/setValue(ratio=1.0, duration=0)
        if(ratio <=1)
            ratio *= 1.25
        ratio = clamp(ratio, 0, 1)
        var/fx = 0
        var/fy = 0
        switch(orientation)
            if(NORTH)
                fy = -1
            if(SOUTH)
                fy = 1
            if(EAST)
                fx = -1
            if(WEST)
                fx = 1
        var/invratio = 1-ratio
        var/epx = fx * (width * invratio)
        var/epy = fy * (height * invratio)
        if(duration)
            animate(fill, pixel_w = epx, pixel_z = epy, time = duration, easing = SINE_EASING)
        else
            fill.pixel_w = epx
            fill.pixel_z = epy

/obj/meter
    icon = 'smallbar1.dmi'
    plane = FLOAT_PLANE
    layer = FLOAT_LAYER
    bar
        icon_state = "fill"
        // blend_mode = BLEND_INSET_OVERLAY

    container
        appearance_flags = KEEP_TOGETHER
        blend_mode = BLEND_MULTIPLY
        icon_state = "background"

    mask
        icon_state = "mask"

    foreground
        icon_state = "foreground" // RAAAAAAAAAAAAAAAAAA

bloodGauge
	var/obj/basemeter/root
	New(mob/p, screen_x, screen_y)
		if(p.Secret != "Vampire")
			del src
		else
			root = new()
			root.screen_loc = "1:[screen_x], 1:[screen_y]"
			root.width = 32
			root.height = 32
			root.orientation = NORTH
			root.setValue(0, 10)
			root.maptext_width = 64
			root.maptext_y = -16
			p.client.screen += root


	proc/fillGauge(y_offset, time2death)
		root.setValue(y_offset, time2death)