/obj/Items/
	var/Augmented = 0
	// Techniques = list( new/obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear, new/obj/Skills/Buffs/SlotlessBuffs/Posture)

/obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear
	// a template for whatever variabled are enabled on the base item ag
	// this is the base buff that is applied to the player when they equip the item
	ActiveMessage = "'s gear hums with power."
	OffMessage = "'s gear stops humming."
	verb/Augmented_Gear()
		set category="Skills"
		src.Trigger(usr)


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Augmented_Gear
	ActiveMessage = "'s gear overflows them with power!"
	OffMessage = "'s gear stops overflowing them with power."

