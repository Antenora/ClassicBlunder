
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

//i'm ngl i don't know what it does above but probably best to keep it

/obj/dorkness
    icon = 'blackcutin.dmi'
    alpha = 0
    layer = 999

/obj/lightness
    icon = 'lightcutin.dmi'
    alpha = 0
    layer = 999

/obj/lightness
    icon = 'lightcutin.dmi'
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


/mob/proc/HellSSJ4Animation1(appearance1, appearance2, user) // the anim take the appearance before and after the transformation. necessary to make everything show up as it should
    var/oldview = client.view
    client.eye = locate(99,99,1)
    Quake(30, z)
    // client.perspective = EDGE_PERSPECTIVE
    // client.edge_limit = "SOUTHWEST to NORTHEAST"
    var/obj/blankHolder = new()
    var/obj/dorkness/dorkness = new()
    var/obj/lightness/lightness = new()


    var/obj/animationobj/background = new(i = 'HellSSJ4AnimationRock.dmi', s_loc = "LEFT,BOTTOM", addto = blankHolder.vis_contents, l = MOB_LAYER+0.5)
    background.icon_state = "Background"

    var/obj/animationobj/ground = new(i = 'HellSSJ4AnimationRock.dmi', s_loc = "LEFT,BOTTOM", addto = blankHolder.vis_contents, l = MOB_LAYER+0.6)
    ground.icon_state = "Ground"
    var/obj/animationobj/bleh = new(s_loc = "CENTER+1,CENTER+1", appear_flags = PIXEL_SCALE | KEEP_TOGETHER, appear_take = appearance1, l = MOB_LAYER+0.7) // THIS IS THE PLAYER CHARACTER (first appearance), that's what appear_take is for
    //NOTE THAT THE ANIMATIONOBJ IS *NOT* A PLAYER CHARACTER. IT CANNOT HANDLE HAIR AND EYES THE NORMAL WAY, YOU HAVE TO MAKE THEM OVERLAYS.
    bleh.screen_loc = "CENTER+1,CENTER+1" // ????
    bleh.dir = SOUTH
    bleh.transform = matrix().Scale(10).Translate(-150, -150)


    blankHolder.screen_loc = "LEFT,BOTTOM"
    client.screen += blankHolder
    blankHolder.vis_contents+=background
    blankHolder.vis_contents+=ground
    client.screen += bleh

    sleep(20) // aura shows up

    var/obj/animationobj/aura = new(i = 'SSJAura.dmi', _px = -32, _py = -16,  appear_flags = PIXEL_SCALE )
    aura.icon_state = "."
    bleh.overlays += aura
    sleep(10)// begin pan up
    animate(bleh, transform = matrix().Scale(10).Translate(-150, -750), time = 20, easing =SINE_EASING|EASE_IN)
    animate(ground, pixel_y=-550, time = 20, easing = SINE_EASING|EASE_IN)

    sleep(30) // supposed to pan upwards and out
    del bleh //Overlook scene
    del ground

    var/obj/animationobj/overlook = new(i = 'HellSSJ4AnimationRock.dmi', s_loc = "LEFT,BOTTOM", addto = blankHolder.vis_contents, l = MOB_LAYER+0.9)
    overlook.icon_state = "Overlook"
    blankHolder.vis_contents += overlook

    sleep(24)
    blankHolder.vis_contents+=dorkness
    blankHolder.vis_contents += lightness
    animate(lightness, alpha = 255, time = 8)
    sleep(10)

    del overlook
    animate(lightness, alpha = 0, time = 3)

    var/obj/animationobj/lightness2 = new(i = 'lightcutin.dmi', s_loc = "LEFT,BOTTOM", addto = blankHolder.vis_contents, l = MOB_LAYER+0.85)
    var/obj/animationobj/i2 = new(i = 'HellSSJ4AnimationRock.dmi', s_loc = "LEFT,BOTTOM",addto = blankHolder.vis_contents,_px = -10, _py = 0, l = MOB_LAYER+0.8)
    i2.icon_state = "HandBack"
    var/obj/animationobj/i3 = new(i = 'HellSSJ4AnimationRock.dmi', s_loc = "LEFT,BOTTOM",addto = blankHolder.vis_contents, _py = 0, l = MOB_LAYER+0.9)
    i3.icon_state = "RockStandard"


    var/obj/animationobj/bleh2 = new(s_loc = "CENTER+1,CENTER+1", appear_flags = PIXEL_SCALE | KEEP_TOGETHER, appear_take = appearance2, l = MOB_LAYER+0.7)


    bleh2.screen_loc = "CENTER+1,CENTER+1" // ????

    bleh2.dir = SOUTH

    bleh2.transform = matrix().Scale(20).Translate(50, -250)

    client.screen += bleh2

    animate(lightness2, alpha=0,time = 15)
    animate(i2, pixel_x=10,time = 10, easing = SINE_EASING|EASE_OUT)
    animate(i2, pixel_y=-200,time = 60, easing = SINE_EASING|EASE_OUT)
    animate(i3, pixel_y=-200,time = 50, easing = SINE_EASING|EASE_OUT)
    sleep(20)
    del i2
    i3.icon_state = "RockGrab"
    sleep(10)
    animate(bleh2, transform = matrix().Scale(20).Translate(50, -150), time = 50, easing = SINE_EASING|EASE_OUT)
    sleep(20)
    animate(lightness, alpha = 255, time = 10)
    sleep(10)
    del i3
    bleh2.transform = matrix().Scale(20).Translate(-20, 250)
    animate(bleh2, transform = matrix().Scale(20).Translate(-20, 0), time = 20, easing = SINE_EASING|EASE_OUT)
    animate(lightness, alpha = 0, time = 2)
    sleep(20)
    animate(bleh2, transform = matrix().Scale(4).Translate(-20, 0), time = 2)
    sleep(20)
    client.view = oldview
    del blankHolder
    del dorkness
    del lightness
    del bleh
    del bleh2
    del background
    del lightness2
    client.eye = src
    src.CutsceneMode()