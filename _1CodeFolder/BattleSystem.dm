/var/BASE_DELAY = 3 //base delay for all attacks
#define MISS 0 // WHEN YOU B MISSIN
#define HIT 1 // WHEN YOU B HITTIN
#define WHIFF 2 // WHEN YOU HIT ON THE 2ND ROLL
#define STATIC_RPP_GAIN 999



/mob/Admin3/verb/Clamp_Power()
	set name = "Enable Power Clamp"
	if(!src.Alert("Are you sure you want to toggle power clamp?")) return
	glob.CLAMP_POWER = !glob.CLAMP_POWER
	src << "Power clamp is now [glob.CLAMP_POWER ? "enabled" : "disabled"]."


mob/var/LastAnger
mob/proc/SetNoAnger(var/obj/Skills/Buffs/b, var/Value=0)
	b.NoAnger=Value
	if(b.NoAnger)
		OMsg(src, "<font color='grey'>[src]'s anger ebbs away...</font color>")
	else
		OMsg(src, "<font color='red'>[src]'s anger flares back to life!</font color>")

//anger is a curve now, not a switch. tiers of list(hp, frac-of-usable-anger, msg or null).
//AngerPoint slides the whole thing, AngerFloor on buffs/forms squeezes it so peak lands at higher hp,
//AngerRush is event fuel that evaluates you as if you were lower. tiers only ratchet up; Calm() resets.
var/list/ANGER_CURVE_DEFAULT = list(list(75, 0.25, "is starting to get worked up..."), list(50, 0.5, null), list(25, 1, "flies into a rage!"))

mob/proc/GetAngerCurve()
	if(race&&race.anger_curve) return race.anger_curve
	return ANGER_CURVE_DEFAULT

mob/proc/GetAngeredIndex()
	var/list/curve=GetAngerCurve()
	return min(race ? race.anger_curve_angered : 2, curve.len)

mob/proc/GetAngerFloor(var/obj/Skills/Buffs/exclude)
	//exclude = a buff mid-removal whose slot pointer hasn't been cleared yet
	var/F=0
	if(ActiveBuff&&ActiveBuff!=exclude&&ActiveBuff.AngerFloor>F) F=ActiveBuff.AngerFloor
	if(SpecialBuff&&SpecialBuff!=exclude&&SpecialBuff.AngerFloor>F) F=SpecialBuff.AngerFloor
	if(StyleBuff&&StyleBuff!=exclude&&StyleBuff.AngerFloor>F) F=StyleBuff.AngerFloor
	for(var/sb in SlotlessBuffs)
		var/obj/Skills/Buffs/B=SlotlessBuffs[sb]
		if(B&&B!=exclude&&B.AngerFloor>F) F=B.AngerFloor
	if(race&&transActive&&transActive<=race.transformations.len)
		var/transformation/T=race.transformations[transActive]
		if(T&&T.angerFloor>F) F=T.angerFloor
	return min(F,99)

mob/proc/AngerTierList(var/obj/Skills/Buffs/exclude)
	var/list/curve=GetAngerCurve()
	var/slide=AngerPoint-50
	var/list/last=curve[curve.len]
	var/peak=last[1]+slide
	var/F=GetAngerFloor(exclude)
	var/list/out=list()
	for(var/list/tier in curve)
		var/t=tier[1]+slide
		if(F>0&&F>peak&&peak<100)
			t=100-(100-t)*(100-F)/(100-peak)
		out+=min(t,99.9)
	return out

mob/proc/AngerFracAt(var/hp)
	var/list/curve=GetAngerCurve()
	var/list/T=AngerTierList()
	var/n=curve.len
	if(hp>T[1]) return 0
	var/list/last=curve[n]
	if(hp<=T[n])
		var/f=last[2]
		//EndlessAnger = no peak. keep climbing past the last tier, Calm() is the only way down
		if(passive_handler.Get("EndlessAnger"))
			f+=(T[n]-hp)*glob.ANGER_ENDLESS_RATE
		return f
	for(var/i=2, i<=n, i++)
		if(hp>T[i])
			var/list/hi=curve[i-1]
			var/list/lo=curve[i]
			var/span=T[i-1]-T[i]
			if(span<=0) return lo[2]
			return hi[2]+(lo[2]-hi[2])*(T[i-1]-hp)/span
	return last[2]

mob/proc/AngerEvalHP(var/incoming=0)
	return ((HealthPct()-incoming)/max(1-HealthCut,0.01))-AngerRush

mob/proc/AngerCurveValue()
	//the live multiplier the power calcs read. 1 = nothing going on
	if(AngerMax<1) return 1
	if(HasCalmAnger())
		var/list/curve=GetAngerCurve()
		var/list/T=AngerTierList()
		var/n=curve.len
		var/list/last=curve[n]
		var/eval=AngerEvalHP()
		var/f=0
		if(eval<=T[n])
			f=last[2]
			if(passive_handler.Get("EndlessAnger"))
				f+=(T[n]-eval)*glob.ANGER_ENDLESS_RATE
		else if(eval<100&&T[n]<100)
			f=last[2]*(100-eval)/(100-T[n])
		if(f>AngerCalmHigh)
			AngerCalmHigh=f
		else
			f=AngerCalmHigh
		if(f<=0) return 1
		var/am=AngerMax
		if(AnsatsukenAscension=="Chikara"&&StyleActive=="Ansatsuken")
			am=max(am,2)
		var/cv=1+(am-1)*f
		if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Anger"))
			cv *= 1+(secretDatum?:getBoon(src, "Anger")/10)
		return cv
	if(HasNoAnger()||AngerCD) return 1
	var/frac=AngerFracAt(AngerEvalHP())
	if(AngerTier)
		var/list/curve=GetAngerCurve()
		var/list/reached=curve[min(AngerTier,curve.len)]
		if(reached[2]>frac) frac=reached[2]
	if(frac<=0) return 1
	var/v=1+(AngerMax-1)*frac
	if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Anger"))
		v *= 1+(secretDatum?:getBoon(src, "Anger")/10)
	return v

mob/proc/AngerAdvance(var/incoming=0)
	if(HasCalmAnger()||HasNoAnger()||AngerCD) return 0
	var/list/curve=GetAngerCurve()
	var/list/T=AngerTierList()
	var/eval=AngerEvalHP(incoming)
	var/newtier=0
	for(var/i=1, i<=curve.len, i++)
		if(eval<=T[i]) newtier=i
	if(newtier<=AngerTier) return 0
	var/ang=GetAngeredIndex()
	var/fired=0
	while(AngerTier<newtier)
		var/i=AngerTier+1
		AngerTier=i
		if(i==ang)
			if(!Anger)
				src.Anger()
				fired=1
		else
			AngerTierMessage(i)
	return fired

mob/proc/UpdateAnger()
	AngerAdvance(0)

mob/proc/AngerTierMessage(var/i)
	var/list/curve=GetAngerCurve()
	if(i>curve.len) return
	var/list/tier=curve[i]
	if(tier.len<3||!tier[3]) return
	if(!AngerColor)
		OMsg(src, "<font color='red'>[src] [tier[3]]</font color>")
	else
		OMsg(src, "<font color='[AngerColor]'>[src] [tier[3]]</font color>")

mob/proc/AngerEvent(var/points)
	if(points<=0) return
	if(HasCalmAnger()||HasNoAnger()||AngerCD) return
	AngerRush=min(AngerRush+points, glob.ANGER_RUSH_CAP)
	AngerAdvance(0)

mob/proc/AngerCCEvent()
	//chain cc pisses you off. first one's free, repeats inside the window stoke you
	if(world.time<AngerCCWindow)
		AngerEvent(glob.ANGER_RUSH_CC)
	AngerCCWindow=world.time+glob.ANGER_CC_WINDOW

