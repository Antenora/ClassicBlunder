#define OOZARU_POTENTIAL_TRANS 10

/mob/var/oozaru_type = null

/obj/Skills/Buffs/SlotlessBuffs/Oozaru
	var/Looking = 1
	var/Controlled = TRUE // if we ever want 'uncontrolled oozaru'
	BuffName = "Great Ape"
	IconTransform = 'Oozonew.dmi'
	Enlarge = 1.5
	TransformX = -32
	TransformY = -32
	AuraLock = 'BLANK.dmi'
	passives = list("GiantForm" = 1, "NoDodge" = 1, "PureDamage" = 2, "PureReduction" = 2, "SweepingStrike" = 2)
	StrMult = 1.3
	ForMult = 1.2
	SpdMult = 0.3
	EndMult = 1.2
	DefMult = 0.1
	PowerMult=1.5
	HealthThreshold=0.01
	AngerFloor = 90
	TimerLimit = 360
	verb/Ultimate_Form_Toggle()
		set category="Other"
		set hidden = 1
		if(!usr.SSJ4FromBase)
			usr.SSJ4FromBase=1
			usr<<"You can now transform straight into your ultimate forms (God or SSj4) from base, replacing your other Super Saiyan transformations."
		else
			usr.SSJ4FromBase=0
			usr<<"You can no longer transform straight into your ultimate form (God or SSj4) from base."
	verb/Moon_Toggle()
		set category="Other"
		set hidden = 1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		Looking=!Looking
		if(usr.Oozaru)
			if(!Controlled)
				usr<<"You cannot will yourself out of the transformed state!"
				return
			usr.Oozaru = 0
			if(usr.CheckSlotless("Great Ape"))
				Trigger(usr, Override = 1)
		if(usr.CheckSlotless("Great Ape"))
			Trigger(usr, Override = 1)
		usr<< "You will [Looking ? "look" : "not look"] at the moon."

	adjust(mob/p)
		if(!p.oozaru_type)
			p.oozaru_type = input(p, "What type of Oozaru are you?") in list("Wrathful", "Enlightened", "Instinctual")
		passives = list("GiantForm" = 1, "NoDodge" = 1, "PureDamage" = 2, "PureReduction" = 2, "SweepingStrike" = 2)
		switch(p.oozaru_type)
			if("Wrathful")
				passives["Manic"] = 4 - p.AscensionsAcquired
				StrMult = 1.2
				ForMult = 1.15
				EndMult = 1.2
				SpdMult = 0.5
				OffMult = 0.8
			if("Enlightened")
				StrMult = 1.2
				ForMult = 1.2
				EndMult = 1.2
				SpdMult = 0.5
				OffMult = 1.2
				TimerLimit = 720
			if("Instinctual")
				StrMult = 1.2
				ForMult = 1.2
				EndMult = 1.2
				SpdMult = 0.7
				OffMult = 1.4
			if("Demonic")
				if(!altered)
					IconTransform = 'DTRed.dmi'
				TransformX = 0
				TransformY = 0
				StrMult = 1.35
				ForMult = 1.35
				OffMult = 1.5
				if(p.transUnlocked==1)
					TimerLimit = 4800
					if(!altered)
						IconTransform = 'SDTBlue.dmi'
						TopOverlayLock='SDTRedWings.dmi'
						TopOverlayX=-10
						Enlarge=3
					var/SS1pot=40-p.Potential
					if(SS1pot<5)
						SS1pot=5
					passives["Transformation Power"] = SS1pot //MATH COMES LATER
					passives["PureReduction"] = 2 + p.AscensionsAcquired
					passives["PureDamage"] = 1 + p.AscensionsAcquired
					VaizardHealth =25
		if(p.Potential > OOZARU_POTENTIAL_TRANS&&p.oozaru_type!="Demonic")
			passives["Transformation Power"] = p.AscensionsAcquired
		if(length(p.race.transformations) >= 4 && p.race.transformations[4].type == /transformation/saiyan/super_saiyan_4 && p.Potential>=55||length(p.race.transformations) >= 2 && p.race.transformations[2].type == /transformation/saiyan/hellspawn_super_saiyan_2 && p.Potential>=55)
			if(!altered)
				IconTransform = 'SSJOozaru.dmi'
			passives["Transformation Power"] = clamp(p.AscensionsAcquired * 6, 1, 40)
			passives["Juggernaut"] = 1 + (p.AscensionsAcquired / 2)
			passives["DisableGodKi"] = 1
			passives["Unstoppable"] = 1
			passives["PUSpike"] = 50
			passives["KiControl"] = 1
			AngerFloor = 0
			VaizardShatter=0
			StrMult = 1.5
			ForMult = 1.5
			EndMult = 1.5
			SpdMult = 0.9
			OffMult = 1.5
			EnergyHeal = 1
			TimerLimit = 2400
			VaizardHealth = 10 + (p.AscensionsAcquired*5)
			PowerMult = 1.6
			if(p.oozaru_type=="Demonic")
				PowerMult=2.5
				passives["PureReduction"] = 2 + (p.AscensionsAcquired*1.25)
				passives["PureDamage"] = 2 + (p.AscensionsAcquired*1.25)
				SpdMult=1
				TimerLimit = 4800
				if(!altered)
					IconTransform = 'SDTBlue.dmi'
					TopOverlayLock='SDTRedWings.dmi'
					TopOverlayX=-10
					TopOverlayY=-10
					Enlarge=3


	Trigger(var/mob/User, Override=0)
		. = ..()
		if(!User.BuffOn(src))
			if((length(User.race.transformations) >= 4 && User.race.transformations[4].type == /transformation/saiyan/super_saiyan_4 && User.transUnlocked >= 4) && User.CanTransform() && !User.transActive&& User.oozaru_type!="Demonic")
				User.transActive = 3
				User.race.transformations[4].transform(User, TRUE)
		if(!User.BuffOn(src))
			if((length(User.race.transformations) >= 2 && User.race.transformations[2].type == /transformation/saiyan/hellspawn_super_saiyan_2 && User.transUnlocked >= 2) && User.CanTransform() && !User.transActive&& User.oozaru_type=="Demonic")
				User.transActive = 1
				User.race.transformations[2].transform(User, TRUE)

	verb/Tail_Toggle()
		set category = "Other"
		set hidden = 1
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
	/*	if(src.KamuiBuffLock)
			for(var/obj/Skills/Buffs/SlotlessBuffs/Oozaru/B in src.SlotlessBuffs)
				if(!src.BuffOn(B))
					B.Trigger(src, Override = 1)*/

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
					if(P.passive_handler.Get("SunStricken"))
						P << "You are afflicted by The Sun, you cannot shift into your cursed form."
						return
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


