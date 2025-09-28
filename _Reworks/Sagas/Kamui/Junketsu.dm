/obj/Skills/Buffs/ActiveBuffs/Kamui/Kamui_Junketsu
	passives = list ("KiControl" = 1, "HealthPU" = 1, "BleedHit" = 0.5)
	StripEquip=1
	FlashChange=1
	HairLock=1
	IconLayer=3
	KenWave=1
	KenWaveIcon='SparkleRed.dmi'
	KenWaveSize=5
	KenWaveTime=30
	KenWaveX=105
	KenWaveY=105
	PowerMult=1
	StrMult=1.25
	EndMult=1.25
	SpdMult=1.5
	Cooldown=60

	IconLock='junketsu_activated.dmi'
	TopOverlayLock='junketsu_activated_headpiece.dmi'

	ActiveMessage="forces their blood into their Kamui, making use of its full power!<br><center><font color='red'>Life Fiber Override: Kamui Junketsu!</font color></center>"
	OffMessage="relaxes their bloodflow, allowing the Kamui they wear to revert..."
	BuffName="Life Fiber Override"
	adjust(mob/p)
		if(altered) return
		var/level = p.SagaLevel
		if(!level || level < 1)
			level = 1
		PowerMult = 1 + level/20
		SureHitTimerLimit = 30 - (level * 3)
		SureDodgeTimerLimit = 30 - (level * 3)
		OverClock = 1 / level
		if(level >= 5)
			OverClock = 0
		passives = list("KiControl" = 1, "HealthPU" = 1, "BleedHit" = 0.5, "Anaerobic" = 1, "CriticalHit" = 1 + level/10, "CriticalChance" = level * 5, "CriticalBlock" = 1 + level/10, "BlockChance" = level * 5)
		ActiveMessage="forces their blood into their Kamui, making use of its full power!<br><center><font color='red'>Life Fiber Override: Kamui Junketsu!</font color></center>"
		OffMessage="relaxes their bloodflow, allowing the Kamui they wear to revert..."

	verb/Life_Fiber_Override()
		set category="Skills"
		if(usr.Saga != "Kamui" && usr.Secret != "Haki")
			usr.TotalInjury += 90
			usr.Unconscious(null, "Junketsu going insane and trying to lash away all the blood from their body!")
			return
		if(!usr.BuffOn(src))
			adjust(usr)
		src.Trigger(usr)

obj/Items/Sword/Heavy/Secret_Sword_Bakuzan
	Ascended = 3
	Unobtainable = 1
	LegendaryItem = 1
	icon = 'cybox_sword.dmi'
	pixel_x = -32
	pixel_y = -32
	passives = list("Life Fiber Rending" = 2)
/*	onBroken()
		. = ..()
		if(Conjured) return
		if(ismob(loc))
			var/mob/m = loc
			var/obj/Items/Sword/Medium/Bakuzan_Gako/bg = new()
			m.contents += bg
			var/obj/Items/Sword/Light/Bakuzan_Koryu/bk = new()
			m.contents += bk
			m << "Secret Sword Bakuzan shatters - but the shattered parts are more than enough to still use!"
			del src

obj/Items/Sword/Medium/Bakuzan_Gako
	Ascended = 3
	Unobtainable = 1
	LegendaryItem = 1
	icon = 'cybox_sword.dm'
	pixel_x = -32
	pixel_y = -32
	passives = list("Life Fiber Rending" = 3)

obj/Items/Sword/Light/Bakuzan_Koryu
	Ascended = 3
	Unobtainable = 1
	LegendaryItem = 1
	icon = 'cybox_sword.dm'
	pixel_x = -32
	pixel_y = -32
	passives = list("Life Fiber Rending" = 2)*/

