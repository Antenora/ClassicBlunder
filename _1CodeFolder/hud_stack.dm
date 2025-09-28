#define CHAT_STYLE "<font face='Comic Sans' size=0.33>"


/obj/hud

	layer = FLY_LAYER
	alpha = 0
	var/tmp/obj/appear
	var/tmp/client/client
	proc/pulse()
		set waitfor = FALSE
		animate(appear, transform=matrix().Scale(1.25), time = 2, loop = -1)
		animate(transform=matrix(), time = 2)
	New(client/_client, o, _x, _y)
		screen_loc = "1:[_x],1:[_y]"
		client = _client
	beastman
		icon = 'BLANK.dmi'
		icon_state = "dot"
		var/tmp/obj/Skills/obj_to_ref
		var/var_to_ref

	mystic
		icon = 'BLANK.dmi'
		icon_state = "dot"
		var/tmp/obj/Skills/obj_to_ref
		var/var_to_ref
		proc/mysticTicker() // make this dynamic prob
			if(client.mob.UsingMysticStyle()[1]==TRUE && client.mob.StyleBuff)
				var/next_cast = client.mob.can_use_style_effect(FALSE)
				if(obj_to_ref)
					next_cast = obj_to_ref.vars["[var_to_ref]"] + glob.FAMILIAR_SKILL_CD
				animate(src, alpha = clamp(255-(next_cast - world.time), 0 , 255), time = 1)
				if(next_cast - world.time <= 0 && length(appear.filters) < 1)
					appear.filters = filter(type="outline", size=1, color=rgb(255, 234, 47))
					pulse()
				if(alpha <= 0 && length(appear.filters) > 0)
					appear.filters = list()
					animate(appear, flags = ANIMATION_END_NOW)
			else
				alpha = 0
				appear.filters = list()
				animate(appear)
		New(client/_client, o, _x, _y, obj/thing, vari)
			. = ..()
			appear = new()
			switch(o)
				if("MysticT0")
					appear.icon = 'chargedMystic.dmi'
				if("MysticT1")
					appear.icon = 'ui.dmi'
				if("SuperCharge")
					appear.icon = 'background.dmi'
					appear.icon_state = "plasma_style"
			appear.layer = FLY_LAYER
			appear.alpha = 255

			if(thing)
				obj_to_ref = thing
				var_to_ref = vari
			vis_contents += appear
		Update()
			mysticTicker()


	ftg
		icon = 'kunai.dmi'
		dir = EAST
		layer = FLY_LAYER
		alpha = 0
		Update()
			var/ftg = client.mob.passive_handler["Flying Thunder God"]
			var/counter = client.mob.IaidoCounter
			if(ftg)
				if(counter >= (15 - ftg))
					if(alpha != 255)
						animate(src, alpha = 255, time = 5, easing = SINE_EASING)
						filters = filter(type="outline", size=1, color=rgb(255, 255, 255))
				else
					if(alpha != 0)
						animate(src, alpha = 0, time = 2, easing = SINE_EASING)
						filters = list()
/obj/Bar
	icon = 'smallbar.dmi'
	icon_state = "fill"
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER
	blend_mode = BLEND_INSET_OVERLAY
	proc/animateBar(x_offset, time2death)
		animate(src, pixel_x = x_offset, time=time2death, easing = LINEAR_EASING)
/obj/Container
	appearance_flags = KEEP_TOGETHER
	icon = 'smallbar.dmi'
	icon_state = "background"
	New(newloc, obj/Bar/b, loc_x, loc_y)
		vis_contents += b
		if(loc_x && loc_y)
			screen_loc = "1:[loc_x],1:[loc_y]"

/obj/barbg
	icon = 'barbgs.dmi'
	New(state)
		icon_state = state



client/var/list/hud_ids = list()

client/proc/add_hud(id, atom/movable/a)
	screen += hud_ids[id] = a
	return a
client/proc/remove_hud(id)
	if(hud_ids[id])
		hud_ids[id].alpha = 0
		var/obj/thing = hud_ids[id]
		screen -= hud_ids[id]
		mob.contents -= hud_ids[id]

		del thing
		hud_ids -= id

/obj/bar
	var/tmp/linked_var = ""
	var/obj/Bar/meter
	var/obj/Container/holder
	var/obj/barbg/barbg
	screen_loc = "LEFT,BOTTOM"
	icon = 'smallbar.dmi'
	var/tmp/client/client

	Del()
		. = ..()
		client.screen -= holder
		client.screen -= barbg
		del holder
		del barbg
		del meter
	New(client/_client, o, _x, _y)
		name = "screen object"
		client = _client
		meter = new()
		holder=new(b=meter)
		linked_var = o
		holder.layer = FLY_LAYER+0.1
		holder.screen_loc = "1:[_x],1:[_y]"
		barbg = new(o)
		barbg.screen_loc = "1:[_x],1:[_y-7]"
		if(linked_var == "Grit")
			barbg.maptext = "[CHAT_STYLE][client.mob.passive_handler["[linked_var]"]]"
		else
			barbg.maptext = "[CHAT_STYLE][client.mob.vars["[linked_var]"]]"
		barbg.maptext_y = 16
		barbg.maptext_width = 62
		client.screen+=holder
		client.screen+=barbg
		meter.animateBar(-32,4)
	Update()
		
		var/val = 0 
		if(linked_var == "HotnCold")
			val = client.mob.vars["[linked_var]"]
			if(holder.alpha == 0 || barbg.alpha == 0)
				animate(holder, alpha = 255, time = 2)
				animate(barbg, alpha = 255, time = 2)
			if(linked_var == "HotnCold")
				meter.animateBar(clamp(val/3, -33, 33) , glob.STACK_ANIMATE_TIME)
				barbg.maptext = "[CHAT_STYLE][val]"
			return
		if(linked_var == "Grit")
			val = client.mob.passive_handler.Get("Grit")
		else
			val = client.mob.vars["[linked_var]"]
		if(val > 0)
			if(holder.alpha == 0 || barbg.alpha == 0)
				animate(holder, alpha = 255, time = 2)
				animate(barbg, alpha = 255, time = 2)
			barbg.maptext = "[CHAT_STYLE][val]"
			var/gap = 32 - glob.vars["MAX_[uppertext(linked_var)]_STACKS"]
			if(val > glob.vars["MAX_[uppertext(linked_var)]_STACKS"] )
				meter.animateBar(clamp(val/3, 0, 32) - 32,glob.STACK_ANIMATE_TIME)
			else
				if(val <= gap)
					gap = 0
				meter.animateBar(clamp(val+gap, 0, 32) - 32,glob.STACK_ANIMATE_TIME)
		else
			animate(holder, alpha = 0, time = 2)
			animate(barbg, alpha = 0, time = 2)


#define BAR_X_LOCS list("Fury" = 1, "Momentum" = 1, "Harden" = 1, "FTG" = 1, "MysticT0" = 1, "MysticT1" = 32, "SuperCharge" = 32, "HotnCold" = 128, "Grit" = 192)
#define BAR_Y_LOCS list("Fury" = 86, "Momentum" = 118, "Harden" = 150, "FTG" = 32, "MysticT0" = 64, "MysticT1" = 64, "SuperCharge" = 32, "HotnCold" = 1, "Grit" = 1)

/mob/proc/hudIsLive(option, path, toss_obj,var_callback)
	if(client.hud_ids[option])
		return TRUE
	else
		client.add_hud(option, new path(client, option, BAR_X_LOCS[option], BAR_Y_LOCS[option], toss_obj, var_callback))
		return FALSE
