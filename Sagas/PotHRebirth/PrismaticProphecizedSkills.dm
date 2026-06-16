//Style
/obj/Skills/Buffs/NuStyle/SwordStyle
	From_Now_On
		NeedsSword=1
		StyleStr = 1.20
		StyleSpd = 1.10
		StyleFor = 1.20
		StyleActive = "From Now On"
		passives = list("HybridStyle" = "MysticStyle", "SoulTug" = 1.5, \
		"SpiritFlow" = 1, "SpiritHand" = 1, "Fury" = 1, "DoubleStrike" = 1, "Flow" = 3, "Instinct" = 1)
		adjust(mob/p)
			var/pLv = p.SagaLevel
			passives = list("HybridStyle" = "MysticStyle", "SoulTug" = 1.5, \
			"SpiritFlow" = pLv, "SpiritHand" = 1, "Fury" = 1, "DoubleStrike" = 1, "Flow" = 3, "Instinct" = 1)
		verb/From_Now_On()
			set hidden=1
			src.Trigger(usr)
// Skills
obj
	Skills/Buffs/SpecialBuffs
		Hyperdeath_Mode
			BuffName="Hyperdeath Mode"
			StrMult=1.2
			EndMult=1.2
			SpdMult=1.2
			ForMult=1.2
			RecovMult=1.2
			passives = list("MovementMastery" = 2, "TechniqueMastery" = 2, "BuffMastery" = 1, "RainbowAfterImages" = 1)
			FlashChange=1
			KenWaveIcon='Unbound.dmi'
			KenWave=1
			KenWaveSize=1
			KenWaveX=72
			KenWaveY=72
			KenWaveBlend=2
			KenWaveTime=5
			ActiveMessage="awakens their Hyperdeath state!"
			OffMessage="returns to their normal self..."
			adjust(mob/p)
				var/pLv = p.SagaLevel
				passives = list("MovementMastery" = 2, "TechniqueMastery" = 2, "BuffMastery" = 1, "RainbowAfterImages" = 1)
			verb/Hyperdeath_Mode()
				set category="Skills"
				adjust(usr)
				if((usr.HyperdeathMeterCurrent < usr.HyperdeathThreshold)&&(!usr.CheckSpecial("Hyperdeath Mode")))
					usr << "You haven't accumulated enough power yet! <Requires [usr.HyperdeathThreshold]% power.>"
				else
					src.Trigger(usr)
					usr.HyperMeterUpdate()
	Skills/Buffs/SlotlessBuffs
		ChaosSaber
			MakesSword=1
			BuffName="Chaos Saber"
			SwordName="Spookysword"
			SwordIcon='Spookysword.dmi'
			SwordX=-32
			SwordY=-32
			SwordClass="Medium"
			StrMult=1.50
			ForMult=1.25
			Cooldown = 1
			SwordAscension=3
			ActiveMessage="readies CHAOS SABER!"
			OffMessage="dispels the CHAOS SABER."
			adjust(mob/p)
				passives = list("PUSpike"=50, "BlurringStrikes"=3,"HybridStrike" = 0.5,"KiControl" = 1, "SpiritSword" = 1)
				PowerMult=1.25
				EnergyHeal=1
				if(p.SagaLevel>=3)
					SwordAscension=p.SagaLevel
					StrMult=1.75
					ForMult=1.5
					passives = list("Secret Knives" = "ChaosKnife", "Tossing"=2, "PUSpike"=50, "BlurringStrikes"=3,"HybridStrike" = 0.5,"KiControl" = 1, "Chaos Buster" = 1, "SpiritSword" = 1)
				if(p.SagaLevel>=4)
					MakesSword=2
					ActiveMessage="manifests their Chaos Sabers in a burst of prismatic light."
					OffMessage="dispels the Chaos Sabers."
					passives = list("Secret Knives" = "ChaosKnife", "Tossing"=2, "PUSpike"=50, "BlurringStrikes"=3,"HybridStrike" = 1,"KiControl" = 1, "Chaos Buster" = 1, "SpiritSword" = 2, "DoubleStrike" = 1)
			verb/Chaos_Saber()
				set category="Skills"
				if(usr.CheckSlotless("Chaos Buster"))
					var/obj/Skills/Buffs/SlotlessBuffs/ChaosBuster/cb = locate(/obj/Skills/Buffs/SlotlessBuffs/ChaosBuster) in usr.contents
					cb.Trigger(usr)
				src.Trigger(usr)
		ChaosBuster
			BuffName="Chaos Buster"
			MakesStaff=1
			FlashDraw=1
			StrMult=1.25
			ForMult=1.50
			StaffName="Chaos Buster"
			StaffIcon='Aether Bow.dmi'
			ActiveMessage="readies CHAOS BUSTER!"
			OffMessage="dispels their CHAOS BUSTER."
			passives = list("StaffAscension" = 2, "Godspeed"=3, "Skimming"=1,"Chaos Buster"=1, "SpiritStrike"=1, "MovingCharge"=1, "SpiritFlow"=1.5)
			StaffAscension=2
			adjust(mob/p)
				passives = list("StaffAscension" = 2, "Godspeed"=3, "Skimming"=1,"Chaos Buster"=1, "SpiritStrike"=1, "MovingCharge"=1, "SpiritFlow"=1.5)
				if(p.SagaLevel>=3)
					passives = list("StaffAscension" = max(p.SagaLevel, 3), "Godspeed"=3, "Skimming"=1,"Chaos Buster"=2, "SpiritStrike"=1, "MovingCharge"=1, "SpiritFlow"=2.5)
					StrMult=1.50
					ForMult=1.75
			verb/Transfigure_Chaos_Buster()
				set category="Utility"
				var/Choice
				if(!usr.BuffOn(src))
					var/Lock=alert(usr, "Do you wish to alter the icon used?", "Weapon Icon", "No", "Yes")
					if(Lock=="Yes")
						src.StaffIcon=input(usr, "What icon will your Chaos Buster use?", "Chaos Buster Icon") as icon|null
						src.StaffX=input(usr, "Pixel X offset.", "Chaos Buster Icon") as num
						src.StaffY=input(usr, "Pixel Y offset.", "Chaos Buster Icon") as num
					Choice=input(usr, "What class of gun do you want your Chaos Buster to be?", "Transfigure Chaos Buster") in list("Light", "Medium", "Heavy")
					switch(Choice)
						if("Light")
							src.StaffClass="Wand"
						if("Medium")
							src.StaffClass="Rod"
						if("Heavy")
							src.StaffClass="Staff"
					usr << "Chaos Buster class set as [Choice]!"
				else
					usr << "You can't set this while using Chaos Buster."
			verb/Chaos_Buster()
				set category="Skills"
				if(usr.CheckSlotless("Chaos Saber"))
					var/obj/Skills/Buffs/SlotlessBuffs/ChaosSaber/cb = locate(/obj/Skills/Buffs/SlotlessBuffs/ChaosSaber) in usr.contents
					cb.Trigger(usr)
				src.Trigger(usr)

	Skills/Projectile
		ChaosBusterShot
			Radius=0
			DamageMult=0.25
			AccMult=0.5
			StrRate=0.5
			ForRate=0.5
			EndRate=1
			Distance=30
			Homing=1
			ManaCost=2
			Piercing=1
			AttackReplace=1
			Striking=1
			Blasts=5
			IconLock='ChaosBuster - Projectile.dmi'
			Variation=48
			Radius=1
		SuperChaosBusterShot
			Radius=0
			DamageMult=0.75
			AccMult=1
			StrRate=1
			ForRate=1
			EndRate=1
			Piercing=1
			IconSize=2
			Distance=30
			Homing=1
			ManaCost=4
			AttackReplace=1
			Striking=1
			Blasts=5
			IconLock='ChaosBuster - Projectile.dmi'
			Variation=48
			Radius=1

	Skills/AutoHit
		Shocker_Breaker
			ElementalClass="Wind"
			SpellElement="Air"
			FlickAttack=1
			Distance=6
			AdaptRate=1
			Area="Target"
			ForOffense=1
			DamageMult=6
			Paralyzing=5
			Size=1
			Bolt=5
			BoltOffset=0
			HitSparkIcon='BLANK.dmi'
			HitSparkX=0
			HitSparkY=0
			WindUp=1
			ManaCost=10
			SpecialAttack=1
			CanBeDodged=1
			CanBeBlocked=0
			Cooldown=45
			WindupMessage="used <font size=+1>SHOCKER BREAKER!</font size>"
			verb/Shocker_Breaker()
				set category="Skills"
				adjust(usr)
				usr.Activate(src)

	Skills/Projectile
		ProjectileDownTestNormal
			ElementalClass="Fire"
			SpellElement="Fire"
			SkillCost=TIER_2_COST
			Copyable=3
			DamageMult=4
			AccMult=2
			IconSize=2
			Homing=1
			Scorching=1
			Knockback=3
			Explode=2
			ManaCost=5
			Cooldown=0
			IconLock='Fireball.dmi'
			adjust(mob/p)
				DamageMult = initial(DamageMult)
			verb/NonAOEFireball()
				set category="Skills"
				set hidden=0
				if(usr.CheckSpecial("Hyperdeath Mode"))
					usr.SpawnAttackMarker(/obj/Skills/Projectile/ProjectileDownTestAOE, usr.Target)
				else
					adjust(usr)
					usr.UseProjectile(src)

		ProjectileDownTestAOE
			ElementalClass="Fire"
			SpellElement="Fire"
			SkillCost=TIER_2_COST
			Copyable=3
			YSpawnOffset=4
			DamageMult=20
			AccMult=2
			IconSize=2
			Scorching=1
			Knockback=3
			Explode=2
			DirOverride=2
			ManaCost=5
			Cooldown=0
			IconLock='Fireball.dmi'
			adjust(mob/p)
				DamageMult = initial(DamageMult)
			verb/AOEFireball()
				set category="Skills"
				set hidden=1
				if(usr.CheckSpecial("Hyperdeath Mode"))
					adjust(usr)
					usr.UseProjectile(src)

