/obj/Skills/AutoHit/Mist_Form
	Area="Circle"
	ComboMaster=1
	AdaptRate=1
	DamageMult=0.025
	Rounds=10
	Cooldown=180
	NoLock = 1
	NoAttackLock = 1
	Size=3
	NeedsSword = 0
	UnarmedOnly = 0
	Icon='mist.dmi'
	HitSparkIcon = 'Hit_Effect_Oath_2.dmi'
	BuffSelf=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Mist_Form
	HitSparkX = -32
	HitSparkY = -32
	Instinct=5
	ActiveMessage="turns into mist!"
	ManaCost = 10
	adjust(mob/p)
		Rounds = 10 + (5 * p.AscensionsAcquired)
		Cooldown = 180 - (15 * p.AscensionsAcquired)
		ManaCost = 10 + (2.5 * p.AscensionsAcquired)
	verb/Mist_Form()
		set category = "Skills"
		if(!usr.isRace(YOKAI))
			src<< " : / "
			return
		adjust(usr)
		usr.Activate(src)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Mist_Form
	IconReplace = 1
	icon = 'mist.dmi'
	IconTransform = 'mist.dmi'
	Cooldown = 60
	TimerLimit = 10
	adjust(mob/p)
		passives = list("Godspeed" = 1 + p.AscensionsAcquired, "Deflection" = 0.5 + (p.AscensionsAcquired/2), "Reversal" = 0.1 + (p.AscensionsAcquired*0.1))
		TimerLimit = 5 + (5*p.AscensionsAcquired)
		if(p.passive_handler["SpiritForm"])
			passives = list("Godspeed" = 3 + p.AscensionsAcquired, "BulletKill" = 1, "Deflection" = 1 + (p.AscensionsAcquired/2), "Reversal" = 0.15 + (p.AscensionsAcquired*0.15))
			TimerLimit = 10 + (5*p.AscensionsAcquired)
		