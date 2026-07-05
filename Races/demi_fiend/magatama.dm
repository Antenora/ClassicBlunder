#define MAGATAMA_SWAP_COOLDOWN 36000 // 1 hour in deciseconds
#define MAGATAMA_COST_ESCALATION 0.25 // +25% base cost per magatama crafted
#define MAGATAMA_IMPRINT_FRACTION 1 // True Demon, base value fraction applied on imprint
#define MAGATAMA_IMPRINT_SCALE   1 // True Demon, fraction of normal scaling rate applied on imprint

mob/var
	magatama_last_swap = 0
	magatama_last_type
	magatama_crafted = 0
	magatama_cooldown_until = 0
	list/magatama_allowed_set = list()
	list/magatama_equip_times = list()
	list/magatama_imprinted = list()
	list/magatama_imprint_active = list()

mob/var/true_demon_power_mult = 0

mob/proc/HasTrueDemonPath()
	return passive_handler?.Get("TrueDemon")

mob/proc/refreshTrueDemonPowerMult()
	if(true_demon_power_mult)
		PowerBoost /= true_demon_power_mult
		true_demon_power_mult = 0
	if(HasTrueDemonPath())
		true_demon_power_mult = 1 + AscensionsAcquired
		PowerBoost *= true_demon_power_mult

mob/proc/getMagatamaEquippedTypes()
	var/list/types = list()
	for(var/obj/Items/Magatama/M in src)
		if(M.suffix == "*Equipped*")
			types[M.type] = 1
	return types

mob/proc/getMagatamaMaxSlots()
	if(passive_handler?.Get("Shijima"))
		return 1 + AscensionsAcquired
	return 1

mob/proc/getMagatamaEquippedCount()
	var/count = 0
	for(var/obj/Items/Magatama/M in src)
		if(M.suffix == "*Equipped*")
			count++
	return count

