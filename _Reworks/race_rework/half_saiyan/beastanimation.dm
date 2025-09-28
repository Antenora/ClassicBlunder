
/obj/plane_test
    plane = 11
    appearance_flags = PLANE_MASTER | PIXEL_SCALE
    screen_loc = "1,1"
    mouse_opacity = 0
    layer = BACKGROUND_LAYER

/obj/client_plane_master
    plane = FLOAT_PLANE
    appearance_flags = PLANE_MASTER | PIXEL_SCALE
    screen_loc = "LEFT,BOTTOM"
    mouse_opacity = 1
    layer = BACKGROUND_LAYER



/obj/dorkness
    icon = 'blackcutin.dmi'
    alpha = 0
    layer = 999

/obj/lightness
    icon = 'lightcutin.dmi'
    alpha = 0
    layer = 999

/obj/flicker
    icon = 'flickercutin.dmi'
    alpha = 0
    layer = 999

/obj/animationobj
    layer = 4.9
    appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
    New(i, s_loc, a_loc, addto,_px,_py, appear_take, l, appear_flags)
        if(i)
            icon = i
        if(screen_loc)
            screen_loc = s_loc
        if(appear_take)
            appearance = appear_take
        if(l)
            layer = l
        if(appear_flags)
            appearance_flags = appear_flags
        if(_py)
            pixel_y = _py
        if(_px)
            pixel_x = _px
        if(addto)
            addto += src
// prob shouldn't make more objs, but w/e
/*
/mob/verb/testBeast()
    set category = "Debug"
    var/oldview = client.view
    client.eye = locate(99,99,1)
    Quake(30, z)
    // client.perspective = EDGE_PERSPECTIVE
    // client.edge_limit = "SOUTHWEST to NORTHEAST"
    var/obj/blankHolder = new()
    var/obj/dorkness/dorkness = new()
    var/obj/lightness/lightness = new()
    var/obj/animationobj/i = new(i = 'Cut in Overlay.dmi', s_loc = "LEFT,BOTTOM", addto = blankHolder.vis_contents, l = MOB_LAYER+0.9)
    var/obj/animationobj/i2 = new(i = 'Cut in Underlay-min.dmi', s_loc = "LEFT,BOTTOM",addto = blankHolder.vis_contents, l = MOB_LAYER)
    var/obj/animationobj/i3 = new(i = 'Cut in Underlay-min.dmi', s_loc = "LEFT,BOTTOM",addto = i2.vis_contents, _py = 672)


    blankHolder.screen_loc = "LEFT,BOTTOM"
    client.screen += blankHolder
    blankHolder.vis_contents+=dorkness

    var/obj/animationobj/bleh = new(s_loc = "CENTER+1,CENTER+1", appear_flags = PIXEL_SCALE | KEEP_TOGETHER, appear_take = src.appearance)
    bleh.screen_loc = "CENTER+1,CENTER+1" // ????
    bleh.layer = FLY_LAYER
    bleh.dir = SOUTH
    bleh.transform = matrix().Scale(4)
    client.screen += bleh
    animate(i2, pixel_y=-64,time = 30)
    flick("", i)
    sleep(15)
    animate(dorkness, alpha = 255, time = 10)
    sleep(15)
    Quake(30, z)
    del i
    del i2
    del i3
    dorkness.alpha = 0
    blankHolder.vis_contents-=dorkness
    // del blankHolder

    var/obj/plane_test/plane_master = new()
    plane_master.screen_loc = "LEFT,BOTTOM"
    client.screen += plane_master

    var/obj/animationobj/test = new(i = 'SharinganEyes.dmi', appear_flags = PIXEL_SCALE | KEEP_TOGETHER, l = MOB_LAYER+0.1)

    client.screen -= bleh
    bleh.transform = matrix()
    bleh.layer = MOB_LAYER
    plane_master.vis_contents += bleh
    plane_master.vis_contents += test
    blankHolder.vis_contents += lightness
    blankHolder.vis_contents += dorkness
    animate(plane_master, transform=matrix().Scale(126), time = 20, easing = CUBIC_EASING)
    sleep(16)
    var/obj/animationobj/tester = new(i = 'GodOrb.dmi', _px = 175, _py = 250, appear_flags = PIXEL_SCALE | KEEP_TOGETHER, l = FLY_LAYER, addto = plane_master.vis_contents)
    tester.transform = matrix().Scale(0.001)
    tester.color = rgb(174, 0, 0, 255)
    plane_master.vis_contents += tester
    var/matrix/M = matrix().Scale(0.25)
    animate(tester, transform = M, time = 10)
    sleep(8)
    del tester
    lightness.alpha = 255
    sleep(2)
    lightness.alpha = 0
    dorkness.alpha = 255
    sleep(2)
    lightness.alpha = 255
    dorkness.alpha = 0
    sleep(2)
    lightness.alpha = 0
    del dorkness
    del test
    plane_master.screen_loc = "CENTER,CENTER"
    animate(plane_master, transform=matrix())
    client.view = oldview
    var/obj/animationobj/aura = new(i = 'Super Amazing Beast Aura.dmi', _px = -32, _py = 32,  appear_flags = PIXEL_SCALE )
    aura.transform = matrix().Scale(1.75)
    bleh.overlays += aura
    var/datum/effect/Test2/t = new(bleh, 250)
    t.emitters[1].alpha = 155
    animate(t.emitters[1], alpha = 255, time = 20)
    sleep(75)
    animate(lightness, alpha = 255, time = 7)
    del t
    sleep(8)
    plane_master.vis_contents -= bleh
    bleh.overlays -= aura
    del bleh
    lightness.alpha = 0
    blankHolder.vis_contents -= lightness
    del blankHolder
    del lightness
    client.eye = src
    overlays += aura*/