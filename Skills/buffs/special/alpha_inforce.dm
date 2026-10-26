/obj/Skills/Buffs/SpecialBuffs/Alpha_inForce
	BuffName = "Alpha inForce"
	SpecialSlot = 0
	Slotless = 1
	NeedsSword = 1
	NoStaff = 1
	passives = list("Knight of the Empty Seat" = 1, "CriticalDamage" = 0.15, "Momentum" = 2, "QuickCast" = 5, "ManaSteal" = 25, "ManaGeneration" = 5)
	verb/Alpha_inForce()
		set category = "Skills"
		set hidden = 1
		src.Trigger(usr)