obj/Items/Magatama
	Stealable = 0
	Pickable = 0
	var/list/base_passives = list()
	var/list/passive_scaling = list()
	var/list/ascension_passives = list()
	var/list/magatama_skills = list()
	var/list/ascension_skills = list()
	var/list/scaled_passives
	var/craft_cost = 0
	var/craft_ascension = 0
	var/mastery = 0
	var/mastery_required_type
	var/mastery_required_amount = 0

	Drop()
		usr << "Magatama are bound to your soul and cannot be dropped."
		return

	verb/Check_Mastery()
		set category = "Demi-fiend"
		set src in usr
		usr << "[name] Mastery: [round(mastery, 0.1)] / 100"

	proc
		gainMastery(amount)
			if(mastery >= 100) return
			var/was_below = mastery < 100
			mastery = min(100, mastery + amount)
			if(was_below && mastery >= 100)
				var/mob/user = loc
				if(user)
					user << "<font color='#FFD700'><b>You have achieved full Mastery over [name]. New possibilities await...</b></font>"
					if(user.HasTrueDemonPath())
						user.imprintMagatama(src)

		getImprintPassives(mob/user)
			// Scaling passives are 25% of base + 50% of normal potential scaling
			// Non-scaling passives get the raw value
			var/list/result = list()
			for(var/p in base_passives)
				var/rate = (p in passive_scaling) ? passive_scaling[p] : 0
				if(rate > 0)
					result[p] = base_passives[p] * MAGATAMA_IMPRINT_FRACTION + potentialBonus(user, rate * MAGATAMA_IMPRINT_SCALE)
				else
					result[p] = base_passives[p]
			for(var/level_str in ascension_passives)
				if(user.AscensionsAcquired >= text2num(level_str))
					var/list/asc_list = ascension_passives[level_str]
					for(var/p in asc_list)
						var/rate = (p in passive_scaling) ? passive_scaling[p] : 0
						var/asc_val
						if(rate > 0)
							asc_val = asc_list[p] * MAGATAMA_IMPRINT_FRACTION + potentialBonus(user, rate * MAGATAMA_IMPRINT_SCALE)
						else
							asc_val = asc_list[p]
						if(p in result)
							result[p] += asc_val
						else
							result[p] = asc_val
			return result

		getMasteryProgress()
			return mastery

		potentialBonus(mob/user, rate)
			if(!rate) return 0
			var/effective_rate = rate
			if(user.passive_handler?.Get("Shijima"))
				effective_rate *= 0.5
			return max(0, user.Potential * effective_rate)

		getScaledPassives(mob/user)
			var/list/result = list()
			for(var/p in base_passives)
				var/rate = (p in passive_scaling) ? passive_scaling[p] : 0
				result[p] = base_passives[p] + potentialBonus(user, rate)
			for(var/level_str in ascension_passives)
				if(user.AscensionsAcquired >= text2num(level_str))
					var/list/asc_list = ascension_passives[level_str]
					for(var/p in asc_list)
						var/rate = (p in passive_scaling) ? passive_scaling[p] : 0
						if(p in result)
							result[p] += asc_list[p] + potentialBonus(user, rate)
						else
							result[p] = asc_list[p] + potentialBonus(user, rate)
			if(user.passive_handler?.Get("Yosuga"))
				var/yosuga_mult = 1 + (0.25 * user.AscensionsAcquired)
				for(var/p in result)
					result[p] *= yosuga_mult
			return result

		grantSkills(mob/user)
			for(var/S in magatama_skills)
				var/obj/Skills/existing = locate(S) in user
				if(!existing)
					user.AddSkill(new S)
			for(var/level_str in ascension_skills)
				if(user.AscensionsAcquired >= text2num(level_str))
					var/list/skill_list = ascension_skills[level_str]
					for(var/S in skill_list)
						var/obj/Skills/existing = locate(S) in user
						if(!existing)
							user.AddSkill(new S)

		revokeSkills(mob/user)
			for(var/S in magatama_skills)
				var/obj/Skills/existing = locate(S) in user
				if(existing) user.DeleteSkill(existing)
			for(var/level_str in ascension_skills)
				var/list/skill_list = ascension_skills[level_str]
				for(var/S in skill_list)
					var/obj/Skills/existing = locate(S) in user
					if(existing) user.DeleteSkill(existing)

		equipMagatama(mob/user)
			suffix = "*Equipped*"
			if(!user.HasTrueDemonPath() || !user.magatama_imprinted || !user.magatama_imprinted[type])
				scaled_passives = getScaledPassives(user)
				user.passive_handler.increaseList(scaled_passives)
			if(!user.passive_handler?.Get("Musubi"))
				grantSkills(user)
			if(!user.passive_handler?.Get("Shijima"))
				user.magatama_last_swap = world.time
				user.magatama_last_type = type
			else
				if(!user.magatama_equip_times) user.magatama_equip_times = list()
				user.magatama_equip_times[type] = world.time
			user << "You ingest [src]. Its power courses through your veins."

		unequipMagatama(mob/user)
			if(user.passive_handler?.Get("Shijima"))
				if(!user.magatama_allowed_set) user.magatama_allowed_set = list()
				user.magatama_allowed_set = user.getMagatamaEquippedTypes()
				user.magatama_cooldown_until = world.time + MAGATAMA_SWAP_COOLDOWN
			if(scaled_passives)
				user.passive_handler.decreaseList(scaled_passives)
				scaled_passives = null
			if(!user.passive_handler?.Get("Musubi"))
				revokeSkills(user)
			suffix = null
			user << "[src]'s influence recedes from your body."

		refreshPassives(mob/user)
			if(suffix != "*Equipped*") return
			if(user.HasTrueDemonPath() && user.magatama_imprinted && user.magatama_imprinted[type])
				if(!user.passive_handler?.Get("Musubi"))
					revokeSkills(user)
					grantSkills(user)
				return
			if(scaled_passives)
				user.passive_handler.decreaseList(scaled_passives)
			scaled_passives = getScaledPassives(user)
			user.passive_handler.increaseList(scaled_passives)
			if(!user.passive_handler?.Get("Musubi"))
				revokeSkills(user)
				grantSkills(user)

	ObjectUse(mob/Players/User = usr)
		if(!(src in User))
			return

		if(!User.isRace(/race/demi_fiend))
			User << "Only a Demi-fiend can harness the power of a Magatama."
			return

		if(suffix == "*Equipped*")
			if(!User.passive_handler?.Get("Musubi"))
				var/can_unequip = 0
				if(User.passive_handler?.Get("Shijima"))
					if(!User.magatama_equip_times) User.magatama_equip_times = list()
					var/equip_time = User.magatama_equip_times[type]
					if(!equip_time)
						can_unequip = 1
					else if(world.time >= equip_time + MAGATAMA_SWAP_COOLDOWN)
						can_unequip = 1
					else if(world.time < equip_time)
						can_unequip = 1
				else if(!User.magatama_last_swap || world.time >= User.magatama_last_swap + MAGATAMA_SWAP_COOLDOWN)
					can_unequip = 1
				else if(world.time < User.magatama_last_swap)
					can_unequip = 1
				if(!can_unequip)
					var/remaining = 0
					if(User.passive_handler?.Get("Shijima") && User.magatama_equip_times && User.magatama_equip_times[type])
						remaining = (User.magatama_equip_times[type] + MAGATAMA_SWAP_COOLDOWN - world.time) / 10
					else
						remaining = (User.magatama_last_swap + MAGATAMA_SWAP_COOLDOWN - world.time) / 10
					var/mins = max(0, round(remaining / 60))
					var/secs = max(0, round(remaining % 60))
					User << "Your body is still bonded to [src]. You must wait [mins]m [secs]s before you can release it."
					return
			unequipMagatama(User)
			return

		var/max_slots = User.getMagatamaMaxSlots()
		if(User.getMagatamaEquippedCount() >= max_slots)
			User << "All your Magatama slots are full ([max_slots]). Unequip one first."
			return

		var/skip_cooldown = User.passive_handler?.Get("Musubi")
		if(!skip_cooldown)
			if(User.passive_handler?.Get("Shijima"))
				if(!User.magatama_allowed_set) User.magatama_allowed_set = list()
				if(!(type in User.magatama_allowed_set))
					if(!User.magatama_cooldown_until || world.time >= User.magatama_cooldown_until || world.time < User.magatama_cooldown_until - MAGATAMA_SWAP_COOLDOWN)
						skip_cooldown = 1
					if(!skip_cooldown && world.time < User.magatama_cooldown_until)
						var/remaining = (User.magatama_cooldown_until - world.time) / 10
						var/mins = max(0, round(remaining / 60))
						var/secs = max(0, round(remaining % 60))
						User << "Your body is still adjusting to your current Magatama. You must wait [mins]m [secs]s before ingesting a different one."
						return
			else if(type != User.magatama_last_type && User.magatama_last_swap)
				if(world.time < User.magatama_last_swap)
					skip_cooldown = 1
				else
					var/elapsed = world.time - User.magatama_last_swap
					if(elapsed < MAGATAMA_SWAP_COOLDOWN)
						var/remaining = (MAGATAMA_SWAP_COOLDOWN - elapsed) / 10
						var/mins = round(remaining / 60)
						var/secs = round(remaining % 60)
						User << "Your body is still adjusting. You must wait [mins]m [secs]s before ingesting a different Magatama."
						return

		equipMagatama(User)

