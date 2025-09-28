mob/proc
	UpdateTechnologyWindow()
		for(var/obj/Money/M in usr)
			src<<output(M,"GridX:1,1")
			src<<output("[Commas(M.Level)]","GridX:2,1")



var/list/Technology_List=new
var/list/BasicTechnology_List=new
var/list/Forging_List=new
var/list/RepairAndConversion_List=new
var/list/Medicine_List=new
var/list/ImprovedMedicalTechnology_List=new
var/list/Telecommunications_List=new
var/list/AdvancedTransmissionTechnology_List=new
var/list/Engineering_List=new
var/list/CyberEngineering_List=new
var/list/MilitaryTechnology_List=new
var/list/MilitaryEngineering_List=new
var/list/PowerPack_List=new

proc/Add_Technology()
	for(var/A in typesof(/obj/Items/Tech))
		var/obj/Items/B=new A
		B.suffix=null
		if(B.Cost) Technology_List+=B
		if(B.TechType)
			if(B.TechType=="BasicTechnology")
				BasicTechnology_List+=B
			if(B.TechType=="Forge")
				Forging_List+=B
			if(B.TechType=="RepairAndConversion")
				RepairAndConversion_List+=B
			if(B.TechType=="Medicine")
				Medicine_List+=B
			if(B.TechType=="ImprovedMedicalTechnology")
				ImprovedMedicalTechnology_List+=B
			if(B.TechType=="Telecommunications")
				if(istype(B, /obj/Items/Tech/Speaker))
					B:randFrequency()
				Telecommunications_List+=B
			if(B.TechType=="AdvancedTransmissionTechnology")
				AdvancedTransmissionTechnology_List+=B
			if(B.TechType=="Engineering")
				Engineering_List+=B
			if(B.TechType=="CyberEngineering")
				CyberEngineering_List+=B
			if(B.TechType=="MilitaryTechnology")
				MilitaryTechnology_List+=B
			if(B.TechType=="MilitaryEngineering")
				MilitaryEngineering_List+=B

	for(var/C in typesof(/obj/Items/Sword))
		var/obj/Items/D=new C
		if(D.Saga) continue
		D.suffix=null
		if(D.Cost>0)
			if(D.TechType=="BasicTechnology")
				BasicTechnology_List+=D
			else
				Forging_List+=D
			Technology_List+=D
		else
			del(D)
	for(var/C in typesof(/obj/Items/Armor))
		var/obj/Items/D=new C
		D.suffix=null
		if(D.Cost>0)
			Forging_List+=D
			Technology_List+=D
		else
			del(D)
	for(var/C in typesof(/obj/Items/WeightedClothing))
		var/obj/Items/D=new C
		D.suffix=null
		if(D.Cost>0)
			Forging_List+=D
			Technology_List+=D
		else
			del(D)
	for(var/C in typesof(/obj/Items/Plating))
		var/obj/Items/D=new C
		D.suffix=null
		if(D.Cost>0)
			RepairAndConversion_List+=D
			Technology_List+=D
		else
			del(D)
	for(var/C in typesof(/obj/Items/BlastShielding))
		var/obj/Items/D=new C
		D.suffix=null
		if(D.Cost>0)
			MilitaryTechnology_List+=D
			Technology_List+=D
		else
			del(D)
	for(var/C in typesof(/obj/Items/Gear))
		var/obj/Items/D=new C
		D.suffix=null
		if(D.Cost>0)
			Technology_List+=D
			if(D.TechType=="ImprovedMedicalTechnology")
				ImprovedMedicalTechnology_List+=D
			else if(D.TechType=="Medicine")
				Medicine_List+=D
			else if(D.TechType=="Engineering")
				Engineering_List+=D
			else if(D.TechType=="MilitaryTechnology")
				MilitaryTechnology_List+=D
			else if(D.TechType=="MilitaryEngineering")
				MilitaryEngineering_List+=D
	for(var/C in typesof(/obj/Items/Tech/Power_Pack))
		var/obj/Items/D=new C
		D.suffix=null
		if(D.Cost>0)
			Technology_List+=D
			PowerPack_List+=D


proc/Can_Afford_Technology(mob/P,obj/Items/O) for(var/obj/Money/M in P) if(M.Level>=Technology_Price(P, O)) return 1
proc/Technology_Price(mob/P,obj/Items/O) return O.Cost*glob.progress.EconomyCost

mob
	var
		MeditateModule
		StabilizeModule
		InfinityModule

