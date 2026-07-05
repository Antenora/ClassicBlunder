/mob/proc/
    HakiArmamentOn()
        if(!CheckSlotless("Haki Armament"))
            for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armament/H in src)
                H.Trigger(src, Override=1);
    HakiArmamentOff()
        if(CheckSlotless("Haki Armament"))
            for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armament/H in src)
                H.Trigger(src, Override=1);
    HakiObservationOn()
        if(!CheckSlotless("Haki Observation"))
            for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Observation/H in src)
                H.Trigger(src, Override=1);
    HakiObservationOff()
        if(CheckSlotless("Haki Observation"))
            for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Observation/H in src)
                H.Trigger(src, Override=1);
