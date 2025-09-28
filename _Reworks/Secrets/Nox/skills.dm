/obj/Skills/AutoHit/Ouroboros/Venomous_Bite
	Area="Circle"
	AdaptRate = 1
	DamageMult=2
	CanBeDodged = 0
	CanBeBlocked = 0
	GuardBreak = 1
	ComboMaster=1
	Rounds=5
	ChargeTech=1
	ChargeFlight=1
	ChargeTime=0.25
	Grapple=1
	Stunner=4
	GrabMaster=1
	Size=1
	Icon='Glow.dmi'
	IconX=-32
	IconY=-32
	Instinct=10


// faux skill
/obj/Skills/Buffs/SlotlessBuffs/Ouroboros/Serpents_Haste
	Cooldown = 15
	TimerLimit = 0.1
	ManaCost = 2.5
	Trigger(mob/User, Override = FALSE)
		..()
		if(User.BuffOn(src))
			User.ActiveZanzo = 1 + (User.Potential/33)
	verb/Serpents_Haste()
		set category = "Skills"
		Trigger(usr)


/obj/Skills/AutoHit/Ouroboros/Snake_Bite
	Area="Circle"
	AdaptRate = 1
	DamageMult = 1
	CanBeDodged = 0
	CanBeBlocked = 0
	GuardBreak = 1
	ComboMaster=1
	Rounds=8
	ChargeTech=1
	GrabTrigger = "/obj/Skills/Grapple/Cleaving_Fang"
	ChargeTime=0.75
	Grapple=1
	GrabMaster=1
	ManaCost = 50
	Size=1
	Instinct = 10
	TurfShift='ouroborostile.dmi'
	TurfShiftDuration=6
	TurfShiftDurationSpawn = 1
	TurfShiftDurationDespawn = 5
	Cooldown = 120
	verb/Snake_Bite()
		set category="Skills"
		usr.Activate(src)


/obj/Skills/Grapple/Cleaving_Fang
	DamageMult=4
	AdaptRate=1
	ThrowAdd=1
	ThrowMult=2
	EffectMult = 3
	OneAndDone = 1
	TriggerMessage="delivers a devastating kick to"
	Effect="Stomp"
	Cooldown=1


/mob/verb/hep(n as num, r as num)
	if(!Target)
		return
	Stomp(src, Target, n, r)