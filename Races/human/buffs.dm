/obj/Skills/Buffs/SlotlessBuffs/Racial/Human
	Deus_Ex_Machina
		Cooldown = -1
		passives = list("You Thought" = 1, "Hopes and Dreams" = 1)
		TimerLimit=30
		ActiveMessage = "channels their inner humanity... and manifests a miracle!"
		FlashChange = 1
		Trigger(mob/User, Override)
			if(Using) return;
			TimerLimit=(30*User.AscensionsAcquired);
			if(User.BuffOn(src))
				User.ShonenAnnounce=0
				User.ShonenCounter=0
			..()
	Activate_High_Tension
		passives = list("FullTensionLock"=1)
		TimerLimit=60
		Cooldown=-1
		ActiveMessage="Psyches themselves up! -- Tension Up!"
		OffMessage="releases their tremendous focus..."
		verb/Activate_High_Tension()
			set category="Skills"
			if(usr.isMazokuPathHuman())
				usr << "You can't access your power at will."
				return
			if(usr.transActive || usr.passive_handler.Get("SSJRose") >= 1)
				usr<<"You can't use this while transformed!"
				return
			if(!usr.BuffOn(src))
				usr.Tension=0
				usr.race.transformations[1].transform(usr, TRUE)
				if(usr.transUnlocked>=4)
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Racial/Human/Double_Helix, usr))
						var/obj/Skills/Buffs/SlotlessBuffs/Racial/Human/Double_Helix/s=new/obj/Skills/Buffs/SlotlessBuffs/Racial/Human/Double_Helix
						usr.AddSkill(s)
				if(usr.transUnlocked>=5)
					usr.race.transformations[2].transform(usr, TRUE)
					usr.race.transformations[3].transform(usr, TRUE)
				if(usr.transUnlocked>=6)
					usr.race.transformations[4].transform(usr, TRUE)
					usr.race.transformations[5].transform(usr, TRUE)
			src.Trigger(User=usr, Override=TRUE)
	Double_Helix
		TimerLimit=1
		Cooldown=-1
		verb/Double_Helix()
			set category="Skills"
			if(usr.isMazokuPathHuman())
				usr << "You can't."
				return
			if(usr.passive_handler.Get("DoubleHelix"))
				switch(usr.DoubleHelix)
					if(0)
						usr.DoubleHelix=1
						OMsg(usr,"<b>The dreams of those who have fallen...</b>")
					if(1)
						usr.DoubleHelix=2
						OMsg(usr,"<b>...and the hopes of those who will follow...</b>")
					if(2)
						usr.DoubleHelix=3
						OMsg(usr,"<b>...those two sets of dreams weave together...</b>")
					if(3)
						usr.DoubleHelix=4
						OMsg(usr,"<b>...into a double helix, paving a path towards tomorrow!!!</b>")
					if(4)
						if(usr.transActive<5)
							return
						usr.DoubleHelix=5
						OMsg(usr,"<b>In their hands, [usr] holds the power to create the heavens!!!!</b>")
				return
			if(usr.canSHTM())
				usr.race.transformations[4].transform(usr, TRUE)
				usr.DoubleHelix=0