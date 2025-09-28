obj
	Savable=1
	var/Unobtainable=0
	var/Pickable=1
	var/Stealable=1
	var/AllowBolt=0

obj/Money
	Level=0
	icon='money.dmi'
	var/MoneyCreator
	Stealable=1
	layer=5
	Click()
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if((src in usr))
			var/Amount=input("Drop how much money? (1-[src.Level])") as num
			Amount=round(Amount)
			if(Amount>Level) Amount=Level
			if(Amount<1) return
			usr.DropMoney(Amount)
		else
			if(ismob(src.loc)&&src.loc:KO)
				var/Amount=input(usr, "Steal how much?") as num|null
				if(Amount>src.Level)
					Amount=src.Level
				if(Amount<1||!Amount)
					return
				src.loc:TakeMoney(Amount)
				OMsg(usr, "[usr] steals [Commas(round(Amount))] [glob.progress.MoneyName] from [src.loc]!")
				usr.GiveMoney(Amount)

	proc/checkDuplicate(mob/p)
		var/counter = 0
		var/list/moneyList = list()
		if(locate(/obj/Money, p))
			for(var/obj/Money/money in p)
				counter ++
				moneyList.Add(money)
			while(counter > 1)
				var/obj/choice = input(p, "You have duplicate's of Money, please select which one to delete", "Money") in moneyList
				moneyList.Remove(choice)
				counter --
				del choice
