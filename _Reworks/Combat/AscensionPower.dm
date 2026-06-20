#define SSJ_1_POWER (1.5-1)
#define SSJ_2_POWER (2-1)
#define SSJ_3_POWER (2.5-1)
#define SSJ_4_POWER (3.5-1)

/mob/proc/GetAscensionPower()
    . = 1;
    . += getRacialAscensionPower()

/mob/proc/getRacialAscensionPower()
    if(isRace(SAIYAN) || isRace(HALFSAIYAN)) return 0;//saiyans have their own stuff going on
    if(isRace(HUMAN)) return 0;//sorry humans, power is not for you
    if(NobodyOriginType=="Pride") return 0;//knockoff saiyans
    //we could break this into multiple procs if we want different power scaling for different races
    //which i do think is a good idea
    //but for now...
    switch(AscensionsAcquired)
        if(0) return 0
        if(1) return 0
        if(2) return SSJ_1_POWER*0.5;
        if(3) return SSJ_2_POWER*0.6;
        if(4) return SSJ_3_POWER*0.7;
        if(5) return SSJ_4_POWER*0.8;
        if(6) return SSJ_4_POWER;