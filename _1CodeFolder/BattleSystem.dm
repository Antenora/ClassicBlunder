/var/BASE_DELAY = 3 //base delay for all attacks
#define MISS 0 // WHEN YOU B MISSIN
#define HIT 1 // WHEN YOU B HITTIN
#define GLANCING 3 // ONLY FOR WHEN SURE HIT / SURE DODGE INTERACT
#define WHIFF 2 // WHEN YOU HIT ON THE 2ND ROLL
#define STATIC_RPP_GAIN 10
var/global/EXPERIMENTAL_ACCURACY = TRUE
var/global/CLAMP_POWER = TRUE



/mob/Admin3/verb/Clamp_Power()
	set name = "Enable Power Clamp"
	glob.CLAMP_POWER = !glob.CLAMP_POWER
	src << "Power clamp is now [glob.CLAMP_POWER ? "enabled" : "disabled"]."


mob/var/LastAnger
mob/proc/SetNoAnger(var/obj/Skills/Buffs/b, var/Value=0)
	b.NoAnger=Value
	if(b.NoAnger)
		OMsg(src, "<font color='grey'>[src]'s anger ebbs away...</font color>")
	else
		OMsg(src, "<font color='red'>[src]'s anger flares back to life!</font color>")

mob/proc/Anger(var/Enraged=0)
	if(src.HasCalmAnger()||src.HasNoAnger())
		if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Anger") && !secretDatum?:hasRestriction("Anger"))
			goto HeavenlyAnger
		src.Anger=0
		return
	HeavenlyAnger
	if(Anger==0&&!AngerCD)
		for(var/obj/Skills/Buffs/SpecialBuffs/Cursed/Jinchuuriki/J in src)
			if(!J.Using&&J.Mastery==1)
				if(src.ActiveBuff)
					if(src.ActiveBuff.SpecialBuffLock)
						src.ActiveBuff.Trigger(src)
				for(var/sb in usr.SlotlessBuffs)
					var/obj/Skills/Buffs/SB = usr.SlotlessBuffs[sb]
					if(SB)
						if(SB.SpecialBuffLock)
							SB.Trigger(src)
				if(src.SpecialBuff)
					if(src.SpecialBuff.BuffName=="Jinchuuriki")
						return
					else
						src.SpecialBuff.Trigger(src)
						J.Trigger(src)
						return

				else
					J.Trigger(src)
					return
		for(var/obj/Skills/Buffs/SpecialBuffs/Cursed/Vaizard_Mask/V in src)
			if(!V.Using&&V.Mastery==1)
				if(src.ActiveBuff)
					if(src.ActiveBuff.SpecialBuffLock)
						src.ActiveBuff.Trigger(src,Override=1)
				if(src.SpecialBuff)
					src.SpecialBuff.Trigger(src,Override=1)
				for(var/sb in usr.SlotlessBuffs)
					var/obj/Skills/Buffs/SB = usr.SlotlessBuffs[sb]
					if(SB)
						if(SB.SpecialBuffLock)
							SB.Trigger(src,Override=1)
				if(src.SpecialBuff)
					if(src.SpecialBuff.BuffName=="Vaizard Mask")
						return
					else
						src.SpecialBuff.Trigger(src)
						V.Trigger(src)
						return
				else
					V.Trigger(src)
					return

		if(CheckActive("Kamui Senketsu") && !CheckSlotless("Life Fiber Berserker") && (!Saga || Saga != "Kamui" || SagaLevel > 1 && SagaLevel < 4))
			if(Saga == "Kamui" && prob(50 - SagaLevel * 5))
				GetAndUseSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Life_Fiber_Berserker)
			else if(!Saga || Saga != "Kamui")
				GetAndUseSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Life_Fiber_Berserker)

		Anger=AngerMax
		if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Anger"))
			Anger *= 1+(secretDatum?:getBoon(src, "Anger")/10)
		
		race.onAnger(src)
		if(src.AngerMessage)
			if(!src.AngerColor)
				if(!Enraged)OMsg(src, "<font color='red'>[src] [src.AngerMessage]</font color>")
			else
				if(!Enraged)OMsg(src, "<font color='[src.AngerColor]'>[src] [src.AngerMessage]</font color>")
		else
			if(src.AngerMax>1)
				if(!src.AngerColor)
					if(!Enraged)OMsg(src, "<font color='red'>[src] becomes angry!</font color>")
				else
					if(!Enraged)OMsg(src, "<font color='[src.AngerColor]'>[src] becomes angry!</font color>")
/mob/var/zombieGetUps = 0
mob/proc/Unconscious(mob/P,var/text)
	if(src.KO)
		return
	if(P)
		var/obj/Skills/Buffs/undying = FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Undying_Rage)
		if(undying && !undying.Using)
			Health = 0.1
			undying.Trigger(src ,TRUE)
			return
		if(!istype(src,/mob/Player/FevaSplits))
			if(P.passive_handler["Undying Rage"])
				P.Health += 2.5 + (glob.racials.UNDYINGRAGE_HEAL * P.AscensionsAcquired)
			src.OMessage(15,"[src] is knocked out by [P]!","<font color=red>[src]([src.key]) is knocked out by [P]([P.key])")
			if(FightingSeriously(P,0)||src.BPPoison<1||src.MortallyWounded)
				src.KOBrutal=1
			else
				src.KOBrutal=0
				OMsg(src, "...but it wasn't too rough, so they'll probably walk it off.")
	if(text)
		if(!istype(src,/mob/Player/FevaSplits))
			src.OMessage(15,"[src] is knocked out by [text]!","<font color=red>[src]([src.key]) is knocked out by [text]")
	if(src.GatesActive==8 && src.Gate8Getups<2)
		src.KO=0
		src.OMessage(15,"...but [src]'s youth is burning too bright to be stopped!","<font color=red>[src]([src.key]) remains standing in their celebration of youth!")
		src.Health=1
		src.VaizardHealth+=30
		src.HealthAnnounce10++
		src.Gate8Getups++
		if(src.Gate8Getups>=2)
			if(src.CheckActive("Eight Gates"))
				src.ActiveBuff:Stop_Cultivation()//deactivate...
				GatesActive=0
		return
	if(src.passive_handler.Get("Tenacity"))
		if(src.HealthAnnounce10<=1&&FightingSeriously(P,src))
			if(prob((src.passive_handler.Get("Tenacity")*glob.TENACITY_GETUP_CHANCE)+5))
				src.KO=0
				src.OMessage(15, "...but [src] refuses to go down!", "<font color=red>[src]([src.key]) remains standing despite impossible odds!")
				src.Health=1
				src.VaizardHealth+=clamp(passive_handler.Get("Tenacity")* glob.TENACITY_VAI_MULT, glob.TENACITY_VAI_MIN, glob.TENACITY_VAI_MAX) //actual clutch now.
				src.HealthAnnounce10=2
				return
	if(passive_handler["Undying Rage"])
		Health = 0.1
		return
	var/GetUpOdds=1
	if(src.KOBrutal)
		GetUpOdds=2
	if(src.ManaDeath)
		// src.Death(null, "turning into stone from overexposure to natural energy!")
		src.ManaDeath=0
		senjutsuOverloadAlert=FALSE
		return
	src.PoweringUp=0
	src.PoweringDown=0
	src.Auraz("Remove")
	src.KOTimer=(300/(src.GetRecov())*glob.GetUpVar*GetUpOdds)
	src.DealWounds(src,20/max(src.GetRecov(2), 1))
	src.KO=1
	src.icon_state="KO"
	src.Health=1
	src.Energy=1
	src.PowerControl=100
	src.Burn=0
	src.AfterImageStrike=0
	src.VaizardHealth=0
	src.ForceCancelBeam()
	src.ForceCancelBuster()
	if(Secret == "Zombie")
		if(HealthCut + 0.1 < 1 && zombieGetUps + 1 <= AscensionsAcquired)
			Conscious()
			var/healthcutClose = clamp(0.9-(zombieGetUps/10),0,0.9)
			HealHealth(30 * (1 - healthcutClose))
			zombieGetUps++

	if(P && P.Saga == "Kamui" && P.CheckSlotless("Decapitation Mode"))
		var/a=0
		for(var/obj/Items/Wearables/w in src)
			if(w.PermEquip) continue
			if(!w.suffix) continue
			if(w.Augmented) continue
			w.ObjectUse(src)
			a++
		if(a) viewers(src) << "<b><font color=#ff7878 size=+2>[P] annihilates [src]'s clothing with a finishing blow!</b></font>"


	if(src.alpha<255)
		src.alpha=255
	var/obj/Items/Enchantment/Flying_Device/FD=src.EquippedFlyingDevice()
	if(src.Flying)
		Flight(src, Land=1)
		sleep(5)
		if(FD)
			FD.AlignEquip(src)

	src.MeditationCD=0
	if(GatesActive>0)
		if(ActiveBuff)
			if(CheckActive("Eight Gates"))
				ActiveBuff:handleGates(src, FALSE)
				GatesActive=0
		else
			GatesActive=0
	if(src.TotalInjury)
		if(!src.HasInjuryImmune())
			if(src.TotalInjury>=35&&src.TotalInjury<60&&src.BPPoison>=0.9)
				var/Time=RawHours(1)
				Time/=src.GetRecov()
				if(Time > BPPoisonTimer)
					src.BPPoisonTimer=Time
				src.BPPoison=0.9
				src.OMessage(10, "[src] has been lightly wounded!", "[src]([src.key]) has over 35% injury.")
			if(src.TotalInjury>=60&&src.BPPoison>=0.7)
				var/Time=RawHours(3)
				Time/=src.GetRecov()
				if(Time > BPPoisonTimer)
					src.BPPoisonTimer=Time
				src.BPPoison=0.7
				src.OMessage(10, "[src] has been heavily wounded!", "[src]([src.key]) has over 50% injury.")
			if(src.TotalInjury>=85)
				var/Time=RawHours(4)
				Time/=src.GetRecov()
				if(Time > BPPoisonTimer)
					src.BPPoisonTimer=Time
				src.BPPoison=0.5
				MortallyWounded+=1
				src.OMessage(10, "[src] has been grieviously wounded!", "[src]([src.key]) has over 85% injury.")
	if(src.client)
		if((transActive||tension)&&!src.HasNoRevert()&&!src.HasMystic())
			for(var/obj/Skills/Buffs/B in src)
				if(src.BuffOn(B)&&B.Transform&&!B.AlwaysOn)
					B.Trigger(src)
					break
			src.Revert()
			src<<"Being knocked out forced you to revert!"
		if(src.isRace(SAIYAN))
			src.Oozaru(0)
	if(src.Grab)
		src.Grab_Release()
	Poison = 0
	Burn = 0
	Shatter = 0
	Slow = 0
	Shock = 0



