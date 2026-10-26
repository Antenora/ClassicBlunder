#define BELT_SLOTS 4
#define BELT_SHARED_CD 15

/datum/itembelt
	var/obj/Items/slot1
	var/obj/Items/slot2
	var/obj/Items/slot3
	var/obj/Items/slot4
	var/list/cooldowns
	var/tmp/ticking = 0
	var/tmp/gen = 0

/mob/var/datum/itembelt/itembelt
/mob/var/tmp/belt_shared_until = 0
/mob/var/tmp/belt_hold_slot = 0
/mob/var/tmp/belt_hold_start = 0
/mob/var/tmp/belt_key_down = 0

/mob/proc/InitBelt()
	if(!itembelt) itembelt = new/datum/itembelt()
	return itembelt

/mob/proc/BeltSlotItem(n)
	if(n < 1 || n > BELT_SLOTS) return null
	InitBelt()
	return itembelt.vars["slot[n]"]

/mob/proc/BeltSlotWrite(n, obj/Items/I)
	if(n < 1 || n > BELT_SLOTS) return
	InitBelt()
	itembelt.vars["slot[n]"] = I

/mob/proc/BeltSlotOf(obj/Items/I)
	if(!I) return 0
	for(var/i = 1 to BELT_SLOTS)
		if(BeltSlotItem(i) == I) return i
	return 0

/mob/proc/BeltFirstFree()
	for(var/i = 1 to BELT_SLOTS)
		if(!BeltSlotItem(i)) return i
	return 0

/mob/proc/BeltValidate()
	. = 0
	for(var/i = 1 to BELT_SLOTS)
		var/obj/Items/I = BeltSlotItem(i)
		if(!I) continue
		if(I.loc != src || (I.Stackable && I.TotalStack <= 0))
			BeltSlotWrite(i, null)
			. = 1

/mob/proc/BeltTypeCD(obj/Items/I)
	if(!I) return 0
	InitBelt()
	if(!itembelt.cooldowns) return 0
	var/k = "[I.type]"
	if(!(k in itembelt.cooldowns)) return 0
	return itembelt.cooldowns[k]

/mob/proc/BeltStartCD(obj/Items/I)
	if(!I || I.BeltCooldown <= 0) return
	InitBelt()
	if(!itembelt.cooldowns) itembelt.cooldowns = list()
	itembelt.cooldowns["[I.type]"] = I.BeltCooldown
	BeltCooldownLoop()

/mob/proc/BeltCooldownLoop()
	InitBelt()
	var/datum/itembelt/B = itembelt
	if(B.ticking) return
	if(!B.cooldowns || !B.cooldowns.len) return
	B.ticking = 1
	B.gen++
	var/mygen = B.gen
	spawn(0)
		var/last = world.time
		while(src && B && B.gen == mygen && B.cooldowns && B.cooldowns.len)
			sleep(1)
			var/step = (world.time - last) / 10
			last = world.time
			if(step <= 0) continue
			var/list/done = list()
			for(var/k in B.cooldowns)
				var/left = B.cooldowns[k] - step
				if(left <= 0) done += k
				else B.cooldowns[k] = left
			for(var/k in done)
				B.cooldowns -= k
			if(client) client.RefreshBeltCooldowns()
		if(B && B.gen == mygen) B.ticking = 0
		if(client) client.RefreshBeltCooldowns()

/mob/proc/BeltLoginSanitize()
	InitBelt()
	BeltValidate()
	var/datum/itembelt/B = itembelt
	if(B.cooldowns)
		var/list/done = list()
		for(var/k in B.cooldowns)
			if(B.cooldowns[k] <= 0) done += k
		for(var/k in done)
			B.cooldowns -= k
		if(!B.cooldowns.len) B.cooldowns = null
	belt_shared_until = 0
	B.ticking = 0
	BeltCooldownLoop()

/mob/proc/BeltSet(n, obj/Items/I)
	if(n < 1 || n > BELT_SLOTS || !I) return 0
	InitBelt()
	if(!I.BeltUsable)
		src << "<font color='#ff6b6b'>[I.name] does not fit on your belt.</font>"
		return 0
	if(I.loc != src)
		src << "<font color='#ff6b6b'>You are not carrying [I.name].</font>"
		return 0
	if(InCombat())
		src << "<font color='#ff6b6b'>You cannot rework your belt in a fight.</font>"
		return 0
	var/held = BeltSlotOf(I)
	if(held && held != n)
		src << "<font color='#ff6b6b'>[I.name] is already on belt slot [held].</font>"
		return 0
	var/obj/Items/cur = BeltSlotItem(n)
	if(cur && cur != I && BeltTypeCD(cur) > 0)
		src << "<font color='#ff6b6b'>[cur.name] is still cooling down.</font>"
		return 0
	if(!I.BeltSlotAllowed(src)) return 0
	BeltSlotWrite(n, I)
	src << "[I.name] goes on belt slot [n]."
	if(client) client.RefreshBeltHUD()
	return 1

