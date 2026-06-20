// Bio-Android system
//
// Bio-Androids are players who have installed the "Biological Cybernetics" augmentation
// via the existing Cybernetic_Augmentation skill. The mob.BioAndroid flag is set to 1
// when the install completes (see _UtilityX.dm Cybernetic_Augmentation switch case).
//
// A Bio-Android can collect genetic samples from other players to gain that race's
// passives and skills. Two tiers of samples exist:
//
//   Tier 1 - Consent path. Collector targets a nearby player, that player gets a popup
//            asking if they want to donate. Free for the donor, weak benefits for the
//            collector. Each player can only ever donate one tier-1 sample in their
//            lifetime, regardless of who they donate to.
//
//   Tier 2 - Two paths to obtain:
//            (a) Bio_Augmentation verb. Pick race from a list, pay a large cost in
//                Mana Bits. No donor required.
//            (b) Force_Extract verb. Pick a KO'd target adjacent to you. Applies a
//                25% HealthCut and 3 Maims to the donor. No consent required. Grants
//                BOTH the tier-1 AND tier-2 sample of the donor's race in one shot.
//
// PLUG AND PLAY:
// Fill in BIO_SAMPLE_DEFS below to define what each race grants per tier. Each entry
// has four lists: tier-1 passives, tier-1 skills, tier-2 passives, tier-2 skills.
// Passive associative lists use "Name" = value format, applied via passive_handler.
// Skill lists hold typepaths, applied via AddSkill(new path). Modify the registry,
// recompile, test. No code changes elsewhere are needed to add or change bonuses.
//
// EXAMPLE entry once you fill it in:
//   "Saiyan" = list(
//       "t1_passives" = list("Brutalize" = 0.05),
//       "t1_skills"   = list(),
//       "t2_passives" = list("Brutalize" = 0.15),
//       "t2_skills"   = list(/obj/Skills/Buffs/SlotlessBuffs/Oozaru)
//   )

var/global/list/BIO_SAMPLE_DEFS = list(
	"Saiyan"       = list("t1_passives"=list("ZenkaiPower" = 0.1, "Brutalize" =0.5), "t1_skills"=list(), "t2_passives"=list("ZenkaiPower" = 0.65, "Brutalize" =1), "t2_skills"=list()),
	"Half_Saiyan"  = list("t1_passives"=list("UnderDog" = 3, "KillerInstinct" = 0.1), "t1_skills"=list(), "t2_passives"=list("UnderDog" = 6, "KillerInstinct" = 0.2), "t2_skills"=list()),
	"Human"        = list("t1_passives"=list("Persistence" = 1, "DemonicDurability" = 0.15), "t1_skills"=list(), "t2_passives"=list("Persistence" = 2, "DemonicDurability" = 0.35), "t2_skills"=list()),
	"Namekian"     = list("t1_passives"=list("TechniqueMastery" = 2, "Duelist" = 1), "t1_skills"=list(), "t2_passives"=list("TechniqueMastery" = 3, "Duelist" = 2), "t2_skills"=list()),
	"Majin"        = list("t1_passives"=list("ManaCapMult" = 0.5, "ManaGeneration" = 2), "t1_skills"=list(), "t2_passives"=list("Extend" = 1, "Gum Gum" = 1), "t2_skills"=list()),
	"Demon"        = list("t1_passives"=list("PureDamage" = 2, "AbyssMod" = 2), "t1_skills"=list(), "t2_passives"=list("PureDamage" = 3, "AbyssMod" = 5), "t2_skills"=list()),
	"Angel"        = list("t1_passives"=list("PureReduction" = 2, "HolyMod" = 2), "t1_skills"=list(), "t2_passives"=list("PureReduction" = 3, "HolyMod" = 5), "t2_skills"=list()),
	"Celestial"    = list("t1_passives"=list("MartialMagic" = 1), "t1_skills"=list(), "t2_passives"=list("BladeFisting" = 1), "t2_skills"=list()),
	"Dragon"       = list("t1_passives"=list("AngerAdaptiveForce" = 0.25, "BlurringStrikes" = 0.5, "LikeWater" = 1, "Flow" = 1, "Instinct" = 1), "t1_skills"=list(), "t2_passives"=list("AngerAdaptiveForce" = 0.5, "BlurringStrikes" = 2 , "LikeWater" = 2, "Flow" = 2, "Instinct" = 2), "t2_skills"=list()),
	"Beastkin"     = list("t1_passives"=list("Fury" = 0.5, "Harden" = 0.5, "Momentum" = 0.5), "t1_skills"=list(), "t2_passives"=list("Fury" = 2, "Harden" = 2, "Momentum" = 2), "t2_skills"=list()),
	"Eldritch"     = list("t1_passives"=list("DebuffResistance"=0.1,"BuffMastery"=1), "t1_skills"=list(/obj/Skills/Utility/Telepathy), "t2_passives"=list("DebuffResistance"=0.3,"BuffMastery"=3), "t2_skills"=list()),
	"Changeling"   = list("t1_passives"=list(), "t1_skills"=list(), "t2_passives"=list(), "t2_skills"=list()),
	"Makyo"        = list("t1_passives"=list("Juggernaut" = 0.5), "t1_skills"=list(), "t2_passives"=list("Juggernaut" = 0.5), "t2_skills"=list(/obj/Skills/Buffs/SlotlessBuffs/Makyo/Expand)),
	"Makaioshin"   = list("t1_passives"=list("SpiritPower" = 0.1, "HybridStrike"=0.5), "t1_skills"=list(), "t2_passives"=list("SpiritPower" = 0.15, "HybridStrike"=0.5), "t2_skills"=list()),
	"Shinjin"      = list("t1_passives"=list(), "t1_skills"=list(), "t2_passives"=list(), "t2_skills"=list()),
	"Demi-fiend"   = list("t1_passives"=list("ManaGeneration" = 1, "ManaCapMult" = 0.5), "t1_skills"=list(), "t2_passives"=list("ManaGeneration" = 2), "t2_skills"=list()),
	"High Faoroan" = list("t1_passives"=list(), "t1_skills"=list(), "t2_passives"=list(), "t2_skills"=list()),
	"Chakardi"     = list("t1_passives"=list(), "t1_skills"=list(), "t2_passives"=list(), "t2_skills"=list()),
	"Popo"         = list("t1_passives"=list("CashCow" = 3), "t1_skills"=list(), "t2_passives"=list("MovementMastery" = 4, "CashCow" = 5), "t2_skills"=list()),
	"Nobody"     = list("t1_passives"=list("MovingCharge" = 1, "SwordAscension" = 1), "t1_skills"=list(), "t2_passives"=list("SwordAscension" = 3, "CriticalChance" = 10, "CriticalDamage" = 0.15), "t2_skills"=list())
)


