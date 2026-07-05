/mob/proc/
    hasHeavenlyPURestriction()
        if(hasSecret("Heavenly Restriction"))
            var/SecretInformation/HeavenlyRestriction/hs = secretDatum;
            if(hs.hasRestriction("Power Control")) return 1;
        return 0;