mob/proc/Conscious()
	if(!src.client)
		return
	// if(src.z==global.MajinZoneZ)
	// 	return
	if(src.KO)
		src.MortallyWounded=0
		src.TsukiyomiTime=1
		src.KOTimer=0
		src.KO=0
		src.icon_state=""

		if(src.KOBrutal)
			src.KOBrutal=0
			src.Health=1
			src.Energy=EnergyMax/100
		else
			src.Health=15
			src.Energy=EnergyMax/5

		if(src.Secret=="Zombie")
			src.HealthCut+=0.1
			src.OMessage(15,"[src] degenerates further.","<font color=blue>[src]([src.key]) decomposes...")
		if(isplayer(src))
			src:move_speed = MovementSpeed()
		src.OMessage(15,"[src] regains consciousness.","<font color=blue>[src]([src.key]) regains consciousness")

mob/proc/Death(mob/P,var/text,var/SuperDead=0, var/NoRemains=0, var/Zombie, extraChance, fakeDeath)
	BreakViewers() //STOP LOOKING AT ME THE SHAME OF DEATH TOO MUCH

	if(isplayer(src))
		for(var/mob/m in viewers(20, src))
			for(var/b in m.SlotlessBuffs)
				var/obj/Skills/Buffs/SlotlessBuffs/A = m.SlotlessBuffs[b]
				if(A.NeedsPassword&&A.FadeByDeath)
					A.Timer = 1
					A.TimerLimit = 1
					A.Trigger(m, 1)

	if(src.NoVoid)
		SuperDead=1

	if(src.IsGrabbed())
		src.IsGrabbed().Grab_Release()
	if(src.Grab)
		src.Grab_Release()

	if(istype(src, /mob/Player/AI))
		if(P)
			var/mob/Player/AI/a = src
			if(a.senpai && length(a.senpai.monsters))
				var/aiType = a.senpai.monsters[1].og_name
				if(!aiType)
					aiType = a.senpai.monsters[1].name
				if(P.killed_AI[aiType])
					P.killed_AI[aiType] ++
				else
					P.killed_AI[aiType] = 1
			var/rppBoon = a.Potential/100
			if(a.in_squad)
				a.in_squad.RemoveMember(src) //Squad members die die when they die.
				a.Potential = 0 //No gains!
			if(a.Potential)
				if(P.Secret=="Zombie")
					if(P.HealthCut > 0)
						P.HealthCut-=(0.001*src.Potential)
						P.HealthCut = max(0, P.HealthCut)
				var/potential_gain=a.Potential/10
				if(P.party)
					if(P.party.members.len>0)
						potential_gain /= 2
						for(var/mob/m in P.party.members)
							m.potential_gain(potential_gain, npc=1)
							//POTENTIAL GAIN ON AI KILL IS HERE !

							var/RPPGain = STATIC_RPP_GAIN // about 10 i'd say, given its 60 a day that means 6 = full
							RPPGain *= 1 + rppBoon
							RPPGain *= m.GetRPPMult()
							RPPGain = round(RPPGain)
							m.GiveRPP(RPPGain)
							// RPP GAIN ON AI KILL (PARTY)
				else
					P.potential_gain(potential_gain, npc=1)
					var/RPPGain = STATIC_RPP_GAIN // about 10 i'd say, given its 60 a day that means 6 = full
					RPPGain *= 1 + rppBoon
					RPPGain *= P.GetRPPMult()
					RPPGain = round(RPPGain)
					P.GiveRPP(RPPGain)
					// rpp gain on ai kill (normal)
			var/totalValue = 0
			var/foundMineral = FALSE
			var/foundMoney = FALSE
			if(P.moneyGrindedDaily < glob.progress.DailyGrindCap * P.EconomyMult)
				if(glob.MONEYORFRAGMENTS)
					for(var/obj/Items/mineral/m in src)
						totalValue += m.value
						del(m)
					for(var/obj/Items/mineral/min in P)
						foundMineral = TRUE
						if(P.passive_handler.Get("CashCow"))
							totalValue *= 1+(P.passive_handler.Get("CashCow")/10)
						if(totalValue + P.moneyGrindedDaily > glob.progress.DailyGrindCap * P.EconomyMult)
							totalValue = glob.progress.DailyGrindCap * P.EconomyMult - P.moneyGrindedDaily
						P.moneyGrindedDaily += totalValue
						min.value += totalValue
						min.assignState()
						min.name = "[Commas(round(min.value))] Mana Bits"
						P << "You've gained [totalValue * 1+(P.passive_handler.Get("CashCow")/10)] Mana Bits!"
						min.checkDuplicate(P)
					if(!foundMineral)
						var/obj/Items/mineral/mineral = new()
						P.contents += mineral
						if(P.passive_handler.Get("CashCow"))
							totalValue *= 1+(P.passive_handler.Get("CashCow")/10)
						if(totalValue + P.moneyGrindedDaily > glob.progress.DailyGrindCap * P.EconomyMult)
							totalValue = glob.progress.DailyGrindCap * P.EconomyMult - P.moneyGrindedDaily
						P.moneyGrindedDaily += totalValue
						mineral.value = totalValue
						mineral.assignState()
						mineral.name = "[Commas(round(mineral.value))] Mana Bits"
						P << "You've gained [totalValue*1+(P.passive_handler.Get("CashCow")/10)] Mana Bits!"
				else
					for(var/obj/Money/m in src)
						totalValue += m.Level
						del(m)
					for(var/obj/Money/money in P)
						foundMoney = TRUE
						if(P.passive_handler.Get("CashCow"))
							totalValue *= 1+(P.passive_handler.Get("CashCow")/10)
						if(totalValue + P.moneyGrindedDaily > glob.progress.DailyGrindCap * P.EconomyMult)
							totalValue = glob.progress.DailyGrindCap * P.EconomyMult - P.moneyGrindedDaily
						P.moneyGrindedDaily += totalValue
						money.Level += totalValue
						money.name = "[Commas(round(money.Level))] Cash"
						P << "You've gained [totalValue * 1+(P.passive_handler.Get("CashCow")/10)] Cash!"
						money.checkDuplicate(P)
					if(!foundMoney)
						var/obj/Money/money = new()
						P.contents += money
						if(P.passive_handler.Get("CashCow"))
							totalValue *= 1+(P.passive_handler.Get("CashCow")/10)
						if(totalValue + P.moneyGrindedDaily > glob.progress.DailyGrindCap * P.EconomyMult)
							totalValue = glob.progress.DailyGrindCap * P.EconomyMult - P.moneyGrindedDaily
						P.moneyGrindedDaily += totalValue
						money.Level = totalValue
						money.name = "[Commas(round(money.Level))] Mana Bits"
						P << "You've gained [totalValue*1+(P.passive_handler.Get("CashCow")/10)] Cash!"		
			
	if(text)
		src.OMessage(20,"[src] was just killed by [text]!","<font color=red>[src] was just killed by [text]!")
	if(P)
		// if(istype(s, /obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin))
		// 	s?:onKill(P, src)
		src.OMessage(20,"[src] was just killed by [P]!","<font color=red>[src] was just killed by [P]([P.key])!")
		if(P.HasPurity()&&IsEvil())
			SuperDead=2
			NoRemains=1
			if(P.Secret=="Ripple")
				src.OMessage(20,"[src] is completely destroyed by the Ripple running through their body!","<font color=red>[src] was purified [P]([P.key])!")
			else
				src.OMessage(20,"[src]'s existence is purged from the world!","<font color=red>[src] was purified [P]([P.key])!")

	if(NoRemains!=2)
		if(src.BloodPower>=2)
			var/obj/Items/Sword/s=P.EquippedSword()
			var/obj/Items/Enchantment/Staff/st=P.EquippedStaff()
			if(s||st)
				if((s && s.Element=="Silver")||(st && st.Element=="Silver"))
					src.OMessage(20,"[src]'s existence is purged from the world!","<font color=red>[src] was purified [P]([P.key])!")
				else if(P.Secret=="Ripple"&&P.HasPurity())
					src.OMessage(20,"[src] is completely destroyed by the Ripple running through their body!","<font color=red>[src] was purified [P]([P.key])!")

		if(src.Phylactery)
			for(var/obj/Items/Enchantment/Phylactery/Phy in world)
				if(Phy.Signature==src.ckey)
					OMsg(src, "[src] vanishes!")
					src.loc=Phy.loc
					src << "Your phylactery has saved you from doom."
					src.PhylacteryNerf+=0.2
					src.MortallyWounded=0
					src.BPPoison=0.9
					src.BPPoisonTimer=1
					src.Conscious()
					return
		if(src.NoDeath)
			if(src.HealthCut<0.5&&!SuperDead)
				src.KO=1
				src.Stasis=2000
				src.icon_state="KO"
				if(passive_handler.Get("VenomBlood"))
					src.overlays+=image('ArtificalObj.dmi',"Acid")
				else
					src.overlays+=image('ArtificalObj.dmi',"Blood")
				src << "Due to damage suffered you will be inert for a minute."
				src.Conscious()
				src.Stasis=0
				if(src.Secret!="Zombie")
					src.HealWounds(50)
					src.HealFatigue(50)
				src.HealHealth(50)
				src.HealEnergy(50)
				if(passive_handler.Get("VenomBlood"))
					src.overlays-=image('ArtificalObj.dmi',"Acid")
				else
					src.overlays-=image('ArtificalObj.dmi',"Blood")
				src.HealthCut+=0.2
				src << "Your body fails to regenerate all damage done to it."
				return
		if(locate(/obj/Regenerate, src))
			if(src.Regenerating)
				return
			for(var/obj/Regenerate/A in src)
				if(A.Level>=1)
					src.Regenerating=1
					A.X=src.x
					A.Y=src.y
					A.Z=src.z
					src.Regenerate(A)
					A.Level/=2
					src.loc=locate(glob.VOID_LOCATION[1], glob.VOID_LOCATION[2], glob.VOID_LOCATION[3])
					return
				else
					src << "Your body fails to regenerate rapidly enough... you can feel yourself fading."

	if(ClothBronze&&ClothBronze=="Phoenix")
		NoRemains=0
		SuperDead=0
		Zombie=0

	if(!src.client)
		NoRemains=1
		SuperDead=1
		Zombie=0

	if(src.Dead)
		NoRemains=1

	if(!NoRemains)
		// for(var/obj/Money/Q in src)
		// 	if(Q.Level)
		// 		var/obj/Money/M=new(src.loc)
		// 		M.Level=Q.Level
		// 		M.name="[Commas(round(M.Level))] [glob.progress.MoneyName]"
		// 		src.TakeMoney(M.Level)
	else
		// for(var/obj/Items/I in src)
		// 	if(I)
		// 		if(I.suffix=="*Equipped*"||I.suffix=="*Equipped (Second)*"||I.suffix=="*Equipped (Third)*")
		// 			I.ObjectUse(User=src)
		// 		if((!I.LegendaryItem&&I.Destructable)||NoRemains==2)
		// 			del I
		// 		if(I)
		// 			I.loc=src.loc
		// for(var/obj/Money/Q in src)
		// 	if(Q.Level)
		// 		var/obj/Money/M=new
		// 		M.Level=Q.Level
		// 		M.name="[Commas(round(M.Level))] [glob.progress.MoneyName]"
		// 		src.TakeMoney(M.Level)
		// 		if(M)
		// 			if(NoRemains==2)
		// 				del M
		// 			else
		// 				M.loc=src.loc
		if(!src.client)
			if(istype(src, /mob/Player/AI))
				var/mob/Player/AI/ai = src
				ai.EndLife(animatedeath=0)
			else
				src.loc=locate(0, 0, 0)
		else
			src.loc=locate(glob.DEATH_LOCATION[1], glob.DEATH_LOCATION[2], glob.DEATH_LOCATION[3])

	if(src.client)
		Void(SuperDead, Zombie, fakeDeath, 0)

	if(!src.Dead)
		src.Conscious()
	else
		src.Dead=1
		src.Conscious()
		src.Poison=0
		src.Burn=0
		src.Slow=0
		src.Shatter=0
		src.Harden=0
		src.Shock=0
		src.Sheared=0
		src.Crippled=0
		src.HealthCut=0
		src.EnergyCut=0
		src.TotalInjury=0
		src.TotalFatigue=0
		src.OverClockNerf=0
		src.OverClockTime=0
		src.BPPoison=1
		src.BPPoisonTimer=0
		src.MortallyWounded=0
		src.StrTax=0
		src.StrCut=0
		src.StrStolen=0
		src.StrEroded=0
		src.EndTax=0
		src.EndCut=0
		src.EndStolen=0
		src.EndEroded=0
		src.SpdTax=0
		src.SpdCut=0
		src.SpdStolen=0
		src.SpdEroded=0
		src.ForTax=0
		src.ForCut=0
		src.ForStolen=0
		src.ForEroded=0
		src.OffTax=0
		src.OffCut=0
		src.OffStolen=0
		src.OffEroded=0
		src.DefTax=0
		src.DefCut=0
		src.DefStolen=0
		src.DefEroded=0
		src.RecovTax=0
		src.RecovCut=0
		if(src.Secret=="Zombie")
			src.Secret=null
			src.NoDeath=0
			src.Timeless=0