obj/Items/Tech
	var/last_hacked_by
	var/disabledFrequency = FALSE
	var/Frequency=null//every tech item gets this now ya yeet.
	proc/randFrequency()
		var/list/letters = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
		var/list/specialChars = list("!","@","#","$","%","^","&","*","(",")","_","+","-","=","[","]","{","}","|",";",":","'","<",">",",",".","?","/","~","`")
		var/ranLen = round(1+rand(1,6))
		var/tempFreq = ""
		for(var/index in 1 to ranLen)
			tempFreq += pick(letters)
			if(prob(25))
				if(length(tempFreq) == 1)
					tempFreq = uppertext(tempFreq)
				else
					var/copypasta = copytext(tempFreq, -1)
					tempFreq = copytext(tempFreq, 1, -1) + uppertext(copypasta)
			tempFreq += "[round(rand(0,9))]"
			if(prob(50))
				tempFreq += pick(specialChars)
		Frequency = tempFreq
		if(Frequency == "a1b2c3d4e5f6g7h8i9j0")
			randFrequency()
		if(Frequency == null)
			randFrequency()
	New()
		..()
		randFrequency()

	Perfume
		Cost = 5
		TechType = "Medicine"
		SubType="Any"
		desc = "Changes your scent to a custom one."
		icon = 'Soap.png'
		Click()
			..()
			if(!(src in usr.contents)) return
			var/scentChoice = input(usr, "What would you like to smell like?", "Scent Choice") as null|text
			if(!scentChoice) return
			usr.custom_scent = scentChoice
			usr << "Your scent is now [usr.custom_scent]"
			del src

	Soap
		Cost = 2
		TechType = "Medicine"
		SubType="Any"
		desc = "Removes any custom scent to randomly one of your race's default."
		icon = 'Soap.png'
		Click()
			..()
			if(!(src in usr.contents)) return
			var/confirm = alert(usr, "Are you sure you want to remove your custom scent?", "Remove Custom Scent", "Yes", "No")
			if(confirm == "No") return
			usr.setUpScent()
			usr << "Your new scent is [usr.custom_scent]"
			del src

	Door_Pass
		name="Key"
		TechType="BasicTechnology"
		Cost=0.01
		desc="Holds a password for a door."
		icon='Tech.dmi'
		icon_state="DoorPass"
		Click()
			..()
			if(!(usr in range(1,src))) return
			if(!Password)
				Password=input("Shape pattern.")as text
			else usr<<"Already shaped!"
	Door
		TechType="BasicTechnology"
		Cost=0.02
		var/DoorID=0 //For LazerDoors.
		var/typee
		var/antispam
		var/AutoOpen=0
		var/GodDoor=0

		density=1
		Glass=1
		Destructable=1
		Pickable=0
		icon='Doors.dmi'
		icon_state="Closed1"
		Door2
			name="Security Door"
			Cost=0.05
			Health=200
			TechType="Engineering"
			SubType="Any"
			icon='Doors.dmi'
			icon_state="Closed2"
			density=1
		TransparentDoor
			name="Plexiglas Door"
			Cost=0.1
			Health=300
			TechType="Engineering"
			SubType="Any"
			icon='Doors.dmi'
			icon_state="Closed3"
			density=1
			opacity=0
			Glass=1
		LazerDoor
			Cost=0.1
			Unobtainable=1
			Health=10000000
			TechType="Engineering"
			SubType="Any"
			LaserDoor3Wide
				name="Laser Gate"
				Unobtainable=0
				icon='Lazerdoor.dmi'
				icon_state="Closed"
				density=1
				opacity=0
				Glass=1
				bound_width=96
			LazerDoorLeft
				icon='LazerdoorLeft.dmi'
				icon_state="Closed"
				density=1
				opacity=0
				Glass=1
			LazerDoorRight
				icon='LazerdoorRight.dmi'
				icon_state="Closed"
				density=1
				opacity=0
				Glass=1
			LazerDoorMiddle
				icon='LazerdoorMiddle.dmi'
				icon_state="Closed"
				density=1
				opacity=0
				Glass=1
		Guild_Door
			GodDoor=1//only unlockable by spawn
			Unobtainable=1
			Grabbable=0
			Health=1.#INF
			Destructable=0
			density=1
			opacity=1
			Guild_Door_Transparent
				Glass=1
				opacity=0
		New()
			Open()
			src.antispam=null
			..()
		Click()
			..()
			if(usr in oview(1,src))
				if(!src.antispam)
					if(istype(src, /obj/Items/Tech/Door/LazerDoor))
						oview(10,src)<<"<font color=red><small>The Lazer made a loud buzzing sound!"
						usr.AddBurn(1)
					else
						oview(10,src)<<"<font color=yellow><small>There is a knock on the door!"
					src.antispam=1
					spawn(30)
						src.antispam=null
		proc/Open()
			density=0
			opacity=0
			if(istype(src, /obj/Items/Tech/Door/Door2))
				typee=2
			else if(istype(src, /obj/Items/Tech/Door/TransparentDoor))
				typee=3
			else
				typee=1
			if(icon=='Doors.dmi')
				flick("Opening[typee]",src)
				icon_state="Open[typee]"
			else
				flick("Opening",src)
				icon_state="Open"
			spawn(50) Close()
		proc/Close()
			density=1
			if(!istype(src, /obj/Items/Tech/Door/TransparentDoor)&&!istype(src, /obj/Items/Tech/Door/LazerDoor))
				opacity=1
			if(icon=='Doors.dmi')
				flick("Closing[typee]",src)
				icon_state="Closed[typee]"
			else
				flick("Closing",src)
				icon_state="Closed"
		verb/Lock_Doors()
			set src in range(1, usr)
			if(src.Password)
				var/Unlocked=0
				for(var/obj/Items/Tech/Door_Pass/L in usr)
					if(L.Password==src.Password)
						Unlocked=1
				for(var/obj/Items/Tech/Digital_Key/C in usr)
					if(C.Password==src.Password||C.Password2==src.Password||C.Password3==src.Password)
						Unlocked=1
				if(!Unlocked)
					var/Pass=input(usr, "What is the password of this door?", "Toggle Open") as text
					if(src.Password!=Pass)
						usr << "That is not the correct password."
						return
			if(src.AutoOpen==0)
				src.AutoOpen=1
				usr << "This door will be open for all."
			else
				src.AutoOpen=0
				usr << "This door will not open unless manually unlocked."


	Lockpick
		TechType="Forge"
		SubType="Locksmithing"
		Cost=0.05
		desc="You can attempt to open a door with it, but it carries a risk of the lockpick breaking."
		icon='Lockpick.dmi'
		Click()
			..()
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				return
			if(!(usr in range(1,src))) return
			var/list/Choices=new
			for(var/atom/O in get_step(usr,usr.dir))
				if(istype(O,/obj/Items/Tech/Door))
					if(O:GodDoor)
						Choices-=O
					else
						Choices+=O
				if(istype(O,/obj/Items/Tech/Door/LazerDoor))
					Choices-=O
			var/obj/Items/Tech/Door/P=input(usr,"Lockpick what?") in Choices
			if(!P)
				usr << "There's nothing to unlock!"
				return
			else
				if(!P.Password)
					usr << "The door isn't locked!"
					return
				if(prob(35*usr.Intelligence))
					P.Password=null
					usr << "You unlock the door!"
				else
					usr << "You fail to unlock the door!"
				if(prob(70/usr.Intelligence))
					usr << "<font color='red'>The lockpick broke!</font>"
					del src


	Conservation_Kit
		TechType="RepairAndConversion"
		SubType="Any"
		icon='Tech.dmi'
		icon_state="Conservation"
		Cost=0.05
		Stackable=1
		Click()
			if(!(src in usr))
				..()
			else
				if(src.Using)
					usr << "You're already using this!"
					return
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(usr.icon_state!="Meditate")
					usr << "You need to be sitting down to use this properly."
					return
				Using=1
				var/list/obj/Items/Bork=list("Cancel")
				for(var/obj/Items/Stuff in usr)
					if(Stuff.Repairable)
						Bork.Add(Stuff)
				if(Bork.len<2)
					usr << "You don't have any equipment that can be polished."
					src.Using=0
					return
				var/obj/Items/Choice=input(usr, "Select a piece to tend to..", "Conservation Kit") in Bork
				if(Choice=="Cancel")
					src.Using=0
					return
				if(Choice.Broken)
					usr << "You need to get [Choice] reforged.  It is already broken."
					src.Using=0
					return
				usr.Frozen=2
				usr << "Repairing [Choice]... (This will take 15 seconds)"
				sleep(150)
				usr.Frozen=0
				usr << "Finished repairing [Choice]."
				Choice.ShatterCounter=Choice.ShatterMax
				src.TotalStack--
				if(src.TotalStack<=0)
					del src
				src.suffix="[src.TotalStack]"
				src.Using=0

	Fiber_Bonding_Agent
		TechType="RepairAndConversion"
		SubType="Molecular Technology"
		icon='Tech.dmi'
		icon_state="Fiber Bond"
		Cost=5
		desc="This will apply a permanent level of brittleness to the equipment while improving its damage."
		Stackable=1
		Click()
			if(!(src in usr))
				..()
			else
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(src.Using)
					usr << "You're already using this!"
					return
				if(usr.icon_state!="Meditate")
					usr << "You need to be sitting down to use this properly."
					return
				Using=1
				var/list/obj/Items/Sharp=list("Cancel")
				for(var/obj/Items/Stuff in usr)
					if(istype(Stuff, /obj/Items/Armor))
						continue
					if(Stuff.Repairable&&!Stuff.Conversions)
						Sharp.Add(Stuff)
				if(Sharp.len<2)
					usr << "You don't have any equipment that can be treated!"
					src.Using=0
					return
				var/obj/Items/Choice=input(usr, "Select a piece to tend to.", "Fiber Bonding Agent") in Sharp
				if(Choice=="Cancel")
					src.Using=0
					return
				if(istype(Choice, /obj/Items/Sword)&&!Choice.LegendaryItem)
					var/Option2=alert(usr, "Do you want to apply a single conversion?", "Fiber Bonding Agent", "No", "Yes")
					if(Option2=="No")
						return
				usr.Frozen=2
				usr << "Bonding [Choice] with fibers... (This will take 15 seconds)"
				sleep(150)
				usr.Frozen=0
				usr << "Finished bonding [Choice]."
				Choice.ShatterTier+=1
				Choice.Conversions="Sharp"//This will flag another shatter tier which won't be repaired by reforging
				src.TotalStack--
				if(src.TotalStack<=0)
					del src
				src.suffix="[src.TotalStack]"
				src.Using=0

	Quicksilver_Alloy
		TechType="RepairAndConversion"
		SubType="Light Alloys"
		icon='Tech.dmi'
		icon_state="Quicksilver"
		Cost=5
		desc="This will apply a permanent level of brittleness to the equipment while improving its speed capabilities.  With ten of these, you can transform a light or medium sword into a glass blade."
		Stackable=1
		Click()
			if(!(src in usr))
				..()
			else
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(src.Using)
					usr << "You're already using this!"
					return
				if(usr.icon_state!="Meditate")
					usr << "You need to be sitting down to use this properly."
					return
				Using=1
				var/list/obj/Items/Sharp=list("Cancel")
				for(var/obj/Items/Stuff in usr)
					if(istype(Stuff, /obj/Items/Armor))
						continue
					if(Stuff.Repairable&&!Stuff.Conversions)
						Sharp.Add(Stuff)
				if(Sharp.len<2)
					usr << "You don't have any equipment that can be treated!"
					src.Using=0
					return
				var/obj/Items/Choice=input(usr, "Select a piece to tend to.", "Quicksilver Alloy") in Sharp
				if(Choice=="Cancel")
					src.Using=0
					return
				if(istype(Choice, /obj/Items/Sword)&&!Choice.LegendaryItem)
					if((Choice.Class=="Light"||Choice.Class=="Medium")&&Choice.Destructable)
						if(src.TotalStack>=10)
							var/Option=alert(usr, "Do you want to consume 10 alloys to form [Choice] into a Glass Sword?", "Quicksilver Alloy", "No", "Yes")
							var/image/i
							if(Option=="Yes")
								OMsg(usr, "[usr] has transformed [Choice] into a glass sword!")
								src.TotalStack-=10
								Choice.Glass=1
								i=image(icon=Choice.icon, pixel_x=Choice.pixel_x, pixel_y=Choice.pixel_y)
								i.color=list(0.5,1,1, 0,1,1, 0,0.5,1, 0,0,0)
								i.alpha=200
								Choice.icon=i
								src.Using=0
								if(src.TotalStack<=0)
									del src
								return
						var/Option2=alert(usr, "Do you want to apply a single conversion?", "Quicksilver Coating", "No", "Yes")
						if(Option2=="No")
							return
				usr.Frozen=2
				usr << "Alloying [Choice] with quicksilver... (This will take 15 seconds)"
				sleep(150)
				usr.Frozen=0
				usr << "Finished quicksilver bonding [Choice]."
				Choice.ShatterMax/=2
				Choice.ShatterMax=round(Choice.ShatterMax)
				if(Choice.ShatterCounter>Choice.ShatterMax)
					Choice.ShatterCounter=Choice.ShatterMax
				Choice.Conversions="Light"
				src.TotalStack--
				if(src.TotalStack<=0)
					del src
				src.suffix="[src.TotalStack]"
				src.Using=0

	Trick_Weapon_Kit
		TechType="RepairAndConversion"
		SubType="Modular Weaponry"
		icon='Tech.dmi'
		icon_state="Modular"
		Cost=25
		desc="This can be used to transform an unconverted sword into a trick weapon. Trick weapons can be used to swap between two different forms."
		Stackable=1
		Click()
			if(!(src in usr))
				..()
			else
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(src.Using)
					usr << "You're already using this!"
					return
				if(usr.icon_state!="Meditate")
					usr << "You need to be sitting down to use this properly."
					return
				Using=1
				var/list/obj/Items/Mod=list("Cancel")
				for(var/obj/Items/Stuff in usr)
					if(istype(Stuff, /obj/Items/Armor))
						continue
					if(istype(Stuff, /obj/Items/Enchantment/Staff))
						continue
					if(Stuff.Repairable&&!Stuff.Conversions&&!Stuff.suffix&&Stuff.Ascended<3)
						Mod.Add(Stuff)
				if(Mod.len<2)
					usr << "You don't have any equipment that can be treated!"
					src.Using=0
					return
				var/obj/Items/Choice=input(usr, "Select a piece to tend to.", "Trick Weapon Kit") in Mod
				if(Choice=="Cancel")
					src.Using=0
					return
				usr.Frozen=2
				var/Lock=alert(usr, "What icon will the alternate weapon form use?", "Trick Weapon Kit", "Current", "New")
				if(Lock=="New")
					Choice:iconAlt=input(usr, "What icon will your Trick Weapon alternate state use?", "Trick Weapon Icon") as icon|null
					Choice:iconAltX=input(usr, "Pixel X offset.", "Trick Weapon Icon") as num
					Choice:iconAltY=input(usr, "Pixel Y offset.", "Trick Weapon Icon") as num
				var/Choice2=input(usr, "What class of weapon do you wish the alternate mode to be?", "Trick Weapon Kit") in list("Light", "Medium", "Heavy")
				Choice:ClassAlt="[Choice2]"
				Choice.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/WeaponSystems/Alternate_Mode")
				Choice:LegendaryItem=1
				usr << "Installing modular frame within [Choice]... (This will take 30 seconds)"
				sleep(300)
				usr.Frozen=0
				usr << "Finished tricking out [Choice]."
				Choice.Conversions="Trick"

				src.TotalStack--
				if(src.TotalStack<=0)
					del src
				src.suffix="[src.TotalStack]"
				src.Using=0

	Resistant_Coating
		TechType="RepairAndConversion"
		SubType="Shock Absorbers"
		icon='Tech.dmi'
		icon_state="Resin"
		Cost=5
		desc="This will apply an additional level of durability to an item, but it comes at the cost of motion precision.  With 10, you can add an indestructable and light overlay to armors!"
		Stackable=1
		Click()
			if(!(src in usr))
				..()
			else
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(src.Using)
					usr << "You're already using this!"
					return
				if(usr.icon_state!="Meditate")
					usr << "You need to be sitting down to use this properly."
					return
				Using=1
				var/list/obj/Items/Sharp=list("Cancel")
				for(var/obj/Items/Stuff in usr)
					if(Stuff.Repairable&&!Stuff.Conversions)
						Sharp.Add(Stuff)
				if(Sharp.len<2)
					usr << "You don't have any equipment that can be treated!"
					src.Using=0
					return
				var/obj/Items/Choice=input(usr, "Select a piece to tend to.", "Resistant Coating") in Sharp
				if(Choice=="Cancel")
					src.Using=0
					return
				if(istype(Choice, /obj/Items/Armor)&&!Choice.LegendaryItem)
					if(src.TotalStack>=10)
						var/Option=alert(usr, "Do you want to consume 10 coatings to form [Choice] into Shock-Resistant Armor?", "Resistant Coating", "No", "Yes")
						if(Option=="Yes")
							OMsg(usr, "[usr] has transformed [Choice] into an indestructable armor!")
							src.TotalStack-=10
							Choice.Destructable=0
							Choice.icon='Armor-Modern.dmi'
							src.Using=0
							if(src.TotalStack<=0)
								del src
							return
						var/Option2=alert(usr, "Do you want to apply a single conversion?", "Resistant Coating", "No", "Yes")
						if(Option2=="No")
							return
				usr.Frozen=2
				usr << "Applying coating to [Choice]... (This will take 15 seconds)"
				sleep(150)
				usr.Frozen=0
				usr << "Finished adding resistant coating to [Choice]."
				Choice.ShatterMax*=2
				Choice.ShatterCounter=Choice.ShatterMax
				Choice.Conversions="Hardened"
				src.TotalStack--
				if(src.TotalStack<=0)
					del src
				src.suffix="[src.TotalStack]"
				src.Using=0


	First_Aid_Kit
		Cost=0.25
		TechType="Medicine"
		SubType="Any"
		icon='Tech.dmi'
		icon_state="FirstAid"
		desc="This will stablize mortal wounds and treat less serious injuries.  It can be used on yourself."
		Click()
			if(!(src in usr))
				..()
			else
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(usr.KO)
					usr << "You can't use a first aid kit while knocked out!"
					return
				if(src.Using)
					usr << "You're already using this."
					return
				if(!usr.Move_Requirements())
					return
				src.Using=1
				var/list/mob/Players/People=list("Cancel")
				for(var/mob/Players/A in view(1,usr))
					People.Add(A)
				if(People.len<2)//somehow...
					usr << "There's no one nearby."
					src.Using=0
					return
				var/mob/Players/Choice=input("Select a target to use the first aid kit on.") in People
				if(Choice=="Cancel")
					src.Using=0
					return
				usr.Frozen=2
				Choice.Frozen=2
				usr << "Applying first aid to [Choice]...(This will take 15 seconds)"
				Choice << "[usr] is using a first aid kit on you...(This will take 15 seconds)"
				sleep(150)
				usr.Frozen=0
				Choice.Frozen=0
				if(Choice.MortallyWounded)
					Choice.TsukiyomiTime=1
					Choice.MortallyWounded=0
					usr<<"You stabilize [Choice]'s internal injuries."
					Choice<<"[usr] has stabilized your internal injuries."
				if(Choice.KO)
					Choice.Conscious()
				var/heal = 8 + (0.15 * Choice.TotalInjury)
				if(heal > 40)
					heal = 40
				Choice.HealWounds(heal)
				del(src)

	Medkit
		Cost=0.5
		TechType="Medicine"
		SubType="Medkits"
		icon='Tech.dmi'
		icon_state="Medkit"
		desc="This will heal the health and injury of a character."
		Click()
			if(!(src in usr))
				..()
			else
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(usr.KO)
					usr << "You can't use a medkit while knocked out!"
					return
				if(src.Using)
					usr << "You're already using this."
					return
				if(usr.icon_state!="Meditate"&&usr.icon_state!="KO")
					usr << "You need to be laying down to use this properly."
					return
				src.Using=1
				var/list/mob/Players/People=list("Cancel")
				for(var/mob/Players/A in view(1,usr))
					if(A.Secret=="Heavenly Restriction" && A.secretDatum?:hasRestriction("Science"))
						continue
					People.Add(A)
				if(People.len<2)//somehow...
					usr << "There's no one to use the medkit on."
					src.Using=0
					return
				var/mob/Players/Choice=input("Select a target to use the medkit on.") in People
				if(Choice=="Cancel")
					src.Using=0
					return
				var/Confirm
				if(!Choice.KO&&Choice!=usr)
					Confirm=alert(Choice, "[usr] wants to use a medkit on you; do you allow this?", "Medkit", "No", "Yes")
				if(Confirm=="No")
					usr << "[Choice] rejected the assistance."
					src.Using=0
					return
				usr.Frozen=2
				if(Choice!=usr)
					Choice.Frozen=2
					usr << "Applying medkit to [Choice]...(This will take 15 seconds)"
					Choice << "[usr] is using a medkit on you...(This will take 15 seconds)"
				else
					usr << "You're using the medkit on yourself...(This will take 30 seconds)"
				if(usr==Choice)
					sleep(300)
				else
					sleep(150)
				usr.Frozen=0
				if(Choice!=usr)
					Choice.Frozen=0
					usr << "Finished applying medkit to [Choice]."
				else
					usr << "Finished applying medkit."
				if(Choice.MortallyWounded)
					Choice.MortallyWounded=0
					Choice.TsukiyomiTime=1
					usr<<"You stabilize [Choice]'s internal injuries."
					Choice<<"[usr] has stabilized your internal internal."
				if(Choice.KO)
					Choice.Conscious()
				var/heal= 15 + (0.3 * Choice.TotalInjury)
				if(heal > 40)
					heal = 40
				Choice.HealWounds(heal)
				Choice.HealHealth(heal/2)
				Choice.Doped=RawMinutes(heal)
				del(src)

	Fast_Acting_Antivenom
		name="Fast-Acting Antivenom"
		Cost=0.2
		TechType="Medicine"
		SubType="Fast Acting Medicine"
		icon='Lab.dmi'
		icon_state="AVenom"
		desc="This is used to decrease poison instantly, and it will also provide resistance for a while longer."
		verb/Apply(mob/m in view(1))
			set name = "Apply"
			set hidden = 1
			if(m) Use(m)
		verb/ApplySelf()
			set name = "Apply Self"
			set hidden = 1
			Use(usr)
		Click()
			if(!(src in usr))
				..()
			else
				Use()

		proc/Use(mob/Choice = null)
			if(src in usr)
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(usr.KO)
					usr << "You can't use an antivenom while knocked out!"
					return
				if(src.Using)
					usr << "You're already using this."
					return
				if(!usr.Move_Requirements())
					return
				src.Using=1
				if(!Choice)
					var/list/mob/Players/People=list("Cancel")
					for(var/mob/Players/A in view(1,usr))
						if(A.Secret=="Heavenly Restriction" && A.secretDatum?:hasRestriction("Science"))
							continue
						People.Add(A)
					if(People.len<2)//somehow...
						usr << "There's no one to use the antivenom on."
						src.Using=0
						return
					Choice=input("Select a target to use the antivenom on.") in People
				if(Choice=="Cancel")
					src.Using=0
					return
				var/Confirm
				if(!Choice.KO&&Choice!=usr)
					Confirm=alert(Choice, "[usr] wants to use an antivenom on you; do you allow this?", "Antivenom", "No", "Yes")
				if(Confirm=="No")
					usr << "[Choice] rejected the assistance."
					src.Using=0
					return
				if(!Choice.Antivenomed)
					Choice.Antivenomed=200
					Choice.Poison-=5
					del(src)
				else
					if(Choice!=usr)
						usr << "They've already had antivenom applied!"
					else
						usr << "You've already had antivenom applied!"
				src.Using=0
	Cooling_Spray
		Cost=0.2
		name="Isothermic Spray"
		TechType="Medicine"
		SubType="Fast Acting Medicine"
		icon='Lab.dmi'
		icon_state="TRegulator"
		desc="This is used to decrease burn and chill instantly.  It will also provide some resistance afterwards."
		verb/Apply(mob/m in view(1))
			set name = "Apply"
			set hidden = 1
			if(m) Use(m)
		verb/ApplySelf()
			set name = "Apply Self"
			set hidden = 1
			Use(usr)
		Click()
			if(!(src in usr))
				..()
			else
				Use()

		proc/Use(mob/Choice = null)
			if(src in usr)
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(usr.KO)
					usr << "You can't use a cooling spray while knocked out!"
					return
				if(src.Using)
					usr << "You're already using this."
					return
				if(!usr.Move_Requirements())
					return
				src.Using=1
				if(!Choice)
					var/list/mob/Players/People=list("Cancel")
					for(var/mob/Players/A in view(1,usr))
						if(A.Secret=="Heavenly Restriction" && A.secretDatum?:hasRestriction("Science"))
							continue
						People.Add(A)
					if(People.len<2)//somehow...
						usr << "There's no one to use the cooling spray on."
						src.Using=0
						return
					Choice=input("Select a target to use the cooling spray on.") in People
				if(Choice=="Cancel")
					src.Using=0
					return
				var/Confirm
				if(!Choice.KO&&Choice!=usr)
					Confirm=alert(Choice, "[usr] wants to use a cooling spray on you; do you allow this?", "Cooling Spray", "No", "Yes")
				if(Confirm=="No")
					usr << "[Choice] rejected the assistance."
					src.Using=0
					return
				if(!Choice.Cooled)
					Choice.Cooled=200
					Choice.Burn-=20
					Choice.Slow-=20
					del(src)
				else
					if(Choice!=usr)
						usr << "They've already had icy hot applied!"
					else
						usr << "You've already had icy hot applied!"
				src.Using=0
	Sealing_Spray
		Cost=0.2
		TechType="Medicine"
		SubType="Fast Acting Medicine"
		icon='Lab.dmi'
		icon_state="SSpray"
		desc="This is used to decrease shatter, shear and cripple instantly.  It will also provide some resistance afterwards."
		verb/Apply(mob/m in view(1))
			set name = "Apply"
			set hidden = 1
			if(m) Use(m)
		verb/ApplySelf()
			set name = "Apply Self"
			set hidden = 1
			Use(usr)
		Click()
			if(!(src in usr))
				..()
			else
				Use()

		proc/Use(mob/Choice = null)
			if(src in usr)
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(usr.KO)
					usr << "You can't use a sealing spray while knocked out!"
					return
				if(src.Using)
					usr << "You're already using this."
					return
				if(!usr.Move_Requirements())
					return
				src.Using=1
				if(!Choice)
					var/list/mob/Players/People=list("Cancel")
					for(var/mob/Players/A in view(1,usr))
						if(A.Secret=="Heavenly Restriction" && A.secretDatum?:hasRestriction("Science"))
							continue
						People.Add(A)
					if(People.len<2)//somehow...
						usr << "There's no one to use the sealing spray on."
						src.Using=0
						return
					Choice=input("Select a target to use the cooling spray on.") in People
				if(Choice=="Cancel")
					src.Using=0
					return
				var/Confirm
				if(!Choice.KO&&Choice!=usr)
					Confirm=alert(Choice, "[usr] wants to use a sealing spray on you; do you allow this?", "Sealing Spray", "No", "Yes")
				if(Confirm=="No")
					usr << "[Choice] rejected the assistance."
					src.Using=0
					return
				if(!Choice.Sprayed)
					Choice.Sprayed=200
					Choice.Crippled-=20
					Choice.Sheared-=20
					del(src)
				else
					if(Choice!=usr)
						usr << "They've already had sealing spray applied!"
					else
						usr << "You've already had sealing spray applied!"
				src.Using=0
	Focus_Stabilizer
		Cost=0.2
		TechType="Medicine"
		SubType="Fast Acting Medicine"
		icon='Lab.dmi'
		icon_state="FStabilizer"
		desc="This is used to decrease shock and confusion instantly.  It will also provide some resistance afterwards."
		verb/Apply(mob/m in view(1))
			set name = "Apply"
			set hidden = 1
			if(m) Use(m)
		verb/ApplySelf()
			set name = "Apply Self"
			set hidden = 1
			Use(usr)
		Click()
			if(!(src in usr))
				..()
			else
				Use()

		proc/Use(mob/Choice = null)
			if(src in usr)
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(usr.KO)
					usr << "You can't use a stabilizer while knocked out!"
					return
				if(src.Using)
					usr << "You're already using this."
					return
				if(!usr.Move_Requirements())
					return
				src.Using=1
				if(!Choice)
					var/list/mob/Players/People=list("Cancel")
					for(var/mob/Players/A in view(1,usr))
						if(A.Secret=="Heavenly Restriction" && A.secretDatum?:hasRestriction("Science"))
							continue
						People.Add(A)
					if(People.len<2)//somehow...
						usr << "There's no one to use the stabilizer on."
						src.Using=0
						return
					Choice=input("Select a target to use the stabilizer on.") in People
				if(Choice=="Cancel")
					src.Using=0
					return
				var/Confirm
				if(!Choice.KO&&Choice!=usr)
					Confirm=alert(Choice, "[usr] wants to use a focus stabilizer on you; do you allow this?", "Focus Stabilizer", "No", "Yes")
				if(Confirm=="No")
					usr << "[Choice] rejected the assistance."
					src.Using=0
					return
				if(!Choice.Stabilized)
					Choice.Stabilized=200
					Choice.Shock-=20
					Choice.Confused-=20
					del(src)
				else
					if(Choice!=usr)
						usr << "They've already had focus stabilizer applied!"
					else
						usr << "You've already had focus stabilizer applied!"
				src.Using=0

	Steroid
		Cost=0.5
		TechType="Medicine"
		SubType="Enhancers"
		icon='Steroid.dmi'
		desc="Steroids will boost your power for a short duration with a crash following afterwards."
		verb/Apply(mob/m in view(1))
			set name = "Apply"
			set hidden = 1
			if(m) Use(m)
		verb/ApplySelf()
			set name = "Apply Self"
			set hidden = 1
			Use(usr)
		Click()
			if(!(src in usr))
				..()
			else
				Use()

		proc/Use(mob/Choice = null)
			if(src in usr)
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(usr.KO)
					usr << "You can't use a steroid while knocked out!"
					return
				if(src.Using)
					usr << "You're already using this."
					return
				if(!usr.Move_Requirements())
					return
				src.Using=1
				if(!Choice)
					var/list/mob/Players/People=list("Cancel")
					for(var/mob/Players/A in view(1,usr))
						if(A.Secret=="Heavenly Restriction" && A.secretDatum?:hasRestriction("Science"))
							continue
						People.Add(A)
					if(People.len<2)//somehow...
						usr << "There's no one to use the steroid on."
						src.Using=0
						return
					Choice=input("Select a target to use the steroid on.") in People
				if(Choice=="Cancel")
					src.Using=0
					return
				var/Confirm
				if(!Choice.KO&&Choice!=usr)
					Confirm=alert(Choice, "[usr] wants to use a steroid on you; do you allow this?", "Steroid", "No", "Yes")
				if(Confirm=="No")
					usr << "[Choice] rejected the 'assistance'."
					src.Using=0
					return
				if(!Choice.Roided)
					Choice.Roided=240
					Choice<<"You've had a steroid applied to you!  Your power is increased!"
					del(src)
				else
					if(Choice!=usr)
						usr << "They've already had steroids applied!"
					else
						usr << "You've already had steroids applied!"
				src.Using=0

	Anesthetics
		Cost= 6
		Stackable=1
		TechType="REMOVED"
		SubType="Anesthetics"
		icon='Anesthetics.dmi'
		desc="Prepares an attack that will soothe a target's anger for a duration."
		Click()
			if(!(src in usr))
				..()
			else
				if(usr.KO)
					usr << "You can't prepare an anesthetic while knocked out!"
					return
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(!usr.Move_Requirements())
					return
				if(!usr.AttackQueue)
					usr.SetQueue(new/obj/Skills/Queue/Anesthetic_Strike)
				if(src.TotalStack>1)
					src.TotalStack--
				else
					del src
	PainKillers
		Cost=0.25
		TechType="Medicine"
		SubType="Anesthetics"
		icon='Lab.dmi'
		icon_state="KeloPill"
		desc="Use this to partly ignore reduced BP due to wounds."
		verb/Use()
			set src in usr
			if(!usr.Move_Requirements())
				return
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				return
			var/validkitters=list("Cancel")
			for(var/mob/Players/A in view(1,usr))
				if(A.Secret=="Heavenly Restriction" && A.secretDatum?:hasRestriction("Science"))
					continue
				validkitters+=A
			var/mob/selection=input("Select a target to use the pain killers on.") in validkitters
			if(selection=="Cancel")
				return
			if(selection.Doped)
				usr<<"They're already doped up."
				return
			usr<<"Applying pain killers to [selection]!"
			selection.Doped=RawHours(2)
			del(src)


	Regenerator_Tank
		TechType="ImprovedMedicalTechnology"
		SubType="Regenerator Tanks"
		var/HealingEffectiveness=1
		icon='Lab.dmi'
		icon_state="Tube"
		var/OverlayKiller=0
		density=1
		Cost=25
		Pickable=0
		New()
			var/image/A=image(icon='Lab.dmi',icon_state="TubeTop",layer=5,pixel_y=32)
			overlays-=A
			if(src.icon=='Lab.dmi')
				overlays+=A
			if(src)
				Regenerator()
				src.OverlayKiller=0
		verb/Upgrade()
			set category=null
			set src in oview(1, usr)
			var/found=0
			if(usr.ImprovedMedicalTechnologyUnlocked>src.HealingEffectiveness)
				src.HealingEffectiveness=usr.ImprovedMedicalTechnologyUnlocked
				found=1
			if(found)
				OMsg(usr, "[usr] uses their knowledge to upgrade the effectiveness of [src]!")
			else
				usr << "This tank is already as upgraded as you can make it."
		verb/Place_Person()
			set category=null
			set src in oview(1, usr)
			var/mob/Patient
			if(!usr.Grab||!istype(usr.Grab,/mob))
				usr << "You're not holding anyone."
				return
			else
				Patient=usr.Grab
				usr.Grab_Release()
				Patient.loc=get_step(src,NORTH)
		proc/Regenerator()
			set waitfor=0
			set background=1
			while(src)
				if(src.icon!='Lab.dmi'&&src.OverlayKiller==0)
					src.overlays-=src.overlays
					src.underlays-=src.underlays
					src.OverlayKiller=1
					src.layer=5
				var/list/mobs_in_regen = list()
				for(var/mob/A in get_step(src,NORTH))
					mobs_in_regen += A

				if(mobs_in_regen.len >= 2)
					oview(10,src) << "The [src] launches everybody from inside it."
					for(var/mob/m in mobs_in_regen)
						m.BeginKB(pick(NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTHWEST,WEST,NORTHWEST), 2)
						sleep(1)
					sleep(10)
					continue
				else
					for(var/mob/A in mobs_in_regen)
						if(A.Secret=="Heavenly Restriction" && A.secretDatum?:hasRestriction("Science"))
							continue
						if(A.icon_state!="Meditate")
							A.icon_state="Meditate"
						if(A.Swim==1)
							A<< "Your Regeneration tank has sunk underwater, and crushed by water pressure!"
							del src
						if(A.Burn>0)
							A.Burn=0
						if(A.Poison>0)
							A.Poison-=1*src.HealingEffectiveness
						if(A.BPPoison)
							A.BPPoisonTimer-=1*src.HealingEffectiveness
						if(A.TotalInjury)
							A.Recover("Injury", 1*A.TotalInjury*src.HealingEffectiveness)
						if(A.TotalFatigue)
							A.Recover("Fatigue",1*A.TotalFatigue*src.HealingEffectiveness)
						A.Recover("Health",1*src.HealingEffectiveness)
						A.Recover("Energy",1*src.HealingEffectiveness)
						if(A.SenseRobbed)
							A.SenseRobbed=max(A.SenseRobbed-0.002*src.HealingEffectiveness,0)
						if(A.MortallyWounded<=src.HealingEffectiveness)
							A.MortallyWounded=0
							A.TsukiyomiTime=1
						A.Conscious()
				sleep(10)



	Genome_Warp_Serum
		TechType="ImprovedMedicalTechnology"
		SubType="Genetic Manipulation"
		icon='Tech.dmi'
		icon_state="Genome"
		desc="A consumable item that will allow you to reset all stats... and other previously defined attributes."
		Cost=25
		Unobtainable=1
		Click()
			if(!(src in usr))
				..()
			else
				if(src.Using)
					usr << "You're already warping your genome!"
					return
				if(usr.isRace(ANDROID))
					return
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(usr.icon_state!="Meditate")
					usr << "You need to be sitting down to use this properly."
					return
				src.Using=1
				var/Confirm=alert(usr, "Are you sure you want to reset all of your stats?", "Genome Warp", "No", "Yes")
				if(Confirm=="No")
					src.Using=0
					return
				if(usr.transActive)
					usr << "Revert from your transformation before using this!"
					src.Using=0
					return
				if(usr.ActiveBuff||usr.SpecialBuff||usr.SlotlessBuffs.len>0)
					usr << "Turn off all buffs before using this!"
					src.Using=0
					return
				usr.Finalize(Warped=1)
				usr.Gender=alert(usr, "What gender do you want to be?", "Genome Warp", "Male", "Female")
				usr.gender = lowertext(usr.Gender)
				var/Sin=alert(usr, "Do you want to possess animal attributes?", "Genome Warp", "No", "Yes")
				if(Sin=="Yes")
					var/Choice=input(usr, "What animal do you want the characteristics of?", "Genome Warp") in list("Cat", "Fox", "Racoon", "Wolf", "Lizard", "Crow", "Bull")
					switch(Choice)
						if("Cat")
							usr.Neko=1
						if("Fox")
							usr.Kitsune=1
						if("Racoon")
							usr.Tanuki=1
						if("Wolf")
							usr.Wolf=1
						if("Lizard")
							usr.Lizard=1
						if("Crow")
							usr.Tengu=1
						if("Bull")
							usr.Bull=1
					var/Color=input(usr,"Choose color") as color|null
					usr.Trait_Color=Color
					usr.contents+=new/obj/FurryOptions
					usr.Hairz("Remove")
					usr.Hairz("Add")
				else
					if(locate(/obj/FurryOptions, usr))
						usr.Neko=0
						usr.Kitsune=0
						usr.Tanuki=0
						usr.Wolf=0
						usr.Lizard=0
						usr.Tengu=0
						usr.Bull=0
						usr.FurryTail=0
						usr.FurryEars=0
						for(var/obj/FurryOptions/Shame in usr)
							del Shame
						usr.Hairz("Remove")
						usr.Hairz("Add")
				src.Using=0
				del src
	Genome_Enhance_Serum
	//	TechType="ImprovedMedicalTechnology"
		icon='Tech.dmi'
		icon_state="GEnhance"
		desc="A consumable item that forces a person's biology to an empowered state at the cost of damaging their constitution."
		Cost=10000000000000000000000000
		Click()
			del src


	Revitalization_Serum
		TechType="ImprovedMedicalTechnology"
		SubType="Regenerative Medicine"
		icon='Tech.dmi'
		icon_state="Vitality"
		desc="A serum that can be used to instantly revitalize any accumulated weariness on the body - including a portion of damage thought to be permanent! But it can only be used every so often."
		Cost=250
		Click()
			if(!(src in usr))
				..()
			else
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(src.Using)
					usr << "You're already preparing a revitalization serum!"
					return
				if(usr.isRace(ANDROID))
					return
				if(usr.icon_state!="Meditate")
					usr << "You need to be sitting down to use this properly."
					return
				if(world.realtime<usr.NextSerum)
					usr << "It's too soon to use another revitalization serum!"
					return
				if(usr.usedSerums >= 6)
					usr << "You've used too many revitalization serums"
					return
				src.Using=1
				var/Confirm=alert(usr, "Do you want to inject a revitalization serum?", "Revitalization Serum", "No", "Yes")
				if(usr.Maimed<1)
					usr << "You have no maims!"
					src.Using=0
					return
				if(Confirm=="No")
					src.Using=0
					return
				if(usr.OverClockNerf)
					usr.OverClockNerf=0
					usr.OverClockTime=0
				if(usr.BPPoison<1)
					usr.BPPoison=1
					usr.BPPoisonTimer=0
				if(usr.SenseRobbed)
					if(usr.SenseRobbed>=5)
						animate(usr.client, color=null, time=1)
					usr.SenseRobbed=0
				if(usr.MortallyWounded)
					usr.MortallyWounded=0
				usr.Maimed--
				usr.TotalInjury=0
				usr.NextSerum=world.realtime+Day(0.5)
				usr << "You're fully revitalized!"
				src.Using=0
				del src

	Super_Soldier_Serum
		TechType = "ImprovedMedicalTechnology"
		SubType = "Regenerative Medicine"
		icon = 'Tech.dmi'
		icon_state = "Youth"
		desc = "A serum that restores all stat taxes and any cuts applied to your character."
		Cost = 100
		Click()
			if(!(src in usr))
				..()
			else
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					return
				if(src.Using)
					usr << "You're already preparing a super soldier serum!"
					return
				if(usr.isRace(ANDROID))
					return
				if(usr.icon_state!="Meditate")
					usr << "You need to be sitting down to use this properly."
					return
				Using=1
				var/Confirm=alert(usr, "Do you want to inject a super soldier serum?", "Super Soldier Serum", "No", "Yes")
				if(Confirm=="No")
					Using=0
					return
				usr.TotalInjury=0
				usr.TotalFatigue=0
				usr.TotalCapacity=0
				usr.StrTax=0
				usr.EndTax=0
				usr.SpdTax=0
				usr.ForTax=0
				usr.OffTax=0
				usr.DefTax=0
				usr.RecovTax=0
				usr.HealthCut=max(usr.HealthCut-0.1,0)
				usr.EnergyCut=max(usr.EnergyCut-0.1,0)
				usr.ManaCut=max(usr.ManaCut-0.1,0)
				usr.StrCut=max(usr.StrCut-0.1,0)
				usr.ForCut=max(usr.ForCut-0.1,0)
				usr.EndCut=max(usr.EndCut-0.1,0)
				usr.SpdCut=max(usr.SpdCut-0.1,0)
				usr.OffCut=max(usr.OffCut-0.1,0)
				usr.DefCut=max(usr.DefCut-0.1,0)
				usr.RecovCut=max(usr.RecovCut-0.1,0)
				usr << "You're fully revitalized!"
				OMsg(usr, "[usr] injects themselves with a super soldier serum, instantly restoring their body to peak condition!")
				Using=0
				del src

	Communicator
		TechType="Telecommunications"
		SubType="Any"
		icon='Communicator.dmi'
		Cost=0.1
		var/toggled_on = 1
		New()
			..()
			addToGlobalListeners(src)

		Del()
			removeFromGlobalListeners(src)
			..()

		broadcastToListeners(msg)
			if(!toggled_on) return
			..()

		recieveBroadcast(msg)
			if(!toggled_on) return
			..()

		verb/Toggle_Communicator()
			toggled_on = !toggled_on
			usr << "[src] is now [toggled_on ? "on" : "off"]."
			suffix = "[toggled_on ? "On -- Freq: [Frequency]" : "Off -- Freq:[Frequency]"]"

		verb/Communicator_Speak(Z as text)
			set src in usr
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] shorts out as [usr] tries to talk into it!")
				del src
				return
			suffix = "[toggled_on ? "On -- Freq: [Frequency]" : "Off -- Freq:[Frequency]"]"
			if(!toggled_on)
				usr << "You can't use this communicator while it's off."
				return
			if(usr.InMagitekRestrictedRegion())
				usr << "The communicator buzzes and loses power."
				return
			var/message = html_encode(Z)
			for(var/mob/E in hearers(12,usr))
				E<<"<font color=[usr.Text_Color]>[usr.name] speaks into a [src.name]: [message]"
			broadcastToListeners("[usr.name]: [message]")

		verb/Communicator_Frequency()
			set src in usr
			var/previousFreq = Frequency
			var/newFreq=input(usr,"Change your Communicator frequency to what?","Frequency",Frequency) as num
			if(previousFreq == newFreq) return
			removeFromGlobalListeners(src)
			Frequency = newFreq
			addToGlobalListeners(src)
			suffix = "[toggled_on ? "On -- Freq: [Frequency]" : "Off -- Freq:[Frequency]"]"
	PDA
		TechType="Telecommunications"
		SubType="Any"
		Cost=0.1
		var/htmlq={"<html><head><title>PDA Title!</title></head><body><body bgcolor=black text=white><h1>Heading!</h1><p>Paragraph!</body></html>"}
		icon='Tech.dmi'
		icon_state="PDA"
		verb/EditPDA()
			set src in usr
			if(Password)
				var/passcheck=input("Enter the edit password.") as text
				if(passcheck==Password)
					htmlq=input(usr,"Edit!","Edit Notes",htmlq) as message
				else
					usr<<"This console is password protected. Access denied."
			else
				htmlq=input(usr,"Edit!","Edit Notes",htmlq) as message
		verb/InputPassword()
			set src in view(1)
			if(Password)
				usr<<"This console already has a password. Disengaging interface."
			else
				Password=input("Enter the desired password.") as text
		verb/View()
			set src in view(1)
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				usr << "Your eyes seem to glaze over as you try to read the PDA..."
				return
			usr<<browse(htmlq,"window=PDA;size=400x400")

	Transmission_Tower
		TechType="Telecommunications"
		SubType="Wide Area Transmissions"
		icon='Beacon.dmi'
		Cost=2.5
		Grabbable=0
		Pickable=0
		density=1
		verb/Set_Password()
			set category=null
			set src in view(1, usr)
			if(src.Password)
				usr << "[src] already has a password set!"
				return
			src.Password=input(usr, "Enter the password you'd like [src] to have.", "Password") as text
		verb/Set_Frequency()
			set category=null
			set src in view(1, usr)
			if(!src.Password)
				usr << "Set a password on [src] first."
				return
			src.Frequency=input(usr, "Enter the frequency you'd like to tie to broadcasting messages.", "Frequency", src.Frequency) as num
	Beacon
		TechType="Telecommunications"
		SubType="Wide Area Transmissions"
		icon='device.dmi'
		icon_state="talarm0"
		Cost=1
		Grabbable=1
		Pickable=0
		var/BeaconState="Off"
		verb/SetPassword()
			set src in oview(1)
			if(Password)
				if((input("You must input the current password to make changes.") as text) != Password)
					usr << "Wrong Password"
					return
			Password = input("What would you like the new password to be for [src]?") as text
			if(Password) usr << "You've set the beacon's password to [Password]"
			else usr << "You've removed the beacon's password."
		verb/ToggleBeacon()
			set src in oview(1)
			if(Password)
				if((input("You must input the current password to make changes.") as text) != Password)
					usr << "Wrong Password"
					return
			if(src.BeaconState=="On")
				src.BeaconState="Off"
				src.icon_state="talarm0"
				usr<<"You've turned off the Beacon."
				return
			else
				src.BeaconState="On"
				src.icon_state="talarm1"
				usr<<"You've turned on the Beacon."
				return

	Wiretap
		TechType="Telecommunications"
		SubType="Espionage Equipment"
		icon='device.dmi'
		icon_state="headphones"
		Cost=0.25
		verb/Set_Frequency()
			set src in usr
			src.Frequency=input(usr, "Set the frequency that you will use to spy.", "Frequency", src.Frequency) as num
		verb/Plant_Wiretap()
			set src in usr
			if(src.Using)
				usr << "You're already planting this wiretap."
				return
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] explodes in [usr]'s hand!")
				del src
				return
			if(!src.Frequency)
				usr << "You need to set a frequency on the wiretap before planting it."
				return
			src.Using=1
			var/list/mob/Players/peeps=list("Cancel")
			for(var/mob/Players/p in oview(1, usr))
				if(p.Secret=="Heavenly Restriction" && p.secretDatum?:hasRestriction("Science"))
					continue
				peeps.Add(p)
			if(peeps.len<2)
				usr << "There's no one to plant the wire tap on."
				src.Using=0
				return
			var/mob/Players/Choice=input(usr, "Who do you want to plant your wiretap on?  They'll have a chance to notice this depending on their Telecommunications knowledge.", "Plant Wiretap") in peeps
			if(!(Choice in oview(1, usr)))
				usr << "[Choice] moved away before you could plant the wiretap..."
				src.Using=0
				return
			var/NoStealth=0
			var/Chance=5
			if(Choice.HasIntuition())
				Chance*=2
			Chance+=(5*Choice.TelecommunicationsUnlocked)+(10*Choice.AdvancedTransmissionTechnologyUnlocked)
			if(prob(Chance))
				Choice << "You notice [usr] planting a wiretap on you..."
				NoStealth=1
			var/obj/Items/Tech/Planted_Wiretap/WT=new/obj/Items/Tech/Planted_Wiretap
			if(NoStealth)
				WT.Revealed=1
			WT.Frequency=src.Frequency
			WT.name=src.name
			Choice.contents+=WT
			src.Using=0
			del src
	Planted_Wiretap
		var/Revealed=0
		New()
			..()
			addToGlobalListeners(src)

		Del()
			removeFromGlobalListeners(src)
			..()

		recieveBroadcast(msg)
			//wiretaps do not recieve

		verb/Remove_Wiretap()
			usr << "You remove the wiretap from your body, destroying it in the process."
			del(src)
	//TODO add camera functionality
	Hacking_Device
		TechType="Telecommunications"
		SubType="Espionage Equipment"
		Cost=0.5
		icon='HDevice.dmi'
		Stackable=1
		Click()
			if(!(src in usr))
				..()
			else
				if(src.Using)
					usr << "You're already using this!"
					return
				if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
					OMsg(usr, "[src] explodes in [usr]'s hand!")
					del src
					return
				src.Using=1
				var/list/obj/HackedIt=list("Cancel")
				for(var/obj/Items/Tech/o in range(usr, 1))
					if(o.Password&&o.TechType!="BasicTechnology")
						HackedIt.Add(o)
				for(var/obj/Items/Gear/o in range(usr, 1))
					if(o.Password&&o.TechType!="BasicTechnology")
						HackedIt.Add(o)
				if(HackedIt.len<2)
					usr << "There are no objects nearby to hack."
					src.Using=0
					return
				var/obj/Items/Tech/Choice=input(usr, "What object do you want to try to hack?", "Hackerman") in HackedIt
				if(Choice=="Cancel")
					src.Using=0
					return
				var/EnemyRoll=round(sqrt(Choice.Cost)*10)
				if(Choice.CreatorKey==usr.ckey)
					EnemyRoll=0
				var/YourRoll=usr.Intelligence*(usr.TelecommunicationsUnlocked+2*usr.AdvancedTransmissionTechnologyUnlocked)
				var/YourRoll2=roll("[round(YourRoll)]d5")
				if(YourRoll2>=EnemyRoll)
					OMsg(usr, "[usr] manages to break [Choice]!")
					usr << "The password of [Choice] is: [Choice.Password]"
					src.last_hacked_by = "[usr]([usr.key])"
				else
					OMsg(usr, "[usr] tries to hack [Choice], but they can't figure out how to do it!")
				src.TotalStack--
				if(src.TotalStack<=0)
					del src
				src.suffix="[src.TotalStack]"
				src.Using=0

	Security_Display
		TechType="Telecommunications"
		SubType="NOT IN"
		Cost=5
		Pickable=0
		var/Active=1
		var/Microphone=0
		icon='security.dmi'
		icon_state="display"
		var/list/StoredTechniques=list()
		var/AudioRange=6
		var/Updated=0
		verb/Download_Techniques()
			set src in view(1, usr)
			if(src.Password)
				var/PassCheck=input("Enter the display's password to download observed techniques.") as text
				if(PassCheck!=src.Password)
					usr<<"Incorrect password. Disengaging interface."
					return
			if(!("Combat Scanning" in usr.knowledgeTracker.learnedKnowledge))
				usr << "You don't know how to learn techniques from recordings!"
				return
			if(!Updated)
				src.Updated=1
				src.StoredTechniques=null
				src.StoredTechniques=list()
			var/list/Passwords=list()
			var/Current="Go"
			while(Current!="Begin"&&Current!=null&&Current)
				Current=input(usr, "Enter the password frequency of the camera(s) you wish to download.  To begin the download, enter 'Begin' or nothing.", "Download Techniques") as text|null
				if(Current!="Begin"&&Current)
					Passwords.Add(Current)
			if(Passwords.len>=1)
				for(var/CheckingPassword in Passwords)
					for(var/obj/Items/Tech/Security_Camera/SC in world)
						if(SC.Password==CheckingPassword)
							if(!SC.Updated)
								SC.Updated=1
								SC.ObservedTechniques=null
								SC.ObservedTechniques=list()//clear list
							for(var/x in SC.ObservedTechniques)
								src.StoredTechniques["[x]"]=SC.ObservedTechniques["[x]"]
			for(var/x in src.StoredTechniques)
				var/Learned=0
				var/obj/Skills/Tech=new x
				if(Tech.PreRequisite.len==0)
					var/Req=src.StoredTechniques["[x]"]
					if(usr.RPPMult*(1+usr.ParasiteCrest())*usr.Intelligence>=Req)
						if(!locate(Tech, usr))
							usr.AddSkill(Tech)
							Tech.Copied = TRUE
							Tech.copiedBy = "Combat Analysis"
							usr << "You've learned [Tech] from observing material stored in cameras!"
							Learned=1
				if(!Learned)
					del Tech
		verb/InputPassword()
			set name="Set Password"
			set src in view(1)
			if(Password)
				usr<<"This console already has a password. Disengaging interface."
			else
				Password=input("Enter the desired password.") as text
		verb/AdjustRange()
			set name="Adjust Range"
			set src in view(1)
			if(!Password)
				usr<<"This console is not password protected. Disengaging interface."
				InputPassword()
				return
			var/PassCheck=input("Enter the display's password to adjust range. Range only effects audio.") as text
			if(PassCheck==src.Password)
				src.AudioRange=input("Enter audio transmission range.") as num
				if(src.AudioRange>=12)
					src.AudioRange=12
				if(src.AudioRange<=3)
					src.AudioRange=3
			else
				usr<<"Incorrect password. Disengaging interface."
		verb/ToggleMicrophone()
			set src in view(1)
			set name="Toggle Microphone"
			if(src.Microphone==1)
				src.Microphone=0
				usr<<"Microphone disabled."
			else if(src.Microphone==0)
				src.Microphone=1
				usr<<"Microphone enabled."
		verb/ViewCamera()
			set src in view(1)
			set name="View Camera"
			var/list/availablecameras=list("Cancel")
			for(var/obj/Items/Tech/Security_Camera/F in world)
				if(F.Password==src.Password)
					availablecameras.Add(F)
			var/obj/Items/Tech/Security_Camera/pickcamera=input("")in availablecameras
			if(pickcamera=="Cancel")
				if(usr.client.perspective!=MOB_PERSPECTIVE)
					usr.client.perspective=MOB_PERSPECTIVE
				usr.client.eye=usr
				pickcamera.listening -= usr
				if(length(pickcamera.listening)==0)
					pickcamera.activeListeners = FALSE
			else
				if(usr.client.perspective!=EYE_PERSPECTIVE)
					usr.client.perspective=EYE_PERSPECTIVE
				usr.client.eye=pickcamera
				pickcamera.activeListeners = TRUE
				pickcamera.listening += usr
		verb/ToggleCamera()
			set src in view(1)
			set name="Turn On/Off"
			var/PassCheck=input("Enter Password.") as text
			if(PassCheck==src.Password)
				if(src.Active==1)
					src.Active=0
					usr<<"[src.name] powered down."
				else if(src.Active==0)
					src.Active=1
					usr<<"[src.name] powered up!"
	Security_Camera
		TechType="Telecommunications"
		SubType="NOT IN"
		Health=20
		Cost=0.5
		Pickable=1
		AllowBolt=1
		layer=7
		var/Updated=0
		var/list/ObservedTechniques=list()
		var/Active=1
		var/AudioRange=6
		var/tmp/mob/Players/list/listening=list()
		var/activeListeners = FALSE
		icon='security.dmi'
		icon_state="camera"
		New()
			..()
			addToGlobalListeners(src)

		Del()
			removeFromGlobalListeners(src)
			..()

		broadcastToListeners(msg)
			if(!Active) return
			..()
		recieveBroadcast(msg)
			if(!Active) return
			..()

		verb/InputPassword()
			set src in view(1)
			set name="Set Password"
			if(Password)
				usr<<"This camera already has a password. Disengaging interface."
				return
			else
				Password=input("Enter the desired password.") as text
		verb/ToggleCamera()
			set src in view(1)
			set name="Turn On/Off"
			var/PassCheck=input("Enter Password.") as text
			if(PassCheck==src.Password)
				if(src.Active==1)
					src.Active=0
					usr<<"[src.name] turned off."
				else if(src.Active==0)
					src.Active=1
					usr<<"[src.name] turned on!"
		verb/ChangeFace()
			set src in view(1)
			set name="Change Facing"
			var/Select=input("Which way?") in list("North","North2","East","East2","South","South2","West","West2")
			switch(Select)
				if("North")
					src.dir=NORTH
				if("North2")
					src.dir=SOUTHWEST
				if("East")
					src.dir=EAST
				if("East2")
					src.dir=NORTHEAST
				if("South")
					src.dir=SOUTH
				if("South2")
					src.dir=SOUTHEAST
				if("West")
					src.dir=WEST
				if("West2")
					src.dir=NORTHWEST
		Click()
			..()
			if(usr.client.perspective!=MOB_PERSPECTIVE)
				usr.client.perspective=MOB_PERSPECTIVE
			usr.client.eye=usr
			if(usr in src.listening)
				src.listening -= usr
				if(length(listening)==0)
					src.activeListeners = FALSE

	Binoculars
		Health=10
		TechType="Telecommunications"
		SubType="Local Range Devices"
		icon='Binoculars.dmi'
		Cost=0.2
		var/viewOld
		desc="Use this to increase your sight range temporarily."
		Click()
			if(!(src in usr))
				..()
			if(src.Using||usr.Observing)
				return
			else
				Using=1
				viewOld=usr.client.view
				usr.client.view="69x69"
				spawn(100)
					usr.client.view=viewOld
					viewOld=null
					Using=0
	Doorbell
		Health=10
		TechType="Telecommunications"
		SubType="Local Range Devices"
		Cost=0.1
		AllowBolt=1
		icon='Tech.dmi'
		icon_state="DoorBell"
		var/DoorBellMessage="Ding Dong!"
		verb/Press()
			set src in oview(1)
			if(src.icon_state=="DoorBellOn")
				usr<<"Don't keep ringing the doorbell. You might annoy someone!"
				return
			src.icon_state="DoorBellOn"
			spawn(30)
				src.icon_state="DoorBell"
			for(var/mob/Players/M in players)
				for(var/obj/Items/Tech/Scouter/Q in M)
					if(Q.Frequency==src.Frequency)
						M<<"<font color=cyan><b>([src.name])</b>: [html_encode(DoorBellMessage)]"
			for(var/mob/E in hearers(6,usr))
				E<<"<font color=cyan><b>([src.name])</b>: [html_encode(DoorBellMessage)]"
			for(var/obj/Items/Tech/Speaker/X in world)
				if(X.Frequency==src.Frequency&&X.Active==1)
					for(var/mob/Y in hearers(X.AudioRange,X))
						Y<<"<font color=cyan><b>([X.name]) </b>: [html_encode(DoorBellMessage)]"
		verb/DoorbellFrequency()
			set src in oview(1)
			Frequency=input(usr,"Change your doorbell frequency to what?","Frequency",Frequency)as num
		verb/ChangeDoorBellMessage(T as text)
			src.DoorBellMessage=T
	Speaker
		Health=10
		TechType="Telecommunications"
		SubType="Local Range Devices"
		Cost=0.1
		AllowBolt=1
		icon='Lab.dmi'
		icon_state="speaker"
		disabledFrequency = TRUE
		var/Intercom=0
		var/Active=1
		var/AudioRange=6
		verb/SpeakerFrequency()
			set src in oview(1)
			Frequency=input(usr,"Change your Speaker frequency to what?","Frequency",Frequency)as num
			disabledFrequency=FALSE
		verb/InputPassword()
			set src in view(1)
			if(Password)
				usr<<"This [src.name] already has a password. Disengaging interface."
			else
				Password=input("Enter the desired password.") as text
		verb/IntercomUpgrade()
			set src in oview(1)
			if(Intercom==1)
				usr<<"This is already a Intercom!"
				return
			else
				src.Intercom=1
				usr<<"You have upgraded [src.name] into a Intercom."
				src.name="Intercom"
				src.icon_state="com"
		verb/ToggleIntercom()
			set src in view(1)
			set name="Toggle Intercom"
			var/PassCheck=input("Enter Password.") as text
			if(PassCheck==src.Password)
				if(src.Active==1)
					src.Active=0
					usr<<"[src.name] Deactivated."
				else if(src.Active==0)
					src.Active=1
					usr<<"[src.name] Activated."
			else
				usr<<"Wrong password."
				return
		verb/AdjustRange()
			set src in view(1)
			var/PassCheck=input("Enter the display's password to adjust range.") as text
			if(PassCheck==src.Password)
				src.AudioRange=input("Enter audio transmission range.") as num
				if(src.AudioRange>=12)
					src.AudioRange=12
				if(src.AudioRange<=3)
					src.AudioRange=3
			else
				usr<<"Incorrect password. Disengaging interface."

	Scouter
		Health=5
		TechType="AdvancedTransmissionTechnology"
		SubType="Scouters"
		icon='GreenScouter.dmi'
		Cost=2
		var/ScouterIcon
		var/Range=1
		var/tmp/Detecting=0
		desc="This device uses technology to guage the power of the enemy. It can also find money. \n(Warning: This device isn't always accurate, and can be fooled by certain techniques.) \n((No Refunds))"
		verb/Scouter_Scan()
			set src in usr
			if(!(world.realtime>src.InternalTimer+Second(5)))
				usr << "The scanning device needs time to recharge."
				return
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] explodes in [usr]'s hand!")
				del src
				return
			src.InternalTimer=world.realtime
			if(!src.suffix=="*Equipped*")
				usr << "You have to equip the scouter to use it!"
				return
			if(usr.InMagitekRestrictedRegion())
				usr << "The scouter flashes with cryptic sequences before losing power."
				return
			usr << "<b>Current Coordinates: ([usr.x], [usr.y], [usr.z])</b>"
			for(var/obj/Items/Tech/Beacon/B in world)
				if(B.BeaconState=="On"&&usr.z==B.z)
					usr << "<b><font color='green'>(BEACON)</font color></b> - ([B.x], [B.y], [B.z])"
			for(var/obj/Items/Enchantment/PocketDimensionGenerator/W in world)
				if(usr.z==W.z)
					usr << "<b><font color='red'>(DISTURBANCE)</font color></b> - ([W.x], [W.y], [W.z])"
			for(var/mob/Players/M in players)
				if(!M.AdminInviso&&!M.HasVoid()&&!M.HasMechanized()&&!M.HasGodKi())
					if(M.z==usr.z)
						var/D=abs(M.x-usr.x)+abs(M.y-usr.y)
						if(D<=src.Range*60)
							if(D<16)
								usr << "<b>[M.name]</b> - [Commas(usr.Get_Scouter_Reading(M))] - [usr.CheckDirection(M)] - <b><font color='red'>NEARBY</font color></b>"
							else
								if(M.PowerControl>25)
									usr << "[Commas(usr.Get_Scouter_Reading(M))] - [usr.CheckDirection(M)] - [Commas(D)] tiles away"
			for(var/mob/Players/M in players)
				if(M.z==usr.z)
					var/D=abs(M.x-usr.x)+abs(M.y-usr.y)
					if(D<=src.Range*80)
						usr << "<b>!!!</b> - [usr.CheckDirection(M)] - [Commas(D)] tiles away"
		verb/Scouter_Speak(Z as text)
			set src in usr
			if(usr.InMagitekRestrictedRegion())
				usr << "The scouter buzzes and loses power."
				return
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] explodes in [usr]'s hand!")
				del src
				return
			var/FrequencySelector=src.Frequency
			for(var/mob/E in hearers(12,usr))
				E<<"<font color=[usr.Text_Color]>[usr] speaks into a [src]: [html_encode(Z)]"
			for(var/mob/Players/M in players)
				for(var/obj/Items/Tech/Scouter/Q in M)
					if(Q.Frequency==FrequencySelector)
						M<<"<font color=green><b>([Q.name])</b> [usr.name]: [html_encode(Z)]"
						M<< output("<font color=green><b>([Q.name])</b> [usr.name]: [html_encode(Z)]","icchat")
						Log(M.ChatLog(),"<font color=green>([src.name])[usr]([usr.key]) says: [html_encode(Z)]")
				for(var/obj/Items/Tech/Communicator/Q in M)
					if(Q.Frequency==FrequencySelector)
						M<<"<font color=green><b>([Q.name])</b> [usr.name]: [html_encode(Z)]"
						M<< output("<font color=green><b>([Q.name])</b> [usr.name]: [html_encode(Z)]","icchat")
						Log(M.ChatLog(),"<font color=green>([src.name])[usr]([usr.key]) says: [html_encode(Z)]")
				for(var/obj/Skills/Utility/Internal_Communicator/B in M)
					if(B.ICFrequency==FrequencySelector)
						M<<"<font color=green><b>(Internal Comms (Freq:[B.ICFrequency]))</b> [usr.name]: [html_encode(Z)]"
						M<< output("<font color=green><b>(Internal Comms (Freq:[B.ICFrequency]))</b> [usr.name]: [html_encode(Z)]","icchat")
						Log(M.ChatLog(),"<font color=green>(Internal Comms (Freq: [B.ICFrequency]))[usr]([usr.key]): [html_encode(Z)]")
					if(B.MonitoringFrequency==FrequencySelector)
						M<<"<font color=green><b>(Internal Comms (Monitoring Freq:[B.MonitoringFrequency]))</b> [usr.name]: [html_encode(Z)]"
						M<< output("<font color=green><b>(Internal Comms (Monitoring Freq:[B.MonitoringFrequency]))</b> [usr.name]: [html_encode(Z)]","icchat")
			for(var/obj/Items/Tech/Speaker/X in world)
				if(X.Frequency==FrequencySelector&&X.Active==1)
					for(var/mob/Y in hearers(X.AudioRange,X))
						Y<<"<font color=green><b>([X.name])</b> [usr.name]: [html_encode(Z)]"
						Y<< output("<font color=green><b>([X.name])</b> [usr.name]: [html_encode(Z)]","icchat")
			for(var/obj/Items/Tech/Transmission_Tower/T in world)
				if(T.Frequency==FrequencySelector)
					for(var/mob/Players/P in players)
						if(P.z==T.z)
							var/found=0
							for(var/obj/Items/Tech/Scouter/Q in P)
								found=1
								P<<"<font color=red><b>(Long-Range Frequency)</b> [usr.name]: [html_encode(Z)]"
								P<<output("<font color=red><b>(Long-Range Frequency)</b> [usr.name]: [html_encode(Z)]","icchat")
								Log(P.ChatLog(),"<font color=red>(Long-Range Frequency)[usr]([usr.key]) says: [html_encode(Z)]")
							if(!found)
								for(var/obj/Items/Tech/Communicator/Q in P)
									found=1
									P<<"<font color=red><b>(Long-Range Frequency)</b> [usr.name]: [html_encode(Z)]"
									P<<output("<font color=red><b>(Long-Range Frequency)</b> [usr.name]: [html_encode(Z)]","icchat")
									Log(P.ChatLog(),"<font color=red>(Long-Range Frequency)[usr]([usr.key]) says: [html_encode(Z)]")
							if(!found)
								for(var/obj/Skills/Utility/Internal_Communicator/B in P)
									P<<"<font color=red><b>(Long-Range Frequency)</b> [usr.name]: [html_encode(Z)]"
									P<<output("<font color=red><b>(Long-Range Frequency)</b> [usr.name]: [html_encode(Z)]","icchat")
									Log(P.ChatLog(),"<font color=red>(Long-Range Frequency)[usr]([usr.key]) says: [html_encode(Z)]")
		verb/Scouter_Frequency()
			set src in usr
			Frequency=input(usr,"Change your Scouter frequency to what?","Frequency",Frequency)as num
		verb
			Upgrade()
				set category=null
				set src in usr
				if(src.Range>=3*usr.AdvancedTransmissionTechnologyUnlocked)
					usr << "This scouter is as upgraded as you can make it!"
					return
				else
					src.Range=3*usr.AdvancedTransmissionTechnologyUnlocked
					OMsg(usr, "[usr] upgrades their [src]!")

	Cloak
		TechType="AdvancedTransmissionTechnology"
		SubType="Obfuscation Equipment"
		icon='Tech.dmi'
		icon_state="Cloak"
		TechType="AdvancedTransmissionTechnology"
		Cost=4
		verb/SetPasscode()
			set src in usr
			if(Password)
				usr<<"Password already set!"
				return
			else
				Password=input("Set a password.")as text
		verb/Use()
			set src in usr
			if(!Password)
				usr<<"Set a passcode first!"
				return
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] explodes in [usr]'s hand!")
				del src
				return
			var/list/obj/Items/Things=list("Cancel")
			for(var/obj/Items/P in get_step(usr,usr.dir))
				Things.Add(P)
			if(Things.len>=2)
				var/obj/Items/Choice=input(usr, "What do you want to install the cloak on?", "Cloak") in Things
				if(Choice!="Cancel")
					Choice.PasswordReception=src.Password
					oview(10)<<"[usr] installed the [src] onto the [Choice]."
					del(src)
	Cloak_Controls
		TechType="AdvancedTransmissionTechnology"
		SubType="Obfuscation Equipment"
		icon='Tech.dmi'
		icon_state="CloakControls"
		Cost=10
		verb/Set_Passcode()
			set src in usr
			Password=input("Set a password.")as text
		verb/Cloak_Objects()
			set src in usr
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] explodes in [usr]'s hand!")
				del src
				return
			for(var/obj/Q in world)
				if(Q.PasswordReception)
					if(Q.PasswordReception==Password)
						animate(Q, alpha=70, time=3)
						sleep(3)
						Q.invisibility=70
						usr<<"[Q] is cloaked!"
		verb/UnCloak_Objects()
			set src in usr
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] explodes in [usr]'s hand!")
				del src
				return
			for(var/obj/Q in world)
				if(Q.PasswordReception)
					if(Q.PasswordReception==Password)
						animate(Q, alpha=255, time=3)
						sleep(3)
						Q.invisibility=0
						usr<<"[Q] is revealed!"
		verb/Uninstall()
			set src in usr
			for(var/obj/P in get_step(usr,dir))
				if(P.PasswordReception)
					P.invisibility=0
					var/obj/Items/Tech/e=new /obj/Items/Tech/Cloak(usr.contents)
					e.Password=P.PasswordReception
					P.PasswordReception=null
					oview(10)<<"[usr] uninstalled the [src] from the [P]."

	Projector_Tower
		Health=20
		TechType="Telecommunications"
		SubType="EM Wave Projectors"
		icon='Projector.dmi'
		layer=FLOAT_LAYER
		Cost=10
		Pickable=0
		Grabbable=0
		density=1
		var/NextBurst
		var/WaveType
		verb/Set_Wave_Type()
			set category=null
			set src in range(1, usr)
			if(src.WaveType)
				usr << "[src] was already configured!"
				return
			src.WaveType=alert(usr, "What wave frequency should the projector be configured for?", "EM Wave Type", "Blutz Rays", "Redlight", "Ultraviolet")
		verb/Activate()
			set category=null
			set src in range(1, usr)
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] explodes in [usr]'s hand!")
				del src
				return
			if(!src.WaveType)
				usr << "Configure the wave type first!"
				return
			if(world.realtime<src.NextBurst)
				usr << "The device is still charging after the last use!"
				return
			src.NextBurst=world.realtime+Minute(5)
			switch(WaveType)
				if("Blutz Rays")
					view(10,src)<<"<font color=red><small>The projector emits a burst of intensified Blutz Rays!"
					for(var/turf/t in Turf_Circle(src, 10))
						sleep(-1)
						TurfShift('GreenDay.dmi', t, 10, src, EFFECTS_LAYER)
						for(var/mob/m in t)
							if(m.isRace(SAIYAN) || m.isRace(HALFSAIYAN))
								m.Tail=1
								m.Oozaru(1)
							if(locate(/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Full_Moon_Form, m))
								if(!m.CheckSlotless("FullMoonForm"))
									if(m.SpecialBuff)
										m.SpecialBuff.Trigger(m)
									if(m.SlotlessBuffs.len>0)
										for(var/sb in m.SlotlessBuffs)
											var/obj/Skills/Buffs/b = m.SlotlessBuffs[sb]
											if(b)
												b.Trigger(m)
									for(var/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Full_Moon_Form/F)
										F.Trigger(m)
				if("Redlight")
					view(10,src)<<"<font color=red><small>The projector emits a burst of an eerie light!"
					for(var/turf/t in Turf_Circle(src, 10))
						sleep(-1)
						TurfShift('Flamestorm.dmi', t, 10, src, EFFECTS_LAYER)
						for(var/mob/m in t)
							if(m.isRace(MAKYO))
								m.StarPowered=1
								for(var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC in m)
									if(!m.BuffOn(KC))
										m.PowerControl=150
										m.PoweringUp=0
										m.Auraz("Remove")
										m.UseBuff(KC)
				if("Ultraviolet")
					view(10,src)<<"<font color=red><small>The projector emits a powerful burst of UV light!"
					for(var/turf/t in Turf_Circle(src, 10))
						sleep(-1)
						TurfShift('BrightDay.dmi', t, 10, src, EFFECTS_LAYER)
						for(var/mob/m in t)
							switch(m.Secret)
								if("Vampire")
									for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Vampire/Rotshreck/v in src)
										if(!m.BuffOn(v))
											v.adjust(m, 1)
									var/bloodPower = m.secretDatum.currentTier
									m.BPPoison=min(0.2*bloodPower,0.9)
									m.BPPoisonTimer=RawHours(6)/bloodPower
								if("Ripple")
									if(m.HasRipple()&&!m.PoseEnhancement)
										m.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Ripple_Enhancement)
	Portable_Projector
		Health=5
		TechType="Telecommunications"
		SubType="EM Wave Projectors"
		icon='PProjector.dmi'
		layer=FLOAT_LAYER
		Cost=30
		Pickable=1
		Grabbable=1
		AllowBolt=1
		density=1
		var/NextBurst
		var/WaveType
		verb/Set_Wave_Type()
			set category=null
			set src in range(1, usr)
			if(src.WaveType)
				usr << "[src] was already configured!"
				return
			src.WaveType=alert(usr, "What wave frequency should the projector be configured for?", "EM Wave Type", "Blutz Rays", "Redlight", "Ultraviolet")
		verb/Activate()
			set category=null
			set src in range(1, usr)
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] explodes in [usr]'s hand!")
				del src
				return
			if(!src.WaveType)
				usr << "Configure the wave type first!"
				return
			if(src.Grabbable)
				usr << "You need to bolt it in place first!"
				return
			if(world.realtime<src.NextBurst)
				usr << "The device is still charging after the last use!"
				return
			src.NextBurst=world.realtime+Hour(1)
			switch(WaveType)
				if("Blutz Rays")
					view(10,src)<<"<font color=red><small>The projector emits a burst of intensified Blutz Rays!"
					for(var/turf/t in Turf_Circle(src, 10))
						sleep(-1)
						TurfShift('GreenDay.dmi', t, 10, src, EFFECTS_LAYER)
						for(var/mob/m in t)
							if(m.isRace(SAIYAN) || m.isRace(HALFSAIYAN))
								m.Tail=1
								m.Oozaru(1)
							if(locate(/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Full_Moon_Form, m))
								if(!m.CheckSlotless("FullMoonForm"))
									if(m.ActiveBuff)
										if(m.CheckActive("Eight Gates"))
											m.ActiveBuff:Stop_Cultivation()
											m.GatesActive=0
										else
											m.ActiveBuff.Trigger(m)
									if(m.SpecialBuff)
										m.SpecialBuff.Trigger(m)
									if(m.SlotlessBuffs.len>0)
										for(var/sb in m.SlotlessBuffs)
											var/obj/Skills/Buffs/b = m.SlotlessBuffs[sb]
											if(b)
												b.Trigger(m)
									for(var/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Full_Moon_Form/F)
										F.Trigger(m)
				if("Redlight")
					view(10,src)<<"<font color=red><small>The projector emits a burst of an eerie light!"
					for(var/turf/t in Turf_Circle(src, 10))
						sleep(-1)
						TurfShift('Flamestorm.dmi', t, 10, src, EFFECTS_LAYER)
						for(var/mob/m in t)
							if(m.isRace(MAKYO))
								m.StarPowered=1
								for(var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC in m)
									if(!m.BuffOn(KC))
										m.PowerControl=150
										m.PoweringUp=0
										m.Auraz("Remove")
										m.UseBuff(KC)
				if("Ultraviolet")
					view(10,src)<<"<font color=red><small>The projector emits a powerful burst of UV light!"
					for(var/turf/t in Turf_Circle(src, 10))
						sleep(-1)
						TurfShift('BrightDay.dmi', t, 10, src, EFFECTS_LAYER)
						for(var/mob/m in t)
							switch(m.Secret)
								if("Vampire")
									for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Vampire/Rotshreck/v in src)
										if(!m.BuffOn(v))
											v.adjust(m, 1)
									var/bloodPower = m.secretDatum.currentTier
									m.BPPoison=min(0.2*bloodPower,0.9)
									m.BPPoisonTimer=RawHours(6)/bloodPower
								if("Ripple")
									if(m.HasRipple()&&!m.PoseEnhancement)
										m.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Ripple_Enhancement)


	Digital_Key
		Health=5
		TechType="Engineering"
		SubType="Any"
		Cost=0.1
		desc="Holds three passwords instead of one."
		icon='Tech.dmi'
		icon_state="DigitalKey"
		Click()
			..()
			if(!(usr.client.mob in view(1,src))) return
			if(!Password)
				Password=input("What passcode?")as text|null
			if(!Password2)
				Password2=input("Enter second password.")as text|null
			if(!Password3)
				Password3=input("Enter third password.")as text|null
			else if(Password&&Password2&&Password3)
				var/PasswordCheck=input("Enter the -first- password if you'd like to reset the Digital Key completely. Useful if you made a mistake.")as text|null
				if(PasswordCheck==null)
					return
				else if(PasswordCheck==Password)
					Password=null
					Password2=null
					Password3=null
					usr<<"All passwords reset."
				else
					usr<<"Incorrect password."
	Reinforced_Door
		Cost=0.5
		TechType="Engineering"
		SubType="Any"
		icon='Vaultdoor.dmi'
		icon_state="Closed"
		desc="A extremely strong and hardened door. Far more resilant to damage, but can only be opened remotely."
		density=1
		opacity=1
		Destructable=0
		Pickable=0
		var/antispam
		New()
			if(src.name=="Reinforced Door")
				var/Randomnumber=rand(1,10000)
				src.name="Reinforced Door #[Randomnumber]"
		verb/Encode_Password()
			set category=null
			set src in view(1)
			if(src.Password)
				usr<<"This reinforced door already has a password encoded."
				return
			else
				src.Password=input("Input desired password.") as text
				if(src.Password==null)
					return
				else
					usr<<"Password set! Password is [src.Password]."
		proc/Open()
			src.density=0
			src.opacity=0
			flick("Opening",src)
			src.icon_state="Open"
		proc/Close()
			src.density=1
			src.opacity=1
			flick("Closing",src)
			src.icon_state="Closed"

		Click()
			..()
			if(usr in oview(1,src))
				if(!src.antispam)
					oview(10,src)<<"<font color=yellow><small>There is a bang on the reinforced door!"
					src.antispam=1
					spawn(30)
						src.antispam=null

	Reinforced_Remote
		Health=5
		Cost=2
		TechType="Engineering"
		SubType="Any"
		icon='Vaultdoor.dmi'
		icon_state="Remote"
		desc="Opens reinforced doors."
		AllowBolt=1
		var/KeyCount=0
		verb/Encode_Password()
			set category=null
			var/Valid=0
			if((src in usr))
				Valid=1
			else if(src in view(1, usr) && !src.Grabbable)
				Valid=1
			if(!Valid)
				usr << "You have to use this while it is on your person, or bolted nearby."
				return
			if(src.Password)
				var/Passcheck=input("Input current password to reset this device.") as text
				if(src.Password!=Passcheck)
					usr<<"Incorrect password."
					return
				else
					src.Password=input("Input new password. This will be stored in the remote and sent when you use Send Password") as text
					if(src.Password==null)
						return
					else
						usr<<"Password set! Password is [src.Password]."
			else
				src.Password=input("Input password.") as text
				if(src.Password==null)
					return
				else
					usr<<"Password set! Password is [src.Password]."
		verb/Send_Door_Password()
			set category=null
			var/Valid=0
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] explodes in [usr]'s hand!")
				del src
				return
			if((src in usr))
				Valid=1
			else if(src in view(1, usr)&&!src.Grabbable)
				Valid=1
			if(!Valid)
				usr << "You have to use this while it is on your person, or bolted nearby."
				return
			var/list/Doorlist=list("Cancel")
			for(var/obj/Items/Tech/Reinforced_Door/A in world)
				if(A.Password==src.Password)
					Doorlist.Add(A)
				for(var/obj/Items/Tech/Digital_Key/X in src)
					if(A.Password==X.Password||A.Password==X.Password2||A.Password==X.Password3)
						if(!(A in Doorlist))
							Doorlist.Add(A)
			var/BlanketOpener=input("Toggle all accessible doors?") in list("Yes","No")
			if(BlanketOpener=="Yes")
				src.BlanketOpener(Doorlist)
			else
				var/obj/PickDoor=input(usr, "Select the door you wish to toggle.", "Specific Unlock") in Doorlist
				var/obj/Items/Tech/Reinforced_Door/selecteddoor=PickDoor
				if(PickDoor=="Cancel")
					return
				else
					if(PickDoor.density==0)
						selecteddoor.Close()
					else if(PickDoor.density==1)
						selecteddoor.Open()
		verb/Insert_Digital_Key()
			set category=null
			var/Valid=0
			if((src in usr))
				Valid=1
			else if(src in view(1, usr)&&!src.Grabbable)
				Valid=1
			if(!Valid)
				usr << "You have to use this while it is on your person, or bolted nearby."
				return
			var/list/KeyList=list("Cancel")
			if(KeyCount>=2)
				usr<<"You can only insert two keys at once!"
				return
			for(var/obj/Items/Tech/Digital_Key/A in usr)
				if(A.Password||A.Password2||A.Password3)
					KeyList+=A
			if(KeyList.len<2)
				return
			var/obj/PickKey=input("Select a key to insert.") in KeyList
			if(PickKey=="Cancel")
				return
			else
				var/obj/Items/Tech/Digital_Key/C=PickKey
				C.loc=src
				src.KeyCount++
				usr<<"You insert a [C] into the Remote."
				src.icon_state="Remote+Key[KeyCount]"
				return
		verb/Remove_Digital_Key()
			set category=null
			var/Valid=0
			if((src in usr))
				Valid=1
			else if(src in view(1, usr)&&!src.Grabbable)
				Valid=1
			if(!Valid)
				usr << "You have to use this while it is on your person, or bolted nearby."
				return
			var/list/KeyList=list("Cancel")
			for(var/obj/Items/Tech/Digital_Key/B in src)
				KeyList+=B
			if(!KeyCount)
				usr << "There aren't any keys to remove!"
				return
			var/obj/PickKey=input("Select a key to remove.") in KeyList
			if(PickKey=="Cancel")
				return
			else
				var/obj/Items/Tech/Digital_Key/C=PickKey
				C.loc=usr
				usr<<"You removed a [C] from the Remote."
				KeyCount--
				if(KeyCount==0)
					src.icon_state="Remote"
				else if(KeyCount==1)
					src.icon_state="Remote+Key[KeyCount]"
				return
		proc/BlanketOpener(var/list/Doorlist)
			var/DoorsOpened=0
			var/DoorsClosed=0
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] explodes in [usr]'s hand!")
				del src
				return
			for(var/obj/Items/Tech/Reinforced_Door/B in Doorlist)
				if(B.density==0)
					B.Close()
					DoorsClosed++
				else if(B.density==1)
					B.Open()
					DoorsOpened++
			usr<<"Blanket Open/Close operation completed. [DoorsClosed] doors closed, [DoorsOpened] doors opened."

	Charging_Station
		Cost=10
		icon='Charger.dmi'
		icon_state="5"
		TechType="Engineering"
		SubType="Power Generators"
		Grabbable=0
		Pickable=0
		density=1
		desc="A nonmobile station where gear can be charged. It also can replinish the energy of cyborgs and androids."
		var/ChargesTotal=10
		verb/Recharge_Gear()
			set category=null
			set src in range(1, usr)
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] shocks [usr]!")
				usr.AddShock(100,usr)
				return
			if(src.ChargesTotal<=0)
				usr << "The device is still charging up."
				return
			if(src.Using)
				usr << "You're already charging something."
				return
			if(!usr.Move_Requirements())
				return
			src.Using=1
			var/list/obj/Items/Gear/Gears=list("Cancel")
			var/obj/Items/Gear/Choice
			for(var/obj/Items/Gear/G in usr)
				if(!G.InfiniteUses&&!(G.type in typesof(/obj/Items/Gear/Prosthetic_Limb))&&G.Uses<G.MaxUses)
					Gears.Add(G)
			Choice=input(usr, "What Gear do you want to recharge?", "Recharge Gear") in Gears
			if(Choice=="Cancel")
				src.Using=0
				return
			else
				usr.Frozen=2
				OMsg(usr, "[usr] begins to recharge their [Choice] Gear...")
				sleep(30)
				Choice.Uses=Choice.MaxUses
				usr.Frozen=0
				OMsg(usr, "[usr] has fully charged their gear!")
				src.ChargesTotal--
				if(src.ChargesTotal<=8)
					src.icon_state="4"
				if(src.ChargesTotal<=6)
					src.icon_state="3"
				if(src.ChargesTotal<=4)
					src.icon_state="2"
				if(src.ChargesTotal<=2)
					src.icon_state="1"
				if(src.ChargesTotal<=0)
					src.icon_state="0"
					Recharging()
				src.Using=0
		verb/Recharge_Battery()
			set category=null
			set src in range(1, usr)
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] shocks [usr]!")
				usr.AddShock(100,usr)
				return
			if(src.ChargesTotal<=0)
				usr << "The device is still charging up."
				return
			if(src.Using)
				usr << "You're already charging something."
				return
			src.Using=1
			if(!usr.isRace(ANDROID)&&!usr.HasMechanized())
				usr << "You aren't mechanized enough to use this on yourself!"
				src.Using=0
				return
			else
				usr.Frozen=2
				OMsg(usr, "[usr] begins to recharge their battery...")
				sleep(30)
				usr.HealMana(10)
				usr.Frozen=0
				OMsg(usr, "[usr] has charged themselves up!")
				src.ChargesTotal--
				if(src.ChargesTotal<=8)
					src.icon_state="4"
				if(src.ChargesTotal<=6)
					src.icon_state="3"
				if(src.ChargesTotal<=4)
					src.icon_state="2"
				if(src.ChargesTotal<=2)
					src.icon_state="1"
				if(src.ChargesTotal<=0)
					src.icon_state="0"
					Recharging()
				src.Using=0
		proc/Recharging()
			set background=1
			sleep(600/src.Level)
			src.ChargesTotal=10
			src.icon_state="5"

	Chip_Controller
		Health=5
		TechType="CyberEngineering"
		SubType="War Crimes"
		Cost=5
		icon='device.dmi'
		icon_state="signaller"
		desc="Remotely activates implants."
		verb/Encode_Password()
			set category=null
			set src in usr
			if(src.Password)
				var/Passcheck=input("Input current password to reset this device.") as text
				if(src.Password!=Passcheck)
					usr<<"Incorrect password."
					return
				else
					src.Password=input("Input new password. This will be stored in the remote and sent when you use Send Password") as text
					if(src.Password==null)
						return
					else
						usr<<"Password set! Password is [src.Password]."
			else
				src.Password=input("Input password.") as text
				if(src.Password==null)
					return
				else
					usr<<"Password set! Password is [src.Password]."
		verb/Activate_Stun_Chip()
			set category=null
			set src in usr
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] shocks [usr]!")
				usr.AddShock(100,usr)
				return
			var/mob/Players/M
			var/list/Stunlist=list("Cancel")
			for(M in range(10,usr))
				if(locate(/obj/Skills/Buffs/SlotlessBuffs/Implants/Stun_Chip, M))
					Stunlist.Add(M)
			var/mob/PickStun=input(usr, "Select the implant you wish to activate.", "Punish") in Stunlist
			if(PickStun=="Cancel")
				return
			else
				for(var/obj/Skills/Buffs/SlotlessBuffs/Implants/Stun_Chip/A in PickStun)
					if(A.Password==src.Password)
						A.Trigger(PickStun)
		verb/Activate_Explosive()
			set category=null
			set src in usr
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] shocks [usr]!")
				usr.AddShock(100,usr)
				return
			var/mob/Players/M
			var/list/Bomblist=list("Cancel")
			for(M in range(10,usr))
				if(locate(/obj/Skills/Buffs/SlotlessBuffs/Implants/Internal_Explosive, M))
					Bomblist.Add(M)
			var/mob/PickBomb=input(usr, "Select the implant you wish to activate.", "Punish") in Bomblist
			if(PickBomb=="Cancel")
				return
			else
				for(var/obj/Skills/Buffs/SlotlessBuffs/Implants/Internal_Explosive/A in PickBomb)
					if(A.Password==src.Password)
						A.Trigger(PickBomb)
		verb/Activate_Failsafe()
			set category=null
			set src in usr
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] shocks [usr]!")
				usr.AddShock(100,usr)
				return
			var/mob/Players/M
			var/list/Safelist=list("Cancel")
			for(M in range(10,usr))
				if(locate(/obj/Skills/Buffs/SlotlessBuffs/Implants/Failsafe_Chip, M))
					Safelist.Add(M)
			var/mob/PickSafe=input(usr, "Select the implant you wish to activate.", "Punish") in Safelist
			if(PickSafe=="Cancel")
				return
			else
				for(var/obj/Skills/Buffs/SlotlessBuffs/Implants/Failsafe_Chip/A in PickSafe)
					if(A.Password==src.Password)
						A.Trigger(PickSafe)



	Power_Pack
		Health=5
		icon='powerpack.dmi'
		Cost=0.1
		desc="Use this to restore power to your Gear."
		Stackable=1
		verb/Recharge_Gear()
			set category=null
			set src in usr
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] shocks [usr]!")
				usr.AddShock(50,usr)
				return
			if(src.Using)
				usr << "You're already charging something."
				return
			if(!usr.Move_Requirements() && usr.icon_state != "Meditate")
				return
			src.Using=1
			var/list/obj/Items/Gear/Gears=list("Cancel")
			var/obj/Items/Gear/Choice
			for(var/obj/Items/Gear/G in usr)
				if(!G.InfiniteUses&&!(G.type in typesof(/obj/Items/Gear/Prosthetic_Limb))&&G.Uses<G.MaxUses)
					Gears.Add(G)
			Choice=input(usr, "What Gear do you want to recharge?", "Recharge Gear") in Gears
			if(Choice=="Cancel")
				src.Using=0
				return
			else
				usr.Frozen=2
				OMsg(usr, "[usr] begins to recharge their [Choice] Gear...")
				sleep(30)
				Choice.Uses=Choice.MaxUses
				usr.Frozen=0
				OMsg(usr, "[usr] has fully charged their gear!")
				src.TotalStack--
				if(src.TotalStack<=0)
					del src
				src.suffix="[src.TotalStack]"
				src.Using=0
		verb/Recharge_Battery()
			set category=null
			set src in usr
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] shocks [usr]!")
				usr.AddShock(100,usr)
				return
			if(src.Using)
				usr << "You're already charging something."
				return
			src.Using=1
			if(!usr.isRace(ANDROID)&&!usr.HasMechanized())
				usr << "You aren't mechanized enough to use this on yourself!"
				src.Using=0
				return
			else
				usr.Frozen=2
				OMsg(usr, "[usr] begins to recharge their battery...")
				sleep(30)
				usr.HealMana(10)
				usr.Frozen=0
				OMsg(usr, "[usr] has charged themselves up!")
				src.TotalStack--
				if(src.TotalStack<=0)
					del src
				src.suffix="[src.TotalStack]"
				src.Using=0


