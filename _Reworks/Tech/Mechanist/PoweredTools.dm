/obj/Items/LifeTool/Powered
	name = "Powered Tool"
	var/Uses = POWERED_TOOL_CHARGE
	var/MaxUses = POWERED_TOOL_CHARGE
	var/PlainSweet = 0
	var/PlainYield = 0
	var/PlainQuality = 0

	proc/PowerSync()
		var/m = Uses > 0 ? POWERED_TOOL_MULT : 1
		SweetSpotBonus = PlainSweet * m
		YieldBonus = round(PlainYield * m, 1)
		QualityBonus = round(PlainQuality * m, 1)

	LifeToolWear(mob/M)
		..()
		if(Broken || Uses <= 0) return
		Uses--
		if(Uses > 0) return
		Uses = 0
		PowerSync()
		if(M) M << "<font color=#ff6464>Your [name] runs out of power. It works as a plain tool until a Power Pack recharges it.</font>"

mob/proc/PoweredToolBase(kind)
	var/obj/Items/LifeTool/best
	for(var/obj/Items/LifeTool/t in src)
		if(istype(t, /obj/Items/LifeTool/Powered)) continue
		if(t.ToolKind != kind || t.Broken) continue
		if(!best || t.ToolTier > best.ToolTier || (t.ToolTier == best.ToolTier && t.CraftQuality > best.CraftQuality))
			best = t
	return best

proc/PoweredToolFrom(obj/Items/LifeTool/base)
	if(!base) return null
	var/obj/Items/LifeTool/Powered/P = new
	P.SetupTool(base.ToolKind, base.metal_id, base.CraftQuality)
	P.PlainSweet = P.SweetSpotBonus
	P.PlainYield = P.YieldBonus
	P.PlainQuality = P.QualityBonus
	P.ShatterMax = base.ShatterMax
	P.ShatterCounter = base.ShatterCounter
	P.gem_id = base.gem_id
	P.gem_quality = base.gem_quality
	P.mmat_id = base.mmat_id
	P.mmat_quality = base.mmat_quality
	P.CreatorKey = base.CreatorKey
	P.CreatorSignature = base.CreatorSignature
	P.CreatorName = base.CreatorName
	P.name = "Powered [P.name]"
	P.desc = "A smith-made [lowertext(P.ToolKind)] with a servo and a power cell built in. It works half again as well while it holds a charge, and each job spends one."
	P.Uses = P.MaxUses
	P.PowerSync()
	return P

/obj/Items/Tech/Power_Pack/RechargeExtras(mob/user)
	. = ..()
	for(var/obj/Items/LifeTool/Powered/P in user)
		if(P.Uses < P.MaxUses) . += P

/obj/Items/Tech/Power_Pack/RechargeDone(obj/Items/I)
	..()
	if(istype(I, /obj/Items/LifeTool/Powered))
		var/obj/Items/LifeTool/Powered/P = I
		P.PowerSync()