//Meter
obj/HyperdeathMeterBarBG
	icon = 'HyperdeathMeter.dmi'
	icon_state = "Background"
	screen_loc = "CENTER-2.5,BOTTOM+3"
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE
	mouse_opacity = 0

obj/HyperdeathMeterBarFill
	icon = 'HyperdeathMeter.dmi'
	icon_state = "FillActive"
	screen_loc = "CENTER-2.5,BOTTOM+3"
	layer = FLOAT_LAYER + 50
	plane = FLOAT_PLANE
	mouse_opacity = 0

mob/var/tmp/obj/HyperdeathMeterBarBG/HyperBar
mob/var/tmp/obj/HyperdeathMeterBarFill/HyperBarFill

mob/proc/HyperMeterCreate()
	if(src.client && !src.HyperBar)
		src.HyperBar = new
		src.client.screen += src.HyperBar

	if(src.client && !src.HyperBarFill)
		src.HyperBarFill = new
		src.client.screen += src.HyperBarFill

mob/proc/HyperMeterUpdate()
	if(!client)
		return

	if(!HyperBar || !HyperBarFill)
		HyperMeterCreate()

	var/max_width = 186
	var/bar_height = 9

	var/percent = HyperdeathMeterCurrent / 100
	percent = min(max(percent, 0), 1)

	var/fill_width = round(max_width * percent)

	if(fill_width<=0)
		HyperBarFill.invisibility=101
		return

	HyperBarFill.invisibility = 0
	var/iconToUse = "FillInactive"
	if(CheckSpecial("Hyperdeath Mode")||HyperdeathMeterCurrent >= HyperdeathThreshold)
		iconToUse = "FillActive"

	var/icon/I = icon('HyperdeathMeter.dmi', iconToUse)
	I.Crop(1, 1, fill_width, bar_height)

	HyperBarFill.icon = I
	HyperBarFill.icon_state = ""

