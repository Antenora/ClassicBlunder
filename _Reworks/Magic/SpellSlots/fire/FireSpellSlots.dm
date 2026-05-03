//fire
/obj/Skills/AutoHit/Magic/Fire
	SpellElement="Fire"
	SpellSlot=1
	MagicNeeded=1
	Blazing_Whip
		ElementalClass="Fire"
		Area="Wave"
		Distance=5
		DamageMult=4
		Scorching=2
		SpecialAttack=1
		ForOffense=1
		CanBeDodged=1
		CanBeBlocked=0
		FlickAttack=1
		ManaCost=5
		Cooldown=45
		TurfStrike=1
		HitSparkIcon='Slash - Hellfire.dmi'
		HitSparkSize=1
		HitSparkDispersion=8
		HitSparkTurns=0
		TurfStrike=1
		TurfShift='blackflameaura.dmi'
		TurfShiftDuration=3
		ActiveMessage="invokes: <font size=+1>BLAZING WHIP!</font size>"
		adjust(mob/p)
			if(!altered)
				if(p.isInnovative(FAE, "Any") && !isInnovationDisable(p))
					DamageMult=6
					Distance=7
					ActiveMessage="invokes a powerful: <font size=+1>BLAZING WHIP!</font size>"
		verb/Blazing_Whip()
			set category="Skills"
			adjust(usr)
			usr.Activate(src)

/obj/Skills/Projectile/Fire
	SpellElement="Fire"
	SpellSlot=1
	Dragon_Arc
		ElementalClass="Fire"
		DamageMult=3
		Radius=1;
		Scorching=1
		Knockback=2
		Speed=0
		Stream=2
		AccMult=1.1
		MultiTrail = 1
		Distance=12
		ManaCost=4
		Cooldown=40
		Trail='Fireball.dmi'
		TrailVariance = 32;
		ActiveMessage="invokes: <font size=+1>DRAGON ARC!</font size>"
		adjust(mob/p)
			if(!altered)
				if(p.isInnovative(FAE, "Any") && !isInnovationDisable(p))
					Speed=0.5
					Distance=15
					Radius=1
					ActiveMessage="invokes a powerful: <font size=+1>DRAGON ARC!</font size>"
		verb/Dragon_Arc()
			set category="Skills"
			usr.UseProjectile(src)

	Fireball
		ElementalClass="Fire"
		DamageMult=5
		Scorching=2
		Homing=1
		AccMult=1.1
		Explode=2
		Knockback=1
		ManaCost=6
		Cooldown=45
		IconLock='Fireball.dmi'
		IconSize=1.5
		ActiveMessage="invokes: <font size=+1>FIREBALL!</font size>"
		adjust(mob/p)
			if(!altered)
				if(p.isInnovative(FAE, "Any") && !isInnovationDisable(p))
					Scorching=3
					Knockback=5
					ActiveMessage="invokes a powerful: <font size=+1>FIREBALL!</font size>"
		verb/Fireball()
			set category="Skills"
			usr.UseProjectile(src)
