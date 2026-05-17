#define BASE_INKWORKS_SLOTS 1


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Inscribed_Ink
/mob/var/InkworkSlots = 1 // The Total amount of Inkworks this mob supports
/mob/var/InkworksTier = 0 // Their Tier in the Inkworks Knowledge subtree
/mob/proc/calculateInkworksSlots() // Doing the actual math for InkworksSlots as we cannot initiate with this calculation
    return BASE_INKWORKS_SLOTS + InkworksTier