obj/Items
	Pickable=1
	Stealable=1
	// wow stat adds or something
	var/strAdd = 0
	var/endAdd = 0
	var/forAdd = 0
	var/spdAdd = 0
	var/offAdd = 0
	var/defAdd = 0









	var/list/Creator=new
	var/CreatorKey
	var/CreatorSignature
	var/Cost
	var/TechType
	var/SubType
	var/UnderlayIcon
	var/UnderlayX
	var/UnderlayY

	var/InternalTimer

	var/EquipIcon
	var/LayerPriority=0//1-9, higher ones are displayed above others
	var/IsHat//Is the object a hat?!

	var/PermEquip=0//Can't be unequipped
	var/BoundEquip//defines true owner
	var/LegendaryItem//Does this have verbs associated with it / a Tier S?
	var/SpiritPower//gives spirit power
	var/Mythical//gives legendary power
	var/HellPower //gives hell power
	var/ShonenPower //makes you into a shonen protagonist
	var/TrueLegend //flagged so that a bunch of legendaries don't spawn when you boot up the world...
	var/list/Techniques=list()//Techniques the item gives.
	var/NoStrip //Don't take the techniques, durhhh
	var/NoSaga //doesn't allow Saga users to fuck with it
	var/Saga //Associated Tier S
	var/list/TierTechniques=list()//1="technique name" and so on
	var/LockedLegend=0//dont give me my sword jutsu

	var/Stackable=0//If this is flagged, it will accumulate stacks of the item
	var/TotalStack=1//Only used if stackable.

	var/UpdatesDescription=0//If this is flagged, runs the Update_Description proc before outputting a desc

	var/Repairable=0//If this is flagged, you can use a conservation kit on it / repair it.
	var/ShatterCounter=200
	var/ShatterMax=500
	var/ShatterTier=0
	var/Broken=0
	var/Unwieldy=0
	var/Conversions

	var/DamageEffectiveness
	var/AccuracyEffectiveness
	var/SpeedEffectiveness
	var/Class
	var/ExtraClass
	var/Element
	var/Ascended=0
	var/InnatelyAscended=0//for conjured items
	var/Glass=0//+1 stat levels, but breaky
	var/Enchanted=0
	var/EnchantType

	var/HeavyHitter
	var/DemonicDurability
	var/CursedWounds
	var/MaimStrike
	var/SwordPunching
	var/list/passives = list()
	var/list/current_passives
	
	proc/onBroken()


	proc/setStatLine()
		switch(Class)
			if("Light")
				DamageEffectiveness=1.025
				AccuracyEffectiveness=0.9
				SpeedEffectiveness=1.25
			if("Medium")
				DamageEffectiveness=1.05
				AccuracyEffectiveness=0.875
				SpeedEffectiveness=1
			if("Heavy")
				DamageEffectiveness=1.1
				AccuracyEffectiveness=0.8
				SpeedEffectiveness=0.8

	proc/startBreaking(dmg, val, mob/owner, mob/attacker, type)
		if(val > glob.MAX_BREAK_MULT)
			val = glob.MAX_BREAK_MULT
		var/breakVal = (dmg * val) * (attacker.GetOff(0.3)+(attacker.GetStr(0.3) * glob.DMG_STR_EXPONENT))

		if(breakVal > glob.MAX_BREAK_VAL)
			breakVal = glob.MAX_BREAK_VAL

		if(owner.Saga=="Unlimited Blade Works")
			breakVal*= glob.UBW_BREAK_MULTIPLIER

			if(owner.UBWPath=="Firm")
				breakVal *= glob.UBW_FIRM_BREAK_MULTIPLIER

		decreaseShatterCounter(breakVal, owner, attacker, type)

	proc/decreaseShatterCounter(val, mob/owner, mob/attacker, type)
		if(ShatterCounter > 0)
			ShatterCounter -= val
			if(ShatterCounter == 100 || ShatterCounter == 25)
				owner<< "Your [src] has [ShatterCounter] durability left."
		if(ShatterCounter <= 0)
			ShatterCounter = 0
			switch(type)
				if("sword")
					owner.SwordShatter(src)
				if("staff")
					owner.StaffShatter(src)
				if("armor")
					owner.ArmorShatter(src)

	verb/Set_Underlay()
		set src in usr
		if(src.suffix=="*Equipped*")
			usr << "Take [src] off before adding an underlay."
			return
		if(src.UnderlayIcon)
			src.UnderlayIcon=null
			src.UnderlayX=0
			src.UnderlayY=0
			usr << "Underlay icon removed."
			return
		src.UnderlayIcon=input(usr, "What icon do you want to display as an underlay?", "Underlay Icon") as icon|null
		src.UnderlayX=input(usr, "Pixel X?", "Underlay Icon") as num|null
		src.UnderlayY=input(usr, "Pixel Y?", "Underlay Icon") as num|null
		usr << "Done."

	verb/Set_Layer()
		set src in usr
		var/Equipped=0
		if(src.suffix=="*Equipped*")
			src.ObjectUse(usr)
			Equipped=1
		var/list/Options=list("Standard Overlay", "Low Overlay", "Lower Overlay", "Lowest Overlay")
		src.LayerPriority=input(usr, "What layer do you want [src] to appear on?  Higher layers are stacked on top of lower layers.", "Set Layer") in Options
		switch(src.LayerPriority)
			if("Lowest Overlay")
				src.LayerPriority=0.3
			if("Lower Overlay")
				src.LayerPriority=0.2
			if("Low Overlay")
				src.LayerPriority=0.1
			if("Standard Overlay")
				src.LayerPriority=0
		if(Equipped)
			src.ObjectUse(usr)

	proc/Drop()
		if(src.PermEquip)
			if(istype(src, /obj/Items/Enchantment/Magic_Crest))
				usr << "You can't drop this, you can only transplant it!"
				return

			usr << "You can't drop this!"
			return
		// if(Augmented)
		// 	usr<<"You can't drop this!"
		// 	return
		if(LegendaryItem)
			usr << "You can't drop this!"
			return

		if(src.Stackable)
			var/Drop=input(usr, "How many [src]s do you want to drop?", "Drop") as num|null
			if(Drop>0&&Drop)
				if(Drop>src.TotalStack)
					Drop=src.TotalStack
				var/Drop2=new src.type(get_step(usr, usr.dir))
				Drop2:TotalStack=Drop
				Drop2:suffix="[Drop2:TotalStack]"
				src.TotalStack-=Drop
				src.suffix="[src.TotalStack]"
				if(src.TotalStack==0)
					del src
		else
			loc=get_step(usr,usr.dir)

	verb/DropItem()
		set name="Drop Item"
		var/Nope=0
		if(istype(src,/obj/Items/Sword))
			if(src:ProjectionBlade)
				usr << "Your magic blade dissolves."
				del src
				return
		if(src.suffix=="*Equipped*")
			Nope=1
		if(Nope)
			usr<<"You can't drop a equiped item. Take it off first!"
			return
		Drop()
	Click()
		if(src in Technology_List)
			var/obj/ItemMade
			if(usr.KO)
				usr << "You cannot create items while KO'd."
				return
			var/Mode=alert(usr, "Do you want to buy the item or examine it?", "[src]", "Buy", "Examine")
			if(Mode=="Examine")
				if(istype(src,/obj/Items))
					if(src:UpdatesDescription)
						src:Update_Description()
				if(src.desc)
					usr<<src.desc
				else
					usr << "[src] has no description."
				return
			if(!usr.HasMoney(src.Cost))
				usr << "You don't have enough money to buy [src]."
				return
			if(1)
				if(istype(src,/obj/Items/Tech/Power_Pack))
					var/MultiMake=input("How many packs would you like to make?")as num|null
					if(MultiMake==null||MultiMake<=0)
						return
					var/MultiCost=Technology_Price(usr,src)
					for(var/obj/Money/M in usr)
						if(M.Level>=MultiCost*MultiMake)
							usr.TakeMoney(MultiCost*MultiMake)
							var/obj/Items/Tech/Power_Pack/P=new type(usr.loc)
							P.TotalStack=MultiMake
							P.suffix="[MultiMake]"
							if(MultiMake>1)
								usr<<"You made [MultiMake] [src]."
						else
							usr<<"You don't have enough money! You need [Commas(MultiCost*MultiMake)] resources to make [MultiMake] [src]."
					return
				if(Can_Afford_Technology(usr, src))
					usr.TakeMoney(Technology_Price(usr, src))
					usr.UpdateTechnologyWindow()


					ItemMade=new src.type
					if(ItemMade:Stackable)
						var/stacktype=ItemMade.type
						for(var/obj/Items/o in usr)
							if(o.type==stacktype)
								o.TotalStack++
								usr << "You stack a new [ItemMade]."
								del ItemMade
					if(ItemMade)
						if(ItemMade.Grabbable)
							ItemMade.loc=usr
						else
							ItemMade.loc=usr.loc
						ItemMade:CreatorKey=usr.ckey
						ItemMade:CreatorSignature=usr.EnergySignature

					usr << "You made \an [ItemMade]!"

				if(istype(src,/obj/Items/Tech/Scouter))
					if(ItemMade:ScouterIcon!=1)
						ItemMade:ScouterIcon=1
						var/Choice=input("What icon would you like for the scouter?") in list ("Green","Blue","Red","Purple")
						switch(Choice)
							if("Green")
								ItemMade:icon='GreenScouter.dmi'
							if("Blue")
								ItemMade:icon='BlueScouter.dmi'
							if("Red")
								ItemMade:icon='RedScouter.dmi'
							if("Purple")
								ItemMade:icon='PurpleScouter.dmi'

		else if(src in Enchantment_List)
			var/obj/ItemMade
			var/Mode=alert(usr, "Do you want to buy the item or examine it?", "[src]", "Buy", "Examine")
			if(Mode=="Examine")
				if(istype(src,/obj/Items))
					if(src:UpdatesDescription)
						src:Update_Description()
				if(src.desc)
					usr<<src.desc
				else
					usr << "[src] has no description."
				return


			if(istype(src, /obj/Items/Enchantment/PocketDimensionGenerator))
				if(!usr.HasFragments(src.Cost*glob.progress.EconomyCost))
					usr << "You don't have enough fragments to buy [src]."
					return
				else
					usr.TakeFragments(src.Cost*glob.progress.EconomyCost)
			if(usr.HasManaCapacity(src.Cost*(glob.progress.EconomyMana/100)))
				usr.TakeManaCapacity(src.Cost*(glob.progress.EconomyMana/100))
				ItemMade=new src.type
				if(istype(src, /obj/Items/Enchantment/Tome))
					ItemMade:init(1, usr)
				if(ItemMade.Grabbable)
					ItemMade.loc=usr
				else
					ItemMade.loc=usr.loc
				ItemMade:CreatorKey=usr.ckey
				ItemMade:CreatorSignature=usr.EnergySignature
				usr << "You made \an [ItemMade]!"
			else
				usr << "You don't have enough capacity stored to make [src]!"
				return
			usr.UpdateTechnologyWindow()
			if(istype(src,/obj/Items/Enchantment/Staff))
				if(ItemMade:StaffIconSelected!=1)
					var/Choice=input("What icon would you like for the staff?") in list ("Red","Grey","Brown","Red 2","Green","Cyan","Red 3")
					switch(Choice)
						if("Red")
							ItemMade:icon='MageStaff.dmi'
							ItemMade:StaffIconSelected=1
						if("Grey")
							ItemMade:icon='MageStaff2.dmi'
							ItemMade:StaffIconSelected=1
						if("Brown")
							ItemMade:icon='MageStaff3.dmi'
							ItemMade:StaffIconSelected=1
						if("Red 2")
							ItemMade:icon='MageStaff4.dmi'
							ItemMade:StaffIconSelected=1
						if("Green")
							ItemMade:icon='MageStaff5.dmi'
							ItemMade:StaffIconSelected=1
						if("Cyan")
							ItemMade:icon='MageStaff6.dmi'
							ItemMade:StaffIconSelected=1
						if("Red 3")
							ItemMade:icon='MageStaff8.dmi'
							ItemMade:StaffIconSelected=1
		else if(src in Clothes_List)
			if(icon == initial(icon)&&usr.IconClicked==0)
				usr.IconClicked=1
				var/Color=input("Choose color") as color|null
				var/icon/newIcon = new(icon)
				newIcon+=Color
				usr.IconClicked=0
				var/obj/A=new type
				A.blend_mode = BLEND_OVERLAY
				A.icon=newIcon
				usr.contents+=A
		else
			if(!usr.Saga||(usr.Saga&&!src.NoSaga)||(usr.Saga&&src.NoSaga&&src.suffix=="*Equipped*"))
				src.ObjectUse()
			else
				usr << "[src] does not resonate with your legendary abilities."
				return

	Edibles
		Health=1
		layer=MOB_LAYER+0.5
		var/EatText
		var/EatNutrition
		var/EatToxicity
		Booze
			icon='Foods.dmi'
			icon_state="Booze"
			Pickable=1
		Food
			icon='Foods.dmi'
			icon_state="Poor"
			Pickable=1
		Senzu
			icon='Senzu.dmi'
			icon_state=""
			Pickable=1
			EatText="eats the bean; its rejuvenating power heals them fully!"
			EatNutrition=6
		Click()
			if(!(usr in oview(1,src))&&!(src in usr))
				return
			var/RacialHunger=1
			if(usr.race in list(SAIYAN,BEASTMAN))
				RacialHunger=5
			if(usr.race in list(MAJIN,DRAGON,DEMON))
				RacialHunger=20
			if(usr.EnhancedSmell)
				RacialHunger*=2
			if(usr.Satiated>=4000*RacialHunger)
				usr << "You are completely full!"
				return
			if(src.EatNutrition>=6 && usr.icon_state != "Meditate")
				usr << "You must be meditating to eat this."
			if(!src.EatToxicity)
				var/eattingtext=replacetext(EatText, "usrName", "[usr]")
				OMsg(usr, "[eattingtext]")
				usr.Satiated+=EatNutrition*1000
				usr.HealWounds(EatNutrition*2)
				usr.HealFatigue(EatNutrition*2)
				if(src.EatNutrition>5)
					usr.Sheared=0
					usr.TotalInjury=0
					usr.TotalFatigue=0
					usr.TotalCapacity=0
					usr.HealHealth(100)
					usr.HealEnergy(100)
					usr.HealMana(100)
					usr.StrTax=0
					usr.EndTax=0
					usr.SpdTax=0
					usr.OffTax=0
					usr.DefTax=0
					if(usr.GatesNerf)
						usr.GatesNerf=1
					if(usr.OverClockTime)
						usr.OverClockTime=1
					if(usr.BPPoison<1)
						usr.BPPoison=1
						usr.BPPoisonTimer=0
					if(usr.Maimed)
						usr.Maimed--
						usr << "You recover from a maiming!"
					if(usr.SenseRobbed)
						if(usr.SenseRobbed>=5)
							animate(usr.client, color=null, time=1)
						usr.SenseRobbed=0
						usr << "You regain lost senses!"
			else
				var/eattingtext=replacetext(EatText, "usrName", "[usr]")
				OMsg(usr, "[eattingtext]")
				usr.Satiated+=EatNutrition*1000
				if(usr.Satiated>=2000 && !usr.Drunk)
					usr.Drunk=1
					usr << "You've grown drunk!"
				if(prob(20*src.EatToxicity))
					usr << "<font color='red'>You feel dizzy!</font>"
					Stun(usr, 2*src.EatToxicity)
				if(prob(20*src.EatToxicity))
					usr << "<font color='red'>You start to stumble!</font>"
					usr.AddConfusing(20*src.EatToxicity)
				if(prob(20*src.EatToxicity))
					usr << "<font color='red'>Your balance is out of whack!</font>"
					usr.AddCrippling(20*src.EatToxicity)
				if(prob(10*src.EatToxicity))
					usr << "You feel really sick!"
					usr.AddPoison(4*src.EatToxicity)
				if(prob(5*src.EatToxicity))
					usr << "<font color='red'>You feel aggressive!</font>"
					usr.Anger()
				else if(prob(5*src.EatToxicity))
					usr << "<font color='red'>You grow mellow!</font>"
					usr.AddPacifying(20*src.EatToxicity)
			del(src)


	Wearables
		Health=1
		var/SpecialClothing=0
		verb/Toggle_Hat()
			set src in usr
			if(src.IsHat)
				src.IsHat=0
				usr << "[src] has been labelled as <FONT COLOR='RED'>NOT A HAT.</font color>"
			else
				src.IsHat=1
				usr << "[src] has been labelled as <font color='green'>A HAT.</font color>"
		verb/Toggle_Special()
			set src in usr
			if(src.SpecialClothing)
				src.SpecialClothing=0
				usr << "[src] has been labelled as <FONT COLOR='RED'>NON-SPECIAL PIECE.</font color>"
			else
				src.SpecialClothing=1
				usr << "[src] has been labelled as <font color='green'>SPECIAL PIECE.</font color>"
		Eyes_1 icon = 'Eyes.dmi'
		Icon_0 icon = 'buttonup-female_mono.dmi'
		Icon_1 icon = 'buttonup-femmale_mono.dmi'
		Icon_2 icon = 'buttonup-male_mono.dmi'
		Icon_3 icon = 'hoodie-female_mono.dmi'
		Icon_4 icon = 'hoodie-femmale_mono.dmi'
		Icon_5 icon = 'hoodie-male_mono.dmi'
		Icon_6 icon = 'jacketsuit-female_mono.dmi'
		Icon_7 icon = 'jacketsuit-femmale_mono.dmi'
		Icon_8 icon = 'jacketsuit-male_mono.dmi'
		Icon_9 icon = 'jackettrench-female-femmale_mono.dmi'
		Icon_10 icon = 'jackettrench-female_mono.dmi'
		Icon_11 icon = 'jackettrench-male_mono.dmi'
		Icon_12 icon = 'longsleeve-female_mono.dmi'
		Icon_13 icon = 'longsleeve-femmale_mono.dmi'
		Icon_14 icon = 'longsleeve-male_mono.dmi'
		Icon_15 icon = 'longsleevevneck-female_mono.dmi'
		Icon_16 icon = 'longsleevevneck-femmale_mono.dmi'
		Icon_17 icon = 'longsleevevneck-male_mono.dmi'
		Icon_18 icon = 'sweater-female_mono.dmi'
		Icon_19 icon = 'sweater-femmale_mono.dmi'
		Icon_20 icon = 'sweater-male_mono.dmi'
		Icon_21 icon = 'tanktop-female_mono.dmi'
		Icon_22 icon = 'tanktop-male-femmale_mono.dmi'
		Icon_23 icon = 'tanktop-male_mono.dmi'
		Icon_24 icon = 'tshirt-female_mono.dmi'
		Icon_25 icon = 'tshirt-femmale_mono.dmi'
		Icon_26 icon = 'tshirt-male_mono.dmi'
		Icon_27 icon = 'tuniclongsleeve-female_mono.dmi'
		Icon_28 icon = 'tuniclongsleeve-femmale_mono.dmi'
		Icon_29 icon = 'tuniclongsleeve-male_mono.dmi'
		Icon_30 icon = 'tunicmidsleeve-female_mono.dmi'
		Icon_31 icon = 'tunicmidsleeve-femmale_mono.dmi'
		Icon_32 icon = 'tunicmidsleeve-male_mono.dmi'
		Icon_33 icon = 'tunictank-female_mono.dmi'
		Icon_34 icon = 'tunictank-femmale_mono.dmi'
		Icon_35 icon = 'tunictank-male_mono.dmi'
		Icon_36 icon = 'turtleneck-female_mono.dmi'
		Icon_37 icon = 'turtleneck-femmale_mono.dmi'
		Icon_38 icon = 'turtleneck-male_mono.dmi'
		Icon_39 icon = 'vestclosed-female_mono.dmi'
		Icon_40 icon = 'vestclosed-male-femmale_mono.dmi'
		Icon_41 icon = 'vestclosed-male_mono.dmi'
		Icon_42 icon = 'vestopen-female_mono.dmi'
		Icon_43 icon = 'vestopen-male-femmale_mono.dmi'
		Icon_44 icon = 'vestopen-male_mono.dmi'
		Icon_45 icon = 'baggypants-female-femmale_mono.dmi'
		Icon_46 icon = 'baggypants-male_mono.dmi'
		Icon_47 icon = 'bballshorts-female-femmale_mono.dmi'
		Icon_48 icon = 'bballshorts-female_mono.dmi'
		Icon_49 icon = 'bballshorts-male_mono.dmi'
		Icon_50 icon = 'pants-female-femmale_mono.dmi'
		Icon_51 icon = 'pants-female_mono.dmi'
		Icon_52 icon = 'pants-male_mono.dmi'
		Icon_53 icon = 'shortshorts-female-femmale_mono.dmi'
		Icon_54 icon = 'shortshorts-female_mono.dmi'
		Icon_55 icon = 'skirtlong-female-femmale_mono.dmi'
		Icon_56 icon = 'skirtlong-female_mono.dmi'
		Icon_57 icon = 'skirtshort-female-femmale_mono.dmi'
		Icon_58 icon = 'skirtshort-female_mono.dmi'
		Icon_59 icon = 'shoes_mono.dmi'
		Icon_60 icon = 'glasses_mono.dmi'
		Icon_61 icon = 'headband-long_mono.dmi'
		Icon_62 icon = 'headband_mono.dmi'
		Icon_63 icon = 'sunglasses_mono.dmi'
		Icon_64 icon = 'cape_mono.dmi'
		Icon_65 icon = 'cape_under_mono.dmi'
		Icon_66 icon = 'scarf_mono.dmi'
		Icon_67 icon = 'Gaja Neck Mantle.dmi'
		Icon_68 icon = 'Gaja Cloak.dmi'
		Icon_69 icon = 'Gaja Furs.dmi'
		Icon_70 icon = 'Gaja Mask.dmi'




	AlignWearable
		Unobtainable=1
		verb/Toggle_Hat()
			set src in usr
			if(src.IsHat)
				src.IsHat=0
				usr << "[src] has been labelled as <FONT COLOR='RED'>NOT A HAT.</font color>"
			else
				src.IsHat=1
				usr << "[src] has been labelled as <font color='green'>A HAT.</font color>"
		Align_1 icon='Eyes.dmi'


