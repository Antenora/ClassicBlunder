datum/mech_intrinsic_part/PhotonicPowerEngine
	id = "photonic_power_engine"
	name = "Photonic Power Engine"
	description = "Core Slot. 25% more heat capacity, +2 cooling per second, and 20% less heat from energy weaponry and skills."
	slot_family = "Reactor"
	core_tier = 3

	ModifyHeatCapacity(mob/User, obj/Items/Mech/R, amount, list/state)
		return amount * 1.25
	ModifyCooling(mob/User, obj/Items/Mech/R, amount, list/state)
		return amount + 2
	ModifyHeatCost(mob/User, obj/Items/Mech/R, amount, obj/source, list/state)
		if(source && source.IsEnergyHeatSource())
			return amount * 0.8
		return amount

datum/mech_intrinsic_part/SpiralDrive
	id = "spiral_drive"
	name = "Spiral Drive"
	description = "Core Slot. Increases the pilot's Will stat bonus by 25% while piloting."
	slot_family = "Reactor"
	core_tier = 3
	will_bonus_mult = 1.25 // gets boosted by having spiral secret (which you should anyway)


datum/mech_intrinsic_part/GetterRaysCore
	id = "getter_rays_core"
	name = "Getter Rays Core"
	description = "Core Slot. 50% more heat capacity, increased Will stat bonus by Saga Level, but heat gain increases the higher your will."
	slot_family = "Reactor"
	core_tier = 4
	will_bonus_mult = 1.25 //higher saga level = higher bonus

	ModifyHeatCapacity(mob/User, obj/Items/Mech/R, amount, list/state)
		return amount * 1.50
	ModifyHeatCost(mob/User, obj/Items/Mech/R, amount, obj/source, list/state)
		if(!User)
			return amount
		var/will_heat = 1 + max(User.Will - 100, 0) / 100
		return amount * min(will_heat, 2)