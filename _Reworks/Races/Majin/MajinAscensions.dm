/mob/proc/prompt(message, title, list/options)
    var/choice = input(src, message, title) in options
    return choice

ascensions
    var/list/choices = list() // if there is a list of choices
    var/list/varsByAscension = list( "1" = list(), "2" = list(), "3" = list()) // a list of variables and values to give to them
    var/list/skillsByAscension = list( "1" = list(), "2" = list(), "3" = list()) // a list of skills and values to give to them
ascensions/majin

/mob/var/list/majinPicks = new()
