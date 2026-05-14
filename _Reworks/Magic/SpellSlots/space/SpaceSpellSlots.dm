//space
/obj/Skills/AutoHit/Magic/Space
	SpellElement="Space"
	SpellSlot=1
	MagicNeeded=1
	Flux
		ElementalClass="Space"
		Area="Circle"
		Distance=5
		DamageMult=8
		Knockback=3
		SpecialAttack=1
		ForOffense=1
		CanBeDodged=1
		CanBeBlocked=0
		FlickAttack=1
		ManaCost=6
		Cooldown=45
		HitSparkIcon='Hit Effect Ripple.dmi'
		HitSparkSize=1
		HitSparkDispersion=8
		HitSparkTurns=0
		TurfStrike=1
		TurfShift='Gravity.dmi'
		TurfShiftDuration=3
		ActiveMessage="invokes: <font size=+1>FLUX!</font size>"
		verb/Flux()
			set category="Skills"
			adjust(usr)
			usr.Activate(src)

	Flow
		ElementalClass="Space"
		Area="Target"
		Distance=6
		DamageMult=10
		SpecialAttack=1
		ForOffense=1
		CanBeDodged=1
		CanBeBlocked=0
		FlickAttack=1
		ManaCost=4
		Cooldown=35
		HitSparkIcon='Hit Effect Ripple.dmi'
		HitSparkSize=1
		HitSparkDispersion=4
		HitSparkTurns=0
		ActiveMessage="invokes: <font size=+1>FLOW!</font size>"
		verb/Flow()
			set category="Skills"
			adjust(usr)
			usr.Activate(src)

/obj/Skills/Buffs/SlotlessBuffs/Magic/Space
	SpellElement="Space"
	SpellSlot=1
	Friction
		AffectTarget=1
		Range=12
		TimerLimit=12
		Cooldown=60
		ManaCost=8
		SlowAffected=4
		EnergyDrain=0.25
		//SpdTaxDrain=0.03 replace this with something else
		ActiveMessage="distorts the space around their target!"
		OffMessage="releases the spatial distortion!"
		verb/Friction()
			set category="Skills"
			adjust(usr)
			src.Trigger(usr)
