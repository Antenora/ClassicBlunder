

race
    wilder
        name = "Wilder"
        desc = {"A loose collection of ex-humans, united only in that they were mutated from 
exposure to a foreign energy system, madra.
Sometimes called sacred artists... Other times, called furries or kemonomimi.
Their ki inherently bears some properties of magic 
and is elementally aligned according to their genealogy.
Later on in development, a proficient wilder will develop an Iron Body, 
then a Jade Cycling Technique, and finally an inhuman Goldsign.
Difficulty: ★★★
(Requires some managing of class and ascension choices,
but is not mechanically rigorous.)"}
        visual = 'Wilder.png'
        classes = list("Mountainheart", "Silverscale", "Cloudhammer", "Brightcrown", "Blackflame");
        class_info = list("Mountainheart wilders have madra based upon Earth and Space. TKWIP", \
"Silverscale wilders have madra based upon Water and Time. TKWIP", \
"Cloudhammer wilders have madra based upon Wind, Earth and Water. TKWIP", \
"Brightcrown wilders have madra based upon Wind and Light. TKWIP", \
"Blackflame wilders have madra based upon Fire and Dark. TKWIP. changhuang is my wife and no one else can have her .");
        stats_per_class = list("Mountainheart" = list(1.5, 3, 1, 1.75, 1.75, 0.75), \
"Silverscale" = list(0.75, 1, 3, 1.75, 1.5, 1.75), \
"Cloudhammer" = list(1.75, 1.5, 0.75, 1.75, 1, 3), \
"Brightcrown" = list(1.5, 1.75, 1.5, 1.75, 1.75, 1.5), \
"Blackflame" = list(1.75, 1, 1.75, 3, 0.75, 1.5));
        var/Racial = ""
        onFinalization(mob/user)
            user.EnhancedSmell=1
            user.EnhancedHearing=1
            Racial = user.Class
            GiveRacial();
            ..(user)

        proc/GiveRacial()
            switch(Racial)
                if("Mountainheart")
                    passives = list("ElementalTechnique" = list("Earth", "Space"),
                    "ElementalMastery" = list("Earth", "Space"),
                    "ElementalLock" = list("Wind", "Time"));
                if("Silverscale")
                    passives = list("ElementalTechnique" = list("Water", "Time"),
                    "ElementalMastery" = list("Water", "Time"),
                    "ElementalLock" = list("Fire", "Space"));
                if("Cloudhammer")
                    passives = list("ElementalTechnique" = list("Wind", "Earth", "Water"),
                    "ElementalMastery" = list("Wind", "Earth", "Water"));
                    //No downsides for cloudhammers since they don't get an advanced element
                if("Brightcrown")
                    passives = list("ElementalTechnique" = list("Wind", "Light"),
                    "ElementalMastery" = list("Wind", "Light"),
                    "ElementalLock" = list("Earth", "Dark"));
                if("Blackflame")
                    passives = list("ElementalTechnique" = list("Fire", "Dark"),
                    "ElementalMastery" = list("Fire", "Dark"),
                    "ElementalLock" = list("Water", "Light"));
            passives["SacredArts"] = 1;
            passives["SacredBody"] = 1;
                    

obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage
    NeedsHealth = 50
    TooMuchHealth = 75
    TextColor=rgb(95, 60, 95)
    ActiveMessage="is consumed by a dragon's rage!"
    OffMessage = "calms their draconic fury..."
    adjust(mob/p)
        NeedsHealth = 50 + (p.AscensionsAcquired*5);
        TooMuchHealth = min(95, 75 + (p.AscensionsAcquired*5));