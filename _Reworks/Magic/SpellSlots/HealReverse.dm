globalTracker/var/INVERSE_HEALING_TIMER = 10

mob/proc/applyHealReverse()
	if(SlotlessBuffs["InverseHealing"]) return
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/InverseHealing/s = findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/InverseHealing)
	s.TimerLimit = glob.INVERSE_HEALING_TIMER
	if(!BuffOn(s))
		s.Trigger(src, TRUE)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/
	InverseHealing
		passives = list("InverseHealing" = 1)
		TimerLimit = 10
		IconLock='Bleed.dmi'
		AlwaysOn = 0
		NeedsPassword = 0