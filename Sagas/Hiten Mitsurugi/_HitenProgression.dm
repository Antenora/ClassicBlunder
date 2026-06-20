#define HITEN_PASSIVES_TIER_1 list("SlayerMod"=1, "Godspeed"=1, "Flicker"=1, "Pursuer"=1, "FavoredPrey"="Mortal")
#define HITEN_PASSIVES_TIER_2 list("Godspeed"=1, "AttackSpeed"=2, "Pursuer"=1, "Flow" = 1, "Instinct" = 1)
#define HITEN_PASSIVES_TIER_3 list("Godspeed"=1, "TechniqueMastery"=2, "Flow" = 1, "Instinct" = 1)
#define HITEN_PASSIVES_TIER_4 list("SlayerMod"=1, "Godspeed"=1, "MovementMastery"=4, "FavoredPrey"="All")
#define HITEN_PASSIVES_TIER_5 list("Godspeed"=1, "AttackSpeed"=3, "Pursuer"=1, "Deicide"=5, "EndlessNine"=0.1)
#define HITEN_PASSIVES_TIER_6 list("Godspeed"=1, "TechniqueMastery"=3, "Deicide"=5, "EndlessNine"=0.1)
#define HITEN_PASSIVES_TIER_7 list("SlayerMod"=1, "Godspeed"=2, "Deicide"=10, "EndlessNine"=0.2, "AsuraStrike"=1)

/mob/proc/gainHitenMitsurugi()
    src<<"You embark down the path of slaying men... <b>Hiten Mitsurugi Style</b>!"
    Saga="Hiten Mitsurugi-Ryuu"
    SagaLevel=1
    var/list/passiveGain = HITEN_PASSIVES_TIER_1
    findOrAddSkill(/obj/Skills/Buffs/NuStyle/SwordStyle/Hiten_Mitsurugi_Ryuu);
    findOrAddSkill(/obj/Skills/Queue/JawStrike);
    findOrAddSkill(/obj/Skills/Queue/FallingBlade);
    if(passiveGain.len > 0) passive_handler.increaseList(passiveGain);

/mob/tierUpSaga(path)

    ..()
    var/list/passiveGain=list();
    if(path=="Hiten Mitsurugi-Ryuu")
        switch(SagaLevel)
            if(2)
                passiveGain=HITEN_PASSIVES_TIER_2
                src << "You learn how to add the momentum of your spin to perform an unavoidable slash!"
                findOrAddSkill(/obj/Skills/AutoHit/CoiledSlash);
                src<< "You learn how to strike countless times with incredible speed!"
                findOrAddSkill(/obj/Skills/AutoHit/NestedSlash);

            if(3)
                passiveGain=HITEN_PASSIVES_TIER_3
                findOrAddSkill(/obj/Skills/Projectile/Sword/Hiten_Mitsurugi/Earth_Dragon_Flash)
                src << "You learn to strike the ground and unleash a torrent of debris!"
                findOrAddSkill(/obj/Skills/Queue/Twin_Dragon_Slash);
                src << "You can deliver a quick blow with your blade only to be followed with a crushing strike from your sheath!"

            if(4)
                passiveGain=HITEN_PASSIVES_TIER_4;
                src << "You can slay even inhuman foes!"
                src << "You have refined your finishing technique into: <b>True Flash Strike!</b>"
                src << "The next time you turn your Hiten Mitsurugi Style on, the finisher will be enhanced."
                var/Choice=alert(src, "Hiten Mitsurugi can follow the path of tradition, embracing the code of a hermit and honorable warrior or can truly become an ultimate tool of murder. What is the mantle you will bear?", "Hiten Path", "Tradition", "Slaughter")
                if(Choice=="Tradition")
                    src<<"You embrace the path of tradition, sharpening your art and making it a constant presence in your life!"
                    findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Dance_Of_The_Full_Moon);
                    src<<"You can now draw out the full form of the Moon by using paired blades."
                if(Choice=="Slaughter")
                    findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Hitokiri_Battosai);
                    src<<"You embrace the path of a killer and assassin, revealing your true nature in moments of strife!"

            if(5)
                passiveGain=HITEN_PASSIVES_TIER_5
                src << "You learn to sheath your sword with such authority that it stuns those around you!"
                findOrAddSkill(/obj/Skills/AutoHit/Sonic_Sheath);
                src << "You learn of nine killing blows: Kuzuryusen!"
                findOrAddSkill(/obj/Skills/Queue/Nine_Dragons_Strike);

            if(6)
                passiveGain=HITEN_PASSIVES_TIER_6
                src<<"Your speed transcends mortal limit and you can chase down any foe..."
                src << "You learn the ultimate killing technique...even if you avoid the fangs of the flying dragon, the claws will rip you apart!"
                findOrAddSkill(/obj/Skills/Queue/Heavenly_Dragon_Flash);

            if(7)
                passiveGain=HITEN_PASSIVES_TIER_7
                src << "Your blade is a tool that can cull even the gods."

        if(passiveGain.len > 0) passive_handler.increaseList(passiveGain);
