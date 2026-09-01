obj/Skills/Buffs/NuStyle/MortalUIStyles// ~~ Angel-taught basic forms ~~  unlocked via tier progression ~~
	Mortal_Instinct_Sword
		Copyable = 0
		MakesSword = 1
		FlashDraw = 1
		BladeFisting = 1
		SagaSignature = 1
		SignatureTechnique = 1
		IconLock='AuraMysticBig.dmi'
		AuraArt=1
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SwordName = "Mortal Instinct Blade"
		SwordIcon = 'Icons/Buffs/Ki-Blade.dmi'
		SwordClass = "Medium"
		passives = list("HybridStyle" = "SwordStyle", "Parry" = 1, "Deflection" = 1, "Momentum" = 1, "PUSpike" = 10, "BladeFisting" = 1)
		StyleActive = "Sword of Awareness"
		StyleStr = 1.15
		StyleOff = 1.1
		StyleDef = 1.1
		StyleSpd = 1.2
		PUSpike = 10
		Finisher = "/obj/Skills/Queue/Finisher/Sword_of_Awareness"
		TextColor = "#b4f0ff"
		ActiveMessage = "draws a blade born of mortal awareness!"
		OffMessage = "lets their sword dissolve into light..."
		var/tmp/obj/Items/Sword/EquippedSword
		adjust(mob/p)
			if(altered) return
			passives = list("Parry" = 1, "Deflection" = 1, "Momentum" = 1, "PUSpike" = 10, "BladeFisting" = 1)
			if(p.AscensionsAcquired==2)
				if(p.isRace(ANGEL))
					passives = list("Parry" = 1.5, "Deflection" = 1, "Momentum" = 1, "PUSpike" = 10,  "Iaijutsu" = 1,)
					StyleStr = 1.35
					StyleOff = 1.35
					StyleDef = 1.45
					StyleSpd = 1.45
				else
					passives = list("Deflection" = 1, "SoftStyle" = 1, "CounterMaster" = 1,  "Iaijutsu" = 1)
					StyleStr = 1.45
					StyleSpd = 1.45
					StyleOff = 1.35
					StyleDef = 1.35
			if(p.AscensionsAcquired>=3)
				if(p.isRace(ANGEL)||p.isRace(MAKAIOSHIN))
					passives = list("Parry" = 1.5, "Deflection" = 1, "Momentum" = 1, "PUSpike" = 10,  "Iaijutsu" = 1.5,)
					StyleStr = 1.45
					StyleOff = 1.45
					StyleDef = 1.45
					StyleSpd = 1.65
				else
					passives = list("Deflection" = 1, "SoftStyle" = 1, "CounterMaster" = 1,  "Iaijutsu" = 1.5)
					StyleStr = 1.45
					StyleSpd = 1.65
					StyleOff = 1.35
					StyleDef = 1.35
		verb/Attune_Mortal_Blade()
			set category = "Utility"
			set hidden = 1
			if(!usr.BuffOn(src))
				var/classChoice = input(usr, "Choose your preferred sword type.") in list("Light", "Medium", "Heavy")
				SwordClass = classChoice
				var/changeIcon = alert(usr, "Would you like to customize your sword icon?", "Instinct Blade", "Yes", "No")
				if(changeIcon == "Yes")
					SwordIcon = input(usr, "Select an icon for your Instinct Blade.") as icon|null
					src.SwordX = input(usr, "Pixel X offset.") as num
					src.SwordY = input(usr, "Pixel Y offset.") as num
				usr << "Your awareness favors a [SwordClass]-class weapon."
			else
				usr << "You cannot attune your blade while Mortal Instinct Sword is active."
		verb/Mortal_Instinct_Sword()
			set hidden = 1
			adjust(usr)
			src.Trigger(usr)
		Trigger(mob/User)
			if(!EquippedSword)
				var/obj/Items/Sword/newSword
				switch(SwordClass)
					if("Light") newSword = new /obj/Items/Sword/Light
					if("Medium") newSword = new /obj/Items/Sword/Medium
					if("Heavy") newSword = new /obj/Items/Sword/Heavy
					else newSword = new /obj/Items/Sword/Medium
				newSword.icon = SwordIcon
				newSword.pixel_x = SwordX
				newSword.pixel_y = SwordY
				newSword.name = SwordName
				newSword.Unobtainable = 1
				newSword.suffix = "*Equipped*"
				newSword.desc = "A sword forged from pure instinct and divine flow."
				if("Destructable" in newSword.vars) newSword.vars["Destructable"] = 0
				if("ShatterCounter" in newSword.vars) newSword.vars["ShatterCounter"] = 999999
				if("ShatterMax" in newSword.vars) newSword.vars["ShatterMax"] = 999999
				if("SummonSwordVisual" in newSword.vars) newSword.vars["SummonSwordVisual"] = 0.5
				if("SwordAscension" in newSword.vars) newSword.vars["SwordAscension"] = 2
				if("MagicSword" in newSword.vars) newSword.vars["MagicSword"] = 1
				if("Unbreakable" in newSword.vars) newSword.vars["Unbreakable"] = 1
				newSword.Move(User)
				EquippedSword = newSword
				User << "Your [SwordName] manifests as a [SwordClass]-class weapon."
			else
				MiSwordOff(User)
			..()
		proc/MiSwordOff(mob/User)
			if(!User || !EquippedSword) return
			if(OffMessage && TextColor)
				view(User, 10) << "<span style='color:[TextColor]'>[User] [OffMessage]</span>"
			EquippedSword.suffix = null
			var/placement = FLOAT_LAYER - 3
			if(EquippedSword.LayerPriority)
				placement -= EquippedSword.LayerPriority
			if(EquippedSword.EquipIcon)
				var/image/equipImg = image(icon = EquippedSword.EquipIcon, pixel_x = EquippedSword.pixel_x, pixel_y = EquippedSword.pixel_y, layer = placement)
				User.overlays -= equipImg
			else
				var/image/swordImg = image(icon = EquippedSword.icon, pixel_x = EquippedSword.pixel_x, pixel_y = EquippedSword.pixel_y, layer = placement)
				User.overlays -= swordImg
			for(var/obj/Items/Sword/S in User)
				if(S.name == SwordName)
					del(S)
			EquippedSword = null
			User.equippedSword = null

	Mortal_Instinct_Grappling
		Copyable = 0
		NeedsSword = 0
		NoSword = 1
		BladeFisting = 1
		SagaSignature = 1
		SignatureTechnique = 1
		IconLock='AuraMysticBig.dmi'
		AuraArt=1
		IconLockBlend=4
		LockX=-32
		LockY=-32
		passives = list("HybridStyle" = "UnarmedStyle", "Muscle Power" = 2, "Grippy" = 2, "Scoop" = 1, "Momentum" = 1, "Deflection" = 0.5, "Reversal" = 0.5, "BladeFisting" = 1)
		StyleActive = "Instinctual Grappling"
		StyleStr = 1.15
		StyleEnd = 1.1
		StyleDef = 1.1
		StyleSpd = 1.15
		StyleOff = 1.1
		Finisher = "/obj/Skills/Queue/Finisher/Instinct_Grapple"
		adjust(mob/p)
			passives = list("Muscle Power" = 2, "Grippy" = 2, "Scoop" = 1, "Momentum" = 1, "Deflection" = 0.5, "Reversal" = 0.5, "BladeFisting" = 1)
			if(p.AscensionsAcquired==2)
				if(p.isRace(ANGEL))
					passives = list("Muscle Power" = 2.5, "Grippy" = 2.5, "Scoop" = 2, "Momentum" = 1.5, "Deflection" = 0.5, "Reversal" = 0.5, "BladeFisting" = 1)
					StyleStr = 1.45
					StyleEnd = 1.3
					StyleDef = 1.2
					StyleSpd = 1.2
					StyleOff = 1.25
				else
					passives = list("Muscle Power" = 2, "Grippy" = 2.5, "Scoop" = 1.5, "Momentum" = 1.5, "Deflection" = 0.5, "Reversal" = 0.75, "BladeFisting" = 1)
					StyleStr = 1.5
					StyleEnd = 1.25
					StyleDef = 1.15
					StyleSpd = 1.15
					StyleOff = 1.25
			if(p.AscensionsAcquired>=3)
				if(p.isRace(ANGEL)||p.isRace(MAKAIOSHIN))
					passives = list("Muscle Power" = 3.5, "Grippy" = 3, "Scoop" = 2.5, "Momentum" = 2, "Deflection" = 0.5, "Reversal" = 1,"UnarmedDamage"=2, "BladeFisting" = 1)
					StyleStr = 1.65
					StyleEnd = 1.35
					StyleDef = 1.1
					StyleSpd = 1.2
					StyleOff = 1.15
				else
					passives = list("Muscle Power" = 3, "Grippy" = 2.5, "Scoop" = 2, "Momentum" = 2.5, "Deflection" = 0.5, "Reversal" = 1.5,"UnarmedDamage"=2, "BladeFisting" = 1)
					StyleStr = 1.6
					StyleEnd = 1.4
					StyleDef = 1.15
					StyleSpd = 1.15
					StyleOff = 1.25
		verb/Mortal_Instinct_Grappling()
			set hidden = 1
			adjust(usr)
			src.Trigger(usr)

	Mortal_Instinct_Mystic
		Copyable = 0
		NeedsSword = 0
		NoSword = 1
		BladeFisting = 1
		SagaSignature = 1
		SignatureTechnique = 1
		IconLock='AuraMysticBig.dmi'
		AuraArt=1
		IconLockBlend=4
		LockX=-32
		LockY=-32
		passives = list("HybridStyle" = "MysticStyle", "Amplify" = 1, "WaveDancer" = 1,  "Burning" = 1, "Freezing" = 1,\
                        "Shocking" = 1, "Shattering" = 1, "MartialMagic" = 1,"PUSpike" = 15, "BladeFisting" = 1)
		StyleActive = "Aetherial Spark"
		StyleFor = 1.15
		StyleOff = 1.1
		StyleDef = 1.1
		StyleSpd = 1.15
		StyleEnd = 1.1
		PUSpike = 15
		Finisher = "/obj/Skills/Queue/Finisher/Dancing_Prism"
		ElementalClass = "Mirror"
		ElementalOffense = "Mirror"
		ElementalDefense = "Mirror"
		adjust(mob/p)
			passives = list("Amplify" = 1, "WaveDancer" = 1,  "Burning" = 1, "Freezing" = 1,\
                        "Shocking" = 1, "Shattering" = 1, "MartialMagic" = 1,"PUSpike" = 15, "BladeFisting" = 1)
			if(p.AscensionsAcquired==2)
				if(p.isRace(ANGEL))
					passives = list("Amplify" = 1, "WaveDancer" = 1,  "Burning" = 1, "Freezing" = 1,\
			                        "Shocking" = 1, "Shattering" = 1, "MartialMagic" = 1,"PUSpike" = 15, "BladeFisting" = 1)
					StyleFor = 1.35
					StyleOff = 1.15
					StyleDef = 1.15
					StyleSpd = 1.25
					StyleEnd = 1.1
				else
					passives = list("Amplify" = 1, "WaveDancer" = 1,  "Burning" = 1, "Freezing" = 1,\
			                        "Shocking" = 1, "Shattering" = 1, "MartialMagic" = 1,"PUSpike" = 15, "BladeFisting" = 1)
					StyleFor = 1.35
					StyleOff = 1.15
					StyleDef = 1.15
					StyleSpd = 1.25
					StyleEnd = 1.1
			if(p.AscensionsAcquired>=3)
				if(p.isRace(ANGEL)||p.isRace(MAKAIOSHIN))
					passives = list("Amplify" = 1, "WaveDancer" = 1,  "Burning" = 1, "Freezing" = 1,\
			                        "Shocking" = 1, "Shattering" = 1, "MartialMagic" = 1,"PUSpike" = 15, "BladeFisting" = 1)
					StyleFor = 1.4
					StyleOff = 1.15
					StyleDef = 1.15
					StyleSpd = 1.5
					StyleEnd = 1.1
				else
					passives = list("Amplify" = 1, "WaveDancer" = 1,  "Burning" = 1, "Freezing" = 1,\
			                        "Shocking" = 1, "Shattering" = 1, "MartialMagic" = 1,"PUSpike" = 15, "BladeFisting" = 1)
					StyleFor = 1.35
					StyleOff = 1.15
					StyleDef = 1.15
					StyleSpd = 1.5
					StyleEnd = 1.1
		verb/Mortal_Instinct_Mystic()
			set hidden = 1
			adjust(usr)
			src.Trigger(usr)

	Mortal_Instinct_Martial
		Copyable = 0
		NeedsSword = 0
		NoSword = 1
		BladeFisting = 1
		SagaSignature = 1
		SignatureTechnique = 1
		IconLock='AuraMysticBig.dmi'
		AuraArt=1
		IconLockBlend=4
		LockX=-32
		LockY=-32
		StyleActive = "Instinctive Palm"
		passives = list("Momentum" = 1, "Deflection" = 0.5, "CounterMaster" = 0.5, "Interception" = 0.5, "Reversal" = 0.5, "BladeFisting" = 1)
		StyleStr = 1.15
		StyleSpd = 1.15
		StyleOff = 1.1
		StyleDef = 1.1
		StyleEnd = 1.1
		StyleFor = 1.05
		Finisher = "/obj/Skills/Queue/Finisher/Instinct_Palm"
		adjust(mob/p)
			passives = list("HybridStyle" = "UnarmedStyle", "Momentum" = 1, "Deflection" = 0.5, "CounterMaster" = 0.5, "Interception" = 0.5, "Reversal" = 0.5, "BladeFisting" = 1)
			if(p.AscensionsAcquired==2)
				if(p.isRace(ANGEL))
					passives = list("Momentum" = 1.5, "Deflection" = 1.25, "CounterMaster" = 0.75, "Interception" = 1.5, "Reversal" = 0.75,"UnarmedDamage"=1, "BladeFisting" = 1)
					StyleStr = 1.35
					StyleSpd = 1.35
					StyleOff = 1.25
					StyleDef = 1.25
					StyleEnd = 1.25
					StyleFor = 1.1
			else
				passives = list("Momentum" = 1.5, "Deflection" = 0.75, "CounterMaster" = 1.25, "Interception" = 0.75, "Reversal" = 1.5,"UnarmedDamage"=1, "BladeFisting" = 1)
				StyleStr = 1.35
				StyleSpd = 1.35
				StyleOff = 1.25
				StyleDef = 1.25
				StyleEnd = 1.25
				StyleFor = 1.1
			if(p.AscensionsAcquired>=3)
				if(p.isRace(ANGEL)||p.isRace(MAKAIOSHIN))
					passives = list("Momentum" = 2, "Deflection" = 2, "CounterMaster" = 1.5, "Interception" = 2, "Reversal" = 1.5,"UnarmedDamage"=2, "BladeFisting" = 1)
					StyleStr = 1.45
					StyleSpd = 1.45
					StyleOff = 1.25
					StyleDef = 1.25
					StyleEnd = 1.25
					StyleFor = 1.15
				else
					passives = list("Momentum" = 2, "Deflection" = 1.5, "CounterMaster" = 2, "Interception" = 1.5, "Reversal" = 2,"UnarmedDamage"=2, "BladeFisting" = 1)
					StyleStr = 1.45
					StyleSpd = 1.45
					StyleOff = 1.25
					StyleDef = 1.25
					StyleEnd = 1.25
					StyleFor = 1.15
		verb/Mortal_Instinct_Martial()
			set hidden = 1
			adjust(usr)
			src.Trigger(usr)
