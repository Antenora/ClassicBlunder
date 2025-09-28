#define OOZARU_POTENTIAL_TRANS 10

/mob/var/tail_mastery = 1 // per 100 = 1 asc worth of resistance
/mob/var/oozaru_type = null

/mob/proc/tailResistanceTraining(probability)
	if(tail_mastery / 100 > clamp(AscensionsAcquired, 1, 5))
		return // maxed out
	if(prob(probability))
		if(prob(1))
			tail_mastery += rand(2,4)
		else
			tail_mastery++
	if(tail_mastery%100 == 0)
		src << "You have learned to adjust to attacks towards your tail!"
		src << "You have reached [tail_mastery/100] ascensions worth of resistance!"

/obj/Skills/Buffs/SlotlessBuffs/Oozaru
	var/Looking = 1
	var/Controlled = TRUE // if we ever want 'uncontrolled oozaru'
	BuffName = "Great Ape"
	IconTransform = 'Oozonew.dmi'
	Enlarge = 1.5
	TransformX = -32
	TransformY = -32
	AuraLock = 'BLANK.dmi'
	passives = list("Vulnerable Behind" = 1, "GiantForm" = 1, "NoDodge" = 1, "SweepingStrike" = 1, \
	"Meaty Paws" = 1)
	StrMult = 1.3
	ForMult = 1.2
	SpdMult = 0.3
	EndMult = 1.2
	DefMult = 0.1
	PowerMult=1.2
	AutoAnger = 0
	TimerLimit = 180
	verb/Moon_Toggle()
		set category="Other"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		Looking=!Looking
		if(usr.Oozaru)
			if(!Controlled)
				usr<<"You cannot will yourself out of the transformed state!"
				return
			usr.Oozaru = 0
			Trigger(usr, Override = 1)
		usr<< "You will [Looking ? "look" : "not look"] at the moon."

	adjust(mob/p)
		if(!p.oozaru_type)
			p.oozaru_type = input(p, "What type of Oozaru are you?") in list("Wrathful", "Enlightened", "Instinctual")
		passives = list("Vulnerable Behind" = 1, "GiantForm" = 1, "NoDodge" = 1, "SweepingStrike" = 1, \
			"Meaty Paws" = 1)
		switch(p.oozaru_type)
			if("Wrathful")
				passives["Manic"] = 4 - p.AscensionsAcquired
				passives["Meaty Paws"] = 2 + (p.AscensionsAcquired /2)
				StrMult = 1.2
				ForMult = 1.15
				EndMult = 1.2
				SpdMult = 0.3
				OffMult = 0.8
			if("Enlightened")
				StrMult = 1.2
				ForMult = 1.2
				EndMult = 1.2
				SpdMult = 0.3
				OffMult = 1.2
				TimerLimit = 360
			if("Instinctual")
				passives["Flow"] = 1
				passives["Instinct"] = 1
				StrMult = 1.2
				ForMult = 1.2
				EndMult = 1.2
				SpdMult = 0.4
				OffMult = 1.4
		if(p.Potential > OOZARU_POTENTIAL_TRANS)
			passives["Transformation Power"] = p.AscensionsAcquired
		if(length(p.race.transformations) >= 4 && p.race.transformations[4].type == /transformation/saiyan/super_saiyan_4 && p.transUnlocked >= 4)
			IconTransform = 'SSJOozaru.dmi'
			passives["Transformation Power"] = clamp(p.AscensionsAcquired * 5, 1, 40)
			passives["Flow"] = 4
			passives["Instinct"] = 4
			passives["Meaty Paws"] = 2 + (p.AscensionsAcquired /2)
			passives["Juggernaut"] = 1 + (p.AscensionsAcquired / 2)
			passives["BuffMastery"] = 5 + (p.AscensionsAcquired / 10)
			StrMult = 1.5
			ForMult = 1.5
			EndMult = 1.5
			SpdMult = 0.5
			OffMult = 1.5
			TimerLimit = 1200
			VaizardHealth = 1 + (p.AscensionsAcquired/1.5)
			VaizardShatter = 1
			PowerMult = 1.5


	Trigger(var/mob/User, Override=0)
		. = ..()
		if(!User.BuffOn(src))
			if((length(User.race.transformations) >= 4 && User.race.transformations[4].type == /transformation/saiyan/super_saiyan_4 && User.transUnlocked >= 4) && User.CanTransform() && !User.transActive)
				User.transActive = 3
				User.race.transformations[4].transform(User, TRUE)

	verb/Tail_Toggle()
		set category = "Other"
		if(usr.Tail)
			usr.Tail(0)
		else
			usr.Tail(1)

