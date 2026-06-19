//File to put all the 'Every Quincy gets these eventually' buffs.
//Quincy are intended to be a 6-tier Saga in my design.
/obj/Skills/Buffs/SlotlessBuffs/LetzStil_Aftermath// hehe I just stole this from Mugetsu.
	name = "Lost Quincy Powers"
	Slotless = 1

	adjust(mob/p)
		if(altered) return
		passives = list(
			"ManaLeak"   = 5,
			"EnergyLeak" = 5
		)
		StrMult = 0.7
		EndMult = 0.7
		ForMult = 0.7
		SpdMult = 0.5
		OffMult = 0.5
		DefMult = 0.5

//I'm using Shikais from Shinigami as a sort of baseline for the Quincy weapons. These are emant to be their Shikai equal.
/obj/Skills/Buffs/SlotlessBuffs/Quincy/
	HeiligBogen//QuincyBow Mutually exclusive with Heilig Schwert
		name = "Heilig Bogen"
		Slotless = 1
		ManaThreshold = 2
		SignatureTechnique=3
		SagaSignature=1
		FlashDraw=1
		StaffName="Heilig Bogen"
		StaffIcon='Aether Bow.dmi'
		ActiveMessage="draws reishi into their hand to form a bow!"
		OffMessage="dispels their Heilig Bogen!"
		SpecialStrike=1
		StaffAscension=1
		MakesStaff=1

		adjust(mob/p)
			if(altered) return
			var/SL = p.SagaLevel
			passives = list(
				"SpecialStrike"  = 1,//Lets you shoot Arrows, Pewpew
				"SpiritStrike"   = 1,// Turns most of your Str-based damage into Force damage.
				"HolyMod"        = 0.5 + (SL/2),// Quincy Bows FUCK on Hollows, so I imagine HolyMod fits.
				"Godspeed"       = 1 + SL,//Quincy Fast
				"Instinct"       = 1 + SL,
				"ManaGeneration" = 1 * SL,
				"StaffAscension" = 1 + SL
			)
			//if(p.Schrift == "The Heat") holding this here for potentially adding schrifts to baseline weapons. IDK if I'm adding schrift functionality to baseline weapons.
			//	passives["Scorching"] = SL
			SpdMult = 1.1 + (0.1 * SL)
			ForMult = 1.1 + (0.1 * SL)
			OffMult = 1.1 + (0.1 * SL)

		verb/Transfigure_Heilig_Bogen()
			set category="Utility"
			var/Choice
			if(!usr.BuffOn(src))
				var/Lock=alert(usr, "Do you wish to alter the icon used?", "Weapon Icon", "No", "Yes")
				if(Lock=="Yes")
					src.StaffIcon=input(usr, "What icon will your Heilig Bogen use?", "Heilig Bogen Icon") as icon|null
					src.StaffX=input(usr, "Pixel X offset.", "Heilig Bogen Icon") as num
					src.StaffY=input(usr, "Pixel Y offset.", "Heilig Bogen Icon") as num
				Choice=input(usr, "What class of bow do you want your Heilig Bogen to be?", "Transfigure Heilig Bogen") in list("Short", "Recurve", "Long")
				switch(Choice)
					if("Short")
						src.StaffClass="Wand"
					if("Recurve")
						src.StaffClass="Rod"
					if("Long")
						src.StaffClass="Staff"
				usr << "Heilig Bogen class set as [Choice]!"
			else
				usr << "You can't set this while using Heilig Bogen."


		verb/HeiligBogen()
			set category="Skills"
			if(!usr.BuffOn(src)) adjust();
			src.Trigger(usr)

	HeiligSchwert//QuincySword Mutually exclusive with Heilig Bogen
		Slotless = 1
		ManaThreshold = 2
		SignatureTechnique=3
		SagaSignature=1
		FlashDraw=1
		SwordName="Heilig Schwert"
		SwordIcon='Aether Blade.dmi'
		SwordX=-32
		SwordY=-32
		ActiveMessage="draws reishi into their hand to form a blade!"
		OffMessage="dispels their Heilig Schwert!"
		adjust(mob/p)
			if(altered) return
			var/SL = p.SagaLevel
			passives = list(
				"Extend"         = 0.5 * SL,//Lets your Sword get bigger.
				"SpiritSword"    = 0.5 * SL,// Hybrid Damage! Waow!
				"HolyMod"        = 0.5 + (SL/2),// Quincy Bows FUCK on Hollows, so I imagine HolyMod fits.
				"Godspeed"       = 1 + SL,//Quincy Fast
				"Instinct"       = 1 + SL,
				"ManaGeneration" = 1 * SL,
				"SwordAscension" = 1 + SL
			)
			//if(p.Schrift == "The Heat") holding this here for potentially adding schrifts to baseline weapons. IDK if I'm adding schrift functionality to baseline weapons.
			//	passives["Scorching"] = SL
			StrMult = 1.1 + (0.1 * SL)
			ForMult = 1.1 + (0.1 * SL)
			OffMult = 1.1 + (0.1 * SL)

		verb/Transfigure_Spirit_Sword()
			set category="Utility"
			var/Choice
			if(!usr.BuffOn(src))
				var/Lock=alert(usr, "Do you wish to alter the icon used?", "Weapon Icon", "No", "Yes")
				if(Lock=="Yes")
					src.SwordIcon=input(usr, "What icon will your Heilig Schwert use?", "Heilig Schwert Icon") as icon|null
					src.SwordX=input(usr, "Pixel X offset.", "Heilig Schwert Icon") as num
					src.SwordY=input(usr, "Pixel Y offset.", "Heilig Schwert Icon") as num
				Choice=input(usr, "What class of blade do you want your Heilig Schwert to be?", "Transfigure Heilig Schwert") in list("Blunt", "Saber", "Longsword", "Greatsword")
				switch(Choice)
					if("Blunt")
						src.SwordClass="Wooden"
					if("Saber")
						src.SwordClass="Light"
					if("Longsword")
						src.SwordClass="Medium"
					if("Greatsword")
						src.SwordClass="Heavy"
				usr << "Heilig Schwert class set as [Choice]!"
			else
				usr << "You can't set this while using Heilig Schwert."
		verb/HeiligSchwert()
			set category="Skills"
			src.Trigger(usr)