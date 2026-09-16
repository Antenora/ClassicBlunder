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
        var/options = Ask(p, "What kind of buff is this?", "Augmented Gear", null, "pick", list("Autonomous", "Not Auto"), 0)
        if(options == "Autonomous")
            Techniques = list(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Augmented_Gear, new/obj/Skills/Buffs/SlotlessBuffs/Posture)
            Techniques[1].NeedsHealth = Ask(p, "When does this buff trigger?", "", null, "num", null, 0)
            Techniques[1].TooMuchHealth = Ask(p, "When does this buff end?", "", null, "num", null, 0)
        else
            Techniques = list(new/obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear, new/obj/Skills/Buffs/SlotlessBuffs/Posture)
        var/obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear/agBuff = Techniques[1]
        var/obj/Skills/Buffs/SlotlessBuffs/Posture/postureBuff = Techniques[2]
        if(p.Admin)
            agBuff.BuffName = Ask(p, "What is the name of the buff active?", "Agumented Gear", null, "text", null, 0)
            postureBuff.BuffName = Ask(p, "What is the name of the posture buff active?", "Posture", null, "text", null, 0)
            if(options != "Autonomous")
                agBuff.verbs -= list(/obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear/verb/Augmented_Gear)
                agBuff.verbs += new /obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear/verb/Augmented_Gear(agBuff, agBuff.BuffName)
            postureBuff.verbs -= list(/obj/Skills/Buffs/SlotlessBuffs/Posture/verb/Posture)
            postureBuff.verbs += new /obj/Skills/Buffs/SlotlessBuffs/Posture/verb/Posture(postureBuff, postureBuff.BuffName)
            var/cancel = 1
            while(cancel)
                var/input = Ask(p, "What skills do you want on the gear? Select Cancel to end ", "", null, "pick", (typesof(/obj/Skills) + "Cancel"), 0)
                if(input == "Cancel")
                    cancel = 0
                else
                    Techniques += new input

            Ask(p, "The next edit menus are for the buff itself, and the posture ", "", null, "confirm", null, 1, "Ok")
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

/mob/Admin2/verb/Copy_AG()
    var/obj/Items/ag = PromptArg(usr, args, 1, "Copy AG", "world:/obj/Items")
    if(isnull(ag)) return
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



/mob/Admin2/verb/Create_AG()
    set category = "Admin"
    var/mob/A = PromptArg(usr, args, 1, "Create AG", "world:/mob")
    if(isnull(A)) return
    if(!A.client) return
    var/types = Ask(src, "What kind of AG do you want to create?", "Augmented Gear", null, "pick", list("Wearables", "Sword", "Armor", "Staff"), 0)
    var/path = types == "Staff" ? "/obj/Items/Enchantment/Staff" : "/obj/Items/[types]"
    var/icon/tempicon
    var/itemType = null
    var/obj/Items/ag
    switch(types)
        if("Wearables")
            tempicon = 'ClothesShoes_Flat.dmi'
        if("Sword")
            itemType = Ask(src, "What type of sword are you making?", "", null, "pick", list("Wooden", "Light", "Medium", "Heavy"), 0)
            tempicon = 'Samurai_sword_3.dmi'
        if("Armor")
            itemType = Ask(src, "What type of armor are you making?", "", null, "pick", list("Mobile", "Balanced", "Plated"), 0)
            itemType = "[itemType]_Armor"
            tempicon = 'DevilScale.dmi'
        if("Staff")
            itemType = Ask(src, "What type of staff are you making?", "", null, "pick", list("Wand", "Rod", "Staff"), 0)
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
    var/descc = Ask(src, "What is the description of the AG?", "", null, "message", null, 0)
    ag.desc = descc