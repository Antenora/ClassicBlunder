/obj/Skills/Buffs/SlotlessBuffs
	Vampire
		Vampire
			IconLock='SharinganEyes.dmi'
			IconLockBlend=2
			IconApart=1
			IconLayer=1
			// this is a constant buff that should never be off
			Flow = 1
			StrMult = 1.2
			OffMult = 1.1
			DefMult = 1.1
			ForMult = 1.1
			SpdMult = 1.1
			adjust(mob/p)
				var/secretLevel = p.getSecretLevel()
				if(p.CheckSlotless("Rotshreck"))
					StrMult = 1 + (secretLevel * 0.25)
					OffMult = 1 + (secretLevel * 0.25)
					DefMult = 1.1 + (secretLevel * 0.25)
					ForMult = 1 + (secretLevel * 0.25)
					SpdMult = 1.1 + (secretLevel * 0.25)
				else
					StrMult = 1.1 + (secretLevel * 0.1)
					OffMult = 1 + (secretLevel * 0.1)
					DefMult = 1 + (secretLevel * 0.1)
					ForMult = 1 + (secretLevel * 0.1)
					SpdMult = 1.1 + (secretLevel * 0.1)

		Wassail
			Curse=1
			Godspeed=1
			Intimidation=1
			LifeSteal=10
			ActiveMessage="has entered Wassail -- the hunger frenzy!"
			OffMessage="regains their sanity..."
			Cooldown=30
			BuffName = "Wassail"
			TextColor=rgb(153, 0, 0)
			var/TrueVampire=0
			adjust(mob/p) // this needs to essentially be a gimped version of rotshreck
				ActiveMessage = "has entered Wassail -- the hunger frenzy!"
				var/secretLevel = p.getSecretLevel()
				Godspeed = (secretLevel/2) * (1 + (p.secretDatum:getHungerRatio()))
				LifeSteal = (10 + secretLevel) * (1 + (p.secretDatum:getHungerRatio()))
				passives = list("LifeSteal" = LifeSteal, "Godspeed" = Godspeed)
			verb/Vampire_Frenzy()
				set category="Skills"
				adjust(usr)
				if(usr.CheckSlotless("Rotschreck"))
					usr << "You are already in Rötschreck!"
					return
				if(!usr.BuffOn(src))
					ActiveMessage="has willingly entered Wassail -- the hunger frenzy!"
				src.Trigger(usr)
				if(usr.BuffOn(src))
					if(usr.secretDatum.currentTier>=2)
						if(usr.BPPoisonTimer>1&&usr.BPPoison<1)
							usr.BPPoison=1
							usr.BPPoisonTimer=1
							OMsg(usr, "[usr] recovers from their injuries!")
						if(usr.Maimed)
							usr.Maimed=0
							OMsg(usr, "[usr] regrows their limbs!")

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Vampire
	Rotshreck
		Curse = 1
		NeedsHealth = 25
		TooMuchHealth=50
		BuffName = "Rotschreck"
		KenWave = 1
		KenWaveSize = 5
		KenWaveBlend = 2
		KenWaveTime = 3
		ActiveMessage = "has lost their composure and enetered Rötschreck!"
		OffMessage = "regains their composure..."
		TextColor = rgb(153, 0, 0)
		var/sunTriggered
		adjust(mob/p, sundamage = 0)
			var/secretLevel = p.secretDatum.currentTier
			if(sundamage)
				NeedsHealth = 0
				TooMuchHealth = 100
			LifeSteal = (10 + secretLevel + 5) * (1 + (p.secretDatum.secretVariable["BloodPower"] * 0.25))
			Godspeed = secretLevel * (1 + (p.secretDatum.secretVariable["BloodPower"] * 0.25))
			passives = list("LifeSteal" = LifeSteal, "Godspeed" = Godspeed)

		Trigger(mob/User, Override = 0)
			adjust(User, 0)
			if(User.CheckSlotless("Wassail"))
				var/obj/Skills/Buffs/SlotlessBuffs/W = User.GetSlotless("Wassail")
				if(User.BuffOn(W))
					W.Trigger(User, 1)
			..()