/mob/proc/BeltClear(n)
	if(n < 1 || n > BELT_SLOTS) return 0
	InitBelt()
	var/obj/Items/I = BeltSlotItem(n)
	if(!I) return 0
	if(InCombat())
		src << "<font color='#ff6b6b'>You cannot rework your belt in a fight.</font>"
		return 0
	if(BeltTypeCD(I) > 0)
		src << "<font color='#ff6b6b'>[I.name] is still cooling down.</font>"
		return 0
	BeltSlotWrite(n, null)
	src << "You take [I.name] off your belt."
	if(client) client.RefreshBeltHUD()
	return 1

/mob/proc/BeltConsume(obj/Items/I)
	if(!I) return
	if(I.Stackable)
		I.TotalStack--
		I.suffix = "[I.TotalStack]"
		if(I.TotalStack <= 0) del I
	else
		del I

/mob/proc/BeltReceiverFor(obj/Items/I)
	if(!I || !I.BeltAlly) return src
	var/mob/T = Target
	if(!ismob(T) || T == src) return src
	if(T.Dead || !T.loc || T.z != z) return src
	if(get_dist(src, T) > 1) return src
	if(T.KO) return T
	if(party && T.party == party) return T
	return src

/mob/proc/BeltHoldStart(n)
	if(n < 1 || n > BELT_SLOTS) return 0
	InitBelt()
	if(belt_hold_slot) return 0
	if(BeltValidate() && client) client.RefreshBeltHUD()
	var/obj/Items/I = BeltSlotItem(n)
	if(!I)
		src << "<font color='#ff6b6b'>Belt slot [n] is empty.</font>"
		return 0
	if(KO || Dead)
		src << "<font color='#ff6b6b'>You cannot reach your belt right now.</font>"
		return 0
	if(Stunned || Suspended || Launched || Stasis > 0)
		src << "<font color='#ff6b6b'>You cannot get a hand to your belt.</font>"
		return 0
	if(held_skill)
		src << "<font color='#ff6b6b'>You can't do that while charging [held_skill.name].</font>"
		return 0
	if(I.Using)
		src << "<font color='#ff6b6b'>You are already using [I.name].</font>"
		return 0
	if(world.time < belt_shared_until)
		src << "<font color='#ff6b6b'>Your belt is not ready yet.</font>"
		return 0
	if(BeltTypeCD(I) > 0)
		src << "<font color='#ff6b6b'>[I.name] is still cooling down.</font>"
		return 0
	belt_hold_slot = n
	belt_hold_start = world.time
	if(client) client.BeltHoldPaint(n, 0)
	spawn() BeltHoldLoop(n, I)
	return 1

/mob/proc/BeltHoldBroken(n, obj/Items/I)
	if(!I || I.loc != src) return 1
	if(BeltSlotItem(n) != I) return 1
	if(belt_key_down != n) return 1
	if(held_skill) return 1
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Charmed/charm_skill = locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Charmed) in src
	if(Stunned || Suspended || Launched || Stasis > 0 || KO || Dead || (charm_skill && BuffOn(charm_skill))) return 1
	return 0

/mob/proc/BeltHoldLoop(n, obj/Items/I)
	var/span = max(I.BeltHoldTime, 1)
	while(belt_hold_slot == n)
		if(BeltHoldBroken(n, I))
			BeltHoldEnd(n, I, 0)
			return
		var/p = (world.time - belt_hold_start) / span
		if(p >= 1)
			BeltHoldEnd(n, I, 1)
			return
		if(client) client.BeltHoldPaint(n, p)
		sleep(2)

/mob/proc/BeltHoldEnd(n, obj/Items/I, fired)
	if(belt_hold_slot != n) return 0
	var/released = (belt_key_down != n)
	belt_hold_slot = 0
	belt_hold_start = 0
	var/used = 0
	if(fired && I && I.loc == src)
		belt_receiver = BeltReceiverFor(I)
		used = I.BeltUse(src)
		belt_receiver = null
	else if(I)
		if(released)
			src << "<font color='#ff6b6b'>You let go of [I.name] before it was ready.</font>"
		else
			src << "<font color='#ff6b6b'>[I.name] slips out of your grip.</font>"
	belt_shared_until = world.time + BELT_SHARED_CD
	if(I) BeltStartCD(I)
	if(used && I && I.BeltConsumes) BeltConsume(I)
	BeltValidate()
	if(client)
		client.RefreshBeltHUD()
		client.BuildInvPage()
	return used

