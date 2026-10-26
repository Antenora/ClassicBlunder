globalTracker/var
	BLEED_RESIST_EPT = 0.2
	BLEED_RESIST_MIN = -5
	BLEED_RESIST_MAX = 5

passiveInfo/BleedResist
	setLines()
		lines = list("Modifies the amount of Bleed debuff you take. Positive numbers mean taking less Bleed, and negative numbers mean taking more Bleed.",\
"Each tick of the passive is worth [glob.outputVariableInfo("BLEED_RESIST_EPT")]% modification of your Bleed debuff taken.",\
"Minimum number of ticks: [glob.outputVariableInfo("BLEED_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("BLEED_RESIST_MAX")]")

#define FULL_BLEED_AMT 1

mob/getBleedResistValue()
	. = FULL_BLEED_AMT
	. -= (getBleedResist() * glob.BLEED_RESIST_EPT)
	. = clamp(., getMaxBleedResistValue(), getMinBleedResistValue())

mob/proc/getBleedResist()
	. = 0
	. += passive_handler.Get("BleedResist")
	. = clamp(., glob.BLEED_RESIST_MIN, glob.BLEED_RESIST_MAX)

mob/proc/getMinBleedResistValue()
	. = FULL_BLEED_AMT - (glob.BLEED_RESIST_MIN * glob.BLEED_RESIST_EPT)

mob/proc/getMaxBleedResistValue()
	. = FULL_BLEED_AMT - (glob.BLEED_RESIST_MAX * glob.BLEED_RESIST_EPT)
