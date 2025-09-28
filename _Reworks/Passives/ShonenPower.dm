/*

Unique Mechanic: ShonenPower
Activate at Low Health, lose at mid health i'd say, something like 10-15% and 25% respectively
in my mind this nullfies the chance to abuse it chain verbing, and it isn't always on like desperation/hellpower is

Rivals: Set a rival and gain bounes for fighting against them, similar to duel
only activates when low health


Friend Mechanic seems abusable, come back to it
was thinking bonus for every member in party, or a verb that lets you set partners, but both seem too abusable to be in, despite being fun


Gain more damage/reduction the lower Health% you are
Gain more power(intim) the more Fatigue% you have

Gain 0.25 Str/For for every tick - Same as Hell Power

Jugg = SPTick/2
-- note to change jugg to either chance to not move or move less, not as it is: dont move unless its forced, move less when it is

Difference between Desperation & this:
Desperation does more damage the more injuries you have, it also just doesn't make u take burn/poison apparently
It also gives a chance to get up
Hell Power does what this does but instead of health it's fatigue
*/



/mob/proc/triggerPlotArmor(shonenPower, unstoppable) // pass it isntead of finding it again
	var/plotArmor = TotalInjury + TotalFatigue
	if(unstoppable)
		plotArmor /= 28-shonenPower
	else
		plotArmor /= 10-shonenPower
	return clamp(plotArmor, 1, 50)


/mob/proc/GetSPScaling(sp)
	. = 1
	var/mult = sp // this is a max of 2 normally
	var/drain = (TotalInjury/4) + (TotalFatigue/2)
	. += ((0.15 * (1+drain * 0.05)) * mult)
	if(. <= 0)
		. = 1


/mob/proc/HasShonenPower()
	return passive_handler.Get("ShonenPower")

/mob/proc/GetShonenPower()
	return ShonenPowerCheck(src)



proc/ShonenPowerCheck(mob/player)
	if(!player) return FALSE
	if(player.Health>25) return FALSE
	if(!player.HasShonenPower())
		return FALSE
	if(player.Health>=1 && player.Health<=25)
		return player.passive_handler.Get("ShonenPower")


/mob/proc/getSPPower()
	var/totalSP = ShonenPowerCheck(src)
	if(totalSP)
		var/spPow = 0.5 * totalSP
		var/healthRatio = Health/100
		return round(spPow * healthRatio,0.1)*10

