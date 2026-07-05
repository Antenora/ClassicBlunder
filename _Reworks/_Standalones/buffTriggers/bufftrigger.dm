
/datum/BuffTrigger
    var/tmp/owner
    var/tmp/obj/Skills/Buffs/SlotlessBuffs/parent_buff
    var/trigger // trigger this
    var/trigger_when // when this happens
    var/trigger_at // at what?
    var/trigger_ref// flexibility
    var/tmp/atom/reference_this // what to reference
    var/reference_this_var // yawn
    var/set_to = 0
    proc/init(mob/p, obj/Skills/Buffs/SlotlessBuffs/b)
    New(mob/p, obj/Skills/Buffs/SlotlessBuffs/b)
        init(p, b)
    
    proc/trigger(mob/p,  obj/Skills/Buffs/SlotlessBuffs/b, triggerThing)
        if(ispath(text2path(triggerThing)))
            p.throwFollowUp(triggerThing)
        if(set_to)
            if(reference_this_var)
                reference_this.vars[reference_this_var][trigger_ref] = set_to
            else
                reference_this.vars[trigger_ref] = set_to
    proc/checkTrigger(mob/p, obj/Skills/Buffs/SlotlessBuffs/b)
        if(!reference_this)
            init(p, b)
        if(trigger)
            switch(trigger_when)
                if("EqualOrMore")
                    var/thing2compare
                    if(reference_this_var)
                        thing2compare = reference_this?:vars[reference_this_var][trigger_ref]
                    else
                        thing2compare = reference_this?:vars[trigger_ref]
                    if(thing2compare >= trigger_at)
                        trigger(p, b, trigger)
                        if(set_to)
                            if(reference_this_var)
                                reference_this?:vars[reference_this_var][trigger_ref] = set_to
                            else
                                reference_this?:vars[trigger_ref] = set_to