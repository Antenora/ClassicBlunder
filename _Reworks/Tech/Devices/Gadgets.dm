#define GADGET_USES 20
#define GADGET_QUALITY_CHANCE 10
#define GADGET_YIELD_MULT 1.15
#define SPRINKLER_RADIUS 4

/obj/Items/Gear/Field_Gadget
	TechType = "Engineering"
	SubType = "Field Gadgets"
	icon = 'Icons/Technology/Tech.dmi'
	Uses = GADGET_USES
	var/gadget_skill
	var/gadget_kind

	proc/GadgetSpend(mob/M)
		if(Uses <= 0) return 0
		Uses--
		if(Uses <= 0 && M) M << "Your [name] is out of charge. Recharge it with a Power Pack."
		return 1

/obj/Items/Gear/Field_Gadget/Ore_Scanner
	name = "Ore Scanner"
	desc = "Equip it and it reads the rock while you mine: each haul has a 10% chance to come out one quality higher. It spends one charge per haul. Recharge it with a Power Pack."
	icon_state = "ScanChip"
	gadget_skill = "Mining"
	gadget_kind = "quality"

/obj/Items/Gear/Field_Gadget/Fish_Finder
	name = "Fish Finder"
	desc = "Equip it and it pings the shoals while you fish: each catch has a 15% chance to bring a second fish with it. It spends one charge per catch. Recharge it with a Power Pack."
	icon_state = "PDA"
	gadget_skill = "Fishing"
	gadget_kind = "yield"

/obj/Items/Gear/Field_Gadget/Botanical_Analyzer
	name = "Botanical Analyzer"
	desc = "Equip it and it grades plants while you forage: each gather has a 10% chance to come out one quality higher. It spends one charge per gather. Recharge it with a Power Pack."
	icon_state = "ScannerStation"
	gadget_skill = "Foraging"
	gadget_kind = "quality"

mob/proc/FieldGadgetFor(skill, kind)
	for(var/obj/Items/Gear/Field_Gadget/G in src)
		if(G.gadget_skill != skill || G.gadget_kind != kind) continue
		if(G.suffix != "*Equipped*" || G.Uses <= 0) continue
		return G
	return null

mob/LifeGatherQualityChance(skill)
	. = ..()
	var/obj/Items/Gear/Field_Gadget/G = FieldGadgetFor(skill, "quality")
	if(G && G.GadgetSpend(src)) . += GADGET_QUALITY_CHANCE

mob/LifeYieldMult(skill)
	. = ..()
	var/obj/Items/Gear/Field_Gadget/G = FieldGadgetFor(skill, "yield")
	if(G && G.GadgetSpend(src)) . *= GADGET_YIELD_MULT

/obj/Items/Tech/Auto_Sprinkler
	name = "Auto-Sprinkler"
	desc = "Bolt it down among your crops: once a day it waters every planted, living, unripe plot within 4 tiles, whoever owns it. It burns 1 Power Pack a day while bolted down."
	icon = 'Icons/Technology/Tech.dmi'
	icon_state = "Emissor"
	TechType = "Engineering"
	SubType = "Field Gadgets"
	Pickable = 1
	Grabbable = 1
	Attackable = 0
	Destructable = 0
	UpdatesDescription = 1
	dev_hopper = 1
	dev_drain = DEV_PER_DAY(1)

	New()
		..()
		spawn(0)
			if(src && isturf(loc) && !Grabbable) DeviceRegister()

	proc/Update_Description()
		desc = DeviceDescText()

	Click()
		if(loc == usr)
			usr << "Drop [src] where you want it, then click it to bolt it down."
			return
		DeviceMenu(usr)

	DevicePowerChanged(on)
		if(on) SprinklerWater()

	DevicePowerTick(minutes)
		..()
		SprinklerWater()

	DeviceStatus(mob/M)
		. = ..()
		if(DevicePlaced()) . += "Plots in reach: [SprinklerPlots()]."

	proc/SprinklerPlots()
		. = 0
		for(var/obj/LifeSkills/FarmPlot/P in range(SPRINKLER_RADIUS, src))
			if(P.crop_id) .++

	proc/SprinklerWater()
		if(!DevicePlaced() || !DevicePowered()) return 0
		. = 0
		var/today = FarmDay()
		for(var/obj/LifeSkills/FarmPlot/P in range(SPRINKLER_RADIUS, src))
			P.Evaluate()
			if(!P.crop_id || P.wilted || P.Ready() || P.wet_day == today) continue
			P.SetWatered()
			.++
