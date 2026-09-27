// this is anything but fast
/mob/Admin3/verb/Respec()
    var/mob/P = PromptArg(usr, args, 1, "Respec", "players")
    if(isnull(P)) return
    if(!src.Alert("Are you sure you want to respec a player?")) return
    for(var/obj/Skills/Choice in P)
        if(Choice.Copyable)
            var/Refund
            if(Choice.NewCost)
                Refund = Choice.NewCost
            switch(Choice.Copyable)
                if(1) // these r maostly gone
                    Refund = TIER_1_COST
                if(2)
                    Refund = TIER_1_COST
                if(3)
                    Refund = TIER_2_COST
                if(4)
                    Refund = TIER_3_COST
                if(5)
                    Refund = TIER_4_COST
            if(istype(Choice, /obj/Skills/Buffs/NuStyle))
                if(Choice.SignatureTechnique > 0) Refund = 0
                else P.SignatureSelected -= Choice.name
                Refund += ((2**(Choice.SignatureTechnique+1)*10)) * max(0,(Choice.Mastery-1))
            else if(Choice.Mastery>1)
                Refund+=(Refund*(Choice.Mastery-1))
            if(Choice.name in P.SkillsLocked)
                P.SkillsLocked -= Choice.name
            P.RPPSpendable+=Refund
            P.RPPSpent-=Refund
            P << "You've refunded [Choice] for [Commas(Refund)] RPP."
            Log("Admin", "[ExtractInfo(src)] refunded [Choice] for [Commas(Refund)] RPP to [ExtractInfo(P)].")
            for(var/obj/Skills/S in P)
                if(Choice&&S)
                    if(S.type==Choice.type)
                        if(S.PreRequisite.len>0 && !istype(Choice, /obj/Skills/Buffs/NuStyle))
                            for(var/path in S.PreRequisite)
                                var/p=text2path(path)
                                var/obj/Skills/oldskill=new p
                                P.AddSkill(oldskill)
                                P << "The prerequisite skill for [Choice], [oldskill] has been readded to your contents."
                        del S
            for(var/obj/Skills/Buffs/NuStyle/s in src)
                src.StyleUnlock(s)
