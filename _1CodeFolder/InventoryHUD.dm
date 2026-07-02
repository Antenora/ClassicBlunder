#define MINV_LAYER (FLY_LAYER+3)
#define MINV_COLS 6
#define MINV_ROWS 5
#define MINV_PER_PAGE (MINV_COLS * MINV_ROWS)
#define MINV_PITCH 34
#define MINV_GRID_TOP 48        // bottom-edge Y of the top slot row, rel center
#define MINV_GRID_LEFT -102     // left-edge X of col 0, rel center
#define MINV_FONT "font-family:'monogram'; font-size:12pt"

/var/list/INV_CATEGORIES = list("Misc", "Consumables")   // Gear lives in the Character menu's Gear tab

#define MINV_LEFT_SHIFT 150
/proc/InvXLoc(off)
	var/vx = off + MINV_LEFT_SHIFT
	return "[1 + (vx - vx % 32) / 32]:[vx % 32]"

mob/proc/MoneyTotal()
	. = 0
	for(var/obj/Money/M in src) . += M.Level
mob/proc/ManaBitsTotal()
	. = 0
	for(var/obj/Items/mineral/m in src) . += m.value

mob/proc/InvClassify(obj/Items/I)
	if(istype(I, /obj/Items/Sword) || istype(I, /obj/Items/Armor) || istype(I, /obj/Items/Enchantment/Staff))
		return "Gear"
	if(istype(I, /obj/Items/Edibles) || istype(I, /obj/Items/Flask))
		return "Consumables"
	return "Misc"

mob/proc/InvItemsFor(cat)
	var/list/items = list()
	for(var/obj/Items/I in src)
		if(istype(I, /obj/Items/mineral)) continue   // Mana Bits live only in the bottom-left readout
		if(InvClassify(I) != cat) continue
		items += I
	var/maxslot = 0
	for(var/obj/Items/I in items)
		if(I.invSlot > maxslot) maxslot = I.invSlot
	for(var/obj/Items/I in items)
		if(!I.invSlot)
			maxslot++
			I.invSlot = maxslot
	var/list/sorted = list()
	for(var/obj/Items/I in items)
		var/placed = 0
		for(var/j = 1 to sorted.len)
			var/obj/Items/S = sorted[j]
			if(I.invSlot < S.invSlot)
				sorted.Insert(j, I)
				placed = 1
				break
		if(!placed) sorted += I
	return sorted

/atom/movable/shud/invitem
	mouse_opacity = 2 // whole cell clickable even on transparent icon pixels
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	layer = MINV_LAYER + 0.3
	var/obj/Items/item
	proc/SetItem(obj/Items/I)
		item = I
		FitIconToBox(src, I, 32)
	MouseEntered(location, control, params)
		filters = filter(type="outline", size=1, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click(location, control, params)
		if(!item || !usr) return
		if(params && findtext(params, "right=1"))
			// same item closes the open blurb
			if(usr.client?.inv_desc_item == item)
				usr.client?.HideItemDesc()
			else
				usr.client?.ShowItemDesc(item)
			return
		spawn()
			item.Click()
			usr.client?.BuildInvPage()
	MouseDrop(atom/over_object, atom/src_location, atom/over_location, src_control, over_control, params)
		if(!item || !usr) return
		// dropped on another cell, swap their slot order
		if(istype(over_object, /atom/movable/shud/invitem))
			var/atom/movable/shud/invitem/tgt = over_object
			if(tgt.item && tgt.item != item)
				usr.client?.SwapInvSlots(item, tgt.item)
			return
		if(istype(over_object, /atom/movable/shud)) return // other HUD element, ignore
		spawn()
			item.DropItem() // guards equipped/legendary, drops in front by facing
			usr.client?.BuildInvPage()
			usr.client?.HideItemDesc()

/atom/movable/shud/invwidget // cross/arrows, press animation from pressbtn
	parent_type = /atom/movable/shud/pressbtn
	layer = MINV_LAYER + 0.4
	DoAction()
		switch(action)
			if("close")
				usr?.client?.CloseInventory()
			if("prev")
				usr?.client?.InvCycle(-1)
			if("next")
				usr?.client?.InvCycle(1)

/atom/movable/shud/invcurrency
	mouse_opacity = 1
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	layer = MINV_LAYER + 0.3
	var/kind   // "money" | "mana"
	MouseDrop(atom/over_object, atom/src_location, atom/over_location, src_control, over_control, params)
		if(!usr) return
		if(istype(over_object, /atom/movable/shud)) return // released back on the HUD, ignore
		spawn() usr.client?.DropCurrency(kind)

/atom/movable/shud/invdescpanel
	mouse_opacity = 2
	layer = MINV_LAYER + 0.5
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr) usr.client.PanelDragStart(src, params)
	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		if(usr) usr.client.PanelDragMove(params)
	MouseUp(location, control, params)
		if(usr) usr.client.PanelDragEnd()
	Click(location, control, params)
		if(params && findtext(params, "right=1"))
			usr?.client?.HideItemDesc()

