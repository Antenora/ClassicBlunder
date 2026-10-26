/obj/Items/Tech/Holo_Sign
	name = "Holo-Sign"
	desc = "A hologram emitter that shows a short line of text above itself for anyone to read. Only its owner can change the text. It needs no power."
	icon = 'Tech.dmi'
	icon_state = "HoloEmitter"
	TechType = "Engineering"
	SubType = "Engineering"
	Pickable = 1
	Grabbable = 1
	var
		sign_text = ""

	New()
		..()
		spawn(1)
			if(src) SignSync()

	Click()
		if(loc == usr)
			usr << "Drop [src] where you want it, then click it to bolt it down and write on it."
			return
		if(!DeviceIsOwner(usr))
			if(sign_text) usr << "The sign reads: [html_encode(sign_text)]"
			return
		DeviceMenu(usr)

	DevicePowerChanged(on)
		SignSync()

	proc/SignShown()
		return length(sign_text) && isturf(loc)

	proc/SignSync()
		overlays.Cut()
		if(!SignShown())
			maptext = null
			return
		maptext_width = DEV_SIGN_WIDTH
		maptext_height = DEV_SIGN_HEIGHT
		maptext_x = (32 - DEV_SIGN_WIDTH) / 2
		maptext_y = DEV_SIGN_RISE
		maptext = "<center><span style=\"[MINV_FONT]; -dm-text-outline: 1px #000000; color:#8be9ff\">[html_encode(sign_text)]</span></center>"
		var/w = min(DEV_SIGN_WIDTH, length(sign_text) * 6 + 12)
		var/image/plate = image(EnvWhiteIcon())
		plate.color = "#0a1a24"
		plate.alpha = 190
		plate.appearance_flags = RESET_COLOR | RESET_ALPHA | PIXEL_SCALE
		var/matrix/m = matrix()
		m.Scale(w / 32, 20 / 32)
		m.Translate(0, DEV_SIGN_RISE + DEV_SIGN_HEIGHT / 2 - 16)
		plate.transform = m
		plate.layer = FLOAT_LAYER - 1
		overlays += plate

	proc/SignWrite(mob/M)
		var/t = Ask(M, "What should the sign say? Up to [DEV_SIGN_MAX] characters.", "[src]", sign_text, "text", null, 1)
		if(isnull(t) || !src) return
		t = trimtext(t)
		t = replacetext(t, "\n", " ")
		if(length(t) > DEV_SIGN_MAX) t = copytext(t, 1, DEV_SIGN_MAX + 1)
		sign_text = t
		SignSync()
		M << (length(t) ? "The sign now reads: [html_encode(t)]" : "You clear the sign.")

	DeviceActions(mob/M)
		. = ..()
		if(DeviceIsOwner(M)) . += "Write the sign"

	DeviceAct(mob/M, act)
		if(act == "Write the sign")
			SignWrite(M)
			return
		..()

	DeviceStatus(mob/M)
		. = ..()
		. += length(sign_text) ? "It reads: [sign_text]" : "It is blank."
