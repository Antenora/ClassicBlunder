/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateOne
	GatesNeeded=1
	BuffName = "First Gate"
	PUSpike = 50
	KiControl=1
	passives = list("TechniqueMastery"=0.5, "Pursuer"=0.5, "Flicker"=0.5, "PUSpike"=50)
	FatigueHeal=40
	EnergyHeal=50
	strAdd=0.05
	spdAdd=0.1
	endAdd=0.05
	adjust(mob/p)
		passives = list("TechniqueMastery"=0.5, "Pursuer"=0.5, "Flicker"=0.5, "PUSpike" = 50, "KiControl"=1,"KiControlMastery"=1)
		PUSpike=50
		KiControl=1
		for(var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC in p)
			IconLock=KC.IconLock
			LockX=KC.LockX
			LockY=KC.LockY
			AuraLock=KC.AuraLock
			AuraX=KC.AuraX
			AuraY=KC.AuraY
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateTwo
	GatesNeeded=2
	BuffName = "Second Gate"
	passives = list("Blurring Strikes"=1, "Momentum"=1, "Instinct"=1)
	PUSpike = 20
	strAdd=0.1
	spdAdd=0.15
	endAdd=0.1
	adjust(mob/p)
		passives = list("BlurringStrikes"=1, "Momentum"=1, "Instinct"=1,"PUSpike" = 20)
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateThree
	GatesNeeded=3
	BuffName = "Third Gate"
	passives = list("TechniqueMastery"=0.5, "Pursuer"=1.5, "Flicker"=1.5,"Godspeed"=1,"PUSpike" = 10)
	PUSpike = 20
	strAdd=0.15
	spdAdd=0.25
	endAdd=0.15
	adjust(mob/p)
		passives = list("TechniqueMastery"=0.5, "Pursuer"=1.5, "Flicker"=1.5,"Godspeed"=1,"PUSpike" = 10)
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateFour
	GatesNeeded=4
	BuffName = "Fourth Gate"
	passives = list("Blurring Strikes"=1.5, "Momentum"=1.5, "Instinct"=1,"PUSpike" = 20)
	PUSpike = 20
	strAdd=0.1
	spdAdd=0.25
	endAdd=0.1
	adjust(mob/p)
		passives = list("BlurringStrikes"=1.5, "Momentum"=1.5, "Instinct"=1,"PUSpike" = 10)
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateFive
	GatesNeeded=5
	BuffName = "Fifth Gate"
	passives = list("TechniqueMastery"=1, "Pursuer"=2, "Flicker"=1.5,"Godspeed"=1,"PUSpike" = 10)
	PUSpike = 20
	strAdd=0.1
	spdAdd=0.25
	endAdd=0.1
	adjust(mob/p)
		passives = list("TechniqueMastery"=1, "Pursuer"=2, "Flicker"=1.5,"Godspeed"=1,"PUSpike" = 10)
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateSix
	GatesNeeded=6
	Slotless = TRUE
	BuffName = "Sixth Gate"
	passives = list("BlurringStrikes"=1, "Momentum"=1, "Instinct"=1)
	PUSpike = 20
	strAdd=0.1
	spdAdd=0.25
	endAdd=0.1
	adjust(mob/p)
		passives = list("BlurringStrikes"=1, "Momentum"=1, "Instinct"=1, "PUSpike" = 20, "Deicide" = 5)
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateSeven
	GatesNeeded=7
	BuffName = "Seventh Gate"
	passives = list("TechniqueMastery"=3, "Pursuer"=4, "Flicker"=3, "PureDamage" = 2, "PureReduction"=2,"Godspeed"=4, "Deicide" = 15)
	strAdd=0.4
	spdAdd=0.75
	endAdd=0.4
	adjust(mob/p)
		passives = list("TechniqueMastery"=3, "Pursuer"=4, "Flicker"=3, "PureDamage" = 2, "PureReduction"=2,"Godspeed"=4, "Deicide" = 15, "The Flame of Youth" = 1)
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateEight
	BuffName = "Eight Inner Gates Released Formation"
	GatesNeeded=8
	adjust(mob/p)
		strAdd=10
		spdAdd=10
		endAdd=10
		HealthCut=0.99
		BuffTechniques=list("/obj/Skills/AutoHit/Night_Guy")
		passives = list("Sunyata"=3, "Seki"=100, "PUSpike" = 200, "Deicide" = 20, "EndlessNine" = 2, "Sekizou" = 1)
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateJort
	BuffName = "Jort Gate"
/obj/Skills/AutoHit
	var/ResourceCost
	Night_Guy
		Area="Circle"
		DamageMult=1.5
		Rounds=10
		Knockback = 1
		ComboMaster=1
		Stunner=3
		Size=4
		StrOffense=1
		GuardBreak=1
		Rush=5
		PullIn=2
		ControlledRush=20
		Cooldown=30
		Instinct=1
		TurfStrike=4
		TurfShift='Dirt1.dmi'
		TurfShiftDuration=1
		ObjIcon = 1
		Icon='drill.dmi'
		IconX = -8
		IconY = -8
		ChargeTech = 1
		ResourceCost = list("Seki", 10)
		WindupMessage="crouches down..."
		ActiveMessage="and kicks off with intense force, bending space around them!!!"
		verb/Night_Guy()
			set category="Skills"
			usr.Activate(src)