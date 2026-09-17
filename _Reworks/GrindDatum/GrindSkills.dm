obj/Skills
    var/list/Masterable = list();//list that can contain 'Hit', 'Dmg', 'Hurt', 'TimeGate'

    proc
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
