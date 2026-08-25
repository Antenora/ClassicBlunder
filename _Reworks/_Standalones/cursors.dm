client
	var/tmp/atom/cursor_dyn
	var/tmp/cursor_2x = 0

var/list/CURSOR_1X = list(
	"neutral" = 'Icons/Cursors/cursor_neutral.dmi',
	"mine" = 'Icons/Cursors/cursor_mine.dmi',
	"chop" = 'Icons/Cursors/cursor_chop.dmi',
	"forge" = 'Icons/Cursors/cursor_forge.dmi',
	"harvest" = 'Icons/Cursors/cursor_harvest.dmi',
	"water" = 'Icons/Cursors/cursor_water.dmi',
	"fish" = 'Icons/Cursors/cursor_fish.dmi',
	"seed" = 'Icons/Cursors/cursor_seed.dmi',
	"pickup" = 'Icons/Cursors/cursor_pickup.dmi',
	"money" = 'Icons/Cursors/cursor_money.dmi',
	"player" = 'Icons/Cursors/cursor_player.dmi',
	"info" = 'Icons/Cursors/cursor_info.dmi',
	"gear" = 'Icons/Cursors/cursor_gear.dmi',
	"forage" = 'Icons/Cursors/cursor_forage.dmi',
	"remains" = 'Icons/Cursors/cursor_remains.dmi',
	"ibeam" = 'Icons/Cursors/cursor_ibeam.dmi',
	"log" = 'Icons/Cursors/cursor_log.dmi',
	"enemy" = 'Icons/Cursors/cursor_enemy.dmi',
	"draggable" = 'Icons/Cursors/cursor_draggable.dmi',
	"drag" = 'Icons/Cursors/cursor_drag.dmi',
	"blocked" = 'Icons/Cursors/cursor_blocked.dmi',
	"scroll" = 'Icons/Cursors/cursor_scroll.dmi',
	"potion" = 'Icons/Cursors/cursor_potion.dmi',
	"dooropen" = 'Icons/Cursors/cursor_dooropen.dmi',
	"doorclose" = 'Icons/Cursors/cursor_doorclose.dmi',
	"locked" = 'Icons/Cursors/cursor_locked.dmi',
	"key" = 'Icons/Cursors/cursor_key.dmi')

var/list/CURSOR_2X = list(
	"neutral" = 'Icons/Cursors/2x/cursor_neutral.dmi',
	"mine" = 'Icons/Cursors/2x/cursor_mine.dmi',
	"chop" = 'Icons/Cursors/2x/cursor_chop.dmi',
	"forge" = 'Icons/Cursors/2x/cursor_forge.dmi',
	"harvest" = 'Icons/Cursors/2x/cursor_harvest.dmi',
	"water" = 'Icons/Cursors/2x/cursor_water.dmi',
	"fish" = 'Icons/Cursors/2x/cursor_fish.dmi',
	"seed" = 'Icons/Cursors/2x/cursor_seed.dmi',
	"pickup" = 'Icons/Cursors/2x/cursor_pickup.dmi',
	"money" = 'Icons/Cursors/2x/cursor_money.dmi',
	"player" = 'Icons/Cursors/2x/cursor_player.dmi',
	"info" = 'Icons/Cursors/2x/cursor_info.dmi',
	"gear" = 'Icons/Cursors/2x/cursor_gear.dmi',
	"forage" = 'Icons/Cursors/2x/cursor_forage.dmi',
	"remains" = 'Icons/Cursors/2x/cursor_remains.dmi',
	"ibeam" = 'Icons/Cursors/2x/cursor_ibeam.dmi',
	"log" = 'Icons/Cursors/2x/cursor_log.dmi',
	"enemy" = 'Icons/Cursors/2x/cursor_enemy.dmi',
	"draggable" = 'Icons/Cursors/2x/cursor_draggable.dmi',
	"drag" = 'Icons/Cursors/2x/cursor_drag.dmi',
	"blocked" = 'Icons/Cursors/2x/cursor_blocked.dmi',
	"scroll" = 'Icons/Cursors/2x/cursor_scroll.dmi',
	"potion" = 'Icons/Cursors/2x/cursor_potion.dmi',
	"dooropen" = 'Icons/Cursors/2x/cursor_dooropen.dmi',
	"doorclose" = 'Icons/Cursors/2x/cursor_doorclose.dmi',
	"locked" = 'Icons/Cursors/2x/cursor_locked.dmi',
	"key" = 'Icons/Cursors/2x/cursor_key.dmi')

