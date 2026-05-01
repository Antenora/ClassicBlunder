#define RANDOM_ALERT list("You feel watched", "Something deep within stirs", "Is there somebody behind you?", "You check over your shoulder, but there's nothing there.", "Faint arcane lingers in the area, if you can detect mana, its plentiful.", "What was... that?")

imitation_info
    var/list/clothes = list()
    var/selfInfo = FALSE
    var/scent
    var/imitatedName
    var/profile
    var/textColor
    var/emoteColor
    var/baseIcon
    var/powerToCopy
    var/list/pronouns
    var/catchline
    var/hair
    var/hair_x
    var/hair_y
    var/hairunder
    var/hairunder_x
    var/hairunder_y
    var/offset_x
    var/offset_y
    var/origin

    New(mob/user, mob/target)
        if(target)
            scent = target.custom_scent
            imitatedName = target.name
            profile = target.Profile
            textColor = target.Text_Color
            emoteColor = target.Emote_Color
            baseIcon = target.icon
            powerToCopy = user.Get_Scouter_Reading(target)
            pronouns = target.information.pronouns.Copy()
            catchline = target.information.catchline
            hair = target.Hair_Base
            hair_x = target.HairX
            hair_y = target.HairY
            hairunder = target.HairUnderlay
            hairunder_x = target.HairUnderlayX
            hairunder_y = target.HairUnderlayY
            offset_x = target.pixel_x 
            offset_y = target.pixel_y
            origin = target.SpawnDisplay
            if(target == user)
                selfInfo = TRUE
                for(var/obj/Items/Wearables/c in user)
                    if(c.suffix == "*Equipped*")
                        clothes += c
            else
                for(var/obj/Items/Wearables/c in target)
                    if(c.suffix == "*Equipped*")
                        var/obj/Items/Wearables/newClothing = new c.type()
                        newClothing.icon = c.icon
                        newClothing.UnderlayIcon = c.UnderlayIcon
                        newClothing.UnderlayX = c.UnderlayX
                        newClothing.UnderlayY = c.UnderlayY
                        newClothing.EquipIcon = c.EquipIcon
                        newClothing.pixel_x = c.pixel_x
                        newClothing.pixel_y = c.pixel_y
                        newClothing.LayerPriority = c.LayerPriority
                        newClothing.IsHat = c.IsHat
                        newClothing.SpecialClothing = c.SpecialClothing
                        clothes += newClothing

    proc/swapTo(mob/user)
        user.custom_scent = scent
        user.name = imitatedName
        user.Profile = profile
        user.Text_Color = textColor
        user.Emote_Color = emoteColor
        user.icon = baseIcon
        user.information.pronouns = pronouns.Copy()
        user.information.catchline = catchline
        user.Hair_Base = hair
        user.HairX = hair_x
        user.HairY = hair_y 
        user.HairUnderlay = hairunder 
        user.HairUnderlayX = hairunder_x 
        user.HairUnderlayY = hairunder_y 
        user.pixel_x = offset_x
        user.pixel_y = offset_y
        user.SpawnDisplay = origin
        if(!selfInfo)
            for(var/obj/Items/Wearables/oldClothes in user)
                if(oldClothes.suffix == "*Equipped*")
                    oldClothes.UnEquip(user)

    proc/cleanUpClothes(mob/user)
        if(selfInfo)
            for(var/obj/Items/Wearables/oldClothing in clothes)
                if(oldClothing && oldClothing.loc == user && oldClothing.suffix != "*Equipped*")
                    oldClothing.Equip(user)
        else
            for(var/obj/Items/Wearables/newClothing in clothes)
                del newClothing
        clothes = list()

/obj/Skills/Utility/Imitate
    var/imitation_info/imitating_info
    var/imitation_info/old_info
    Cooldown = 10
    verb/Change_Scent()
        set category = "Roleplay"
        var/category = input(usr, "What category?") in scents
        usr.custom_scent = input(usr, "What scent?") in scents[category]
        usr << "Scent changed to [usr.custom_scent]"
    
    verb/Activate_Void()
        set category = "Roleplay"
        usr.passive_handler.Set("Void", !usr.passive_handler.passives["Void"])
        usr << "Void is [usr.passive_handler["Void"] ? "on" : "off"]."


    verb/Imitate()
        set category = "Roleplay"
        if(usr.Imitating)
            var/oldName = usr.name
            OMsg(usr, "[usr]'s appearance distorts and their illusion crackles...")
            usr.invisibility = 99
            if(imitating_info)
                imitating_info.cleanUpClothes(usr)
                imitating_info = null
            if(old_info)
                old_info.swapTo(usr)
                old_info.cleanUpClothes(usr)
                old_info = null
            usr.Imitating = 0
            usr.AppearanceOff()
            usr.AppearanceOn()
            sleep(10)
            usr.invisibility = 0
            OMsg(usr, "[usr] stands where [oldName] used to, their disguise cast away!")
            src.Cooldown()
        else
            if(usr.CheckSlotless("Disguise"))
                usr << "You cannot imitate while disguised. Drop your disguise first."
                return
            var/mob/Target = usr.Target
            if(!isplayer(Target))
                usr << "You can't imitate anything that isn't a player!" 
                return
            if(Target && get_dist(usr, Target) < 20)
                if(!Target.client) return
                Target <<"<i>[pick(RANDOM_ALERT)]</i>"
                usr.invisibility = 99
                usr<<"<i>You fade into the ether as your magic replicates [Target]'s form.</i>"
                old_info = new/imitation_info(usr, usr)
                imitating_info = new/imitation_info(usr, Target)
                imitating_info.swapTo(usr)
                usr.Imitating = 1
                usr.AppearanceOn()
                sleep(10)
                usr.invisibility = 0
            else
                usr << "Your target is too far"
