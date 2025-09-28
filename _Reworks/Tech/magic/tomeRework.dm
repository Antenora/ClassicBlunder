/*

Tomes:
    as they are you can keep adding pages (levels) to make it so u have an inf capacity of a tome
    tomes should have tiers or something that dictate the limit of their pages
    tome should grant the ability to use the spells in it, and with translate you can learn them
    you have a limit based on ur magic level of how many tome spells you can learn.
    tomes should be able to be upgraded to increase their limit, but they have a MAX based on tier


    turn scrolls into 1 time usages that don't gimp the spell inside, this way the person can make scrolls for people

    secruity is fine (password protected)

    cleansing is also somewhat fine
        - cant cleanse a spell that has been translated

    Bindin
        - binding should happen on extremely rare tomes, vs just any tome
        - people can app for get their shit binded if it gets to the legedendary point
        - probably invole a philo stone for automation

*/
#define MAX_EXTRA_SPELL_PER_TIER 8
#define SPELLS_PER_UPGRADE 3 // 2 t3 spells
#define BASE_SPELLS 2

#define UPGRADE_BASE_COST 1.5


/mob/Admin3/verb/Give_Fragments(mob/p in players)
    if(!p.client) return
    var/obj/Items/mineral/m = new()
    m = locate() in p
    if(!m)
        m = new()
        m.Move(p)
    m.checkDuplicate(p)
    var/num = input(src, "How many fragments?") as num
    m.value += num
    m.assignState(num)


/mob/Admin3/verb/tierUpTome(obj/Items/Enchantment/Tome/t in world)
    set name = "Tier Up Tome"
    src << "later..."