proc/CursorFile(client/C, key)
	if(C && C.cursor_2x)
		return CURSOR_2X[key]
	return CURSOR_1X[key]

proc/CursorNeutral(client/C)
	if(!C) return
	C.mouse_pointer_icon = CursorFile(C, "neutral")
	C.cursor_dyn = null

proc/CursorHover(atom/A, key)
	if(!usr || !usr.client) return
	usr.client.mouse_pointer_icon = CursorFile(usr.client, key)
	usr.client.cursor_dyn = A

proc/CursorLeave(atom/A)
	if(!usr || !usr.client) return
	if(usr.client.cursor_dyn != A) return
	CursorNeutral(usr.client)

client/New()
	. = ..()
	CursorNeutral(src)

proc/DoorKeyMatch(mob/M, atom/D)
	if(!M || !D || !D.Password) return 0
	for(var/obj/Items/Tech/Door_Pass/L in M)
		if(L.Password == D.Password) return 1
	for(var/obj/Items/Tech/Digital_Key/C in M)
		if(C.Password == D.Password || C.Password2 == D.Password || C.Password3 == D.Password) return 1
	return 0

proc/DoorCursorFor(atom/movable/D, mob/M)
	var/auto = 0
	var/god = 0
	if(istype(D, /obj/Items/Tech/Door))
		var/obj/Items/Tech/Door/T = D
		auto = T.AutoOpen
		god = T.GodDoor
	else if(istype(D, /obj/Turfs/Door))
		var/obj/Turfs/Door/T = D
		auto = T.AutoOpen
		god = T.GodDoor
	if(!D.density) return "doorclose"
	if(!D.Password || auto) return "dooropen"
	if(god) return (M && M.Spawn == D.Password) ? "dooropen" : "locked"
	if(DoorKeyMatch(M, D)) return "key"
	return "locked"

obj/Items/Tech/Door/MouseEntered(location, control, params)
	..()
	if(!usr || !usr.client) return
	if(get_dist(usr, src) > 1) return
	CursorHover(src, DoorCursorFor(src, usr))
obj/Items/Tech/Door/MouseExited(location, control, params)
	..()
	CursorLeave(src)

obj/Turfs/Door/MouseEntered(location, control, params)
	..()
	if(!usr || !usr.client) return
	if(get_dist(usr, src) > 1) return
	CursorHover(src, DoorCursorFor(src, usr))
obj/Turfs/Door/MouseExited(location, control, params)
	..()
	CursorLeave(src)

mob/Player/AI/MouseEntered(location, control, params)
	..()
	if(!usr || !usr.client || usr == src) return
	if(istype(src, /mob/Player/AI/Pet)) return
	if(ai_hostility < 1) return
	if(AllianceCheck(usr)) return
	CursorHover(src, "enemy")
mob/Player/AI/MouseExited(location, control, params)
	..()
	CursorLeave(src)

atom/movable/shud/aqrow/MouseEntered(location, control, params)
	..()
	if(!usr || !usr.client) return
	var/client/C = usr.client
	if(!C.aqmenu_open || !C.aq_entries || entry_idx < 1 || entry_idx > C.aq_entries.len) return
	if(!C.AqClickInBand(params)) return
	var/datum/aqentry/E = C.aq_entries[entry_idx]
	CursorHover(src, (E.can_buy || E.can_pick) ? "scroll" : "blocked")
atom/movable/shud/aqrow/MouseExited(location, control, params)
	..()
	CursorLeave(src)

atom/movable/shud/ttnode/MouseEntered(location, control, params)
	..()
	CursorHover(src, "scroll")
