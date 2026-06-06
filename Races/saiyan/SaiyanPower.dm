/mob/proc/GetSaiyanPower()
    if(!(isRace(SAIYAN) || isRace(HALFSAIYAN) || NobodyOriginType=="Pride")) return 1
    . = 1;

    . += getSSJ1Power();
    . += getSSJ2Power();
    . += getSSJ3Power();
    . += getSSJ4Power();
    . += getSSJGodPower();
    . += getSSJVoidPower();
    . += getTrueZenkaiPower();
    
    . *= getSpiralPower();

    . = max(1, .);

/mob/proc/
    getSSJPower(typeSSJ)
        if(!passive_handler) return 0;
        var/mag = passive_handler.Get("MagnifiedSSJ[typeSSJ]");
        . = passive_handler.Get("SaiyanPower[typeSSJ]");

        if(typeSSJ==1) . *= (race.transformations[1].mastery/100)//unique to SSJ1

        if(mag) . += mag;
    getSSJ1Power()
        return getSSJPower(1);
    getSSJ2Power()
        return getSSJPower(2);
    getSSJ3Power()
        return getSSJPower(3);
    getSSJ4Power()
        return getSSJPower(4);
    getSSJGodPower()
        return getSSJPower("God");
    getSSJVoidPower()
        . = getSSJPower("Void");
    getTrueZenkaiPower()
        if(!passive_handler) return 0;
        . = passive_handler.Get("TrueZenkaiPower");
    getSpiralPower()
        . = 1;
        if(!passive_handler) return 1;//this is applied as a mult to SSJVoidPower so it returns 1 (no modification) rather than 0 (remove bonus)
        var/spiralBonus = (passive_handler.Get("SpiralPowerUnlocked")/10);
        if(NobodyOriginType=="Pride" && spiralBonus) return (1+spiralBonus);
        if((isRace(SAIYAN) || isRace(HALFSAIYAN)) && spiralBonus)//spiralBonus is marked, but it will be ignored...
            return getNextSaiyanTransMult();//...in favour of simulating what the next tf mult would be
    getNextSaiyanTransMult()
        . = 1;
        switch(transUnlocked)
            if(0) . += 0.4;
            if(1) . += 0.2;
            if(2) . += 0.5;
            if(3) . += 1;
            if(4) . += 0.5;
            if(5)
                if(HasGodKi()) . += 0.15;
                else . += 0.25;