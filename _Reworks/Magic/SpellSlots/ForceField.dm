globalTracker/var/FORCEFIELD_RANGE = 0
globalTracker/var/FORCEFIELD_TIME = 10

mob/proc/applyForceField(mob/source)
	if(SlotlessBuffs["ForceFielded"]) return
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/ForceFielded/s = findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/ForceFielded)
	s.passives = list("ForceFielded" = source.ckey)
	s.TimerLimit = glob.FORCEFIELD_TIME
	if(!BuffOn(s))
		s.Trigger(src, TRUE)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/
	ForceFielded
		passives = list("ForceFielded" = 1)
		TimerLimit = 10
		IconLock='Bleed.dmi'
		AlwaysOn = 0
		NeedsPassword = 0