obj/ProjectionSun
	icon='SunP.dmi'
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
		view(15,src)<<"<font color=#ffcc00>The sun's rays glow brightly!</font>"
		if(src)
			for(var/mob/Players/P in view(15))
				if(P.passive_handler.Get("Rank-Down Protection") || P.passive_handler.Get("Heavensent") || P.isRace(ANGEL))
					var/obj/Skills/Buffs/SlotlessBuffs/Sun_Seared/applyBuff1 = new
					applyBuff1.Trigger(P, 1)
					P.AddBurn(100)
				else if(P.IsEvil() || P.isRace(MAKAIOSHIN) || P.isRace(ELDRITCH) || P.Secret=="Vampire" || P.Secret=="Werewolf" || P.Secret=="Eldritch")
					var/obj/Skills/Buffs/SlotlessBuffs/Sun_Stricken/applyBuff2 = new
					applyBuff2.Trigger(P, 1)
					P.AddBurn(50)
					if(P.Secret=="Vampire")
						for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Vampire/Rotshreck/v in src)
							if(!P.BuffOn(v))
								v.adjust(P, 1)
						var/bloodPower = P.secretDatum.currentTier
						P.BPPoison=min(0.2*bloodPower,0.9)
						P.BPPoisonTimer=RawHours(6)/bloodPower
						P << "<font color=#ffcc00>You have been burned by the light of The Sun!</font>"
				else
					var/obj/Skills/Buffs/SlotlessBuffs/Sun_Blessed/applyBuff3 = new
					applyBuff3.Trigger(P, 1)
					if(P.Secret=="Hamon")
						if(P.RippleActive()&&!P.PoseEnhancement)
							P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Ripple_Enhancement)

obj/Skills/Buffs/SlotlessBuffs/Sun_Seared
	KenWave = 4
	KenWaveIcon='KenShockwaveGold.dmi'
	IconLock='FlameGlowHades.dmi'
	LockX=-16
	LockY=-4
	TimerLimit=60
	ActiveMessage="becomes fully mortal beneath the light of The Sun!"
	OffMessage="ascends once again into a divine being."
	TextColor="#ffcc00"
	MagicNeeded=0
	Cooldown=120
	adjust(mob/p)
		passives = list("DisableGodKi" = 1, "Silenced" = 1)

obj/Skills/Buffs/SlotlessBuffs/Sun_Stricken
	KenWave = 4
	KenWaveIcon='KenShockwaveGold.dmi'
	IconLock='FlameGlowHerc.dmi'
	LockX=-16
	LockY=-4
	TimerLimit=60
	ActiveMessage="experiences freedom from their curses beneath the light of The Sun!"
	OffMessage="descends back into their cursed existence."
	TextColor="#ffcc00"
	MagicNeeded=0
	Cooldown=120
	adjust(mob/p)
		passives = list("SunStricken" = 1)

obj/Skills/Buffs/SlotlessBuffs/Sun_Blessed
	KenWave = 4
	KenWaveIcon='KenShockwaveGold.dmi'
	HitSpark='Star.dmi'
	IconLock='FlameGlowZeus.dmi'
	LockX=-16
	LockY=-4
	TimerLimit=60
	ActiveMessage="shatters the chains of oppression, basking in the light of The Sun!"
	OffMessage="carries on with the truth of the light in their heart."
	TextColor="#ffcc00"
	MagicNeeded=0
	Cooldown=120
	adjust(mob/p)
		passives = list("LifeGeneration" = 3, "EnergyGeneration" = 3, "Antsy" = 10, "Conductor" = 20)