/obj/Skills/Bestow_Life_Fiber
	var/consentNeeded = TRUE 
	var/role = "Life Fiber Hybrid"
	proc/consentCheck(mob/source, mob/consentNeeded)
		if(!consentNeeded) return TRUE
		var/confirm = input(consentNeeded, "[source] is offering you a role as [role], do you accept?") in list("Yes", "No")
		if(confirm == "No") return FALSE
		else if(confirm == "Yes") return TRUE

	Bestow_Disciplinary_Chair
		role = "Disciplinary Chair"
		verb/Bestow_Disciplinary_Chair()
			set category = "Utility"
			if(!usr.Target)
				usr << "You require a target to do this!"
				return
			var/mob/m = usr.Target
			OMsg(usr, "[usr] extends a singular long red thread towards [m]...")
			if(consentCheck(usr, m, "Disciplinary Chair"))
				var/doubleCheck = input(usr, "Are you sure you want to make [m] the Disciplinary Chair?") in list("Yes", "No")
				if(doubleCheck == "Yes")
					OMsg(usr, "[m]'s body accepts the thread!")
					m.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Life_Fiber_Hybrid/Disciplinary_Chair)
				else
					OMsg(usr, "[usr] retracts the thread!")
					return

	Bestow_Athletic_Chair
		role = "Athletic Chair"
		verb/Bestow_Athletic_Chair()
			set category = "Utility"
			if(!usr.Target)
				usr << "You require a target to do this!"
				return
			var/mob/m = usr.Target
			OMsg(usr, "[usr] extends a singular long red thread towards [m]...")
			if(consentCheck(usr, m))
				var/doubleCheck = input(usr, "Are you sure you want to make [m] the [role]?") in list("Yes", "No")
				if(doubleCheck == "Yes")
					OMsg(usr, "[m]'s body accepts the thread!")
					m.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Life_Fiber_Hybrid/Athletics_Chair)
				else
					OMsg(usr, "[usr] retracts the thread!")
					return

	Bestow_Non_Athletic_Chair
		role = "Non Athletic Chair"
		verb/Bestow_Non_Athletic_Chair()
			set category = "Utility"
			if(!usr.Target)
				usr << "You require a target to do this!"
				return
			var/mob/m = usr.Target
			OMsg(usr, "[usr] extends a singular long red thread towards [m]...")
			if(consentCheck(usr, m))
				var/doubleCheck = input(usr, "Are you sure you want to make [m] the [role]?") in list("Yes", "No")
				if(doubleCheck == "Yes")
					OMsg(usr, "[m]'s body accepts the thread!")
					m.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Life_Fiber_Hybrid/Non_Athletics_Chair)
				else
					OMsg(usr, "[usr] retracts the thread!")
					return

	Bestow_Information_and_Strategy_Chair
		role = "Information and Strategy Chair"
		verb/Bestow_Information_and_Strategy_Chair()
			set category = "Utility"
			if(!usr.Target)
				usr << "You require a target to do this!"
				return
			var/mob/m = usr.Target
			OMsg(usr, "[usr] extends a singular long red thread towards [m]...")
			if(consentCheck(usr, m))
				var/doubleCheck = input(usr, "Are you sure you want to make [m] the [role]?") in list("Yes", "No")
				if(doubleCheck == "Yes")
					OMsg(usr, "[m]'s body accepts the thread!")
					m.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Life_Fiber_Hybrid/Information_and_Strategy_Chair)
				else
					OMsg(usr, "[usr] retracts the thread!")
					return