mob/proc/refreshMagatama()
	for(var/obj/Items/Magatama/M in src)
		if(M.suffix == "*Equipped*")
			M.refreshPassives(src)
	refreshImprintedPassives()

mob/proc/buildImprintSnapshot()
	var/list/merged = list()
	for(var/T in magatama_imprinted)
		var/obj/Items/Magatama/M = locate(T) in src
		if(!M) continue
		var/list/passives = M.getImprintPassives(src)
		for(var/p in passives)
			if(!(p in merged) || passives[p] > merged[p])
				merged[p] = passives[p]
	return merged

mob/proc/refreshImprintedPassives()
	if(!HasTrueDemonPath()) return
	if(!magatama_imprinted || !magatama_imprinted.len) return
	if(magatama_imprint_active && magatama_imprint_active.len)
		passive_handler?.decreaseList(magatama_imprint_active)
	magatama_imprint_active = buildImprintSnapshot()
	passive_handler?.increaseList(magatama_imprint_active)

mob/proc/imprintMagatama(obj/Items/Magatama/mag)
	if(!mag) return
	if(!HasTrueDemonPath()) return
	if(!magatama_imprinted) magatama_imprinted = list()
	if(magatama_imprinted[mag.type]) return // already imprinted; idempotent
	magatama_imprinted[mag.type] = TRUE
	refreshImprintedPassives()
	src << "<font color='#FFD700'>The essence of [mag.name] imprints upon your soul, never to fade...</font>"

mob/proc/onTrueDemonAscended()
	// Retroactive imprint sweep
	for(var/obj/Items/Magatama/M in src)
		if(M.mastery >= 100)
			imprintMagatama(M)

mob/proc/revertTrueDemonImprints()
	if(magatama_imprint_active && magatama_imprint_active.len)
		passive_handler?.decreaseList(magatama_imprint_active)
	magatama_imprinted = list()
	magatama_imprint_active = list()

mob/proc/CraftMagatama()
	set name = "Craft Magatama"
	set category = "Demi-fiend"

	if(!isRace(/race/demi_fiend))
		return

	var/list/craft_names = list()
	var/list/craft_paths = list()
	var/list/craft_costs = list()

	for(var/T in subtypesof(/obj/Items/Magatama))
		var/obj/Items/Magatama/template = new T
		if(template.craft_cost <= 0)
			del template
			continue
		if(template.craft_ascension > src.AscensionsAcquired)
			del template
			continue
		if(locate(T) in src)
			del template
			continue
		if(template.mastery_required_type)
			var/obj/Items/Magatama/req = locate(template.mastery_required_type) in src
			if(!req || req.mastery < template.mastery_required_amount)
				del template
				continue
		var/actual_cost = template.craft_cost
		if(!passive_handler?.Get("Musubi"))
			actual_cost = round(template.craft_cost * (1 + magatama_crafted * MAGATAMA_COST_ESCALATION))
		craft_names += template.name
		craft_paths += T
		craft_costs += actual_cost
		del template

	if(!craft_names.len)
		src << "There are no Magatama available to craft right now."
		return

	var/list/display = list()
	for(var/i = 1; i <= craft_names.len; i++)
		display += "[craft_names[i]] ([Commas(craft_costs[i])] Mana Bits)"
	display += "Cancel"

	var/choice = input(src, "Select a Magatama to craft.", "Craft Magatama") in display
	if(choice == "Cancel" || !choice) return

	var/idx = display.Find(choice)
	if(idx < 1 || idx > craft_names.len) return

	var/cost = craft_costs[idx]
	var/craft_path = craft_paths[idx]

	var/obj/Items/mineral/bits = locate(/obj/Items/mineral) in src
	if(!bits || bits.value < cost)
		src << "You need [Commas(cost)] Mana Bits to craft this Magatama."
		return

	src.TakeMineral(cost)
	var/obj/Items/Magatama/M = new craft_path
	src.AddItem(M)
	magatama_crafted++
	src << "You have crafted [M.name]."

	if(passive_handler?.Get("Musubi"))
		var/list/skill_options = list()
		var/list/skill_paths = list()
		for(var/S in M.magatama_skills)
			if(locate(S) in src)
				continue
			var/obj/Skills/temp = new S
			skill_options += temp.name
			skill_paths += S
			del temp
		for(var/level_str in M.ascension_skills)
			for(var/S in M.ascension_skills[level_str])
				if(locate(S) in src)
					continue
				if(S in skill_paths)
					continue
				var/obj/Skills/temp = new S
				skill_options += temp.name
				skill_paths += S
				del temp
		if(skill_options.len)
			var/skill_choice = input(src, "Your inner world expands. Choose one skill from [M.name] to internalize permanently.", "Internalize Skill") in skill_options
			if(skill_choice)
				var/cidx = skill_options.Find(skill_choice)
				if(cidx >= 1 && cidx <= skill_paths.len)
					var/chosen_path = skill_paths[cidx]
					var/obj/Skills/new_skill = new chosen_path
					src.AddSkill(new_skill)
					src << "You have internalized [skill_choice] into your inner world."

