mob/var/tmp/hudActive = 0
obj/screen_object
	name = "screen object"
	appearance_flags = NO_CLIENT_COLOR | TILE_BOUND
	icon = null
	icon_state = "ffsfd"
	var/tmp/client/client

	New(client/_client)
		client = _client
		..()

	Write()
		return

	Read()
		return

mob/proc/GenerateHUD()
	if(!client) return
	client.ClearHUD()
	if(client.buildMode)
		AddBuildButtons()
	hudActive = 1

obj/screen_object/screen_button
	plane = 10

	Click(location, control, params)
		ButtonUse()

	proc/ButtonUse()

obj/screen_object/screen_button/toggle
	var
		active = 0
		obj/screen_object/button_darken
		obj/screen_object/toggle_grouper/button_group

	New()
		..()
		button_darken = new
		button_darken.alpha = 125
		button_darken.icon = icon
		button_darken.icon_state = "blank"
		button_darken.plane = plane
		button_darken.layer = layer + 0.1
		button_darken.vis_flags = VIS_INHERIT_ID

	ButtonUse()
		if(!button_group) return
		if(!active)
			button_group.SetActive(src)
		else
			button_group.SetActive(null)

	proc
		AddOverlay()
			vis_contents |= button_darken

		RemoveOverlay()
			vis_contents -= button_darken

		Activate()
			active = 1

		Deactivate()
			active = 0

obj/screen_object/toggle_grouper
	var
		list/group = list()
		obj/screen_object/screen_button/toggle/active

	proc
		AddButton(obj/screen_object/screen_button/toggle/B)
			if(!B) return
			group |= B
			B.button_group = src

		AddOverlays(obj/screen_object/O)
			for(var/obj/screen_object/screen_button/toggle/B in group)
				O.vis_contents |= B

		SetActive(obj/screen_object/screen_button/toggle/O)
			active = O
			if(!active) active = group[1]
			for(var/obj/screen_object/screen_button/toggle/B in group)
				B.RemoveOverlay()
				B.Deactivate()
			active.AddOverlay()
			active.Activate()
client/var/hudFadeTime = 150
client/var/maxHUDOpacity = 255
client/var/minHUDOpacity = 0
client/var/hudScale = 1

obj/screen_object/maptext_holder
	var
		text_size = "7pt"
		text_color = "#000f"
		outline_size = "1px"
		outline_color = "#ffffff"
		font_family = "Walk The Moon"
		text_align = "center"
		padding = 2

	maptext_width = TILE_WIDTH * 8
	maptext_height = TILE_HEIGHT

	proc
		CenterVertical()
			maptext_y = -(maptext_height / 2) + TILE_HEIGHT / 2

		CenterAlign()
			maptext_x = -(maptext_width / 2) + TILE_WIDTH / 2

		RightAlign()
			maptext_x = -(maptext_width + padding)

		LeftAlign()
			maptext_x = padding

		SetText(text, center_y = 0)
			maptext = "<span style='font-family:[font_family];font-size:[text_size];text-align:[text_align];\
						-dm-text-outline:[outline_size] [outline_color];color:[text_color]'>[text]</span>"
			if(center_y)
				CenterVertical()

			switch(text_align)
				if("right")
					RightAlign()
				if("left")
					LeftAlign()
				else
					CenterAlign()

var/list/BuildTools = list(BUILD_PAINT, BUILD_LINE, BUILD_PICK, BUILD_FILL, BUILD_RECT, BUILD_RECT_HOLLOW, BUILD_ELLIPSE, BUILD_SELECT)

proc/DirectionToState(direction)
	switch(direction)
		if(NORTH) return "N"
		if(SOUTH) return "S"
		if(EAST) return "E"
		if(WEST) return "W"
		if(NORTHWEST) return "NW"
		if(NORTHEAST) return "NE"
		if(SOUTHWEST) return "SW"
		if(SOUTHEAST) return "SE"

obj/screen_object/screen_button/offset
	icon = 'build mode small icons.dmi'
	var
		axis = "y"
		direction = 1

	ButtonUse()
		usr?.client?.OffsetSelections(axis, direction)

obj/screen_object/screen_button/toggle/direction
	icon = 'build mode small icons.dmi'

	var
		build_dir

	Activate()
		..()
		if(istype(usr?.Target, /obj/Turfs/CustomObj1))
			usr?.CustomObj1State = DirectionToState(build_dir)
		usr?.client?.buildDir = build_dir