atom/movable/shud/ttnode/MouseExited(location, control, params)
	..()
	CursorLeave(src)

proc/CursorGrabDown(atom/A)
	if(!usr || !usr.client) return
	usr.client.mouse_pointer_icon = CursorFile(usr.client, "drag")
	usr.client.cursor_dyn = A

proc/CursorGrabUp(atom/A)
	if(!usr || !usr.client) return
	if(usr.client.cursor_dyn == A)
		usr.client.mouse_pointer_icon = CursorFile(usr.client, "draggable")
	else
		CursorNeutral(usr.client)

atom/movable/shud/menupanel/draggable/MouseEntered(location, control, params)
	..()
	CursorHover(src, "draggable")
atom/movable/shud/menupanel/draggable/MouseExited(location, control, params)
	..()
	CursorLeave(src)
atom/movable/shud/menupanel/draggable/MouseDown(location, control, params)
	..()
	CursorGrabDown(src)
atom/movable/shud/menupanel/draggable/MouseUp(location, control, params)
	..()
	CursorGrabUp(src)

atom/movable/shud/invdescpanel/MouseEntered(location, control, params)
	..()
	CursorHover(src, "draggable")
atom/movable/shud/invdescpanel/MouseExited(location, control, params)
	..()
	CursorLeave(src)
atom/movable/shud/invdescpanel/MouseDown(location, control, params)
	..()
	CursorGrabDown(src)
atom/movable/shud/invdescpanel/MouseUp(location, control, params)
	..()
	CursorGrabUp(src)

atom/movable/shud/cmframe/MouseEntered(location, control, params)
	..()
	CursorHover(src, "draggable")
atom/movable/shud/cmframe/MouseExited(location, control, params)
	..()
	CursorLeave(src)
atom/movable/shud/cmframe/MouseDown(location, control, params)
	..()
	CursorGrabDown(src)
atom/movable/shud/cmframe/MouseUp(location, control, params)
	..()
	CursorGrabUp(src)

atom/movable/shud/cmdesc/MouseEntered(location, control, params)
	..()
	if(draggable) CursorHover(src, "draggable")
atom/movable/shud/cmdesc/MouseExited(location, control, params)
	..()
	CursorLeave(src)
atom/movable/shud/cmdesc/MouseDown(location, control, params)
	..()
	if(draggable) CursorGrabDown(src)
atom/movable/shud/cmdesc/MouseUp(location, control, params)
	..()
	if(draggable) CursorGrabUp(src)

atom/movable/shud/aqbg/MouseEntered(location, control, params)
	..()
	CursorHover(src, "draggable")
atom/movable/shud/aqbg/MouseExited(location, control, params)
	..()
	CursorLeave(src)
atom/movable/shud/aqbg/MouseDown(location, control, params)
	..()
	CursorGrabDown(src)
atom/movable/shud/aqbg/MouseUp(location, control, params)
	..()
	CursorGrabUp(src)

atom/movable/shud/ttbg/MouseEntered(location, control, params)
	..()
	CursorHover(src, "draggable")
atom/movable/shud/ttbg/MouseExited(location, control, params)
	..()
	CursorLeave(src)
atom/movable/shud/ttbg/MouseDown(location, control, params)
	..()
	CursorGrabDown(src)
atom/movable/shud/ttbg/MouseUp(location, control, params)
	..()
	CursorGrabUp(src)

atom/movable/shud/ttpan/MouseEntered(location, control, params)
	..()
	CursorHover(src, "draggable")
atom/movable/shud/ttpan/MouseExited(location, control, params)
	..()
	CursorLeave(src)
atom/movable/shud/ttpan/MouseDown(location, control, params)
	..()
	CursorGrabDown(src)
atom/movable/shud/ttpan/MouseUp(location, control, params)
	..()
	CursorGrabUp(src)

atom/movable/shud/logbg/MouseEntered(location, control, params)
	..()
	CursorHover(src, "draggable")
atom/movable/shud/logbg/MouseExited(location, control, params)
	..()
	CursorLeave(src)
