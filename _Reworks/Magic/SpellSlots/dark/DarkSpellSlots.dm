//dark
/obj/Skills/AutoHit/Magic/Dark
	SpellElement="Dark"
	SpellSlot=1
	MagicNeeded=1
	Shadow_Cleave
		ElementalClass="Dark"
		Area="Arc"
		Distance=3
		DamageMult=12
		SpecialAttack=1
		StrOffense=1
		Instinct=1
		CanBeDodged=1
		CanBeBlocked=0
		FlickAttack=1
		ManaCost=5
		Cooldown=45
		HitSparkIcon='Hit Effect Dark.dmi'
		HitSparkSize=1
		HitSparkDispersion=6
		HitSparkTurns=0
		TurfStrike=1
		TurfShift='Dark.dmi'
		TurfShiftDuration=3
		ActiveMessage="invokes: <font size=+1>SHADOW CLEAVE!</font size>"
		adjust(mob/p)
			if(!altered)
				DamageMult=12
				Cooldown=45
		verb/Shadow_Cleave()
			set category="Skills"
			adjust(usr)
			usr.Activate(src)

	Arachnae_Touch
		ElementalClass="Dark"
		DamageMult=4
		Rounds=3
		Area="Wave"
		ForOffense=1
		Instinct=1
		Distance=12
		ManaCost=5
		Cooldown=45
		HitSparkIcon='Hit Effect Dark.dmi'
		HitSparkSize=1
		HitSparkDispersion=3
		HitSparkTurns=0
		TurfStrike=1
		ActiveMessage="invokes: <font size=+1>ARACHNAE TOUCH!</font size>"
		adjust(mob/p)
			if(!altered)
				DamageMult=4
				Cooldown=45
		verb/Arachnae_Touch()
			set category="Skills"
			adjust(usr)
			usr.Activate(src)


/obj/Skills/Projectile/Magic/Dark
	SpellElement="Dark"
	SpellSlot=1
	Arachnae_Touch
		ElementalClass="Dark"
		DamageMult=4
		MultiShot=3;
		Speed=0;
		Piercing=1;
		AccMult=1.2
		Distance=12
		ManaCost=5
		Cooldown=45
		Trail='Hit Effect Dark.dmi'
		TrailX=-32
		TrailY=-32
		ActiveMessage="invokes: <font size=+1>ARACHNAE TOUCH!</font size>"
		adjust(mob/p)
			if(!altered)
				DamageMult=4
				Cooldown=45
		verb/Arachnae_Touch()
			set category="Skills"
			usr<<"Giving you the new skill."
			usr.AddSkill(new/obj/Skills/AutoHit/Magic/Dark/Arachnae_Touch)
			del src

	Void_Blast
		ElementalClass="Dark"
		DamageMult=12
		Speed=1
		Homing=1
		Explode=2
		AccMult=1.1
		Knockback=2
		ManaCost=6
		Cooldown=45
		IconLock='Hit Effect Dark.dmi'
		LockX=-32
		LockY=-32
		IconSize=1.5
		ActiveMessage="invokes: <font size=+1>VOID BLAST!</font size>"
		adjust(mob/p)
			if(!altered)
				DamageMult=12
		verb/Void_Blast()
			set category="Skills"
			usr.UseProjectile(src)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/
	Shadow_Infusion
		BuffName="Shadow Infusion"
		passives = list("LifeSteal" = 10)
		TimerLimit=10;
		AlwaysOn=1;
		ActiveMessage="drinks the essence of their opponent with shadow magic!"
		OffMessage="quenches their bloody appetite..."