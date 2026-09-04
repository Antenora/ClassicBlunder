var/list/ELEMENT_LIST = list("Fire", "Water", "Ice", "Wind", "Lightning", "Earth", "Light", "Dark", "Space", "Time")
var/list/ELEMENT_PHYSICAL = list("Fire", "Water", "Ice", "Wind", "Lightning", "Earth")
var/list/ELEMENT_ADVANCED = list("Light", "Dark", "Space", "Time")
var/list/ELEMENT_NEUTRAL = list("Space", "Time")
var/list/ELEMENT_STATUS_CARRIERS = list("Poison", "Blade")
var/list/ELEMENT_STRONG = list(\
	"Fire" = list("Ice", "Earth"),\
	"Water" = list("Fire", "Earth"),\
	"Ice" = list("Water", "Wind"),\
	"Wind" = list("Fire", "Lightning"),\
	"Lightning" = list("Water", "Ice"),\
	"Earth" = list("Wind", "Lightning"),\
	"Light" = list("Dark"),\
	"Dark" = list("Light"),\
	"Space" = list(),\
	"Time" = list())
var/list/ELEMENT_POOL = list("Fire" = "Burn", "Water" = "Drenched", "Ice" = "Slow", "Wind" = "Exposed", "Lightning" = "Shock", "Earth" = "Shatter", "Light" = "Judged", "Dark" = "Doomed")

globalTracker/var
	ELEMENT_MATCHUP_MOD = 0.75
	ELEMENT_PROC_BASE = 30
	ELEMENT_PROC_ADVANCED = 20
	ELEMENT_PROC_EDGE = 20
	ELEMENT_PROC_SAME = -10
	DRENCHED_INTENSITY = 1
	EXPOSED_INTENSITY = 1
	DOOM_INTENSITY = 0.5
	DRENCHED_AMP = 1
	DRENCHED_DOUSE = 1
	SHOCK_PARALYSIS = 2
	SHOCK_PARALYSIS_AT = 90
	SHOCK_PARALYSIS_RESET = 50

proc
	IsChartElement(e)
		return (e in ELEMENT_LIST)
	ElementStrongVs(a, d)
		if(!(a in ELEMENT_STRONG)) return 0
		return (d in ELEMENT_STRONG[a])
	ElementMatchupMod(a, list/defense)
		. = 0
		if(!IsChartElement(a) || !defense) return
		for(var/d in defense)
			if(!IsChartElement(d)) continue
			if(ElementStrongVs(a, d)) . += glob.ELEMENT_MATCHUP_MOD
			else if(ElementStrongVs(d, a)) . -= glob.ELEMENT_MATCHUP_MOD
	ElementProcRate(a, list/defense)
		if(a in ELEMENT_STATUS_CARRIERS) return glob.ELEMENT_PROC_BASE
		if(!IsChartElement(a)) return 0
		if(a in ELEMENT_NEUTRAL) return 0
		. = (a in ELEMENT_ADVANCED) ? glob.ELEMENT_PROC_ADVANCED : glob.ELEMENT_PROC_BASE
		if(!defense) return
		for(var/d in defense)
			if(!IsChartElement(d)) continue
			if(d == a) . += glob.ELEMENT_PROC_SAME
			if(ElementStrongVs(a, d)) . += glob.ELEMENT_PROC_EDGE
			else if(ElementStrongVs(d, a)) . -= glob.ELEMENT_PROC_EDGE
	FirstChartElement(v)
		if(!v) return null
		if(islist(v))
			for(var/e in v)
				if(IsChartElement(e)) return e
			return null
		return IsChartElement(v) ? v : null

mob/proc
	AttunementAtkMult(element, mob/attacker)
		if(attacker && attacker != src && attacker.Attunement == element) return 1.5
		return 1
	AttunementDefMult(element)
		if(!src.Attunement || !IsChartElement(src.Attunement)) return 1
		if(src.Attunement == element) return 0.5
		if(ElementStrongVs(element, src.Attunement)) return 1.5
		if(ElementStrongVs(src.Attunement, element)) return 0.5
		return 1
	AttunementMult(element, mob/attacker)
		return AttunementAtkMult(element, attacker) * AttunementDefMult(element)
	InfuseElement(element)
		if(!src.Infusion) return 1
		if(!src.InfusionElement) src.InfusionElement = element
		return 0.5
	getElementResistValue(element)
		switch(element)
			if("Fire") return getFireResistValue()
			if("Water") return getWaterResistValue()
			if("Ice") return getIceResistValue()
			if("Wind") return getWindResistValue()
			if("Lightning") return getLightningResistValue()
			if("Earth") return getEarthResistValue()
		return 1
	getElementResistFor(spellElement, elementalClass)
		var/e = FirstChartElement(spellElement)
		if(!e) e = FirstChartElement(elementalClass)
		if(!e) return 1
		return getElementResistValue(e)
