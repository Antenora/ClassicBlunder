obj
	Skills/Buffs/SpecialBuffs
		Hyperdeath_Mode
			EnergyThreshold=10
			EnergyLeak=1
			StrMult=1.2
			EndMult=1.2
			SpdMult=1.2
			ForMult=1.2
			RecovMult=1.2
			passives = list("MovementMastery" = 2, "TechniqueMastery" = 2, "BuffMastery" = 1, "RainbowAfterImages" = 1)
			FlashChange=1
			KenWaveIcon='Unbound.dmi'
			KenWave=1
			KenWaveSize=1
			KenWaveX=72
			KenWaveY=72
			KenWaveBlend=2
			KenWaveTime=5
			ActiveMessage="unleashes their complete self!"
			OffMessage="returns to their old self..."
			adjust(mob/p)
			verb/Hyperdeath_Mode()
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)
	Skills/Buffs/SlotlessBuffs
		ChaosSaber
			MakesSword=1
			BuffName="Chaos Saber"
			SwordName="Spookysword"
			SwordIcon='Spookysword.dmi'
			SwordX=-32
			SwordY=-32
			SwordClass="Medium"
			StrMult=1.50
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
					StrMult=1.75
					ForMult=1.5
					passives = list("PUSpike"=50, "BlurringStrikes"=3,"HybridStrike" = 1,"KiControl" = 1, "Chaos Buster" = 1)
				if(p.SagaLevel>=4)
					MakesSword=2
					ActiveMessage="manifests their Chaos Sabers in a burst of prismatic light."
					OffMessage="dispels the Chaos Sabers."
					passives = list("PUSpike"=50, "BlurringStrikes"=3,"HybridStrike" = 1,"KiControl" = 1, "Chaos Buster" = 1, "DoubleStrike" = 1)
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
			StrMult=1.25
			ForMult=1.50
			StaffName="Chaos Buster"
			StaffIcon='Aether Bow.dmi'
			ActiveMessage="readies CHAOS BUSTER."
			OffMessage="dispels their CHAOS BUSTER!"
			passives = list("StaffAscension" = 2, "Godspeed"=3, "Skimming"=1,"Chaos Buster"=1, "SpiritStrike"=1)
			StaffAscension=2
			adjust(mob/p)
				passives = list("StaffAscension" = 2, "Godspeed"=3, "Skimming"=1,"Chaos Buster"=1, "SpiritStrike"=1)
				if(p.SagaLevel>=3)
					passives = list("StaffAscension" = 2, "Godspeed"=3, "Skimming"=1,"Chaos Buster"=2, "SpiritStrike"=1)
					StrMult=1.50
					ForMult=1.75
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


	Skills/Projectile
		ChaosBusterShot
			Radius=0
			DamageMult=0.25
			AccMult=0.5
			StrRate=0.5
			ForRate=0.5
			EndRate=1
			Distance=30
			Homing=1
			ManaCost=0.5
			Piercing=1
			AttackReplace=1
			Striking=1
			Blasts=5
			IconLock='ChaosBuster - Projectile.dmi'
			Variation=48
			Radius=1
		SuperChaosBusterShot
			Radius=0
			DamageMult=0.75
			AccMult=1
			StrRate=1
			ForRate=1
			EndRate=1
			Piercing=1
			IconSize=2
			Distance=30
			Homing=1
			ManaCost=1.5
			AttackReplace=1
			Striking=1
			Blasts=5
			IconLock='ChaosBuster - Projectile.dmi'
			Variation=48
			Radius=1

	Skills/AutoHit
		Shocker_Breaker
			ElementalClass="Wind"
			SpellElement="Air"
			FlickAttack=1
			Distance=6
			Area="Target"
			ForOffense=1
			DamageMult=6
			Paralyzing=5
			Size=1
			Bolt=5
			BoltOffset=1
			HitSparkIcon='BLANK.dmi'
			HitSparkX=0
			HitSparkY=0
			WindUp=1
			ManaCost=10
			SpecialAttack=1
			CanBeDodged=1
			CanBeBlocked=0
			Cooldown=45
			WindupMessage="used <font size=+1>SHOCKER BREAKER!</font size>"
			verb/Shocker_Breaker()
				set category="Skills"
				adjust(usr)
				usr.Activate(src)