obj/Items/Magatama/Marogareh
	name = "Marogareh"
	desc = "The first Magatama, born when the Conception reshaped the world. A writhing, parasitic organism that awakens the demonic potential within its host."
	base_passives = list("UnarmedDamage" = 1, "LifeGeneration" = 0.5, "Flow" = 1, "Instinct" = 1)
	passive_scaling = list("UnarmedDamage" = 0.09, "CounterMaster" = 0.1, "LifeGeneration" = 0.04, "Brutalize" = 0.04, "Flow" = 0.04, "Instinct" = 0.04, "HeavyHitter" = 0.09)
	ascension_passives = list("2" = list("CounterMaster" = 1, "Brutalize" = 1, "HeavyHitter" = 1), "3" = list("ComboMaster" = 1))
	magatama_skills = list(/obj/Skills/AutoHit/DemiFiend/Lunge)
	ascension_skills = list("2" = list(/obj/Skills/AutoHit/DemiFiend/Berserk))

obj/Items/Magatama/Wadatsumi
	name = "Wadatsumi"
	desc = "A Magatama borne of the sea god Wadatsumi. Those who ingest it command the bitter cold and the rhythmic power of ocean waves."
	base_passives = list("ManaCapMult" = 0.2, "WaterSpellDamage" = 0.25, "Chilling" = 2, "WaterSpellCooldown" = 0.1, "WaterSpellManaCost" = 0.1)
	passive_scaling = list("ManaCapMult" = 0.008, "ChillResist" = 0.04, "WaterSpellDamage" = 0.0075, "Chilling" = 0.1, "WaterSpellCooldown" = 0.007, "WaterSpellManaCost" = 0.007, "LikeWater" = 0.04)
	ascension_passives = list("2" = list("ChillResist" = 1, "IceHerald" = 1, "LikeWater" = 1))
	magatama_skills = list(/obj/Skills/AutoHit/DemiFiend/Ice_Breath)
	ascension_skills = list("2" = list(/obj/Skills/AutoHit/DemiFiend/Fog_Breath))
	craft_cost = 5000

obj/Items/Magatama/Ankh
	name = "Ankh"
	desc = "A Magatama shaped like the ancient symbol of life. Its restorative power soothes wounds and wards off the touch of darkness."
	base_passives = list("Godspeed" = 1, "GoodResist" = 1, "LifeGeneration" = 1, "LightSpellDamage" = 0.2, "HolyMod" = 2, "Restoration" = 1)
	passive_scaling = list("Godspeed" = 0.09, "GoodResist" = 0.04, "LifeGeneration" = 0.04, "LightSpellDamage" = 0.008, "HolyMod" = 0.08)
	ascension_passives = list("2" = list("AngelicInfusion" = 1), "3" = list("Purity" = 1), "4" = list("BeyondPurity" = 1))
	magatama_skills = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Dia)
	ascension_skills = list("3" = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Media))
	craft_cost = 5000

obj/Items/Magatama/Iyomante
	name = "Iyomante"
	desc = "A Magatama born from the Ainu bear-sending ritual. Its power enfeebles those who stand against its host, sapping the strength of body and spirit."
	base_passives = list("LifeGeneration" = 1, "ManaGeneration" = 1, "Confusing" = 5, "Disarm" = 1, "ControlResist" = 1, "Unnerve" = 1)
	passive_scaling = list("LifeGeneration" = 0.04, "ManaGeneration" = 0.04, "ManaStats" = 0.05, "Confusing" = 0.25, "Disarm" = 0.02, "ControlResist" = 0.04, "Unnerve" = 0.04, "BuffMastery" = 0.09)
	ascension_passives = list("2" = list("ManaStats" = 2, "BuffMastery" = 1))
	magatama_skills = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Tarunda)
	ascension_skills = list("2" = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Sukunda), "2" = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Rakunda))
	craft_cost = 5000

obj/Items/Magatama/Shiranui
	name = "Shiranui"
	desc = "A Magatama that blazes with foxfire. Named for the mysterious lights that dance above the seas of Kyushu, its sacred flame consumes all in its path."
	base_passives = list("FireSpellDamage" = 0.25, "BurnResist" = 1, "Burning" = 2, "FireSpellCooldown" = 0.1, "FireSpellManaCost" = 0.1)
	passive_scaling = list("FireSpellDamage" = 0.0075, "BurnResist" = 0.04, "Burning" = 0.1, "Combustion" = 0.75, "SpiritHand" = 0.04, "FireSpellCooldown" = 0.007, "FireSpellManaCost" = 0.007)
	ascension_passives = list("2" = list("FireHerald" = 1, "Combustion" = 25, "SpiritHand" = 4))
	magatama_skills = list(/obj/Skills/AutoHit/DemiFiend/Flame_Breath)
	ascension_skills = list("2" = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Taunt))
	craft_cost = 5000

