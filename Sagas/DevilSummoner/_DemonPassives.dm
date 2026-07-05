var/global/list/DEMON_PASSIVE_DB = list()

/datum/demon_passive
	var/passive_name  = ""
	var/description   = ""
	var/category      = ""   // "stat" / "resist" / "trigger" / "ailment" / "special"
	var/element       = ""   // For element-specific passives ("Fire", "Ice", "Elec", "Force", "Phys", "Almighty", "Curse")

	New(name, desc, cat, elem = "")
		passive_name = name
		description  = desc
		category     = cat
		element      = elem

/proc/InitDemonPassives()
	// Build into a local list and assign at the end — BYOND 516 has a quirk where
	// `DEMON_PASSIVE_DB = list()` followed immediately by indexing fails with "bad index".
	var/list/pdb = list()

	// ===== STAT BOOSTS =====
	pdb["Phys Boost"]   = new /datum/demon_passive("Phys Boost",  "Demon Str x1.5.",                              "stat", "Phys")
	pdb["Phys Amp"]     = new /datum/demon_passive("Phys Amp",    "Demon Str x2.0.",                              "stat", "Phys")
	pdb["Phys Up"]      = new /datum/demon_passive("Phys Up",     "Demon Str x1.2.",                              "stat", "Phys")
	pdb["Fire Boost"]   = new /datum/demon_passive("Fire Boost",  "+20% damage to demon's fire attacks.",         "stat", "Fire")
	pdb["Fire Amp"]     = new /datum/demon_passive("Fire Amp",    "+50% damage to demon's fire attacks.",         "stat", "Fire")
	pdb["Ice Boost"]    = new /datum/demon_passive("Ice Boost",   "+20% damage to demon's ice attacks.",          "stat", "Ice")
	pdb["Ice Amp"]      = new /datum/demon_passive("Ice Amp",     "+50% damage to demon's ice attacks.",          "stat", "Ice")
	pdb["Elec Boost"]   = new /datum/demon_passive("Elec Boost",  "+20% damage to demon's electric attacks.",     "stat", "Elec")
	pdb["Elec Amp"]     = new /datum/demon_passive("Elec Amp",    "+50% damage to demon's electric attacks.",     "stat", "Elec")
	pdb["Force Boost"]  = new /datum/demon_passive("Force Boost", "+20% damage to demon's force attacks.",        "stat", "Force")
	pdb["Force Amp"]    = new /datum/demon_passive("Force Amp",   "+50% damage to demon's force attacks.",        "stat", "Force")
	pdb["Crit Up"]      = new /datum/demon_passive("Crit Up",     "Demon gains +0.75 CriticalDamage.",            "stat")
	pdb["Pierce"]       = new /datum/demon_passive("Pierce",      "Demon gains +9 Brutalize.",                    "stat", "Phys")

	// ===== RESISTS =====
	pdb["Anti-Phys"]    = new /datum/demon_passive("Anti-Phys",   "-25% damage taken from normal attacks/queues.","resist", "Phys")
	pdb["Anti-Fire"]    = new /datum/demon_passive("Anti-Fire",   "-50% damage taken from fire spells/skills.",   "resist", "Fire")
	pdb["Anti-Ice"]     = new /datum/demon_passive("Anti-Ice",    "-50% damage taken from water spells/skills.",  "resist", "Ice")
	pdb["Anti-Elec"]    = new /datum/demon_passive("Anti-Elec",   "-50% damage taken from lightning spells.",     "resist", "Elec")
	pdb["Anti-Force"]   = new /datum/demon_passive("Anti-Force",  "-50% damage taken from wind spells/skills.",   "resist", "Force")
	pdb["Anti-Curse"]   = new /datum/demon_passive("Anti-Curse",  "-50% damage taken from dark spells/skills.",   "resist", "Curse")
	pdb["Anti-Almighty"]= new /datum/demon_passive("Anti-Almighty","Demon gains DebuffReversal.",                 "resist", "Almighty")
	pdb["Anti-Ailment"] = new /datum/demon_passive("Anti-Ailment","Demon gains +2 DebuffResistance.",             "resist")
	pdb["Anti-Most"]    = new /datum/demon_passive("Anti-Most",   "Demon End x2.",                                "resist")
	pdb["Anti-All"]     = new /datum/demon_passive("Anti-All",    "All damage taken halved.",                     "resist")

	// ===== NULLS =====
	pdb["Null Phys"]    = new /datum/demon_passive("Null Phys",   "-50% damage from normal attacks/queues.",      "resist", "Phys")
	pdb["Null Fire"]    = new /datum/demon_passive("Null Fire",   "Fully nullifies fire damage.",                 "resist", "Fire")
	pdb["Null Ice"]     = new /datum/demon_passive("Null Ice",    "Fully nullifies water damage.",                "resist", "Ice")
	pdb["Null Elec"]    = new /datum/demon_passive("Null Elec",   "Fully nullifies lightning damage.",            "resist", "Elec")
	pdb["Null Force"]   = new /datum/demon_passive("Null Force",  "Fully nullifies wind damage.",                 "resist", "Force")
	pdb["Null Curse"]   = new /datum/demon_passive("Null Curse",  "Fully nullifies dark damage.",                 "resist", "Curse")

	// ===== DRAINS =====
	pdb["Phys Drain"]   = new /datum/demon_passive("Phys Drain",  "Heals 25% / -75% damage from phys.",           "resist", "Phys")
	pdb["Fire Drain"]   = new /datum/demon_passive("Fire Drain",  "Heals 25% / -75% damage from fire.",           "resist", "Fire")
	pdb["Ice Drain"]    = new /datum/demon_passive("Ice Drain",   "Heals 25% / -75% damage from water.",          "resist", "Ice")
	pdb["Elec Drain"]   = new /datum/demon_passive("Elec Drain",  "Heals 25% / -75% damage from lightning.",      "resist", "Elec")
	pdb["Force Drain"]  = new /datum/demon_passive("Force Drain", "Heals 25% / -75% damage from wind.",           "resist", "Force")

	// ===== REPELS =====
	pdb["Phys Repel"]   = new /datum/demon_passive("Phys Repel",  "Reflects 25% / -75% damage from phys.",        "resist", "Phys")
	pdb["Fire Repel"]   = new /datum/demon_passive("Fire Repel",  "Reflects 25% / -75% damage from fire.",        "resist", "Fire")
	pdb["Ice Repel"]    = new /datum/demon_passive("Ice Repel",   "Reflects 25% / -75% damage from water.",       "resist", "Ice")
	pdb["Elec Repel"]   = new /datum/demon_passive("Elec Repel",  "Reflects 25% / -75% damage from lightning.",   "resist", "Elec")
	pdb["Force Repel"]  = new /datum/demon_passive("Force Repel", "Reflects 25% / -75% damage from wind.",        "resist", "Force")

	// ===== HP/MP CAPACITY =====
	pdb["Life Bonus"]   = new /datum/demon_passive("Life Bonus",  "+10% demon Max HP.",                           "stat")
	pdb["Life Lift"]    = new /datum/demon_passive("Life Lift",   "Demon gains +5 LifeGeneration.",               "stat")
	pdb["Life Surge"]   = new /datum/demon_passive("Life Surge",  "+30% demon Max HP.",                           "stat")
	pdb["Life Stream"]  = new /datum/demon_passive("Life Stream", "+50% demon Max HP.",                           "stat")
	pdb["Life Aid"]     = new /datum/demon_passive("Life Aid",    "Demon gains +2 LifeGeneration.",               "stat")
	pdb["Mana Bonus"]   = new /datum/demon_passive("Mana Bonus",  "User: +10% mana cap.",                         "stat")
	pdb["Mana Surge"]   = new /datum/demon_passive("Mana Surge",  "User: +30% mana cap.",                         "stat")
	pdb["Mana Stream"]  = new /datum/demon_passive("Mana Stream", "User: +50% mana cap.",                         "stat")
	pdb["Mana Aid"]     = new /datum/demon_passive("Mana Aid",    "User: +5 ManaGeneration.",                     "stat")

	// ===== AILMENT INFLICTORS =====
	pdb["+Forget"]      = new /datum/demon_passive("+Forget",     "Demon gains +3 Disarm.",                       "ailment")
	pdb["+Paralyze"]    = new /datum/demon_passive("+Paralyze",   "Demon's normal attacks inflict shock.",        "ailment")
	pdb["+Poison"]      = new /datum/demon_passive("+Poison",     "Demon's normal attacks inflict poison.",       "ailment")
	pdb["+Stone"]       = new /datum/demon_passive("+Stone",      "Demon's normal attacks inflict shatter.",      "ailment")

	// ===== TRIGGERS =====
	pdb["Counter"]       = new /datum/demon_passive("Counter",       "Demon gains +2 Parry (tied to Counter).",    "trigger")
	pdb["Retaliate"]     = new /datum/demon_passive("Retaliate",     "Demon gains +4 Parry.",                      "trigger")
	pdb["Endure"]        = new /datum/demon_passive("Endure",        "Demon gains Color of Courage (UndyingRage).","trigger")
	pdb["Drain Hit"]     = new /datum/demon_passive("Drain Hit",     "Demon gains +50 LifeSteal.",                 "trigger")
	pdb["Avenge"]        = new /datum/demon_passive("Avenge",        "Demon gains +6 Parry.",                      "trigger")
	pdb["Dodge"]         = new /datum/demon_passive("Dodge",         "Demon Def x1.5.",                            "trigger")
	pdb["Watchful"]      = new /datum/demon_passive("Watchful",      "Reduces ambush chance. (does nothing atm)",                     "trigger")
	pdb["Vigilant"]      = new /datum/demon_passive("Vigilant",      "Greatly reduces ambush chance. (does nothing atm)",             "trigger")
	pdb["Ultimate Hit"]  = new /datum/demon_passive("Ultimate Hit",  "Demon's normal attacks inflict all almighty debuffs.","trigger")

	// ===== SPECIALS =====
	pdb["Double Strike"] = new /datum/demon_passive("Double Strike", "Demon gains +5 DoubleStrike.",                              "special")
	pdb["Attack All"]    = new /datum/demon_passive("Attack All",    "User: gains SweepingStrike while demon summoned.",          "special")
	pdb["Quick Move"]    = new /datum/demon_passive("Quick Move",    "Demon Spd x1.5.",                                           "special")
	pdb["Swift Step"]    = new /datum/demon_passive("Swift Step",    "Demon Spd x2.0.",                                           "special")
	pdb["Dual Shadow"]   = new /datum/demon_passive("Dual Shadow",   "25% chance demon's skills trigger twice.",                  "special")
	pdb["Victory Cry"]   = new /datum/demon_passive("Victory Cry",   "Recovers HP/Energy on kill.",                               "special")
	pdb["Ares Aid"]      = new /datum/demon_passive("Ares Aid",      "Demon gains +50 CriticalChance, +0.25 CriticalDamage.",     "special")
	pdb["Hero Aid"]      = new /datum/demon_passive("Hero Aid",      "Demon gains +25 CriticalChance, +0.25 CriticalDamage.",     "special")
	pdb["Hero Soul"]     = new /datum/demon_passive("Hero Soul",     "User: -75% damage; demon takes 100% of that damage.",       "special")
	pdb["Knight Soul"]   = new /datum/demon_passive("Knight Soul",   "User: -25% damage; demon takes 300% of that damage.",       "special")
	pdb["Paladin Soul"]  = new /datum/demon_passive("Paladin Soul",  "User: -50% damage; demon takes 200% of that damage.",       "special")
	pdb["Extra One"]     = new /datum/demon_passive("Extra One",     "User: gains +5 TechniqueMastery while demon summoned.",     "special")
	pdb["Extra Bonus"]   = new /datum/demon_passive("Extra Bonus",   "Demon's skill cooldowns reduced by ~15% (uncapped).",       "special")
	pdb["Preserve Extra"]= new /datum/demon_passive("Preserve Extra","Halves cooldown of next skill on kill.",                    "special")
	pdb["Grimoire"]      = new /datum/demon_passive("Grimoire",      "Demon inflicts more statuses from its attacks.",            "special")
	pdb["Moneybags"]     = new /datum/demon_passive("Moneybags",     "User: 1.25x EconomyMult while demon summoned.",             "special")
	pdb["Race-O"]        = new /datum/demon_passive("Race-O",        "Boosts damage vs same race enemies.",                       "special")
	pdb["Race-D"]        = new /datum/demon_passive("Race-D",        "Reduces damage from same race enemies.",                    "special")

	DEMON_PASSIVE_DB = pdb

