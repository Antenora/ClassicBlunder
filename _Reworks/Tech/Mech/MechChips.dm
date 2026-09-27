#define MECH_BEACON_PERIOD 3000
#define MECH_BEACON_STEP 50

/obj/Items/Chip/System/Mech_Alarm
	name = "Mech Alarm"
	ModuleKey = "Mech Alarm"
	ChipFamily = "Mech"
	desc = "A theft alarm for a mech's chip socket. When someone starts hacking the parked mech, its builder's Communicator hears about it, and again when the hack fails or goes through. It fits only a mech, socketed at a Mech Bay."

	ChipBlock(mob/M, short)
		return short ? "mech only" : "The [name] only fits a mech's chip socket."

/obj/Items/Chip/System/Mech_Beacon
	name = "Mech Beacon"
	ModuleKey = "Mech Beacon"
	ChipFamily = "Mech"
	desc = "A tracking beacon for a mech's chip socket. While anyone but the builder has the mech out, the builder's Communicator gets its position every 5 minutes. It comes out only through Pull Beacon at a Mech Bay, and pulling it tells the builder one last time."

	ChipBlock(mob/M, short)
		return short ? "mech only" : "The [name] only fits a mech's chip socket."

/obj/Items/Mech/MechChipFits(obj/Items/Chip/C)
	if(istype(C) && C.ChipFamily == "Mech")
		return (socket_chips && (C.type in socket_chips)) ? 0 : 1
	return ..()

/obj/Items/Mech/proc/MechHasChip(path)
	return (socket_chips && (path in socket_chips)) ? 1 : 0
