/mob/Player/AI/GIGASpiritSummon
    var/list/voicelines = list("attack" = list(), "dash" = list(), "reverse_dash" = list(), "assist" = list())
    var/glow_filter    
    var/last_decision = "idle"
    var/last_decision_extended = "none"
    var/list/queues = list()
    var/list/autohits = list()
    var/list/projs = list()
/mob/Player/AI/GIGASpiritSummon/New()
    if(!passive_handler)
        passive_handler = new()
    ..() 


/mob/Player/AI/GIGASpiritSummon/proc/vanish()
    animate(src, alpha=0, time = 10, easing=SINE_EASING)
/mob/Player/AI/GIGASpiritSummon/proc/appear(mob/p)
    src.loc = locate(p.x, p.y, p.z)
    animate(src, alpha=255, time = 15, easing=SINE_EASING)
/mob/Player/AI/GIGASpiritSummon/proc/initSkills()

/mob/Player/AI/GIGASpiritSummon/proc/canAct()
    if(Launched || Stunned || icon_state=="KB")
        return 0
    if(icon_state == "Meditate")
        icon_state = ""
    return 1

/mob/Player/AI/GIGASpiritSummon/proc/handleTargetting()
    if(istype(Target, /mob/Player/AI))
        if(Target:ai_owner)
            Target = Target:ai_owner
            
/mob/Player/AI/GIGASpiritSummon/proc/melee(mob/target)
    if(!canAct())
        return
    Target = target ? target : ai_owner.Target
    if(!Target)
        return
    if(Target.KO)
        handleTargetting()
        // if(Target == prev_target)
        //     Target = null
        //     ai_state = "idle"
        //     return

    

