#define AH_CUT 0.20
#define AH_FEE_PCT 0.01
#define AH_FEE_MIN 10
#define AH_MAX_LISTINGS 10
#define AH_FIXED_EXPIRE_DS 6048000    // fixed listings: 7 real days
#define AH_MIN_INC 0.05               // bids: +5% minimum
#define AH_SNIPE_WINDOW 1200          // a bid in the final 2 min...
#define AH_SNIPE_EXTEND 3000          // ...pushes the close out 5 min
#define AH_PRICE_MAX 16000000         // Maybe, might try and figure out a workaround to let this be higher
#define AH_SAVEFILE "Saves/AuctionHouse.sav"
#define AH_BACKUP "Saves/AuctionHouse.bak"

/datum/ah_listing
	var/id = 0
	var/kind = "item"          // item | lot
	var/is_auction = 0
	var/seller_ckey = ""
	var/seller_name = ""
	var/seller_cid = ""        // no alts
	var/seller_ip = ""
	var/obj/Items/item         // held here while listed (loc = null)
	var/matclass = ""          // lots
	var/mquality = 0
	var/mcount = 0
	var/price = 0              // fixed asking price / auction buy-in reference
	var/start_bid = 0
	var/cur_bid = 0
	var/cur_bidder_ckey = ""
	var/cur_bidder_name = ""
	var/listed_rt = 0
	var/end_rt = 0             // auction close / fixed expiry, absolute realtime
	var/pkey = ""              // price-history key

	proc/Label()
		if(kind == "lot") return "[mcount]x [QualityName(mquality)] [LifeMatName(matclass)]"
		return item ? "[item.name]" : "?"

/datum/ah_box_entry
	var/kind = "money"         // money | item | lot
	var/amount = 0
	var/obj/Items/item
	var/matclass = ""
	var/mquality = 0
	var/mcount = 0
	var/note = ""

/datum/auction_house
	var/list/listings = list()     // "id" -> /datum/ah_listing
	var/next_id = 1
	var/list/boxes = list()        // ckey -> list of /datum/ah_box_entry
	var/list/history = list()      // pkey -> list of list(realtime, unit_price)

var/datum/auction_house/AuctionHouse

proc/AuctionHouseLoad()
	if(AuctionHouse) return
	if(fexists(AH_SAVEFILE))
		var/savefile/F = new(AH_SAVEFILE)
		F["ah"] >> AuctionHouse
	if(!AuctionHouse && fexists(AH_BACKUP))
		// main file died mid-write, the backup is the last good state
		world.log << "//\[warn]: AuctionHouse.sav unreadable, restoring from backup."
		var/savefile/B = new(AH_BACKUP)
		B["ah"] >> AuctionHouse
	if(!AuctionHouse) AuctionHouse = new
	if(!AuctionHouse.listings) AuctionHouse.listings = list()
	if(!AuctionHouse.boxes) AuctionHouse.boxes = list()
	if(!AuctionHouse.history) AuctionHouse.history = list()

proc/AuctionHouseSave()
	if(!AuctionHouse) return
	// keep the last good file around until the new write lands
	if(fexists(AH_SAVEFILE))
		fdel(AH_BACKUP)
		fcopy(AH_SAVEFILE, AH_BACKUP)
	fdel(AH_SAVEFILE)
	var/savefile/F = new(AH_SAVEFILE)
	F["ah"] << AuctionHouse

proc/AhOnlineMob(ckey)
	for(var/mob/Players/P in world)
		if(P.ckey == ckey && P.client) return P
	return null

proc/AhSaveMob(mob/M)
	if(M && M.client && M.Savable) M.client.SaveChar()

proc/AhNotify(ckey, msg)
	var/mob/M = AhOnlineMob(ckey)
	if(M) M << "<font color=#ffd86b><b>Auction House:</b></font> [msg]"

// collection box

proc/AhBox(ckey)
	AuctionHouseLoad()
	if(!AuctionHouse.boxes[ckey]) AuctionHouse.boxes[ckey] = list()
	return AuctionHouse.boxes[ckey]

