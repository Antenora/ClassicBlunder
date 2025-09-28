mob/proc/InterceptionStrike(stacks)
    var/obj/Skills/AutoHit/Counter/_counter = findOrAddSkill(/obj/Skills/AutoHit/Counter)
    _counter.adjust(src, stacks)
    Activate(_counter)

/mob/proc/canFaJin()
    if(passive_handler["Fa Jin"])
        if(last_fa_jin + glob.FA_JIN_BASE_COOLDOWN - (passive_handler["Fa Jin"] * glob.FA_JIN_COOLDOWN_REDUCTION) < world.time)
            return TRUE
    return FALSE

/obj/fa_jin
    icon = 'fa_jin.dmi'
    layer = FLY_LAYER
    alpha = 0
    pixel_x = -12
    pixel_y = 12
    mouse_opacity = 0

/mob/var/tmp/last_fa_jin = 0 
/mob/var/tmp/obj/fa_jin/fa_jin_effect
/mob/var/icon/fa_jin_icon // prob make it admin only ye 

/mob/proc/generate_fa_jin()
    if(!fa_jin_effect)
        fa_jin_effect = new()
        if(fa_jin_icon)
            fa_jin_effect.icon = fa_jin_icon
        vis_contents += fa_jin_effect
        animate(fa_jin_effect, alpha = 255, time=2)
/mob/proc/fa_jin_effect()
    if(!fa_jin_effect)
        generate_fa_jin()
    if(fa_jin_effect.alpha == 255)
        animate(fa_jin_effect, alpha = 0, time=2)
    else
        animate(fa_jin_effect, alpha = 255, time=2)
    
    
/mob/var/HitScanIcon = null
/mob/var/HitScanHitSpark = null
/mob/var/HitScanHitSparkX = -32
/mob/var/HitScanHitSparkY = -32

/obj/tracker
    var/tmp/mob/owner
    var/tmp/mob/target
    var/tmp/hitSpark = null
    var/tmp/hs_y
    var/tmp/hs_x
    var/tmp/life = 0
    New(loc, _target, _owner, _icon, _hs, _hsX = 0, _hsY = 0 )
        . = ..()
        //if(owner.styleActive?:FTG_icon)
            //icon = FTG_icon
        if(_icon)
            icon = _icon
        if(_hs)
            hitSpark = _hs
            hs_y = _hsY
            hs_x = _hsX
        filters = list(filter(type="motion_blur", x=0,y=0), filter(type="outline"))
        target = _target
        owner = _owner
        ticking_generic += src
    proc/end_effect()
        ticking_generic -= src
        del src
    Update()
        // get distance, increase speed the further they move, prob
        if(!target || life>= 100)
            end_effect()
        if(src.loc == target.loc)
            owner.HitEffect(target, null, null, null)
            end_effect()
        else
            var/distance = get_dist(src, target)
            if(distance >= 6)
                distance*=2
            step_towards(src, target, 32 * (1.5 + distance/10))  
        life+=world.tick_lag
    FTG_seeker 
        icon = 'kunai.dmi' // make this changable w/ the style
        end_effect()
            owner.Comboz(target, 0, TRUE)
            LightningBolt(target, 1)
            ticking_generic-=src
            del src
