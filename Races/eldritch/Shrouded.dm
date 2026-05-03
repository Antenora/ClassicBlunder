/mob/proc/selectShroudedStyle()
    var/list/ShroudedRaces=list("Nevermind", "Saiyan", "Human", "Beastkin", "Namekian");
    var/choice = input(src, "Every Shrouded Eldritch has a race that they were before they were cast through the Sea of Darkness. What was your vessel's origin?", "Shrouded Style") in ShroudedRaces;
    if(choice=="Nevermind") return;
    src << "You remember your Origin that has been Shrouded: That of a <b>[choice]</b>...";
    switch(choice)
        if("Beastkin")
            EnhancedSmell=1;
            EnhancedHearing=1;
            src << "Your senses sharpen!"
        if("Saiyan")
            passive_handler.passives["ZenkaiPower"] = 0.5;
            src << "Your power rises in response to stress!"
        if("Human")
            RPPMult=1.35;
            src << "You're better at learning!"
        if("Namekian")
            var/obj/Skills/Buffs/SlotlessBuffs/Regeneration/r = findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Regeneration)
            r.HealthHeal *= 2;
            src << "Your regeneration is stronger!"
    setShroudedOrigin(choice);

/mob/proc/setShroudedOrigin(race)
    var/SecretInformation/EldritchShrouded/es = GetShroudedDatum()
    if(es) es.ShroudedOrigin = race;

/mob/proc/GetShroudedDatum()
    if(!hasSecret("Eldritch (Shrouded)")) return 0;
    return secretDatum;

/mob/proc/setShroudedStyle()//ShroudedPassives are used in the AddStyleBuff and SubStyleBuff procs
    var/SecretInformation/EldritchShrouded/es = GetShroudedDatum()
    if(es)
        if(!es.ShroudedOrigin) selectShroudedStyle();
        if(es.currentTier >= 1)
            switch(es.ShroudedOrigin)
                if("Beastkin")
                    es.ShroudedPassives["DoubleStrike"]=1;
                    es.ShroudedPassives["Pressure"]=1;
                    es.ShroudedPassives["Fury"]=1;
                    es.ShroudedPassives["Momentum"]=1;
                if("Human")
                    es.ShroudedPassives["Tenacity"]=1;
                    es.ShroudedPassives["Shonen"]=1;
                    es.ShroudedPassives["ShonenPower"]=0.5;
                    es.ShroudedPassives["Persistence"]=1;
                if("Saiyan")
                    es.ShroudedPassives["Steady"]=1;
                    es.ShroudedPassives["PureDamage"]=1;
                    es.ShroudedPassives["PureReduction"]=1;
                    es.ShroudedPassives["Brutalize"]=1;
                if("Namekian")
                    es.ShroudedPassives["SpiritSword"]=1;
                    es.ShroudedPassives["SpiritFlow"]=1;
                    es.ShroudedPassives["TechniqueMastery"]=1;
                    es.ShroudedPassives["Pursuer"]=1;
        if(es.currentTier >= 2)
            if(!es.ShroudedSubtype)
                switch(es.ShroudedOrigin)
                    if("Beastkin")
                        es.ShroudedSubtype = input(src, "You've awakened to a deeper understanding of your Origin. But what Origin was it?", "Origin Enhancement") in list("Feathers", "Heart", "Predator")
                    if("Human")
                        es.ShroudedSubtype = input(src, "You've awakened to a deeper understanding of your Origin. But what Origin was it?", "Origin Enhancement") in list("Heroism", "Resourceful", "Dogged")
                        switch(es.ShroudedSubtype)
                            if("Resourceful")
                                AngerMax -= 0.25;
                                Intelligence *= 1.5;
                                EconomyMult *= 1.5;
                            if("Dogged")
                                AngerMax += 0.5;
                    if("Saiyan")
                        es.ShroudedSubtype = input(src, "You've awakened to a deeper understanding of your Origin. But what Origin was it?", "Origin Enhancement") in list("Honor", "Zeal", "Pride")
                    if("Namekian")
                        es.ShroudedSubtype = input(src, "You've awakened to a deeper understanding of your Origin. But what Origin was it?", "Origin Enhancement") in list("Warrior", "Dragon", "Demon")
            switch(es.ShroudedSubtype)
                if("Feathers")
                    es.ShroudedPassives["CriticalChance"] = 10;
                    es.ShroudedPassives["CriticalDamage"] = 0.2;
                    es.ShroudedPassives["CriticalBlock"] = 10;
                    es.ShroudedPassives["BlockDamage"] = 0.2;
                if("Heart")
                    es.ShroudedPassives["Harden"] = 2;
                    es.ShroudedPassives["CallousedHands"] = 0.2;
                    es.ShroudedPassives["Adrenaline"] = 1;
                if("Predator")
                    es.ShroudedPassives["Steady"] = 2;
                    es.ShroudedPassives["Brutalize"] = 2;
                    es.ShroudedPassives["Unnerve"] = 1;
                if("Heroism")
                    es.ShroudedPassives["BuffMastery"] = 10;
                    es.ShroudedPassives["ShonenPower"] = 0.5;
                    es.ShroudedPassives["Persistence"] = 3;
                if("Resourceful")
                    es.ShroudedPassives["GodSpeed"] = 4;
                if("Dogged")
                    es.ShroudedPassives["Motivation"] = 0.25;
                if("Honor") src << "oops"
                if("Zeal") src << "oops"
                if("Pride") src << "oops"
                if("Warrior") src << "oops"
                if("Dragon") src << "oops"
                if("Demon") src << "oops"

        //t6 later (something unique)
                

