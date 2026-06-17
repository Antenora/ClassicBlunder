obj/Skills/Buffs/NuStyle/UIHybridStyles// ~~ Angel-taught advanced forms ~~ not unlocked via combo or tier progression ~~//Stat line for these is mostly in line with Tier 3s, but has a little extra oomph
	Ultra_Instinct_Sword
		Copyable = 0
		MakesSword = 1
		FlashDraw = 1
		BladeFisting = 1
		SagaSignature = 1
		SignatureTechnique = 4
		IconLock='GentleDivine.dmi'
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SwordName = "Instinct Blade"
		SwordIcon = 'Icons/Buffs/Ki-Blade.dmi'
		SwordClass = "Medium"
		passives = list("HybridStyle" = "SwordStyle", "LikeWater" = 5, "Instinct" = 4, "The Way" = 1, "Sword Master" = 1, "Flow" = 2.5, "Parry" = 2, "Deflection" = 2,\
                        "Godspeed" = 2, "BlurringStrikes" = 1.5, "Fury" = 3, "Deicide" = 1, "Pressure" = 3, "Momentum" = 1.5, "PUSpike" = 50)
		StyleActive = "Sword Without Thought"
		StyleStr = 1.4
		StyleOff = 1.4
		StyleDef = 1.35
		StyleSpd = 1.5
		PUSpike = 50
		Finisher = "/obj/Skills/Queue/Finisher/Sword_of_No_Thought"
		TextColor = "#b4f0ff"
		ActiveMessage = "draws a blade born of pure instinct!"
		OffMessage = "lets their sword dissolve into light..."
		var/tmp/obj/Items/Sword/EquippedSword
		verb/Attune_Instinct_Blade()
			set category = "Utility"
			if(!usr.BuffOn(src))
				var/classChoice = input(usr, "Choose your preferred sword type.") in list("Light", "Medium", "Heavy")
				SwordClass = classChoice
				var/changeIcon = alert(usr, "Would you like to customize your sword icon?", "Instinct Blade", "Yes", "No")
				if(changeIcon == "Yes")
					SwordIcon = input(usr, "Select an icon for your Instinct Blade.") as icon|null
					src.SwordX = input(usr, "Pixel X offset.") as num
					src.SwordY = input(usr, "Pixel Y offset.") as num
				usr << "Your instincts favor a [SwordClass]-class weapon."
			else
				usr << "You cannot attune your blade while Ultra Instinct Sword is active."
		verb/Ultra_Instinct_Sword()
			set hidden = 1
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
				if("Deflection" in newSword.vars) newSword.vars["Deflection"] = 1
				if("SpiritSword" in newSword.vars) newSword.vars["SpiritSword"] = 1
				if("SwordAscension" in newSword.vars) newSword.vars["SwordAscension"] = 3
				if("MagicSword" in newSword.vars) newSword.vars["MagicSword"] = 1
				if("Unbreakable" in newSword.vars) newSword.vars["Unbreakable"] = 1
				if("BulletKill" in newSword.vars) newSword.vars["BulletKill"] = 1
				if("Extend" in newSword.vars) newSword.vars["Extend"] = 1
				newSword.Move(User)
				EquippedSword = newSword
				User << "Your [SwordName] manifests as a [SwordClass]-class weapon."
			else
				UiSwordOff(User)
			..()
		proc/UiSwordOff(mob/User)
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

	Ultra_Instinct_Grappling
		Copyable = 0
		NeedsSword = 0
		NoSword = 1
		BladeFisting = 1
		SagaSignature = 1
		SignatureTechnique = 4
		IconLock='GentleDivine.dmi'
		IconLockBlend=4
		LockX=-32
		LockY=-32
		passives = list("HybridStyle" = "UnarmedStyle", "Instinct" = 4, "LikeWater" = 4, "Muscle Power" = 5, "Grippy" = 4, "Scoop" = 3, "CounterMaster" = 4,\
                       "Momentum" = 3, "Pressure" = 3, "Flow" = 3, "Juggernaut" = 1, "Fury" = 2, "Deflection" = 2, "Reversal" = 1,\
                       "Parry" = 2, "Godspeed" = 1.5, "PUSpike" = 50)// DO NOT GET GRABBNED ODDO NOT GET GRABBED DO NOT GET GRABBED DO NOT TRY TO THROW THEM DO NOT GET GRABBED
		StyleActive = "Heavenly Wrestling"
		StyleStr = 1.5
		StyleEnd = 1.4
		StyleDef = 1.4
		StyleSpd = 1.35
		StyleOff = 1.3
		PUSpike = 50
		Finisher = "/obj/Skills/Queue/Finisher/Heavenly_Suplex"
		verb/Ultra_Instinct_Grappling()
			set hidden = 1
			src.Trigger(usr)

	Ultra_Instinct_Mystic
		Copyable = 0
		NeedsSword = 0
		NoSword = 1
		BladeFisting = 1
		SagaSignature = 1
		SignatureTechnique = 4
		IconLock='GentleDivine.dmi'
		IconLockBlend=4
		LockX=-32
		LockY=-32
		passives = list("HybridStyle" = "MysticStyle", "Instinct" = 4, "SpiritFlow" = 5, "LikeWater" = 4, "Amplify" = 3, "Familiar" = 3, "Harden" = 2, "Flow" = 3, "Godspeed" = 1.5,\
                       "Erosion" = 0.15, "Deterioration" = 1, "WaveDancer" = 2, "Rain" = 3, "ManaGeneration"=3,\
                       "Burning" = 2, "Freezing" = 2, "Shocking" = 2, "Shattering" = 2, "PUSpike" = 50)/*This should bridge the gap between grappling/sword/martial without being too bad to fight against.
                                                                                        Should. Might need to finetune it because I'm not super familiar with magic shenanigans*/
		StyleActive = "Aetherial Flow"
		StyleFor = 1.5
		StyleOff = 1.4
		StyleDef = 1.3
		StyleSpd = 1.3
		StyleEnd = 1.25
		ElementalClass = "Ultima"
		ElementalOffense = "Ultima"
		ElementalDefense = "Chaos"
		PUSpike = 50
		Finisher = "/obj/Skills/Queue/Finisher/Prismatic_Samsara"
		verb/Ultra_Instinct_Mystic()
			set hidden = 1
			src.Trigger(usr)


	Ultra_Instinct_Martial
		Copyable = 0
		NeedsSword = 0
		NoSword = 1
		BladeFisting = 1
		SagaSignature = 1
		SignatureTechnique = 4
		IconLock='GentleDivine.dmi'
		IconLockBlend=4
		LockX=-32
		LockY=-32
		passives = list("HybridStyle" = "UnarmedStyle", "Instinct" = 5, "LikeWater" = 4, "Momentum" = 3, "Fa Jin" = 3, "Flow" = 3, "Pressure" = 3, "Deflection" = 1.5, "BlurringStrikes" = 1,\
                       "CounterMaster" = 2.5, "Interception" = 3, "Harden" = 2, "Godspeed" = 2, "Fury" = 2, "Parry" = 2, \
                       "Sunyata" = 2, "Reversal" = 1, "PUSpike" = 50)//Hey, it's me, goku.
		StyleActive = "Heavenly Palm"
		StyleStr = 1.4
		StyleSpd = 1.6
		StyleOff = 1.45
		StyleDef = 1.35
		StyleEnd = 1.3
		StyleFor = 1.25
		PUSpike = 50
		Finisher = "/obj/Skills/Queue/Finisher/Heavenly_Palm_Transcendence"
		verb/Ultra_Instinct_Martial()
			set hidden = 1
			src.Trigger(usr)