obj/Regenerate
	var/X
	var/Y
	var/Z

mob/proc/Regenerate(var/obj/Regenerate/R in src)
	var/Timer=600/max(R.Level,0.0001)
	src.Regenerating=1
	src <<"You will regenerate in [Timer/10] seconds."
	src.OMessage(10,null,"[src]([src.key]) will regenerate in [Timer/10] seconds.")
	if(KO) Conscious()
	spawn(Timer)
		if(src&&R)
			if(R.X&&R.Y&&R.Z)
				loc=locate(R.X,R.Y,R.Z)
				src.Sheared=0
				src.Maimed=0
				src.MortallyWounded=0
				src.TotalInjury=0
				src.TotalFatigue=0
				src.HealHealth(100)
				src.HealEnergy(100)
				src.HealMana(100)
				R.X=null
				R.Y=null
				R.Z=null
				src.Regenerating=0


mob/Body
	var/description
	KO=1
	var/DeathTime
	var/TrulyDead=1//dont nerf people who are voiding naturally
	Savable=1
	Grabbable = 1
	New()
		DeathTime=world.realtime
		..()
	verb/Bury()
		set src in oview(1)
		OMsg(usr, "[usr] buries [src]")
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		src.layer=AREA_LAYER
		src.density=0
		src.Grabbable=0
		src.Savable=1
	verb/Loot()
		set category=null
		set src in range(1, usr)
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		usr.Grid("Loot", Lootee=src)
		OMsg(usr, "[usr] loots [src]...")
	Del()
		for(var/obj/Items/Sword/I in src)
			if(I.Conjured)
				del I
		for(var/obj/Items/Armor/I in src)
			if(I.Conjured)
				del I
		for(var/obj/Items/I in src)
			if(I.Stealable)
				if(I.suffix=="*Equipped*")
					spawn(5)
						I.suffix=null
			I.loc=src.loc
		if(Target)
			Target << "Your body has been destroyed."
		..()
	Click()
		..()
		if(!glob.ALLOW_CLICK_CORPSE) return
		if(!description)
			description = input(usr, "What sort of description would you like to set upon this body? How were they killed?\n The format is 'Name's corpse' INPUT ", "Dead Body") as message
		else
			usr << "[src] [description]"
/proc/SaveIRLNPCs()
	set background = 1
	var/savefile/F = new("Saves/IRLNPCs")
	var/list/npcs = list()
	for(var/mob/irlNPC/N in world)
		N.orgX = N.x
		N.orgY = N.y
		N.orgZ = N.z
		npcs += N
	F["IRLNPCs"] << npcs

/proc/LoadIRLNPCs()
	var/savefile/F = new("Saves/IRLNPCs")
	var/list/npcs = new()
	F["IRLNPCs"] >> npcs
	for(var/mob/irlNPC/N in npcs)
		N.loc = locate(N.orgX, N.orgY, N.orgZ)


proc/Save_Bodies()
	set background = 1
	var/Amount=0
	var/E=1
	var/savefile/F=new("Saves/Bones/File[E]")
	var/list/Types=new
	for(var/mob/Body/A in world) if(A.Savable&&A.z)
		A.buildPreviousX = A.x
		A.buildPreviousY = A.y
		A.buildPreviousZ = A.z
		Types+=A
		Amount+=1
		if(Amount % 250 == 0)
			F["Types"]<<Types
			E++
			F=new("Saves/Bones/File[E]")
			Types=new
	if(Amount % 250 != 0)
		F["Types"]<<Types
	hacklol
	if(fexists("Saves/Bones/File[E++]"))
		fdel("Saves/Bones/File[E++]")
		world<<"<small>Server: Objects DEBUG system check: extra bones file deleted!"
		E++
		goto hacklol

proc/Load_Bodies()
	var/amount=0
	var/filenum=0
	wowza
	filenum++
	if(fexists("Saves/Bones/File[filenum]"))
		var/savefile/F=new("Saves/Bones/File[filenum]")
		var/list/L=new
		F["Types"]>>L
		for(var/mob/Body/A in L)
			amount+=1
			A.x = A.buildPreviousX
			A.y = A.buildPreviousY
			A.z = A.buildPreviousZ
			A.loc = locate(A.buildPreviousX, A.buildPreviousY, A.buildPreviousZ)
			world.log << "[A] found in [L] [A.loc], at [A.x], [A.y], [A.z] | [A.buildPreviousX], [A.buildPreviousY], [A.buildPreviousZ]"
		goto wowza

