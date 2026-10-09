proc/EnergyFXBurstColors(datum/energyfx_row/row, list/colors)
	if(istype(colors, /datum/energyfx_colors)) return colors
	var/main = (colors && colors.len >= 1) ? colors[1] : null
	var/core = (colors && colors.len >= 2) ? colors[2] : null
	var/glow = (colors && colors.len >= 3) ? colors[3] : null
	return EnergyFXResolveColors(main, core, glow, row ? row.def_main : null, row ? row.def_core : null, row ? row.def_glow : null)

proc/EnergyFXBurst(turf/T, radius, datum/energyfx_row/row, colors)
	if(!T || !glob || !glob.ENERGYFX) return 0
	if(ispath(row)) row = EnergyFXRowOf(row)
	if(istype(row, /obj/Skills)) row = EnergyFXRow(row)
	var/datum/energyfx_colors/C = EnergyFXBurstColors(row, colors)
	if(!C) return 0
	if(radius >= 2 && energyfx_burst_look) return energyfx_burst_look.Burst(T, radius, row, C)
	if(radius < 2 && energyfx_small_burst_look) return energyfx_small_burst_look.Burst(T, radius, row, C)
	return 0

var/datum/energyfx_look/energyfx_small_burst_look
