obj/Skills/Buffs/SlotlessBuffs/Niohoggrs_Chains
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Niohoggr_Restrain
	ActiveMessage = "restrains their opponent with countless chains!"
	EndYourself = 1
	ManaCost=15
	Cooldown=120
	AffectTarget = 1
	Range = 12
	adjust(mob/p)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: Ruined World")
			applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Niohoggr_World_Restrain
		else
			applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Niohoggr_Restrain
		Cooldown = 120 - (p.SagaLevel * 4)
		ManaCost = 15 - p.SagaLevel
	verb/Chains()
		set name = "N��h�ggrs's Chains"
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/Niohoggr_Restrain
	TimerLimit = 60
	ActiveMessage = "is ensnared by countless chains!"
	OffMessage = "is no longer restrained..."
	adjust(mob/p)
		var/removeGodspeed = p.passive_handler.Get("Godspeed")
		passives = list("Godspeed" = -removeGodspeed)
		SpdMult = 0.5
	Trigger(mob/User, Override = FALSE)
		if(!User.BuffOn(src))
			adjust(User)
		..()

obj/Skills/Buffs/SlotlessBuffs/Niohoggr_World_Restrain
	TimerLimit = 60
	ActiveMessage = "is ensnared by countless chains boasting the power that could restrain even the mightiest!"
	OffMessage = "is no longer restrained..."
	adjust(mob/p)
		var/removeGodspeed = p.passive_handler.Get("Godspeed")
		passives = list("Godspeed" = -removeGodspeed)
		SpdMult = 0.25
	Trigger(mob/User, Override = FALSE)
		if(!User.BuffOn(src))
			adjust(User)
		..()