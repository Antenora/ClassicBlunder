#define ALWAYS_ON_HEAVY_STRIKES list("Eldritch (Shrouded)", "Haki", "Werewolf", "Vampire", "Zombie")
/mob/proc/
    getSpecialHeavyStrike()
        if(hasWitchCraftStrike()) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Soulsap_Strike);
        if(hasEldritchStrike()) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Maleific_Strike);
        if(hasHakiStrike()) return getHakiStrike();
        if(hasRippleStrike()) return getRippleStrike();
        if(hasSenjutsuStrike()) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Sage_Energy_Strike);
        if(hasWerewolfStrike()) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Rip_and_Tear);
        if(hasVampireStrike()) return getVampireStrike();
        if(hasBlackFlashStrike()) return getBlackFlashStrike();
        if(hasZombieStrike()) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Death_Grasp);
        if(hasHeavenlyRestrictionStrike()) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Heavenly_Strike);
        if(hasShinStrike()) return getShinStrike();
        if(hasSpiralStrike()) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Spiral_Drill);
        if(hasNecromancyStrike()) return 0;
        if(hasJaganStrike()) return 0;
        if(hasUltraInstinctStrike()) return 0;
        //stuff i dont wanna support
        if(hasGoeticStrike()) return 0;
        if(hasStellarStrike()) return 0;
        if(hasElvenStrike()) return 0;
        return 0;

    canNormalHeavyStrike()
        for(var/obj/Skills/Queue/Secret_Heavy_Strike/shs in src)
            if(shs.Using) return 0;
        return 1;
    canSpecialHeavyStrike()
        for(var/obj/Skills/Queue/Heavy_Strike/hs in src)//check to see if default hs is on cd
            if(hs.Using) return 0;
        for(var/obj/Skills/Queue/Secret_Heavy_Strike/shs in src)//or any of your special heavy strikes
            if(shs.Using) return 0;
        return 1;
    hasWitchCraftStrike()
        if(hasWitchCraft() && StyleActive=="Witch") return 1;
        return 0;
    hasUltraInstinctStrike()
        if(isRace(ANGEL) || hasSecret("Ultra Instinct")) return 1;
        return 0;
    hasEldritchStrike()
        if(hasEldritchPower()) return 1;
        return 0;
    hasJaganStrike()
        if(hasSecret("Jagan Eye")) return 1;
        return 0;
    hasSpiralStrike()
        if(hasSecret("Spiral")) return 1;
        return 0;
    hasNecromancyStrike()
        if(hasSecret("Necromancy")) return 1;
        return 0;
    hasHakiStrike()
        if(hasSecret("Haki")) return 1;
        return 0;
    hasBlackFlashStrike()
        if(hasSecret("Black Flash"))
            if(canBlackFlashStrike()) return 1;
        return 0;
    canBlackFlashStrike()//only gamba if all of your heavy strikes are off cd
        for(var/obj/Skills/Queue/Heavy_Strike/hs in src)
            if(hs.Using) return 0;
        for(var/obj/Skills/Queue/Secret_Heavy_Strike/shs in src)
            if(shs.Using) return 0;
        return 1;
    getBlackFlashStrike()
        if(!secretDatum)
            admins << "<b><font size=+1>DEBUG:</font size></b> Somehow, [src] called getBlackFlashStrike() while not having a secretDatum...That's a bug!";
            src << "Your character has called getBlackFlashStrike() while not having a defined secret datum. Admins have been notified, but you can drop a bug report in the Discord as well.";
            return 0;
        var/usedChance = getBlackFlashChance();
        if(prob(usedChance)) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Black_Flash/Black_Flash_Strike);
        return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Black_Flash/Divergent_Fist);
    getHakiStrike()
        if(!secretDatum)
            admins << "<b><font size=+1>DEBUG:</font size></b> Somehow, [src] called getHakiStrike() while not having a secretDatum...That's a bug!";
            src << "Your character has called getHakiStrike() while not having a defined secret datum. Admins have been notified, but you can drop a bug report in the Discord as well.";
            return 0;
        if(secretDatum.secretVariable["HakiSpecialization"] == "Armament") return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Haki/BusoKoka);
        return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Haki/Armament_Strike);
    hasRippleStrike()
        if(hasSecret("Hamon") && RippleActive()) return 1;
        return 0;
    getRippleStrike()
        if(!secretDatum)
            admins << "<b><font size=+1>DEBUG:</font size></b> Somehow, [src] called getRippleStrike() while not having a secretDatum...That's a bug!";
            src << "Your character has called getRippleStrike() while not having a defined secret datum. Admins have been notified, but you can drop a bug report in the Discord as well.";
            return 0;
        if(secretDatum.currentTier >= 5) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Hamon/Flaming_Scarlet_Overdrive);
        if(prob(20)) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Hamon/Overdrive_Barrage);
        if(SwordWounds()) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Hamon/Metal_Silver_Overdrive);
        if(hasElementalOffense("Fire")) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Hamon/Scarlet_Overdrive);
        if(hasElementalOffense("Water")) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Hamon/Turqoiuse_Blue_Overdrive);
        if(hasElementalOffense("Wind")) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Hamon/Tornado_Overdrive);
        if(hasElementalOffense("Earth")) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Hamon/Sendo_Ripple_Overdrive);
        return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Hamon/Ripple_Overdrive);
    hasWerewolfStrike()
        if(hasSecret("Werewolf")) return 1;
        return 0;
    hasVampireStrike()
        if(hasSecret("Vampire")) return 1;
        return 0;
    getVampireStrike()
        if(PoseEnhancement) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Vampire/Enhanced_Vampire_Strike);
        return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Vampire/Vampire_Strike);
    hasZombieStrike()
        if(hasSecret("Zombie")) return 1;
        return 0;
    hasSenjutsuStrike()
        if(hasSecret("Senjutsu") && CheckSlotless("Senjutsu Focus")) return 1;
        return 0;
    hasHeavenlyRestrictionStrike()
        if(hasSecret("Heavenly Restriction"))
            var/SecretInformation/HeavenlyRestriction/hs = secretDatum;
            if(hs.hasImprovement("Heavy Strike")) return 1;
        return 0;
    hasShinStrike()
        if(hasSecret("Shin")) return 1;
        return 0;
    getShinStrike()
        if(CheckSlotless("Shin Radiance")) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Shin/Shin_Strike);
        if(CheckSlotless("Mang Resonance")) return findOrAddSkill(/obj/Skills/Queue/Secret_Heavy_Strike/Shin/Mang_Strike);
        return 0;

    //i dont use hasSecret for these because i don't reeeallly wanna support themmm
    hasGoeticStrike()
        if(Secret == "Goetic Virtue") return 1;
        return 0;
    hasStellarStrike()
        if(Secret == "Stellar Constellation") return 1;
        return 0;
    hasElvenStrike()
        if(Secret == "Elven Sanctuary") return 1;
        return 0;
