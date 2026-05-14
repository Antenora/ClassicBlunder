/mob/Admin3/verb/GiveMazoku()
	var/mob/p = input(src, "Who?") in players
	if(!p.isRace(HUMAN))
		src << "[p] is not Human."
		return
	var/safety = 20
	while(p.transActive > 0 && safety-- > 0)
		var/oldTA = p.transActive
		p.Revert()
		if(p.transActive == oldTA)
			p.transActive = 0
			break
	for(var/transformation/T in p.race.transformations.Copy())
		p.race.transformations -= T
		del T
	p << "You have been given Mazoku."
	p.passive_handler.Increase("HellPower", 0.25)
	p.passive_handler.Increase("DemonicDurability", 2)
	p.passive_handler.Increase("AbyssMod", 1)
	p.passive_handler.Increase("DormantDemon", 1)
	p.TrueName=input(p, "Your lineage can be traced to a Great Demon Lord. Who were they?", "Get True Name") as text
	p << "The name your Mazoku Ancestor is <b>[p.TrueName]</b>."
