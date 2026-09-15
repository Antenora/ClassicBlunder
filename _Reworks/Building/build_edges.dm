turf/var/tmp/list/edgeOverlays
turf/var/EdgeOptOut = 0

var/global/list/buildMaterialPriority = list("Grass" = 20, "Dirt" = 30, "Sand" = 40, "Ice" = 60, "Wood" = 70, "Stone" = 80, "Water" = 100)
var/global/list/buildMaterialNames = list("Grass", "Dirt", "Sand", "Water", "Stone", "Wood", "Ice")

var/global/list/buildMaterialTypeOverride

/proc/BuildMaterialTypeInit()
	if(buildMaterialTypeOverride)
		return
	buildMaterialTypeOverride = list()
	buildMaterialTypeOverride[/turf/IconsX/Icon9] = "Grass"
	buildMaterialTypeOverride[/turf/IconsX/Icon27] = "Grass"
	buildMaterialTypeOverride[/turf/IconsX/Icon52] = "Grass"
	buildMaterialTypeOverride[/turf/IconsX/Icon57] = "Grass"
	buildMaterialTypeOverride[/turf/IconsX/Icon5] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon6] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon7] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon10] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon11] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon12] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon55] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon56] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon58] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc3] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc4] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc5] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc6] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc7] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc8] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc9] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc10] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc11] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc12] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc13] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc14] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc15] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc16] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc17] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc18] = "Dirt"
	buildMaterialTypeOverride[/turf/Waters/WaterU1] = "none"
	buildMaterialTypeOverride[/turf/Waters/WaterU2] = "none"
	buildMaterialTypeOverride[/turf/Waters/WaterU3] = "none"

var/global/list/buildMaterialByType = list()

/proc/BuildMaterialFor(turf/T)
	if(!T)
		return null
	if(!buildMaterialTypeOverride)
		BuildMaterialTypeInit()
	var/ov = buildMaterialTypeOverride[T.type]
	if(ov)
		return (ov == "none") ? null : ov
	if(istype(T, /turf/Waters) || istype(T, /turf/Waterfall))
		return "Water"
	if(istype(T, /turf/CustomTurf))
		return BuildCustomMaterial(T.icon, T.icon_state)
	var/st = T.SecondaryTurfType
	if(st && (st in buildMaterialNames))
		return st
	var/pt = "[T.type]"
	var/memo = buildMaterialByType[pt]
	if(memo)
		return (memo == "none") ? null : memo
	for(var/nm2 in buildMaterialNames)
		if(findtext(pt, "/[nm2]"))
			buildMaterialByType[pt] = nm2
			return nm2
	buildMaterialByType[pt] = "none"
	return null

/proc/BuildMaterialForType(p)
	if(!p)
		return null
	BuildMaterialTypeInit()
	var/ov = buildMaterialTypeOverride[p]
	if(ov)
		return (ov == "none") ? null : ov
	if(ispath(p, /turf/Waters) || ispath(p, /turf/Waterfall))
		return "Water"
	var/pt = "[p]"
	for(var/nm2 in buildMaterialNames)
		if(findtext(pt, "/[nm2]"))
			return nm2
	return null

/proc/BuildMaterialPriority(id)
	if(!id)
		return 0
	var/p = buildMaterialPriority[id]
	if(p)
		return p
	return 50

/proc/BuildEdgeCutMask(corner)
	switch(corner)
		if("nw")
			return 'Mapping/EdgeMasks/cut_nw.png'
		if("ne")
			return 'Mapping/EdgeMasks/cut_ne.png'
		if("sw")
			return 'Mapping/EdgeMasks/cut_sw.png'
	return 'Mapping/EdgeMasks/cut_se.png'

/proc/BuildEdgeCutMask32(corner)
	if(corner == "nw")
		return 'Mapping/EdgeMasks/cut32_nw.png'
	return 'Mapping/EdgeMasks/cut32_ne.png'

var/global/list/buildEdgeStyles = list("Grass" = "wispy", "Dirt" = "crumbly", "Sand" = "soft", "Ice" = "soft", "Stone" = "jagged", "Wood" = "hard", "Water" = "crisp")
var/global/list/buildEdgeMaskCache = list()

/proc/BuildEdgeStyleFor(id)
	if(!id)
		return "wispy"
	var/s = buildEdgeStyles[id]
	if(s)
		return s
	return "wispy"

var/global/list/buildEdgeMaskLits

