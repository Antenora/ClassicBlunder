globalTracker/var/COOLDOWNDRAG_CAP = 50
globalTracker/var/COOLDOWNDRAG_MULT = 1

mob/var/tmp/CooldownDrag=0

mob/proc/addCooldownDrag(amt, mob/source)
	if(!amt) return

	amt *= glob.COOLDOWNDRAG_MULT
	CooldownDrag = clamp(CooldownDrag + amt, 0, glob.COOLDOWNDRAG_CAP)