obj/Items/Magatama/Hifumi
	name = "Hifumi"
	desc = "A Magatama of howling gales and cutting force. Named for the opening moves of a master strategist, it bends the wind to its host's will."
	base_passives = list("AirSpellDamage" = 0.25, "ShearResist" = 1, "AirSpellCooldown" = 0.1, "AirSpellManaCost" = 0.1, "QuickCast" = 1)
	passive_scaling = list("AirSpellDamage" = 0.0075, "ShearResist" = 0.04, "BlurringStrikes" = 0.04, "AttackSpeed" = 0.008, "AirSpellCooldown" = 0.007, "AirSpellManaCost" = 0.007, "QuickCast" = 0.04, "Flicker" = 0.09)
	ascension_passives = list("2" = list("AttackSpeed" = 0.2, "BlurringStrikes" = 1, "Flicker" = 1))
	magatama_skills = list(/obj/Skills/Projectile/DemiFiend/Tornado)
	ascension_skills = list("2" = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/War_Cry))
	craft_cost = 5000

obj/Items/Magatama/Kamudo
	name = "Kamudo"
	desc = "A Magatama of the war god's fury. Those who endure its trial become instruments of destruction, wielding power that transcends mortal limits."
	base_passives = list("Brutalize" = 1, "KillerInstinct" = 0.05, "Steady" = 1, "UnarmedDamage" = 1, "CriticalChance" = 5, "CriticalDamage" = 0.05)
	passive_scaling = list("Brutalize" = 0.05, "KillerInstinct" = 0.01, "CriticalChance" = 0.25, "Steady" = 0.09, "MeleeResist" = 0.04, "CriticalDamage" = 0.0045, "UnarmedDamage" = 0.09, "DoubleStrike" = 0.03)
	ascension_passives = list("2" = list("MeleeResist" = 1, "DoubleStrike" = 1))
	magatama_skills = list(/obj/Skills/AutoHit/DemiFiend/Heat_Wave, /obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Focus)
	ascension_skills = list("2" = list(/obj/Skills/Projectile/DemiFiend/Freikugel_Beam))
	craft_cost = 5000
	mastery_required_type = /obj/Items/Magatama/Marogareh
	mastery_required_amount = 100

obj/Items/Magatama/Narukami
	name = "Narukami"
	desc = "A Magatama crackling with divine lightning. It carries the wrath of the thunder god, striking with the fury of the storm."
	base_passives = list("AirSpellDamage" = 0.15, "ShockResist" = 1, "Shocking" = 5, "AirSpellCooldown" = 0.1, "AirSpellManaCost" = 0.1)
	passive_scaling = list("AirSpellDamage" = 0.0085, "ShockResist" = 0.04, "Shocking" = 0.15, "DenkoSekka" = 0.05, "AirSpellCooldown" = 0.007, "AirSpellManaCost" = 0.007, "CriticalChance" = 0.25, "CriticalDamage" = 0.0045)
	ascension_passives = list("2" = list("ThunderHerald" = 1, "DenkoSekka" = 1), "3" = list("CriticalChance" = 5, "CriticalDamage" = 0.05))
	ascension_skills = list("2" = list(/obj/Skills/AutoHit/DemiFiend/Shock))
	craft_cost = 5000

obj/Items/Magatama/Anathema
	name = "Anathema"
	desc = "A Magatama cast from the curse of the excommunicated. Those who ingest it siphon power from the anguish of the damned and return the gift as unblinking judgment."
	base_passives = list("DarkSpellDamage" = 0.25, "Terrifying" = 2, "AbyssMod" = 2, "DarkSpellCooldown" = 0.1, "DarkSpellManaCost" = 0.1)
	passive_scaling = list("EvilResist" = 0.04, "Terrifying" = 0.1, "DarkSpellDamage" = 0.0075, "AbyssMod" = 0.08, "DarkSpellCooldown" = 0.007, "DarkSpellManaCost" = 0.007, "Scorching" = 0.15, "Poisoning" = 0.15, "ManaSteal" = 0.25)
	ascension_passives = list("4" = list("EvilResist" = 1, "Scorching" = 5, "Poisoning" = 5, "ManaSteal" = 5))
	magatama_skills = list(/obj/Skills/AutoHit/DemiFiend/Mamudo_Curse)
	ascension_skills = list("4" = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Evil_Gaze, /obj/Skills/AutoHit/DemiFiend/Mamudoon))
	craft_cost = 15000
	craft_ascension = 3

obj/Items/Magatama/Miasma
	name = "Miasma"
	desc = "A Magatama exhaled by a dying god of winter. Its frigid breath chokes the living and drinks the ice that flows from the wounds it opens."
	base_passives = list("ChillResist" = 2, "WaterSpellCooldown" = 0.2, "WaterSpellManaCost" = 0.2, "WaterSpellDamage" = 0.2, "IceHerald" = 1)
	passive_scaling = list("ChillResist" = 0.03, "ChillAbsorb" = 0.075, "WaterSpellCooldown" = 0.006, "WaterSpellManaCost" = 0.006, "WaterSpellDamage" = 0.008, "Blubber" = 0.04, "FluidForm" = 0.03)
	ascension_passives = list("4" = list("ChillAbsorb" = 1, "Blubber" = 1, "FluidForm" = 1))
	magatama_skills = list(/obj/Skills/AutoHit/DemiFiend/Glacial_Blast_Ice)
	ascension_skills = list("4" = list(/obj/Skills/AutoHit/DemiFiend/Wild_Dance))
	craft_cost = 15000
	craft_ascension = 3
	mastery_required_type = /obj/Items/Magatama/Wadatsumi
	mastery_required_amount = 100