/proc/BuildEdgeMaskInit()
	if(buildEdgeMaskLits)
		return
	buildEdgeMaskLits = list()
	buildEdgeMaskLits["f_wispy_n"] = 'Mapping/EdgeMasks/f_wispy_n.png'
	buildEdgeMaskLits["f_wispy_s"] = 'Mapping/EdgeMasks/f_wispy_s.png'
	buildEdgeMaskLits["f_wispy_ns"] = 'Mapping/EdgeMasks/f_wispy_ns.png'
	buildEdgeMaskLits["f_wispy_e"] = 'Mapping/EdgeMasks/f_wispy_e.png'
	buildEdgeMaskLits["f_wispy_ne"] = 'Mapping/EdgeMasks/f_wispy_ne.png'
	buildEdgeMaskLits["f_wispy_se"] = 'Mapping/EdgeMasks/f_wispy_se.png'
	buildEdgeMaskLits["f_wispy_nse"] = 'Mapping/EdgeMasks/f_wispy_nse.png'
	buildEdgeMaskLits["f_wispy_w"] = 'Mapping/EdgeMasks/f_wispy_w.png'
	buildEdgeMaskLits["f_wispy_nw"] = 'Mapping/EdgeMasks/f_wispy_nw.png'
	buildEdgeMaskLits["f_wispy_sw"] = 'Mapping/EdgeMasks/f_wispy_sw.png'
	buildEdgeMaskLits["f_wispy_nsw"] = 'Mapping/EdgeMasks/f_wispy_nsw.png'
	buildEdgeMaskLits["f_wispy_ew"] = 'Mapping/EdgeMasks/f_wispy_ew.png'
	buildEdgeMaskLits["f_wispy_new"] = 'Mapping/EdgeMasks/f_wispy_new.png'
	buildEdgeMaskLits["f_wispy_sew"] = 'Mapping/EdgeMasks/f_wispy_sew.png'
	buildEdgeMaskLits["f_wispy_nsew"] = 'Mapping/EdgeMasks/f_wispy_nsew.png'
	buildEdgeMaskLits["f_crumbly_n"] = 'Mapping/EdgeMasks/f_crumbly_n.png'
	buildEdgeMaskLits["f_crumbly_s"] = 'Mapping/EdgeMasks/f_crumbly_s.png'
	buildEdgeMaskLits["f_crumbly_ns"] = 'Mapping/EdgeMasks/f_crumbly_ns.png'
	buildEdgeMaskLits["f_crumbly_e"] = 'Mapping/EdgeMasks/f_crumbly_e.png'
	buildEdgeMaskLits["f_crumbly_ne"] = 'Mapping/EdgeMasks/f_crumbly_ne.png'
	buildEdgeMaskLits["f_crumbly_se"] = 'Mapping/EdgeMasks/f_crumbly_se.png'
	buildEdgeMaskLits["f_crumbly_nse"] = 'Mapping/EdgeMasks/f_crumbly_nse.png'
	buildEdgeMaskLits["f_crumbly_w"] = 'Mapping/EdgeMasks/f_crumbly_w.png'
	buildEdgeMaskLits["f_crumbly_nw"] = 'Mapping/EdgeMasks/f_crumbly_nw.png'
	buildEdgeMaskLits["f_crumbly_sw"] = 'Mapping/EdgeMasks/f_crumbly_sw.png'
	buildEdgeMaskLits["f_crumbly_nsw"] = 'Mapping/EdgeMasks/f_crumbly_nsw.png'
	buildEdgeMaskLits["f_crumbly_ew"] = 'Mapping/EdgeMasks/f_crumbly_ew.png'
	buildEdgeMaskLits["f_crumbly_new"] = 'Mapping/EdgeMasks/f_crumbly_new.png'
	buildEdgeMaskLits["f_crumbly_sew"] = 'Mapping/EdgeMasks/f_crumbly_sew.png'
	buildEdgeMaskLits["f_crumbly_nsew"] = 'Mapping/EdgeMasks/f_crumbly_nsew.png'
	buildEdgeMaskLits["f_soft_n"] = 'Mapping/EdgeMasks/f_soft_n.png'
	buildEdgeMaskLits["f_soft_s"] = 'Mapping/EdgeMasks/f_soft_s.png'
	buildEdgeMaskLits["f_soft_ns"] = 'Mapping/EdgeMasks/f_soft_ns.png'
	buildEdgeMaskLits["f_soft_e"] = 'Mapping/EdgeMasks/f_soft_e.png'
	buildEdgeMaskLits["f_soft_ne"] = 'Mapping/EdgeMasks/f_soft_ne.png'
	buildEdgeMaskLits["f_soft_se"] = 'Mapping/EdgeMasks/f_soft_se.png'
	buildEdgeMaskLits["f_soft_nse"] = 'Mapping/EdgeMasks/f_soft_nse.png'
	buildEdgeMaskLits["f_soft_w"] = 'Mapping/EdgeMasks/f_soft_w.png'
	buildEdgeMaskLits["f_soft_nw"] = 'Mapping/EdgeMasks/f_soft_nw.png'
	buildEdgeMaskLits["f_soft_sw"] = 'Mapping/EdgeMasks/f_soft_sw.png'
	buildEdgeMaskLits["f_soft_nsw"] = 'Mapping/EdgeMasks/f_soft_nsw.png'
	buildEdgeMaskLits["f_soft_ew"] = 'Mapping/EdgeMasks/f_soft_ew.png'
	buildEdgeMaskLits["f_soft_new"] = 'Mapping/EdgeMasks/f_soft_new.png'
	buildEdgeMaskLits["f_soft_sew"] = 'Mapping/EdgeMasks/f_soft_sew.png'
	buildEdgeMaskLits["f_soft_nsew"] = 'Mapping/EdgeMasks/f_soft_nsew.png'
	buildEdgeMaskLits["f_jagged_n"] = 'Mapping/EdgeMasks/f_jagged_n.png'
	buildEdgeMaskLits["f_jagged_s"] = 'Mapping/EdgeMasks/f_jagged_s.png'
	buildEdgeMaskLits["f_jagged_ns"] = 'Mapping/EdgeMasks/f_jagged_ns.png'
	buildEdgeMaskLits["f_jagged_e"] = 'Mapping/EdgeMasks/f_jagged_e.png'
	buildEdgeMaskLits["f_jagged_ne"] = 'Mapping/EdgeMasks/f_jagged_ne.png'
	buildEdgeMaskLits["f_jagged_se"] = 'Mapping/EdgeMasks/f_jagged_se.png'
	buildEdgeMaskLits["f_jagged_nse"] = 'Mapping/EdgeMasks/f_jagged_nse.png'
	buildEdgeMaskLits["f_jagged_w"] = 'Mapping/EdgeMasks/f_jagged_w.png'
	buildEdgeMaskLits["f_jagged_nw"] = 'Mapping/EdgeMasks/f_jagged_nw.png'
	buildEdgeMaskLits["f_jagged_sw"] = 'Mapping/EdgeMasks/f_jagged_sw.png'
	buildEdgeMaskLits["f_jagged_nsw"] = 'Mapping/EdgeMasks/f_jagged_nsw.png'
	buildEdgeMaskLits["f_jagged_ew"] = 'Mapping/EdgeMasks/f_jagged_ew.png'
	buildEdgeMaskLits["f_jagged_new"] = 'Mapping/EdgeMasks/f_jagged_new.png'
	buildEdgeMaskLits["f_jagged_sew"] = 'Mapping/EdgeMasks/f_jagged_sew.png'
	buildEdgeMaskLits["f_jagged_nsew"] = 'Mapping/EdgeMasks/f_jagged_nsew.png'
	buildEdgeMaskLits["f_hard_n"] = 'Mapping/EdgeMasks/f_hard_n.png'
	buildEdgeMaskLits["f_hard_s"] = 'Mapping/EdgeMasks/f_hard_s.png'
	buildEdgeMaskLits["f_hard_ns"] = 'Mapping/EdgeMasks/f_hard_ns.png'
	buildEdgeMaskLits["f_hard_e"] = 'Mapping/EdgeMasks/f_hard_e.png'
	buildEdgeMaskLits["f_hard_ne"] = 'Mapping/EdgeMasks/f_hard_ne.png'
	buildEdgeMaskLits["f_hard_se"] = 'Mapping/EdgeMasks/f_hard_se.png'
	buildEdgeMaskLits["f_hard_nse"] = 'Mapping/EdgeMasks/f_hard_nse.png'
	buildEdgeMaskLits["f_hard_w"] = 'Mapping/EdgeMasks/f_hard_w.png'
	buildEdgeMaskLits["f_hard_nw"] = 'Mapping/EdgeMasks/f_hard_nw.png'
	buildEdgeMaskLits["f_hard_sw"] = 'Mapping/EdgeMasks/f_hard_sw.png'
	buildEdgeMaskLits["f_hard_nsw"] = 'Mapping/EdgeMasks/f_hard_nsw.png'
	buildEdgeMaskLits["f_hard_ew"] = 'Mapping/EdgeMasks/f_hard_ew.png'
	buildEdgeMaskLits["f_hard_new"] = 'Mapping/EdgeMasks/f_hard_new.png'
	buildEdgeMaskLits["f_hard_sew"] = 'Mapping/EdgeMasks/f_hard_sew.png'
	buildEdgeMaskLits["f_hard_nsew"] = 'Mapping/EdgeMasks/f_hard_nsew.png'
	buildEdgeMaskLits["fw_wispy_n"] = 'Mapping/EdgeMasks/fw_wispy_n.png'
	buildEdgeMaskLits["fw_wispy_s"] = 'Mapping/EdgeMasks/fw_wispy_s.png'
	buildEdgeMaskLits["fw_wispy_ns"] = 'Mapping/EdgeMasks/fw_wispy_ns.png'
	buildEdgeMaskLits["fw_wispy_e"] = 'Mapping/EdgeMasks/fw_wispy_e.png'
	buildEdgeMaskLits["fw_wispy_ne"] = 'Mapping/EdgeMasks/fw_wispy_ne.png'
	buildEdgeMaskLits["fw_wispy_se"] = 'Mapping/EdgeMasks/fw_wispy_se.png'
	buildEdgeMaskLits["fw_wispy_nse"] = 'Mapping/EdgeMasks/fw_wispy_nse.png'
	buildEdgeMaskLits["fw_wispy_w"] = 'Mapping/EdgeMasks/fw_wispy_w.png'
	buildEdgeMaskLits["fw_wispy_nw"] = 'Mapping/EdgeMasks/fw_wispy_nw.png'
	buildEdgeMaskLits["fw_wispy_sw"] = 'Mapping/EdgeMasks/fw_wispy_sw.png'
	buildEdgeMaskLits["fw_wispy_nsw"] = 'Mapping/EdgeMasks/fw_wispy_nsw.png'
	buildEdgeMaskLits["fw_wispy_ew"] = 'Mapping/EdgeMasks/fw_wispy_ew.png'
	buildEdgeMaskLits["fw_wispy_new"] = 'Mapping/EdgeMasks/fw_wispy_new.png'
	buildEdgeMaskLits["fw_wispy_sew"] = 'Mapping/EdgeMasks/fw_wispy_sew.png'
	buildEdgeMaskLits["fw_wispy_nsew"] = 'Mapping/EdgeMasks/fw_wispy_nsew.png'
	buildEdgeMaskLits["fw_crumbly_n"] = 'Mapping/EdgeMasks/fw_crumbly_n.png'
	buildEdgeMaskLits["fw_crumbly_s"] = 'Mapping/EdgeMasks/fw_crumbly_s.png'
	buildEdgeMaskLits["fw_crumbly_ns"] = 'Mapping/EdgeMasks/fw_crumbly_ns.png'
	buildEdgeMaskLits["fw_crumbly_e"] = 'Mapping/EdgeMasks/fw_crumbly_e.png'
	buildEdgeMaskLits["fw_crumbly_ne"] = 'Mapping/EdgeMasks/fw_crumbly_ne.png'
	buildEdgeMaskLits["fw_crumbly_se"] = 'Mapping/EdgeMasks/fw_crumbly_se.png'
	buildEdgeMaskLits["fw_crumbly_nse"] = 'Mapping/EdgeMasks/fw_crumbly_nse.png'
	buildEdgeMaskLits["fw_crumbly_w"] = 'Mapping/EdgeMasks/fw_crumbly_w.png'
	buildEdgeMaskLits["fw_crumbly_nw"] = 'Mapping/EdgeMasks/fw_crumbly_nw.png'
	buildEdgeMaskLits["fw_crumbly_sw"] = 'Mapping/EdgeMasks/fw_crumbly_sw.png'
	buildEdgeMaskLits["fw_crumbly_nsw"] = 'Mapping/EdgeMasks/fw_crumbly_nsw.png'
	buildEdgeMaskLits["fw_crumbly_ew"] = 'Mapping/EdgeMasks/fw_crumbly_ew.png'
	buildEdgeMaskLits["fw_crumbly_new"] = 'Mapping/EdgeMasks/fw_crumbly_new.png'
	buildEdgeMaskLits["fw_crumbly_sew"] = 'Mapping/EdgeMasks/fw_crumbly_sew.png'
	buildEdgeMaskLits["fw_crumbly_nsew"] = 'Mapping/EdgeMasks/fw_crumbly_nsew.png'
	buildEdgeMaskLits["af_wispy_nw"] = 'Mapping/EdgeMasks/af_wispy_nw.png'
	buildEdgeMaskLits["af_wispy_ne"] = 'Mapping/EdgeMasks/af_wispy_ne.png'
	buildEdgeMaskLits["af_wispy_sw"] = 'Mapping/EdgeMasks/af_wispy_sw.png'
	buildEdgeMaskLits["af_wispy_se"] = 'Mapping/EdgeMasks/af_wispy_se.png'
	buildEdgeMaskLits["af_crumbly_nw"] = 'Mapping/EdgeMasks/af_crumbly_nw.png'
	buildEdgeMaskLits["af_crumbly_ne"] = 'Mapping/EdgeMasks/af_crumbly_ne.png'
	buildEdgeMaskLits["af_crumbly_sw"] = 'Mapping/EdgeMasks/af_crumbly_sw.png'
	buildEdgeMaskLits["af_crumbly_se"] = 'Mapping/EdgeMasks/af_crumbly_se.png'
	buildEdgeMaskLits["af_soft_nw"] = 'Mapping/EdgeMasks/af_soft_nw.png'
	buildEdgeMaskLits["af_soft_ne"] = 'Mapping/EdgeMasks/af_soft_ne.png'
	buildEdgeMaskLits["af_soft_sw"] = 'Mapping/EdgeMasks/af_soft_sw.png'
	buildEdgeMaskLits["af_soft_se"] = 'Mapping/EdgeMasks/af_soft_se.png'
	buildEdgeMaskLits["af_jagged_nw"] = 'Mapping/EdgeMasks/af_jagged_nw.png'
	buildEdgeMaskLits["af_jagged_ne"] = 'Mapping/EdgeMasks/af_jagged_ne.png'
	buildEdgeMaskLits["af_jagged_sw"] = 'Mapping/EdgeMasks/af_jagged_sw.png'
	buildEdgeMaskLits["af_jagged_se"] = 'Mapping/EdgeMasks/af_jagged_se.png'
	buildEdgeMaskLits["af_hard_nw"] = 'Mapping/EdgeMasks/af_hard_nw.png'
	buildEdgeMaskLits["af_hard_ne"] = 'Mapping/EdgeMasks/af_hard_ne.png'
	buildEdgeMaskLits["af_hard_sw"] = 'Mapping/EdgeMasks/af_hard_sw.png'
	buildEdgeMaskLits["af_hard_se"] = 'Mapping/EdgeMasks/af_hard_se.png'
	buildEdgeMaskLits["afw_wispy_nw"] = 'Mapping/EdgeMasks/afw_wispy_nw.png'
	buildEdgeMaskLits["afw_wispy_ne"] = 'Mapping/EdgeMasks/afw_wispy_ne.png'
	buildEdgeMaskLits["afw_wispy_sw"] = 'Mapping/EdgeMasks/afw_wispy_sw.png'
	buildEdgeMaskLits["afw_wispy_se"] = 'Mapping/EdgeMasks/afw_wispy_se.png'
	buildEdgeMaskLits["afw_crumbly_nw"] = 'Mapping/EdgeMasks/afw_crumbly_nw.png'
	buildEdgeMaskLits["afw_crumbly_ne"] = 'Mapping/EdgeMasks/afw_crumbly_ne.png'
	buildEdgeMaskLits["afw_crumbly_sw"] = 'Mapping/EdgeMasks/afw_crumbly_sw.png'
	buildEdgeMaskLits["afw_crumbly_se"] = 'Mapping/EdgeMasks/afw_crumbly_se.png'
	buildEdgeMaskLits["af32_wispy_nw"] = 'Mapping/EdgeMasks/af32_wispy_nw.png'
	buildEdgeMaskLits["af32_wispy_ne"] = 'Mapping/EdgeMasks/af32_wispy_ne.png'
	buildEdgeMaskLits["af32_crumbly_nw"] = 'Mapping/EdgeMasks/af32_crumbly_nw.png'
	buildEdgeMaskLits["af32_crumbly_ne"] = 'Mapping/EdgeMasks/af32_crumbly_ne.png'
	buildEdgeMaskLits["af32_soft_nw"] = 'Mapping/EdgeMasks/af32_soft_nw.png'
	buildEdgeMaskLits["af32_soft_ne"] = 'Mapping/EdgeMasks/af32_soft_ne.png'
	buildEdgeMaskLits["af32_jagged_nw"] = 'Mapping/EdgeMasks/af32_jagged_nw.png'
	buildEdgeMaskLits["af32_jagged_ne"] = 'Mapping/EdgeMasks/af32_jagged_ne.png'
	buildEdgeMaskLits["af32_hard_nw"] = 'Mapping/EdgeMasks/af32_hard_nw.png'
	buildEdgeMaskLits["af32_hard_ne"] = 'Mapping/EdgeMasks/af32_hard_ne.png'
	buildEdgeMaskLits["afw32_wispy_nw"] = 'Mapping/EdgeMasks/afw32_wispy_nw.png'
	buildEdgeMaskLits["afw32_wispy_ne"] = 'Mapping/EdgeMasks/afw32_wispy_ne.png'
	buildEdgeMaskLits["afw32_crumbly_nw"] = 'Mapping/EdgeMasks/afw32_crumbly_nw.png'
	buildEdgeMaskLits["afw32_crumbly_ne"] = 'Mapping/EdgeMasks/afw32_crumbly_ne.png'
	buildEdgeMaskLits["sq_nw"] = 'Mapping/EdgeMasks/sq_nw.png'
	buildEdgeMaskLits["sq_ne"] = 'Mapping/EdgeMasks/sq_ne.png'
	buildEdgeMaskLits["sq_sw"] = 'Mapping/EdgeMasks/sq_sw.png'
	buildEdgeMaskLits["sq_se"] = 'Mapping/EdgeMasks/sq_se.png'
	buildEdgeMaskLits["msq_sw"] = 'Mapping/EdgeMasks/msq_sw.png'
	buildEdgeMaskLits["msq_se"] = 'Mapping/EdgeMasks/msq_se.png'
	buildEdgeMaskLits["tc32_nw"] = 'Mapping/EdgeMasks/tc32_nw.png'
	buildEdgeMaskLits["tc32_ne"] = 'Mapping/EdgeMasks/tc32_ne.png'
	buildEdgeMaskLits["tc32_sw"] = 'Mapping/EdgeMasks/tc32_sw.png'
	buildEdgeMaskLits["tc32_se"] = 'Mapping/EdgeMasks/tc32_se.png'
	buildEdgeMaskLits["tc_nw"] = 'Mapping/EdgeMasks/tc_nw.png'
	buildEdgeMaskLits["tc_ne"] = 'Mapping/EdgeMasks/tc_ne.png'
	buildEdgeMaskLits["tc_sw"] = 'Mapping/EdgeMasks/tc_sw.png'
	buildEdgeMaskLits["tc_se"] = 'Mapping/EdgeMasks/tc_se.png'

