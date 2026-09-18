obj/Skills
    var/list/Masterable = list();//list that can contain 'Hit', 'Dmg', 'Hurt', 'TimeGate', 'TimeGateMastery'
    var/PostTimeGateMasteryNeeded = 0;//only used for skills that need to be mastered within a time period

    proc
        youCanNotAdvance()
            if(Masterable.len <= 0) return 1;
            return 0;
        isHitMasterable()
            if(Masterable.Find("Hit")) return 1;
            return 0;
        isDmgMasterable()
            if(Masterable.Find("Dmg")) return 1;
            return 0;
        isHurtMasterable()
            if(Masterable.Find("Hurt")) return 1;
            return 0;
        isTimeGateMasterable()
            if(Masterable.Find("TimeGate")) return 1;
            return 0;
        isOnlyTimeGated()
            if(Masterable.Find("TimeGateMastery")) return 0;
            return 1;

obj/Skills
    proc
        advance_adjustment(mob/p)//does not do anything by itself
            return;