obj/Items/Magatama/Nirvana
	name = "Nirvana"
	desc = "A Magatama that embodies the boundless calm of enlightenment. Its radiance pierces all illusion and grants the bearer perfect poise against every darkness."
	base_passives = list("GoodResist" = 3, "AngelicInfusion" = 1, "LightSpellDamage" = 0.2, "LifeGeneration" = 0.5)
	passive_scaling = list("GoodResist" = 0.04, "HolyMod" = 0.08, "LightSpellDamage" = 0.008, "LifeGeneration" = 0.045, "Reversal" = 0.06, "EnergySteal" = 0.25, "Adaptation" = 0.04)
	ascension_passives = list("4" = list("HolyMod" = 2, "Purity" = 1, "BeyondPurity" = 1, "Reversal" = 0.3, "EnergySteal" = 5, "Adaptation" = 1))
	magatama_skills = list(/obj/Skills/Projectile/DemiFiend/Divine_Shot)
	ascension_skills = list("4" = list(/obj/Skills/AutoHit/DemiFiend/Violet_Flash))
	craft_cost = 15000
	craft_ascension = 3

obj/Items/Magatama/Murakumo
	name = "Murakumo"
	desc = "The famed cloud-gathering blade, reborn as a Magatama. Legends say it cleaves through any illusion, curse, or chain that binds the soul."
	base_passives = list("MeleeResist" = 1, "ControlResist" = 1, "CrippleResist" = 1, "EvilResist" = 1, "Steady" = 1, "Harden" = 2, "GoodResist" = 1)
	passive_scaling = list("MeleeResist" = 0.04, "ControlResist" = 0.04, "CrippleResist" = 0.04, "EvilResist" = 0.04, "Steady" = 0.09, "Harden" = 0.08, "GoodResist" = 0.04, "BurnResist" = 0.04, "ChillResist" = 0.04, "ShearResist" = 0.04)
	ascension_passives = list("4" = list("BurnResist" = 1, "ChillResist" = 1, "ShearResist" = 1))
	magatama_skills = list(/obj/Skills/AutoHit/DemiFiend/Chaos_Blade)
	ascension_skills = list()
	craft_cost = 15000
	craft_ascension = 3

obj/Items/Magatama/Geis
	name = "Geis"
	desc = "A Magatama of inviolable vow. Its oath binds death, ward, and wound alike, shielding its bearer within the weave of sacred geometries."
	base_passives = list("LifeGeneration" = 2, "ManaGeneration" = 5, "LifeSteal" = 20, "Godspeed" = 2, "ManaCapMult" = 0.2, "GoodResist" = 1)
	passive_scaling = list("LifeGeneration" = 0.04, "ManaGeneration" = 0.1, "LifeSteal" = 0.3, "Godspeed" = 0.08, "ManaCapMult" = 0.008, "GoodResist" = 0.04, "SoftStyle" = 0.04)
	ascension_passives = list("4" = list("AngelicInfusion" = 1, "SoftStyle" = 1))
	magatama_skills = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Diarama, /obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Tetraja)
	ascension_skills = list("4" = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Mediarama, /obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Diarahan))
	craft_cost = 15000
	craft_ascension = 3
	mastery_required_type = /obj/Items/Magatama/Ankh
	mastery_required_amount = 100

obj/Items/Magatama/Djed
	name = "Djed"
	desc = "A Magatama shaped like the pillar of stability. Sacred to Osiris, it bears the unshakable spine of order that holds the soul's many bodies aloft."
	base_passives = list("Harden" = 1, "EvilResist" = 1, "GoodResist" = 1, "Steady" = 1, "MeleeResist" = 1)
	passive_scaling = list("Harden" = 0.09, "Steady" = 0.09, "EvilResist" = 0.04, "GoodResist" = 0.04, "ControlResist" = 0.04, "MeleeResist" = 0.04)
	ascension_passives = list("4" = list("ControlResist" = 1, "DebuffReversal" = 1))
	magatama_skills = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Tarukaja, /obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Rakukaja)
	ascension_skills = list("4" = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Sukukaja, /obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Makakaja, /obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Dekaja))
	craft_cost = 15000
	craft_ascension = 3

obj/Items/Magatama/Muspell
	name = "Muspell"
	desc = "A Magatama of the burning south. Its howl unmakes minds, sears tongues silent, and crushes the still-standing underfoot."
	base_passives = list("Brutalize" = 1, "Confusing" = 5, "Harden" = 1, "BurnResist" = 1, "CrippleResist" = 1, "Disarm" = 1)
	passive_scaling = list("Brutalize" = 0.05, "Confusing" = 0.25, "Harden" = 0.09, "BurnResist" = 0.04, "CrippleResist" = 0.04, "Disarm" = 0.02, "ControlResist" = 0.04, "DebuffResistance" = 0.03)
	ascension_passives = list("4" = list("ControlResist" = 1, "DebuffResistance" = 1))
	magatama_skills = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Tentarafoo)
	ascension_skills = list("4" = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Makajamon), "5" = list(/obj/Skills/Projectile/DemiFiend/Xeros_Beat_Proj))
	craft_cost = 15000
	craft_ascension = 3

