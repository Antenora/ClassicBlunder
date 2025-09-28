/obj/Skills/Buffs/SlotlessBuffs/Gear/Lightsaber
	var/LSUID = 0
	SwordUnbreakable = TRUE
	proc/changeColor()
		var/Choice = AssociatedGear?:lightSaberColorChoice
		var/double = type ==  /obj/Skills/Buffs/SlotlessBuffs/Gear/Lightsaber/Double_Lightsaber ? 1 : 0
		var/cross = type == /obj/Skills/Buffs/SlotlessBuffs/Gear/Lightsaber/Crossguard_Lightsaber ? 1 : 0
		var/shoto = type == /obj/Skills/Buffs/SlotlessBuffs/Gear/Lightsaber/Shoto_Lightsaber ? 1 : 0
		var/great = type == /obj/Skills/Buffs/SlotlessBuffs/Gear/Lightsaber/Great_Lightsaber ? 1 : 0
		switch(Choice)
			if("Blue")
				if(double)
					SwordIcon='LightsaberBlueDouble.dmi'
				else if(cross)
					SwordIcon='CLightsaberBlue.dmi'
				else if(shoto)
					SwordIcon='SLightsaberBlue.dmi'
				else if(great)
					SwordIcon='GLightsaberBlue.dmi'
				else
					SwordIcon='LightsaberBlue.dmi'
			if("Green")
				if(double)
					SwordIcon='LightsaberGreenDouble.dmi'
				else if(cross)
					SwordIcon='CLightsaberGreen.dmi'
				else if(shoto)
					SwordIcon='SLightsaberGreen.dmi'
				else if(great)
					SwordIcon='GLightsaberGreen.dmi'
				else
					SwordIcon='LightsaberGreen.dmi'
			if("Purple")
				if(double)
					SwordIcon='LightsaberPurpleDouble.dmi'
				else if(cross)
					SwordIcon='CLightsaberPurple.dmi'
				else if(shoto)
					SwordIcon='SLightsaberPurple.dmi'
				else if(great)
					SwordIcon='GLightsaberPurple.dmi'
				else
					SwordIcon='LightsaberPurple.dmi'
			if("Red")
				if(double)
					SwordIcon='LightsaberRedDouble.dmi'
				else if(cross)
					SwordIcon='CLightsaberRed.dmi'
				else if(shoto)
					SwordIcon='SLightsaberRed.dmi'
				else if(great)
					SwordIcon='GLightsaberRed.dmi'
				else
					SwordIcon='LightsaberRed.dmi'
	proc/getImprovements()
	Lightsaber
		SpiritSword=0.15
		MakesSword=1
		passives = list("Deflection" = 1, "SpiritSword" = 0.1, "SwordAscension" = 1)
		FlashDraw=1
		Deflection=1
		SwordAscension=1
		SwordClass="Medium"
		SwordIcon='LightsaberBlue.dmi'
		SwordX=-32
		SwordY=-32
		Cooldown=30
		ActiveMessage="ignites an elegant lightsaber!"
		OffMessage="extinguishes the plasma of their lightsaber..."
		verb/Lightsaber()
			set category="Skills"
			if(!altered)
				changeColor()
			getImprovements()
			src.Trigger(usr)
	Double_Lightsaber
		SpiritSword=0.25
		MakesSword=1
		FlashDraw=1
		Deflection=1
		SwordAscension=1
		DoubleStrike = 1
		SwordClass="Double"
		SwordIcon='LightsaberBlueDouble.dmi'
		SwordX=-32
		SwordY=-32
		Cooldown=30
		ActiveMessage="ignites an elegant lightsaber!"
		OffMessage="extinguishes the plasma of their lightsaber..."
		getImprovements()
			var/improvementLevel = AssociatedGear.Improvements
			passives = list("SpiritSword" = 0.1 + (0.1*improvementLevel), "Deflection" = 1 + (0.2*improvementLevel), "SwordAscension" = 1 + (improvementLevel-1), "DoubleStrike" = 0.75+(improvementLevel*0.25))
			if(improvementLevel)
				SpiritSword = 0.25 + (0.25 * improvementLevel)
				Deflection = 1 + (0.2 * improvementLevel)
				SwordAscension = 1 + (improvementLevel-1)
				DoubleStrike = 1 + (improvementLevel * 0.25)
		verb/Double_Lightsaber()
			set category="Skills"
			if(!altered)
				changeColor()
			getImprovements()
			src.Trigger(usr)
	Great_Lightsaber
		SpiritSword=0.25
		MakesSword=1
		FlashDraw=1
		Deflection=1
		SwordAscension=1
		SwordDamage = 1
		Extend = 1
		SpdMult = 0.75
		OffMult = 0.75
		SwordClass="Heavy"
		SwordIcon='LightsaberBlue.dmi'
		SwordX=-32
		SwordY=-32
		Cooldown=30
		ActiveMessage="ignites a giant, unwieldly lightsaber!"
		OffMessage="extinguishes the plasma of their lightsaber..."
		getImprovements()
			var/improvementLevel = AssociatedGear.Improvements
			passives = list("SpiritSword" = 0.1 + (0.1*improvementLevel), "Extend"= 1, "Deflection" = 1 + (0.4*improvementLevel), "SwordAscension" = 1 + (improvementLevel-1), "SwordDamage" = 0.5+(improvementLevel*0.25))
			if(improvementLevel)
				SpiritSword = 0.25 + (0.25 * improvementLevel)
				Deflection = 1 + (0.2 * improvementLevel)
				SwordAscension = 1 + (improvementLevel-1)
				SwordDamage = 1 + (0.25 * improvementLevel)
		verb/Great_Lightsaber()
			set category="Skills"
			if(!altered)
				changeColor()
			getImprovements()
			src.Trigger(usr)
	Crossguard_Lightsaber
		SpiritSword=0.25
		MakesSword=1
		FlashDraw=1
		Deflection=1
		SwordAscension=1
		Instinct = 1
		SwordClass="Medium"
		SwordIcon='CProgressiveBlade.dmi'
		SwordX=-32
		SwordY=-32
		Cooldown=30
		ActiveMessage="ignites a giant, unwieldly lightsaber!"
		OffMessage="extinguishes the plasma of their lightsaber..."
		getImprovements()
			var/improvementLevel = AssociatedGear.Improvements
			passives = list("SpiritSword" = 0.1 + (0.1*improvementLevel), "Deflection" = 1 + (0.4*improvementLevel), "SwordAscension" = 1 + (improvementLevel-1), "Instinct" = 0.75+(improvementLevel*0.25))
			if(improvementLevel)
				SpiritSword = 0.25 + (0.25 * improvementLevel)
				Deflection = 1 + (0.4 * improvementLevel)
				SwordAscension = 1 + (improvementLevel-1)
				Instinct = 1 + (0.25 * improvementLevel)
		verb/Crossguard_Lightsaber()
			set category="Skills"
			if(!altered)
				changeColor()
			getImprovements()
			src.Trigger(usr)
	Shoto_Lightsaber
		SpiritSword=0.25
		MakesSword=1
		FlashDraw=1
		Deflection=1
		SwordAscension=1
		Flow = 1
		SwordClass="Light"
		SwordIcon='SLightsaberBlue.dmi'
		SwordX=-32
		SwordY=-32
		Cooldown=30
		ActiveMessage="ignites a giant, unwieldly lightsaber!"
		OffMessage="extinguishes the plasma of their lightsaber..."
		getImprovements()
			var/improvementLevel = AssociatedGear.Improvements
			passives = list("SpiritSword" = 0.1 + (0.1*improvementLevel), "Deflection" = 1 + (0.4*improvementLevel), "SwordAscension" = 1 + (improvementLevel-1), "Flow" = 0.75+(improvementLevel*0.25))
			if(improvementLevel)
				SpiritSword = 0.25 + (0.25 * improvementLevel)
				Deflection = 1 + (0.75 * improvementLevel)
				SwordAscension = 1 + (improvementLevel-1)
				Flow = 1 + (0.5 * improvementLevel)
		verb/Shoto_Lightsaber()
			set category="Skills"
			if(!altered)
				changeColor()
			getImprovements()
			src.Trigger(usr)