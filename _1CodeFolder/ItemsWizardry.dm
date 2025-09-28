obj/var/EnchType

var/list/Enchantment_List=new
var/list/BasicEnchantment_List=new
var/list/Alchemy_List=new
var/list/ImprovedAlchemy_List=new
var/list/ToolEnchantment_List=new
var/list/ArmamentEnchantment_List=new
var/list/TomeCreation_List=new
var/list/CrestCreation_List=new
var/list/SummoningMagic_List=new
var/list/SealingMagic_List=new
var/list/SpaceMagic_List=new
var/list/TimeMagic_List=new

proc/Add_Enchantment()
	for(var/A in typesof(/obj/Items/Enchantment))
		var/obj/Items/B=new A
		B.suffix=null
		if(B.Cost) Enchantment_List+=B
		if(B.EnchType)
			if(B.EnchType=="BasicEnchantment")
				BasicEnchantment_List+=B
			if(B.EnchType=="Alchemy")
				Alchemy_List+=B
			if(B.EnchType=="ImprovedAlchemy")
				ImprovedAlchemy_List+=B
			if(B.EnchType=="ToolEnchantment")
				ToolEnchantment_List+=B
			if(B.EnchType=="ArmamentEnchantment")
				ArmamentEnchantment_List+=B
			if(B.EnchType=="TomeCreation")
				TomeCreation_List+=B
			if(B.EnchType=="CrestCreation")
				CrestCreation_List+=B
			if(B.EnchType=="SummoningMagic")
				SummoningMagic_List+=B
			if(B.EnchType=="SealingMagic")
				SealingMagic_List+=B
			if(B.EnchType=="SpaceMagic")
				SpaceMagic_List+=B
			if(B.EnchType=="TimeMagic")
				TimeMagic_List+=B

obj/Items/Gear
	Pure_Grimoire
		NoSaga=1
		PermEquip=1
		InfiniteUses=1
		Destructable=0
		Cost=0//doesn't appear in tech list
		icon='BLANK.dmi'
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Grimoire/Pure_Grimoire")
	Crimson_Grimoire
		NoSaga=1
		PermEquip=1
		InfiniteUses=1
		Destructable=0
		Cost=0//doesn't appear in tech list
		icon='CrimsonOrb.dmi'
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Grimoire/Crimson_Grimoire")
	Blood_Grimoire
		NoSaga=1
		InfiniteUses=1
		Destructable=0
		Cost=0//doesn't appear in tech list
		icon='Demon_Blood_Talismans.dmi'
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Grimoire/Blood_Grimoire")
	Prosthetic_Limb
		Blue_Grimoire
			icon='AzureArm.dmi'
			NoSaga=1
			PermEquip=1
			InfiniteUses=1
			Destructable=0
			Cost=0//doesn't appear in tech list
			Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Grimoire/Azure_Grimoire_True")
		Azure_Grimoire
			NoSaga=1
			PermEquip=1
			InfiniteUses=1
			Destructable=0
			Cost=0//doesn't appear in tech list
			Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Grimoire/Azure_Grimoire")


obj/Seal
	icon='Seal.dmi'
	var/Creator//ckey
	//Level = int*img*sealing
	var/XBind
	var/YBind
	var/ZPlaneBind//holds z plane
	Savable=1
	Destructable=0
	Attackable=0
	Grabbable=0
	Pickable=0
	Stealable=0
	Power_Seal//it seals power
	Command_Seal//does mad shit
		var/Orders


obj/Magic_Circle
	icon='Demon Gate.dmi'
	pixel_x=-96
	pixel_y=-96
	Pickable=0
	Grabbable=0
	Destructable=0
	layer=TURF_LAYER
	Savable=1
	var/Creator//holds creator ckey
	var/Locked=1//only cuts creator mana
	var/currentRitualID = null
/*	proc/ritualAnimation()
		
	verb/triggerRitual()
		if(!currentRitualID) return
		var/ritual/ritual
		for(var/ritual/r in ritualDatabase)
			if(r.name == currentRitualID)
				ritual = new r
		ritual.performRitual(src, usr)
		ritualAnimation()

	verb/setRitual()
		var/list/validRituals = list("Cancel")
		for(var/knowledge in usr.knowledgeTracker.learnedMagic)
			if(knowledge == "Introductory Ritual Magics")
				validRituals += list("Sword Enchanting")
		if(length(validRituals)==1) return
		var/chosenRitual = input(usr, "Pick a ritual.") in validRituals
		if(chosenRitual == "Cancel") return
		currentRitualID = chosenRitual*/

	verb/Toggle()
		set src in range(1, usr)
		if(usr.ckey==src.Creator)
			if(src.Locked)
				src.Locked=0
				usr << "You allow your magic circle to be used by others nearby!  But the benefits are reduced."
			else
				src.Locked=1
				usr << "You do not allow others to use your magic circle!"
		else
			usr << "This isn't your magical circle!"
	verb/Erase()
		set src in range(1, usr)
		if(usr.ckey==src.Creator)
			if(!locate(/obj/Skills/Utility/Create_Magic_Circle, usr))
				usr << "You erase the circle, ready to place it elsewhere."
				usr.AddSkill(new/obj/Skills/Utility/Create_Magic_Circle)
			del src

