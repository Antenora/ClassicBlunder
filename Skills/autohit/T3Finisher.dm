/obj/Skills/AutoHit
	True_One_Inch_Punch
		UnarmedOnly=1
		FlickAttack=1
		Area="Strike"
		StrOffense=2
		DamageMult=T3_DMG_MULT/2;
		Stunner=3
		Rush=3
		RushDelay=0.1
		ControlledRush=1
		Knockback=0
		Quaking=4
		PreShockwave=1
		PreShockwaveDelay=1
		PostShockwave=0
		Shockwaves=2
		Shockwave=0.5
		ShockIcon='KenShockwaveFocus.dmi'
		ShockBlend=2
		ShockDiminish=1.15
		ShockTime=4
		ActiveMessage="curls up their fingers into a fist and delivers a crushing blow!!!"

	Divine_Cleave
		Distance=15
		Gravity=5
		DamageMult = (T3_DMG_MULT*0.9);
		StrOffense=1
		ActiveMessage="cleaves through all protections in Defiance of the Gods!"
		Area="Target"
		GuardBreak=1
		PassThrough=1
		MortalBlow=10
		Crippling = 40
		HitSparkIcon='Slash - Zan.dmi'
		HitSparkX=-16
		HitSparkY=-16
		HitSparkTurns=1
		HitSparkSize=3
		Instinct=3

	Urda_Impulse
		Area="Strike"
		DamageMult=T3_DMG_MULT/2;
		Rush=3
		RushDelay=0.1
		ControlledRush=1
		Stunner=2
		Knockback=0
		AdaptRate=1
		HitSparkIcon='Hit Effect.dmi'
		HitSparkX=-32
		HitSparkY=-32
		ActiveMessage="glides forward and rams through everything in their path!"

	Albion
		Area="Target"
		Distance=8
		DamageMult=T3_DMG_MULT;
		AdaptRate=1
		NoLock=1
		NoAttackLock=1
		CanBeDodged=0
		CanBeBlocked=0
		Cooldown=10
		HitSparkIcon='Hit Effect.dmi'
		HitSparkX=-32
		HitSparkY=-32
		ActiveMessage="grounds themselves before shooting out a powerful blast of energy!"

	Desdemona
		Area="Target"
		Distance=8
		Rounds=2
		DamageMult=T3_DMG_MULT;
		Burning=100
		Poisoning=100
		AdaptRate=1
		NoLock=1
		NoAttackLock=1
		CanBeDodged=0
		CanBeBlocked=0
		Cooldown=10
		HitSparkIcon='Hit Effect.dmi'
		HitSparkX=-32
		HitSparkY=-32
		ActiveMessage="hurls flames of darkness from their hands that carry the power of the abyss!"
	Bloodruin
		Area = "Target"
		NoLock=1
		NoAttackLock=1
		Distance=50
		DamageMult= T3_DMG_MULT / 2;
		StrOffense=1
		ForOffense=1
		EndDefense=1
		Cooldown=4
		BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Ruptured"
	Atomic_Dismantling
		ElementalClass="Chaos"
		SpellElement="Chaos"
		Area="Target"
		Distance=70
		DamageMult=T3_DMG_MULT/20
		Rounds=20
		WindUp=1
		HitSparkIcon='Hit Effect Satsui.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitSparkTurns=1
		HitSparkSize=5
		HitSparkCount=2
		HitSparkDispersion=1
		ForOffense=1
		SpecialAttack=1
		ComboMaster=1
		WindupMessage="invokes: <font size=+1>TEAR APART!</font size>"