proc/AhBoxMoney(ckey, amount, note)
	if(amount <= 0) return
	var/datum/ah_box_entry/e = new
	e.kind = "money"
	e.amount = amount
	e.note = note
	var/list/B = AhBox(ckey)
	B += e
	AhNotify(ckey, "[note] $[Commas(amount)] awaits you in your collection box.")

proc/AhBoxItem(ckey, obj/Items/I, note)
	if(!I) return
	I.loc = null
	var/datum/ah_box_entry/e = new
	e.kind = "item"
	e.item = I
	e.note = note
	var/list/B = AhBox(ckey)
	B += e
	AhNotify(ckey, "[note] [I.name] awaits you in your collection box.")

proc/AhBoxLot(ckey, matclass, q, count, note)
	if(count <= 0) return
	var/datum/ah_box_entry/e = new
	e.kind = "lot"
	e.matclass = matclass
	e.mquality = q
	e.mcount = count
	e.note = note
	var/list/B = AhBox(ckey)
	B += e
	AhNotify(ckey, "[note] [count]x [QualityName(q)] [LifeMatName(matclass)] awaits you in your collection box.")

mob/proc/AhClaimBox()
	AuctionHouseLoad()
	var/list/B = AuctionHouse.boxes[ckey]
	if(!B || !B.len)
		src << "Your collection box is empty."
		return
	var/claimed = 0
	var/list/keep = list()
	for(var/datum/ah_box_entry/e in B)
		if(e.kind == "money")
			GiveMoney(e.amount)
			src << "<font color=#78eb78>Collected $[Commas(e.amount)]. ([e.note])</font>"
			claimed++
		else if(e.kind == "item")
			if(e.item)
				if(!CanPickupItem(e.item))
					src << "<font color=#ffd86b>[e.item.name] stays boxed - make room in your [InvClassify(e.item)] pack first.</font>"
					keep += e
					continue
				GiveOrDrop(e.item)
				src << "<font color=#78eb78>Collected [e.item.name]. ([e.note])</font>"
			claimed++
		else if(e.kind == "lot")
			var/banked = MatLogAdd(e.matclass, e.mquality, e.mcount)
			if(banked < e.mcount)
				// log bucket full, the rest stays boxed
				e.mcount -= banked
				src << "<font color=#ffd86b>Collected [banked]x [LifeMatName(e.matclass)] - your log is full, [e.mcount] stay boxed.</font>"
				keep += e
				continue
			src << "<font color=#78eb78>Collected [e.mcount]x [QualityName(e.mquality)] [LifeMatName(e.matclass)]. ([e.note])</font>"
			claimed++
	AuctionHouse.boxes[ckey] = keep
	AuctionHouseSave()
	AhSaveMob(src)
	if(!claimed && keep.len) src << "Nothing could be collected right now."

// listability

proc/AhCanList(mob/M, obj/Items/I)
	if(!I) return "Nothing to list."
	if(I.loc != M) return "You aren't holding that."
	if(findtext(I.suffix, "Equipped")) return "Unequip it first."
	if(I.PermEquip) return "That's bound to its wearer."
	if(I.BoundEquip) return "That item is soulbound."
	if(I.Saga || I.TrueLegend) return "Relics of that caliber can't be consigned."
	if(!I.Savable) return "The house won't hold something that unstable."
	if(istype(I, /obj/Items/Sword) && I:ProjectionBlade) return "That blade isn't really there."
	return ""

mob/proc/AhListingCount()
	AuctionHouseLoad()
	. = 0
	for(var/k in AuctionHouse.listings)
		var/datum/ah_listing/L = AuctionHouse.listings[k]
		if(L && L.seller_ckey == ckey) .++

// price history

proc/AhPriceKeyItem(obj/Items/I)
	return "[I.type]|[I.metal_id ? I.metal_id : ""]|[I.CraftQuality]"

proc/AhPriceKeyLot(matclass, q)
	return "lot|[matclass]|[q]"

