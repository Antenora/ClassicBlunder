//Style
/obj/Skills/Buffs/NuStyle/SwordStyle //T1
	Fight_or_Flight
		StyleStr = 1.15
		StyleFor = 1.15
		StyleOff = 1.05
		StyleDef = 1.05
		StyleActive = "Fight or Flight"
		passives = list("HybridStyle" = "MysticStyle", "SpiritFlow" = 1, "SpiritSword" = 0.5, "Flow" = 1, "Instinct" = 0.5)
		verb/Fight_or_Flight()
			set hidden=1
			src.Trigger(usr)

	Mountain_King //T2
		StyleStr = 1.25
		StyleFor = 1.25
		StyleOff = 1.15
		StyleDef = 1.10
		StyleSpd = 1.10
		StyleActive = "Mountain King"
		passives = list("HybridStyle" = "MysticStyle", "HybridStrike" = 0.5, "SpiritFlow" = 2, "SpiritSword" = 1, "Flow" = 2, "Instinct" = 1, "DoubleStrike" = 1)
		verb/Mountain_King()
			set hidden=1
			src.Trigger(usr)

	Dreamlike_Savior//T3
		StyleStr = 1.35
		StyleFor = 1.35
		StyleOff = 1.25
		StyleDef = 1.20
		StyleSpd = 1.20
		StyleActive = "Dreamlike Savior"
		passives = list("HybridStyle" = "MysticStyle",  "HybridStrike" = 1, "SpiritFlow" = 3, "SpiritSword" = 1.5,\
		"Flow" = 3, "Instinct" = 2, "DoubleStrike" = 2, "Deflection" = 2,)
		verb/Dreamlike_Savior()
			set hidden=1
			src.Trigger(usr)

	Afterlife//T4
		StyleStr = 1.50
		StyleFor = 1.50
		StyleOff = 1.40
		StyleDef = 1.35
		StyleSpd = 1.35
		StyleActive = "Afterlife"
		passives = list("HybridStyle" = "MysticStyle",  "HybridStrike" = 1.5, "SpiritFlow" = 4, "SpiritSword" = 2, "Flow" = 4, "Instinct" = 3,\
		"LikeWater" = 3, "DoubleStrike" = 2, "TripleStrike" = 0.5, "Deflection" = 2, "Pressure" = 2, "PUSpike" = 50)
		verb/Afterlife()
			set hidden=1
			src.Trigger(usr)