/atom/movable/shud/invtext
	layer = MINV_LAYER + 0.4
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/invcustbtn
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
		usr.client?.CustomizeItem(item)

/atom/movable/shud/invrenamebtn
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
		usr.client?.RenameItem(item, "inv")

client
	var/tmp
		inv_open = FALSE
		inv_cat_index = 1
		list/inv_objs       // book chrome (panel, title, banner, arrows, close)
		list/inv_item_objs  // current page's item cells
		list/inv_desc_objs  // floating description panel
		obj/Items/inv_desc_item // item whose blurb is currently shown
		atom/movable/shud/invtext/inv_cat_label
		atom/movable/shud/invtext/inv_count_label
		atom/movable/shud/invtext/inv_money_label
		atom/movable/shud/invtext/inv_mana_label
		atom/movable/shud/menubtn/btn_inv
		atom/movable/shud/menulabel/btn_inv_label

client/proc/InitInventoryButton()
	btn_inv = new('HUD/ui_icon_backpack.png')
	btn_inv.btn_id = "inventory"
	btn_inv.screen_loc = "EAST:-4,NORTH:-140" // below the Options gear (vertical strip, 36px pitch), pushed down for the target card
	shud_parts += btn_inv
	btn_inv_label = new
	btn_inv_label.maptext_width = 64
	btn_inv_label.SetText("Inventory")
	btn_inv_label.pixel_x = -70 // -(64 block + 6 gap)
	btn_inv_label.pixel_y = 8
	btn_inv.label = btn_inv_label
	btn_inv.vis_contents += btn_inv_label

client/proc/ResetInventoryHUD()
	CloseInventory()
	btn_inv = null
	btn_inv_label = null

client/proc/ToggleInventory()
	if(inv_open)
		CloseInventory()
	else
		OpenInventory()

client/proc/CloseInventory()
	inv_open = FALSE
	HideItemDesc()
	if(inv_item_objs)
		while(inv_item_objs.len)
			var/atom/movable/o = inv_item_objs[inv_item_objs.len]
			inv_item_objs.len--
			screen -= o
			del o
		inv_item_objs = null
	if(inv_objs)
		while(inv_objs.len)
			var/atom/movable/o = inv_objs[inv_objs.len]
			inv_objs.len--
			screen -= o
			del o
		inv_objs = null
	inv_cat_label = null
	inv_count_label = null
	if(btn_inv)
		btn_inv.icon = 'HUD/ui_slot_available.png'
		btn_inv.SetGlyphDimmed(FALSE)