obj
	clothes_grid_visual
		var/wearable_path
		New(obj/Items/Wearables/w)
			icon = w.icon
			name = w.name
			wearable_path = w.type

		Click()
			..()
			var/obj/Items/Wearables/w = new wearable_path
			var/Color=input(usr,"Choose color") as color|null
			if(Color) w.icon+=Color
			usr.contents += w

mob/proc/CheckWeightsTraining()
	var/obj/Items/WeightedClothing/w=EquippedWeights()
	if(w)
		var ready = world.realtime
		if(ready > w.InternalTimer) ready = 1
		else ready = 0
		src << "You've been wearing weights since [time2text(w.InternalTimer - Day(2), "MMM DD hh:mm")]. Your weight training is<b>[ready ? null : " not"] complete![ready ? " Unequip them at 75% health or below to gain their benefits!" : null]"

obj/Items/WeightedClothing//we are now a DBZ rip ... or is it pokemon?
	Unobtainable=1
	Unwieldy=1
	TechType="Forge"
	SubType="Weighted Clothing"
	Cost=10
	desc="Weights restrict your power until removed!  When they are removed, the trainee gains great speed and power for a duration."
	var/Plated//Has plating benefits and gives stronger boonsxz
	var/PlatedHealth=50
	Weights
		icon='MachoBrace.dmi'
		Unobtainable=0
		verb/Apply_Plating()
			set category=null
			set src in usr
			if(!("Advanced Plating" in usr.knowledgeTracker.learnedKnowledge))
				usr << "You don't know how to add plating to things!"
				return
			if(src.suffix=="*Equipped*")
				usr << "Take off the armor if you're going to fiddle with it!"
				return
			if(src.Plated)
				usr << "[src] already has plating applied to it!"
				return
			var/PCost=(glob.progress.EconomyCost*0.5)
			var/Choice=alert(usr, "Do you want to apply refractive and ceramic plating to your weights?  This will apply the effects of both types of plating as well as make the weights much heavier!  It costs [Commas(PCost)] to apply.  Do you want to do this?", "Apply Plating", "No", "Yes")
			if(Choice=="No")
				return
			if(!usr.HasMoney(PCost))
				usr << "You don't have enough money to fund the plating!"
				return
			src.Plated=1
			src.UpdatesDescription=1
			OMsg(usr, "[usr] has applied plating reinforcement to their [src]!")
			usr.TakeMoney(PCost)
		proc/Update_Description()
			desc="Weights restrict your power until removed!  When they are removed, the trainee gains great speed and power for a duration.<br>"
			desc+="This set of weights has been reinforced with plating!<br><br>"
			desc+="<b>Durability:</b> [src.PlatedHealth/50*100]%"
		Examined(mob/user)
			if(user && (src in user))
				usr.CheckWeightsTraining()



obj/Items/Plating
	TechType="RepairAndConversion"
	SubType="Advanced Plating"
	Unobtainable=1
	Cost=2
	var/PlatedHealth=50

	//i dont have icons my dude
	Ceramic_Plating
		Unobtainable=0
		desc="Ceramic plating soaks up wound damage for the user, but it has limited durability!"
		UpdatesDescription=1
		proc/Update_Description()
			desc="Ceramic plating soaks up wound damage for the user, but it has limited durability!<br><br>"
			desc+="<b>Durability:</b> [src.PlatedHealth/50*100]%"

	Refractive_Plating
		Unobtainable=0
		desc="Refractive plating is designed to reflect projectile attacks easily, but it is heavy and makes it harder to dodge melee strikes."

obj/Items/BlastShielding
	TechType="MilitaryTechnology"
	SubType="Blast Shielding"
	Cost=5
	Blast_Shield
		Unobtainable=0
		icon='Blast_Shield.dmi'
		desc="A heavy-duty alloy shield meant to provide additional protection from explosions and other burst type attacks!"

obj/Items/Armor
	Health=10
	//TrueLegend//blah
	//Class//blah
	//ShatterCounter//durability
	//ShatterMax
	//ShatterTier//it breaks down when ur hit
	//Broken//is it bork?
	//Ascended//git gud
	//InnatelyAscended//just in case
	//Element
	var/Conjured=0
	Unobtainable=1
	UpdatesDescription=1
	Repairable=1
	TechType="Forge"
	SubType="Armor"
	Mobile_Armor
		name="Armored Vest"
		Class="Light"
		DamageEffectiveness=0.25
		AccuracyEffectiveness=0.95
		SpeedEffectiveness=0.85
		ShatterCounter=200
		ShatterMax=200
		icon='ArmorLight-White.dmi'
		Unobtainable=0
		Cost=0.3
	Balanced_Armor
		name="Standard Armor"
		Class="Medium"
		DamageEffectiveness=0.5
		AccuracyEffectiveness=0.9
		SpeedEffectiveness=0.8
		ShatterCounter=300
		ShatterMax=300
		icon='ArmorBalanced-White.dmi'
		Unobtainable=0
		Cost=0.4
	Plated_Armor
		name="Plated Armor"
		Class="Heavy"
		DamageEffectiveness=0.75
		AccuracyEffectiveness=0.8
		SpeedEffectiveness=0.6
		ShatterCounter=400
		ShatterMax=400
		icon='ArmorBulky-Black.dmi'
		Unobtainable=0
		Cost=0.5
	New()
		..()
		switch(src.Class)
			if("Light")
				src.icon=pick('ArmorLight-White.dmi','ArmorLight-Black.dmi')
			if("Medium")
				src.icon=pick('ArmorBalanced-White.dmi','ArmorBalanced-Black.dmi')
			if("Heavy")
				src.icon=pick('ArmorBulky-White.dmi','ArmorBulky-Black.dmi')
		spawn()src.Update_Description()

	proc/Update_Description()
		desc="<b>[name]</b><br>\
		<br>"
		desc+="Class: [Class]<br>"
		if(Destructable)
			desc+="Durability: [(round(ShatterCounter/src.ShatterMax,0.01)*100)]%<br>"
		else
			desc+="Durability: Limitless<br>"
		if(Element)
			desc+="Elemental Infusion: [Element]<br>"
		if(Conversions)
			desc+="Upgrade Type: [Conversions]"
		desc+="<br>Armors deflect damage at the cost of reducing accuracy and increasing delays.<br>"