/mob/Player/AI/Demon
	// Resist multipliers per element (1.0 = normal; lower = resist)
	var/resist_phys     = 1.0
	var/resist_fire     = 1.0
	var/resist_ice      = 1.0
	var/resist_elec     = 1.0
	var/resist_force    = 1.0
	var/resist_curse    = 1.0
	var/resist_almighty = 1.0

	// Per-element flags for repel/drain (these add 75% reduction + reflect/heal 25%)
	var/passive_repel_phys = FALSE
	var/passive_repel_fire = FALSE
	var/passive_repel_ice  = FALSE
	var/passive_repel_elec = FALSE
	var/passive_repel_force= FALSE
	var/passive_drain_phys = FALSE
	var/passive_drain_fire = FALSE
	var/passive_drain_ice  = FALSE
	var/passive_drain_elec = FALSE
	var/passive_drain_force= FALSE

	// Outgoing element damage multipliers (ForMod is also boosted)
	var/dmg_mult_fire   = 1.0
	var/dmg_mult_ice    = 1.0
	var/dmg_mult_elec   = 1.0
	var/dmg_mult_force  = 1.0

	// Ailment add-ons
	var/passive_add_paralyze   = 0
	var/passive_add_poison     = 0
	var/passive_add_stone      = 0
	var/passive_grimoire_active= FALSE
	var/passive_ultimate_hit_active = FALSE

	// Specials
	var/passive_double_strike  = FALSE
	var/passive_attack_all     = FALSE
	var/passive_dual_shadow    = FALSE
	var/passive_victory_cry    = FALSE
	var/passive_extra_one      = FALSE
	var/passive_race_o         = FALSE
	var/passive_race_d         = FALSE

	// Stream/Aid
	var/passive_life_stream_active = FALSE
	var/passive_loop_gen        = 0

	// Track applied passives so RemoveDemonPassives() knows what to undo
	var/list/applied_passives   = null
	// Owner-side mods
	var/list/passive_owner_grants = null

	var/demon_base_str = 0
	var/demon_base_for = 0
	var/demon_base_end = 0
	var/demon_base_spd = 0
	var/demon_base_def = 0