client/proc/OpenInventory()
	if(!mob) return
	CloseMenu() // never both big panels at once
	CloseCharacterMenu()
	CloseSkillMenu()
	CloseTechMenu()
	CloseAcquireMenu()
	inv_open = TRUE
	inv_cat_index = 1
	btn_inv.icon = 'HUD/ui_slot_unavailable.png'
	btn_inv.SetGlyphDimmed(TRUE)
	btn_inv_label.alpha = 0
	inv_objs = list()
	inv_item_objs = list()

	var/atom/movable/shud/menupanel/draggable/P = new
	P.icon = 'HUD/inv_book.png'
	P.layer = MINV_LAYER
	P.screen_loc = "[InvXLoc(-144)],CENTER:-160"
	inv_objs += P
	// restore saved drag position
	inv_pan_x = getPref("invPanX"); if(isnull(inv_pan_x)) inv_pan_x = 0
	inv_pan_y = getPref("invPanY"); if(isnull(inv_pan_y)) inv_pan_y = 0
	var/list/ib = PanBounds("inventory", P)
	inv_pan_x = clamp(inv_pan_x, ib[1], ib[2])
	inv_pan_y = clamp(inv_pan_y, ib[3], ib[4])

	var/atom/movable/shud/invtext/title = new
	title.maptext_width = 120
	title.maptext_height = 20
	title.maptext = "<center><span style=\"[MINV_FONT]; color:#ffffff\">INVENTORY</span></center>"
	title.screen_loc = "[InvXLoc(-60)],CENTER:128"
	inv_objs += title

	var/atom/movable/shud/invwidget/X = new
	X.icon = 'HUD/ui_cross.png'
	X.action = "close"
	X.widget_kind = "cross"
	X.screen_loc = "[InvXLoc(112)],CENTER:122"
	inv_objs += X

	var/atom/movable/shud/menupanel/banner = new
	banner.icon = 'HUD/inv_banner.png'
	banner.layer = MINV_LAYER + 0.1
	banner.mouse_opacity = 0
	banner.screen_loc = "[InvXLoc(-75)],CENTER:86"
	inv_objs += banner

	inv_cat_label = new
	inv_cat_label.maptext_width = 150
	inv_cat_label.maptext_height = 20
	inv_cat_label.screen_loc = "[InvXLoc(-75)],CENTER:96"
	inv_objs += inv_cat_label

	var/atom/movable/shud/invwidget/AL = new
	AL.icon = 'HUD/ui_arrow_left.png'
	AL.action = "prev"
	AL.widget_kind = "arrow_left"
	AL.screen_loc = "[InvXLoc(-120)],CENTER:84"
	inv_objs += AL

	var/atom/movable/shud/invwidget/AR = new
	AR.icon = 'HUD/ui_arrow_right.png'
	AR.action = "next"
	AR.widget_kind = "arrow_right"
	AR.screen_loc = "[InvXLoc(92)],CENTER:84"
	inv_objs += AR

	inv_count_label = new
	inv_count_label.maptext_width = 110
	inv_count_label.maptext_height = 18
	inv_count_label.screen_loc = "[InvXLoc(-10)],CENTER:-128"
	inv_objs += inv_count_label

	// Money + Mana Bits live in inv_objs so they persist across section cycling, amounts refreshed in BuildInvPage
	var/icon/micon = icon('money.dmi'); micon.Scale(16, 16)
	var/atom/movable/shud/invcurrency/mobj = new
	mobj.icon = micon
	mobj.kind = "money"
	mobj.screen_loc = "[InvXLoc(-102)],CENTER:-108"
	inv_objs += mobj
	inv_money_label = new
	inv_money_label.maptext_width = 80
	inv_money_label.maptext_height = 18
	inv_money_label.mouse_opacity = 0
	inv_money_label.screen_loc = "[InvXLoc(-82)],CENTER:-106"
	inv_objs += inv_money_label
	var/icon/cicon = icon('Crystal_Fragments.dmi', "lot"); cicon.Scale(16, 16)
	var/atom/movable/shud/invcurrency/cobj = new
	cobj.icon = cicon
	cobj.kind = "mana"
	cobj.screen_loc = "[InvXLoc(-102)],CENTER:-130"
	inv_objs += cobj
	inv_mana_label = new
	inv_mana_label.maptext_width = 80
	inv_mana_label.maptext_height = 18
	inv_mana_label.mouse_opacity = 0
	inv_mana_label.screen_loc = "[InvXLoc(-82)],CENTER:-128"
	inv_objs += inv_mana_label

	for(var/atom/movable/o in inv_objs)
		screen += o
	PanShift(inv_objs, inv_pan_x, inv_pan_y)
	KineticEntrance(inv_objs)
	BuildInvPage(TRUE)

client/proc/InvCycle(dir)
	if(!inv_open) return
	HideItemDesc()
	inv_cat_index = inv_cat_index + dir
	if(inv_cat_index > INV_CATEGORIES.len) inv_cat_index = 1
	if(inv_cat_index < 1) inv_cat_index = INV_CATEGORIES.len
	BuildInvPage()