mob/proc/ForceAngered(var/Enraged=0)
	//instant angry for enrage debuffs and weird food. banks rush so the state survives reclamps
	if(HasCalmAnger()||HasNoAnger()||AngerCD) return
	var/ang=GetAngeredIndex()
	var/list/T=AngerTierList()
	var/need=AngerEvalHP()-T[ang]
	if(need>0)
		AngerRush=min(AngerRush+need, glob.ANGER_RUSH_CAP)
	if(AngerTier<ang)
		AngerTier=ang
	if(!Anger)
		src.Anger(Enraged)

mob/proc/AngerReclamp(var/obj/Skills/Buffs/gone)
	if(!AngerTier) return
	var/list/curve=GetAngerCurve()
	var/list/T=AngerTierList(gone)
	var/eval=AngerEvalHP()
	var/newtier=0
	for(var/i=1, i<=curve.len, i++)
		if(eval<=T[i]) newtier=i
	if(newtier>=AngerTier) return
	AngerTier=newtier
	if(AngerTier<GetAngeredIndex()&&Anger)
		Anger=0
		DefianceCounter=0
		race.onCalm(src)
		AngerCD=5
		if(src.oozaru_type=="Demonic")
			AngerCD=0

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
						src.ActiveBuff.Trigger(src,Override=1)
				for(var/sb in src.SlotlessBuffs)
					var/obj/Skills/Buffs/SB = src.SlotlessBuffs[sb]
					if(SB)
						if(SB.SpecialBuffLock)
							SB.Trigger(src,Override=1)
				if(src.SpecialBuff)
					if(src.SpecialBuff.BuffName=="Jinchuuriki")
						return
					else
						src.SpecialBuff.Trigger(src,Override=1)
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
				for(var/sb in src.SlotlessBuffs)
					var/obj/Skills/Buffs/SB = src.SlotlessBuffs[sb]
					if(SB)
						if(SB.SpecialBuffLock)
							SB.Trigger(src,Override=1)
				if(src.SpecialBuff)
					if(src.SpecialBuff.BuffName=="Vaizard Mask")
						return
					else
						src.SpecialBuff.Trigger(src,Override=1)
						V.Trigger(src)
						return
				else
					V.Trigger(src)
					return

		if(CheckActive("Kamui Senketsu") && !CheckSlotless("Life Fiber Berserker") && (!Saga || Saga != "Kamui" || SagaLevel > 1 && SagaLevel < 4))
			if(Saga == "Kamui" && prob(50 - SagaLevel * 5))
				UseBuff(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Life_Fiber_Berserker)
			else if(!Saga || Saga != "Kamui")
				UseBuff(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Life_Fiber_Berserker)

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
mob/proc/Unconscious(mob/P,var/text)
	if(src.KO)
		return
	if(P)
		var/obj/Skills/Buffs/undying = FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Undying_Rage)
		if(undying && !undying.Using)
			SetHealthPct(0.1)
			undying.Trigger(src ,TRUE)
			return
		if(src.passive_handler.Get("Color of Courage")&& src.HealthPct()>glob.TRIPLEHELIX_MAX_NEG_HP) //The Character will refuse to get downed until they reach (global) negative hp! (the global must be a negative variable, like -50)
			if(!src.passive_handler.Get("Triple Helix"))
				src.passive_handler.Set("Triple Helix", 1) // triple helix is just a flavor passive that tells the game to only play the message once
				src.OMessage(15,"<font color=green><h2><big><b>... but just who the hell do you think they are?!</b></big></h2></font color>")
				src.OMessage(15,"<font color=green>[src] <b>starts fighting past the limits of even mortality!!!</b></font color>")
			return
		if(!istype(src,/mob/Player/FevaSplits))
			if(P.passive_handler["Undying Rage"])
				P.HealPct(2.5 + (glob.racials.UNDYINGRAGE_HEAL * P.AscensionsAcquired))
			src.OMessage(15,"[src] is knocked out by [P]!","<font color=red>[src]([src.key]) is knocked out by [P]([P.key])")
			if(FightingSeriously(P,0)||src.BPPoison<1||src.MortallyWounded)
				src.KOBrutal=1
			else
				src.KOBrutal=0
				OMsg(src, "...but it wasn't too rough, so they'll probably walk it off.")
	if(text)
		if(!istype(src,/mob/Player/FevaSplits))
			src.OMessage(15,"[src] is knocked out by [text]!","<font color=red>[src]([src.key]) is knocked out by [text]")
	if(src.party)
		for(var/mob/m in src.party.members)
			if(m==src||m.KO||m.z!=src.z||get_dist(m,src)>12) continue
			m.AngerEvent(glob.ANGER_RUSH_ALLY_DOWN)
			m << "<font color=red>Seeing [src] go down sets your blood boiling!</font>"
	if(src.passive_handler.Get("TrueZenkai"))
		src.passive_handler.Set("TrueZenkaiPower", 0)
	var/HellspawnOdds=(10+(src.TotalInjury-40))/(src.Potential/20)//less likely the further you are from 20 pot without outright disabling it before then
	var/CalamityOdds=src.passive_handler.Get("The Clock Is Ticking")*(src.Potential/55)
	if(CalamityOdds<0)
		CalamityOdds=0
	if(src.Potential<50)
		CalamityOdds=0
	if((src.oozaru_type=="Demonic" && src.TotalInjury>=40&&prob(HellspawnOdds)&&src.transUnlocked<1&&!src.HellspawnBerserk&&!src.HellspawnBerserking)||(src.ForcedHellspawn&&!src.HellspawnBerserk&&!src.HellspawnBerserking))
		src.RPModeSwitch()
		src.Energy=src.EnergyMax
		src.HellspawnTimer=360
		src.ForcedHellspawn=0
		src.KO=0
		src.SetHealthPct(60)
		src.TotalInjury=40
		src.VaizardHealth+=30
		src.OMessage(15,"...you thought it was over? You thought you had hope?","<font color=red>[src]([src.key]) awakens.")
		src.HellspawnBerserking=1
		sleep(20)
		src.OMessage(15,"...you thought you were fighting something you could understand?","<font color=red>[src]([src.key]) presses further.")
		sleep(20)
		src.race.transformations[1].transform(src, TRUE)
		src.OMessage(15,"<b>HOW INTERESTING THAT YOU CONTINUE TO MISUNDERSTAND WHAT'S AT STAKE HERE.</b>","<font color=red>[src]([src.key]) heralds the end..")
		src.HellspawnBerserk=1
		src.SetHealthPct(30)
		return
	if((src.oozaru_type=="Demonic" && prob(CalamityOdds)&&src.transUnlocked==1&&!src.TheCalamity&&!src.CalamityCaused&&src.race.transformations[1].mastery==100)||(src.ForcedCalamity&&!src.CalamityCaused))
		src.Revert()
		world<<"<font color=red><b>The hearts of all those in creation beat as one. Their breath is stolen away from them. </b></font>"
		src.RPModeSwitch()
		sleep(30)
		world<<"<font color=red><b>There is no chance to question, no chance to wonder. To all those who live, the answer presents itself.</b></font>"
		src.TheCalamity=1
		src.CalamityCaused=1
		sleep(30)
		src.SetHealthPct(100)
		src.TotalInjury=0
		world<<"<font color=red><b>Here, on this one fateful day...</b></font>"
		src.race.transformations[1].transform(src, TRUE)
		sleep(30)
		world<<"<font color=red><b>...The Calamity...</b></font>"
		src.race.transformations[2].transform(src, TRUE)
		src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HellbornFury/Stage_Five)
		sleep(30)
		world<<"<font color=red><b>...begins anew.</b></font>"
		src.RPModeSwitch()
		return
	if(src.HellspawnBerserk||src.TheCalamity)
		src.HellspawnBerserk=0
		src.HellspawnTimer=0
		src.TheCalamity=0
		src.TotalInjury=85
	if(src.GatesActive==8 && src.Gate8Getups<2)
		src.KO=0
		src.OMessage(15,"...but [src]'s youth is burning too bright to be stopped!","<font color=red>[src]([src.key]) remains standing in their celebration of youth!")
		src.SetHealthPct(1)
		src.VaizardHealth+=30
		src.HealthAnnounce10++
		src.Gate8Getups++
		if(src.Gate8Getups>=2)
			if(src.CheckActive("Eight Gates"))
				var/obj/Skills/Buffs/ActiveBuffs/Eight_Gates/eg = src.ActiveBuff
				eg.Stop_Cultivation()//deactivate...
				GatesActive=0
		return
	var/RedTenacity=0
	if(src.RebirthHeroType=="Red" && src.SagaLevel>=2)
		RedTenacity+=1
	if(src.RebirthHeroType=="Red" && src.SagaLevel>=2)
		if(src.HealthAnnounce10<=1&&FightingSeriously(P,src))
			src.KO=0
			src.OMessage(15, "...but [src] refused, reloading a quicksave.", "<font color=red>[src]([src.key]) remains standing despite impossible odds!")
			src.SetHealthPct(15)
			src.VaizardHealth+=15
			src.HealthAnnounce10=2
			return
	if(src.passive_handler.Get("SecondWind") == "Unstoppable")
		if(src.UnstoppableForceCounter<9&&FightingSeriously(P,src))
			src.KO=0
			src.OMessage(15, "<b>But [src] is unwavering in their pursuit of victory.</b>", "<font color=red>[src]([src.key]) remains standing despite impossible odds!")
			src.SetHealthPct(10)
			src.HealthAnnounce10=10
			src.UnstoppableForceCounter+=1
			return
	if(src.passive_handler.Get("SecondWind") == "Hope")
		if(src.HealthAnnounce10<=1&&FightingSeriously(P,src))
			if(prob((src.passive_handler.Get("Tenacity")*glob.TENACITY_GETUP_CHANCE)+10))
				src.KO=0
				src.OMessage(15, "...but [src] refused.", "<font color=red>[src]([src.key]) remains standing despite impossible odds!")
				src.SetHealthPct(10)
				src.VaizardHealth+=20
				src.HealthAnnounce10+=1
				return
	if(src.passive_handler.Get("Tenacity"))
		if(src.HealthAnnounce10<=1+RedTenacity&&FightingSeriously(P,src))
			if(prob((src.passive_handler.Get("Tenacity")*glob.TENACITY_GETUP_CHANCE)+5))
				src.KO=0
				src.OMessage(15, "...but [src] refuses to go down!", "<font color=red>[src]([src.key]) remains standing despite impossible odds!")
				if(src.passive_handler.Get("Color of Courage"))
					src.HealPct(5)
				else
					src.SetHealthPct(5)
				src.VaizardHealth+=clamp(passive_handler.Get("Tenacity")* glob.TENACITY_VAI_MULT, glob.TENACITY_VAI_MIN, glob.TENACITY_VAI_MAX) //actual clutch now.
				src.HealthAnnounce10+=1
				return
	if(src.passive_handler.Get("SecondWind") == "Echo")
		if(src.HealthAnnounce10<=2+RedTenacity&&FightingSeriously(P,src))
			src.KO=0
			src.OMessage(15, "[src] saw a world in which they lost, and starts to push just a little bit harder!", "<font color=red>[src]([src.key]) activates The Echo!")
			src.SetHealthPct(10)
			src.VaizardHealth+=20
			src.HealthAnnounce10+=3
			return
	if(src.passive_handler.Get("Alter the Future")&&src.passive_handler.Get("The Almighty"))
		if(src.HealthAnnounce10<=4)
			if(prob(src.passive_handler.Get("Alter the Future")))
				src.KO=0
				src.OMessage(15, "...but [src] rewrites the future to prevent their defeat!", "<font color=red>[src]([src.key]) rewrites the future!")
				src.SetHealthPct(10)
				src.passive_handler.Decrease("Alter the Future", 25)
				src.VaizardHealth+=20
				src.HealthAnnounce10+=1
				return
	if(src.passive_handler.Get("SecondWind") == "Comeback")
		if(src.HealthAnnounce10<=9)
			if(prob(1))
				var/HealthRecovery=P.HealthPct()/2
				src.KO=0
				src.OMessage(15, "[src] reloads their last SAVE!", "<font color=red>[src]([src.key]) stages a miraculous comeback!!")
				src.SetHealthPct(HealthRecovery)
				P.HealPct(HealthRecovery/2)
				src.HealthAnnounce10+=1
				return
	if(src.race in list(HUMAN, CELESTIAL) && !src.isMazokuPathHuman())
		if(src.transActive==1&&src.transUnlocked>=2)
			src.KO=0
			src.OMessage(15, "...<b>but [src] evolves one final time, pushing out every last bit of their potential!!!!</b>", "<font color=red>[src]([src.key]) activates Unlimited High Tension!!!")
			src.SetHealthPct(5)
			if(src.isRace(HUMAN))
				src.VaizardHealth+=(P.HealthPct()+P.VaizardHealth)/1.5
			if(src.isRace(CELESTIAL))
				src.VaizardHealth+=(P.HealthPct()+P.VaizardHealth)/2
			src.race.transformations[2].transform(src, TRUE)
			src.Tension=100
			return
		if(src.transActive==2&&src.transUnlocked>=3)
			src.KO=0
			src.OMessage(15, "...<b>but [src] evolves one final time, pushing out every last bit of their potential!!!!</b>", "<font color=red>[src]([src.key]) activates Unlimited High Tension!!!")
			src.SetHealthPct(5)
			if(src.isRace(HUMAN))
				src.VaizardHealth+=(P.HealthPct()+P.VaizardHealth)/1.5
			if(src.isRace(CELESTIAL))
				src.VaizardHealth+=(P.HealthPct()+P.VaizardHealth)/2
			src.race.transformations[3].transform(src, TRUE)
			src.Tension=100
			return
	if(src.passive_handler.Get("DoubleHelix")&&src.transActive==4&&src.transUnlocked>=5&&src.CelestialAscension=="Demon")
		src.KO=0
		src.OMessage(15, "...<b>but [src] evolves one final time, drawing out the full might of their demonic ancestor!</b>", "<font color=red>[src]([src.key]) activates Unlimited High Tension!!!")
		src.SetHealthPct(10)
		src.DoubleHelix=5
		if(src.isRace(CELESTIAL))
			src.VaizardHealth+=10;
		src.race.transformations[5].transform(src, TRUE)
		return
	if(passive_handler["Undying Rage"])
		SetHealthPct(0.1)
		return
	if(src.AwakeningSkillUsed)
		src.AwakeningSkillUsed=0
		src.passive_handler.Set("RedPUSpike", 0)
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
	src.Guarding=0
	src.GuardMeter=0
	src.ChargingEnergy=0
	src.Auraz("Remove")
	src.KOTimer=(300/(src.GetRecov())*glob.GetUpVar*GetUpOdds)
	src.DealWounds(src,src.PctToHP(20/max(src.GetRecov(2), 1)))
	src.KO=1
	src.icon_state="KO"
	src.SetHealthPct(1)
	src.Energy=1
	src.PowerControl=100
	src.ClearFrenzyOnKO()
	src.Burn=0
	src.Bleed=0
	src.AfterImageStrike=0
	src.ais_window_until=0
	src.VaizardHealth=0
	src.ForceCancelBeam()
	src.ForceCancelBuster()
	if(src.passive_handler.Get("Triple Helix"))
		src.passive_handler.Set("Triple Helix", 0)
	var/obj/Skills/Buffs/SlotlessBuffs/RoyalGuard/RG = locate(/obj/Skills/Buffs/SlotlessBuffs/RoyalGuard) in src.contents
	if(RG && RG.RoyalMeter > 0)
		RG.RoyalMeter = 0
		src << "Your Royal Meter went back to 0."
		src.client.updateRGMeter()

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
			var/inj = src.TotalInjury / (1 + src.GetVit(glob.VIT_INJURY_SOFTEN))
			if(inj>=35&&inj<60&&src.BPPoison>=0.9)
				var/Time=RawHours(1)
				Time/=src.GetRecov()
				if(Time > BPPoisonTimer)
					src.BPPoisonTimer=Time
				src.BPPoison=0.9
				src.OMessage(10, "[src] has been lightly wounded!", "[src]([src.key]) has over 35% injury.")
			if(inj>=60&&src.BPPoison>=0.7)
				var/Time=RawHours(3)
				Time/=src.GetRecov()
				if(Time > BPPoisonTimer)
					src.BPPoisonTimer=Time
				src.BPPoison=0.7
				src.OMessage(10, "[src] has been heavily wounded!", "[src]([src.key]) has over 50% injury.")
			if(inj>=85)
				var/Time=RawHours(4)
				Time/=src.GetRecov()
				if(Time > BPPoisonTimer)
					src.BPPoisonTimer=Time
				src.BPPoison=0.5
				src.MortallyWounded+=1
				src.OMessage(10, "[src] has been grieviously wounded!", "[src]([src.key]) has over 85% injury.")
	if(src.client)
		if((transActive||tension)&&!src.HasMystic())
			for(var/obj/Skills/Buffs/B in src)
				if(src.BuffOn(B)&&B.Transform&&!B.AlwaysOn)
					B.Trigger(src)
					break
			src.Revert()
			src<<"Being knocked out forced you to revert!"
		if(src.isRace(SAIYAN))
			src.Oozaru(0)
		var/obj/Skills/Buffs/SlotlessBuffs/Enma_Korogi/ek = src.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Enma_Korogi)
		if(ek && ek.SlotlessOn)
			ek.Trigger(src)
			src << "Being knocked out collapsed your bankai!"
	if(src.Grab)
		src.Grab_Release()
	Poison = 0
	Burn = 0
	Bleed = 0
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
			src.SetHealthPct(1)
			src.Energy=EnergyMax/100
		if(src.passive_handler.Get("Our Future"))
			src.KOBrutal=0
			src.SetHealthPct(100)
			src.Energy=src.EnergyMax
			src.TotalInjury/=2
			src.TotalFatigue/=2
			src.OMessage(15,"<font color='green'><b>[src] refuses to let fate get the better of them!!!</b></font color>","<font color=blue>[src]([src.key]) regains consciousness.")
		else if(src.passive_handler.Get("SecondWind") == "Hope")
			src.SetHealthPct(30)
			src.Energy=EnergyMax/2
			src.OMessage(15,"[src] is ready for another go.","<font color=blue>[src]([src.key]) regains consciousness.")
		else
			src.SetHealthPct(15)
			src.Energy=EnergyMax/5

		if(isplayer(src))
			src:move_speed = MovementSpeed()
		src.OMessage(15,"[src] regains consciousness.","<font color=blue>[src]([src.key]) regains consciousness")

