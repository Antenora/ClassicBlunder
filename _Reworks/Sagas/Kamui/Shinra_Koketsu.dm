/obj/Skills/Buffs/ActiveBuffs/Kamui/Shinra_Koketsu
	passives = list ("KiControl" = 1, "HealthPU" = 1, "BleedHit" = 0.5)
	StripEquip=1
	FlashChange=1
	HairLock=1
	IconLayer=3
	KenWave=2
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

	IconLock='shinrafinal.dmi'
	LockX = -64
	LockY = -64

	ActiveMessage="becomes one with the very concept of Life Fibers!<br><center><font color='white'><b>Life Fiber Domination: Shinra Koketsu!</b></font color></center>"
	OffMessage="seperates from their unity with Life Fibers..."
	BuffName="Life Fiber Domination"
	adjust(mob/p)
		if(altered) return
		var/level = p.SagaLevel
		PowerMult = 1 + level/20
		SureHitTimerLimit = 30 - (level * 3)
		SureDodgeTimerLimit = 30 - (level * 3)
		passives = list("KiControl" = 1, "HealthPU" = 1, "BleedHit" = 0.5, "Anaerobic" = 1, "CriticalHit" = 1 + level/10, "CriticalChance" = level * 5, "CriticalBlock" = 1 + level/10, "BlockChance" = level * 5)
		ActiveMessage="becomes one with the very concept of Life Fibers!<br><center><font color='white'><b>Life Fiber Domination: Shinra Koketsu!</b></font color></center>"
		OffMessage="seperates from their unity with Life Fibers..."

	verb/Life_Fiber_Domination()
		set category="Skills"
		if(usr.Saga != "Kamui")
			usr.Death(null, "Shinra Koketsu's spite.")
			return
		if(!usr.BuffOn(src))
			adjust(usr)
		src.Trigger(usr)

obj/Skills/Mental_Refitting
	Cooldown = 1 DAY
	CooldownStatic = 1
	verb/Mental_Refitting()

/obj/Skills/Bestow_Life_Fiber/Life_Fiber_Hybrid
	role = "Life Fiber Hybrid"
	var/lifeFiberHybridID
	verb/Life_Fiber_Hybridize()
		set category = "Utility"
		if(!usr.Target)
			usr << "You require a target to do this!"
			return
		var/mob/m = usr.Target
		OMsg(usr, "[usr] extends countless long red threads towards [m]...")
		var/confirm = input(usr, "Are you sure you want to use this on [m], it will confirm after - this is a one time use verb.") in list("Yes", "No")
		if(confirm == "No") return
		if(consentCheck(usr, m))
			var/doubleCheck = input(usr, "Are you sure you want to make [m] into a [role]?") in list("Yes", "No")
			if(doubleCheck == "Yes")
				OMsg(usr, "[m]'s body accepts the countless threads, becoming something so - so much more!")
				m << "Your whole body is now integrated with fibers - you can feel your very existence rewrite itself to accomodate this..."
				m << "You know at a thought - that any attacks against the one who did this to you? They'd do hardly a thing as your very body would resist..."
				m.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Life_Fiber_Hybrid)
				for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Life_Fiber_Hybrid/lfh in m.contents)
					lfh.Password = usr?:UniqueID 
			else return

obj/Skills/Buffs/SlotlessBuffs/Autonomous/Life_Fiber_Hybrid
	AlwaysOn=1
	PowerMult=1.25
	StrMult=1.5
	EndMult = 1.5
	SpdMult=1.5
	RecovMult=1.5
	passives = list("Infatuated" = 100)
	Cooldown = 1