proc/AhRecordSale(pkey, unit_price)
	if(!pkey || unit_price <= 0) return
	AuctionHouseLoad()
	if(!AuctionHouse.history[pkey]) AuctionHouse.history[pkey] = list()
	var/list/H = AuctionHouse.history[pkey]
	H += list(list(world.realtime, unit_price))
	while(H.len > 200) H.Cut(1, 2)

proc/AhMedianPrice(pkey)
	AuctionHouseLoad()
	var/list/H = AuctionHouse.history[pkey]
	if(!H || !H.len) return 0
	var/list/vals = list()
	for(var/i = max(1, H.len - 19) to H.len)
		var/list/rec = H[i]
		vals += rec[2]
	// window's only 20 wide, insertion sort is plenty
	for(var/i = 2 to vals.len)
		var/v = vals[i]
		var/j = i - 1
		while(j >= 1 && vals[j] > v)
			vals[j + 1] = vals[j]
			j--
		vals[j + 1] = v
	var/mid = round((vals.len + 1) / 2)
	if(vals.len % 2) return vals[mid]
	return round((vals[mid] + vals[mid + 1]) / 2)

proc/AhSaleCount(pkey)
	AuctionHouseLoad()
	var/list/H = AuctionHouse.history[pkey]
	return H ? H.len : 0

// listing

// fee is up front and non-refundable. ask = buyout for fixed, start bid for auctions
proc/AhListingFee(ask)
	return max(AH_FEE_MIN, round(ask * AH_FEE_PCT))

mob/proc/AhListItem(obj/Items/I, ask, is_auction = 0, duration_ds = 864000)
	AuctionHouseLoad()
	var/why = AhCanList(src, I)
	if(why)
		src << "<font color=#ff6464>[why]</font>"
		return 0
	if(ask < 1)
		src << "Set a real price."
		return 0
	if(ask > AH_PRICE_MAX)
		src << "The house caps prices at $[Commas(AH_PRICE_MAX)]."
		return 0
	if(AhListingCount() >= AH_MAX_LISTINGS)
		src << "You already have [AH_MAX_LISTINGS] listings up."
		return 0
	var/fee = AhListingFee(ask)
	if(!HasMoney(fee))
		src << "The listing fee is $[Commas(fee)] - you can't cover it."
		return 0
	TakeMoney(fee)
	var/datum/ah_listing/L = new
	L.id = AuctionHouse.next_id++
	L.kind = "item"
	L.is_auction = is_auction
	L.seller_ckey = ckey
	L.seller_name = name
	if(client)
		L.seller_cid = "[client.computer_id]"
		L.seller_ip = client.address ? "[client.address]" : ""
	L.item = I
	I.loc = null
	L.pkey = AhPriceKeyItem(I)
	L.listed_rt = world.realtime
	if(is_auction)
		L.start_bid = ask
		L.end_rt = world.realtime + duration_ds
	else
		L.price = ask
		L.end_rt = world.realtime + AH_FIXED_EXPIRE_DS
	AuctionHouse.listings["[L.id]"] = L
	AuctionHouseSave()
	AhSaveMob(src)
	src << "<font color=#78eb78>Listed [L.Label()] [is_auction ? "for auction, opening at" : "at"] $[Commas(ask)]. (fee $[Commas(fee)])</font>"
	return 1

mob/proc/AhListLot(matclass, q, count, ask, is_auction = 0, duration_ds = 864000)
	AuctionHouseLoad()
	if(count < 1 || ask < 1) return 0
	if(ask > AH_PRICE_MAX)
		src << "The house caps prices at $[Commas(AH_PRICE_MAX)]."
		return 0
	if(MatLogCountQ(matclass, q) < count)
		src << "You don't hold that many in your log."
		return 0
	if(AhListingCount() >= AH_MAX_LISTINGS)
		src << "You already have [AH_MAX_LISTINGS] listings up."
		return 0
	var/fee = AhListingFee(ask)
	if(!HasMoney(fee))
		src << "The listing fee is $[Commas(fee)] - you can't cover it."
		return 0
	TakeMoney(fee)
	MatLogTakeQ(matclass, q, count)
	var/datum/ah_listing/L = new
	L.id = AuctionHouse.next_id++
	L.kind = "lot"
	L.is_auction = is_auction
	L.seller_ckey = ckey
	L.seller_name = name
	if(client)
		L.seller_cid = "[client.computer_id]"
		L.seller_ip = client.address ? "[client.address]" : ""
	L.matclass = matclass
	L.mquality = q
	L.mcount = count
	L.pkey = AhPriceKeyLot(matclass, q)
	L.listed_rt = world.realtime
	if(is_auction)
		L.start_bid = ask
		L.end_rt = world.realtime + duration_ds
	else
		L.price = ask
		L.end_rt = world.realtime + AH_FIXED_EXPIRE_DS
	AuctionHouse.listings["[L.id]"] = L
	AuctionHouseSave()
	AhSaveMob(src)
	src << "<font color=#78eb78>Listed [L.Label()] [is_auction ? "for auction, opening at" : "at"] $[Commas(ask)]. (fee $[Commas(fee)])</font>"
	return 1