// Skills
obj
	Skills/Buffs/SpecialBuffs
		Hyperdeath_Mode
			BuffName = "Hyperdeath Mode"
			StrMult = 1.25
			EndMult = 1.10
			SpdMult = 1.15
			ForMult = 1.25
			RecovMult = 1.10
			passives = list("MovementMastery" = 2, "TechniqueMastery" = 2, "HybridStrike" = 0.25, "SpiritFlow" = 2, "SpiritSword" = 1, "Pressure" = 2,\
			"Instinct" = 2, "Flow" = 2, "RainbowAfterImages" = 1)
			FlashChange = 1
			KenWaveIcon = 'Unbound.dmi'
			KenWave = 1
			KenWaveSize = 1
			KenWaveX = 72
			KenWaveY = 72
			KenWaveBlend = 2
			KenWaveTime = 5
			ActiveMessage = "awakens their Hyperdeath state!"
			OffMessage = "returns to their normal self..."
			adjust(mob/p)
				var/pLv = p.SagaLevel
				StrMult = 1.25 + (0.01 * pLv)
				ForMult = 1.25 + (0.01 * pLv)
				SpdMult = 1.15 + (0.01 * pLv)
				EndMult = 1.10 + (0.01 * pLv)
				RecovMult = 1.10 + (0.01 * pLv)
				passives = list("MovementMastery" = 2,"TechniqueMastery" = 2, "HybridStrike" = 0.25 + min(1, (pLv / 5)), "SpiritFlow" = 1 + pLv, "SpiritSword" = max(1, round(pLv / 2, 1)), \
				"Pressure" = 1 + round(pLv / 2, 1), "Instinct" = 1 + round(pLv / 2, 1), "Flow" = 1 + round(pLv / 2, 1), "RainbowAfterImages" = 1)
				if(pLv > 4)
					passives = list("MovementMastery" = 2,"TechniqueMastery" = 2, "HybridStrike" = 0.25 + min(1, (pLv / 5)), "SpiritFlow" = 1 + pLv, "SpiritSword" = max(1, round(pLv / 2, 1)), \
					"Pressure" = 1 + round(pLv / 2, 1), "Instinct" = 1 + round(pLv / 2, 1), "Flow" = 1 + round(pLv / 2, 1), "RainbowAfterImages" = 1, "GodKi" = min(max((pLv - 4) * 0.25, 0), 0.5))
			verb/Hyperdeath_Mode()
				set category = "Skills"
				adjust(usr)
				if((usr.HyperdeathMeterCurrent < usr.HyperdeathThreshold) && (!usr.CheckSpecial("Hyperdeath Mode")))
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
			Cooldown = 1
			SwordAscension=3
			ActiveMessage="readies CHAOS SABER!"
			OffMessage="dispels the CHAOS SABER."
			adjust(mob/p)
				MakesSword = 1
				SwordAscension = 2
				StrMult = 1.35
				ForMult = 1.15
				PowerMult = 1.15
				EnergyHeal=1
				passives = list("SwordAscension" = 2, "PUSpike" = 25, "KiControl" = 1, "SpiritSword" = 1, "HybridStrike" = 0.25, \
				"DoubleStrike" = 0.5, "BlockChance" = 5, "CriticalBlock" = 0.05, "ManaGeneration" = 1)
				if(p.SagaLevel>=3)
					SwordAscension=p.SagaLevel
					StrMult=1.50
					ForMult=1.25
					PowerMult=1.20
					//HybridStrike is removed because t2 style gives it
					passives = list("SwordAscension"=p.SagaLevel, "Secret Knives" = "ChaosKnife", "Tossing"=2, "PUSpike"=35,"KiControl" = 1,"Chaos Buster" = 1,"SpiritSword" = 1.5, \
					"DoubleStrike" = 1, "BlockChance" = 10, "CriticalBlock" = 0.10, "ManaGeneration" = 2)
				if(p.SagaLevel>=4)
					MakesSecondSword=1
					StrMult=1.60
					ForMult=1.35
					PowerMult=1.25
					ActiveMessage="manifests their Chaos Sabers in a burst of prismatic light."
					OffMessage="dispels the Chaos Sabers."
					passives = list("SwordAscension"=p.SagaLevel, "SwordAscensionSecond"=p.SagaLevel, "Secret Knives" = "ChaosKnife", "Tossing"=2, "PUSpike"=50, "KiControl" = 1, "Chaos Buster" = 1, "SpiritSword" = 2, \
					"DoubleStrike" = 1.5, "Pressure" = 1, "BlockChance" = 15, "CriticalBlock" = 0.15, "ManaGeneration" = 3)
				if(p.SagaLevel>=5)
					MakesSecondSword=1
					StrMult=1.65
					ForMult=1.40
					PowerMult=1.30
					passives = list("SwordAscension"=p.SagaLevel, "SwordAscensionSecond"=p.SagaLevel, "Secret Knives" = "ChaosKnife", "Tossing"=2, "PUSpike"=50, "KiControl" = 1, "Chaos Buster" = 1, "SpiritSword" = 2.25, \
					"DoubleStrike" = 2, "TripleStrike" = 0.5, "Pressure" = 1, "BlockChance" = 15, "CriticalBlock" = 0.15, "ManaGeneration" = 4)
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
			StaffName="Chaos Buster"
			StaffIcon='Aether Bow.dmi'
			ActiveMessage="readies CHAOS BUSTER!"
			OffMessage="dispels their CHAOS BUSTER."
			StaffAscension=2
			adjust(mob/p)
				StrMult=1.15
				ForMult=1.35
				PowerMult = 1.15
				StaffAscension=2
				passives = list("KiControl" = 1, "StaffAscension" = 2, "Chaos Buster" = 1, "SpiritStrike" = 1, "SpiritFlow" = 1.5, "GodSpeed" = 1, "Skimming" = 1, "MovingCharge" = 1, "QuickCast" = 1)
				if(p.SagaLevel>=3)
					passives = list("KiControl" = 1, "StaffAscension" = 3, "Chaos Buster" = 2, "SpiritStrike" = 1, "SpiritFlow" = 2.5, "GodSpeed" = 2, "Skimming" = 1, "MovingCharge" = 1, "QuickCast" = 1)
					StrMult=1.25
					ForMult=1.50
					PowerMult = 1.20
					StaffAscension=3
				if(p.SagaLevel>=4)
					passives = list("KiControl" = 1, "StaffAscension" = 4, "Chaos Buster" = 2, "SpiritStrike" = 1, "SpiritFlow" = 3, "GodSpeed" = 2, "Skimming" = 1, "MovingCharge" = 1, "QuickCast" = 2,)
					StrMult=1.30
					ForMult=1.60
					PowerMult = 1.25
					StaffAscension=4
				if(p.SagaLevel>=5)
					passives = list("KiControl" = 1, "StaffAscension" = p.SagaLevel, "Chaos Buster" = 2, "SpiritStrike" = 1, "SpiritFlow" = 3.5, "GodSpeed" = 2, "Skimming" = 1, "MovingCharge" = 1, "QuickCast" =3)
					StrMult=1.30
					ForMult=1.60
					PowerMult = 1.25
					StaffAscension=p.SagaLevel
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
		ChaosSaberToss
			DamageMult=6
			AccMult=2
			Cooldown=45
			IconSize=1
			Homing=1
			Knockback=3
			ManaCost=5
			Trail='Trail - Flare.dmi'
			TrailSize=1
			IconLock='ChaosSaberProjectile.dmi'
			adjust(mob/p)
				DamageMult = initial(DamageMult)
			verb/ChaosSaberToss()
				set category="Skills"
				set hidden=0
				if(Using || cooldown_remaining)
					return FALSE
				if(usr.CheckSpecial("Hyperdeath Mode"))
					var/hyper_mana_cost = 15
					if(usr.ManaAmount < hyper_mana_cost)
						usr << "You need [hyper_mana_cost] mana."
						return FALSE
					if(!usr.Target || usr.Target == usr)
						usr << "You need a valid target."
						return FALSE
					adjust(usr)
					usr.ManaAmount -= hyper_mana_cost
					if(usr.ManaAmount < 0)
						usr.ManaAmount = 0
					src.Cooldown(1, null, usr)
					usr.SpawnMMOCrossMarkers(/obj/Skills/Projectile/ChaosSaberWave, usr.Target, 11)
					return TRUE
				adjust(usr)
				usr.UseProjectile(src)

		ChaosSaberWave
			YSpawnOffset=4
			DamageMult=20
			AccMult=2
			IconSize=1
			DirOverride=2
			Piercing=1
			Striking=1
			ManaCost=0
			Cooldown=0
			Trail='Trail - Flare.dmi'
			TrailSize=1
			IconLock='ChaosSaberProjectile.dmi'
			adjust(mob/p)
				DamageMult = initial(DamageMult) * glob.MMO_PROJ_DAMAGE_MULT
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

