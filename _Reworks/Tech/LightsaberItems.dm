/obj/Items/Gear/var/Improvable = 0
/obj/Items/Gear/var/ImproveLimit = 4
/obj/Items/Gear/var/Improvements = 0
/obj/Items/Gear/Lightsaber
	var/lightSaberColorChoice = "Blue"
	TechType="MilitaryTechnology"
	SubType="Melee Weaponry"
	icon='ProgressiveHilt.dmi'
	pixel_x=-32
	pixel_y=-32
	Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Lightsaber/Lightsaber")
	desc="A more elegant implementation of the Progressive Blade allowing for energy deflections, cleaner bladework and using a miniaturized battery allowing for continuous activation."
	UpgradePath= list(.Double_Lightsaber, .Great_Lightsaber, .Crossguard_Lightsaber, .Shoto_Lightsaber)
	Cost=20
	UpgradeMult=1
	InfiniteUses=1
	Integrateable=1
	Unobtainable=1
	verb/Lightsaber_Color()
		set src in usr
		lightSaberColorChoice=input(usr, "What color would you like for your lightsaber?", "Set Color") in list("Blue", "Green", "Purple", "Red")
			
/obj/Items/Gear/
	verb/Improve()
		set category=null
		set src in usr
		if(src.Using)
			return
		if(usr.icon_state!="Meditate")
			usr << "You need to be sitting down to use this properly."
			return
		if(src.suffix=="*Equipped*")
			usr << "Take off [src] if you want to upgrade it!"
			return
		if(!Improvable)
			usr << "You can't improve [src]!"
			return
		if(Improvements+1 > ImproveLimit)
			usr << "You can't improve [src] any further!"
			return
		src.Using = 1
		usr << "You begin to improve [src]..."
		var/cost = (Cost * (1 + Improvements)) * glob.progress.EconomyCost
		var/Confirm = alert("This will cost [cost] credits. Are you sure you want to continue?", "Improvement", "Yes", "No")
		if(Confirm == "No")
			usr << "You decide not to improve [src]."
			src.Using = 0
			return
		if(!usr.HasMoney(cost))
			usr << "You don't have enough money to improve [src]! ([Commas(usr.GetMoney())] / [Commas(cost)])"
			src.Using = 0
			return
		usr.TakeMoney(cost)
		Improvements++
		Cost = (cost/glob.progress.EconomyCost)
		usr << "You improve [src]!"
		src.Using = 0

	Double_Lightsaber
		var/lightSaberColorChoice = "Blue"
		Cost = 40
		icon='ProgressiveHiltDouble.dmi'
		pixel_x=-32
		pixel_y=-32
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Lightsaber/Double_Lightsaber")
		desc="A more cumbersome implementation of the Lightsaber, allowing for much of the same, but with reduced accuracy and uniquely faster swing speed."
		InfiniteUses=1
		Integrateable=0//honestly none of these should be integratable because it looks ugly with no hilt
		Improvable = 1
		verb/Lightsaber_Color()
			set src in usr
			lightSaberColorChoice=input(usr, "What color would you like for your lightsaber?", "Set Color") in list("Blue", "Green", "Purple", "Red")
		
	Great_Lightsaber
		var/lightSaberColorChoice = "Blue"
		Cost = 40
		icon='GLightsaberHilt.dmi'
		pixel_x=-32
		pixel_y=-32
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Lightsaber/Great_Lightsaber")
		desc="A huge lightsaber that is unwieldly for those smaller in stature. It's size allows for a much more powerful blade, but it's size makes it difficult to use."
		InfiniteUses=1
		Integrateable=0
		Improvable = 1
		verb/Lightsaber_Color()
			set src in usr
			lightSaberColorChoice=input(usr, "What color would you like for your lightsaber?", "Set Color") in list("Blue", "Green", "Purple", "Red")
	
	Crossguard_Lightsaber
		var/lightSaberColorChoice = "Blue"
		Cost = 40
		icon='CrossguardHilt.dmi'
		pixel_x=-32
		pixel_y=-32
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Lightsaber/Crossguard_Lightsaber")
		desc="A Lightsaber focused on dueling and defense, it's crossguard allows for a more defensive style of fighting, but it's blade is weaker than most."
		InfiniteUses=1
		Integrateable=0
		Improvable = 1
		verb/Lightsaber_Color()
			set src in usr
			lightSaberColorChoice=input(usr, "What color would you like for your lightsaber?", "Set Color") in list("Blue", "Green", "Purple", "Red")
	
	Shoto_Lightsaber
		var/lightSaberColorChoice = "Blue"
		Cost = 40
		icon='SProgressiveHilt.dmi'
		pixel_x=-32
		pixel_y=-32
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Lightsaber/Shoto_Lightsaber")
		desc="A smaller lightsaber meant for those smaller in stature. It's size allows for a much more precise blade, but it also has reduced power."
		InfiniteUses=1
		Integrateable=0
		Improvable = 1
		verb/Lightsaber_Color()
			set src in usr
			lightSaberColorChoice=input(usr, "What color would you like for your lightsaber?", "Set Color") in list("Blue", "Green", "Purple", "Red")
	