/mob/Player/AI/Demon/proc/ApplyDemonPassives()
	if(!demon_data) return
	if(!ai_owner)   return
	var/datum/party_demon/pd = DemonGetPartyDemon()
	if(!pd) return
	if(!pd.passives || !pd.passives.len) return

	// Ensure passive_handler exists on the demon mob
	if(!passive_handler) passive_handler = new()

	// Wipe any prior grants from this demon before re-applying.
	// Stops owner-side passives (ManaCapMult etc) from stacking if Apply runs twice.
	if(passive_owner_grants && passive_owner_grants.len)
		RemoveDemonPassives()

	if(!applied_passives)    applied_passives    = list()
	if(!passive_owner_grants) passive_owner_grants = list()

	for(var/pname in pd.passives)
		if(pname in applied_passives) continue
		ApplyOnePassive(pname)
		applied_passives += pname


/mob/Player/AI/Demon/proc/GrantOwnerPassive(key, val)
	if(!ai_owner) return
	if(!ai_owner.passive_handler) ai_owner.passive_handler = new()
	ai_owner.passive_handler.Increase(key, val)
	if(!passive_owner_grants) passive_owner_grants = list()
	passive_owner_grants[key] += val

/mob/Player/AI/Demon/proc/ApplyOnePassive(pname)
	switch(pname)

		if("Phys Up")    StrMultTotal *= 1.20
		if("Phys Boost") StrMultTotal *= 1.50
		if("Phys Amp")   StrMultTotal *= 2.00
		if("Quick Move") SpdMultTotal *= 1.50
		if("Swift Step") SpdMultTotal *= 2.00
		if("Dodge")      DefMultTotal *= 1.50
		if("Anti-Most")  EndMultTotal *= 2.00


		if("Life Bonus")  EndMultTotal *= 1.20
		if("Life Surge")  EndMultTotal *= 1.50
		if("Life Stream")
			EndMultTotal *= 2
			passive_life_stream_active = TRUE
			spawn() DemonLifeStreamLoop()


		if("Fire Boost")
			dmg_mult_fire *= 1.20
			ForMultTotal  *= 1.20
		if("Fire Amp")
			dmg_mult_fire *= 1.50
			ForMultTotal  *= 1.50
		if("Ice Boost")
			dmg_mult_ice *= 1.20
			ForMultTotal *= 1.20
		if("Ice Amp")
			dmg_mult_ice *= 1.50
			ForMultTotal *= 1.50
		if("Elec Boost")
			dmg_mult_elec *= 1.20
			ForMultTotal  *= 1.20
		if("Elec Amp")
			dmg_mult_elec *= 1.50
			ForMultTotal  *= 1.50
		if("Force Boost")
			dmg_mult_force *= 1.20
			ForMultTotal   *= 1.20
		if("Force Amp")
			dmg_mult_force *= 1.50
			ForMultTotal   *= 1.50

		// =================== RESISTS (DEMON) ===================
		if("Anti-Phys")     resist_phys  *= 0.75
		if("Anti-Fire")     resist_fire  *= 0.50
		if("Anti-Ice")      resist_ice   *= 0.50
		if("Anti-Elec")     resist_elec  *= 0.50
		if("Anti-Force")    resist_force *= 0.50
		if("Anti-Curse")    resist_curse *= 0.50
		if("Anti-All")
			resist_phys     *= 0.50
			resist_fire     *= 0.50
			resist_ice      *= 0.50
			resist_elec     *= 0.50
			resist_force    *= 0.50
			resist_curse    *= 0.50
			resist_almighty *= 0.50
		if("Anti-Ailment")
			passive_handler.Increase("DebuffResistance", 2)
		if("Anti-Almighty")
			passive_handler.Increase("DebuffReversal", 1)

		// =================== NULLS (DEMON) ===================
		if("Null Phys")  resist_phys   = 0.50
		if("Null Fire")  resist_fire   = 0
		if("Null Ice")   resist_ice    = 0
		if("Null Elec")  resist_elec   = 0
		if("Null Force") resist_force  = 0
		if("Null Curse") resist_curse  = 0

		// =================== DRAINS (heal 25%, take 25%) ===================
		if("Phys Drain")  passive_drain_phys = TRUE
		if("Fire Drain")  passive_drain_fire = TRUE
		if("Ice Drain")   passive_drain_ice  = TRUE
		if("Elec Drain")  passive_drain_elec = TRUE
		if("Force Drain") passive_drain_force= TRUE

		// =================== REPELS (reflect 25%, take 25%) ===================
		if("Phys Repel")  passive_repel_phys = TRUE
		if("Fire Repel")  passive_repel_fire = TRUE
		if("Ice Repel")   passive_repel_ice  = TRUE
		if("Elec Repel")  passive_repel_elec = TRUE
		if("Force Repel") passive_repel_force= TRUE

		// =================== AILMENT INFLICTORS (DEMON) ===================
		if("+Paralyze")   passive_add_paralyze = 25  // shock
		if("+Poison")     passive_add_poison   = 25  // poison
		if("+Stone")      passive_add_stone    = 20  // shatter
		if("+Forget")     passive_handler.Increase("Disarm", 3)

		// =================== TRIGGERS via passive_handler (DEMON) ===================
		if("Counter")
			passive_handler.Increase("Parry", 2)
		if("Retaliate")
			passive_handler.Increase("Parry", 4)
		if("Avenge")
			passive_handler.Increase("Parry", 6)
		if("Endure")
			passive_handler.Increase("Color of Courage", 1)
		if("Drain Hit")
			passive_handler.Increase("LifeSteal", 50)
		if("Crit Up")
			passive_handler.Increase("CriticalDamage", 0.75)
		if("Hero Aid")
			passive_handler.Increase("CriticalChance", 25)
			passive_handler.Increase("CriticalDamage", 0.25)
		if("Ares Aid")
			passive_handler.Increase("CriticalChance", 50)
			passive_handler.Increase("CriticalDamage", 0.25)
		if("Pierce")
			passive_handler.Increase("Brutalize", 9)
		if("Double Strike")
			passive_double_strike = TRUE
			passive_handler.Increase("DoubleStrike", 5)
		if("Life Aid")
			passive_handler.Increase("LifeGeneration", 2)
		if("Life Lift")
			passive_handler.Increase("LifeGeneration", 5)

		// =================== SPECIALS (DEMON) ===================
		if("Dual Shadow")     passive_dual_shadow   = TRUE
		if("Ultimate Hit")    passive_ultimate_hit_active = TRUE
		if("Grimoire")        passive_grimoire_active = TRUE
		if("Victory Cry")     passive_victory_cry   = TRUE
		if("Race-O")          passive_race_o        = TRUE
		if("Race-D")          passive_race_d        = TRUE
		if("Extra Bonus")
			// +1.5 TechniqueMastery → ~13% cd reduction (close to spec's 15%)
			passive_handler.Increase("TechniqueMastery", 1.5)

		// =================== USER-AFFECTING PASSIVES ===================
		if("Knight Soul")
			if(ai_owner)
				ai_owner.demon_soul_dmg_pct      = max(ai_owner.demon_soul_dmg_pct,      0.25)
				ai_owner.demon_soul_transfer_pct = max(ai_owner.demon_soul_transfer_pct, 3.0)
		if("Paladin Soul")
			if(ai_owner)
				ai_owner.demon_soul_dmg_pct      = max(ai_owner.demon_soul_dmg_pct,      0.50)
				ai_owner.demon_soul_transfer_pct = max(ai_owner.demon_soul_transfer_pct, 2.0)
		if("Hero Soul")
			if(ai_owner)
				ai_owner.demon_soul_dmg_pct      = max(ai_owner.demon_soul_dmg_pct,      0.75)
				ai_owner.demon_soul_transfer_pct = max(ai_owner.demon_soul_transfer_pct, 1.0)
		if("Moneybags")
			if(ai_owner)
				ai_owner.EconomyMult *= 2
				if(!passive_owner_grants) passive_owner_grants = list()
				passive_owner_grants["EconomyMult_x2"] = 1
		if("Mana Bonus")   ApplyOwnerManaCap(0.10)
		if("Mana Surge")   ApplyOwnerManaCap(0.30)
		if("Mana Stream")  ApplyOwnerManaCap(0.50)
		if("Mana Aid")     GrantOwnerPassive("ManaGeneration", 5)
		if("Attack All")
			passive_attack_all = TRUE
			GrantOwnerPassive("SweepingStrike", 1)
		if("Extra One")
			passive_extra_one = TRUE
			GrantOwnerPassive("TechniqueMastery", 5)