mob/proc/Death(mob/P,var/text,var/SuperDead=0, var/NoRemains=0, extraChance, fakeDeath)
	if(majinCheatDeathInProgress) return
	// Majin once-per-ascension cheat death
	if(isRace(MAJIN) && !fakeDeath && !SuperDead && !NoVoid && !majinCheatDeathUsed)
		majinCheatDeathInProgress = 1
		majinCheatDeathUsed = 1
		src.OMessage(20,"[src] was just killed by [text]!","<font color=red>[src] was just killed by [text]!")
		sleep(20)
		src.OMessage(15,"<b><font color=[src.Text_Color]><font size=+1>...but [src] begins to rapidly regenerate!</b></font color></font size>","<font color=blue>[src]([src.key]) isn't dead yet.")
		src.MortallyWounded=0
		src.KOTimer=0
		src.KO=0
		src.icon_state=""
		src.HealWounds(99999)
		src.SetHealthPct(25)
		src.MaxEnergy()
		src.MaxMana()
		spawn() src.MajinCheatDeathReformFX()
		return
	if(isRace(MAJIN) && majinAbsorb && majinAbsorb.absorbed && majinAbsorb.absorbed.len)
		majinAbsorb.releaseAll(src, "majin_died")
//	BreakViewers() //STOP LOOKING AT ME THE SHAME OF DEATH TOO MUCH
	if(src.passive_handler.Get("The Legend of REBIRTH"))
		src.OMessage(20,"[src] was just killed by [text]!","<font color=red>[src] was just killed by [text]!")
		sleep(20)
		src.OMessage(15,"<b><font color=[src.Text_Color]><font size=+1>...but [src] refuses to allow their story to end here!</b></font color></font size>","<font color=blue>[src]([src.key]) denies death.")
		src.MortallyWounded=0
		src.TsukiyomiTime=1
		src.KOTimer=0
		src.KO=0
		src.SetHealthPct(100)
		src.Energy=src.EnergyMax
		return
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
	if(StarCrossed)
		StarCrossed = FALSE
	if(painShared)
		turnOffPainShared()


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
				var/potential_gain=(a.Potential/2)*glob.MOB_POTENTIAL_MODIFIER
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
			if(P.moneyGrindedDaily < glob.progress.DailyGrindCap * P.EconomyMult)
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

	if(text)
		src.OMessage(20,"[src] was just killed by [text]!","<font color=red>[src] was just killed by [text]!")
	if(P)
		// if(istype(s, /obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin))
		// 	s?:onKill(P, src)
		src.OMessage(20,"[src] was just killed by [P]!","<font color=red>[src] was just killed by [P]([P.key])!")
		if(P.HasPurity()&&IsEvil())
			SuperDead=2
			NoRemains=1
			if(P.Secret=="Hamon")
				src.OMessage(20,"[src] is completely destroyed by the Ripple running through their body!","<font color=red>[src] was purified [P]([P.key])!")
			else
				src.OMessage(20,"[src]'s existence is purged from the world!","<font color=red>[src] was purified [P]([P.key])!")

	// Hunting: fallen monsters leave carveable remains (potential sets the tier)
	if(istype(src, /mob/Player/AI) && !NoRemains && !fakeDeath)
		LifeSpawnRemains(src)

	// Reflected Eldritch Chrysalis — intercepts death if body remains
	if(src.hasSecret("Eldritch (Reflected)") && !src.ChrysalisActive && !NoRemains)
		src.enterChrysalis()
		return

	if(hasDeathEvolution())
		var/obj/Skills/Buffs/SlotlessBuffs/Death_Evolution/de = locate(/obj/Skills/Buffs/SlotlessBuffs/Death_Evolution, src);
		if(locate(/obj/Skills/Buffs/SlotlessBuffs/X_Evolution, src))
			var/obj/Skills/Buffs/SlotlessBuffs/A = src.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/X_Evolution)
			if(A.Using) A.Trigger(src,1)
		RPModeSwitch()
		sleep(30)
		world<<"<font color=red><b>When gathering souls become one, a new despair will bring about the Absolute End.</b></font>"
		sleep(30)
		world<<"<font color=red><b>[src] becomes the path its darkness advances upon.</b></font>"
		sleep(30)
		world<<"<font color=red><b>Shinka no Yami.</b></font>"
		HealAllCutTax();
		src.FullRestore();
		sleep(30)
		DeathEvolutionEffects();//Unused currently, but this would be just for visuals
		Conscious();
		world<<"<font color=red><b>Death-X-Evolution...</b></font>"
		de.Trigger(src)
		de.evolution_charges--;
		return;//no more dying
		//not for you anyway

	if(hasMazokuRevival())
		RPModeSwitch()
		sleep(30)
		MazokuEffects() //unused currently
		KenShockwave(src, icon='KenShockwavePurple.dmi', Size=1, Blend=2)
		src.Quake(20)
		world<<"<font color=red><b>As a descendant of a Great Demon Lord who has become powerful enough...</b></font>"
		sleep(30)
		KenShockwave(src, icon='KenShockwavePurple.dmi', Size=2, Blend=2)
		src.Quake(20)
		world<<"<font color=red><b>[src] has become a vessel for that Demon's soul.</b></font>"
		sleep(30)
		KenShockwave(src, icon='KenShockwavePurple.dmi', Size=3, Blend=2)
		src.Quake(20)
		world<<"<font color=red><b>Atavism of the Mazoku.</b></font>"
		HealAllCutTax()
		src.FullRestore()
		src.name=src.TrueName
		sleep(30)
		KenShockwave(src, icon='KenShockwavePurple.dmi', Size=5, Blend=2)
		src.Quake(20)
		src.passive_handler.Increase("DeathDefied", 1)
		if(src.race && src.race.transformations)
			//slot order matters: 1-5 HT chain, 6 DT, 7 SEA - mazokuActivateHighestHT counts on it
			src.race.transformations += new /transformation/human/high_tension/mazoku()
			src.race.transformations += new /transformation/human/high_tension_MAX/mazoku()
			src.race.transformations += new /transformation/human/super_high_tension/mazoku()
			src.race.transformations += new /transformation/human/super_high_tension_MAX/mazoku()
			src.race.transformations += new /transformation/human/unlimited_high_tension/mazoku()
			src.race.transformations += new /transformation/demon/devil_trigger/mazoku()
			if(src.AscensionsAcquired >= 6)
				src.race.transformations += new /transformation/human/sacred_energy_aura()
			if(src.transUnlocked < 3)
				src.transUnlocked = 3
		Conscious()
		world<<"<font color=red><b>[src] has awakened.</b></font>"
		return

	if(NoRemains!=2)
		if(src.BloodPower>=2)
			var/obj/Items/Sword/s=P.EquippedSword()
			var/obj/Items/Enchantment/Staff/st=P.EquippedStaff()
			if(s||st)
				if((s && s.Element=="Silver")||(st && st.Element=="Silver"))
					src.OMessage(20,"[src]'s existence is purged from the world!","<font color=red>[src] was purified [P]([P.key])!")
				else if(P.Secret=="Hamon"&&P.HasPurity())
					src.OMessage(20,"[src] is completely destroyed by the Ripple running through their body!","<font color=red>[src] was purified [P]([P.key])!")

		if(src.NoDeath)
			if(src.HealthCut<0.5&&!SuperDead)
				src.KO=1
				src.ClearFrenzyOnKO()
				src.Stasis=2000
				src.icon_state="KO"
				if(passive_handler.Get("VenomBlood"))
					src.overlays+=image('ArtificalObj.dmi',"Acid")
				else
					src.overlays+=image('ArtificalObj.dmi',"Blood")
				src << "Due to damage suffered you will be inert for a minute."
				src.Conscious()
				src.Stasis=0
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

	if(!src.client)
		NoRemains=1
		SuperDead=1

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

		src.loc=locate(glob.DEATH_LOCATION[1], glob.DEATH_LOCATION[2], glob.DEATH_LOCATION[3])
		if(src.isRace(DEMON, ELDRITCH)||src.Damned||(hasEldritchPower()))
			src.Damned=0
			src.loc=locate(198, 238, 8)
			return

	if(src.client)
		if(!(isRace(MAJIN) && (!majinCheatDeathUsed || majinCheatFXRunning || majinCheatDeathInProgress)))
			Void(SuperDead, fakeDeath, 0)

	if(!src.Dead)
		src.Conscious()
	else
		src.Dead=1
		src.Conscious()
		src.Poison=0
		src.SilentPoisonAmount=0
		src.Burn=0
		src.SilentBurnAmount=0
		src.Bleed=0
		src.Slow=0
		src.Shatter=0
		src.HardenAccumulated=0
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

