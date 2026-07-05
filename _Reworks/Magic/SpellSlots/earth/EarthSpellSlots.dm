//earth
/obj/Skills/AutoHit/Magic/Earth
	SpellElement="Earth"
	SpellSlot=1
	MagicNeeded=1
	Seismic_Entry
		ElementalClass="Earth"
		Area="Circle"
		Distance=4
		DamageMult=7.5
		Instinct=1
		Crushing=3
		SpecialAttack=1
		StrOffense=1
		CanBeDodged=1
		CanBeBlocked=0
		FlickAttack=1
		ManaCost=5
		Cooldown=45
		HitSparkIcon='Hit Effect Ripple.dmi'
		HitSparkSize=1
		HitSparkDispersion=8
		HitSparkTurns=0
		TurfStrike=1
		TurfShift='Dirt1.dmi'
		TurfShiftDuration=3
		ActiveMessage="invokes: <font size=+1>SEISMIC ENTRY!</font size>"
		adjust(mob/p)
			if(!altered)
				DamageMult=7.5
				if(p.isInnovative(FAE, "Any") && !isInnovationDisable(p))
					DamageMult=11
					Distance=6
					ActiveMessage="invokes a powerful: <font size=+1>SEISMIC ENTRY!</font size>"
		verb/Seismic_Entry()
			set category="Skills"
			adjust(usr)
			usr.Activate(src)

/obj/Skills/Buffs/SlotlessBuffs/Magic/Earth
	SpellElement="Earth"
	SpellSlot=1
	Ward_of_Stone
		TimerLimit=20
		Cooldown=90
		ManaCost=8
		ManaDrain=0.01
		EndMult=1.15
		PureReduction=2
		passives=list("Harden" = 1, "MeleeResist" = 1, "PureReduction" = 5)
		ActiveMessage="wraps themselves in a ward of living stone!"
		OffMessage="lets the stone crumble away..."
		adjust(mob/p)
			if(!altered)
				passives=list("Harden" = 1, "MeleeResist" = 1, "PureReduction" = 5)
				if(p.isInnovative(FAE, "Any") && !isInnovationDisable(p))
					TimerLimit=40
					Cooldown=70
					EndMult=1.25
					PureReduction=3
					passives=list("Harden" = 1, "MeleeResist" = 1, "PureReduction" = 7)
					ActiveMessage="wraps themselves in a barrier of living stone!"
		verb/Ward_of_Stone()
			set category="Skills"
			adjust(usr)
			src.Trigger(usr)

	Prickly_Ballet
		AffectTarget=1
		Range=10
		TimerLimit=10
		Cooldown=60
		ManaCost=8
		ShatterAffected=3
		CrippleAffected=2
		ActiveMessage="curses the earth beneath their target!"
		OffMessage="releases the curse!"
		adjust(mob/p)
			if(!altered)
				if(p.isInnovative(FAE, "Any") && !isInnovationDisable(p))
					TimerLimit=15
					Cooldown=55
					ShatterAffected=4
					CrippleAffected=3
					ActiveMessage="hexes the earth beneath their target!"
		verb/Prickly_Ballet()
			set category="Skills"
			adjust(usr)
			src.Trigger(usr)
