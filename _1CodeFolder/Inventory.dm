// 30 held items per HUD category (Misc / Consumables / Gear). Materials live in the Collection Log.

#define MAX_INVENTORY 60          // this will be phased out soonish
#define INV_PAGE_SIZE 30

mob/var/tmp/inv_page = 1

// Count all physical items (not Money, not Skills)
mob/proc/GetItemCount()
	var/count = 0
	for(var/obj/Items/I in src)
		count++
	return count

// Count held items in one HUD category. Currency (mineral) and materials (Collection Log) don't count.
mob/proc/GetCategoryCount(cat)
	var/count = 0
	for(var/obj/Items/I in src)
		if(istype(I, /obj/Items/mineral) || istype(I, /obj/Items/Material)) continue
		if(InvClassify(I) == cat) count++
	return count

mob/proc/CategoryFull(cat)
	return GetCategoryCount(cat) >= INV_CATEGORY_CAP

mob/proc/InventoryFull()
	return GetItemCount() >= MAX_INVENTORY

// item-aware fullness message
mob/proc/CheckInventoryFull(var/obj/Items/item = null)
	if(item)
		if(istype(item, /obj/Items/mineral) || istype(item, /obj/Items/Material)) return 0
		var/cat = InvClassify(item)
		if(!CategoryFull(cat)) return 0
		src << "<b><font color=red>Your [cat] inventory is full! ([INV_CATEGORY_CAP] max)</font></b>"
		return 1
	if(!CategoryFull("Misc") || !CategoryFull("Consumables") || !CategoryFull("Gear")) return 0
	src << "<b><font color=red>Your inventory is full!</font></b>"
	return 1

mob/proc/CanPickupItem(var/obj/Items/item)
	if(!item) return 0
	if(item.Stackable)
		for(var/obj/Items/existing in src)
			if(existing.type == item.type && existing.Stackable && existing.CraftQuality == item.CraftQuality && existing.metal_id == item.metal_id)
				if(existing.TotalStack < INV_STACK_MAX) return 1
	if(istype(item, /obj/Items/mineral) || istype(item, /obj/Items/Material)) return 1   // currency / log, uncapped here
	return !CategoryFull(InvClassify(item))

// hand an item to a player, or drop it at their feet if that category is full. returns 1 if held.
mob/proc/GiveOrDrop(var/obj/Items/I, var/quiet = 0)
	if(!I) return 0
	if(I.Stackable)
		for(var/obj/Items/e in src)
			if(e.type == I.type && e.Stackable && e.CraftQuality == I.CraftQuality && e.metal_id == I.metal_id)
				if(e.TotalStack < INV_STACK_MAX)
					StackInto(e, I.TotalStack)
					del I
					if(client) client.BuildInvPage()
					return 1
				break   // matching stack is maxed
	if(CanPickupItem(I))
		I.loc = src
		if(client) client.BuildInvPage()
		return 1
	var/turf/T = get_step(src, dir)
	I.loc = T ? T : loc
	if(!quiet) src << "<b><font color=red>Your [InvClassify(I)] pack is full - [I.name] drops at your feet.</font></b>"
	if(client) client.BuildInvPage()
	return 0

// add `amount` onto an existing stack, capped at 999; overflow drops a fresh stack at the owner's feet. returns amount merged.
mob/proc/StackInto(var/obj/Items/existing, var/amount)
	if(!existing || amount <= 0) return 0
	var/room = INV_STACK_MAX - existing.TotalStack
	if(room <= 0)
		DropStackRemainder(existing, amount)
		return 0
	var/merged = min(amount, room)
	existing.TotalStack += merged
	existing.suffix = "[existing.TotalStack]"
	if(amount > merged)
		DropStackRemainder(existing, amount - merged)
	return merged

mob/proc/DropStackRemainder(var/obj/Items/proto, var/amount)
	if(!proto || amount <= 0) return
	var/turf/T = get_step(src, dir)
	var/obj/Items/o = new proto.type(T ? T : loc)
	o.TotalStack = min(amount, INV_STACK_MAX)
	o.CraftQuality = proto.CraftQuality
	o.metal_id = proto.metal_id
	o.name = proto.name
	o.suffix = "[o.TotalStack]"
	src << "<b><font color=red>[proto.name] is capped at [INV_STACK_MAX] - [amount] more drop at your feet.</font></b>"

