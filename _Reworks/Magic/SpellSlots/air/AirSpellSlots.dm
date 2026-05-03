//air
/obj/Skills/AutoHit/Magic/Air
	SpellElement="Air"
	SpellSlot=1
	MagicNeeded=1
	Breaking_Twister
		ElementalClass="Wind"
		Area="Circle"
		Distance=5
		DamageMult=3
		Paralyzing=3
		Knockback=2
		SpecialAttack=1
		ForOffense=1
		CanBeDodged=1
		CanBeBlocked=0
		FlickAttack=1
		ManaCost=5
		Cooldown=45
		HitSparkIcon='Hit Effect Wind.dmi'
		HitSparkSize=1
		HitSparkDispersion=8
		HitSparkTurns=0
		TurfStrike=1
		TurfShift='Dirt1.dmi'
		TurfShiftDuration=3
		ActiveMessage="invokes: <font size=+1>BREAKING TWISTER!</font size>"
		adjust(mob/p) //Coded out for Balance checking reasons.
			if(!altered)
				if(p.isInnovative(FAE, "Any") && !isInnovationDisable(p))
					DamageMult=4.5
					Distance=7
					ActiveMessage="invokes a powerful: <font size=+1>BREAKING TWISTER!</font size>"
		verb/Breaking_Twister()
			set category="Skills"
			adjust(usr)
			usr.Activate(src)

/obj/Skills/Buffs/SlotlessBuffs/Magic/Air
	SpellElement="Air"
	SpellSlot=1
	Evading_Zephyr
		TimerLimit=15
		Cooldown=90
		ManaCost=8
		ManaDrain=0.01
		SpdMult=1.15
		passives=list("FluidForm" = 1, "Godspeed" = 1)
		ActiveMessage="wraps themselves in a veil of wind!"
		OffMessage="lets the wind dissipate..."
		adjust(mob/p)
			if(!altered)
				if(p.isInnovative(FAE, "Any") && !isInnovationDisable(p))
					TimerLimit=30
					SpdMult=1.25
					Cooldown=75
					ActiveMessage="wraps themselves in a aegis of wind!"
		verb/Evading_Zephyr()
			set category="Skills"
			adjust(usr)
			src.Trigger(usr)

/obj/Skills/Projectile/Magic/Air
	SpellElement="Air"
	SpellSlot=1
	Mentis_Imperium
		ElementalClass="Wind"
		DamageMult=4
		Paralyzing=4
		Speed=0.5
		Homing=1
		AccMult=1.1
		Distance=12
		ManaCost=5
		Cooldown=40
		IconLock='Air Render.dmi'
		ActiveMessage="invokes: <font size=+1>MENTIS IMPERIUM!</font size>"
		adjust(mob/p)
			if(!altered)
				if(p.isInnovative(FAE, "Any") && !isInnovationDisable(p))
					Speed=0.25
					Distance=15
					Radius=1
					ActiveMessage="invokes a powerful: <font size=+1>MENTIS IMPERIUM!</font size>"
		verb/Mentis_Imperium()
			set category="Skills"
			usr.UseProjectile(src)
