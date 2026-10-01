//SUPER

//Getter Robo
obj/Skills/Buffs/SlotlessBuffs
	Change_Dragon
		BuffName="Change: Dragon!"
		FocusShifter=1
		FocusShiftType="STR"
		FocusShiftBoost=1.5
		Cooldown = 1
		MechCompatible = 1
		ActiveMessage="enters their Dragon formation, prioritizing their offensive!"
		OffMessage="switches out of the Dragon formation."
		adjust(mob/p)
			StrMult = 1.20
			ForMult = 1.05
			EndMult = 0.90
			OffMult = 1.30
			DefMult = 0.90
			SpdMult = 1.10
			passives = list("")
		verb/Change_Dragon()
			set category="Skills"
			if(usr.CheckSlotless("Change: Liger!"))
				var/obj/Skills/Buffs/SlotlessBuffs/Change_Liger/cb = locate(/obj/Skills/Buffs/SlotlessBuffs/Change_Liger) in usr.contents
				cb.Trigger(usr)
			src.Trigger(usr)
			if(usr.CheckSlotless("Change: Poseidon!"))
				var/obj/Skills/Buffs/SlotlessBuffs/Change_Poseidon/cb = locate(/obj/Skills/Buffs/SlotlessBuffs/Change_Poseidon) in usr.contents
				cb.Trigger(usr)
			src.Trigger(usr)

	Change_Liger
		BuffName="Change: Liger!"
		FocusShifter=1
		FocusShiftType="FOR"
		FocusShiftBoost=1.5
		Cooldown = 1
		MechCompatible = 1
		ActiveMessage="enters their Liger formation, prioritizing their speed!"
		OffMessage="switches out of the Liger formation."
		adjust(mob/p)
			StrMult = 1.05
			ForMult = 1.15
			EndMult = 0.80
			OffMult = 1.10
			DefMult = 0.90
			SpdMult = 1.30
			passives = list("")
		verb/Change_Liger()
			set category="Skills"
			if(usr.CheckSlotless("Change: Liger!"))
				var/obj/Skills/Buffs/SlotlessBuffs/Change_Liger/cb = locate(/obj/Skills/Buffs/SlotlessBuffs/Change_Liger) in usr.contents
				cb.Trigger(usr)
			src.Trigger(usr)
			if(usr.CheckSlotless("Change: Poseidon!"))
				var/obj/Skills/Buffs/SlotlessBuffs/Change_Poseidon/cb = locate(/obj/Skills/Buffs/SlotlessBuffs/Change_Poseidon) in usr.contents
				cb.Trigger(usr)
			src.Trigger(usr)

	Change_Poseidon
		BuffName="Change: Poseidon!"
		FocusShifter=1
		FocusShiftType="STR"
		FocusShiftBoost=1.5
		Cooldown = 1
		MechCompatible = 1
		ActiveMessage="enters their Poseidon formation, prioritizing their defense!"
		OffMessage="switches out of the Poseidon formation."
		adjust(mob/p)
			StrMult = 1.20
			ForMult = 1.15
			EndMult = 1.30
			OffMult = 1.30
			DefMult = 1.30
			SpdMult = 1.10
			passives = list("")
		verb/Change_Poseidon()
			set category="Skills"
			if(usr.CheckSlotless("Change: Liger!"))
				var/obj/Skills/Buffs/SlotlessBuffs/Change_Liger/cb = locate(/obj/Skills/Buffs/SlotlessBuffs/Change_Liger) in usr.contents
				cb.Trigger(usr)
			src.Trigger(usr)
			if(usr.CheckSlotless("Change: Poseidon!"))
				var/obj/Skills/Buffs/SlotlessBuffs/Change_Poseidon/cb = locate(/obj/Skills/Buffs/SlotlessBuffs/Change_Poseidon) in usr.contents
				cb.Trigger(usr)
			src.Trigger(usr)