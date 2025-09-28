#define WW_HUNGER_MAX 250
#define WW_REDUCTION_PER_TIER 25

#define MADNESS_MAX 100
#define MADNESS_ADD_PER_TIER 25
/mob/var/SecretInfomation/secretDatum = new()





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
		p.secretDatum.tierUp(1, p)

/mob/proc/getSecretLevel()
	if(secretDatum)
		return secretDatum.currentTier
	return 0


SecretInfomation
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
/*
	proc/checkTierUp(mob/p)
		if(currentTier < maxTier)
	/*		if(p.Potential >= potentialRecieved + (glob.progress.PotentialDaily*nextTierUp))
				potentialRecieved = glob.progress.DaysOfWipe
				if(currentTier + 1 <= tierUnlocked)
					tierUp(1, p)*/
			if(currentTier > lastCheckedTier)
				tierUp(currentTier-lastCheckedTier, p)
*/


	proc/tierUp(num, mob/p)
		lastCheckedTier = currentTier
		if(currentTier < maxTier)
			var/difference = maxTier - currentTier
			for(var/x in 1 to num)
				if(difference > 0)
					currentTier++
					applySecret(p)
					difference--
					lastCheckedTier = currentTier
				else
					break
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

	proc/applySecret()


	Jagan
		name = "Jagan Eye"
		givenSkills = list("/obj/Skills/Buffs/SpecialBuffs/Cursed/Jagan_Eye", "/obj/Skills/Utility/Telepathy", "obj/Skills/Telekinisis" )
		givenVariables = list("EnhancedHearing", "EnhancedSmell")

		applySecret(mob/p)
			switch(currentTier)
				if(1)
					p << "You have awakened the power of the Jagan Eye!"
					giveSkills(p)
					giveVariables(p)
					p.JaganPowerNerf = 0.3
				if(2)
					p << "Your Jagan Eye has grown stronger!"
					p.JaganPowerNerf = 0.5
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
					p.JaganPowerNerf = 0.75
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
			if(prob(glob.CONQ_HAKI_CHANCE*currentTier) && secretVariable["ConquerorsHaki"] != 1)
				unlockConquerorsHaki(p)
		proc/unlockConquerorsHaki(mob/p)
			p << "You have the qualities of a King..."
			p << "You have awakened the power of Conqueror's Haki!"
			secretVariable["ConquerorsHaki"] = 1
			p.AddSkill(new/obj/Skills/AutoHit/Haki/Conquerors_Haki)
		proc/conqPaths(mob/p)
			if(secretVariable["ConquerorsHaki"] == 1)
				switch(currentTier)
					if(2)
						p.AddSkill(new/obj/Skills/Queue/Haki/Kings_Infusion)
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





	Hamon
		name = "Hamon"
		givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/Ripple/Ripple_Breathing")
		secretVariable = list("Ripple")
		applySecret(mob/p)
			switch(currentTier)
				if(1)
					p << "Your blood's beat is razor sharp...You've awakened the power of the Ripple!"
					giveSkills(p)
					giveVariables(p)


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
				p.vampireBlood = new(p, 6, 45)
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


	Eldritch
		name = "Eldritch"
		secretVariable = list("Madness" = 0, "Madness Active" = 0)
		givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/Eldritch/True_Form")
		applySecret(mob/p)
			switch(currentTier)
				if(1)
					giveSkills(p)
		proc/getMadnessLimit(mob/p)
			. = MADNESS_MAX + (MADNESS_ADD_PER_TIER * (1+p.AscensionsAcquired))
			if(. <0)
				. = 50
			else if(. > MADNESS_MAX)
				. = MADNESS_MAX
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

	HeavenlyRestriction
		name = "Heavenly Restriction"
		givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/HeavenlyRestriction/HeavenlyRestriction")
		secretVariable = list("Restrictions" = list(), "Improvements" = list())
		applySecret(mob/p)
			var/list/restriction = pickRestriction(p)
			applySecretVariable(p, restriction, pickImprove(p, restriction))


	SageArts
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
					var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sennin_Mode/focus = new()
					focus = locate() in p
					if(!focus)
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sennin_Mode)
						focus = locate() in p
					var/obj/Skills/Queue/Rasengan/r = new()
					r = locate() in p
					if(!r)
						p.AddSkill(new/obj/Skills/Queue/Rasengan)
						p << "You have learned the Rasengan!"
					focus.passives["ManaStats"] = 2
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
					var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sennin_Mode/focus = new()
					focus = locate() in p
					if(!focus)
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sennin_Mode)
						focus = locate() in p
					var/obj/Skills/Projectile/Rasenshuriken/r = new()
					r = locate() in p
					if(!r)
						p.AddSkill(new/obj/Skills/Projectile/Rasenshuriken)
						p << "You have learned the Rasenshuriken!"
					focus.passives["ManaStats"] = 3
					nextTierUp = 4
				if(5)
					nextTierUp=999
					p << "You have mastered the art of Senjutsu!"

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
			path = text2path("/SecretInfomation/[path]")
			var/SecretInfomation/secret = new path
			secretDatum = secret
			secret.init(src)

mob/Admin3/verb
	SecretManagement(var/mob/P in players)
		set category="Admin"
		if(!P.client) return
		var/list/Secrets=list("Spirits of The World","Jagan", "Hamon of the Sun", "Werewolf", "Vampire", "Sage Arts", "Haki", "Eldritch", "Heavenly Restriction")
		var/Selection=input(src, "Which aspect of power does [P] awaken to?", "Secret Management") in Secrets
		if(P.Secret)
			src << "They already have a secret."
			return
		else
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
				if("Jagan")
					P.Secret = "Jagan"
					P.giveSecret("Jagan")
				if("Hamon of the Sun")
					P.ModifyPrime+=1
					P.Secret="Ripple"
					P.giveSecret("Hamon")
				if("Sage Arts")
					P.ModifyPrime+=1
					P.Secret="Senjutsu"
					P.giveSecret("SageArts")
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
mob
	proc
		AddHaki(var/Type)
			src.secretDatum.secretVariable["HakiCounter[Type]"]++
			if(src.secretDatum.secretVariable["HakiCounter[Type]"]>=100&&!src.secretDatum.secretVariable["HakiSpecialization"])
				src.secretDatum.secretVariable["HakiSpecialization"]="[Type]"
				src << "Your Haki becomes centered around the Color of [Type]!"