/obj/Skills/Buffs/SpecialBuffs
	Monk_of_The_True_Name
		SignatureTechnique=3
		SagaSignature=1
		BuffTechniques=list("/obj/Skills/AutoHit/BlackAnt")
		StrMult=1.2
		EndMult=1.2
		SpdMult=1.2
		ForMult=1.2
		passives = list("Deicide" = 10, "EndlessNine" = 0.2, "MovementMastery" = 8)
		ActiveMessage="claims dominion over names."
		OffMessage="discards their dominion over names."
		verb/Monk_of_The_True_Name()
			set category="Skills"
			adjust(usr)
			src.Trigger(usr)
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/NameCurse
	BlackAnt
		ActiveMessage="becomes as insignificant as a black ant."
		OffMessage="regains their name!"
		passives = list("NameCurse" = "Black Ant")
		NameFake="Black Ant"
		SlowAffected = 1
		TimerLimit = 30
		NeedsPassword = 1
		AlwaysOn = 1
		IconLock = 'SweatDrop.dmi'
obj/Skills/AutoHit
	BlackAnt
		Area="Target"
		SignatureTechnique=3
		AdaptRate = 1
		Cooldown=-1
		DamageMult = 5
		Distance = 15
		DelayTime = 0
		HitSparkIcon = 'BLANK.dmi'
		TurfDirt = 1
		ShockIcon = 'Icons/NSE/spells/cast/KrysiaHitspark2.dmi'
		Shockwave = 4
		Shockwaves = 1
		PostShockwave = 1
		PreShockwave = 0
		WindUp = 0.75
		WindupMessage="weaves a curse upon their victim..."
		ActiveMessage = "declares their adversary as insignificant as an ant!"
		BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/NameCurse/BlackAnt"
		verb/BlackAnt()
			set category="Skills"
			set name="Name Curse: Black Ant"
			usr.Activate(src)