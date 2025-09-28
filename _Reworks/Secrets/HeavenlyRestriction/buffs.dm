obj/Skills/Buffs/SlotlessBuffs/Heavenly_Reversal
	Cooldown = 1
	ActiveMessage="begins to dash around with an absurd physicality!"
	OffMessage="ceases dashing around so much. . ."
	DeleteOnRemove = TRUE
	adjust(mob/p)
		var/boon = p.secretDatum?:getBoon(p,"Reverse Dash")
		passives = list("Godspeed" = boon, "Juggernaut" = boon)
		SpdMult = 1 + (boon/2)
		TimerLimit = boon
	Trigger(mob/User, Override = FALSE)
		if(!User.BuffOn(src))
			adjust(User)
		..()