/mob/proc/DeathEvolutionEffects()//Proc that doesn't do anything. but maybe someone wants to do visuals at some point

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
		return
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
	var/list/Types=list()
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
			Types=list()
	if(Amount % 250 != 0)
		F["Types"]<<Types
	var/cleanup_file = E + 1
	while(fexists("Saves/Bones/File[cleanup_file]"))
		fdel("Saves/Bones/File[cleanup_file]")
		world<<"<small>Server: Objects DEBUG system check: extra bones file deleted!"
		cleanup_file++

proc/Load_Bodies()
	var/amount=0
	var/filenum=0
	wowza
	filenum++
	if(fexists("Saves/Bones/File[filenum]"))
		var/savefile/F=new("Saves/Bones/File[filenum]")
		var/list/L=list()
		F["Types"]>>L
		for(var/mob/Body/A in L)
			amount+=1
			A.x = A.buildPreviousX
			A.y = A.buildPreviousY
			A.z = A.buildPreviousZ
			A.loc = locate(A.buildPreviousX, A.buildPreviousY, A.buildPreviousZ)
			world.log << "[A] found in [L] [A.loc], at [A.x], [A.y], [A.z] | [A.buildPreviousX], [A.buildPreviousY], [A.buildPreviousZ]"
		goto wowza

