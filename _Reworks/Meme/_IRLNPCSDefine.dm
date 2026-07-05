/client/var/tmp/npcInterface/interfaceHUD = new()

npcInterface
    var/mob/owner = null // a key generally, this won't be saved
    var/mob/npc = null // the mob this is attached to
    var/lastUpdate = 0 // the last time we updated the interface
    var/lastSay = 0 // the last words that were put in the hud
    var/obj/speechbubble = null // the speech bubble object
    var/obj/mugshot = null // the mugshot object
    var/obj/information = null // the information object

/mob/irlNPC
    var/orgX
    var/orgY
    var/orgZ
    var/profession
    var/newName
    var/list/sayings = list() // a list of sayings that are common
    var/list/raresaying = list() // a list of sayings that are rare
    var/icon/mugshot = null // the mugshot of the npc