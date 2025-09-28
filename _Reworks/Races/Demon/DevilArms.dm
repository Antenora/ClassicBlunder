/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2
    passives = list()
    SignatureTechnique=3
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

    name = "Devil Arm"


    verb/Customize_Devil_Arm()
        var/options = list("Icon", "Name","ActiveMessage", "OffMessage","TextColor")
        if(selection == "Unarmed")
            options -= "Icon"
        var/thing = input(usr, "What do you want to customize?") in options
        if(thing == "Icon")
            var/selection = input(usr, "Sword, Staff, or Armor Icon?") in list("Sword","Armor","Staff")
            vars["[selection][thing]"] = input(usr, "Change to what?") as icon | null
            vars["[selection]X"] = input(usr, "What is the pixel X?") as num
            vars["[selection]Y"] = input(usr, "What is the pixel y?") as num
        else if("Name")
            vars["[selection][thing]"] = input(usr, "Change to what?") as text
        else
            vars["[thing]"] = input(usr, "Change to what?") as message

    proc/checkEvolve(mob/p)
        if(totalEvolvesMain < p.race?:devil_arm_upgrades)
            return TRUE
        if(totalEvolvesSecondary < p.race?:sub_devil_arm_upgrades)
            return TRUE
        return FALSE
    adjust(mob/p)
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
        if(!usr.isRace(DEMON) && glob.DEVILARMDEMONONLY) return
        if(!usr.BuffOn(src) && checkEvolve(usr) )
            evolve(usr)
            usr << "Activate again after."
            return
        if(!selection)
            pickSelection(usr)
        if(!usr.BuffOn(src))
            adjust(usr)
        src.Trigger(usr)

    proc/handlePassive(list/theList, input, secondary)
        . = TRUE

        if(passives["[input]"])
            if(passives["[input]"] + theList[input][1] > theList[input][2])
                return FALSE
            switch(input)
                if("CriticalChance")
                    passives["[input]"] += theList[input][1]
                    passives["CriticalDamage"] += 0.1
                    return
                if("BlockChance")
                    passives["[input]"] += theList[input][1]
                    passives["CriticalDamage"] += 0.1
                    return
            passives["[input]"] += theList[input][1]
        else
            passives["[input]"] = theList[input][1]


    proc/pickSelection(mob/p, secondary = FALSE)
        var/select
        if(secondary)
            secondDevilArmPick = input(p, "What thing?") in list("Staff", "Sword", "Unarmed","Armor") - selection
            select = secondDevilArmPick
        else
            selection = input(p, "What thing?") in list("Staff", "Sword", "Unarmed")
            select = selection
        if(select != "Unarmed")
            vars["Makes[select]"] = 1
        var/class
        vars["[select]Name"] = input(p, "Change name to what?") as text
        if(select != "Unarmed")
            if(select == "Staff")
                class = input(p, "What thing?") in list("Wand", "Rod", "Staff")
            else
                class = input(p, "What thing?") in list("Light", "Medium", "Heavy")
            vars["[select]Class"] = class
            vars["[select]Icon"] = input(p, "Change name to what?") as icon | null
            vars["[select]X"] = input(p, "What is the pixel X?") as num
            vars["[select]Y"] = input(p, "What is the pixel y?") as num
    proc/pickPassive(mob/p, list/choices, list/mainData, secondary = FALSE)
        var/correct = FALSE
        var/attempts = 0
        while(correct == FALSE)
            var/passive = input(p, "What passive? ([secondary == FALSE ? "Main Branch" : "Side Branch"])") in choices
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

    proc/evolve(mob/p)
        if(!selection)
            pickSelection(p, FALSE)
        if(!p.BuffOn(src))
            var/race/demon/r = p.race
            if(totalEvolvesMain < r.devil_arm_upgrades)
                var/list/data = getJSONInfo(getPassiveTier(p), "GENERIC_PASSIVES")
                data.Add(getJSONInfo(getPassiveTier(p), "[uppertext(selection)]_PASSIVES"))
                var/choices = list()
                for(var/a in data)
                    choices += "[a]"
                pickPassive(p, choices, data, FALSE)
                totalEvolvesMain++
            if(totalEvolvesSecondary < r.sub_devil_arm_upgrades)
                var/list/secondaryData
                secondaryData = getJSONInfo(getPassiveTier(p), "[uppertext(secondDevilArmPick)]_PASSIVES")
                var/secondChoices = list()
                for(var/a in secondaryData)
                    secondChoices += "[a]"
                if(r.sub_devil_arm_upgrades)
                    pickPassive(p, secondChoices, secondaryData, TRUE)
                    totalEvolvesSecondary++


