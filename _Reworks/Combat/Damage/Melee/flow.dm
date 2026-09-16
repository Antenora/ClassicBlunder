// aids
// make it so basically when they use flow, they drain energy or something
// but also make it not spammable
/mob/Admin4/verb/testDummy()
    var/i = Ask(usr, "How many?", "", null, "num", null, 0)
    while(i)
        var/mob/Players/P = new()
        P.passive_handler = new()
        P.setRace(HUMAN, FALSE)
        P.loc = src.loc
        P.icon = 'Namek1.dmi'
        gain_loop.Add(P)
        i--