mob/proc/Oozaru(Go_Oozaru=1,var/revert, obj/Skills/Buffs/SlotlessBuffs/Oozaru/Buff)
	if(!src.oozaru_type)
		src.oozaru_type = input(src, "What type of Oozaru are you?") in list("Wrathful", "Enlightened", "Instinctual")
	if(Go_Oozaru)
		if(!src.Tail)return
		if(src.Dead)return
		if(transActive)return
		if(src.CheckActive("Ki Control"))
			for(var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC in src)
				src.UseBuff(KC)
		src.Oozaru=1
		Buff.adjust(src)
		src.PowerControl=100
		Buff.Trigger(src, 1)

		// src.Anger=2

		if(revert)
			spawn(revert)Oozaru(0)
		spawn(rand(0,10)) for(var/mob/P in view(20,src)) P<<sound('Roar.wav', repeat = 0, wait = 0, channel = 0, volume = 50)


	else

		src.Oozaru=0

		for(var/obj/Skills/Buffs/SlotlessBuffs/Oozaru/B in src.SlotlessBuffs)
			if(src.BuffOn(B))
				B.Trigger(src, Override = 1)

obj/Oozaru


mob/proc/Tail(Add_Tail=1)
	if(Add_Tail) Tail(0)
	var/image/T=image(src.TailIcon)
	var/image/T3
	if(src.TailIconUnderlay)
		T3=image(src.TailIconUnderlay)
	var/image/T2=image(src.TailIconWrapped)
	if(Add_Tail)
		overlays-=T
		overlays-=T2
		underlays-=T3
		Tail=1
		overlays+=T
		underlays+=T3
	else
		Tail=0
		overlays-=T
		overlays-=T2
		underlays-=T3
		Oozaru(0)
		overlays+=T2
/mob/proc/triggerOozaru()
	if(isRace(SAIYAN) || isRace(HALFSAIYAN))
		for(var/obj/Skills/Buffs/SlotlessBuffs/Oozaru/B in src)
			if(B.Looking)
				src.Oozaru(1, null, B)


obj/ProjectionMoon
	icon='MoonP.dmi'
	layer=EFFECTS_LAYER
	New()
		spawn() src.Project()
	proc/Project()
		spawn(100)if(src)del(src)
		src.icon_state="Other On"
		animate(src,pixel_z=80,flags=ANIMATION_RELATIVE,time=20)
		sleep(20)
		src.icon_state="On"
		sleep(10)
		view(10,src)<<"<font color=red><small>The moon emits an odd glow.."
		if(src)
			for(var/mob/Players/P in view(10))
				P.triggerOozaru()
				if(locate(/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Full_Moon_Form, P))
					if(!P.CheckSlotless("FullMoonForm"))
						if(P.SpecialBuff)
							P.SpecialBuff.Trigger(P)
						if(P.SlotlessBuffs.len>0)
							for(var/sb in P.SlotlessBuffs)
								var/obj/Skills/Buffs/b = P.SlotlessBuffs[sb]
								if(b)
									b.Trigger(P)
						for(var/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Full_Moon_Form/F)
							F.Trigger(P)



