#define TRUTH_PASSIVES_ASC_1 list("Extend" = 1, "BlurringStrikes" = 0.5, "QuickCast" = 1, "MovingCharge" = 1)
#define TRUTH_PASSIVES_ASC_2 list("Duelist" = 1, "Deflection" = 1, "HybridStrike" = 1.5, "ManaSteal" = 25)
#define TRUTH_PASSIVES_ASC_3 list("ManaStats" = 0.25, "Steady" = 2)


/obj/Skills/Buffs/SlotlessBuffs/Elf/God_Slicer
    // a spirit-sword esque buff
    MakesSword=3
    FlashDraw=1
    SwordName="God Slicer"
    SwordIcon='Ki-Blade.dmi'
    var/truthPassives = list()
    var/truthApplied = 0
    SwordAscension=2
    SwordNameSecond="God Slicer"
    SwordIconSecond='Aether Blade Alternate.dmi'
    SwordAscensionSecond=2
    SwordXSecond=-32
    SwordYSecond=-32
    MagicSword=1
    MagicSwordSecond = 1
    MagicSwordThird = 1
    SwordNameThird="God Slicer"
    SwordAscensionThird=2
    ActiveMessage="draws spirit energy into their hand to form a blade!"
    OffMessage="dispels their God Slicer!"
    verb/Transfigure_God_Slicer()
        set category="Utility"
        var/Choice
        if(!usr.BuffOn(src))
            var/modify_sword_num = 1
            if((locate(/obj/Skills/Buffs/NuStyle/SwordStyle/Nito_Ichi_Style) in usr) || (locate(/obj/Skills/Buffs/NuStyle/SwordStyle/Santoryu) in usr))
                var/list/options = list("Primary","Secondary")
                if((locate(/obj/Skills/Buffs/NuStyle/SwordStyle/Santoryu) in usr)) options += "Tertiary"
                switch(input("Which sword would you like to modify?") in options)
                    if("Secondary") modify_sword_num=2
                    if("Tertiary") modify_sword_num=3
            var/Lock=alert(usr, "Do you wish to alter the icon used?", "Weapon Icon", "No", "Yes")
            if(Lock=="Yes")
                switch(modify_sword_num)
                    if(1)
                        src.SwordIcon=input(usr, "What icon will your God Slicer use?", "God Slicer Icon") as icon|null
                        src.SwordX=input(usr, "Pixel X offset.", "God Slicer Icon") as num
                        src.SwordY=input(usr, "Pixel Y offset.", "God Slicer Icon") as num
                    if(2)
                        src.SwordIconSecond=input(usr, "What icon will your God Slicer use?", "God Slicer Icon") as icon|null
                        src.SwordXSecond=input(usr, "Pixel X offset.", "God Slicer Icon") as num
                        src.SwordYSecond=input(usr, "Pixel Y offset.", "God Slicer Icon") as num
                    if(3)
                        src.SwordIconThird=input(usr, "What icon will your God Slicer use?", "God Slicer Icon") as icon|null
                        src.SwordXThird=input(usr, "Pixel X offset.", "God Slicer Icon") as num
                        src.SwordYThird=input(usr, "Pixel Y offset.", "God Slicer Icon") as num
            Choice=input(usr, "What class of blade do you want your God Slicer to be?", "Transfigure God Slicer") in list("God Split Cut", "God Slicer", "Violent Fierce God Slicer", "Azure Dragon Sword")
            switch(Choice)
                if("God Split Cut")
                    switch(modify_sword_num)
                        if(1) src.SwordClass="Wooden"
                        if(2) src.SwordClassSecond="Wooden"
                        if(3) src.SwordClassThird="Wooden"
                if("God Slicer")
                    switch(modify_sword_num)
                        if(1) src.SwordClass="Light"
                        if(2) src.SwordClassSecond="Light"
                        if(3) src.SwordClassThird="Light"
                if("Violent Fierce God Slicer")
                    switch(modify_sword_num)
                        if(1) src.SwordClass="Medium"
                        if(2) src.SwordClassSecond="Medium"
                        if(3) src.SwordClassThird="Medium"
                if("Azure Dragon Sword")
                    switch(modify_sword_num)
                        if(1) src.SwordClass="Heavy"
                        if(2) src.SwordClassSecond="Heavy"
                        if(3) src.SwordClassThird="Heavy"
            usr << "God Slicer class set as [Choice]!"
        else
            usr << "You can't set this while using God Slicer."
    
    proc/checkTruth(mob/p)
        if(truthApplied >= p.AscensionsAcquired + 1)
            return TRUE
        return FALSE

    proc/truthChoice(mob/p)
        if(!checkTruth(p))
            // apply it here
            for(var/x in 1 to p.AscensionsAcquired)
                switch(p.AscensionsAcquired) // ghetto application
                    if(0) 
                        if(truthApplied != 0) break
                        var/passive = input(p, "what passive") in TRUTH_PASSIVES_ASC_1
                        truthPassives += TRUTH_PASSIVES_ASC_1[passive]
                        truthApplied = 1
                    if(1)
                        if(truthApplied != 1) break
                        var/passive = input(p, "what passive") in TRUTH_PASSIVES_ASC_1
                        truthPassives += TRUTH_PASSIVES_ASC_1[passive]
                        truthApplied = 2
                    if(2)
                        if(truthApplied != 2) break
                        var/passive = input(p, "what passive") in TRUTH_PASSIVES_ASC_2
                        truthPassives += TRUTH_PASSIVES_ASC_2[passive]
                        truthApplied = 3
                    if(3)
                        if(truthApplied != 3) break
                        var/passive = input(p, "what passive") in TRUTH_PASSIVES_ASC_3
                        truthPassives += TRUTH_PASSIVES_ASC_3[passive]
                        truthApplied = 4
    adjust(mob/p, )
        truthChoice(p)
        var/asc = p.AscensionsAcquired
        passives = list("SpiritSword" = (1 + (asc/2)) / 4, "MagicSword" = 1)
        for(var/x in truthPassives)
            passives[x] = truthPassives[x]
        SwordAscension = asc 
        SwordAscensionSecond = asc 
        SwordAscensionThird = asc 
        ElementalOffense = "Truth"
    verb/God_Slicer()
        set category="Skills"
        if(!usr.BuffOn(src))
            adjust(usr)
        src.Trigger(usr)

    
