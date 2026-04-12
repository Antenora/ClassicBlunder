// Inventory System - 60 item limit, 2 pages of 30, grid-based display

#define MAX_INVENTORY 60
#define INV_PAGE_SIZE 30

mob/var/tmp/inv_page = 1

// Count physical items (not Money, not Skills)
mob/proc/GetItemCount()
	var/count = 0
	for(var/obj/Items/I in src)
		count++
	return count

// Check if inventory has room
mob/proc/InventoryFull()
	return GetItemCount() >= MAX_INVENTORY

// Check and print message if full. Returns 1 if full, 0 if space available.
mob/proc/CheckInventoryFull()
	if(!InventoryFull()) return 0
	src << "<b><font color=red>Your inventory is full! ([GetItemCount()]/[MAX_INVENTORY])</font></b>"
	return 1

// Check if a specific item can be picked up (handles stackables)
mob/proc/CanPickupItem(var/obj/Items/item)
	if(!item) return 0
	if(item.Stackable)
		for(var/obj/Items/existing in src)
			if(existing.type == item.type && existing.Stackable)
				return 1
	if(CheckInventoryFull())
		return 0
	return 1

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
