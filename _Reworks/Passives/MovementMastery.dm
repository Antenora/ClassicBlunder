globalTracker/var
    MOVE_MASTERY_PER_ZEAL_TRANS = 1;
    MOVE_MASTERY_PER_COSMO_SAGA = 2.5;
    MOVE_MASTERY_PER_INFINITY_MOD = 2;
    MOVE_MASTERY_PER_SHIN = 1;
    MOVE_MASTERY_PER_HOPE_ASC = 5;
    MOVE_MASTERY_DOUBLE_HELIX_KAIOKEN_MULT = 1;

/mob/proc/GetMovementMastery()
    . = 0;
    . += passive_handler.Get("MovementMastery")
    if(passive_handler.Get("Zeal")) . += (transActive * glob.MOVE_MASTERY_PER_ZEAL_TRANS);
    if(Saga=="Cosmo" && !SpecialBuff) . += (SagaLevel * glob.MOVE_MASTERY_PER_COSMO_SAGA);
    if(InfinityModule) . += (AscensionsAcquired * glob.MOVE_MASTERY_PER_INFINITY_MOD);
    if(hasSecret("Shin")) . += (secretDatum.currentTier * glob.MOVE_MASTERY_PER_SHIN);
    if(passive_handler.Get("Hopes and Dreams")) . += (AscensionsAcquired * glob.MOVE_MASTERY_PER_HOPE_ASC)
    if(passive_handler.Get("Kaioken")&&(src.passive_handler.Get("DoubleHelix"))) . += (DoubleHelix * glob.MOVE_MASTERY_DOUBLE_HELIX_KAIOKEN_MULT)
    if(. <= 0) return 0;
    . *= glob.MOVEMENT_MASTERY_DIVISOR;
    . /= 100;//every single instance of GetMovementMastery is working with a ratio rather than raw numbers so we can do this here