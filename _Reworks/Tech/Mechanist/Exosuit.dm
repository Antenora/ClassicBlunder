#define EXOSUIT_DRAIN_TICK 60
#define EXOSUIT_DRAIN_BASE 1
#define EXOSUIT_POLL 10
#define EXO_DRAIN_LIGHT 1
#define EXO_DRAIN_HEAVY 2
#define EXO_DRAIN_ORDNANCE 3
#define EXO_ROW_DRAIN 1
#define EXO_ROW_SKILL 2
#define EXO_ROW_SUIT_ONLY 3
#define HOVERBOARD_SPEED 1.5
#define POWERED_TOOL_MULT 1.5
#define POWERED_TOOL_CHARGE 20

var/list/EXOSUIT_INTEGRABLE = list(\
	/obj/Items/Gear/Deflector_Shield = list(EXO_DRAIN_LIGHT, /obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Deflector_Shield, 0),\
	/obj/Items/Gear/Bubble_Shield = list(EXO_DRAIN_LIGHT, /obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Bubble_Shield, 0),\
	/obj/Items/Gear/Jet_Boots = list(EXO_DRAIN_LIGHT, /obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Boots, 0),\
	/obj/Items/Gear/Jet_Pack = list(EXO_DRAIN_LIGHT, /obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Pack, 0),\
	/obj/Items/Gear/Progressive_Blade = list(EXO_DRAIN_LIGHT, /obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Progressive_Blade, 0),\
	/obj/Items/Gear/Lightsaber = list(EXO_DRAIN_LIGHT, /obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Lightsaber, 0),\
	/obj/Items/Gear/Blast_Fist = list(EXO_DRAIN_LIGHT, /obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Blast_Fist, 0),\
	/obj/Items/Gear/Power_Fist = list(EXO_DRAIN_LIGHT, /obj/Skills/Queue/Gear/Integrated/Integrated_Power_Fist, 0),\
	/obj/Items/Gear/Pile_Bunker = list(EXO_DRAIN_LIGHT, /obj/Skills/Queue/Gear/Integrated/Integrated_Pile_Bunker, 0),\
	/obj/Items/Gear/Chainsaw = list(EXO_DRAIN_LIGHT, /obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Chainsaw, 0),\
	/obj/Items/Gear/Power_Claw = list(EXO_DRAIN_LIGHT, /obj/Skills/Queue/Gear/Integrated/Integrated_Power_Claw, 0),\
	/obj/Items/Gear/Hook_Grip_Claw = list(EXO_DRAIN_LIGHT, /obj/Skills/Queue/Gear/Integrated/Integrated_Hook_Grip_Claw, 0),\
	/obj/Items/Gear/Plasma_Blaster = list(EXO_DRAIN_HEAVY, /obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Blaster, 0),\
	/obj/Items/Gear/Plasma_Rifle = list(EXO_DRAIN_HEAVY, /obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Rifle, 0),\
	/obj/Items/Gear/Plasma_Gatling = list(EXO_DRAIN_HEAVY, /obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Gatling, 0),\
	/obj/Items/Gear/Missile_Launcher = list(EXO_DRAIN_HEAVY, /obj/Skills/Projectile/Gear/Integrated/Integrated_Missile_Launcher, 0),\
	/obj/Items/Gear/Chemical_Mortar = list(EXO_DRAIN_HEAVY, /obj/Skills/Projectile/Gear/Integrated/Integrated_Chemical_Mortar, 0),\
	/obj/Items/Gear/Incinerator = list(EXO_DRAIN_HEAVY, /obj/Skills/AutoHit/Gear/Integrated/Integrated_Incinerator, 0),\
	/obj/Items/Gear/Freeze_Ray = list(EXO_DRAIN_HEAVY, /obj/Skills/AutoHit/Gear/Integrated/Integrated_Freeze_Ray, 0),\
	/obj/Items/Gear/Ultra_Laser = list(EXO_DRAIN_ORDNANCE, /obj/Skills/Projectile/Gear/Ultra_Laser, 1),\
	/obj/Items/Gear/Missile_Massacre = list(EXO_DRAIN_ORDNANCE, /obj/Skills/Projectile/Gear/Missile_Massacre, 1))

