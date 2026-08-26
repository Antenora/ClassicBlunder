mob/proc/gainSorcerer()
    src << "You are now capable of wielding Cursed Energy... you are now A <b>Sorcerer</b>."
    src.Saga = Sorcerer
    src.SagaLevel = 1
    for(var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC in src)
        src.DeleteSkill(KC)
    src.AddSkill(/obj/Skills/Buffs/Ki_Control/Cursed_Energy)

    var/list/CTList = list("Limitless", "Shrine", "Ratio", "Disaster Flames", "Disaster Tides", "Disaster Plants", "Blood Manipulation", "Ice Formation") // More to be added
    src.CursedTechnique = input("Which technique does [src] recieve?", "Cursed Technique") in CTList

mob/tierUpSaga(Path)
    ..()
    if(Path == "Sorcerer")
        switch(SagaLevel)
            if(2)
                src << "Your Understanding of Cursed Energy and your Cursed Technique grows."


// mob/proc/giveTechniqueSkills()
    // if(src.CursedTechnique == "Limitless")