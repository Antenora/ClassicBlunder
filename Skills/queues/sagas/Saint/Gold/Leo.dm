obj/Skills/Queue/Lightning_Plasma_Strike
	UnarmedOnly=1
	CosmoPowered=1
	GodPowered=0.25
	DamageMult=0.75
	InstantStrikes=20
	InstantStrikesDelay=1
	AccuracyMult = 1.25
	Instinct=5
	Duration=5
	PrecisionStrike=10
	Cooldown=-1
	HybridStrike=1
	KBAdd=1
	IconLock=1
	HitSparkIcon='LightningPlasma.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkSize=1.3
	HitSparkTurns=1
	HitSparkDispersion=32
	ActiveMessage="is surrounded by roar of thunder!"
	HitMessage="tears their opponent apart with golden fangs of light!"
	verb/Lightning_Plasma_Strike()
		set category="Skills"
		set name="Lightning Plasma (Strike)"
		if(usr.SagaLevel<5 && usr.Health>15 && !usr.InjuryAnnounce)
			usr << "You can't use this technique except when in a dire pinch!"
			return
		usr.SetQueue(src)