/mob/Player/AI/Demon/proc/ApplyOwnerManaCap(pct)
	if(!ai_owner || !ai_owner.passive_handler) return
	ai_owner.passive_handler.Increase("ManaCapMult", pct)
	if(!passive_owner_grants) passive_owner_grants = list()
	passive_owner_grants["ManaCapMult"] = (passive_owner_grants["ManaCapMult"] || 0) + pct

/mob/Player/AI/Demon/proc/RemoveDemonPassives()
	passive_loop_gen++   // halts any loops

	if(ai_owner && passive_owner_grants)
		for(var/k in passive_owner_grants)
			var/v = passive_owner_grants[k]
			switch(k)
				if("EnergyMax")
					ai_owner.EnergyMax -= v
					if(ai_owner.Energy > ai_owner.EnergyMax)
						ai_owner.Energy = ai_owner.EnergyMax
				if("EconomyMult_x2")
					ai_owner.EconomyMult /= 2
				else
					if(ai_owner.passive_handler)
						ai_owner.passive_handler.Decrease(k, v)
		passive_owner_grants.Cut()
	// Clear demon-soul redirection on owner
	if(ai_owner)
		ai_owner.demon_soul_dmg_pct      = 0
		ai_owner.demon_soul_transfer_pct = 0
	// Prevents stacking
	if(applied_passives) applied_passives.Cut()

	resist_phys     = 1.0
	resist_fire     = 1.0
	resist_ice      = 1.0
	resist_elec     = 1.0
	resist_force    = 1.0
	resist_curse    = 1.0
	resist_almighty = 1.0

	passive_repel_phys  = FALSE
	passive_repel_fire  = FALSE
	passive_repel_ice   = FALSE
	passive_repel_elec  = FALSE
	passive_repel_force = FALSE
	passive_drain_phys  = FALSE
	passive_drain_fire  = FALSE
	passive_drain_ice   = FALSE
	passive_drain_elec  = FALSE
	passive_drain_force = FALSE

	dmg_mult_fire   = 1.0
	dmg_mult_ice    = 1.0
	dmg_mult_elec   = 1.0
	dmg_mult_force  = 1.0

	StrMultTotal = 1.0
	ForMultTotal = 1.0
	EndMultTotal = 1.0
	SpdMultTotal = 1.0
	DefMultTotal = 1.0

	passive_add_paralyze        = 0
	passive_add_poison          = 0
	passive_add_stone           = 0
	passive_double_strike       = FALSE
	passive_attack_all          = FALSE
	passive_dual_shadow         = FALSE
	passive_ultimate_hit_active = FALSE
	passive_grimoire_active     = FALSE
	passive_victory_cry         = FALSE
	passive_race_o              = FALSE
	passive_race_d              = FALSE
	passive_extra_one           = FALSE

	if(demon_base_str)
		StrMod = demon_base_str
		ForMod = demon_base_for
		EndMod = demon_base_end
		SpdMod = demon_base_spd
		DefMod = demon_base_def

	passive_handler = new()

	passive_life_stream_active = FALSE



