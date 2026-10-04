advanceSpecs/JaganEye
    advancementStageMax = 5;
    onMasteryGain()
        if(!owner) return;
        if(!levelNeeded) levelNeeded = (owner.Potential + 10);
        setJaganEnergyStage();
    
    proc
        setJaganEnergyStage()
            setJaganEnergyBaseline();
            getJaganTimeAdvancement();
            getJaganMortalAdvancement();
            getJaganMaimAdvancement();
            if(advancementStage > 1 && advancementStage < 4) correctJaganOvercap();
            setJaganEnergyCap();

        setJaganEnergyBaseline()
            switch(advancementStage)
                if(1) owner.EnergyCut = 0.5;
                if(2) owner.EnergyCut = 0.4;
                if(3) owner.EnergyCut = 0.25;
                if(4) owner.EnergyCut = 0.1;
                if(5) owner.EnergyCut = 0;

        setJaganEnergyCap()
            switch(advancementStage)
                if(1) owner.EnergyCut = 0.4;
                if(2) owner.EnergyCut = 0.25;
                if(3) owner.EnergyCut = 0.1;
                if(4) owner.EnergyCut = 0.1;
                if(5) owner.EnergyCut = 0;
        
        correctJaganOvercap()
            var/cap;
            switch(advancementStage)
                if(2) cap = 0.25;
                if(3) cap = 0.1;
            if(owner.Potential < levelNeeded)
                if(owner.EnergyCut > cap)
                    var/dif = (owner.EnergyCut - cap);
                    dif *= 100;
                    levelNeeded -= dif;//each 1% of energy overcap is 1 level less needed to advance

        
        getJaganTimeAdvancement()
            var/dif = (owner.Potential - levelNeeded);
            dif = min(0, dif);
            dif *= (-1);
            owner.EnergyCut -= (dif*0.01);
        getJaganMortalAdvancement()
            if(advancementStage == 2)
                owner.EnergyCut -= (mastery["MortalWoundsDealt"] * 0.03);
        getJaganMaimAdvancement()
            if(advancementStage == 3)
                owner.EnergyCut -= (mastery["MaimsDealt"] * 0.05);

        