mob/proc/Leave_Body(var/SuperDead=0, var/ForceVoid=0)
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
	var/NotYet=0

	if(!SuperDead||NotYet)
		if(glob.VoidsAllowed||ForceVoid)
			var/Timer
			ActuallyDead=1
			if(ForceVoid)
				Timer=Minute(1)//this will always happen
				ActuallyDead=0
				A.TrulyDead=0
			if(prob(Chance)||NotYet)
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
							if(src.isRace(MAJIN))
								src.MajinCleanupOnDeletion()
							if(istype(src, /mob/Players))
								fdel("Saves/Players/[src.ckey]")
							src.loc=locate(0,0,0)
							return
						else
							src << "Your fate has been decided; you move on to the realm of the dead..."
							if(src.isRace(DEMON, ELDRITCH)||src.Damned||src.Secret=="Eldritch")
								src.Damned=0
								src.loc=locate(198, 238, 8)
								return
							src.loc=locate(glob.DEATH_LOCATION[1], glob.DEATH_LOCATION[2], glob.DEATH_LOCATION[3])

	else
		ActuallyDead=1
		if(src.NoSoul)
			src << "<font size='big'><b>You have been destroyed completely by some overwhelming force -- body and soul. Nothing remains.</b></font size>"
			src.Savable=0
			if(src.isRace(MAJIN))
				src.MajinCleanupOnDeletion()
			if(istype(src, /mob/Players))
				fdel("Saves/Players/[src.ckey]")
			src.loc=locate(0,0,0)
			return
		else
			src << "Your fate has been sealed by an overwhelming force; you move on immediately to the realm of the dead..."
			src.loc=locate(glob.DEATH_LOCATION[1], glob.DEATH_LOCATION[2], glob.DEATH_LOCATION[3])
	src.Burn=0
	src.SilentBurnAmount=0
	src.Bleed=0
	src.Poison=0
	src.SilentPoisonAmount=0
	src.Slow=0
	src.Shatter=0
	src.Shock=0
	src.Sheared=0
	src.Crippled=0
	src.Confused=0
	src.Stunned=0
	A.Body=Body
	if(1>=ForceVoid)
		A.SetHealthPct(1000)
	A.EnergyMax=src.EnergyMax
	A.Energy=src.Energy
	A.Power=src.Power
	A.StrMod=src.GetStr()
	A.EndMod=src.GetEnd()
	A.VitMod=src.GetVit()
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
	if(src.NoSoul && !ForceVoid)
		src << "<font size='big'><b>You have died on a plane with no Afterlife; there is nothing for you now. This is oblivion.</b></font size>"
		src.Savable=0
		if(src.isRace(MAJIN))
			src.MajinCleanupOnDeletion()
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
	var/_range = input(src, "Do you want to do a range?") in list(1,0)
	var/min_range
	var/max_range
	var/per_change
	if(_range)
		min_range = input(src, "min_range") as num
		max_range = input(src, "max_range") as num
		per_change = input(src, "per_change") as num
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
				Target.SetHealthPct(100)
				Target.Energy=Target.EnergyMax
				Target.Burn=0
				Target.SilentBurnAmount=0
				Target.Poison=0
				Target.SilentPoisonAmount=0
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
		StrReplace = 0
		Target.EndReplace = 0
	else
		for(var/attempts in 1 to looplength)
			var/result = Melee1(BreakAttackRate=1)
			damageMatrix["[result]"]++
			if(Target.KO)
				Target.Conscious()
			Target.SetHealthPct(100)
			Target.Energy=Target.EnergyMax
			Target.Burn=0
			Target.SilentBurnAmount=0
			Target.Poison=0
			Target.SilentPoisonAmount=0
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
		var/result = Accuracy_Formula(p1, Target, newaccmult, glob.WorldDefaultAcc, 0, 0)
		switch(result)
			if(HIT)
				hits++
			if(WHIFF)
				whiffs++
			if(MISS)
				misses++
	src <<"\nsimulated [p1] vs [Target]  [looplength] times at \nhits:[hits]([round((hits/looplength)*100)]%)\nwhiffs:[whiffs]([round((whiffs/looplength)*100)]%)\nmisses:[misses]([round((misses/looplength)*100)]%)\nmissed [((misses+whiffs)/looplength)*100]% of the time"
	src <<"simulating target vs src"
	hits = 0
	misses = 0
	whiffs = 0
	s = Target.EquippedSword()
	s2 = Target.EquippedSecondSword()
	if(!s2 && Target.UsingDualWield()) s2 = s
	s3 = Target.EquippedThirdSword()
	if(!s3 && Target.UsingTrinityStyle()) s3 = s
	st = Target.EquippedStaff()
	atkArmor = Target.EquippedArmor()
	swordAtk = FALSE
	if(s || s2 || s3)
		swordAtk = TRUE
	for(var/attempts in 1 to looplength)
		var/newaccmult = accmult
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
	src <<"\nsimulated [Target] vs [p1] [looplength] times at \nhits:[hits]([round((hits/looplength)*100)]%)\nwhiffs:[whiffs]([round((whiffs/looplength)*100)]%)\nmisses:[misses]([round((misses/looplength)*100)]%) missed [((misses+whiffs)/looplength)*100]% of the time"

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
	var/accmult = input(src, "What accmult do u want") as num
	var/enemyoff = input(src, "What off do u want enemy to have") as num
	Target.OffMod = enemyoff
	var/enemydef = input(src, "What def do u want enemy to have") as num
	Target.DefMod = enemydef
	var/enemyspd = input(src, "What spd do u want enemy to have") as num
	Target.SpdReplace = enemyspd
	var/looplength = input(src, "How many attempts") as num
	var/randomizeAccMult = input(src, "randomize acc mult between 1 and accmult?") in list(TRUE, FALSE)
	var/hits = 0
	var/misses = 0
	var/whiffs = 0
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
		var/result = Accuracy_Formula(src, Target, newaccmult, glob.WorldDefaultAcc, 0, 0)
		switch(result)
			if(HIT)
				hits++
			if(WHIFF)
				whiffs++
			if(MISS)
				misses++
	src <<"\nsimulated [looplength] times at \nhits:[hits]([round((hits/looplength)*100)]%)\nwhiffs:[whiffs]([round((whiffs/looplength)*100)]%)\nmisses:[misses]([round((misses/looplength)*100)]%)\nminhitsrolles:[minhitroll]\nmissed [((misses+whiffs)/looplength)*100]% of the time"
	src <<"simulating target vs src"
	hits = 0
	misses = 0
	whiffs = 0
	s = Target.EquippedSword()
	s2 = Target.EquippedSecondSword()
	if(!s2 && Target.UsingDualWield()) s2 = s
	s3 = Target.EquippedThirdSword()
	if(!s3 && Target.UsingTrinityStyle()) s3 = s
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
	src <<"\nsimulated [looplength] times at \nhits:[hits]([round((hits/looplength)*100)]%)\nwhiffs:[whiffs]([round((whiffs/looplength)*100)]%)\nmisses:[misses]([round((misses/looplength)*100)]%)\nminhitsrolled:[minhitroll]\nmissed [((misses+whiffs)/looplength)*100]% of the time"
	minhitroll = 0
	// var/list/itemMod = getItemDamage(list(s,s2,s3,st), delay, acc, SecondStrike, ThirdStrike, swordAtk)
	// delay = itemMod[1]
	// acc = itemMod[2]
