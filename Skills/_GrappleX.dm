obj/Skills/Grapple
	var
		removeAfter = FALSE


		DamageMult=1
		MultiHit=1//hit multiple times durr
		EnergyDamage=0//do damage to energy+fatigue and heal self mana

		StrRate=1
		ForRate=0
		EndRate=1

		UnarmedOnly=1
		SpecialAttack=0//staves n shiet

		ObjectEnabled=0
		Reversal=0//allows you to throw the one you've grabbed
		//Stunner

		ThrowDir/*carries a direction so people dont end up going wonky*/
		ThrowAdd=0//adds value to kb
		ThrowMult=1//mult value to kb
		ThrowSpeed = 0

		TriggerMessage
		Effect//"Shockwave"
		EffectMult=1
		OneAndDone=0//prevents multiple iterations from effectmult

		DrainBlood // for vampire
		MortalBlow=0
		DashAfter = FALSE
////BASIC
	skillDescription()
		..()
		if(DamageMult)
			description += "DamageMult: [DamageMult]\n"
		if(MultiHit)
			description += "Hits [MultiHit] times.\n"
		if(StrRate)
			description += "Strength Damage %: [StrRate*100]\n"
		if(ForRate)
			description += "Force Damage %: [ForRate*25]\n"
		if(EndRate<1)
			description += "Endurance Ignoring: [1-EndRate]%\n"
		if(UnarmedOnly)
			description += "Unarmed Only.\n"
		if(Reversal)
			description += "Reversal; will throw after use.\n"
		if(ThrowAdd)
			description += "Will throw [ThrowAdd] tiles.\n"
		if(ThrowMult)
			description += "Will multiply thrown distance by [ThrowMult]\n"

	Toss
		DamageMult=0
		UnarmedOnly=0
		ObjectEnabled=1
		CooldownStatic=1
		Cooldown=20
		ThrowMult=1.5
		ThrowAdd=1.5
		TriggerMessage="tosses"
		proc/resetValues()
			TriggerMessage = "tosses"
			Effect = initial(Effect)
			EffectMult = initial(EffectMult)
			DamageMult = initial(DamageMult)
			StrRate = initial(StrRate)
			ThrowMult = initial(ThrowMult)
			ThrowAdd = initial(ThrowAdd)
			ThrowSpeed = initial(ThrowSpeed)
			DashAfter = FALSE
		verb/Toss()
			set category="Skills"
			if(!usr.Grab && !src.Using)
				if(usr.Saga=="Unlimited Blade Works"&&usr.GetSlotless("GaeBolg"))
					for(var/obj/Skills/Buffs/SlotlessBuffs/GaeBolg/GB in usr)
						GB.Trigger(usr, Override = 1)
					for(var/obj/Skills/Projectile/Zone_Attacks/Gae_Bolg/GBT in usr)
						GBT.alter(usr)
						usr.UseProjectile(GBT)
				usr.SecretToss(src)
			else
				if(usr.Secret == "Vampire")
					// if(adjusted) return
					// activate the vampire toss skill
					ThrowMult=0.75
					ThrowAdd=2
					ObjectEnabled = 0
					TriggerMessage = "sinks their fangs into"
					Effect = "Strike"
					var/secretLevel = usr.getSecretLevel()
					DamageMult = (6 + secretLevel) * (1 + usr.secretDatum:getBloodPowerRatio())
					Cooldown = 20
					StrRate = 0.8 * (1 + usr.secretDatum:getBloodPowerRatio())
					var/boon = 0// check to see if in wassail or in rotschreck
					if(usr.CheckSlotless("Wassail"))
						boon = 1
					else if(usr.CheckSlotless("Rotschreck"))
						boon = 0.5
					DrainBlood = 1 + boon
				else if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasImprovement("Throw"))
					Effect = "Shockwave"
					EffectMult = usr.secretDatum?:getBoon(usr, "Throw")
					DamageMult = 3 + usr.secretDatum?:getBoon(usr, "Throw")
					ThrowAdd = 2 + usr.secretDatum?:getBoon(usr, "Throw")
					ThrowMult = max(1, usr.secretDatum?:getBoon(usr, "Throw") / 2)
					ThrowSpeed = 2.5/usr.secretDatum?:getBoon(usr, "Throw")
					DashAfter = TRUE
				else
					resetValues()
				src.Activate(usr)
