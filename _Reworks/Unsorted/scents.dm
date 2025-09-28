
/var/list/scents = list(
    "HUMAN" = list("Sweat", "Gamer Musk", "Flowery", "Cologne"), \
    "NAMEKIAN" = list("Grass", "Forest", "Spices"), \
    "Chakardi" = list("Money", "Gold", "Greed"), \
    "ELVES" = list("Society", "Rich", "Noble","Royalty"), \
    "SAIYAN" = list("Musk", "Animalistic", "Sweaty", "Unbathed"), \
    "MAKYO" = list("Garlic", "Feet", "Alcohol" ), \
    "Alien" = list("Musk", "Incense", "Exotic"), \
    "YOKAI" = list("Incense", "Alcohol "), \
    "ELDRITCH" = list("Ocean", "Alien", "Exotic", "Overwhelming"), \
    "BEASTMAN" = list("Musk", "Animalistic", "Sweaty", "Unbathed"), \
    "DEMON" = list("Brimstone", "Nothingness", "Blood", "Death", "Overwhelming"), \
    "MAJIN" = list("Gum", "Sweets"), \
    "DRAGON" = list("Ozone", "Animalistic", "Overwhelming"), \
    "Mechanized" = list("Metal"), \
    "Secret" = list("Grass", "Blood", "Decay"), \
    "Custom" = list("Muk", "Grime", "Magical", ))


mob/proc/setUpScent()
    switch(usr.Target.race.type)
        if(ELF)
            custom_scent=pick("Society", "Rich", "Noble","Royalty")
        if(GAJALAKA)
            custom_scent = pick("Dirt", "Gold", "Musky", "Greed")
        if(HUMAN)
            custom_scent=pick("Sweat","Gamer Musk","Flowery","Cologne")
        if(NAMEKIAN)
            custom_scent=pick("Grass", "Forest", "Spices", "Cotton", "Spring")
        if(SAIYAN)
            custom_scent=pick("Musk", "Animalistic", "Sweaty", "Unbathed")
        if(MAKYO)
            custom_scent=pick("Garlic", "Feet", "Alcohol", "The Sky")
        if("Alien")
            if(usr.Target.Class=="Brutality"||usr.Target.Class=="Tenacity")
                custom_scent="Musk"
            if(usr.Target.Class=="Harmony"||usr.Target.Class=="Equanimity")
                custom_scent="Incense"
            else
                custom_scent="Exotic"
        if(YOKAI)
            custom_scent=pick("Incense", "Alcohol", "Iron", "Thrill")
        if(ELDRITCH)
            custom_scent=pick("Ocean", "Alien", "Exotic", "Nothingness")
        if(BEASTMAN)
            custom_scent=pick("Musk", "Animalistic", "Sweaty", "Unbathed")
        if(DEMON)
            custom_scent=pick("Brimstone", "Nothingness", "Blood", "Death")
        if(MAJIN)
            custom_scent=pick("Gum", "Sweets", "Cake", "Vanilla")
        if(DRAGON)
            custom_scent=pick("Ozone", "Animalistic", "Power", "The World")
        if(CHANGELING)
            custom_scent=pick("Decay", "Muk", "Grime", "Magical")
        if(HALFSAIYAN)
            custom_scent=pick("Musk", "Animalistic", "Sweaty", "Flowery","Cologne")
        if(ANDROID)
            custom_scent=pick("Metal", "Electricity")
        if(DRAGON)
            custom_scent=pick("Nature", "Power", "Ozone", "Animalistic")
    if(custom_scent!="Overwhelming")
        if(usr.Target.HasHellPower())
            custom_scent=pick("Brimstone", "Nothingness", "Blood", "Death", "Overwhelming")
        if(usr.Target.HasJagan())
            custom_scent="Death"
        if(usr.Target.HasMechanized())
            custom_scent="Metal"
        if(usr.Target.Secret=="Ripple"||usr.Target.Secret=="Senjutsu")
            custom_scent="Grass"
        if(usr.Target.Secret=="Vampire"||usr.Target.Secret=="Werewolf")
            custom_scent="Blood"
        if(usr.Target.Secret=="Necromancer"||usr.Target.Secret=="Zombie")
            custom_scent="Decay"