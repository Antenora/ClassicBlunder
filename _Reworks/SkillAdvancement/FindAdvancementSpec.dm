var/list/ScalingSignatures = list(/obj/Skills/Buffs/SpecialBuffs/Cursed/Jagan_Eye = /advanceSpecs/JaganEye);

obj/Skills
    New()
        ..()
        AssignSpecialAdvanceData()

    proc
        AssignSpecialAdvanceData()
            if(type in ScalingSignatures)
                var/advDataType = ScalingSignatures[type];
                advanceData = new advDataType;