// var/obj/Items/Armor/atkArmor = EquippedArmor()
// 				var/obj/Items/Armor/defArmor = enemy.EquippedArmor()

// 				if(atkArmor)
// 					acc *= GetArmorAccuracy(atkArmor)
// 					delay /= GetArmorDelay(atkArmor)
mob/var/tmp/last_combo
var/static/list/opposite_dirs = list(SOUTH,NORTH,NORTH|SOUTH,WEST,SOUTHWEST,NORTHWEST,NORTH|SOUTH|WEST,EAST,SOUTHEAST,NORTHEAST,NORTH|SOUTH|EAST,WEST|EAST,WEST|EAST|NORTH,WEST|EAST|SOUTH,WEST|EAST|NORTH|SOUTH)

mob/proc/ComboLandingClear(mob/M, direction)
	var/turf/W = get_step(M, direction)
	if(!W)
		return null
	if(istype(W,/turf/Special/Blank))
		return null //a Blank tile can't be landed on
	if(W.density)
		return null
	for(var/atom/x in W)
		if(x.density)
			return null //a dense atom (often the adjacent caster) blocks this tile
	if(PmActive())
		for(var/mob/m in range(1, W))
			if(m == src || m == M || !m.density) continue
			if(abs((m.x-W.x)*32 + m.step_x) < 32 && abs((m.y-W.y)*32 + m.step_y) < 32)
				return null
	return W

mob/proc/Comboz(mob/M, LightAttack=0, ignoreTiledistance = FALSE, landBehind = FALSE, landDir = 0, frontOnly = FALSE)
	if(last_combo >= world.time) return
	last_combo = world.time
	var/list/dirs = list(NORTH,SOUTH,EAST,WEST,NORTHWEST,SOUTHWEST,NORTHEAST,SOUTHEAST)
	if(frontOnly && M)
		var/front = DisplayedCardinal(M.dir, 0)
		dirs = list(landBehind ? opposite_dirs[front] : front)	
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
			//asked-for side goes first, random fallback after
			var/direction = (landDir && !landBehind && (landDir in dirs)) ? landDir : pick(dirs)
			dirs-=direction
			if(landBehind && !frontOnly)
				direction = opposite_dirs[M.dir]
			W=ComboLandingClear(M, direction)
			if(!W)
				continue //blocked tile; try another dir, don't abort the whole teleport
			src.last_combo_warp_dist = get_dist(src, M)
			src.loc=W
			if(PmActive())//land on the target's sprite, not its tile origin
				src.step_x=M.step_x
				src.step_y=M.step_y
			src.dir=ReturnDirection(src,M)
			if(!LightAttack && get_dist(src,M)>1)
				if(src.AttackQueue && src.AttackQueue.Rapid)
					FlashImage(src)
				else
					VanishImage(src)
			if(M.Beaming!=2 && !(frontOnly && landBehind))
				M.dir=ReturnDirection(M,src)
			break