/mob/Player/AI/Demon/proc/DemonLifeStreamLoop()
	set waitfor = FALSE
	var/my_gen = passive_loop_gen
	while(src && passive_life_stream_active && my_gen == passive_loop_gen)
		if(demon_hp > 0 && demon_hp < 100)
			demon_hp = min(100, demon_hp + 5)
			var/datum/party_demon/pd = DemonGetPartyDemon()
			if(pd) pd.current_hp = demon_hp
		sleep(50)


/mob/Player/AI/Demon/proc/DemonGetResistMult(element)
	switch(element)
		if("Phys", "Physical")  return resist_phys
		if("Fire")              return resist_fire
		if("Ice")               return resist_ice
		if("Elec")              return resist_elec
		if("Force")             return resist_force
		if("Curse")             return resist_curse
		if("Almighty")          return resist_almighty
	return 1.0

// Damage multiplier for outgoing element (ForMod is also boosted)
/mob/Player/AI/Demon/proc/DemonGetDamageMult(element)
	switch(element)
		if("Fire")              return dmg_mult_fire
		if("Ice")               return dmg_mult_ice
		if("Elec")              return dmg_mult_elec
		if("Force")             return dmg_mult_force
	return 1.0


/mob/Player/AI/Demon/proc/DemonHasRepel(element)
	switch(element)
		if("Phys", "Physical")  return passive_repel_phys
		if("Fire")              return passive_repel_fire
		if("Ice")               return passive_repel_ice
		if("Elec")              return passive_repel_elec
		if("Force")             return passive_repel_force
	return FALSE


