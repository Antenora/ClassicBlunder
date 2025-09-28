/mob/var/scrollTicker = 0
/mob/proc/setScrollTicker(ticker)
    scrollTicker = ticker

/obj/Items/Enchantment/Scroll
    Unobtainable = 1
    var/spell
    icon='Scroll.dmi'
    desc = "A one-time scroll that casts a magic spell without a focus."
    proc/init(obj/Skills/theSpell, mob/p)
        spell = theSpell.type

    Click()
        if(src in usr) // ?
            if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
                return
            if(!spell || Using || usr.scrollTicker > 0)
                usr << "You can't use that right now."
                return
            var/obj/Skills/newSpell = new spell
            newSpell.MagicNeeded = 0
            switch(newSpell.parent_type)
                if(/obj/Skills/AutoHit/Magic)
                    usr.Activate(newSpell)
                if(/obj/Skills/Projectile/Magic)
                    usr.UseProjectile(newSpell)
                if(/obj/Skills/Buffs/SlotlessBuffs/Magic)
                    var/obj/Skills/Buffs/SlotlessBuffs/m = newSpell
                    m?:Trigger(usr)
            usr.setScrollTicker(600)
            usr << "You use the scroll with spell [newSpell.name]."
            del spell

// TODO make scrolls use a spell on click, which can't be used if they have used on recently