/obj/Items/Gear
	var/part_slots = 0
	var/sockets = 0
	var/list/integrated_parts
	var/list/integrated_kept
	var/list/socket_chips
	var/tmp/exo_token = 0

	proc/ExoRoom()
		if(istype(src, /obj/Items/Gear/Prosthetic_Limb))
			return Techniques.len ? 0 : 1
		return max(0, part_slots - length(integrated_parts))

	proc/ExoAccepts(obj/Items/Gear/g)
		if(!istype(g) || g == src || !g.Integrateable) return 0
		if(g.suffix == "*Equipped*") return 0
		if(istype(g, /obj/Items/Gear/Prosthetic_Limb)) return 0
		var/list/row = EXOSUIT_INTEGRABLE[g.type]
		if(!row) return 0
		if(istype(src, /obj/Items/Gear/Prosthetic_Limb))
			return row[EXO_ROW_SUIT_ONLY] ? 0 : 1
		if(integrated_parts && (g.type in integrated_parts)) return 0
		return 1

	proc/ExoKept(path)
		if(!integrated_kept) integrated_kept = list()
		var/obj/Skills/S = integrated_kept[path]
		if(!S)
			S = new path
			integrated_kept[path] = S
		return S

	proc/ExoClearParts()
		integrated_parts = null
		if(integrated_kept)
			for(var/k in integrated_kept)
				var/obj/Skills/S = integrated_kept[k]
				if(S) del S
		integrated_kept = null

	proc/ExoDrainCost()
		. = EXOSUIT_DRAIN_BASE
		for(var/p in integrated_parts)
			var/list/row = EXOSUIT_INTEGRABLE[p]
			if(row) . += row[EXO_ROW_DRAIN]

	proc/ExoTickDS()
		return EXOSUIT_DRAIN_TICK * 10

	proc/ExoPayMinute(mob/M, obj/Skills/Buffs/B)
		if(InfiniteUses) return 1
		var/cost = ExoDrainCost()
		if(Uses < cost)
			if(M) M << "Your [src] runs out of power."
			if(M && B && M.BuffOn(B)) B.Trigger(M, Override = 1)
			return 0
		Uses -= cost
		return 1

	proc/ExoDrainLoop(mob/M, obj/Skills/Buffs/B, token)
		set waitfor = 0
		var/elapsed = 0
		while(M && B && exo_token == token)
			sleep(EXOSUIT_POLL)
			if(!M || !B || exo_token != token) return
			if(!M.BuffOn(B))
				M.ExoSuitOff(src)
				return
			elapsed += EXOSUIT_POLL
			if(elapsed < ExoTickDS()) continue
			elapsed = 0
			if(!ExoPayMinute(M, B)) return

	proc/ExoChipFits(obj/Items/Chip/C)
		if(!istype(C)) return 0
		if(C.ChipFamily != "System" && C.ChipFamily != "Routine") return 0
		if(socket_chips && (C.type in socket_chips)) return 0
		return 1

	proc/Update_Description()
		if(!part_slots) return
		desc = initial(desc)
		desc += "<br><br>Charge: [Uses] / [MaxUses], drains [ExoDrainCost()] a minute while on"
		var/list/names = list()
		for(var/p in integrated_parts)
			names += TechItemName(p)
		desc += "<br>Integrated ([length(integrated_parts)] of [part_slots]): [names.len ? jointext(names, ", ") : "nothing"]"
		var/list/chips = list()
		for(var/c in socket_chips)
			chips += "[QualityName(socket_chips[c])] [TechItemName(c)]"
		desc += "<br>Chip sockets ([length(socket_chips)] of [sockets]): [chips.len ? jointext(chips, ", ") : "empty"]"

