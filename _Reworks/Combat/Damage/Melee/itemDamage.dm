/mob/proc/getItemDamage(list/swords, delay, acc, secondStrike, thirdStrike, swordAtk, specialstrike) // i hate it here
	#if DEBUG_ITEM_DAMAGE
	log2text("------", "----------------------------------------", "damageDebugs.txt", "[ckey]/[name]")
	log2text("Damage", "Starting Item Damage Mod", "damageDebugs.txt", "[ckey]/[name]")
	log2text("Damage", 0, "damageDebugs.txt", "[ckey]/[name]")
	#endif
	var/list/returnValues = list(delay, acc, 0) // delay, acc and damage mod
	var/obj/Items/Sword/s = swords[1]
	var/obj/Items/Sword/s2 = swords[2]
	var/obj/Items/Sword/s3 = swords[3]
	var/obj/Items/Enchantment/Staff/st = swords[4]
	if(st)
		if(specialstrike||UsingBattleMage())
			returnValues[1] /= GetStaffDrain(st)
			if(UsingBattleMage())
				returnValues[3] += GetStaffDamage(st)
			returnValues[2] *= GetStaffAccuracy(st)
	if(!secondStrike)
		if(s && swordAtk)
			returnValues[1] /= GetSwordDelay(s)
			returnValues[3] += GetSwordDamage(s)
			returnValues[2] *= GetSwordAccuracy(s)
	if(secondStrike && !thirdStrike)
		if(s2 && swordAtk)
			returnValues[1] /= GetSwordDelay(s2)
			returnValues[3] += GetSwordDamage(s2)
			returnValues[2] *= GetSwordAccuracy(s2)
		else if(s &&!s2&&swordAtk)
			returnValues[1] /= GetSwordDelay(s)
			returnValues[3] += GetSwordDamage(s)
			returnValues[2] *= GetSwordAccuracy(s)
		else if(ArcaneBladework&&st)
			returnValues[1] /= GetStaffDrain(st)
			returnValues[3] += GetStaffDamage(st)
			returnValues[2] *= GetStaffAccuracy(st)
			swordAtk = 0
	if(secondStrike && thirdStrike)
		if(s3 && swordAtk)
			returnValues[1] /= GetSwordDelay(s3)
			returnValues[3] += GetSwordDamage(s3)
			returnValues[2] *= GetSwordAccuracy(s3)
		else if(s&&!s3&&swordAtk)
			returnValues[1] /= GetSwordDelay(s)
			returnValues[3] += GetSwordDamage(s)
			returnValues[2] *= GetSwordAccuracy(s)
	#if DEBUG_ITEM_DAMAGE
	log2text("Damage", "Item dmg mod beflore global", "damageDebugs.txt", "[ckey]/[name]")
	log2text("Damage", returnValues[3], "damageDebugs.txt", "[ckey]/[name]")
	#endif
	if(returnValues[3] > 0)
		returnValues[3] *= glob.GLOBAL_ITEM_DAMAGE_MULT
		#if DEBUG_ITEM_DAMAGE
		log2text("Damage", "Item dmg mod after global", "damageDebugs.txt", "[ckey]/[name]")
		log2text("Damage", returnValues[3], "damageDebugs.txt", "[ckey]/[name]")
		#endif
	returnValues[3] = returnValues[3]
	#if DEBUG_ITEM_DAMAGE
	log2text("--------------------", "----------------------------------------", "damageDebugs.txt", "[ckey]/[name]")
	#endif
	return returnValues