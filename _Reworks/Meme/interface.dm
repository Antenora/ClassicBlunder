/*

npcInterface
    var/owner = null // a key generally, this won't be saved
    var/mob/npc = null // the mob this is attached to
    var/lastUpdate = 0 // the last time we updated the interface
    var/lastSay = 0 // the last words that were put in the hud
    var/obj/speechbubble = null // the speech bubble object
    var/obj/mugshot = null // the mugshot object


/mob/irlNPC
    var/profession
    var/newName
    var/list/sayings = list() // a list of sayings that are common
    var/list/raresaying = list() // a list of sayings that are rare
    var/icon/mugshot = null // the mugshot of the npc

*/




/obj/mugshot
    New(icon/i)
        icon = i

/obj/speechbubble
    icon ='Icons/irlNPCs/speech.dmi'
    New(text)
        maptext="<html><center><small>[text]</font></center></html>"
        maptext_width = 448
        maptext_height = 74
        maptext_y = 84
        maptext_x = 17
        pixel_y = 85

/obj/infoBoxNPC
    icon = 'Icons/irlNPCs/infoBox.dmi'
    New(text)
        maptext="<html><center><small>[text]</font></center></html>"
        maptext_width = 96
        maptext_height = 64
        maptext_y = 12
        maptext_x = 0
        pixel_x = 100

npcInterface/proc/displayInformationBox(mob/owner, text)
    if(information)
        clearInformationBox(owner)
    information = new /obj/infoBoxNPC(text)
    mugshot.vis_contents += information

npcInterface/proc/clearInformationBox(mob/owner)
    if(information)
        mugshot.vis_contents -= information
        information = null
        del information // in case it isn't deleted


npcInterface/proc/displayMugshot(mob/irlNPC/npc, mob/owner)
    if(mugshot)
        clearMugshot(owner)
    mugshot = new /obj/mugshot(npc.mugshot) // this will pass the icon
    owner.client.screen += mugshot
    mugshot.screen_loc = "LEFT,BOTTOM"

npcInterface/proc/clearMugshot(mob/owner)
    if(mugshot)
        owner.client.screen -= mugshot
        mugshot = null
        del mugshot // in case it isn't deleted

npcInterface/proc/displaySpeechBubble(mob/owner, text)
    if(speechbubble)
        clearSpeechBubble(owner)
    speechbubble = new /obj/speechbubble(text)
    mugshot.vis_contents += speechbubble

npcInterface/proc/clearSpeechBubble(mob/owner)
    if(speechbubble)
        mugshot.vis_contents -= speechbubble
        speechbubble = null
        del speechbubble // in case it isn't deleted

npcInterface/proc/setUpVars(mob/npc, mob/pc)
    if(owner)
        clearVars()
    owner = pc
    src.npc = npc

npcInterface/proc/clearVars()
    owner = null
    npc = null

npcInterface/proc/fadeOut()
    blobLoop -= src
    animate(mugshot, alpha = 0, time = 15)
    sleep(15)
    clearMugshot(owner)
    clearSpeechBubble(owner)
    clearInformationBox(owner)
    clearVars()



npcInterface/Update()
    if(get_dist(owner, npc) > 5 || lastUpdate + 300 < world.time)
        lastUpdate = world.time
        fadeOut()
        return