/proc/BuildEdgeMaskFile(nm)
	BuildEdgeMaskInit()
	return buildEdgeMaskLits[nm]

/proc/BuildEdgeFringeMask(styleId, combo, onWater = 0)
	if(styleId == "crisp")
		return null
	if(onWater)
		var/F = BuildEdgeMaskFile("fw_[styleId]_[combo]")
		if(F)
			return F
	return BuildEdgeMaskFile("f_[styleId]_[combo]")

var/global/list/buildCliffStyles
var/global/list/buildCliffStyleNames

/proc/BuildCliffInit()
	if(buildCliffStyles)
		return
	buildCliffStyles = list()
	buildCliffStyles["default"] = 'Mapping/Cliffs/cliff_default.png'
	buildCliffStyles["default_end_l"] = 'Mapping/Cliffs/cliff_default_end_l.png'
	buildCliffStyles["default_end_r"] = 'Mapping/Cliffs/cliff_default_end_r.png'
	buildCliffStyles["default_end_lr"] = 'Mapping/Cliffs/cliff_default_end_lr.png'
	buildCliffStyles["wall7"] = 'Mapping/Cliffs/cliff_wall7.png'
	buildCliffStyles["wall7_end_l"] = 'Mapping/Cliffs/cliff_wall7_end_l.png'
	buildCliffStyles["wall7_end_r"] = 'Mapping/Cliffs/cliff_wall7_end_r.png'
	buildCliffStyles["wall7_end_lr"] = 'Mapping/Cliffs/cliff_wall7_end_lr.png'
	buildCliffStyles["wall12"] = 'Mapping/Cliffs/cliff_wall12.png'
	buildCliffStyles["wall12_end_l"] = 'Mapping/Cliffs/cliff_wall12_end_l.png'
	buildCliffStyles["wall12_end_r"] = 'Mapping/Cliffs/cliff_wall12_end_r.png'
	buildCliffStyles["wall12_end_lr"] = 'Mapping/Cliffs/cliff_wall12_end_lr.png'
	buildCliffStyles["wall13"] = 'Mapping/Cliffs/cliff_wall13.png'
	buildCliffStyles["wall13_end_l"] = 'Mapping/Cliffs/cliff_wall13_end_l.png'
	buildCliffStyles["wall13_end_r"] = 'Mapping/Cliffs/cliff_wall13_end_r.png'
	buildCliffStyles["wall13_end_lr"] = 'Mapping/Cliffs/cliff_wall13_end_lr.png'
	buildCliffStyles["wall14"] = 'Mapping/Cliffs/cliff_wall14.png'
	buildCliffStyles["wall14_end_l"] = 'Mapping/Cliffs/cliff_wall14_end_l.png'
	buildCliffStyles["wall14_end_r"] = 'Mapping/Cliffs/cliff_wall14_end_r.png'
	buildCliffStyles["wall14_end_lr"] = 'Mapping/Cliffs/cliff_wall14_end_lr.png'
	buildCliffStyles["wall15"] = 'Mapping/Cliffs/cliff_wall15.png'
	buildCliffStyles["wall15_end_l"] = 'Mapping/Cliffs/cliff_wall15_end_l.png'
	buildCliffStyles["wall15_end_r"] = 'Mapping/Cliffs/cliff_wall15_end_r.png'
	buildCliffStyles["wall15_end_lr"] = 'Mapping/Cliffs/cliff_wall15_end_lr.png'
	buildCliffStyles["wall16"] = 'Mapping/Cliffs/cliff_wall16.png'
	buildCliffStyles["wall16_end_l"] = 'Mapping/Cliffs/cliff_wall16_end_l.png'
	buildCliffStyles["wall16_end_r"] = 'Mapping/Cliffs/cliff_wall16_end_r.png'
	buildCliffStyles["wall16_end_lr"] = 'Mapping/Cliffs/cliff_wall16_end_lr.png'
	buildCliffStyles["wall29"] = 'Mapping/Cliffs/cliff_wall29.png'
	buildCliffStyles["wall29_end_l"] = 'Mapping/Cliffs/cliff_wall29_end_l.png'
	buildCliffStyles["wall29_end_r"] = 'Mapping/Cliffs/cliff_wall29_end_r.png'
	buildCliffStyles["wall29_end_lr"] = 'Mapping/Cliffs/cliff_wall29_end_lr.png'
	buildCliffStyles["wall36"] = 'Mapping/Cliffs/cliff_wall36.png'
	buildCliffStyles["wall36_end_l"] = 'Mapping/Cliffs/cliff_wall36_end_l.png'
	buildCliffStyles["wall36_end_r"] = 'Mapping/Cliffs/cliff_wall36_end_r.png'
	buildCliffStyles["wall36_end_lr"] = 'Mapping/Cliffs/cliff_wall36_end_lr.png'
	buildCliffStyles["wall37"] = 'Mapping/Cliffs/cliff_wall37.png'
	buildCliffStyles["wall37_end_l"] = 'Mapping/Cliffs/cliff_wall37_end_l.png'
	buildCliffStyles["wall37_end_r"] = 'Mapping/Cliffs/cliff_wall37_end_r.png'
	buildCliffStyles["wall37_end_lr"] = 'Mapping/Cliffs/cliff_wall37_end_lr.png'
	buildCliffStyles["wall38"] = 'Mapping/Cliffs/cliff_wall38.png'
	buildCliffStyles["wall38_end_l"] = 'Mapping/Cliffs/cliff_wall38_end_l.png'
	buildCliffStyles["wall38_end_r"] = 'Mapping/Cliffs/cliff_wall38_end_r.png'
	buildCliffStyles["wall38_end_lr"] = 'Mapping/Cliffs/cliff_wall38_end_lr.png'
	buildCliffStyles["wall56"] = 'Mapping/Cliffs/cliff_wall56.png'
	buildCliffStyles["wall56_end_l"] = 'Mapping/Cliffs/cliff_wall56_end_l.png'
	buildCliffStyles["wall56_end_r"] = 'Mapping/Cliffs/cliff_wall56_end_r.png'
	buildCliffStyles["wall56_end_lr"] = 'Mapping/Cliffs/cliff_wall56_end_lr.png'
	buildCliffStyles["wall99"] = 'Mapping/Cliffs/cliff_wall99.png'
	buildCliffStyles["wall99_end_l"] = 'Mapping/Cliffs/cliff_wall99_end_l.png'
	buildCliffStyles["wall99_end_r"] = 'Mapping/Cliffs/cliff_wall99_end_r.png'
	buildCliffStyles["wall99_end_lr"] = 'Mapping/Cliffs/cliff_wall99_end_lr.png'
	buildCliffStyleNames = list("Default (water Wall29, raised terrain Wall38)" = "default", "None - water gets no rock strip" = "none", "Wall 7" = "wall7", "Wall 12" = "wall12", "Wall 13" = "wall13", "Wall 14" = "wall14", "Wall 15" = "wall15", "Wall 16" = "wall16", "Wall 29" = "wall29", "Wall 36" = "wall36", "Wall 37" = "wall37", "Wall 38" = "wall38", "Wall 56" = "wall56", "Wall 99" = "wall99")

