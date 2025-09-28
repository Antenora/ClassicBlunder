/obj/Items/Sword
    var/unsheathed = FALSE
    var/icon/unsheatheIcon
    var/unsheatheOffsetX = 0
    var/unsheatheOffsetY = 0
    var/unsheatheState = ""
    var/removeSheathedOnUnSheathe = TRUE
    var/sheatheIcon
    var/org_icon
    // var/unsheatheSound = sound("sword-unsheathe.wav")
    proc/addUnsheathedState()
        if(suffix && unsheatheIcon)
            var/image/im1 = image(icon=unsheatheIcon, layer=src.layer, pixel_x=unsheatheOffsetX, pixel_y=unsheatheOffsetY)
            im1.layer = src.layer
            if(usr.ArmamentGlow)
                im1.filters+=usr.ArmamentGlow
            usr.overlays += im1
            if(removeSheathedOnUnSheathe)
                AlignEquip(usr, TRUE)
            else
                AlignEquip(usr, TRUE)
                suffix = FALSE
                icon = sheatheIcon
                var/placement=FLOAT_LAYER-3
                if(src.LayerPriority)
                    placement-=src.LayerPriority
                var/image/im=image(icon=src.icon, pixel_x=src.pixel_x, pixel_y=src.pixel_y, layer=placement)
                if(istype(src, /obj/Items/Sword) || istype(src, /obj/Items/Enchantment/Staff))
                    if(usr.ArmamentGlow)
                        im.filters += usr.ArmamentGlow
                if(usr.CheckActive("Mobile Suit")&&(istype(src, /obj/Items/Sword)||istype(src, /obj/Items/Armor)||istype(src, /obj/Items/Enchantment/Staff)))
                    if(src:Conjured)
                        im.transform*=3
                        im.appearance_flags+=512
                usr.overlays+=im
                suffix="*Equipped*"
    proc/removeUnsheathedState()
        if(suffix && unsheatheIcon)
            var/image/im1 = image(icon=unsheatheIcon, layer=src.layer, pixel_x=unsheatheOffsetX, pixel_y=unsheatheOffsetY)
            if(usr.ArmamentGlow)
                im1.filters+=usr.ArmamentGlow
            usr.overlays -= im1
            if(removeSheathedOnUnSheathe)
                suffix = null
                if(usr.equippedSword == src)
                    usr.equippedSword = null
                AlignEquip(usr)
            else
                AlignEquip(usr, TRUE)
                suffix=FALSE
                icon = org_icon
                var/placement=FLOAT_LAYER-3
                if(src.LayerPriority)
                    placement-=src.LayerPriority
                var/image/im=image(icon=src.icon, pixel_x=src.pixel_x, pixel_y=src.pixel_y, layer=placement)
                if(istype(src, /obj/Items/Sword) || istype(src, /obj/Items/Enchantment/Staff))
                    if(usr.ArmamentGlow)
                        im.filters += usr.ArmamentGlow
                if(usr.CheckActive("Mobile Suit")&&(istype(src, /obj/Items/Sword)||istype(src, /obj/Items/Armor)||istype(src, /obj/Items/Enchantment/Staff)))
                    if(src:Conjured)
                        im.transform*=3
                        im.appearance_flags+=512
                usr.overlays+=im
                suffix="*Equipped*"
    verb/Unsheathe()
        if(!unsheatheIcon)
            usr<<"You need to set up an unsheathe icon for this sword."
            return
        if(unsheathed)
            usr<<"You already have your sword unsheathed."
            return
        unsheathed = TRUE
        // view(5, usr) << sound(unsheatheSound, 0, 0 , 25)
        addUnsheathedState()


    verb/Sheathe()
        if(!unsheatheIcon)
            usr<<"You need to set up an unsheathe icon for this sword."
            return
        if(!unsheathed)
            usr<<"You already have your sword sheathed."
            return
        unsheathed = FALSE
        removeUnsheathedState()


    verb/SetUnsheatheIcon()
        var/icon/newIcon = input(usr, "Set unsheathe icon", "Set unsheathe icon for this sword.") as icon|null
        if(newIcon)
            unsheatheIcon = newIcon
            usr<<"Unsheathe icon set."
        else
            usr<<"Unsheathe icon not set."
            return
        unsheatheOffsetX = input(usr, "Set unsheathe icon offset X", "Set unsheathe icon offset X for this sword.") as num
        unsheatheOffsetY = input(usr, "Set unsheathe icon offset Y", "Set unsheathe icon offset Y for this sword.") as num
        unsheatheState = input(usr, "Set unsheathe icon state", "Yes") as text
        if(!unsheatheState)
            unsheatheState = ""
        removeSheathedOnUnSheathe = input(usr, "Remove sheathed state on unsheathe?", "Yes") in list(TRUE, FALSE)
        if(!removeSheathedOnUnSheathe)
            sheatheIcon = input(usr, "Set sheathe icon", "Set sheathe icon for this sword.") as icon|null 
            org_icon = icon
        usr<<"Unsheathe icon offset X and Y set."