obj/Items/Sword
	Health=10
	Unobtainable=1
	var/Conjured=0
	var/SpiritStrike
	var/SwordIconSelected=0
	var/ImprovedStat
	var/ProjectionBlade=0//Dissolves on drop
	var/MagicSword=0//Sword is treated as a staff.
	var/ScissorBlade=0
	var/WeaponBreaker=0
	var/Shearing=0//shears stuff
	var/ElementallyInfused
	var/SpiritSword=0
	var/CalmAnger=0
	var/SweepingStrike
	var/BulletKill=0
	var/Extend=0

	// New Vars //
	var/Steady = 0
	// End New Vars //


	var/HitSparkIcon
	var/HitSparkX
	var/HitSparkY
	var/HitSparkSize=1
	var/Purity //waifu swords
	var/ManaGeneration=0
	var/iconAlt=null
	var/iconAltX=0
	var/iconAltY=0
	var/ClassAlt=null
	var/noHistory = TRUE
	icon_state="Inventory"
	TechType="Forge"
	UpdatesDescription=1
	Repairable=1
	Wooden
		name="Training Sword"
		Unobtainable=0
		icon='Bokken.dmi'
		DamageEffectiveness=1
		AccuracyEffectiveness=1
		SpeedEffectiveness=1
		ShatterCounter=200
		ShatterMax=200
		HitSparkIcon='Hit Effect.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitSparkSize=1
		Cost=0.05
		Repairable=1
		Class="Wooden"
		TechType="BasicTechnology"
		SubType=null
		Legendary
			LegendaryItem = 1
			TechType=null
			SubType="Weapons"
			Unobtainable = 1
			Ascended = 5
			ShatterCounter = 600
			ShatterMax = 600
			WeaponSoul
				Destructable = 0
				Saga = "Weapon Soul"

	Legendary
		Ascended = 5
		LegendaryItem = 1
		TechType=null
		Unobtainable = 1
		ShatterCounter=100
		ShatterMax=100
		AlienBlade
			name="Alien Blade"
			icon='Bokken.dmi'
			DamageEffectiveness=1
			AccuracyEffectiveness=1
			HitSparkIcon='Hit Effect.dmi'
			HitSparkSize=1



	Light
		name="Bastard Sword"
		Unobtainable=0
		icon='LightSword.dmi'
		DamageEffectiveness=1.025
		AccuracyEffectiveness=0.9
		SpeedEffectiveness=1.25
		HitSparkSize=0.8
		ShatterCounter=300
		ShatterMax=300
		Cost=0.3
		Class="Light"
		SubType="Weapons"
		unsheatheIcon = 'KATANA SILVER.dmi'
		unsheatheOffsetX = -16
		unsheatheOffsetY = -16
		Legendary
			LegendaryItem=1
			Unobtainable=1
			Ascended=5
			ShatterCounter=700
			ShatterMax=700
			Yukianesa
				name="Yukianesa"
				icon='Yukianesa.dmi'
				pixel_x=-16
				pixel_y=-16
				NoSaga=1
				CalmAnger=1
				MagicSword=1
				Element="Water"
				unsheatheIcon = 'Yukianesa.dmi'
				passives = list("CalmAnger" = 1, "MagicSword" = 1, "ManaGeneration" = 3, "AngerThreshold" = 1.5)
				ManaGeneration=3
				Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Grimoire/OverDrive/Frost_End", "/obj/Skills/AutoHit/FrostBite", "/obj/Skills/Projectile/Sword/TougaHyoujin", "/obj/Skills/Queue/KokujinYukikaze")


	Medium
		name="Longsword"
		Unobtainable=0
		icon='MediumSword.dmi'
		DamageEffectiveness=1.05
		AccuracyEffectiveness=0.875
		SpeedEffectiveness=1
		ShatterCounter=400
		ShatterMax=400
		Cost=0.4
		Class="Medium"
		SubType="Weapons"
		unsheatheIcon = 'Kagata.dmi'
		unsheatheOffsetX = -16
		unsheatheOffsetY = -16
		Legendary
			LegendaryItem=1
			Unobtainable=1
			Ascended=5
			ShatterCounter=800
			ShatterMax=800

			Soul_Eater
				icon='Soul_Eater.dmi'
				name="Soul Eater"
				pixel_x=-16
				pixel_y=-16
				Techniques=list("/obj/Skills/Queue/Darkness_Blast","/obj/Skills/Queue/Heart_Slayer","/obj/Skills/Queue/Riku_Soul_Render")
				verb/ChooseForm()
					set category="Other"
					var/check = 0
					var/S = input(usr,"Choose the form of your Soul Eater", "Form") in list("Shield","Sword","Staff")
					switch(S)
						if("Sword")
							if(check!=0)
								passives = list("SpiritSword" = 0, "SpiritStrike" = 0,"CallousedHands" = 0)
							view(10,src) << "[src]'s weapon transforms in to a Sword!"
							passives = list("SpiritSword" = 0.5)
							check += 1

						if("Shield")
							if(check!=0)
								passives = list("SpiritSword" = 0, "SpiritStrike" = 0,"CallousedHands" = 0)
							view(10,src) << "[src]'s weapon transforms in to a shield!"
							passives = list("CallousedHands" = 0.5)
							check += 1



						if("Staff")
							if(check!=0)
								passives = list("SpiritSword" = 0, "SpiritStrike" = 0,"CallousedHands" = 0)
							view(10,src) << "[src]'s weapon transforms in to a Staff!"
							passives = list("SpiritStrike" = 1)
							check += 1

			WeaponSoul
				Destructable = 0
				Saga="Weapon Soul"
				pixel_x=0
				pixel_y=0

	Heavy
		name="Greatsword"
		Unobtainable=0
		icon='Sheath Taco In Sword.dmi'
		DamageEffectiveness=1.1
		AccuracyEffectiveness=0.8
		SpeedEffectiveness=0.8
		HitSparkSize=1.2
		ShatterCounter=500
		ShatterMax=500
		Cost=0.5
		Class="Heavy"
		SubType="Weapons"
		unsheatheIcon = 'Taco Blade.dmi'
		unsheatheOffsetX = -32
		unsheatheOffsetY = -32
		sheatheIcon = 'Sheath Taco Empty.dmi'
		org_icon = 'Sheath Taco In Sword.dmi'
		removeSheathedOnUnSheathe = FALSE
		Legendary
			LegendaryItem=1
			Unobtainable=1
			Ascended=5
			ShatterCounter=1000
			ShatterMax=1000

			Ookami
				name="Ookami"
				icon='Ookami.dmi'
				pixel_x=-32
				pixel_y=-32
				NoSaga=1
				passives = list("CalmAnger" = 1,"MagicSword" = 1, "Extend" = 1, "BulletKill" = 1, "ManaGeneration" = 3, "AngerThreshold" = 1.5)
				CalmAnger=1
				MagicSword=1
				Extend=1
				BulletKill=1
				ManaGeneration=3
				Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Grimoire/OverDrive/Fierce_God", "/obj/Skills/Buffs/SlotlessBuffs/Grimoire/Slaying_God", "/obj/Skills/Projectile/Sword/KokujinShippu", "/obj/Skills/Queue/KokujinYukikaze")

			WeaponSoul
				Destructable = 0
				Saga="Weapon Soul"
				pixel_x=0
				pixel_y=0

				Spear_of_War // "Green Dragon Crescent Blade" / Guan Yu
					pixel_x = -16
					pixel_y = -16
					name = "Spear of War"
					icon = 'GreenDragonCrescentBlade_NoTrain.dmi'
					passives = list("SweepingStrike" = 1)
					SweepingStrike = 1
					TierTechniques=list(null, null, null, null, "/obj/Skills/AutoHit/War_God_Descent", null)

				Sword_of_the_Moon//Moonlight Greatsword
					pixel_x	=	-16
					pixel_y	=	-16
					name	=	"Sword of the Moon"
					icon	=	'MLGS.dmi'
					TierTechniques=list(null, null, null, null, null, "/obj/Skills/Projectile/Wisdom_Form_Blast", null, null)


	desc="Weapons alter the effects of melee combat and have their own advantages and disadvantages."
	New()
		..()
		spawn()src.Update_Description()
	Click()
		Update_Description()
		..()
	proc/Update_Description()
		desc="<b>[name]</b><br>\
		<br>"
		if(name=="Keyblade"&&Class=="Wooden")
			desc+="Class: Starting<br>"
		else
			desc+="Class: [Class]<br>"
		if(Destructable)
			desc+="Durability: [(round(src.ShatterCounter/src.ShatterMax,0.01)*100)]%<br>"
		else
			desc+="Durability: Limitless<br>"
		if(Ascended||InnatelyAscended)
			var/info = "Rarity: "
			var/A=min(Ascended+InnatelyAscended, 6)
			switch(A)
				if(1)
					info+="Uncommon [A]<br>"
				if(2)
					info+="Rare [A]<br>"
				if(3)
					info+="Very Rare [A]<br>"
				if(4)
					info+="Epic [A]<br>"
				if(5)
					info+="Legendary [A]<br>"
				if(6)
					info+="Mythical [A]<br>"
			desc+=info
		if(Element)
			desc+="Elemental Infusion: [Element]<br>"
		if(Conversions)
			desc+="Upgrade Type: [Conversions]"
		desc+="<br>Weapons alter the effects of melee combat and have their own advantages and disadvantages.<br>"

	verb/UseDefaultSwordIcon()
		set src in usr
		switch(src.Class)
			if("Wooden")
				src.icon='Bokken.dmi'
			if("Light")
				src.icon='LightSword.dmi'
			if("Medium")
				src.icon='MediumSword.dmi'
			if("Heavy")
				src.icon='HeavySword.dmi'

