/mob/proc/activateStyleEffects(forcewarp, ignore=FALSE, disarm, mob/target)
    if(disarm)
        target.Disarm(src, UsingGladiator())

var/disarm_timer = 0

/mob/proc/Disarm(mob/atk, mod)
    if(EquippedSword() || EquippedStaff())
        passive_handler.Set("Disarmed", 1)
        ticking_generic += src
        disarm_timer = glob.DISARM_TIMER * mod
    else
        Crippled = 125


/mob/Update()
    disarm_timer--
    if(disarm_timer <= 0)
        passive_handler.Set("Disarmed", 0)
        src << "You regain control of your weapon."
        ticking_generic -= src
        disarm_timer = 0

