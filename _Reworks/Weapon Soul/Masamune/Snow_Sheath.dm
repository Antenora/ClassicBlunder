obj/Skills/AutoHit/Purifying_Frost
	NeedsSword=1
	Area="Circle"
	Cleansing = 5
	ControlledRush=1
	Rush=3
	ChargeTech=1
	ChargeTime=1
	Rounds=5
	StrOffense=1
	DamageMult=2
	Purity = 1
	Chilling = 100
	Cooldown=120
	Knockback=1
	Size=1
	Icon='CircleWind.dmi'
	IconX=-32
	IconY=-32
	HitSparkIcon='Slash.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=1
	HitSparkDispersion=1
	TurfStrike=1
	TurfShift='IceGround.dmi'
	TurfShiftDuration=30
	EnergyCost=5
	Instinct=1
	ActiveMessage="'s soothing blade causes frost to snap out!"
	adjust(mob/p)
		Size = p.SagaLevel
		DamageMult = 2 + p.SagaLevel
		Rush = 3 + p.SagaLevel
	verb/Purifying_Frost()
		set category="Skills"
		adjust(usr)
		usr.Activate(src)