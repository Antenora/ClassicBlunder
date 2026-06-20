/obj/leftOver
    Grabbable = 0
    Attackable = 0
    Destructable = 0
    density = 0
    var/power
    var/lifetime
    var/tmp/mob/owner
    var/tmp/list/tick_on = list()
    var/proc_to_call
    var/proc_params
    var/inflicts_owner = FALSE

/obj/leftOver/proc/on_tick()
    for(var/mob/m in tick_on)
        if(proc_to_call)
            call(m,proc_to_call)(list2params(proc_params))

/obj/leftOver/Cross(atom/movable/O)
    if(ismob(O) && O != owner)
        tick_on |= O
    . = ..()

/obj/leftOver/Uncross(atom/movable/O)
    if(ismob(O) && O != owner)
        if(O in tick_on)
            tick_on -= O
    . = ..()

/obj/leftOver/Update()
    lifetime-=world.tick_lag
    if(lifetime<=0)
        ticking_generic -= src
        owner = null
        tick_on = null
        loc = null
    else
        on_tick()

/obj/leftOver/proc/on_death()
    ticking_generic -= src
    owner = null
    tick_on = null
    loc = null
/obj/leftOver/proc/init(mob/p)
    ticking_generic += src
    owner = p
    for(var/mob/m in loc)
        tick_on |= m

/obj/leftOver/Blood
    icon = 'BloodRain.dmi'
    icon_state="puddle"
    bound_height = 32
    bound_width = 32
    alpha= 0
    New(turf/T, mob/p, style_value)
        if(!T) del src
        loc = locate(T.x, T.y, T.z)
        alpha = 0
        lifetime = (5 SECONDS) * style_value
        init(p)
        animate(src, alpha = 255, time = 5)
    Cross(atom/movable/O)
        if(ismob(O) && O != owner)
            var/mob/Player/p = O
            if(!p.Swim)
                p.Swim = 1
                tick_on |= O
        . = ..()

    Uncross(atom/movable/O)
        if(ismob(O) && O != owner)
            var/mob/Player/p = O
            if(p.Swim)
                p.Swim = 0
                tick_on -= O
        . = ..()

    on_death()
        for(var/mob/p in tick_on)
            if(p.Swim)
                p.Swim = 0
        ..()

    on_tick()
        // do nothing


/obj/leftOver/poisonCloud
    icon = 'PoisonGas.dmi'
    power = 1
    lifetime = 15 SECONDS
    pixel_x = -32
    pixel_y = -32
    bound_height = 64
    bound_width = 64
    alpha = 0
    New(turf/_loc, mob/p, style_value)
        if(!_loc) del src
        loc = locate(_loc.x,_loc.y,_loc.z)
        alpha = 0
        animate(src, transform=matrix().Scale(2))
        animate(src, alpha = 255, time = 5)
        power = 5+style_value
        lifetime = (15 SECONDS) * style_value
        proc_params = list("Value" = style_value*glob.DEBUFF_INTENSITY, "Attacker" = owner)
        init(p)
        owner = p
        ..()
        spawn(5)
            animate(src, alpha = 0, time = lifetime-5)
    Update()
        lifetime-=world.tick_lag
        if(lifetime<=0)
            on_death()
        else
            on_tick()
            if(owner.Target)
                step_towards(src, owner.Target, 32)

/obj/leftOver/LingeringTornado
    icon = 'Tornado.dmi'
    density = 0
    lifetime = 60 SECONDS
    pixel_x = -32
    pixel_y = -32
    bound_height = 32
    bound_width = 32
    alpha = 255
    var/tornado_damage = 0.5
    var/tmp/mob/chase_target
    var/tmp/list/last_damage_time = list()
    var/damage_interval = 10
    var/move_interval = 5
    var/next_move_time = 0
    New(turf/_loc, mob/p, mob/target)
        loc = locate(_loc.x, _loc.y, _loc.z)
        animate(src, transform=matrix().Scale(2))
        init(p)
        owner = p
        chase_target = target
        if(!chase_target)
            chase_target = owner?.Target
        next_move_time = world.time + move_interval
        ..()
    proc/deal_tornado_damage(mob/m, initial_contact = 0)
        if(!m || m == owner || m.KO || !ismob(m)) return
        if(owner && owner != m)
            if(istype(m, /mob/Players) || istype(m, /mob/Player))
                if(initial_contact)
                    m.LoseHealth(tornado_damage)
                    last_damage_time[m] = world.time
                else
                    var/last = last_damage_time[m]
                    if(!last || (world.time - last) >= damage_interval)
                        m.LoseHealth(tornado_damage)
                        last_damage_time[m] = world.time
    on_tick()
        for(var/mob/m in tick_on)
            deal_tornado_damage(m, 0)
    Cross(atom/movable/O)
        . = ..()
        if(ismob(O) && O != owner)
            deal_tornado_damage(O, 1)
    Update()
        lifetime-=world.tick_lag
        if(lifetime<=0)
            ticking_generic -= src
            owner = null
            chase_target = null
            last_damage_time = null
            tick_on = null
            loc = null
        else
            on_tick()
            for(var/mob/m in loc)
                if(m != owner && !(m in tick_on))
                    tick_on |= m
                    deal_tornado_damage(m, 1)
            if(chase_target && !chase_target.loc)
                chase_target = null
            if(!chase_target && owner)
                chase_target = owner.Target
            var/mob/targ = chase_target || owner?.Target
            if(targ && world.time >= next_move_time)
                var/turf/my_turf = get_turf(src)
                var/turf/their_turf = get_turf(targ)
                if(my_turf != their_turf)
                    var/d = get_dir(src, targ)
                    if(d)
                        var/turf/T = get_step(src, d)
                        if(T)
                            loc = T
                    next_move_time = world.time + move_interval





