//light
/obj/Skills/Buffs/SlotlessBuffs/Magic/Light
	SpellElement="Light"
	SpellSlot=1
	MagicNeeded=1
	Bless
		TimerLimit=20
		Cooldown=90
		ManaCost=10
		ManaDrain=0.1
		StableHeal=1
		HealthHeal=0.05
		WoundHeal=1
		passives=list("HolyMod" = 1, "LifeGeneration" = 2, "PureReduction" = 5)
		ActiveMessage="channels the light to mend their wounds!"
		OffMessage="lets the blessing fade..."
		verb/Bless()
			set category="Skills"
			adjust(usr)
			src.Trigger(usr)

/obj/Skills/Projectile/Magic/Light
	SpellElement="Light"
	SpellSlot=1
	Lightspeed
		ElementalClass="Light"
		DamageMult=6
		Speed=0.1
		AccMult=1.1
		Distance=15
		ManaCost=5
		Cooldown=35
		IconLock='AvalonLight.dmi'
		ActiveMessage="invokes: <font size=+1>LIGHTSPEED!</font size>"
		verb/Lightspeed()
			set category="Skills"
			usr.UseProjectile(src)

	Solar_Burst
		ElementalClass="Light"
		DamageMult=7.5
		Speed=1
		AccMult=1.1
		Homing=1
		Explode=2
		Knockback=2
		ManaCost=6
		Cooldown=45
		IconLock='AvalonLight.dmi'
		IconSize=1.5
		ActiveMessage="invokes: <font size=+1>SOLAR BURST!</font size>"
		verb/Solar_Burst()
			set category="Skills"
			usr.UseProjectile(src)
