/*
essentially check if we are -on update x, if not, update to x, if so, do nothing
*/

// make it so on world load we make the current version datum and use it for all people
proc/generateVersionDatum()
	var/update/updateversion
	for(var/i in subtypesof(/update))
		if(!ispath(i)) continue
		var/update/check = new i
		if(!check) continue
		if(updateversion && check.version > updateversion.version)
			updateversion = check
		else if (!updateversion)
			updateversion = check
	if(updateversion)
		glob.currentUpdate = updateversion

globalTracker
	var/UPDATE_VERSION = 34
	var/tmp/update/currentUpdate

	proc/updatePlayer(mob/p)
		if(!p.updateVersion)
			var/updateversion = "/update/version[UPDATE_VERSION]"
			p.updateVersion = new updateversion
			p.updateVersion.updateMob(p)
		if(UPDATE_VERSION == p.updateVersion.version)
			return
		if(p.updateVersion.version + 1 == UPDATE_VERSION)
			var/updateversion = "/update/version[p.updateVersion.version + 1]"
			var/update/update = new updateversion
			update.updateMob(p)
		else if(p.updateVersion.version + 1 < UPDATE_VERSION)
			for(var/x in 1 to abs(p.updateVersion.version - UPDATE_VERSION))
				// get the number of updates we are missing
				var/updateversion = "/update/version[p.updateVersion.version + 1]"
				var/update/update = new updateversion
				update.updateMob(p)


mob/var/update/updateVersion

// fix for disarm
/mob/proc/RestoreSkillDamageMultsAfterDisarmFix()
	if(!Skills || !Skills.len)
		return 0
	var/skills_reset = 0
	for(var/obj/Skills/Queue/q in Skills)
		var/defq = initial(q.DamageMult)
		if(q.DamageMult != defq)
			q.DamageMult = defq
			skills_reset++
	for(var/obj/Skills/AutoHit/a in Skills)
		var/defa = initial(a.DamageMult)
		if(a.DamageMult != defa)
			a.DamageMult = defa
			skills_reset++
	for(var/obj/Skills/Projectile/pr in Skills)
		var/defp = initial(pr.DamageMult)
		if(pr.DamageMult != defp)
			pr.DamageMult = defp
			skills_reset++
	for(var/obj/Skills/Grapple/g in Skills)
		var/defg = initial(g.DamageMult)
		if(g.DamageMult != defg)
			g.DamageMult = defg
			skills_reset++
	return skills_reset

