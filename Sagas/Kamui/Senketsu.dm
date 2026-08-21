mob/proc/getSenketsuViewers()
    var/count = 0
    var/viewDistance = passive_handler.Get("Shameful Display") * 3 + 30
    for(var/mob/m as anything in players)
        if(see_invisible > m.invisibility && getdist(src, m) <= viewDistance || m.Observing == src && m.Observing == 4)
            count++
    return count

/obj/Skills/Buffs/ActiveBuffs/Kamui/Kamui_Senketsu
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

	IconLock='senketsu_activated.dmi'
	TopOverlayLock='senketsu_activated_headpiece.dmi'

	ActiveMessage="feeds blood into their Kamui, drawing on its full power.<br><center><font color='red'>Life Fiber Synchronize: Kamui Senketsu!</font color></center>"
	OffMessage="runs out of blood to feed their Kamui, releasing the transformed state..."
	BuffName="Life Fiber Synchronize"
	adjust(mob/p)
		if(altered) return
		var/level = p.SagaLevel
		SpdMult = 1.2 + (level * 0.05)
		StrMult = 1.2 + (level * 0.05)
		EndMult = 1.2 + (level * 0.05)

		if(usr.Saga!="Kamui")
			ActiveMessage="attempts to wear a Kamui which they have no connection to!<br><center><font color='red'>Life Fiber ?Synchronize?: Kamui Senketsu!?!?</font color></center>"
			OffMessage="has their power stolen from them..."
			passives = list("KiControl" = 1, "HealthPU" = 1, "BleedHit" = 2, "Shameful Display" = 1, "Persistence" = 3, "UnderDog" = 3,  "ContinuallyStun" = 5)

		else
			passives = list("KiControl" = 1, "HealthPU" = 1, "BleedHit" = 0.5, "Shameful Display" = level, "Persistence" = level, "UnderDog" = level, "Adrenaline" = level / 2)
			if(usr.SagaLevel == 1)
				IconLock='senketsu_activated.dmi'
				TopOverlayLock='senketsu_activated_headpiece.dmi'
			if(usr.SagaLevel >= 2)
				IconLock='senketsu_v2.dmi'
				TopOverlayLock='senketsu_v2_headpiece.dmi'

			if(usr.SagaLevel < 4)
				ActiveMessage="feeds blood into their Kamui, drawing on its full power.<br><center><font color='red'>Life Fiber Synchronize: Kamui Senketsu!</font color></center>"
				OffMessage="runs out of blood to feed their Kamui, releasing the transformed state..."
			if(usr.SagaLevel >= 4)
				ActiveMessage="synchronizes perfectly with their Kamui!<br><center><font color='red'>Life Fiber Synchronize: Kamui Senketsu!</font color></center>"
				OffMessage="separates from their Kamui..."

	verb/Life_Fiber_Synchronize()
		set category="Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		src.Trigger(usr)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Life_Fiber_Berserker
	DarkChange=1
	AlwaysOn=1
	StripEquip = 1
	RecovMult=1.5
	passives = list("BleedHit" = 3, "LifeSteal" = 15)
	KenWave=1
	KenWaveIcon='SparkleRed.dmi'
	KenWaveSize=5
	KenWaveTime=30
	KenWaveX=105
	KenWaveY=105
	IconLock='senketsu_lifefiberbeserker.dmi'
	IconLayer = 3
	HairLock = 1
	ActiveMessage="'s blood boils and overwhelms their Kamui, transforming them into a berserker!"
	OffMessage="exhausts all the blood in their body..."
	Cooldown = 1

obj/Skills/AutoHit/Shippu_Rush
	Area="Circle"
	StrScaling=1
	EndEffectiveness=1
	DamageMult=0.8
	GuardBreak=1
	ChargeTech=1
	Rounds=10
	DelayTime=0.5
	ChargeTime=0
	Instinct=2
	ChargeFlight=1
	Knockback=1
	Cooldown=25
	EnergyCost=5
	Size=1
	Rush=7
	ControlledRush=1
	Hurricane="/obj/Skills/Projectile/GravityTornado"
	HurricaneDelay=0.3
	WindUp=0.1
	WindupIcon=2
	ActiveMessage="fires their jets at max capacity, kicking up a storm as they launch themselves at their target!"
	verb/Shippu_Rush()
		set category="Skills"
		if(!usr.CheckSpecial("Kamui Shippu")&&!usr.CheckSpecial("Kamui Senjin Shippu"))
			usr << "You need to be using Kamui Shippu or Senjin Shippu to use this!"
			return
		usr.Activate(src)

obj/Skills/Projectile/Shippu_Winds
	Copyable=0
	FlickBlast=0
	AttackReplace=1
	Distance=10
	DamageMult=0.25
	FadeOut=10
	Instinct=1
	Deflectable=0
	Radius=1
	ZoneAttack=1
	ZoneAttackX=0
	ZoneAttackY=0
	FireFromSelf=1
	FireFromEnemy=0
	Knockback=0
	Piercing=1
	Launcher=1
	IconLock='Icons/Buffs/Boosting Winds.dmi'
	IconSize=3
	LockX=-8
	LockY=-8