obj/Items/Magatama/Gehenna
	name = "Gehenna"
	desc = "A Magatama drawn from the valley of infernal judgment. Its flame is older than mercy, and it drinks deep from what it consumes."
	base_passives = list("BurnResist" = 2, "ManaCapMult" = 0.25, "FireSpellManaCost" = 0.2, "FireSpellCooldown" = 0.2, "FireSpellDamage" = 0.2, "Burning" = 5)
	passive_scaling = list("BurnResist" = 0.04, "ManaCapMult" = 0.0075, "FireAbsorb" = 0.0075, "FireSpellManaCost" = 0.006, "FireSpellCooldown" = 0.006, "FireSpellDamage" = 0.008, "Burning" = 0.15, "HybridStrike" = 0.04, "SoulFire" = 0.07)
	ascension_passives = list("4" = list("FireAbsorb" = 1, "FireHerald" = 1, "HybridStrike" = 1, "SoulFire" = 1))
	magatama_skills = list(/obj/Skills/Projectile/DemiFiend/Hellfire_Proj)
	ascension_skills = list("4" = list(/obj/Skills/Projectile/DemiFiend/Magma_Axis_Beam))
	craft_cost = 15000
	craft_ascension = 3
	mastery_required_type = /obj/Items/Magatama/Shiranui
	mastery_required_amount = 100

obj/Items/Magatama/Kamurogi
	name = "Kamurogi"
	desc = "A Magatama imbued with the primordial authority of the Heavenly Ancestors. Its bearer's wounds close on their own, their skin turns aside what would wound them, and every raised hand is met in kind."
	base_passives = list("LifeGeneration" = 1, "CounterMaster" = 2, "SwordDamage" = 1, "AttackSpeed" = 0.2, "LikeWater" = 1)
	passive_scaling = list("LifeGeneration" = 0.04, "CounterMaster" = 0.1, "SwordDamage" = 0.09, "AttackSpeed" = 0.008, "LikeWater" = 0.04, "HardStyle" = 0.04, "Fa Jin" = 0.03, "DoubleStrike" = 0.03, "TripleStrike" = 0.02)
	ascension_passives = list("6" = list("HardStyle" = 1, "Fa Jin" = 1, "DoubleStrike" = 1, "TripleStrike" = 1))
	magatama_skills = list(/obj/Skills/AutoHit/DemiFiend/Blight)
	ascension_skills = list("6" = list(/obj/Skills/AutoHit/DemiFiend/Iron_Claw, /obj/Skills/AutoHit/DemiFiend/Oni_Kagura))
	craft_cost = 30000
	craft_ascension = 5
	mastery_required_type = /obj/Items/Magatama/Kamudo
	mastery_required_amount = 100

obj/Items/Magatama/Satan
	name = "Satan"
	desc = "A Magatama that whispers with the voice of the Adversary. Those who endure its trial become a murderous axis of judgment, striking down the wicked with every blow."
	base_passives = list("EvilResist" = 3, "ManaCapMult" = 0.3, "AbyssMod" = 2, "DarkSpellDamage" = 0.2)
	passive_scaling = list("EvilResist" = 0.05, "ManaCapMult" = 0.007, "AbyssMod" = 0.08, "HellRisen" = 0.0075, "ManaStats" = 0.1, "DemonicDurability" = 0.05, "DarkSpellDamage" = 0.008)
	ascension_passives = list("6" = list("HellRisen" = 0.25, "ManaStats" = 2, "DemonicDurability" = 1, "CursedWounds" = 1, "DemonicInfusion" = 1))
	magatama_skills = list(/obj/Skills/AutoHit/DemiFiend/Deadly_Fury)
	ascension_skills = list()
	craft_cost = 30000
	craft_ascension = 5

obj/Items/Magatama/Adama
	name = "Adama"
	desc = "A Magatama shaped from the red clay of the first-formed. Its bearer draws down the storm — thunder surges through their veins, searing any who dare raise a hand against them."
	base_passives = list("AirSpellDamage" = 0.2, "ManaCapMult" = 0.35, "DenkoSekka" = 2, "AirSpellCooldown" = 0.2, "AirSpellManaCost" = 0.2, "ShockResist" = 1, "Shocking" = 5)
	passive_scaling = list("AirSpellDamage" = 0.008, "ManaCapMult" = 0.0065, "ShockAbsorb" = 0.02, "DenkoSekka" = 0.05, "AirSpellCooldown" = 0.006, "AirSpellManaCost" = 0.006, "ShockResist" = 0.04, "Shocking" = 0.15, "Fury" = 0.06, "Warping" = 0.03)
	ascension_passives = list("6" = list("ThunderHerald" = 1, "ShockAbsorb" = 1, "Fury" = 2, "Warping" = 1))
	magatama_skills = list(/obj/Skills/AutoHit/DemiFiend/Bolt_Storm)
	ascension_skills = list()
	craft_cost = 30000
	craft_ascension = 5
	mastery_required_type = /obj/Items/Magatama/Djed
	mastery_required_amount = 100

obj/Items/Magatama/Vimana
	name = "Vimana"
	desc = "A Magatama shaped like the sky-chariot of the gods. Its bearer rides the howling stratosphere, striking with the swiftness of divine flight."
	base_passives = list("Tenacity" = 1, "BlockChance" = 10, "CriticalBlock" = 0.1, "Harden" = 1, "MeleeResist" = 1, "Steady" = 1, "AttackSpeed" = 0.1)
	passive_scaling = list("Harden" = 0.09, "BlockChance" = 0.2, "CriticalBlock" = 0.0075, "Tenacity" = 0.075, "PhysPleroma" = 0.04, "MeleeResist" = 0.04, "Steady" = 0.09, "AttackSpeed" = 0.008, "Siphon" = 0.04)
	ascension_passives = list("6" = list("PhysPleroma" = 1, "Siphon" = 1))
	magatama_skills = list(/obj/Skills/AutoHit/DemiFiend/Tempest)
	ascension_skills = list("6" = list(/obj/Skills/Projectile/DemiFiend/Javelin_Rain_Proj, /obj/Skills/AutoHit/DemiFiend/Hades_Blast))
	craft_cost = 30000
	craft_ascension = 5
	mastery_required_type = /obj/Items/Magatama/Kamudo
	mastery_required_amount = 100

