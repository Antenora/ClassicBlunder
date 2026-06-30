/mob/var/tmp/
    magicTreeDisplayed=0;

/mob/proc/showMagicTree()
    changeTreeImage();
    updateSelectionNodes();
    skinShow(MAGIC_TREE);

/mob/proc/setMagicTreeToElement()
    switch(magicTreeDisplayed)
        if("Water") setMagicTreeToWater();
        if("Fire") setMagicTreeToFire();
        if("Air") setMagicTreeToAir();
        if("Earth") setMagicTreeToEarth();
        if("Light") setMagicTreeToLight();
        if("Time") setMagicTreeToTime();
        if("Dark") setMagicTreeToDark();
        if("Space") setMagicTreeToSpace();
        else setMagicTreeToWater();//default

/mob/proc/
    setMagicTreeToWater()
        hideRevealedButtons();
        magicTreeDisplayed="Water";
        showWaterTree();
    showWaterTree()
        showMagicTree();
        for(var/mname in glob.WaterTreeNodes)
            skinShow(mname);
            revealedMagicButtons |= mname;


/mob/proc/
    setMagicTreeToFire()
        hideRevealedButtons();
        magicTreeDisplayed="Fire";
        showFireTree();
    showFireTree()
        showMagicTree();
        for(var/mname in glob.FireTreeNodes)
            skinShow(mname);
            revealedMagicButtons |= mname;

/mob/proc/
    setMagicTreeToAir()
        hideRevealedButtons();
        magicTreeDisplayed="Air";
        showAirTree();
    showAirTree()
        showMagicTree();
        for(var/mname in glob.AirTreeNodes)
            skinShow(mname);
            revealedMagicButtons |= mname;

/mob/proc/
    setMagicTreeToEarth()
        hideRevealedButtons();
        magicTreeDisplayed="Earth";
        showEarthTree();
    showEarthTree()
        showMagicTree();
        for(var/mname in glob.EarthTreeNodes)
            skinShow(mname);
            revealedMagicButtons |= mname;

/mob/proc/
    setMagicTreeToLight()
        hideRevealedButtons();
        magicTreeDisplayed="Light";
        showLightTree();
    showLightTree()
        showMagicTree();
        for(var/mname in glob.LightTreeNodes)
            skinShow(mname);
            revealedMagicButtons |= mname;

/mob/proc/
    setMagicTreeToTime()
        hideRevealedButtons();
        magicTreeDisplayed="Time";
        showTimeTree();
    showTimeTree()
        showMagicTree();
        for(var/mname in glob.TimeTreeNodes)
            skinShow(mname);
            revealedMagicButtons |= mname;

/mob/proc/
    setMagicTreeToDark()
        hideRevealedButtons();
        magicTreeDisplayed="Dark";
        showDarkTree();
    showDarkTree()
        showMagicTree();
        for(var/mname in glob.DarkTreeNodes)
            skinShow(mname);
            revealedMagicButtons |= mname;

/mob/proc/
    setMagicTreeToSpace()
        hideRevealedButtons();
        magicTreeDisplayed="Space";
        showSpaceTree();
    showSpaceTree()
        showMagicTree();
        for(var/mname in glob.SpaceTreeNodes)
            skinShow(mname);
            revealedMagicButtons |= mname;

/mob/var/tmp/
    loadingTree=0;

/mob/proc/loadButtons(list/treeNodes)
    loadingTree=1;
    for(var/mname in treeNodes)
        createMagicTreeButton(treeNodes[mname]);
        revealedMagicButtons |= mname;
    loadingTree=0;

/mob/verb/
    Show_Magic_Tree()
        set category="Utility"
        set hidden = 1
        if(loadingTree || nodeing) return
        nodeing=1;
        setMagicTreeToElement();
        nodeing=0;

    Show_Water_Tree()
        set hidden=1;
        set name=".ShowWaterTree"
        if(loadingTree || nodeing) return
        nodeing=1;
        setMagicTreeToWater();
        nodeing=0;

    Show_Fire_Tree()
        set hidden=1;
        set name=".ShowFireTree"
        if(loadingTree || nodeing) return
        nodeing=1;
        setMagicTreeToFire();
        nodeing=0;

    Show_Air_Tree()
        set hidden=1;
        set name=".ShowAirTree";
        if(loadingTree || nodeing) return
        nodeing=1;
        setMagicTreeToAir();
        nodeing=0;

    Show_Earth_Tree()
        set hidden=1;
        set name=".ShowEarthTree";
        if(loadingTree || nodeing) return
        nodeing=1;
        setMagicTreeToEarth();
        nodeing=0;

    Show_Light_Tree()
        set hidden=1;
        set name=".ShowLightTree";
        if(loadingTree || nodeing) return
        nodeing=1;
        setMagicTreeToLight();
        nodeing=0;

    Show_Time_Tree()
        set hidden=1;
        set name=".ShowTimeTree";
        if(loadingTree || nodeing) return
        nodeing=1;
        setMagicTreeToTime();
        nodeing=0;

    Show_Dark_Tree()
        set hidden=1;
        set name=".ShowDarkTree";
        if(loadingTree || nodeing) return
        nodeing=1;
        setMagicTreeToDark();
        nodeing=0;

    Show_Space_Tree()
        set hidden=1;
        set name=".ShowSpaceTree";
        if(loadingTree || nodeing) return
        nodeing=1;
        setMagicTreeToSpace();
        nodeing=0;