obj/Items/Gear
	Unwieldy=1
	var
		Integrateable=0//If this is flagged it can be jammed in a prosthetic
		Uses=0
		MaxUses=0
		IntegratedUses=0
		IntegratedMaxUses=0
		InfiniteUses=0
		AutoCharge=0//For integratable gear
		UpgradeMult=0
		UpgradePath=null
	New()
		..()
		if(src.Uses&&!src.MaxUses)
			src.MaxUses=src.Uses
	verb/Upgrade()
		set category=null
		set src in usr
		if(src.Using)
			return
		if(usr.icon_state!="Meditate")
			usr << "You need to be sitting down to use this properly."
			return
		if(!src.UpgradeMult)
			usr << "[src] isn't capable of being upgraded!"
			return
		if(!src.UpgradePath)
			usr << "[src] doesn't upgrade into anything!"
			return
		if(src.suffix=="*Equipped*")
			usr << "Take off [src] if you want to upgrade it!"
			return
		if(!(src.SubType in usr.knowledgeTracker.learnedKnowledge))
			usr << "You don't have the knowledge required to upgrade [src]!"
			return
		src.Using=1
		var/NuCost=Technology_Price(usr,src)*src.UpgradeMult
		var/Confirm=alert(usr, "Would you like to upgrade your [src]?  It will cost [Commas(NuCost)].", "Upgrade", "No", "Yes")
		if(Confirm=="No")
			src.Using=0
			return
		if(!usr.HasMoney(NuCost))
			usr << "You don't have enough money to upgrade [src]! ([Commas(usr.GetMoney())] / [Commas(NuCost)])"
			src.Using=0
			return
		var/obj/Items/I
		if(islist(src.UpgradePath))
			var/choice = input(usr, "What would you like to upgrade [src] into?", "Upgrade") in src.UpgradePath + "Cancel"
			if(choice=="Cancel")
				src.Using=0
				return
			else
				I=new choice
		else
			I=new src.UpgradePath
		usr.TakeMoney(NuCost)
		I.Cost=I.Cost+(NuCost/glob.progress.EconomyCost)
		usr.contents+=I
		OMsg(usr, "[usr] has upgraded [src] into a new gear!")
		src.Using=0
		del src

	Automated_Aid_Dispenser
		TechType="Medicine"
		SubType="Automated Dispensers"
		icon='AAD.dmi'
		desc="A device programmed to provide immediate medical assistance in circumstances when time is of essence."
		Cost=5
		Uses=5


	Hazard_Suit
		TechType="Engineering"
		SubType="Hazard Suits"
		icon='HazmatSuit.dmi'
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Hazard_Suit")
		desc="A hazmat suit suitable for dealing with heated and toxic environments."
		Cost=5
		UpgradeMult=2
		UpgradePath=.Sealed_Suit
		Uses=3
	Sealed_Suit
		icon='SealedSuit.dmi'
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Sealed_Suit")
		desc="A sealed suit suitable for dealing with any kind of environment!"
		Uses=1

	Deflector_Shield
		TechType="Engineering"
		SubType="Force Shielding"
		icon='TacticalShield.dmi'
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Deflector_Shield")
		desc="A deflector apparatus that can generate a time-limited field to protect the user from projectiles."
		Cost=2
		UpgradeMult=5
		UpgradePath=.Bubble_Shield
		Uses=3
		Integrateable=1
	Bubble_Shield
		icon='TacticalShield.dmi'
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Bubble_Shield")
		desc="An upgraded apparatus that will soak any type of damage until its energy is exhausted."
		Uses=1
		Integrateable=1

	Jet_Boots
		TechType="Engineering"
		SubType="Jet Propulsion"
		icon='JetBoots.dmi'
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Jet_Boots")
		desc="Shoes that allow one to dash with great speed and efficiency, as well as navigate over minor objects."
		Cost=2
		UpgradeMult=2.5
		UpgradePath=.Jet_Pack
		Uses=3
		Integrateable=1
	Jet_Pack
		icon='JetPack.dmi'
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Jet_Pack")
		desc="A pack of jet fuel that allows sustained flight!"
		Uses=1
		Integrateable=1


	Plasma_Blaster
		TechType="MilitaryTechnology"
		SubType="Any"
		icon='Blaster.dmi'
		Techniques=list("/obj/Skills/Projectile/Gear/Plasma_Blaster")
		desc="A gun that can fire a quick shot of plasma frequently!"
		Cost=1
		Uses=5
		Integrateable=1

	Plasma_Rifle
		TechType="MilitaryTechnology"
		SubType="Assault Weaponry"
		icon='AssaultRifle.dmi'
		Techniques=list("/obj/Skills/Projectile/Gear/Plasma_Rifle")
		desc="An assault rifle that fires bursts of plasma."
		Cost=2
		UpgradeMult=5
		UpgradePath=.Plasma_Gatling
		Uses=20
		Integrateable=1
	Plasma_Gatling
		icon='Minigun.dmi'
		Techniques=list("/obj/Skills/Projectile/Gear/Plasma_Gatling")
		desc="A gatling gun capable of unleashing an onslaught of plasma!"
		Uses=90
		Integrateable=1

	Missile_Launcher
		TechType="MilitaryTechnology"
		SubType="Missile Weaponry"
		icon='HomingMissile.dmi'
		Techniques=list("/obj/Skills/Projectile/Gear/Missile_Launcher")
		desc="An auto-aiming apparatus that spews a cluster of missiles."
		Cost=2.5
		UpgradeMult=4
		UpgradePath=.Chemical_Mortar
		Uses=3
		Integrateable=1
	Chemical_Mortar
		Techniques=list("/obj/Skills/Projectile/Gear/Chemical_Mortar")
		desc="A singular devastating missile loaded with a toxic payload."
		Uses=1
		Integrateable=1

	Progressive_Blade
		TechType="MilitaryTechnology"
		SubType="Melee Weaponry"
		icon='ProgressiveHilt.dmi'
		pixel_x=-32
		pixel_y=-32
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Progressive_Blade")
		desc="A hilt that can project a stable beam of plasma suitable for being used as a sword!"
		Cost=1
		UpgradeMult=20
		UpgradePath=.Lightsaber
		Uses=3
		Integrateable=1
	// Lightsaber
	// 	TechType="MilitaryTechnology"
	// 	SubType="Melee Weaponry"
	// 	icon='ProgressiveHilt.dmi'
	// 	pixel_x=-32
	// 	pixel_y=-32
	// 	Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Lightsaber")
	// 	desc="A more elegant implementation of the Progressive Blade allowing for energy deflections, cleaner bladework and using a miniaturized battery allowing for continuous activation."
	// 	UpgradePath=.Double_Lightsaber
	// 	Cost=20
	// 	UpgradeMult=1
	// 	InfiniteUses=1
	// 	Integrateable=1
	// 	Unobtainable=1
	// Double_Lightsaber
	// 	icon='ProgressiveHiltDouble.dmi'
	// 	pixel_x=-32
	// 	pixel_y=-32
	// 	Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Double_Lightsaber")
	// 	desc="A more cumbersome implementation of the Lightsaber, allowing for much of the same, but with reduced accuracy and uniquely faster swing speed."
	// 	InfiniteUses=1
	// 	Integrateable=0//honestly none of these should be integratable because it looks ugly with no hilt

	Incinerator
		TechType="MilitaryTechnology"
		SubType="Thermal Weaponry"
		icon='JetGear.dmi'
		Techniques=list("/obj/Skills/AutoHit/Gear/Incinerator")
		desc="Gear allowing the user to release a large blast of flame in front of them!  It burns."
		Cost=2
		Uses=3
		Integrateable=1
	Freeze_Ray
		TechType="MilitaryTechnology"
		SubType="Thermal Weaponry"
		icon='JetGear.dmi'
		Techniques=list("/obj/Skills/AutoHit/Gear/Freeze_Ray")
		desc="Gear allowing the user to cast a cloud of coolant!  It freezes."
		Cost=2
		Uses=3
		Integrateable=1

	Power_Armor
		name="Powered Exoskeleton"
		TechType="MilitaryEngineering"
		SubType="Any"
		icon='Ironman.dmi'
		Techniques=list("/obj/Skills/Buffs/ActiveBuffs/Gear/Power_Armor")
		desc="A prototype powered exo-suit that sacrifices mobility and efficiency for bulk! An additional piece of gear can be integrated with it."
		Cost=10
		IntegratedUses=100
		IntegratedMaxUses=100
		Uses=1
		verb/Unintegrate()
			set category=null
			set src in usr
			if(src.suffix=="*Equipped*")
				usr << "Take off your armor before you try to jam a gear in it!"
				return
			if(src.Techniques.len<=1)
				usr << "This armor doesn't have any gear integrated!"
				return
			if(src.Using)
				usr << "You cannot unintegrate and integrate gear at the same time!"
				return
			src.Using=1
			switch(input("Are you sure you wish to unintegrate? This will destroy any integration this armor currently has!") in list("Yes","No"))
				if("Yes")
					Techniques=list("/obj/Skills/Buffs/ActiveBuffs/Gear/Power_Armor")
					desc="A prototype powered exo-suit that sacrifices mobility and efficiency for bulk! An additional gear can be integrated with it."
					usr << "You've successfully removed all integrations from this gear."
			src.Using=0
		verb/Integrate()
			set category=null
			set src in usr
			if(src.suffix=="*Equipped*")
				usr << "Take off your armor before you try to jam a gear in it!"
				return
			if(src.Techniques.len>1)
				usr << "This armor already has a gear integrated!"
				return
			if(src.Using)
				usr << "You're already putting something in this armor!"
				return
			src.Using=1
			var/obj/Items/Gear/Choice
			var/list/obj/Items/Gear/IG=list("Cancel")
			for(var/obj/Items/Gear/g in usr)
				if(istype(g, /obj/Items/Gear/Prosthetic_Limb))
					continue
				if(!g.Integrateable)
					continue
				IG.Add(g)
			if(IG.len<2)
				usr << "You don't have any gear capable of being integrated into your armor."
				src.Using=0
				return
			Choice=input(usr, "What gear do you want to integrate into your power armor?", "Integrate") in IG
			if(Choice=="Cancel")
				src.Using=0
				return
			switch(Choice.type)
				if(/obj/Items/Gear/Deflector_Shield)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Deflector_Shield")
				if(/obj/Items/Gear/Bubble_Shield)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Bubble_Shield")
				if(/obj/Items/Gear/Jet_Boots)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Boots")
				if(/obj/Items/Gear/Jet_Pack)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Pack")
				if(/obj/Items/Gear/Plasma_Blaster)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Blaster")
				if(/obj/Items/Gear/Plasma_Rifle)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Rifle")
				if(/obj/Items/Gear/Plasma_Gatling)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Gatling")
				if(/obj/Items/Gear/Missile_Launcher)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Missile_Launcher")
				if(/obj/Items/Gear/Chemical_Mortar)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Chemical_Mortar")
				if(/obj/Items/Gear/Progressive_Blade)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Progressive_Blade")
				if(/obj/Items/Gear/Lightsaber)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Lightsaber")
				if(/obj/Items/Gear/Incinerator)
					src.Techniques.Add("/obj/Skills/AutoHit/Gear/Integrated/Integrated_Incinerator")
				if(/obj/Items/Gear/Freeze_Ray)
					src.Techniques.Add("/obj/Skills/AutoHit/Gear/Integrated/Integrated_Freeze_Ray")
				if(/obj/Items/Gear/Pile_Bunker)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Pile_Bunker")
				if(/obj/Items/Gear/Power_Fist)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Fist")
				if(/obj/Items/Gear/Blast_Fist)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Blast_Fist")
				if(/obj/Items/Gear/Chainsaw)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Chainsaw")
				if(/obj/Items/Gear/Power_Claw)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Claw")
				if(/obj/Items/Gear/Hook_Grip_Claw)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Hook_Grip_Claw")
				else
					usr << "Ruh roh.  Something went wrong.  Yell at Yan."
					src.Using=0
					return
			usr << "You've integrated [Choice] into your armor!"
			src.desc="A prototype powered exo-suit that sacrifices mobility and efficiency for bulk! A [Choice] gear has been integrated with it."
			del Choice
			src.Using=0
	Power_Armor_Burst
		TechType="MilitaryEngineering"
		SubType="Powered Armor Specialization"
		icon='Ironman.dmi'
		Techniques=list("/obj/Skills/Buffs/ActiveBuffs/Gear/Power_Armor_Burst")
		desc="A specialized armor that sacrifices bulk in order to unleash hellish firepower! An additional gear can be integrated with it."
		Cost=25
		IntegratedUses=100
		IntegratedMaxUses=100
		Uses=1
		verb/Unintegrate()
			set category=null
			set src in usr
			if(src.suffix=="*Equipped*")
				usr << "Take off your armor before you try to jam a gear in it!"
				return
			if(src.Techniques.len<=1)
				usr << "This armor doesn't have any gear integrated!"
				return
			if(src.Using)
				usr << "You cannot unintegrate and integrate gear at the same time!"
				return
			src.Using=1
			switch(input("Are you sure you wish to unintegrate? This will destroy any integration this armor currently has!") in list("Yes","No"))
				if("Yes")
					Techniques=list("/obj/Skills/Buffs/ActiveBuffs/Gear/Power_Armor_Burst")
					desc="A specialized armor that sacrifices bulk in order to unleash hellish firepower! An additional gear can be integrated with it."
					usr << "You've successfully removed all integrations from this gear."
			src.Using=0
		verb/Integrate()
			set category=null
			set src in usr
			if(src.suffix=="*Equipped*")
				usr << "Take off your armor before you try to jam a gear in it!"
				return
			if(src.Techniques.len>1)
				usr << "This armor already has a gear integrated!"
				return
			if(src.Using)
				usr << "You're already putting something in this armor!"
				return
			src.Using=1
			var/obj/Items/Gear/Choice
			var/list/obj/Items/Gear/IG=list("Cancel")
			for(var/obj/Items/Gear/g in usr)
				if(istype(g, /obj/Items/Gear/Prosthetic_Limb))
					continue
				if(!g.Integrateable)
					continue
				IG.Add(g)
			if(IG.len<2)
				usr << "You don't have any gear capable of being integrated into your armor."
				src.Using=0
				return
			Choice=input(usr, "What gear do you want to integrate into your power armor?", "Integrate") in IG
			if(Choice=="Cancel")
				src.Using=0
				return
			switch(Choice.type)
				if(/obj/Items/Gear/Deflector_Shield)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Deflector_Shield")
				if(/obj/Items/Gear/Bubble_Shield)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Bubble_Shield")
				if(/obj/Items/Gear/Jet_Boots)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Boots")
				if(/obj/Items/Gear/Jet_Pack)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Pack")
				if(/obj/Items/Gear/Plasma_Blaster)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Blaster")
				if(/obj/Items/Gear/Plasma_Rifle)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Rifle")
				if(/obj/Items/Gear/Plasma_Gatling)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Gatling")
				if(/obj/Items/Gear/Missile_Launcher)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Missile_Launcher")
				if(/obj/Items/Gear/Chemical_Mortar)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Chemical_Mortar")
				if(/obj/Items/Gear/Progressive_Blade)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Progressive_Blade")
				if(/obj/Items/Gear/Lightsaber)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Lightsaber")
				if(/obj/Items/Gear/Incinerator)
					src.Techniques.Add("/obj/Skills/AutoHit/Gear/Integrated/Integrated_Incinerator")
				if(/obj/Items/Gear/Freeze_Ray)
					src.Techniques.Add("/obj/Skills/AutoHit/Gear/Integrated/Integrated_Freeze_Ray")
				if(/obj/Items/Gear/Pile_Bunker)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Pile_Bunker")
				if(/obj/Items/Gear/Power_Fist)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Fist")
				if(/obj/Items/Gear/Blast_Fist)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Blast_Fist")
				if(/obj/Items/Gear/Chainsaw)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Chainsaw")
				if(/obj/Items/Gear/Power_Claw)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Claw")
				if(/obj/Items/Gear/Hook_Grip_Claw)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Hook_Grip_Claw")
				else
					usr << "Ruh roh.  Something went wrong.  Yell at Yan."
					src.Using=0
					return
			src.IntegratedUses=Choice.MaxUses
			src.IntegratedMaxUses=src.IntegratedUses
			usr << "You've integrated [Choice] into your armor!"
			src.desc="A specialized armor that sacrifices bulk in order to unleash hellish firepower! A [Choice] gear has been integrated with it."
			del Choice
			src.Using=0
	Power_Armor_Burly
		TechType="MilitaryEngineering"
		SubType="Powered Armor Specialization"
		icon='IronmanBurly.dmi'
		Techniques=list("/obj/Skills/Buffs/ActiveBuffs/Gear/Power_Armor_Burly")
		desc="A specialized armor that focuses on becoming even more resilient than the prototype! An additional gear can be integrated with it."
		Cost=25
		IntegratedUses=100
		IntegratedMaxUses=100
		Uses=1
		verb/Unintegrate()
			set category=null
			set src in usr
			if(src.suffix=="*Equipped*")
				usr << "Take off your armor before you try to jam a gear in it!"
				return
			if(src.Techniques.len<=1)
				usr << "This armor doesn't have any gear integrated!"
				return
			if(src.Using)
				usr << "You cannot unintegrate and integrate gear at the same time!"
				return
			src.Using=1
			switch(input("Are you sure you wish to unintegrate? This will destroy any integration this armor currently has!") in list("Yes","No"))
				if("Yes")
					Techniques=list("/obj/Skills/Buffs/ActiveBuffs/Gear/Power_Armor_Burly")
					desc="A specialized armor that focuses on becoming even more resilient than the prototype! An additional gear can be integrated with it."
					usr << "You've successfully removed all integrations from this gear."
			src.Using=0

		verb/Integrate()
			set category=null
			set src in usr
			if(src.suffix=="*Equipped*")
				usr << "Take off your armor before you try to jam a gear in it!"
				return
			if(src.Techniques.len>1)
				usr << "This armor already has a gear integrated!"
				return
			if(src.Using)
				usr << "You're already putting something in this armor!"
				return
			src.Using=1
			var/obj/Items/Gear/Choice
			var/list/obj/Items/Gear/IG=list("Cancel")
			for(var/obj/Items/Gear/g in usr)
				if(istype(g, /obj/Items/Gear/Prosthetic_Limb))
					continue
				if(!g.Integrateable)
					continue
				IG.Add(g)
			if(IG.len<2)
				usr << "You don't have any gear capable of being integrated into your armor."
				src.Using=0
				return
			Choice=input(usr, "What gear do you want to integrate into your power armor?", "Integrate") in IG
			if(Choice=="Cancel")
				src.Using=0
				return
			switch(Choice.type)
				if(/obj/Items/Gear/Deflector_Shield)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Deflector_Shield")
				if(/obj/Items/Gear/Bubble_Shield)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Bubble_Shield")
				if(/obj/Items/Gear/Jet_Boots)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Boots")
				if(/obj/Items/Gear/Jet_Pack)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Pack")
				if(/obj/Items/Gear/Plasma_Blaster)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Blaster")
				if(/obj/Items/Gear/Plasma_Rifle)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Rifle")
				if(/obj/Items/Gear/Plasma_Gatling)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Gatling")
				if(/obj/Items/Gear/Missile_Launcher)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Missile_Launcher")
				if(/obj/Items/Gear/Chemical_Mortar)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Chemical_Mortar")
				if(/obj/Items/Gear/Progressive_Blade)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Progressive_Blade")
				if(/obj/Items/Gear/Lightsaber)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Lightsaber")
				if(/obj/Items/Gear/Incinerator)
					src.Techniques.Add("/obj/Skills/AutoHit/Gear/Integrated/Integrated_Incinerator")
				if(/obj/Items/Gear/Freeze_Ray)
					src.Techniques.Add("/obj/Skills/AutoHit/Gear/Integrated/Integrated_Freeze_Ray")
				if(/obj/Items/Gear/Pile_Bunker)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Pile_Bunker")
				if(/obj/Items/Gear/Power_Fist)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Fist")
				if(/obj/Items/Gear/Blast_Fist)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Blast_Fist")
				if(/obj/Items/Gear/Chainsaw)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Chainsaw")
				if(/obj/Items/Gear/Power_Claw)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Claw")
				if(/obj/Items/Gear/Hook_Grip_Claw)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Hook_Grip_Claw")
				else
					usr << "Ruh roh.  Something went wrong.  Yell at Yan."
					src.Using=0
					return
			usr << "You've integrated [Choice] into your armor!"
			src.desc="A specialized armor that focuses on becoming even more resilient than the prototype! A [Choice] gear has been integrated with it."
			del Choice
			src.Using=0
	Power_Armor_Blitz
		TechType="MilitaryEngineering"
		SubType="Powered Armor Specialization"
		icon='IronmanBlitz.dmi'
		Techniques=list("/obj/Skills/Buffs/ActiveBuffs/Gear/Power_Armor_Blitz")
		desc="A specialized armor that focuses on speedy, offensive manuevering! An additional gear can be integrated with it."
		Cost=25
		IntegratedUses=100
		IntegratedMaxUses=100
		Uses=1
		verb/Unintegrate()
			set category=null
			set src in usr
			if(src.suffix=="*Equipped*")
				usr << "Take off your armor before you try to jam a gear in it!"
				return
			if(src.Techniques.len<=1)
				usr << "This armor doesn't have any gear integrated!"
				return
			if(src.Using)
				usr << "You cannot unintegrate and integrate gear at the same time!"
				return
			src.Using=1
			switch(input("Are you sure you wish to unintegrate? This will destroy any integration this armor currently has!") in list("Yes","No"))
				if("Yes")
					Techniques = list("/obj/Skills/Buffs/ActiveBuffs/Gear/Power_Armor_Blitz")
					desc = "A specialized armor that focuses on speedy, offensive manuevering! An additional gear can be integrated with it."
					usr << "You've successfully removed all integrations from this gear."
			src.Using=0
		verb/Integrate()
			set category=null
			set src in usr
			if(src.suffix=="*Equipped*")
				usr << "Take off your armor before you try to jam a gear in it!"
				return
			if(src.Techniques.len>1)
				usr << "This armor already has a gear integrated!"
				return
			if(src.Using)
				usr << "You're already putting something in this armor!"
				return
			src.Using=1
			var/obj/Items/Gear/Choice
			var/list/obj/Items/Gear/IG=list("Cancel")
			for(var/obj/Items/Gear/g in usr)
				if(istype(g, /obj/Items/Gear/Prosthetic_Limb))
					continue
				if(!g.Integrateable)
					continue
				IG.Add(g)
			if(IG.len<2)
				usr << "You don't have any gear capable of being integrated into your armor."
				src.Using=0
				return
			Choice=input(usr, "What gear do you want to integrate into your power armor?", "Integrate") in IG
			if(Choice=="Cancel")
				src.Using=0
				return
			switch(Choice.type)
				if(/obj/Items/Gear/Deflector_Shield)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Deflector_Shield")
				if(/obj/Items/Gear/Bubble_Shield)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Bubble_Shield")
				if(/obj/Items/Gear/Jet_Boots)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Boots")
				if(/obj/Items/Gear/Jet_Pack)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Pack")
				if(/obj/Items/Gear/Plasma_Blaster)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Blaster")
				if(/obj/Items/Gear/Plasma_Rifle)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Rifle")
				if(/obj/Items/Gear/Plasma_Gatling)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Gatling")
				if(/obj/Items/Gear/Missile_Launcher)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Missile_Launcher")
				if(/obj/Items/Gear/Chemical_Mortar)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Chemical_Mortar")
				if(/obj/Items/Gear/Progressive_Blade)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Progressive_Blade")
				if(/obj/Items/Gear/Lightsaber)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Lightsaber")
				if(/obj/Items/Gear/Incinerator)
					src.Techniques.Add("/obj/Skills/AutoHit/Gear/Integrated/Integrated_Incinerator")
				if(/obj/Items/Gear/Freeze_Ray)
					src.Techniques.Add("/obj/Skills/AutoHit/Gear/Integrated/Integrated_Freeze_Ray")
				if(/obj/Items/Gear/Pile_Bunker)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Pile_Bunker")
				if(/obj/Items/Gear/Power_Fist)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Fist")
				if(/obj/Items/Gear/Blast_Fist)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Blast_Fist")
				if(/obj/Items/Gear/Chainsaw)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Chainsaw")
				if(/obj/Items/Gear/Power_Claw)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Claw")
				if(/obj/Items/Gear/Hook_Grip_Claw)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Hook_Grip_Claw")
				else
					usr << "Ruh roh.  Something went wrong.  Yell at Yan."
					src.Using=0
					return
			usr << "You've integrated [Choice] into your armor!"
			src.desc="A specialized armor that focuses on speedy, offensive manuevering!  A [Choice] gear has been integrated within it."
			del Choice
			src.Using=0

	Blast_Fist
		TechType="MilitaryEngineering"
		SubType="Impact Weaponry"
		icon='ImpactGloves.dmi'
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Blast_Fist")
		desc="Powered gloves that discharge a shell on contact!"
		Cost=2
		UpgradeMult=0.25
		UpgradePath=.Power_Fist
		Uses=1
		Integrateable=1
	Power_Fist
		icon='PowerFist.dmi'
		Techniques=list("/obj/Skills/Queue/Gear/Power_Fist")
		desc="A gauntlet capable of producing a singular powerful impact."
		Uses=1
		Integrateable=1
	Pile_Bunker
		TechType="MilitaryEngineering"
		SubType="Armorpiercing Weaponry"
		icon='PileBunker.dmi'
		Techniques=list("/obj/Skills/Queue/Gear/Pile_Bunker")
		desc="A large, mechanized nail that can deliver a single blow."
		Cost=2.5
		UpgradeMult=0.2
		UpgradePath=.Chainsaw
		Uses=1
		Integrateable=1
	Chainsaw
		//HIT ME WITH THAT CHAINSAW ICON BAYBAY
		Techniques=list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Chainsaw")
		desc="A powered armament that shears through anything."
		Uses=1
		Integrateable=1
	Power_Claw
		TechType="MilitaryEngineering"
		SubType="Hydraulic Weaponry"
		icon='PowerClaw.dmi'
		Techniques=list("/obj/Skills/Queue/Gear/Power_Claw")
		desc="A mechanized claw capable of GRIPPING the opponent.  Shocking.  Not literally."
		Cost=1
		UpgradeMult=1.5
		UpgradePath=.Hook_Grip_Claw
		Uses=3
		Integrateable=1
	Hook_Grip_Claw
		icon='PowerClaw.dmi'
		Techniques=list("/obj/Skills/Queue/Gear/Hook_Grip_Claw")
		desc="Another mechanized appendage, but this time it's loaded with a hook shot!  Get over here."
		Uses=3
		Integrateable=1
	Prosthetic_Limb
		TechType="ImprovedMedicalTechnology"
		SubType="Prosthetic Limbs"
		Cost=4
		Stealable=0
		icon='AutomailArmLeft.dmi'
		desc="A replacement limb.  It is possible to integrate some gears into the limbs."
		verb/Integrate()
			set category=null
			set src in usr
			if(src.suffix=="*Equipped*")
				usr << "Take off your limb before you try to jam a gear in it!"
				return
			if(src.Techniques.len>0)
				usr << "This limb already has a gear integrated!"
				return
			if(src.Using)
				usr << "You're already putting something in this limb!"
				return
			src.Using=1
			var/obj/Items/Gear/Choice
			var/list/obj/Items/Gear/IG=list("Cancel")
			for(var/obj/Items/Gear/g in usr)
				if(istype(g, /obj/Items/Gear/Prosthetic_Limb))
					continue
				if(!g.Integrateable)
					continue
				IG.Add(g)
			if(IG.len<2)
				usr << "You don't have any gear capable of being integrated into your prosthetic."
				src.Using=0
				return
			Choice=input(usr, "What gear do you want to integrate into your prosthetic limb?", "Integrate") in IG
			if(Choice=="Cancel")
				src.Using=0
				return
			switch(Choice.type)
				if(/obj/Items/Gear/Deflector_Shield)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Deflector_Shield")
				if(/obj/Items/Gear/Bubble_Shield)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Bubble_Shield")
				if(/obj/Items/Gear/Jet_Boots)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Boots")
				if(/obj/Items/Gear/Jet_Pack)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Pack")
				if(/obj/Items/Gear/Plasma_Blaster)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Blaster")
				if(/obj/Items/Gear/Plasma_Rifle)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Rifle")
				if(/obj/Items/Gear/Plasma_Gatling)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Gatling")
				if(/obj/Items/Gear/Missile_Launcher)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Missile_Launcher")
				if(/obj/Items/Gear/Chemical_Mortar)
					src.Techniques.Add("/obj/Skills/Projectile/Gear/Integrated/Integrated_Chemical_Mortar")
				if(/obj/Items/Gear/Progressive_Blade)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Progressive_Blade")
				if(/obj/Items/Gear/Lightsaber)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Lightsaber")
				if(/obj/Items/Gear/Incinerator)
					src.Techniques.Add("/obj/Skills/AutoHit/Gear/Integrated/Integrated_Incinerator")
				if(/obj/Items/Gear/Freeze_Ray)
					src.Techniques.Add("/obj/Skills/AutoHit/Gear/Integrated/Integrated_Freeze_Ray")
				if(/obj/Items/Gear/Pile_Bunker)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Pile_Bunker")
				if(/obj/Items/Gear/Power_Fist)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Fist")
				if(/obj/Items/Gear/Blast_Fist)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Blast_Fist")
				if(/obj/Items/Gear/Chainsaw)
					src.Techniques.Add("/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Chainsaw")
				if(/obj/Items/Gear/Power_Claw)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Claw")
				if(/obj/Items/Gear/Hook_Grip_Claw)
					src.Techniques.Add("/obj/Skills/Queue/Gear/Integrated/Integrated_Hook_Grip_Claw")
				else
					usr << "This gear isn't valid for prosthetic limb integration!."
					src.Using=0
					return
			src.IntegratedUses=Choice.MaxUses
			src.IntegratedMaxUses=src.IntegratedUses
			usr << "You've integrated [Choice] into your prosthetic!"
			src.desc="A replacement limb.  A [Choice] gear has been integrated within it."
			del Choice
			src.Using=0
	Mobile_Suit
		var/Drive = "None"
		var/Augment = "None"
		var/beamSaberSetUp = FALSE
		var/MechType = "None"
		TechType="MilitaryEngineering"
		SubType="Vehicular Power Armor"
		icon='Gundam.dmi'
		icon_state="Inventory"
