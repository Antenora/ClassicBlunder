/obj/Skills/var
    SpellElement;//tracks what element a spell belongs to and therefore what kinds of passives can be invested into it (unless you break the rules)
    SpellSlot=0;//hands down the worst way to do this, but unfortunately, we don't use inheritance well for our skills system so it's just gonna have to work
    list/SpellPassives=list();//contains a list of spell passives that are influencing this spell

/mob/proc/unlockSpellSlot(magic_node/mn)
    for(var/t in mn.grantsSkills)
        var/obj/Skills/granted = findOrAddSkill(t);
        // If the granted spell lists "Grit" among its passives (e.g. Earth Ward of
        // Stone), also grant the active dump skill so the listed passive is functional
        // for non-Beastheart mages instead of decorative on the buff bar.
        if(granted && istype(granted, /obj/Skills/Buffs))
            var/obj/Skills/Buffs/granted_buff = granted
            if(granted_buff.passives && ("Grit" in granted_buff.passives))
                if(!FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/The_Grit))
                    findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/The_Grit)
                    src << "Your magical resilience can now be channeled into a Vai Health shield."

/mob/proc/getSpellSlots()
    var/list/slots = list()
    for(var/obj/Skills/s in src)
        if(s.SpellSlot) slots |= s;
    return slots.len > 0 ? slots : 0;
/mob/proc/getSpellSlotsWithPassives()
    var/list/slots = list();
    for(var/obj/Skills/s in src)
        if(s.SpellSlot)
            if(s.SpellPassives.len > 0)
                slots |= s;
    return slots.len > 0 ? slots : 0;

var/list/allSpellPassives=list();
/proc/getAllSpellPassives()
    for(var/type in subtypesof(/spell_passive))
        if(!ispath(type)) continue
        var/spell_passive/sp = new type;
        allSpellPassives |= sp.passives;
        allSpellPassives |= sp.autohitOnlyPassives;
        allSpellPassives |= sp.projectileOnlyPassives;
        allSpellPassives |= sp.buffOnlyPassives;

#define SET_EXCEPTIONS list("StrOffense", "ForOffense", "StrRate", "ForRate")//these variables are set rather than added
#define MULT_EXCEPTIONS list("DamageMult")//list of variables that are not added to the spell, and instead are multiplied
/obj/Skills/proc/SpellSlotModification()
    if(!SpellSlot) return;
    // Reset all spell-passive-affected vars to their initial values before accumulating
    for(var/p in allSpellPassives)
        if(p in vars) vars["[p]"] = initial(vars["[p]"])
    // For buff-type slots, build the merged passives list in a LOCAL variable first,
    // then assign once at the end. Assigning to obj.list_var and then indexing into
    // it on the same proc tick races on 516.1681 (the same quirk that bites
    // GLOBAL = list() / GLOBAL["k"] = v patterns). Building locally and assigning
    // once is the workaround.
    //
    // Hit-only vars (Scorching, Reinforcement, PureDamage, etc.) are no-ops on a buff
    // because buffs don't run through autohit/projectile hit hooks — buff effects flow
    // through the associative `passives` list which the passive_handler reads on BuffOn.
    // So for buffs we route enchant `passives` and `buffOnlyPassives` into that list.
    var/obj/Skills/Buffs/buffSrc = istype(src, /obj/Skills/Buffs) ? src : null
    var/list/buildPassives = null
    if(buffSrc)
        var/list/initialPassives = initial(buffSrc.passives)
        buildPassives = initialPassives ? initialPassives.Copy() : list()
    // Apply modifications from all enchanted passives
    for(var/spell_passive/sp in SpellPassives)
        for(var/pass in sp.passives)
            if(buffSrc)
                if(buildPassives[pass]) buildPassives[pass] += sp.passives[pass]
                else buildPassives[pass] = sp.passives[pass]
            else if(pass in MULT_EXCEPTIONS)
                vars["[pass]"] *= sp.passives["[pass]"]
            else if(pass in SET_EXCEPTIONS)
                vars["[pass]"] = sp.passives["[pass]"]
            else
                vars["[pass]"] += sp.passives["[pass]"]
        for(var/autoPass in sp.autohitOnlyPassives)
            if(buffSrc) continue
            if(autoPass in MULT_EXCEPTIONS)
                vars["[autoPass]"] *= sp.autohitOnlyPassives["[autoPass]"]
            else if(autoPass in SET_EXCEPTIONS)
                vars["[autoPass]"] = sp.autohitOnlyPassives["[autoPass]"]
            else
                vars["[autoPass]"] += sp.autohitOnlyPassives["[autoPass]"]
        for(var/projPass in sp.projectileOnlyPassives)
            if(buffSrc) continue
            if(projPass in MULT_EXCEPTIONS)
                vars["[projPass]"] *= sp.projectileOnlyPassives["[projPass]"]
            else if(projPass in SET_EXCEPTIONS)
                vars["[projPass]"] = sp.projectileOnlyPassives["[projPass]"]
            else
                vars["[projPass]"] += sp.projectileOnlyPassives["[projPass]"]
        for(var/buffPass in sp.buffOnlyPassives)
            if(buffSrc)
                if(buildPassives[buffPass]) buildPassives[buffPass] += sp.buffOnlyPassives[buffPass]
                else buildPassives[buffPass] = sp.buffOnlyPassives[buffPass]
            else if(buffPass in MULT_EXCEPTIONS)
                vars["[buffPass]"] *= sp.buffOnlyPassives["[buffPass]"]
            else if(buffPass in SET_EXCEPTIONS)
                vars["[buffPass]"] = sp.buffOnlyPassives["[buffPass]"]
            else
                vars["[buffPass]"] += sp.buffOnlyPassives["[buffPass]"]
    if(buffSrc)
        buffSrc.passives = buildPassives



/*
/mob/verb/find_spell_slots()
    set category="Debug"
    set name = "DEBUG: Find Spell Slots"
    var/list/slots = getSpellSlots()
    if(!slots)
        src << "no slots"
        return;
    for(var/x in slots)
        src << "slot found: [x]";*/