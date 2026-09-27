#define BELT_ROW_LEFT 64
#define BELT_ROW_Y 66
#define BELT_PITCH 32
#define BELT_ICON_SZ 22
#define BELT_ICON_OFF 5
#define BELT_COUNT_INSET 6
#define BELT_DESC_BTN_Y 162

/atom/movable/shud/beltslot
	icon = SHUD_SLOT_ICON
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/slot_index
	var/obj/Items/cur
	var/on_cd = FALSE
	var/glow_on = FALSE
	var/atom/movable/shud/orbpart/iconpart
	var/atom/movable/shud/orbpart/cdfill
	var/atom/movable/shud/slottext/keytext
	var/atom/movable/shud/slottext/counttext
	New()
		..()
		iconpart = new
		iconpart.layer = SHUD_LAYER + 0.1
		iconpart.pixel_x = BELT_ICON_OFF
		iconpart.pixel_y = BELT_ICON_OFF
		cdfill = new
		cdfill.icon = 'HUD/cd_fill.png'
		cdfill.layer = SHUD_LAYER + 0.2
		cdfill.pixel_x = BELT_ICON_OFF
		cdfill.pixel_y = BELT_ICON_OFF
		cdfill.filters = filter(type="alpha", icon='HUD/cd_mask.png', y = CD_EMPTY_Y)
		cdfill.alpha = 0
		keytext = new
		keytext.layer = SHUD_LAYER + 0.5
		keytext.maptext_width = BELT_PITCH
		keytext.maptext_height = 12
		keytext.maptext_y = 0
		counttext = new
		counttext.layer = SHUD_LAYER + 0.6
		counttext.maptext_width = 8
		counttext.maptext_height = 14
		counttext.maptext_x = BELT_ICON_OFF + BELT_ICON_SZ - BELT_COUNT_INSET
		counttext.maptext_y = BELT_ICON_OFF
		vis_contents += iconpart
		vis_contents += cdfill
		vis_contents += keytext
		vis_contents += counttext
	Del()
		for(var/atom/movable/o in vis_contents)
			vis_contents -= o
			del o
		iconpart = null
		cdfill = null
		keytext = null
		counttext = null
		..()
	proc/SetVeilFrac(frac)
		cdfill.filters = filter(type="alpha", icon='HUD/cd_mask.png', y = CD_EMPTY_Y + round(CD_H * frac))
	proc/SetGlow(on)
		if(on == glow_on) return
		glow_on = on
		if(on)
			iconpart.filters = filter(type="drop_shadow", x=0, y=0, size=SLOT_GLOW_SIZE, color=SLOT_GLOW_COLOR)
		else
			iconpart.filters = null
	proc/SetHold(p)
		if(p < 0) p = 0
		if(p > 1) p = 1
		on_cd = FALSE
		iconpart.alpha = 255
		cdfill.alpha = 255
		SetVeilFrac(p)
		SetGlow(TRUE)
	proc/SetCount()
		if(!counttext) return
		if(!cur)
			if(counttext.maptext) counttext.maptext = ""
			return
		var/n = cur.BeltCount()
		if(n < 0) n = 0
		counttext.maptext_width = 6 * length("[n]") + 2
		counttext.maptext_x = BELT_ICON_OFF + BELT_ICON_SZ - 6 * length("[n]")
		counttext.maptext = "<span style=\"[SHUD_FONT_STYLE]; color:[n > 0 ? "#ffd76a" : "#ff5a5a"]\">[n]</span>"
	proc/SetItem(obj/Items/I, keylabel)
		cur = I
		on_cd = FALSE
		if(I)
			FitIconToBox(iconpart, I, BELT_ICON_SZ)
		else
			iconpart.icon = null
		iconpart.pixel_x = BELT_ICON_OFF
		iconpart.pixel_y = BELT_ICON_OFF
		iconpart.alpha = 255
		cdfill.alpha = 0
		SetVeilFrac(0)
		SetGlow(FALSE)
		if(keylabel)
			keytext.maptext = "<center><span style=\"[SHUD_FONT_STYLE]; color:#cfe9ff\">[keylabel]</span></center>"
		else
			keytext.maptext = ""
		SetCount()
	proc/UpdateCooldown(rem)
		if(!cur || rem <= 0)
			if(on_cd)
				iconpart.alpha = 255
				cdfill.alpha = 0
				SetVeilFrac(0)
				on_cd = FALSE
			return FALSE
		on_cd = TRUE
		iconpart.alpha = 120
		cdfill.alpha = 255
		var/total = cur.BeltCooldown
		var/frac = total ? rem / total : 1
		if(frac > 1) frac = 1
		animate(cdfill.filters[1], y = CD_EMPTY_Y + CD_H * frac, time = world.tick_lag, easing = LINEAR_EASING)
		return TRUE
	Click(location, control, params)
		if(!usr || !usr.client) return
		var/obj/Items/I = usr.BeltSlotItem(slot_index)
		if(params && findtext(params, "right=1"))
			if(!I) return
			if(usr.client.inv_desc_item == I)
				usr.client.HideItemDesc()
				return
			if(!usr.client.inv_open) usr.client.OpenInventory()
			usr.client.ShowItemDesc(I)
			return
		if(!I) return
		usr << "<font color='#ff6b6b'>[I.name] is used by holding its bound key, not by clicking the slot.</font>"
	MouseDrop(atom/over_object, atom/src_location, atom/over_location, src_control, over_control, params)
		if(!usr) return
		if(istype(over_object, /atom/movable/shud)) return
		usr.BeltClear(slot_index)