mob/proc/SpeedDelay(var/Modifier=1)
	var/Spd=(src.GetSpd()+glob.ATTACK_DELAY_STAT_BASE)**glob.ATTACK_DELAY_EXPONENT
	var/Delay=glob.ATTACK_DELAY_DIVISOR/Spd
	if(passive_handler["Speed Force"])
		Delay = glob.ATTACK_DELAY_DIVISOR/((GetSpd()*glob.SPEED_FORCE_DELAYMULT+glob.ATTACK_DELAY_STAT_BASE)**glob.ATTACK_DELAY_EXPONENT)
	// Inevitable (Makyo)
	Delay += passive_handler.Get("Inevitable")
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
	if(P.IsGuarding() && !Forced && !trueForced)
		return	//guarded hits only move you via the pushback nudge
	if(!Direction)
		Direction=src.dir
	Forced+=isForced()
	if(P.ContinuousAttacking)
		for(var/obj/Skills/Projectile/p in P.contents)
			if(p.ContinuousOn && !p.StormFall)
				P.UseProjectile(p)
			continue
	Distance*=(gatherKBMods())
	Distance*=1+src.GetStr(glob.STR_KB_RATE) //muscle sends harder
	Distance/=1+P.GetVit(glob.VIT_KB_RATE) //mass stays planted
	Distance*=getKnockbackMultiplier(P) // gets the knockback multiplier(reduction) for the target
	if(!Forced)
		if(P.is_dashing)
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

	P.kb_sender = src	//splat credit + flourish
	if(P.Knockbacked)
		var/orgDistance = Distance
		P.Knockbacked=Direction
		Distance -= (P.previousKnockBack * glob.KB_SPEED)
		P.Knockback += max(Distance, 0)
		if(Forced>=3)
			P.Knockback = (orgDistance) * world.tick_lag
	else
		P.BeginKB(Direction, Distance, Ki, override_speed = override_speed * world.tick_lag)
		P.previousKnockBack = Distance

mob
	var/tmp/kb_loft = 0
	var/tmp/kb_recent_until = 0 
	var/tmp/dash_clash = 0 
	var/tmp/mob/clash_pursuit 
	var/tmp/clash_pursuit_until = 0
	proc/BeginKB(var/Direction, var/Distance, var/Ki, override_speed)
		if(src.Guarding) src.GuardStop()	//hard cc drops guard
		if(src.ChargingEnergy) src.ChargeStop()
		if(PmActive()) //tile-quantize before knockback so its get_step wall/edge probes stay accurate and it doesn't rest ~step_x px short
			src.step_x=0
			src.step_y=0
		src.icon_state="KB"
		src.Knockbacked=Direction
		src.Knockback=Distance*world.tick_lag
		src.kb_start_time = world.time	//fresh KB only - extensions keep the anchor
		//heavy sends pop the victim into a low arc; the world shadow shrinks under them so it reads as airtime
		var/w = min(Distance / glob.MAX_KB_TIME, 1)
		if(w >= glob.KB_LOFT_MIN && !src.Flying && !src.Launched && !src.pixel_z)
			src.kb_loft = 1
			animate(src, pixel_z = round(4 + glob.KB_LOFT_PX * w), time = 3, easing = SINE_EASING|EASE_OUT)
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
					if(ismob(a))
						var/mob/dm = a
						if(dm == src.kb_sender || (dm.is_dashing && dm.Target == src))
							continue
					dense=1
					break
			if(dense)
				//wall splat: force left in the send = stagger + thud
				if(src.Knockbacked && src.Knockback >= glob.SPLAT_MIN_REMAINING * world.tick_lag && src.splat_stagger_until < world.time)
					var/remTiles = src.Knockback / world.tick_lag
					ApplySplatStagger(src, glob.SPLAT_STAGGER_DS)
					var/splat_mult = 1
					if(src.splat_bonus_until > world.time && src.splat_bonus)
						splat_mult = 1 + src.splat_bonus
						src.splat_bonus_until = 0
					var/mob/sender = src.kb_sender
					spawn()
						if(sender && sender != src)
							sender.DoDamage(src, remTiles * glob.SPLAT_DMG_PER_TILE * splat_mult)
							sender.FlourishArm()
						src.Earthquake(4, -4,4,-4,4, 0, src.Knockbacked)
						KenShockwave(src, Size = min(remTiles/5, 1.5), Time = 4)
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
		//generic state-clear callers arrive with this already null, so they don't fire Landfalls
		var/wasKB = src.Knockbacked
		if(wasKB)
			src.kb_recent_until = world.time + glob.TIMING_WINDOW
		if(!src.KO)
			src.icon_state=""
		else
			src.icon_state="KO"
		src.Knockbacked=null
		src.Knockback=null
		if(src.kb_loft) //bring the arc down; animate commits pixel_z=0 instantly so the Landfall gate below still passes
			src.kb_loft = 0
			animate(src, pixel_z = 0, time = 2, easing = SINE_EASING|EASE_IN)
		if(src.Dunked)
			spawn()
				Crater(src,round(1+Dunked))
			src.Dunked=0
		else if(wasKB&&src.pixel_z==0&&!DustBlock)
			Landfall(src, min(previousKnockBack / glob.MAX_KB_TIME, 1)) //dust scales with how hard you were sent
		src.kb_sender = null
	proc/ClashPxDist(mob/M)
		if(!ismob(M) || M == src || M.z != z || !isturf(loc) || !isturf(M.loc))
			return 1000000
		return max(abs((M.x-x)*32 + (M.step_x-step_x)), abs((M.y-y)*32 + (M.step_y-step_y)))
	proc/ClashReach(mob/M)
		if(!M)
			return 0
		return (get_dist(src, M) <= 1 || ClashPxDist(M) <= 48)
	proc/TryDragonClash(mob/Trg, force_clashable = 0, from_hit = 0)
		if(!Trg || Trg == src)
			return
		if(!from_hit && !ClashReach(Trg))
			return
		var/pursued = (src.clash_pursuit == Trg && world.time <= src.clash_pursuit_until)
		if(Trg.Knockbacked||world.time<=Trg.kb_recent_until||pursued||src.passive_handler&&src.passive_handler.Get("SpiralImpact"))
			src.NextAttack=0
			Trg.StopKB()
			if(force_clashable || pursued || src.dash_clash>=2 || Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Dragon Dash")||src.passive_handler&&src.passive_handler.Get("SpiralImpact"))
				for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Clash_Defensive/DC in Trg)
					if(!Trg.BuffOn(DC))
						var/pursuerBoon = Trg.HasPursuer()
						DC.TimerLimit = 3 + clamp(0.25 * pursuerBoon, 0.001, glob.MAX_PURSUER_BOON)
						DC.Trigger(Trg)
				for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Clash/DC in src)
					if(!src.BuffOn(DC))
						var/pursuerBoon = HasPursuer()
						DC.TimerLimit = 3 + clamp(0.25 * pursuerBoon, 0.001, glob.MAX_PURSUER_BOON)
						if(isRace(MAKYO) && ActiveBuff)
							DC.passives["Star Surge"] = 1
							DC.TimerLimit = 1.5 + clamp(0.5 * pursuerBoon, 0.001, glob.MAX_PURSUER_BOON)
						if(src.hasSecret("Eldritch (Reflected)"))
							DC.ManaHeal=3+(src.AscensionsAcquired*2)
						DC.Trigger(src)
			src.clash_pursuit = null 
			return 1
	proc/ClashWatch(mob/Trg, clashable = 0)
		set waitfor = 0
		var/until = world.time + 30
		var/tail = 0
		var/armed = 0
		while(src && Trg && Trg.loc && world.time <= until)
			if(clashable && (Trg.Knockbacked || world.time <= Trg.kb_recent_until))
				armed = 1
				src.clash_pursuit = Trg
				src.clash_pursuit_until = world.time + 30
			if(glob && glob.DRAGON_CLASH_DEBUG && client)
				src << "clash-dbg: px=[ClashPxDist(Trg)] gd=[get_dist(src, Trg)] kb=[Trg.Knockbacked ? Trg.Knockbacked : 0] grace=[max(0, Trg.kb_recent_until - world.time)] armed=[armed] dash=[dash_clash]"
			if(TryDragonClash(Trg, clashable))
				if(glob && glob.DRAGON_CLASH_DEBUG && client) src << "clash-dbg: FIRED"
				return
			if(!src.dash_clash && !tail)
				tail = 1
				until = min(until, world.time + glob.TIMING_WINDOW)
			sleep(world.tick_lag)
		if(src && Trg && Trg.loc && armed && ClashPxDist(Trg) <= 64)
			if(glob && glob.DRAGON_CLASH_DEBUG && client) src << "clash-dbg: settling debt at px=[ClashPxDist(Trg)]"
			TryDragonClash(Trg, clashable, from_hit = 1)
		else if(glob && glob.DRAGON_CLASH_DEBUG && client)
			src << "clash-dbg: watcher exit unpaid armed=[armed] px=[Trg ? ClashPxDist(Trg) : "gone"]"
	proc/ClashBump(atom/A)
		if(!ismob(A))
			return
		var/mob/M = A
		if(src.dash_clash)
			src.TryDragonClash(M)
		if(M.dash_clash && (src.Knockbacked||world.time<=src.kb_recent_until))
			M.TryDragonClash(src)

