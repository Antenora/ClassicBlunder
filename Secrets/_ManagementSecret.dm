#define WW_HUNGER_MAX 250
#define WW_REDUCTION_PER_TIER 25

#define MADNESS_MAX 100
#define MADNESS_ADD_PER_TIER 25

#define VALID_SECRET_LIST list("Jagan Eye", "Haki", "Hamon", "Vampire", "Werewolf", "Heavenly Restriction", "Senjutsu", "Shin",\
"Ultra Instinct", "Zombie", "Necromancy", "Eldritch", "Eldritch (Shrouded)", "Eldritch (Reflected)", "Black Flash", "Spiral", "Heavenborn")
#define RACIAL_SECRETS list("Eldritch (Shrouded)", "Eldritch (Reflected)")
#define RARE_LIST list(MAKAIOSHIN, MAJIN, DEMON, ANGEL, ELDRITCH, DEMIFIEND)

//thank you hadoje
/mob/var/SecretInformation/secretDatum = new()

/mob/proc/
	hasSecret(secretName)
		if(!secretName) return 0;
		if(!Secret) return 0;
		if(!(secretName in VALID_SECRET_LIST))
			liveDebugMsg("[src] called hasSecret proc with the argument [secretName]. That's not a valid secret!");
			src << "[secretName] is not a valid secret name for the hasSecret proc. Admins have been notified of the error, but you can throw it in the Discord bug channel too.";
			return 0;
		if(!(Secret in VALID_SECRET_LIST))
			admins << "<font size=+1><b>DEBUG:</b></font size> [src] called hasSecret proc when their own Secret variable was marked as [Secret]. That's not a valid secret!";
			src << "Your current Secret variable, [Secret], is not in the valid secret list. Admins have been notified of the error, but you can admin help over it.";
		if(secretName != Secret) return 0;//if secretName (argument) does not match Secret (mob variable) then say Nope.
		return 1;


/mob/Admin4/verb/editSecretDatum(mob/p in players)
	if(p.secretDatum)
		var/atom/A = p.secretDatum
		var/Edit="<html><Edit><body bgcolor=#000000 text=#339999 link=#99FFFF>"
		var/list/B=new
		Edit+="[A]<br>[A.type]"
		Edit+="<table width=10%>"
		for(var/C in A.vars) B+=C
		B.Remove("Package","bound_x","bound_y","step_x","step_y","Admin","Profile", "GimmickDesc", "NoVoid", "BaseProfile", "Form1Profile", "Form2Profile", "Form3Profile", "Form4Profile", "Form5Profile")
		for(var/C in B)
			Edit+="<td><a href=byond://?src=\ref[A];action=edit;var=[C]>"
			Edit+=C
			Edit+="<td>[Value(A.vars[C])]</td></tr>"
		Edit += "</html>"
		usr<<browse(Edit,"window=[A];size=450x600")

/mob/Admin3/verb/TierSecretUp(mob/p in players)
	if(p.secretDatum)
		var/confirm = alert(usr, "Are you sure you want to tier up [p]'s [p.secretDatum.name]?",,"Yes","No")
		if(confirm == "No") return
		p.secretDatum.tierUp(p.secretDatum.currentTier+1, p)

/mob/proc/getSecretLevel()
	if(secretDatum)
		return secretDatum.currentTier
	return 0


