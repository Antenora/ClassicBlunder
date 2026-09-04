
verb/Concoct_Flask()
    set category = "Utility"
    set hidden = 1
    var/choice = input(usr, "Choose an option", "Concoct Flask Options") in list("Create New Flask", "Alter Equipped Flask Concoction", "Reset Flask Concoction" ,"Upgrade Existing Flask", "Cancel")
    if(choice == "Cancel") return
    if(choice == "Create New Flask")
        CreateFlask(usr)
    if(choice == "Alter Equipped Flask Concoction") // change flasks in your contents
        EditFlaskContent(usr)
    if(choice == "Reset Flask Concoction")
        ResetFlask(usr)
    if(choice == "Upgrade Existing Flask")
        FlaskUpgrade(usr)
        return
// Makes a new flask
proc/CreateFlask(mob/P)
    var/SpecificCost = (glob.POTIONCOST * 4)
    if(P.GetMineral() < SpecificCost) // If we don't have enough... (20k)
        P << "You don't have enough Mana Bits fuckwit. You need [SpecificCost] Manabits."
        return
    else if(P.GetMineral() >= SpecificCost) // If we have enough... (20k)
        var/obj/Items/Flask/f = new /obj/Items/Flask();
        f.Slots = P.GetMaxFlaskSlots();
        P.GiveOrDrop(f);
        P << "You have created a new Flask!"
        P.TakeMineral(SpecificCost) //(20k)
// Edits which herbs are set to 1 in the flask object
proc/EditFlaskContent(mob/P) // The first layer of crimes
    var/obj/Items/Flask/Option = FlaskChoice(P)
    if(Option == "Cancel") return
    HerbOptions(P, Option)

// Determines what flask we chose
proc/FlaskChoice(mob/P)
    var/list/FlasksInContents = list("Cancel") // We will throw all your flasks in here
    for(var/obj/Items/Flask/f in P.contents)
        FlasksInContents |= f
    return input(P, "Which Flask do you wish to alter?", "Alter Existing Flask") in FlasksInContents // THIS HAS TO STAY HERE DO NOT MOVE IT

// Determines what herbs you can add, or if you can put add any at all.
proc/HerbOptions(mob/P, obj/Items/Flask/ChosenFlask)  // Selects herbs
    ChosenFlask.Slots = P.GetMaxFlaskSlots() // This might be setting it to null
    while(ChosenFlask.Slots > 0) // If you have slots, select them. Cancel
        var/list/Choices = list("Cancel") + P.PotionTypes
        var/herbchoice = input(P, "Choose an herb.", "Alter Existing Flask") in Choices
        if(herbchoice == "Cancel")
            return
        P.TakeMineral(glob.POTIONCOST/5)
        TheEvilAssIfWall(P, herbchoice, ChosenFlask)
        --ChosenFlask.Slots
        if(ChosenFlask.Slots <= 0)
            P << "You have no more flask slots!"
// War crime Proc
proc/TheEvilAssIfWall(mob/P, herbchoice, obj/Items/Flask/ChosenFlask)  //You have no idea how much I loathed making this
    if(herbchoice == "Healing Herb")
        ChosenFlask.Heal = 1
    if(herbchoice == "Magic Herb")
        ChosenFlask.Mana = 1
    if(herbchoice == "Refreshment Herb")
        ChosenFlask.Energy = 1
    if(herbchoice == "Hallucinogens")
        ChosenFlask.Hallucinogen = 1
    if(herbchoice == "Stimulant Herb")
        ChosenFlask.Searing = 1
    if(herbchoice == "Numbing Herb")
        ChosenFlask.Hard = 1
    if(herbchoice == "Relaxant Herb")
        ChosenFlask.Flowy = 1
    if(herbchoice == "Quicksilver Herb")
        ChosenFlask.Quicksilver = 1
// Resets Flask Slots
proc/ResetFlask(mob/P)
    var/Warning = input(P, "WARNING: By proceeding you will reset this flasks' total slots. You will not be refunded the mana bits you spent to make the current concoction. Proceed?", "WARNING!") in list("Yes", "No")
    if(Warning == "No") return // No need for an ifstatement if you pick yes, I'd be fucking amazed if you found a way to give a third input.
    var/obj/Items/Flask/Option = FlaskChoice(P)
    Option.Slots = P.GetMaxFlaskSlots() // Set slots to max
    // Inellegant solution to reset every variable to 0.
    Option.Heal = 0
    Option.Mana = 0
    Option.Energy = 0
    Option.Hallucinogen = 0
    Option.Searing = 0
    Option.Hard = 0
    Option.Flowy = 0
    Option.Quicksilver = 0
    P << "Flask Successfully Reset, it has [Option.Slots] slots once more."

// Upgrades flask
proc/FlaskUpgrade(mob/P)
    var/obj/Items/Flask/Option = FlaskChoice(P)
    var/SpecificCost = (glob.POTIONCOST*4)*(2+Option.Tier)
    if(P.AlchemyUnlocked < Option.Tier+2)
        P << "You must improve your knowledge of flasks to upgrade this further."
        return
    if(Option.Tier >= 2)
        P << "You cannot upgrade this flask any further"
        return
    if(P.GetMineral() < SpecificCost)
        P << "You need [SpecificCost] mana bits to upgrade this flask."
        return
    P.TakeMineral(SpecificCost)
    ++Option.Tier
    P << "You have upgraded your flask. It is now a Tier [Option.Tier] Flask."