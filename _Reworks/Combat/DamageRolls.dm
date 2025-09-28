
var/global/new_damage_calc = 0

proc/randValue(min,max,divider=10)
	return rand(min*divider,max*divider)/divider



/mob/proc/GetDamageMod(lowerMod, upperMod)
	var/min = glob.min_damage_roll+lowerMod
	var/max = glob.upper_damage_roll+upperMod
	var/obj/Items/Sword/s = src.EquippedSword()
	var/val = randValue(min,max)
	val += Judgment && !Oozaru ? (glob.min_damage_roll/2)*AscensionsAcquired : 0
	if(src.HasSteady())
		val += GetSteady()
		if(s && passive_handler["Zornhau"] && Target)
			var/zorn = 0 
			if(Target.equippedArmor)
				zorn = (passive_handler["Zornhau"] * 2)
			else
				zorn = passive_handler["Zornhau"]
			zorn *= glob.STEADY_MODIFIER
			val += zorn
	var/negate = 0
	if(src.Target)
		negate = GetUnnvere() * (glob.STEADY_MODIFIER)
	val-=negate
	if(val >= glob.upper_damage_roll)
		val = glob.upper_damage_roll
	if(val <= min)
		val = min
	if(val > max)
		val = max
	return val

/mob/proc/GetUnnvere()
	var/total = passive_handler.Get("Unnerve")
	if(HasMythical())
		total+=HasMythical()*2
	return total