mob/proc/GroundPickup(var/obj/Items/I)
	if(!I || !isturf(I.loc)) return
	if(get_dist(src, I) > 1)
		src << "You're too far away to pick that up."
		return
	if(!I.Grabbable && I.CreatorKey && I.CreatorKey != src.ckey)
		src << "That doesn't belong to you."
		return
	if(istype(I, /obj/Items/Material))
		// materials live in the Collection Log
		var/obj/Items/Material/mat = I
		if(mat.MaterialClass && mat.MaterialClass != "Scrap")
			var/banked = MatLogAdd(mat.MaterialClass, mat.CraftQuality, mat.TotalStack)
			src << "<font color=#78eb78>You bank [banked]x [mat.name] in your Collection Log.</font>"
			del I
			return
	if(istype(I, /obj/Items/mineral))
		var/obj/Items/mineral/gi = I
		var/obj/Items/mineral/have = locate() in src
		if(have && have != gi)
			have.Add(gi.value)
			del gi
			if(client) client.BuildInvPage()
			return
	if(I.Stackable)
		for(var/obj/Items/e in src)
			if(e.type == I.type && e.Stackable && e.CraftQuality == I.CraftQuality && e.metal_id == I.metal_id)
				var/room = INV_STACK_MAX - e.TotalStack
				if(room <= 0)
					src << "That stack is already full ([INV_STACK_MAX])."
					return
				var/take = min(I.TotalStack, room)
				e.TotalStack += take
				e.suffix = "[e.TotalStack]"
				I.TotalStack -= take
				src << "You pick up [take]x [e.name]. ([e.TotalStack] total)"
				if(I.TotalStack <= 0)
					del I
				else
					I.suffix = "[I.TotalStack]"
					src << "Stack full - [I.TotalStack]x stay on the ground."
				if(client) client.BuildInvPage()
				return
	if(CheckInventoryFull(I)) return
	I.loc = src
	if(I.Stackable && I.TotalStack > 1)
		src << "You pick up [I.TotalStack]x [I.name]."
	else
		src << "You pick up [I]."
	if(client) client.BuildInvPage()

// Open inventory window
mob/verb/Open_Inventory()
	set name = ".Open_Inventory"
	set hidden = 1
	RefreshInventory()
	winshow(src, "InventoryWindow", 1)

// Switch page
mob/verb/InvPage(var/p as text)
	set name = ".InvPage"
	set hidden = 1
	var/num_p = text2num(p)
	if(!num_p || num_p < 1) num_p = 1
	if(num_p > 2) num_p = 2
	inv_page = num_p
	RefreshInventory()

// Refresh the grid display
mob/proc/RefreshInventory()
	if(!client) return

	// Gather items - equipped first, then unequipped
	var/list/equipped_items = list()
	var/list/loose_items = list()
	for(var/obj/Items/I in src)
		if(findtext(I.suffix, "Equipped"))
			equipped_items += I
		else
			loose_items += I

	var/list/all_items = equipped_items + loose_items
	var/total = all_items.len

	// Calculate page bounds
	var/page_start = (inv_page - 1) * INV_PAGE_SIZE + 1
	var/page_end = min(inv_page * INV_PAGE_SIZE, total)
	var/rows = 0
	if(page_end >= page_start)
		rows = page_end - page_start + 1

	// Update count label
	winset(src, "InvCount", "text=\"[total] / [MAX_INVENTORY]\"")

	// Highlight active page button
	if(inv_page == 1)
		winset(src, "InvPage1Btn", "background-color=#2a2a4a")
		winset(src, "InvPage2Btn", "background-color=#1c1c1c")
	else
		winset(src, "InvPage1Btn", "background-color=#1c1c1c")
		winset(src, "InvPage2Btn", "background-color=#2a2a4a")

	// Clear and resize grid
	winset(src, "InvGrid", "cells=2x[rows]")

	// Fill grid rows
	var/row = 0
	for(var/i = page_start, i <= page_end, i++)
		row++
		var/obj/Items/item = all_items[i]
		src << output(item, "InvGrid:1,[row]")
		var/status = ""
		if(findtext(item.suffix, "Equipped"))
			status = "<font color=#55ff55>Equipped</font>"
		else if(item.Stackable && item.TotalStack > 1)
			status = "<font color=#aaaaaa>x[item.TotalStack]</font>"
		src << output(status, "InvGrid:2,[row]")
