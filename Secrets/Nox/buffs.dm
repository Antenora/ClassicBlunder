/obj/Skills/Buffs
	var/Counter // this is a counter skill, altho i think this is more for letting the backend know?
	var/WarpOnCounter // raw dog or not
	var/CounterHit = 0


/obj/Skills/Buffs/SlotlessBuffs/Grimoire/OverDrive/Jormungandr
	// dumb small buff thats once a fight
	

/obj/Skills/Buffs/SlotlessBuffs/Ouroboros/Venomous_Bite
	passives = list("Perfect Counter" = 1)
	// counters whatever hits u ig
	FollowUp = "/obj/Skills/AutoHit/Ouroboros/Venomous_Bite"
	WarpOnCounter = 1
	ThrowOnCounter = 1
	Counter = 1
	TimerLimit = 5
	ManaGlow = "#018907"
	ManaGlowSize = 1
	KenWave=1
	KenWaveIcon='Azure Crest.dmi'
	KenWaveSize=0.2
	KenWaveX=-785
	KenWaveY=-389
	Cooldown = 120
	Trigger(mob/User, Override)
		. = ..()
		if(!User.BuffOn(src))
			CounterHit = 0
	
	verb/Venomous_Bite()
		set category = "Skills"
		Trigger(usr)


