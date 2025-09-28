// TESTED
var/list/debuffVars = list("Burning", "Scorching", "Chilling","Freezing", "Crushing", \
    "Shattering", "Shocking", "Paralyzing", "Poisoning","Toxic")
var/list/debuff2Element = list("Burning" = "Fire", "Scorching" = "Fire", \
    "Chilling" = "Water", "Freezing" = "Water", "Crushing" = "Earth", \
    "Shattering" = "Earth", "Shocking" = "Wind", "Paralyzing" = "Wind", \
    "Poisoning" = "Poison", "Toxic" = "Poison")

/mob/proc/addPassivePassives(obj/Skills/Q)
    // my care for clarity is 0
    var/list/passivesWeWant = list("CursedWounds") // add more here
    for(var/passive in passivesWeWant)
        if(Q.vars[passive])
            passive_handler.Increase(passive, Q.vars[passive])

/mob/proc/removePassivePassives(obj/Skills/Q)
    var/list/passivesWeWant = list("CursedWounds")
    for(var/passive in passivesWeWant)
        if(Q.vars[passive])
            passive_handler.Decrease(passive, Q.vars[passive])