obj/Items/Enchantment

	Cauldron
		Cost=80
		Grabbable=0
		Destructable=1
		density=1
		EnchType="Alchemy"
		SubType="Any"
		name="Cauldron"
		icon='enchantmenticons.dmi'
		icon_state="Cauldron"
		desc="Cauldrons are used to brew potions and other acts of alchemy."
		Click()
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
				return
			if((src in Alchemy_List))
				..()
			else
				if(src.Using)
					usr << "This cauldron is already in use!"
					return
				src.Using=1
				var/list/Modes=list("Cancel", "Brew Potion", "Enhance Potion", "Transmute Lifeforce")
				if(("Distillation Process" in usr.knowledgeTracker.learnedMagic) && ("CrestCreation" in usr.knowledgeTracker.learnedMagic))
					Modes.Add("Transmute Philosopher Stone")
				var/Mode=input(usr, "What do you want to do with this cauldron?", "Cauldron") in Modes
				if(Mode=="Cancel")
					src.Using=0
					return
				else
					switch(Mode)
						if("Transmute Lifeforce")
							var/Choice
							var/list/Choices=list("Cancel", "Self")
							for(var/obj/Items/Enchantment/PhilosopherStone/PS in usr)
								if(!PS.ToggleUse) continue
								if(istype(PS, /obj/Items/Enchantment/PhilosopherStone/Magicite)) continue
								if(PS.CurrentCapacity<PS.MaxCapacity)
									Choices.Add(PS)
							if(Choices.len>2)
								Choice=input(usr, "What do you want to restore capacity to?", "Select Vessel") in Choices
							if(Choice=="Self"||Choices.len<=2)
								var/Amt=input(usr, "How much capacity do you want to restore through spirit transmutation?", "Restore Capacity (1-[round(usr.TotalCapacity)])") as num|null
								if(Amt>usr.TotalCapacity)
									Amt=usr.TotalCapacity
								if(Amt&&Amt>0)
									var/Cost=Amt*(glob.progress.EconomyCost/10)
									var/Confirm=alert(usr, "Restoring [round(Amt)] capacity will cost [Commas(round(Cost))] [glob.progress.MoneyName].  Do you want to spend it?", "Restore Capacity", "No", "Yes")
									if(Confirm=="No")
										src.Using=0
										return
									if(!usr.HasMoney(Cost))
										usr << "You don't have enough money to fill your capacity by [round(Amt)]! ([Commas(usr.GetMoney())] / [Commas(Cost)])"
										src.Using=0
										return
									usr.TakeMoney(Cost)
									usr.TotalCapacity-=Amt
									if(usr.TotalCapacity<0)
										usr.TotalCapacity=0
									usr << "You've restored your capacity by [Amt]!"
							else if(Choice=="Cancel")
								src.Using=0
								return
							else
								var/obj/Items/Enchantment/PhilosopherStone/PS=Choice
								var/Amt=input(usr, "How much capacity do you want to restore through spirit transmutation?", "Restore Capacity (1-[round(PS.MaxCapacity-PS.CurrentCapacity)])") as num|null
								if(Amt>(PS.MaxCapacity-PS.CurrentCapacity))
									Amt=(PS.MaxCapacity-PS.CurrentCapacity)
								if(Amt&&Amt>0)
									var/Cost=Amt*(glob.progress.EconomyCost*1.25)
									var/Confirm=alert(usr, "Restoring [round(Amt)] capacity will cost [Commas(round(Cost))] [glob.progress.MoneyName].  Do you want to spend it?", "Restore Capacity", "No", "Yes")
									if(Confirm=="No")
										src.Using=0
										return
									if(!usr.HasMoney(Cost))
										usr << "You don't have enough money to fill your vessel's capacity by [round(Amt)]! ([Commas(usr.GetMoney())] / [Commas(Cost)])"
										src.Using=0
										return
									usr.TakeMoney(Cost)
									PS.CurrentCapacity+=Amt
									if(PS.CurrentCapacity>PS.MaxCapacity)
										PS.CurrentCapacity=PS.MaxCapacity
									usr << "You've restored your vessel's capacity by [Amt]!"
							src.Using=0
							return
						if("Brew Potion")
							return
							var/list/Option=list("Cancel")
							var/Effect
							var/Confirm
							Option.Add(usr.PotionTypes)
							while(Confirm!="Yes")
								Effect=input(usr, "Brewing a potion.  Assign the first effect.", "Create Potion") in Option
								switch(Effect)
									if("Cancel")
										src.Using=0
										return
									if("Wild Herb")
										Confirm=alert(usr, "Wild Herbs allow you to customize a distinctive effect that the potion has on the drinker.  It does not take capacity to add to a potion.  Do you want to start your potion with Wild Herbs?", "Create Potion", "No", "Yes")
									if("Healing Herb")
										Confirm=alert(usr, "Healing Herbs grant the drinker a sudden spike of health.  Do you want to start your potion with Healing Herbs?", "Create Potion", "No", "Yes")
									if("Refreshment Herb")
										Confirm=alert(usr, "Refreshment Herbs grant the drinker a sudden spike of energy.  Do you want to start your potion with Refreshment Herbs?", "Create Potion", "No", "Yes")
									if("Magic Herb")
										Confirm=alert(usr, "Magic Herbs grant the drinker a sudden spike of mana.  Do you want to start your potion with Magic Herbs?", "Create Potion", "No", "Yes")
									if("Toxic Herb")
										Confirm=alert(usr, "Toxic Herbs predictably make a potion toxic.  This stimulates the drinker's metabolism and lets them drink another potion sooner.  It does not take capacity to add to a potion.  Do you want to start your potion with Toxic Herbs?", "Create Potion", "No", "Yes")
									if("Hallucinogen Herb")
										Confirm=alert(usr, "Hallucinogen Herbs induce a powerful drive in the drinker.  It causes their emotions to flare out, potentially making them a very dangerous force.  Do you want to start your potion with Hallucinogen Herbs?", "Create Potion", "No", "Yes")
									if("Philter Herb")
										Confirm=alert(usr, "Philter Herbs induce a strong feeling of infatuation towards the creator in the drinker. The instinctive attraction will be so strong, they'll instinctually hold back whenever they're in the position to inflict some harm upon the maker.  Do you want to start your potion with Philter Herbs?", "Create Potion", "No", "Yes")
									if("Stimulant Herb")
										Confirm=alert(usr, "Stimulant Herbs grant the drinker a form of liquid courage, increasing their damage.  They cost an extra 10 capacity.  Do you want to start your potion with Stimulant Herbs?", "Create Potion", "No", "Yes")
									if("Relaxant Herb")
										Confirm=alert(usr, "Relaxant Herbs grant the drinker a relaxed form which surreptitiously avoids the bulk of an attack.  They cost an extra 10 capacity.  Do you want to start your potion with Relaxant Herbs?", "Create Potion", "No", "Yes")
									if("Numbing Herb")
										Confirm=alert(usr, "Numbing Herbs grant the drinker the ability to endure pain.  They cost an extra 10 capacity.  Do you want to start your potion with Numbing Herbs?", "Create Potion", "No", "Yes")
									if("Mutagenic Herb")
										Confirm=alert(usr, "Mutagenic Herbs twist and change the physical form and capabilities of the drinker in major ways.  Do you want to start your potion with Mutagenic Herbs?", "Create Potion", "No", "Yes")
							var/Cost
							if(Effect in list("Stimulant Herb", "Relaxant Herb", "Numbing Herb", "Philter Herb"))
								Cost=10
							else if(Effect in list("Hallucinogen Herb", "Mutagenic Herb"))
								Cost=15
							else if(Effect in list("Wild Herb", "Toxic Herbs"))
								Cost=0
							else
								Cost=5
							if(usr.HasManaCapacity(Cost))
								var/obj/Items/Enchantment/Potion/p=new
								switch(Effect)
									if("Wild Herb")
										p.Gimmick=input(usr, "Write out the message that will be added to the drinker's description.", "Create Gimmick Potion") as message
										p.name="Magic Potion"
									if("Healing Herb")
										p.Heal=1
										p.name="Health Potion"
									if("Refreshment Herb")
										p.Energy=1
										p.name="Energy Potion"
									if("Magic Herb")
										p.Mana=1
										p.name="Mana Potion"
									if("Toxic Herb")
										p.Toxic=1
										p.name="Toxin"
									if("Hallucinogen Herb")
										p.Hallucinogen=1
										p.name="Hallucinogenic"
									if("Philter Herb")
										p.Sexy=1
										p.Password=usr.name
										p.name="Love Potion"
									if("Stimulant Herb")
										p.Searing=1
										p.name="Stimulant"
									if("Relaxant Herb")
										p.Flowy=1
										p.name="Relaxant"
									if("Numbing Herb")
										p.Hard=1
										p.name="Numbing Potion"
									if("Mutagenic Herb")
										p.Transform=alert(usr,"Should the form entered be weak or strong?","Polymorph","Weak","Strong")
										p.TransformIcon=input(usr, "What icon will the polymorphed being use?", "Polymorph") as icon
										p.name="Mutagen"
								usr.TakeManaCapacity(Cost)
								if(!(Effect in list("Wild Herb")))
									p.Slots--
								usr << "You've created \an [p]!"
								var/Custom=alert(usr, "Do you want to give [p] a custom name and drink message?", "Custom Potion", "No", "Yes")
								if(Custom=="Yes")
									var/Name=input(usr, "Input custom potion name.", "Potion Name") as text
									if(!(Name==""||!Name||Name==null))
										p.name=Name
									p.DrinkMessage=input(usr, "Input message for when potion is consumed.", "Potion Active") as text
									p.OffMessage=input(usr, "Input message for when potion wears off.", "Potion Off") as text
								usr.contents+=p
							else
								usr << "You don't have enough capacity to brew this potion!"
							src.Using=0
							return
						if("Enhance Potion")
							var/list/obj/Items/Enchantment/Potion/Pots=list("Cancel")
							for(var/obj/Items/Enchantment/Potion/p in usr)
								if(p.Slots>0)
									Pots.Add(p)
							if(Pots.len<2)
								usr << "You don't have any potions capable of having more added to them!"
								src.Using=0
								return
							var/obj/Items/Enchantment/Potion/Choice=input(usr, "What potion do you want to add further effects to?", "Add Effect") in Pots
							if(Choice=="Cancel")
								src.Using=0
								return
							var/list/Effects=list("Cancel")
							Effects.Add(usr.PotionTypes)
							var/MaxEffect=1
							if("Distillation Process" in usr.knowledgeTracker.learnedMagic)
								MaxEffect=2
							if(Choice.Gimmick)
								Effects.Remove("Wild Herb")
							if(Choice.Transform)
								Effects.Remove("Mutagenic Herb")
							if(Choice.Heal>=MaxEffect)
								Effects.Remove("Healing Herb")
							if(Choice.Energy>=MaxEffect)
								Effects.Remove("Refreshment Herb")
							if(Choice.Mana>=MaxEffect)
								Effects.Remove("Magic Herb")
							if(Choice.Toxic>=MaxEffect)
								Effects.Remove("Toxic Herb")
							if(Choice.Hallucinogen>=MaxEffect)
								Effects.Remove("Hallucinogen Herb")
							if(Choice.Searing>=MaxEffect)
								Effects.Remove("Stimulant Herb")
							if(Choice.Flowy>=MaxEffect)
								Effects.Remove("Relaxant Herb")
							if(Choice.Hard>=MaxEffect)
								Effects.Remove("Numbing Herb")
							if(Choice.Sexy>=MaxEffect)
								Effects.Remove("Philter Herb")

							var/Confirm
							var/Effect
							while(Confirm!="Yes")
								Effect=input(usr, "What effect do you want to add to your potion?", "Add Effect") in Effects
								switch(Effect)
									if("Cancel")
										src.Using=0
										return
									if("Wild Herb")
										Confirm=alert(usr, "Wild Herbs allow you to customize a distinctive effect that the potion has on the drinker.  They don't take capacity to add.  They don't fill a limited slot.  Do you want to add them to your potion?", "Add Effect", "No", "Yes")
									if("Healing Herb")
										Confirm=alert(usr, "Healing Herbs grant the drinker a sudden spike of health.  Do you want to add them to your potion?", "Add Effect", "No", "Yes")
									if("Refreshment Herb")
										Confirm=alert(usr, "Refreshment Herbs grant the drinker a sudden spike of energy.  Do you want to add them to your potion?", "Add Effect", "No", "Yes")
									if("Magic Herb")
										Confirm=alert(usr, "Magic Herbs grant the drinker a sudden spike of mana.  Do you want to add them to your potion?", "Add Effect", "No", "Yes")
									if("Toxic Herb")
										Confirm=alert(usr, "Toxic Herbs predictably make a potion toxic.  This stimulates the drinker's metabolism and lets them drink another potion sooner.  Do you want to add them to your potion?", "Add Effect", "No", "Yes")
									if("Hallucinogen Herb")
										Confirm=alert(usr, "Hallucinogen Herbs induce a powerful drive in the drinker.  It causes their emotions to flare out, potentially making them a very dangerous force. They cost an extra 15 capacity. Do you want to add them to your potion?", "Add Effect", "No", "Yes")
									if("Philter Herb")
										Confirm=alert(usr, "Philter Herbs induce a strong feeling of infatuation towards the creator in the drinker. The instinctive attraction will be so strong, they'll instinctually hold back whenever they're in the position to inflict some harm upon the maker.  They cost an extra 10 capacity. Do you want to add them to your potion?", "Add Effect", "No", "Yes")
									if("Stimulant Herb")
										Confirm=alert(usr, "Stimulant Herbs grant the drinker a form of liquid courage, increasing their damage.  They cost an extra 10 capacity.  Do you want to add them to your potion?", "Add Effect", "No", "Yes")
									if("Relaxant Herb")
										Confirm=alert(usr, "Relaxant Herbs grant the drinker a relaxed form which surreptitiously avoids the bulk of an attack.  They cost an extra 10 capacity.  Do you want to add them to your potion?", "Add Effect", "No", "Yes")
									if("Numbing Herb")
										Confirm=alert(usr, "Numbing Herbs grant the drinker the ability to endure pain.  They cost an extra 10 capacity.  Do you want to add them to your potion?", "Add Effect", "No", "Yes")
									if("Mutagenic Herb")
										Confirm=alert(usr, "Mutagenic Herbs twist and change the physical form and capabilities of the drinker in major ways.  They cost an extra 15 capacity.  Do you want to add them to your potion?", "Add Effect", "No", "Yes")
							var/Cost
							if(Effect in list("Stimulant Herb", "Relaxant Herb", "Numbing Herb", "Philter Herb"))
								Cost=10
							else if(Effect in list("Hallucinogen Herb", "Mutagenic Herb"))
								Cost=15
							else if(Effect in list("Wild Herb", "Toxic Herbs"))
								Cost=0
							else
								Cost=5
							if(Choice.Slots==1)
								Cost*=4
							else if(Choice.Slots==2)
								Cost*=2
							if(usr.HasManaCapacity(Cost))
								switch(Effect)
									if("Wild Herb")
										Choice.Gimmick=input(usr, "Write out the message that will be added to the drinker's description.", "Create Gimmick Potion") as message
										Choice.name="Augmented [Choice.name]"
									if("Healing Herb")
										Choice.Heal+=1
										Choice.name="Healing [Choice.name]"
									if("Refreshment Herb")
										Choice.Energy+=1
										Choice.name="Refreshing [Choice.name]"
									if("Magic Herb")
										Choice.Mana+=1
										Choice.name="Arcane [Choice.name]"
									if("Toxic Herb")
										Choice.Toxic+=1
										Choice.name="Toxic [Choice.name]"
									if("Hallucinogen Herb")
										Choice.Hallucinogen+=1
										Choice.name="Hallucinogenic [Choice.name]"
									if("Philter Herb")
										Choice.Sexy+=1
										Choice.Password=usr.name
										Choice.name="Ensnaring [Choice.name]"
									if("Stimulant Herb")
										Choice.Searing+=1
										Choice.name="Exciting [Choice.name]"
									if("Relaxant Herb")
										Choice.Flowy+=1
										Choice.name="Relaxing [Choice.name]"
									if("Numbing Herb")
										Choice.Hard+=1
										Choice.name="Numbing [Choice.name]"
									if("Mutagenic Herb")
										Choice.Transform=alert(usr,"Should the form entered be weak or strong?","Polymorph","Weak","Strong")
										Choice.TransformIcon=input(usr, "What icon will the polymorphed being use?", "Polymorph") as icon
										Choice.name="Polymorphic [Choice.name]"
								usr.TakeManaCapacity(Cost)
								usr << "You've modified your potion into \an [Choice]!"
								if(!(Effect in list("Wild Herb")))
									Choice.Slots--
									if(Choice.Slots<=0)
										usr << "[Choice] has been fully enchanted!"
							else
								usr << "You don't have enough capacity to add this effect!"
							src.Using=0
							return
						if("Transmute Philosopher Stone")
							var/Cost=(glob.progress.EconomyCost*100*(glob.progress.EconomyMana/100))
							var/Confirm=alert(usr, "Do you want to create an artificial Philosopher Stone?  This will cost [Commas(Cost)] resources!", "Create Artificial Philosopher Stone", "No", "Yes")
							if(Confirm=="Yes")
								if(usr.HasMoney(Cost))
									usr.TakeMoney(Cost)
									var/obj/Items/Enchantment/PhilosopherStone/Artificial/a=new
									a.SoulStrength=2
									usr.contents+=a
									usr << "You've created an artificial Philosopher Stone!"
								else
									usr << "You don't have enough money to make an artificial Philosopher Stone!  ([Commas(Cost)] / [Commas(usr.GetMoney())])"
							src.Using=0
							return
				src.Using=0
				return
	Potion
		icon='Magic Potion.dmi'
		var/Heal=0
		var/Energy=0
		var/Mana=0

		var/Toxic=0

		var/Hallucinogen=0
		var/Transform=0
		var/Searing=0
		var/Flowy=0
		var/Hard=0
		var/Sexy=0

		var/FoundHallucinogen=0
		var/FoundSearing=0
		var/FoundFlowy=0
		var/FoundHard=0
		var/FoundSexy=0


		var/TransformIcon

		var/Gimmick
		var/DrinkMessage
		var/OffMessage
		var/Slots=3

		Click()
			if(!(src in usr))
				return
			if(usr.KO)
				return
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
				return
			if(usr.PureRPMode)
				usr << "You cannot use potions while in RP Mode."
				return
			if(usr.CheckSlotless("Potion Power"))
				return
			if(usr.PotionCD)
				usr << "It's too soon to use a potion! (Wait [usr.PotionCD] seconds)"
				return
			if(usr.is_arcane_beast)
				usr << "You find that the potions effects are inert on you. However, your body does absorb the magical essence used to create it. The normally foul taste also is pleasant to you."
				var/mana_return = min(20, (Heal + Energy)*3 + (Mana*5) + (Hallucinogen + (Transform ? 1 : 0))*10 + (Searing + Flowy + Hard + Sexy)*7)
				if(mana_return)
					usr.TotalCapacity-=mana_return
					if(usr.TotalCapacity<0)
						usr.TotalCapacity=0
				del src
				return
			else
				var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Potion_Power/PP=new
				var/CD=600 // 1 min base cooldown
				var/WEAK_EFFECT_CD = 100
				var/MEDIUM_EFFECT_CD = 200
				var/STRONG_EFFECT_CD = 300
				if(src.Energy)
					PP.InstantAffect=1
					PP.EnergyHeal=src.Energy*10
					CD+=(src.Energy*WEAK_EFFECT_CD) // 10
				if(src.Mana)
					PP.InstantAffect=1
					PP.ManaHeal=src.Mana*10
					CD+=(src.Mana*STRONG_EFFECT_CD)
				if(src.Heal)
					PP.InstantAffect=1
					PP.StableHeal=1
					PP.HealthHeal=src.Heal*glob.POTIONHEAL
					CD+=(src.Heal*STRONG_EFFECT_CD)

				if(src.Searing)
					FoundSearing=1
					PP.passives["PureDamage"] =  src.Searing/50 * usr.Potential
					CD+=(src.Searing*MEDIUM_EFFECT_CD)
				if(src.Hard)
					FoundHard=1

					PP.passives["Hardening"] = clamp((src.Hard / 10) * usr.AlchemyUnlocked, 0.1, 5)
					CD+=(src.Hard*MEDIUM_EFFECT_CD)
				if(src.Hallucinogen)
					FoundHallucinogen=1
					PP.AutoAnger=1
					var/buff = 0.25 * src.Hallucinogen // 25%
					PP.AngerMult= 1 + buff
					PP.DefMult = 1 - buff
					PP.EndMult = 1 - buff
					PP.passives["PureReduction"] = 0 - Hallucinogen
					CD+=(src.Hallucinogen*STRONG_EFFECT_CD)
				if(src.Flowy)
					FoundFlowy=1
					PP.passives["Flow"] = src.Flowy
					CD+=(src.Flowy*MEDIUM_EFFECT_CD)

				if(src.Sexy)
					FoundSexy=1
					PP.Infatuated=src.Sexy
					CD+=(src.Sexy*90) // this doesn't do anything
				if(src.Transform)
					switch(src.Transform)
						if("Weak")
							CD+=STRONG_EFFECT_CD
						if("Strong")
							CD+=STRONG_EFFECT_CD

				if(src.Gimmick)
					if(usr.GimmickDesc)
						usr.GimmickDesc+="<br><br>[src.Gimmick]"
					else
						usr.GimmickDesc=src.Gimmick
					if(!usr.GimmickTimer)
						usr.GimmickTimer=RawHours(1)

				PP.TimerLimit=2

				if(src.Toxic)
					PP.InstantAffect=1
					PP.PoisonAffected=src.Toxic*50
					PP.TimerLimit*=(src.Toxic*2)
					CD/=(src.Toxic*2)

				if(FoundSearing||FoundFlowy||FoundHard||FoundHallucinogen||FoundSexy||src.Transform)
					var/Timer=0
					if(FoundSexy)
						Timer+=3
					if(FoundSearing||FoundHard)
						Timer+=2 // pure dmg or tanky
					if(FoundHallucinogen||FoundFlowy)
						Timer+=2
					if(src.Transform)
						switch(src.Transform)
							if("Weak")
								Timer+=2
							if("Strong")
								Timer+=2
					PP.TimerLimit *= 15 * Timer // basically they r all 1 min long
				if(PP.TimerLimit >2 && Heal )
					PP.HealthHeal /= PP.TimerLimit 
				if(PP.TimerLimit>5)
					PP.OffMessage="burns off the excess magical effects..."

				PP.PotionCD=CD
				PP.Password=src.Password

				if(src.Transform)
					PP.Transform=src.Transform
					PP.IconTransform=src.TransformIcon

				if(src.DrinkMessage)
					PP.ActiveMessage=src.DrinkMessage
				if(src.OffMessage)
					PP.OffMessage=src.OffMessage
				usr.AddSkill(PP)
				del src

	Tarot_Deck
		desc="Tarot decks change your stats with a pair of increases and decreases."
		icon='TarotDeck.dmi'
		Cost=60
		Health=1
		Destructable=1
		var/DeckPotency=1
		var/RemainingDraws=7
		Click()
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
				return
			if(src in ToolEnchantment_List || !(src in usr))
				..()
			else
				if(usr.TarotCooldown)
					if(world.realtime<usr.TarotCooldown)
						usr << "It's too soon to draw another card!"
						return
				if(src.Using)
					return
				src.Using=1
				var/Confirm=alert(usr, "Are you sure you want to draw a tarot card?  This will have a permanent effect!", "Tarot Deck", "No", "Yes")
				var/DeckDraw
				if(Confirm=="Yes")
					if(!usr.TarotFate)
						var/Roll=roll("1d56")
						RemainingDraws=max(0, RemainingDraws-1)
						switch(Roll)
							if(1)
								DeckDraw="Ace of Swords"
								usr.StrChaos+=0.1*src.DeckPotency
								usr.ForChaos-=0.1*src.DeckPotency
							if(2)
								DeckDraw="Three of Swords"
								usr.StrChaos+=0.1*src.DeckPotency
								usr.EndChaos-=0.1*src.DeckPotency
							if(3)
								DeckDraw="Five of Swords"
								usr.StrChaos+=0.1*src.DeckPotency
								usr.OffChaos-=0.1*src.DeckPotency
							if(4)
								DeckDraw="Seven of Swords"
								usr.StrChaos+=0.1*src.DeckPotency
								usr.DefChaos-=0.1*src.DeckPotency
							if(5)
								DeckDraw="Nine of Swords"
								usr.StrChaos+=0.1*src.DeckPotency
								usr.SpdChaos-=0.1*src.DeckPotency
							if(6)
								DeckDraw="Page of Swords"
								usr.StrChaos+=0.1*src.DeckPotency
								usr.RecovChaos-=0.1*src.DeckPotency
							if(7)
								DeckDraw="Queen of Swords"
								usr.StrChaos+=0.1*src.DeckPotency
								usr.RecovChaos-=0.1*src.DeckPotency
							if(8)
								DeckDraw="Ace of Wands"
								usr.ForChaos+=0.1*src.DeckPotency
								usr.StrChaos-=0.1*src.DeckPotency
							if(9)
								DeckDraw="Three of Wands"
								usr.ForChaos+=0.1*src.DeckPotency
								usr.EndChaos-=0.1*src.DeckPotency
							if(10)
								DeckDraw="Five of Wands"
								usr.ForChaos+=0.1*src.DeckPotency
								usr.OffChaos-=0.1*src.DeckPotency
							if(11)
								DeckDraw="Seven of Wands"
								usr.ForChaos+=0.1*src.DeckPotency
								usr.DefChaos-=0.1*src.DeckPotency
							if(12)
								DeckDraw="Nine of Wands"
								usr.ForChaos+=0.1*src.DeckPotency
								usr.SpdChaos-=0.1*src.DeckPotency
							if(13)
								DeckDraw="Page of Wands"
								usr.ForChaos+=0.1*src.DeckPotency
								usr.RecovChaos-=0.1*src.DeckPotency
							if(14)
								DeckDraw="Queen of Wands"
								usr.ForChaos+=0.1*src.DeckPotency
								usr.RecovChaos-=0.1*src.DeckPotency
							if(15)
								DeckDraw="Ace of Disks"
								usr.EndChaos+=0.1*src.DeckPotency
								usr.StrChaos-=0.1*src.DeckPotency
							if(16)
								DeckDraw="Three of Disks"
								usr.EndChaos+=0.1*src.DeckPotency
								usr.ForChaos-=0.1*src.DeckPotency
							if(17)
								DeckDraw="Five of Disks"
								usr.EndChaos+=0.1*src.DeckPotency
								usr.OffChaos-=0.1*src.DeckPotency
							if(18)
								DeckDraw="Seven of Disks"
								usr.EndChaos+=0.1*src.DeckPotency
								usr.DefChaos-=0.1*src.DeckPotency
							if(19)
								DeckDraw="Nine of Disks"
								usr.EndChaos+=0.1*src.DeckPotency
								usr.SpdChaos-=0.1*src.DeckPotency
							if(20)
								DeckDraw="Page of Disks"
								usr.EndChaos+=0.1*src.DeckPotency
								usr.RecovChaos-=0.1*src.DeckPotency
							if(21)
								DeckDraw="Queen of Disks"
								usr.EndChaos+=0.1*src.DeckPotency
								usr.RecovChaos-=0.1*src.DeckPotency
							if(22)
								DeckDraw="Two of Swords"
								usr.OffChaos+=0.1*src.DeckPotency
								usr.StrChaos-=0.1*src.DeckPotency
							if(23)
								DeckDraw="Four of Swords"
								usr.OffChaos+=0.1*src.DeckPotency
								usr.ForChaos-=0.1*src.DeckPotency
							if(24)
								DeckDraw="Six of Swords"
								usr.OffChaos+=0.1*src.DeckPotency
								usr.EndChaos-=0.1*src.DeckPotency
							if(25)
								DeckDraw="Eight of Swords"
								usr.OffChaos+=0.1*src.DeckPotency
								usr.DefChaos-=0.1*src.DeckPotency
							if(26)
								DeckDraw="Ten of Swords"
								usr.OffChaos+=0.1*src.DeckPotency
								usr.SpdChaos-=0.1*src.DeckPotency
							if(27)
								DeckDraw="Knight of Swords"
								usr.OffChaos+=0.1*src.DeckPotency
								usr.RecovChaos-=0.1*src.DeckPotency
							if(28)
								DeckDraw="King of Swords"
								usr.OffChaos+=0.1*src.DeckPotency
								usr.RecovChaos-=0.1*src.DeckPotency
							if(29)
								DeckDraw="Two of Wands"
								usr.DefChaos+=0.1*src.DeckPotency
								usr.StrChaos-=0.1*src.DeckPotency
							if(30)
								DeckDraw="Four of Wands"
								usr.DefChaos+=0.1*src.DeckPotency
								usr.ForChaos-=0.1*src.DeckPotency
							if(31)
								DeckDraw="Six of Wands"
								usr.DefChaos+=0.1*src.DeckPotency
								usr.EndChaos-=0.1*src.DeckPotency
							if(32)
								DeckDraw="Eight of Wands"
								usr.DefChaos+=0.1*src.DeckPotency
								usr.OffChaos-=0.1*src.DeckPotency
							if(33)
								DeckDraw="Ten of Wands"
								usr.DefChaos+=0.1*src.DeckPotency
								usr.SpdChaos-=0.1*src.DeckPotency
							if(34)
								DeckDraw="Knight of Wands"
								usr.OffChaos+=0.1*src.DeckPotency
								usr.RecovChaos-=0.1*src.DeckPotency
							if(35)
								DeckDraw="King of Wands"
								usr.OffChaos+=0.1*src.DeckPotency
								usr.RecovChaos-=0.1*src.DeckPotency
							if(36)
								DeckDraw="Two of Disks"
								usr.SpdChaos+=0.1*src.DeckPotency
								usr.StrChaos-=0.1*src.DeckPotency
							if(37)
								DeckDraw="Four of Disks"
								usr.SpdChaos+=0.1*src.DeckPotency
								usr.ForChaos-=0.1*src.DeckPotency
							if(38)
								DeckDraw="Six of Disks"
								usr.SpdChaos+=0.1*src.DeckPotency
								usr.EndChaos-=0.1*src.DeckPotency
							if(39)
								DeckDraw="Eight of Disks"
								usr.SpdChaos+=0.1*src.DeckPotency
								usr.OffChaos-=0.1*src.DeckPotency
							if(40)
								DeckDraw="Ten of Disks"
								usr.SpdChaos+=0.1*src.DeckPotency
								usr.DefChaos-=0.1*src.DeckPotency
							if(41)
								DeckDraw="Knight of Disks"
								usr.SpdChaos+=0.1*src.DeckPotency
								usr.RecovChaos-=0.1*src.DeckPotency
							if(42)
								DeckDraw="King of Disks"
								usr.SpdChaos+=0.1*src.DeckPotency
								usr.RecovChaos-=0.1*src.DeckPotency
							if(43)
								DeckDraw="Ace of Cups"
								usr.RecovChaos+=0.1*src.DeckPotency
								usr.StrChaos-=0.1*src.DeckPotency
							if(44)
								DeckDraw="Three of Cups"
								usr.RecovChaos+=0.1*src.DeckPotency
								usr.ForChaos-=0.1*src.DeckPotency
							if(45)
								DeckDraw="Five of Cups"
								usr.RecovChaos+=0.1*src.DeckPotency
								usr.EndChaos-=0.1*src.DeckPotency
							if(46)
								DeckDraw="Seven of Cups"
								usr.RecovChaos+=0.1*src.DeckPotency
								usr.OffChaos-=0.1*src.DeckPotency
							if(47)
								DeckDraw="Nine of Cups"
								usr.RecovChaos+=0.1*src.DeckPotency
								usr.DefChaos-=0.1*src.DeckPotency
							if(48)
								DeckDraw="Page of Cups"
								usr.RecovChaos+=0.1*src.DeckPotency
								usr.SpdChaos-=0.1*src.DeckPotency
							if(49)
								DeckDraw="Queen of Cups"
								usr.RecovChaos+=0.1*src.DeckPotency
								usr.RecovChaos-=0.1*src.DeckPotency
							if(50)
								DeckDraw="Two of Cups"
								usr.RecovChaos+=0.1*src.DeckPotency
								usr.StrChaos-=0.1*src.DeckPotency
							if(51)
								DeckDraw="Four of Cups"
								usr.RecovChaos+=0.1*src.DeckPotency
								usr.ForChaos-=0.1*src.DeckPotency
							if(52)
								DeckDraw="Six of Cups"
								usr.RecovChaos+=0.1*src.DeckPotency
								usr.EndChaos-=0.1*src.DeckPotency
							if(53)
								DeckDraw="Eight of Cups"
								usr.RecovChaos+=0.1*src.DeckPotency
								usr.OffChaos-=0.1*src.DeckPotency
							if(54)
								DeckDraw="Ten of Cups"
								usr.RecovChaos+=0.1*src.DeckPotency
								usr.DefChaos-=0.1*src.DeckPotency
							if(55)
								DeckDraw="Knight of Cups"
								usr.RecovChaos+=0.1*src.DeckPotency
								usr.SpdChaos-=0.1*src.DeckPotency
							if(56)
								DeckDraw="King of Cups"
								usr.RecovChaos+=0.1*src.DeckPotency
								usr.RecovChaos-=0.1*src.DeckPotency
					else
						DeckDraw=usr.TarotFate
					usr << "You draw the mystic card, aiming to learn your destiny..."
					usr.TarotCooldown=world.realtime+Day(1)
					OMsg(usr, "[usr] draws [DeckDraw] Arcana!")
				src.Using=0
				if(!RemainingDraws)
					usr << "The deck runs out of magical potency and bursts into mist!"
					del src

	Greater_Tarot_Deck
		desc="Well this isn't good at all."
		name="Deck of Chaos"
		icon='TarotDeckS.dmi'
		Cost=300
		Health=1
		Destructable=1
		Unobtainable=1
		var/DeckPotency=3
		var/RemainingDraws=22
		var/list/Cards=list("The Fool", "The Magician", "The High Priestess", "The Empress", "The Emperor", "The Hierophant", "The Lovers", "The Chariot", "Strength",\
		"The Hermit", "Wheel of Fortune", "Justice", "The Hanged Man", "Death", "Temperance", "The Devil", "The Tower", "The Star", "The Moon", "The Sun", "Judgment", "The World")
		Click()
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
				return
			if(src in ToolEnchantment_List)
				..()
			else
				if(usr.TarotFate)
					usr << "The cards are impossibly heavy. You cannot lift another."
					return
				if(src.Using)
					return
				src.Using=1
				var/Confirm=alert(usr, "Are you sure you want to draw a card...?", "You Could Die", "No", "Yes")
				var/DeckDraw
				if(Confirm=="Yes")
					if(!usr.TarotFate)
						var/Card=pick(Cards)
						RemainingDraws=max(0, RemainingDraws-1)
						switch(Card)
							if("The Fool")
								DeckDraw="The Fool"
								usr.TarotFate="The Fool"
								usr.PotentialRate*=2
							if("The Magician")
								DeckDraw="The Magician"
								usr.TarotFate="The Magician"
								usr.Intelligence+=1
							if("The High Priestess")
								DeckDraw="The High Priestess"
								usr.TarotFate="The High Priestess"
							if("The Empress")
								DeckDraw="The Empress"
								usr.TarotFate="The Empress"
							if("The Emperor")
								DeckDraw="The Emperor"
								usr.TarotFate="The Emperor"
							if("The Hierophant")
								DeckDraw="The Hierophant"
								usr.TarotFate="The Hierophant"
							if("The Lovers")
								DeckDraw="The Lovers"
								usr.TarotFate="The Lovers"
							if("The Chariot")
								DeckDraw="The Chariot"
								usr.TarotFate="The Chariot"
								usr.SpdMod*=2
							if("Strength")
								DeckDraw="Strength"
								usr.TarotFate="Strength"
								usr.StrMod*=2
							if("The Hermit")
								DeckDraw="The Hermit"
								usr.TarotFate="The Hermit"
							if("Wheel of Fortune")
								DeckDraw="Wheel of Fortune"
								usr.TarotFate="Wheel of Fortune"
								usr.StrMod*=pick(0.5, 0.75, 1, 1.25, 1.5, 1.75, 2)
								usr.ForMod*=pick(0.5, 0.75, 1, 1.25, 1.5, 1.75, 2)
								usr.EndMod*=pick(0.5, 0.75, 1, 1.25, 1.5, 1.75, 2)
								usr.SpdMod*=pick(0.5, 0.75, 1, 1.25, 1.5, 1.75, 2)
							if("Justice")
								DeckDraw="Justice"
								usr.TarotFate="Justice"
							if("The Hanged Man")
								DeckDraw="The Hanged Man"
								usr.TarotFate="The Hanged Man"
							if("Death")
								DeckDraw="Death"
								usr.TarotFate="Death"
								usr.NoDeath=1
							if("Temperance")
								DeckDraw="Temperance"
								usr.TarotFate="Temperance"
							if("The Devil")
								DeckDraw="The Devil"
								usr.TarotFate="The Devil"
							if("The Tower")
								DeckDraw="The Tower"
								usr.TarotFate="The Tower"
							if("The Star")
								DeckDraw="The Star"
								usr.TarotFate="The Star"
								usr.Maimed=0
								usr.EconomyMult+=4
							if("The Moon")
								DeckDraw="The Moon"
								usr.TarotFate="The Moon"
								usr.Imagination+=2
							if("The Sun")
								DeckDraw="The Sun"
								usr.TarotFate="The Sun"
							if("Judgment")
								DeckDraw="Judgment"
								usr.TarotFate="Judgment"
							if("The World")
								DeckDraw="The World"
								usr.TarotFate="The World"
					usr << "You draw the cursed card and learn your destiny..."
					OMsg(usr, "[usr] draws [DeckDraw] Arcana!")
					Cards.Remove(DeckDraw)
				src.Using=0
				if(!RemainingDraws)
					usr << "The deck runs out of magical potency and bursts into mist!"
					del src

	ArcanicOrb
		EnchType="ToolEnchantment"
		SubType="NOT IN"
		Cost=60
		icon='enchantmenticons.dmi'
		icon_state="ArcanOrb"
		desc="Used to spy using Arcanic Masks."
		var/Active=1

		var/list/LinkedMasks=list()

		verb/Toggle()
			set src in usr
			set name="Activate Orb"
			if(src.Password)
				var/Passcheck=input("This orb has an arcane signature.  Enter it to complete the activation.")as text
				if(Passcheck!=src.Password)
					usr << "Incorrect signature."
					return
			if(src.Active)
				src.Active=0
				usr<<"Orb toggled off."
			else
				src.Active=1
				usr<<"Orb toggled on."
		verb/SetPassword()
			set src in usr
			set name="Arcane Tuning"
			if(src.Password)
				usr << "This orb already has a signature."
				return
			src.Password=input("Enter the desired signature.")as text
			usr<<"The orb glows as you cast a tuning spell on it."
		verb/ViewEye()
			set src in usr
			set name="Arcane Spy"
			var/list/ValidEyes=list("Cancel")
			for(var/mob/Players/A in players)
				for(var/obj/Items/Enchantment/Arcane_Mask/B in A)
					if(B.LinkTag in src.LinkedMasks)
						if(B.suffix)
							ValidEyes+=A
			var/obj/pickeye=input("")in ValidEyes
			if(pickeye=="Cancel")
				usr.client.eye=usr
				usr.client.perspective=MOB_PERSPECTIVE
			else
				usr.client.eye=pickeye
				usr.client.perspective=EYE_PERSPECTIVE
		verb/SpeakEye()
			set src in usr
			set name="Arcane Speak"
			var/TextColor=usr.Text_Color
			var/list/ValidTongues=list("Cancel")
			for(var/mob/Players/A in players)
				for(var/obj/Items/Enchantment/Arcane_Mask/B in A)
					if(B.LinkTag in src.LinkedMasks)
						if(B.suffix)
							ValidTongues+=A
			var/mob/picktongue=input("")in ValidTongues
			if(picktongue!="Cancel")
				var/voiceselect=input("Use your voice, or the holder of the tongue's?")in list("Your Voice","Tongue Holder")
				var/texttosay=input("Say stuffs.")as text|null
				if(texttosay==null)
					return
				if(voiceselect=="Your Voice")
					for(var/mob/E in hearers(12,picktongue))
						if(E.Timestamp)
							E<<"<font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]<font color=[TextColor]>[picktongue][E.Controlz(picktongue)] says with the voice of [usr]: [html_encode(texttosay)]"
							Log(E.ChatLog(),"<font color=green>[picktongue]([picktongue.key]) says with the voice of [usr]: [html_encode(texttosay)]")
						else
							E<<"<font color=[TextColor]>[picktongue][E.Controlz(picktongue)] says with the voice of [usr]: [html_encode(texttosay)]"
							Log(E.ChatLog(),"<font color=green>[picktongue]([picktongue.key]) says with the voice of [usr]: [html_encode(texttosay)]")
				else
					TextColor=picktongue.Text_Color
					for(var/mob/E in hearers(12,picktongue))
						if(E.Timestamp)
							E<<"<font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]<font color=[TextColor]>[picktongue][E.Controlz(picktongue)] says: [html_encode(texttosay)]"
							Log(E.ChatLog(),"<font color=green>[picktongue]([picktongue.key]) says: [html_encode(texttosay)]")
						else
							E<<"<font color=[TextColor]>[picktongue][E.Controlz(picktongue)] says: [html_encode(texttosay)]"
							Log(E.ChatLog(),"<font color=green>[picktongue]([picktongue.key]) says: [html_encode(texttosay)]")
	Arcane_Mask
		EnchType="ToolEnchantment"
		SubType="NOT IN"
		Cost=40
		icon='BlankMask.dmi'
		desc="After being placed on another person, it allows someone with a linked arcane orb to look through their eyes, speak with their tongue, and hear what they hear."

		var/LinkTag
		var/Forced//can they remove it?

		Click()
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
				return
			if(src in ToolEnchantment_List && !(src in usr))
				..()
			else
				if(src.Forced)
					usr << "You can't remove a mask that was forced onto you!"
					return
				..()

		New()
			..()
			if(!src.LinkTag)

				Reroll

				src.LinkTag=rand(1,9999)

				for(var/obj/Items/Enchantment/Arcane_Mask/AM in world)
					if(AM==src)
						continue
					if(AM.LinkTag==src.LinkTag)
						goto Reroll
						break
		verb/Link_to_Orb()
			set category=null
			set src in usr
			var/obj/Items/Enchantment/ArcanicOrb/AO
			var/list/obj/Items/Enchantment/ArcanicOrb/OwnedOrbs=list("Cancel")
			for(var/obj/Items/Enchantment/ArcanicOrb/orbz in usr)
				if(!(src.LinkTag in orbz.LinkedMasks))
					OwnedOrbs.Add(orbz)
			AO=input(usr, "What orb do you want to link with this mask?", "Arcane Link") in OwnedOrbs
			if(AO=="Cancel")
				return
			AO.LinkedMasks.Add(src.LinkTag)
			usr << "[src] linked to [AO]!"
			return
		verb/Place_Mask()
			set category=null
			set src in usr
			var/mob/Players/Trg
			var/list/mob/Players/Peeps=list("Cancel")
			for(var/mob/Players/p in view(1, usr))
				if(p.Secret=="Heavenly Restriction" && p.secretDatum?:hasRestriction("Magic"))
					continue
				Peeps.Add(p)
			Trg=input(usr, "Who do you want to place this arcane mask on?", "Place Mask") in Peeps
			if(Trg.KO)
				src.Forced=1
				src.loc=Trg
				src.ObjectUse(Trg)
				OMsg(Trg, "[usr] forces a  plain mask onto [Trg]'s face ... it melds with their face and leaves rune etchings on [Trg]'s eyes!")
				return
			else
				var/Confirm=alert(Trg, "Do you want to allow [usr] to place an arcane mask on you?", "Place Mask", "No", "Yes")
				if(Confirm=="No")
					OMsg(Trg, "[Trg] refuses the mask!")
					return
				src.Forced=0
				src.loc=Trg
				src.ObjectUse(Trg)
				OMsg(Trg, "[usr] places a plain mask over [Trg]'s face ... it melds with their face and leaves rune etchings on [Trg]'s eyes!")
				return
	Flying_Device
		name = "Magical Skateboard"
		EnchType="ToolEnchantment"
		SubType="Magical Vehicles"
		icon='Skateboard.dmi'
		icon_state="Inventory"
		var/CustomState
		pixel_y=-4
		Unwieldy=1
		var/NoChange=1
		Cost=80
		Techniques = list("/obj/Skills/Buffs/SlotlessBuffs/Skating")
		desc="A device which, when active, allows you to skim across the land!"
		verb/Set_Flying_State()
			set category=null
			set src in usr
			src.CustomState=input(usr, "What icon state should your Magical Skateboard set you in?", "Set Flying State") as text|null
			usr << "Flying state for [src] set to [src.CustomState]."
	Surfing_Device
		name = "Magical Surfboard"
		EnchType="ToolEnchantment"
		SubType="Magical Vehicles"
		icon='Skateboard.dmi'
		icon_state="Inventory"
		var/CustomState
		pixel_y=-4
		Unwieldy=1
		var/NoChange=1
		Cost=80
		Techniques = list("/obj/Skills/Buffs/SlotlessBuffs/Surfing")
		desc="A device which, when active, allows you to skim across the water!"
		verb/Set_State()
			set category=null
			set src in usr
			src.CustomState=input(usr, "What icon state should your Magical Surfboard set you in?", "Set Flying State") as text|null
			usr << "Flying state for [src] set to [src.CustomState]."

	Tome111
		Cost=80
		Level=1
		Unwieldy=1
		var/PagesFilled=0
		icon='Tome.dmi'
		icon_state="Inventory"
		desc="A tome can hold a number of spells, reducing the cooldown and removing the mana cost for them."
		var/list/obj/Skills/Spells=list()
		verb/Scribe_Spell()
			set category=null
			set src in usr
			if(src.Using)
				return
			src.Using=1
			var/list/obj/Skills/MagicKnown=list("Cancel")
			for(var/obj/Skills/s in usr.contents)
				if(s.MagicNeeded&&s.ManaCost&&s.Copyable)
					var/NotFound=1
					for(var/obj/Skills/Known in src.Spells)
						if(s.type==Known.type)
							NotFound=0
							break
					if(NotFound)
						MagicKnown.Add(s)
			if(MagicKnown.len<2)
				usr << "You don't know any magic to be scribed to [src]!"
				src.Using=0
				return
			var/obj/Skills/Choice=input(usr, "What spell do you want to inscribe on your [src]?  This will make it cost less mana and take less time to cast again.", "Scribe [src]") in MagicKnown
			if(Choice=="Cancel")
				src.Using=0
				return
			if(src.Level<src.PagesFilled+Choice:Copyable)
				usr << "The tome lacks the capacity to fit this spell."
				src.Using=0
				return
			var/Cost=glob.progress.EconomyMana/4*Choice:Copyable
			if(usr.HasManaCapacity(Cost))
				usr.TakeManaCapacity(Cost)
				usr << "You've scribed [Choice] into your [src]!"
				var/obj/Skills/S=new Choice.type
				src.Spells.Add(S)
				src.PagesFilled+=S.Copyable
				src.Using=0
				return
			else
				usr << "You don't have enough capacity to scribe a spell into [src].  It takes [Commas(Cost)] capacity."
				src.Using=0
				return
			src.Using=0
			return
		verb/Manage_Contents()
			set category=null
			set src in usr
			if(src.Using)
				return
			src.Using=1
			var/list/Options=list("Cancel")
			if((usr.TomeCreationUnlocked+usr.CrestCreationUnlocked)*usr.Imagination*10>src.Level)
				Options.Add("Expand")
			if("Tome Cleansing" in usr.knowledgeTracker.learnedKnowledge)
				Options.Add("Cleanse")
			if("Tome Security" in usr.knowledgeTracker.learnedKnowledge)
				Options.Add("Secure")
			if("Tome Translation" in usr.knowledgeTracker.learnedKnowledge)
				Options.Add("Study")
			if("Tome Binding" in usr.knowledgeTracker.learnedKnowledge)
				Options.Add("Bind")
			if("Tome Excerpts" in usr.knowledgeTracker.learnedKnowledge)
				Options.Add("Take Excerpt")
			if(Options.len<2)
				usr << "You don't know how to interact further with [src]."
				src.Using=0
				return
			var/Mode=input(usr, "How do you wish to interact with [src]?", "[src] Enchantment") in Options
			if(Mode=="Cancel")
				src.Using=0
				return
			switch(Mode)
				if("Expand")
					var/MultiMake=input("How much spell level space do you wish to add?")as num|null
					if(MultiMake==null||MultiMake<=0)
						src.Using=0
						return
					var/MultiCost=glob.progress.EconomyMana/10*MultiMake
					if(usr.HasManaCapacity(MultiCost))
						usr.TakeManaCapacity(MultiCost)
						usr << "You expanded your [src]!"
						src.Level+=MultiMake
						if(MultiMake>1)
							usr<<"You added [MultiMake] spell levels."
					else
						usr<<"You don't have enough magic capacity! You need to give up [Commas(MultiCost)] capacity to add [MultiMake] spell levels."
						src.Using=0
						return
					src.Using=0
					return
				// if("Take Excerpt")
				// 	var/list/obj/Skills/Scribed=list("Cancel")
				// 	for(var/obj/Skills/S in src.Spells)
				// 		Scribed.Add(S)
				// 	if(Scribed.len<2)
				// 		usr << "There aren't any spells in [src] that you don't know!"
				// 		src.Using=0
				// 		return
				// 	var/Cost=global.EconomyMana/10
				// 	var/obj/Skills/Learn=input(usr, "What spell do you want to turn into an excerpt from [src]?", "Scribe Scroll") in Scribed
				// 	if(Learn=="Cancel")
				// 		src.Using=0
				// 		return
				// 	if(usr.HasManaCapacity(Cost*Learn.Copyable))
				// 		var/obj/Items/Enchantment/Scroll/sc = new
				// 		sc.StoredSpell=Learn.type
				// 		sc.StoredSpellLevel=Learn.Copyable
				// 		sc.name="Scroll of [Learn.name]"
				// 		usr.contents+=sc
				// 		src.Spells.Remove(Learn)
				// 		src.Level-=Learn.Copyable
				// 		src.PagesFilled-=Learn.Copyable
				// 		usr << "You've torn out a [sc] from [src]!"
				// 		usr.TakeManaCapacity(Cost*Learn.Copyable)
				// 		src.Using=0
				// 		if(src.Level<=0)
				// 			usr << "You've torn up the [src] beyond repair!"
				// 			del src
				// 		src.Using=0
				// 		return
				// 	else
				// 		usr << "You don't have enough capacity to take out a spell from [src].  It costs [Commas(Cost*Learn.Copyable)] capacity."
				// 		src.Using=0
					//	return
				if("Cleanse")
					if(!src.Spells||src.Spells.len<=0)
						usr << "[src] has no spells inscribed."
						src.Using=0
						return
					var/list/Delete=list("Cancel")
					for(var/obj/Skills/S in src.Spells)
						Delete.Add(S)
					var/Choice=input(usr, "What spell do you want to erase from [src]?", "Cleanse [src]") in Delete
					if(Choice=="Cancel")
						src.Using=0
						return
					src.Using=0
					src.Spells.Remove(Choice)
					usr << "[src] has been purged of the [Choice] spell!"
					return
				if("Secure")
					if(src.Password)
						var/PassCheck=input(usr, "[src] already has a password.  Enter it now if you wish to change it.", "Secure Tome") as text|null
						if(PassCheck)
							if(PassCheck==src.Password)
								src.Password=input(usr, "Correct.  Enter the new password you wish to secure this tome with.", "Secure Tome") as text|null
								src.Using=0
								return
							else
								usr << "Incorrect password."
								src.Using=0
								return
					else
						var/Cost=glob.progress.EconomyMana/4
						if(usr.HasManaCapacity(Cost))
							src.Password=input(usr, "Enter the password you wish to secure this tome with.", "Secure Tome") as text|null
							usr.TakeManaCapacity(Cost)
							usr << "[src] has now been secured with the password '[src.Password]'."
							src.Using=0
							return
						else
							usr << "You don't have enough capacity to cast the security spell.  It requires [Commas(Cost)] capacity."
							src.Using=0
							return
				if("Study")
					var/list/obj/Skills/Scribed=list("Cancel")
					for(var/obj/Skills/S in src.Spells)
						if(S.SignatureTechnique)
							continue
						if(!locate(S.type, usr))
							Scribed.Add(S)
					if(Scribed.len<2)
						usr << "There aren't any spells in [src] that you don't know!"
						src.Using=0
						return
					var/Cost=glob.progress.EconomyMana/4
					var/obj/Skills/Learn=input(usr, "What spell do you want to learn from [src]?", "Study Tome") in Scribed
					if(Learn=="Cancel")
						src.Using=0
						return
					if(Learn.PreRequisite.len) for(var/index in Learn.PreRequisite)	if(!locate(text2path(index)) in usr.contents)
						usr << "You do not currently have all of the prerequisite skills for [Learn]."
						src.Using=0
						return
					if(!(usr.Imagination*usr.Intelligence*usr.RPPMult*(1+usr.ParasiteCrest())+usr.TomeCreationUnlocked/2>=Learn.Copyable))
						src.Using=0
						return
					if(usr.HasManaCapacity(Cost*(Learn.Copyable ? Learn.Copyable : 6)))
						var/obj/Skills/s = new Learn.type
						usr.AddSkill(s)
						usr << "You've learned [s] from [src]!"
						usr.TakeManaCapacity(Cost*Learn.Copyable)
						src.Using=0
						return
					else
						usr << "You don't have enough capacity to translate a spell from [src].  It costs [Commas(Cost*Learn.Copyable)] capacity."
						src.Using=0
						return
				if("Bind")
					if(!src.Stealable)
						usr << "[src] is already bound."
						src.Using=0
						return
					else
						var/Cost=glob.progress.EconomyMana/2
						if(usr.HasManaCapacity(Cost))
							usr.TakeManaCapacity(Cost)
							src.Stealable=0
						else
							usr << "You don't have enough capacity to bind this tome to you.  It requires [Commas(Cost)] capacity."
							src.Using=0
							return
			src.Using=0
			return

	// Scroll
	// 	Unobtainable=1
	// 	var/StoredSpell
	// 	var/StoredSpellLevel
	// 	icon='Scroll.dmi'
	// 	desc="A scroll is a fragment torn out of a magic Tome that can be placed into another without the need to expand the tome first."
	// 	Click()
	// 		if((src in usr))
	// 			if(!src.StoredSpell)
	// 				return
	// 			if(src.Using)
	// 				return
	// 			if(usr.EquippedTome())
	// 				var/obj/Items/Enchantment/Tome/T=usr.EquippedTome()
	// 				var/obj/Skills/S=new StoredSpell
	// 				var/NotFound=1
	// 				for(var/obj/Skills/Recorded in T.Spells)
	// 					if(S.type==Recorded.type)
	// 						NotFound=0
	// 						usr << "This spell already exists in [T]."
	// 						break
	// 				if(NotFound)
	// 					T.Spells.Add(S)
	// 					T.Level+=src.StoredSpellLevel
	// 					T.PagesFilled+=src.StoredSpellLevel
	// 					del src
	// 			else
	// 				usr << "Please equip a Tome you wish to integrate the excerpt into first."
	// 				src.Using=0
	// 				return

	Magic_Crest
		Stealable=1
		PermEquip=1
		desc="A Magic Crest is a repository for spells which can be passed down.  It grants spells stored inside as opposed to Tomes which only make spells more easy to use."
		var/list/obj/Skills/Spells=list()
		var/Wielder
		var/list/PastCKeys=list()
		var/FreeSpells=0//allows the next wielder to add more.
		var/Parasite=0//makes bad thing happen
		var/CrestMadeAge=0//the era that the crest was made on
		verb/Examine()
			var/head="<html><title>[src]</title><body bgcolor=#000000 text=#339999>"
			var/close="</body></html>"
			var/content="<table>"
			for(var/obj/Skills/x in src.Spells)
				content+="<tr><td>[x]</td></tr>"
			content+="</table>"
			var/HTML="[head][content][close]"
			usr << browse(HTML,"window=[src];size=450x600")
		verb
			Transplant_Crest()
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
					return
				if(src.Using)
					return
				src.Using=1
				var/list/mob/Players/Options=list("Cancel")
				if(src.loc==usr)
					for(var/mob/Players/P in oview(1, usr))
						if(P.Secret=="Heavenly Restriction" && P.secretDatum?:hasRestriction("Magic"))
							continue
						Options.Add(P)
					for(var/mob/Body/b in oview(1, usr))
						Options.Add(b)
					if(Options.len<2)
						usr << "There's no one here to transplant your [src] into."
						src.Using=0
						return
					var/mob/Players/Choice=input(usr, "Who do you want to transplant your [src] into?", "Transplant [src]") in Options
					if(Choice=="Cancel")
						src.Using=0
						return
					if(Choice.ckey in src.PastCKeys)
						usr << "This person has owned this Crest before!"
						src.Using=0
						return
					if(Choice.EquippedCrest())
						usr << "This person already carries a legacy of magic!"
						src.Using=0
						return
					var/Kill=0
					if(src.Parasite)
						Kill=1
					src.AlignEquip(usr)
					src.PastCKeys.Add(usr.ckey)
					src.Wielder=Choice.ckey
					src.FreeSpells=src.Spells.len
					Choice.AddSkill(src)
					src.ObjectUse(Choice)
					OMsg(usr, "[usr] has passed on their [src] to [Choice]!")
					if(Kill)
						OMsg(usr, "[usr] struggles as their body attempts to adjust to not having a cursed crest!")
						spawn(66)
							usr.Death(null, "failing to adjust to a lack of cursed crest!", SuperDead=99)
							usr.Reincarnate()
				else
					if(usr.CrestCreationUnlocked>=4)
						var/Choice=alert(usr, "Do you want to expend capacity to force this Magic Crest to accept you?", "Steal Crest", "No", "Yes")
						if(Choice=="No")
							return
						var/Cost=glob.progress.EconomyMana/2
						if(usr.HasManaCapacity(Cost))
							var/Kill=0
							if(src.Parasite)
								Kill=1
							src.AlignEquip(src.loc)
							usr.TakeManaCapacity(Cost)
							src.PastCKeys.Add(src.loc:ckey)
							src.Wielder=usr.ckey
							src.FreeSpells=src.Spells.len
							usr.AddSkill(src)
							src.ObjectUse(usr)
							OMsg(usr, "[usr] has stolen the [src] from its former owner!")
							if(Kill)
								OMsg(usr, "[usr] struggles as their cursed crest is ripped away from them!")
								spawn(66)
									usr.Death(null, "failing to adjust to a lack of cursed crest!", SuperDead=99)
									usr.Reincarnate()
						else
							usr << "You don't have enough capacity to take over [src].  It costs [Commas(Cost)] capacity."
					else
						usr << "You don't know enough about Crest Creation to affect this crest."
				src.Using=0
				return
			Malform_Crest()
				if(src.Parasite)
					return
				if(usr.CrestCreationUnlocked<10)
					usr << "You lack the skill required!"
					return
				if(src.Wielder!=usr.ckey)
					usr << "You don't own this [src]!"
					return
				if(src.Using)
					return
				src.Using=1
				var/Choice=alert(usr, "Who do you want to turn your [src] into a parasitic entity?", "Malform [src]", "No", "Yes")
				if(Choice=="No")
					src.Using=0
					return
				src.Parasite=1
				OMsg(usr, "[usr] has malformed their [src]!")
				src.Using=0
				return
			Implant_Spell()
				if(src.Wielder!=usr.ckey)
					usr << "You don't own this [src]!"
					return
				if(src.Using)
					return
				if(usr.CrestCreationUnlocked<=(src.Spells.len-src.FreeSpells))
					usr << "You've already engraved as many spells as you know how to into [src]."
					return
				src.Using=1
				var/list/obj/Skills/MagicKnown=list("Cancel")
				for(var/obj/Skills/s in usr.contents)
					if(istype(s, /obj/Skills/Buffs/SlotlessBuffs/Autonomous))
						continue
					if(s.MagicNeeded)
						var/NotFound=1
						for(var/obj/Skills/Known in src.Spells)
							if(s.type==Known.type)
								NotFound=0
								break
						if(s.CrestGranted)
							NotFound=0
						if(s.Cooldown==-1)
							NotFound=0
						if(s.NoTransplant)
							NotFound=0
						if(NotFound)
							MagicKnown.Add(s)
				if(MagicKnown.len<2)
					usr << "You don't know any magic to add to your [src]!"
					src.Using=0
					return
				var/obj/Skills/Choice=input(usr, "What spell do you want to implant into [src]?", "Implant Spell") in MagicKnown
				if(Choice=="Cancel")
					src.Using=0
					return
				else
					var/Cost=glob.progress.EconomyMana/2
					if(usr.HasManaCapacity(Cost))
						usr.TakeManaCapacity(Cost)
						var/obj/Skills/S=new Choice.type
						src.Spells.Add(S)
						usr << "You successfully engrave [Choice] into your [src]!"
						src.Using=0
						return
					else
						usr << "You don't have enough capacity to engrave a spell right now.  It costs [Commas(Cost)] capacity."
						src.Using=0
						return
				src.Using=0
				return

	// Summoning_Contract
	// 	desc="A contract that can be used to make an agreement with a spiritual entity.  Ripping up the paper severs this link."
	// 	icon='SummoningContract.dmi'
	// 	var/Contractee//holds a ckey
	// 	var/ContracteeSignature
	// 	var/Contractor//holds a ckey
	// 	var/ContractorSignature
	// 	var/SummonX
	// 	var/SummonY
	// 	var/SummonZ
	// 	var/TeleportX
	// 	var/TeleportY
	// 	var/TeleportZ
	// 	Destructable=0
	// 	verb/Destroy()
	// 		set src in usr
	// 		set category=null
	// 		if(locate(/obj/Seal, src))
	// 			for(var/obj/Seal/S in src)
	// 				if(usr.ckey!=S.Creator)
	// 					usr << "This contract has been sealed!  You must break the seal before you can destroy it."
	// 					return
	// 		var/Confirm=alert(usr, "Are you sure you want to destroy this contract?", "Destroy Contract", "No", "Yes")
	// 		if(Confirm=="No")
	// 			return
	// 		var/ContracteeFound=0
	// 		var/ContractorFound=0
	// 		for(var/mob/Players/P in world)
	// 			if(P.ckey==src.Contractee||P.ckey==src.Contractor)
	// 				P.SummonContract--
	// 				if(P.ckey==src.Contractee)
	// 					ContracteeFound=1
	// 				if(P.ckey==src.Contractor)
	// 					ContractorFound=1
	// 		if(!ContracteeFound)
	// 			global.ContractBroken.Add(src.Contractee)
	// 		if(!ContractorFound)
	// 			global.ContractBroken.Add(src.Contractor)
	// 		OMsg(usr, "[usr] tears up [src]!")
	// 		del src

	// 	Click()
	// 		if((src in usr))
	// 			if(src.Using)
	// 				return
	// 			if(!usr.SummoningMagicUnlocked)
	// 				usr << "You don't know how to use summoning magic!"
	// 				return


	// 			if(locate(/obj/Seal, src))
	// 				for(var/obj/Seal/S in src)
	// 					if(src.Contractor)
	// 						if(usr.ckey!=src.Contractor || (src.ContractorSignature && (usr.EnergySignature!=src.ContractorSignature)))
	// 							usr << "This contract has been sealed!  You must break the seal before you can use it."
	// 							return
	// 			if(!usr.Move_Requirements()||usr.KO)
	// 				return
	// 			src.Using=1
	// 			if(src.Contractee)
	// 				for(var/mob/Players/p in world)
	// 					if(p.ckey == src.Contractee && (!src.ContracteeSignature || (src.ContracteeSignature == p.EnergySignature)) && (!p.Dead||p.HasEnlightenment()))
	// 						var/list/Options=list("Cancel", "Summon", "Dismiss")
	// 						if(usr.SummoningMagicUnlocked>=2)
	// 							Options.Add("Communicate")
	// 						if(usr.SummoningMagicUnlocked>=4)
	// 							Options.Add("Lifelink")
	// 						if(usr.SummoningMagicUnlocked>=5)
	// 							Options.Add("Punish")
	// 						if(locate(/obj/Seal/Command_Seal,usr))
	// 							Options.Add("Suicide")
	// 							Options.Add("Miracle")
	// 							Options.Add("Obedience")
	// 						var/Choice=input(usr, "What do you want to use [p]'s contract for?", "Contract") in Options
	// 						if(Choice=="Cancel")
	// 							src.Using=0
	// 							return
	// 						switch(Choice)
	// 							if("Communicate")
	// 								usr.TwoWayTelepath(p)
	// 								src.Using=0
	// 								return
	// 							if("Summon")
	// 								if(p.Grab)
	// 									usr << "[p] can't grab someone and be summoned!"
	// 									src.Using=0
	// 									return
	// 								if(usr.TotalCapacity>=25)
	// 									usr << "You don't have enough magic capacity to summon [p] right now!"
	// 									src.Using=0
	// 									return
	// 								if(p.MovementSealed())
	// 									usr << "[p]'s movement has been sealed and so they cannot be summoned!"
	// 									src.Using=0
	// 									return
	// 								p.PrevX=p.x
	// 								p.PrevY=p.y
	// 								p.PrevZ=p.z
	// 								p.SummonReturnTimer=-1
	// 								src.SummonX=p.x
	// 								src.SummonY=p.y
	// 								src.SummonZ=p.z
	// 								p.loc=usr.loc
	// 								usr.TotalCapacity+=75
	// 								OMsg(usr, "[usr] summons [p] by their contract!")
	// 								src.Using=0
	// 								return
	// 							if("Dismiss")
	// 								if(p.Grab)
	// 									usr << "[p] can't grab someone and be dismissed!"
	// 									src.Using=0
	// 									return
	// 								if(!src.SummonX||!src.SummonY||!src.SummonZ)
	// 									usr << "They don't have a last location to return to."
	// 									src.Using=0
	// 									return
	// 								OMsg(p, "[usr] returns [p] to their last location!")
	// 								p.loc=locate(src.SummonX, src.SummonY, src.SummonZ)
	// 								p.SummonReturnTimer=0
	// 								src.SummonX=0
	// 								src.SummonY=0
	// 								src.SummonZ=0
	// 								src.Using=0
	// 								usr.TotalCapacity-=75
	// 								if(usr.TotalCapacity<0)
	// 									usr.TotalCapacity=0
	// 								return
	// 							if("Lifelink")
	// 								if(usr.Transfering)
	// 									usr<<"You stop lifelinking."
	// 									usr.Transfering=null
	// 									src.Using=0
	// 									return
	// 								else
	// 									usr.Transfering=p
	// 									usr<<"You begin sharing your lifeforce."
	// 									src.Using=0
	// 									return
	// 							if("Punish")
	// 								if(usr.ManaAmount>=30*max((p.Power/usr.Power),1))
	// 									usr.LoseMana(30*max((p.Power/usr.Power),1))
	// 									if(p.HellPower&&prob(50))
	// 										OMsg(usr, "[usr] failed to punish [p] using their contract!")
	// 										src.Using=0
	// 										return
	// 									p << "<font color=#FF0000>A jolt of pain goes through your body!</font>"
	// 									p.DamageSelf(TrueDamage(10))
	// 									Stun(p, 3)
	// 									OMsg(usr, "[usr] punishes [p] using their contract!")
	// 									src.Using=0
	// 									return
	// 								else
	// 									OMsg(usr, "[usr] lacks strength to punish [p].")
	// 									src.Using=0
	// 									return
	// 							if("Suicide")
	// 								for(var/obj/Seal/Command_Seal/CS in usr)
	// 									if(CS.Orders>=3)
	// 										CS.Orders--
	// 										CS.Orders--
	// 										CS.Orders--
	// 										if(CS.Orders<=0)
	// 											OMsg(usr, "The Command Seal fades from [usr]!")
	// 											del CS
	// 										if(p.HellPower&&prob(50))
	// 											OMsg(usr, "[usr] failed to order [p] using their Command Seal!")
	// 											src.Using=0
	// 											return
	// 										p.CursedWounds=1
	// 										p.DamageSelf(TrueDamage(250))
	// 										p.CursedWounds=0
	// 										OMsg(usr, "[p] harms themselves grieviously under [usr]'s command!")
	// 								src.Using=0
	// 								return
	// 							if("Miracle")
	// 								for(var/obj/Seal/Command_Seal/CS in usr)
	// 									if(CS.Orders>=2)
	// 										CS.Orders--
	// 										CS.Orders--
	// 										if(CS.Orders<=0)
	// 											OMsg(usr, "The Command Seal fades from [usr]!")
	// 											del CS
	// 										p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Empowered)
	// 										OMsg(usr, "[p] becomes capable of miracles under [usr]'s command!")
	// 								src.Using=0
	// 								return
	// 							if("Obedience")
	// 								for(var/obj/Seal/Command_Seal/CS in usr)
	// 									CS.Orders--
	// 									if(CS.Orders<=0)
	// 										OMsg(usr, "The Command Seal fades from [usr]!")
	// 										del CS
	// 									if(p.HellPower&&prob(50))
	// 										OMsg(usr, "[usr] failed to order [p] using their Command Seal!")
	// 										src.Using=0
	// 										return
	// 									var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Shackled/S=new
	// 									S.Password=usr.name
	// 									p.AddSkill(S)
	// 									OMsg(usr, "[p] becomes incapable of harming [usr]!")
	// 								src.Using=0
	// 								return
	// 						break
	// 			else
	// 				var/list/mob/Players/Options=list("Cancel")
	// 				for(var/mob/Players/P in ohearers(15, usr))
	// 					if(P.Spiritual)
	// 						if(!locate(/obj/Skills/Soul_Contract, P)&&!(P.SummonContract&&P.SummonReturnTimer==-1))
	// 							Options.Add(P)
	// 				if(Options.len<2)
	// 					usr << "There are no nearby spirits to contract."
	// 					src.Using=0
	// 					return
	// 				var/mob/Players/Choice=input(usr, "What nearby spirit do you wish to attempt to contract with?", "Contract Spirit") in Options
	// 				if(Choice=="Cancel")
	// 					src.Using=0
	// 					return
	// 				var/Confirm=alert(Choice, "[usr] wishes to enter into a contract with you.  Do you accept?", "Contract Spirit", "No", "Yes")
	// 				if(Confirm=="No")
	// 					OMsg(usr, "[Choice] rejects [usr]'s offer of a contract!")
	// 					src.Using=0
	// 					return
	// 				if(!usr.SummonContract)
	// 					usr.SummonContract=1
	// 				else
	// 					usr.SummonContract++
	// 				if(!Choice.SummonContract)
	// 					Choice.SummonContract=1
	// 				else
	// 					Choice.SummonContract++
	// 				Choice.SummonReturnTimer=-1
	// 				src.SummonX=Choice.PrevX
	// 				src.SummonY=Choice.PrevY
	// 				src.SummonZ=Choice.PrevZ
	// 				src.Contractee=Choice.ckey
	// 				src.ContracteeSignature=Choice.EnergySignature
	// 				src.Contractor=usr.ckey
	// 				src.ContractorSignature=usr.EnergySignature
	// 				OMsg(usr, "[usr] strikes a contract with [Choice]!")
	// 				src.Using=0
	// 				return
	// 			src.Using=0
	// 			return



	Teleport_Nexus
		Cost=100
		Pickable=0
		Grabbable=0
		desc="A teleport nexus can link two locations over any distance."
		EnchType="SpaceMagic"
		SubType="NOT IN"
		icon='TeleportNexus.dmi'
		verb/Nexus_Teleport()
			set category=null
			set src in view(1, usr)

			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
				return
			var/obj/Skills/Teleport/Nexus_Teleport/nt=new
			nt.FocalPassword=src.Password
			nt.FocalExceptions.Add(src)
			for(var/obj/Items/Enchantment/Teleport_Amulet/ta in usr)
				nt.FocalExceptions.Add(ta)
			nt.Activate(usr)
			return
		verb/Set_Password()
			set category=null
			set src in view(1, usr)
			if(src.Password)
				var/PassCheck=input(usr, "Enter the nexus' current password in order to reset it.", "Reset Password") as text
				if(PassCheck==src.Password)
					src.Password=input(usr, "Correct.  Enter the new password you'd like for this nexus.", "Reset Password") as text
				else
					usr << "That was not the correct password."
					return
			else
				src.Password=input(usr, "Enter a password for the nexus.", "Set Password") as text
		verb/Nexus_Summon()
			set category=null
			set src in view(1, usr)
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
				return
			var/PassCheck=input(usr, "Enter the nexus' password to summon one of those with a teleport amulet assigned to this nexus.", "Rally") as text
			if(PassCheck==src.Password)
				var/obj/Skills/Teleport/Nexus_Summon/ns=new
				ns.FocalPassword=src.Password
				ns.FocalExceptions.Add(src)
				for(var/obj/Items/Enchantment/Teleport_Amulet/ta in usr)
					ns.FocalExceptions.Add(ta)
				ns.Activate(usr)
			else
				usr << "That is not the password to use the nexus."
		verb/Nexus_Rally()
			set category=null
			set src in view(1, usr)
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
				return
			var/PassCheck=input(usr, "Enter the nexus' password to summon those with a teleport amulet assigned to this nexus.", "Rally") as text
			if(PassCheck==src.Password)
				var/obj/Skills/Teleport/Nexus_Summon/Nexus_Rally/ns=new
				ns.FocalPassword=src.Password
				ns.FocalExceptions.Add(src)
				for(var/obj/Items/Enchantment/Teleport_Amulet/ta in usr)
					ns.FocalExceptions.Add(ta)
				ns.Activate(usr)
			else
				usr << "That is not the password to use the nexus."


	Teleport_Amulet
		Cost=80
		desc="A teleport amulet can be used to grant access to a teleport nexus."
		EnchType="SpaceMagic"
		SubType="NOT IN"
		icon='TeleportAmulet.dmi'
		verb/Set_Password()
			set category=null
			set src in usr
			if(src.Password)
				var/PassCheck=input(usr, "Enter the teleport necklace's current password to reset it.", "Reset Password") as text
				if(src.Password==PassCheck)
					src.Password=input(usr, "Enter a new password for the teleport necklace.", "Reset Password") as text
				else
					usr << "That is not [src]'s current password."
					return
			else
				src.Password=input(usr, "Set the teleport necklace's password.", "Set Password") as text
		verb/Necklace_Teleport()
			set category=null
			set src in usr

			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
				return
			var/obj/Skills/Teleport/Nexus_Teleport/nt=new
			nt.FocalPassword=src.Password
			nt.FocalExceptions.Add(src)
			for(var/obj/Items/Enchantment/Teleport_Amulet/ta in usr)
				nt.FocalExceptions.Add(ta)
			nt.Activate(usr)
			return


	Dimensional_Cage
		Pickable=1
		Grabbable=1
		Savable=1
		Destructable=1
		desc="This small spatial rift generator allows you to temporarily send a target into a locked space."
		EnchType="SpaceMagic"
		SubType="NOT IN"
		icon='Caja.dmi'
		Cost=100
		var
			ReturnX=0
			ReturnY=0
			ReturnZ=0
		Click()
			if(!(src in usr))
				..()
			if((src in usr))
				if(src.Using)
					return
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
					return
				src.Using=1
				if(!usr.GlobalCooldowns["[src.type]"])
					usr.GlobalCooldowns["[src.type]"] = 0
				if(!(world.realtime > usr.GlobalCooldowns["[src.type]"] + Hour(3)))
					usr << "Not enough time has passed between uses of Dimensional Cubes."
					src.Using=0
					return
				if(!usr.Target||usr.Target==usr||usr.Target.z!=usr.z)
					usr << "You need a nearby target to use this item!"
					src.Using=0
					return
				if(get_dist(usr,usr.Target)>5)
					usr << "Your target is too far!"
					src.Using=0
					return
				usr.GlobalCooldowns["[src.type]"] = world.realtime
				missile(src.icon,usr,usr.Target)
				sleep(10)
				src.Pickable=0
				src.Grabbable=0
				src.Destructable=0
				src.loc=usr.Target.loc
				src.icon_state="Active"
				usr.Target.density=0
				usr.Target.Grabbable=0
				usr.Target.Incorporeal=1
				usr.Target.invisibility=90
				usr.Target.SetStasis(120)
				usr.Target.StasisSpace=1
				spawn()animate(usr.Target.client, color = list(-1,0,0, 0,-1,0, 0,0,-1, 0,1,1), time = 5)
				OMsg(usr, "[usr] locks [usr.Target] in an isolated space!")
				spawn(1200)
					del src

	PocketDimensionGenerator
		var/DimensionType
		var/PortalStatus="Off"
		density=1
		Pickable=1
		Grabbable=1
		Savable=1
		icon='enchantmenticons.dmi'
		icon_state="PDG"
		desc="This magical device can create a small dimension just outside the boundries of the dimension its in. It doesn't work in other pocket dimensions."
		EnchType="SpaceMagic"
		SubType="Bilocation"
		Cost=20
		Destructable=0
		verb/SetPassword()
			set src in view(1, usr)
			set name="Set Password"
			if(src.Password)
				var/PassCheck=input(usr, "Enter the current password in order to reset.", "Reset Password") as text
				if(PassCheck==src.Password)
					src.Password=input(usr, "Enter the new password you'd like.", "Reset Password") as text
				else
					usr << "Incorrect password."
			else
				src.Password=input(usr, "Enter the password you'd like.", "Set Password") as text
		verb/TogglePortal()
			set src in oview(1)
			set name="Toggle Portal"

			if(usr.InMagitekRestrictedRegion())
				usr << "The dimension generator attempts to form a portal, but it disperses before fully forming."
				return
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
				return
			if(!src.DimensionType)
				var/list/obj/Effects/PocketExit/Available=list()
				for(var/obj/Effects/PocketExit/PE in world)
					if(!PE.density)
						Available.Add(PE)
				if(Available.len)
					var/obj/Portal=pick(Available)
					src.DimensionType=Portal.Password
					usr << "[src]'s dimension ID set to [src.DimensionType]!"
				else
					usr << "All current pocket dimensions are full!  Contact the admin team to set up a new one."
					return
			var/found=0
			for(var/obj/Effects/PocketExit/PE in world)
				if(PE.Password==src.DimensionType)
					found=1
					PE.density=1
					break
			if(!found)
				usr << "The dimension type of this generator is no longer found in the world!  Contact the admins to try to find your pocket dimension."
				return
			if(src.Password)
				var/PassCheck=input("Enter the password to toggle this generator.") as text
				if(PassCheck==src.Password)
					if(src.PortalStatus=="Off")
						var/obj/Effects/PocketPortal/PP=new(src.x, src.y+2, src.z)
						PP.Password=src.DimensionType
						src.PortalStatus="On"
						OMsg(usr, "[usr] opens a pocket dimension generated by [src]!")
						src.Grabbable=0
						src.Pickable=0
					else
						for(var/obj/Effects/PocketPortal/PP in world)
							if(src.DimensionType==PP.Password)
								del(PP)
								OMsg(usr, "[usr] closes the pocket dimension generated by [src]!")
								src.PortalStatus="Off"
								src.Grabbable=1
								src.Pickable=1
								return
				else
					usr<<"Incorrect password."
					return
			else
				usr << "This generator does not have a password set yet.  Give it one before trying to open a dimension."
				return

	Crystal_of_Recall
		Cost=80
		EnchType="SpaceMagic"
		SubType="Retrieval"
		icon='CrystalOfRecall.dmi'
		desc="A crystal of recall can be consumed to restore the user to a previously set location."
		var
			ReturnUser
			ReturnX=0
			ReturnY=0
			ReturnZ=0
			ConcentrationCheck=0
		verb/Set_Location()
			set category=null
			set src in usr
			if(usr.totalRecall >= 3)
				usr << "You can't use this anymore!"
				return
			if(usr.NoTPZone())
				usr << "The crystal refuses your connection."
				return

			src.ReturnUser=usr.ckey
			src.ReturnX=usr.x
			src.ReturnY=usr.y
			src.ReturnZ=usr.z
			usr << "Location set!"
			src.suffix="([src.ReturnX], [src.ReturnY], [src.ReturnZ])"
		Click()
			if(!(src in usr))
				..()
			else
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
					return
				if(src.Using)
					return
				if(usr.Grab)
					usr << "You can't use this while grabbing someone!"
					return
				if(usr.NoTPZone())
					usr << "The crystal refuses your connection."
					return
				src.Using=1
				src.ConcentrationCheck=usr.Health
				var/Confirm
				if(!src.ReturnX&&!src.ReturnY&&!src.ReturnZ)
					Confirm=alert(usr, "You are about to use your [src] to return to spawn!  Are you sure you want to do this?", "Crystal of Recall", "No", "Yes")
				else
					Confirm=alert(usr, "You are about to use your [src] to return to [src.ReturnX], [src.ReturnY], [src.ReturnZ]!  Are you sure you want to do this?", "Crystal of Recall", "No", "Yes")
				if(Confirm=="No")
					src.Using=0
					return
				OMsg(usr, "[usr] activates their Crystal of Recall to return to a previous location!")
				sleep(30)
				if(usr.ckey!=ReturnUser)
					if(prob(75))
						OMsg(usr, "[usr] isn't recorded - the crystal shatters in a failed attempt to recall!")
						src.Using=0
						del src
						return
				if(usr.Health<src.ConcentrationCheck)
					OMsg(usr, "[usr] lost their concentration and the crystal fizzled out!")
					src.Using=0
					del src
					return
				if(src.ReturnX&&src.ReturnY&&src.ReturnZ)
					usr.loc=locate(src.ReturnX, src.ReturnY, src.ReturnZ)
				else
					MoveToSpawn(usr)
				usr.OverClockNerf+=0.5
				usr.OverClockTime+=RawHours(2)
				src.Using=0
				usr.totalRecall+=1
				del src
				return

	Crystal_of_Bilocation
		icon='CrystalOfDuplicity.dmi'
		desc="A powerful contingency that waits for a caster to be in mortal peril, then teleports them out of it!"
		Cost=600
		EnchType="SpaceMagic"
		SubType="NOT IN"
		var
			Signature//ckey
		Click()
			if(src in oview(1, usr))
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
					return
				if(Signature)
					var/PassCheck=input(usr, "Enter the password protecting this crystal if you want to change who it is attuned to.", "Change Signature") as text
					if(PassCheck==src.Password)
						src.Password=input(usr, "Enter a new password.", "Change Signature") as text
						src.Signature=usr.ckey
						usr << "[src] has accepted your magical signature!"
						return
					else
						usr << "Incorrect."
				else
					src.Password=input(usr, "Enter a password to safeguard your signature.", "Assign Signature") as text
					src.Signature=usr.ckey
					usr << "Your magical signature has been accepted by [src]!"
					src.icon_state="Active"
					src.suffix="(Active)"
			else
				..()


	AgeDeceivingPills
		Cost=40
		name="Age-Deceiving Pills"
		EnchType="TimeMagic"
		SubType="NOT IN"
		icon='Lab.dmi'
		icon_state="KeloPill"
		desc="Use this to temporarily force your body into its prime."
		verb/Use()
			set src in usr
			if(!usr.Move_Requirements())
				return
			var/validkitters=list("Cancel")
			for(var/mob/Players/A in view(1,usr))
				validkitters+=A
			var/mob/selection=input("Select a target to use the age-deceiving pills on.") in validkitters
			if(selection=="Cancel")
				return
			if(selection.Aged)
				usr<<"They're already aged up."
				return
			if(selection.Timeless||selection.HasMechanized())
				usr<<"They're not affected by the pill."
				return
			usr<<"Applying age-deceiving pills to [selection]!"
			selection.OMessage(10,"<font color=red><b>[selection] suddenly rapidly ages up!</b></font>","Aging pills applied.")
			selection.Aged=RawHours(1)
			del(src)


	Crystal_of_Reversal
		icon='ReCrystal.dmi'
		desc="A crystal that will selectively rewind the user's time, restoring particularly grevious wounds at the cost of physical development."
		Cost=1500
		EnchType="TimeMagic"
		SubType="Temporal Rewinding"
		Click()
			if((src in usr))
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Magic"))
					return
				if(usr.HasMechanized())
					usr<<"They're not affected by the crystal."
					return
				usr.Potential=1
				if(usr.Maimed && usr.magicalMaimRecov<5)
					usr.Maimed=max(usr.Maimed-1,0)
					usr.magicalMaimRecov++
				if(usr.isRace(SAIYAN) && !usr.Tail)
					usr.Tail=1
				if(usr.HealthCut)
					usr.HealthCut=max(usr.HealthCut-0.1,0)
				if(usr.EnergyCut)
					usr.EnergyCut=max(usr.EnergyCut-0.1,0)
				if(usr.ManaCut)
					usr.ManaCut=max(usr.ManaCut-0.1,0)
				if(usr.StrCut)
					usr.StrCut=max(usr.StrCut-0.1,0)
				if(usr.EndCut)
					usr.EndCut=max(usr.EndCut-0.1,0)
				if(usr.SpdCut)
					usr.SpdCut=max(usr.SpdCut-0.1,0)
				if(usr.ForCut)
					usr.ForCut=max(usr.ForCut-0.1,0)
				if(usr.OffCut)
					usr.OffCut=max(usr.OffCut-0.1,0)
				if(usr.DefCut)
					usr.DefCut=max(usr.DefCut-0.1,0)
				if(usr.RecovCut)
					usr.RecovCut=max(usr.RecovCut-0.1,0)
				OMsg(usr, "[usr] crushes the crystal in their hand to partly rewind time!")
				del src
			else
				..()


	Elixir_of_Longevity
		icon='ElixerOfLongevity.dmi'
		desc="A potion which will grant the drinker the ability to indefinitely avoid a death by aging...though it does not keep them young."
		Cost=1000
		EnchType="TimeMagic"
		SubType="Lifespan Extension"
		Click()
			if((src in usr))
				if(usr.HasMechanized())
					usr<<"They're not affected by the brew."
					return
				if(usr.Immortal||usr.Timeless)
					usr << "Your lifespan is already limitless!"
					return
				usr.Immortal=1
				OMsg(usr, "[usr] drinks an elixer of longevity to become immortal!")
				del src
			else
				..()


	Phylactery
		icon='Phylactery.dmi'
		desc="A container for your soul, making you incapable of dying...but if it is shattered, you will die instantly."
		Cost=1000
		EnchType="TimeMagic"
		SubType="NOT IN"
		var
			Signature//ckey
		Click()
			if(src in oview(1, usr))
				var/Confirm=alert(usr, "Do you wish to place your soul in this phylactery?  It will make you immortal and ageless, but if it is ever destroyed you will perish.", "Phylactery", "No", "Yes")
				if(usr.Secret||usr.HasMechanized())
					usr << "Your nature makes you incompatibile with this phylactery!"
					return
				if(Confirm=="Yes")
					usr.Phylactery=1
					usr.PhylacteryNerf=0
					usr.Timeless=1
					usr.Secret="Zombie"
					src.Signature=usr.ckey
					OMsg(usr, "[usr] seals their soul into [src]!")
					return
			else
				..()
	Elixir_of_Reincarnation
		icon='ElixerOfReincarnation.dmi'
		desc="A potion which will allow the drinker to come back as a child with their current memories."
		Cost=400
		EnchType="TimeMagic"
		SubType="NOT IN "
		Unobtainable=1
		Click()
			if((src in usr))
				if(src.Using)
					return
				if(usr.HasMechanized())
					usr<<"They're not affected by the brew."
					return
				src.Using=1

				usr.UpdateBio()
				usr.Finalize(Warped=1)
				var/mob/Creation/C = new
				C.NextStep2(usr)
				del C

				OMsg(usr, "[usr] is reborn!")
				usr.EraAge=glob.progress.Era
				usr.EraBody="Child"
				if(usr.isRace(SAIYAN)||usr.isRace(HALFSAIYAN))
					usr.Tail(1)

				src.Using=0
				del src
				return
			else
				..()

	Time_Displacer
		icon='TimeDisplacer.dmi'
		desc="Use this to shift one age category around between yourself and another person!"
		Cost=800
		EnchType="TimeMagic"
		SubType="NOT IN"
		Click()
			if((src in usr))
				if(src.Using)
					return
				if(usr.HasMechanized())
					usr<<"They're not affected by the device."
					return
				src.Using=1
				var/list/mob/Players/Options=list("Cancel")
				for(var/mob/Players/P in view(1, usr))
					if(usr==P)
						continue
					if(P.icon_state=="Meditate")
						Options.Add(P)
				if(Options.len<2)
					usr << "There's no one nearby to displace time with! Make sure they're meditating to do this."
					src.Using=0
					return
				var/mob/Players/Choice=input(usr, "What person do you want to displace time with?", "Time Displacer") in Options
				if(Choice=="Cancel")
					src.Using=0
					return
				var/Consent
				if(Choice.KO)
					Consent="Yes"
				else
					Consent=alert(Choice, "[usr] is wanting to displace a time period with you!  This means you will either gain or lower an age category.  Do you wish to do this?", "Time Displacer", "No", "Yes")
				if(Consent=="No")
					OMsg(usr, "[Choice] refuses [usr]'s offer to have their time displaced!")
					src.Using=0
					return
				var/Mode=alert(usr, "Do you want to TAKE an age category from [Choice], or GIVE an age category to [Choice]?", "Time Displacer", "Take Age", "Give Age")
				if(Mode=="Take Age")
					usr.EraAge-=1
					Choice.EraAge+=1
					OMsg(usr, "[usr] takes some of the years lived away from [Choice]!")
				if(Mode=="Give Age")
					usr.EraAge+=1
					Choice.EraAge-=1
					OMsg(usr, "[usr] gives [Choice] their excess age!")
				if(usr.EraAge>glob.progress.Era)
					usr.Death(null, "being reverted to a time before their birth!", SuperDead=1)
				if(Choice.EraAge>glob.progress.Era)
					Choice.Death(null, "being reverted to a time before their birth!", SuperDead=1)
				usr << "Relog to change to your new age."
				Choice << "Relog to change to your new age."
				src.Using=0
				del src
				return
			else
				..()


	Portal
		Level=50
		Cost=200
		Savable=1
		Grabbable=0
		Destructable=0
		density=1
		icon='BlackHole.dmi'
		desc="This portal allows transport to another portal linked to it. Portals can only be linked in pairs."
		verb/SetPassword()
			set src in oview(1)
			var/PasswordCheck
			if(src.Password)
				usr<<"This portal is already configured."
				return
			PasswordCheck=input("Input the desired password. This won't work if two portals already share the same password!")as text
			var/PortalChecker=0
			for(var/obj/Items/Enchantment/Portal/A in world)
				if(A.Password==PasswordCheck)
					PortalChecker++
			if(PortalChecker>=2)
				usr<<"Sorry, but this password is in use by two portals already..."
				src.Password=null
				return
			else if(PortalChecker==1)
				usr<<"The portal shimmers as it links with the other one set to this magical frequency. It can no longer be moved."
				src.Password=PasswordCheck
				src.Grabbable=0
				return
			else
				usr<<"The portal is ready to be linked to another. It can no longer be moved."
				src.Password=PasswordCheck
				src.Grabbable=0
				return
	LinkingBook
		Level=55
		Cost=5000000
		desc="This book lets you travel to a portal with the same magical frequency (password) as the book itself. If you have two portals with the same, you can choose. The book is highly malible magic wise, and the password may be changed at will."
		verb/SetPassword()
			set src in usr
			set name="Infuse Magical Signature"
			src.Password=input("Input a password.",src.Password)as text
			usr<<"The book has been aligned with a magical frequency ([src.Password])."
		verb/GoToPortal()
			if(src.Password==null)
				usr<<"Configure a password first!"
				return
			var/PortalChecker=0
			var/list/PortalsFound=list("Cancel")
			for(var/obj/Items/Enchantment/Portal/A in world)
				if(A.Password==src.Password)
					PortalChecker++
					PortalsFound.Add(A)
			if(PortalChecker==0)
				usr<<"There's no portals to go to!"
				return
			else
				var/obj/selection=input("")in PortalsFound
				if(selection=="Cancel")
					return
				else
					usr.OMessage(15,"[usr] flips open a book, magical energies beginning to flow!","[usr]([usr.key]) is using a Linking Book.")
					sleep(20)
					usr.loc=locate(selection.x,selection.y,selection.z)

	PhilosopherStone
		name="Philosopher Stone"
		icon='enchantmenticons.dmi'
		icon_state="PhiloStone"
		desc="A philosopher's stone is the result of a sapient being transmuted into pure mana.  They regenerate capacity.<br>"
		suffix = "Will Use."
		var/CurrentCapacity
		var/MaxCapacity
		var/RegenRate
		var/SoulStrength//regen+recov at moment of stoning
		var/SoulIdentity//UID of person stoned
		var/ToggleUse = 1
		New()
			..()
			Update_Description()
		verb/ToggleStone()
			set name = "Toggle Stone"
			ToggleUse = !ToggleUse
			Update_Description()

		UpdatesDescription=1
		Fake
			CurrentCapacity = 200
			MaxCapacity = 200
			RegenRate = 1
			proc/reintegrate(mob/Players/user)
				if(SoulIdentity==user.UniqueID)
					user.ManaSealed = 0
					OMsg(user, "[user] has been reintegrated with their magical circuits!")
					del src
				else
					user << "This stone doesn't belong to your circuits!"

			verb/Reintegrate_Stone()
				set name = "Reintegrate Stone"
				reintegrate(usr)
		True
			CurrentCapacity=400
			MaxCapacity=400
			RegenRate=1
		Artificial
			name="Philosopher Stone (Artificial)"
			CurrentCapacity=200
			MaxCapacity=200
			RegenRate=1
		Magicite
			name="Magicite Stone"
			icon_state = "MagiStone"
			CurrentCapacity=1
			MaxCapacity=1
			RegenRate=0
			SoulStrength=2
			Update_Description()
				src.desc="A magicite stone, operating as a source of mana.<br>Your [src] mana storage: [round(src.CurrentCapacity)] / [src.MaxCapacity]"
				if(ToggleUse)
					usr << "This stone is now available for enchanting."
					src.suffix = "[round(src.CurrentCapacity)] / [src.MaxCapacity] (Enabled for Use)"
				else
					usr << "This stone will not be used for enchanting."
					src.suffix = "[round(src.CurrentCapacity)] / [src.MaxCapacity] (Disabled for Use)"
		proc/Update_Description()
			src.desc="A philosopher's stone is the result of a sapient being transmuted into pure mana.<br>Your [src] mana storage: [round(src.CurrentCapacity)] / [src.MaxCapacity]"
			if(ToggleUse)
				usr << "This stone is now available for enchanting."
				src.suffix = "[round(src.CurrentCapacity)] / [src.MaxCapacity] (Enabled for Use)"
			else
				usr << "This stone will not be used for enchanting."
				src.suffix = "[round(src.CurrentCapacity)] / [src.MaxCapacity] (Disabled for Use)"