/proc/BuildCliffStrip(styleId, variant)
	BuildCliffInit()
	var/F
	if(variant)
		F = buildCliffStyles["[styleId]_[variant]"]
		if(F)
			return F
		F = buildCliffStyles["default_[variant]"]
		if(F)
			return F
	F = buildCliffStyles[styleId]
	if(F)
		return F
	return buildCliffStyles["default"]

/proc/BuildEdgeBlendMask(side, seed)
	switch("[side][seed]")
		if("n1")
			return 'Mapping/EdgeMasks/blend_n_1.png'
		if("n2")
			return 'Mapping/EdgeMasks/blend_n_2.png'
		if("n3")
			return 'Mapping/EdgeMasks/blend_n_3.png'
		if("s1")
			return 'Mapping/EdgeMasks/blend_s_1.png'
		if("s2")
			return 'Mapping/EdgeMasks/blend_s_2.png'
		if("s3")
			return 'Mapping/EdgeMasks/blend_s_3.png'
		if("e1")
			return 'Mapping/EdgeMasks/blend_e_1.png'
		if("e2")
			return 'Mapping/EdgeMasks/blend_e_2.png'
		if("e3")
			return 'Mapping/EdgeMasks/blend_e_3.png'
		if("w1")
			return 'Mapping/EdgeMasks/blend_w_1.png'
		if("w2")
			return 'Mapping/EdgeMasks/blend_w_2.png'
	return 'Mapping/EdgeMasks/blend_w_3.png'