mob/proc/Leave_Body(var/SuperDead=0, var/Zombie, var/ForceVoid=0)
	var/mob/Body/A=new
	var/ActuallyDead=0
	var/Chance=glob.VoidChance
	// var/c_red=Chance * (min(src.Potential, 100) / 100)
	// Chance-=c_red

	if(src.Saga=="King of Braves")
		Chance+=(src.SagaLevel*5)

	if(src.ClothBronze=="Phoenix")
		Chance+=(40 - (src.SagaLevel*5))

	A.icon_state="KO"
	A.name="Body of [src]"
	A.loc=locate(src.x, src.y, src.z)
	A.transform=src.transform
	src.loc=locate(glob.currentlyVoidingLoc[1], glob.currentlyVoidingLoc[2], glob.currentlyVoidingLoc[3])

	if(!SuperDead)
		if(glob.VoidsAllowed||ForceVoid)
			var/Timer
			ActuallyDead=1
			if(ForceVoid)
				Timer=Minute(1)//this will always happen
				ActuallyDead=0
				A.TrulyDead=0
			if(prob(Chance))
				ActuallyDead=0
				A.TrulyDead=0
			if(!ActuallyDead)
				Log("Admin", "[ExtractInfo(src)] is voiding.")
			if(ForceVoid > 1)
				Timer=Minute(ForceVoid)
			else
				Timer=Minute(1)
			src << "<font color=red><big>DO NOT LOG OUT!</big></font color>"
			src << "Your fate is still uncertain and you may come back to life..."
			spawn(Timer)
				if(src&&A)
					if(src.Grab)
						src.Grab_Release()
					var/mob/m=src.IsGrabbed()
					if(m)
						m.Grab_Release()
					if(!ActuallyDead)
						src << "Your fate is not yet decided! You return to the light of the living!"
						A.Barely_Alive(src)
					else
						if(src.NoSoul)
							src << "You have no soul contained within your body; there is nothing after life for you."
							src.Savable=0
							if(istype(src, /mob/Players))
								fdel("Saves/Players/[src.ckey]")
							src.loc=locate(0,0,0)
							return
						else
							src << "Your fate has been decided; you move on to the realm of the dead..."
							src.loc=locate(glob.DEATH_LOCATION[1], glob.DEATH_LOCATION[2], glob.DEATH_LOCATION[3])

	else if(SuperDead&&Zombie)
		src<<"<font color=red><big>DO NOT LOG OUT!"
		src<<"Your life is being shackled by a powerful curse!"
		src.OMessage(0,"","<font color=red>[src] is zombifying.")
		ActuallyDead=0
		spawn(600)
			if(src&&A)
				A.Unholy_Alive(src)
	else
		ActuallyDead=1
		if(src.NoSoul)
			src << "<font size='big'><b>You have been destroyed completely by some overwhelming force -- body and soul. Nothing remains.</b></font size>"
			src.Savable=0
			if(istype(src, /mob/Players))
				fdel("Saves/Players/[src.ckey]")
			src.loc=locate(0,0,0)
			return
		else
			src << "Your fate has been sealed by an overwhelming force; you move on immediately to the realm of the dead..."
			src.loc=locate(glob.DEATH_LOCATION[1], glob.DEATH_LOCATION[2], glob.DEATH_LOCATION[3])
	src.Burn=0
	src.Poison=0
	src.Slow=0
	src.Shatter=0
	src.Shock=0
	src.Sheared=0
	src.Crippled=0
	src.Confused=0
	src.Stunned=0
	A.Body=Body
	if(1>=ForceVoid)
		A.Health=1000
	A.EnergyMax=src.EnergyMax
	A.Energy=src.Energy
	A.Power=src.Power
	A.StrMod=src.GetStr()
	A.EndMod=src.GetEnd()
	A.ForMod=src.GetFor()
	A.Target=src
	A.icon=src.icon
	A.overlays=src.overlays
	A.DeathKillerTargets=src.key//used for Death Killer
	A.Savable=0
	if(src.ClothBronze&&src.ClothBronze=="Phoenix"&&!ActuallyDead)
		A.invisibility=100
		A.Savable=1
		A.density=0
		A.Grabbable=0
		OMsg(A, "[A] turns to ash!")
	if(!ForceVoid)
		if(passive_handler.Get("VenomBlood"))
			A.overlays+=image('ArtificalObj.dmi',"Acid")
		else
			A.overlays+=image('ArtificalObj.dmi',"Blood")
	if(src.client)
		src.overlays-='Halo.dmi'
		src.overlays+='Halo.dmi'
	if(ActuallyDead)
		for(var/obj/Items/I in src)
			if(I.suffix=="*Equipped*")
				I.ObjectUse(src)
			A.contents+=I
	for(var/obj/Money/Q in src)
		if(Q.Level)
			var/obj/Money/M=new(A.loc)
			M.Level=Q.Level
			M.name="[Commas(round(M.Level))] [glob.progress.MoneyName]"
			src.TakeMoney(M.Level)
	if(src.NoSoul && !ForceVoid && !Zombie)
		src << "<font size='big'><b>You have died on a plane with no Afterlife; there is nothing for you now. This is oblivion.</b></font size>"
		src.Savable=0
		if(istype(src, /mob/Players))
			fdel("Saves/Players/[src.ckey]")
		src.loc=locate(0,0,0)
		return


mob/proc/Barely_Alive(mob/P) if(P)
	P.loc=loc
	if(P.KO)
		P.Conscious()
	P.Revive()
	P<<"You have returned to your body, barely alive."
	del(src)

mob/proc/Unholy_Alive(mob/P) if(P)
	var/icon/Z=new(P.icon)
	Z.MapColors(0.3,0.3,0.3, 0.59,0.59,0.59, 0.11,0.11,0.11, 0,0,0)
	P.loc=loc
	P.Conscious()
	P.Health=50
	P.Energy=100
	P.Sheared=100
	P.HealthCut=0.2
	P.NoDeath=1
	P.Timeless=1
	P.Revive()
	P.icon=Z
	P.Secret="Zombie"
	P<<"You have returned to your body, a mockery of what you once were."
	del(src)

mob/proc/Revive()
		overlays-='Halo.dmi'
		Dead=0


proc/getBackSide(mob/offender, mob/defender, diags = FALSE)
	if(defender)
		var/resultingDir = get_dir(offender, defender)
		// . = opposite_dirs[resultingDir]
		switch(defender.dir)
			if(NORTH)
				if(resultingDir in list(NORTH, NORTHWEST, NORTHEAST))
					return 1
			if(SOUTH)
				if(resultingDir in list(SOUTH, SOUTHEAST, SOUTHWEST))
					return 1
			if(EAST)
				if(resultingDir in list(EAST, NORTHEAST, SOUTHEAST))
					return 1
			if(WEST)
				if(resultingDir in list(WEST, NORTHWEST, SOUTHWEST))
					return 1
			if(NORTHWEST)
				if(resultingDir in list(NORTHWEST, NORTH, WEST))
					return 1
			if(NORTHEAST)
				if(resultingDir in list(NORTHEAST, NORTH, EAST))
					return 1
			if(SOUTHWEST)
				if(resultingDir in list(SOUTHWEST, SOUTH, WEST))
					return 1
			if(SOUTHEAST)
				if(resultingDir in list(SOUTHEAST, SOUTH, EAST))
					return 1