//		EquipIcon='FoGundam.dmi'
		pixel_x=-32
		pixel_y=-32
		Pickable=0
		Grabbable=0
		Unwieldy=0
		density=1
		layer=MOB_LAYER+1
		Techniques=list("/obj/Skills/Buffs/ActiveBuffs/Gear/Mobile_Suit")
		desc="A specialized armor that focuses on overwhelming force and size."
		InfiniteUses=1
		Cost=1000000
		Health=1000000000000
		proc/changeType(mob/player)
			if(MechType)
				switch(input(player, "Do you want to change your mech's type? Each type has a different boon") in list("Yes","No")=="No")
					if("Yes")
						MechType = input(player, "What type?") in list("Speed","Tank","Assault")
			else
				MechType = input(player, "What type of mech do you want to use?", "Mech Type") in list("Speed","Tank","Assault")
		proc/setup(mob/player)
			var/level2 = Level>=2 ? 1 : 0
			var/level4 = Level>=4 ? 1 : 0
			if(Drive == "None")
				Drive = input(player, "What type of drive do you want to use?", "Drive") in list("Supersonic","Fortress", "Destroyer")
			if(level2)
				if(Drive == "Supersonic")
					Augment = "Trans_Am"
				if(Drive == "Fortress")
					Augment = "Fortress_Mode"
				if(Drive == "Destroyer")
					Augment = "Destroyer_Mode"
			if(level4)
				if(Drive == "Supersonic")
					Augment ="Twin_Drive"
				if(Drive == "Fortress")
					Augment = "Unbreakable_Mode"
				if(Drive == "Destroyer")
					Augment = "Annihilation_Mode"


		verb/Alter_Mech()
			set category = "Mecha"
			set src in range(1, usr)
			if(src.Using)
				return
			if(get_dist(src, usr) > 1)
				return
			changeType(usr)
		verb/Pilot()
			set src in range(1, usr)
			set category="Utility"
			if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Science"))
				OMsg(usr, "[src] shocks [usr]!")
				usr.AddShock(100,usr)
				return
			if(get_dist(src, usr) > 1)
				return
			if(src.Using)
				return
			setup(usr)
			Techniques = list()
			if(MechType == "None")
				var/result = input(usr, "What type?") in list("Speed","Tank","Assault")
				MechType = result
			Techniques = list("/obj/Skills/Buffs/ActiveBuffs/Gear/Mobile_Suit/[MechType]")
			if(Augment != "None")
				Techniques += "/obj/Skills/Buffs/SlotlessBuffs/WeaponSystems/[Augment]"
				if(Drive == "Fortress")
					Techniques += list("/obj/Skills/Projectile/Gear/Installed/Giga_Laser", \
				"/obj/Skills/Projectile/Gear/Installed/Missle_Onslaught", "/obj/Skills/Projectile/Gear/Installed/Laser_Circus")
			src.Using=1
			src.ObjectUse(usr)
			src.Using=0
		verb/Set_Start_Code()
			set src in range(1, usr)
			set name="Set Password"
			if(src.Password)
				var/Passcheck=input(usr,"Input original code.")as text
				if(Passcheck==src.Password)
					Password=input(usr,"Input a code for the suit.")as text
				else
					usr<<"Incorrect password."
			else
				Password=input(usr,"Input a code for the suit.")as text