/proc/BuildMatSameH(turf/O, th)
	return (O && ElevAt(O) == th) ? BuildMaterialFor(O) : null

/proc/BuildIsEdgeObj(obj/O)
	if(!O || !istype(O, /obj/Turfs))
		return 0
	if(O.icon == 'Edges.dmi' || O.icon == 'grayrockedges.dmi' || O.icon == 'Icons/Objects/EdgesDir.dmi')
		return 1
	return 0

/proc/BuildEdgeObjOn(turf/T)
	if(!T)
		return null
	for(var/obj/Turfs/O in T)
		if(BuildIsEdgeObj(O))
			return O
	return null

/proc/BuildEdgeObjSideways(turf/T)
	var/obj/O = BuildEdgeObjOn(T)
	if(!O)
		return 0
	return (O.dir == EAST || O.dir == WEST) ? 1 : 0

/proc/BuildMatFor(turf/T, turf/O, th)
	if(!O || O.EdgeOptOut || BuildEdgeObjOn(O))
		return null
	return BuildMatSameH(O, th)

/proc/BuildNoEdgeExportSidecar(x1, y1, x2, y2, z, fname)
	var/cf = "[copytext(fname, 1, -4)]_noedge.txt"
	if(fexists(cf))
		fdel(cf)
	var/list/out = list()
	for(var/y = y1 to y2)
		for(var/x = x1 to x2)
			var/turf/T = locate(x, y, z)
			if(T && T.EdgeOptOut)
				out += "[x - x1]\t[y - y1]"
	if(!out.len)
		return 0
	text2file(jointext(out, "\n"), cf)
	return out.len