/mob/Admin3/verb/simulateAttacks()
	var/self = input(src, "Use on self?") in list("Yes", "No")
	var/mob/Player/p1 = src
	if(self == "No")
		p1 = input(src, "who") in players
		Target = input(src, "who") in players
	if(!Target) 
		src<< "get an enemy"
		return
	var/looplength = input(src, "How many attempts") as num
	var/list/damageMatrix = list()
	var/forcedmgrolls = input(src, "Force the dmg rolsl temp?") in list(1,0)
	var/orgdmgrolls = list(glob.min_damage_roll, glob.upper_damage_roll)
	var/dmgrolls = list(glob.min_damage_roll, glob.upper_damage_roll)
	var/_range = input(src, "Do you want to do a range?") in list(1,0)
	var/min_range
	var/max_range 
	var/per_change
	if(_range)
		min_range = input(src, "min_range") as num
		max_range = input(src, "max_range") as num
		per_change = input(src, "per_change") as num
	if(forcedmgrolls)
		dmgrolls[1] = input(src, "What is the min?") as num
		dmgrolls[2] = input(src, "What is the upper?") as num
		glob.min_damage_roll = dmgrolls[1]
		glob.upper_damage_roll = dmgrolls[2]
	if(_range)
		var/total_iteration = (max_range-min_range)/per_change
		var/statInQuestion = input(src, "what stat") in list("Str", "End")
		if(statInQuestion == "End")
			StrReplace = input(src, "What srt do u want") as num
		else
			Target.EndReplace = input(src, "What end do u want") as num
		for(var/i in 0 to total_iteration)
			if(statInQuestion == "End")
				Target.EndReplace = min_range + (per_change * i)
			else
				StrReplace = min_range + (per_change * i)
			for(var/attempts in 1 to looplength)
				var/result = Melee1(BreakAttackRate=1)
				damageMatrix["[result]"]++
				if(Target.KO)
					Target.Conscious()
				Target.Health=100
				Target.Energy=Target.EnergyMax
				Target.Burn=0
				Target.Poison=0
				Target.Slow=0
				Target.Shock=0
				Target.Shatter=0
				Target.TotalFatigue=0
				Target.TotalInjury=0
				Target.BPPoison=1
				Target.BPPoisonTimer=0
				Energy=EnergyMax
			var/average
			var/sum
			var/msg = {"Simulated [p1] vs [Target]
[looplength] times."}
			for(var/x in damageMatrix)
				sum += text2num(x) * damageMatrix[x] // the number and the instances
				msg += "( [x] Dmg for [damageMatrix[x]] times ), "
			average = sum/looplength

			msg += {"
[p1] did a total of [sum] damage to [Target].
The average damage was [average] over [looplength] times.
[p1] has [GetStr()] Str, and [GetFor()] For. 
[Target] has [Target.GetEnd()] End."}
			src << msg
			damageMatrix = list()
			sum = 0
			average = 0
	else
		for(var/attempts in 1 to looplength)
			var/result = Melee1(BreakAttackRate=1)
			damageMatrix["[result]"]++
			if(Target.KO)
				Target.Conscious()
			Target.Health=100
			Target.Energy=Target.EnergyMax
			Target.Burn=0
			Target.Poison=0
			Target.Slow=0
			Target.Shock=0
			Target.Shatter=0
			Target.TotalFatigue=0
			Target.TotalInjury=0
			Target.BPPoison=1
			Target.BPPoisonTimer=0
		

		var/average
		var/sum
		var/msg = {"Simulated [p1] vs [Target]
[looplength] times."}
		for(var/x in damageMatrix)
			sum += text2num(x) * damageMatrix[x] // the number and the instances
			msg += "( [x] Dmg for [damageMatrix[x]] times ), "
		average = sum/looplength

		msg += {"\n
[p1] did a total of [sum] damage to [Target].
The average damage was [average] over [looplength] times.
[p1] has [GetStr()] Str, and [GetFor()] For. 
[Target] has [Target.GetEnd()] End."}
	
		src << msg
	if(forcedmgrolls)
		glob.min_damage_roll = orgdmgrolls[1] 
		glob.upper_damage_roll = orgdmgrolls[2]
		StrReplace = 0
		Target.EndReplace = 0 
/mob/Admin3/verb/SimulateAccuracyNOSTATCHANGE()
	set category = "Debug"
	var/self = input(src, "Use on self?") in list("Yes", "No")
	var/mob/Player/p1 = src
	if(self == "No")
		p1 = input(src, "who") in players
		Target = input(src, "who") in players
	if(!Target) 
		src<< "get an enemy"
		return
	var/accmult = input(src, "What accmult do u want") as num
	var/looplength = input(src, "How many attempts") as num
	var/hits = 0 
	var/misses = 0 
	var/whiffs = 0
	var/flowdodge = 0
	var/obj/Items/Sword/s = p1.EquippedSword()
	var/obj/Items/Sword/s2 = p1.EquippedSecondSword()
	if(!s2 && p1.UsingDualWield()) s2 = s
	var/obj/Items/Sword/s3 = p1.EquippedThirdSword()
	if(!s3 && p1.UsingTrinityStyle()) s3 = s
	var/obj/Items/Enchantment/Staff/st = p1.EquippedStaff()
	var/obj/Items/Armor/atkArmor = p1.EquippedArmor()
	var/swordAtk = FALSE
	if(s || s2 || s3)
		swordAtk = TRUE
	for(var/attempts in 1 to looplength)
		var/newaccmult = accmult
		var/list/itemMod = p1.getItemDamage(list(s,s2,s3,st), 1, newaccmult, FALSE, FALSE, swordAtk)
		if(s)
			newaccmult = itemMod[2]
		if(atkArmor)
			newaccmult *= p1.GetArmorAccuracy(atkArmor)
		if(Target.GetFlow())
			var/enemyflow
			var/instinct = p1.HasInstinct()
			var/base_prob = glob.BASE_FLOW_PROB
			var/result = 0
			enemyflow = Target.GetFlow()
			if(instinct)
				result = enemyflow - instinct
			else
				result = enemyflow
			if(prob(base_prob*result))
				flowdodge++
				continue
		var/result = Accuracy_Formula(p1, Target, newaccmult, glob.WorldDefaultAcc, 0, 0)
		switch(result)
			if(HIT)
				hits++
			if(WHIFF)
				whiffs++
			if(MISS)
				misses++
	src <<"\nsimulated [p1] vs [Target]  [looplength] times at \nhits:[hits]([round((hits/looplength)*100)]%)\nwhiffs:[whiffs]([round((whiffs/looplength)*100)]%)\nmisses:[misses]([round((misses/looplength)*100)]%)\nflowdodge:[flowdodge]([round((flowdodge/looplength)*100)]%)\nmissed [((misses+whiffs+flowdodge)/looplength)*100]% of the time"
	src <<"simulating target vs src"
	hits = 0 
	misses = 0 
	whiffs = 0
	flowdodge = 0
	s = Target.EquippedSword()
	st = Target.EquippedStaff()
	atkArmor = Target.EquippedArmor()
	swordAtk = FALSE
	if(s || s2 || s3)
		swordAtk = TRUE
	for(var/attempts in 1 to looplength)
		var/newaccmult = accmult
		if(p1.HasFlow())
			var/flow
			var/base_prob = glob.BASE_FLOW_PROB
			var/result = 0
			var/enemyinstinct = Target.HasInstinct()
			flow = GetFlow()
			if(enemyinstinct)
				result = flow - enemyinstinct
			else
				result = flow
			if(prob(base_prob*result))
				flowdodge++
				continue
		var/list/itemMod = Target.getItemDamage(list(s,s2,s3,st), 1, newaccmult, FALSE, FALSE, swordAtk)
		if(s)
			newaccmult = itemMod[2]
		if(atkArmor)
			newaccmult *= GetArmorAccuracy(atkArmor)
		var/result = Accuracy_Formula(Target, p1, newaccmult, glob.WorldDefaultAcc, 0, 0)
		switch(result)
			if(HIT)
				hits++
			if(WHIFF)
				whiffs++
			if(MISS)
				misses++
	src <<"\nsimulated [Target] vs [p1] [looplength] times at \nhits:[hits]([round((hits/looplength)*100)]%)\nwhiffs:[whiffs]([round((whiffs/looplength)*100)]%)\nmisses:[misses]([round((misses/looplength)*100)]%)\nflowdodge:[flowdodge]([round((flowdodge/looplength)*100)]%) missed [((misses+whiffs+flowdodge)/looplength)*100]% of the time"

mob/var/minhitroll = 0
/mob/Admin3/verb/SimulateAccuracy()
	set category = "Debug"
	if(!Target) 
		src<< "get an enemy"
		return
	var/off = input(src, "What off do u want") as num
	OffMod = off
	var/spd = input(src, "What spd do u want") as num
	SpdMod = spd
	var/def = input(src, "What def do u want") as num
	DefMod = def 
	var/flow = input(src, "What flow do u want") as num
	var/instinct = input(src, "What instinct do u want") as num
	passive_handler.Set("Flow", flow)
	passive_handler.Set("Instinct", instinct)
	var/accmult = input(src, "What accmult do u want") as num
	var/enemyoff = input(src, "What off do u want enemy to have") as num
	Target.OffMod = enemyoff
	var/enemydef = input(src, "What def do u want enemy to have") as num
	Target.DefMod = enemydef
	var/enemyspd = input(src, "What spd do u want enemy to have") as num
	Target.SpdReplace = enemyspd
	var/enemyflow = input(src, "What flow do u want") as num
	var/enemyinstinct = input(src, "What instinct do u want") as num
	Target.passive_handler.Set("Flow",  enemyflow)
	Target.passive_handler.Set("Instinct",enemyinstinct)
	var/looplength = input(src, "How many attempts") as num
	var/randomizeAccMult = input(src, "randomize acc mult between 1 and accmult?") in list(TRUE, FALSE)
	var/hits = 0 
	var/misses = 0 
	var/whiffs = 0
	var/flowdodge = 0
	var/obj/Items/Sword/s = EquippedSword()
	var/obj/Items/Sword/s2 = EquippedSecondSword()
	if(!s2 && UsingDualWield()) s2 = s
	var/obj/Items/Sword/s3 = EquippedThirdSword()
	if(!s3 && UsingTrinityStyle()) s3 = s
	var/obj/Items/Enchantment/Staff/st = EquippedStaff()
	var/obj/Items/Armor/atkArmor = EquippedArmor()
	var/swordAtk = FALSE
	if(s || s2 || s3)
		swordAtk = TRUE
	for(var/attempts in 1 to looplength)
		var/newaccmult = accmult
		if(randomizeAccMult)
			newaccmult = randValue(0.8, accmult)
		var/list/itemMod = getItemDamage(list(s,s2,s3,st), 1, newaccmult, FALSE, FALSE, swordAtk)
		if(s)
			newaccmult = itemMod[2]
		if(atkArmor)
			newaccmult *= GetArmorAccuracy(atkArmor)
		if(enemyflow)
			var/base_prob = glob.BASE_FLOW_PROB
			var/result = 0
			enemyflow = Target.GetFlow()
			instinct = HasInstinct()
			if(instinct)
				result = enemyflow - instinct
			else
				result = enemyflow
			if(prob(base_prob*result))
				flowdodge++
				continue
		var/result = Accuracy_Formula(src, Target, newaccmult, glob.WorldDefaultAcc, 0, 0)
		switch(result)
			if(HIT)
				hits++
			if(WHIFF)
				whiffs++
			if(MISS)
				misses++
	src <<"\nsimulated [looplength] times at \nhits:[hits]([round((hits/looplength)*100)]%)\nwhiffs:[whiffs]([round((whiffs/looplength)*100)]%)\nmisses:[misses]([round((misses/looplength)*100)]%)\nflowdodge:[flowdodge]([round((flowdodge/looplength)*100)]%)\nminhitsrolles:[minhitroll]\nmissed [((misses+whiffs+flowdodge)/looplength)*100]% of the time"
	src <<"simulating target vs src"
	hits = 0 
	misses = 0 
	whiffs = 0
	flowdodge = 0
	s = Target.EquippedSword()
	st = Target.EquippedStaff()
	atkArmor = EquippedArmor()
	swordAtk = FALSE
	minhitroll = 0
	if(s || s2 || s3)
		swordAtk = TRUE
	for(var/attempts in 1 to looplength)
		var/newaccmult = accmult
		if(randomizeAccMult)
			newaccmult = randValue(0.8, accmult)
		if(flow)
			var/base_prob = glob.BASE_FLOW_PROB
			var/result = 0
			flow = GetFlow()
			if(enemyinstinct)
				result = flow - enemyinstinct
			else
				result = flow
			if(prob(base_prob*result))
				flowdodge++
				continue
		var/list/itemMod = Target.getItemDamage(list(s,s2,s3,st), 1, newaccmult, FALSE, FALSE, swordAtk)
		if(s)
			newaccmult = itemMod[2]
		if(atkArmor)
			newaccmult *= GetArmorAccuracy(atkArmor)
		var/result = Accuracy_Formula(Target, src, newaccmult, glob.WorldDefaultAcc, 0, 0)
		switch(result)
			if(HIT)
				hits++
			if(WHIFF)
				whiffs++
			if(MISS)
				misses++
	src <<"\nsimulated [looplength] times at \nhits:[hits]([round((hits/looplength)*100)]%)\nwhiffs:[whiffs]([round((whiffs/looplength)*100)]%)\nmisses:[misses]([round((misses/looplength)*100)]%)\nflowdodge:[flowdodge]([round((flowdodge/looplength)*100)]%)\nminhitsrolled:[minhitroll]\nmissed [((misses+whiffs+flowdodge)/looplength)*100]% of the time"
	minhitroll = 0
	// var/list/itemMod = getItemDamage(list(s,s2,s3,st), delay, acc, SecondStrike, ThirdStrike, swordAtk)
	// delay = itemMod[1]
	// acc = itemMod[2]
// var/obj/Items/Armor/atkArmor = EquippedArmor()
// 				var/obj/Items/Armor/defArmor = enemy.EquippedArmor()

// 				if(atkArmor)
// 					acc *= GetArmorAccuracy(atkArmor)
// 					delay /= GetArmorDelay(atkArmor)
	//LABEL: ACCURACY FORMULA
proc/Accuracy_Formula(mob/Offender,mob/Defender,AccMult=1,BaseChance=glob.WorldDefaultAcc, Backfire=0, IgnoreNoDodge=0)
	if(Offender&&Defender)
		if(Defender.Frozen==3)
			return MISS
		if(Offender.HasNoMiss())
			return HIT
		if(Defender.HasNoDodge()&&!IgnoreNoDodge)
			return HIT
		if(Backfire&&Offender==Defender)
			return HIT
		if(Defender.SureDodge&&!Defender.passive_handler.Get("NoDodge"))
			Defender.SureDodge=0
			if(Offender.SureHit)
				return WHIFF
			else
				return MISS
		if(Offender.SureHit)
			Offender.SureHit=0
			return HIT
		if(Defender.Stunned || Defender.Launched || Defender.PoweringUp)
			return HIT
		if(Offender.Grab == Defender && glob.GRABS_AUTOHIT)
			return HIT

		if(getBackSide(Offender, Defender))

			if(Defender.CheckSlotless("Great Ape")|| Defender.passive_handler.Get("Vulnerable Behind"))
				var/tail_resistance_max = Defender.AscensionsAcquired + (round(Defender.AscensionsAcquired/2))
				var/tail_resistance = Defender.tail_mastery / 20
				tail_resistance += Defender.AscensionsUnlocked * 5
				tail_resistance = clamp(tail_resistance, 0, tail_resistance_max * 5)
				if(prob(50 - tail_resistance))
					Stun(Defender, 2 - (tail_resistance * 0.1))
					Defender.tailResistanceTraining(25 + tail_resistance * 2)
					if(Defender.Stunned)
						return HIT
				else
					Defender.tailResistanceTraining(5)
			if(prob(0.5))
				// smirk
				OMsg(Defender, "[Defender] is getting Ashton'd.")

			AccMult*=1.2

		if(Offender.UsingCriticalImpact())
			AccMult*=1.15
		if(Defender.HasRefractivePlating()||Defender.HasPlatedWeights())
			AccMult*=1.15


		if(Offender.AttackQueue)
			AccMult+=Offender.QueuedAccuracy()

		if(Offender.SenseRobbed>=4&&(Offender.SenseUnlocked<=Offender.SenseRobbed&&Offender.SenseUnlocked>5))
			AccMult*=(1-(Offender.SenseRobbed*0.1))
		if(Defender.SenseRobbed>=4&&(Defender.SenseUnlocked<=Defender.SenseRobbed&&Defender.SenseUnlocked>5))
			AccMult/=(1-(Offender.SenseRobbed*0.1))


		// if(Defender.Adrenaline)
		// 	var/CombatSlow=10/max(Defender.Health,1)
		// 	if(CombatSlow>1)
		// 		AccMult/=1+(0.05*CombatSlow)
		// ! ADRENALINE NO LONGER LETS PEOPLE DODGE MORE !

		if(Offender.HasClarity()||Offender.HasFluidForm()||Offender.HasIntuition())
			if(AccMult<1)
				if(Offender.HasFluidForm())
					AccMult+=(Offender.HasFluidForm()*glob.FLUID_FORM_RATE)*AccMult
				if(AccMult>1)
					AccMult=1
		if(Defender.HasClarity()||Defender.HasFluidForm()||Defender.HasIntuition())
			if(AccMult>1)
				if(Defender.HasFluidForm())
					AccMult-=(Defender.HasFluidForm()*glob.FLUID_FORM_RATE)
				if(AccMult<1)
					AccMult=1
		var/GodKiDif = 1
		if(Offender.GetGodKi())
			GodKiDif = 1 + Offender.GetGodKi()
		if(Defender.GetGodKi())
			GodKiDif /= (1 + Defender.GetGodKi())
		AccMult *= GodKiDif

		// START OF REAL FUNCTION
		var/OffenseModifier
		var/DefenseModifier
		var/OffenseAdvantage = Offender.Power / Defender.Power
		var/DefenseAdvantage = Defender.Power / Offender.Power
		var/Offense 
		var/Defense
		var/TotalAccuracy 
		if(glob.CLAMP_POWER)
			if(!Offender.ignoresPowerClamp())
				OffenseAdvantage = clamp(OffenseAdvantage,glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
			if(!Defender.ignoresPowerClamp())
				DefenseAdvantage = clamp(DefenseAdvantage,glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
		
		if(glob.JORDAN_ACCURACY)
			// trying to make it less complex for the very roughly same result
			Offense = Offender.GetOff(glob.ACC_OFF)+Offender.GetSpd(glob.ACC_OFF_SPD)
			Defense = Defender.GetDef(glob.ACC_DEF)+Defender.GetSpd(glob.ACC_DEF_SPD)
			
			var/mod = clamp(((Offense/Defense) * AccMult) * OffenseAdvantage, glob.MIN_JORDAN_ACC_MOD, glob.MAX_JORDAN_ACC_MOD)



			if(glob.OLD_ACCURACY)
				Offense=(Offender.Power*(Offender.GetOff(glob.ACC_OFF)+Offender.GetSpd(glob.ACC_OFF_SPD)))*(1+Offender.GetGodKi())
				Defense=(Defender.Power*(Defender.GetDef(glob.ACC_DEF)+Defender.GetSpd(glob.ACC_DEF_SPD)))*(1+Defender.GetGodKi())
				mod = clamp(((Offense*AccMult)/max(Defense,0.01)), 0.5, 2)
			
			var/roll = randValue((100-BaseChance) * mod, 100)
			if(glob.MOD_AFTER_ROLL)
				roll = randValue((100-BaseChance), 100)
				roll*=mod
			
			if(roll >= BaseChance)
				return HIT
			else
				if(glob.MOD_AFTER_ROLL)
					roll = randValue((100-BaseChance), 100)
					roll*=mod
				else
					roll = randValue((100-BaseChance) * mod, 100)
				
				if(roll <= glob.WorldWhiffRate)
					return MISS
				else if(roll > glob.WorldWhiffRate)
					return WHIFF
		else
			if(1 + ((OffenseAdvantage - DefenseAdvantage)/2) < 1) // output is if = or under, make 1
				OffenseModifier = 1
			else
				OffenseModifier = 1 + ((OffenseAdvantage - DefenseAdvantage)/2) // at 2x power instead of hitting 2x times mroe, u hit 1.75x more

			if(1 + ((DefenseAdvantage - OffenseAdvantage)/2) < 1)
				DefenseModifier = 1
			else
				DefenseModifier = 1 + ((DefenseAdvantage - OffenseAdvantage)/2)

			Offense= OffenseModifier * (Offender.GetOff(glob.ACC_OFF)+Offender.GetSpd(glob.ACC_OFF_SPD))
			Defense= DefenseModifier * (Defender.GetDef(glob.ACC_DEF)+Defender.GetSpd(glob.ACC_DEF_SPD)) * glob.EXTRA_DEF_MOD
			TotalAccuracy = (BaseChance/100) * ((Offense*AccMult) / Defense) * 100
			if(glob.DEBUG_MESSAGES_ACCURACY)
				Offender << "--------------------"
				Offender << "Offense: [Offense]"
				Offender << "Defense: [Defense]"
				Offender << "Chance: [BaseChance]"
				Offender << "Accuracy: [TotalAccuracy]"
				Offender << "Accuracy Modifier: [AccMult]"
				Offender << "Defense Mod: [DefenseModifier]"
				Offender << "Offense Mod: [OffenseModifier]"
				Offender << "--------------------"

			TotalAccuracy = clamp(TotalAccuracy, glob.LOWEST_ACC, 100)
			if(TotalAccuracy <= glob.LOWEST_ACC)
				Offender.minhitroll++
			if(!prob(TotalAccuracy))
				if(!prob(TotalAccuracy))
					return MISS
				else
					return WHIFF
			else
				return HIT
	else
		return MISS

proc/Deflection_Formula(var/mob/Offender,var/mob/Defender,var/AccMult=1,var/BaseChance=glob.WorldDefaultAcc, var/Backfire=0)
	if(Offender&&Defender)
		if(Defender.Frozen==3)
			return MISS
		if(Offender.HasNoMiss())
			return HIT
		if(Defender.SureDodge)
			Defender.SureDodge=0
			if(Offender.SureHit)
				return HIT
			else
				return MISS
		if(Offender.SureHit)
			Offender.SureHit=0
			return HIT
		if(Defender.Stunned || Defender.Launched || Defender.PoweringUp)
			return HIT

		if(Backfire&&Offender==Defender)
			AccMult*=0.8
		if(getBackSide(Offender, Defender))
			AccMult*=1.2
		if(Defender.Beaming || Defender.BusterTech)
			AccMult*=1.15
		if(Defender.HasRefractivePlating()||Defender.HasPlatedWeights())
			AccMult/=1.15
		if(Offender.SenseRobbed>=4&&(Offender.SenseUnlocked<=Offender.SenseRobbed&&Offender.SenseUnlocked>5))
			AccMult*=(1-(Offender.SenseRobbed*0.1))
		if(Defender.SenseRobbed>=4&&(Defender.SenseUnlocked<=Defender.SenseRobbed&&Defender.SenseUnlocked>5))
			AccMult/=(1-(Defender.SenseRobbed*0.1))
		// if(Defender.Adrenaline)
		// 	var/CombatSlow=10/max(Defender.Health,1)
		// 	if(CombatSlow>1)
		// 		AccMult/=1+(0.05*CombatSlow)
		if(Offender.HasClarity()||Offender.HasFluidForm()||Offender.HasIntuition())
			if(AccMult<1)
				AccMult+=0.2*AccMult
				if(AccMult>1)
					AccMult=1
		if(Defender.HasClarity()||Defender.HasFluidForm()||Defender.HasIntuition())
			var/cumAvoidance = (Defender.HasClarity()/4) + (Defender.HasIntuition() / 4) + Defender.HasFluidForm()
			if(AccMult>1)
				AccMult-=(0.2*AccMult) * cumAvoidance
				if(AccMult<1)
					AccMult=1


		var/GodKiDif = 1
		if(Offender.GetGodKi())
			GodKiDif = 1 + Offender.GetGodKi()
		if(Defender.GetGodKi())
			GodKiDif /= (1 + Defender.GetGodKi())
		AccMult *= GodKiDif

		var/OffenseModifier
		var/DefenseModifier
		var/OffenseAdvantage = Offender.Power / Defender.Power
		var/DefenseAdvantage = Defender.Power / Offender.Power
		if(glob.CLAMP_POWER)
			if(!Offender.ignoresPowerClamp())
				OffenseAdvantage = clamp(OffenseAdvantage,glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
			if(!Defender.ignoresPowerClamp())
				DefenseAdvantage = clamp(DefenseAdvantage,glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
		if(1 + ((OffenseAdvantage - DefenseAdvantage)/2) < 1)
			OffenseModifier = 1
		else
			OffenseModifier = 1 + ((OffenseAdvantage - DefenseAdvantage)/2)

		if(1 + ((DefenseAdvantage - OffenseAdvantage)/2) < 1)
			DefenseModifier = 1
		else
			DefenseModifier = 1 + ((DefenseAdvantage - OffenseAdvantage)/2)

		var/Offense= OffenseModifier * (Offender.GetOff(glob.ACC_OFF)+Offender.GetSpd(glob.ACC_OFF_SPD))
		var/Defense= DefenseModifier * (Defender.GetDef(glob.ACC_DEF)+Defender.GetSpd(glob.ACC_DEF_SPD))
		var/TotalAccuracy = BaseChance * ((Offense*AccMult) / Defense) * 100

		TotalAccuracy = clamp(glob.LOWEST_ACC, TotalAccuracy, 100)
		if(Defender.passive_handler.Get("TotalDeflection"))
			return MISS

		if(!prob(TotalAccuracy))
			if(!prob(TotalAccuracy))
				return MISS
			else
				return WHIFF
		else
			return HIT
	else
		return MISS

mob/var/tmp/last_combo
var/static/list/opposite_dirs = list(SOUTH,NORTH,NORTH|SOUTH,WEST,SOUTHWEST,NORTHWEST,NORTH|SOUTH|WEST,EAST,SOUTHEAST,NORTHEAST,NORTH|SOUTH|EAST,WEST|EAST,WEST|EAST|NORTH,WEST|EAST|SOUTH,WEST|EAST|NORTH|SOUTH)

mob/proc/Comboz(mob/M, LightAttack=0, ignoreTiledistance = FALSE, landBehind = FALSE)
	if(last_combo >= world.time) return
	last_combo = world.time
	var/list/dirs = list(NORTH,SOUTH,EAST,WEST,NORTHWEST,SOUTHWEST,NORTHEAST,SOUTHEAST)
	var/limit = 15
	if(ignoreTiledistance)
		limit  = 100
	if(M in view(limit, src))
		var/turf/W
		if(M.z!=src.z)
			return //lol you can't combo through dimensions anymore.  sad.
		if(20 < get_dist(src, M) && !ignoreTiledistance)
			return


		while(dirs.len)
			var/direction = pick(dirs)
			dirs-=direction

			W=get_step(M, direction)
			if(landBehind)
				W=get_step(M, opposite_dirs[M.dir])
			if(W)
				if(istype(W,/turf/Special/Blank))
					return
				if(!W.density)
					for(var/atom/x in W)
						if(x.density)
							return
					src.loc=W
					src.dir=ReturnDirection(src,M)
					if(!LightAttack && get_dist(src,M)>1)
						if(src.AttackQueue && src.AttackQueue.Rapid)
							FlashImage(src)
						else
							VanishImage(src)
					if(M.Beaming!=2)
						M.dir=ReturnDirection(M,src)
					break

mob/proc/SpeedDelay(var/Modifier=1)
	var/Spd=src.GetSpd()**glob.ATTACK_DELAY_EXPONENT
	var/Delay=glob.ATTACK_DELAY_DIVISOR/Spd
	if(passive_handler["Speed Force"])
		Delay = glob.ATTACK_DELAY_DIVISOR/(GetSpd()**2)
	if(Delay>=glob.ATTACK_DELAY_MAX)
		Delay=glob.ATTACK_DELAY_MAX
	if(src.HasBlastShielding())
		Delay*=1.5
	if(passive_handler["Speed Force"])
		return max(Delay,0.33)
	return max(Delay,glob.ATTACK_DELAY_MIN)


mob/proc/Knockback(var/Distance,var/mob/P,var/Direction=0, var/Forced=0, var/Ki=0, var/override_speed = 0, trueForced = 0)
	if(src)
		if(istype(src,/mob/Player/Afterimage))
			return
	if(src.loc == null)
		return
	if(!P) return
	if(P.Stasis)
		return
	if(!Direction)
		Direction=src.dir
	Forced+=isForced()
	if(P.ContinuousAttacking)
		for(var/obj/Skills/Projectile/p in P.contents)
			if(p.ContinuousOn && !p.StormFall)
				P.UseProjectile(p)
			continue
	Distance*=(gatherKBMods())
	Distance*=getKnockbackMultiplier(P) // gets the knockback multiplier(reduction) for the target
	if(!Forced)
		var/chance2Stop = prob(50*(P.HasMythical()))
		if(P.is_dashing || chance2Stop)
			return
		Distance /= 1 + ((/*P.passive_handler.Get("Juggernaut") + P.HasMythical()*/ P.is_dashing) * 0.5)
	else
		if((Forced) && (P.is_dashing))
			Distance *= Forced/(1 + max(P.is_dashing,1) * 0.5)
	if(Distance>glob.MAX_KB_TIME)
		Distance=glob.MAX_KB_TIME
	if(Distance<=0.5)
		return
	if(Distance>=0.5&&Distance<1)
		Distance=1

	if(P.Knockbacked)
		var/orgDistance = Distance
		P.Knockbacked=Direction
		Distance -= (P.previousKnockBack * glob.KB_SPEED)
		P.Knockback+=Distance
		if(Forced>=3)
			P.Knockback = (orgDistance) * world.tick_lag
	else
		P.BeginKB(Direction, Distance, Ki, override_speed = override_speed * world.tick_lag)
		P.previousKnockBack = Distance

mob
	proc/BeginKB(var/Direction, var/Distance, var/Ki, override_speed)
		src.icon_state="KB"
		src.Knockbacked=Direction
		src.Knockback=Distance*world.tick_lag
		spawn()
			while(src.Knockback)
				src.ContinueKB(Ki)
				sleep(override_speed ? override_speed : (world.tick_lag*2.5))
			src.StopKB(Ki)
	proc/GetKBDir(var/DustBlock=0)
		spawn()
			var/dense=0
			for(var/atom/a in get_step(src, src.Knockbacked))
				if(a.density)
					if(istype(a, /obj/Items/Tech/Door))
						PlanetEnterBump(a, src)
						continue
					dense=1
					break
			if(dense)
				src.StopKB(DustBlock)
	proc/ContinueKB(var/DustBlock=0)
		set waitfor=0
		src.icon_state="KB"
		src.GetKBDir(DustBlock)
		if(src.KBFreeze())
			src.StopKB(DustBlock)
			return
		var/turf/NextTurf=get_step(src, src.Knockbacked)
		if(!NextTurf)//if you're trying to fly off the map or into blankspace
			src.StopKB(DustBlock)
			return
		step(src, src.Knockbacked)
		src.Knockback--
		if(!DustBlock)
			if(prob(5))
				Dust(src.loc)
				if(prob(5))
					Dust(src.loc)
		if(src.Knockback<0)
			src.Knockback=0
	proc/StopKB(var/DustBlock=0)
		if(!src.KO)
			src.icon_state=""
		else
			src.icon_state="KO"
		src.Knockbacked=null
		src.Knockback=null
		if(src.Dunked)
			spawn()
				Crater(src,round(1+Dunked))
			src.Dunked=0
		else if(prob(20)&&src.pixel_z==0&&!DustBlock)
			Dust(src.loc)
			Dust(src.loc)

/var/tmp/lastGrabUsage=0


mob/proc/Grab()
	if(src.Stunned||src.icon_state=="KB")
		return
	if(!Grab)
		if(lastZanzoUsage+3 > world.time)
			return
		if(src.Target&&src.Target!=src&&ismob(src.Target))
			var/extraTiles = 0
			extraTiles += passive_handler.Get("Scoop")
			if(Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Grab"))
				return
			if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Grab"))
				extraTiles += secretDatum?:getBoon(src, "Grab")
			src.DashTo(src.Target, 2 + passive_handler.Get("Scoop"))
			if(src.Target in oview(1, src))
				src.Grab_Mob(src.Target)
			for(var/obj/Skills/Grab/g in src)
				g.Cooldown(2)
		else
			var/list/Choices=new
			for(var/atom/O in get_step(src,dir))
				if((isobj(O)||ismob(O))&&O.Grabbable&&O.mouse_opacity)
					Choices+=O
				if(!ismob(O))
					var/obj/Seal/s = (locate(/obj/Seal) in O.contents)
					if(s && (s.Creator != src.ckey))
						Choices-=O
			var/mob/P=input(src,"Grab what?") in Choices
			if(!(locate(P) in get_step(src,dir)))
				return
			else if(istype(P,/obj/Items))
				var/obj/Items/buh=P
				if(istype(buh, /obj/Items/mineral))
					var/obj/Items/mineral/min = P
					for(var/obj/Items/mineral/m in src)
						m.value += min.value
						m.name = "[Commas(round(m.value))] Mana Bits"
						src.OMessage(10,"[src] picks up [min].","[src]([src.key]) picks up ([min.value])[ExtractInfo(P)] made by [m.owner].")
						del(buh)
						return
				if(buh.Pickable==1)
					src.OMessage(10,"[src] picks up [P].","[src]([src.key]) picks up [ExtractInfo(P)] made by [buh.CreatorKey].")
					if(buh.Stackable)
						var/found=0
						for(var/obj/Items/i in usr)
							if(i.type == P.type)
								i.TotalStack+=buh.TotalStack
								i.suffix="[Commas(i.TotalStack)]"
								del(P)
								return
						if(!found)
							buh.suffix="[Commas(buh:TotalStack)]"
					P.Move(src)
					if(istype(P, /obj/Items/Enchantment/PhilosopherStone/Magicite))
						var/obj/Items/Enchantment/PhilosopherStone/Magicite/Prime
						for(var/obj/Items/Enchantment/PhilosopherStone/Magicite/m2 in src)
							if(!Prime)
								Prime=m2
								continue
							else
								Prime.MaxCapacity+=m2.MaxCapacity
								Prime.CurrentCapacity+=m2.CurrentCapacity
								src << "Your magicite collects into a single cluster."
								del m2
								Prime.Update_Description()
					if(P.suffix=="*Equipped*")
						P.suffix=null
					return
				else
					src.Grab=P
					src.OMessage(10,"[src] grabbed [P]!","[src]([src.key]) grabs [ExtractInfo(P)]")
					src.Grab_Update()
			else if(istype(P,/obj/Money))
				var/obj/Money/buh=P
				src.GiveMoney(P.Level)
				src.OMessage(10,"[src] picks up [P].","[src]([src.key]) picks up ([P.Level])[ExtractInfo(P)] made by [buh.MoneyCreator].")
				del(P)
				return
			else if(ismob(P))
				if(!P.IsGrabbed())
					src.Grab_Mob(P)
			else
				if(istype(P, /obj/Exchange/npc)) return
				src.Grab=P
				src.OMessage(10,"[src] grabbed [P]!","[src]([src.key]) grabs [ExtractInfo(P)]")
				src.Grab_Update()

	else
		src.Grab_Release()

mob/proc/Grab_Mob(var/mob/P, var/Forced=0)
	if(istype(P, /mob/irlNPC))
		return
	if(P.Frozen==2)
		return
	if(isai(P))
		var/mob/Player/AI/aa = P
		if(!istype(src, /mob/Player/AI))
			if(aa.ai_hostility >= 1)
				if(aa.inloop == FALSE && !(aa in ticking_ai))
					ticking_ai.Add(aa)
				aa.SetTarget(src)
				aa.ai_state = "Chase"
				aa.last_activity = world.time
	if(Secret == "Vampire")
		Forced = 1
	if(passive_handler.Get("Iron Grip"))
		Forced = 1
	if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Grab"))
		Forced = 1
	if(!Forced)
		if(istype(P, /mob/Body))
			src.Grab=P
			P.grabbed = src
			src.GrabTime = world.time
			src.OMessage(10,"[src] grabbed [P]!","[src]([src.key]) grabs [ExtractInfo(P)]")
			src.Grab_Update()
			src.Grab_Effects(P)
			return
		if((P.passive_handler.Get("Fishman")||P.HasGiantForm()||P.HasMythical()>=1)&&!P.KO&&P.icon_state!="Meditate")
			src.OMessage(10,"[src] fails to get a firm hold on [P]!","[src]([src.key]) fails to grab [ExtractInfo(P)]")
			return
	src.Grab=P
	P.grabbed = src
	src.GrabTime = world.time
	src.OMessage(10,"[src] grabbed [P]!","[src]([src.key]) grabs [ExtractInfo(P)]")
	src.Grab_Update()
	src.Grab_Effects(P)



/mob/var/tmp/mob/Player/grabbed = null
mob/proc/Grab_Release()
	src.Grab.grabbed = null
	sleep(1)
	
	src.Grab=null







mob/proc/Grab_Update()
	if(src.Grab)
		Grab.grabbed = src
		src.Grab.loc=src.loc
		if(isai(Grab)&&!Grab.KO)
			var/grabbing = Grab
			spawn(60)
				if(grabbing==Grab)
					src.Grab_Release()
		if(ismob(Grab))
			if(src.Grab.Grab)
				src.Grab.Grab.loc=Grab.loc
			if(src.Grab.Knockbacked||src.Knockbacked)
				src.Grab_Release()
		if(src.KO)
			src.Grab_Release()

mob/proc/Grab_Effects(var/mob/P)
	if(src.HasRipple())
		if(src.Oxygen > src.OxygenMax*0.9)
			src.OMessage(10,"[src] channels the Ripple into [P]...","[src]([src.key]) tests [ExtractInfo(P)]")
			src.Oxygen-=0.1*src.OxygenMax
			if(P.IsEvil())
				src.OMessage(10,"[P] shudders from sudden pain!")
			else
				if(P.MortallyWounded)
					P.MortallyWounded=0
					P.TsukiyomiTime=1
				if(P.SenseRobbed)
					if(P.SenseRobbed>=5)
						animate(P.client, color=null, time=3)
					P.SenseRobbed=0
				if(P.KO)
					P.Conscious()
	if(src.Lethal>=1)
		if(src.Secret=="Vampire")
			if(P.KO&&istype(P, /mob/Players))
				if(istype(P, /mob/Player/AI))
					src << "[P] is an AI!"
					return
				//TODO VAMPIRE LETHAL				
				var/Choice=alert(src, "Do you wish to convert [P] to a vampire?", "Vampire Grab", "Yes", "No")
				if(P in range(1, src))
					if(Choice=="Yes")
						src.Grab=null
						src.TotalInjury/=4
						src.TotalFatigue/=4
						src.HealHealth(src.secretDatum.currentTier * 3)
						src.HealEnergy(src.secretDatum.currentTier * 3)
						if(!P.Secret)
							var/likelihood = secretDatum.currentTier * 10
							if(prob(likelihood))
								P.Secret="Vampire"
								P.giveSecret("Vampire")
							else
								P.Death(src, "[src] sucking out their life essence!!")

						else
							P.Death(src, "[src] sucking out their life essence!!")




		if((src.Secret=="Werewolf"&&(src.CheckSlotless("New Moon Form")||src.CheckSlotless("Full Moon Form"))))
			if(P.KO&&istype(P, /mob/Players))
				if(istype(P, /mob/Player/AI))
					src << "[P] is an AI!"
					return
				var/Choice=alert(src, "Do you wish to devour [P]?", "Feast", "No", "Yes")
				if(P in range(1, src))
					if(Choice=="Yes")
						src.Grab=null
						if(src.Secret=="Werewolf")
							P.Death(null, "[src] ripping them apart!!", 1, NoRemains=1)
							src.TotalInjury=0
							src.HealHealth(50)