mob/proc/AhCancel(id)
	AuctionHouseLoad()
	var/datum/ah_listing/L = AuctionHouse.listings["[id]"]
	if(!L) return
	if(L.seller_ckey != ckey)
		src << "Not your listing."
		return
	if(L.is_auction && L.cur_bidder_ckey)
		src << "<font color=#ff6464>There's a live bid on it - the hammer decides now.</font>"
		return
	AuctionHouse.listings -= "[id]"
	if(L.kind == "item" && L.item)
		GiveOrDrop(L.item)
		src << "You take [L.item.name] back off the block."
	else if(L.kind == "lot")
		var/banked = MatLogAdd(L.matclass, L.mquality, L.mcount)
		if(banked < L.mcount) AhBoxLot(ckey, L.matclass, L.mquality, L.mcount - banked, "Canceled listing overflow:")
		src << "You take [L.Label()] back off the block."
	AuctionHouseSave()
	AhSaveMob(src)

// buying + bidding

// anti-alt measures
proc/AhSameOwner(mob/M, datum/ah_listing/L)
	if(!M || !L) return 0
	if(L.seller_ckey == M.ckey) return 1
	if(M.client)
		if(L.seller_cid && "[M.client.computer_id]" == L.seller_cid) return 1
		if(L.seller_ip && M.client.address && "[M.client.address]" == L.seller_ip) return 1
	return 0

proc/AhDeliver(mob/M, datum/ah_listing/L)
	if(L.kind == "item" && L.item)
		M.GiveOrDrop(L.item)
	else if(L.kind == "lot")
		var/banked = M.MatLogAdd(L.matclass, L.mquality, L.mcount)
		if(banked < L.mcount) AhBoxLot(M.ckey, L.matclass, L.mquality, L.mcount - banked, "Purchase overflow:")

// count applies to fixed lot listings: 0 = the whole remaining lot
mob/proc/AhBuy(id, count = 0)
	AuctionHouseLoad()
	var/datum/ah_listing/L = AuctionHouse.listings["[id]"]
	if(!L || L.is_auction) return
	if(AhSameOwner(src, L))
		src << "The house won't broker a sale back to its own seller."
		return
	if(L.kind == "lot" && count > 0 && count < L.mcount)
		// partial fill: ceil the unit price so partials never underpay, floor $1
		var/cost = max(1, -round(-(L.price * count / L.mcount)))
		if(!HasMoney(cost))
			src << "You can't cover the $[Commas(cost)]."
			return
		TakeMoney(cost)
		L.price = max(0, L.price - cost)
		L.mcount -= count
		var/banked = MatLogAdd(L.matclass, L.mquality, count)
		if(banked < count) AhBoxLot(ckey, L.matclass, L.mquality, count - banked, "Purchase overflow:")
		var/pcut = round(cost * AH_CUT)
		AhBoxMoney(L.seller_ckey, cost - pcut, "[count]x [QualityName(L.mquality)] [LifeMatName(L.matclass)] sold to [name]:")
		AhRecordSale(L.pkey, max(1, round(cost / count)))
		AuctionHouseSave()
		AhSaveMob(src)
		AhSaveMob(AhOnlineMob(L.seller_ckey))
		src << "<font color=#78eb78>Bought [count]x [QualityName(L.mquality)] [LifeMatName(L.matclass)] for $[Commas(cost)]. ([L.mcount] left listed)</font>"
		return
	if(!HasMoney(L.price))
		src << "You can't cover the $[Commas(L.price)]."
		return
	TakeMoney(L.price)
	AuctionHouse.listings -= "[id]"
	AhDeliver(src, L)
	var/cut = round(L.price * AH_CUT)
	AhBoxMoney(L.seller_ckey, L.price - cut, "[L.Label()] sold to [name]:")
	AhRecordSale(L.pkey, L.kind == "lot" ? max(1, round(L.price / L.mcount)) : L.price)
	AuctionHouseSave()
	AhSaveMob(src)
	AhSaveMob(AhOnlineMob(L.seller_ckey))
	src << "<font color=#78eb78>Bought [L.Label()] for $[Commas(L.price)].</font>"