////AUTO TRIGGER
	Lightning_Blade
		OneAndDone = 1
		Effect = "Shockwave"
		EffectMult=1
		DamageMult=2
		AdaptRate = 1
		ThrowAdd=15
		TriggerMessage = "stabs their lightning infused hand into"


	Muscle_Buster
		DamageMult = 2
		StrRate = 1.5
		EffectMult=3
		OneAndDone=1
		HarderTheyFall = 2
		Effect="MuscleBuster"
		TriggerMessage = "lifts, flips, and slams"

	Giant_Swing
		DamageMult = 4
		StrRate = 1.25
		EffectMult=2
		OneAndDone=1
		Effect="MuscleBuster"
		HarderTheyFall = 3
		TriggerMessage = "starts spinning"

	Heavenly_Potemkin_Buster
		DamageMult = 6
		StrRate=1
		EndRate=0.75
		OneAndDone = 1
		EffectMult=3
		HarderTheyFall = 4
		Effect="PotemkinBuster"
	
	Tombstone_Piledriver
		DamageMult = 8
		HarderTheyFall = 6
		StrRate=1.5
		EndRate=0.75
		EffectMult=3
		Effect="PotemkinBuster" //TODO: MAKE ANIMATION LATER
		TriggerMessage = "is dropping the tombstone on"

	Ryukoha
		DamageMult = 4
		HarderTheyFall = 1.5
		EffectMult=1.5
		Effect="Lotus"
		OneAndDone = 1
		EndRate=0.75
		StrRate=0.75
		

	Lotus_Drop
		DamageMult=5
		StrRate=1
		TriggerMessage="spins into a vicious lotus drop to crack the skull of"
		Effect="Lotus"
		EffectMult=3
		OneAndDone=1
		ThrowMult=0
		ThrowAdd=0
		//Set from other queues
	True_Lotus
		DamageMult=8
		StrRate=1
		TriggerMessage="embraces the full power of their youth to spiral into a lotus drop to crack the skull of"
		Effect="Lotus"
		EffectMult=4
		OneAndDone=1
		ThrowMult=0
		ThrowAdd=0
		//still set from other queues
////UNARMED
	Snake_Fang_Bites
		MultiHit=2
		DamageMult=2
		StrRate=1
		ForRate=4
		ThrowAdd=5
		TriggerMessage="drives two fang-hands into"
		Effect="Strike"
		EffectMult=1
	Hammer_Crush
		Stunner=3
		DamageMult=4
		StrRate=1
		ForRate=0
		ThrowAdd=1
		ThrowMult=0
		TriggerMessage="presses down fiercely on"
		Effect="Suplex"
	Imperial_Disgust
		Stunner=5
		DamageMult=10
		StrRate=1
		ForRate=4
		ThrowMult=0
		ThrowAdd=10
		TriggerMessage="casts all of their disgust upon"
		Effect="Bang"
		EffectMult=5

