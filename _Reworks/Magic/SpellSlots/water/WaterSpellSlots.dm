//water
/obj/Skills/Buffs/SlotlessBuffs/Magic/Water
	SpellElement="Water"
	SpellSlot=1
	MagicNeeded=1
	Wetten_Socks
		ElementalOffense="Water"
		AffectTarget=1
		Range=12
		TimerLimit=12
		Cooldown=60
		ManaCost=8
		SlowAffected=3
		CrippleAffected=2
		ActiveMessage="curses their target with sodden footing!"
		OffMessage="releases the hex!"
		adjust(mob/p)
			if(!altered)
				if(p.isInnovative(FAE, "Any") && !isInnovationDisable(p))
					TimerLimit=18
					SlowAffected=4
					CrippleAffected=3
					ActiveMessage="cackles as their target's feet get wet!"
		verb/Wetten_Socks()
			set category="Skills"
			adjust(usr)
			src.Trigger(usr)

/obj/Skills/AutoHit/Magic/Water
	SpellElement="Water"
	SpellSlot=1
	Riptide
		ElementalClass="Water"
		Area="Target"
		Distance=5
		DamageMult=8
		Instinct=1
		Freezing=2
		Slow=1
		SpecialAttack=1
		ForOffense=1
		CanBeDodged=1
		CanBeBlocked=0
		FlickAttack=1
		ManaCost=5
		Cooldown=45
		HitSparkIcon='SnowBurst2.dmi'
		HitSparkSize=1
		HitSparkDispersion=6
		HitSparkTurns=0
		ActiveMessage="invokes: <font size=+1>RIPTIDE!</font size>"
		adjust(mob/p)
			if(!altered)
				DamageMult=8
				Cooldown=45
				if(p.isInnovative(FAE, "Any") && !isInnovationDisable(p))
					DamageMult=11
					Freezing=3
					ActiveMessage="invokes a powerful: <font size=+1>RIPTIDE!</font size>"
		verb/Riptide()
			set category="Skills"
			adjust(usr)
			usr.Activate(src)

/obj/Skills/Projectile/Magic/Water
	SpellElement="Water"
	SpellSlot=1
	Frost_Shamshir
		ElementalClass="Water"
		DamageMult=7
		AccMult=1.1
		Freezing=2
		Homing=1
		Knockback=1
		Speed=1
		Distance=15
		ManaCost=5
		Cooldown=45
		IconLock='Ice.dmi'
		ActiveMessage="invokes: <font size=+1>FROST SHAMSHIR!</font size>"
		adjust(mob/p)
			if(!altered)
				DamageMult=7
				if(p.isInnovative(FAE, "Any") && !isInnovationDisable(p))
					DamageMult=9
					Freezing=3
					ActiveMessage="invokes a powerful: <font size=+1>FROST SHAMSHIR!</font size>"
		verb/Frost_Shamshir()
			set category="Skills"
			usr.UseProjectile(src)
