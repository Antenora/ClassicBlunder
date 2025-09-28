/obj/Skills/Buffs/SlotlessBuffs/Autonomous/MSDebuff
	NeedsPassword = 1
	TimerLimit = 1
	Cooldown = 4
	AlwaysOn = 1

particles/blades
	width = 500
	height = 500
	count = 10
	spawning = 5
	bound1 = list(-1000, -1000, -1000)
	lifespan = 5
	fade = 4
	position = generator("box", list(-1,1,0), list(1,1,1))
	velocity = list(generator("sphere", -3, 3), generator("sphere", 0, 0), generator("sphere", -3, 3))
	rotation = generator("sphere", 0, 360)
	spin = 30
	scale = generator("num", 2,4)
	gravity = list(0, -0.01)
	friction = generator("sphere", 0.01, 0.3)
	drift = generator("sphere", 0, 2)
	icon = 'CHECKMATE2.dmi'

obj/blades
	layer = FLY_LAYER
	screen_loc = "CENTER,CENTER"
	particles = new/particles/blades

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/MSDebuff/Genjutsu
	DefMult = 0.75
	passives = list("Instinct" = -1, "Flow" = -1)
	ShockAffected = 1
	SlowAffected = 1
	IconLock = 'SweatDrop.dmi'
	TimerLimit = 20


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/MSDebuff/Seishinkai_to_Yami
	var/tmp/mob/tmpAppearanceMob
	var/tmp/obj/blades/b
	StunAffected = 1
	HealthDrain = 0.05
	TimerLimit = 10
	Trigger(mob/User, Override = FALSE)
		if(!User.BuffOn(src))
			// activation
			sendtoGenjutsu(User)
			animateTorture(User)
		else
			// deactivation
			User.density = 1
			User.Grabbable = 1
			User.Incorporeal = 0
			User.invisibility = 0
			User.Stasis = 0
			User.StasisSpace = 0
			endTorture(User)
			OMsg(User, "[User] has been released from Tsukuyomi!")
		..()



	proc/sendtoGenjutsu(mob/target)
		tmpAppearanceMob = new(target.loc)
		tmpAppearanceMob.appearance = target.appearance
		animate(tmpAppearanceMob, color = list(-1,0,0, 0,-1,0, 0,0,-1, 0,1,1), time = 5)
		var/obj/Effects/Stun/S=new
		S.appearance_flags=66
		tmpAppearanceMob.overlays+=S
		target.density = 0
		target.Grabbable = 0
		target.Incorporeal = 1
		target.invisibility = 90
		target.SetStasis(TimerLimit)
		target.StasisSpace = 1

	proc/animateTorture(mob/target)
		b = new()
		target.client += b

	proc/endTorture(mob/target)
		del tmpAppearanceMob
		target.client -= b
		del b
		target.DamageSelf(5)


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/MSDebuff/Busshitsukai_to_Hikari
	TooMuchHealth = 99.8
	BurnAffected = 3
	CrippleAffected = 2
	EndTaxDrain = 0.00005
	EndTax = 0.01
	EnergyDrain = 0.05
	TimerLimit = 0
	IconLock='DarknessFlameAura.dmi'
	LockX=-32
	LockY=-32
	IconLayer=-1
	ActiveMessage = "has been inflicted with abyssal flames!"
	OffMessage = "has managed to extinguish the flames."



/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Blinded
	NeedsPassword = 1
	Cooldown = 4
	AlwaysOn = 1
	passives = list("NoDodge" = 1, "FluidForm" = -2)
	IconLock = 'SweatDrop.dmi'
	TimerLimit = 35


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/AchillesHeel
	NeedsPassword = 1
	Cooldown = 15
	AlwaysOn = 1
	CrippleAffected = 2
	SpdMult = 0.9
	DefMult = 0.9
	passives = list("Flow" = -1, "Godspeed" = -2)
	IconLock = 'LegendSparks.dmi'
	TimerLimit = 20
	Disgruntled
		SpdMult=1
		DefMult=1
		CrippleAffected = 0.1
		ShatterAffected = 0.1
		TimerLimit=10
		passives = list("Godspeed" = -1, "Flow" = -0.5)


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Staggered
	NeedsPassword = 1
	Cooldown = 15
	AlwaysOn = 1
	ShatterAffected = 2
	passives = list("Shellshocked" = 1, "Flow" = -1)
	IconLock = 'LegendSparks.dmi'
	TimerLimit = 30