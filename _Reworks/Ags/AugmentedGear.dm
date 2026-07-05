proc/copyatom(atom/a)
	if(!a) return
	var/atom/b = new a.type
	if(a.vars["name"])
		b.name = a.name
	for(var/v in a.vars)
		if(issaved(a.vars[v]))
			if(islist(a.vars[v]))
				var/list/new_list = new()
				for(var/key in a.vars[v])
					var/value = a.vars[v][key]
					var/copy_value
					if(istype(value, /atom))
						copy_value = copyatom(value)
					else if(islist(value))
						copy_value = value:Copy()
					else
						copy_value = value
					new_list[key] = copy_value
				b.vars[v] = new_list
			else
				b.vars[v] = a.vars[v]
	return b



/obj/Items
    proc/freshCreate(mob/p)
        if(!Augmented) return
        // this is on creation of the ag, if we are having classes or statis, mention them here
        var/options = input(p, "What kind of buff is this?", "Augmented Gear") in list("Autonomous", "Not Auto")
        if(options == "Autonomous")
            Techniques = list(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Augmented_Gear, new/obj/Skills/Buffs/SlotlessBuffs/Posture)
            Techniques[1].NeedsHealth = input(p, "When does this buff trigger?") as num
            Techniques[1].TooMuchHealth = input(p, "When does this buff end?") as num
        else
            Techniques = list(new/obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear, new/obj/Skills/Buffs/SlotlessBuffs/Posture)
        var/obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear/agBuff = Techniques[1]
        var/obj/Skills/Buffs/SlotlessBuffs/Posture/postureBuff = Techniques[2]
        if(p.Admin)
            agBuff.BuffName = input(p, "What is the name of the buff active?", "Agumented Gear") as text
            postureBuff.BuffName = input(p, "What is the name of the posture buff active?", "Posture") as text
            if(options != "Autonomous")
                agBuff.verbs -= list(/obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear/verb/Augmented_Gear)
                agBuff.verbs += new /obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear/verb/Augmented_Gear(agBuff, agBuff.BuffName)
            postureBuff.verbs -= list(/obj/Skills/Buffs/SlotlessBuffs/Posture/verb/Posture)
            postureBuff.verbs += new /obj/Skills/Buffs/SlotlessBuffs/Posture/verb/Posture(postureBuff, postureBuff.BuffName)
            var/cancel = 1
            while(cancel)
                var/input = input(p, "What skills do you want on the gear? Select Cancel to end ") in typesof(/obj/Skills) + "Cancel"
                if(input == "Cancel")
                    cancel = 0
                else
                    Techniques += new input

            alert(p, "The next edit menus are for the buff itself, and the posture ")
            p << "You have created an AG named [agBuff.BuffName] with the following skills: [jointext(Techniques, ", ")]"
            archive.addAG(src)
            EditAll(src)


    proc/EditBuff(mob/p)
        if(!Augmented) return
        if(p.Admin)
            p?:Edit(Techniques[1])

    proc/EditPosture(mob/p)
        if(!Augmented) return
        if(p.Admin)
            p?:Edit(Techniques[2])

    proc/EditAll(mob/p)
        if(!Augmented) return
        if(p.Admin)
            for(var/i in Techniques)
                p?:Edit(i)

/mob/Admin2/verb/Copy_AG(obj/Items/ag in world)
    if(!ag.Augmented)
        src<<"Not an AG"
        return
    var/obj/Items/newAG = copyatom(ag)
    for(var/p in ag.passives)
        newAG.passives[p] = ag.passives[p]
    var/list/techs = list()
    for(var/technique in ag.Techniques)
        techs += copyatom(technique)
    newAG.Techniques = techs
    newAG.name = "[ag.name]"
    newAG.Move(src)
    archive.addAG(newAG)



/mob/Admin2/verb/Create_AG(mob/A in world)
    set category = "Admin"
    if(!A.client) return
    var/types = input(src, "What kind of AG do you want to create?", "Augmented Gear") in list("Wearables", "Sword", "Armor", "Staff")
    var/path = types == "Staff" ? "/obj/Items/Enchantment/Staff" : "/obj/Items/[types]"
    var/icon/tempicon
    var/itemType = null
    var/obj/Items/ag
    switch(types)
        if("Wearables")
            tempicon = 'ClothesShoes_Flat.dmi'
        if("Sword")
            itemType = input(src, "What type of sword are you making?") in list("Wooden", "Light", "Medium", "Heavy")
            tempicon = 'Samurai_sword_3.dmi'
        if("Armor")
            itemType = input(src, "What type of armor are you making?") in list("Mobile", "Balanced", "Plated")
            itemType = "[itemType]_Armor"
            tempicon = 'DevilScale.dmi'
        if("Staff")
            itemType = input(src, "What type of staff are you making?") in list("Wand", "Rod", "Staff")
            itemType = "NonElemental/[itemType]"
            tempicon = 'Staff2.dmi'
    if(!itemType)
        path= "[path]"
    else
        path = "[path]/[itemType]"
    ag = new path
    ag.UpdatesDescription = FALSE
    ag.icon = tempicon
    ag.Augmented = 1
    ag.Destructable = 0
    ag.freshCreate(src)
    ag.Move(A)
    var/descc = input(src, "What is the description of the AG?") as message
    ag.desc = descc