atom/movable/shud/logbg/MouseDown(location, control, params)
	..()
	CursorGrabDown(src)
atom/movable/shud/logbg/MouseUp(location, control, params)
	..()
	CursorGrabUp(src)

atom/movable/shud/ahbg/MouseEntered(location, control, params)
	..()
	CursorHover(src, "draggable")
atom/movable/shud/ahbg/MouseExited(location, control, params)
	..()
	CursorLeave(src)
atom/movable/shud/ahbg/MouseDown(location, control, params)
	..()
	CursorGrabDown(src)
atom/movable/shud/ahbg/MouseUp(location, control, params)
	..()
	CursorGrabUp(src)

atom/movable/shud/stbg/MouseEntered(location, control, params)
	..()
	CursorHover(src, "draggable")
atom/movable/shud/stbg/MouseExited(location, control, params)
	..()
	CursorLeave(src)
atom/movable/shud/stbg/MouseDown(location, control, params)
	..()
	CursorGrabDown(src)
atom/movable/shud/stbg/MouseUp(location, control, params)
	..()
	CursorGrabUp(src)

atom/movable/shud/lsbg/MouseEntered(location, control, params)
	..()
	CursorHover(src, "draggable")
atom/movable/shud/lsbg/MouseExited(location, control, params)
	..()
	CursorLeave(src)
atom/movable/shud/lsbg/MouseDown(location, control, params)
	..()
	CursorGrabDown(src)
atom/movable/shud/lsbg/MouseUp(location, control, params)
	..()
	CursorGrabUp(src)

atom/movable/shud/adminpanelbg/MouseEntered(location, control, params)
	..()
	CursorHover(src, "draggable")
atom/movable/shud/adminpanelbg/MouseExited(location, control, params)
	..()
	CursorLeave(src)
atom/movable/shud/adminpanelbg/MouseDown(location, control, params)
	..()
	CursorGrabDown(src)
atom/movable/shud/adminpanelbg/MouseUp(location, control, params)
	..()
	CursorGrabUp(src)

atom/movable/shud/npdrag/MouseEntered(location, control, params)
	..()
	CursorHover(src, "draggable")
atom/movable/shud/npdrag/MouseExited(location, control, params)
	..()
	CursorLeave(src)
atom/movable/shud/npdrag/MouseDown(location, control, params)
	..()
	CursorGrabDown(src)
atom/movable/shud/npdrag/MouseUp(location, control, params)
	..()
	CursorGrabUp(src)

obj/LifeSkills/OreNode/MouseEntered(location, control, params)
	..()
	if(!depleted) CursorHover(src, "mine")
obj/LifeSkills/OreNode/MouseExited(location, control, params)
	..()
	CursorLeave(src)

obj/LifeSkills/Tree/MouseEntered(location, control, params)
	..()
	if(!depleted) CursorHover(src, "chop")
	else CursorHover(src, "blocked")
obj/LifeSkills/Tree/MouseExited(location, control, params)
	..()
	CursorLeave(src)

obj/LifeSkills/Station/Forge/MouseEntered(location, control, params)
	..()
	CursorHover(src, "forge")
obj/LifeSkills/Station/Forge/MouseExited(location, control, params)
	..()
	CursorLeave(src)

obj/LifeSkills/Station/Anvil/MouseEntered(location, control, params)
	..()
	CursorHover(src, "forge")
obj/LifeSkills/Station/Anvil/MouseExited(location, control, params)
	..()
	CursorLeave(src)

obj/LifeSkills/FishingSpot/MouseEntered(location, control, params)
	..()
	if(!depleted) CursorHover(src, "fish")
obj/LifeSkills/FishingSpot/MouseExited(location, control, params)
	..()
	CursorLeave(src)

obj/LifeSkills/ForageNode/MouseEntered(location, control, params)
	..()
	if(!depleted) CursorHover(src, "forage")
obj/LifeSkills/ForageNode/MouseExited(location, control, params)
	..()
	CursorLeave(src)

obj/LifeSkills/Remains/MouseEntered(location, control, params)
	..()
	if(!decaying) CursorHover(src, "remains")
