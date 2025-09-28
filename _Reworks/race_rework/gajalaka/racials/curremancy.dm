/*
**CURREMANCY:** So i think it should manifest in Curremancy,
 a magic verb that uses weights based on current wallet and strength of spells on a table to cast a random spell
 from both the elf pool and the demon pool with a really long c/d
*/
/proc/pickspell(modifier)
    var/random = randValue(0 + modifier, 100)
    var/_prev = 1
    for(var/x in glob.racials.GAJALAKA_SPELL_POOL)
        if(glob.racials.GAJALAKA_SPELL_POOL[x] == 1)
            continue
        if(random >= _prev && random < glob.racials.GAJALAKA_SPELL_POOL[x])
            return glob.racials.GAJALAKA_SPELL_POOL[x]
        else
            _prev = glob.racials.GAJALAKA_SPELL_POOL[x]

/racials/var/GAJALAKA_SPELL_POOL = list( "/obj/Skills/AutoHit/Elf/Compel" = 1,\
    "/obj/Skills/Projectile/Magic/HellFire/Hellpyre" = 15 ,\
    "/obj/Skills/Projectile/Magic/DarkMagic/Shadow_Ball" = 35,\
    "/obj/Skills/AutoHit/Elf/Flee" = 60 ,\
    "/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/OverHeat" = 70 ,\
    "/obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Soul_Leech" = 80 ,\
    "/obj/Skills/AutoHit/Elf/Silence" = 90 ,\
    "/obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Dominate_Mind" = 95,\
    "/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/Hellstorm" = 100)