// ===== HELPER PROCS =====

/mob/proc/HasBioSample(race_name, tier)
	if(!bio_samples)
		return FALSE
	return ("[race_name]:[tier]" in bio_samples)

/mob/proc/GiveBioSample(race_name, tier)
	// Returns TRUE if granted, FALSE if collector already had it.
	if(!bio_samples)
		bio_samples = list()
	var/key = "[race_name]:[tier]"
	if(key in bio_samples)
		return FALSE
	bio_samples += key
	ApplyBioSample(race_name, tier)
	return TRUE
/mob/proc/RemoveBioSample(race_name, tier)
	// Returns TRUE if granted, FALSE if collector already had it.
	if(!bio_samples)
		bio_samples = list()
	var/key = "[race_name]:[tier]"
	if(key in bio_samples)
		return FALSE
	bio_samples -= key
	ApplyBioSample(race_name, tier)
	return TRUE

/mob/proc/ApplyBioSample(race_name, tier)
	// Looks up the registry for this race and tier, then applies passives and skills
	// to src. Called automatically by GiveBioSample, and also by RefreshAllBioSamples.
	var/list/def = BIO_SAMPLE_DEFS[race_name]
	if(!def)
		return
	var/passive_key = "t2_passives"
	var/skill_key = "t2_skills"
	if(tier == 1)
		passive_key = "t1_passives"
		skill_key = "t1_skills"
	var/list/passives_to_apply = def[passive_key]
	var/list/skills_to_apply = def[skill_key]
	if(passives_to_apply && passives_to_apply.len)
		passive_handler.increaseList(passives_to_apply)
	if(skills_to_apply && skills_to_apply.len)
		for(var/skill_path in skills_to_apply)
			AddSkill(new skill_path)

/mob/proc/RefreshAllBioSamples()
	// Re-applies every collected sample on src. Useful after editing BIO_SAMPLE_DEFS
	// values, or after race change / respawn that wipes passives. Safe to call multiple
	// times - passive_handler.increaseList stacks, so call sparingly.
	if(!bio_samples)
		return
	for(var/key in bio_samples)
		var/list/parts = splittext(key, ":")
		if(parts.len < 2)
			continue
		var/race_name = parts[1]
		var/tier = text2num(parts[2])
		ApplyBioSample(race_name, tier)