mob/Bump(atom/A)
	ClashBump(A)
	..()

/var/tmp/lastGrabUsage=0


mob/proc/Grab()
	if(src.Stunned||src.Suspended||src.icon_state=="KB")
		return
	//tech: mash grab the instant you're grabbed to slip it. grab while held = tech, not a chain grab
	if(src.grabbed && ismob(src.grabbed) && src.grabbed:Grab == src)
		var/mob/G = src.grabbed
		if(world.time <= G.GrabTime + glob.TIMING_WINDOW)
			src.OMessage(10, "[src] slips [G]'s grip before it closes!", "[src] techs [G]'s grab")
			G.Grab_Release()
			if(PmActive())
				src.PmDashStep(G, 32, away = 1)
				G.PmDashStep(src, 32, away = 1)
			else
				step_away(src, G, 1)
				step_away(G, src, 1)
			KenShockwave(src, Size = 0.5, Time = 4)
			ApplySplatStagger(G, glob.SPLAT_STAGGER_DS)
			src.FlourishArm()
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
			if((src.Target in oview(1, src)) || InBodyReach(src.Target))
				src.Grab_Mob(src.Target)
			else
				ApplySplatStagger(src, glob.SPLAT_STAGGER_DS)	//whiffed the lunge, punishable
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
					if(buh.Stackable)
						for(var/obj/Items/i in src)
							if(i.type == P.type)
								i.TotalStack+=buh.TotalStack
								i.suffix="[Commas(i.TotalStack)]"
								src.OMessage(10,"[src] picks up [P].","[src]([src.key]) picks up [ExtractInfo(P)] made by [buh.CreatorKey].")
								del(P)
								return
						buh.suffix="[Commas(buh:TotalStack)]"
					if(src.CheckInventoryFull(P))
						return
					src.OMessage(10,"[src] picks up [P].","[src]([src.key]) picks up [ExtractInfo(P)] made by [buh.CreatorKey].")
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
	if(isAI(P))
		var/mob/Player/AI/aa = P
		if(!istype(src, /mob/Player/AI))
			if(aa.ai_hostility >= 1)
				if(aa.inloop == FALSE && !(aa in ticking_ai) && !(aa in companion_ais))
					ticking_ai.Add(aa)
				aa.SetTarget(src)
				aa.ai_state = "Chase"
				aa.last_activity = world.time
	if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Grab"))
		Forced = 1
	if(!Forced)
		if(istype(P, /mob/Body))
			src.Grab=P
			P.grabbed = src
			if(P.Guarding) P.GuardStop()	//grabs beat guard
			if(P.ChargingEnergy) P.ChargeStop()
			src.GrabTime = world.time
			src.OMessage(10,"[src] grabbed [P]!","[src]([src.key]) grabs [ExtractInfo(P)]")
			src.Grab_Update()
			src.Grab_Effects(P)
			var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/NearSighted/ns = src.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/NearSighted)
			if(ns && src.BuffOn(ns) && ns.source == P)
				ns.stopNearSighted(src)
				ns.Trigger(src, 1)
				var/obj/Skills/Buffs/SlotlessBuffs/Enma_Korogi/ek = P.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Enma_Korogi)
				if(ek && ek.domain_active)
					ek.ns_exempt |= src
			return
		if(!P.canBeGrabbed())
			src.OMessage(10,"[src] fails to get a firm hold on [P]!","[src]([src.key]) fails to grab [ExtractInfo(P)]")
			return
	src.Grab=P
	P.grabbed = src
	if(P.Guarding) P.GuardStop()	//grabs beat guard
	if(P.ChargingEnergy) P.ChargeStop()
	src.GrabTime = world.time
	src.OMessage(10,"[src] grabbed [P]!","[src]([src.key]) grabs [ExtractInfo(P)]")
	src.Grab_Update()
	src.Grab_Effects(P)
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/NearSighted/ns = src.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/NearSighted)
	if(ns && src.BuffOn(ns) && ns.source == P)
		ns.stopNearSighted(src)
		ns.Trigger(src, 1)
		var/obj/Skills/Buffs/SlotlessBuffs/Enma_Korogi/ek = P.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Enma_Korogi)
		if(ek && ek.domain_active)
			ek.ns_exempt |= src

/mob/proc/canBeGrabbed()
	if(KO) return 1;
	if(icon_state=="Meditate") return 1;
	if(HasGiantForm()) return 0;
	return 1;


/mob/var/tmp/mob/Player/grabbed = null
mob/proc/Grab_Release()
	if(src.Grab)
	{
		src.Grab.grabbed = null
		sleep(1)
		src.Grab=null
	}

mob/proc/Grab_Update()
	if(src.Grab)
		Grab.grabbed = src
		src.Grab.loc=src.loc
		if(PmActive())//grabbed victim rides the grabber's mid-tile sprite, not the tile origin
			src.Grab.step_x=src.step_x
			src.Grab.step_y=src.step_y
		if(isAI(Grab)&&!Grab.KO)
			var/grabbing = Grab
			spawn(60)
				if(grabbing==Grab)
					src.Grab_Release()
		if(ismob(Grab))
			if(src.Grab.Grab)
				src.Grab.Grab.loc=Grab.loc
				if(PmActive())//chain-grabbed victim rides the middle link's offset (set just above)
					src.Grab.Grab.step_x=Grab.step_x
					src.Grab.Grab.step_y=Grab.step_y
			if(src.Grab.Knockbacked||src.Knockbacked)
				src.Grab_Release()
		if(src.KO)
			src.Grab_Release()

mob/proc/Grab_Effects(var/mob/P)
	if(src.RippleActive())
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

	if(src.passive_handler["WarpPoint"] && ismob(P))
		var/obj/Skills/Grapple/Flashback/fb = src.FindSkill(/obj/Skills/Grapple/Flashback)
		if(fb && src.warp_strike_saved_loc)
			fb.FlashbackTrigger(src, P)

	if(canStealMana(P))//eldritch magic steal
		var/confirm = prompt("You can feel the threads of [P]'s magic circuits. Are they your's, now?", "Take Magic", list("No", "Yes"));
		if(confirm=="Yes") EldritchMagicSteal(P);

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

