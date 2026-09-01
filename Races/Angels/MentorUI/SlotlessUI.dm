/obj/Skills/Buffs/SlotlessBuffs/Autonomous/SlotlessUI
	Instinct_Stage_One
		Copyable=0
		SpecialSlot=0
		Slotless=1
		passives = list("Deflection" = 1, "SoftStyle" = 1)
		NeedsSword=0
		NeedsStaff=0
		NoSword=0
		NoStaff=0
		SpdMult=1.15
		DefMult=1.15
		IconLock='AuraMysticBig.dmi'
		AuraArt=1
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SagaSignature = 1
		SignatureTechnique=1
		ActiveMessage="displays the first steps of Ultra Instinct: Waste no movement."
		OffMessage="dispels the first stage of Instinct."
		verb/Instinct_Stage_One()
			set category="Skills"
			set hidden = 1
			src.Trigger(usr)

	Instinct_Stage_Two
		Copyable=0
		passives = list("Deflection" = 1, "SoftStyle" = 1, "CounterMaster" = 1)
		NeedsSword=0
		NeedsStaff=0
		NoSword=0
		NoStaff=0
		StrMult=1.15
		ForMult=1.15
		SpdMult=1.45
		OffMult=1.45
		DefMult=1.45
		IconLock='AuraMysticBig.dmi'
		AuraArt=1
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SagaSignature = 1
		SignatureTechnique=2
		ActiveMessage="displays the second form of Ultra Instinct: Be as tranquil as the heavens, and quick as lightning."
		OffMessage="dispels the second stage of Instinct."
		verb/Instinct_Stage_Two()
			set category="Skills"
			set hidden = 1
			src.Trigger(usr)

	Instinct_Stage_Three
		Copyable=0
		passives = list("Deflection" = 1, "SoftStyle" = 1, "CounterMaster" = 3, "Godspeed" = 1, "UnarmedDamage"=4)
		NeedsSword=0
		NeedsStaff=0
		NoSword=0
		NoStaff=0
		StrMult=1.35
		ForMult=1.35
		SpdMult=1.75
		OffMult=1.75
		DefMult=1.75
		IconLock='GentleDivine.dmi'
		AuraArt=1
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SagaSignature = 1
		SignatureTechnique=3
		ActiveMessage="displays the third aspect of Ultra Instinct: Be clear of mind."
		OffMessage="dispels the third  stage of Instinct."
		verb/Instinct_Stage_Three()
			set category="Skills"
			set hidden = 1
			src.Trigger(usr)

	Instinct_Divine_Stage
		Copyable=0
		passives = list("Deflection" = 1, "SoftStyle" = 1, "CounterMaster" = 5, "Godspeed" = 1)
		NeedsSword=0
		NeedsStaff=0
		NoSword=0
		NoStaff=0
		StrMult=1.45
		ForMult=1.45
		SpdMult=2
		OffMult=2
		DefMult=2
		IconLock='GentleDivine.dmi'
		AuraArt=1
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SagaSignature = 1
		SignatureTechnique=4
		ActiveMessage="displays the final truth of Ultra Instinct: Perfect self control."
		OffMessage="dispels the final stage of Instinct."
		verb/Instinct_Divine_Stage()
			set category="Skills"
			set hidden = 1
			src.Trigger(usr)
			if(usr.AscensionsAcquired==5)
				passives = list("Deflection" = 1, "SoftStyle" = 1, "CounterMaster" = 5, "Godspeed" = 5)

	Divine_Instinct
		Copyable=0
		SpecialSlot=0
		Slotless=1
		NeedsSword=0
		NeedsStaff=0
		NoSword=0
		NoStaff=0
		IconLock='AuraMysticBig.dmi'
		AuraArt=1
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SagaSignature = 1
		SignatureTechnique=1
		ActiveMessage="manifests their Instinct."
		OffMessage="dispels the first stage of Instinct."
		verb/Divine_Instinct()
			set category="Skills"
			set hidden = 1
			var/asc = usr.AscensionsAcquired
			if(asc==0)
				ActiveMessage="shows the signs of Divine Instinct."
				OffMessage="dispels the first stage of Instinct."
				passives = list("Deflection" = 1, "SoftStyle" = 1)
				SpdMult=1.15
				DefMult=1.15
			if(asc==1)
				ActiveMessage="shows incomplete Divine Instinct."
				OffMessage="dispels the second stage of Instinct."
				passives = list("Deflection" = 1, "SoftStyle" = 1, "CounterMaster" = 1)
				StrMult=1.15
				ForMult=1.15
				SpdMult=1.45
				OffMult=1.45
				DefMult=1.45
			if(asc==2)
				ActiveMessage="display Ultra Instinct in its' mortal glory."
				OffMessage="dispels the third stage of Instinct."
				passives = list("Deflection" = 1, "SoftStyle" = 1, "CounterMaster" = 3, "Godspeed" = 1)
				StrMult=1.35
				ForMult=1.35
				SpdMult=1.75
				OffMult=1.75
				DefMult=1.75
			if(asc==3)
				ActiveMessage="manifests Divine Instinct."
				OffMessage="dispels the final stage of Instinct."
				passives = list("Deflection" = 1, "SoftStyle" = 1, "CounterMaster" = 5, "Godspeed" = 1)
				StrMult=1.45
				ForMult=1.45
				SpdMult=2
				OffMult=2
				DefMult=2
			if(asc==4)
				ActiveMessage="shows true discipline in Divine Instinct."
				OffMessage="dispels the divine stage of Instinct."
				passives = list("Deflection" = 1, "SoftStyle" = 1, "CounterMaster" = 5, "Godspeed" = 2)
				StrMult=2
				ForMult=2
				SpdMult=2.25
				OffMult=2.25
				DefMult=2.25
			if(asc>=5)
				ActiveMessage="shows the utter perfection of Divine Instinct."
				OffMessage="dispels the divine stage of Instinct."
				passives = list("Deflection" = 1, "SoftStyle" = 1, "CounterMaster" = 5, "Godspeed" = 3)
				StrMult=2.25
				ForMult=2.25
				SpdMult=2.75
				OffMult=2.75
				DefMult=2.75
			src.Trigger(usr)