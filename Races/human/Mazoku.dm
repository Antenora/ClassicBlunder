/mob/Admin3/verb/GiveMazoku()
	var/mob/p = input(src, "Who?") in players
	if(!p.isRace(HUMAN))
		src << "[p] is not Human."
		return
	if(p.Class != "Heroic")
		src << "[p] is not a Heroic Human."
		return
	if(p.Secret)
		src << "[p] has a Secret and cannot become a Rare Variant."
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
	p.passive_handler.Increase("AbyssMod", 1)
	p.passive_handler.Increase("DormantDemon", 1)
	p.TrueName=input(p, "Your lineage can be traced to a Great Demon Lord. Who were they?", "Get True Name") as text
	p << "The name of your Mazoku Ancestor is <b>[p.TrueName]</b>."
	p.Secret = "Rare Variant"
	if(!locate(/obj/Skills/Projectile/Spirit_Gun, p))
		p.AddSkill(new/obj/Skills/Projectile/Spirit_Gun)
		for(var/obj/Skills/Projectile/Spirit_Gun/se in p.contents)
			se.SagaSignature=1
			se.SignatureTechnique=0