mob/proc/AhMinBid(datum/ah_listing/L)
	return L.cur_bid ? max(L.cur_bid + 1, round(L.cur_bid * (1 + AH_MIN_INC))) : L.start_bid

mob/proc/AhBid(id, amt)
	AuctionHouseLoad()
	var/datum/ah_listing/L = AuctionHouse.listings["[id]"]
	if(!L || !L.is_auction) return
	if(world.realtime >= L.end_rt)
		src << "That auction just closed."
		return
	if(AhSameOwner(src, L))
		src << "The house won't take your bid on your own consignment."
		return
	if(L.cur_bidder_ckey == ckey)
		src << "You're already the top bid."
		return
	amt = round(amt)
	if(amt > AH_PRICE_MAX)
		src << "The house caps bids at $[Commas(AH_PRICE_MAX)]."
		return
	var/minbid = AhMinBid(L)
	if(amt < minbid)
		src << "The bid must be at least $[Commas(minbid)]."
		return
	if(!HasMoney(amt))
		src << "You can't cover $[Commas(amt)]."
		return
	TakeMoney(amt)
	// refund the old bidder - straight back if online, boxed if not
	if(L.cur_bidder_ckey)
		var/mob/prev = AhOnlineMob(L.cur_bidder_ckey)
		if(prev)
			prev.GiveMoney(L.cur_bid)
			prev << "<font color=#ffd86b><b>Auction House:</b></font> Outbid on [L.Label()] - your $[Commas(L.cur_bid)] is returned."
			AhSaveMob(prev)
		else
			AhBoxMoney(L.cur_bidder_ckey, L.cur_bid, "Outbid on [L.Label()]:")
	L.cur_bid = amt
	L.cur_bidder_ckey = ckey
	L.cur_bidder_name = name
	// anti-snipe: late bids stretch the clock
	if(L.end_rt - world.realtime < AH_SNIPE_WINDOW)
		L.end_rt += AH_SNIPE_EXTEND
		src << "The hammer hovers - the close extends five minutes."
	AuctionHouseSave()
	AhSaveMob(src)
	AhNotify(L.seller_ckey, "[name] bids $[Commas(amt)] on your [L.Label()].")
	src << "<font color=#78eb78>Bid $[Commas(amt)] on [L.Label()].</font>"

proc/AhSettleDue()
	AuctionHouseLoad()
	var/changed = 0
	for(var/k in AuctionHouse.listings)
		var/datum/ah_listing/L = AuctionHouse.listings[k]
		if(!L || world.realtime < L.end_rt) continue
		AuctionHouse.listings -= k
		changed = 1
		if(L.is_auction && L.cur_bidder_ckey)
			// goods to the winner, gold minus the cut to the seller
			if(L.kind == "item" && L.item) AhBoxItem(L.cur_bidder_ckey, L.item, "Auction won -")
			else if(L.kind == "lot") AhBoxLot(L.cur_bidder_ckey, L.matclass, L.mquality, L.mcount, "Auction won -")
			var/cut = round(L.cur_bid * AH_CUT)
			AhBoxMoney(L.seller_ckey, L.cur_bid - cut, "[L.Label()] hammered to [L.cur_bidder_name]:")
			AhRecordSale(L.pkey, L.kind == "lot" ? max(1, round(L.cur_bid / L.mcount)) : L.cur_bid)
		else
			// no takers or lapsed: back to the seller
			if(L.kind == "item" && L.item) AhBoxItem(L.seller_ckey, L.item, L.is_auction ? "No bids -" : "Listing expired -")
			else if(L.kind == "lot") AhBoxLot(L.seller_ckey, L.matclass, L.mquality, L.mcount, L.is_auction ? "No bids -" : "Listing expired -")
	if(changed) AuctionHouseSave()