/obj/Items/Gear/Power_Armor
	part_slots = 1
	sockets = 1
	UpdatesDescription = 1

/obj/Items/Gear/Power_Armor_Burst
	part_slots = 2
	sockets = 2
	UpdatesDescription = 1

/obj/Items/Gear/Power_Armor_Burly
	part_slots = 2
	sockets = 2
	UpdatesDescription = 1

/obj/Items/Gear/Power_Armor_Blitz
	part_slots = 2
	sockets = 2
	UpdatesDescription = 1

mob/proc/IntegrateGear(obj/Items/Gear/suit, obj/Items/Gear/part)
	if(!istype(suit) || suit.loc != src) return 0
	var/limb = istype(suit, /obj/Items/Gear/Prosthetic_Limb)
	if(!limb && !suit.part_slots) return 0
	var/host = limb ? "limb" : "armor"
	if(suit.suffix == "*Equipped*")
		src << "Take off your [host] before you try to jam a gear in it!"
		return 0
	if(!suit.ExoRoom())
		src << "This [host] already has as much gear integrated as it can hold!"
		return 0
	if(suit.Using)
		src << "You're already putting something in this [host]!"
		return 0
	suit.Using = 1
	. = ExoIntegratePick(suit, part, limb)
	if(suit) suit.Using = 0

mob/proc/ExoIntegratePick(obj/Items/Gear/suit, obj/Items/Gear/part, limb)
	var/where = limb ? "prosthetic" : "armor"
	if(!part)
		var/list/choices = list("Cancel")
		for(var/obj/Items/Gear/g in src)
			if(suit.ExoAccepts(g)) choices += g
		if(choices.len < 2)
			src << "You don't have any gear capable of being integrated into your [where]."
			return 0
		part = Ask(src, "What gear do you want to integrate into your [limb ? "prosthetic limb" : "power armor"]?", "Integrate", null, "pick", choices, 0)
	if(!istype(part, /obj/Items/Gear)) return 0
	if(!suit || suit.loc != src || part.loc != src || suit.suffix == "*Equipped*" || !suit.ExoRoom() || !suit.ExoAccepts(part))
		src << "That gear can't go into your [where] right now."
		return 0
	var/list/row = EXOSUIT_INTEGRABLE[part.type]
	if(limb)
		suit.Techniques += "[row[EXO_ROW_SKILL]]"
		suit.IntegratedUses = part.MaxUses
		suit.IntegratedMaxUses = suit.IntegratedUses
		suit.desc = "A replacement limb.  A [part] gear has been integrated within it."
	else
		if(!suit.integrated_parts) suit.integrated_parts = list()
		suit.integrated_parts += part.type
	src << "You've integrated [part] into your [where]!"
	del part
	if(client) client.BuildInvPage()
	return 1

mob/proc/UnintegrateGear(obj/Items/Gear/suit)
	if(!istype(suit) || suit.loc != src || !suit.part_slots) return 0
	if(suit.suffix == "*Equipped*")
		src << "Take off your armor before you try to jam a gear in it!"
		return 0
	if(!length(suit.integrated_parts))
		src << "This armor doesn't have any gear integrated!"
		return 0
	if(suit.Using)
		src << "You cannot unintegrate and integrate gear at the same time!"
		return 0
	suit.Using = 1
	var/ans = Ask(src, "Are you sure you wish to unintegrate? This will destroy any integration this armor currently has!", "", null, "pick", list("Yes","No"), 0)
	if(ans == "Yes" && suit && suit.loc == src && suit.suffix != "*Equipped*")
		suit.ExoClearParts()
		src << "You've successfully removed all integrations from this gear."
	if(suit) suit.Using = 0
	return 1

mob/proc/ExoSuitOn(obj/Items/Gear/G, obj/Skills/Buffs/B)
	if(!G || !B) return
	ExoGrant(G)
	G.exo_token++
	G.ExoDrainLoop(src, B, G.exo_token)

mob/proc/ExoSuitOff(obj/Items/Gear/G)
	if(!G) return
	G.exo_token++
	ExoRevoke(G)

