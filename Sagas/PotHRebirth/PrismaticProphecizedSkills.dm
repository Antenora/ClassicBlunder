obj
	Skills/Buffs/SlotlessBuffs
		ChaosSaber
			MakesSword=1
			BuffName="Chaos Saber"
			SwordName="Spookysword"
			SwordIcon='Spookysword.dmi'
			SwordX=-32
			SwordY=-32
			SwordClass="Medium"
			StrMult=1.25
			ForMult=1.25
			Cooldown = 1
			SwordAscension=3
			ActiveMessage="readies CHAOS SABER."
			OffMessage="dispels the CHAOS SABER!"
			adjust(mob/p)
				passives = list("PUSpike"=50, "BlurringStrikes"=3,"HybridStrike" = 1,"KiControl" = 1)
				PowerMult=1.25
				EnergyHeal=1
				if(p.SagaLevel>=3)
					SwordAscension=p.SagaLevel
					StrMult=1.5
					ForMult=1.5
				if(p.SagaLevel>=4)
					ActiveMessage="manifests their Chaos Sabers in a burst of prismatic light."
					OffMessage="dispels the Chaos Sabers."
					passives = list("PUSpike"=50, "BlurringStrikes"=3,"HybridStrike" = 1,"KiControl" = 1, "DoubleStrike" = 1)
			verb/Chaos_Saber()
				set category="Skills"
				if(usr.CheckSlotless("Chaos Buster"))
					var/obj/Skills/Buffs/SlotlessBuffs/ChaosBuster/cb = locate(/obj/Skills/Buffs/SlotlessBuffs/ChaosBuster) in usr.contents
					cb.Trigger(usr)
				src.Trigger(usr)
		ChaosBuster
			BuffName="Chaos Buster"
			MakesStaff=1
			FlashDraw=1
			StaffName="Chaos Buster"
			StaffIcon='Aether Bow.dmi'
			ActiveMessage="readies CHAOS BUSTER."
			OffMessage="dispels their CHAOS BUSTER!"
			passives = list("SpecialStrike" = 1, "StaffAscension" = 2, "Godspeed"=3, "Skimming"=1,"SpiritStrike"=1)
			SpecialStrike=1
			StaffAscension=3
			adjust(mob/p)
			verb/Transfigure_Chaos_Buster()
				set category="Utility"
				var/Choice
				if(!usr.BuffOn(src))
					var/Lock=alert(usr, "Do you wish to alter the icon used?", "Weapon Icon", "No", "Yes")
					if(Lock=="Yes")
						src.StaffIcon=input(usr, "What icon will your Chaos Buster use?", "Chaos Buster Icon") as icon|null
						src.StaffX=input(usr, "Pixel X offset.", "Chaos Buster Icon") as num
						src.StaffY=input(usr, "Pixel Y offset.", "Chaos Buster Icon") as num
					Choice=input(usr, "What class of gun do you want your Chaos Buster to be?", "Transfigure Chaos Buster") in list("Light", "Medium", "Heavy")
					switch(Choice)
						if("Light")
							src.StaffClass="Wand"
						if("Medium")
							src.StaffClass="Rod"
						if("Heavy")
							src.StaffClass="Staff"
					usr << "Chaos Buster class set as [Choice]!"
				else
					usr << "You can't set this while using Chaos Buster."
			verb/Chaos_Buster()
				set category="Skills"
				if(usr.CheckSlotless("Chaos Saber"))
					var/obj/Skills/Buffs/SlotlessBuffs/ChaosSaber/cb = locate(/obj/Skills/Buffs/SlotlessBuffs/ChaosSaber) in usr.contents
					cb.Trigger(usr)
				src.Trigger(usr)