/mob/var
    TetherPacted=0;
    TetherPactOwner;
    list/TetherPacts=list();

/mob/proc/getShadowEyeTargets()//if they're within view x asc, you can see them
    var/list/who = list();
    var/shadowRange = (50 * secretDatum.currentTier);
    for(var/mob/Players/M in view(shadowRange, src))
        who |= M;
    for(var/mob/W in view(shadowRange, src))
        if(W.AdminInviso)
            who.Remove(W)
        if(W.invisibility)
            who.Remove(W)
    return who;
/mob/proc/getAdvancedShadowEyeTargets()//if they're on the z plane, you can see them
    var/list/who = list()
    if(!passive_handler.Get("AdminVision")) passive_handler["AdminVision"] = 1;
    for(var/mob/Players/m in world)
        if(m.z == src.z) who |= m;
    return who;

/proc/GetTetherCost()
    return (glob.progress.EconomyMana*5);
/proc/GetTetherWarpCost()
    return (glob.progress.EconomyMana);

/mob/proc/canOfferTether(obj/Skills/Utility/u)
    if(u.Using)
        src << "Tether is already in use."
        return 0;
    if(!hasSecret("Eldritch (Shrouded)"))
        src << "Only Shrouded Eldritch can use Tether. (Reflected have their own Pacts!)"
        return 0;
    var/Cost = GetTetherCost()//more expensive for the Shrouded to Pact
    if(GetMineral() < Cost)
        src << "You don't have enough mana bits to offer a Tether Pact. (It needs [Commas(Cost)])"
        return 0;
    var/list/choices = list();
    for(var/mob/Players/p in view(3, src))
        if(p == src) continue;
        if(p.TetherPacted) continue;
        choices.Add(p);
    if(!choices.len)
        src << "There's nobody nearby to offer a Tether Pact to!"
        return 0;
    if(TetherPacts.len >= secretDatum.currentTier)
        src << "You can only have [secretDatum.currentTier] Tethers at once!"
        return 0;
    return choices;
    
/mob/proc/canTetherWarp(obj/Skills/Utility/u)
    if(u.Using)
        src << "It's too soon to use Tether Warp again!"
        return 0;
    if(KO)
        src << "You're knocked out. Too late to warp out."
        return 0;
    var/Cost = GetTetherWarpCost();
    if(GetMineral() < Cost)//always costs mana bits for Shrouded to warp
        src << "You don't have enough mana bits to warp (You needs [Commas(Cost)])"
        return 0;
    var/list/tetherOptions = findTetherPacts();
    if(!tetherOptions)
        src << "None of your Tether Pacts are awake!"
        return 0;
    return tetherOptions;

/mob/proc/findTetherPacts()
    var/list/l = list();
    for(var/mob/Players/p in world)
        if(p.TetherPactOwner == key)
            l.Add(p);
    if(l.len > 0) return l;
    return 0;
        
obj/Skills/Utility
    Tether
        Cooldown=30;
        desc="Offer a pact to another character to allow you to teleport to them... always."
        verb/Tether_Pact()
            set category="Utility"
            var/list/PactOptions = usr.canOfferTether(src);//will be 0 if it is invalid; will return a list otherwise
            if(!PactOptions) return;
            Using=1;
            PactOptions.Add("Cancel")
            var/mob/Players/Choice=input(usr, "Who do you wish to offer a Tethering Pact to?", "Offer Tether Pact") in PactOptions;
            if(Choice=="Cancel")
                Using=0
                return
            if(!Choice || !Choice.client)
                Using=0;
                return;
            var/TargetConfirm=alert(Choice, "[usr] is offering you a Tethering Pact, wherein they will always be able to be by your side... Do you accept?", "Eldritch Pact", "Accept", "Refuse")
            if(!usr || !usr.client)
                Using=0;
                return;
            if(TargetConfirm=="Refuse")
                usr << "[Choice] has refused your pact."
                src.Using=0
                return
            OMsg(usr, "<font color='red'><b>[usr]'s Shroud</b> reaches out towards <b>[Choice]</b>...</font color>")
            usr.TakeMineral(GetTetherCost());
            Choice.TetherPacted=1
            Choice.TetherPactOwner=usr.key
            usr.TetherPacts.Add(Choice.key)
            OMsg(usr, "<font color='red'>...and the weight of the Shroud falls upon both equally. <b>The Tether Pact is successful.</b></font color>");
            Using=0;

        verb/Tether_Warp()
            set category="Utility"
            var/list/WarpOptions = usr.canTetherWarp(src);
            if(!WarpOptions) return;
            Using=1;
            WarpOptions.Add("Cancel");
            var/mob/choice = input(usr, "Who do you want to Warp to?", "Tether Warp") in WarpOptions;
            if(choice=="Cancel")
                Using=0;
                return;
            OMsg(usr, "<font color='purple'><b>[usr]'s Shroud</b> reaches out towards a soul who bears the same weight...</font color>");
            usr.TakeMineral(GetTetherWarpCost());
            sleep(20)
            //aesthetics
            usr.loc = choice.loc;
            OMsg(usr, "<font color='purple'>...<b>[usr]'s Shroud</b> drags their body through space to a fellow Tether!!</font color>");