//time
/obj/Skills/AutoHit/Magic/Time
	SpellElement="Time"
	SpellSlot=1
	MagicNeeded=1
	Tempus_Cessat
		ElementalClass="Time"
		Area="Circle"
		Distance=5
		DamageMult=10
		Instinct=1
		Slow=1
		SpecialAttack=1
		ForOffense=1
		CanBeDodged=1
		CanBeBlocked=0
		FlickAttack=1
		ManaCost=6
		Cooldown=50
		HitSparkIcon='Magic Time circle.dmi'
		HitSparkSize=1
		HitSparkDispersion=8
		HitSparkTurns=0
		TurfStrike=1
		TurfShift='Gravity.dmi'
		TurfShiftDuration=3
		ActiveMessage="invokes: <font size=+1>TEMPUS CESSAT!</font size>"
		adjust(mob/p)
			if(!altered)
				DamageMult=10
		verb/Tempus_Cessat()
			set category="Skills"
			adjust(usr)
			usr.Activate(src)

/obj/Skills/Buffs/SlotlessBuffs/Magic/Time
	SpellElement="Time"
	SpellSlot=1
	Haste
		TimerLimit=15
		Cooldown=90
		ManaCost=10
		ManaDrain=0.01
		SpdMult=1.2
		Godspeed=1
		passives=list("Godspeed" = 6, "BlurringStrikes" = 2, "FluidForm" = 1, "Skimming" = 2)
		ActiveMessage="accelerates through time!"
		OffMessage="slows back to a normal pace..."
		adjust(mob/p)
			if(!altered)
				passives=list("Godspeed" = 6, "BlurringStrikes" = 2, "FluidForm" = 1, "Skimming" = 2)
		verb/Haste()
			set category="Skills"
			adjust(usr)
			src.Trigger(usr)

	Wither
		AffectTarget=1
		Range=12
		TimerLimit=12
		Cooldown=60
		ManaCost=8
		FatigueDrain=0.15
		EnergyDrain=1.5
		//SpdTaxDrain=0.02 replace this with something else
		//StrTaxDrain=0.02 replace this with something else
		ActiveMessage="begins to decay the flow of time around their target!"
		OffMessage="releases the temporal hex!"
		verb/Wither()
			set category="Skills"
			adjust(usr)
			src.Trigger(usr)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/
	Outrunning_the_Past
		BuffName="Outrunning the Past"
		passives = list("Godspeed" = 2)
		TimerLimit=10;
		AlwaysOn=1;
		ActiveMessage="'s usage of time magic allows them to outpace the them of a second ago!"
		OffMessage="falls back into sync with the timeline."