obj/Skills/Buffs/SpecialBuffs
	Kamui_Senjin
		FlashChange=1
		KenWave=1
		KenWaveIcon='SparkleRed.dmi'
		KenWaveSize=2
		KenWaveTime=5
		KenWaveX=105
		KenWaveY=105
		ABuffNeeded=list("Life Fiber Synchronize")
		ActiveMessage="augments their Kamui with powerful blades!<br><center><font color='red'>Kamui Senketsu: Senjin!</font color></center>"
		OffMessage="shrinks the blades back into their uniform..."
		StrMult=1.25
		OffMult=1.25
		passives = list("PureDamage" = 1, "DeathField" = 1, "HardStyle" = 1 )
		IconLock='senketsu_senjin.dmi'
		TopOverlayLock='senketsu_senjin_headpiece.dmi'
		TopOverlayX=0
		TopOverlayY=0
		adjust(mob/p)
			StrMult = 1.05 + (p.SagaLevel * 0.05)
			OffMult = 1.05 + (p.SagaLevel * 0.05)
			passives = list("DeathField" = round(p.SagaLevel*1.5,1), "SwordAscension" = p.SagaLevel, "HardStyle" = p.SagaLevel, "PureDamage" = p.SagaLevel/2, "BleedHit" = 6-p.SagaLevel)

		verb/Kamui_Senjin()
			set category="Skills"
			if(!usr.BuffOn(src))
				adjust(usr)
			src.Trigger(usr)
	Kamui_Shippu
		FlashChange=1
		KenWave=1
		KenWaveIcon='SparkleRed.dmi'
		KenWaveSize=2
		KenWaveTime=5
		KenWaveX=105
		KenWaveY=105
		ABuffNeeded=list("Life Fiber Synchronize")
		ActiveMessage="augments their Kamui to become a streamlined aerial form!<br><center><font color='red'>Kamui Senketsu: Shippu!</font color></center>"
		OffMessage="relaxes the aerodynamics of their uniform..."
		SpdMult=1.25
		DefMult=1.25
		IconLock='senketsu_shippu.dmi'
		LockX=-14
		LockY=-16
		TopOverlayLock='senketsu_shippu_headpiece.dmi'
		TopOverlayX=-16
		TopOverlayY=-16
		adjust(mob/p)
			SpdMult = 1.05 + (p.SagaLevel * 0.05)
			DefMult = 1.05 + (p.SagaLevel * 0.05)
			passives = list("Skimming" = 2, "Godspeed"=1+(p.SagaLevel/1.5), "Flicker" = p.SagaLevel, "DoubleStrike" = p.SagaLevel/2, "Pursuer" = p.SagaLevel/2, "CounterMaster" = p.SagaLevel, "BleedHit" = 6-p.SagaLevel)

		verb/Kamui_Shippu()
			set category="Skills"
			if(!usr.BuffOn(src))
				adjust(usr)
			src.Trigger(usr)

	Kamui_Senjin_Shippu
		FlashChange=1
		KenWave=1
		KenWaveIcon='SparkleRed.dmi'
		KenWaveSize=2
		KenWaveTime=5
		KenWaveX=105
		KenWaveY=105
		ABuffNeeded=list("Life Fiber Synchronize")
		ActiveMessage="balances destructive capability and quick movement with a new fierce Kamui form!<br><center><font color='red'>Kamui Senketsu: Senjin Shippu!</font color></center>"
		OffMessage="returns their Kamui to its usual configuration..."
		StrMult=1.25
		SpdMult=1.25
		DefMult=1.25
		OffMult=1.25
		IconLock='senketsu_senjinshippu.dmi'
		LockX=-14
		LockY=-16
		TopOverlayLock='senketsu_senjinshippu_headpiece.dmi'
		adjust(mob/p)
			StrMult = 1.04 + (p.SagaLevel * 0.04)
			OffMult = 1.04 + (p.SagaLevel * 0.04)
			SpdMult = 1.04 + (p.SagaLevel * 0.04)
			DefMult = 1.04 + (p.SagaLevel * 0.04)
			passives = list("DeathField" = round(p.SagaLevel*1.25,1), "SwordAscension" = round(p.SagaLevel/1.5,1), "HardStyle" = p.SagaLevel/1.5, "PureDamage" = round(p.SagaLevel/2.5,1), "Skimming" = 2, "Godspeed"=1+(p.SagaLevel*1.25),"Flicker" = round(p.SagaLevel/1.25,1), "DoubleStrike" = round(p.SagaLevel/2.5,1), "Pursuer" = round(p.SagaLevel/2.5,1), "CounterMaster" = round(p.SagaLevel/1.25,1), "BleedHit" = 8-p.SagaLevel)

		verb/Kamui_Senjin_Shippu()
			set category="Skills"
			if(!usr.BuffOn(src))
				adjust(usr)
			src.Trigger(usr)