/atom/movable/shud/invbeltbtn
	layer = MINV_LAYER + 0.7
	mouse_opacity = 2
	maptext_height = 18
	var/obj/Items/item
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")
	Click(location, control, params)
		if(!usr || !item) return
		if(params && findtext(params, "right=1"))
			usr.client?.HideItemDesc()
			return
		var/n = usr.BeltSlotOf(item)
		if(n)
			usr << "<font color='#ff6b6b'>[item.name] is already on belt slot [n].</font>"
			return
		n = usr.BeltFirstFree()
		if(!n)
			usr << "<font color='#ff6b6b'>Your belt is full.</font>"
			return
		usr.BeltSet(n, item)

client/var/tmp
	list/belt_objs
	list/belt_slots

client/InitBeltHUD()
	ResetBeltHUD()
	if(!mob) return
	mob.BeltLoginSanitize()
	belt_objs = list()
	belt_slots = list()
	for(var/i = 1 to BELT_SLOTS)
		var/atom/movable/shud/beltslot/s = new
		s.slot_index = i
		belt_slots += s
		belt_objs += s
	PositionBeltHUD()
	for(var/atom/movable/o in belt_objs)
		screen += o
	RefreshBeltHUD()

client/PositionBeltHUD()
	if(!belt_slots || !belt_slots.len) return
	var/list/v = splittext("[view]", "x")
	if(v.len < 2) return
	var/tw = text2num(v[1])
	if(!tw) return
	var/mid = round((tw * world.icon_size) / 2)
	for(var/i = 1 to belt_slots.len)
		var/atom/movable/shud/beltslot/s = belt_slots[i]
		if(!s) continue
		s.screen_loc = "1:[mid + BELT_ROW_LEFT + (i - 1) * BELT_PITCH],SOUTH:[BELT_ROW_Y]"

client/ResetBeltHUD()
	belt_slots = null
	if(belt_objs)
		while(belt_objs.len)
			var/atom/movable/o = belt_objs[belt_objs.len]
			belt_objs.len--
			screen -= o
			del o
		belt_objs = null

client/proc/BeltKeyLabel(n)
	if(!mob) return ""
	var/k = mob.KeybindKey("item[n]") || mob.KeybindKey("item[n]", 2)
	return k ? KeyDisplay(k) : ""

client/RefreshBeltHUD()
	if(!mob || !belt_slots) return
	mob.InitBelt()
	for(var/atom/movable/shud/beltslot/s in belt_slots)
		s.SetItem(mob.BeltSlotItem(s.slot_index), BeltKeyLabel(s.slot_index))
	RefreshBeltCooldowns()

client/proc/RefreshBeltCooldowns()
	if(!mob || !belt_slots) return
	for(var/atom/movable/shud/beltslot/s in belt_slots)
		if(mob.belt_hold_slot == s.slot_index) continue
		s.UpdateCooldown(mob.BeltTypeCD(s.cur))

client/proc/BeltHoldPaint(n, p)
	if(!belt_slots) return
	for(var/atom/movable/shud/beltslot/s in belt_slots)
		if(s.slot_index == n)
			s.SetHold(p)
			return

client/BeltDropTarget(atom/over, obj/Items/I)
	if(!istype(over, /atom/movable/shud/beltslot)) return 0
	if(mob && I)
		var/atom/movable/shud/beltslot/s = over
		mob.BeltSet(s.slot_index, I)
	return 1

client/BeltDescButton(obj/Items/I, list/objs)
	if(!I || !I.BeltUsable || !islist(objs)) return
	var/atom/movable/shud/invbeltbtn/bb = new
	bb.item = I
	bb.maptext_width = 100
	bb.maptext = "<span style=\"[MINV_FONT]; color:#8be9ff\">&#9670; Slot</span>"
	bb.screen_loc = "[InvXLoc(252)],CENTER:[BELT_DESC_BTN_Y]"
	objs += bb
