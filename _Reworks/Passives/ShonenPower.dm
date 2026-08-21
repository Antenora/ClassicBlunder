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
	if(passive_handler.Get("Hopes and Dreams")) . *= clamp((1.5 + (AscensionsAcquired/10)), 1.5, 2);
	if(. <= 0)
		. = 1


/mob/proc/HasShonenPower()
	return passive_handler.Get("ShonenPower")

/mob/proc/GetShonenPower()
	return ShonenPowerCheck(src)



proc/ShonenPowerCheck(mob/player)
	if(!player) return FALSE
	if(player.HealthPct() >= glob.SHONEN_RAMP_START) return FALSE
	if(player.HealthPct() < 1) return FALSE
	if(!player.HasShonenPower())
		return FALSE
	return player.passive_handler.Get("ShonenPower")


/mob/proc/getSPPower()
	var/totalSP = ShonenPowerCheck(src)
	if(totalSP)
		var/f = clamp((glob.SHONEN_RAMP_START - HealthPct()) / (glob.SHONEN_RAMP_START - glob.SHONEN_RAMP_FLOOR), 0, 1)
		return totalSP * f * glob.SHONEN_POWER_SCALE

/strikeHook/shonenCounter
	stage = "post"
	fire(strike/S)
		var/mob/attacker = S.attacker
		var/mob/defender = S.defender
		var/val = S.defender.HPToPct(S.dealt)
		if(defender.passive_handler["Shonen"]&&defender.Target)
			if(defender.HealthPct() < defender.Target.HealthPct() && attacker.HealthPct() < 50 + 5 * defender.AscensionsAcquired)
				defender.ShonenCounter+=(val * (defender.AscensionsAcquired/40)) * 1 + (defender.passive_handler["Shonen"]/5)
				if(defender.ShonenCounter>=glob.SHONENCOUNTERLIMIT)
					defender.ShonenCounter=1
					if(!defender.ShonenAnnounce)
						defender << "This is your...Moment! (No App)"
						var/obj/Skills/Buffs/s = defender.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Racial/Human/Deus_Ex_Machina)
						if(!defender.BuffOn(s))
							s.Trigger(defender, TRUE)
						defender.ShonenAnnounce=1
		if(attacker.passive_handler["Shonen"]&&defender==attacker.Target)
			if(attacker.HealthPct() < attacker.Target.HealthPct() && attacker.HealthPct() < 50 + 5 * attacker.AscensionsAcquired)
				attacker.ShonenCounter+=(val * (attacker.AscensionsAcquired/40)) * 1 + (attacker.passive_handler["Shonen"]/5)
				if(attacker.ShonenCounter>=glob.SHONENCOUNTERLIMIT)
					attacker.ShonenCounter=1
					if(!attacker.ShonenAnnounce)
						attacker << "This is your...Moment! (No App)"
						var/obj/Skills/Buffs/s = attacker.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Racial/Human/Deus_Ex_Machina)
						if(!attacker.BuffOn(s))
							s.Trigger(attacker, TRUE)
						attacker.ShonenAnnounce=1

/strikeHook/adaptationCounter
	stage = "post"
	fire(strike/S)
		var/mob/attacker = S.attacker
		var/mob/defender = S.defender
		var/val = S.defender.HPToPct(S.dealt)
		if(!(defender.HasAdaptation()&&attacker==defender.Target||attacker.HasAdaptation()&&defender==attacker.Target))
			return
		if(defender.HasAdaptation()&&!defender.CheckSlotless("Great Ape"))
			defender.AdaptationTarget=attacker
			defender.AdaptationCounter+=( val*(defender.AscensionsAcquired/40) )
			if(defender.AdaptationCounter>=1)
				defender.AdaptationCounter=1
				if(!defender.AdaptationAnnounce)
					defender << "<b>You've adapted to your target's style!</b>"
					defender.AdaptationAnnounce=1
		if(attacker.HasAdaptation()&&!attacker.CheckSlotless("Great Ape"))
			attacker.AdaptationTarget=defender
			attacker.AdaptationCounter+=(val*(attacker.AscensionsAcquired/40))
			if(attacker.AdaptationCounter>=1)
				attacker.AdaptationCounter=1
				if(!attacker.AdaptationAnnounce)
					attacker << "<b>You've adapted to your target's style!</b>"
					attacker.AdaptationAnnounce=1