client/proc/BuildInvPage(fade = FALSE)
	if(!mob || !inv_open) return
	while(inv_item_objs.len)
		var/atom/movable/o = inv_item_objs[inv_item_objs.len]
		inv_item_objs.len--
		screen -= o
		del o
	var/cat = INV_CATEGORIES[inv_cat_index]
	inv_cat_label.maptext = "<center><span style=\"[MINV_FONT]; color:#bfefff\">[uppertext(cat)]</span></center>"
	var/list/items = mob.InvItemsFor(cat)
	inv_count_label.maptext = "<span style=\"[MINV_FONT]; color:#ffffff; text-align:right\">[items.len] item\s</span>"
	UpdateInvCurrency()
	for(var/k = 1 to MINV_PER_PAGE)
		var/col = (k - 1) % MINV_COLS
		var/row = round((k - 1) / MINV_COLS)
		var/sx = MINV_GRID_LEFT + col * MINV_PITCH
		var/sy = MINV_GRID_TOP - row * MINV_PITCH
		var/atom/movable/shud/menupanel/cell = new
		cell.icon = 'HUD/inv_slot.png'
		cell.layer = MINV_LAYER + 0.2
		cell.mouse_opacity = 0
		cell.screen_loc = "[InvXLoc(sx)],CENTER:[sy]"
		inv_item_objs += cell
		screen += cell
		if(k <= items.len)
			var/obj/Items/I = items[k]
			var/atom/movable/shud/invitem/cellitem = new
			cellitem.SetItem(I)
			cellitem.screen_loc = "[InvXLoc(sx)],CENTER:[sy]"
			inv_item_objs += cellitem
			screen += cellitem
			// "E" badge for anything equipped/worn
			if(findtext(I.suffix, "Equipped"))
				var/atom/movable/shud/invtext/badge = new
				badge.maptext_width = 16
				badge.maptext_height = 14
				badge.maptext = "<span style=\"[MINV_FONT]; color:#8be9ff\"><b>E</b></span>"
				badge.layer = MINV_LAYER + 0.45
				badge.mouse_opacity = 0
				badge.screen_loc = "[InvXLoc(sx + 21)],CENTER:[sy - 1]"
				inv_item_objs += badge
				screen += badge
	PanShift(inv_item_objs, inv_pan_x, inv_pan_y)
	if(fade)
		KineticEntrance(inv_item_objs)

// safe to call from anywhere money/mana changes
client/proc/UpdateInvCurrency()
	if(!inv_open || !mob) return
	if(inv_money_label) inv_money_label.maptext = "<span style=\"[MINV_FONT]; color:#ffe066\">[Commas(round(mob.MoneyTotal()))]</span>"
	if(inv_mana_label) inv_mana_label.maptext = "<span style=\"[MINV_FONT]; color:#9bdcff\">[Commas(round(mob.ManaBitsTotal()))]</span>"

client/proc/DropCurrency(kind)
	set waitfor = 0
	if(!mob) return
	if(kind == "money")
		var/total = mob.MoneyTotal()
		if(total < 1)
			mob << "You have no [glob.progress.MoneyName] to drop."
			return
		var/amt = input(mob, "Drop how much [glob.progress.MoneyName]? (1-[round(total)])", "Drop") as num|null
		if(isnull(amt)) return
		amt = round(amt)
		if(amt < 1) return
		if(amt > total) amt = total
		mob.DropMoney(amt)
	else
		var/obj/Items/mineral/m = locate() in mob
		if(!m || m.value < 1)
			mob << "You have no Mana Bits to drop."
			return
		var/amt = input(mob, "Drop how many Mana Bits? (1-[round(m.value)])", "Drop") as num|null
		if(isnull(amt)) return
		amt = round(amt)
		if(amt < 1) return
		if(amt > m.value) amt = m.value
		m.Drop(amt, mob)
	BuildInvPage()

client/proc/SwapInvSlots(obj/Items/a, obj/Items/b)
	if(!a || !b || !mob) return
	var/t = a.invSlot
	a.invSlot = b.invSlot
	b.invSlot = t
	// clothes layer by slot order, so re-derive LayerPriority + refresh the look
	if(istype(a, /obj/Items/Wearables) || istype(b, /obj/Items/Wearables))
		mob.RecomputeClothesLayerPriority()
	BuildInvPage()
	HideItemDesc()

// clothes nearest the first slot render on top. LayerPriority climbs +0.1 per garment down the
// slot order, lower priority draws above (Equip() does placement -= LayerPriority)
mob/proc/RecomputeClothesLayerPriority()
	var/list/misc = InvItemsFor("Misc")
	var/ci = 0
	for(var/obj/Items/I in misc)
		if(istype(I, /obj/Items/Wearables))
			I.LayerPriority = ci * 0.1
			ci++
	AppearanceOff()
	AppearanceOn()

client/proc/HideItemDesc()
	inv_desc_item = null
	if(inv_desc_objs)
		while(inv_desc_objs.len)
			var/atom/movable/o = inv_desc_objs[inv_desc_objs.len]
			inv_desc_objs.len--
			screen -= o
			del o
		inv_desc_objs = null

