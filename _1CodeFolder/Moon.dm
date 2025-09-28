var/global/celestialObjectTicks = Hour(12)/10
var
	MoonMessage="The lone local holmin moon shines brightly!"
	MakyoMessage="A cursed star shines in the sky"
	MoonSetMessage="The lone local moon sets!"
	MakyoSetMessage="A cursed star disappears from the sky"

proc/CelestialBodiesLoop()
	set waitfor = 0
	while(1)
		celestialObjectTicks--
		if(celestialObjectTicks==0)
			CallMoon()
			CallStar()
			celestialObjectTicks = Hour(12)/10
		sleep(10)

mob
	proc
		MoonWarning()
			if(src.Secret=="Werewolf")
				src << "You feel the moon begin to rise... "
			if(src.Tail&&(src.isRace(SAIYAN)||src.isRace(HALFSAIYAN)))
				src << "You feel the moon begin to rise... "
			if(src.AdvancedTransmissionTechnologyUnlocked>0)
				src << "Your observation devices are warning you about full moon... "
		MoonTrigger()
			triggerOozaru()
			if(locate(/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Full_Moon_Form, src))
				if(!src.CheckSlotless("FullMoonForm"))
					if(src.SpecialBuff)
						src.SpecialBuff.Trigger(src)
					if(src.SlotlessBuffs.len>0)
						for(var/obj/Skills/Buffs/b in src.SlotlessBuffs)
							b.Trigger(src)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Full_Moon_Form/F in src)
						F.Trigger(src)
			src<<"<font color=yellow>[global.MoonMessage]</font color>"
		MoonSetTrigger()
			for(var/obj/Oozaru/O in src)
				if(O.icon)
					src.Oozaru(0)
			if(locate(/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Full_Moon_Form, src))
				if(src.CheckSlotless("FullMoonForm"))
					for(var/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Full_Moon_Form/F in src)
						F.Trigger(src)
			src<<"<font color=yellow>[global.MoonSetMessage]</font color>"
		MakyoWarning()
			if(src.isRace(MAKYO))
				src << "You feel your blood boiling in anticipation... "
			if(src.AdvancedTransmissionTechnologyUnlocked>0)
				src << "Your observation devices are warning you about an unusual celestial object... "
		MakyoTrigger()
			if(src.isRace(MAKYO) && race?:accepting_boons)
				if(src.PotentialRate<2)
					src.PotentialRate+=0.25
					if(src.PotentialRate>2)
						src.PotentialRate=2
				src.StarPowered=1
				for(var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC in src)
					if(!src.BuffOn(KC))
						src.PowerControl=150
						src.PoweringUp=0
						src.Auraz("Remove")
						src.UseBuff(KC)
			src<<"<font color=red>[global.MakyoMessage]</font color>"

		MakyoFade()
			if(isRace(MAKYO))
				src.StarPowered=0
				for(var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC in src)
					if(src.BuffOn(KC))
						src.UseBuff(KC, TRUE)
			src<<"<font color=red>The hanging star slowly drifts out of view...</font color>"

		MakyoSetTrigger()
			if(src.isRace(MAKYO))
				for(var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC in src)
					if(src.BuffOn(KC))
						src.UseBuff(KC)
			src<<"<font color=red>[global.MakyoSetMessage]</font color>"

proc/CallMoon(var/OnlyZ=null)
	set waitfor=0
	set background=1
	for(var/mob/Players/P in players)
		if(OnlyZ)
			if(P.z==OnlyZ)
				P.MoonWarning()
		else
			P.MoonWarning()
	sleep(Minute(2))
	for(var/mob/Players/P in players)
		if(OnlyZ)
			if(P.z==OnlyZ)
				P.MoonTrigger()
		else
			P.MoonTrigger()


var/starActive = FALSE
proc/CallStar(var/OnlyZ=null)
	set waitfor=0
	set background=1
	for(var/mob/Players/P in players)
		if(OnlyZ)
			if(P.z==OnlyZ)
				P.MakyoWarning()
		else
			P.MakyoWarning()
	sleep(Minute(2))
	starActive = TRUE
	for(var/mob/Players/P in players)
		if(OnlyZ)
			if(P.z==OnlyZ)
				P.MakyoTrigger()
		else
			P.MakyoTrigger()
	sleep(glob.racials.MAKYO_TOTAL_TIME)
	starActive = FALSE
	for(var/mob/Players/P in players)
		if(OnlyZ)
			if(P.z==OnlyZ)
				P.MakyoFade()
		else
			P.MakyoFade()