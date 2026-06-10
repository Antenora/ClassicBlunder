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
        boss_stagger_back = new /obj/BossStaggerBack
        vis_contents += boss_stagger_back

   	if(!boss_stagger_fill)
   	    boss_stagger_fill = new /obj/BossStaggerFill
   	    vis_contents += boss_stagger_fill

    var/max_stagger = 100
    if(!max_stagger)
        max_stagger = 100

    var/percent = StaggerMeter / max_stagger
    percent = min(max(percent, 0), 1)

    var/matrix/M = matrix()
    M.Scale(percent,1)

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