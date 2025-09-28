// how do we do this


 /*
    on press -> trigger qTracker
    qTracker will start to track
    every key will be noted list(index = list("key", timepressed in ticks, TRIGGER = TRUE/FALSE))
    MAKE SURE TO IGNORE KEY INPUTS THAT ARE NORTH/SOUTH/EAST/WEST!!
    WHEN DONE TRACKING REMOVE THE ENTIRE THING

    on the 2nd cast, retrieve the list, make sure it is possible
    biggest issue with this is if you hit Q -> w -> -> W -> w
    hypothetically it will b impossible to complete, we must denote that Q is the start, and anything after is the thing, but anything that is done within the given time doesn't count
    so depending on the ms between the Q and the key will determine if it goes off or not
 */
#define LEEWAY_TIME 15


/datum/queueTracker
    var/tmp/TRIGGERED = null
    var/tmp/triggerTime = null
    var/tmp/initType = null
    var/tmp/LAST_CAST = -100

    proc/trigger(t)
        TRIGGERED = TRUE
        triggerTime = world.time
        initType = t

    proc/clearInfo()
        TRIGGERED = null
        initType = null
        triggerTime = null

    proc/detectInput(delay)
        // we have trigger + time + type
        // this will be active after a button was already pressed
        // it should jsut see if they are over the delay
        if(triggerTime + delay > world.time)
            return FALSE
        else
            if(triggerTime + (delay + LEEWAY_TIME) > world.time)
                // within the leeway time
                clearInfo()
                return 1
            else if(world.time in (triggerTime + delay) to (triggerTime + 5 + delay))
                // perfect cast
                clearInfo()
                return 2
        return -1
// needs to be cleaned up ^
/client/var/tmp/datum/queueTracker/keyQueue = new()



/client/var/tmp/trackingMacro = null
// need to define in the loop that when this is active to make it track for this skill

#define WXH_TO_HEIGHT(measurement, return_var) \
	do { \
		var/_measurement = measurement; \
		return_var = text2num(copytext(_measurement, findtextEx(_measurement, "x") + 1)); \
	} while(FALSE);


/obj/castingSpeechHolder
    var/toDeath = 40
    var/tmp/mob/owner = null
    var/WIDTH = 64
    maptext_width = 64
    maptext_height = 64
    alpha = 0
    var/mheight
    proc/createCastingSpeechHolder(msg, textColor, life, mob/p)
        companion_ais += src
        toDeath = life ? life : 50
        owner = p
        msg = {"<span style='font-size:8pt;font-family:"Pterra";color:[textColor];text-shadow:0 0 5px #000,0 0 5px #000,0 0 5px #000,0 0 5px #000;' class='center maptext ' style='color: [textColor]'>[msg]</span>"}
        WXH_TO_HEIGHT(p.client.MeasureText(msg, null, WIDTH), mheight)
        makeMessage(msg, textColor)
        animate(src, alpha = 150, time = 20 )
        p.vis_contents += src
    proc/makeMessage(msg, textColor)
        appearance_flags = (RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|RESET_ALPHA|PIXEL_SCALE) | KEEP_APART
        alpha = 0
        pixel_y = owner.bound_height * 0.95
        maptext_width = WIDTH
        maptext_height = mheight
        maptext_x = (WIDTH - owner.bound_width) * -0.5
        maptext = msg

    Update()
        toDeath--
        if(toDeath == 20)
            animate(src, alpha = 0, time = 20)
        if(toDeath <= 0)
            companion_ais-=src
            owner.vis_contents -= src
            del src


/mob/proc/castAnimation()
    var/static/list/phrases = list("parvus pendetur fur, magnus abire videtur", "para bellum", "parturiunt montes, nascetur ridiculus mus", \
                                    "Pericula ludus", "principiis obst, et respice finem", "pro se", "pro scientia atque sapientia", "propria manu ", \
                                    "ad vitam aut culpam", "aut vincere aut mori", "cor aut mors", "esto perpetua", "usque ad finem")
    var/obj/castingSpeechHolder/csh = new()
    csh.createCastingSpeechHolder(pick(phrases), Text_Color, null, src)