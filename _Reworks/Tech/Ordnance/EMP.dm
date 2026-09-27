atom/movable/proc/EMPHit(strength)
	return 0

mob/EMPHit(strength)
	if(strength <= 0) return 0
	. = 0
	if(EMPDropShields()) . = 1
	if(hascall(src, "ChipOffline"))
		call(src, "ChipOffline")(null, ORD_EMP_CHIP_SECS * strength)
		. = 1
	if(EMPDrainGear(strength)) . = 1
	if(.) src << "<font color='#8be9ff'>The pulse sets your equipment sparking.</font>"

mob/proc/EMPShieldBuffs()
	. = list()
	for(var/k in SlotlessBuffs)
		var/obj/Skills/Buffs/B = SlotlessBuffs[k]
		if(!B || !BuffOn(B)) continue
		if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Gear/Deflector_Shield) || istype(B, /obj/Skills/Buffs/SlotlessBuffs/Gear/Bubble_Shield))
			. += B
		else if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Deflector_Shield) || istype(B, /obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Bubble_Shield))
			. += B

mob/proc/EMPDropShields()
	var/list/L = EMPShieldBuffs()
	if(!L.len) return 0
	for(var/obj/Skills/Buffs/B in L)
		B.Trigger(src, Override = 1)
	if(length(EMPShieldBuffs())) spawn() EMPShieldRetry()
	return 1

mob/proc/EMPShieldRetry()
	for(var/i = 1 to ORD_EMP_SHIELD_TRIES)
		sleep(ORD_EMP_SHIELD_WAIT)
		var/list/L = EMPShieldBuffs()
		if(!L.len) return
		for(var/obj/Skills/Buffs/B in L)
			B.Trigger(src, Override = 1)

mob/proc/EMPDrainGear(strength)
	. = 0
	for(var/obj/Items/Gear/G in src)
		if(G.suffix != "*Equipped*") continue
		if(G.InfiniteUses) continue
		if(istype(G, /obj/Items/Gear/Prosthetic_Limb)) continue
		if(G.MaxUses <= 0 || G.Uses <= 0) continue
		G.Uses = max(0, G.Uses - G.MaxUses * strength)
		. = 1
