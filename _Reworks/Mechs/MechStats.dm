/mob/proc/findMecha()
    var/obj/Items/Gear/Mobile_Suit/MS = locate() in src
    return MS ? MS : FALSE