proc/AuctionHouseTick()
	set background = 1
	AuctionHouseLoad()
	AhSettleDue()   // settle anything that came due while the server was down
	while(1)
		sleep(300)
		AhSettleDue()

/obj/AuctionHouse
	name = "Auction House"
	desc = "Consignments, bids, and the taxman's fifth. Interact to trade."
	icon = 'Icons/LifeSkills/FarmTools.dmi'
	icon_state = "stall"
	color = "#8be9ff"
	density = 1
	Savable = 1
	InteractWith(mob/M)
		if(M.client) M.client.OpenAhMenu(src)
		return 1
	Click()
		if(!usr || !usr.client || get_dist(usr, src) > 3) return
		usr.client.OpenAhMenu(src)

mob/Admin4/verb/makeAuctionHouse()
	set category = "Admin"
	new/obj/AuctionHouse(get_step(src, src.dir))
	src << "Auction house placed."

mob/Admin4/verb/ahListings()
	set category = "Admin"
	AuctionHouseLoad()
	if(!AuctionHouse.listings.len)
		src << "No live listings."
		return
	src << "<b>Live listings:</b>"
	for(var/k in AuctionHouse.listings)
		var/datum/ah_listing/L = AuctionHouse.listings[k]
		if(!L) continue
		src << "#[L.id] [L.seller_name]: [L.Label()] - [L.is_auction ? "bid $[Commas(L.cur_bid ? L.cur_bid : L.start_bid)][L.cur_bidder_name ? " ([L.cur_bidder_name])" : ""]" : "$[Commas(L.price)]"]"

mob/Admin4/verb/ahRemoveListing(id as num)
	set category = "Admin"
	AuctionHouseLoad()
	var/datum/ah_listing/L = AuctionHouse.listings["[round(id)]"]
	if(!L)
		src << "No listing #[round(id)]."
		return
	AuctionHouse.listings -= "[L.id]"
	if(L.is_auction && L.cur_bidder_ckey)
		var/mob/prev = AhOnlineMob(L.cur_bidder_ckey)
		if(prev)
			prev.GiveMoney(L.cur_bid)
			AhSaveMob(prev)
		else
			AhBoxMoney(L.cur_bidder_ckey, L.cur_bid, "Bid refunded (listing removed by staff):")
	if(L.kind == "item" && L.item) AhBoxItem(L.seller_ckey, L.item, "Removed by staff -")
	else if(L.kind == "lot") AhBoxLot(L.seller_ckey, L.matclass, L.mquality, L.mcount, "Removed by staff -")
	AuctionHouseSave()
	src << "Listing #[L.id] ([L.Label()], [L.seller_name]) pulled - goods and any bid returned."

mob/Admin4/verb/ahWipe()
	set category = "Admin"
	if(!src.Alert("Wipe the ENTIRE Auction House - all listings, boxes, and price history?")) return
	AuctionHouse = new
	fdel(AH_SAVEFILE)
	fdel(AH_BACKUP)
	AuctionHouseSave()
	src << "Auction house wiped clean."

mob/var/tmp/ah_box_pinged = 0

mob/proc/AhLoginPing()
	if(ah_box_pinged || !client) return
	ah_box_pinged = 1
	AuctionHouseLoad()
	var/list/B = AuctionHouse.boxes[ckey]
	if(B && B.len)
		src << "<font color=#ffd86b><b>Auction House:</b></font> [B.len] thing[B.len == 1 ? "" : "s"] await[B.len == 1 ? "s" : ""] you in your collection box."