/mob/Exited(atom/movable/AM)
	. = ..()
	if(!itembelt || !istype(AM, /obj/Items)) return
	var/obj/Items/I = AM
	var/n = BeltSlotOf(I)
	if(!n) return
	BeltSlotWrite(n, null)
	if(belt_hold_slot == n) belt_key_down = 0
	if(client) client.RefreshBeltHUD()

/mob/verb/Belt_Slot_1()
	set hidden = 1
	set instant = 1
	usr.belt_key_down = 1
	spawn() usr.BeltHoldStart(1)

/mob/verb/Belt_Slot_1_up()
	set hidden = 1
	set instant = 1
	if(usr.belt_key_down == 1) usr.belt_key_down = 0

/mob/verb/Belt_Slot_2()
	set hidden = 1
	set instant = 1
	usr.belt_key_down = 2
	spawn() usr.BeltHoldStart(2)

/mob/verb/Belt_Slot_2_up()
	set hidden = 1
	set instant = 1
	if(usr.belt_key_down == 2) usr.belt_key_down = 0

/mob/verb/Belt_Slot_3()
	set hidden = 1
	set instant = 1
	usr.belt_key_down = 3
	spawn() usr.BeltHoldStart(3)

/mob/verb/Belt_Slot_3_up()
	set hidden = 1
	set instant = 1
	if(usr.belt_key_down == 3) usr.belt_key_down = 0

/mob/verb/Belt_Slot_4()
	set hidden = 1
	set instant = 1
	usr.belt_key_down = 4
	spawn() usr.BeltHoldStart(4)

/mob/verb/Belt_Slot_4_up()
	set hidden = 1
	set instant = 1
	if(usr.belt_key_down == 4) usr.belt_key_down = 0

/mob/Admin4/verb/beltTestKit()
	var/list/kit = list(/obj/Items/Tech/First_Aid_Kit, /obj/Items/Tech/Fast_Acting_Antivenom, /obj/Items/Tech/Cooling_Spray, /obj/Items/Tech/Sealing_Spray, /obj/Items/Tech/Focus_Stabilizer, /obj/Items/Tech/Power_Pack, /obj/Items/Tech/Medkit, /obj/Items/Tech/Coagulant_Spray, /obj/Items/Tech/Restorative_Salve, /obj/Items/Tech/Emergency_Autoinjector, /obj/Items/Tech/Defibrillator, /obj/Items/Ordnance/Frag_Grenade, /obj/Items/Ordnance/Smoke_Grenade, /obj/Items/Ordnance/Flash_Grenade, /obj/Items/Ordnance/Gas_Grenade, /obj/Items/Ordnance/EMP_Grenade, /obj/Items/Ordnance/Flare, /obj/Items/Ordnance/Bola, /obj/Items/Ordnance/Caltrops, /obj/Items/Ordnance/Frag_Mine, /obj/Items/Ordnance/EMP_Mine, /obj/Items/Ordnance/Breaching_Charge)
	for(var/t in kit)
		for(var/i = 1 to 5)
			var/obj/Items/I = new t(src)
			if(I.Stackable)
				I.TotalStack = 5
				I.suffix = "[I.TotalStack]"
				break
	src << "Belt test kit delivered."
	if(client) client.BuildInvPage()

/mob/Admin4/verb/beltSaveCheck()
	var/obj/Items/I = null
	for(var/obj/Items/x in src)
		if(x.BeltUsable)
			I = x
			break
	if(!I)
		src << "Belt save check: carry a belt item first, run beltTestKit."
		return
	var/obj/Items/mark = new I.type()
	mark.name = I.name
	var/datum/itembelt/probe = new/datum/itembelt()
	probe.slot1 = mark
	var/path = "SaveBackups/beltprobe_[ckey].sav"
	if(fexists(path)) fdel(path)
	var/savefile/F = new(path)
	F["pair"] << list(mark, probe)
	del F
	var/savefile/G = new(path)
	var/list/back
	G["pair"] >> back
	del G
	fdel(path)
	del mark
	if(!islist(back) || back.len < 2)
		src << "Belt save check: FAILED, the savefile gave nothing back."
		return
	var/obj/Items/ri = back[1]
	var/datum/itembelt/rb = back[2]
	src << "Belt save check: item [ri ? ri.name : "null"], slot1 [rb && rb.slot1 ? rb.slot1.name : "null"]."
	src << "Belt save check: refs [(rb && rb.slot1 == ri) ? "SURVIVED, a belt slot reloads onto the same item" : "BROKE, the belt must be rebuilt at login instead"]."
	if(ri) del ri
