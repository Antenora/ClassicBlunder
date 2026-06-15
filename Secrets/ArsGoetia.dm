/obj/Items/Demon_Summoning/ArsGoetia
	name = "Ars Goetia"
	icon = 'Icons/NSE/Icons/Thot_book.dmi'
	var/BloodSacrifice=3
	var/BloodSacrificeCD
	var/DemonSummonCD
	var/DemonRevivalCD
	var/GoetiaOwner
	var/OwnerPassword
	var/GoetiaNumber
	verb/Claim_Ownership()
		set name= "Ars Goetia: Claim Ownership"
		set category = "Ars Goetia"
		if(usr.ArsGoetiaOwner)
			usr<<"You already own this and have no need to claim it."
			return
		if(!src.OwnerPassword)
			var/Confirm=alert(usr, "You can choose to sell your soul to the Ars Goetia in exchange for incredible demonic magic, as well as a demonic True Name that will function as a password. However, should anyone else claim ownership over it, you will die, and if it's stolen from you, they will be know your true name. Do you wish to sign this pact? This is not required to summon or revive Demons.", "Claim Ownership", "Yes", "No")
			if(Confirm=="Yes")
				if(usr.isRace(DEMON)||usr.isRace(ELDRITCH))
					usr<<"Races native to the Depths cannot utilize or claim ownership over the Ars Goetia."
					return
				usr.TrueName=input(usr, "As the owner of the Ars Goetia, you have a True Name that functions as the password to open the book. It should be kept secret. What is your True Name?", "Get True Name") as text
				src.GoetiaOwner=usr.TrueName
				usr.ArsGoetiaOwner=1
				src.OwnerPassword=usr.TrueName
				if(!usr.Secret)
					if(!(usr.race.type in glob.NoSagaRaces))
						usr.Secret = "Eldritch"
						usr.giveSecret("Eldritch")
						usr<<"The power of the Depths floods your body, giving you a permanent Eldritch nature."
				usr.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic)
				usr.AddSkill(new/obj/Skills/Teleport/Traverse_Depths)
				usr.AddSkill(new/obj/Skills/Utility/Imitate)
				usr.passive_handler.Increase("Hellpower" = 0.5)
				usr.client.updateCorruption()
				usr.demon.selectPassive(usr, "CORRUPTION_PASSIVES", "Buff", TRUE)
				usr.demon.selectPassive(usr, "CORRUPTION_DEBUFFS", "Debuff")
		else
			var/AGPass=input(usr,"You must know the True Name of the original owner to claim ownership.") as text
			if(AGPass==src.OwnerPassword)
				if(usr.isRace(DEMON)||usr.isRace(ELDRITCH))
					usr<<"Races native to the Depths cannot claim ownership over the Ars Goetia."
					return
				for(var/mob/M in players)
					if(AGPass==M.TrueName)
						M.Death(src, "the Ars Goetia claiming their soul.")
						src.BloodSacrifice++
				usr.TrueName=input(usr, "As the owner of the Ars Goetia, you have a True Name that functions as the password to open the book. It should be kept secret. What is your True Name?", "Get True Name") as text
				src.GoetiaOwner=usr.TrueName
				usr.ArsGoetiaOwner=1
				src.OwnerPassword=usr.TrueName
				if(!usr.Secret)
					if(!(usr.race.type in glob.NoSagaRaces))
						usr.Secret = "Eldritch"
						usr.giveSecret("Eldritch")
						usr<<"The power of the Depths floods your body, giving you a permanent Eldritch nature."
				usr.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic)
				usr.AddSkill(new/obj/Skills/Teleport/Traverse_Depths)
				usr.AddSkill(new/obj/Skills/Utility/Imitate)
				usr.passive_handler.Increase("Hellpower" = 0.5)
				usr.client.updateCorruption()
				usr.demon.selectPassive(usr, "CORRUPTION_PASSIVES", "Buff", TRUE)
				usr.demon.selectPassive(usr, "CORRUPTION_DEBUFFS", "Debuff")
			else
				usr<<"You guessed incorrectly. The Ars Goetia doesn't appreciate intrusion."
				return

	verb/Blood_Sacrifice(mob/M in get_step(usr, usr.dir))
		set name = "Ars Goetia: Blood Sacrifice"
		set category = "Ars Goetia"
		if(!M.KO)
			usr << "[M] needs to be KO'd!"
			return
		if(src.BloodSacrificeCD < world.realtime )
			src.BloodSacrifice+= 1
			M.BPPoison=0.5
			M.MortallyWounded+=1
			M.DoDamage(M, 100)
			M.TotalInjury+=85
			M.AddHealthCut(0.1)
			OMsg(usr, "[usr] sacrifices the blood of [M], inflicting a brutal injury and leaving them on the brink of death. [M] loses 10% of their max health.")
			src.BloodSacrificeCD = world.realtime + 24 HOURS
		else
			usr << "You're on cooldown till [time2text(src.BloodSacrificeCD, "hh:ss") ]"
	verb/Summon_Demon()
		set name= "Ars Goetia: Summon Demon"
		set category = "Ars Goetia"
		var/mob/Choice
		if(usr.isRace(DEMON)||usr.isRace(ELDRITCH))
			usr<<"Races native to the Depths cannot utilize or claim ownership over the Ars Goetia."
			return
		if(src.Using)
			return
		if(!usr.Move_Requirements()||usr.KO)
			return
		if(world.realtime<src.DemonSummonCD)
			usr << "It's too soon to use this!  ([round((src.DemonSummonCD-world.realtime)/Hour(1), 0.1)] hours)"
			return
		src.Using=1

		var/Cost=1

		if(!src.BloodSacrifice)
			usr << "You don't have enough capacity to summon an otherworldly entity!  It takes [Cost] sacrifice to summon a demon."
			src.Using=0
			return

		switch(input(usr, "Summoning this otherworldly entity requires you to inflict or take a mortal wound. Are you sure you want to do it?", "Summon Demon") in list("Yes","No"))
			if("No")
				src.Using=0
				return

		var/Failure=0
		var/Invocation=input(usr, "What True Name do you attempt to invoke?", "Summon Demon") as text
		if(Invocation in glob.trueNames)
			var/Found=0
			for(var/mob/Players/m in players)
				if(m.TrueName==Invocation)
					if(m.isRace(MAKAIOSHIN))
						usr<<"They are outside of your authority."
						OMsg(usr, "[usr] attempted to invoke the True Name of something they have no authority over, causing magical backlash.")
						usr.DoDamage(usr, 25)
						src.Using=0
						return
					if(m.isRace(CELESTIAL))
						usr<<"The demon they're connected to slumbers and cannot be awoken through mere magic alone."
						src.Using=0
						return
					else
						Found=1
						Choice=m
						break

			if(!Found)
				OMsg(usr, "[usr] invoked a True Name properly, but the being slumbers currently...")
				src.Using=0
				return

		else
			Failure=1
			src.Using=0
			OMsg(usr, "[usr] attempted to invoke a True Name of no existing being!")




		if(!Failure) //wanna do something cool with this but I think I'll just have it straight up summon someone atm
			if(!Choice.GoetiaContacted)
				usr<<"You must contact a Demon before summoning them."
				src.Using=0
				return
			Choice<<"<b>You are being summoned by [usr] using the Ars Goetia...</b>"
			spawn()
				for(var/x=0, x<5, x++)
					LightningBolt(Choice)
					sleep(3)
			Choice.loc=locate(usr.x, usr.y-1, usr.z)
		src.BloodSacrifice--
		src<<"You have [src.BloodSacrifice] sacrifices left stored in the Ars Goetia."
		src.DemonSummonCD=world.realtime+Day(1)
		src.Using=0
		return
	verb/Revive_Demon(mob/A in players)
		set name= "Ars Goetia: Revive Demon/Eldritch"
		set category = "Ars Goetia"
		if(usr.isRace(DEMON)||usr.isRace(ELDRITCH))
			usr<<"Races native to the Depths cannot utilize or claim ownership over the Ars Goetia."
			return
		if(src.Using)
			return
		if(!usr.Move_Requirements()||usr.KO)
			return
		src.Using=1

		var/Cost=3

		if(src.BloodSacrifice<3)
			usr << "You don't have enough capacity to revive an otherworldly entity!  It takes [Cost] sacrifices to revive someone."
			src.Using=0
			return
		if(A.isRace(DEMON, ELDRITCH)||A.hasEldritchPower())
			A.loc=locate(usr.x, usr.y-1, usr.z)
			A.Revive()
			src.BloodSacrifice-=3
			src<<"You have [src.BloodSacrifice] sacrifices left stored in the Ars Goetia."
			OMsg(usr, "The Ars Goetia floods [A] with stored up blood, bringing them back from the dead.")
			src.Using=0
			src.DemonRevivalCD=world.realtime+Day(7)
		else
			usr<<"This can only be used on Demons."
			src.Using=0
			return
		src.Using=0
	verb/Contact_Demon()
		set name= "Ars Goetia: Contact Demon"
		set category = "Ars Goetia"
		var/mob/Choice
		if(usr.isRace(DEMON)||usr.isRace(ELDRITCH))
			usr<<"Races native to the Depths cannot utilize or claim ownership over the Ars Goetia."
			return
		if(src.Using)
			return
		if(!usr.Move_Requirements()||usr.KO)
			return
		src.Using=1


		var/Failure=0
		var/Invocation=input(usr, "What True Name do you attempt to contact?", "Contact Demon") as text
		if(Invocation in glob.trueNames)
			var/Found=0
			for(var/mob/Players/m in players)
				if(m.TrueName==Invocation)
					if(m.isRace(MAKAIOSHIN))
						usr<<"They are outside of your authority."
						src.Using=0
						return
					if(m.isRace(CELESTIAL))
						usr<<"The demon they're connected to slumbers and cannot be awoken through mere magic alone."
						src.Using=0
						return
					else
						Found=1
						Choice=m
						break

			if(!Found)
				usr<<"You invoked the correct name, but they are slumbering."
				src.Using=0
				return

		else
			src.Using=0
			Failure=1
			OMsg(usr, "[usr] attempted to invoke a True Name of no existing being!")
		if(!Failure)
			src.Using=0
			var/list/who=list("Cancel")
			who.Add(Choice)
			var/mob/Players/selector=input("Select a demon to contact.") in who||null
			if(selector=="Cancel")
				return
			usr.TwoWayTelepath(selector, 0)
			Choice.GoetiaContacted=1