client/proc/ShowItemDesc(obj/Items/I)
	HideItemDesc()
	if(!I || !inv_open) return
	inv_desc_objs = list()
	inv_desc_item = I
	desc_pan_x = getPref("descPanX"); if(isnull(desc_pan_x)) desc_pan_x = 0
	desc_pan_y = getPref("descPanY"); if(isnull(desc_pan_y)) desc_pan_y = 0

	var/atom/movable/shud/invdescpanel/P = new
	P.icon = 'HUD/inv_desc.png'
	P.screen_loc = "[InvXLoc(152)],CENTER:-150"   // docked to the right of the book
	inv_desc_objs += P

	var/atom/movable/shud/orbpart/pic = new
	pic.icon = I.icon
	pic.icon_state = I.icon_state
	pic.color = I.color
	pic.overlays = I.overlays
	pic.underlays = I.underlays
	pic.transform = matrix(2, 0, 0, 0, 2, 0) // 2x, scales about its center
	pic.layer = MINV_LAYER + 0.6
	pic.mouse_opacity = 0 // clicks fall through to the panel so right-click closes
	pic.screen_loc = "[InvXLoc(191)],CENTER:96"
	inv_desc_objs += pic

	// Update_Description is per-subtype not on base /obj/Items, reach it via the ':' operator like the item code does
	if(I.UpdatesDescription)
		I:Update_Description()
	var/body = I.desc ? I.desc : "No description."
	// some items' desc already starts with the name (e.g. armor), don't show it twice
	var/namehdr = (findtext(body, I.name) == 1) ? "" : "<center><span style=\"[MINV_FONT]; color:#ffffff\"><b>[I.name]</b></span></center>"

	var/stats = ""
	if(mob.InvClassify(I) == "Gear")
		var/list/pairs = list("Str" = "STR", "End" = "END", "For" = "FOR", "Spd" = "SPD", "Off" = "OFF", "Def" = "DEF")
		var/line = ""
		for(var/key in pairs)
			var/v = I.getItemStatAdd(key)
			if(v)
				line += "[v > 0 ? "+" : ""][v] [pairs[key]]<br>"
		if(line)
			stats = "<br><span style=\"color:#bfefff\">- Stats -</span><br>[line]"

	var/atom/movable/shud/invtext/T = new
	T.layer = MINV_LAYER + 0.6
	T.mouse_opacity = 0 // clicks fall through to the panel
	T.maptext_width = 176
	T.maptext_height = 152
	T.screen_loc = "[InvXLoc(164)],CENTER:-70"   // low enough that long descriptions clear the icon
	T.maptext = "[namehdr]<span style=\"[MINV_FONT]; color:#ffffff\">[body][stats]</span>"
	inv_desc_objs += T

	// gear and clothing actions stacked top-right, clear of the description text
	if(IsCustomizableItem(I))
		var/atom/movable/shud/invcustbtn/cb = new
		cb.item = I
		cb.maptext_width = 100
		cb.maptext = "<span style=\"[MINV_FONT]; color:#8be9ff\">&#9874; Customize</span>"
		cb.screen_loc = "[InvXLoc(252)],CENTER:112"
		inv_desc_objs += cb
	if(CanBeHat(I))
		var/atom/movable/shud/invtext/htl = new
		htl.layer = MINV_LAYER + 0.6
		htl.mouse_opacity = 0
		htl.maptext_width = 90
		htl.screen_loc = "[InvXLoc(252)],CENTER:90"
		htl.maptext = "<span style=\"[MINV_FONT]; color:#8be9ff\">Toggle Hat</span>"
		inv_desc_objs += htl
		var/atom/movable/shud/hattoggle/htsw = new
		htsw.item = I
		htsw.ctx = "inv"
		htsw.layer = MINV_LAYER + 0.7
		htsw.icon = I.IsHat ? HAT_TGL_ON[5] : HAT_TGL_OFF[5]
		htsw.screen_loc = "[InvXLoc(315)],CENTER:92"
		inv_desc_objs += htsw
	if(IsCustomizableItem(I))
		var/atom/movable/shud/invrenamebtn/rb = new
		rb.item = I
		rb.maptext_width = 100
		rb.maptext = "<span style=\"[MINV_FONT]; color:#8be9ff\">&#9998; Rename</span>"
		rb.screen_loc = "[InvXLoc(252)],CENTER:68"
		inv_desc_objs += rb

	// clamp the saved popup offset to the current view, then apply it
	var/list/db = PanBounds("invdesc", inv_desc_objs.len ? inv_desc_objs[1] : null)
	desc_pan_x = clamp(desc_pan_x, db[1], db[2])
	desc_pan_y = clamp(desc_pan_y, db[3], db[4])
	for(var/atom/movable/o in inv_desc_objs)
		screen += o
	PanShift(inv_desc_objs, desc_pan_x, desc_pan_y)
	KineticEntrance(inv_desc_objs)