update
	var/version = 1

	proc/updateMob(mob/p)
		if(version>1) p << "You have been updated to version [version]"
		p.updateVersion = src

	version1
		version = 1;
		updateMob(mob/p)
			. = ..()//left alone for easy copy pasting
	version2
		version = 2;
		updateMob(mob/p)
			. = ..()//left alone for easy copy pasting
			if(p.isRace(ELDRITCH))
				p.race.transformations += new /transformation/eldritch/partial_manifestation()
				p.race.transformations += new /transformation/eldritch/full_manifestation()
			if(p.isRace(HUMAN))
				if(p.Class=="Resourceful")
					for(var/x in p.knowledgeTracker.learnedKnowledge)
						p<<"You have had [x] refunded. (Tech)"
						var/theCost=glob.TECH_BASE_COST / p.Intelligence
						p.removeTechKnowledge(p, x, theCost, FALSE)
						del x
					for(var/x in p.knowledgeTracker.learnedKnowledge)
						if(x in EnchantmentKnowledge)
							del x
							p<<"You have had [x] refunded. (ench)"
					for(var/obj/Skills/S in p.Skills)
						if(S.Copyable>0&&S.SkillCost>1&&!S.Copied)
							p.refund_skill(S)
					p.RPPSpent=0
					p.RPPSpendable=p.RPPCurrent
					p.Intelligence=3
					p.AngerMax=1.25
					p.RPPMult=1.25
					p.Imagination=3
					p.ChooseSpawn()
					if(p.AscensionsAcquired==1)
						p.SpdAscension=0.4
	version3
		version = 3;
		updateMob(mob/p)
			. = ..()//left alone for easy copy pasting
			var/list/BasicElementPinnacles = list("Alight", "Awash", "Aerde", "Aloft")
			var/list/AdvancedElementPinnacles = list("Mender", "Survivor", "Future", "Kinematics")
			for(var/mage_passive/mp in p.acquiredMagePassives)
				if(mp.name in BasicElementPinnacles)
					mp.passives["ManaGeneration"] = 1;
					p.passive_handler.Decrease("ManaGeneration", 2);
					p << "Your Basic Element Pinnacles have had their Mana Generation reduced. This should only trigger once per element."
				if(mp.name in AdvancedElementPinnacles)
					mp.passives["ManaGeneration"] = 2;
					p.passive_handler.Decrease("ManaGeneration", 3);
					p << "Your Advanced Element Pinnacles have had their Mana Generation reduced. This should only trigger once per element."
	version4
		version = 4;
		updateMob(mob/p)
			. = ..()//left alone for easy copy pasting
			if(p.isRace(NOBODY)||p.isRace(ANDROID))
				p.refundNewMagicTree()
				p.RPPMult*=1.25
				if(p.isRace(NOBODY))
					p.passive_handler.Set("Longing", 1)
					p.passive_handler.Set("Emptiness", 1)
					if(p.Class=="Samurai")
						p.passive_handler.Set("EmptyFlashStep", 1)
				if(p.isRace(ANDROID))
					if(p.AscensionsAcquired==1)
						p.EnhanceChipsMax +=2
			if(p.isRace(HUMAN))
				if(p.Class=="Underdog")
					p.AngerMax=2
					p.RPPMult = 1.35
	version5
		version = 5;
		updateMob(mob/p)
			. = ..()//left alone for difficult copy pasting
			if(p.isRace(HALFSAIYAN))
				p.stat_redo()
			if(p.isRace(HUMAN))
				if(p.Class=="Underdog")
					p.passive_handler.Increase("Motivation", 0.25)
					if(p.AscensionsAcquired==1)
						p.passive_handler.Increase("Motivation", 0.1)
	version6
		version = 6;
		updateMob(mob/p)
			. = ..()//left alone for slightly easier copy pasting
			if(p.isRace(HALFSAIYAN))
				p.stat_redo()
			if(p.isRace(HUMAN))
				if(p.Class=="Underdog")
					p.passive_handler.Increase("Motivation", 0.5)
				if(!p.passive_handler.Get("Shonen"))
					if(p.AscensionsAcquired==1)
						p.passive_handler.Increase("Shonen", 1)
						p.passive_handler.Increase("ShonenPower", 0.15)
						p.passive_handler.Increase("UnderDog", 1)
						p.passive_handler.Increase("Persistence", 1)
						admins<< "[p] had their missed ascension passives applied. If they already had them, whoops, I fucked up"
	version7
		version = 7;
		updateMob(mob/p)
			. = ..()//left alone for easy copy pasting
			if(p.ArmamentEnchantmentUnlocked>=5||("Soul Infusion" in p.knowledgeTracker.learnedMagic))
				if(!locate(/obj/Skills/Utility/Enchant_Equipment, p))
					p.AddSkill(new/obj/Skills/Utility/Enchant_Equipment)
					p << "Your knowledge of Soul Infusion grants you the Enchant Equipment skill."
	version8
		version = 8;
		updateMob(mob/p)
			. = ..()//left alone for mildly challenging copy pasting
			if(p.Saga=="Hiten Mitsurugi-Ryuu")
				if(p.SagaLevel>=2)
					p.passive_handler.Decrease("SlayerMod", 1)
					p.passive_handler.Increase("Flow", 1)
					p.passive_handler.Increase("Instinct", 1)
				if(p.SagaLevel>=3)
					p.passive_handler.Decrease("SlayerMod", 1)
					p.passive_handler.Decrease("Brutalize", 2)
					p.passive_handler.Increase("Flow", 1)
					p.passive_handler.Increase("Instinct", 1)
	version9
		version = 9;
		updateMob(mob/p)
			. = ..()
			if(!p.absorbedBy)
				return
			var/absorberCkey = p.absorbedBy
			var/mob/Players/M = GetMajinByCkey(absorberCkey)
			if(M && M.majinAbsorb && M.majinAbsorb.absorbed && M.majinAbsorb.absorbed["[p.ckey]"])
				var/list/entry = M.majinAbsorb.absorbed["[p.ckey]"]
				if(islist(entry) && !entry["absorbedAt"])
					entry["mob"] = p
					M.majinAbsorb.DigestVictim(M, "[p.ckey]")
					return
				return
			if(p.absorbedAtTimestamp)
				return
			if(!MAJIN_PENDING_DIGEST_CREDITS["[absorberCkey]"])
				MAJIN_PENDING_DIGEST_CREDITS["[absorberCkey]"] = list()
			if(!("[p.ckey]" in MAJIN_PENDING_DIGEST_CREDITS["[absorberCkey]"]))
				MAJIN_PENDING_DIGEST_CREDITS["[absorberCkey]"] += "[p.ckey]"
			p.absorbedBy = null
			p.majinRoomIndex = 0
			p.absorbedAtTimestamp = 0
			p.RevokeObserveMajinVerb()
			MoveToSpawn(p)
			p.KO = 0
			p << "<font color='purple'>You've been digested and sent back to spawn.</font>"
	version10
		version = 10;
		updateMob(mob/p)
			. = ..()//slightly altered for inconvenient copypasting
			if(p.isRace(MAKYO))
				if(p.AscensionsAcquired>=1)
					p.NewAnger(p.AngerMax+0.1)
				if(p.AscensionsAcquired>=2)
					p.NewAnger(p.AngerMax+0.1)
			if(p.isRace(BEASTKIN))
				if(p.Class=="Feather Cowl"&&p.AscensionsAcquired>=1)
					if(p.StrAscension<0)
						p.StrAscension=0
	version11
		version = 11;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(ELDRITCH))
				p.passive_handler.Increase("Fishman", 1);
				p << "You have been blessed by the space squids of old."
				p << "Which is to say, you have the Fishman passive now."
	version12
		version = 12;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(CELESTIAL) && p.CelestialAscension == "Demon")
				p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/RoyalGuard)
				p.AddSkill(new/obj/Skills/AutoHit/RoyalRelease)
				p << "Things are getting even crazier- You've been granted Royal Guard & Release!"
	version13
		version = 13;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(MAKYO))
				if(p.AscensionsAcquired >= 1)
					// Asc 1 stat buffs: Str 0.5->1, End 0->1, Off 0->0.25, Anger 0.1->0.15
					p.StrAscension += 0.5
					p.EndAscension += 1
					p.OffAscension += 0.25
					p.NewAnger(p.AngerMax + 0.05)
					// Asc 1 new passive: Adrenaline 1
					p.passive_handler.Increase("Adrenaline", 1)
				if(p.AscensionsAcquired >= 2)
					// Asc 2 stat buffs: Str 0->1.25, End 0.25->1.25, For 0->0.5, Anger 0.1->0.15
					p.StrAscension += 1.25
					p.EndAscension += 1
					p.ForAscension += 0.5
					p.NewAnger(p.AngerMax + 0.05)
					// Asc 2 new passive: Adrenaline 2
					p.passive_handler.Increase("Adrenaline", 2)
	version14
		version = 14;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(HUMAN))
				if(p.passive_handler.Get("TensionPowered") && p.transActive == 0)
					p.transActive = 1;
					p.Revert();
					//an attempt is made
				if(!p.passive_handler.Get("DormantDemon") && !p.passive_handler.Get("DeathDefied") && p.Class == "Underdog")//normal human, woof woof
					p << "You are recognized as a NOT Mazoku human."
					p << "So give me those transformations back, boo.";
					var/safety = 20
					while(p.transActive > 0 && safety-- > 0)
						var/oldTA = p.transActive
						p.Revert()
						if(p.transActive == oldTA)
							p.transActive = 0
							break
					for(var/transformation/T in p.race.transformations.Copy())
						p.race.transformations -= T
						del T
					p << "Also, here, have your normal transformations back. Kthxbye."
					p.race.transformations += new /transformation/human/high_tension()
					p.race.transformations += new /transformation/human/high_tension_MAX()
					p.race.transformations += new /transformation/human/super_high_tension()
					p.race.transformations += new /transformation/human/super_high_tension_MAX()
					p.race.transformations += new /transformation/human/unlimited_high_tension()
	version15
		version = 15;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(HUMAN))
				if(p.Class == "Heroic" || p.Class == "Resourceful")
					var/safety = 20
					while(p.transActive > 0 && safety-- > 0)
						var/oldTA = p.transActive
						p.Revert()
						if(p.transActive == oldTA)
							p.transActive = 0
							break
					for(var/transformation/T in p.race.transformations.Copy())
						p.race.transformations -= T
						del T
					p << "Heroic and Resourceful humans don't transform. Your transformation list has been cleared."
				else if(p.passive_handler.Get("DormantDemon") && !p.passive_handler.Get("DeathDefied"))
					var/safety = 20
					while(p.transActive > 0 && safety-- > 0)
						var/oldTA = p.transActive
						p.Revert()
						if(p.transActive == oldTA)
							p.transActive = 0
							break
					for(var/transformation/T in p.race.transformations.Copy())
						p.race.transformations -= T
						del T
					p << "As a Mazoku human who has not yet died at ascension 3, you have no transformations until you trigger your cheat death."
				else if(p.passive_handler.Get("DormantDemon") && p.passive_handler.Get("DeathDefied"))
					var/safety = 20
					while(p.transActive > 0 && safety-- > 0)
						var/oldTA = p.transActive
						p.Revert()
						if(p.transActive == oldTA)
							p.transActive = 0
							break
					for(var/transformation/T in p.race.transformations.Copy())
						p.race.transformations -= T
						del T
					p.race.transformations += new /transformation/human/high_tension/mazoku()
					p.race.transformations += new /transformation/human/high_tension_MAX/mazoku()
					p.race.transformations += new /transformation/human/super_high_tension/mazoku()
					p.race.transformations += new /transformation/human/super_high_tension_MAX/mazoku()
					p.race.transformations += new /transformation/human/unlimited_high_tension/mazoku()
					p.race.transformations += new /transformation/demon/devil_trigger/mazoku()
					if(p.AscensionsAcquired >= 6)
						p.race.transformations += new /transformation/human/sacred_energy_aura()
					p << "Your Mazoku transformations have been refreshed."
			else if(p.isRace(DEMON))
				var/removed_mazoku_dt = 0
				for(var/transformation/demon/devil_trigger/mazoku/T in p.race.transformations)
					p.race.transformations -= T
					del T
					removed_mazoku_dt = 1
				if(removed_mazoku_dt)
					p << "A stray Mazoku Devil Trigger has been removed from your transformations. You're a regular Demon. Dummy."


	version16
		version = 16;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(DRAGON))
				switch(p.Class)
					if("Metal")
						if(p.AscensionsAcquired >= 1)
							p.StrAscension += 0.25
							p.EndAscension += 1.25
							p.OffAscension -= 0.5
							p.ForAscension += 0.5
							p.passive_handler.Decrease("DeathField", 1)
							p.passive_handler.Increase("PureReduction", 1)
						if(p.AscensionsAcquired >= 2)
							p.StrAscension += 0.75
							p.EndAscension += 0.75
							p.DefAscension -= 0.25
							p.ForAscension += 0.5
							p.passive_handler.Decrease("DeathField", 1)
							p.passive_handler.Increase("PureReduction", 1)
					if("Fire")
						if(p.AscensionsAcquired >= 1)
							p.StrAscension += 0.5
							p.ForAscension += 0.5
							p.OffAscension += 0.25
							p.passive_handler.Increase("SpiritHand", 1.5)
						if(p.AscensionsAcquired >= 2)
							p.StrAscension += 0.75
							p.ForAscension += 0.75
							p.OffAscension -= 0.25
							p.passive_handler.Increase("SpiritHand", 1.5)
					if("Water")
						if(p.AscensionsAcquired >= 1)
							p.StrAscension -= 0.25
							p.ForAscension += 0.25
							p.DefAscension += 0.5
							p.SpdAscension += 1
						if(p.AscensionsAcquired >= 2)
							p.StrAscension -= 0.25
							p.ForAscension += 0.25
							p.DefAscension += 1
							p.SpdAscension += 0.5
					if("Wind")
						if(p.AscensionsAcquired >= 1)
							p.ForAscension += 0.25
							p.SpdAscension += 1
							p.OffAscension -= 0.25
							p.DefAscension += 0.5
						if(p.AscensionsAcquired >= 2)
							p.ForAscension += 0.25
							p.SpdAscension += 1.25
							p.OffAscension += 0.25
					if("Gold")
						if(p.AscensionsAcquired >= 1)
							p.EndAscension += 0.5
							p.SpdAscension += 0.75
						if(p.AscensionsAcquired >= 2)
							p.EndAscension += 0.75
							p.SpdAscension += 1
					if("Dark")
						if(p.AscensionsAcquired >= 1)
							p.StrAscension += 0.65
							p.SpdAscension += 0.15
							p.OffAscension += 0.15
						if(p.AscensionsAcquired >= 2)
							p.StrAscension += 0.75
							p.SpdAscension += 0.75
							p.OffAscension += 0.25
	version17
		version = 17;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(HUMAN)&&p.Class=="Heroic")
				if(p.AscensionsAcquired >= 2)
					p.passive_handler.Increase("PureReduction", 3)
					p.passive_handler.Increase("PureDamage", 3)
				if(p.AscensionsAcquired >= 3)
					p.passive_handler.Increase("PureReduction", 2)
					p.passive_handler.Increase("PureDamage", 2)
	version18
		version = 18;
		updateMob(mob/p)
			. = ..()
			var/fixed = p.RestoreSkillDamageMultsAfterDisarmFix()
			if(fixed)
				p << "Your skill DamageMults have been restored. Rejoice."
			if(p.isRace(BEASTKIN))
				for(var/a=p.AscensionsAcquired, a > 0, a--)
					var/ascension/asc = p.race.ascensions[a];
					asc.revertAscension(p);
					p.AscensionsAcquired--;
					p << "Reverted Beastkin ascension [a]"
				p.race.ascensions = list();
				p.race.fixAscensions();
				p << "Gave new Beastkin ascension types."
	version19
		version = 19;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(BEASTKIN))
				p.race.ascensions = list();
				if(p.race.ascensions.len <= 0)
					p.race.ascensions |= new/ascension/beastkin/one
					p.race.ascensions |= new/ascension/beastkin/two
					p.race.ascensions |= new/ascension/beastkin/three
					p.race.ascensions |= new/ascension/beastkin/four
					p.race.ascensions |= new/ascension/beastkin/five
					p.race.ascensions |= new/ascension/beastkin/six
					p << "You have <b>actually</b> been given new ascensions as a Beastkin now.";
	version20
		version = 20;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(NOBODY)&&p.Class=="Imaginary")
				p.passive_handler.Increase("DrainlessPUSpike", 1)
				if(p.AscensionsAcquired>=1)
					p.passive_handler.Increase("EnergyGeneration", 2)
					p.passive_handler.Increase("ManaGeneration", 1)
				if(p.AscensionsAcquired>=2)
					p.passive_handler.Increase("EnergyGeneration", 2)
					p.passive_handler.Increase("ManaGeneration", 1)
	version21
		version = 21;
		updateMob(mob/p)
			. = ..()
			if(p.passive_handler.Get("Limited Rank-Up"))
				p.passive_handler.Set("Limited Rank-Up", 0)
				p<<"<b>Whoops you weren't supposed to have that lol</b>"
			p.refundNewMagicTreeOld()
			if(p.isRace(DEMIFIEND) && p.Saga == "Devil Summoner" && p.SagaLevel > 0)
				var/effective_level
				if(p.demon_party_cap >= 12)      effective_level = 6
				else if(p.demon_party_cap >= 10) effective_level = 5
				else if(p.demon_party_cap >= 8)  effective_level = 4
				else if(p.demon_party_cap >= 6)  effective_level = 3
				else if(p.demon_party_cap >= 4)  effective_level = 2
				else effective_level = 1

				if(effective_level < p.SagaLevel)
					var/target = p.SagaLevel
					p.SagaLevel = effective_level
					while(p.SagaLevel < target)
						p.SagaLevel++
						p.tierUpSaga("Devil Summoner")
	version22
		version = 22;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(POPO))
				if(p.AscensionsAcquired==3)
					p.StrAscension = 6
					p.ForAscension = 6
					p.EndAscension = 6
					p.OffAscension = 6
					p.DefAscension = 6
					p.SpdAscension = 7.5
					p.RecovAscension = 6
				if(p.AscensionsAcquired==6)
					p.StrAscension = 21
					p.ForAscension = 21
					p.EndAscension = 21
					p.OffAscension = 21
					p.DefAscension = 21
					p.SpdAscension = 24
					p.RecovAscension = 21
	version23
		version = 23;
		updateMob(mob/p)
			. = ..()
			if(p.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/The_Grit))
				if(p.Class!="Heart of The Beastkin")
					p.passive_handler.Set("Grit", 0)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/The_Grit/TG in p)
						del TG
	version24
		version = 24;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(DRAGON)&&p.Class=="Gold")
				if(p.AscensionsAcquired>=1)
					p.StrAscension += 0.5
				if(p.AscensionsAcquired>=2)
					p.StrAscension += 0.5
				if(p.AscensionsAcquired>=3)
					p.StrAscension += 0.75
	version25
		version = 25;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(ELDRITCH))
				if(p.AscensionsAcquired>=1)
					p.passive_handler.Decrease("BuffMastery", 2)
				if(p.AscensionsAcquired>=2)
					p.passive_handler.Decrease("BuffMastery", 2)
				if(p.AscensionsAcquired>=3)
					p.passive_handler.Decrease("BuffMastery", 2)
			if(p.isRace(BEASTKIN))
				if(p.Class == "Feather Cowl")
					if(p.AscensionsAcquired>=1)
						p.passive_handler.Increase("PureReduction", 2);
						p.passive_handler.Increase("PureDamage", 1);
						p.passive_handler.Increase("Juggernaut", 1);
						p.passive_handler.Decrease("BlockChance", 10);
						p.passive_handler.Decrease("CriticalBlock", 0.1);
						p.passive_handler.Decrease("CriticalChance", 5);
						p.passive_handler.Decrease("CriticalDamage", 0.05);
					if(p.AscensionsAcquired>=2)
						p.passive_handler.Increase("PureReduction", 2);
						p.passive_handler.Increase("PureDamage", 1);
						p.passive_handler.Increase("Juggernaut", 1);
						p.passive_handler.Decrease("BlockChance", 10);
						p.passive_handler.Decrease("CriticalBlock", 0.1);
						p.passive_handler.Decrease("CriticalChance", 5);
						p.passive_handler.Decrease("CriticalDamage", 0.05);
				if(p.Class == "Feather Knife")
					if(p.AscensionsAcquired>=1)
						p.passive_handler.Increase("PureDamage", 2);
						p.passive_handler.Increase("PureReduction", 1);
						p.passive_handler.Increase("BlurringStrikes", 1);
						p.passive_handler.Decrease("CriticalChance", 25);
						p.passive_handler.Decrease("CriticalDamage", 0.25);
					if(p.AscensionsAcquired>=2)
						p.passive_handler.Increase("PureDamage", 2);
						p.passive_handler.Increase("PureReduction", 1);
						p.passive_handler.Increase("BlurringStrikes", 1);
						p.passive_handler.Decrease("CriticalChance", 10);
						p.passive_handler.Decrease("CriticalDamage", 0.1);
	version26
		version = 26;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(ELDRITCH))
				p.passive_handler.Increase("SpaceWalk", 1);
				p.passive_handler.Increase("StaticWalk", 1);
				p << "The Space Squids of old look upon you kindly."
				p << "WHY THE FRIGGLE FRACK DID THEY TAKE SPACEWALK AND STATIC WALK OFF YOU?!"
				p << "How can you space squid if you can't even go to space...!"
			if(p.isRace(BEASTKIN))
				if(p.Class == "Feather Cowl")
					if(p.AscensionsAcquired>=1)
						p.passive_handler.Decrease("PureReduction", 2);
						p.passive_handler.Decrease("PureDamage", 1);
						p.passive_handler.Increase("PureReduction", 0.25);
						p.passive_handler.Increase("PureDamage", 0.125);
					if(p.AscensionsAcquired>=2)
						p.passive_handler.Decrease("PureReduction", 2);
						p.passive_handler.Decrease("PureDamage", 1);
						p.passive_handler.Increase("PureReduction", 0.25);
						p.passive_handler.Increase("PureDamage", 0.125);
					p << "Your pure damage and pure reduction have been reduced."
					p << "bird down..."
				if(p.Class == "Feather Knife")
					if(p.AscensionsAcquired>=1)
						p.passive_handler.Decrease("PureReduction", 1);
						p.passive_handler.Decrease("PureDamage", 2);
						p.passive_handler.Increase("PureReduction", 0.125);
						p.passive_handler.Increase("PureDamage", 0.25);
					if(p.AscensionsAcquired>=2)
						p.passive_handler.Decrease("PureReduction", 1);
						p.passive_handler.Decrease("PureDamage", 2);
						p.passive_handler.Increase("PureReduction", 0.125);
						p.passive_handler.Increase("PureDamage", 0.25);
					p << "Your pure damage and pure reduction have been reduced."
					p << "bird down..."
	version27
		version = 27;
		updateMob(mob/p)
			. = ..()
			if(p.passive_handler.Get("SpiralPowerUnlocked"))
				p.passive_handler.Set("SpiralPowerUnlocked", 0)
	version28
		version = 28;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(HUMAN)&&p.Class=="Heroic")
				if(p.AscensionsAcquired>=1)
					p.passive_handler.Increase("Instinct", 2);
					p.passive_handler.Increase("Flow", 2);
				if(p.AscensionsAcquired>=2)
					p.passive_handler.Increase("Instinct", 2);
					p.passive_handler.Increase("Flow", 2);
				if(p.AscensionsAcquired>=3)
					p.passive_handler.Increase("Instinct", 2);
					p.passive_handler.Increase("Flow", 2);
	version29
		version = 29;
		updateMob(mob/p)
			. = ..()
			if(p.isRace(HUMAN)&&p.Class=="Heroic")
				if(p.AscensionsAcquired>=4)
					p.StrAscension += 0.5
					p.ForAscension += 0.5
					p.EndAscension += 0.5
					p.OffAscension += 0.5
					p.DefAscension += 0.5
	version30
		version = 30
		updateMob(mob/p)
			. = ..()
			var/list/giveBack = list()
			for(var/spell_passive/sp in p.acquiredSpellPassives)
				if(sp.enchantedIn)
					p.disenchantSpellWithPassive(sp.enchantedIn, sp)
				giveBack += sp.type
				del sp
			if(length(giveBack))
				p.acquiredSpellPassives = list()
				for(var/type in giveBack)
					var/spell_passive/sp = new type;
					p.acquiredSpellPassives |= sp;
				p << "You'll need to reapply your spell passives."
	version31
		version = 31
		updateMob(mob/p)
			. = ..()
			if(p.isRace(ELDRITCH))
				p << "You're going to have to redo your ascension choices..."
				p.race.revertAndFixAllAscensions(p);
				p << "It is done. Remeditate to have your ascensions granted again!"
				if(p.passive_handler["Soulfire"] != 0)//this is a typo. we do not use this.
					p.passive_handler["Soulfire"] = 0;

	version32
		version = 32
		updateMob(mob/p)
			. = ..()
			// digest anyone still trapped under the old absorb
			if(!p.absorbedBy)
				return
			var/absorberCkey = p.absorbedBy
			var/mob/Players/M = GetMajinByCkey(absorberCkey)
			if(M && M.majinAbsorb && M.majinAbsorb.absorbed && islist(M.majinAbsorb.absorbed["[p.ckey]"]))
				M.majinAbsorb.DigestVictim(M, "[p.ckey]")
				return
			if(!MAJIN_PENDING_DIGEST_CREDITS["[absorberCkey]"])
				MAJIN_PENDING_DIGEST_CREDITS["[absorberCkey]"] = list()
			if(!("[p.ckey]" in MAJIN_PENDING_DIGEST_CREDITS["[absorberCkey]"]))
				MAJIN_PENDING_DIGEST_CREDITS["[absorberCkey]"] += "[p.ckey]"
			p.absorbedBy = null
			p.majinRoomIndex = 0
			p.absorbedAtTimestamp = 0
			p.RevokeObserveMajinVerb()
			MoveToSpawn(p)
			p.KO = 0
			p << "<font color='purple'>You've been digested and sent back to spawn.</font>"
	version33
		version = 33
		updateMob(mob/p)
			. = ..()
			if(p.isRace(SAIYAN))
				if(p.AscensionsAcquired>=2)
					if(p.Class=="Pride")
						p.passive_handler.Increase("PureDamage", 1)
						p.passive_handler.Increase("Steady", 1)
					if(p.Class=="Zeal")
						p.passive_handler.Increase("Adaptation", 0.5)
					if(p.Class=="Honor")
						p.passive_handler.Increase("PureReduction", 0.5)
						p.passive_handler.Increase("Adrenaline", 1)
						p.passive_handler.Increase("AngerAdaptiveForce", 0.2)
				if(p.AscensionsAcquired>=3)
					if(p.Class=="Pride")
						p.passive_handler.Increase("PureDamage", 1)
						p.passive_handler.Increase("Steady", 1)
					if(p.Class=="Zeal")
						p.passive_handler.Increase("Adaptation", 0.5)
						p.passive_handler.Increase("LikeWater", 0.5)
					if(p.Class=="Honor")
						p.passive_handler.Increase("PureReduction", 0.5)
						p.passive_handler.Increase("Juggernaut", 1)
						p.passive_handler.Increase("AngerAdaptiveForce", 0.2)
				if(p.AscensionsAcquired>=4)
					if(p.Class=="Pride")
						p.passive_handler.Increase("PureDamage", 1)
						p.passive_handler.Increase("Steady", 1)
					if(p.Class=="Zeal")
						p.passive_handler.Increase("Adaptation", 0.5)
						p.passive_handler.Increase("LikeWater", 0.5)
					if(p.Class=="Honor")
						p.passive_handler.Increase("PureReduction", 1)
						p.passive_handler.Increase("Adrenaline", 1)
						p.passive_handler.Increase("AngerAdaptiveForce", 0.2)
	version34
		version = 34
		updateMob(mob/p)
			. = ..()
			if(p.isRace(DRAGON))
				for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage/dr in p.contents)
					dr.adjust(p);
					p << "Your Dragon Rage has been adjusted to scale with health!"
/globalTracker/var/COOL_GAJA_PLAYERS = list("Thorgigamax", "Gemenilove" )
/globalTracker/var/GAJA_PER_ASC_CONVERSION = 0.25
/globalTracker/var/GAJA_MAX_EXCHANGE = 1

/mob/proc/gajaConversionCheck()
	if(key in glob.COOL_GAJA_PLAYERS)
		verbs += /mob/proc/ExchangeMinerals

/mob/proc/gajaConversionRateUpdate()
	if(isRace(GAJALAKA) && key in glob.COOL_GAJA_PLAYERS)
		var/asc = AscensionsAcquired
		var/ascRate = 0.5 + (glob.GAJA_PER_ASC_CONVERSION * asc) // 1.25 max
		for(var/obj/Money/moni in src)
			if(moni.Level >= 10000)
				var/boon = round(moni.Level * 0.00001, 0.1)
				if(boon > glob.GAJA_MAX_EXCHANGE) // so 1.75 total
					boon = glob.GAJA_MAX_EXCHANGE
				playerExchangeRate = ascRate + boon