SecretInformation
	var
		name
		lastCheckedTier = 1
		currentTier = 1
		maxTier = 5
		list/givenSkills = list()
		secretVariable = list() // "Ripple" = 1 for ripple, or say "BloodPower" = 1 for vampire, etc
		list/givenVariables = list()
		potentialRecieved = -1
		nextTierUp = 999
		tierUnlocked = 3 // always allow them to auto to tier 3
	proc/init(mob/p)
		potentialRecieved = glob.progress.DaysOfWipe*glob.progress.PotentialDaily
		nextTierUp = 3
		applySecret(p)


	proc/tierUp(num, mob/p)
		while(currentTier < num)
			currentTier++;
			applySecret(p);
		lastCheckedTier = currentTier
	proc/tierDown(num)
		if(currentTier > 1)
			currentTier -= num
	proc/giveSkills(mob/p)
		for(var/skill in givenSkills)
			p.AddSkill(new skill)
	proc/giveVariables(mob/p)
		for(var/variable in givenVariables)
			p.passive_handler.Set(variable,1)
			p.vars[variable] += 1

	proc/applySecret(mob/p)
		if(!p) return;
		admins << "[p] has been given T[currentTier] [p.secretDatum.name]."

	JaganEye
		name = "Jagan Eye"
		givenSkills = list("/obj/Skills/Buffs/SpecialBuffs/Cursed/Jagan_Eye", "/obj/Skills/Utility/Telepathy", "/obj/Skills/Telekinesis" )
		givenVariables = list("EnhancedHearing", "EnhancedSmell")

		applySecret(mob/p)
			switch(currentTier)
				if(1)
					p << "You have awakened the power of the Jagan Eye!"
					giveSkills(p)
					giveVariables(p)
					p.JaganPowerNerf = 0.5
					nextTierUp = 3;
				if(2)
					p << "Your Jagan Eye has grown stronger!"
					p.JaganPowerNerf = 0.7
					nextTierUp = 7
					// add expert here
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Jagan_Expert, p.Buffs))
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Jagan_Expert)
						p << "You can push the limits of the Jagan Eye for a time to regain lost power!"
					if(!locate(/obj/Skills/Projectile/Beams/Big/Jagan/Dragon_of_the_Darkness_Flame, p.Projectiles))
						p.AddSkill(new/obj/Skills/Projectile/Beams/Big/Jagan/Dragon_of_the_Darkness_Flame)
						p << "Through disciplining your Jagan Eye, you've developed the Dragon of the Darkness Flame!"
						p << "It is a reckless attack and will sacrifice the limb used to perform it."
				if(3)
					p << "Your Jagan Eye has grown stronger!"
					p.JaganPowerNerf = 0.85
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/SwordOfDarknessFlame, p.Buffs))
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/SwordOfDarknessFlame)
					for(var/obj/Skills/Projectile/Beams/Big/Jagan/Dragon_of_the_Darkness_Flame/DF in p.Projectiles)
						if(DF.MaimCost)
							DF.MaimCost=0
							p << "Through refining the Jagan Eye, your control over darkness flame grows!"
					nextTierUp = 7
				if(4)
					p << "Your Jagan Eye has grown stronger!"
					p.JaganPowerNerf = 0
					for(var/obj/Skills/Projectile/Beams/Big/Jagan/Dragon_of_the_Darkness_Flame/DF in p.Projectiles)
						if(DF.MaimCost||DF.WoundCost)
							DF.WoundCost=0
							p << "Through mastering your Jagan Eye, you can now call on the Dragon with absolute control!"
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Darkness_Dragon_Master, p))
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Darkness_Dragon_Master)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Jagan_Expert/je in usr)
						del je
					nextTierUp = 999
			..(p);


	Haki
		name = "Haki"
		givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armament", "/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Observation", "/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armor_Lite", \
		"/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armor", "/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Shield_Lite", "/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Shield", \
		"/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Relax_Lite", "/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Relax", "/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Future_Flash_Lite", \
		"/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Future_Flash")
		secretVariable = list("HakiSpecialization", "HakiCounterArmament", "HakiCounterObservation", "ConquerorsHaki")
		proc/conQHaki(mob/p)
		/*	if(!(p.race.name in glob.CONQ_HAKI_RACES))
				return 0*/
			if(prob((currentTier**glob.CONQ_HAKI_CHANCE)+4) && secretVariable["ConquerorsHaki"] != 1)
				unlockConquerorsHaki(p)
		proc/unlockConquerorsHaki(mob/p)//god i want to stick this shit in a blender
			p << "You have the qualities of a King..."
			p << "You have awakened the power of Conqueror's Haki!"
			secretVariable["ConquerorsHaki"] = 1
			p.AddSkill(new/obj/Skills/AutoHit/Haki/Conquerors_Haki)
			p.AddSkill(new/obj/Skills/Queue/Haki/Kings_Infusion)
			p << "You can now infuse your Fist with the power of your Conquerer's Will!"
		proc/conqPaths(mob/p)
			if(secretVariable["ConquerorsHaki"] == 1)
				switch(currentTier)
					if(4)
						var/path = input(p, "Which path of Conqueror's Haki do you wish to follow?", "Conqueror's Haki") in list("Unarmed", "Armed")
						if(path == "Unarmed")
							p.AddSkill(new/obj/Skills/Queue/Haki/Galaxy_Impact)
						else
							p.AddSkill(new/obj/Skills/Projectile/Divine_Departure)
		applySecret(mob/p)
			switch(currentTier)
				if(1)
					p << "You have awakened the power of Haki!"
					giveSkills(p)
					giveVariables(p)
					conQHaki(p)
				if(2)
					p << "Your Haki has grown stronger!"
					conQHaki(p)
					conqPaths(p)
					if(!secretVariable["HakiSpecialization"])
						var/path = input(p, "Which path of Haki do you wish to follow?", "Haki") in list("Armament", "Observation")
						secretVariable["HakiSpecialization"] = path
					nextTierUp = 2
				if(3)
					p << "Your Haki has grown stronger!"
					conQHaki(p)
					conqPaths(p)
					nextTierUp = 2
				if(4)
					p << "Your Haki has grown stronger!"
					conQHaki(p)
					conqPaths(p)
					nextTierUp = 4
				if(5)
					p << "Your Haki has grown stronger!"
					conQHaki(p)
					conqPaths(p)
					nextTierUp = 999
			..(p);





	Hamon
		name = "Hamon"
		givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/Ripple/Ripple_Breathing", "/obj/Skills/Buffs/SlotlessBuffs/Ripple/Life_Magnetism_Overdrive", "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Ripple_Enhancement")
		secretVariable = list("Ripple")
		applySecret(mob/p)
			switch(currentTier)
				if(1)
					p << "Your blood's beat is razor sharp...You've awakened the power of the Ripple!"
					giveSkills(p)
					giveVariables(p)
					p.OxygenMax+=50
				if(2)
					p << "Your mastery of the Ripple improves!"
					nextTierUp = 2
					p.OxygenMax+=50
				if(3)
					p << "Your mastery of the Ripple improves!"
					nextTierUp = 2
					p.OxygenMax+=50
				if(4)
					p << "Your mastery of the Ripple improves!"
					nextTierUp = 4
					p.OxygenMax+=50
				if(5)
					p << "Your mastery of the Ripple has reached its peak."
					nextTierUp = 999
					p.OxygenMax+=50
			..(p);


	Vampire
		name = "Vampire"
		givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Vampire/Rotshreck","/obj/Skills/Buffs/SlotlessBuffs/Vampire/Wassail", "/obj/Skills/Buffs/SlotlessBuffs/Regeneration", "/obj/Skills/Buffs/SlotlessBuffs/Vampire/Vampire")
		givenVariables = list("EnhancedHearing", "EnhancedSmell", "Timeless")
		secretVariable = list("BloodPower" = 1, "LastBloodGain" = 0 )
		proc/bloodThreshold(tier)
			// for 1-2 = 1, 3-4 = 2, 5 = 3
			return round((tier/2),1)
		proc/getBloodPowerRatio()
			return secretVariable["BloodPower"] * 0.25
			// 25% per BloodPower
		proc/getHungerRatio()
			// Hunger ratio will be how far away their bloodpower is from their current normal
			// at t1-2 it is 1, at t3-4 it is 2 and at t5 it is 3
			// so if they have 2 bloodpower and are at t1-2, it will be 0, anything over their normal is nothing
			var/threshold = bloodThreshold(currentTier)
			var/ratio = secretVariable["BloodPower"]/threshold
			if(ratio>=1)
				ratio = 1
			return 1 - ratio
		proc/gainBloodPower(amount)
			// the thing that passes is going to be the straight damage
			var/blood = amount / 3
			if(blood <= 0.1)
				blood = 0.1
			secretVariable["BloodPower"] += blood
			if(secretVariable["BloodPower"] >= 4)
				secretVariable["BloodPower"] = 4
			secretVariable["LastBloodGain"] = world.time
		proc/drainBlood()
			if(secretVariable["BloodPower"] <= 0)
				return
			var/blood = secretVariable["BloodPower"] * 0.1
			if(blood <= 0.1)
				blood = 0.1
			secretVariable["BloodPower"] -= blood
			if(secretVariable["BloodPower"] <= 0)
				secretVariable["BloodPower"] = 0
		applySecret(mob/p)
			if(!p.vampireBlood)
				p.vampireBlood = new(p, 6, 184)
			switch(currentTier)
				if(1)
					p << "You have willingly consumed blood, forsaking your humanity...You've awakened the power of a Vampire!"
					giveSkills(p)
					giveVariables(p)
				if(2)
					p << "Your bloodlust is growing...You've become a more powerful Vampire!"
					nextTierUp = 4
					var/obj/Skills/Buffs/SlotlessBuffs/Regeneration/r = new()
					r = locate() in p
					if(!r)
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Regeneration)
						p << "Your ability to regeneration can restore lost limbs."
				if(3)
					p << "Your mastery of the blood curse is coming close to its peak..."
					nextTierUp = 3
					if(p.RecovMod < 3)
						p.RecovMod = 3
						p<<"Your innate regeneration has increased!"
				if(4)
					p << "Your prowess as a Vampire knows no limits"
					nextTierUp = 4
				if(5)
					p << "You have forgotten what it means to be mortal..."
					nextTierUp = 999
			..(p);

	EldritchShrouded
		name = "Eldritch (Shrouded)"
		var/list/ShroudedPassives=list();
		var/ShroudedOrigin;//assigned at t1
		var/ShroudedSubtype;//assigned at t2
		var/ShroudedMastery;//assigned at t5
		applySecret(mob/p)
			p << "Your Shrouded origin bubbles to the surface; [currentTier] Step\s towards the road to Assimilation [currentTier == 1 ? "has" : "have"] been taken..."
			//1, 2, and 5 upgrade your "Origin" style enhancements
			//I'm not being lazy, I'm being ~efficient~
			if(currentTier==3)
				p.findOrAddSkill(/obj/Skills/Utility/Tether)
				p << "Your Shroud learns to link itself with another body for ease of existence! (Tether)"
			if(currentTier==4)
				p << "When you Fade into Shadow, your existence is further nullified (Upgrades to Fade into Shadow movement)"
				p << "Your All Seeing Eyes can pierce any veils within this reality! (Restrictions on All Seeing Eyes removed)"
			..(p);

	EldritchReflected
		name = "Eldritch (Reflected)"
		givenSkills = list("/obj/Skills/Utility/Offer_Pact", "/obj/Skills/Utility/Revoke_Pact");
		applySecret(mob/p)
			p << "You reflect a greater portion of your True Essence! [currentTier] Shards have been collected..."
			switch(currentTier)
				if(2)
					p.findOrAddSkill(/obj/Skills/Utility/Refresh);
					p << "You remember how to Refresh someone and ignore the time their body is taxed! (Refresh)"
					p.findOrAddSkill(/obj/Skills/Utility/Eldritch_Domain);
					p << "You remember how to expand your Eldritch Domain and empower yourself and your Coven! (Eldritch Domain)";
				if(3)
					p.findOrAddSkill(/obj/Skills/Utility/Altered_Nature);
					p << "You remember how to weave the threads of Fate between your Coven! (Altered Nature)"
					p.findOrAddSkill(/obj/Skills/Utility/Bared_Souls);
					p << "You remember how to bare your true nature to a Coven member! (Bared Souls)"
				if(4)
					p.findOrAddSkill(/obj/Skills/Utility/Glimpse_Inside);
					p << "You remember how to reach inside a Coven member and bestow Eldritch secrets upon them! (Glimpse Inside)"
					p.findOrAddSkill(/obj/Skills/Utility/Shared_Dreaming);
					p << "You remember how to instantly teleport to a member of your Coven! (Shared Dreaming)";
				if(5)
					p.findOrAddSkill(/obj/Skills/Utility/With_You_In_Darkness);
					p << "You remember how to bestow your dark protection upon a Coven member! (With You in Darkness)"
					p.findOrAddSkill(/obj/Skills/Utility/Observe);
					p << "...you can observe."
				if(6)
					p.findOrAddSkill(/obj/Skills/Utility/Reclamation)
					p << "You remember how to take it all away, stealing your threads back to yourself for your own gain! (Reclamation)"
			..(p);

	Eldritch
		name = "Eldritch"
		secretVariable = list("Madness" = 0, "Madness Active" = 0, "Lunatic Mode" = 0, "Power From Blood" = 0, "Blood Stock" = 0, "Resource Stock" = 0)
		givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/Eldritch/True_Form")
		applySecret(mob/p)
			p << "You have awakened the [currentTier]\th tier of Eldritch secrets!";
			switch(currentTier)
				if(1)
					giveSkills(p)
			..(p);
		proc/noMobCheck(mob/p, procName)
			if(!p)
				DEBUGMSG("Eldritch (Secret) [procName] does not have a mob argument.");
				return 1;
			return 0;

		//todo this should hopefully be able to be removed between wipes
		//should only trigger once
		proc/updateSecretVariables(mob/p)
			var/SecretInformation/Eldritch/e = p.secretDatum;
			e.secretVariable["Power From Blood"] = 0;
			e.secretVariable["Lunatic Mode"] = 0;
			e.secretVariable["Blood Stock"] = 0;
			e.secretVariable["Resource Stock"] = 0;

		proc/getPowerFromBlood(mob/p)
			if(src.noMobCheck(p, "getPowerFromBlood")) return
			addBloodStock(p, 100);
			p.secretDatum.secretVariable["Power From Blood"]++;
			p << "<font color='red'>You gain an unnatural level of proficiency in the magickal arts.</font color>";
			p << "<font color='red'>Your Blood Stock is 100% charged by the atrocity you've inflicted.</font color>";

		#define ELDRITCH_STOCK_SECRET_LIMIT 50
		#define ELDRITCH_STOCK_RACIAL_LIMIT 100
		#define LUNATIC_MODE_MAX_TIMER 180

		proc/EndLunaticMode(mob/p)
			if(src.noMobCheck(p, "EndLunaticMode")) return
			p << "Your sacrificial stock has run its course; <b>Lunatic Mode is no longer active</b>."
			src.secretVariable["Lunatic Mode"] = 0;

		proc/useStock(mob/p)
			if(src.noMobCheck(p, "useStock")) return
			var/limit = ELDRITCH_STOCK_SECRET_LIMIT
			if(p.isRace(ELDRITCH))
				limit = ELDRITCH_STOCK_RACIAL_LIMIT;
			var/stockUsing = p.secretDatum.secretVariable["Resource Stock"];
			src.subResourceStock(p, p.secretDatum.secretVariable["Resource Stock"]);
			if(stockUsing < limit)
				stockUsing += p.secretDatum.secretVariable["Blood Stock"];
				src.subBloodStock(p, p.secretDatum.secretVariable["Blood Stock"]);
			if(stockUsing > limit)
				src.addBloodStock(p, (stockUsing - limit));//add the remainder back
				stockUsing = limit;//use only up to the limit
			p.secretDatum.secretVariable["Lunatic Mode"] = (LUNATIC_MODE_MAX_TIMER * (stockUsing / 100));//Acts a timer for Lunatic Mode
			p.LunaticModeEffect();

		proc/addBloodStock(mob/p, val)
			if(src.noMobCheck(p, "addBloodStock")) return
			p.secretDatum.secretVariable["Blood Stock"] += val;
			src.capBloodStock(p);
		proc/subBloodStock(mob/p, val)
			if(src.noMobCheck(p, "subBloodStock")) return
			p.secretDatum.secretVariable["Blood Stock"] -= val;
			src.capBloodStock(p);
		proc/capBloodStock(mob/p)
			if(src.noMobCheck(p, "capBloodStock")) return
			var/limit = p.isRace(ELDRITCH) ? ELDRITCH_STOCK_RACIAL_LIMIT : ELDRITCH_STOCK_SECRET_LIMIT;
			p.secretDatum.secretVariable["Blood Stock"] = clamp(p.secretDatum.secretVariable["Blood Stock"], 0, limit);
		proc/addResourceStock(mob/p, val)
			if(src.noMobCheck(p, "addResourceStock")) return
			p.secretDatum.secretVariable["Resource Stock"] += val;
			src.capResourceStock(p);
		proc/subResourceStock(mob/p, val)
			if(src.noMobCheck(p, "subResourceStock")) return
			p.secretDatum.secretVariable["Resource Stock"] -= val
			src.capResourceStock(p);
		proc/capResourceStock(mob/p)
			if(src.noMobCheck(p, "capResourceStock")) return
			var/limit = p.isRace(ELDRITCH) ? ELDRITCH_STOCK_RACIAL_LIMIT : ELDRITCH_STOCK_SECRET_LIMIT;
			p.secretDatum.secretVariable["Resource Stock"] = clamp(p.secretDatum.secretVariable["Resource Stock"], 0, limit);

		proc/getMadnessLimit(mob/p)
			. = MADNESS_MAX + (MADNESS_ADD_PER_TIER * (1+p.AscensionsAcquired))
			if(. <0)
				. = 50
		proc/addMadness(mob/p,amount)
			if(secretVariable["Madness Active"] == 1) return
			if(amount < 0.9)
				amount *= 4
			else if(amount > 1.5)
				amount *= 2
			else
				amount *= 3
			var/tierEffectiveness = (1+p.AscensionsAcquired) * 1.5
			amount *= tierEffectiveness
			if(secretVariable["Madness"] + amount > getMadnessLimit(p))
				secretVariable["Madness"] = getMadnessLimit(p)
			else
				secretVariable["Madness"] += amount

		proc/releaseMadness(mob/user)
			var/tierEffectiveness = glob.racials.MADNESS_DRAIN - (user.AscensionsAcquired/2)
			// LESS = MORE
			if(user.CheckSlotless("True Form"))
				tierEffectiveness = clamp(tierEffectiveness-glob.racials.MADNESS_DRAIN_FORM, 0.5, glob.racials.MADNESS_DRAIN)
			secretVariable["Madness"] -= tierEffectiveness
			if(secretVariable["Madness"] <= 0)
				secretVariable["Madness"] = 0
			user.Update_Stat_Labels()

		proc/setMadness(madnessSet = 0)
			secretVariable["Madness"] = clamp(getMadnessLimit(),madnessSet,0)

		proc/getMadnessBoon()
			return secretVariable["Madness"]/getMadnessLimit()

	Werewolf
		name = "Werewolf"
		givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/Werewolf/New_Moon_Form", "/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Half_Moon_Form", "/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Full_Moon_Form")
		givenVariables = list("Restoration", "EnhancedHearing", "EnhancedSmell", "Timeless")
		secretVariable = list("Hunger Satiation" = 0, "Hunger Active" = 0)
		proc/getHungerLimit(mob/p)
			. = WW_HUNGER_MAX - (WW_REDUCTION_PER_TIER * (currentTier))
			if(. <0)
				. = 50
			else if(. > WW_HUNGER_MAX)
				. = WW_HUNGER_MAX
		proc/addHunger(amount)
			if(secretVariable["Hunger Active"] == 1) return
			if(amount < 0.9)
				amount *= 4
			else if(amount > 1.5)
				amount *= 2
			else
				amount *= 3
			var/tierEffectiveness = currentTier * 1.5
			amount *= tierEffectiveness
			if(secretVariable["Hunger Satiation"] + amount > getHungerLimit())
				secretVariable["Hunger Satiation"] = getHungerLimit()
			else
				secretVariable["Hunger Satiation"] += amount

		proc/releaseHunger()
			if(secretVariable["Hunger Active"] == 0) return
			var/tierEffectiveness = 8 - currentTier
			// LESS = MORE
			secretVariable["Hunger Satiation"] -= tierEffectiveness
			if(secretVariable["Hunger Satiation"] <= 0)
				secretVariable["Hunger Satiation"] = 0
				secretVariable["Hunger Active"] = 0

		proc/getHungerBoon()
			return secretVariable["Hunger Satiation"]/getHungerLimit()

		applySecret(mob/p)
			switch(currentTier)
				if(1)
					p << "You have given into the lunar curse, forsaking your humanity... You've awakened the power of a Werewolf!"
					giveSkills(p)
					giveVariables(p)
					var/obj/Skills/Buffs/SlotlessBuffs/Regeneration/r = new()
					r = locate() in p
					if(!r)
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Regeneration)
						p << "The Moon's energy has granted you the ability to regenerate"
				if(2)
					var/obj/Skills/Buffs/SlotlessBuffs/Regeneration/r = new()
					r = locate() in p
					if(r)
						r.RegenerateLimbs = 1
					p << "You can now restore lost limbs with ease!"
					nextTierUp = 4
				if(3)
					p << "Your mastery of the lunar curse is coming close to its peak..."
					nextTierUp = 3
				if(4)
					p << "Your prowess as a Werewolf knows no limits"
					nextTierUp = 4
				if(5)
					p << "Your mastery of the lunar curse is godly..."
			..(p);

	HeavenlyRestriction
		name = "Heavenly Restriction"
		givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/HeavenlyRestriction/HeavenlyRestriction")
		secretVariable = list("Restrictions" = list(), "Improvements" = list())
		applySecret(mob/p)
			var/list/restriction = pickRestriction(p)
			applySecretVariable(p, restriction, pickImprove(p, restriction))
			admins << "[p] has had their Heavenly Restriction increased."


	SageArts//TODO BETWEEN WIPES: Make this Senjutsu jesus fucking christ
		name = "Senjutsu"
		givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/Senjutsu/Senjutsu_Focus", "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sennin_Mode")
		applySecret(mob/p)
			switch(currentTier)
				if(1)
					p << "Enlightened to the natural order of things, you become capable of drawing on the power of the world!"
					giveSkills(p)
					giveVariables(p)
				if(2)
					p << "Handling natrual energy becomes easier..."
					var/obj/Skills/Queue/Rasengan/r = new()
					r = locate() in p
					if(!r)
						p.AddSkill(new/obj/Skills/Queue/Rasengan)
						p << "You have learned the Rasengan!"
					nextTierUp = 4
				if(3)
					p << "Your mastery of natural energy is coming close to its peak..."
					nextTierUp = 3
					var/obj/Skills/Queue/Oodama_Rasengan/r = new()
					r = locate() in p
					if(!r)
						p.AddSkill(new/obj/Skills/Queue/Oodama_Rasengan)
						p << "You have learned the Oodama Rasengan!"
				if(4)
					p << "You have climbed the mountain of natural energy, and have become a Sage!"
					var/obj/Skills/Projectile/Rasenshuriken/r = new()
					r = locate() in p
					if(!r)
						p.AddSkill(new/obj/Skills/Projectile/Rasenshuriken)
						p << "You have learned the Rasenshuriken!"
					nextTierUp = 4
				if(5)
					nextTierUp=999
					p << "You have mastered the art of Senjutsu!"
			..(p);

	Spiral
		name = "Spiral"
		givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/Spiral/Evolution_Power")
		maxTier = 6
		applySecret(mob/p)
			switch(currentTier)
				if(1) // Unlocks Spiral and get your first buff
					p << "Your fighting spirit soars throughout you. Unknown to you, this is the beginning of Spiral Energy."
					giveSkills(p)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Spiral/Clobber)
				if(2) // Get your main attack
					p << "You hone your fighting spirit, fueled by the urge to make your dreams real."
					p.AddSkill(new/obj/Skills/AutoHit/Giga_Drill_Breaker)
					nextTierUp = 2
					if(p.passive_handler.Get("SpiralEngine")) // If you're an Android who has installed a Spiral Engine, you get ascension stats so that Evolution Power can buff you
						p.StrAscension+= 0.1
						p.EndAscension+= 0.1
						p.ForAscension+= 0.1
						p.SpdAscension+= 0.1
						p.OffAscension+= 0.1
						p.DefAscension+= 0.1
						p << "Your synthetic body evolved!"
				if(3) // Gives you your second buff
					p << "Your body surges with Spiral Energy, the power of evolution driving you forward."
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Spiral/InspiredEvo)
					nextTierUp = 2
					if(p.passive_handler.Get("SpiralEngine"))
						p.StrAscension+= 0.15
						p.EndAscension+= 0.15
						p.ForAscension+= 0.15
						p.SpdAscension+= 0.15
						p.OffAscension+= 0.15
						p.DefAscension+= 0.15
						p << "Your synthetic body evolved!"
				if(4)
					p << "Your soul burns with Spiral Hope. You refuse to be oppressed by the limitations of others."
					nextTierUp = 4
					if(p.passive_handler.Get("SpiralEngine"))
						p.StrAscension+= 0.15
						p.EndAscension+= 0.15
						p.ForAscension+= 0.15
						p.SpdAscension+= 0.15
						p.OffAscension+= 0.15
						p.DefAscension+= 0.15
						p << "Your synthetic body evolved!"
				if(5)
					p << "Your very DNA resonates with Spiral Power. You climb upwards toward the ceiling of your cage."
					nextTierUp = 4
					p.AddSkill(new/obj/Skills/Projectile/Spiral/Probability_Negation_Missiles)
					if(p.passive_handler.Get("SpiralEngine"))
						p.StrAscension+= 0.2
						p.EndAscension+= 0.2
						p.ForAscension+= 0.2
						p.SpdAscension+= 0.2
						p.OffAscension+= 0.2
						p.DefAscension+= 0.2
						p << "Your synthetic body evolved!"
				if(6)
					p << "You have gone beyond your full potential. You have evolved beyond the person you were before. You are free."
					if(p.passive_handler.Get("SpiralEngine"))
						p.StrAscension+= 0.3
						p.EndAscension+= 0.3
						p.ForAscension+= 0.3
						p.SpdAscension+= 0.3
						p.OffAscension+= 0.3
						p.DefAscension+= 0.3
						p << "Your synthetic body evolved!"
			..(p);

	Shin
		name = "Shin"
		givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/Shin_Radiance")
		maxTier = 6;
		var/Mang = 0; // The current amount of mang used
		var/MangMastery = 0; // The maximum amount of mang you can use
		applySecret(mob/p)
		// This code checks for the maximum Mang you can have, wheras var/Mang checks for your current mang :3
			if(currentTier >= 2)
				MangMastery = (currentTier-1)
			else
				MangMastery = 0
		// This code switches your Secret Tier
			switch(currentTier)
				if(1) //Unlocks Shin
					p << "You let go of all things... except for your most intense memories. You have awakened the power of Shin."
					giveSkills(p) // This only adds Shin_Radiance, Mang is on the next tier
					giveVariables(p)
				if(2) //Unlocks 1 Mang Ring
					p << "You fill your empty self with the emotions born from intense of Memories. You have awakened the power of Mang."
					nextTierUp = 2
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Mang_Resonance)
				if(3) // 2 Mang Rings
					p << "Your mastery over Shin and Mang improves."
					nextTierUp = 2
				if(4) // 3 Mang Rings
					p << "You further refine your mastery over Shin and Mang"
					nextTierUp = 4
				if(5) // 4 Mang Rings
					p << "You're at the cusp of perfecting the arts of Shin and Mang, your very presence begins to weigh upon others."
					nextTierUp = 4
				if(6) // 5 Mang Rings
					p << "You have refined both Shin and Mang to perfection, leveraging perfect control over your sense of self to invoke that intense emotion."
			..(p);


	BlackFlash
		name = "Black Flash"
		givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/BlackFlash_Potential")
		maxTier = 6;
		var/BlackFlashCount = 0; //Tracks how many were fired off during a fight
		var/BFlashPotential = 0; // If 120 Potential is up
		var/BlackFlashChance = 0; // Usually a raising chance to land one per Heavy Strike
		var/BlackFlashBaseChance = 5; // The chance it goes back to after med or too much time passed
		var/BlackFlashForcedChance = 0; // If above 0, is used to force a certain chance to BFlash
		var/BlackFlashFirstTimeUse = 1; // Literally just to do some funny narrative yapping like in the series
		applySecret(mob/p)
			p << "You feel a new resonance with your own energy..."
			switch(currentTier)
				if(1)
					giveSkills(p)
					giveVariables(p)
					BlackFlashBaseChance = 5;
				if(2)
					BlackFlashBaseChance = 15;
				if(3)
					BlackFlashBaseChance = 25;
					p << "You now have a chance to keep your focus when landing a Black Flash! (Your Chance to land a Black Flash has a 50% chance to not reset when landing one.)"
					p.passive_handler.Set("Sparks of Black",1)
				if(4)
					BlackFlashBaseChance = 35;
				if(5)
					BlackFlashBaseChance = 50;
					p << "The Blessing of the Sparks of Black allow you to force a Black Flash out no matter what!"
					p << "(Black Flash SureStrike: A 5 second Slotless Buff that forces your chance to land a Black Flash to 100%.)"
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/BlackFlash_SureStrike)
				if(6) // are you out of your motherfucking miiiiiiiiiind
					BlackFlashBaseChance = 60;
			..(p);