/obj/Skills/Buffs/SlotlessBuffs/Life_Fiber_Hybrid
	Disciplinary_Chair
		EndMult = 1.25
		passives = list("Juggernaut" = 1, "PureReduction" = 2)
		ActiveMessage="takes up their role as the Disciplinary Chair beneath the banner of an empire!"
		OffMessage="forsakes their role..."
		verb/Disciplinary_Chair()
			set category="Skills"
			src.Trigger(usr)

	Athletics_Chair
		SpdMult = 1.25
		passives = list("Pursuer" = 2, "Godspeed" = 2, "BlurringStrikes" = 0.2)
		ActiveMessage="takes up their role as the Athletics Chair beneath the banner of an empire!"
		OffMessage="forsakes their role..."
		verb/Athletics_Chair()
			set category="Skills"
			src.Trigger(usr)
	
	Non_Athletics_Chair
		ForMult = 1.25
		passives = list("DualCast" = 1)
		ActiveMessage="takes up their role as the Non Athletics Chair beneath the banner of an empire!"
		OffMessage="forsakes their role..."
		verb/Non_Athletics_Chair()
			set category="Skills"
			src.Trigger(usr)

	Information_and_Strategy_Chair
		OffMult = 1.15
		DefMult = 1.15
		passives = list("Adaptation" = 1, "Flow" = 1, "Instinct" = 1)
		ActiveMessage="takes up their role as the Information and Strategy Chair beneath the banner of an empire!"
		OffMessage="forsakes their role..."
		verb/Information_and_Strategy_Chair()
			set category="Skills"
			src.Trigger(usr)

	Kamui_Senpu
		KiControl=1
		PUSpike=100
		FlashChange=1
		KenWave=1
		KenWaveIcon='SparkleRed.dmi'
		KenWaveSize=2
		KenWaveTime=5
		KenWaveX=105
		KenWaveY=105
		ABuffNeeded=list("Life Fiber Override")
		ActiveMessage="forces their Kamui to assume a more aerodynamic form!<br><center><font color='cyan'>Kamui Junketsu: Senpu!</font color></center>"
		OffMessage="allows their Kamui to rest..."
		SpdMult=1.3
		EndMult=1.3
		passives = list("VoidField" = 1, "PureReduction" = 1, "Flicker" = 1)

		IconLock='junketsu_senpu.dmi'
		LockX=-16
		LockY=-16
		TopOverlayLock='junketsu_senpu_headpiece.dmi'
		TopOverlayX=-32
		TopOverlayY=-32
		adjust(mob/p)
			SpdMult = 1.05 + (p.SagaLevel * 0.05)
			DefMult = 1.05 + (p.SagaLevel * 0.05)
			passives = list("Skimming" = 2, "Flicker" = p.SagaLevel, "Flow" = p.SagaLevel/2, "DoubleStrike" = p.SagaLevel/2, "Pursuer" = p.SagaLevel/2, "CounterMaster" = p.SagaLevel, "BleedHit" = 6-p.SagaLevel)

		verb/Kamui_Senpu()
			set category="Skills"
			if(!usr.BuffOn(src))
				adjust(usr)
			src.Trigger(usr)

	Kamui_Senpu_Zanken
		FlashChange=1
		KenWave=1
		KenWaveIcon='SparkleRed.dmi'
		KenWaveSize=2
		KenWaveTime=5
		KenWaveX=105
		KenWaveY=105
		ABuffNeeded=list("Life Fiber Override")
		ActiveMessage="forces their kamui to twist into a new fierce Kamui form of jagged blades and jets!<br><center><font color='cyan'>Kamui Junketsu: Senpu Zanken!</font color></center>"
		OffMessage="allows their Kamui to rest..."
		StrMult=1.25
		SpdMult=1.3
		EndMult=1.25
		passives = list("KiControl" = 1, "PureDamage" = 1, "DeathField" = 1, "HardStyle" = 1, "VoidField" = 1, "PureReduction" = 1, "Flicker" = 1)
		IconLock='junketsu_senpuzenkan.dmi'
		LockX=-16
		LockY=-16
		TopOverlayLock='junketsu_senpuzenkan_headpiece.dmi'
		TopOverlayX=-16
		TopOverlayY=-16
		adjust(mob/p)
			StrMult = 1.04 + (p.SagaLevel * 0.04)
			OffMult = 1.04 + (p.SagaLevel * 0.04)
			SpdMult = 1.04 + (p.SagaLevel * 0.04)
			DefMult = 1.04 + (p.SagaLevel * 0.04)
			passives = list("DeathField" = p.SagaLevel*1.25, "SwordAscension" = p.SagaLevel/1.5, "HardStyle" = p.SagaLevel/1.5, "PureDamage" = p.SagaLevel/2.5, "Skimming" = 2, "Flicker" = p.SagaLevel/1.25, "Flow" = p.SagaLevel/2.5, "DoubleStrike" = p.SagaLevel/2.5, "Pursuer" = p.SagaLevel/2.5, "CounterMaster" = p.SagaLevel/1.25, "BleedHit" = 8-p.SagaLevel)

		verb/Kamui_Senpu_Zanken()
			set category="Skills"
			if(!usr.BuffOn(src))
				adjust(usr)
			src.Trigger(usr)