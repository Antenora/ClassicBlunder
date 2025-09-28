

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Elf_Silence
	BuffName="Truth Manifestation: Silence"
	passives = list("Silenced" = 1)
	adjust(mob/p)
		TimerLimit = 3 + p.AscensionsAcquired


/obj/Skills/AutoHit/Elf/Compel
	Area="Circle"
	Distance = 5
	AdaptRate = 1
	GuardBreak=0
	DamageMult=1
	Knockback=0
	Cooldown=60
	Shockwaves=1
	Shockwave=2
	SpecialAttack=1
	Stunner=6
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	ActiveMessage="manipulates the reality around themselves, forcing their foes to stand still."
	HealthCost=0.25
	adjust(mob/p)
		Cooldown=90 - (10 * p.AscensionsAcquired)
		Distance = 5 + (p.AscensionsAcquired)
	verb/Power_Word_Compel()
		set category = "Skills"
		adjust(usr)
		usr.Activate(src)

/obj/Skills/AutoHit/Elf/Silence
	Area="Wide Wave"
	Distance=6
	AdaptRate=1
	DamageMult=0.01
	Cooldown=60
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	HealthCost=0.25
	SpecialAttack=1
	BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Elf_Silence"
	ActiveMessage="manipulates the reality around themselves, forcing their foes to silence!"
	adjust(mob/p)
		Cooldown=60 - (5 * p.AscensionsAcquired)
		Distance = 5 + (p.AscensionsAcquired)
	verb/Power_Word_Silence()
		set category = "Skills"
		adjust(usr)
		usr.Activate(src)


/obj/Skills/AutoHit/Elf/Flee
	Area="Circle"
	Distance=8
	StrOffense=1
	DamageMult=1
	Cooldown=90
	Knockback=25
	Size=2
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	Shockwaves=1
	Shockwave=1
	HealthCost=0.25
	SpecialAttack=1
	ActiveMessage="manipulates the reality around themselves, forcing their foes to flee!"
	adjust(mob/p)
		Cooldown=90 - (10 * p.AscensionsAcquired)
		Distance = 8 + (p.AscensionsAcquired)
	verb/Power_Word_Flee()
		set category = "Skills"
		adjust(usr)
		usr.Activate(src)