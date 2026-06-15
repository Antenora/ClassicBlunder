/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2
    passives = list()
    SignatureTechnique=3
    SpecialSlot=1
    Slotless=0
    Mastery=0
    Copyable=0
    MakesSword=0
    FlashDraw=1
    SwordName="Demon Blade"
    SwordIcon='SwordBroad.dmi'
    StaffName="Demon Rod"
    StaffIcon='MageStaff.dmi'
    ArmorName="Demon Scales"
    ArmorIcon='DevilScale.dmi'
    TextColor="#adf0ff"
    ActiveMessage=null
    OffMessage=null
    var/secondDevilArmPick
    var/selection
    var/totalEvolvesMain = 0
    var/totalEvolvesSecondary = 0
    var/tmp/evolving=0;
    name = "Devil Arm"
    var/SwordIconDT
    var/SwordXDT = 0
    var/SwordYDT = 0
    var/SwordUseUnderDT = 0
    var/SwordIconUnderDT
    var/SwordXUnderDT = 0
    var/SwordYUnderDT = 0
    var/StaffIconDT
    var/StaffXDT = 0
    var/StaffYDT = 0
    var/StaffUseUnderDT = 0
    var/StaffIconUnderDT
    var/StaffXUnderDT = 0
    var/StaffYUnderDT = 0
    var/ArmorIconDT
    var/ArmorXDT = 0
    var/ArmorYDT = 0
    var/ArmorUseUnderDT = 0
    var/ArmorIconUnderDT
    var/ArmorXUnderDT = 0
    var/ArmorYUnderDT = 0
    var/SwordUnderlayStack = 0
    var/StaffUnderlayStack = 0
    var/ArmorUnderlayStack = 0
    var/SwordUnderlayStackDT = 0
    var/StaffUnderlayStackDT = 0
    var/ArmorUnderlayStackDT = 0
    proc/Input_Underlay_Stack(mob/m)
        var/n = input(m, "Depth 0–1000: higher = further back.", "Underlay layer") as num|null
        if(isnull(n))
            return 0
        if(n < 0)
            m << "Layer cannot be negative, using 0."
            n = 0
        else if(n > 1000)
            m << "Capped at 1000."
            n = 1000
        return n
    proc/SyncConjuredItemUnderFromBuff(mob/m, pick)
        switch(pick)
            if("Sword")
                var/obj/Items/Sword/s = m.EquippedSword()
                if(s && s.Conjured)
                    s.UnderlayIcon = SwordIconUnder
                    s.UnderlayX = SwordXUnder
                    s.UnderlayY = SwordYUnder
                    s.UnderlayStack = SwordUnderlayStack
            if("Staff")
                var/obj/Items/Enchantment/Staff/s = m.EquippedStaff()
                if(s && s.Conjured)
                    s.UnderlayIcon = StaffIconUnder
                    s.UnderlayX = StaffXUnder
                    s.UnderlayY = StaffYUnder
                    s.UnderlayStack = StaffUnderlayStack
            if("Armor")
                var/obj/Items/Armor/s = m.EquippedArmor()
                if(s && s.Conjured)
                    s.UnderlayIcon = ArmorIconUnder
                    s.UnderlayX = ArmorXUnder
                    s.UnderlayY = ArmorYUnder
                    s.UnderlayStack = ArmorUnderlayStack
    proc/RefreshConjuredArmAfterUnderChange(mob/m, pick)
        SyncConjuredItemUnderFromBuff(m, pick)
        m.AppearanceOff()
        m.AppearanceOn()
        if(m.isInDemonDevilTrigger())
            applyDTIcons(m)
    verb/Examine_Devil_Arm()
        set src in usr
        var/devilArmDetail = "<html><head><title>Devil Arm Detail ([src.name])</title></head>"
        devilArmDetail += "<body bgcolor=black text=white><table cellspacing=6%>"
        for(var/p in src.passives)
            devilArmDetail += "<tr><td><b>[p]</b></td><td>[src.passives[p]]</td></tr>"
        devilArmDetail += "<tr><td>Main Passives Used: </td><td>[src.totalEvolvesMain]</td></tr>"
        if(usr.isRace(DEMON) || usr.isRace(MAKAIOSHIN))
            devilArmDetail += "<tr><td>Side Passives Used: </td><td>[src.totalEvolvesSecondary]</td></tr>"
        devilArmDetail += "</table></body></html>"
        usr << browse(devilArmDetail, "window=DevilArm;size=350x500");

    verb/Customize_Devil_Arm()
        set src in usr
        var/options = list("Icon", "Name","ActiveMessage", "OffMessage","TextColor")
        var/thing = input(usr, "What do you want to customize?") in options
        if(thing == "Icon")
            var/armPick = input(usr, "Sword, Staff, or Armor Icon?") in list("Sword","Armor","Staff")
            var/icon/newIcon = input(usr, "Change to what?") as icon|null
            if(isnull(newIcon)) return
            var/newX = input(usr, "What is the pixel X?") as num
            var/newY = input(usr, "What is the pixel y?") as num
            switch(armPick)
                if("Sword")
                    SwordIcon = newIcon
                    SwordX = newX
                    SwordY = newY
                if("Staff")
                    StaffIcon = newIcon
                    StaffX = newX
                    StaffY = newY
                if("Armor")
                    ArmorIcon = newIcon
                    ArmorX = newX
                    ArmorY = newY
            var/editUnder = alert(usr, "Would you like to edit [armPick]'s Underlay icon too?", "Devil Arm Underlay", "Yes", "No")
            if(editUnder == "Yes")
                var/underAction = input(usr, "Underlay action?") in list("Set/Change", "Clear", "Keep Existing")
                if(underAction == "Set/Change")
                    var/icon/newUnder = input(usr, "Set [armPick] Underlay icon to what?") as icon|null
                    if(newUnder)
                        var/newUnderX = input(usr, "Underlay pixel X offset?") as num
                        var/newUnderY = input(usr, "Underlay pixel Y offset?") as num
                        var/stackTier = Input_Underlay_Stack(usr)
                        switch(armPick)
                            if("Sword")
                                SwordIconUnder = newUnder
                                SwordXUnder = newUnderX
                                SwordYUnder = newUnderY
                                SwordUnderlayStack = stackTier
                            if("Staff")
                                StaffIconUnder = newUnder
                                StaffXUnder = newUnderX
                                StaffYUnder = newUnderY
                                StaffUnderlayStack = stackTier
                            if("Armor")
                                ArmorIconUnder = newUnder
                                ArmorXUnder = newUnderX
                                ArmorYUnder = newUnderY
                                ArmorUnderlayStack = stackTier
                        RefreshConjuredArmAfterUnderChange(usr, armPick)
                else if(underAction == "Clear")
                    switch(armPick)
                        if("Sword")
                            SwordIconUnder = null
                            SwordXUnder = 0
                            SwordYUnder = 0
                            SwordUnderlayStack = 0
                        if("Staff")
                            StaffIconUnder = null
                            StaffXUnder = 0
                            StaffYUnder = 0
                            StaffUnderlayStack = 0
                        if("Armor")
                            ArmorIconUnder = null
                            ArmorXUnder = 0
                            ArmorYUnder = 0
                            ArmorUnderlayStack = 0
                    RefreshConjuredArmAfterUnderChange(usr, armPick)
        else if(thing == "Name")
            var/armPick = input(usr, "Sword, Staff, or Armor Name?") in list("Sword","Armor","Staff")
            var/newName = input(usr, "Change to what?") as text
            switch(armPick)
                if("Sword")
                    SwordName = newName
                if("Staff")
                    StaffName = newName
                if("Armor")
                    ArmorName = newName
        else if(thing == "TextColor")
            TextColor = input(usr, "Change to what?") as text
        else if(thing == "ActiveMessage")
            ActiveMessage = input(usr, "Change to what?") as message
        else if(thing == "OffMessage")
            OffMessage = input(usr, "Change to what?") as message

    verb/Customize_Devil_Arm_DT()
        set src in usr
        var/pick = input(usr, "Which Devil Arm Devil Trigger icon?") in list("Sword","Staff","Armor")
        var/icon/newDtIcon = input(usr, "Set [pick] Devil Trigger icon to what?") as icon|null
        if(isnull(newDtIcon)) return
        var/newDtX = input(usr, "Pixel X offset?") as num
        var/newDtY = input(usr, "Pixel Y offset?") as num
        switch(pick)
            if("Sword")
                SwordIconDT = newDtIcon
                SwordXDT = newDtX
                SwordYDT = newDtY
            if("Staff")
                StaffIconDT = newDtIcon
                StaffXDT = newDtX
                StaffYDT = newDtY
            if("Armor")
                ArmorIconDT = newDtIcon
                ArmorXDT = newDtX
                ArmorYDT = newDtY

        var/baseUnderExists = FALSE
        switch(pick)
            if("Sword") if(SwordIconUnder) baseUnderExists = TRUE
            if("Staff") if(StaffIconUnder) baseUnderExists = TRUE
            if("Armor") if(ArmorIconUnder) baseUnderExists = TRUE

        if(baseUnderExists)
            var/setUnder = input(usr, "[pick] uses an Under icon. Configure Devil Trigger Under icon?") in list("Set/Change", "Clear", "Keep Existing")
            if(setUnder == "Set/Change")
                var/icon/newDtUnder = input(usr, "Set [pick] Devil Trigger Under icon to what?") as icon|null
                if(newDtUnder)
                    var/newDtUnderX = input(usr, "Under icon pixel X offset?") as num
                    var/newDtUnderY = input(usr, "Under icon pixel Y offset?") as num
                    var/dtStackTier = Input_Underlay_Stack(usr)
                    switch(pick)
                        if("Sword")
                            SwordUseUnderDT = 1
                            SwordIconUnderDT = newDtUnder
                            SwordXUnderDT = newDtUnderX
                            SwordYUnderDT = newDtUnderY
                            SwordUnderlayStackDT = dtStackTier
                        if("Staff")
                            StaffUseUnderDT = 1
                            StaffIconUnderDT = newDtUnder
                            StaffXUnderDT = newDtUnderX
                            StaffYUnderDT = newDtUnderY
                            StaffUnderlayStackDT = dtStackTier
                        if("Armor")
                            ArmorUseUnderDT = 1
                            ArmorIconUnderDT = newDtUnder
                            ArmorXUnderDT = newDtUnderX
                            ArmorYUnderDT = newDtUnderY
                            ArmorUnderlayStackDT = dtStackTier
            else if(setUnder == "Clear")
                switch(pick)
                    if("Sword")
                        SwordUseUnderDT = 0
                        SwordIconUnderDT = null
                        SwordXUnderDT = 0
                        SwordYUnderDT = 0
                        SwordUnderlayStackDT = 0
                    if("Staff")
                        StaffUseUnderDT = 0
                        StaffIconUnderDT = null
                        StaffXUnderDT = 0
                        StaffYUnderDT = 0
                        StaffUnderlayStackDT = 0
                    if("Armor")
                        ArmorUseUnderDT = 0
                        ArmorIconUnderDT = null
                        ArmorXUnderDT = 0
                        ArmorYUnderDT = 0
                        ArmorUnderlayStackDT = 0
        if(usr.BuffOn(src))
            if(usr.isInDemonDevilTrigger())
                applyDTIcons(usr)
            else
                usr.AppearanceOff()
                usr.AppearanceOn()

    proc/swapItemIcon(mob/user, obj/Items/s, newIcon, newX, newY, useUnderOverride = FALSE, newUnderIcon = null, newUnderX = 0, newUnderY = 0, newUnderStack = 0)
        if(!s || !s.suffix || s.loc != user) return
        // Set the underlying equipped item data and let AppearanceOn rebuild overlays.
        s.icon = newIcon
        if(s.EquipIcon)
            s.EquipIcon = newIcon
        s.pixel_x = newX
        s.pixel_y = newY
        if(useUnderOverride)
            s.UnderlayIcon = newUnderIcon
            s.UnderlayX = newUnderX
            s.UnderlayY = newUnderY
            s.UnderlayStack = newUnderStack

    proc/applyDTIcons(mob/user)
        var/willChange = FALSE
        if(SwordIconDT)
            var/obj/Items/Sword/sw = user.EquippedSword()
            if(sw && sw.Conjured) willChange = TRUE
        if(StaffIconDT)
            var/obj/Items/Enchantment/Staff/st = user.EquippedStaff()
            if(st && st.Conjured) willChange = TRUE
        if(ArmorIconDT)
            var/obj/Items/Armor/ar = user.EquippedArmor()
            if(ar && ar.Conjured) willChange = TRUE
        if(willChange)
            user.AppearanceOff()
        if(SwordIconDT)
            var/obj/Items/Sword/s = user.EquippedSword()
            if(s && s.Conjured)
                swapItemIcon(user, s, SwordIconDT, SwordXDT, SwordYDT, SwordUseUnderDT, SwordIconUnderDT, SwordXUnderDT, SwordYUnderDT, SwordUnderlayStackDT)
        if(StaffIconDT)
            var/obj/Items/Enchantment/Staff/s = user.EquippedStaff()
            if(s && s.Conjured)
                swapItemIcon(user, s, StaffIconDT, StaffXDT, StaffYDT, StaffUseUnderDT, StaffIconUnderDT, StaffXUnderDT, StaffYUnderDT, StaffUnderlayStackDT)
        if(ArmorIconDT)
            var/obj/Items/Armor/s = user.EquippedArmor()
            if(s && s.Conjured)
                swapItemIcon(user, s, ArmorIconDT, ArmorXDT, ArmorYDT, ArmorUseUnderDT, ArmorIconUnderDT, ArmorXUnderDT, ArmorYUnderDT, ArmorUnderlayStackDT)
        if(willChange)
            user.AppearanceOn()

    proc/revertDTIcons(mob/user)
        var/willChange = FALSE
        if(SwordIconDT)
            var/obj/Items/Sword/sw = user.EquippedSword()
            if(sw && sw.Conjured) willChange = TRUE
        if(StaffIconDT)
            var/obj/Items/Enchantment/Staff/st = user.EquippedStaff()
            if(st && st.Conjured) willChange = TRUE
        if(ArmorIconDT)
            var/obj/Items/Armor/ar = user.EquippedArmor()
            if(ar && ar.Conjured) willChange = TRUE
        if(willChange)
            user.AppearanceOff()
        if(SwordIconDT)
            var/obj/Items/Sword/s = user.EquippedSword()
            if(s && s.Conjured)
                swapItemIcon(user, s, SwordIcon, SwordX, SwordY, TRUE, SwordIconUnder, SwordXUnder, SwordYUnder, SwordUnderlayStack)
        if(StaffIconDT)
            var/obj/Items/Enchantment/Staff/s = user.EquippedStaff()
            if(s && s.Conjured)
                swapItemIcon(user, s, StaffIcon, StaffX, StaffY, TRUE, StaffIconUnder, StaffXUnder, StaffYUnder, StaffUnderlayStack)
        if(ArmorIconDT)
            var/obj/Items/Armor/s = user.EquippedArmor()
            if(s && s.Conjured)
                swapItemIcon(user, s, ArmorIcon, ArmorX, ArmorY, TRUE, ArmorIconUnder, ArmorXUnder, ArmorYUnder, ArmorUnderlayStack)
        if(willChange)
            user.AppearanceOn()

    proc/checkEvolve(mob/p)
        if(totalEvolvesMain < p.race?:devil_arm_upgrades)
            return TRUE
        if(totalEvolvesSecondary < p.race?:sub_devil_arm_upgrades)
            return TRUE
        return FALSE
    adjust(mob/p)
        if(!altered)
            SpecialSlot=1
            Slotless=0
        if(passives["CriticalChance"]>30)
            passives["CriticalChance"]=30
            passives["CriticalDamage"]=0.15
        if(passives["BlockChance"]>30)
            passives["BlockChance"]=30
            passives["CriticalBlock"]=0.15
        switch(selection)
            if("Sword")
                passives["SwordAscension"] = p.AscensionsAcquired + 1
            if("Staff")
                passives["StaffAscension"] = p.AscensionsAcquired + 1
            if("Unarmed")
                passives["UnarmedDamage"] = p.AscensionsAcquired + 1
        switch(secondDevilArmPick)
            if("Armor")
                passives["ArmorAscension"] = p.AscensionsAcquired + 1
            if("Sword")
                passives["SwordAscension"] = p.AscensionsAcquired + 1
            if("Staff")
                passives["StaffAscension"] = p.AscensionsAcquired + 1
            if("Unarmed")
                passives["UnarmedDamage"] = p.AscensionsAcquired + 1
        ElementalOffense = "HellFire"
    verb/Devil_Arm()
        set category = "Skills"
        if(!usr.BuffOn(src) && checkEvolve(usr) )
            if(usr.isRace(DEMON) || usr.isRace(MAKAIOSHIN))
                evolve(usr)
                usr << "Activate again after."
                return
        if(!selection)
            pickSelection(usr)
        if(!usr.BuffOn(src))
            adjust(usr)
        src.Trigger(usr)
        if(usr.BuffOn(src) && usr.isInDevilTriggerLikeForm())
            applyDTIcons(usr)

    proc/checkPassiveAmt(list/theList, input)
        if(passives["[input]"])
            if(passives["[input]"] + theList[input][1] > theList[input][2])
                return FALSE
        return TRUE;
    proc/handlePassive(list/theList, input)
        . = TRUE

        if(checkPassiveAmt(theList, input))
            switch(input)
                if("CriticalChance")
                    passives["[input]"] += theList[input][1]
                    passives["CriticalDamage"] += 0.05
                    return
                if("BlockChance")
                    passives["[input]"] += theList[input][1]
                    passives["CriticalBlock"] += 0.05
                    return
            passives["[input]"] += theList[input][1]
        else
            . = FALSE


    proc/pickSelection(mob/p, secondary = FALSE)
        var/select
        if(secondary)
            var/list/choices = list("Staff", "Sword", "Unarmed","Armor");
            choices.Remove(selection);
            secondDevilArmPick = input(p, "What thing?") in choices;
            select = secondDevilArmPick;
        else
            selection = input(p, "What thing?") in list("Staff", "Sword", "Unarmed")
            select = selection
        if(select != "Unarmed")
            vars["Makes[select]"] = 1
            if(select=="Sword") MakesSword = 3;
        vars["[select]Name"] = input(p, "Change name to what?") as text
        var/class
        if(select != "Unarmed")
            if(select == "Staff")
                class = input(p, "What thing?") in list("Wand", "Rod", "Staff")
            else
                class = input(p, "What thing?") in list("Light", "Medium", "Heavy")
            vars["[select]Class"] = class
            var/icon/i = input(p, "Set appearance to what?") as icon|null
            if(!i)
                return
            var/iconX = input(p, "What is the pixel X?") as num
            var/iconY = input(p, "What is the pixel y?") as num
            switch(select)
                if("Sword")
                    SwordIcon = i
                    SwordX = iconX
                    SwordY = iconY
                if("Staff")
                    StaffIcon = i
                    StaffX = iconX
                    StaffY = iconY
                if("Armor")
                    ArmorIcon = i
                    ArmorX = iconX
                    ArmorY = iconY
    proc/pickPassive(mob/p, list/choices, list/mainData, secondary = FALSE)
        var/correct = FALSE
        var/attempts = 0
        for(var/d in choices)//hopefully remove passives before they fail
            if(!checkPassiveAmt(mainData, d)) choices.Remove(d);
        while(correct == FALSE)
            var/passive = input(p, "What passive?  [secondary == FALSE ? "Main Branch - [selection] \n([totalEvolvesMain] / [p.race?:devil_arm_upgrades] passives picked)" : "Side Branch - [secondDevilArmPick] \n([totalEvolvesSecondary] / [p.race?:sub_devil_arm_upgrades] passives picked)"]") in choices
            if(attempts >=3)
                p << "You tried too many times, alert an admin"
                break
            if(!handlePassive(mainData, passive))
                p << "Too much passive value"
                choices -= passive
                correct = FALSE // have them go again
            else
                correct = TRUE
            attempts++

    proc/getSelectionTypeKey(sel)
        switch(sel)
            if("Sword")   return "SWORD_PASSIVES"
            if("Staff")   return "STAFF_PASSIVES"
            if("Unarmed") return "UNARMED_PASSIVES"
            if("Armor")   return "ARMOR_PASSIVES"
        return null

    proc/evolve(mob/p)
        if(evolving) return
        evolving=1;
        if(!selection)
            pickSelection(p, FALSE)
        if(!secondDevilArmPick && p.Potential >= ASCENSION_TWO_POTENTIAL)
            pickSelection(p, TRUE);
            p.checkDevilArmUpgrades();
        if(!p.BuffOn(src))
            if(totalEvolvesMain < p.race?:devil_arm_upgrades)
                p << "Evolving Main Branch for the [totalEvolvesMain+1]\th step..."
                var/mainType = getSelectionTypeKey(selection)
                if(!mainType)
                    evolving=0;
                    p << "Invalid devil arm selection '[selection]'"
                    return
                var/list/data = getJSONInfo(getPassiveTier(p, totalEvolvesMain), "GENERIC_PASSIVES")
                var/list/selectionData = getJSONInfo(getPassiveTier(p, totalEvolvesMain), mainType)
                for(var/k in selectionData)
                    data[k] = selectionData[k]
                var/list/choices = list()
                for(var/a in data)
                    if(islist(data[a]))
                        choices += "[a]"
                if(choices.len < 1)
                    evolving=0;
                    p << "The list of passives could not generate for your Main Branch ([selection])"
                    return;
                pickPassive(p, choices, data, FALSE)
                totalEvolvesMain++
            if(secondDevilArmPick && totalEvolvesSecondary < p.race?:sub_devil_arm_upgrades)
                p << "Evolving Side Branch for the [totalEvolvesSecondary+1]\th step..."
                var/secondType = getSelectionTypeKey(secondDevilArmPick)
                if(!secondType)
                    evolving=0;
                    p << "Invalid secondary devil arm selection '[secondDevilArmPick]'"
                    return
                var/list/secondaryData = getJSONInfo(getPassiveTier(p, totalEvolvesSecondary, TRUE), secondType)
                var/list/secondChoices = list()
                for(var/a in secondaryData)
                    if(islist(secondaryData[a]))
                        secondChoices += "[a]"
                if(secondChoices.len < 1)
                    evolving=0;
                    p << "The list of passives could not generate for your Side Branch ([secondDevilArmPick])"
                    return;
                pickPassive(p, secondChoices, secondaryData, TRUE)
                totalEvolvesSecondary++
        evolving=0;

/mob/proc/checkDevilArmUpgrades()
    var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/da = FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2)
    var/max = round(Potential / 5) + 1
    var/max2 = round(Potential / 10) + 1
    if(race?:devil_arm_upgrades < max)
        if(race?:devil_arm_upgrades + 1 > max) // not even possible
            return
        race?:devil_arm_upgrades = max
        src << "Your devil arm evolves, toggle it on and off to use it"
    if(da.secondDevilArmPick)
        if(race?:sub_devil_arm_upgrades < max2)
            if(race?:sub_devil_arm_upgrades + 1 > max2)
                return
            race?:sub_devil_arm_upgrades = max2
            src << "Your secondary devil arm evolves, toggle it on and off to use it"