/proc/BuildNoEdgeImportSidecar(fname, ox, oy, oz)
	var/cf = "[copytext(fname, 1, -4)]_noedge.txt"
	if(!fexists(cf))
		return 0
	var/raw = file2text(cf)
	var/n = 0
	for(var/line in splittext(raw, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len < 2)
			continue
		var/dx = text2num(f[1])
		var/dy = text2num(f[2])
		if(isnull(dx) || isnull(dy))
			continue
		var/turf/T = locate(ox + dx, oy + dy, oz)
		if(T)
			T.EdgeOptOut = 1
			n++
	return n

var/global/list/buildLipCrawlStates

/proc/BuildIsRockLip(obj/O)
	if(!O)
		return 0
	if(O.icon == 'grayrockedges.dmi')
		return 1
	if(O.icon == 'Edges.dmi' && (O.icon_state in list("1", "2", "3", "4", "5", "6", "7")))
		return 1
	return 0

/proc/BuildLipCrawl(turf/T, obj/EO, list/fresh)
	if(!T || !EO || !(EO.dir == EAST || EO.dir == WEST) || !BuildIsRockLip(EO))
		return
	var/m = BuildMaterialFor(T)
	if(!m || m == "Water")
		return
	var/sty = BuildEdgeStyleFor(m)
	if(sty != "wispy" && sty != "crumbly" && sty != "soft")
		return
	if(!buildLipCrawlStates)
		buildLipCrawlStates = ElevStateSet('Mapping/Elevation/elev_lipcrawl.dmi')
	var/st = "lc_[sty]_[(EO.dir == WEST) ? "L" : "R"]_[ElevLipWidth(EO)]"
	if(!buildLipCrawlStates[st])
		return
	var/eh = ElevAt(T)
	var/image/I = image(ElevTexIcon(T, eh), null, ElevTexState(T, eh))
	I.layer = EO.layer + 0.01
	I.filters = filter(type = "alpha", icon = ElevMaskIcon('Mapping/Elevation/elev_lipcrawl.dmi', st))
	fresh += I

/proc/BuildEdgePiece(turf/src_turf, mask)
	var/eh = ElevAt(src_turf)
	var/image/I = image(ElevTexIcon(src_turf, eh), null, ElevTexState(src_turf, eh))
	I.layer = 2.9
	I.filters = filter(type = "alpha", icon = mask)
	return I


var/global/list/buildCliffTurfTypes
var/global/list/cliffPaintMap

/proc/BuildCliffTypesInit()
	if(buildCliffTurfTypes)
		return
	buildCliffTurfTypes = list()
	buildCliffTurfTypes[/turf/Wall7] = 1
	buildCliffTurfTypes[/turf/Wall12] = 1
	buildCliffTurfTypes[/turf/Wall13] = 1
	buildCliffTurfTypes[/turf/Wall14] = 1
	buildCliffTurfTypes[/turf/Wall15] = 1
	buildCliffTurfTypes[/turf/Wall16] = 1
	buildCliffTurfTypes[/turf/Wall29] = 1
	buildCliffTurfTypes[/turf/Wall36] = 1
	buildCliffTurfTypes[/turf/Wall37] = 1
	buildCliffTurfTypes[/turf/Wall38] = 1
	buildCliffTurfTypes[/turf/Wall56] = 1
	buildCliffTurfTypes[/turf/Wall99] = 1

/proc/BuildIsCliffTurf(turf/T)
	if(!T)
		return 0
	BuildCliffTypesInit()
	if(buildCliffTurfTypes[T.type])
		return 1
	if(istype(T, /turf/CustomTurf))
		var/datum/build_custom_def/D = BuildCustomDefForIcon(T.icon, T.icon_state)
		if(D && D.cliff)
			return 1
	return 0

/proc/BuildCliffPaintLoad()
	if(cliffPaintMap)
		return
	cliffPaintMap = list()
	if(!fexists("Saves/CliffPaint.txt"))
		return
	var/raw = file2text("Saves/CliffPaint.txt")
	for(var/line in splittext(raw, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len < 2)
			continue
		if(!length(f[1]) || !length(f[2]))
			continue
		cliffPaintMap[f[1]] = f[2]

/proc/BuildCliffPaintSave()
	if(!cliffPaintMap)
		return
	var/list/lines = list()
	for(var/k in cliffPaintMap)
		lines += "[k]\t[cliffPaintMap[k]]"
	if(fexists("Saves/CliffPaint.txt"))
		fdel("Saves/CliffPaint.txt")
	text2file(jointext(lines, "\n"), "Saves/CliffPaint.txt")

/proc/BuildCliffStyleAt(turf/T)
	if(!T)
		return "default"
	BuildCliffPaintLoad()
	var/s = cliffPaintMap["[T.x],[T.y],[T.z]"]
	return s ? s : "default"

/proc/BuildCliffPaintRegion(x1, y1, x2, y2, z, style)
	BuildCliffPaintLoad()
	var/list/hit = list()
	var/n = 0
	for(var/turf/T in TurfSquare(x1, y1, x2, y2, z, 0))
		var/k = "[T.x],[T.y],[T.z]"
		if(style == "default")
			cliffPaintMap -= k
		else
			cliffPaintMap[k] = style
		hit += T
		n++
		if(n % BUILD_COMMIT_CHUNK == 0)
			sleep(-1)
	BuildCliffPaintSave()
	if(hit.len)
		BuildEdgeSmoothAround(hit, 1)
		if(elevMap && elevMap.len)
			ElevVisualRefresh(hit)
	return n

/proc/BuildCliffExportSidecar(x1, y1, x2, y2, z, fname)
	BuildCliffPaintLoad()
	var/cf = "[copytext(fname, 1, -4)]_cliffs.txt"
	if(fexists(cf))
		fdel(cf)
	var/list/out = list()
	for(var/y = y1 to y2)
		for(var/x = x1 to x2)
			var/st = cliffPaintMap["[x],[y],[z]"]
			if(st)
				out += "[x - x1]\t[y - y1]\t[st]"
	if(!out.len)
		return 0
	text2file(jointext(out, "\n"), cf)
	return out.len

/proc/BuildCliffImportSidecar(fname, ox, oy, oz)
	var/cf = "[copytext(fname, 1, -4)]_cliffs.txt"
	if(!fexists(cf))
		return 0
	BuildCliffPaintLoad()
	var/raw = file2text(cf)
	var/n = 0
	for(var/line in splittext(raw, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len < 3)
			continue
		var/dx = text2num(f[1])
		var/dy = text2num(f[2])
		if(isnull(dx) || isnull(dy) || !length(f[3]))
			continue
		cliffPaintMap["[ox + dx],[oy + dy],[oz]"] = f[3]
		n++
	if(n)
		BuildCliffPaintSave()
	return n

var/global/list/foamPaintMap

/proc/BuildFoamPaintLoad()
	if(foamPaintMap)
		return
	foamPaintMap = list()
	if(!fexists("Saves/FoamPaint.txt"))
		return
	var/raw = file2text("Saves/FoamPaint.txt")
	for(var/line in splittext(raw, "\n"))
		var/k = copytext(line, 1, findtext(line, "\t") || 0)
		if(length(k))
			foamPaintMap[k] = "off"

/proc/BuildFoamPaintSave()
	if(!foamPaintMap)
		return
	var/list/lines = list()
	for(var/k in foamPaintMap)
		lines += "[k]\toff"
	if(fexists("Saves/FoamPaint.txt"))
		fdel("Saves/FoamPaint.txt")
	text2file(jointext(lines, "\n"), "Saves/FoamPaint.txt")

/proc/BuildFoamOffAt(turf/T)
	if(!T)
		return 0
	BuildFoamPaintLoad()
	return foamPaintMap["[T.x],[T.y],[T.z]"] ? 1 : 0

/proc/BuildFoamPaintRegion(x1, y1, x2, y2, z, off)
	BuildFoamPaintLoad()
	var/list/hit = list()
	var/n = 0
	var/cnt = 0
	for(var/turf/T in TurfSquare(x1, y1, x2, y2, z, 0))
		var/k = "[T.x],[T.y],[T.z]"
		if(off)
			foamPaintMap[k] = "off"
		else
			foamPaintMap -= k
		hit += T
		if(BuildMaterialFor(T) == "Water")
			cnt++
		n++
		if(n % BUILD_COMMIT_CHUNK == 0)
			sleep(-1)
	BuildFoamPaintSave()
	if(hit.len)
		BuildEdgeSmoothAround(hit, 1)
		ElevVisualRefresh(hit)
	return cnt

/proc/BuildFoamExportSidecar(x1, y1, x2, y2, z, fname)
	BuildFoamPaintLoad()
	var/cf = "[copytext(fname, 1, -4)]_foam.txt"
	if(fexists(cf))
		fdel(cf)
	var/list/out = list()
	for(var/y = y1 to y2)
		for(var/x = x1 to x2)
			if(foamPaintMap["[x],[y],[z]"])
				out += "[x - x1]\t[y - y1]\toff"
	if(!out.len)
		return 0
	text2file(jointext(out, "\n"), cf)
	return out.len

/proc/BuildFoamImportSidecar(fname, ox, oy, oz)
	var/cf = "[copytext(fname, 1, -4)]_foam.txt"
	if(!fexists(cf))
		return 0
	BuildFoamPaintLoad()
	var/raw = file2text(cf)
	var/n = 0
	for(var/line in splittext(raw, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len < 2)
			continue
		var/dx = text2num(f[1])
		var/dy = text2num(f[2])
		if(isnull(dx) || isnull(dy))
			continue
		foamPaintMap["[ox + dx],[oy + dy],[oz]"] = "off"
		n++
	if(n)
		BuildFoamPaintSave()
	return n

/proc/BuildCliffCurveSides(turf/T)
	if(!BuildIsCliffTurf(T))
		return 0
	if(BuildIsCliffTurf(locate(T.x, T.y - 1, T.z)))
		return 0
	var/s = 0
	var/turf/W = locate(T.x - 1, T.y, T.z)
	var/turf/E = locate(T.x + 1, T.y, T.z)
	if(W && !BuildIsCliffTurf(W) && !BuildIsCliffTurf(locate(T.x - 1, T.y - 1, T.z)))
		s |= 1
	if(E && !BuildIsCliffTurf(E) && !BuildIsCliffTurf(locate(T.x + 1, T.y - 1, T.z)))
		s |= 2
	return s

/proc/BuildCliffCurve(turf/T, list/fresh)
	var/s = BuildCliffCurveSides(T)
	if(!s || ElevFaceInfo(T))
		return
	if(s & 1)
		fresh += BuildEdgePiece(locate(T.x - 1, T.y, T.z), 'Mapping/EdgeMasks/cc_l.png')
	if(s & 2)
		fresh += BuildEdgePiece(locate(T.x + 1, T.y, T.z), 'Mapping/EdgeMasks/cc_r.png')

/proc/BuildEdgeApply(turf/T, list/fresh)
	if(!fresh || !fresh.len)
		return
	for(var/img in fresh)
		T.overlays += img
	T.edgeOverlays = fresh

/proc/BuildEdgeUpdate(turf/T, doBlend = 1)
	if(!T)
		return
	if(T.edgeOverlays)
		for(var/img in T.edgeOverlays)
			T.overlays -= img
	T.edgeOverlays = null
	var/list/fresh = list()
	if(T.EdgeOptOut)
		return
	var/obj/EO = BuildEdgeObjOn(T)
	if(EO)
		BuildLipCrawl(T, EO, fresh)
		BuildEdgeApply(T, fresh)
		return
	BuildCliffCurve(T, fresh)
	var/m = BuildMaterialFor(T)
	if(!m)
		BuildEdgeApply(T, fresh)
		return
	var/mp = BuildMaterialPriority(m)
	var/turf/N = locate(T.x, T.y + 1, T.z)
	var/turf/So = locate(T.x, T.y - 1, T.z)
	var/turf/E = locate(T.x + 1, T.y, T.z)
	var/turf/W = locate(T.x - 1, T.y, T.z)
	var/th = ElevAt(T)
	var/mn = BuildMatFor(T, N, th)
	var/ms = BuildMatFor(T, So, th)
	var/me = BuildMatFor(T, E, th)
	var/mw = BuildMatFor(T, W, th)
	var/turf/DNW = locate(T.x - 1, T.y + 1, T.z)
	var/turf/DNE = locate(T.x + 1, T.y + 1, T.z)
	var/turf/DSW = locate(T.x - 1, T.y - 1, T.z)
	var/turf/DSE = locate(T.x + 1, T.y - 1, T.z)
	var/mdnw = BuildMatFor(T, DNW, th)
	var/mdne = BuildMatFor(T, DNE, th)
	var/mdsw = BuildMatFor(T, DSW, th)
	var/mdse = BuildMatFor(T, DSE, th)
	var/cliffTile = (m == "Water" && mn && mn != "Water")
	var/list/corners = list("nw" = list(N, mn, W, mw, DNW, mdnw), "ne" = list(N, mn, E, me, DNE, mdne), "sw" = list(So, ms, W, mw, DSW, mdsw), "se" = list(So, ms, E, me, DSE, mdse))
	for(var/c in corners)
		var/list/info = corners[c]
		var/turf/o1 = info[1]
		var/m1 = info[2]
		var/turf/o2 = info[3]
		var/m2 = info[4]
		var/turf/dg = info[5]
		var/md = info[6]
		if(!m1 || !m2)
			continue
		var/p1 = BuildMaterialPriority(m1)
		var/p2 = BuildMaterialPriority(m2)
		if(m1 != m && m2 != m && p1 < mp && p2 < mp)
			var/turf/src_turf = (p1 >= p2) ? o1 : o2
			fresh += BuildEdgePiece(src_turf, BuildEdgeCutMask(c))
			continue
		if(m1 == m2 && m1 != m && p1 > mp)
			if(m1 == "Water" && (c == "sw" || c == "se"))
				continue
			if(md == m1)
				var/AF
				if(m1 == "Water")
					fresh += BuildEdgePiece(dg, BuildEdgeCutMask32(c))
					AF = BuildEdgeMaskFile("afw32_[BuildEdgeStyleFor(m)]_[c]")
					if(!AF)
						AF = BuildEdgeMaskFile("af32_[BuildEdgeStyleFor(m)]_[c]")
				else
					fresh += BuildEdgePiece(dg, BuildEdgeCutMask(c))
					AF = BuildEdgeMaskFile("af_[BuildEdgeStyleFor(m)]_[c]")
				if(AF)
					var/image/AFI = BuildEdgePiece(T, AF)
					if(m1 == "Water")
						var/sealTop = (c == "nw") ? (me && me != "Water") : (mw && mw != "Water")
						var/sealSide = (ms && ms != "Water")
						if(!sealTop)
							AFI.filters += filter(type = "alpha", icon = 'Mapping/EdgeMasks/bs_n.png', flags = MASK_INVERSE)
						if(!sealSide)
							AFI.filters += filter(type = "alpha", icon = (c == "nw") ? 'Mapping/EdgeMasks/bs_w.png' : 'Mapping/EdgeMasks/bs_e.png', flags = MASK_INVERSE)
					fresh += AFI
	if(cliffTile && BuildCliffStyleAt(T) == "none")
		cliffTile = 0
	if(cliffTile)
		var/endL = (!mw) || (mw == "Water" && !(mdnw && mdnw != "Water"))
		var/endR = (!me) || (me == "Water" && !(mdne && mdne != "Water"))
		var/variant
		if(endL && endR)
			variant = "end_lr"
		else if(endL)
			variant = "end_l"
		else if(endR)
			variant = "end_r"
		fresh += BuildCliffStripImage(BuildCliffStyleAt(T), variant)
	if(m != "Water" && mn == "Water" && N)
		var/dcl = (mw && mw != "Water" && mdnw == "Water")
		var/dcr = (me && me != "Water" && mdne == "Water")
		if(dcl && dcr)
			fresh += BuildEdgePiece(N, 'Mapping/EdgeMasks/nfd.png')
		else if(dcr)
			fresh += BuildEdgePiece(N, 'Mapping/EdgeMasks/nfd_l.png')
		else if(dcl)
			fresh += BuildEdgePiece(N, 'Mapping/EdgeMasks/nfd_r.png')
		else
			fresh += BuildEdgePiece(N, 'Mapping/EdgeMasks/nfd_lr.png')
	ShoreFoamAdd(T, m, fresh)
	if(m == "Water" && ms && ms != "Water" && So)
		var/ucl = (mw == "Water" && mdsw && mdsw != "Water")
		var/ucr = (me == "Water" && mdse && mdse != "Water")
		if(ucl && ucr)
			fresh += BuildEdgePiece(So, 'Mapping/EdgeMasks/nfu.png')
		else if(ucr)
			fresh += BuildEdgePiece(So, 'Mapping/EdgeMasks/nfu_l.png')
		else if(ucl)
			fresh += BuildEdgePiece(So, 'Mapping/EdgeMasks/nfu_r.png')
		else
			fresh += BuildEdgePiece(So, 'Mapping/EdgeMasks/nfu_lr.png')
	var/list/sides = list("n" = list(N, mn), "s" = list(So, ms), "e" = list(E, me), "w" = list(W, mw))
	var/list/fringeCombos = list()
	var/list/fringeSrc = list()
	var/list/fringeTapers = list()
	var/si = 0
	for(var/sd in sides)
		si++
		var/list/info = sides[sd]
		var/turf/NB = info[1]
		var/mb = info[2]
		if(!NB || !mb)
			continue
		if(mb != m && BuildMaterialPriority(mb) < mp)
			if(m == "Water" && sd == "s")
				continue
			fringeCombos[mb] = "[fringeCombos[mb]][sd]"
			if(!fringeSrc[mb])
				fringeSrc[mb] = NB
			var/list/tl = fringeTapers[mb]
			if(!tl)
				tl = list()
				fringeTapers[mb] = tl
			var/wp = (m == "Water")
			switch(sd)
				if("n")
					if(!wp)
						if(mw == m && mdnw == m)
							tl += "tc_nw"
						if(me == m && mdne == m)
							tl += "tc_ne"
				if("s")
					if(mw == m && mdsw == m)
						tl += wp ? "tc32_sw" : "tc_sw"
					if(me == m && mdse == m)
						tl += wp ? "tc32_se" : "tc_se"
				if("e")
					if(mn == m && mdne == m)
						tl += wp ? "tc32_ne" : "tc_ne"
					if(ms == m && mdse == m)
						tl += wp ? "msq_se" : "tc_se"
				if("w")
					if(mn == m && mdnw == m)
						tl += wp ? "tc32_nw" : "tc_nw"
					if(ms == m && mdsw == m)
						tl += wp ? "msq_sw" : "tc_sw"
			continue
		if(!doBlend)
			continue
		if(mb != m || NB.type == T.type)
			continue
		if("[NB.type]" > "[T.type]")
			continue
		var/seed = ((T.x * 7 + T.y * 13 + si) % 3) + 1
		fresh += BuildEdgePiece(NB, BuildEdgeBlendMask(sd, seed))
	for(var/fmat in fringeCombos)
		var/FF = BuildEdgeFringeMask(BuildEdgeStyleFor(fmat), fringeCombos[fmat], m == "Water")
		if(!FF)
			continue
		var/image/FI = BuildEdgePiece(fringeSrc[fmat], FF)
		var/list/tl = fringeTapers[fmat]
		if(tl)
			for(var/tc in tl)
				FI.filters += filter(type = "alpha", icon = BuildEdgeMaskFile(tc), flags = MASK_INVERSE)
		fresh += FI
	BuildEdgeApply(T, fresh)

/proc/BuildEdgeSmoothAround(list/turfs, doBlend = 1)
	var/list/seen = list()
	var/n = 0
	for(var/turf/T in turfs)
		for(var/dx = -1 to 1)
			for(var/dy = -1 to 1)
				var/turf/T2 = locate(T.x + dx, T.y + dy, T.z)
				if(!T2 || seen[T2])
					continue
				seen[T2] = 1
				BuildEdgeUpdate(T2, doBlend)
				n++
				if(n % BUILD_COMMIT_CHUNK == 0)
					sleep(-1)

/proc/BuildEdgeBootPass()
	set waitfor = FALSE
	set background = TRUE
	var/list/all = list()
	for(var/turf/T in Turfs)
		all += T
	for(var/turf/T in CustomTurfs)
		all += T
	if(!all.len)
		return
	BuildEdgeSmoothAround(all, 1)
	Log("Mapper", "Auto-edge boot pass smoothed around [all.len] registered turfs.", 1)
	var/list/cliffs = list()
	for(var/turf/T in all)
		if(BuildIsCliffTurf(T))
			cliffs += T
	if(cliffs.len)
		ElevVisualRefresh(cliffs)
		Log("Mapper", "Cliff boot pass dressed [cliffs.len] placed cliff turfs.", 1)

var/global/list/buildCliffPickerEntries

/proc/BuildCliffCodeForPath(path)
	switch(path)
		if(/turf/Wall7)
			return "wall7"
		if(/turf/Wall12)
			return "wall12"
		if(/turf/Wall13)
			return "wall13"
		if(/turf/Wall14)
			return "wall14"
		if(/turf/Wall15)
			return "wall15"
		if(/turf/Wall16)
			return "wall16"
		if(/turf/Wall29)
			return "wall29"
		if(/turf/Wall36)
			return "wall36"
		if(/turf/Wall37)
			return "wall37"
		if(/turf/Wall38)
			return "wall38"
		if(/turf/Wall56)
			return "wall56"
		if(/turf/Wall99)
			return "wall99"
	return ""

/proc/BuildCliffStyleCodeFor(datum/build_entry/E)
	if(!E || !E.iconF)
		return ""
	var/c = BuildCliffCodeForPath(E.Creates)
	if(length(c))
		return c
	return "i:[E.iconF]|[E.icon_state]"

/proc/BuildCliffPickerEntries()
	if(buildCliffPickerEntries)
		return buildCliffPickerEntries
	BuildPaletteInit()
	var/list/out = list()
	var/datum/build_entry/DE = new
	DE.name = "-DEFAULT ROCK: WALL38 FACES, WALL29 WATER STRIPS-"
	DE.styleCode = "default"
	for(var/datum/build_entry/E in buildPalette)
		if(E.Creates == /turf/Wall38)
			DE.iconF = E.iconF
			DE.icon_state = E.icon_state
			DE.thumb = E.thumb
			break
	out += DE
	var/datum/build_entry/NE = new
	NE.name = "-NO ROCK STRIP UNDER WATER (FACES: DEFAULT ROCK)-"
	NE.styleCode = "none"
	NE.iconF = 'HUD/build_white.png'
	NE.swatchColor = "#3b7dd8"
	out += NE
	for(var/datum/build_entry/E in buildPalette)
		if(E.isZone || E.category == BUILD_CAT_SPECIAL || !ispath(E.Creates, /turf) || !E.iconF)
			continue
		var/take = 0
		if(E.isCustom)
			var/datum/build_custom_def/D = BuildCustomDefForIcon(E.iconF, E.icon_state)
			take = (D && D.cliff) ? 1 : 0
		else if(findtext(lowertext("[E.Creates]"), "wall") || findtext(lowertext(E.name), "wall"))
			take = 1
		if(!take)
			continue
		E.styleCode = BuildCliffStyleCodeFor(E)
		out += E
	buildCliffPickerEntries = out
	return out

/proc/BuildCliffStyleLabel(code)
	if(!length(code) || code == "default")
		return "DEFAULT ROCK"
	if(code == "none")
		return "NO ROCK STRIP UNDER WATER"
	for(var/datum/build_entry/E in BuildCliffPickerEntries())
		if(E.styleCode == code)
			return E.name
	if(copytext(code, 1, 5) == "wall")
		return "WALL [copytext(code, 5)]"
	var/p = findtext(code, "|")
	return p ? copytext(code, p + 1) : code

/proc/BuildCliffStyleStamp(turf/T, style)
	if(!T || !length(style))
		return 0
	BuildCliffPaintLoad()
	var/k = "[T.x],[T.y],[T.z]"
	if(style == "default")
		if(!cliffPaintMap[k])
			return 0
		cliffPaintMap -= k
		return 1
	if(cliffPaintMap[k] == style)
		return 0
	cliffPaintMap[k] = style
	return 1

/proc/BuildCliffStripImage(style, variant)
	var/image/CI
	if(ElevStyleGeneric(style))
		var/list/art = ElevStyleArt(style)
		if(art)
			CI = image(art[1], null, art[2])
			CI.filters = filter(type = "alpha", icon = BuildCliffStrip("default", variant))
	if(!CI)
		CI = image(BuildCliffStrip(style, variant))
	CI.layer = 2.9
	return CI

/proc/BuildCliffPickEnter(datum/build_session/S)
	if(!S?.active)
		return
	S.CancelPending()
	S.pickPrevCat = S.category
	S.stylePick = 1
	S.filter = ""
	S.RefreshFiltered()
	BuildHUDRefreshGrid(S)
	BuildHUDRefreshDrop(S)
	BuildHUDRefreshSearch(S)
	BuildHUDSetSelName(S, "CLIFF STYLE: CLICK A WALL (NOW: [BuildCliffStyleLabel(S.cliffStyleSel)])")
	S.C.mob << "CLIFF STYLE: the drawer now lists every wall. Click one - from then on every tile you raise wears it as its cliff face and water you place gets it as its rock strip, until you pick another. Current: [BuildCliffStyleLabel(S.cliffStyleSel)]. Pick a category from the drop-down to leave without changing it."

/proc/BuildCliffPickExit(datum/build_session/S)
	if(!S?.stylePick)
		return
	S.stylePick = 0
	if(length(S.pickPrevCat))
		S.category = S.pickPrevCat
	S.RefreshFiltered()
	BuildHUDRefreshGrid(S)
	BuildHUDRefreshDrop(S)

/proc/BuildCliffPickChoose(datum/build_session/S, datum/build_entry/E)
	if(!S || !E)
		return
	var/code = length(E.styleCode) ? E.styleCode : BuildCliffStyleCodeFor(E)
	if(!length(code))
		return
	S.cliffStyleSel = code
	S.C?.setPref("cliffStyle", code)
	BuildCliffPickExit(S)
	BuildHUDSetSelName(S, "CLIFF STYLE: [BuildCliffStyleLabel(code)]")
	S.C?.mob << "Cliff style: [BuildCliffStyleLabel(code)]. Raised terrain and placed water use it from now on."
	Log("Mapper", "[S.C?.mob] ([S.C?.ckey]) set cliff style [code].", 1)

mob/Mapper/verb/Paint_Cliff_Style()
	set category = "Mapper"
	var/datum/build_session/S = usr.client?.bsession
	if(!S?.active)
		usr << "Turn on Build Mode first (ToggleBuildMode), then run this again."
		return
	BuildCliffPickEnter(S)

mob/Mapper/verb/Paint_Foam_Off()
	set category = "Mapper"
	var/datum/build_session/S = usr.client?.bsession
	if(!S?.active)
		usr << "Turn on Build Mode first (ToggleBuildMode), then run this again."
		return
	S.CancelPending()
	S.regionSel = "foam:off"
	S.cliffStage = 1
	usr << "FOAM OFF: click the FIRST corner of the region. Water tiles inside it lose their shore foam. Right-click cancels."

mob/Mapper/verb/Paint_Foam_On()
	set category = "Mapper"
	var/datum/build_session/S = usr.client?.bsession
	if(!S?.active)
		usr << "Turn on Build Mode first (ToggleBuildMode), then run this again."
		return
	S.CancelPending()
	S.regionSel = "foam:on"
	S.cliffStage = 1
	usr << "FOAM ON: click the FIRST corner of the region. Water tiles inside it get their shore foam back. Right-click cancels."

mob/Mapper/verb/Edge_Debug()
	set category = "Mapper"
	var/turf/T = usr.loc
	if(!isturf(T))
		usr << "Stand on a tile first."
		return
	BuildEdgeMaskInit()
	usr << "EDGE DEBUG @ ([T.x],[T.y],[T.z]) - [buildEdgeMaskLits.len] masks compiled in."
	var/m = BuildMaterialFor(T)
	usr << "  HERE: [T.type] -> [m ? "[m] (style [BuildEdgeStyleFor(m)], priority [BuildMaterialPriority(m)])" : "NO MATERIAL (will not edge)"]"
	usr << "  tracked edge overlays on this tile: [T.edgeOverlays ? T.edgeOverlays.len : 0]"
	usr << "  auto-edging for this tile: [T.EdgeOptOut ? "OFF (placed with auto-edge off; neighbours ignore it)" : "on"][BuildEdgeObjOn(T) ? ", edge object present (no auto pieces, lip crawl only)" : ""]"
	var/list/dirs = list("N" = list(0, 1), "S" = list(0, -1), "E" = list(1, 0), "W" = list(-1, 0))
	for(var/d in dirs)
		var/list/o = dirs[d]
		var/turf/T2 = locate(T.x + o[1], T.y + o[2], T.z)
		if(!T2)
			continue
		var/m2 = BuildMaterialFor(T2)
		usr << "  [d]: [T2.type] -> [m2 ? "[m2] (style [BuildEdgeStyleFor(m2)], priority [BuildMaterialPriority(m2)])" : "NO MATERIAL (will not edge)"]"

mob/Mapper/verb/Smooth_Region()
	set category = "Mapper"
	var/datum/build_session/S = usr.client?.bsession
	if(!S?.active)
		usr << "Turn on Build Mode first (ToggleBuildMode), then run this again."
		return
	S.CancelPending()
	S.smoothStage = 1
	usr << "SMOOTH: click the FIRST corner of the region to auto-edge. Right-click cancels."