obj/screen_object/screen_button/toggle/build_button
	plane = 10
	icon = 'build mode buttons.dmi'
	icon_state = "blank"
	var
		build_tool

	Activate()
		..()
		usr?.client?.buildTool = build_tool

	Deactivate()
		..()
		usr?.client?.buildTool = BUILD_PAINT

	proc
		SetupButton(tool)
			build_tool = tool
			icon_state = ToolIconState(build_tool)
			SetMaptext()

		ToolIconState(tool_name)
			switch(tool_name)
				if(BUILD_PAINT) return "paint"
				if(BUILD_RECT) return "rect_fill"
				if(BUILD_RECT_HOLLOW) return "rect_hollow"
				if(BUILD_LINE) return "line"
				if(BUILD_FILL) return "fill"
				if(BUILD_ELLIPSE) return "ellipse"
				if(BUILD_SELECT) return "select"
				if(BUILD_PICK) return "dropper"
				else return "blank"

		SetMaptext()
			maptext_width = 256
			maptext_x = -(maptext_width + 4)
			maptext = "<span style='font-family:Walk The Moon;font-size:7pt;text-align:right;-dm-text-outline:1px white;color:black]'>[build_tool]</span>"

mob/var/tmp/obj/screen_object/build_hud_holder
mob/proc/AddBuildButtons()
	client.screen -= build_hud_holder
	build_hud_holder = new(client)
	build_hud_holder.screen_loc = "RIGHT-0.5,TOP-0.5"
	client.screen += build_hud_holder
	var/obj/screen_object/toggle_grouper/G = new(client)
	var/count = 0, scale = client.hudScale + 0.5
	for(var/i in BuildTools)
		var/obj/screen_object/screen_button/toggle/build_button/B = new(client)
		B.SetupButton(i)
		B.transform = matrix().Scale(scale)
		B.pixel_y = floor(-((16 * scale) + (16 * scale) / 2) * count)
		B.color = hudColor
		G.AddButton(B)
		if(i == BUILD_PAINT)
			G.SetActive(B)
		count++
	G.AddOverlays(build_hud_holder)

	G = new
	for(var/i in CARDINAL_DIRECTIONS+ORDINAL_DIRECTIONS)
		var/obj/screen_object/screen_button/toggle/direction/B = new(client)
		B.icon_state = DirectionToState(i)
		B.build_dir = i
		B.transform = matrix().Scale(scale)
		B.pixel_y = floor(-((16 * scale) + (16 * scale) / 2) * count)
		B.pixel_y += floor(8 * scale)
		B.pixel_x = -floor((16 * scale) / 4)
		if(i == EAST)
			B.pixel_y -= floor((8 * scale) + (8 * scale) / 4)
			B.pixel_x += floor((8 * scale) + (8 * scale) / 4)
		if(i == WEST)
			B.pixel_y -= floor((8 * scale) + (8 * scale) / 4)
			B.pixel_x -= floor((8 * scale) + (8 * scale) / 4)
		if(i == SOUTH)
			B.pixel_y -= floor((16 * scale) + (16 * scale) / 4)
		if(i == NORTHEAST)
			B.pixel_x += floor((8 * scale) + (8 * scale) / 4)
		if(i == NORTHWEST)
			B.pixel_x -= floor((8 * scale) + (8 * scale) / 4)
		if(i == SOUTHEAST)
			B.pixel_y -= floor((16 * scale) + (16 * scale) / 4)
			B.pixel_x += floor((8 * scale) + (8 * scale) / 4)
		if(i == SOUTHWEST)
			B.pixel_y -= floor((16 * scale) + (16 * scale) / 4)
			B.pixel_x -= floor((8 * scale) + (8 * scale) / 4)
		B.color = hudColor
		G.AddButton(B)
	count++
	G.AddOverlays(build_hud_holder)

	for(var/i in list("UP", "DOWN", "LEFT", "RIGHT"))
		var/obj/screen_object/screen_button/offset/B = new(client)
		B.icon_state = i
		B.transform = matrix().Scale(scale)
		B.pixel_y = floor(-((18 * scale) + (18 * scale) / 2) * count)
		B.pixel_y += floor(8 * scale)
		B.pixel_x = -floor((16 * scale) / 4)
		if(i == "RIGHT")
			B.axis = "x"
			B.pixel_x += floor((8 * scale) + (8 * scale) / 4)
			B.pixel_y -= floor((8 * scale) + (8 * scale) / 4)
		if(i == "LEFT")
			B.axis = "x"
			B.direction = -1
			B.pixel_x -= floor((8 * scale) + (8 * scale) / 4)
			B.pixel_y -= floor((8 * scale) + (8 * scale) / 4)
		if(i == "DOWN")
			B.direction = -1
			B.pixel_y -= floor((8 * scale) + (8 * scale) / 4)
		B.color = hudColor
		build_hud_holder.vis_contents |= B
	count++

client/proc/ClearHUD()
	for(var/obj/screen_object/O in screen)
		screen -= O