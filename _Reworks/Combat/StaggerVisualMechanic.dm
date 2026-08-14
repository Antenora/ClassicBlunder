mob/var/tmp/obj/BossStaggerBack/boss_stagger_back
mob/var/tmp/obj/BossStaggerFill/boss_stagger_fill

obj/BossStaggerBack
    icon = 'StaggerBar.dmi'
    icon_state = "back"
    layer = FLOAT_LAYER
    plane = FLOAT_PLANE
    mouse_opacity = 0
    pixel_x = 0
    pixel_y = 36

obj/BossStaggerFill
    icon = 'StaggerBar.dmi'
    icon_state = "fill"
    layer = FLOAT_LAYER + 30
    plane = FLOAT_PLANE
    mouse_opacity = 0
    pixel_x = 0
    pixel_y = 36

mob/proc/UpdateBossStaggerBar()
    if(!passive_handler.Get("BossStagger"))
        HideBossStaggerBar()
        return

    if(!boss_stagger_back)
        for(var/obj/BossStaggerBack/B in vis_contents)
            if(!boss_stagger_back)
                boss_stagger_back = B
            else
                vis_contents -= B
                del(B)

        if(!boss_stagger_back)
            boss_stagger_back = new /obj/BossStaggerBack
            vis_contents += boss_stagger_back

    if(!boss_stagger_fill)
        for(var/obj/BossStaggerFill/F in vis_contents)
            if(!boss_stagger_fill)
                boss_stagger_fill = F
            else
                vis_contents -= F
                del(F)

        if(!boss_stagger_fill)
            boss_stagger_fill = new /obj/BossStaggerFill
            vis_contents += boss_stagger_fill

    var/max_stagger = 100

    var/percent = StaggerMeter / max_stagger
    percent = min(max(percent, 0), 1)

    var/matrix/M = matrix()
    M.Scale(percent, 1)

    boss_stagger_fill.transform = M


mob/proc/HideBossStaggerBar()
    if(boss_stagger_back)
        vis_contents -= boss_stagger_back
        del boss_stagger_back
        boss_stagger_back = null

    if(boss_stagger_fill)
        vis_contents -= boss_stagger_fill
        del boss_stagger_fill
        boss_stagger_fill = null

/strikeHook/bossStagger
    stage = "post"
    fire(strike/S)
        var/mob/attacker = S.attacker
        var/mob/defender = S.defender
        var/val = S.dealt
        if(!defender.passive_handler.Get("BossStagger") || defender.passive_handler.Get("Staggered!"))
            return
        defender.StaggerMeter+=min(max(val, 0.1), glob.STAGGER_HIT_CAP)*defender.StaggerMult
        defender.StaggerMeter += 0.04*defender.StaggerMult //the old prob(2) drip, flattened
        defender.UpdateBossStaggerBar()
        if(defender.StaggerMeter>=100)
            defender.HideBossStaggerBar()
            defender.StaggerMeter=0
            var/StunStacking = 0
            if(defender.Stunned > 0) //Was already stunned
                StunStacking = 1
            Stun(defender, 15, TRUE)
            if(StunStacking == 1)
                defender.last_stunned = defender.last_stunned + 150
            KKTShockwave(defender, icon='KenShockwaveGold.dmi', Size=4, Time=16)
            OMsg(attacker, "<b><font color='green'><font size=+1>[attacker] lands a decisive strike! [defender] is stunned-- Use everything you've got!</font color></font size></b>")
            defender.passive_handler.Set("Staggered!", 1)
