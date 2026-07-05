/mob/proc/scalingEldritchPower()
    . = 0;
    if(hasSecret("Eldritch (Shrouded)")) . = scalingShroudedPower() * AscensionsAcquired;
    if(hasSecret("Eldritch (Reflected)")) . = scalingReflectedPower() * AscensionsAcquired;
    if(passive_handler.Get("Half Manifestation")) . = max(., 3);
    if(passive_handler.Get("Full Manifestation")) . = max(., 6);

/mob/proc/scalingShroudedPower()//once a shrouded takes enough damage determined by potential, 
//they get 100% of their true form buffs for this potential level
    if(Health <= 100 - (get_potential()+TotalInjury)) return 1;
    return 0;
/mob/proc/scalingReflectedPower()//reflected also scale based on potential, but they do so more slowly
//lower ascension levels give only portions of their true form
//but ascension 6 grants an additional 0.5
    if(AscensionsAcquired >= 6) return 1.5;
    return (AscensionsAcquired * 0.2)

/mob/proc/hasEldritchRacial()
    if(hasSecret("Eldritch (Shrouded)")) return 1;
    if(hasSecret("Eldritch (Reflected)")) return 1;
    return 0;

/mob/proc/hasEldritchPower()
    if(!WoundIntent) return 0;
    if(isEldritchTrueForm()) return 1;
    if(hasSecret("Eldritch (Shrouded)")) return 1;
    if(isEnlightenedReflected()) return 1;
    return 0;

/mob/proc/isEldritchTrueForm()
    if(hasSecret("Eldritch") && CheckSlotless("True Form")) return 1;
    return 0;
/mob/proc/isEnlightenedReflected()
    if(hasSecret("Eldritch (Reflected)") && secretDatum.currentTier >= 4) return 1;
    return 0;