/*	verb/Change_Scent()
		set category = "Ars Goetia"
		var/category = input(usr, "What category?") in scents
		usr.custom_scent = input(usr, "What scent?") in scents[category]
		usr << "Scent changed to [usr.custom_scent]"

	verb/Activate_Void()
		set category = "Ars Goetia"
		usr.passive_handler.Set("Void", !usr.passive_handler.passives["Void"])
		usr << "Void is [usr.passive_handler["Void"] ? "on" : "off"]."


	verb/Imitate()
		set category = "Ars Goetia"
		if(usr.Imitating)
			usr.invisibility = 99
			usr.information.loadProfile(usr, "[usr.ckey]_Old_Profile_1", FALSE)
			usr.swapToProfileVars(TRUE)
			sleep(10)
			usr.invisibility = 0
			usr.Imitating = 0
		else
			var/mob/Target = usr.Target
			if(Target && get_dist(usr, Target) < 20)
				if(!Target.client) return
				Target <<"<i>[pick(RANDOM_ALERT)]</i>"
				usr.information.takeInformation(usr, usr, "Original Profile","Old_Profile", TRUE, 1)
				usr.invisibility = 99
				usr<<"<i>You fade into the ether as your dark magic replicates [Target]'s form.</i>"
				usr.information.takeInformation(Target, usr, "null", "discarded_file", TRUE, 1)
				usr.swapToProfileVars(FALSE)
				usr.appearance = Target.appearance
				usr.invisibility = 99
				sleep(10)
				usr.invisibility = 0
				usr.Imitating = 1
			else
				usr << "Your target is too far"*/
obj/Skills/Buffs/SlotlessBuffs/Autonomous/Beckoned
	AlwaysOn=1
	TimerLimit=30
	ActiveMessage="starts to fade in and out of reality..."
	OffMessage="suddenly vanishes."
	Cooldown=-1
	WarpZone=1
/*	WarpX=1
	WarpY=1
	WarpZ=1*/