/obj/Items/Enchantment/Tome
    EnchType="TomeCreation"
    SubType="Any"
    Cost=80
    var/spellSlots = 1
    var/maxSpellSlots = 10
    var/currentSpellSlots = 0
    var/tier = 1
    var/upgrades = 0
    var/upgradeLimit = 2
    Unwieldy = 1
    var/list/obj/Skills/Spells = list()
    var/list/spellsLearnedFrom = list()

    icon = 'Tome.dmi'
    icon_state = "Inventory"
    desc = "A tome."

    proc/adjustSpellSlots(mob/p)
        maxSpellSlots = MAX_EXTRA_SPELL_PER_TIER * tier + BASE_SPELLS + round(p.getTotalMagicLevel()/2,1)
        spellSlots = BASE_SPELLS + round(p.getTotalMagicLevel()/2,1) + (SPELLS_PER_UPGRADE * upgrades)
        if(spellSlots >= maxSpellSlots)
            spellSlots = maxSpellSlots

    proc/init(t, mob/p)
        maxSpellSlots = MAX_EXTRA_SPELL_PER_TIER * t + BASE_SPELLS + round(p.getTotalMagicLevel()/2,1)
        spellSlots = BASE_SPELLS + round(p.getTotalMagicLevel()/2,1)
        tier = t
        upgrades = 0
        upgradeLimit = 2 * t

    verb/Examine()
        var/header ="<html><title>[src]</title><body bgcolor=#000000 text=#339999>"
        var/close = "</body></html>"
        var/content = ""
        content += "\[SPELL SLOTS: [currentSpellSlots] / [spellSlots]([maxSpellSlots])\]<br>"
        content += "\[TIER: [tier]\]<br>\[UPGRADES: [upgrades] / [upgradeLimit]\]<br>"
        for(var/obj/Skills/x in Spells)
            content += "\[SPELL: [x]. LEVEL: [x.Copyable] \]<br>"
        var/html = "[header][content][close]"
        usr<< browse(html, "window=[src];size=450x600")

    verb/Use_Tome()
        set category=null
        set src in usr
        if(usr.icon_state != "Meditate")
            usr << "You can't use this unless you are meditating."
            return
        if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
            return
        if(src.Using)
            return
        src.Using=1
        var/options = list("Cancel")
        if("Spell Sealing")
            options += list("Seal")
        if("TomeCreation" in usr.knowledgeTracker.learnedMagic)
            options += list("Scribe")
        if("Tome Cleansing" in usr.knowledgeTracker.learnedMagic)
            options += list("Cleanse")
        if("Tome Security" in usr.knowledgeTracker.learnedMagic)
            options += list("Secure")
        if("Tome Binding" in usr.knowledgeTracker.learnedMagic)
            options += list("Bind")
        if("Tome Expansion" in usr.knowledgeTracker.learnedMagic)
            options += list("Expand")
        if("Tome Excerpts" in usr.knowledgeTracker.learnedMagic)
            options += list("Make Scroll")
        if("Tome Translation" in usr.knowledgeTracker.learnedMagic)
            options += list("Translate")
        var/choice = input(usr, "What would you like to do?") in options
        if(choice == "Cancel")
            usr << "You either lack the ability to use this tome, or you lost interest."
            src.Using=0
            return
        switch(choice)
            if("Seal")
                var/cost = round((UPGRADE_BASE_COST*(glob.progress.EconomyCost/2)) * (tier + 1) * (upgrades + 1), 1)
                var/obj/Skills/spell = input(usr, "What spell would you like to seal?") in Spells
                if(spell.Sealed)
                    usr << "This spell is already sealed."
                    src.Using=0
                    return
                if(usr.HasFragments(cost))
                    var/confirm = input(usr, "Are you sure you want to seal this tome? It will cost [cost] fragments.") in list("Yes", "No")
                    if(confirm == "Yes")
                        if(usr.HasManaCapacity(2 * (tier + 1) * (upgrades + 1)))
                            usr.TakeManaCapacity(2 * (tier + 1) * (upgrades + 1))
                        else
                            usr << "You don't have enough mana capacity to seal this tome."
                            src.Using=0
                            return
                        usr.TakeFragments(cost)
                        spell.Sealed=0
                        usr << "You have sealed this tome."
                    else
                        usr << "You decide against sealing the tome."
                else
                    usr << "You don't have enough fragments to seal this tome."
                src.Using=0
                return
            if("Scribe")
                var/list/obj/Skills/MagicKnown = list()
                for(var/obj/Skills/s in usr.contents)
                    if(s.MagicNeeded&&s.Copyable&&s.ManaCost)
                        var/found = 0
                        for(var/obj/Skills/scribed in Spells)
                            if(scribed.type == s.type)
                                found = 1
                                break
                        if(!found)
                            MagicKnown+=s
                if(length(MagicKnown)<1)
                    usr << "You don't know any spells that can be scribed into this tome."
                    src.Using=0
                    return
                var/obj/Skills/selection = input(usr, "What spell would you like to scribe into this tome?") in MagicKnown + "Cancel"
                if(selection == "Cancel")
                    usr << "You decide against scribing a spell."
                    src.Using=0
                    return
                if(selection.Copyable > spellSlots - currentSpellSlots)
                    usr << "You don't have enough spell slots to scribe this spell."
                    src.Using=0
                    return
                var/cost = (selection.Copyable * glob.progress.EconomyCost/8) * (tier)
                var/manaCost = 5 * selection.Copyable
                if(usr.HasFragments(cost))
                    var/confirm = input(usr, "Are you sure you want to scribe [selection] into this tome? It will cost [cost] fragments and [manaCost] mana.") in list("Yes", "No")
                    if(confirm == "Yes")
                        if(usr.HasManaCapacity(manaCost))
                            usr.TakeManaCapacity(manaCost)
                        else
                            usr << "You don't have enough mana capacity to scribe this spell."
                            src.Using=0
                            return
                        usr.TakeFragments(cost)
                        addSpell(selection, usr)
                    else
                        usr << "You decide against scribing a spell."
                else
                    usr << "You don't have enough fragments to scribe this spell."
                src.Using=0
                return
            if("Translate")
                var/list/obj/Skills/scribed = list()
                for(var/obj/Skills/s in Spells)
                    if(s.SignatureTechnique)
                        continue
                    if(s.Sealed)
                        continue
                    if(!locate(s.type, usr))
                        scribed += s
                if(length(scribed)<1)
                    usr << "You don't have any spells in this tome that can be translated."
                    src.Using=0
                    return
                var/obj/Skills/selection = input(usr, "What spell would you like to translate?") in scribed + "Cancel"
                if(selection == "Cancel")
                    usr << "You decide against translating a spell."
                    src.Using=0
                    return
                var/cost = round((selection.Copyable * glob.progress.EconomyCost/2) / tier,1)
                var/manaCost = (10 * selection.Copyable) / tier
                if(selection.PreRequisite.len)
                    for(var/index in selection.PreRequisite)
                        if(!locate(text2path(index), usr.contents))
                            usr << "You don't know the pre-requisite spell [index] to translate this spell."
                            src.Using=0
                            return
                var/learningSkill = round((usr.Imagination * usr.Intelligence * usr.RPPMult) + usr.getTotalMagicLevel() / 2,1)
                var/learningReq = round(selection.Copyable * (1 + (upgrades/2 + tier/4)),1)
                if(learningSkill < learningReq)
                    usr << "You don't have enough magical mastery to translate this spell."
                    src.Using=0
                    return
                if(usr.HasFragments(cost))
                    var/confirm = input(usr, "Are you sure you want to translate [selection] into this tome? It will cost [cost] fragments and [manaCost] mana.") in list("Yes", "No")
                    if(confirm == "Yes")
                        if(usr.HasManaCapacity(manaCost))
                            usr.TakeManaCapacity(manaCost)
                        else
                            usr << "You don't have enough mana capacity to translate this spell."
                            src.Using=0
                            return
                        usr.TakeFragments(cost)
                        spellsLearnedFrom["[selection.name]"] = TRUE
                        usr << "You have translated [selection]."
                        var/obj/Skills/s = new selection.type
                        s.Copied = TRUE
                        s.copiedBy = "Tome"
                        usr.AddSkill(s)
                    else
                        usr << "You decide against translating a spell."
                        src.Using=0
                        return
                else
                    usr << "You don't have enough fragments to translate this spell."
                    src.Using=0
                    return
                src.Using=0
                return

            if("Expand")
                var/cost = round((UPGRADE_BASE_COST*(glob.progress.EconomyCost/2)) * (tier + 1) * (upgrades + 1), 1)
                if(usr.HasFragments(cost))
                    var/confirm = input(usr, "Are you sure you want to expand this tome? It will cost [cost] fragments.") in list("Yes", "No")
                    if(confirm == "Yes")
                        if(usr.HasManaCapacity(5 * (tier + 1) * (upgrades + 1)))
                            usr.TakeManaCapacity(5 * (tier + 1) * (upgrades + 1))
                        else
                            usr << "You don't have enough mana capacity to expand this tome."
                            src.Using=0
                            return
                        upgrade(usr, cost)
                    else
                        usr << "You decide against expanding the tome."
                else
                    usr << "You don't have enough fragments to expand this tome."
                src.Using=0
                return
                //TESTED AND WORKING
            if("Cleanse")
                var/cost = round((UPGRADE_BASE_COST*(glob.progress.EconomyCost/4)) * (tier + 1) * (upgrades + 1), 1)
                if(usr.HasFragments(cost))
                    var/confirm = input(usr, "Are you sure you want to cleanse a spell out of this tome? It will cost [cost] fragments.") in list("Yes", "No")
                    if(confirm == "Yes")
                        if(usr.HasManaCapacity(2 * (tier + 1) * (upgrades + 1)))
                            usr.TakeManaCapacity(2 * (tier + 1) * (upgrades + 1))
                        else
                            usr << "You don't have enough mana capacity to cleanse this tome."
                            src.Using=0
                            return
                        cleanse(usr, cost)
                    else
                        usr << "You decide against cleansing the tome."
                else
                    usr << "You don't have enough fragments to cleanse this tome."
                src.Using=0
                return
            if("Secure")
                if(Password)
                    var/check = input(usr, "What is the password?") as text
                    if(check == Password)
                        var/newPass = input(usr, "What would you like to change the password to?") as text
                        Password = newPass
                        usr << "You have changed the password. The new password is [Password]."
                    else
                        usr << "You have entered the wrong password."
                else
                    var/cost = round((UPGRADE_BASE_COST*(glob.progress.EconomyCost/10)) * (tier + 1) * (upgrades + 1), 1)
                    var/manaCost = glob.progress.EconomyMana/4
                    if(usr.HasFragments(cost))
                        var/confirm = input(usr, "Are you sure you want to secure this tome? It will cost [cost] fragments and [manaCost] mana.") in list("Yes", "No")
                        if(confirm == "Yes")
                            if(usr.HasManaCapacity(manaCost))
                                usr.TakeManaCapacity(manaCost)
                            else
                                usr << "You don't have enough mana capacity to secure this tome."
                                src.Using=0
                                return
                            Password = input(usr, "What would you like to set the password to?") as text
                            usr << "You have secured the tome. The password is [Password]."
                        else
                            usr << "You decide against securing the tome."
                    else
                        usr << "You don't have enough fragments to secure this tome."
                src.Using=0
                return
            if("Make Scroll")
                var/obj/Skills/selection = input(usr, "What spell would you like to make a scroll of?") in Spells + "Cancel"
                if(selection == "Cancel")
                    usr << "You decide against making a scroll."
                    src.Using=0
                    return
                var/cost = round(UPGRADE_BASE_COST*(glob.progress.EconomyCost/2), 1)
                cost += round(selection.Copyable * glob.progress.EconomyCost/5,10)
                if(usr.HasFragments(cost))
                    var/confirm = input(usr, "Are you sure you want to make a scroll of [selection]? It will cost [cost] fragments.") in list("Yes", "No")
                    if(confirm == "Yes")
                        if(usr.HasManaCapacity(selection.Copyable * 10 ))
                            usr.TakeManaCapacity(selection.Copyable * 10 )
                        else
                            usr << "You don't have enough mana capacity to make this scroll."
                            src.Using=0
                            return
                        usr.TakeFragments(cost)
                        var/obj/Items/Enchantment/Scroll/S = new()
                        S.init(selection, usr)
                        S.Move(usr)
                        usr << "You have made a scroll of [selection]."
                    else
                        usr << "You decide against making a scroll."
                else
                    usr << "You don't have enough fragments to make a scroll."
            if("Bind")
                // this is either app only, or they need a philo stone ( a real one )
                // this is a 1 time thing, and it should be a big deal
                var/obj/Items/Enchantment/PhilosopherStone/True/philo = null
                for(var/obj/Items/Enchantment/PhilosopherStone/True/t in usr)
                    philo = t
                    break
                if(!philo)
                    usr << "You don't have a True philosopher stone."
                    src.Using=0
                    return
                else
                    var/cost = round((UPGRADE_BASE_COST*(glob.progress.EconomyCost)) * (tier + 1) * (upgrades + 1), 1)
                    if(usr.HasFragments(cost))
                        var/confirm = input(usr, "Are you sure you want to bind this tome? It will cost [cost] fragments.") in list("Yes", "No")
                        if(confirm == "Yes")
                            if(philo.SoulStrength >= tier)
                                if(usr.HasManaCapacity(90))
                                    usr.TakeManaCapacity(90)
                                else
                                    usr << "You don't have enough mana capacity to bind this tome. (90)"
                                    src.Using=0
                                    return
                                usr.TakeFragments(cost)
                                del philo
                                Stealable=0
                            else
                                usr << "Your philosopher stone is not strong enough to bind this tome."
                                src.Using=0
                                return
                            usr << "You have bound this tome."
                        else
                            usr << "You decide against binding this tome."
                    else
                        usr << "You don't have enough fragments to bind this tome."
                src.Using=0
                return

    proc/removeSpell(obj/Skills/spell, mob/p)
        currentSpellSlots -= spell.Copyable
        Spells -= spell
        p << "You have removed [spell] from your tome. Your tome now has [currentSpellSlots] / [maxSpellSlots] spell slots."
        del spell
    proc/addSpell(obj/Skills/spell, mob/p)
        currentSpellSlots += spell.Copyable
        Spells += copyatom(spell)
        spellsLearnedFrom["[spell.name]"] = FALSE
        p << "You have added [spell] to your tome. Your tome now has [currentSpellSlots] / [maxSpellSlots] spell slots."


    proc/cleanse(mob/p, cost)
        var/obj/Skills/spell = input(p, "What spell would you like to cleanse?") in Spells
        if(spell == null)
            p << "You don't have that spell in your tome."
            return
        if(spellsLearnedFrom["[spell.name]"] == TRUE)
            p << "You can't cleanse a spell that has been translated."
            return
        removeSpell(spell, p)
        usr.TakeFragments(cost)


    proc/upgrade(mob/p, cost)
        if(upgrades+1 > upgradeLimit)
            p << "You have reached the upgrade limit for this tome."
            return
        upgrades++
        adjustSpellSlots(p)
        usr.TakeFragments(cost)
        p << "You have upgraded your tome. Your tome now has [spellSlots] / [maxSpellSlots] spell slots."

    proc/tierUp(mob/p)
        upgrades = 0
        tier++
        adjustSpellSlots(p)
        p << "You have tiered up your tome. Your tome now has [spellSlots] / [maxSpellSlots] spell slots."