obj/Items/Symbiotic
	Destructable=0
	Unobtainable=1
	LegendaryItem=1
	icon_state="Inventory"

	Shroud_of_Martin

	Potara_Earrings
		Right_Earring
			icon='Potara Earrings - Right.dmi'
			Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Divine_Fusion")
		Left_Earring
			icon='Potara Earrings - Left.dmi'
			Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Divine_Fusion")

	Saint_Cloth
		Unwieldy=1
		var
			ReturnX=0
			ReturnY=0
			ReturnZ=0
		Bronze_Cloth
			Saga="Cosmo"
			icon='Pandora_Box.dmi'
			Pegasus_Cloth

			Dragon_Cloth

			Cygnus_Cloth

			Andromeda_Cloth

			Phoenix_Cloth

			Unicorn_Cloth
				T
		Bronze_Cloth_V2
			Saga="Cosmo"
			icon='Pandora_Box.dmi'
			Pegasus_Cloth

			Dragon_Cloth

			Cygnus_Cloth

			Andromeda_Cloth

			Phoenix_Cloth

		Gold_Cloth
			icon='Golden_Pandora_Box.dmi'
			Aries_Cloth

			Gemini_Cloth

			Cancer_Cloth

			Leo_Cloth

			Virgo_Cloth

			Libra_Cloth

			Scorpio_Cloth

			Capricorn_Cloth

			Aquarius_Cloth

			Pisces_Cloth


	Kamui
		Unwieldy=1
		var/wornInform = FALSE
		KamuiSenketsu
			icon='senketsu.dmi'
			name="Senketsu"
			var/wornByJunketsu = FALSE
			Techniques=list("/obj/Skills/Buffs/ActiveBuffs/Kamui/Kamui_Senketsu")

		KamuiJunketsu
			icon='junketsu.dmi'
			name="Junketsu"
			var/wornBySenketsu = FALSE
			Techniques=list("/obj/Skills/Buffs/ActiveBuffs/Kamui/Kamui_Junketsu")

		Shinra_Koketsu
			icon = 'shinrakoketsu.dmi'
			pixel_x = -48
			pixel_y = -48
			Techniques = list("/obj/Skills/Buffs/ActiveBuffs/Kamui/Shinra_Koketsu")

/mob/proc/UsingLightSaber()
	var/list/lightSaberBuffs = list("Great Lightsaber", "Lightsaber", "Crossguard Lightsaber", \
	"Shoto Lightsaber", "Double Lightsaber")
	for(var/x in lightSaberBuffs)
		if(SlotlessBuffs[x])
			return TRUE
	return FALSE


obj/Items/proc/AlignEquip(mob/A, dontUnEquip = FALSE)
	var/placement=FLOAT_LAYER-3
	if(src.LayerPriority)
		placement-=src.LayerPriority
	if(istype(src,/obj/Items/Wearables))
		if(src.IsHat)
			placement=FLOAT_LAYER-1
	if(suffix&&(A==src.loc))
		if(istype(src, /obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin))
			var/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin/s = src
			if(!s.putAway(A))
				return
		if(!dontUnEquip)
			if(istype(src, /obj/Items/Sword))
				var/obj/Items/Sword/sord = src
				if(Augmented)
					for(var/obj/Skills/Buffs/x in Techniques)
						if(x.Using || A.CheckSlotless(x.BuffName))
							A << "You can't remove [src] while you have [x.BuffName] active!"
							return
				for(var/obj/Skills/s in A)
					for(var/obj/Skills/x in Techniques)
						if(x == s)
							A.DeleteSkill(x, FALSE)
				if(!A.UsingLightSaber() && (suffix == "*Equipped*" || "*Equipped (Second)*" || "*Equipped (Third)*"))
					if(A.equippedSword == src)
						A.equippedSword = null
					suffix = null
				else if(!sord.Conjured && name != "Keyblade")
					if(A.equippedSword == src)
						A.equippedSword = null
					suffix = null
				else if(sord.Conjured)
					if(A.equippedSword == src)
						A.equippedSword = null
					suffix = null
					del sord


			else
				if(istype(src, /obj/Items/Armor))
					A.equippedArmor = null
				suffix=null
		if(src.EquipIcon)
			var/image/im=image(icon=src.EquipIcon, pixel_x=src.pixel_x, pixel_y=src.pixel_y, layer=placement)
			A.overlays-=im
		else
			var/image/im=image(icon=src.icon, pixel_x=src.pixel_x, pixel_y=src.pixel_y, layer=placement)
			if(istype(src, /obj/Items/Sword)||istype(src, /obj/Items/Armor)||istype(src, /obj/Items/Enchantment/Staff))
				var/image/im2=image(icon=src.icon, pixel_x=src.pixel_x, pixel_y=src.pixel_y, layer=placement)
				im2.transform*=3
				im2.appearance_flags+=512
				if(A.ArmamentGlow && !istype(src, /obj/Items/Armor))
					im.filters += A.ArmamentGlow
					im2.filters += A.ArmamentGlow
				A.overlays-=im2
			A.overlays-=im

	else
		if(A==src.loc)
			if(istype(src, /obj/Items/Sword))
				if(istype(src, /obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin))
					var/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin/s = src
					if(!A.dainsleifDrawn)
						var/confirm = input(A, "Are you sure you want to draw Dainsleif?") in list("Yes", "No")
						if(confirm == "No") return
						s.drawDainsleif(A)
					spawn(-1) s.dainsleifDrain(A)
				if(A.NeedsSecondSword() && A.EquippedSword() && !A.EquippedSecondSword())
					var/found = 0
					for(var/obj/Items/Sword/s in A)
						if(s.suffix == "*Equipped (Second)*")
							found = 1
							break
					if(!found)
						if(Techniques.len>0)
							for(var/obj/Skills/x in Techniques) // they should be skill objects
								A.AddSkill(x)
								if(istype(x, /obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear))
									x.verbs -= list(/obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear/verb/Augmented_Gear)
									x.verbs += new /obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear/verb/Augmented_Gear(x, x?:BuffName)
								if(istype(x, /obj/Skills/Buffs/SlotlessBuffs/Posture))
									x.verbs -= list(/obj/Skills/Buffs/SlotlessBuffs/Posture/verb/Posture)
									x.verbs += new /obj/Skills/Buffs/SlotlessBuffs/Posture/verb/Posture(x, x?:BuffName)
						suffix = "*Equipped (Second)*"
				else if(A.NeedsThirdSword() && A.EquippedSword() && !A.EquippedThirdSword())
					var/found = 0
					for(var/obj/Items/Sword/s in A)
						if(s.suffix == "*Equipped (Third)*")
							found = 1
							break
					if(!found)
						if(Techniques.len>0)
							for(var/obj/Skills/x in Techniques) // they should be skill objects
								A.AddSkill(x)
								if(istype(x, /obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear))
									x.verbs -= list(/obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear/verb/Augmented_Gear)
									x.verbs += new /obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear/verb/Augmented_Gear(x, x?:BuffName)
								if(istype(x, /obj/Skills/Buffs/SlotlessBuffs/Posture))
									x.verbs -= list(/obj/Skills/Buffs/SlotlessBuffs/Posture/verb/Posture)
									x.verbs += new /obj/Skills/Buffs/SlotlessBuffs/Posture/verb/Posture(x, x?:BuffName)
						suffix = "*Equipped (Third)*"
				else if(!A.equippedSword)
					A.equippedSword = src
					suffix = "*Equipped*"
				else
					return 1
			else
				if(istype(src, /obj/Items/Armor))
					A.equippedArmor = src

				// TODO: replace this whole damn proc with 'onEquip()' calls for items. holy shit just clean up the whole equip code
				if(istype(src, /obj/Items/Symbiotic/Kamui/KamuiSenketsu))
					var/obj/Items/Symbiotic/Kamui/KamuiSenketsu/KS = src
					if(A.Saga=="Kamui" && A.KamuiType == "Junketsu")
						KS.wornByJunketsu = TRUE
				if(istype(src, /obj/Items/Symbiotic/Kamui/KamuiJunketsu))
					var/obj/Items/Symbiotic/Kamui/KamuiJunketsu/KJ = src
					if(A.Saga=="Kamui" && A.KamuiType == "Senketsu" && A.SagaLevel >= 4 && !KJ.wornBySenketsu)
						KJ.wornBySenketsu = TRUE
						A << "A bit of your blood seems to infuse into Junketsu..."
						src.Techniques += list("/obj/Skills/Buffs/SpecialBuffs/Kamui_Senpu", "/obj/Skills/Buffs/SpecialBuffs/Kamui_Senpu_Zanken")
					if(A.Saga == "Kamui" && A.KamuiType == "Junketsu" && KJ.wornBySenketsu && !KJ.wornInform)
						A << "The remanents of the Senketsu wearer's blood have awoken something new in your Kamui!"
						A << "Kamui Senpu & Kamui Senpu Zanken beckon to your imperial will!"
						KJ.wornInform = TRUE

				suffix="*Equipped*"
		else if(istype(src,/obj/Items/Gear/Mobile_Suit))
			src.suffix="*Equipped*"
		if(src.EquipIcon)
			var/image/im=image(icon=src.EquipIcon, pixel_x=src.pixel_x, pixel_y=src.pixel_y, layer=placement)
			A.overlays+=im
		else
			var/image/im=image(icon=src.icon, pixel_x=src.pixel_x, pixel_y=src.pixel_y, layer=placement)
			if(istype(src, /obj/Items/Sword) || istype(src, /obj/Items/Enchantment/Staff))
				if(A.ArmamentGlow)
					im.filters += A.ArmamentGlow
			if(A.CheckActive("Mobile Suit")&&(istype(src, /obj/Items/Sword)||istype(src, /obj/Items/Armor)||istype(src, /obj/Items/Enchantment/Staff)))
				if(src:Conjured)
					im.transform*=3
					im.appearance_flags+=512
			A.overlays+=im
	if(src.UnderlayIcon)
		var/image/im=image(icon=src.UnderlayIcon, pixel_x=src.UnderlayX, pixel_y=src.UnderlayY)
		if(src.suffix=="*Equipped*")
			A.underlays+=im
		else
			A.underlays-=im
	return 1


