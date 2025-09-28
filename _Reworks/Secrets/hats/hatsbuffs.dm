// Gravity = waterwalk+godspeed+likewater+fluiodform


/obj/Skills/Buffs/SlotlessBuffs/Spirits/Base_Hat_Buff
    passives = list("MartialMagic" = 1, "Gravity" = 1)
    var/hat_name
    proc/getChildBoons(mob/p)
        passives = p.secretDatum:applyPassives(p)
        hat_name = "[replacetext("[p.secretDatum.type]", "/SecretInfomation/Spirits_Of_The_World/", "")]"
    proc/setup_visuals()
        if(!IconLock)
            switch(hat_name)
                if("Goetic_Virtue")
                    IconLock= 'WitchHatBLACK.dmi'
                    LockX = -32
                    LockY = -32
                if("Stellar_Constellation")
                    IconLock = 'Witch Hat White.dmi'
                    LockX = -16
                    LockY = -18
                if("Elven_Sanctuary")
                    IconLock = 'green_hat.dmi'
                    LockX = -32
                    LockY = -32
    adjust(mob/p)
        getChildBoons(p)
        if(altered) return
        var/secretLevel = p.getSecretLevel()
        var/pot = p.Potential
        if(p.Class != "Yokai")
            passives["ManaStats"] = 0.25 * secretLevel + (0.01 * pot) // 0.25 per tier + 0.1 per 10 potential
            passives["ManaCapMult"] = 0.2 * secretLevel + (0.01 * pot) // 0.2 per tier + 0.1 per 10 potential
        passives["ManaSteal"] = 5 + (0.5 * pot + (5 * secretLevel)) // max 50% of dmg as mana back @ 50 pot, 80 @ 100
        strAdd = (0.05 * secretLevel) + (0.005 * pot)
        forAdd = (0.05 * secretLevel) + (0.005 * pot)
        setup_visuals()

    verb/Hat_Buff()
        set category = "Skills"
        set name = "Spirit Buff"
        src.Trigger(usr)
        usr << "You feel a surge of power from your hat!"