// ===== STAT PANEL =====
// Called from Stats.dm mob/Players/Stat() when src.BioAndroid is set.

/mob/Players/proc/BioAndroidStatPanel()
	statpanel("Samples")
	if(statpanel("Samples"))
		if(!bio_samples || !bio_samples.len)
			stat("Collected Samples", "(none yet)")
			return
		// Group entries by race so each race shows once with its tier list
		var/list/by_race = list()
		for(var/key in bio_samples)
			var/list/parts = splittext(key, ":")
			if(parts.len < 2)
				continue
			var/race_name = parts[1]
			var/tier_str = parts[2]
			if(!by_race[race_name])
				by_race[race_name] = list()
			by_race[race_name] += tier_str
		for(var/race_name in by_race)
			var/list/tier_list = by_race[race_name]
			stat("[race_name]", "Tier [jointext(tier_list, ", Tier ")]")


// ===== VERBS =====

obj/Skills/Utility

	Collect_Sample
		desc="Request a Tier 1 genetic sample from a nearby player. They must consent. They can only ever donate one Tier 1 sample in their entire life."
		verb/Collect_Sample()
			set category="Utility"
			if(usr.PerfectForm)
				usr<<"You can no longer extract samples."
				return
			if(!usr.BioAndroid)
				usr << "You need Biological Cybernetics installed to collect samples."
				return
			if(usr.Using)
				usr << "You are already running an operation."
				return
			usr.Using = 1

			var/list/Targets = list("Cancel")
			for(var/mob/Players/m in oview(2, usr))
				if(m == usr)
					continue
				if(!m.race)
					continue
				if(m.bio_donated_t1)
					continue
				if(usr.HasBioSample(m.race.name, 1))
					continue
				Targets += m
			if(Targets.len <= 1)
				usr << "No valid donors nearby. Donors must be within 2 tiles, must not have already donated a Tier 1 sample, and you must not already have a Tier 1 sample of their race."
				usr.Using = 0
				return

			var/mob/Players/donor = input(usr, "Whose Tier 1 sample do you want to request?", "Collect Sample") in Targets
			if(donor == "Cancel" || !donor)
				usr.Using = 0
				return
			if(!istype(donor) || get_dist(usr, donor) > 2)
				usr << "[donor] is no longer in range."
				usr.Using = 0
				return

			var/race_name = donor.race.name
			var/answer = alert(donor, "[usr] is requesting a Tier 1 genetic sample of your [race_name] essence. This will not harm you, but you can only ever donate one Tier 1 sample in your entire life. Allow it?", "Bio-Android Sample Request", "Allow", "Deny")
			if(answer != "Allow")
				usr << "[donor] declined the sample request."
				usr.Using = 0
				return

			// Re-validate after the dialog (donor or collector state may have changed)
			if(!donor || get_dist(usr, donor) > 2)
				usr << "[donor] is no longer in range."
				usr.Using = 0
				return
			if(donor.bio_donated_t1)
				usr << "[donor] has already donated a Tier 1 sample."
				usr.Using = 0
				return
			if(usr.HasBioSample(race_name, 1))
				usr << "You already have a Tier 1 sample of [race_name]."
				usr.Using = 0
				return

			donor.bio_donated_t1 = 1
			usr.GiveBioSample(race_name, 1)
			OMsg(usr, "[usr] takes a Tier 1 [race_name] sample from [donor].")
			usr.Using = 0


	Force_Extract
		desc="Forcibly extract a Tier 2 sample from a KO'd target. Severely wounds them. Grants both the Tier 1 and Tier 2 sample of their race."
		verb/Force_Extract()
			set category="Utility"
			if(usr.PerfectForm)
				usr<<"You can no longer extract samples."
				return
			if(!usr.BioAndroid)
				usr << "You need Biological Cybernetics installed to extract samples."
				return
			if(usr.Using)
				usr << "You are already running an operation."
				return
			usr.Using = 1

			var/list/Targets = list("Cancel")
			for(var/mob/Players/m in oview(1, usr))
				if(m == usr)
					continue
				if(!m.race)
					continue
				if(!m.KO)
					continue
				if(usr.HasBioSample(m.race.name, 2))
					continue
				Targets += m
			if(Targets.len <= 1)
				usr << "No valid extraction targets adjacent. Targets must be KO'd, within 1 tile, and you must not already have a Tier 2 sample of their race."
				usr.Using = 0
				return

			var/mob/Players/donor = input(usr, "Whose Tier 2 sample do you want to extract?", "Force Extract") in Targets
			if(donor == "Cancel" || !donor)
				usr.Using = 0
				return
			if(!istype(donor) || get_dist(usr, donor) > 1 || !donor.KO)
				usr << "[donor] is no longer a valid extraction target."
				usr.Using = 0
				return

			var/race_name = donor.race.name
			var/confirm = alert(usr, "Forcibly extract a Tier 2 [race_name] sample from [donor]? They will be left grievously wounded.", "Confirm Extraction", "Extract", "Cancel")
			if(confirm != "Extract")
				usr.Using = 0
				return

			// Re-validate after the confirm dialog
			if(!donor || get_dist(usr, donor) > 1 || !donor.KO)
				usr << "[donor] is no longer a valid extraction target."
				usr.Using = 0
				return
			if(usr.HasBioSample(race_name, 2))
				usr << "You already have a Tier 2 sample of [race_name]."
				usr.Using = 0
				return

			// Apply wounds to the donor
			donor.AddHealthCut(0.05)
			donor.Maimed += 1
			donor.recordMaim(usr, "Bio Sample Extraction")

			// Forced extraction grants both tiers, regardless of donor's prior tier-1 donation status
			usr.GiveBioSample(race_name, 1)
			usr.GiveBioSample(race_name, 2)

			OMsg(usr, "[usr] forcibly carves a Tier 2 [race_name] sample out of [donor].")
			usr.Using = 0


	Bio_Augmentation
		desc="Install a Tier 2 genetic sample of any race directly. Costs a large amount of Mana Bits. No donor required."
		verb/Bio_Augmentation()
			set category="Utility"
			if(usr.PerfectForm)
				usr<<"You can no longer augment yourself."
				return
			if(!usr.BioAndroid)
				usr << "You need Biological Cybernetics installed to install samples."
				return
			if(usr.Using)
				usr << "You are already running an operation."
				return
			usr.Using = 1

			var/list/Choices = list("Cancel")
			for(var/race_name in BIO_SAMPLE_DEFS)
				if(usr.HasBioSample(race_name, 2))
					continue
				Choices += race_name
			if(Choices.len <= 1)
				usr << "You already have Tier 2 samples of every available race."
				usr.Using = 0
				return

			var/race_choice = input(usr, "Which Tier 2 sample do you want to install?", "Bio Augmentation") in Choices
			if(race_choice == "Cancel" || !race_choice)
				usr.Using = 0
				return

			var/Cost = glob.progress.EconomyCost * 1000
			if(!usr.HasMoney(Cost))
				usr << "You need [Cost] resources to install a Tier 2 [race_choice] sample."
				usr.Using = 0
				return

			var/confirm = alert(usr, "Install a Tier 2 [race_choice] sample for [Cost] Mana Bits?", "Confirm Installation", "Install", "Cancel")
			if(confirm != "Install")
				usr.Using = 0
				return

			// Re-validate after the confirm dialog
			if(!usr.HasMoney(Cost))
				usr << "You no longer have enough resources."
				usr.Using = 0
				return
			if(usr.HasBioSample(race_choice, 2))
				usr << "You already have a Tier 2 sample of [race_choice]."
				usr.Using = 0
				return

			usr.TakeMoney(Cost)
			usr.GiveBioSample(race_choice, 2)
			OMsg(usr, "[usr] installs a Tier 2 [race_choice] sample.")
			usr.Using = 0
	Become_Perfect
		desc="Sacrifice 3 of your Tier 2 Bio Android samples to unlock your Perfect Form."
		verb/Bio_Augmentation()
			set category="Utility"
			if(!usr.BioAndroid)
				usr << "You need Biological Cybernetics installed to install samples."
				return
			if(usr.Using)
				usr << "You are already running an operation."
				return
			usr.Using = 1
			var/Samples

			var/list/Choices = list("Cancel")
			var/race_choice = input(usr, "Which Tier 2 sample do you want to remove?", "Bio Augmentation") in Choices
			for(var/race_name in BIO_SAMPLE_DEFS)
				if(usr.HasBioSample(race_name, 2))
				//	continue
					Choices += race_name
					Samples++
			if(Samples<3)
				usr<<"You need at least 3 tier 2 samples to use this!"
				usr.Using = 0
				return

			usr.PerfectForm=1
			usr.RemoveBioSample(race_choice, 2)
			usr.Using = 0