mob/proc/ExoGrant(obj/Items/Gear/G)
	var/added = 0
	for(var/p in G.integrated_parts)
		var/list/row = EXOSUIT_INTEGRABLE[p]
		if(!row) continue
		var/obj/Skills/S = G.ExoKept(row[EXO_ROW_SKILL])
		S.AssociatedGear = G
		S.Integrated = 1
		S.CooldownStatic = 1
		if(!(S in Skills))
			AddSkill(S)
			added++
	if(added && client) client.RefreshHotbar()

mob/proc/ExoRevoke(obj/Items/Gear/G)
	if(!G || !G.integrated_kept) return
	var/removed = 0
	for(var/k in G.integrated_kept)
		var/obj/Skills/S = G.integrated_kept[k]
		if(!S) continue
		if(istype(S, /obj/Skills/Buffs))
			var/obj/Skills/Buffs/b = S
			if(BuffOn(b)) b.Trigger(src, Override = 1)
		if(AttackQueue == S) AttackQueue = null
		if(S in Skills)
			DeleteSkill(S, FALSE)
			removed++
	if(removed && client) client.RefreshHotbar()

mob/proc/ExoResume()
	for(var/obj/Items/Gear/G in src)
		if(!G.part_slots) continue
		var/obj/Skills/Buffs/B = ActiveBuff
		if(B && B.AssociatedGear == G && BuffOn(B))
			ExoSuitOn(G, B)
		else
			ExoRevoke(G)

mob/Players/Login()
	..()
	spawn(20) ExoResume()

/obj/Skills/Buffs/ActiveBuffs/Gear
	var/list/exo_base_passives

	proc/ExoAdjust(mob/p)
		var/obj/Items/Gear/G = AssociatedGear
		if(!istype(G) || !G.sockets) return
		if(!exo_base_passives) exo_base_passives = passives ? passives.Copy() : list()
		var/list/np = exo_base_passives.Copy()
		for(var/c in G.socket_chips)
			var/list/cp = ChipPassives(c, G.socket_chips[c])
			for(var/k in cp)
				np[k] = (np[k] ? np[k] : 0) + cp[k]
		passives = np

	proc/ExoAfter(mob/User, was)
		var/obj/Items/Gear/G = AssociatedGear
		if(!User || !istype(G) || !G.part_slots) return
		var/now = User.BuffOn(src)
		if(now && !was) User.ExoSuitOn(G, src)
		else if(was && !now) User.ExoSuitOff(G)

/obj/Skills/Buffs/ActiveBuffs/Gear/Power_Armor
	adjust(mob/p)
		..()
		ExoAdjust(p)
	Trigger(mob/User, Override = 0)
		var/was = User ? User.BuffOn(src) : 0
		. = ..()
		ExoAfter(User, was)

/obj/Skills/Buffs/ActiveBuffs/Gear/Power_Armor_Burst
	adjust(mob/p)
		..()
		ExoAdjust(p)
	Trigger(mob/User, Override = 0)
		var/was = User ? User.BuffOn(src) : 0
		. = ..()
		ExoAfter(User, was)

/obj/Skills/Buffs/ActiveBuffs/Gear/Power_Armor_Burly
	adjust(mob/p)
		..()
		ExoAdjust(p)
	Trigger(mob/User, Override = 0)
		var/was = User ? User.BuffOn(src) : 0
		. = ..()
		ExoAfter(User, was)

/obj/Skills/Buffs/ActiveBuffs/Gear/Power_Armor_Blitz
	adjust(mob/p)
		..()
		ExoAdjust(p)
	Trigger(mob/User, Override = 0)
		var/was = User ? User.BuffOn(src) : 0
		. = ..()
		ExoAfter(User, was)