obj/AttackMarker
	icon = 'MMOAttackMarker.dmi'
	icon_state = "WarningBox"
	layer = EFFECTS_LAYER
	mouse_opacity = 0

	var/mob/owner
	var/delay = 20
	var/projectile_type = /obj/Skills/Projectile/ProjectileDownTestAOE

	New(loc, mob/O, projectile_path = null)
		..()

		owner = O

		if(ispath(projectile_path, /obj/Skills/Projectile))
			projectile_type = projectile_path

		spawn(delay)
			FireMMOAttack(owner, projectile_type)

	proc/FireMMOAttack(mob/O, path)
		if(!src || !loc)
			return

		if(!O)
			del(src)
			return

		if(!ispath(path, /obj/Skills/Projectile))
			path = /obj/Skills/Projectile/ProjectileDownTestAOE

		var/obj/Skills/Projectile/p = O.FindSkill(path)

		if(!p)
			p = new path
			O.AddSkill(p)

		p.adjust(O)
		p.SpawnPosition = src
		O.UseProjectile(p)
		p.SpawnPosition = null

		world << "attack fired"
		del(src)

mob/proc/SpawnAttackMarker(path, Target)
	var/turf/T = get_turf(Target)

	if(!T)
		return

	new /obj/AttackMarker(T, src, path)

mob/verb/Test_Marker()
	set category = "Debug"

