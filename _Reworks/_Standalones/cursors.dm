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
	"remains" = 'Icons/Cursors/cursor_remains.dmi')

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
	"remains" = 'Icons/Cursors/2x/cursor_remains.dmi')

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

obj/LifeSkills/OreNode/MouseEntered(location, control, params)
	..()
	if(!depleted) CursorHover(src, "mine")
obj/LifeSkills/OreNode/MouseExited(location, control, params)
	..()
	CursorLeave(src)

obj/LifeSkills/Tree/MouseEntered(location, control, params)
	..()
	if(!depleted) CursorHover(src, "chop")
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
