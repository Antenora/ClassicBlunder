// TESTED
var/list/debuffVars = list("Burning", "Scorching", "Drenching", "Soaking", "Chilling", "Freezing", "Exposing", "Shredding", \
    "Crushing", "Shattering", "Shocking", "Paralyzing", "Poisoning", "Toxic", "Bloodletting")
var/list/debuff2Element = list("Burning" = "Fire", "Scorching" = "Fire", \
    "Drenching" = "Water", "Soaking" = "Water", "Chilling" = "Ice", "Freezing" = "Ice", \
    "Exposing" = "Wind", "Shredding" = "Wind", "Crushing" = "Earth", "Shattering" = "Earth", \
    "Shocking" = "Lightning", "Paralyzing" = "Lightning", "Poisoning" = "Poison", "Toxic" = "Poison", "Bloodletting" = "Blade")

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