/*
obj/AttackMarker
	icon = 'MMOAttackMarker.dmi'
	icon_state = "WarningBox"
	layer = EFFECTS_LAYER
	mouse_opacity = 0

	var/mob/owner
	var/delay = 20
	var/projectile_type
	var/fire_dir = null

	New(loc, mob/O, projectile_path = null, custom_delay = null, custom_dir = null)
		..()

		owner = O

		if(ispath(projectile_path, /obj/Skills/Projectile))
			projectile_type = projectile_path

		if(!isnull(custom_delay))
			delay = custom_delay

		if(custom_dir)
			fire_dir = custom_dir

		spawn(delay)
			FireMMOAttack()

	proc/FireMMOAttack()
		if(!src || !loc)
			return

		if(!owner)
			del(src)
			return

		var/path = projectile_type

		if(!ispath(path, /obj/Skills/Projectile))
			path = /obj/Skills/Projectile/ChaosSaberWave

		var/obj/Skills/Projectile/p = new path

		p.adjust(owner)

		p.SpawnPosition = src

		if(fire_dir)
			p.DirOverride = fire_dir
		if(fire_dir == EAST)
			p.YSpawnOffset=0
			p.XSpawnOffset=-4
		if(fire_dir == WEST)
			p.YSpawnOffset=0
			p.XSpawnOffset=4
		if(fire_dir == NORTH)
			p.YSpawnOffset=-4
			p.XSpawnOffset=0
		if(fire_dir == SOUTH)
			p.YSpawnOffset=4
			p.XSpawnOffset=0

		owner.UseProjectile(p)

		del(src)

mob/proc/SpawnAttackMarker(path, Target)
	var/turf/T = get_turf(Target)

	if(!T)
		return

	new /obj/AttackMarker(T, src, path)

mob/proc/SpawnCheckerboardMarkers(projectile_path, Target, marker_range = 3)
	if(!Target)
		return

	var/turf/Center = get_turf(Target)
	if(!Center)
		return

	for(var/dx = -marker_range to marker_range)
		for(var/dy = -marker_range to marker_range)
			if((abs(dx) + abs(dy)) % 2 != 0)
				continue

			var/turf/T = locate(Center.x + dx, Center.y + dy, Center.z)
			if(!T)
				continue

			new /obj/AttackMarker(T, src, projectile_path)


mob/proc/SpawnCrossMarkers(projectile_path, Target, marker_range = 3)
	if(!Target)
		return

	var/turf/Center = get_turf(Target)
	if(!Center)
		return

	var/count = 0

	for(var/dx = -marker_range to marker_range)
		var/turf/T = locate(Center.x + dx, Center.y, Center.z)
		if(!T)
			continue

		var/side_dir

		if(dx > 0)
			side_dir = NORTH
		else
			side_dir = SOUTH

		var/marker_delay = 20 + round(count / 4)
		new /obj/AttackMarker(T, src, projectile_path, marker_delay, side_dir)

		count++

	sleep(10)

	for(var/dy = -marker_range to marker_range)

		var/turf/T = locate(Center.x, Center.y + dy, Center.z)
		if(!T)
			continue

		var/side_dir

		if(dy > 0)
			side_dir = EAST
		else
			side_dir = WEST

		var/marker_delay = 20 + round(count / 4)
		new /obj/AttackMarker(T, src, projectile_path, marker_delay, side_dir)

		count++*/