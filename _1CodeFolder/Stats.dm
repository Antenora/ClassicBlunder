mob/verb/Character_Sheet()
	set category = "Other"
	src<<browse(src.GetAssess(),"window=Assess;size=275x650")

mob/proc/GetAssess()
	var/PowerDisplay
	var/IntimDisplay
	var/BaseDisplay
	var/GodKiDisplay
	var/StatAverage=round((src.GetStr()+src.GetEnd()+src.GetSpd()+src.GetFor()+src.GetOff()+src.GetDef())/6, 0.05)
	var/EffectiveAnger=Anger
	var/PDam=1+((src.HasPureDamage()/10)*glob.PURE_MODIFIER)
	var/PRed=1+((src.HasPureReduction()/10)*glob.PURE_MODIFIER)
	if(src.Anger)
		if(src.AngerMult>1)
			var/ang=EffectiveAnger-1//Usable anger
			var/mult=ang*src.AngerMult
			EffectiveAnger=mult+1
		if(src.AngerThreshold)
			if(EffectiveAnger<src.AngerThreshold)
				EffectiveAnger=src.AngerThreshold
		if(src.DefianceCounter>0&&!CheckSlotless("Great Ape"))
			EffectiveAnger+=src.DefianceCounter*0.05
		if(src.CyberCancel>0)
			var/ang=EffectiveAnger-1//Usable anger.
			var/cancel=ang*src.CyberCancel//1 Cyber Cancel = all of usable anger.
			EffectiveAnger-=cancel//take the anger away.
			if(EffectiveAnger<1)//Only nerf anger.
				EffectiveAnger=1
		if(src.PhylacteryNerf)
			EffectiveAnger-=(EffectiveAnger*src.PhylacteryNerf)

	PowerDisplay=Get_Scouter_Reading(src)
	if(src.HasPowerReplacement())
		BaseDisplay=src.GetPowerReplacement()*src.PowerBoost*src.RPPower
	else
		BaseDisplay=src.potential_power_mult*src.PowerBoost*src.RPPower
	if(src.HasIntimidation())
		IntimDisplay=src.GetIntimidation()
	else
		IntimDisplay=1
	if(src.HasGodKi())
		GodKiDisplay=src.GetGodKi()
	else
		GodKiDisplay=0
	if(potential_power_tier < 1)
		potential_power_tier = 1
	if(power_display < 1 || power_display == null)
		power_display = 1
	var/blahh={"

			<html>
	<style type="text/css">
	<!--
	body {
	     color:#449999;
	     background-color:black;
	     font-size:12;
	 }
	table {
	     font-size:12;
	 }
	//-->
	</style>
	<body>
	[src.name]<br><br>
	Current Anger:	[EffectiveAnger*100]%<br>
	<table cellspacing="6%" cellpadding="1%">
	<tr><ts>Current Power:</td><td>[Power] / Power Mult: [round(src.potential_power_mult, 0.05)]</td></tr>
	<tr><td>Base:</td><td>[BaseDisplay]/([src.PowerBoost*src.RPPower*round(src.potential_power_mult, 0.05)])</td></tr>
	<tr><td>Intimidation:</td><td>x[IntimDisplay]</td></tr>
	<tr><td>Damage Boost:</td><td>x[PDam] ([PDam*100]%)</td></tr>
	<tr><td>Damage Reduction:</td><td>x[PRed] ([PRed*100]%)</td></tr>
	<tr><td>God Ki:</td><td>x[GodKiDisplay]</td></tr>
	<tr><td>Current BP:</td><td>[Commas(PowerDisplay)]</td></tr>
	<tr><td>Energy:</td><td>[Commas(round(src.EnergyMax))] (1)</td></tr>
	<tr><td>Buffed Stat/True Stat (Mod)</td></tr>
	<tr><td>Strength:</td><td> [round(src.GetStr(), 0.01)] ([src.BaseStr()])</td></tr>
	<tr><td>Endurance:</td><td> [round(src.GetEnd(), 0.01)] ([src.BaseEnd()])</td></tr>
	<tr><td>Speed:</td><td> [round(src.GetSpd(), 0.01)] ([src.BaseSpd()])</td></tr>
	<tr><td>Force:</td><td> [round(src.GetFor(), 0.01)] ([src.BaseFor()])</td></tr>
	<tr><td>Offense:</td><td> [round(src.GetOff(), 0.01)] ([src.BaseOff()])</td></tr>
	<tr><td>Defense:</td><td> [round(src.GetDef(), 0.01)] ([src.BaseDef()])</td></tr>
	<tr><td>Recovery:</td><td> [round(src.GetRecov(), 0.01)] ([src.BaseRecov()])</td></tr>
	<tr><td>Anger:</td><td>[src.AngerMax*100]%</td></tr>
	<tr><td>Power Mult:</td><td>[round(src.potential_power_mult, 0.05) + src.PowerBoost]%</td></tr>
	<tr><td>Potential:</td><td>[Potential]/100</td></tr>
	<tr><td>Transformation Potential:</td><td>[src.potential_trans]/100</td></tr>
	<tr><td>Average Stats: [StatAverage]</td></tr>
	<tr><td>Magic Level: [getTotalMagicLevel()]</td></tr>
			</table></html>"}
/*	<tr><td>True Tier:</td><td>[POWER_TIERS[potential_power_tier]]</td></tr>
	<tr><td>Display Tier:</td><td>[POWER_TIERS[power_display]]</td></tr>*/

	return blahh

mob
	proc
		GetHealthBPMult()
			var/Return=0
			Return=min(src.TotalInjury/100,0.25)*(-1)
			if(Return>0)
				Return=0
			return Return
		GetEnergyBPMult()
			var/Return=0
			Return=min(src.TotalFatigue/100,0.5)*(-1)
			if(Return>0)
				Return=0
			if(src.passive_handler.Get("Anaerobic"))
				Return=min(src.TotalFatigue-20/100,0.5)
			return Return


proc/SenseDetect(atom/A,Range)
	var/list/Mobs=new
	for(var/mob/P in players)
		if(P.client)
			if(P.z==A.z)
				var/t=abs(A.x-P.x)+abs(A.y-P.y)
				if(t<Range)
					Mobs+=P
	return Mobs

mob/var/list/Tabz=list("Science"="Hide","Build"="Hide","Enchantment"="Hide","Inventory"="Show")

mob/Players/Stat()
	if(client.show_verb_panel)

		statpanel("Statistics")
		if(statpanel("Statistics"))
			CHECK_TICK
			if(src.Mapper)
				stat("Location", "[src.x], [src.y], [src.z]")
/*			if(power_display)
				stat("Power Tier: ", "[POWER_TIERS[power_display]]")*/
			if(src.EraDeathClock)
				stat("Death Timer: ", "[round((src.EraDeathClock-world.realtime)/Hour(1), 0.1)] hours")

			switch(BPPoison)
				if(0.01 to 0.5)
					stat("Health Status: ", "<font color='red'>Grieviously Wounded ([round(src.BPPoisonTimer/RawHours(1), 0.1)] hours)</font color>")
				if(0.51 to 0.7)
					stat("Health Status: ", "<font color='orange'>Heavily Wounded ([round(src.BPPoisonTimer/RawHours(1), 0.1)] hours)</font color>")
				if(0.71 to 0.9)
					stat("Health Status: ", "<font color='yellow'>Lightly Wounded ([round(src.BPPoisonTimer/RawHours(1), 0.1)] hours)</font color>")
				if(1.01 to 1#INF)
					stat("Health Status: ", "<font color='green'>Boosted ([round(src.BPPoisonTimer/RawMinutes(1), 0.1)] minutes)</font color>")

			switch(OverClockNerf)
				if(0.001 to 0.5)
					stat("Fatigue Status: ", "<font color='yellow'>Exhausted ([round(src.OverClockTime/RawHours(1), 0.1)] hours)</font color>")
				if(0.51 to 0.7)
					stat("Fatigue Status: ", "<font color='orange'>Heavily Exhausted ([round(src.OverClockTime/RawHours(1), 0.1)] hours)</font color>")
				if(0.71 to 0.99)
					stat("Fatigue Status: ", "<font color='red'>Helplessly Exhausted ([round(src.OverClockTime/RawHours(1), 0.1)] hours)</font color>")

			if(src.Satiated)
				stat("Satiation: ", "Well Fed")
				if(src.Drunk)
					stat("Inebriation: ", "Drunk")
			if(src.Maimed)
				stat("Maims: ", "[src.Maimed]")

			if(!src.StrTax&&!src.StrCut)
				stat("Strength","[src.BaseStr()]")
			else
				stat("Strength","[src.BaseStr()] (Tax: [round((src.StrTax+src.StrCut)*100)]%)")
			if(!src.EndTax&&!src.EndCut)
				stat("Endurance","[src.BaseEnd()]")
			else
				stat("Endurance","[src.BaseEnd()] (Tax: [round((src.EndTax+src.EndCut)*100)]%)")
			if(!src.SpdTax&&!src.SpdCut)
				stat("Speed","[src.BaseSpd()]")
			else
				stat("Speed","[src.BaseSpd()] (Tax: [round((src.SpdTax+src.SpdCut)*100)]%)")
			if(!src.ForTax&&!src.ForCut)
				stat("Force","[src.BaseFor()]")
			else
				stat("Force","[src.BaseFor()] (Tax: [round((src.ForTax+src.ForCut)*100)]%)")
			if(!src.OffTax&&!src.OffCut)
				stat("Offense","[src.BaseOff()]")
			else
				stat("Offense","[src.BaseOff()] (Tax: [round((src.OffTax+src.OffCut)*100)]%)")
			if(!src.DefTax&&!src.DefCut)
				stat("Defense","[src.BaseDef()]")
			else
				stat("Defense","[src.BaseDef()]) (Tax: [round((src.DefTax+src.DefCut)*100)]%)")
			if(!src.RecovTax&&!src.RecovCut)
				stat("Recovery","[round(src.BaseRecov(), 0.05)]")
			else
				stat("Recovery","[round(src.BaseRecov(), 0.05)] (Tax: [round((src.RecovTax+src.RecovCut)*100)]%)")

			stat("Potential:","[round(src.Potential, 0.005)]")
			if(HealthCut)
				stat("HealthCut: ", "[round(HealthCut*100)]%")
			stat("----","----")
			stat("Reward Points:","[round(usr.RPPSpendable)]")
			stat("Reward Points Used:","[round(usr.RPPSpent)]")
			if(usr.RPPDonate)
				stat("Donate RPP:", "[round(usr.RPPDonate)]")
			if(usr.PotentialRate>0)
				switch(usr.PotentialStatus)
					if("Distracted")
						stat("Focus Status: ", "<font color='red'>[usr.PotentialStatus]</font color>")
					if("Average")
						stat("Focus Status: ", "<font color='yellow'>[usr.PotentialStatus]</font color>")
					if("Focused")
						stat("Focus Status: ", "<font color='green'>[usr.PotentialStatus]</font color>")

			if(src.StyleActive||src.ActiveBuff||src.SpecialBuff||src.SlotlessBuffs.len>0)
				var/textBuffs=""
				if(src.SlotlessBuffs.len>0)
					var/Remaining=src.SlotlessBuffs.len
					for(var/i in src.SlotlessBuffs)
						if(i == null)
							usr.SlotlessBuffs.Remove(null)
							continue
						if(Remaining>1)
							textBuffs+="[i], "
						else
							textBuffs+="[i]"
						Remaining--
				stat("")
				stat("--BUFFS--")
				stat("")
				if(src.StyleActive)
					stat("Style: ", "[usr.StyleActive]")
				if(src.ActiveBuff)
					stat("Active Buff: ","[usr.ActiveBuff.name]")
				if(src.SpecialBuff)
					stat("Special Buff: ","[usr.SpecialBuff.name]")
				if(src.SlotlessBuffs.len > 0)
					stat("Augments: ", "[textBuffs]")

		if(Admin&&usr.Overview==1 && usr.AFKTimer)
			statpanel("Overview")
			if(statpanel("Overview"))
				CHECK_TICK
				stat("Coordinates","[usr.x],[usr.y],[usr.z]")
				stat("CPU","[world.cpu] ([world.tick_usage])")
				stat("Era","[glob.progress.Era]")
				stat("Days of Wipe:", "[glob.progress.DaysOfWipe]")
				stat("DAILY CHECK TIMER: ", "[time2text(glob.progress.WipeStart,"hh:mm:ss")]")
				stat("Celestial Object Ticks: ", "[celestialObjectTicks]")
				stat("Potential Daily:", "[glob.progress.PotentialDaily]")
				stat("Dead Spawn:", "([glob.DEATH_LOCATION[1]], [glob.DEATH_LOCATION[2]], [glob.DEATH_LOCATION[3]])")
				stat("Void Spawn:", "([glob.VOID_LOCATION[1]], [glob.VOID_LOCATION[2]], [glob.VOID_LOCATION[3]])")
				stat("KO Get Up Speed","[glob.GetUpVar]x")
				stat("Voids On?", "[glob.VoidsAllowed]")
				stat("Void Chance", "[glob.VoidChance]%")

				stat("----Damage---", "------")
				stat("Base Power: ", "[Commas(glob.WorldBaseAmount)]")
				stat("World Queue Damage Multiplier", "[glob.GLOBAL_QUEUE_DAMAGE]x")
				stat("World Damage Multiplier", "x[glob.WorldDamageMult]")
				stat("World Accuracy Rate", "[glob.WorldDefaultAcc]%")
				stat("World Whiff Rate", "[glob.WorldWhiffRate]% hits will not whiff")
				stat("World Melee Damage", "[glob.GLOBAL_MELEE_MULT]x")
				stat("World Item Damage", "[glob.GLOBAL_ITEM_DAMAGE_MULT]x")
				stat("World Autohit Damage", "[glob.AUTOHIT_GLOBAL_DAMAGE]x")
				stat("World Proj Damage", "[glob.PROJ_DAMAGE_MULT]x")
				stat("DMG Effectiveness", "[glob.DMG_STR_EXPONENT]")
				stat("DMG END Effectiveness", "[glob.DMG_END_EXPONENT]")
				stat("Power in DMG effectiveness", "[glob.DMG_POWER_EXPONENT]")
				stat("Melee Effectiveness", "[glob.MELEE_EFFECTIVENESS]x")
				stat("Projectile Effectiveness", "[glob.PROJECTILE_EFFECTIVNESS]x")
				stat("Grapple Effectiveness", "[glob.GRAPPLE_EFFECTIVNESS]x")
				stat("AutoHit Effectiveness", "[glob.AUTOHIT_EFFECTIVNESS]x")
				stat("Damage Rolls", "[glob.min_damage_roll],[glob.upper_damage_roll]")
				stat("Intim Ratio", "[glob.INTIMRATIO]x")
				stat("RPP Routine", "[Commas(glob.progress.RPPDaily)]")
				stat("RPP Starting / RPP Starting Days", "[Commas(glob.progress.RPPStarting)] / [Commas(glob.progress.RPPStartingDays)]")
				stat("Economy Rates", "[Commas(glob.progress.EconomyCost)] [glob.progress.MoneyName] Cost / [Commas(glob.progress.EconomyIncome)] Income / [Commas(glob.progress.EconomyMana)] Mana Cost")


		statpanel("Inventory")
		if(statpanel("Inventory")&&usr.AFKTimer)
			CHECK_TICK
			for(var/obj/Money/M in usr)
				M.name="[Commas(round(M.Level))] [glob.progress.MoneyName]"
				stat(M)
			for(var/obj/Items/A in usr)
				if(!(A.PermEquip&&A.suffix&&!A.Stealable))
					if(istype(A, /obj/Items/Armor) || istype(A, /obj/Items/Sword))
						if(A:Conjured) continue
					if(istype(A, /obj/Items/Enchantment/Tome))
						A.icon_state="Inventory"
					if(A.Stackable)
						A.suffix="[A.TotalStack]"
					stat(A)
					if(istype(A, /obj/Items/Gear))
						A.icon_state="Inventory"
						if(!A:InfiniteUses)
							if(A.Techniques.len>=2)
								stat("[A:Uses] / [A:MaxUses] | Int: [A:IntegratedUses] / [A:IntegratedMaxUses]")
							else if(A.Techniques.len==1&&!(istype(A, /obj/Items/Gear/Prosthetic_Limb)))
								stat("[A:Uses] / [A:MaxUses]")
							else if(A.Techniques.len==1&&(istype(A, /obj/Items/Gear/Prosthetic_Limb)))
								stat("Int: [A:IntegratedUses] / [A:IntegratedMaxUses]")
							else
								stat("[A:Uses] / [A:MaxUses]")

		statpanel("Current Target")
		if(statpanel("Current Target")&&usr.Target)
			CHECK_TICK
			if(isplayer(usr.Target) || istype(usr.Target, /mob/Player))
				stat("Focused:",Target)
				if(usr.EnhancedSmell&&!usr.Target.passive_handler.Get("Void") || usr.Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Senses"))
					if(usr.Secret == "Heavenly Restriction" && usr.secretDatum?:hasRestriction("Senses"))
						goto Restricted
					var/Scent="Sewage"
					if(usr.Target.custom_scent)
						Scent=usr.Target.custom_scent
						stat("Scent: ", usr.Target.custom_scent)
					else
						usr.Target.setUpScent()
						stat("Scent: ", Scent)

				Restricted

				var/WoundIntent
				var/KillingIntent
				var/Status
				var/RPIntent

				if(usr.Secret == "Heavenly Restriction" && usr.secretDatum?:hasRestriction("Senses"))
					goto Restricted2

				if(usr.Target.HasFakePeace()||(usr.Target.WoundIntent==0&&!usr.Target.SwordWounds()&&!usr.Target.CursedWounds()&&!(usr.IsEvil()&&usr.Target.HasPurity())))
					WoundIntent="<font color='green'>None</font color>"
				else
					WoundIntent="<font color='red'>Strong</font color>"

				if(usr.Target.HasFakePeace()||(usr.Target.Lethal==0&&!usr.Target.CursedWounds()&&!(usr.IsEvil()&&usr.Target.HasPurity())))
					KillingIntent="<font color='green'>None</font color>"
				else
					KillingIntent="<font color='red'>Strong</font color>"

				if(usr.Target.BPPoison>=1)
					Status="<font color='green'>Healthy</font color>"
				else
					Status="<font color='red'>Wounded</font color>"

				stat("Injury Intent: ", WoundIntent)
				stat("Killing Intent: ", KillingIntent)


				if(usr.MedicineUnlocked+usr.ImprovedMedicalTechnologyUnlocked>=2&&!usr.Target.passive_handler.Get("Void")&&!usr.Target.HasMechanized() || usr.Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Senses"))
					stat("Status:", Status)
				if(usr.Target.Maimed)
					stat("<font color='red'>They are maimed.</font color>")
				if(usr.Target.MortallyWounded)
					stat("<font color='red'>They are bleeding heavily.</font color>")

				if(!usr.Target.HasGodKi()&&!usr.Target.passive_handler.Get("Void")&&!usr.Target.HasMechanized()&&usr.Target.SenseUnlocked<7 || usr.Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Senses"))
					stat("Direction - [get_dist(usr, usr.Target)] tiles away","[CheckDirection(usr.Target)]")
					stat("Power:","[Get_Sense_Reading(Target)]")
					if(Target.BioArmor)
						var/displayMarks = ""
						if(Target.BioArmor >= 100)
							displayMarks = "???"
						else if(Target.BioArmor < 99 && Target.BioArmor >= 10)
							displayMarks = "??"
						else if(Target.BioArmor < 10)
							displayMarks = "?"
						stat("Health:", "[Target.Health]([displayMarks])%")
					else if(Target.VaizardHealth)
						stat("Health:", "[Target.Health]([Target.VaizardHealth])%")
					else
						stat("Health: ","[Target.Health]%")
					stat("Energy: ","[(Target.Energy/Target.EnergyMax)*100]%")
				else
					stat("Power: ", "Incomprehensible")
					if(usr.HasClarity() || usr.passive_handler.Get("AdminVision"))
						stat("Direction - [get_dist(usr, usr.Target)] tiles away","[CheckDirection(usr.Target)]")
						stat("Health: ","[round(Target.Health)]%")

				Restricted2

				if(usr.Target.PureRPMode==0)
					RPIntent="<font color='green'>RP Mode Off</font color>"
				else
					RPIntent="<font color='red'>RP Mode On</font color>"

				stat("Roleplay Mode: ", RPIntent)

				if(usr.Admin || glob.TESTER_MODE)
					stat(viewmobcontents)
					if(AdminContentsView)
						for(var/obj/Z in Target.contents)
							if(!Z.AdminInviso)
								stat(Z)



atom/proc/CheckDirection(var/mob/M)
	if(M.z != src.z) return "???"
	var/h = get_dir(src, M)
	switch(h)
		if(NORTH)
			. = "North"
		if(SOUTH)
			. = "South"
		if(EAST)
			. = "East"
		if(WEST)
			. = "West"
		if(NORTHEAST)
			. = "North East"
		if(NORTHWEST)
			. = "North West"
		if(SOUTHEAST)
			. = "South East"
		if(SOUTHWEST)
			. = "South West"

globalTracker/var/MOVEMENT_MASTERY_DIVISOR = 10


mob/proc/GetPowerUpRatio()
	var/Ratio=1
	var/PowerUp=max(((PowerControl-100)/100),-0.5)
	if(passive_handler.Get("PUSpike"))
		PowerUp+=passive_handler.Get("PUSpike")/100
	if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Power Control"))
		PowerUp += secretDatum?:getBoon(src, "Power Control")/12
	if(src.CheckSpecial("Overdrive"))
		PowerUp+=1
/*	if(src.CyberCancel)
		if(!isRace(ANDROID))
			PowerUp-=PowerUp*src.CyberCancel*/
	if(src.HasMovementMastery()&&PowerUp>0)
		var/mmBonus = src.GetMovementMastery() / glob.MOVEMENT_MASTERY_DIVISOR
		// max is around 20, maybe 22 or 23

		Ratio=1+(PowerUp*(1+(mmBonus)))
	else
		Ratio=1+PowerUp

	if(!src.HasKiControl()&&!src.PoweringUp)
		if(Ratio>1)
			Ratio=1

	if(passive_handler.Get("AllowedPower")&&Ratio>passive_handler.Get("AllowedPower"))
		Ratio=passive_handler.Get("AllowedPower")

	if(Ratio<=0)
		Ratio=0.01

	return Ratio

mob/proc/GetPowerUpRatioVisble()
	var/Ratio=1
	var/PowerUp=(PowerControl-100)/100
	if(passive_handler.Get("PUSpike"))
		PowerUp+=(passive_handler.Get("PUSpike")/100)
	if(src.CheckSpecial("Overdrive"))
		PowerUp+=1
	/*if(src.CyberCancel)
		if(!isRace(ANDROID))
			PowerUp-=PowerUp*src.CyberCancel*/
	if(HasMovementMastery()&&PowerUp>0)
		Ratio=1+(PowerUp*(1+(GetMovementMastery()/glob.MOVEMENT_MASTERY_DIVISOR)))
	else
		Ratio=1+PowerUp
	if(!src.HasKiControl()&&!src.PoweringUp)
		if(Ratio>1)
			Ratio=1
	if(passive_handler.Get("AllowedPower")&&Ratio>passive_handler.Get("AllowedPower"))
		Ratio=passive_handler.Get("AllowedPower")
	if(Ratio<=0)
		Ratio=0.01
	return Ratio

mob/proc/Recover(var/blah,Amount=1)
	switch(blah)
		if("Health")
			if(PureRPMode)
				return
			if(src.Transfering)
				return
			if(src.Oxygen<=10)
				return
			if(SenseRobbed>=2&&(src.SenseUnlocked<=src.SenseRobbed&&src.SenseUnlocked>5))
				Amount/=src.SenseRobbed
			if(src.MeditateModule)
				Amount*=2
			if(Swim&&passive_handler.Get("Fishman"))
				Amount*=2
			src.HealHealth(Amount*(25/max(Health,1)))
			if(Health==100&&src.BioArmor<src.BioArmorMax)
				src.BioArmor+=Amount
				if(src.BioArmor>=src.BioArmorMax)
					src.BioArmor=src.BioArmorMax
			if(src.StrStolen)
				src.StrStolen-=0.1
				if(src.StrStolen<0)
					src.StrStolen=0
			if(src.EndStolen)
				src.EndStolen-=0.1
				if(src.EndStolen<0)
					src.EndStolen=0
			if(src.SpdStolen)
				src.SpdStolen-=0.1
				if(src.SpdStolen<0)
					src.SpdStolen=0
			if(src.ForStolen)
				src.ForStolen-=0.1
				if(src.ForStolen<0)
					src.ForStolen=0
			if(src.OffStolen)
				src.OffStolen-=0.1
				if(src.OffStolen<0)
					src.OffStolen=0
			if(src.DefStolen)
				src.DefStolen-=0.1
				if(src.DefStolen<0)
					src.DefStolen=0
			if(src.PowerEroded>0)
				src.PowerEroded-=0.02
				if(src.PowerEroded<0)
					src.PowerEroded=0
			if(src.StrEroded>0)
				src.StrEroded-=0.02
				if(src.StrEroded<0)
					src.StrEroded=0
			if(src.EndEroded>0)
				src.EndEroded-=0.02
				if(src.EndEroded<0)
					src.EndEroded=0
			if(src.SpdEroded>0)
				src.SpdEroded-=0.02
				if(src.SpdEroded<0)
					src.SpdEroded=0
			if(src.ForEroded>0)
				src.ForEroded-=0.02
				if(src.ForEroded<0)
					src.ForEroded=0
			if(src.OffEroded>0)
				src.OffEroded-=0.02
				if(src.OffEroded<0)
					src.OffEroded=0
			if(src.DefEroded>0)
				src.DefEroded-=0.02
				if(src.DefEroded<0)
					src.DefEroded=0
			if(src.RecovEroded>0)
				src.RecovEroded-=0.02
				if(src.RecovEroded<0)
					src.RecovEroded=0
			if(Health>10*(1-src.HealthCut)&&src.HealthAnnounce10)
				src.HealthAnnounce10=0
			if(Health>25*(1-src.HealthCut)&&src.HealthAnnounce25)
				src.HealthAnnounce25=0
			if(Health>50*(1-src.HealthCut)&&src.MeltyMessage)
				src.MeltyMessage=0
			if(Health>50*(1-src.HealthCut)&&src.VenomMessage)
				src.VenomMessage=0
			if(src.NanoBoost)
				if(src.Health>=75*(1-src.HealthCut)&&src.NanoAnnounce)
					src.NanoAnnounce=0
			if(isplayer(src))
				src:move_speed = MovementSpeed()
		if("Injury")
			if(PureRPMode)
				return
			if(src.Transfering)
				return
			// if(src.SummonReturnTimer)
			// 	return
			if(src.Oxygen<=10)
				return
			if(SenseRobbed>=2&&(src.SenseUnlocked<=src.SenseRobbed&&src.SenseUnlocked>5))
				Amount/=src.SenseRobbed
			if(src.MeditateModule)
				Amount*=3
			if(Swim&&passive_handler.Get("Fishman"))
				Amount*=2
			if(TotalInjury>0)
				var/InjuryRecov
				if(src.icon_state == "Meditate")
					InjuryRecov=0.008*(min(src.GetRecov())**2)*Amount*(max(0.1,Health/80))
				else
					InjuryRecov=0.004*(src.GetRecov()**4)*Amount*(max(0.1,Health/100))
				src.HealWounds(InjuryRecov)//Injuries last longer for good reason
			if(TotalInjury<50&&src.InjuryAnnounce)
				src.InjuryAnnounce=0
		if("Energy")
			if(PureRPMode)
				return
			if(src.Transfering)
				return
			if(src.Oxygen<=10)
				return
			if(SenseRobbed>=2&&(src.SenseUnlocked<=src.SenseRobbed&&src.SenseUnlocked>5))
				Amount/=src.SenseRobbed
			if(Swim&&passive_handler.Get("Fishman"))
				Amount*=2
			var/KiControl=src.GetKiControlMastery()
			if(KiControl>0)
				Amount*=1+KiControl
			if(src.Secret=="Ripple")
				Amount*=2
			Amount*=sqrt(max(1,GetRecov()))
			src.HealEnergy(Amount*(100/max(Health,1)))
		if("Fatigue")
			if(PureRPMode)
				return
			if(src.Transfering)
				return
			// if(src.SummonReturnTimer)
			// 	return
			if(src.Oxygen<=10)
				return
			if(src.transActive()&&!src.HasMystic())
				if(src.race.transformations[transActive].mastery<75)
					return
			if(Swim&&passive_handler.Get("Fishman"))
				Amount*=2
			if(src.Secret=="Ripple")
				Amount*=2
			if(TotalFatigue>0)
				var/FatigueRecov=0.01*Amount
				src.HealFatigue(FatigueRecov)
		if("Mana")
			if(PureRPMode)
				return
			if(src.Transfering)
				return
			// if(src.SummonReturnTimer)
			// 	return
			if(UsingAnsatsuken())
				return
			if(SagaLevel>1&&Saga=="Path of a Hero: Rebirth")
				return
			if(Oxygen<=10)
				return
			if(SenseRobbed>=2&&(src.SenseUnlocked<=src.SenseRobbed&&src.SenseUnlocked>5))
				Amount/=src.SenseRobbed
			if(Swim&&passive_handler.Get("Fishman"))
				Amount*=2
			if(CheckSpecial("Bond Keeper"))
				Amount*=max(2,2*(1-(ManaAmount/(100*GetManaCapMult()))))
			src.HealMana(Amount)
		if("Capacity")
			if(PureRPMode)
				return
			// if(src.SummonReturnTimer)
			// 	return
			if(src.Transfering)
				return
			if(Oxygen<=10)
				return
			if(SenseRobbed>=2&&(src.SenseUnlocked<=src.SenseRobbed&&src.SenseUnlocked>5))
				Amount/=src.SenseRobbed
			if(Swim&&passive_handler.Get("Fishman"))
				Amount*=2
			if(TotalCapacity>0)
				var/CapacityRecov=((0.001*(src.GetRecov()+src.GetRecov()))*Amount)
				src.HealCapacity(CapacityRecov)
			for(var/obj/Items/Enchantment/PhilosopherStone/PS in src)
				if(istype(PS, /obj/Items/Enchantment/PhilosopherStone/Magicite)) continue
				if(PS.CurrentCapacity<PS.MaxCapacity)
					PS.CurrentCapacity+=(0.0005*PS.SoulStrength*Amount)
				if(PS.CurrentCapacity>PS.MaxCapacity)
					PS.CurrentCapacity=PS.MaxCapacity

mob/proc/
	Available_Power()
//Kaiokek
		if(src.Kaioken)
			switch(src.Kaioken)
				if(1)
					src.PowerControl=160
					src.KaiokenBP=1.2
				if(2)
					src.PowerControl=175
					src.KaiokenBP=1.3
				if(3)
					src.PowerControl=200
					src.KaiokenBP=1.4
				if(4)
					src.PowerControl=250
					src.KaiokenBP=1.5
				if(5)
					src.PowerControl=300
					src.KaiokenBP=1.7
		else
			src.KaiokenBP=1
//EPM modifications
		var/EPM=src.Power_Multiplier
		if(src.HasMovementMastery())
			if(src.ActiveBuff && src.ActiveBuff.PowerMult > 1 && (GetPowerUpRatio()<=1))
				EPM+=((src.ActiveBuff.PowerMult-1) * (1+(src.GetMovementMastery()/glob.MOVEMENT_MASTERY_DIVISOR)))-(src.ActiveBuff.PowerMult-1)

		if(src.PowerEroded)
			EPM-=src.PowerEroded
		if(src.NanoBoost&&src.Health<25)
			EPM+=0.25

		// if(src.DemonicPower())
		// 	var/pot=src.get_potential()
		// 	EPM+=pot/100

		// if(isRace(MAKYO)&&src.ActiveBuff&&!src.HasMechanized())
		// 	EPM+=0.1*src.AscensionsAcquired

		if(EPM<=0)
			EPM=0.1
		//Ratio
		var/Ratio=1
		Ratio*=EPM
		var/ShonenPower = ShonenPowerCheck(src)
		if(ShonenPower)
			Ratio*=GetSPScaling(ShonenPower)
		if(src.HasHellPower())
			Ratio*=src.GetHellScaling()
		Ratio*=src.Base()
		temp_potential_power(src)//get them potential powers
		Ratio*=src.potential_power_mult

		if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Power"))
			Ratio *= 1+(secretDatum?:getBoon(src, "Power")/15)
		//BODY CONDITION INFLUENCES
		if(!passive_handler.Get("Piloting"))
			if(!passive_handler.Get("Possessive"))
				if(src.CanLoseVitalBP()>=1||src.passive_handler.Get("Anaerobic"))
					Ratio*=1+src.GetEnergyBPMult()

				if(src.JaganPowerNerf)
					Ratio*=src.JaganPowerNerf
				if(src.BPPoison)
					if((src.Secret=="Zombie"||src.Doped||(src.SagaLevel>=5&&src.AnsatsukenAscension=="Chikara"))&&src.BPPoison<1)
						Ratio*=1
					else
						Ratio*=src.BPPoison
				if(src.Maimed)
					var/Ignore=src.HasMaimMastery()
					if(Ignore || isRace(CHANGELING))
						Ratio*=1
					else
						src.MaimsOutstanding=max(src.Maimed-(0.5*src.GetProsthetics()), 0)
						Ratio*=(1-(0.1*src.MaimsOutstanding))
				if(src.HasWeights())
					if(src.Saga!="Eight Gates")
						Ratio*=0.7
					else
						Ratio*=0.8
				if(src.Roided)
					Ratio*=1.15
				if(src.OverClockNerf)
					Ratio*=max(1-src.OverClockNerf,0.1)
				if(src.GatesNerfPerc)
					Ratio*=((100-src.GatesNerfPerc)/100)
				if(src.AngerMax)
					var/a=1
					if(HasCalmAnger())
						a=src.AngerMax
						if((src.AnsatsukenAscension=="Chikara"&&src.StyleActive=="Ansatsuken"))
							a=max(src.AngerMax,2)
						if(src.HasAngerThreshold())
							if(a<src.GetAngerThreshold())
								a=src.GetAngerThreshold()
						if(src.AngerMult>1)
							var/ang=a-1//Usable anger
							var/mult=ang*src.AngerMult
							a=mult+1
					else if(Anger&&!src.HasNoAnger())
						a=Anger
						if(src.AngerMult>1)
							var/ang=a-1//Usable anger
							var/mult=ang*src.AngerMult
							a=mult+1
						if(src.HasAngerThreshold())
							if(a<src.GetAngerThreshold())
								a=src.GetAngerThreshold()
						if(src.DefianceCounter)
							a+=src.DefianceCounter*0.05
					if(src.CyberCancel>0 && !isRace(ANDROID))
						var/ang=a-1//Usable anger.
						var/cancel=ang*src.CyberCancel//1 Cyber Cancel = all of usable anger.
						a-=cancel//take the anger away.
						if(a<1)//Only nerf anger.
							a=1
			/*					if(src.PhylacteryNerf)
						a-=(a*src.PhylacteryNerf)*/
					if(a<=0)
						a=0.01
					Ratio*=a

			//sneaky
			if(src.PowerInvisible)
				Ratio*=src.PowerInvisible
			if(src.PowerBoost)
				Ratio*=src.PowerBoost

			if(isRace(SAIYAN)&&transActive&&ActiveBuff)
				if(race.transformations[transActive].mastery==100)
					Ratio *= 1 + (0.15 * transActive)

			if(src.Target)
				if(ismob(src.Target))
					if(src.HasMirrorStats()&&!src.Target.HasMirrorStats()&&!src.Target.CheckSlotless("Saiyan Soul"))
						Ratio=src.Target.Power/src.Target.GetPowerUpRatio()

		if(passive_handler["Rebel Heart"])
			var/h = ((missingHealth()/glob.REBELHEARTMOD) * passive_handler["Rebel Heart"])/5
			Ratio+=h
		Power=Ratio*GetPowerUpRatio()

		if(Power < 1)
			Power = 1
		if(passive_handler["Hidden Potential"] && Target)
			if(Target.Power > Power)
				Power = Target.Power
				Power*=GetPowerUpRatio()
		var/nerf = GetPowerUpRatio()+EPM > 2.3 ? 1 : 0
		power_display=get_power_tier(0, Power, nerf)

		if(src.Dead&&!src.KeepBody)
			Ratio*=0.5
		else if(src.z==glob.DEATH_LOCATION[3]&&!src.CheckSpecial("Cancer Cloth")&&src.SenseUnlocked<8&&!src.passive_handler.Get("SpiritPower"))
			Ratio*=0.5

		if(src.KO)
			Power*=0.05

		if(GetPowerUpRatio()<=1)
			if(icon_state=="Meditate")
				if(TotalInjury<50&&src.InjuryAnnounce)
					src.InjuryAnnounce=0
				if(Health>10*(1-src.HealthCut)&&src.HealthAnnounce10)
					src.HealthAnnounce10=0
				if(Health>25*(1-src.HealthCut)&&src.HealthAnnounce25)
					src.HealthAnnounce25=0
				if(Health<(100*(1-src.HealthCut))||src.BioArmor<src.BioArmorMax)
					var/Boosted=1
					if(isRace(MAJIN))
						Boosted*=getMajinMedRate()
					Recover("Health",1*Boosted)
					if(isRace(HUMAN))
						Boosted *= 1 + (TotalInjury/50)
					Recover("Injury",1*Boosted)
					if(src.passive_handler.Get("Restoration")||src.Secret=="Zombie")
						Recover("Health",1)
						Recover("Injury",1)
						BPPoisonTimer-=15
				if(src.Energy<src.EnergyMax)
					Recover("Energy",1)
					Recover("Fatigue",1.25)
					if(src.passive_handler.Get("Restoration"))
						Recover("Energy",1)
						Recover("Fatigue",1)
				if(Secret == "Senjutsu")
					if((CheckSlotless("Senjutsu Focus") || CheckSlotless("Sage Mode")) != 0)
						var/boon = Secret == "Senjutsu" ? secretDatum.currentTier : 0
						Recover("Mana",1 + boon)
						if(src.passive_handler.Get("Restoration"))
							Recover("Mana",1)
				else
					if(ManaAmount<((src.ManaMax-src.TotalCapacity)*src.GetManaCapMult()))
						Recover("Mana",1)
					if(src.passive_handler.Get("Restoration"))
						Recover("Mana",1)
				Recover("Capacity",2)
			else
				Recover("Energy",0.5)

		if(src.PowerControl<=25)
			Recover("Fatigue",0.5)
			if(src.ManaDeath)
				ManaAmount-=5*GetManaCapMult()
			else if(src.is_arcane_beast || (isRace(YOKAI) && src.AscensionsAcquired>0 && !src.Mechanized && !src.ActiveBuff))
				if(isRace(YOKAI))
					Recover("Mana", 1*GetManaCapMult())
				else
					Recover("Mana",1)

		if(src.FusionPowered)
			Recover("Energy",1)

		if(src.is_arcane_beast)
			Recover("Mana",1)

		if(src.TotalCapacity>0)
			Recover("Capacity", 1)

		if(src.PoweringUp==1 && !PureRPMode && src.icon_state!="Meditate")

			var/PUGain=src.PUSpeedModifier

			if(src.HasPULock())
				PUGain=0

			if(!src.HasHealthPU())
				PUGain*=src.GetRecov(10)
			else
				PUGain*=src.GetRecov(10)

			if(src.Kaioken)
				PUGain=0
				src.PoweringUp=0

			if(src.HasKiControlMastery())
				if(src.transActive())
					if(src.race.transformations[transActive].mastery<50)
						PUGain*=1+(src.GetKiControlMastery())/2
					else if(src.race.transformations[transActive].mastery>=100)
						PUGain*=2+(src.GetKiControlMastery())
				else
					PUGain*=1+(src.GetKiControlMastery())
			src.PowerControl+=PUGain

			var/PUThreshold=150
/*
			if(src.Race=="Changeling"&&src.transActive()==4)
				PUThreshold+=50
*/
			if(src.PowerControl>=PUThreshold)
				if(!src.ActiveBuff || (src.ActiveBuff.BuffName == "Soul Resonance" && !ActiveBuff.PULock))
					src.Auraz("Remove")
/*					if(src.Race!="Changeling"||(src.Race=="Changeling"&&src.transActive()==4))*/
					for(var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC in src)
						if(!src.BuffOn(KC))
							src.UseBuff(KC)
							break
/*					else
						if(src.transActive()==3)
							if(src.Class=="Prodigy")
								for(var/obj/Skills/Buffs/SpecialBuffs/OneHundredPercentPower/FF in src)
									if(!src.BuffOn(FF))
										src.UseBuff(FF)
										break
							else if(src.Class=="Experience")
								for(var/obj/Skills/Buffs/SpecialBuffs/FifthForm/FF in src)
									if(!src.BuffOn(FF))
										src.UseBuff(FF)
										break*/
				src.PowerControl=PUThreshold
				src.PoweringUp=0
			if(src.Energy<=30&&!src.PUUnlimited)
				src.Auraz("Remove")
				src<<"You are too tired to power up."
				src.PoweringUp=0
				if(isRace(SAIYAN)||isRace(HALFSAIYAN))
					if(src.transActive()>0)
						var/Skip=0
						if(src.race.transformations[transActive].mastery>=25)
							Skip=1
						if(src.HasNoRevert())
							Skip=1
						if(!Skip)
							Revert()
				src.PowerControl=100
				src.LoseEnergy(30)

		//Beyond 100% Drain
		if(!KO && src.PowerControl>=100 && src.PoweringUp && !src.PureRPMode)
			if(src.Energy<=30&&!src.PUUnlimited)
				src.PoweringUp=0
				src.Auraz("Remove")
				src<<"You are too tired to power up."
				if(isRace(SAIYAN)||isRace(HALFSAIYAN))
					if(src.transActive>0)
						var/Skip=0
						if(src.race.transformations[transActive].mastery>=25)
							Skip=1
						if(src.HasNoRevert())
							Skip=1
						if(!Skip)
							Revert()
				src.PowerControl=100
				src.LoseEnergy(30)


			var/PowerDrain = 1 / PUDrainReduction

			if(src.PowerControl<=src.PUEffortless)
				PowerDrain = 0
			/*if(src.Race=="Changeling")
				PowerDrain /= 7.5*/

			if(!src.PUUnlimited)
				if(passive_handler.Get("ManaPU"))
					src.LoseMana(1*PowerDrain*glob.WorldPUDrain)
				else
					src.LoseEnergy(2*PowerDrain*glob.WorldPUDrain)


mob/proc/Update_Stat_Labels()
	set waitfor=0
	if(!client) return
	if(!src.ha)
		var/ManaMessage="%"
		if(round(TotalInjury))
			src<<output("Health: [round(Health)+round(VaizardHealth)+round(BioArmor)] (Injuries:[round(TotalInjury)]%)", "BarHealth")
		else
			src<<output("Health: [round(Health)+round(VaizardHealth)+round(BioArmor)]%", "BarHealth")
		if(round(TotalFatigue))
			src<<output("Energy: [round((Energy/EnergyMax)*100)] (Fatigue:[round(TotalFatigue)]%)","BarEnergy")
		else
			src<<output("Energy: [round((Energy/EnergyMax)*100)]%","BarEnergy")
		if(round(TotalCapacity))
			ManaMessage=" (Capacity:[100-round(TotalCapacity)]%)"

		if(Saga && Saga=="Ansatsuken"&&src.UsingAnsatsuken())
			src<<output("SUPER: [round(ManaAmount/ManaMax*100)]","BarMana")
		if(SagaLevel>1&&Saga=="Path of a Hero: Rebirth")
			src<<output("ACT: [round(ManaAmount/ManaMax*100)]","BarMana")
		else if(src.HasMechanized())
			src<<output("Battery: [round(ManaAmount/ManaMax*100)]","BarMana")
		else if(passive_handler["RenameMana"])
			src<<output("[passive_handler["RenameMana"]]: [round(ManaAmount/ManaMax*100)]","BarMana")
		else
			src<<output("Mana: [round((ManaAmount/100)*100)][ManaMessage]","BarMana")
		if(!src.Kaioken)
			if(src.PoweringUp)
				src<<output("Power: [round((Energy/EnergyMax)*100)*round(src.GetPowerUpRatioVisble(), 0.01)]% (+)","BarPower")
			else if(src.PowerControl<100)
				src<<output("Power: [round((Energy/EnergyMax)*100)*round(src.GetPowerUpRatioVisble(), 0.01)]% (-)","BarPower")
			else
				src<<output("Power: [round((Energy/EnergyMax)*100)*round(src.GetPowerUpRatioVisble(), 0.01)]%","BarPower")
		else
			if(src.PoweringUp)
				src<<output("Power: [round((100/EnergyMax)*100)*round(src.GetPowerUpRatioVisble(), 0.01)*src.KaiokenBP]% (+)","BarPower")
			else if(src.PowerControl<100)
				src<<output("Power: [round((100/EnergyMax)*100)*round(src.GetPowerUpRatioVisble(), 0.01)*src.KaiokenBP]% (-)","BarPower")
			else
				src<<output("Power: [round((100/EnergyMax)*100)*round(src.GetPowerUpRatioVisble(), 0.01)*src.KaiokenBP]%","BarPower")
		if(src.Poison>0)
			winshow(src, "BarPoison",1)
			src<<output("POI: [round(Poison, 1)]","BarPoison")
		else
			winshow(src, "BarPoison",0)
		if(src.Burn>0)
			winshow(src, "BarBurning",1)
			src<<output("BUR: [round(Burn, 1)]","BarBurning")
		else
			winshow(src, "BarBurning",0)
		if(src.Shatter>0)
			winshow(src, "BarBreak",1)
			src<<output("SHT: [round(Shatter, 1)]","BarBreak")
		else
			winshow(src, "BarBreak",0)
		if(src.Shock>0)
			winshow(src, "BarShock",1)
			src<<output("SHK: [round(Shock, 1)]","BarShock")
		else
			winshow(src, "BarShock",0)
		if(src.Slow>0)
			winshow(src, "BarSlow",1)
			src<<output("CHL: [round(Slow, 1)]","BarSlow")
		else
			winshow(src, "BarSlow",0)
		if(src.Sheared>0)
			winshow(src, "BarPotion",1)
			src<<output("SHR: [round(Sheared, 1)]","BarPotion")
		else
			winshow(src, "BarPotion",0)
		if(src.PureRPMode==1)
			winshow(src, "BarRP",1)
			src<<output("RP MODE","BarRP")
		else
			winshow(src, "BarRP",0)
		if(src.WoundIntent==1||src.Lethal>=1)
			if(src.Lethal==1)
				winshow(src, "BarWound",1)
				src<<output("LETHAL","BarWound")
			else
				winshow(src, "BarWound",1)
				src<<output("INJURE","BarWound")
		else
			winshow(src, "BarWound",0)
		if(src.StyleActive)
			winshow(src, "StyleLabel",1)
			winshow(src, "StanceLabel",1)
			src<<output("[src.StyleActive]","StyleLabel")
			src<<output("[src.StanceActive]","StanceLabel")
			if(src.StyleBuff)
				winshow(src, "TensionLabel",1)
				winshow(src, "TensionBar",1)

				var/maxTension = 100
				if(passive_handler.Get("Conductor"))
					maxTension = max(glob.MIN_TENSION, maxTension - passive_handler.Get("Conductor"))
					winset(src, "TensionBar", "value=[(100-maxTension) + src.Tension]")
				else
					winset(src, "TensionBar", "value=[src.Tension]")



				if(src.Tension>=maxTension)
					winset(src, "TensionBar", "bar-color='#F00'")
					winset(src, "TensionLabel", "text-color='#F00'")
					src << output("FINISHER!!!", "TensionLabel")
				else
					winset(src, "TensionBar", "bar-color='#F0F'")
					winset(src, "TensionLabel", "text-color='#F0F'")
					src << output("TENSION", "TensionLabel")
			if(client.getPref("oldZanzo"))
				winshow(src, "MovementBar", 1)
				winshow(src, "MovementLabel", 1)
				if(src.MovementCharges<1)
					winset(src, "MovementBar", "bar-color=#666")
					winset(src, "MovementLabel", "text-color=#666")
				else if(src.MovementCharges<2)
					winset(src, "MovementBar", "bar-color=#0F0")
					winset(src, "MovementLabel","text-color=#0F0")
				else if(src.MovementCharges<3)
					winset(src, "MovementBar", "bar-color=#F00")
					winset(src, "MovementLabel", "text-color=#F00")
				else
					winset(src, "MovementBar", "bar-color=#FF0")
					winset(src, "MovementLabel", "text-color=#FF0")
				winset(src, "MovementBar", "value=[(src.MovementCharges-round(src.MovementCharges))*100]")
				winset(src, "MovementLabel", "text=[round(src.MovementCharges)]")
		else
			winshow(src, "StyleLabel",0)
			winshow(src, "StanceLabel",0)
			winshow(src, "TensionLabel",0)
			winshow(src, "TensionBar",0)
			winshow(src, "MovementBar", 0)
			winshow(src, "MovementLabel", 0)
	if(Secret)
		switch(Secret)
			if("Werewolf")
				if(CheckSlotless("New Moon Form"))
					var/SecretInfomation/Werewolf/s = secretDatum
					var/maxHunger = s:getHungerLimit()
					var/currentHunger = secretDatum.secretVariable["Hunger Satiation"]
					if(currentHunger > 0)
						winshow(src, "Hunger", 1)
						winset(src, "Hunger", "value=[round(currentHunger/maxHunger*100)]")
					else
						winshow(src, "Hunger", 0)
			if("Eldritch")
				var/SecretInfomation/Eldritch/s = secretDatum
				var/maxMadness = s:getMadnessLimit(src)
				var/currentMadness = secretDatum.secretVariable["Madness"]
				if(currentMadness > 0)
					winshow(src, "Hunger", 1)
					winset(src, "Hunger", "value=[round(currentMadness/maxMadness*100)]")
				else
					winshow(src,"Hunger", 0)
	if(isRace(DEMON))
		if(Corruption > 0)
			winshow(src, "Hunger", 1)
			winset(src, "Hunger", "value=[round(Corruption/MaxCorruption*100)]")
		else
			winshow(src,"Hunger", 0)
	if(SpecialBuff&&SpecialBuff.BuffName == "Gluttony")
		if(SpecialBuff:gluttonStorage>0)
			winshow(src, "Storage",1)
			winshow(src, "StorageLabel",1)
			winset(src, "Storage", "value=[round(SpecialBuff:gluttonStorage/SpecialBuff:maxGluttonStorage*100)]")
			winset(src, "StorageLabel", "text=[round(SpecialBuff:gluttonStorage)]")
		else
			winshow(src, "Storage",0)
			winshow(src, "StorageLabel",0)

	if(src.Oxygen!=src.OxygenMax)
		winshow(src, "BarOxygen",1)
		src<<output("OXY: [round(Oxygen, 1)]","BarOxygen")
	else
		winshow(src, "BarOxygen",0)

mob/var/tmp/ha=0

mob/verb/SwitchShit()
	set hidden=1
	usr.ha=0
	for(var/e in list("Health","Energy","Mana","Power"))
		winset(src,"Bar[e]","is-visible=true")

mob/proc/Get_Sense_Reading(mob/A)

	var/Power=round(100*(Get_Scouter_Reading(A)/Get_Scouter_Reading(src)))
	if(A.passive_handler.Get("PowerAppearance"))
		Power = 0
	switch(Power)
		if(0 to 10)
			. = "Inconsequential"
		if(11 to 50)
			. = "Much Weaker"
		if(50 to 90)
			. = "Weaker"
		if(90 to 110)
			. = "Equal"
		if(110 to 200)
			. = "Stronger"
		if(200 to 500)
			. = "Much Stronger"
		if(500 to 1#INF)
			. = "Massively Stronger"
	if(A.Health<=25)
		. +=" (Disturbed)"
	else if(A.KO&&A.MortallyWounded)
		. +=" (Fading)"

mob/proc/Get_Scouter_Reading(mob/B)
	var/Ratio=B.EnergyUniqueness

	var/EPM=B.Power_Multiplier//effective power multiplier
	if(B.PowerEroded)
		EPM-=B.PowerEroded
	if(B.NanoBoost&&B.Health<25)
		EPM+=0.25
	if(B.isRace(MAKYO))
		if(B.ActiveBuff&&!B.HasMechanized())
			EPM*=1+(0.5*B.AscensionsAcquired) * 7
	if(EPM<=0)
		EPM=0.1
	if(src.DemonicPower())
		var/pot=src.get_potential()
		EPM+=pot/10
	// here we can make demonic power fake visual bp


	Ratio*=EPM

	if(B.HasMythical())
		Ratio*= 1 + (2*B.HasMythical())
	if(B.HasHellPower())
		Ratio*=(B.GetHellScaling() * 1500)
	Ratio*=B.Base() * 100
	temp_potential_power(B)//get them potential powers
	Ratio*=B.potential_power_mult

	//BODY CONDITION ADJUSTMENTS
	if(!B.passive_handler.Get("Piloting"))
		if(!B.passive_handler.Get("Possessive"))
			if(!B.Timeless)
				var/AgeRate=1

				if((B.EraBody=="Child"||B.EraBody=="Youth")&&B.Aged)
					AgeRate=1
				else if(B.EraBody=="Child"||B.EraBody=="Senile")
					if(B.ParasiteCrest())
						AgeRate=0.5
					else
						AgeRate=0.4
				else if(B.EraBody=="Youth"||B.EraBody=="Elder")
					if(B.ParasiteCrest())
						AgeRate=0.5
					else
						AgeRate=0.8
				else
					AgeRate=1

				if(B.isRace(YOKAI))
					if(B.EraBody=="Elder"||(B.EraBody=="Adult"&&B.Aged))
						AgeRate=1.25
				if(B.isRace(HALFSAIYAN)&&B.Anger)
					AgeRate=1
				Ratio*=AgeRate
			if(locate(/obj/Seal/Power_Seal, B))
				Ratio*=0.5
			if(B.CanLoseVitalBP())
				Ratio*=1+(B.GetHealthBPMult()+B.GetEnergyBPMult())
			if(B.JaganPowerNerf)
				Ratio*=B.JaganPowerNerf
			if(B.BPPoison)
				if(B.Secret=="Zombie"||B.Doped||(B.SagaLevel>=5&&B.AnsatsukenAscension=="Chikara"))
					Ratio*=1
				else
					Ratio*=B.BPPoison
			if(B.Maimed)
				var/Ignore=B.HasMaimMastery()
				if(Ignore || isRace(CHANGELING))
					Ratio*=1
				else
					B.MaimsOutstanding=max(B.Maimed-(0.5*B.GetProsthetics()), 0)
					Ratio*=(1-(0.2*B.MaimsOutstanding))
			if(B.HasWeights())
				Ratio*=0.75
			if(B.Roided)
				Ratio*=1.15
			if(B.OverClockNerf)
				Ratio*=(1-B.OverClockNerf)
			if(B.GatesNerfPerc)
				Ratio*=((100-B.GatesNerfPerc)/100)
			if(B.AngerMax)
				var/a=1
				if(B.HasCalmAnger())
					a=B.AngerMax
					if(B.AngerMult>1)
						var/ang=a-1//Usable anger
						var/mult=ang*B.AngerMult
						a=mult+1
				else if(B.Anger&&!B.HasNoAnger()&&!B.HiddenAnger)
					a=B.Anger
					if(B.AngerMult>1)
						var/ang=a-1//Usable anger
						var/mult=ang*B.AngerMult
						a=mult+1
					if(B.HasAngerThreshold())
						if(a<B.GetAngerThreshold())
							a=B.GetAngerThreshold()
					if(B.DefianceCounter)
						a+=B.DefianceCounter*0.25
				if(B.CyberCancel>0)
					var/ang=a-1//Usable anger.
					var/cancel=ang*B.CyberCancel//1 Cyber Cancel = all of usable anger.
					a-=cancel//take the anger away.
					if(a<1)//Only nerf anger.
						a=1
				if(a<=0)
					a=0.01
				Ratio*=a

		if(B.HasIntimidation()&&B.PowerControl>25)
			Ratio*=B.GetIntimidation()
		if(B.PowerBoost)
			Ratio*=B.PowerBoost
		if(B.TarotFate=="The Sun")
			Ratio*=1.5

	Ratio*=B.GetPowerUpRatioVisble()

	if(B.Dead&&!B.KeepBody)
		Ratio*=0.5
	else if(B.z==glob.DEATH_LOCATION[3]&&!B.CheckActive("Cancer Cloth")&&B.SenseUnlocked<8&&!B.passive_handler.Get("SpiritPower"))
		Ratio*=0.1

	var/Reading=Ratio
	if(passive_handler.Get("PowerAppearance"))
		Reading = passive_handler.Get("PowerAppearance")
	if(B.KO)
		Reading*=0.05
	if(Reading<1)
		Reading=1
	return Reading