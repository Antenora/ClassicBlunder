/mob/var/MagicTaken = 0; //holds a realtime

/globalTracker/var
    ELDRITCH_MANABIT_EFFICIENCY = 10;
    ELDRITCH_MANABIT_TIME_LIMIT = 3 DAYS;

/mob/proc/HasMagicTaken()
	if(!src.MagicTaken) return 0 //if it has never been taken, nope
	if(src.MagicTaken < world.realtime) return 0; //if the time has elapsed, nope
	return 1; //otherwise, yes, it's been stolen

/mob/proc/canStealMana(mob/trg)
    if(!trg) return 0;
    if(isAI(trg)) return 0;
    if(!trg.KO) return 0;
    if(trg.HasMagicTaken()) return 0;
    if(!hasEldritchPower()) return 0;
    if(!Lethal) return 0;
    return 1;

//Used in Grab_Effect()
/mob/proc/EldritchMagicSteal(mob/trg)
    //mechanics
    if(hasSecret("Eldritch")) secretDatum.secretVariable["Power From Blood"]++;//this is just for adapted eldritch, not naturals
    else GiveMineral((100-trg.TotalCapacity) * glob.ELDRITCH_MANABIT_EFFICIENCY);//otherwise, just accumulate mana bits

    trg.MagicTaken = world.realtime + glob.ELDRITCH_MANABIT_TIME_LIMIT;
    trg.Conscious();
    trg.TotalInjury=90;
    trg.TotalCapacity=100;
    src.TotalCapacity=0;
    src.ManaAmount=100;
    trg.Unconscious(src, "has been debilitated by an unnatural harvesting!");

    //visuals
    var/image/img = image(icon='Novabolt.dmi', pixel_x=-33, pixel_y=-33);
    trg.overlays.Add(img);

    KKTShockwave(M = trg, Size=1);
    KKTShockwave(M = trg, Size=2);
    KKTShockwave(M = trg, Size=3);
    spawn(12)
        LightningBolt(trg, 3);
        spawn(5)
        trg.overlays.Remove(img);

    //output
    OMsg(trg, "[trg]'s mana circuits have been harvested for [src]'s gain!", "[src]([src.key]) harvested [trg]([trg.key])'s mana circuits (Eldritch Secret).");
