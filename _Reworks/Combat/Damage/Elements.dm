/mob/proc/handleStaff(var/obj/Items/Enchantment/Staff/staff, mob/defender, second)
	if(NotUsingMagicSword())
		if(!ArcaneBladework)
			. += applyWeaponElement(staff, defender)
		else
			if(second)
				. += applyWeaponElement(staff, defender)

/mob/proc/doWeaponElements(second, third, mob/defender, list/weapons)
	if(!second&&!third)
		. += applyWeaponElement(weapons[1],defender)
	if(second&&!third)
		if(weapons[2])
			.+= applyWeaponElement(weapons[2],defender)
		else
			.+= applyWeaponElement(weapons[1],defender)
	if(second&&third)
		if(weapons[3])
			.+= applyWeaponElement(weapons[3],defender)
		else
			.+= applyWeaponElement(weapons[2],defender)

/mob/proc/applyWeaponElement(obj/Items/sword, mob/defender)
	if(!sword) return 0
	. = ElementalCheck(src, defender, list(sword.Element))




/mob/proc/getArmorEDefense()
	var/val = ElementalDefense
	if(EquippedArmor())
		ElementalDefense = EquippedArmor().Element ? EquippedArmor().Element : 0
	return val