proc/ReturnDirection(var/mob/buh,var/mob/M)
	if(M.x > buh.x)
		if(M.y>buh.y)
			return NORTHEAST
		if(M.y<buh.y)
			return SOUTHEAST
		if(M.y==buh.y)
			return EAST
	if(M.x < buh.x)
		if(M.y>buh.y)
			return NORTHWEST
		if(M.y<buh.y)
			return SOUTHWEST
		if(M.y==buh.y)
			return WEST
	if(M.x == buh.x)
		if(M.y>buh.y)
			return NORTH
		if(M.y<buh.y)
			return SOUTH

obj/Items/Tech
	var/Lvl=1
	var/UpgradePrice

	Safe
		Cost=2.5
		Pickable=0
		Destructable=0
		TechType="Engineering"
		SubType="Any"
		icon='Drill 3.dmi'
		desc="Stores resources."
		verb/Set_Password()
			set src in oview(1)
			set name="Set Password"
			if(src.Password)
				var/Passcheck=input(usr,"Input original password.")as text
				if(Passcheck==src.Password)
					Password=input(usr,"Input a password for the safe.")as text
				else
					usr<<"Incorrect password."
			else
				Password=input(usr,"Input a password for the safe.")as text
		verb/Withdraw()
			set src in oview(1)
			set name="Withdraw"
			if(src.Password)
				var/Passcheck=input(usr,"Input password.")as text
				if(Passcheck!=src.Password)
					usr<<"This isn't the right password..."
					return
			if(src.Lvl==0)
				usr<<"The safe has no resources in it!"
				return
			var/Withdrawing=input(usr,"How much would you like to withdraw?","[src.Lvl] resources available")as num
			if(Withdrawing==0||Withdrawing==null)
				return
			if(Withdrawing>src.Lvl)
				Withdrawing=src.Lvl
			for(var/obj/Money/M in usr)
				M.Level+=Withdrawing
				src.Lvl-=Withdrawing
				usr.OMessage(3,"[usr] withdraws [Commas(Withdrawing)] from the [src].","<font color=red>[usr]([usr.key]) withdraws [Commas(Withdrawing)] resources from a Safe made by [src.CreatorKey].")
		verb/Deposit()
			set src in oview(1)
			set name="Deposit"
			if(src.Password)
				var/Passcheck=input(usr,"Input password.")as text
				if(Passcheck!=src.Password)
					usr<<"This isn't the right password..."
					return
			for(var/obj/Money/M in usr)
				if(M.Level==0)
					usr<<"You have no resources to deposit!"
					return
				var/Depositing=input(usr,"How much would you like to deposit?","[src.Lvl] resources available")as num
				if(Depositing==0||Depositing==null)
					return
				if(Depositing>M.Level)
					Depositing=M.Level
				src.Lvl+=Depositing
				M.Level-=Depositing
				usr.OMessage(3,"[usr] deposits [Commas(Depositing)] to the [src].","<font color=red>[usr]([usr.key]) deposits [Commas(Depositing)] resources to a Safe made by [src.CreatorKey].")




	SpaceMask
		icon='BreathingPiece.dmi'
		name="Air Mask"
		TechType="Engineering"
		Cost=0.25
		SubType="Any"
		var/OxygenMax=200
		var/Oxygen=200
		desc="A mask that helps one breathe in enviroments that have low or no oxygen. Has a limited oxygen supply, but it can be replenished and enhanced."
		verb/RestoreOxygen()
			var/FuelTotal=src.OxygenMax-src.Oxygen
			var/RefuelConfirm=input("Would you like to reoxygenate? It'll cost 5 per Oxygen point, for a total of [Commas(FuelTotal*5)].") in list("Yes","No")
			switch(RefuelConfirm)
				if("Yes")
					for(var/obj/Money/Q in usr)
						if(Q.Level<FuelTotal*5)
							usr<<"You don't have enough resources."
							return
						else
							Q.Level-=FuelTotal*5
							src.Oxygen=src.OxygenMax
							usr<<"Reoxygenization successful!"
				if("No")
					return