/mob/Player/AI/Demon/proc/DemonHasDrain(element)
	switch(element)
		if("Phys", "Physical")  return passive_drain_phys
		if("Fire")              return passive_drain_fire
		if("Ice")               return passive_drain_ice
		if("Elec")              return passive_drain_elec
		if("Force")             return passive_drain_force
	return FALSE

// Apply ailments based on +Status passives. Grimoire boosts the chance, Ultimate Hit
// applies all almighty debuffs.
/mob/Player/AI/Demon/proc/DemonPassiveAddAilments(mob/target)
	if(!target) return
	var/grimoire_mult = passive_grimoire_active ? 1.75 : 1.0
	if(passive_add_paralyze && prob(passive_add_paralyze * grimoire_mult))
		target.AddShock(20, src)
	if(passive_add_poison && prob(passive_add_poison * grimoire_mult))
		target.AddPoison(20, src)
	if(passive_add_stone && prob(passive_add_stone * grimoire_mult))
		target.AddSlow(25, src)
	if(passive_ultimate_hit_active)
		// Almighty debuffs: poison, shock, slow, cripple — apply all on every hit
		target.AddShock(15, src)
		target.AddPoison(15, src)
		target.AddSlow(15, src)
		target.AddCrippling(15, src)

// Crit chance
/mob/Player/AI/Demon/proc/DemonPassiveCritBonus()
	if(!passive_handler) return 0
	return passive_handler.Get("CriticalChance")