mob
	var
		//HAKI
		HakiSpecialization
		HakiCounterArmament
		HakiCounterObservation

		//HAMON
		Ripple//Breathing

		//VAMPIRISM
		BloodPower

	proc
		giveSecret(path)
			path = text2path("/SecretInformation/[path]")
			var/SecretInformation/secret = new path
			secretDatum = secret
			secret.init(src)

mob/Admin3/verb
	SecretManagement(var/mob/P in players)
		set category="Admin"
		if(!P.client) return
		if(P.Secret)
			src << "They already have a secret."
			return
		if(P.RaceInRareList())
			src << "No."
			return
		var/list/validSecrets = list("Cancel");
		validSecrets |= VALID_SECRET_LIST;
		validSecrets.Remove(RACIAL_SECRETS);
		var/Selection=input(src, "Which aspect of power does [P] awaken to?", "Secret Management") in validSecrets;
		if(Selection=="Cancel") return;
		switch(Selection)
			if("Spirits of The World")
				var/path = input(src, "Which path of Spirits of The World do you wish to follow?", "Spirits of The World") in list("Goetic Virtue", "Stellar Constellation", "Elven Sanctuary")
				// for now, admins pick it, as there
				P.Secret = path
				var/newpath = replacetext(path, " ", "_")
				newpath = "Spirits_Of_The_World/[newpath]"
				P.giveSecret(newpath)
			if("Heavenly Restriction")
				P.Secret = "Heavenly Restriction"
				P.giveSecret("HeavenlyRestriction")
			if("Jagan Eye")
				P.Secret = "Jagan Eye"
				P.giveSecret("JaganEye")
			if("Hamon")
				P.ModifyPrime+=1
				P.Secret="Hamon"
				P.giveSecret("Hamon")
			if("Senjutsu")
				P.ModifyPrime+=1
				P.Secret="Senjutsu"//i want to krill myself.
				P.giveSecret("SageArts")//better yet i want to krill whoever made it this way
			if("Haki")
				// P.ModifyPrime+=1
				P.Secret="Haki"
				P.giveSecret("Haki")
				// P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armament)
				// P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Observation)
				// P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armor_Lite)
				// P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armor)
				// P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Shield_Lite)
				// P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Shield)
				// P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Relax_Lite)
				// P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Relax)
				// P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Future_Flash_Lite)
				// P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Future_Flash)
				P << "Possessing such an overwhelming amount of willpower, you learn to chart destiny through your own ambition!"
			if("Werewolf")
				P.Secret="Werewolf"
				P.giveSecret("Werewolf")
			if("Eldritch")
				P.Secret = "Eldritch"
				P.giveSecret("Eldritch")
			if("Vampire")
				P.Secret="Vampire"
				P.giveSecret("Vampire")
			if("Shin")
				P.Secret="Shin"
				P.giveSecret("Shin")
			if("Black Flash")
				P.Secret="Black Flash"
				P.giveSecret("BlackFlash")
			if("Spiral")
				P.Secret="Spiral"
				P.giveSecret("Spiral")
mob
	proc
		AddHaki(var/Type)
			src.secretDatum.secretVariable["HakiCounter[Type]"]++
			if(src.secretDatum.secretVariable["HakiCounter[Type]"]>=100&&!src.secretDatum.secretVariable["HakiSpecialization"])
				src.secretDatum.secretVariable["HakiSpecialization"]="[Type]"
				src << "Your Haki becomes centered around the Color of [Type]!"

/mob/proc/RaceInRareList()
	for(var/x in RARE_LIST)
		if(isRace(x)) return 1;
	return 0;
