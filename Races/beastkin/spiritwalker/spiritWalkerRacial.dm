/mob/proc/preForm()
	if(SlotlessBuffs["Pheonix Form"] || SlotlessBuffs["Ram Form"] || SlotlessBuffs["Bear Form"] || SlotlessBuffs["Turtle Form"])
		for(var/index in SlotlessBuffs)
			if(istype(SlotlessBuffs[index], /obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker))
				SlotlessBuffs[index].Trigger(src, TRUE)
/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker
	TimerLimit = 30
	Cooldown = 90
/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker/Pheonix_Form
	endAdd = -0.25
	defAdd = -0.25
	offAdd = 0.5
	adjust(mob/p)
		var/asc = p.AscensionsAcquired
		passives = list("SweepingStrike" = 1, "Extend" = 1 + (asc/4), "Gum Gum" = 1 + (asc/4), "ComboMaster" = 1)
		Cooldown = 90 - (10 *p.AscensionsAcquired)
		TimerLimit = 30 + (6 *p.AscensionsAcquired)
	verb/Pheonix_Form()
		set category = "Stances"
		usr.preForm()
		Trigger(usr)

/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker/Ram_Form
	spdAdd = 0.25
	endAdd = 0.25
	offAdd = -0.25
	defAdd = -0.25
	adjust(mob/p)
		var/asc = p.AscensionsAcquired
		passives = list("Godspeed" = 1 + (asc/2), "BlurringStrikes" = clamp(asc/4, 0.25, 1), "Brutalize" = 0.5 + (asc/2))
		Cooldown = 90 - (10 *p.AscensionsAcquired)
		TimerLimit = 30 + (6 *p.AscensionsAcquired)
	verb/Ram_Form()
		set category = "Stances"
		usr.preForm()
		Trigger(usr)
/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker/Bear_Form
	strAdd = 0.25
	defAdd = -0.5
	forAdd = 0.25
	adjust(mob/p)
		var/asc = p.AscensionsAcquired
		passives = list("StunningStrike" = 2.5+asc, "ComboMaster" = 1,  "CheapShot" = asc/2, "Instinct" = asc)
		Cooldown = 90 - (10 *p.AscensionsAcquired)
		TimerLimit = 30 + (6 *p.AscensionsAcquired)
	verb/Bear_Form()
		set category = "Stances"
		usr.preForm()
		Trigger(usr)
/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker/Turtle_Form
	endAdd = 0.5
	defAdd = -0.5
	adjust(mob/p)
		var/asc = p.AscensionsAcquired
		passives = list("Harden" = 2 + asc/2,  "HardenedFrame" = 1, "DeathField" = 2+asc*2)
		Cooldown = 90 - (10 *p.AscensionsAcquired)
		TimerLimit = 30 + (6 *p.AscensionsAcquired)
	verb/Turtle_Form()
		set category = "Stances"
		usr.preForm()
		Trigger(usr)