// Crit damage
/mob/Player/AI/Demon/proc/DemonPassiveCritDmgMult()
	if(!passive_handler) return 1.5
	return 1.0 + passive_handler.Get("CriticalDamage")

// Victory Cry: on enemy kill, restore HP/Energy (this is useless but I can't think of how to change it atm)
/mob/Player/AI/Demon/proc/DemonPassiveOnKill(mob/dead)
	if(passive_victory_cry)
		demon_hp = min(100, demon_hp + 25)
		var/datum/party_demon/pd = DemonGetPartyDemon()
		if(pd) pd.current_hp = demon_hp
		if(ai_owner)
			ai_owner.HealEnergy(15)

// Race-O and Race-D (also kinda useless but I'll figure something out later)
/mob/Player/AI/Demon/proc/DemonPassiveRaceMult(mob/other, attacking)
	if(!demon_data || !other) return 1.0
	if(istype(other, /mob/Player/AI/Demon))
		var/mob/Player/AI/Demon/od = other
		if(od.demon_data && od.demon_data.demon_race == demon_data.demon_race)
			if(attacking && passive_race_o) return 1.20
			if(!attacking && passive_race_d) return 0.80
	return 1.0

/mob/Player/AI/Demon/proc/HasDemonPassive(pname)
	if(!applied_passives) return FALSE
	return (pname in applied_passives)