obj/Items/Enchantment/Staff
	Health=10
	Unobtainable=1
	icon='MageStaff.dmi'
	var/Points=0
	var/PointsAssigned=0
	var/ManaGeneration=0
	var/ElementallyInfused
	var/CalmAnger=0
	var/StaffIconSelected=0
	var/Conjured=0
	var/modifiedAttack = TRUE
	UpdatesDescription=1
	Repairable=1
	Element=0
	EnchType="ToolEnchantment"
	SubType="Spell Focii"
	desc="Spell focii alter the effects of fighting with Spells and energy attacks; they are also required to cast more complex magic."
	NonElemental
		Wand
			name="Null Wand"
			DamageEffectiveness=0.95
			AccuracyEffectiveness=1.2
			SpeedEffectiveness=1.2
			ShatterCounter=100
			ShatterMax=100
			Unobtainable=0
			Class="Wand"
			Cost=30
			Legendary
				LegendaryItem=1
				Unobtainable=1
				Ascended=5
		Rod
			name="Null Rod"
			DamageEffectiveness=1.1
			AccuracyEffectiveness=1
			SpeedEffectiveness=0.85
			ShatterCounter=150
			ShatterMax=150
			Unobtainable=0
			Class="Rod"
			Cost=40
			Legendary
				LegendaryItem=1
				Unobtainable=1
				Ascended=5

				Bolverk
					name="Bolverk"
					icon='Bolverk.dmi'
					pixel_x=-32
					pixel_y=-32
					Destructable=0
					passives = list("ManaGeneration" = 4, "CalmAnger" = 1)
					NoSaga=1
					ManaGeneration=4
					CalmAnger=1
					Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Grimoire/OverDrive/Chain_Quasar", "/obj/Skills/AutoHit/OpticBarrel", "/obj/Skills/Projectile/Fenrir", "/obj/Skills/Projectile/Thor", "/obj/Skills/Queue/ChainRevolver")
		Staff
			name="Null Staff"
			DamageEffectiveness=1.25
			AccuracyEffectiveness=0.85
			SpeedEffectiveness=0.65
			ShatterCounter=200
			ShatterMax=200
			Unobtainable=0
			Class="Staff"
			Cost=50
			Legendary
				LegendaryItem=1
				Unobtainable=1
				Ascended=5
	New()
		..()
		spawn()src.Update_Description()

	proc/Update_Description()
		desc="<b>[name]</b><br>\
		<br>"
		desc+="Class: [Class]<br>"
		if(Destructable)
			desc+="Durability: [(round(ShatterCounter/src.ShatterMax,0.01)*100)]%<br>"
		else
			desc+="Durability: Limitless<br>"
		if(Ascended||InnatelyAscended)
			var/A=min(Ascended+InnatelyAscended,4)
			switch(A)
				if(1)
					desc+="Ascension Level: Reinforced (1)<br>"
				if(2)
					desc+="Ascension Level: Enchanted (2)<br>"
				if(3)
					desc+="Ascension Level: Legendary (3)<br>"
				if(4)
					desc+="Ascension Level: Peerless (4)<br>"
		if(Element)
			desc+="Elemental Infusion: [Element]<br>"
		if(Conversions)
			desc+="Upgrade Type: [Conversions]"
		desc+="<br>Staffs alter the effects of projectile combat and have their own advantages and disadvantages.<br>"

	verb/Toggle_Staff_Projectile()
		modifiedAttack=!modifiedAttack
		usr<< "You will now[modifiedAttack ? "" : " not"] shoot staff projectiles on basic attack."

proc/Can_Afford_Enchantment(mob/P,obj/Items/O) for(var/obj/Money/M in P) if(O.Cost<=M.Level) return 1
proc/Enchantment_Price(mob/P,obj/Items/O) return O.Cost