obj/Items/Magatama/Gundari
	name = "Gundari"
	desc = "A Magatama forged in the likeness of the wrathful guardian. It sharpens its bearer into a coiling blade of wind — unblockable, uncatchable, lethal at the first strike."
	base_passives = list("AirSpellDamage" = 0.2, "Flicker" = 1, "Pursuer" = 1, "ShearResist" = 1, "QuickCast" = 1, "AirSpellCooldown" = 0.1, "AirSpellManaCost" = 0.1)
	passive_scaling = list("AirSpellDamage" = 0.008, "ShearResist" = 0.04, "WindAbsorb" = 0.02, "QuickCast" = 0.04, "AirSpellCooldown" = 0.007, "AirSpellManaCost" = 0.007, "MovementMastery" = 0.09, "Speed Force" = 0.03, "Flicker" = 0.09, "Pursuer" = 0.09)
	ascension_passives = list("6" = list("WindAbsorb" = 1, "MovementMastery" = 1, "Speed Force" = 1))
	magatama_skills = list(/obj/Skills/AutoHit/DemiFiend/Wind_Cutter_Gust)
	ascension_skills = list("6" = list(/obj/Skills/Projectile/DemiFiend/Spiral_Viper_Beam))
	craft_cost = 30000
	craft_ascension = 5
	mastery_required_type = /obj/Items/Magatama/Nirvana
	mastery_required_amount = 100

obj/Items/Magatama/Sophia
	name = "Sophia"
	desc = "A Magatama of pure, crystalline wisdom. Its bearer becomes a vessel of holy light — smiting the unclean and bathing their allies in restorative radiance."
	base_passives = list("AngelicInfusion" = 1, "LightSpellDamage" = 0.2, "LifeSteal" = 30, "GoodResist" = 2, "HolyMod" = 2, "LifeGeneration" = 1, "Godspeed" = 2)
	passive_scaling = list("LightSpellDamage" = 0.008, "LifeSteal" = 0.2, "GoodResist" = 0.04, "LightSpellCooldown" = 0.008, "LightSpellManaCost" = 0.008, "HolyMod" = 0.08, "LifeGeneration" = 0.04, "Godspeed" = 0.08)
	ascension_passives = list("6" = list("LightSpellCooldown" = 0.02, "LightSpellManaCost" = 0.02))
	magatama_skills = list(/obj/Skills/AutoHit/DemiFiend/Thunderclap_Storm)
	ascension_skills = list("6" = list(/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Mediarahan, /obj/Skills/AutoHit/DemiFiend/Holy_Wrath))
	craft_cost = 30000
	craft_ascension = 5
	mastery_required_type = /obj/Items/Magatama/Geis
	mastery_required_amount = 100

obj/Items/Magatama/Gaea
	name = "Gaea"
	desc = "A Magatama that beats with the slow heart of the living earth. Its bearer becomes an unstoppable avalanche of violence — every swing a sweeping carnage, every wound answered with greater wrath."
	base_passives = list("CounterMaster" = 1, "SweepingStrike" = 1, "GiantSwings" = 1, "PhysPleroma" = 2, "Zornhau" = 1, "EarthHerald" = 1, "Shatter" = 5)
	passive_scaling = list("CounterMaster" = 0.1, "GiantSwings" = 0.01, "KillerInstinct" = 0.01, "UnarmedDamage" = 0.09, "PhysPleroma" = 0.04, "Zornhau" = 0.04, "Shatter" = 0.15)
	ascension_passives = list("6" = list("UnarmedDamage" = 1, "KillerInstinct" = 0.075))
	magatama_skills = list(/obj/Skills/AutoHit/DemiFiend/Deathbound)
	ascension_skills = list("6" = list(/obj/Skills/AutoHit/DemiFiend/Gaea_Rage))
	craft_cost = 50000
	craft_ascension = 5
	mastery_required_type = /obj/Items/Magatama/Kamurogi
	mastery_required_amount = 100

obj/Items/Magatama/Kailash
	name = "Kailash"
	desc = "A Magatama that hums with the silence of the unreachable peak. Its bearer strikes with the weight of the underworld itself — a single blow capable of breaking armies."
	base_passives = list("MeleeResist" = 1, "TechniqueMastery" = 1, "PowerfulCasting" = 0.5, "Vortex" = 5, "Entropic" = 0.5)
	passive_scaling = list("MeleeResist" = 0.04, "TechniqueMastery" = 0.09, "PowerfulCasting" = 0.015, "Vortex" = 0.2, "Entropic" = 0.035, "PUSpike" = 0.5, "DeathField" = 0.09, "VoidField" = 0.09)
	ascension_passives = list("6" = list("SuperDash" = 1, "PUSpike" = 50, "DeathField" = 1, "VoidField" = 1))
	magatama_skills = list(/obj/Skills/Projectile/DemiFiend/Freikugel_Beam)
	ascension_skills = list()
	craft_cost = 50000
	craft_ascension = 5