obj/LifeSkills/Remains/MouseExited(location, control, params)
	..()
	CursorLeave(src)

obj/LifeSkills/FarmPlot/MouseEntered(location, control, params)
	..()
	if(Ready()) CursorHover(src, "harvest")
	else if(crop_id && !wilted && grow_days < needed && wet_day != FarmDay()) CursorHover(src, "water")
	else if(!crop_id) CursorHover(src, "seed")
obj/LifeSkills/FarmPlot/MouseExited(location, control, params)
	..()
	CursorLeave(src)

obj/Money/MouseEntered(location, control, params)
	..()
	CursorHover(src, "money")
obj/Money/MouseExited(location, control, params)
	..()
	CursorLeave(src)

obj/gold/MouseEntered(location, control, params)
	..()
	CursorHover(src, "money")
obj/gold/MouseExited(location, control, params)
	..()
	CursorLeave(src)

obj/Items/MouseEntered(location, control, params)
	..()
	if(!usr || !usr.client) return
	if(istype(src, /obj/Items/Sword) || istype(src, /obj/Items/Armor) || istype(src, /obj/Items/Enchantment/Staff))
		CursorHover(src, "gear")
		return
	if(!isturf(loc)) return
	if(!Grabbable && CreatorKey && usr.ckey && CreatorKey != usr.ckey) return
	if(get_dist(usr, src) > 1) return
	if(istype(src, /obj/Items/Material))
		var/obj/Items/Material/mat = src
		if(mat.MaterialClass && mat.MaterialClass != "Scrap")
			CursorHover(src, "log")
			return
	CursorHover(src, "pickup")
obj/Items/MouseExited(location, control, params)
	..()
	CursorLeave(src)

mob/Players/MouseEntered(location, control, params)
	..()
	CursorHover(src, "player")
mob/Players/MouseExited(location, control, params)
	..()
	CursorLeave(src)

atom/movable/shud/invitem/MouseEntered(location, control, params)
	..()
	if(item && usr && usr.InvClassify(item) == "Consumables")
		CursorHover(src, "potion")
	else
		CursorHover(src, "info")
atom/movable/shud/invitem/MouseExited(location, control, params)
	..()
	CursorLeave(src)

atom/movable/shud/cmpassrow/MouseEntered(location, control, params)
	..()
	CursorHover(src, "info")
atom/movable/shud/cmpassrow/MouseExited(location, control, params)
	..()
	CursorLeave(src)

atom/movable/shud/cmbuff/MouseEntered(location, control, params)
	..()
	CursorHover(src, "info")
atom/movable/shud/cmbuff/MouseExited(location, control, params)
	..()
	CursorLeave(src)

atom/movable/shud/tbufficon/MouseEntered(location, control, params)
	..()
	CursorHover(src, "info")
atom/movable/shud/tbufficon/MouseExited(location, control, params)
	..()
	CursorLeave(src)

atom/movable/shud/debufficon/MouseEntered(location, control, params)
	..()
	CursorHover(src, "info")
atom/movable/shud/debufficon/MouseExited(location, control, params)
	..()
	CursorLeave(src)

atom/movable/shud/skmenu_icon/MouseEntered(location, control, params)
	..()
	CursorHover(src, "info")
atom/movable/shud/skmenu_icon/MouseExited(location, control, params)
	..()
	CursorLeave(src)

atom/movable/shud/buffpassrow/MouseEntered(location, control, params)
	..()
	CursorHover(src, "info")
atom/movable/shud/buffpassrow/MouseExited(location, control, params)
	..()
	CursorLeave(src)

atom/movable/shud/cmgearslot/MouseEntered(location, control, params)
	..()
	CursorHover(src, "gear")
atom/movable/shud/cmgearslot/MouseExited(location, control, params)
	..()
	CursorLeave(src)

atom/movable/shud/cmgeargrid/MouseEntered(location, control, params)
	..()
	CursorHover(src, "gear")
atom/movable/shud/cmgeargrid/MouseExited(location, control, params)
	..()
	CursorLeave(src)