obj/Items/proc/ObjectUse(var/mob/Players/User=usr)
	var/Looted=0
	if(locate(/obj/Seal, src))
		for(var/obj/Seal/S in src)
			if(User.ckey!=S.Creator)
				usr << "This item has been sealed!  You must break the seal before you can use it."
				return


	if(!(src in User))
		if(ismob(src.loc))
			if(src.loc:KO)
				Looted=1




	if(istype(src, /obj/Items/Cursed_Gear))
		var/obj/Items/Cursed_Gear/ag=src
		if(ag.Bound)
			if(Looted)
				User<<"[src] cannot be taken away!"
				return
		else
			if(!Looted)
				switch(alert(usr, "Are you sure you want to don [ag] willingly? It could be dangerous.", "Don Augmented Gear", "No", "Hell No", "Yes"))
					if("Yes")
						ag.Bound=1
						usr.NoSoul=1
						OMsg(usr, "[ag] worms its way inside [usr]'s body...")
						usr << "You feel the wretched grip of nihilism..."
						if(ag.Augment)
							var/obj/Skills/Buffs/b=text2path(ag.Augment)
							usr.AddSkill(new b)
	if(src.suffix=="*Equipped*"&&src.PermEquip)
		if(istype(src,/obj/Items/Enchantment/Magic_Crest)&&Looted)
			var/mob/Players/OldLoc=src.loc
			src:Transplant_Crest()
			usr.Grid("Loot", Lootee=OldLoc)
			return
		else
			User << "[src] cannot be unequipped!"
			return

	if((src in User)||Looted||istype(src,/obj/Items/Gear/Mobile_Suit))
		if(Looted)
			User=src.loc
		if(src.suffix!="*Equipped*"&&Looted)
			goto Steal

		if(src.Unwieldy)
			if(User.icon_state != "Meditate"||User.KO)
				if(!src.suffix)
					User << "You must be meditating to do this."
					return
			User.Tension=0

		if(istype(src,/obj/Items/Wearables))
			var/obj/Items/W=src
			if(W.Augmented)
				for(var/obj/Skills/Buffs/x in W.Techniques)
					if(x.Using || User.CheckSlotless(x.BuffName))
						User << "You can't remove [src] while you have [x.BuffName] active!"
						return
			W.AlignEquip(User)

		if(istype(src,/obj/Items/Enchantment/Arcane_Mask))
			var/obj/Items/W=src
			W.AlignEquip(User)
		if(istype(src,/obj/Items/Enchantment/Tome))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Magic"))
				return
			var/obj/Items/Enchantment/Tome/T=User.EquippedTome()
			if(suffix=="*Equipped*")
				if(length(T.Spells)>0)
					for(var/obj/Skills/spell in T.Spells)
						for(var/obj/Skills/ownerSpells in User)
							if(ownerSpells.type == spell.type)
								if(ownerSpells.Temporary)
									User.contents-=ownerSpells
									del ownerSpells
			else
				if(T && T != src)
					return
				T = src
				if(length(T.Spells)>0)
					for(var/obj/Skills/spell in T.Spells)
						var/found = 0
						for(var/obj/Skills/ownerSpells in User)
							if(ownerSpells.type == spell.type)
								found = 1
								break
						if(!found)
							var/obj/Skills/s = copyatom(spell)
							s.Temporary = TRUE
							s.Copyable = FALSE
							User.AddSkill(s)

			if(T)
				if(T!=src)
					User << "You already have a tome equipped!"
					return
			else
				for(var/obj/Items/Gear/g in User)
					if(g.NoSaga || istype(g, /obj/Items/Gear/Prosthetic_Limb))
						continue
					else if(g.suffix=="*Equipped*")
						User << "You cannot equip a tome while you have gear(s) equipped."
						return
				if(src.Password)
					var/PassCheck=input(User, "Enter the password to access this secure knowledge.", "Tome Security") as text
					if(PassCheck!=src.Password)
						User << "Incorrect, you can't access the tome with that password."
						return
			src.AlignEquip(User)

		if(istype(src,/obj/Items/Enchantment/Magic_Crest))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Magic"))
				return
			var/obj/Items/Enchantment/Magic_Crest/MC=User.EquippedCrest()
			if(MC)
				if(MC!=src)
					User << "You already have a Magic Crest equipped!"
					return
			var/obj/Items/W=src
			W.AlignEquip(User)
			if(src.suffix=="*Equipped*")
				if(src:Parasite)
					User.ModifyPrime=-1
					User.ModifyLate=-1
				if(src:Spells.len>0)
					for(var/x=1, x<=src:Spells.len, x++)
						var/obj/Skills/Tech=src:Spells[x]
						var/obj/Skills/o=new Tech.type
						if(!locate(o, User))
							if(!o.Copyable&&User.Saga)
								continue
							o.CrestGranted=1
							User.AddSkill(o)
			else
				for(var/obj/Skills/s in User)
					if(s.CrestGranted)
						User.contents-=s

		if(istype(src,/obj/Items/Enchantment/Flying_Device))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Magic"))
				return
			var/obj/Items/Enchantment/Flying_Device/FD=User.EquippedFlyingDevice()
			if(FD)
				if(FD!=src)
					User << "You already have a magical vehicle equipped!"
					return
			else
				FD = User.EquippedSurfingDevice()
				if(FD)
					User << "You can't use a magical vehicle while you have a surfboard equipped!"
					return

			if(!src.suffix)
				for(var/mob/Player/AI/a in view(15, User))
					if(a.WoundIntent || a.Lethal)
						User << "You cannot use a magical vehicle in the presence of hostiles!"
						return
				if(User.Health<75*(1-User.HealthCut))
					User << "You cannot use a magical vehicle while below [75*(1-User.HealthCut)] health!"
					return
			var/obj/Items/Enchantment/Flying_Device/W=src
			if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Skating, User))
				User.AddSkill(new /obj/Skills/Buffs/SlotlessBuffs/Skating)
			W.AlignEquip(User)
			User.icon_state=W.CustomState
			if(src.suffix)
				for(var/obj/Skills/Buffs/SlotlessBuffs/Skating/s in User)
					s.Trigger(User,1)
			else
				for(var/obj/Skills/Buffs/SlotlessBuffs/Skating/s in User)
					s.Trigger(User,1)
					del s
		if(istype(src,/obj/Items/Enchantment/Surfing_Device))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Magic"))
				return
			var/obj/Items/Enchantment/Surfing_Device/FD=User.EquippedSurfingDevice()
			if(FD)
				if(FD!=src)
					User << "You already have a magical vehicle equipped!"
					return
			else
				FD = User.EquippedFlyingDevice()
				if(FD)
					User << "You can't use a surfing device while you have a skateboard equipped!"
					return


			if(!src.suffix)
				for(var/mob/Player/AI/a in view(15, User))
					if(a.WoundIntent || a.Lethal)
						User << "You cannot use a magical vehicle in the presence of hostiles!"
						return
				if(User.Health<75*(1-User.HealthCut))
					User << "You cannot use a magical vehicle while below [75*(1-User.HealthCut)] health!"
					return
			var/obj/Items/Enchantment/Surfing_Device/W=src
			if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Surfing, User))
				User.AddSkill(new /obj/Skills/Buffs/SlotlessBuffs/Surfing)
			W.AlignEquip(User)
			User.icon_state=W.CustomState
			if(src.suffix)
				for(var/obj/Skills/Buffs/SlotlessBuffs/Surfing/s in User)
					s.Trigger(User,1)
			else
				for(var/obj/Skills/Buffs/SlotlessBuffs/Surfing/s in User)
					s.Trigger(User,1)
					del s
		if(istype(src,/obj/Items/Enchantment/Staff))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Staff"))
				return
			var/obj/Items/Enchantment/Staff/staf=User.EquippedStaff()
			var/obj/Items/Sword/sord=User.EquippedSword()
			if(staf)
				if(staf!=src)
					User << "You already have a staff equipped."
					return
			if(src:Broken)
				User << "[src] is broken currently and can't be used."
				return
			if(sord)
				if(!User.ArcaneBladework&&!User.isRace(DEMON))
					User << "You can't use a sword and a staff at the same time!"
					return
			if(User.StanceBuff)
				if(User.StanceBuff.NeedsStaff||User.StanceBuff.MakesStaff||User.NeedSpellFocii(User.StanceBuff))
					User << "You can't remove your staff with [User.StanceBuff] active!"
					return
				if(User.StanceBuff.NoStaff&&User.NotUsingBattleMage())
					User << "You can't use a staff with [User.StanceBuff] active!"
					return
			if(User.StyleBuff)
				if(User.StyleBuff.NeedsStaff||User.StyleBuff.MakesStaff||User.NeedSpellFocii(User.StyleBuff))
					User << "You can't remove your staff with [User.StyleBuff] active!"
					return
				if(User.StyleBuff.NoStaff&&User.NotUsingBattleMage())
					User << "You can't use a staff with [User.StyleBuff] active!"
					return
			if(User.ActiveBuff)
				if(User.ActiveBuff.NeedsStaff||User.ActiveBuff.MakesStaff||User.NeedSpellFocii(User.ActiveBuff))
					User << "You can't remove your Staff with [User.ActiveBuff] active!"
					return
				if(User.ActiveBuff.NoStaff&&User.NotUsingBattleMage())
					User << "You can't use a staff with [User.ActiveBuff] active!"
					return
			if(User.SpecialBuff)
				if(User.SpecialBuff.NeedsStaff||User.SpecialBuff.MakesStaff||User.NeedSpellFocii(User.SpecialBuff))
					User << "You can't remove your staff with [User.SpecialBuff] active!"
					return
				if(User.SpecialBuff.NoStaff&&User.NotUsingBattleMage())
					User << "You can't use a staff with [User.SpecialBuff] active!"
					return
			if(User.SlotlessBuffs.len>0)
				for(var/sb in User.SlotlessBuffs)
					var/obj/Skills/Buffs/b = User.SlotlessBuffs[sb]
					if(b)
						if(b.NeedsStaff||b.MakesStaff||User.NeedSpellFocii(b))
							User << "You can't remove your staff with [b] active!"
							return
						if(b.NoStaff&&User.NotUsingBattleMage())
							User << "You can't use a staff with [b] active!"
							return
			var/obj/Items/W=src
			if(W.suffix)
				if(W.Augmented)
					for(var/obj/Skills/Buffs/x in W.Techniques)
						if(x.Using || User.CheckSlotless(x.BuffName))
							User << "You can't remove [src] while you have [x.BuffName] active!"
							return
				if(User.ActiveBuff)
					for(var/x in src.Techniques)
						var/Path1=text2path("[User.ActiveBuff.type]")
						var/Path2=text2path("[x]")
						if(Path1==Path2)
							User << "You can't take off [src] while one of its techniques is being used!"
							return
				if(User.SpecialBuff)
					for(var/x in src.Techniques)
						var/Path1=text2path("[User.SpecialBuff.type]")
						var/Path2=text2path("[x]")
						if(Path1==Path2)
							User << "You can't take off [src] while one of its techniques is being used!"
							return
			W.AlignEquip(User)

		if(istype(src,/obj/Items/Sword))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Sword"))
				return
			var/obj/Items/Enchantment/Staff/staf=User.EquippedStaff()
			var/obj/Items/Sword/sord=User.EquippedSword()
			if(src.Broken && !User.passive_handler["Sword Master"])
				User << "[src] is broken; it can't be wielded right now."
				return
			if(sord)
				if(sord!=src)
					User << "You already have a sword equipped."
					return
			if(staf)
				if(!User.ArcaneBladework&&!User.isRace(DEMON))
					User << "You can't use a sword and a staff at the same time!"
					return
			if(User.StyleBuff)
				if(User.StyleBuff.NeedsSword||User.StyleBuff.MakesSword)
					User << "You can't remove your sword with [User.StyleBuff] active!"
					return
				if(User.StyleBuff.NoSword&&!User.HasSwordPunching())
					User << "You can't use a sword with [User.StyleBuff] active!"
					return
			if(User.ActiveBuff)
				if(User.ActiveBuff.NeedsSword||User.ActiveBuff.MakesSword)
					User << "You can't remove your sword with [User.ActiveBuff] active!"
					return
				if(User.ActiveBuff.NoSword&&!User.HasSwordPunching())
					User << "You can't use a sword with [User.ActiveBuff] active!"
					return
			if(User.SpecialBuff)
				if(User.SpecialBuff.NeedsSword||User.SpecialBuff.MakesSword)
					User << "You can't remove your sword with [User.SpecialBuff] active!"
					return
				if(User.SpecialBuff.NoSword&&!User.HasSwordPunching())
					User << "You can't use a sword with [User.SpecialBuff] active!"
					return
			if(User.SlotlessBuffs.len>0)
				for(var/sb in User.SlotlessBuffs)
					var/obj/Skills/Buffs/b = User.SlotlessBuffs[sb]
					if(b)
						if(b.NeedsSword||b.MakesSword)
							User << "You can't remove your sword with [b] active!"
							return
						if(b.NoSword&&!User.HasSwordPunching())
							User << "You can't use a sword with [b] active!"
							return
			var/obj/Items/W=src
			if(W.suffix)
				if(W.Augmented)
					for(var/obj/Skills/Buffs/x in W.Techniques)
						if(x.Using || User.CheckSlotless(x.BuffName))
							User << "You can't remove [src] while you have [x.BuffName] active!"
							return
				if(User.ActiveBuff)
					for(var/x in src.Techniques)
						var/Path1=text2path("[User.ActiveBuff.type]")
						var/Path2=text2path("[x]")
						if(Path1==Path2)
							User << "You can't take off [src] while one of its techniques is being used!"
							return
				if(User.SpecialBuff)
					for(var/x in src.Techniques)
						var/Path1=text2path("[User.SpecialBuff.type]")
						var/Path2=text2path("[x]")
						if(Path1==Path2)
							User << "You can't take off [src] while one of its techniques is being used!"
							return
			W.AlignEquip(User)

		if(istype(src,/obj/Items/Armor))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Armor"))
				return
			var/obj/Items/Armor/A=User.EquippedArmor()
			if(src:Broken)
				User << "[src] is broken; it can't be worn right now."
				return
			if(A)
				if(A!=src)
					User << "You already have an armor equipped."
					return
			var/obj/Items/W=src
			if(W.suffix)
				if(W.Augmented)
					for(var/obj/Skills/Buffs/x in W.Techniques)
						if(x.Using || User.CheckSlotless(x.BuffName))
							User << "You can't remove [src] while you have [x.BuffName] active!"
							return
				if(User.ActiveBuff)
					for(var/x in src.Techniques)
						var/Path1=text2path("[User.ActiveBuff.type]")
						var/Path2=text2path("[x]")
						if(Path1==Path2)
							User << "You can't take off [src] while one of its techniques is being used!"
							return
				if(User.SpecialBuff)
					for(var/x in src.Techniques)
						var/Path1=text2path("[User.SpecialBuff.type]")
						var/Path2=text2path("[x]")
						if(Path1==Path2)
							User << "You can't take off [src] while one of its techniques is being used!"
							return
			W.AlignEquip(User)

		if(istype(src,/obj/Items/Symbiotic))
			var/obj/Items/W=src
			if(W.suffix)
				if(User.ActiveBuff)
					for(var/x in src.Techniques)
						var/Path1=text2path("[User.ActiveBuff.type]")
						var/Path2=text2path("[x]")
						if(Path1==Path2)
							User << "You can't take off [src] while one of its techniques is being used!"
							return
				if(User.SpecialBuff)
					for(var/x in src.Techniques)
						var/Path1=text2path("[User.SpecialBuff.type]")
						var/Path2=text2path("[x]")
						if(Path1==Path2)
							User << "You can't take off [src] while one of its techniques is being used!"
							return
			W.AlignEquip(User)

		if(istype(src,/obj/Items))
			if(src.LegendaryItem)
				var/obj/Items/W=src
				if(W.suffix=="*Equipped*")
					if(W.Techniques.len>0)
						for(var/x=1, x<=W.Techniques.len, x++)
							var/path=text2path("[W.Techniques[x]]")
							var/obj/Skills/o = new path
							if(!locate(o, User))
								User.AddSkill(o)
								o.AssociatedLegend=src
					if(User.Saga==W.Saga)
						if(W.TierTechniques.len>0)
							for(var/x=1, x<=User.SagaLevel, x++)
								if(islist(W.TierTechniques[x]))
									for(var/y=1, y<=W.TierTechniques[x].len, y++)
										var/Tech=W.TierTechniques[x][y]
										if(Tech)
											var/path=text2path("[Tech]")
											var/obj/Skills/o =new path
											if(!locate(o, User))
												User.AddSkill(o)
												o.AssociatedLegend=src
								else
									var/Tech=W.TierTechniques[x]
									if(Tech)
										var/path=text2path("[Tech]")
										var/obj/Skills/o =new path
										if(!locate(o, User))
											User.AddSkill(o)
											o.AssociatedLegend=src
				else
					if(W.Techniques.len>0)
						if(!W.NoStrip)
							for(var/x=1, x<=W.Techniques.len, x++)
								var/path=text2path("[W.Techniques[x]]")
								for(var/obj/Skills/o in User)
									if(o.type == path)
										del o
					if(User.Saga==W.Saga)
						if(W.TierTechniques.len>0)
							for(var/x=1, x<=User.SagaLevel, x++)
								var/Tech=W.TierTechniques[x]
								if(Tech)
									var/path=text2path("[Tech]")
									for(var/obj/Skills/s in User)
										if(s.type==path)
											del s


		if(istype(src,/obj/Items/WeightedClothing))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Science"))
				return
			var/obj/Items/WeightedClothing/W=User.EquippedWeights()
			if(W)
				if(W!=src)
					User << "You already have weights applied to you!"
					return
				if(User.CheckSlotless("Unburdened")||User.CheckSlotless("Unrestrained"))
					User << "You are still experiencing the effects of previous training!"
					return
				if(W.suffix=="*Equipped*")
					if(User.Health<=75&&(W.InternalTimer<world.realtime)||User.CyberCancel)
						var/Choice=alert(User, "Are you ready to unleash the power gained from your weight training!? With your body used to the weights, they'll be abandoned.", "Weight Boost!", "No", "Yes")
						if(Choice=="Yes")
							W.AlignEquip(User)
							if(W.Plated)
								var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Unrestrained/U=new
								if(User.Saga=="Eight Gates")
									U.PowerInvisible+=0.10
									U.Godspeed*=2
									U.Pursuer*=2
									U.passives["Godspeed"] *= 2
									U.passives["Pursuer"] *= 2
									U.KenWave*=2
									U.DustWave*=2
								User.AddSkill(U)
							else
								var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Unburdened/U=new
								if(User.Saga=="Eight Gates")
									U.PowerInvisible+=0.10
									U.passives["Godspeed"] *= 2
									U.passives["Pursuer"] *= 2
									U.Godspeed*=2
									U.Pursuer*=2
									U.KenWave*=2
									U.DustWave*=2
								User.AddSkill(U)
							spawn(10)
								User.equippedWeights = null
								del W
					else
						var/Choice=alert(User, "You haven't completed your weight training, do you still want to take your weights off now...?", "Remove Weights", "No", "Yes")
						if(Choice=="Yes")
							W.AlignEquip(User)
							User.equippedWeights = null
							W.Unwieldy=1
			else
				if(User.CyberCancel)
					User << "Your converted body does not respond to training much."
					return
				var/Choice=alert(User, "Do you want to begin your weight training?  It will lower your power, but allow a burst of strength and mobility in a pinch!", "Weight Training", "No", "Yes")
				if(Choice=="Yes")
					var/obj/Items/WeightedClothing/Dis=src
					Dis.AlignEquip(User)
					User.equippedWeights = Dis
					Dis.InternalTimer=world.realtime+Day(2)
					Dis.Unwieldy=0

		if(istype(src, /obj/Items/Plating))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Science"))
				return
			var/obj/Items/Plating/P=User.EquippedPlating()
			var/obj/Items/WeightedClothing/W=User.EquippedWeights()
			if(W)
				if(W.Plated)
					User << "You're already getting plating effects from your plated weights!"
					return
			if(P)
				if(P!=src)
					User << "You're already wearing plating!"
					return
			var/obj/Items/Dis=src
			Dis.AlignEquip(User)


		if(istype(src,/obj/Items/BlastShielding))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Science"))
				return
			var/obj/Items/BlastShielding/B=User.EquippedShielding()
			if(B)
				if(B!=src)
					User << "You're already using additional shielding!"
					return
			var/obj/Items/Bla=src
			Bla.AlignEquip(User)


		if(istype(src,/obj/Items/Tech/Scouter))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Science"))
				return
			for(var/obj/Items/Tech/Scouter/S in User) if(S.suffix&&S!=src)
				User<<"You already have a Scouter equipped"
				return
			AlignEquip(User)


		if(istype(src,/obj/Items/Tech/SpaceMask))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Science"))
				return
			for(var/obj/Items/Tech/SpaceMask/S in User)
				if(S.suffix&&S!=src)
					User<<"You already have a Space Mask equipped"
					return
				if(S.Oxygen<=0)
					User<<"You can't equip a mask if it's out of Oxygen!"
					return
			AlignEquip(User)


		if(istype(src,/obj/Items/Gear/Mobile_Suit))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Science"))
				return
			if(!src.suffix)
				var/GearCount=0
				if(get_dist(User, src) > 1)
					return //Too far.

				if(User.EquippedTome())
					User << "You can't have any tomes equipped while inside a Mobile Suit!"
					return

				for(var/obj/Items/Gear/g in User)
					if(g==src)
						continue
					if(g.suffix)
						if(istype(g,/obj/Items/Gear/Prosthetic_Limb))
							continue
						else
							GearCount++
					if(GearCount>=1)
						User << "You can't have any weapons equipped while inside a Mobile Suit!"
						return
					if(User.InfinityModule)
						User << "The radiation of your core unit disrupts the electronics of the Suit!"
						return
				if(src.Password)
					var/Unlocked=0
					for(var/obj/Items/Tech/Door_Pass/L in User)
						if(L.Password==src.Password)
							Unlocked=1
					for(var/obj/Items/Tech/Digital_Key/C in User)
						if(C.Password==src.Password||C.Password2==src.Password||C.Password3==src.Password)
							Unlocked=1
					if(!Unlocked)
						var/Pass=input(User, "Please enter startup code.", "Enter Code") as text
						if(src.Password!=Pass)
							usr << "That is not the correct password."
							return
				User.loc=src.loc
				User.dir=src.dir
				sleep(5)
			var/obj/Items/W=src
			W.AlignEquip(User)
			if(W.suffix=="*Equipped*")
				W.loc=User
				if(W.Techniques.len>0)
					for(var/x=1, x<=W.Techniques.len, x++)
						var/path=text2path("[W.Techniques[x]]")
						var/obj/Skills/o = new path
						o.CooldownStatic=1
						if(!locate(o, User))
							User.AddSkill(o)
							o.AssociatedGear=src
						for(var/obj/Skills/Buffs/ActiveBuffs/Gear/Mobile_Suit/MS in User)
							MS.NameFake=W.name
							if(User.Saga=="King of Braves")
								MS.SpecialBuffLock=0
							else
								MS.SpecialBuffLock=1
							if(!User.BuffOn(MS))
								MS.init(W, User)
								MS.passives["PowerReplacement"] = usr.Potential+(7.5*src.Level)
								MS.PowerReplacement=usr.Potential+(7.5*src.Level)
								MS.Trigger(User)
				if(W.PermEquip)
					User<<"The suit merges with your body!"
			else
				for(var/obj/Skills/Buffs/ActiveBuffs/Gear/Mobile_Suit/MS in User)
					if(User.BuffOn(MS))
						MS.Trigger(User)
				if(W.Techniques.len>0)
					for(var/x=1, x<=W.Techniques.len, x++)
						var/path=text2path("[W.Techniques[x]]")
						for(var/obj/Skills/o in User)
							if(o.type == path)
								del o
				W.loc=User.loc

		if(istype(src,/obj/Items/Gear)&&!istype(src,/obj/Items/Gear/Prosthetic_Limb)&&!istype(src,/obj/Items/Gear/Mobile_Suit))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Science"))
				return
			if(User.is_arcane_beast)
				User << "A magical force surrounding your body repels the gear."
				return
			if(!src.suffix)
				if(!src.NoSaga)
					if(User.EquippedTome())
						User << "You cannot equip a tome and gears at the same time."
						return
				var/GearCount=0
				for(var/obj/Items/Gear/g in User)
					if(g==src)
						continue
					if(g.suffix)
						if(istype(g,/obj/Items/Gear/Prosthetic_Limb))
							continue
						if(istype(g,/obj/Items/Gear/Mobile_Suit))
							User << "You can't equip gear inside a mobile suit!"
							return
						else
							GearCount++
					if(GearCount>=3)
						User << "You have 3 gears equipped already!"
						return
			var/obj/Items/W=src
			if(W.suffix=="*Equipped*")
				if(User.ActiveBuff)
					for(var/x in src.Techniques)
						var/Path1=text2path("[User.ActiveBuff.type]")
						var/Path2=text2path("[x]")
						if(Path1==Path2)
							User << "You can't take off [src] while one of its techniques is being used!"
							return
				for(var/sb in User.SlotlessBuffs)
					var/obj/Skills/Buffs/SlotlessBuffs/Gear/G = User.SlotlessBuffs[sb]
					if(G)
						for(var/x in src.Techniques)
							var/Path1=text2path("[G.type]")
							var/Path2=text2path("[x]")
							if(Path1==Path2)
								User << "You can't take off [src] while one of its techniques is being used!"
								return
			W.AlignEquip(User)
			sleep(1)
			if(W.suffix=="*Equipped*")
				if(W.Techniques.len>0)
					for(var/x=1, x<=W.Techniques.len, x++)
						var/path=text2path("[W.Techniques[x]]")
						var/obj/Skills/o = new path
						o.CooldownStatic=1
						if(!locate(o, User))
							User.AddSkill(o)
							o.AssociatedGear=src
				if(W.PermEquip)
					User<<"The item merges with your body!"
			else
				if(W.Techniques.len>0)
					for(var/x=1, x<=W.Techniques.len, x++)
						var/path=text2path("[W.Techniques[x]]")
						for(var/obj/Skills/o in User)
							if(o.type == path)
								del o

		if(istype(src,/obj/Items/Gear/Prosthetic_Limb))
			if(User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Science"))
				return
			if(User.is_arcane_beast)
				User << "A magical force surrounding your body repels the prosthetic."
				return
			if(!src.suffix)
				var/LimbCount=User.GetProsthetics()
				if(LimbCount>=User.Maimed)
					User << "You have enough replacements equipped already!"
					return
			var/obj/Items/W=src
			if(W.suffix=="*Equipped*")
				if(User.ActiveBuff)
					for(var/x in src.Techniques)
						var/Path1=text2path("[User.ActiveBuff.type]")
						var/Path2=text2path("[x]")
						if(Path1==Path2)
							User << "You can't take off [src] while one of its techniques is being used!"
							return
				for(var/sb in User.SlotlessBuffs)
					var/obj/Skills/Buffs/SlotlessBuffs/Gear/G = User.SlotlessBuffs[sb]
					if(G)
						for(var/x in src.Techniques)
							var/Path1=text2path("[G.type]")
							var/Path2=text2path("[x]")
							if(Path1==Path2)
								User << "You can't take off [src] while one of its techniques is being used!"
								return
			W.AlignEquip(User)
			sleep(1)
			if(W.suffix=="*Equipped*")
				if(User.equippedProsthetics < 4)
					User.equippedProsthetics++
				if(W.Techniques.len>0)
					for(var/x=1, x<=W.Techniques.len, x++)
						var/path=text2path("[W.Techniques[x]]")
						var/obj/Skills/o = new path
						o.CooldownStatic=1
						if(!locate(o, User))
							User.AddSkill(o)
							o.AssociatedGear=src
				if(W.PermEquip)
					User<<"The item merges with your body!"
			else
				if(User.equippedProsthetics > 0)
					User.equippedProsthetics--
				if(W.Techniques.len>0)
					for(var/x=1, x<=W.Techniques.len, x++)
						var/path=text2path("[W.Techniques[x]]")
						for(var/obj/Skills/o in User)
							if(o.type == path)
								del o

		if(!LegendaryItem && Augmented)
			if(suffix=="*Equipped*")
				if(Techniques.len>0)
					for(var/obj/Skills/x in Techniques) // they should be skill objects
						User.AddSkill(x)
						if(istype(x, /obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear))
							x.verbs -= list(/obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear/verb/Augmented_Gear)
							x.verbs += new /obj/Skills/Buffs/SlotlessBuffs/Augmented_Gear/verb/Augmented_Gear(x, x?:BuffName)
						if(istype(x, /obj/Skills/Buffs/SlotlessBuffs/Posture))
							x.verbs -= list(/obj/Skills/Buffs/SlotlessBuffs/Posture/verb/Posture)
							x.verbs += new /obj/Skills/Buffs/SlotlessBuffs/Posture/verb/Posture(x, x?:BuffName)
			else
				for(var/obj/Skills/s in User)
					for(var/obj/Skills/x in Techniques)
						if(x == s)
							User.DeleteSkill(x, FALSE)

		if(passives)
			if(suffix=="*Equipped*")
				current_passives = passives
				User.passive_handler.increaseList(passives)
				if("RenameMana" in passives)
					User.ManaAmount = 0
			else if(suffix == null)
				User.passive_handler.decreaseList(current_passives)

		Steal
		if(Looted)
			var/mob/Players/OldLoc=src.loc
			OMsg(usr, "[usr] steals [src] from [OldLoc]!")
			usr.contents+=src
			usr.Grid("Loot", Lootee=OldLoc)



obj/Items/verb
	Bolt()
		set src in oview(1)
		set category=null
		if(src.Pickable||istype(src,/obj/Items/Gear/Mobile_Suit))
			if(!src.AllowBolt)
				usr<<"You can't bolt this down."
				return

		if(!src.Grabbable)
			var/signature = usr.droidFormerEnergysignature ? usr.droidFormerEnergysignature : usr.EnergySignature
			if(usr.ckey!=src.CreatorKey || ((src.CreatorSignature!=signature) && src.CreatorSignature))
				usr<<"This doesn't belong to you..."
				return
			src.Grabbable=1
			view(10,usr)<<"[usr] unbolted [src]"
		else
			for(var/obj/Items/i in loc) if(!i.Grabbable)
				usr<<"There is already something else bolted here."
				return
			var/signature = usr.droidFormerEnergysignature ? usr.droidFormerEnergysignature : usr.EnergySignature
			if(usr.ckey!=src.CreatorKey || ((src.CreatorSignature!=signature) && src.CreatorSignature))
				usr<<"This doesn't belong to you..."
				return
			src.Grabbable=0
			view(10,usr)<<"[usr] bolted [src]"

			if(istype(src,/obj/Items/Tech/Door))
				src.Password=input(usr,"Do you wish to install a password lock?") as text
				if(!src)
					return

mob/var/tmp/Customizing