//T1 is in Queues.
//T2 is in Autohits.
//T3 has damage mult 3 - 5.
	Throw
		SkillCost=TIER_3_COST
		Copyable=3
		DamageMult=2
		StrRate=1
		ThrowAdd=5
		ThrowMult=1.5
		TriggerMessage="violently throws"
		Effect="Shockwave"
		Cooldown=90
		verb/Throw()
			set category="Skills"
			src.Activate(usr)
	Judo_Throw
		SkillCost=TIER_3_COST
		Copyable=4
		DamageMult=4
		Reversal=1
		Stunner=2
		StrRate=1
		ThrowAdd=1
		ThrowMult=0
		TriggerMessage="performs a judo throw on"
		Effect="Shockwave"
		Cooldown=90
		verb/Judo_Throw()
			set category="Skills"
			src.Activate(usr)
	Izuna_Drop
		SkillCost=TIER_3_COST
		Copyable=4
		DamageMult=4
		EndRate = 0.8
		StrRate=1
		ThrowAdd=0
		ThrowMult=0
		TriggerMessage="goes on a short flight with"
		Effect="Lotus"
		EffectMult=2
		OneAndDone=1
		Cooldown=60
		verb/Izuna_Drop()
			set category="Skills"
			src.Activate(usr)
	Suplex
		NewCost = TIER_2_COST
		NewCopyable = 3
		SkillCost=120
		Copyable=4
		DamageMult=3
		Stunner=3
		StrRate=1
		ThrowAdd=1
		ThrowMult=0
		TriggerMessage="suplexes"
		Effect="Suplex"
		EffectMult=1
		Cooldown=60
		verb/Disable_Innovate()
			set category = "Other"
			disableInnovation(usr)
		adjust(mob/p)
			if(p.isInnovative(HUMAN, "Unarmed") && !isInnovationDisable(p))
				Effect="SuperSuplex"
				TriggerMessage="starts freakifying"
				EffectMult=0.5
				Stunner=5
				OneAndDone=1
				StrRate=1
				DamageMult = 2.5 + (p.Potential / 50)
			else
				Effect="Suplex"
				DamageMult=3
				EffectMult=1
				Stunner=3
				StrRate=1
		verb/Suplex()
			set category="Skills"
			adjust(usr)
			src.Activate(usr)
	Burning_Finger
		NewCost = TIER_2_COST
		NewCopyable = 3
		SkillCost=120
		Copyable=4
		DamageMult=3
		ForRate=2
		StrRate=0.5
		TriggerMessage="shoves their burning red hand through"
		Effect="Bang"
		EffectMult=2
		ThrowMult=0
		ThrowAdd=5
		Cooldown=60
		verb/Burning_Finger()
			set category="Skills"
			src.Activate(usr)