mob/proc/ExoSocketReady(obj/Items/Gear/G, removing = 0)
	if(!istype(G) || G.loc != src || !G.sockets) return 0
	if(G.suffix == "*Equipped*")
		src << "Take off your [G] before you work on its chip sockets."
		return 0
	if(InCombat())
		src << "You can't work on a chip socket in a fight."
		return 0
	if(removing)
		if(!length(G.socket_chips))
			src << "Your [G] has no chip socketed."
			return 0
	else if(length(G.socket_chips) >= G.sockets)
		src << "Every chip socket on your [G] is full."
		return 0
	return 1

mob/proc/ExoSocketPick(obj/Items/Gear/G, obj/Items/Chip/C)
	if(!ExoSocketReady(G)) return 0
	if(!C)
		var/list/choices = list("Cancel")
		for(var/obj/Items/Chip/c in src)
			if(G.ExoChipFits(c)) choices += c
		if(choices.len < 2)
			src << "You have no System or Routine chip that fits your [G]."
			return 0
		C = Ask(src, "Which chip goes into your [G]?", "Socket Chip", null, "pick", choices, 0)
	if(!istype(C, /obj/Items/Chip) || C.loc != src || !G.ExoChipFits(C) || !ExoSocketReady(G)) return 0
	if(!G.socket_chips) G.socket_chips = list()
	G.socket_chips[C.type] = C.CraftQuality
	src << "You socket the [C] into your [G]."
	del C
	if(client) client.BuildInvPage()
	return 1

mob/proc/ExoUnsocketPick(obj/Items/Gear/G)
	if(!ExoSocketReady(G, 1)) return 0
	var/list/labels = list()
	var/list/choices = list("Cancel")
	for(var/t in G.socket_chips)
		var/label = "[QualityName(G.socket_chips[t])] [TechItemName(t)]"
		labels[label] = t
		choices += label
	var/pick = Ask(src, "Which chip comes out of your [G]?", "Unsocket Chip", null, "pick", choices, 0)
	if(!pick || pick == "Cancel") return 0
	var/t = labels[pick]
	if(!t || !G.socket_chips || !(t in G.socket_chips) || !ExoSocketReady(G, 1)) return 0
	var/q = G.socket_chips[t]
	G.socket_chips -= t
	if(!G.socket_chips.len) G.socket_chips = null
	var/obj/Items/Chip/C = new t
	C.CraftQuality = q
	GiveOrDrop(C)
	src << "You pull the [C] out of your [G]."
	if(client) client.BuildInvPage()
	return 1

/atom/movable/shud/invexobtn
	layer = MINV_LAYER + 0.7
	mouse_opacity = 2
	maptext_height = 18
	var/obj/Items/Gear/suit
	var/unsocket = 0

	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1"))
			usr.client.HideItemDesc()
			return
		var/mob/M = usr
		var/obj/Items/Gear/G = suit
		var/out = unsocket
		spawn()
			if(!M || !G) return
			if(out) M.ExoUnsocketPick(G)
			else M.ExoSocketPick(G)
			if(M && M.client && G && G.loc == M) M.client.ShowItemDesc(G)

client/ExosuitDescButton(obj/Items/I, list/objs)
	..()
	var/obj/Items/Gear/G = I
	if(!istype(G) || !G.sockets || !islist(objs)) return
	var/atom/movable/shud/invexobtn/b = new
	b.suit = G
	b.maptext_width = 100
	b.maptext = "<span style=\"[MINV_FONT]; color:#8be9ff\">&#9874; Socket chip</span>"
	b.screen_loc = "[InvXLoc(TECH_INV_BTN_X)],CENTER:[TECH_INV_BTN_Y]"
	objs += b
	if(!length(G.socket_chips)) return
	var/atom/movable/shud/invexobtn/u = new
	u.suit = G
	u.unsocket = 1
	u.maptext_width = 100
	u.maptext = "<span style=\"[MINV_FONT]; color:#8be9ff\">&#9874; Unsocket chip</span>"
	u.screen_loc = "[InvXLoc(TECH_INV_BTN_X)],CENTER:[TECH_INV_BTN_Y - TECH_INV_BTN_STEP]"
	objs += u
