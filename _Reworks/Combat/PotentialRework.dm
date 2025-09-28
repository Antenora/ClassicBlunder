///var/list/POWER_TIERS = list("F", "E", "D", "C", "B", "A", "S", "SS", "SSS", "LEGENDARY", "DIVINE", "GODLY", "OMNI", "INFINITE")

/var/MAX_MULT = 250
/var/POTENTIAL_HIGH_POINT = 400
/var/MAX_TIERS = 14
/var/GLOBAL_DISPLAY_NERF = 0.80 // if your actual
/mob/var/potential_power_tier = 1
/mob/var/power_display // the display power, meaning pot + other effects tha tmake u to have more power
/var/BASE_MOD = 1 // the base mod for power, this is the mod that is used for the first tier of power

/mob/Admin3/verb/changeBaseMod()
	set category = "Admin"
	set desc = "Changes the base mod for power"
	set name = "Change Global Base"
	var/previous = BASE_MOD
	var/newMod = input(src, "Enter a new base mod for power") as num
	if(newMod)
		BASE_MOD = newMod
		world << "Base mod for power changed from [previous] to [newMod]"

/mob/proc/get_power_tier(actual = 1, pot, nerf) // if actual is 0 take into account other benefits, this is for display
	var/midway = POTENTIAL_HIGH_POINT / 5
	var/divisor = 10
	if(!actual)
		pot = nerf&&pot>50 ? pot * GLOBAL_DISPLAY_NERF : pot // if applicable, given anger makes it 2x and 3x etc it will very easily climb
		divisor = potential_power_mult
	if(pot <= 0)
		return 1
	else if(pot < midway)
		if(divisor == 0)
			return 1
		return round(pot/divisor, 1)
	else
		var/tier = 10
		if(!actual)
			tier = potential_power_tier-1
			midway = midway
		tier+=log(pot-(midway-10))
		var/normalized_tier = tier / (10 + log(POTENTIAL_HIGH_POINT - (midway-10)))
		. = min(round(normalized_tier * MAX_TIERS, 1), MAX_TIERS)
		return min(round(normalized_tier * MAX_TIERS, 1), MAX_TIERS)

/mob/proc/getDisplayPower()

proc
	/*
		Each tier of power increases the mult that you have, increasing ur overall power aka damage etc.
		the issue rn is that this is set up for 1-100, which is rigid and static, essentially there are 10 tiers of power and once you pass that there is no more scaling
		to fix that we need a dynamic calculation that will consistently get you a scaling mult depending on a variable
		the only issue is that a wipe runner does not know how long a wipe will be running for, and therefore the number is more like infinity than a variable itself

		Tiers
			F, E, D, C, B, A, S, SS, SSS, LEGENDARY, DIVINE, GODLY, OMNI, INFINITE
			these names are just cool names, they don't mean anything
			there are 14 tiers instead of 10, giving more room for dynamic scaling

		Variables
			CONSTANS
				MAX_TIERS
				POTENTIAL_HIGH_POINT
		Formula
			Input: 0-'ininfite'
			Output: 1-MAX_TIERS
		get_tier(input)
			tier = log(input) + 1
			normalized_tier = tier / (log(POTENTIAL_HIGH_POINT) + 1)
			return min(normalized_tier * MAX_TIERS + 1, MAX_TIERS)
	*/


	temp_potential_power(mob/player)
		if(player.get_potential()==player.potential_last_checked)
			return//don't keep getting potential power if the potential hasn't changed
		var/potential = player.get_potential()
		if(player.Class in list("Dance", "Potara"))
			return // dont mess with my fusion power
		var/tier = player.get_power_tier(1, potential)
		var/new_mult = round((potential/POTENTIAL_HIGH_POINT) * MAX_MULT)
		if(new_mult < 1) // if the mult is less than 1, make it 1
			new_mult = 1
		player.potential_power_mult = new_mult
		player.potential_last_checked = potential
		player.potential_power_tier = tier