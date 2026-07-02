

race
    wilder
        name = "Wilder"
        desc = {"A loose collection of ex-humans, united only in that they were mutated from the remnants of the Lost Artifacts of the Rift.
Difficulty: ★★★
(Requires some managing of class and ascension choices, but is not mechanically intensive.)"}
        visual = 'Wilder.png'
        classes = list("Mountainheart", "Silverscale", "Cloudhammer", "Brightcrown", "Blackflame");
        class_info = list("Mountainheart info.", \
"Silverscale info.", \
"Cloudhammer info.", \
"Brightcrown info.", \
"Blackflame info.");
        stats_per_class = list("Mountainheart" = list(1.5, 3, 1, 1.75, 1.75, 0.75), \
"Silverscale" = list(0.75, 1, 3, 1.75, 1.5, 1.75), \
"Cloudhammer" = list(1.75, 1.5, 0.75, 1.75, 1, 3), \
"Brightcrown" = list(1.5, 1.75, 1.5, 1.75, 1.75, 1.5), \
"Blackflame" = list(1.75, 1, 1.75, 3, 0.75, 1.5));
        var/Racial = "" // first sub ascension choice
        onFinalization(mob/user)
            user.EnhancedSmell=1
            user.EnhancedHearing=1
            Racial = user.Class
            GiveRacial();
            ..()

        proc/GiveRacial()
            switch(Racial)
                if("Mountainheart")
                    skills = list(/obj/Skills/Buffs/SlotlessBuffs/Racial/Wilder/The_Grit, 
                    /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wilder/Heart_of_the_Half_Beast, 
                    /obj/Skills/Queue/Racial/Wilder/Savagery);
                    passives = list("Grit" = 1, "Steady" = 1, "DoubleStrike" = 1, "Heavy Strike" = "Unseen Predator");
                if("Silverscale")
                    skills = list(/obj/Skills/Buffs/SlotlessBuffs/Spirit_Form, /obj/Skills/AutoHit/Mist_Form, 
                    /obj/Skills/Utility/Imitate, /obj/Skills/Buffs/SlotlessBuffs/Racial/Blend_In, 
                    /obj/Skills/Projectile/Racial/Fox_Fire_Barrage);
                    passives = list("ManaGeneration" = 2, "Touch of Death" = 1, "Heavy Strike" = "Fox Fire");
                if("Cloudhammer")
                    skills = list(/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Feather_Cowl,
                    /obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Clean_Cuts);
                    passives = list("Harden" = 1, "Pressure" = 1, "Bladefisting" = 1, "Extra Secret Knives" = "Feathers", "Tossing" = 1,
                    "Momentum" = 1);
                if("Brightcrown")
                    skills = list(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastkin/Never_Fall,
                    /obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker/Pheonix_Form,
                    /obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker/Ram_Form,
                    /obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker/Bear_Form,
                    /obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker/Turtle_Form);
                    passives = list("Nimbus" = 1, "Instinct" = 1);
                if("Blackflame")
                    skills = list(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Undying_Rage);
                    passives = list("Fury" = 1, "Wrathful Tenacity" = 0.15);

obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage
    NeedsHealth = 50
    TooMuchHealth = 75
    TextColor=rgb(95, 60, 95)
    ActiveMessage="is consumed by a dragon's rage!"
    OffMessage = "calms their draconic fury..."
    adjust(mob/p)
        NeedsHealth = 50 + (p.AscensionsAcquired*5);
        TooMuchHealth = min(95, 75 + (p.AscensionsAcquired*5));