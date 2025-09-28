
mob/var/tmp/currentMagatama = 0
mob/var/tmp/list/magatamaBeads = list()
mob/var/tmp/manaStolen = 0
mob/proc/stealManaMagatama(value)
	manaStolen += value
	var/magatamaBeadAmount = 15
	if(ismob(loc))
		var/mob/m = loc
		magatamaBeadAmount = getMagatamaMana(m)
	while(manaStolen >= magatamaBeadAmount)
		gainMagatama()
		manaStolen -= magatamaBeadAmount

mob/proc/getMagatamaMana(mob/m)
	var/mana = 15
	if(m.SpecialBuff&&m.SpecialBuff.name == "Heavenly Regalia: The Three Treasures")
		mana = 15
	return mana

mob/proc/gainMagatama()
	var/obj/Magatama/magatama = new()
	magatama.StartOrbit()
	magatamaBeads += magatama
	vis_contents += magatama

mob/proc/loseMagatama()
	if(length(magatamaBeads)>0)
		for(var/obj/Magatama/magatama in magatamaBeads)
			magatamaBeads -= magatama
			vis_contents -= magatama
			del magatama
			return


obj/Skills/Buffs/SlotlessBuffs/Yasakani_no_Magatama/Bead_Constraint
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Yasakani_no_Magatama/Bead_Constraints
	ActiveMessage = "tosses a chain of beads forth!"
	EndYourself = 1
	AffectTarget = 1
	Range = 20
	ManaCost = 15
	Cooldown = 90
	adjust(mob/p)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: The Three Treasures")
			applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Yasakani_no_Magatama/Heavenly_Bead_Constraints
		else
			applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Yasakani_no_Magatama/Bead_Constraints
	verb/Bead_Constraint()
		set name = "Yasakani no Magatama: Bead Constraint"
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr)/*
		var/magatamaFound = FALSE
		if(length(usr.magatamaBeads)>0)
			magatamaFound = TRUE
			usr.loseMagatama()
		if(magatamaFound)*/
		Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/Yasakani_no_Magatama/Bead_Constraints
	EnergyDrain = 0.1
	TimerLimit = 60
	ActiveMessage = "is restrained by beads shimmering with energy around them!"
	OffMessage = "is no longer restrained..."
	passives = list("PureDamage" = -1)

obj/Skills/Buffs/SlotlessBuffs/Yasakani_no_Magatama/Heavenly_Bead_Constraints
	EnergyDrain = 0.3
	TimerLimit = 60
	ActiveMessage = "is restrained by beads shimmering with energy around them!"
	OffMessage = "is no longer restrained..."
	passives = list("PureDamage" = -1, "PureReduction" = -1)

/*mob/verb/testMagatama()
	var/obj/Magatama/magatama = new()
	usr.vis_contents += magatama
	sleep(10)
	magatama.StartOrbit()*/

obj/Magatama
	icon = 'Magatama.dmi'

	proc/StartOrbit()
		var/angle = 0
		while (TRUE)
			angle += 30
			if (angle >= 360)
				angle = 0

			var new_x = 48 + round(50 * cos(angle), 1)
			var new_y = 48 + round(50 * sin(angle), 1)

			animate(src, pixel_x =new_x, pixel_y = new_y, time = 5)
			spawn(5)
			animate(src, pixel_x = -new_x, pixel_y = -new_y, time = 5)

			sleep(10)