//T4 is in Queues and Autohits.
//T5 (Sig 1) is damage mult 5, usually.
	Erupting_Burning_Finger
		UnarmedOnly=0
		NeedsSword=0
		SignatureTechnique=1
		DamageMult=8
		StrRate=1
		ForRate=2
		TriggerMessage="shoves their grossly incandescent hand through"
		Effect="Bang"
		EffectMult=5
		ThrowMult=0
		ThrowAdd=15
		Cooldown=150
		verb/Erupting_Burning_Finger()
			set category="Skills"
			src.Activate(usr)
		Removeable
			removeAfter = 1
	Lightning_Stake
		UnarmedOnly=0
		NeedsSword=0
		SignatureTechnique=1
		DamageMult=8
		ForRate=1
		StrRate=0
		TriggerMessage="fills their grasp with lightning and takes hold of"
		Effect="Lightning"
		EffectMult=5
		ThrowMult=0
		ThrowAdd=15
		Cooldown=150
		verb/Lightning_Stake()
			set category="Skills"
			src.Activate(usr)




	Energy_Drain
		DamageMult=0.75
		EnergyDamage=2
		ForRate=3
		StrRate=0.25
		TriggerMessage="drains energy from"
		Effect="Drain"
		EffectMult=1
		OneAndDone=1
		Cooldown=30
		verb/Energy_Drain()
			set category="Skills"
			src.Activate(usr)

	Sword
		NeedsSword=1
		UnarmedOnly=0

		Butterfly_Souffle
			DamageMult=2
			MultiHit=5
			StrRate=1
			ThrowMult=0
			ThrowAdd=1
			TriggerMessage="rips and tears into"
			Effect="Strike"
			EffectMult=5

		Impale
			Copyable=3
			SkillCost=120
			DamageMult=4
			StrRate=1.5
			TriggerMessage="impales"
			Effect="Strike"
			EffectMult=2
			ThrowMult=1.5
			Cooldown=90
			verb/Impale()
				set category="Skills"
				src.Activate(usr)
		Blade_Drive//run through pt 2
			DamageMult=5
			StrRate=1
			ThrowMult=2
			TriggerMessage="drives their weapon through the guts of"
			Effect="Shockwave"
			EffectMult=3
			//set from other queues
		Shank
			DamageMult=1
			StrRate=1
			ThrowMult=3
			ThrowAdd=1
			Effect="Shockwave"
			EffectMult=1
		Eviscerate
			Copyable=4
			SkillCost=TIER_3_COST
			DamageMult=1
			MultiHit=8
			StrRate=1
			ThrowMult=0
			ThrowAdd=0
			TriggerMessage="eviscerates"
			Effect="Strike"
			EffectMult=5
			Cooldown=90
			verb/Eviscerate()
				set category="Skills"
				src.Activate(usr)
		Hacksaw
			Copyable=4
			SkillCost=TIER_3_COST
			DamageMult=8
			StrRate=1
			ThrowMult=0
			ThrowAdd=0
			TriggerMessage="hacks their weapon cruelly into"
			Effect="Strike"
			EffectMult=3
			MortalBlow=1
			Cooldown=90
			verb/Hacksaw()
				set category="Skills"
				src.Activate(usr)
			Cancer_Snap
				NeedsSword=0
				TriggerMessage="uses their legs to crush"
				Cooldown=0
				//set from Acubens
		No_Worries
			Copyable = 0
			DamageMult=8
			StrRate=1.5
			Stunner=3
			Effect="Shockwave"
			EffectMult=1
			Cooldown=60
			TriggerMessage="tries to commit double suicide with "
		Form_Ataru
			Copyable=4
			SkillCost=TIER_3_COST
			DamageMult=8
			Reversal=1
			StrRate=1
			ThrowMult=0
			ThrowAdd=1
			TriggerMessage="does a slashing flip to break free of"
			Effect="Strike"
			EffectMult=2
			Cooldown=90
			verb/Form_Ataru()
				set category="Skills"
				set name="Form: Ataru"
				src.Activate(usr)



	proc
		Activate(var/mob/User)
			src.ThrowDir=User.dir
			if(src.Using)
				return
			if(!heavenlyRestrictionIgnore&&User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Grapples"))
				return
			if(!heavenlyRestrictionIgnore&&User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("All Skills"))
				return
			if(!heavenlyRestrictionIgnore&&NeedsSword && User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Armed Skills"))
				return
			if(!heavenlyRestrictionIgnore&&UnarmedOnly && User.Secret=="Heavenly Restriction" && User.secretDatum?:hasRestriction("Unarmed Skills"))
				return
			if(User.GrabMove)
				return//do not allow for grab moves to be mashed
			if(!User.Grab)
				if(src.Reversal)
					var/mob/Grabber=User.IsGrabbed()
					if(Grabber)
						Grabber.Grab=null
						User.Grab=Grabber
					else
						return
				else
					return
			if(src.UnarmedOnly)
				if(User.EquippedSword() && !User.HasSwordPunching())
					User << "You cannot use a sword and use [src]!"
					return
				if(User.EquippedStaff() && User.UsingBattleMage())
					User << "You cannot use Battle Mage style and use [src]!"
					return
			if(src.NeedsSword)
				if(!User.EquippedSword() && !User.HasSwordPunching() && !(User.EquippedStaff() && User.UsingBattleMage()))
					User << "You have to have a sword to use [src]!"
					return

			if(!src.ObjectEnabled)
				if(isobj(User.Grab))
					User << "You cannot use [src] on an object!"
					return
			else//object grapples
				if(isobj(User.Grab))
					if(istype(src, /obj/Skills/Grapple/Toss))
						var/obj/Q=User.Grab
						User.Grab=null
						for(var/x=5, x>0, x--)
							Q.transform=turn(Q.transform, 225)
							step(Q, src.ThrowDir)
							sleep(1)
						Q.transform=matrix()
						return//dont trigger cd for object interacts

			if(ismob(User.Grab))
				User.GrabMove=1
				var/mob/Trg=User.Grab
				// Trg.isGrabbed = TRUE
				User.Grab=null
				var/dmgRoll = User.GetDamageMod()
				#if DEBUG_GRAPPLE
				User.log2text("Grapple dmg roll ", dmgRoll, "damageDebugs.txt", User.ckey)
				#endif
				// get their damage roll, they don't get to ignore it cause its a grapple
				var/userPower = User.getPower(Trg)
				var/statPower = 1
				#if DEBUG_GRAPPLE
				User.log2text("Grapple User Power", userPower, "damageDebugs.txt", User.ckey)
				#endif
				var/itemDmg = 1
				if(src.StrRate)
					if(src.ForRate)
						statPower = User.getStatDmg2(unarmed = !NeedsSword, sword = NeedsSword, spirithand = ForRate) * StrRate
					else
						statPower = User.getStatDmg2(unarmed = !NeedsSword, sword = NeedsSword,) * StrRate
				else
					if(src.ForRate)
						statPower += User.GetFor(src.ForRate,)
				if(HarderTheyFall)
					var/enemyEnd = Trg.GetEnd(1)
					statPower += enemyEnd * (HarderTheyFall/10)
				#if DEBUG_GRAPPLE
				User.log2text("Grapple Stat Power", statPower, "damageDebugs.txt", User.ckey)
				#endif
				if(src.NeedsSword)
					itemDmg = (User.GetSwordDamage(User.EquippedSword()))
					if(src.SpecialAttack)
						var/obj/Items/Enchantment/Staff/st=User.EquippedStaff()
						var/obj/Items/Sword/sw=User.EquippedSword()
						if(sw?.MagicSword)
							itemDmg = ( User.GetSwordDamage(sw))
						else if(st)
							itemDmg = ( User.GetStaffDamage(st))
					itemDmg *= glob.GLOBAL_ITEM_DAMAGE_MULT
				var/unarmedBoon = !NeedsSword ? glob.GRAPPLE_MELEE_BOON : 1
				#if DEBUG_GRAPPLE
				User.log2text("Grapple Item Damage", itemDmg, "damageDebugs.txt", User.ckey)
				#endif
				var/endFactor = Trg.getEndStat(EndRate)
				if(User.HasPridefulRage())
					if(User.passive_handler.Get("PridefulRage") >= 2)
						endFactor = 1
					else
						endFactor = clamp(Trg.getEndStat(1)/2, 1, Trg.getEndStat(1))
				#if DEBUG_GRAPPLE
				User.log2text("Grapple End Factor", endFactor, "damageDebugs.txt", User.ckey)
				#endif
				var/Damage=1
				// userPower += User.getIntimDMGReduction(Trg)
				#if DEBUG_GRAPPLE
				User.log2text("Grapple User Power", userPower, "damageDebugs.txt", User.ckey)
				#endif
				Damage = (userPower**glob.DMG_POWER_EXPONENT) * (glob.CONSTANT_DAMAGE_EXPONENT+glob.GRAPPLE_EFFECTIVNESS) ** -(endFactor**glob.DMG_END_EXPONENT / statPower**glob.DMG_STR_EXPONENT)

				#if DEBUG_GRAPPLE
				User.log2text("Grapple Damage", Damage, "damageDebugs.txt", User.ckey)
				#endif
				Damage *= dmgRoll
				var/extra = User.passive_handler.Get("Muscle Power") / glob.MUSCLE_POWER_DIVISOR
				Damage *= DamageMult
				if(HarderTheyFall && Trg.BioArmor)
					Damage *= 1 + Trg.BioArmor / glob.HARDER_THEY_FALL_BIO_DIVISOR // i want to make the ticks matter, but cant formulate an idea how
				if(HarderTheyFall && Trg.VaizardHealth)
					Damage *= 1 + Trg.VaizardHealth / glob.HARDER_THEY_FALL_VAI_DIVISOR // i want to make the ticks matter, but cant formulate an idea how
				Damage *= (unarmedBoon + extra) // unarmed boon is 0.5,
				Damage *= glob.GRAPPLE_DAMAGE_MULT
				#if DEBUG_GRAPPLE
				User.log2text("Grapple Damage dmgroll", Damage, "damageDebugs.txt", User.ckey)
				#endif
				Damage *= itemDmg
				#if DEBUG_GRAPPLE
				User.log2text("Grapple Damage item dmg", Damage, "damageDebugs.txt", User.ckey)
				#endif
				if(Accuracy_Formula(User, Trg, AccMult=DamageMult/10, BaseChance=glob.WorldDefaultAcc, IgnoreNoDodge=0) == WHIFF)
					if(!User.NoWhiff())
						Damage/=glob.GRAPPLE_WHIFF_DAMAGE
				#if DEBUG_GRAPPLE
				User.log2text("Grapple Whiff Reduc", Damage, "damageDebugs.txt", User.ckey)
				#endif
				var/Hits=src.MultiHit
				
				while(Hits)
					if(!src.EnergyDamage)
						#if DEBUG_GRAPPLE
						User.log2text("Before do damage Grapple Damage", Damage, "damageDebugs.txt", User.ckey)
						#endif
						User.DoDamage(Trg, Damage, src.UnarmedOnly, src.NeedsSword, SpiritAttack=src.SpecialAttack)
						if(DrainBlood)
							User.secretDatum:gainBloodPower(Damage*src.DrainBlood)
							User.vampireBlood.fillGauge(clamp(User.secretDatum.secretVariable["BloodPower"]/4, 0, 1), 10)
					else
						Trg.LoseEnergy(Damage*src.EnergyDamage)
						Trg.GainFatigue(Damage*src.EnergyDamage)
						User.HealMana(Damage*src.EnergyDamage)
					Hits--
				if(src.MortalBlow)
					if(src.MortalBlow<0)
						Trg.MortallyWounded+=4
					else
						if(prob(glob.MORTAL_BLOW_CHANCE * MortalBlow) && !Trg.MortallyWounded)
							var/mortalDmg = Trg.Health * 0.05 // 5% of current
							Trg.LoseHealth(mortalDmg)
							Trg.WoundSelf(mortalDmg)
							Trg.MortallyWounded += 1
							OMsg(User, "<b><font color=#ff0000>[User] has dealt a mortal blow to [Trg]!</font></b>")
				OMsg(User, "[User] [src.TriggerMessage] [Trg]!")
				if(src.Effect in list("Suplex", "Drain", "Lotus", "SuperSuplex"))
					src.OneAndDone=1
				var/Times=src.EffectMult
				if(src.OneAndDone)
					Times=1
				while(Times)
					switch(src.Effect)
						if("Shockwave")
							KenShockwave(Trg)
						if("Bang")
							Bang(Trg.loc, 1.3, Offset=0.75)
						if("Lightning")
							LightningStrike2(Trg, Offset=GoCrand(0.5,0.1*src.EffectMult))
						if("Lotus")
							LotusEffect(User, Trg, src.EffectMult)
						if("MuscleBuster")
							MuscleBusterEffect(User, Trg, src.EffectMult)
						if("PotemkinBuster")
							PotemkinBusterEffect(User, Trg, EffectMult)
						if("Suplex")
							SuplexEffect(User, Trg)
						if("SuperSuplex")
							LotusEffect(User, Trg, src.EffectMult)
							SuplexEffect(User, Trg)
						if("Strike")
							User.HitEffect(Trg)
						if("Drain")
							animate(Trg, color=list(1,1,1, 0,1,0, 1,1,1, 0,0,0), time=10, flags=ANIMATION_RELATIVE)
							sleep(10)
							animate(Trg, color=Trg.MobColor, time=10, flags=ANIMATION_RELATIVE)
							sleep(10)
						if("SpinTornado")
							SpinTornado(User, Trg, EffectMult)
							ThrowDir=NORTH
						if("ShowStopper")
							ShowStopper(User, Trg, 4 + (clamp(Trg.GetEnd(), 1, 10)))
						if("Stomp")
							Stomp(User, Trg, 2, EffectMult)
					sleep(world.tick_lag)
					Times--
				User.Knockback((dmgRoll*src.ThrowMult)+src.ThrowAdd, Trg, Direction=src.ThrowDir, Forced=1, override_speed = ThrowSpeed)
				if(src.Stunner)
					Stun(Trg, src.Stunner)
					// sleep(5)//final effects
					switch(src.Effect)
						if("Bang")//biggest boom
							Bang(Trg.loc, src.EffectMult, Offset=0)
							KenShockwave(Trg, src.EffectMult/2)
						if("Lightning")
							KenShockwave(Trg, src.EffectMult/2)
						if("Strike")
							KenShockwave(Trg, src.EffectMult)
						if("SpinTornado")
							Crater(Trg,1.5)
						if("ShowStopper")
							Trg.icon_state = ""
				if(Crippling)
					Trg.AddCrippling(Crippling,User)
				User.GrabMove=0
				// Trg.isGrabbed = FALSE
				src.Cooldown()

				if(DashAfter)
					for(var/obj/Skills/Dragon_Dash/dd in User)
						User.SkillX("DragonDash",dd)
				if(removeAfter)
					User.DeleteSkill(src)
			else
				Log("Admin", "[ExtractInfo(User)] currently has [User.Grab.type] grabbed and attempted to grapple them with [src].")


/obj/Skills/Grapple/proc/doGrappleEffects(Times, mob/User, mob/Trg, EffectMult)
	set waitfor = 0
	while(Times)
		switch(src.Effect)
			if("Shockwave")
				KenShockwave(Trg)
			if("Bang")
				Bang(Trg.loc, 1.3, Offset=0.75)
			if("Lightning")
				LightningStrike2(Trg, Offset=GoCrand(0.5,0.1*src.EffectMult))
			if("Lotus")
				LotusEffect(User, Trg, src.EffectMult)
			if("MuscleBuster")
				MuscleBusterEffect(User, Trg, src.EffectMult)
			if("PotemkinBuster")
				PotemkinBusterEffect(User, Trg, EffectMult)
			if("Suplex")
				SuplexEffect(User, Trg)
			if("SuperSuplex")
				LotusEffect(User, Trg, src.EffectMult)
				SuplexEffect(User, Trg)
			if("Strike")
				User.HitEffect(Trg)
			if("Drain")
				animate(Trg, color=list(1,1,1, 0,1,0, 1,1,1, 0,0,0), time=10, flags=ANIMATION_RELATIVE)
				sleep(10)
				animate(Trg, color=Trg.MobColor, time=10, flags=ANIMATION_RELATIVE)
				sleep(10)
			if("SpinTornado")
				SpinTornado(User, Trg, EffectMult)
				ThrowDir=NORTH
			if("ShowStopper")
				ShowStopper(User, Trg, 4 + (clamp(Trg.GetEnd(), 1, 10)))
			if("Stomp")
				Stomp(User, Trg, 2, EffectMult)
		sleep(world.tick_lag)
		Times--

/mob/proc/SpinAnimation2(speed = 10, loops = 0, clockwise = 0, segments = 4, mob/a)
	if(!segments)
		return
	var/segment = 360/segments
	if(!clockwise)
		segment = -segment
	var/list/matrices = list()
	for(var/i in 1 to segments-1)
		var/matrix/M = matrix(transform)
		M.Turn(segment*i)
		matrices += M
	var/matrix/last = matrix(transform)
	matrices += last

	speed /= segments
	var/list/directions = list(WEST, SOUTH, EAST, NORTH)
	a.dir = directions[1]
	var/new_z = a.pixel_z + 6
	animate(a, pixel_z = new_z, time = 8, flags=ANIMATION_PARALLEL)
	animate(src, transform = matrices[1], time = speed, flags=ANIMATION_PARALLEL)
	animate(src, pixel_x = -16, pixel_y = 0, pixel_z = new_z, time = speed)
	sleep(speed)
	for(var/i in 2 to segments) //2 because 1 is covered above
		animate(src,transform = matrices[i], time = speed, flags=ANIMATION_PARALLEL)
		if(i == segments)
			animate(src, pixel_x = 0, pixel_y = 16, time = speed)
		else
			animate(src, pixel_x = -32 + (i*16), pixel_y = (i == 2 ? -16 : 0), time = speed)
		a.dir = directions[i]
		sleep(speed)
